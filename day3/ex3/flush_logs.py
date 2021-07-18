#!/usr/bin/env python
import sys, time, os, shutil

# 1. read apache_logs flush every 100 lines until 1000 lines
# 2.   every 1000 lines file close & rename file with seq
# 3. create new accesslogs and goto 1.

def readlines(fp, num_of_lines):
    lines = ""
    for line in fp:
        lines += line
        num_of_lines = num_of_lines - 1
        if num_of_lines == 0:
            break
    return lines


fr = open("apache_logs", "r")
for x in range(0, 10):
    fw = open("/fluentd/source/accesslogs", "w+")
    for y in range(0, 10):
        lines = readlines(fr, 100)
        fw.write(lines)
        fw.flush()
        time.sleep(0.1)
        sys.stdout.write(".")
        sys.stdout.flush()
    fw.close()
    print("file flushed ... sleep 10 secs")
    time.sleep(10)
    shutil.move("/fluentd/source/accesslogs", "/fluentd/source/accesslogs.%d" % x)
    print("renamed accesslogs.%d" % x)
fr.close()
