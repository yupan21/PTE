from __future__ import print_function
import sys
import statistics
import os
from datetime import datetime


def __initTime(tStart, tEnd):
    # print("initializing...")
    tStart = datetime.fromtimestamp(tStart/1000).strftime("%I:%M:%S")
    tEnd = datetime.fromtimestamp(tEnd/1000).strftime("%I:%M:%S")
    print("tStart:", tStart)
    print("tEnd:", tEnd)
    # print("Command: sar -s {} -e {} > out_{}-{}.txt 2>&1".format(tStart, tEnd, tStart, tEnd))
    return tStart, tEnd


def readFile(fileName, tStart, elasep):
    # read cpu txt
    user_cpu = []
    print("Loading", fileName, "-----")
    pwd = os.getcwd()
    with open("{}/process_cpu-log/{}".format(pwd, fileName), "r") as file:
        elasep_count = 0
        for i in file.readlines():
            i = i.strip()
            if i != "":
                i = i.split("     ")
                if i[0].find(tStart) > -1 or elasep_count != 0:
                    # print(i)
                    user_cpu.append(float(i[2]))
                    elasep_count += 1
                    if elasep_count == elasep:
                        print("The max cpu usage is:", max(user_cpu))
                        print("The avg cpu usage is:",
                              round(statistics.mean(user_cpu), 2))
                        return
            # break
    return


def readLog(fileName):
    print("Loading...", fileName, "-----")
    pwd = os.getcwd()
    tag = True  # This tag is used to check time
    with open("{}/CITest/Logs/{}".format(pwd, fileName), "r") as file:
        for i in reversed(file.readlines()):
            i = i.strip()
            # find a summary list
            if i != "" and i.find("Test Summary") > -1:
                if i.find("Test Summary:Total") > -1:
                    index_1 = i.find("transaction=")
                    index_2 = i.find(", ")
                    index_3 = i.find("total throughput=")
                    print("Total", i[index_1:index_2], "/", i[index_3:])
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
    return int(tStart), int(tEnd)


def __main__():
    arg = sys.argv[1:]
    print(arg)
    # You should modify you own data
    fileName_1 = "pte_0320_blockchainmaster151.txt"
    fileName_2 = "pte_0320_blockchainmonion153.txt"
    # LogfileName = "RMT-3808-2i_0319175605.log"
    LogfileName = "RMT-3808-2i_0320184010.log"
    tStart, tEnd = readLog(LogfileName)
    # print(summary)
    # run code
    elasep = int((tEnd-tStart)/1000)
    tStart, tEnd = __initTime(tStart, tEnd)
    print("Elasep time:", elasep)
    print("-------------------")
    readFile(fileName_1, tStart, elasep)
    readFile(fileName_2, tStart, elasep)


__main__()
