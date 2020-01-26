#!/bin/bash
#To Create use
#/.autodirect/mthswgwork/davidtu/OVS_OFFLOAD/scripts/create_remove_mdev.sh -p <pci_device_in_bf> -n <number_of_mdevs>
#For example:
#/.autodirect/mthswgwork/davidtu/OVS_OFFLOAD/scripts/create_remove_mdev.sh -p 0000:03:00.0 -n 8
#To Remove:
#/.autodirect/mthswgwork/davidtu/OVS_OFFLOAD/scripts/create_remove_mdev.sh -p “<mdevs_uuids>”

#To Mapped between them use:
#/.autodirect/mthswgwork/davidtu/OVS_OFFLOAD/scripts/mapped-mdevs-reps.sh -p 0000:03:00.0


function usage(){
        echo -e "This script will Create or Remove VFIO Mediated devices \n"

        echo "  -h|--help           : Will show this help message"
        echo "  -r|--uuid_to_remove : UUID's to remove"
        echo "  -p|--pci_Device     : PCI Device of the physical function"
        echo "  -n|--num_mdev       : Number of mdev to create, by default it's 1"
        echo
        echo "For Example Remove: create_remove_mdev.sh -r \"0de2e04-7f99-4812-a0a6-f33dd7409742 49d0e9ac-61b8-4c91-957e-6f6dbc42557d\" "
        echo "For Example Create: create_remove_mdev.sh -p 0000:03:00.0 -n 2"
       exit 1
}



#Function that run command on hosts
function run_cmd() {
        echo "      $@"
            if ! eval "$@"; then
                printf "\nFailed executing $@\n"
                exit 1
            fi
}

#Generate random uuid on host
function generate_uuid(){
        uuidgen
}


#Get maximum number of Supported SFs by FW
function get_maxmdev(){
        cat /sys/class/net/$ifs/device/mdev_supported_types/mlx5_core-local/max_mdevs
}


#Get the available_instances how many more mdev we can to create
function get_available(){
        cat /sys/class/net/$ifs/device/mdev_supported_types/mlx5_core-local/available_instances

}



function get_ifs_by_pci(){
        local pci=$1
        ls /sys/bus/pci/devices/$pci/net/
}

function unbind_bind(){
        local uuid=$1
        local driver="$2"
        local action="$3"

        run_cmd "echo $uuid > /sys/bus/mdev/drivers/"$driver"/"$action""

}

function set_mac_addr(){
        local uuid=$1
        local physicalfn=$2
        local mac_addr=""

        pre_mac=$(cat /sys/class/net/$physicalfn/address | cut -d: -f1-2)

                for i in {1..4}; do
                random_2_chars=`cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 2 | head -1`
                mac_addr="$mac_addr:$random_2_chars"
                done
                mac_addr="$pre_mac$mac_addr"

        run_cmd "echo $mac_addr > /sys/bus/mdev/devices/$uuid/devlink-compat-config/mac_addr"

}


#Get maximum number of Supported SFs:
function create_mdev(){
        local ifs=$1
        local mdevs=$2
        local pci_device=$3
        local new_uuid=""
        local max_mdev=$(get_maxmdev)
        local available_mdev=$(get_available)

                if [[ $mdevs -gt $max_mdev ]] ; then
                        echo "There is not enough mdev in FW"
						                       exit 1
                elif [[ $mdevs -gt $available_mdev ]] ; then
                        echo "There is not enough resources available in the system"
                        echo "The available mdev's are $available_mdev and you request $mdevs"
                        exit 1
                fi


        for ((mdev=0; mdev<$mdevs ; mdev++)) ; do
           echo "Generating new UUID for mdev $((mdev+1))"
                new_uuid=$(generate_uuid)
           echo "Creating new mdev $((mdev+1))"
                run_cmd "echo $new_uuid > /sys/bus/pci/devices/$pci_device/mdev_supported_types/mlx5_core-local/create"
           echo "Unbind mdev from his own driver"
                unbind_bind $new_uuid "vfio_mdev" "unbind"
           echo "Set mac address for mdev interface"
                set_mac_addr $new_uuid $ifs
           echo "Bind mdev to MLX5_CORE driver"
                unbind_bind $new_uuid "mlx5_core" "bind"
        echo
        done

echo done..

}


# Function to remove mdev
function remove_mdev(){
        local uuids="$1"
        for uuid in $uuids ; do
            `ls /sys/bus/mdev/devices/ | grep $uuid > /dev/null`
                if [[ $? != 0 ]] ; then
                        echo "Something wrong with current UUID $uuid"

                else
                        echo "Removing...."
                        run_cmd "echo 1 > /sys/bus/mdev/devices/$uuid/remove"
                        echo "UUID $uuid has been removed"
                echo
                fi
        done
  exit 0;
}

#Main

if [[ -z $1 ]] ; then usage ; exit 1 ; fi
if [[ -n $1 ]] && [[ -z $2 ]] ; then usage ; exit 1 ; fi

#Check flags arguments
while [[ $# -gt 0 ]]
 do
        key="$1"

 case $key in
    -p|--pci_device)
    pci_device="$2"
    shift # past argument
    ;;

    -n|--num_mdev)
    mdev=${2:-1}
    shift # past argument
    ;;

    -r|--uuid_to_remove)
    uuid_to_remove="$2"
    shift #past argument
    remove_mdev "$uuid_to_remove"
        #Remove uuid configured
    ;;

    -h|--help|*)
        echo "Error, unsupported parameter: $1"
        usage
        exit 1
            # unknown option
    ;;

 esac
 shift # past argument or value
done



ifs=$(get_ifs_by_pci $pci_device)

#Go to Create.

create_mdev $ifs $mdev $pci_device
                                        
