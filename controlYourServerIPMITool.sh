#!/bin/bash
#New script - control my server - easy to edit - easy to use!
#By Eliad Avraham - PXE Team

globalChoose=0.0.0.0   #Global variable - Will be save the user input and convert it to IP
globalServerName=''    #Global variable - Will be save the server name and print it with ipmitool command
globalUserName=''      #Global variable - Will be save the user name of current server
globalUserPass=''      #Global variable - Will be save the user password of current server

#function displayMainMenu used to print the UI
function displayMainMenu
{
	echo "" #new line
	echo "---------------------------------------------------------"
	echo "-----Restart your server and BOOT to BIOS/O.S/PXE--------"
	echo "---------------------------------------------------------"
	echo "--             Choose your server :                    --"
	echo "---------------------------------------------------------"
	echo "---------------LENOVO Servers----------------------------"
	echo "--                                                     --"
	echo "---Enter 1 for - IP: 10.7.102.34  - qaibm056           --"
	echo "---Enter 2 for - IP: 10.7.102.169 - pxelnv069          --"
	echo "---Enter 3 for - IP: 10.7.101.30  - pxelnv030          --"
	echo "---Enter 4 for - IP: 10.7.96.16   - pxelnv170          --"
	echo "---Enter 5 for - IP: 10.7.6.168   - pxeibm168          --"
        echo "---Enter 64 for- IP: 10.7.102.247 - pxelnv070          --"
	echo "---Enter 100 for all servers - Not implemented yet     --"
	echo "---------------------------------------------------------"
	echo "------------Ibm Blade - CX3 only:------------------------"
	echo "---Enter 10 for - IP: 10.7.40.224  - Bay 11            --"
	echo "---Enter 11 for - IP: 10.7.43.112  - Bay 13            --"
	echo "---Enter 12 for - IP: pxezt123                         --"
	echo "---Enter 13 for - IP: pxezt124                         --"
	echo "---------------------------------------------------------"
	echo "--------------Guests servers:----------------------------"
	echo "---Enter 20 for - IP: 10.7.126.8 - Olympus MSFT(CX3)   --"
	echo "---Enter 21 for - IP: pxefuj01                         --"
	echo "---Enter 22 for - IP: pxequalcomm16                    --"
	echo "---------------------------------------------------------"
        echo "---------------HP Servers--------------------------------"
	echo "---Enter 23 for - IP: pxehp87  (Gen10)                 --"
	echo "---Enter 24 for - IP: pxehp206 (Gen10)                 --"
	echo "---Enter 25 for - IP: pxehp091                         --"
	echo "---Enter 26 for - IP: pxehp049                         --"
	echo "---Enter 27 for - IP: pxehp237                         --"
	echo "---Enter 28 for - IP: pxehp013                         --"
	echo "---Enter 29 for - IP: pxehp070                         --"
	echo "---------------------------------------------------------"
	echo "---------------DELL Servers------------------------------"
	echo "---Enter 50 for - IP: pxedell011                       --"
	echo "---Enter 51 for - IP: pxedell126                       --"
	echo "---Enter 52 for - IP: pxedell047                       --"
	echo "---Enter 53 for - IP: pxedell167                       --"
	echo "---Enter 54 for - IP: pxedell012                       --"
	echo "---Enter 55 for - IP: Dell baldur 242                  --"
	echo "---Enter 56 for - IP: Dell baldur 241                  --"
	echo "---Enter 57 for - IP: Dell baldur 240                  --"
	echo "---Enter 58 for - IP: oracle:perf-uek-01               --"
        echo "---------------Fujitsu Servers---------------------------"
        echo "---Enter 59 for - IP: pxefuj03                         --"
        echo "---Enter 60 for - IP: pxefuj04                         --"
        echo "---Enter 63 for - IP: qa-fjs04                         --"
	echo "---------------------------------------------------------"
        echo "---------------Stark-Lenovo Servers----------------------"
        echo "---Enter 61 for - IP: qa-stark01                       --"
        echo "---Enter 62 for - IP: qa-stark03                       --"
        echo "---Enter 65 for - IP: qalenovo-11                      --"  
        echo "---------------------------------------------------------"
	echo "---Enter bfdell01 		-----------------------"
	echo "---Enter bfdell02                 -----------------------"
        echo "---Enter bfint02                  -----------------------"
        echo "---Enter bfint03                  -----------------------"
	echo "*********************************************************"
	echo "*** Please enter your choice - press CTRL + C to exit ***"
	echo "*********************************************************"
}
#End of function displayMainMenu


#function checkWhichServerChoosen - convert the user input to real IP and other server details
# $1 - User input
function checkWhichServerChoosen
{
	case "$1" in 
                '1')globalChoose=10.7.102.34 globalServerName='qaibm056' globalUserName='root' globalUserPass='3tango11';;
                '2')globalChoose=10.7.102.169 globalServerName='pxelnv069' globalUserName='root' globalUserPass='3tango11';;
                '3')globalChoose=10.7.101.30 globalServerName='pxelnv030' globalUserName='root' globalUserPass='3tango11';;
                '4')globalChoose=10.7.96.16 globalServerName='pxelnv170' globalUserName='USERID' globalUserPass='PASSW0RD';;
		'5')globalChoose=10.7.97.168 globalServerName='pxeibm168' globalUserName='root' globalUserPass='3tango11';;
                '10')globalChoose=10.7.40.224 globalServerName='Ibm Blade-Bay 11' globalUserName='root' globalUserPass='3tango11';;
                '11')globalChoose=10.7.43.112 globalServerName='Ibm Blade-Bay 13' globalUserName='root' globalUserPass='3tango11';;
		'12')globalChoose=10.7.98.230 globalServerName='pxezt123' globalUserName='admin' globalUserPass='admin';;
		'13')globalChoose=10.7.100.194 globalServerName='pxezt124' globalUserName='rcon' globalUserPass='3tango11';;
		'20')globalChoose=10.7.126.8 globalServerName='Olympus MSFT' globalUserName='admin' globalUserPass='admin';;
		'21')globalChoose=10.7.99.243 globalServerName='pxefuj01' globalUserName='admin' globalUserPass='admin';;
		'22')globalChoose=10.7.103.67 globalServerName='pxequalcomm16' globalUserName='root' globalUserPass='3tango11!';;
		'23')globalChoose=10.7.101.204 globalServerName='pxehp87 (GEN 10)' globalUserName='rcon' globalUserPass='3tango11';;
		'24')globalChoose=10.7.99.233 globalServerName='pxehp206 (HPE Gen10)' globalUserName='root' globalUserPass='3tango11';;
		'25')globalChoose=10.7.103.91 globalServerName='pxehp091' globalUserName='root' globalUserPass='3tango11';;
		'26')globalChoose=10.7.102.49 globalServerName='pxehp049' globalUserName='root' globalUserPass='3tango11';;
		'27')globalChoose=10.7.4.236 globalServerName='pxehp237' globalUserName='root' globalUserPass='3tango11';;
		'28')globalChoose=10.7.101.13 globalServerName='pxehp013' globalUserName='root' globalUserPass='3tango11';;
		'29')globalChoose=10.7.102.70 globalServerName='pxehp070' globalUserName='root' globalUserPass='3tango11';;
		'50')globalChoose=10.7.116.11 globalServerName='pxedell011' globalUserName='root' globalUserPass='3tango11';;
		'51')globalChoose=10.7.104.126 globalServerName='pxedell126' globalUserName='root' globalUserPass='3tango11';;
		'52')globalChoose=10.7.103.47 globalServerName='pxedell047' globalUserName='root' globalUserPass='3tango11';;
		'53')globalChoose=10.7.101.56 globalServerName='pxedell167' globalUserName='root' globalUserPass='3tango11';;
		'54')globalChoose=10.7.114.196 globalServerName='pxedell012' globalUserName='root' globalUserPass='3tango11';;
		'55')globalChoose=10.7.112.142  globalServerName='pxedell242' globalUserName='root' globalUserPass='3tango11';;
		'56')globalChoose=10.7.112.87  globalServerName='pxedell241' globalUserName='root' globalUserPass='3tango11';;
		'57')globalChoose=10.7.112.86  globalServerName='pxedell240' globalUserName='root' globalUserPass='3tango11';;
                '58')globalChoose=10.7.118.1  globalServerName='perf-uek-01' globalUserName='root' globalUserPass='3tango11';; 
                '59')globalChoose=10.7.105.132 globalServerName='pxefuj03' globalUserName='admin' globalUserPass='admin';;
                '60')globalChoose=10.7.105.134 globalServerName='pxefuj04' globalUserName='admin' globalUserPass='admin';;
                '61')globalChoose=10.7.99.251 globalServerName='qa-stark01' globalUserName='USERID' globalUserPass='PASSW0RD';;
                '62')globalChoose=10.7.99.253 globalServerName='qa-stark03' globalUserName='USERID' globalUserPass='PASSW0RD';;
                '63')globalChoose=10.7.104.39 globalServerName='qa-fjs04' globalUserName='rcon' globalUserPass='3tango11';;
                '64')globalChoose=10.7.102.247 globalServerName='pxelnv070' globalUserName='root' globalUserPass='3tango11';;
                '65')globalChoose=10.7.106.111 globalServerName='qalenovo11' globalUserName='USERID' globalUserPass='PASSW0RD';;
		'bfdell01')globalChoose=10.7.116.3 globalServerName='bfdell01' globalUserName='root' globalUserPass='3tango11';;
		'bfdell02')globalChoose=10.7.106.3 globalServerName='bfdell02' globalUserName='root' globalUserPass='3tango11';;
		'bfint02')globalChoose=bfint02-ilo globalServerName='bfint02' globalUserName='root' globalUserPass='3tango11';;
		'bfint03')globalChoose=bfint03-ilo globalServerName='bfint03' globalUserName='root' globalUserPass='3tango11';;
		

		 *)clear  #Execute this section in every char/number that not appears above
		   echo '---------------------------------------------------------'
		   echo '--You have entered Wrong Input - its a good day to die!--'
		   echo '---------------------------------------------------------'
		   exit;;  #Kill the script
	esac #End of internal case - option 1
}
#end of function checkWhichServerChoosen


#function actionOnServerWithIpmiTool - user need to choose the action that will active
function actionOnServerWithIpmiTool
{
	
	clear #Clear the screen
	echo "" #new line
        echo "---------------------------------------------------------------"
        echo "--                Choose your next command:                  --"
	echo "---------------------------------------------------------------"
        echo "------ $globalChoose $globalServerName - ipmitool commands   --"
	echo "---------------------------------------------------------------"
        echo "--Enter 1 for - boot to BIOS                                 --"
        echo "--Enter 2 for - boot to O.S                                  --"
        echo "--Enter 3 for - boot to PXE                                  --"
        echo "--Enter 4 for - power on                                     --"
	echo "--Enter 5 for - power off                                    --"
	echo "--Enter 6 for - power on and Entering BIOS                   --"
	echo "--Enter 7 for - power on and Entering O.S                    --"
	echo "--Enter 8 for - Reset                                        --"
	echo "--Enter 9 for - Status                                       --"
	echo "--Enter 10 for - Serial Over Lan [SOL]                       --"
	echo "---------------------------------------------------------------"
        echo "" #new line
        echo "" #new line
        echo "****************************************************************"
        echo "******* Please enter your choice - press CTRL + C to exit ******"
        echo "****************************************************************"
        read userChoice #User input
        clear #Clear your screen
	echo "-------------- $globalChoose $globalServerName ------------------" 

	
		case "$userChoice" in #Internal case - option 1
                '1')
                ipmitool -I lanplus -H "$globalChoose" -U "$globalUserName" -P "$globalUserPass" chassis bootdev bios  #Boot to bios
                ipmitool -I lanplus -H "$globalChoose" -U "$globalUserName" -P "$globalUserPass" chassis power reset
                echo "Boot to BIOS for server IP: "$globalChoose" - $globalServerName - DONE!"
		echo '---------------------------------------------------------------';;
                '2')
                ipmitool -I lanplus -H "$globalChoose" -U "$globalUserName" -P "$globalUserPass" chassis bootdev disk  #Boot to disk
                ipmitool -I lanplus -H "$globalChoose" -U "$globalUserName" -P "$globalUserPass" chassis power reset
                echo "Boot to O.S for server IP: "$globalChoose" - $globalServerName - DONE!"
		echo '---------------------------------------------------------------';;
                '3')
                ipmitool -I lanplus -H "$globalChoose" -U "$globalUserName" -P "$globalUserPass" chassis bootdev pxe options=persistent   #Boot to PXE
                ipmitool -I lanplus -H "$globalChoose" -U "$globalUserName" -P "$globalUserPass" chassis power reset
                echo "Boot to PXE for server IP: "$globalChoose" - $globalServerName - DONE!"
		echo '---------------------------------------------------------------';;
		'4')
                ipmitool -I lanplus -H "$globalChoose" -U "$globalUserName" -P "$globalUserPass" chassis power on
                echo "Power on server IP: "$globalChoose" - $globalServerName - DONE!"
		echo '---------------------------------------------------------------';;
		'5')
                ipmitool -I lanplus -H "$globalChoose" -U "$globalUserName" -P "$globalUserPass" chassis power off
                echo "Power off server IP:"$globalChoose" - $globalServerName - DONE!"
		echo '---------------------------------------------------------------';;
		'6')
		ipmitool -I lanplus -H "$globalChoose" -U "$globalUserName" -P "$globalUserPass" chassis power on
		echo 'Im sleeping 5 seconds, Hold on... '
		sleep 5 #Let the machine time to wake up
		echo '---------------------------------------------------------------'
		ipmitool -I lanplus -H "$globalChoose" -U "$globalUserName" -P "$globalUserPass" chassis bootdev bios  #Boot to bios
                ipmitool -I lanplus -H "$globalChoose" -U "$globalUserName" -P "$globalUserPass" chassis power reset
		echo "Power on server IP: "$globalChoose" - $globalServerName - DONE!"
		echo "Boot to BIOS for server IP: "$globalChoose" - $globalServerName - DONE!"
		echo '---------------------------------------------------------------';;
		'7')
                ipmitool -I lanplus -H "$globalChoose" -U "$globalUserName" -P "$globalUserPass" chassis power on
                echo 'Im sleeping 5 seconds, Hold on... '
                sleep 5 #Let the machine time to wake up
                echo '---------------------------------------------------------------'
                ipmitool -I lanplus -H "$globalChoose" -U "$globalUserName" -P "$globalUserPass" chassis bootdev disk
                ipmitool -I lanplus -H "$globalChoose" -U "$globalUserName" -P "$globalUserPass" chassis power reset
                echo "Power on server IP: "$globalChoose" - $globalServerName - DONE!"
                echo "Boot to O.S for server IP: "$globalChoose" - $globalServerName - DONE!"
                echo '---------------------------------------------------------------';;
		'8')
		ipmitool -I lanplus -H "$globalChoose" -U "$globalUserName" -P "$globalUserPass" chassis power reset
		echo "Reset for server IP: "$globalChoose" - $globalServerName - DONE!";;
		'9')
		ipmitool -I lanplus -H "$globalChoose" -U "$globalUserName" -P "$globalUserPass" chassis status
		echo '---------------------------------------------------------------'
		;;
		'10')
		ipmitool -I lanplus -H "$globalChoose" -U "$globalUserName" -P "$globalUserPass" sol -e @ activate
		echo "Start S-O-L for server "$globalChoose" - "$globalServerName" - DONE!"
        	esac #End of internal case - option 1
}
#End of function actionOnServerWithIpmiTool


#Main Menu:
while true; do
	clear
	displayMainMenu #Dispaly UI to user
	read chooseServer #User input
	checkWhichServerChoosen $chooseServer #Save the needed IP according to user input
	actionOnServerWithIpmiTool #Execute  
	echo ''
	echo ''
	echo ''
	echo "---------------------------------------------------------------"
	echo '--            Press any key to continue...                   --'
	echo '---------------------------------------------------------------'
	echo '--                                                           --'
	echo '---------------------------------------------------------------'
	echo '--            Press CTRL+C to exit..                         --'
	echo '---------------------------------------------------------------'
	read enter
done

