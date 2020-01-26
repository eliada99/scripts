#!/bin/sh
#New script - easy to edit - easy to use!
#By Eliad Avraham - 

globalCommand='' #Global variable - Will save the user
globalFWToburn=''
globalyesOrNo=''
chooseServer=''

#function displayMainMenu used to print the UI
function displayMainMenu(){
	echo "-------------------------------------------------------"
	echo "--------- Choose Which Command To Run -----------------"
	echo "****************** Installations **********************"
	echo "-- 1)  - Install nfs-utils, autofs, ypbind on ARM  ----"
	echo "-- 2)  - Install iperf & netperf on your host  --------"
	echo "-- 3)  - Install iperf3 (arch64)  ---------------------"
	echo "-- 4)  - Install MFT latest  --------------------------"
	echo "-- 5)  - Install MLNX_OFED_LINUX  ---------------------"
    echo "********************** Usb Host ***********************"
	echo "-- 6)  - Copy new SOC version to your /root  ----------"
	echo "-- 7)  - Copy OFED to your ARM side  ------------------"
	echo "-- 8)  - Find errors in dmesg  ------------------------"
	echo "-- 9)  - Find errors in /var/log/messages  ------------"
	echo "-- 10) - Run setup.sh script for smartnic bring-up ----"
	echo "-- 11) - Reset your ARM with b.py script  -------------"
	echo "-- 12) - Configure host interfaces with script  -------"
	echo "-- 13) - Remote reboot option  ------------------------"
	echo "-- 14) - Load interfaces on your USB HOST  ------------"
	echo "-- 15) - Config trusted to route - HOST  --------------"
	echo "-- 16) - Copy NFS files to ARM  -----------------------"
    echo "********************** A-R-M  *************************"
	echo "-- 17) - Set bridges in your ARM openvswitch ----------"
	echo "-- 18) - Modprobe and route in ARM  -------------------"
	echo "-- 19) - ifdown ifup eth0 in ARM ----------------------"
	echo "-- 20) - enable and restart nfs services --------------"
    echo "********************** B-O-T-H ************************"
	echo "-- 21) - Burn FW on your smartNIC  --------------------"
	echo "-- 22) - Run Mlxfwreset on your DUT  ------------------"
	echo "-- 23) - Clear /var/log/messages  ---------------------"
	echo "-- 24) - Clear /var/log/dmesg  ------------------------"
	echo "-- 25) - Create OVS with bridges  ---------------------"
	#echo "-- ) - "
	#echo "-- ) - "
	echo "*******************************************************"
	echo "* Please enter your choice - press CTRL + C to exit ***"
	echo "*******************************************************"
}
#End of function displayMainMenu


#function checkWhichServerChoosen - convert the user input to real IP and other server details
# $1 - User input
function checkWhichCommandChoosen(){
	case "$1" in 
		'1')installNFSOnARM ;;
		'2')installIperfNetperf;;
		'3')installIperf3ARCH64 ;;
		'4')installMFTLatest ;;
		'5')installMlnxOfed;;
		'6')copyNewSOCVerToRoot ;;
		'7')copyOFEDToARM;;
		'8')findErrorsInDmesg ;;
		'9')findErrorsInMessages ;;
		'10')runSetupSHScript ;;
		'11')resetARM ;;
		'12')configInterface ;;
		'13')remoteReboot ;;
		'14')loadInterfaces ;;
		'15')configTrusted ;;
		'16')copyNFSFilesToARM ;;
		'17')configBridges ;;
		'18')routeInARM ;;
		'19')ifdownIfup ;;
		'20')enableRestart;;
		'21')burnFwFunc;;
		'22')mlxfwresetOnDUT ;;
		'23')clearVarLogMessages;;
		'24')clearVarLogDmesg;;
		'25')createOvs;;

		 *)#clear  #Execute this section in every char/number that not appears above
		   echo '---------------------------------------------------------'
		   echo '--You have entered Wrong Input - its a good day to die!--'
		   echo '---------------------------------------------------------'
		   exit;;  #Kill the script
	esac #End of internal case - option 1
}
#end of function checkWhichServerChoosen


function createOvs(){
	echo "" #new line
	echo "Set the bridges and add ports:  --"
		systemctl restart openvswitch
		ovs-vsctl del-br BondBr
		ovs-vsctl del-br Br1
		ovs-vsctl del-br connTrackBr1
		ovs-vsctl add-br connTrackBr1
		ovs-vsctl add-port connTrackBr1 rep0-0
		ovs-vsctl add-port connTrackBr1 rep0-ffff

		ovs-vsctl del-br connTrackBr2
		ovs-vsctl add-br connTrackBr2
		ovs-vsctl add-port connTrackBr2 rep1-0
		ovs-vsctl add-port connTrackBr2 rep1-ffff

		ifconfig rep0-0 up
		ifconfig rep0-ffff up

		ifconfig rep1-0 up
		ifconfig rep1-ffff up

		ovs-vsctl set Open_vSwitch . other_config:hw-offload=true
		systemctl restart openvswitch

}
function burnFwFunc(){

	echo "" #new line
    echo "----------------------------------------------------"
	echo "Please type FW number in format e.g: xx_xx_xxxx:  --"
	read globalFWToburn
	echo "----------------------------------------------------"
	echo '----------------------------------------------------'
        echo "--Do you want to burn $globalFWToburn FW now [y/n]?              --"
        read globalyesOrNo
	echo '----------------------------------------------------'
        if [[ $globalyesOrNo == "y" ]]; then
	mlxfwmanager -d /dev/mst/mt41682_pciconf0 -D /mswg/release/host_fw/fw-41682/fw-41682-rel-"$globalFWToburn"-build-001/etc/bin/ -u -y -f
	globalyesOrNo='n'
        fi
	
}

function installIperfNetperf(){

	echo '----------------------------------------------------'
        echo "--Do you want to install iperf now [y/n]?        --"
        read globalyesOrNo
	echo '----------------------------------------------------'
        if [[ $globalyesOrNo == "y" ]]; then
           	/.autodirect/mswg/projects/ver_tools/reg2_latest/install.sh
		globalyesOrNo='n'			
        fi
}

function installIperf3ARCH64(){
	echo '----------------------------------------------------'
        echo "--Do you want to install iperf3-arch64 now [y/n]?--"
        read globalyesOrNo
        echo '----------------------------------------------------'
        if [[ $globalyesOrNo == "y" ]]; then
		yum install iperf3 -y
                globalyesOrNo='n'
        fi
}

function installMFTLatest(){
        echo '----------------------------------------------------'
        echo "--Do you want to install LATEST MFT now [y/n]?--"
        read globalyesOrNo
        echo '----------------------------------------------------'
        if [[ $globalyesOrNo == "y" ]]; then
        /.autodirect/mswg/release/mft/latest/install.sh
	globalyesOrNo='n'
        fi
}

function installMlnxOfed(){
	echo "----------------------------------------------------"
	echo "Please type OFED version in format e.g: 4.2-1.4.19.0--"
        read globalFWToburn
	echo '----------------------------------------------------'
        echo "--Do you want to install OFED for HOST now [y/n]?--"
        read globalyesOrNo
        echo '----------------------------------------------------'
        if [[ $globalyesOrNo == "y" ]]; then
			yum install unbound -y
			build=MLNX_OFED_LINUX-"$globalFWToburn" /.autodirect/mswg/release/MLNX_OFED/mlnx_ofed_install --with-rshim
			globalyesOrNo='n'
        fi


}

function copyNewSOCVerToRoot(){
	echo "" #new line
        echo "----------------------------------------------------"
        echo "Please type SOC version in format e.g: 1.0.alpha6.10489--"
        read globalFWToburn
        echo "----------------------------------------------------"
        echo '----------------------------------------------------'
        echo "--Do you want to copy $globalFWToburn SOC now [y/n]?--"
        read globalyesOrNo
        echo '----------------------------------------------------'
        if [[ $globalyesOrNo == "y" ]]; then
        	tar "-xvf" /mswg/release/sw_mc_soc/BlueField-"$globalFWToburn"/BlueField-"$globalFWToburn".tar.xz "-C" /root
		#tar "-xvf" /mswg/release/sw_mc_soc/BlueField-2.0.alpha1.10742/BlueField-2.0.alpha1.10742.tar.xz
		globalyesOrNo='n'
        fi
}


function copyOFEDToARM(){
        echo "" #new line
        echo "----------------------------------------------------"
        echo "Please type OFED version in format e.g: 4.2-1.4.18.0  --"
        read globalFWToburn
        echo "----------------------------------------------------"
        echo '----------------------------------------------------'
        echo "--Do you want to copy $globalFWToburn OFED ver now [y/n]?--"
        read globalyesOrNo
        echo '----------------------------------------------------'
        if [[ $globalyesOrNo == "y" ]]; then
        scp -r /.autodirect/mswg/release/MLNX_OFED/MLNX_OFED_LINUX-"$globalFWToburn"/MLNX_OFED_LINUX-"$globalFWToburn"-rhel7.4alternate-aarch64 192.168.100.2:/opt
		globalyesOrNo='n'
        fi
}


function findErrorsInDmesg(){
	echo '----------------------------------------------------'
	dmesg | grep 'synd\|err\|assert\|Call\|ERR\|err\|fatal\|fw\|kernel\|crash'
    echo '----------------------------------------------------'
}

function findErrorsInMessages(){
    echo '----------------------------------------------------'
	cat /var/log/messages | grep -Ei "fatal|Oops|CQ overrun|error|mlx.*fail|call trace|mlx.*temperature|assert|health compromised" | grep -Eiv "ACPI|ERST|Error Record Serialization Table|anaconda-generator|ioapic|abrt-oops|/dev/sdc|init: Failed to open system console, retrying|probe of i8042|usb.*device descriptor read|/dev/sda|Btrfs|NetworkManager|PIT calibration matches HPET|adding VLAN 0 to HW filter on device|gnome-session|exited with error code|rsyslog|systemd-remount-fs|kdumpctl: cat: write error: Broken pipe|add_ipv4_to_acl|Continuing with errors|libvirtd|systemd-udevd: error: /dev/sdb: No medium found|error.+in libcrypto.so|nl_recv returned with error|mlxrpc|libopensm.so|Device .* does not seem to be present, delaying|required key missing - tainting kernel|usb.*device not accepting address|usb.*read configuration|ntpd.*Too many errors|HEST: Enabling Firmware First mode for corrected errors|mlnx_interface_mgr\.sh|\/unix\/.*\.c:|GHES: Poll interval is.*for generic hardware error source|mcelog read: Input/output error|ipmievb|Machine check events logged|Failed to spawn splash-manager main process|Failed to init debugfs files for|Bringing up interface|sshd|udev_monitor_receive_device|rngd|EDAC|mce|PCC|USB device|nrpe|mlx5e_dcbnl_setall, Failed to validate ETS: -22|Get SEL Info command failed|libmozjs|abrt\-|GPT error|ata\d+\.\d|Failed to validate ETS: BW sum is illegal|generic hardware error source|Error changing net interface name|megaraid_sas|irqbalance.*segfault|freedesktop|rshim: fifo_read_callback: failed submitting interrupt urb, error -8|Request for unknown module key 'Mellanox Technologies signing key:/.*' err -11|localhost mlnx_interface_mgr.sh: Error: Connection activation failed: .*|Bringing up interface tmfifo_net0: .*"
	echo '----------------------------------------------------'
}


function runSetupSHScript(){
	echo "" #new line
        echo "----------------------------------------------------"
        echo "Please type SOC version in format e.g: 1.0.alpha6.10489--"
        read globalFWToburn
        echo '----------------------------------------------------'
        echo "--Do you want to run setup.sh for $globalFWToburn SOC now [y/n]?--"
        read globalyesOrNo
        echo '----------------------------------------------------'
        if [[ $globalyesOrNo == "y" ]]; then
	BlueField-"$globalFWToburn"/distro/rhel/pxeboot/setup.sh -d BlueField-"$globalFWToburn"/ -i CentOS-7-aarch64-Everything.iso -c ttyAMA0
                globalyesOrNo='n'
        fi
}

function resetARM(){
	echo '----------------------------------------------------'
        echo "--Do you want to reset ARM now [y/n]?--"
        read globalyesOrNo
        echo '----------------------------------------------------'
        if [[ $globalyesOrNo == "y" ]]; then
			echo "SW_RESET 1" > /dev/rshim0/misc
			globalyesOrNo='n'
        fi

}


function configInterface(){
	echo '----------------------------------------------------'
        echo "--Do you want to Configure Interfaces now [y/n]?--"
        read globalyesOrNo
        echo '----------------------------------------------------'
        if [[ $globalyesOrNo == "y" ]]; then
	/.autodirect/QA/qa/smart_nic/scripts/mlnx_config.sh -m en -s s
        globalyesOrNo='n'
        fi
}


function configBridges(){
        echo '----------------------------------------------------'
        echo "--Do you want to Configure Bridges now [y/n]?--"
        read globalyesOrNo
        echo '----------------------------------------------------'
        if [[ $globalyesOrNo == "y" ]]; then
	/.autodirect/QA/qa/smart_nic/scripts/setupConnTrackBridge.sh
        globalyesOrNo='n'
        fi
}



function remoteReboot(){
        echo '----------------------------------------------------'
        echo "Please type host to RR in format e.g: '10.136.30.60'--"
        read globalFWToburn
        echo '----------------------------------------------------'
	echo '----------------------------------------------------'
        echo "--Do you want to Start RR script now [y/n]?      --"
        read globalyesOrNo
        echo '----------------------------------------------------'
        if [[ $globalyesOrNo == "y" ]]; then
	/mswg/utils/bin/rreboot "$globalFWToburn"
        globalyesOrNo='n'
        fi
}

function loadInterfaces(){
        echo '----------------------------------------------------'
        echo "--Do you want to load interfaces now [y/n]?      --"
        read globalyesOrNo
        echo '----------------------------------------------------'
        if [[ $globalyesOrNo == "y" ]]; then
		modprobe rshim_usb
		modprobe rshim_net
        	ifdown tmfifo_net0
        	ifup tmfifo_net0
        	systemctl restart dhcpd
        	systemctl restart tftp
        	globalyesOrNo='n'
        fi
}


function routeInARM(){
        echo '----------------------------------------------------'
        echo "--Do you want to route in ARM now [y/n]?      --"
        read globalyesOrNo
        echo '----------------------------------------------------'
        if [[ $globalyesOrNo == "y" ]]; then
		modprobe eth0
		ifconfig eth0 192.168.100.2/24 up
		route add default gw 192.168.100.1
		echo "Execute the following commands: "
		echo "1. modprobe eth0" 
		echo "2. ifconfig eth0 192.168.100.2/24 up"
		echo "3. route add default gw 192.168.100.1"
                globalyesOrNo='n'
        fi
}


function configTrusted(){
        echo '----------------------------------------------------'
        echo "Please type host trusted interface, Ex: eth0      --"
        read globalFWToburn
        echo '----------------------------------------------------'
        echo '----------------------------------------------------'
        echo "--Do you want to config trusted interface now [y/n]?      --"
        read globalyesOrNo
        echo '----------------------------------------------------'
        if [[ $globalyesOrNo == "y" ]]; then
		modprobe rshim_net
		systemctl restart dhcpd
		echo 1 > /proc/sys/net/ipv4/ip_forward
		iptables -t nat -A POSTROUTING -o "$globalFWToburn" -j MASQUERADE;
		echo "Execute the following commands: "
		echo "1. modprobe rshim_net"
                echo "2. systemctl restart dhcpd"
                echo "3. echo 1 > /proc/sys/net/ipv4/ip_forward"
                echo "4. iptables -t nat -A POSTROUTING -o "$globalFWToburn" -j MASQUERADE"
        	globalyesOrNo='n'
        fi
}


function ifdownIfup(){
        echo '----------------------------------------------------'
        echo "--Do you want to restart eth0 inter now [y/n]?      --"
        read globalyesOrNo
        echo '----------------------------------------------------'
        if [[ $globalyesOrNo == "y" ]]; then
		ifdown eth0
		ifup eth0
                echo "Execute the following commands: "
                echo "1. ifdown eth0"
		echo "2. ifup eth0"
                globalyesOrNo='n'
        fi
}

function copyNFSFilesToARM(){
        echo '----------------------------------------------------'
        echo "--Do you want to copy NFS files to ARM now [y/n]?      --"
        read globalyesOrNo
        echo '----------------------------------------------------'
        if [[ $globalyesOrNo == "y" ]]; then
		scp -r /.autodirect/QA/qa/smart_nic/files/nfs-utils-autofs-ypbind/* 192.168.100.2:/etc
                echo "Execute the following commands: "
                echo "1. scp -r /.autodirect/QA/qa/smart_nic/files/nfs-utils-autofs-ypbind/* 192.168.100.2:/etc "
                globalyesOrNo='n'
        fi
}


function installNFSOnARM(){
	echo '----------------------------------------------------'
        echo "--Do you want to install NFS on ARM now [y/n]?      --"
        read globalyesOrNo
        echo '----------------------------------------------------'
        if [[ $globalyesOrNo == "y" ]]; then
		yum -y install nfs-utils
		yum -y install autofs
		yum -y install ypbind
                echo "Execute the following commands: "
                echo "1. yum -y install nfs-utils "
		echo "2. yum -y install autofs"
		echo "3. yum -y install ypbind"
                globalyesOrNo='n'
        fi
}


function mlxfwresetOnDUT(){
	echo '----------------------------------------------------'
	echo "Must run it from the HOST side only![--skip_fsm_sync flag in use]"
        echo '----------------------------------------------------'
        echo "--Do you want to execute MLXFWRESET now [y/n]?    --"
        read globalyesOrNo
        echo '----------------------------------------------------'
        if [[ $globalyesOrNo == "y" ]]; then
		mst restart
		mlxfwreset -d /dev/mst/mt41682_pciconf0 -l 3 reset -y --skip_fsm_sync
                echo "Execute the following commands: "
                echo "1. mst restart"
		echo "2. mlxfwreset -d /dev/mst/mt41682_pciconf0 -l 3 reset -y --skip_fsm_sync"
                globalyesOrNo='n'
        fi
}

function enableRestart(){
        echo '----------------------------------------------------'
        echo "--Do you want to restart NFS services on ARM [y/n]?-"
        read globalyesOrNo
        echo '----------------------------------------------------'
        if [[ $globalyesOrNo == "y" ]]; then
		systemctl enable ypbind; systemctl enable autofs; systemctl enable nfs; systemctl enable rpcbind;
		systemctl restart ypbind; systemctl restart autofs; systemctl restart nfs;
                echo "Execute the following commands: "
                echo "1. systemctl enable ypbind; systemctl enable autofs; systemctl enable nfs; systemctl enable rpcbind;
			 systemctl restart ypbind; systemctl restart autofs; systemctl restart nfs;"
                globalyesOrNo='n'
        fi
}

function clearVarLogMessages(){
        echo '----------------------------------------------------'
        echo "--Do you want to CLEAR /var/log/MESSAGES [y/n]?  ---"
        read globalyesOrNo
        echo '----------------------------------------------------'
        if [[ $globalyesOrNo == "y" ]]; then
		echo "" >/var/log/messages
		cat /var/log/messages
		globalyesOrNo='n'
	fi
}

function clearVarLogDmesg(){

       echo '----------------------------------------------------'
        echo "--Do you want to CLEAR /var/log/DMESG   [y/n]?  ---"
        read globalyesOrNo
        echo '---------------------------------------------------'
        if [[ $globalyesOrNo == "y" ]]; then
		dmesg -c
		dmesg -c
                globalyesOrNo='n'
        fi
}






#Main Menu:
while true; do
	#clear
	displayMainMenu #Dispaly UI on screen
	read chooseServer #User input
	checkWhichCommandChoosen $chooseServer #Save the needed IP according to user input
	#actionOnServerWithIpmiTool #Execute  
	echo ''
	echo ''
	echo ''
	echo "------------------------------------------------------"
	echo '--       Press any key to continue...               --'
	echo '------------------------------------------------------'
	echo '--                                                  --'
	echo '------------------------------------------------------'
	echo '--       Press CTRL+C to exit..                     --'
	echo '------------------------------------------------------'
	read enter
done


