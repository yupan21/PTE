from __future__ import print_function
import psutil
print([x for x in psutil.disk_io_counters(perdisk=True)])