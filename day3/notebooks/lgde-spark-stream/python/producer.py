#!/usr/bin/env python

import sys
from time import sleep
from json import dumps
import json
from kafka import KafkaProducer
import names

# 카프카에 데이터를 전송하는 코드
def produce(port):
    try:
        hostname="kafka:%d" % port
        producer = KafkaProducer(bootstrap_servers=[hostname],
            value_serializer=lambda x: dumps(x).encode('utf-8')
        )
        data = {}
        for seq in range(9999):
            print("Sequence", seq)
            first_name = names.get_first_name()
            last_name = names.get_last_name()
            data["first"] = first_name
            data["last"] = last_name
            producer.send('events', value=data)
            sleep(0.5)
    except:
        import traceback
        traceback.print_exc(sys.stdout)

# 카프카의 데이터 수신을 위한 내부 포트는 9093
if __name__ == "__main__":
    port = 9093
    if len(sys.argv) == 2:
        port = int(sys.argv[1])
    produce(port)
