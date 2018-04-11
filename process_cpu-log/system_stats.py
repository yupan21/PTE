from __future__ import print_function
import psutil
import sys
import traceback
import os
from datetime import datetime

# difine you environment type
envir = "local"

def busy_disk(eachdisk):
    last_busy_time = [0,0,0]
    current_busy_time = []
    for disk_Name in eachdisk:
        if disk_Name == "dm-0" or disk_Name == "sda3" or disk_Name == "sda2":
            current_busy_time.append(last_busy_time)
            # developing

def check_memory_local():
    username = os.uname()[1]
    memory = open("./memory_{}.txt".format(username), "w")
    networkIO = open("./networkIO_{}.txt".format(username), "w")
    precentCPU = open("./cpu_{}.txt".format(username), "w")
    diskIO = open("./disk_{}.txt".format(username), "w")
    last_io_value = [0 for i in range(2)]
    last_disk_value = [0 for i in range(5)]
    first_line = True
    while True:
        cpu = psutil.cpu_percent(interval=1)
        men = psutil.virtual_memory()
        net = psutil.net_io_counters()
        disk = psutil.disk_io_counters()
        diskNum = len(psutil.disk_io_counters(perdisk=True))
        # the number of disk
        t = str(datetime.now().strftime('%Y-%m-%d %I:%M:%S'))[11:]
        # set timestamp
        memory_prec = t+"     "+"Memory(%)"+"     "+str(men[2])
        current_io_value = [net[i] - last_io_value[i] for i in range(2)]
        netIO = t+"     "+"NetIO(KB)"+"     " + \
            str(int(current_io_value[0]/1024)) + \
            "     " + str(int(current_io_value[1]/1024))
        cpu_prec = t+"     "+"CPU"+"     "+str(cpu)
        current_disk_value = [disk[0] - last_disk_value[0],
                              disk[1] - last_disk_value[1],
                              disk[2] - last_disk_value[2],
                              disk[3] - last_disk_value[3],
                              disk[8] - last_disk_value[4]]
        # busy_disk(eachdisk)
        # TODO: use busy disk to run each disk
        disk_io = t+"     "+"Disk"+"     "+str(int(current_disk_value[0]))+"     "+str(
            int(current_disk_value[1]))+"     "+str(int(current_disk_value[2]/1024))+"     "+str(int(current_disk_value[3]/1024))+"     "+str(round((current_disk_value[4]/diskNum)/10, 2))
        # The last item is busy time

        last_io_value = [net[i] for i in range(2)]
        last_disk_value = [disk[0], disk[1], disk[2], disk[3], disk[8]]
        if first_line:
            first_line = False
            continue
        else:
            # print(memory_prec)
            # print(netIO)
            # print(cpu_prec)
            # print(disk_io)
            memory.write(memory_prec+"\n")
            networkIO.write(netIO+"\n")
            precentCPU.write(cpu_prec+"\n")
            diskIO.write(disk_io+"\n")
            memory.flush()
            networkIO.flush()
            precentCPU.flush()
            diskIO.flush()
            # flush file real time, may affect performance a little bit, comment if you want to use more precise data

def check_memory_ecs():
    username = os.uname()[1]
    memory = open("./memory_{}.txt".format(username), "w")
    networkIO = open("./networkIO_{}.txt".format(username), "w")
    precentCPU = open("./cpu_{}.txt".format(username), "w")
    diskIO = open("./disk_{}.txt".format(username), "w")
    last_io_value = [0 for i in range(2)]
    last_disk_value = [0 for i in range(5)]
    first_line = True
    while True:
        cpu = psutil.cpu_percent(interval=1)
        men = psutil.virtual_memory()
        net = psutil.net_io_counters()
        disk = psutil.disk_io_counters(perdisk=True)
        t = str(datetime.now().strftime('%Y-%m-%d %I:%M:%S'))
        # set timestamp
        memory_prec = t+"     "+"Memory(%)"+"     "+str(men[2])
        current_io_value = [net[i] - last_io_value[i] for i in range(2)]
        netIO = t+"     "+"NetIO(KB)"+"     " + \
            str(int(current_io_value[0]/1024)) + \
            "     " + str(int(current_io_value[1]/1024))
        cpu_prec = t+"     "+"CPU"+"     "+str(cpu)
        current_disk_value = [disk[0] - last_disk_value[0],
                              disk[1] - last_disk_value[1],
                              disk[2] - last_disk_value[2],
                              disk[3] - last_disk_value[3],
                              disk[8] - last_disk_value[4], ]
        disk_io = t+"     "+"Disk"+"     "+str(int(current_disk_value[0]))+"     "+str(
            int(current_disk_value[1]))+"     "+str(int(current_disk_value[2]/1024))+"     "+str(int(current_disk_value[3]/1024))+"     "+str(round(current_disk_value[4]/1000, 2))
        # The last item is busy time

        last_io_value = [net[i] for i in range(2)]
        last_disk_value = [disk[0], disk[1], disk[2], disk[3], disk[8]]
        if first_line:
            first_line = False
            continue
        else:
            # print(memory_prec)
            # print(netIO)
            # print(cpu_prec)
            # print(disk_io)
            memory.write(memory_prec+"\n")
            networkIO.write(netIO+"\n")
            precentCPU.write(cpu_prec+"\n")
            diskIO.write(disk_io+"\n")
            memory.flush()
            networkIO.flush()
            precentCPU.flush()
            diskIO.flush()
            # flush file real time, may affect performance a little bit, comment if you want to use more precise data



def main():
    try:
        if envir == "local":
            check_memory_local()
        elif envir == "ecs":
            check_memory_ecs()
    except KeyboardInterrupt:
        pass
    except Exception:
        pass
    sys.exit(0)


if __name__ == "__main__":
    main()
