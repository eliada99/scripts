import os
import re
import subprocess
import sys
import utilities
import paramiko
import time

PORT = 22
USERNAME = 'root'
PASSWORD = '3tango'

class host_linux:
    def __init__(self,host_ip):
        err=0
        print ("------------------------------------------")
        utilities.reporter("Start to build host_linux object of host: "+host_ip,'blue')
        try:
            client = paramiko.Transport((host_ip, PORT))
            client.connect(username=USERNAME, password=PASSWORD)
        except:
            utilities.reporter("No connection to host: "+host_ip+" -> Object not created!",'red')
            print ("------------------------------------------\n")
            return None

        try:     
            #session = client.open_channel(kind='session')
            #output  = utilities.run_command_on_session(session,'hostname')
            self.ip = host_ip
            time.sleep(0.5)
        except:
            utilities.reporter("Cant pull the hostname with command: hostname",'red')
            self.ip = 'Cant pull the hostname with command: hostname'
            err=1
            
        try:
            session = client.open_channel(kind='session')
            output = utilities.run_command_on_session(session,'mst start')
            time.sleep(0.5)
        except:
            print("Fail to run the command: mst start")
            return None
        
        try:    
            session = client.open_channel(kind='session')
            output  = utilities.run_command_on_session(session,'ofed_info -s')
            self.ofed_info = re.findall('\w+\-(\d\.\d\-\d\.\d\.\d+\.\d)', output)[0]
            time.sleep(0.5)
        except:
            print("Fail to pull the ofed version")
            self.ofed_info = "Fail to pull the ofed version"
            err=1

        try:    
            session = client.open_channel(kind='session')
            output  = utilities.run_command_on_session(session,'mst version')
            self.mst_version = re.findall('mst\W+mft\s(\d\.\d+\.\d\-\d+).*', output)[0]
            time.sleep(0.5)
        except:
            print("Fail to pull the mst version")
            self.mst_version = "Fail to pull the mst version"
            err=1

        try:   
            session = client.open_channel(kind='session')
            output  = utilities.run_command_on_session(session,'mst status -v')
            self.mst_device = re.findall('\W+(/dev/mst/mt\d+\_\w+\d).*', output)[0]
            time.sleep(0.5)
        except:
            print("Fail to pull the mst device with command: mst status -v")
            self.mst_device = "Fail to pull the mst device with command: mst status -v"
            err=1

        try:   
            session = client.open_channel(kind='session')
            output  = utilities.run_command_on_session(session,"flint -d "+self.mst_device+" q | grep -i fw | grep -i version")
            self.fw = re.findall('FW\sVersion\:\s+(\d{2}\.\d{2}\.\d{4})', output)[0]
            time.sleep(0.5)
        except:
            print("Fail to pull the FW version with flint query")
            self.fw = "Fail to pull the FW version with flint query"
            err=1

        try:  
            session = client.open_channel(kind='session')
            output  = utilities.run_command_on_session(session,"flint -d "+self.mst_device+" q | grep -i rom")
            self.exp_rom = re.findall('Rom\sInfo\:\s+(.*)', output)[0]
            time.sleep(0.5)
        except:
            print("Fail to pull the Rom Info with flint query")
            self.exp_rom = "Fail to pull the Rom Info with flint query"
            err=1

        try:  
            session = client.open_channel(kind='session')
            output  = utilities.run_command_on_session(session,'mst status -v')
            self.pci = re.findall('(\d{2}\:\d{2}\.0).*', output)[0]
            time.sleep(0.5)     
        except:
            print("Fail to pull the PCI with mst status command")
            self.pci = "Fail to pull the PCI with mst status command"
            err=1

        try:    
            session = client.open_channel(kind='session')
            output  = utilities.run_command_on_session(session,'mlxburn -d '+self.mst_device+' -vpd')
            self.board_id = re.findall('.*Board\sId\s+(.*)', output)[0]
            time.sleep(0.5)     
        except:
            print("Fail to pull the board id with mlxburn -d <device> -vpd")
            self.board_id = "Fail to pull the board id with mlxburn -d <device> -vpd"
            err=1

        try:   
            session = client.open_channel(kind='session')
            output  = utilities.run_command_on_session(session,'mlxburn -d '+self.mst_device+' -vpd')
            self.part_number = re.findall('.*Part\sNumber\s+(.*)', output)[0]
            time.sleep(0.5)            
        except:
            print("Fail to pull the part number with mlxburn -d <device> -vpd")
            self.part_number = "Fail to pull the part number with mlxburn -d <device> -vpd"
            err=1
        
        utilities.reporter("host_linux object created successfully!",'green')
        if err: utilities.reporter("1 or more fields is missing in this host_linux object!",'red')
        #self.print_content()
    

    def print_content(self):
        utilities.reporter("Printing the attributes of Host_linux Object:",'bold')
        try:
            print ("Host Name:     " + self.ip + "\n" +
                   "Ofed Info:     " + self.ofed_info + "\n" +
                   "MST Version:   " + self.mst_version + "\n" +
                   "MST Device:    " + self.mst_device + "\n" +
                   "FW Version:    " + self.fw + "\n" +
                   "Rom Info:      " + self.exp_rom + "\n" +
                   "PCI:           " + self.pci + "\n" +
                   "Board Id:      " + self.board_id + "\n" +
                   "Part Number:   " + self.part_number + "\n" +
                   "------------------------------------------\n")
        except:
            print("Fail to print the object attributes!\n" +
            "------------------------------------------\n")

