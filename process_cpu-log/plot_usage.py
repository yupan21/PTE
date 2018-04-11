from __future__ import print_function
import matplotlib.pyplot as plt
import matplotlib.dates
import numpy as np
from datetime import datetime as dtdt
import time





def read_file(fileName, tags):
    print("reading {}".format(fileName))
    data = []
    tag = [i for i in tags if i in fileName][0]
    len_data = len(tags[tag])
    with open("./{}".format(fileName), "r") as file:
        for i in file.readlines():
            i = i[:-1].split("     ")
            datetime_object = dtdt.strptime(i[0], '%H:%M:%S')
            datenums = matplotlib.dates.date2num(datetime_object)
            data_object = i[0-len_data:]
            data.append([datenums]+data_object)
    return data


def plot(data):
    # n = 20
    # duration = 1000
    # now = time.mktime(time.localtime())
    # timestamps = np.linspace(now, now+duration, n)
    # dates = [dtdt.fromtimestamp(ts) for ts in timestamps]
    # print(dates)
    # datenums = matplotlib.dates.date2num(dates)
    # print(datenums)
    # values = np.sin((timestamps-now)/duration*2*np.pi)
    datenums = [i[0] for i in data]
    values = [i[1:] for i in data]
    xfmt = matplotlib.dates.DateFormatter('%H:%M:%S')
    ax = plt.gca()
    ax.xaxis.set_major_formatter(xfmt)
    plt.subplots_adjust(bottom=0.2)
    plt.xticks(rotation=25)
    plt.plot(datenums, values)
    plt.show()


fileName = "networkIO_blockchainmonion153.txt"
tags = {
    "networkIO": ["send(kb/s)", "receive(kb/s)"],
    "disk": ["read_count", "write_count", "read_data(kb/s)", "write_data(kb/s)", "busy_time(%)"],
    "memory": ["usage(%)"],
    "cpu": ["usage(%)"]
}

data = read_file(fileName, tags)

plot(data)