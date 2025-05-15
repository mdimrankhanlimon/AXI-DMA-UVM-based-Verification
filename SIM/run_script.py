#!/bin/python3

#-----------------------------------------------
#    Design      : RUN_SCRIPT 
#    Designer    : shazarul.islam@siliconova.com
#    company     : Siliconova Limited
#
#    Version     : 1.1
#    Created     : 25 Apr, 2024
#    Last updated: 06 April, 2025   
#------------------------------------------------


from test_list import *
import re
import subprocess
import os
import shutil
import glob
import argparse
import time  
import random
from datetime import datetime
#dut_name=
cadence_path= "/home/cadence/lnx/xce_23/tools.lnx86/methodology/UVM/CDNS-1.2" 
coverage_switch = "-coverage all -covoverwrite -covfile cov.ccf  -covdut tb_top -assert_count_traces -nowarn COVSEC -assert_logging_error_off"


#--------------------------------------
#  User Variable Section  for xcelium
#--------------------------------------
#command for elaboration
elab_cmd_xrun = f"xrun -access +rwc -timescale 1ns/1ps -sv -sysv -f rtl_files.f -f tb_files.f -uvm -uvmhome {cadence_path} +fsmdebug -snapshot tb_top_snap >> flow_logfile.txt  -createdebugdb -elaborate -log ./elaborate/run_elaboration.log"
#command for elaboration with coverage
elab_cmd_xrun_with_coverage = f"xrun -access +rwc -timescale 1ns/1ps -sv -sysv -f rtl_files.f -f tb_files.f -uvm -uvmhome {cadence_path} {coverage_switch} +fsmdebug -snapshot tb_top_snap >> flow_logfile.txt  -createdebugdb -elaborate -log ./elaborate/run_elaboration.log"

run_cmd_xrun = "xrun -r tb_top_snap >> flow_logfile.txt "
#run_cmd_xrun = "xrun -r tb_top_snap "

debug_cmd_xrun = f"xrun -access +rwc -timescale 1ns/1ps -sv -sysv -f rtl_files.f  -f tb_files.f -uvm -uvmhome {cadence_path} {coverage_switch} +fsmdebug -snapshot tb_top_snap >> flow_logfile.txt -createdebugdb -input debug_script.tcl"
#debug_cmd_xrun = f"xrun -access +rwc -timescale 1ns/1ps -sv -sysv -f rtl_files.f  -f tb_files.f -uvm -uvmhome {cadence_path} +fsmdebug -snapshot tb_top_snap -createdebugdb -input debug_script.tcl"

# COmmand for elaboration and then simulation at a time
elab_and_run_xrun_with_coverage = f"xrun -access +rwc -timescale 1ns/1ps -sv -sysv -f rtl_files.f -f tb_files.f -uvm -uvmhome {cadence_path} {coverage_switch} +fsmdebug -snapshot tb_top_snap >> flow_logfile.txt -createdebugdb -run"

elab_and_run_xrun = f"xrun -access +rwc -timescale 1ns/1ps -sv -sysv -f rtl_files.f -f tb_files.f -uvm -uvmhome {cadence_path} +fsmdebug -snapshot tb_top_snap >> flow_logfile.txt -createdebugdb -run"

#--------------vivado base command------------------------
vcomp = "xvlog -sv -f vivado_rtl_files.f -f vivado_tb_files.f -L uvm --log vivado_compilation.log >> vivado_flow_logfile.txt"
velab = "xelab -timescale 1ns/1ps -debug all -top tb_top -s tb_top_snap -L uvm --log vivado_elaboration.log >> vivado_flow_logfile.txt"
vsimulation  = "xsim -R tb_top_snap >> vivado_flow_logfile.txt" 


#--------------------------------------
#  Script Variable Section
#--------------------------------------
my_list = []
elab_then_run = []
no_need_elab_only_run = []
run_cmn_elab = []
my_final_cmd = ""
successful_tests = 0
unsuccessful_tests = 0
pass_count = 0
fail_count = 0
fatal_count =0
start_time=0
end_time=0
#--------------------------------------

def get_run_op(my_test):
    my_list.clear()
    new_str = ""
    for op in my_test:
        if "run_op" in op:
            new_str = string_regexp(op, "run_op", new_str)
            my_list.append(op)
            #print(new_str)
    return new_str

def get_cmp_op(my_test):
    my_list.clear()
    new_str = ""
    for op in my_test:
        if "cmp_op" in op:
            new_str = string_regexp(op, "cmp_op", new_str)
            my_list.append(op)
            #print(new_str)
    return new_str

def get_reg_grp(my_test):
    my_list.clear()
    new_str = ""
    for op in my_test:
        if "reg_grp" in op:
            new_str = string_regexp(op, "reg_grp", new_str)
            my_list.append(op)
    return new_str

def get_data_dic(my_dict, my_test, op_type):
    if my_dict.get(my_test):
        if op_type == "run_op":
            return get_run_op(my_dict[my_test])
        elif op_type == "cmp_op":
            return get_cmp_op(my_dict[my_test])
        elif op_type == "reg_grp":
            return get_reg_grp(my_dict[my_test])
        elif op_type == "all":
            return (my_dict[my_test])
    else:
        print(f"No test available named {my_test} in {type(my_dict)} list")
        exit()

def string_regexp(hndl, pattern, my_str):
    if pattern == "run_op":
        match = re.match(r"run_op.*:(.*)", hndl)
    elif pattern == "cmp_op":
        match = re.match(r"cmp_op.*:(.*)", hndl)
    elif pattern == "reg_grp":
        match = re.match(r"reg_grp.*:(.*)", hndl)

    if match:
        my_str = my_str + " " + match.group(1)
    return my_str


##........String_generation for vivado........##

'''
##..............................
#      Command Generation --- this function is not used 
##..............................
def command_gen(my_dict, my_test, seed_value):
    my_elb = get_data_dic(my_dict, my_test, "cmp_op")
    my_run = get_data_dic(my_dict, my_test, "run_op")
    my_final_cmd = ""
    
    if len(my_elb) > 2:
        #my_final_cmd = f"{elab_and_run_xrun} -svseed {seed_value} {my_elb} {my_run}"
        my_final_cmd = f"{elab_and_run_xrun} {my_elb} {my_run}"
        elab_then_run.append(my_final_cmd)
    else:
        #my_final_cmd = f"{run_cmd_xrun} -svseed {seed_value} {my_run}"
        my_final_cmd = f"{run_cmd_xrun} {my_run}"
        no_need_elab_only_run.append(my_final_cmd)
'''
##............time....................
def format_time(timestamp):
    """Format a timestamp to a human-readable string."""
    return datetime.fromtimestamp(timestamp).strftime('%Y-%m-%d %H:%M:%S')

##................................................................
##    Function for regression run by Cadence_Xcelium
##................................................................

def regression_gen(my_dict, seed, verbosity, coverage):
    global successful_tests
    global pass_count
    global fail_count
    global unsuccessful_tests

    test_list = list(my_dict.keys())
    timestamp = time.strftime('%Y_%m_%d_%H_%M_%S', time.localtime())

    if os.path.exists("flow_logfile.txt"):
        os.remove("flow_logfile.txt")

    for my_test in test_list:
        start_time = time.time()
        start_time_str = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(start_time))
        print(f"Test '{my_test}'\n\t|| Start: {start_time_str} ")

        my_elb = get_data_dic(my_dict, my_test, "cmp_op")
        my_run = get_data_dic(my_dict, my_test, "run_op")
        my_final_cmd = ""

        dest_dir = f"./{timestamp}_regr/{my_test}/"
        os.makedirs(dest_dir, exist_ok=True)

        seed_value = get_seed(seed)

        if len(my_elb) > 2:
            if coverage == "yes":
                my_final_cmd = f"{elab_and_run_xrun_with_coverage} -svseed {seed_value} +UVM_VERBOSITY={verbosity} {my_elb} {my_run} -covtest {my_test}"
            else:
                my_final_cmd = f"{elab_and_run_xrun} -svseed {seed_value} +UVM_VERBOSITY={verbosity} {my_elb} {my_run}"

            if os.path.exists("./elaborate/tb_top_snap"):
                os.remove("./elaborate/tb_top_snap")
            if os.path.exists("./xcelium.d"):
                shutil.rmtree("./xcelium.d")
        else:
            if coverage == "yes":
                my_final_cmd = f"{run_cmd_xrun} {my_run} -svseed {seed_value} +UVM_VERBOSITY={verbosity} -covtest {my_test}"
            else:
                my_final_cmd = f"{run_cmd_xrun} {my_run} -svseed {seed_value} +UVM_VERBOSITY={verbosity}"

            if not os.path.exists("./elaborate/tb_top_snap"):
                xelb(coverage)

        result = subprocess.run(
            f"{my_final_cmd} -log {dest_dir}{my_test}_run_simulation.log",
            shell=True
        )

        if result.returncode == 0:
            successful_tests += 1
        elif result.returncode == 1:
            unsuccessful_tests += 1
            print(f"{my_test} is unsuccessful")

        # Cleanup/move generated files
        if os.path.exists("dump.vcd"):
            os.remove("dump.vcd")

        if os.path.exists("waves.shm"):
            shutil.move("waves.shm", dest_dir)

        # Move all monitor logs (e.g. axi4_s_monitor.log, etc.)
        monitor_logs = glob.glob("*monitor.log")
        for log_file in monitor_logs:
            shutil.move(log_file, os.path.join(dest_dir, log_file))

        end_time = time.time()
        duration = end_time - start_time
        end_time_str = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(end_time))
        print(f"\t|| End: {end_time_str} || Duration: {duration:.2f} seconds \n")

        # Analyze the simulation result log
        log_file = os.path.join(dest_dir, f"{my_test}_run_simulation.log")
        test_pass_fail(log_file, my_test)


##.....................................................................
#...............single test run by Cadence_Xcelium.....................
##.....................................................................

def single_run(my_dict, my_test, seed, verbosity, coverage):
    global successful_tests
    global pass_count
    global fail_count
    global unsuccessful_tests

    test_list = list(my_dict.keys())

    timestamp = time.strftime('%Y_%m_%d_%H_%M_%S', time.localtime())
    start_time = time.time()  # Start time
    start_time_str = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(start_time))
    print(f"Test '{my_test}'\n\t|| Start: {start_time_str} ")

    my_elb = get_data_dic(my_dict, my_test, "cmp_op")
    my_run = get_data_dic(my_dict, my_test, "run_op")
    my_final_cmd = ""

    if os.path.exists("flow_logfile.txt"):
        os.remove("flow_logfile.txt")

    dest_dir = f"./{timestamp}_single_test_run/{my_test}/"
    os.makedirs(dest_dir, exist_ok=True)

    if len(my_elb) > 2:
        seed_value = get_seed(seed)
        if coverage == "yes":
            my_final_cmd = f"{elab_cmd_xrun_with_coverage} -svseed {seed_value} +UVM_VERBOSITY={verbosity} {my_elb} {my_run} -covtest {my_test}"
        else:
            my_final_cmd = f"{elab_and_run_xrun} -svseed {seed_value} +UVM_VERBOSITY={verbosity} {my_elb} {my_run}"

        if os.path.exists("./elaborate/tb_top_snap"):
            os.remove("./elaborate/tb_top_snap")
        if os.path.exists("./xcelium.d"):
            shutil.rmtree("./xcelium.d")

        result = subprocess.run(
            f"{my_final_cmd} -log {dest_dir}{my_test}_run_simulation.log",
            shell=True
        )

    else:
        seed_value = get_seed(seed)
        if coverage == "yes":
            my_final_cmd = f"{run_cmd_xrun} {my_run} +UVM_VERBOSITY={verbosity} -svseed {seed_value} -covtest {my_test}"
        else:
            my_final_cmd = f"{run_cmd_xrun} {my_run} +UVM_VERBOSITY={verbosity} -svseed {seed_value}"

        if not os.path.exists("./elaborate/tb_top_snap"):
            xelb(coverage)

        result = subprocess.run(
            f"{my_final_cmd} -log {dest_dir}{my_test}_run_simulation.log",
            shell=True
        )

    if result.returncode == 0:
        successful_tests += 1
    if result.returncode == 1:
        unsuccessful_tests += 1
        print(f"{my_test} is unsuccessful")

    # Move VCD and waveform files
    if os.path.exists("dump.vcd"):
        shutil.move("dump.vcd", dest_dir)
    if os.path.exists("waves.shm"):
        shutil.move("waves.shm", dest_dir)

    # Move monitor logs that match "*monitor.log"
    monitor_logs = glob.glob("*monitor.log")
    for log_file in monitor_logs:
        shutil.move(log_file, os.path.join(dest_dir, log_file))

    # Log time info
    end_time = time.time()  # End time
    duration = end_time - start_time  # Duration
    end_time_str = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(end_time))
    print(f"\t|| End: {end_time_str} || Duration: {duration:.2f} seconds \n")

    # Evaluate pass/fail based on the run simulation log
    log_file = os.path.join(dest_dir, f"{my_test}_run_simulation.log")
    test_pass_fail(log_file, my_test)

##.....................................................
#............... debug test run .......................
##.....................................................

def single_run_with_debug(my_dict, my_test, seed, verbosity):
    global successful_tests
    global pass_count
    global fail_count
    global unsuccessful_tests

    timestamp = time.strftime('%Y_%m_%d_%H_%M_%S', time.localtime())
    start_time = time.time()
    start_time_str = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(start_time))
    print(f"Test '{my_test}'\n\t|| Start: {start_time_str} ")

    my_elb = get_data_dic(my_dict, my_test, "cmp_op")
    my_run = get_data_dic(my_dict, my_test, "run_op")

    seed_value = get_seed(seed)
    my_final_cmd = f"{debug_cmd_xrun} -svseed {seed_value} +UVM_VERBOSITY={verbosity} {my_elb} {my_run}"

    if os.path.exists("./elaborate/tb_top_snap"):
        os.remove("./elaborate/tb_top_snap")
    if os.path.exists("./xcelium.d"):
        shutil.rmtree("./xcelium.d")

    # Create directory for logs and output
    dest_dir = f"./{timestamp}_single_test_run/{my_test}/"
    os.makedirs(dest_dir, exist_ok=True)

    result = subprocess.run(
        f"{my_final_cmd} -log {dest_dir}{my_test}_run_simulation.log",
        shell=True
    )

    if result.returncode == 0:
        successful_tests += 1
    elif result.returncode == 1:
        unsuccessful_tests += 1
        print(f"{my_test} is unsuccessful")

    if os.path.exists("dump.vcd"):
        shutil.move("dump.vcd", os.path.join(dest_dir, "dump.vcd"))

    if os.path.exists("waves.shm"):
        shutil.move("waves.shm", os.path.join(dest_dir, "waves.shm"))

    # Move any monitor log files (e.g., axi4lite_m_monitor.log, axi4_s_monitor.log, etc.)
    monitor_logs = glob.glob("*monitor.log")
    for log_file in monitor_logs:
        shutil.move(log_file, os.path.join(dest_dir, log_file))

    end_time = time.time()
    duration = end_time - start_time
    end_time_str = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(end_time))

    print(f"\t|| End: {end_time_str} || Duration: {duration:.2f} seconds \n")

    log_file = os.path.join(dest_dir, f"{my_test}_run_simulation.log")
    test_pass_fail(log_file, my_test)

##...................................................
#..............elaboration xcelium...................
##...................................................

def xelb(coverage):
    if coverage == "yes":
       subprocess.run(elab_cmd_xrun_with_coverage, shell=True)
    else:
       subprocess.run(elab_cmd_xrun, shell=True)
    
#................Elaboration Successfull or not..........
def elab_pass_fail(elaboration_file_path):
    if not os.path.exists(elaboration_file_path):
        print(f"The elaboration log file {elaboration_file_path} does not exist")
        return

    with open(elaboration_file_path, "r") as logfile:
        error_found = False
        fatal_found = False

        for line in logfile:
            if "*E" in line:
                error_found = True
            if "*F" in line:
                fatal_found = True

        if fatal_found:
            print("Fatal found in the elaboration log")
        elif error_found:
            print("Error found in the elaboration log")
        else:
            print("Elaboration Successful.")

#...........................................
##............test_pass_fail................
#...........................................
def test_pass_fail(logfile_path, my_test):
    global pass_count
    global fail_count
    global fatal_count

    # Corrected path: cov_work/scope/<my_test>
    dir_to_delete = os.path.join("cov_work", "scope", my_test)

    if not os.path.exists(logfile_path):
        print(f"The log file {logfile_path} does not exist.")
        return pass_count, fail_count, fatal_count

    with open(logfile_path, "r") as logfile:
        for line in logfile:
            if "TEST PASS" in line:
                pass_count += 1
                break

            elif "xmsim: *E" in line or "TEST FAIL" in line:
                fail_count += 1
                print(f"\tFAIL in {logfile_path}")
                if os.path.exists(dir_to_delete):
                    shutil.rmtree(dir_to_delete)
                    print(f"\tDeleted directory due to FAIL: {dir_to_delete}")
                else:
                    print(f"\tDirectory not found (FAIL): {dir_to_delete}")
                break

            elif "UVM_FATAL :" in line:
                try:
                    fatal_value = int(line.split(":")[1].strip())
                    if fatal_value != 0:
                        fatal_count += 1
                        print(f"\tFATAL ERROR in {logfile_path}")
                        if os.path.exists(dir_to_delete):
                            shutil.rmtree(dir_to_delete)
                            print(f"\tDeleted directory due to FATAL: {dir_to_delete}")
                        else:
                            print(f"\tDirectory not found (FATAL): {dir_to_delete}")
                        break
                except ValueError:
                    print(f"\tMalformed UVM_FATAL line in {logfile_path}: {line.strip()}")

    return pass_count, fail_count, fatal_count
#..........................................
#............seed generator................
#..........................................
def get_seed(seed):
    if seed.lower() == "random":
        seed_value = int(time.time())  # Generate a seed based on the current time
    else:
        # Try to convert the provided seed argument to an integer
        try:
            seed_value = int(seed)
        except ValueError:
            # Raise an error if the provided seed is not valid
            raise ValueError(f"Invalid seed value: {seed}. It must be an integer or 'random'.")
    
    return seed_value



#..................................................
#.............vivado Section.......................
#..................................................
def vcmp():
    subprocess.run(vcomp, shell=True, check=True)

def velb():
    vcmp()
    subprocess.run(velab, shell=True, check=True)

def vsim(test_name):
    if os.path.exists(test_name):
        shutil.rmtree(test_name)
    os.mkdir(test_name)
    velb(test_name)  # Call velb here to compile and elaborate before simulation
    subprocess.run(["bash", "-c", f"xsim tb_top_snap -R -testplusarg UVM_TESTNAME={test_name} -sv_seed 100 -testplusarg UVM_TIMEOUT=1us --log ./{test_name}/run_simulation.log"])
    if os.path.exists("dump.vcd"):
        shutil.move("dump.vcd", f"./{test_name}/")

##..................................................
#...............vivado single test run.....................
##..................................................

def vivado_single_run(my_dict, my_test, seed, verbosity):
    global successful_tests
    global pass_count
    global fail_count
    test_list = list(my_dict.keys())
    snap = f"./xsim.dir" 
    if not os.path.exists(snap):
        print("*****\nSnap file is not Found, Elaborating first\n*****")
        velb()
        print("*****\nElaboration Done!\n*****")

    timestamp = time.strftime('%Y_%m_%d_%H_%M_%S', time.localtime())
    start_time = time.time()  # Start time
    start_time_str = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(start_time))
    print(f"Test '{my_test}'\n\t|| Start: {start_time_str} ")
    

    target_dir = f"./{timestamp}_single_test_run/{my_test}/"
    if not os.path.exists(target_dir):
        os.makedirs(target_dir)

    my_elb = get_data_dic(my_dict, my_test, "cmp_op")
    vivado_my_elb = re.sub(r'\+',' -testplusarg ',my_elb)
    my_run = get_data_dic(my_dict, my_test, "run_op")
    vivado_my_run= re.sub(r'\+',' -testplusarg ',my_run)
    my_final_cmd = ""


    if len(my_elb) > 2:
        seed_value=int(get_seed(seed))
        my_final_cmd = f"{vsimulation} testplusarg -sv_seed {seed_value} {vivado_my_elb} {vivado_my_run}"

        result = subprocess.run(
            f"{my_final_cmd} --log ./{timestamp}_single_test_run/{my_test}/{my_test}_vivado_run_simulation.log",
            shell=True
        )

    else:
        seed_value=int(get_seed(seed))
        my_final_cmd = f"{vsimulation} {vivado_my_run} -sv_seed {seed_value}"

        result = subprocess.run(
            f"{my_final_cmd} --log ./{timestamp}_single_test_run/{my_test}/{my_test}_vivado_run_simulation.log",
            shell=True
        )

    if result.returncode == 0:
        successful_tests += 1
    if result.returncode == 1:
        print(f"{my_test} is unsuccessful")

    if os.path.exists("dump.vcd"):
        shutil.move("dump.vcd",target_dir)
    if os.path.exists("apb_monitor.log"):
        shutil.move("apb_monitor.log",target_dir)

    end_time = time.time()  # End time
    duration = end_time - start_time  # Duration
    end_time_str = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(end_time))

    print(f"\t|| End: {end_time_str} || Duration: {duration:.2f} seconds \n")

##...........................................
#..............remove function..........
##...........................................

def remove():
    subprocess.run(["find", ".", "-type", "d", "-name","-exec", "rm", "-r", "{}", "+"])
    files_to_delete = ["*.log", "*.pb", "*.jou", "*.wdb", "dump*", "*.diag", "*.history", "*.txt"]
    dirs_to_delete = ["xsim.dir", "xcelium.d", "waves.shm", "elaborate", "__pycache__"]
    for file_pattern in files_to_delete:
        for file_path in glob.glob(file_pattern):
            os.remove(file_path)
    for dir_to_delete in dirs_to_delete:
        shutil.rmtree(dir_to_delete, ignore_errors=True)
    subprocess.run(["reset"])
    subprocess.run(["ls", "-ltrh"])


##..............................................................
#..............count the number of tests pass and fail..........
##..............................................................

def test_pass_fail_count():
    print("\n Test Completed")
    print(f"\t Number of Successful Tests Simulated: {successful_tests}")
    print(f"\t Number of Simulation Fail: {unsuccessful_tests}")
    print(f"\t Number of TEST PASS: {pass_count}")
    print(f"\t Number of TEST FAIL: {fail_count}")
    print(f"\t Number of TEST FATAL: {fatal_count}")
    if successful_tests > 0:
        print(f"\t Number of Passing Rate: {(pass_count/(successful_tests + unsuccessful_tests ))*100}%")
    else:
        print("\t No Test is Successful")

##..............................................................
#..............Merging coverage and getting report..........
##..............................................................

def merge_coverage():
    scope_path = "cov_work/scope"
    output_file = "imc.cmd"
    #clean_scope_directory()

    # Get sorted test list
    test_paths = []
    if os.path.isdir(scope_path):
        for entry in sorted(os.listdir(scope_path)):
            full_path = os.path.join(scope_path, entry)
            if os.path.isdir(full_path) or os.path.isfile(full_path):
                test_paths.append(f"./{scope_path}/{entry}")

    # Build the merge command in one line
    merge_command = "merge -initial_model union_all " + " ".join(test_paths) + " -out merged -metrics all"

    # Other IMC commands
    commands = [
        merge_command,
        "load ./cov_work/scope/merged",
        "report -detail -html -metrics all -out html_report",
        "exit"
    ]

    # Write to imc.cmd
    with open(output_file, "w") as f:
        for cmd in commands:
            f.write(cmd + "\n")

    print(f"'imc.cmd' created successfully with {len(test_paths)} test entries.")
    run_imc()

# remove files if exists in the scope directory

def clean_scope_directory():
    scope_path = "cov_work/scope"

    if os.path.isdir(scope_path):
        for entry in os.listdir(scope_path):
            full_path = os.path.join(scope_path, entry)

            # Check if the entry is a directory and ends with 'test'
            if os.path.isdir(full_path) and entry.endswith("test"):
                continue  # Keep this directory

            # Otherwise, delete (file or non-test directory)
            if os.path.isfile(full_path):
                os.remove(full_path)
                print(f"Deleted file: {full_path}")
            elif os.path.isdir(full_path):
                shutil.rmtree(full_path)
                print(f"Deleted directory: {full_path}")
    else:
        print(f"Directory '{scope_path}' does not exist.")

# Command for merge the coverage
def run_imc():
    try:
        result = subprocess.run(["imc", "-exec", "imc.cmd"], check=True)
        print("IMC executed successfully.")
    except subprocess.CalledProcessError as e:
        print(f"IMC execution failed with return code {e.returncode}")

##...........................................
#..............custom help function..........
##...........................................

def custom_help():
    print('\n')
    print('Custom help message:')
    print('\n')
    print('Switches:')
    print('    --test: Test name (default: sanity_test)')
    print('    --run: Run type (choices: cmp, elb, sim, debug, wave; default: sim)')
    print('    --tool: Tool name (choices: vivado, xlim; default: vivado)')
    print('    --seed: Seed value for the simulation, default value ==0')
    print('    --coverage: The uvc has coverage or no, default value ==no')
    print('    --verbosity: UVM verbosity for the simulation, default value ==UVM_NONE')
    print('    --regr: Run regression test')
    print('    --remove: Remove all directories existing in the current directory')
    print('    --help: Show this custom help message')
    print('\n')
    print('sample command for Elaboration:\n \t ./run_script.py --run elb --tool xlim')
    print('\n')
    print('sample command for single test:\n \t ./run_script.py --test sanity_test --run sim --tool xlim --seed 12345 --coverage yes/no')
    print('\n')
    print('command for regression:\n \t ./run_script.py --regr --seed 125/random --coverage yes/no')
    print('\n')




##...........................................
#..............main function.................
##...........................................
def main():
    global successful_tests
    global unsuccessful_tests
    try:
        parser = argparse.ArgumentParser(description='Run simulation scripts.', add_help=False)
        parser.add_argument('--test', default='sanity_test', help='Test name (default: sanity_test)')
        parser.add_argument('--run', default='sim', choices=['cmp', 'elb', 'sim', 'debug'], help='Run type (default: sim)')
        parser.add_argument('--tool', default='xlim', choices=['vivado', 'xlim'], help='Tool name (default: vivado)')
        parser.add_argument('--seed', type=str, default=str(1234),help='Seed value for the simulation (default: 1235 or use "random" for random seed)')
        parser.add_argument('--regr', action='store_true', help='Run regression test')
        parser.add_argument('--verbosity', default='UVM_NONE', choices=['UVM_NONE', 'UVM_LOW','UVM_MEDIUM','UVM_HIGH','UVM_DEBUG'], help='Verbosity type (default: vivado)')
        parser.add_argument('--help', action='store_true', help='Show custom help message')
        parser.add_argument('--remove', action='store_true', help='Remove previous simulation data')
        parser.add_argument('--coverage', default='no', choices=['yes', 'no'], help='Has coverage (default: no)')

        args = parser.parse_args()

        if args.help:
            custom_help()
            return
        if args.remove:
            remove()
            return
        
        my_test = args.test
        run = args.run
        tool = args.tool
        verbosity = args.verbosity
        seed = args.seed
        coverage= args.coverage

        if run == "cmp":
            if tool == "vivado":
                print("\n	 ***** Compilation started! *****\n")
                vcmp()
                print("\n	 ***** Compilation Finished! ****")
            elif tool == "xlim":
                print("\n*****Compilation is not available for Xcelium Tool.Please try Elaboration by this Tool****\n")
        elif run == "elb":
            if tool == "vivado":
                print("\n	***** Elaboration Started *****\n")
                velb()
                elab_pass_fail(f"./elaborate/run_elaboration.log")
                print("\n	***** Elaboration is done *****")
            elif tool == "xlim":
                print("\n	***** Elaboration Started *****\n")
                xelb(coverage)
                elab_pass_fail(f"./elaborate/run_elaboration.log")
                print("\n	***** Elaboration is done *****")
        elif run == "sim":
            if args.regr:
                    if tool == "vivado":
                            print("\n*****Regression run is not available by Vivado tool*****\n");
                    if tool == "xlim":
                            regression_gen(testcase, seed, verbosity,coverage)  # my_dict == testcase
                            if coverage == "yes":
                                   merge_coverage()
                            test_pass_fail_count()
            elif tool == "xlim":
                single_run(testcase, my_test, seed,verbosity,coverage)
                test_pass_fail_count()
            elif tool == "vivado":
                vivado_single_run(testcase, my_test, seed,verbosity)
               # test_pass_fail_count()
        elif run == "debug":
            if tool == "xlim":
                single_run_with_debug(testcase, my_test, seed,verbosity)
                test_pass_fail_count()
            elif tool == "vivado":
                print("This feature is not available for vivado tool")
        elif run == "wave":
            wave()
    except SystemExit as error:
        if error.code != 0:
            custom_help()

if __name__ == "__main__":
    main()




