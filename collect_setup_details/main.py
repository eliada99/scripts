import sys
import re
import subprocess
import paramiko
import time
import datetime
import threading

#My proj. inc.
from host_linux import host_linux
import utilities



class SomeThread(threading.Thread):
    def __init__(self,ip):
        threading.Thread.__init__(self)
        self.ip = ip

    def run(self):
        #print self.ip
        self.instance = host_linux(self.ip)


def get_user_choice():
    print("------------------------------------------------------------------\n")
    res = raw_input("--- Are you want to save the servers details in new file[y/n]?----\n")
    print("------------------------------------------------------------------\n")
    if re.findall('y|Y', res):
        return True
    elif re.findall('n|N', res):
        return False
    print ("Bad Request!")
    exit(2) #close the app

#create new file and save objects details
def save_objects_in_file(setup):
    try:
        file_path = "/.autodirect/QA/qa/smart_nic/debug_files_eliad/servers_details_"+str(datetime.date.today())+".txt"
        f = open(file_path,"w+")
    except:
        print("Fail to create the file: "+file_path)
    for host in setup:
        try:
            f.write("HostName:     %s\r\n" % (str(host.instance.ip)))
            f.write("Ofed Info:    %s\r\n" % (str(host.instance.ofed_info)))
            f.write("MST Version:  %s\r\n" % (str(host.instance.mst_version)))
            f.write("MST Device:   %s\r\n" % (str(host.instance.mst_device)))
            f.write("FW Version:   %s\r\n" % (str(host.instance.fw)))
            f.write("Rom Info:     %s\r\n" % (str(host.instance.exp_rom)))
            f.write("PCI:          %s\r\n" % (str(host.instance.pci)))
            f.write("Board Id:     %s\r\n" % (str(host.instance.board_id)))
            f.write("Part Number:  %s\r\n" % (str(host.instance.part_number)))
            f.write("------------------------------------------\n")
        except:
            #f.write("HostName:     %s\r\n" % (str(host.ip)))
            f.write("Fail to save the content of this host\r\n")
            f.write("------------------------------------------\n")
    print("\r\n------------------------------------------\n")
    utilities.reporter("Check running report in: "+file_path+"\n",'green')
    print("------------------------------------------\n")
    f.close()

def usage():
    utilities.reporter("\r\nUsage: ",'red')
    print("python " + sys.argv[0] + " bfdell01 10.7.15.1")
    utilities.reporter("\r\nYou can run few servers in parallel.\r\nThen save the results in file or print the output in your local machine\r\n",'red')
    exit(2) #close the app




###################################### Main Menu ##########################################
if __name__ == '__main__':
    if re.findall('-h|--help|\?', sys.argv[1]):
        usage()
        
    setup = []
    saveInFile = get_user_choice()

    for host in sys.argv[1:]: #start from the second cell
        t = SomeThread(host)
        obj = t.start()
        setup.append(t)
    for t in setup:
        t.join()
    print ('All Threads are done!')        
    '''End Of: create objects according the inputs servers'''

    '''Create file and save server details inside - if saveInFile true'''
    if saveInFile:
        save_objects_in_file(setup)
    else:
        for host in setup:
            print host.instance.print_content()

    #def close_me_daddy():