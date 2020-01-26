#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Config::Abstract::Ini;


use constant {
    PXE_AND_UEFI        =>"PXE_and_UEFI",
    LINUX_DRIVERS       =>"Linux_Drivers",
    CONNECTX4_FIRMWARE  =>"ConnectX4_Firmware",
    BLUEFIELD           =>"BlueField",
};

our $AUTOMATION_PATH;
our $exit_status = 0;
our @arr_pxe_files;
our @arr_linux_drivers_files;
our @arr_fw_files;
our @arr_blufield_files;
our $if_success_all_project = 1;
our $test_index = 1;


reporter::title("Start to check if exist files with the same name in projects PXE_AND_UEFI, LINUX_DRIVERS, CONNECTX4_FIRMWARE, BLUEFIELD");
check_automation_path(); 
my_main();



# FUNCTION NAME: my_main
# WRITTEN BY: Eliad Avraham
# DATE: 07-05-2018
# PURPOSE: running functions
# NOTES:
# HISTORY:
# IN PARAMS:
# OPTIONAL: 
# RETURNED VALUES:
# Sample call: my_main();
sub my_main{
    
    #path to the needed project by $AUTOMATION_PATH variable
    my $dir_bluefield = $AUTOMATION_PATH."/".BLUEFIELD;
    my $dir_driver = $AUTOMATION_PATH."/".LINUX_DRIVERS;
    my $dir_pxe = $AUTOMATION_PATH."/".PXE_AND_UEFI;
    my $dir_fw= $AUTOMATION_PATH."/".CONNECTX4_FIRMWARE;
    
    #fill arrays with files names with 'search_dir' sub
    search_dir ($dir_bluefield);
    search_dir ($dir_driver);
    search_dir ($dir_pxe);
    search_dir ($dir_fw);
    
    #sort based on ASCII order
    @arr_pxe_files = sort @arr_pxe_files;
    @arr_linux_drivers_files = sort @arr_linux_drivers_files;
    @arr_fw_files = sort @arr_fw_files;
    @arr_blufield_files = sort @arr_blufield_files;
    
    #check a against b,c and d
    check_if_exist_dup_files(\@arr_pxe_files,\@arr_linux_drivers_files,PXE_AND_UEFI,LINUX_DRIVERS);
    check_if_exist_dup_files(\@arr_pxe_files,\@arr_fw_files,PXE_AND_UEFI,CONNECTX4_FIRMWARE);
    check_if_exist_dup_files(\@arr_pxe_files,\@arr_blufield_files,PXE_AND_UEFI,BLUEFIELD);
    
    #check b against c and d
    check_if_exist_dup_files(\@arr_linux_drivers_files,\@arr_fw_files,LINUX_DRIVERS,CONNECTX4_FIRMWARE);
    check_if_exist_dup_files(\@arr_linux_drivers_files,\@arr_blufield_files,LINUX_DRIVERS,BLUEFIELD);
    
    #check c against d
    check_if_exist_dup_files(\@arr_fw_files,\@arr_blufield_files,CONNECTX4_FIRMWARE,BLUEFIELD);

    if ($if_success_all_project) {
        reporter::pass("Test passed! Not found any duplicate files in all projects!\n");
        return;
    }
    reporter::fail("Test failed! Found files from a different projects with the same name!\n");
    
    return;
}



# FUNCTION NAME: search_dir
# WRITTEN BY: Eliad Avraham
# DATE: 07-05-2018
# PURPOSE: save .pm files in relevant array
# NOTES:
# HISTORY:
# IN PARAMS:
# OPTIONAL: 
# RETURNED VALUES:
# Sample call: search_dir($dir_fw);
sub search_dir {
    my ($dir) = @_;
    
    my $dh;
    if ( !opendir ($dh, $dir)) {
        warn "Unable to open $dir: $!\n";
        return;
    }
    
    # Two dummy reads for . & ..
    readdir ($dh);
    readdir ($dh);
    
    while (my $file = readdir ($dh) ) {
    
        my $path = "$dir/$file";    # / should work on UNIX & Win32
        
        if ( -d $path ) {
            #print "Directory $path found\n";
            search_dir ($path); 
        }
        
        else {
            if ($dir =~ /pxe_and_uefi/i) {
                push (@arr_pxe_files, $file) if ($file =~ /.pm/);
            }
                 elsif($dir =~ /linux_drivers/i){
                     push (@arr_linux_drivers_files, $file) if ($file =~ /.pm/);  
                 }
                    elsif($dir =~ /ConnectX4_Firmware/i){
                       push (@arr_fw_files, $file) if ($file =~ /.pm/);   
                    }
                        elsif($dir =~ /bluefield/i){
                            push (@arr_blufield_files, $file) if ($file =~ /.pm/);  
                        }
        }
    }
    
    closedir ($dh);
}





sub check_automation_path {
    $AUTOMATION_PATH = $ENV{AUTOMATION_PATH};
    if (!$AUTOMATION_PATH) {
        reporter::fail("Empty environment variable: AUTOMATION_PATH\n");
        exit $exit_status;
    }
    
    $AUTOMATION_PATH .= '/' if ($AUTOMATION_PATH !~ /\/$/);   #Add / to the path
    $AUTOMATION_PATH .= 'projects';
}






sub check_if_exist_dup_files($$$$){
    my ($fir_arr,$sec_arr,$fir_proj_name,$sec_proj_name) = @_;
    my @arr1 = @{$fir_arr}; #dereference array
    my @arr2 = @{$sec_arr};
    my $status = 1;
    
    for (my $i=0; $i < scalar(@arr1); $i++) {
        for (my $j=0; $j < scalar(@arr2); $j++) {
            if ($arr1[$i] eq $arr2[$j]){
                reporter::fail("Test number $test_index: Found two files from a different projects with the same name: $fir_proj_name: $arr1[$i], $sec_proj_name: $arr2[$j]");
                $status = 0;
                $if_success_all_project = 0;
                $test_index++;
            }
        }
    }
        if ($status == 1) {
           reporter::pass("Test number $test_index: Not found files with the same name at projects: $fir_proj_name and $sec_proj_name");
           $test_index++;
        }
}
  
  
  
    
##################
package reporter;

    sub fail {
        my ($message) = @_;
        print "\n\e[5m\x1b[31;1mFAIL:\t\t\x1b[0m".$message."\n"; # Red and blinking
        $exit_status = 1;
    }
    
    sub pass {
        my ($message) = @_;
        print "\n\x1b[32;1mPASS:\t\t\x1b[0m".$message."\n"; # Green
    }
    
    sub warning {
        my ($message) = @_;
        print "\n\x1b[33;1mWARNING:\t\x1b[0m".$message."\n"; # Yellow orange
    }
    
    sub info {
        my ($message) = @_;
        print "\n\x1b[34;1m".$message."\x1b[0m\n"; # Blue
    }
    
    sub title {
        my ($message) = @_;
        my $length = length($message);
        print "\n\x1b[36;1m".'=' x $length."\n\x1b[0m";
        print "$message\n";
        print "\x1b[36;1m".'=' x $length."\n\x1b[0m";
    }
    
    sub prompt {
        my ($message) = @_;
        print $message;
        my $answer = <STDIN>;
        chomp $answer;
        new_line();
        return $answer;
    }
    
    sub new_line {
        print "\n";
    }
    
    
    
    
    