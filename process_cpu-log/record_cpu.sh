#!/bin/bash
sar -u 1 &> pte_$(date +%m%d)_$(uname -n).txt