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
    # pwd = os.getcwd()
    with open("./{}".format(fileName), "r") as file:
        elasep_count = 0
        for i in file.readlines():
            i = i.strip()
            if i != "":
                i = i.split("     ")
                if i[0].find(tStart) > -1 or elasep_count != 0:
                    try:
                        user_cpu.append(float(i[2]))
                    except:
                        print("The max usage is:", max(user_cpu))
                        print("The avg usage is:",
                              round(statistics.mean(user_cpu), 2))
                        return
                    elasep_count += 1
                    if elasep_count == elasep:
                        print("The max usage is:", max(user_cpu))
                        print("The avg usage is:",
                              round(statistics.mean(user_cpu), 2))
                        return
            # break
    return


def readLog(path,fileName):
    print("Loading...", fileName, "-----")
    # pwd = os.getcwd()
    tag = True  # This tag is used to check time
    with open("{}/{}".format(path, fileName), "r") as file:
        for i in reversed(file.readlines()):
            i = i.strip()
            # find a summary list
            if i != "" and i.find("Test Summary") > -1:
                if i.find("Test Summary:Total") > -1:
                    # index_1 = i.find("transaction=")
                    # index_2 = i.find(", ")
                    # index_3 = i.find("total throughput=")
                    # print("Total", i[index_1:index_2], "/", i[index_3:])
                    print(i[10:])
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
    # You should modify you own data
    filesList = os.listdir("./")
    if not arg:
        logsPath = "/opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/Logs"
    else:
        logsPath = arg[0]
    logsLists = os.listdir(logsPath)
    print(logsLists)
    for i in logsLists:
        try:
            if i[-3:] == "log":
                print("------[calculating log...]------")
                LogfileName = i
                tStart, tEnd = readLog(logsPath,LogfileName)

                # run code
                elasep = int((tEnd-tStart)/1000)
                tStart, tEnd = __initTime(tStart, tEnd)
                print("Elasep time:", elasep)
                print("----------------")
                for fileName in filesList:
                    if fileName.endswith(".txt"):
                        readFile(fileName, tStart, elasep)
        except print(0):
            pass


__main__()
