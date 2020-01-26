import subprocess
import re
import os
import sys
import paramiko


def run_cmd(cmd ,output=0):
    cmd = ['sudo'] + cmd.split(' ');
    if output:
        proc = subprocess.Popen(cmd)
    else:
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

    out, err = proc.communicate()
    return out


#EXAMPLE: self.ofed_info = utilities.run_cmd_and_regex('ofed_info -s','\w+\-(\d\.\d\-\d\.\d\.\d+\.\d)')
def run_cmd_and_regex(cmd, regex, ret1stOnly=1):
	array = []
	output = run_cmd(cmd).split('\n')
	for line in output:
            #print str(line)+"\n"
            reg = re.findall(regex, line)
            print reg
            if reg:
                return reg[0]
        return None
    
def regex_output(regex, output, ret1stOnly=1):
	#output = run_cmd(cmd).split('\n')
	for line in output:
            reg = re.findall(regex, line)
            if reg:
                return reg
        return None


#Example call: utilities.reporter("Created successfully: " + ip,'green')
def reporter(toPrint ,color):
    if   color == 'red':
        sys.stdout.write("\033[1;31m")  # print text in red
    elif color == 'green':
        sys.stdout.write("\033[0;32m")  # print text in green
    elif color == 'blue':
        sys.stdout.write("\033[1;34m")  # print text in blue
    elif color == 'bold':
        sys.stdout.write("\033[;1m")  # print text in bold
    print(toPrint)  # print it after add the color to string
    sys.stdout.write("\033[0;0m")  # no colors or formatting - back to the default


def connect_to_host_and_run_cmd(hostname,username,password,command):
    nbytes = 4096
    port = 22

    client = paramiko.Transport((hostname, port))
    client.connect(username=username, password=password)

    stdout_data = []
    stderr_data = []
    session = client.open_channel(kind='session')
    session.exec_command(command)
    while True:
        if session.recv_ready():
            stdout_data.append(session.recv(nbytes))
        if session.recv_stderr_ready():
            stderr_data.append(session.recv_stderr(nbytes))
        if session.exit_status_ready():
            break

    #print 'exit status from '+hostname+' :', session.recv_exit_status()
    output = ''.join(stdout_data)
    session.close()
    client.close()
    return output


def display_details_in_table(num_of_lines,fields,parameters):
    print "Name\t\t\tnumeric grade\t\tlettergrade"
    print "---------------------------------------------------------------"
    #print "%s:\t\t\t%f\t\t%s" % ('name1', 50, 'F')
    #print "%s:\t\t\t%f\t\t%s" % ('name2', 50, 'F')
    #print "%s:\t\t\t%f\t\t%s" % ('name3', 23, 'F')
    #print "%s:\t\t\t%f\t\t%s" % ('name4', 44, 'F')
    #print "%s:\t\t\t%f\t\t%s" % ('name5', 48, 'F')
    print "---------------------------------------------------------------"




############################################



def run_command_on_session(session,command):
    nbytes = 4096
    stdout_data = []
    stderr_data = []
    session.exec_command(command)
    while True:
        if session.recv_ready():
            stdout_data.append(session.recv(nbytes))
        if session.recv_stderr_ready():
            stderr_data.append(session.recv_stderr(nbytes))
        if session.exit_status_ready():
            break
    output = ''.join(stdout_data)
    return output

def close_client_and_session(session,client):
    session.close()
    client.close()
    print ("Pass to close client and session")





