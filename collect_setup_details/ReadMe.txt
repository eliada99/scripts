Connect to server/s and pull some usueful information.
Working in parallel, connect to few server together.

How to:
	1. cd /.autodirect/QA/qa/smart_nic/scripts/collect_setup_details
	2. python main.py bfdell01 bfdell02
	3. Choose if save the content in file or not(the path is HC).
	4. See the output in file or on console
	

	
Output example:
------------------------------------------
Start to build host_linux object of host: bfdell01
host_linux object created successfully!
All Threads are done!
Printing the attributes of Host_linux Object:
Host Name:     bfdell01
Ofed Info:     4.4-2.5.11.0
MST Version:   4.11.0-103
MST Device:    /dev/mst/mt41682_pciconf0
FW Version:    18.24.1000
Rom Info:      type=UEFI version=14.17.11 cpu=AMD64,AARCH64
PCI:           08:00.0
Board Id:      BlueField(TM) SmartNIC 25GbE dual-port SFP28, PCIe Gen3.0/4.0 x8, BlueField(TM) G-Series 16 Cores, Crypto enabled, 16GB on-board DDR, tall bracket, HHHL, ROHS R6
Part Number:   MBF1M332A-ASCAT
------------------------------------------




Will fail in the following cases:
	1. Server is down
	2. No OFED driver install
	3. More than 2 devices enabled
	4. To use only over Linux machine
	5. enjoy