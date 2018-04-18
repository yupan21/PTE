from __future__ import print_function
import os
from subprocess import check_output

pwd = "/opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log"
def connet2host(IP):
    print("connecting to",IP)
    diskName = check_output("ssh root@{} -i ~/.ssh/id_rsa \"cd {}; python utils_read_name.py\" ".format(IP, pwd),shell=True)
    uname = check_output("ssh root@{} -i ~/.ssh/id_rsa \"uname -n\" ".format(IP),shell=True)
    return diskName.decode(),uname.decode()

def readDiskName(IP):
    diskName,uname = connet2host(IP)
    # print(uname)
    # print(diskName)
    # disklist = eval(diskName)
    return diskName.strip(),uname.strip()

# def readIO(fileName, tStart, tEnd, elasep):
#     # read disk and network IO
#     send_read = []
#     recv_write = []
#     busy_time = []
#     read_bytes = []
#     write_bytes = []
#     print("Loading", fileName, "-----")
#     with open("./{}".format(fileName),"r") as file:
#         elasep_count = 0
#         for i in file.readlines():
#             i = i.strip()
#             # replace linebreak
#             if i != "":
#                 i = i.split("     ")
#                 if i[0].find(tStart) > -1 or elasep_count != 0:
#                     try:
#                         send_read.append(float(i[2]))
#                         recv_write.append(float(i[3]))
#                         try:
#                             read_bytes.append(float(i[4]))
#                             write_bytes.append(float(i[5]))
#                             busy_time.append(float(i[6]))
#                         except:
#                             pass
#                     except:
#                         print("The max [{}] of send or read io is".format(fileName[:5]), max(send_read))
#                         print("The avg [{}] of send or read io is".format(fileName[:5]), round(statistics.mean(send_read)))
#                         print("The max [{}] of receive or write io is".format(fileName[:5]), max(recv_write))
#                         print("The avg [{}] of receive or write io is".format(fileName[:5]), round(statistics.mean(recv_write)))
#                         if fileName.find("disk") > -1:
#                             print("The Max/Sum busy time(s):", max(busy_time),sum(busy_time))
#                             print("Max Read data(KB/s):",max(read_bytes))
#                             print("Max Write data(KB/s):",max(write_bytes))
#                         return
#                     elasep_count += 1
#                     if elasep_count == elasep or i[0].find(tEnd) > -1 :
#                         print("The max [{}] of send or read io is".format(fileName[:5]), max(send_read))
#                         print("The avg [{}] of send or read io is".format(fileName[:5]), round(statistics.mean(send_read)))
#                         print("The max [{}] of receive or write io is".format(fileName[:5]), max(recv_write))
#                         print("The avg [{}] of receive or write io is".format(fileName[:5]), round(statistics.mean(recv_write)))
#                         if fileName.find("disk") > -1:
#                             print("The Max/Sum busy time(s):", max(busy_time),sum(busy_time))
#                             print("Max Read data(KB/s):",max(read_bytes))
#                             print("Max Write data(KB/s):",max(write_bytes))
#                         return
#     print("readIO ends...")
#     return


# def readSys(fileName, tStart, tEnd, elasep):
#     # read cpu and memory txt
#     user_cpu = []
#     print("Loading", fileName, "-----")
#     # pwd = os.getcwd()
#     with open("./{}".format(fileName), "r") as file:
#         elasep_count = 0
#         for i in file.readlines():
#             i = i.strip()
#             if i != "":
#                 i = i.split("     ")
#                 if i[0].find(tStart) > -1 or elasep_count != 0:
#                     try:
#                         user_cpu.append(float(i[2]))
#                     except:
#                         print("The max [{}] is:".format(fileName[:5]), max(user_cpu))
#                         print("The avg [{}] is:".format(fileName[:5]),
#                               round(statistics.mean(user_cpu), 2))
#                         return
#                     elasep_count += 1
#                     if elasep_count == elasep or i[0].find(tEnd) > -1:
#                         print("The max [{}] is:".format(fileName[:5]), max(user_cpu))
#                         print("The avg [{}] is:".format(fileName[:5]),
#                               round(statistics.mean(user_cpu), 2))
#                         return
#             # break
#     return

# def main():
#     for i in logsLists:
#         try:
#             if i[-3:] == "log":
#                 print("------[calculating log...]------")
#                 LogfileName = i
#                 tStart, tEnd = readLog(logsPath,LogfileName)
#                 # read logs
#                 elasep = int((tEnd-tStart)/1000)
#                 tStart, tEnd = __initTime(tStart, tEnd)
#                 # calculate start time and elasep time
#                 print("Elasep time:", elasep)
#                 print("----------------")
#                 for fileName in filesList:
#                     if fileName.endswith(".txt"):
#                         # read computer status log
#                         if fileName.startswith("networkIO") or fileName.startswith("disk"):
#                             # read IO file
#                             readIO(fileName, tStart, tEnd, elasep)
#                         else:
#                             readSys(fileName, tStart, tEnd, elasep)
#         except print(0):
#             pass
