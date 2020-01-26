#!/usr/bin/perl

use Term::ANSIColor;
   
print "\n";
our $conf_path = "/etc/sysconfig/network-scripts/";

######################   check parameters and set flags  $$$$$$$$$$$$$$$$$$$$$$$$$$$$$
my %params = ("-h"=>"--help", "-d"=>"--driver", "-b"=>"--backup", "-i"=>"--start_interface", "-v"=>"--verbose");
$i=0;
$j=0;
$verbose=0;
$start_iface = "10";
foreach $param (@ARGV) {
	if ($j){
		$j = 0;
		next;
	}
	@keys = keys %params;
	@values = values %params;
	$exists = 0;
	foreach (@keys){
		$exists = 1 if ($_ eq $param);
	}
	foreach (@values) {
		$exists = 1 if ($_ eq $param);
	}
	if (0 == $exists){
		print color("red"), "Wrong param: $param\n\n\n", color("reset");
		goto USAGE2;		
	}
	if ($param eq "-i" || $param eq "--start_interface"){
		if ($ARGV[$i+1] !~ /[a-z]+\d+/)	{
			goto USAGE;
		}
		else {
			$ARGV[$i+1] =~ /[a-z]+(\d+)/;
			$start_iface = $1;
			$j=1;
		}
	}
	goto USAGE if (($param eq "-h") || ($param eq "--help"));
	$backup=1 if (($param eq "-b") || ($param eq "--backup"));
	$driver=1 if (($param eq "-d") || ($param eq "--driver"));
	$verbose=1 if (($param eq "-v") || ($param eq "--verbose"));
	$i++;
}


######  Get trusted interface and ip  ##########
my $trusted_ip;
my $trusted_iface;
foreach (`ifconfig | grep "10.7" -B1 `){
	if ($_ =~ /\D(10\.7\.\d+\.\d+)/){;
		$trusted_ip = $1;
		last;
	}
}
foreach (`ifconfig | grep "$trusted_ip" -B1`){
	if ($_ =~ /^(\w+)[:\s]+[L|f]/){;
		$trusted_iface = $1;
		last;
	}
}

$trusted_iface =~ /(\d+)/;
$trusted_num = $1;


#########   get OS and define target path  ########
my @os_type = `cat /etc/issue`;
foreach (@os_type){
	if ($_ =~ /suse/i){
		$conf_path = "/etc/sysconfig/network/";
		last;
	}
}




#########   remove (+backup) any existing interface definitions  ########
print "\nBacking up existing configuration files ... " if ($backup);
print "\nRemoving existing configuration files ... " if (!$backup);
print "\n" if ($verbose);
$folder="/tmp/network-scripts-backup/";
`mkdir $folder 2>&1` if ($backup);
@files = `ls $conf_path | grep ifcfg | grep -v ifcfg-ib 2>&1;`;
foreach (@files) {
	next if ($_ =~ /$trusted_iface|ifcfg-lo/);
	chomp($_);
	$old = $conf_path.$_;
	if ($backup){ 
		print ("\tmv $old $folder\n") if ($verbose);
		`mv $old $folder`;	
	}
	else { 
		print "\trm -f $old\n" if ($verbose);
		`rm -f $old`;
	}
}
`sleep 1;`;
print color("green"), "done", color("reset");
`sleep 1;`;
print "\n\n";

########  splitting IP address and creating parts  ########
$trusted_ip =~ /10\.(.+)/;
$ip_suffix = $1;
$network_suffix = ".7.0.0";
$bcast_suffix = ".7.255.255";


print "\nCreating new configuration files ... ";
print "\n" if ($verbose);

########  get mst devices  ########
$out = `mst start`;
my @devices;
foreach (`mst status`){
        next if /4113/;
	if (/(\/dev\/mst\/mt\d{4}_pciconf\d)\s+/) {
		if ($verbose) {print "Device found: $&\n"}
                push @devices, $&;
        }
}

########  creating new interfaces  ########
my $val = $start_iface;
my $MAC2;
foreach $mst_dev (@devices){
	chomp $mst_dev;
	$mst_dev =~ s/\s//g;
	$MAC2 = 0;
	print "\n\tDevice: $mst_dev\n" if ($verbose);
	$val += 10 if ($trusted_num == $val);
	$fname = $conf_path."ifcfg-eth$val";
	my $MAC = "";
	$mst_dev =~ /mt41(\d+)_pciconf(\d)/;
	my $start = $1;
	my $end = $2;
	$start =  ($start =~ /1(\d)/) ? $1 : $start;
	foreach (`/.autodirect/QA/danielbr/my_scripts/MAC_extract.pl $start $end`){
		if ($_ =~ /MAC:\s+([a-zA-Z0-9\:]+[a-zA-Z0-9])/){
			$MAC = $1;
			@arr = split /:/, $MAC;
			if ($arr[0] eq "00" && $arr[1] eq "00"){
				$arr[0] = "";
				$arr[1] = "";
				$MAC = join(':', @arr);
			}
		}
                if ($_ =~ /MAC2:\s+([a-zA-Z0-9\:]+)/){
                        $MAC2 = $1;
                        @arr = split /:/, $MAC2;
                        if ($arr[0] eq "00" && $arr[1] eq "00"){
                                $arr[0] = "";
                                $arr[1] = "";
                                $MAC2 = join(':', @arr);
                        }
                }
	}
	if ($MAC eq "") {
		print "Coudln`t read MAC from $mst_dev, skipping\n";
		next;
	}
	if ($verbose){
		print "\t\tInterface name for $mst_dev:\t\t\teth$val\n";
		print "\t\tMAC for $mst_dev:\t\t\t\t$MAC\n";
		
	}
	$dual = 0;
	$tmp = `flint -d $mst_dev dc | grep Desc | egrep -i '2port|2-port|dual|2x'`;
	$dual = 1 if ($? == 0);
	$tmp1 = `flint -d $mst_dev q | grep secure`;
	$dual = 1 if ($? == 0);
	
	open(OUT,">$fname") || die "Can't create output file: $!";
	$oldhandle = select OUT;
   
	print "DEVICE=eth$val\n";
	print "HWADDR=$MAC\n";
	print "BOOTPROTO=static\n";
	print "IPADDR="; print (100+$val); print ".$ip_suffix\n";
	print "NETMASK=255.255.0.0\n";
	print "NETWORK=".(100+$val).$network_suffix."\n";
	print "BROADCAST=".(100+$val).$bcast_suffix."\n";
	print "ONBOOT=yes\n";
	print "TYPE=Ethernet\n";
	print "MTU=1500\n";
	print "STARTMODE=auto\n";
	close OUT;
	select $oldhandle;
	system("sleep 0.5");
   
	if ($dual){
		@array = split /:/, $MAC;
		$string = $array[5];
		$x = ($string =~ /^0.$/) ? 1 : 0;
		$string = hex($string);
		$string++;
		$array[5] = sprintf "%X", $string;
		if ($x) { $array[5] = "0".$array[5];}
		$MAC1 = join(':', @array);
		$MAC1 = $MAC2 if ($MAC2);
		$val++;		
		$fname = $conf_path."ifcfg-eth$val";
		if ($verbose){
			print "\t\t2nd interface name for $mst_dev:\t\teth$val\n";
			print "\t\tMAC for $mst_dev 2nd interface:\t\t\t$MAC1\n" ;			
		}		
		
		open(OUT,">$fname") || die "Can't create output file: $!";
		$oldhandle1 = select OUT;
		print "MAC for $mst_dev se: $MAC\n" if ($verbose);
		print "DEVICE=eth$val\n";
		print "HWADDR=$MAC1\n";
		print "BOOTPROTO=static\n";
		print "IPADDR="; print (100+$val); print ".$ip_suffix\n";
		print "NETMASK=255.255.0.0\n";
		print "NETWORK=".(100+$val).$network_suffix."\n";
		print "BROADCAST=".(100+$val).$bcast_suffix."\n";
		print "ONBOOT=yes\n";
		print "TYPE=Ethernet\n";
		print "MTU=1500\n";
		print "STARTMODE=auto\n";
		close OUT;
		select $oldhandle1;
	}
#	$val++;
	if ($dual) 	{$val += 9;}
	else 		{$val += 10;}
}

print color("green"), "done", color("reset");
`sleep 0.5;`;
print "\n";

print color("green"), "\n\nInterface files were created successfully \n\n", color("reset");
`sleep 0.5;`;
die "\n" unless $driver;


########  restart driver  ########
$sm_flag = 0;
system("rm -rf /etc/udev/rules.d/70-persistent-net.rules");
foreach (`/etc/init.d/opensmd status`) {
	if (/is running/){
		print "\nStopping SM ... \n\n";
		$sm_flag = 1;
		`pkill opensm`;
		`sleep 1`;
		print "SM stopped ... \n";
	}
}
print "\nRestarting driver ... \n\n";
$o = system("/etc/init.d/openibd restart");
`sleep 0.5;`;
print "\nDriver has been restarted successfully ...\n\n";
`sleep 0.5;`;
if ($sm_flag){
	print "\nStarting SM ... \n\n";
	$o = system("/etc/init.d/opensmd start");
	print "\n\n";
}
`sleep 0.5;`;
print color("green"), "Done!\n", color("reset");
color("reset");
`sleep 0.5;`;
print "\n";
system("ibdev2netdev");
die "\n";


##########################  usage instructions ####################
USAGE:
print color("blue"), "Description\n", color("reset");
print color("blue"), "===========\n", color("reset"); 
print "The script configures ETH interfaces for all devices available on host.\n";
print "All previous ETH config files are removed (see options below for backup existing configuration).\n";
print "New interfaces names will start with \e[4meth10\e[24m , unless specified using -i flag.\n";
print "New interfaces IPs will start with \e[4m110.X.X.X\e[24m , and will be 120, 130, etc for each device.\n";
print "\n\n";

USAGE2:
print color("red"), "  Usage :  ", color("reset");
print "./eth_interfaces_config.pl [-d | --driver] [-b | --backup] [-i ifname] [-v | --verbose] [-h | --help]\n\n";
print "    -d  | --driver	Remove udev rules and restart driver after configuring interfaces\n";
print "    -b  | --backup	Move old definition files to /tmp/network-scripts-backup\n";
print "    -v  | --verbose	Add printings in the process\n";
print "    -i			Name of first interface, e.g. eth20\n";
print "    -h  | --help	Display help menu\n";
print "\n\n";
