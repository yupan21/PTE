from __future__ import print_function
import psutil
import sys
import traceback
from datetime import datetime


def check_memory():
    while True:
        cpu = psutil.cpu_percent(interval=1)
        men = psutil.virtual_memory()
        t = str(datetime.now().strftime('%Y-%m-%d %I:%M:%S'))[11:]
        print(t+"     "+"Memory"+"     "+str(men[2]))

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