import pandas as pd
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
    print("Loading", fileName,"-----")
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
                              statistics.mean(user_cpu))
                        return
            # break
    return


def readLog(fileName):
    print("Loading...", fileName,"-----")
    pwd = os.getcwd()
    tag = True  # This tag is used to check time
    with open("{}/CITest/Logs/{}".format(pwd, fileName), "r") as file:
        # summary = []
        for i in reversed(file.readlines()):
            i = i.strip()
            if i != "" and i.find("Test Summary") > -1:
                if i.find("Test Summary:Total") > -1:
                    print(i[10:])
                if i.find("start") > -1 and tag == True and i.find("invoke_query_simple") == -1:
                    tag = False
                    index_1 = i.find("start")
                    index_2 = i.find("end")
                    index_3 = i.find(",Throughput")
                    # index_3 = i.find(", #event")
                    tStart = i[index_1+5:index_2].replace(" ", "")
                    tEnd = i[index_2+3:index_3].replace(" ", "")
                # summary.append(i)
    return int(tStart), int(tEnd)


def __main__():
    # You should modify you own data
    fileName_1 = "pte_test_3_19_153.txt"
    fileName_2 = "pte_test_3_19_151.txt"
    # LogfileName = "RMT-3808-2i_0319175605.log"
    LogfileName = "RMT-3811-2q_0319181219.log"
    tStart, tEnd = readLog(LogfileName)
    # print(summary)
    # tStart = 1521451381010
    # tEnd = 1521448856460
    # run code
    print("-------------------")
    elasep = int((tEnd-tStart)/1000)
    tStart, tEnd = __initTime(tStart, tEnd)
    print("Elasep time:", elasep)
    readFile(fileName_1, tStart, elasep)
    readFile(fileName_2, tStart, elasep)


__main__()
