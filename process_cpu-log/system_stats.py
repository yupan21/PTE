from __future__ import print_function
import psutil
import sys
import traceback
import os
from datetime import datetime


def check_memory():
    username = os.uname()[1]
    with open("./memory_{}.txt".format(username), "w") as memory:
        with open("./networkIO_{}.txt".format(username), "w") as networkIO:
            with open("./cpu_{}.txt".format(username),"w") as precentCPU:
                with open("./disk_{}.txt".format(username),"w") as diskIO:
                    last_io_value = [0 for i in range(2)]
                    last_disk_value = [0 for i in range(2)]
                    first_line = True
                    while True:
                        cpu = psutil.cpu_percent(interval=1)
                        men = psutil.virtual_memory()
                        net = psutil.net_io_counters()
                        disk = psutil.disk_io_counters()
                        t = str(datetime.now().strftime('%Y-%m-%d %I:%M:%S'))[11:]
                        # set timestamp
                        memory_prec = t+"     "+"Memory"+"     "+str(men[2])
                        current_io_value = [net[i] - last_io_value[i] for i in range(2)]
                        netIO = t+"     "+"NetIO"+"     "+str(int(current_io_value[0]/1024))+"     " +str(int(current_io_value[0]/1024))
                        cpu_prec = t+"     "+"CPU"+"     "+str(cpu)
                        current_disk_value = [disk[2] - last_disk_value[0], disk[3] - last_disk_value[1]]
                        disk_io = t+"     "+"Disk"+"     "+str(int(current_disk_value[0]/1024))+"     "+str(int(current_disk_value[1]/1024))
                        

                        last_io_value = [net[i] for i in range(2)]
                        last_disk_value = [disk[i] for i in range(4) if i == 2 or i == 3]
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
