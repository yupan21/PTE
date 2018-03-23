#!/bin/bash
sar -u 1 &> cpu_$(uname -n).txt