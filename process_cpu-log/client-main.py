from __future__ import print_function
import sys
import statistics
import os
import pandas as pd
import numpy as np
from copy import copy
from datetime import datetime
import psutil
import utils

# global arguments
# csv name
title_row = ["Processes","tag","tStart","tEnd","Duration(s)","TPS","waiting_time_peer_to_propsoal(sum/avg/min/max) ms","waiting_time_check_promise(sum/avg/min/max) ms","waiting_time_event(sum/avg/min/max) ms"]
csvData_title = copy(title_row)
csvData_client = []
csvData_set = []
username = os.uname()[1]
global_logsPath = "/opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/Logs"
global_hostIP = ["120.79.163.88","172.16.50.153"]

# client is not include in hostname
# hostname = ["iZwz9gd8k08kdmtd4qg7rhZ"] # ecs single test case
# hostname = ["iZwz9gd8k08kdmtd4qg7riZ","iZwz9gd8k08kdmtd4qg7rhZ"] # ecs multiple test case
# hostname = ["blockchainmaster151","blockchainmonion153"] # remote multiple network test case
# hostname = ["iZwz9gd8k08kdmtd4qg7rhZ","blockchainmonion153"] # public multiple network test case


# global arguments to None to assigning anything
Processes = 1
TestID = None
tStart = None
tEnd = None
elasep = None
tps = None
waiting_time_peer_to_propsoal = [0,0,0,0]
waiting_time_check_promise = [0,0,0,0]
waiting_time_event = [0,0,0,0]

avg_send = None
max_send = None
avg_receive = None
max_receive = None

# received and send data of network IO
max_read_count = None
sum_read_count = None
max_write_count = None
sum_write_count = None

max_read_data = None
sum_read_data = None
avg_read_data = None

max_write_data = None
sum_write_data = None
avg_write_data = None

max_busy_time = None
avg_busy_time = None

# memory data and cpu data
max_memory_usage = None
avg_memory_usage = None
max_cpu_usage = None
avg_cpu_usage = None




def __initTime(tStart, tEnd):
    # print("initializing...")
    tStart = datetime.fromtimestamp(tStart/1000).strftime("%I:%M:%S")
    tEnd = datetime.fromtimestamp(tEnd/1000).strftime("%I:%M:%S")
    print("tStart:", tStart)
    print("tEnd:", tEnd)
    return tStart, tEnd


def writeNetworkIO(fileName, tStart, tEnd, elasep):
    elasep_count = 0
    
    global avg_send
    global avg_receive
    global max_send
    global max_receive
    send = []
    receive = []
    print("Loading", fileName, "---------")
    with open("./{}".format(fileName),"r") as file:
        for line in file.readlines():
            line = line.strip()
            if line != "":
                line = line.split("     ")
                if line[0].find(tStart) > -1 or elasep_count != 0:
                    send.append(float(line[2]))
                    receive.append(float(line[3]))
                    elasep_count += 1
                    if elasep_count == elasep or line[0].find(tEnd) > -1 :
                        avg_send = round(statistics.mean(send),2)
                        print("avg send data kb/s", avg_send)
                        avg_receive = round(statistics.mean(receive),2)
                        print("avg receive data kb/s",avg_receive)
                        max_send = max(send)
                        print("max send data kb/s", max_send)
                        max_receive = max(receive)
                        print("max receive data kb/s", max_receive)
                        return
    return "writeNetworkIO"
                    
def writeDiskIO(fileName, tStart, tEnd, elasep):
    elasep_count = 0
    # global argumetns
    global max_read_count
    global sum_read_count
    global max_write_count
    global sum_write_count
    # global argumetns
    global max_read_data
    global sum_read_data
    global avg_read_data
    # global argumetns
    global max_write_data
    global sum_write_data
    global avg_write_data
    # global argumetns
    global max_busy_time
    global avg_busy_time
    # global argumetns
    read_count = []
    write_count = []
    read_data = []
    write_data = []
    busy_time = []
    print("Loading", fileName, "---------")
    with open("./{}".format(fileName),"r") as file:
        for line in file.readlines():
            line = line.strip()
            if line != "":
                line = line.split("     ")
                if line[0].find(tStart) > -1 or elasep_count != 0:
                    read_count.append(float(line[2]))
                    write_count.append(float(line[3]))
                    read_data.append(float(line[4]))
                    write_data.append(float(line[5]))
                    busy_item = [float(x) for x in line[6].split("_")]
                    busy_time.append(busy_item)

                    elasep_count += 1
                    if elasep_count == elasep or line[0].find(tEnd) > -1 :
                        max_read_count = max(read_count)
                        print("max read count", max_read_count)
                        sum_read_count = sum(read_count)
                        print("sum read count",sum_read_count)
                        max_write_count = max(write_count)
                        print("max write count",max_write_count)
                        sum_write_count = sum(write_count)
                        print("sum write count", sum_write_count)

                        max_read_data = max(read_data)
                        print("max read data kb/s", max_read_data)
                        sum_read_data = sum(read_data)
                        print("sum read data kb", sum_read_data)
                        avg_read_data = round(statistics.mean(read_data), 2)
                        print("avg read data kb/s", avg_read_data)

                        max_write_data = max(write_data)
                        print("max write data kb/s",max_write_data)
                        sum_write_data = sum(write_data)
                        print("sum write data kb", sum_write_data)
                        avg_write_data = round(statistics.mean(write_data),2)
                        print("avg write data kb/s", avg_write_data)

                        max_busy_time = [round(x,2) for x in np.max(busy_time,axis=0)]
                        print("max busy time %", max_busy_time)
                        avg_busy_time =  [round(x,2) for x in np.average(busy_time,axis=0)]
                        print("avg busy time %", avg_busy_time)
                        return
    return "writeDiskIO"


def writeMemory(fileName, tStart, tEnd, elasep):
    elasep_count = 0
    # global argumetns
    global max_memory_usage
    global avg_memory_usage
    memory_usage = []
    print("Loading", fileName, "---------")
    with open("./{}".format(fileName),"r") as file:
        for line in file.readlines():
            line = line.strip()
            if line != "":
                line = line.split("     ")
                if line[0].find(tStart) > -1 or elasep_count != 0:
                    memory_usage.append(float(line[2]))

                    elasep_count += 1
                    if elasep_count == elasep or line[0].find(tEnd) > -1 :
                        max_memory_usage = max(memory_usage)
                        print("max memory usage %", max_memory_usage)
                        avg_memory_usage = round(statistics.mean(memory_usage),2)
                        print("avg memory usage %", avg_memory_usage)

                        return
    return "writeMemory"


def writeCPU(fileName, tStart, tEnd, elasep):
    elasep_count = 0
    global max_cpu_usage
    global avg_cpu_usage
    # global argumetns
    memory_usage = []
    print("Loading", fileName, "---------")
    with open("./{}".format(fileName),"r") as file:
        for line in file.readlines():
            line = line.strip()
            if line != "":
                line = line.split("     ")
                if line[0].find(tStart) > -1 or elasep_count != 0:
                    memory_usage.append(float(line[2]))

                    elasep_count += 1
                    if elasep_count == elasep or line[0].find(tEnd) > -1 :
                        max_cpu_usage = max(memory_usage)
                        print("max cpu usage %", max_cpu_usage)
                        avg_cpu_usage = round(statistics.mean(memory_usage),2)
                        print("avg cpu usage %", avg_cpu_usage)

                        return
    return "writeCPU"


def readLog(path,fileName):
    global Processes
    global tps
    global waiting_time_peer_to_propsoal
    global waiting_time_check_promise
    global waiting_time_event
    # set default mode, to get the watiting time request
    print("Loading...", fileName, "-----")
    # pwd = os.getcwd()
    tag = True  # This tag is used to check time
    with open("{}/{}".format(path, fileName), "r") as file:
        Processes = 1
        for i in reversed(file.readlines()):
            if i.find("Threads run completed") > -1:
                temp = [int(s) for s in i.split() if s.isdigit()]
                Processes = temp[1]
            i = i.strip()
            # find a summary list
            if i != "" and i.find("Test Summary") > -1:
                if i.find("Test Summary:Total") > -1:
                    # use to check the TPS
                    print(i[10:])
                    tps_index = i.find("total throughput=")+len("total throughput=")
                    tps = i[tps_index:-3]
                    print("The tps is", tps)
                    # ======= the main print ========
                # filter the invoke check
                if i.find("timestamp:") > -1 and tag == True:
                    tag = False
                    index_1 = i.find("start")
                    index_2 = i.find("end")
                    # find the invoke
                    if i.find("invoke_query_mix") > -1:
                        index_3 = i[index_2:].find(",")+index_2
                    elif i.find("eventRegister") > -1:
                        index_3 = i[index_2:].find(",")+index_2
                        index_4 = i[index_3:].find("#event unreceived: ")
                        index_5 = i[index_4+18:].find(",")+index_4+18
                        if index_4 > -1 and index_5 < 2:
                            print("Unreceived events:", i[index_4:index_5])
                    else:
                        index_3 = i[index_2:].find(",")+index_2
                    tStart = i[index_1+5:index_2].replace(" ", "")
                    tEnd = i[index_2+3:index_3].replace(" ", "")
            elif i != "" and i.find("waiting_time") > -1:
                # use to check waiting time for each transaction
                index_output = i.find("Time:")+ 6
                if i.find("peer") > -1:
                    out = i[index_output:]
                    waiting_time_peer_to_propsoal += np.array([float(x) for x in out.split(",")])
                elif i.find("promise") > -1:
                    out = i[index_output:]
                    waiting_time_check_promise += np.array([float(x) for x in out.split(",")])
                elif i.find("time_event") > -1:
                    out = i[index_output:]
                    waiting_time_event += np.array([float(x) for x in out.split(",")])
            
            # TODO:process waiting_time
        print("The PTE Process is :", Processes)
        waiting_time_peer_to_propsoal = [round(x/Processes,2) for x in waiting_time_peer_to_propsoal]
        print("waiting time peer to propsoal:", waiting_time_peer_to_propsoal)
        waiting_time_check_promise = [round(x/Processes,2) for x in waiting_time_check_promise]
        print("waiting time check promise:", waiting_time_check_promise)
        waiting_time_event = [round(x/Processes,2) for x in waiting_time_event]
        print("waiting time event:", waiting_time_event)

    return int(tStart), int(tEnd)



def writeCSV(logsPath,logsLists,hostIP):
    csvData = []
    global csvData_title
    global csvData_client
    global csvData_set

    for log in logsLists:
        if log[-3:] == "log":
            diskName = [x for x in psutil.disk_io_counters(perdisk=True)] # local diskName
            # header parameter
            # Processes = ""
            tag = ""
            TestID = log[-14:-4]
            LogfileName = log
            tStart, tEnd = readLog(logsPath,LogfileName)
            elasep = int((tEnd-tStart)/1000)
            tStart, tEnd = __initTime(tStart, tEnd)
            # read time
            statsFileList = [i for i in os.listdir("./") if i.endswith(".txt")]
            # read the stats file
            for fileName in statsFileList:
                if fileName.find(username) > -1:
                    # check the client system record
                    # csvData_client
                    if fileName.find("disk") > -1:
                        writeDiskIO(fileName, tStart, tEnd, elasep)
                    if fileName.find("memory") > -1:
                        writeMemory(fileName, tStart, tEnd, elasep)
                    if fileName.find("cpu") > -1:
                        writeCPU(fileName, tStart, tEnd, elasep)
                    if fileName.find("network") > -1:
                        writeNetworkIO(fileName, tStart, tEnd, elasep)
            # end read client file
            # jump out of loop
            csvData_client = [Processes,tag,tStart, tEnd, elasep, tps, str(waiting_time_peer_to_propsoal), str(waiting_time_check_promise), str(waiting_time_event), 
                            avg_send, 
                            max_send, 
                            avg_receive, 
                            max_receive, 
                            max_read_count,
                            sum_read_count, 
                            max_write_count, 
                            sum_write_count, 
                            max_read_data, 
                            sum_read_data,
                            avg_read_data, 
                            max_write_data, 
                            sum_write_data, 
                            avg_write_data, 
                            max_busy_time,
                            avg_busy_time, 
                            max_memory_usage, 
                            avg_memory_usage, 
                            max_cpu_usage, 
                            avg_cpu_usage]

            host = "client"
            title = ["{} network avg send(kb/s)".format(host),
                    "{} network max send(kb/s)".format(host), 
                    "{} network avg receive(kb/s)".format(host),
                        "{} network max receive(kb/s)".format(host),
                        "{} disk max read count".format(host),
                        "{} disk sum read count".format(host),
                        "{} disk max write count".format(host),
                        "{} disk sum write count".format(host),
                        "{} disk max read data(kb/s)".format(host),
                        "{} disk sum read data(kb)".format(host),
                        "{} disk avg read data(kb/s)".format(host),
                        "{} disk max write data(kb/s)".format(host),
                        "{} disk sum write data(kb)".format(host),
                        "{} disk avg write data(kb/s)".format(host),
                        "{} disk max busy time {}(%)".format(host,diskName),
                        "{} disk avg busy time {}(%)".format(host,diskName),
                        "{} memory max usage(%)".format(host),
                        "{} memory avg usage(%)".format(host),
                        "{} cpu max usage(%)".format(host),
                        "{} cpu avg usage(%)".format(host),
                        ]
            csvData_title +=title
            csvData_set += csvData_client
            # end read client file
            # read the stats file
            sut_host_count = 0
            for IP in hostIP:
                diskName,name = utils.readDiskName(IP)
                print(diskName,name)
                for fileName in statsFileList:
                    if fileName.find(name) > -1:
                        # check other log
                        # csvData_client
                        if fileName.find("disk") > -1:
                            writeDiskIO(fileName, tStart, tEnd, elasep)
                        if fileName.find("memory") > -1:
                            writeMemory(fileName, tStart, tEnd, elasep)
                        if fileName.find("cpu") > -1:
                            writeCPU(fileName, tStart, tEnd, elasep)
                        if fileName.find("network") > -1:
                            writeNetworkIO(fileName, tStart, tEnd, elasep) 
                # jump out of loop to load data
                csvData_client = [avg_send, 
                                max_send, 
                                avg_receive, 
                                max_receive, 
                                max_read_count,
                                sum_read_count, 
                                max_write_count, 
                                sum_write_count, 
                                max_read_data, 
                                sum_read_data,
                                avg_read_data, 
                                max_write_data, 
                                sum_write_data, 
                                avg_write_data, 
                                max_busy_time,
                                avg_busy_time, 
                                max_memory_usage, 
                                avg_memory_usage, 
                                max_cpu_usage, 
                                avg_cpu_usage]
                host = "sut{}".format(sut_host_count)
                sut_host_count += 1
                title = ["{} network avg send(kb/s)".format(host),
                        "{} network max send(kb/s)".format(host), 
                        "{} network avg receive(kb/s)".format(host),
                            "{} network max receive(kb/s)".format(host),
                            "{} disk max read count".format(host),
                            "{} disk sum read count".format(host),
                            "{} disk max write count".format(host),
                            "{} disk sum write count".format(host),
                            "{} disk max read data(kb/s)".format(host),
                            "{} disk sum read data(kb)".format(host),
                            "{} disk avg read data(kb/s)".format(host),
                            "{} disk max write data(kb/s)".format(host),
                            "{} disk sum write data(kb)".format(host),
                            "{} disk avg write data(kb/s)".format(host),
                            "{} disk max busy time{}(%)".format(host,diskName),
                            "{} disk avg busy time{}(%)".format(host,diskName),
                            "{} memory max usage(%)".format(host),
                            "{} memory avg usage(%)".format(host),
                            "{} cpu max usage(%)".format(host),
                            "{} cpu avg usage(%)".format(host),]
                csvData_title += title
                csvData_set += csvData_client
        print("Writing file to csv")
        print()
        # print(csvData_set,csvData_title)
        print("lenth of csv",len(csvData_set),len(csvData_title))
        csvData.append(csvData_set)
        csvData_title_all = csvData_title
        # append the csv set to csvfile
        csvData_set = []
        csvData_title = copy(title_row)
        # print global arguments
        # print(TestID, tStart, tEnd, elasep, tps)
        # print(avg_send,max_send,avg_receive,max_receive)
        # print(max_read_count,sum_read_count)
        # print(max_write_count,sum_write_count)
        # print(max_read_data,sum_read_data,avg_read_data)
        # print(max_write_data,sum_write_data,avg_write_data)
        # print(max_busy_time, avg_busy_time)
        # print(max_memory_usage, avg_memory_usage)
        # print(max_cpu_usage, avg_cpu_usage)
    df = pd.DataFrame(columns=csvData_title_all,data = csvData)
    df.to_csv("output_{}_test.csv".format(TestID))
    print("Done.")
    return 

            

def main():
    global global_logsPath
    global global_hostIP

    arg = sys.argv[1:]
    # read arguments
    # filesList = os.listdir("./")
    logsPath = global_logsPath
    if not arg:
        hostIP = global_hostIP
    else:
        hostIP = [x for x in arg[0].split("-") if x != ""]
        print(hostIP)
    logsLists = [i for i in os.listdir(logsPath) if i.endswith(".log")]
    print(logsLists)

    writeCSV(logsPath,logsLists,hostIP)
    

if __name__ == "__main__":
    main()
