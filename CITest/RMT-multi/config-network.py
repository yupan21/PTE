from __future__ import print_function
import os
import sys

arg = sys.argv[1:]

print(arg)
shell = []
target = ""
with open("./test_nl.sh",'r') as file:
    for line in file.readlines():
        line = line.strip()
        if line.startswith("bash networkLauncher.sh"):
            if not line.endswith("down"):
                for i in arg:
                    target += " "+i
                line = "bash networkLauncher.sh"+target
                print("changing network to ",line)
        shell.append(line)

with open("./test_nl.sh",'r+') as file:
    for l in shell:
        file.write(l+"\n")