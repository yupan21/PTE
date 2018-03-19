import pandas as pd
import statistics
import os
from datetime import datetime




def __init__(tStart,tEnd):
    print("initializing...")
    tStart = datetime.fromtimestamp(tStart/1000).strftime("%I:%M:%S")
    tEnd = datetime.fromtimestamp(tEnd/1000).strftime("%I:%M:%S")
    print("tStart:", tStart)
    print("tEnd:", tEnd)
    print("Command: sar -s {} -e {} > out_{}-{}.txt 2>&1".format(tStart,tEnd,tStart,tEnd))
    return tStart,tEnd

def readFile(fileName,tStart,tEnd):
    # read txt
    user_cpu = []

    with open("./process_cpu-log/{}".format(fileName),"r") as file:
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
                        print("The avg cpu usage is:", statistics.mean(user_cpu))
                        return 
            # break

# You should modify you own data
fileName = "pte_test_3_19_153.txt"
tStart = 1521431255614
tEnd = 1521431337889
# run code
elasep = int((tEnd-tStart)/1000)
tStart,tEnd =  __init__(tStart,tEnd)
print("Elasep time:", elasep)
readFile(fileName,tStart,elasep)
