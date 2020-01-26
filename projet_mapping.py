#!/usr/bin/python
"""
 By Eliad Av [Daddi] - eliada@mellanox.com
 The script collect data from our automation project [need to set specific path in this variable: glob_project_path]
 pull the file description from #START.. over #END..
 pull the functions and description
 The whole data above save in file [need to set specific path in this variable: glob_res_file]
"""

import os
import re


glob_start_file_desc = '#START_OF_FILE_DESCRIPTION:'
glob_end_file_desc = '#END_OF_FILE_DESCRIPTION'
glob_project_path = 'Y:\\eliada\\repositories\\qa_automation_perl_BlueField'
glob_res_file = 'Y:\\eliada\\Automation_beckup\\automation_hierarchy.txt'


files = []
desc = 0
# r=root, d=directories, f=files
for r, d, f in os.walk(glob_project_path):
    for file in f:
        if '.pm' in file: # save only the perl files
            files.append("----------------- Start Of " + file + "-----------------")
            files.append(os.path.join(r, file))
            file_full_path = os.path.join(r, file)
            with open(file_full_path) as tmp_file: # open the file and mapping only files with description
                if glob_start_file_desc in tmp_file.read():
                    content = []
                    with open(file_full_path) as tmp_file:
                        for line in tmp_file:
                            if line.strip() == glob_start_file_desc:
                                content.append(line)
                                break
                        for line in tmp_file:
                            content.append(line)
                            if line.strip() == glob_end_file_desc: # here we finish with the description
                                content.append("\nFile functions with description:\n")
                                for line in tmp_file: # start and save the functions
                                    if any(x in line for x in ('# PURPOSE:', '# DESCRIPTION:')):
                                         desc = line
                                    if any(x in line for x in ('sub ',)):
                                         line = re.findall(r'(sub\s\w+).*', line)[0]
                                         content.append("   " + line + " =>")
                                         content.append("   " + str(desc))
                        files.append(content)
            files.append("----------------- End Of " + file + "-----------------\n\n")

# create result file and save the content [file from global]
res_file = open(glob_res_file, "w+")
for f in files:
    if isinstance(f, list):
        for l in f:
            res_file.write(l)
        res_file.write('\n')
    else: res_file.write(f + '\n')
res_file.close()

Daddi_break_me = 1
