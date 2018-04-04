from __future__ import print_function
import sys
from subprocess import Popen
import subprocess
from commands import getstatusoutput as command

localip = "172.16.50.151"
hostip = "172.16.50.153"
# local-ip = "39.108.167.205"
# host-ip = "120.79.163.88"

def swarm():
    init_command = "bash ./multi-setup.sh {}".format(localip)
    # leaving swarm
    command(init_command)[1]
    join_token = command("docker swarm join-token manager")[1]
    for i in join_token.split("\n"):
        if i.find("SWMTKN") > -1:
            join_token = i
            print join_token
    return 

def ssh_join():
    cmd_1 = "ssh root@{} -i ~/.ssh/id_rsa \"uname -a \""
    print command(cmd_1)[1]


def main():
    swarm()
    ssh_join()


if __name__ == "__main__":
    main()