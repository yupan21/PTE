from __future__ import print_function
import psutil
import sys
import traceback
import os
from datetime import datetime
import numpy as np

def check_memory():
    username = os.uname()[1]
    memory = open("./memory_{}.txt".format(username), "w")
    networkIO = open("./networkIO_{}.txt".format(username), "w")
    precentCPU = open("./cpu_{}.txt".format(username), "w")
    diskIO = open("./disk_{}.txt".format(username), "w")

    last_io_value = [0 for i in range(2)]
    last_disk_value = [0 for i in range(4)]
    last_busy_value = [0]

    first_line = True
    while True:
        cpu = psutil.cpu_percent(interval=1)
        men = psutil.virtual_memory()
        net = psutil.net_io_counters()
        disk = psutil.disk_io_counters()
        disk_busy = psutil.disk_io_counters(perdisk=True)
        diskNum = len(disk_busy)
        disk_items = [i[1] for i in disk_busy.items()]
        disk_items_busy = [i[-1]/10 for i in disk_items]
        # the number of disk
        t = str(datetime.now().strftime('%Y-%m-%d-%I:%M:%S'))
        # set timestamp
        memory_prec = t+"     "+"Memory(%)"+"     "+str(men[2])
        current_io_value = [net[i] - last_io_value[i] for i in range(2)]
        netIO = t+"     "+"NetIO(KB)"+"     " + \
            str(int(current_io_value[0]/1024)) + \
            "     " + str(int(current_io_value[1]/1024))
        cpu_prec = t+"     "+"CPU"+"     "+str(cpu)

        current_busy = [str(round(i,2)) for i in list(np.array(disk_items_busy) - np.array(last_busy_value))]
        current_disk_value = [disk[0] - last_disk_value[0],
                              disk[1] - last_disk_value[1],
                              disk[2] - last_disk_value[2],
                              disk[3] - last_disk_value[3],
                              "_".join(current_busy)]

        disk_io = t+"     "+"Disk"+"     "+str(int(current_disk_value[0]))+"     "+str(
            int(current_disk_value[1]))+"     "+str(int(current_disk_value[2]/1024))+"     "+str(int(current_disk_value[3]/1024))+"     "+str(current_disk_value[4])
        # The last item is busy time

        last_io_value = [net[i] for i in range(2)]
        last_disk_value = [disk[0], disk[1], disk[2], disk[3], disk[8]]
        last_busy_value = disk_items_busy
        if first_line:
            # skip first line
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
        check_memory()
    except KeyboardInterrupt:
        pass
    except Exception:
        pass
    sys.exit(0)


if __name__ == "__main__":
    main()
