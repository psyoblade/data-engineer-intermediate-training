#!/usr/bin/env python
# https://needjarvis.tistory.com/607
import threading, time

from kafka import KafkaAdminClient, KafkaConsumer, KafkaProducer
from kafka.admin import NewTopic
from json import dumps
from json import loads

KAFKA_HOST_PORT="kafka:9093"

def createTopic():
    try:
        admin = KafkaAdminClient(bootstrap_servers=KAFKA_HOST_PORT)
        topic = NewTopic(name='events', num_partitions=1, replication_factor=1)
        # admin.delete_topics([topic])

        print("create topic events")
        admin.create_topics([topic])
    except Exception:
        pass

def produceMessage():
    employees_json = [ { "emp_id":1, "emp_name":"엘지전자", "timestamp":1625238000, "time":"2021. 7. 3. 오전 12:00:00" },
    { "emp_id":1, "emp_name":"엘지전자", "timestamp":1625238300, "time":"2021. 7. 3. 오전 12:05:00" },
    { "emp_id":1, "emp_name":"엘지전자", "timestamp":1625238600, "time":"2021. 7. 3. 오전 12:10:00" },
    { "emp_id":2, "emp_name":"엘지화학", "timestamp":1625238900, "time":"2021. 7. 3. 오전 12:15:00" },
    { "emp_id":3, "emp_name":"엘지에너지솔루션", "timestamp":1625239800, "time":"2021. 7. 3. 오전 12:30:00" },
    { "emp_id":4, "emp_name":"엘지", "timestamp":1625241600, "time":"2021. 7. 3. 오전 1:00:00" },
    { "emp_id":4, "emp_name":"엘지", "timestamp":1625243400, "time":"2021. 7. 3. 오전 1:30:00" },
    { "emp_id":1, "emp_name":"엘지전자", "timestamp":1625239200, "time":"2021. 7. 3. 오전 12:20:00" } ]
    producer = None
    try:
        # producer = KafkaProducer(bootstrap_servers=KAFKA_HOST_PORT)
        producer = KafkaProducer(bootstrap_servers=KAFKA_HOST_PORT, value_serializer=lambda m: dumps(m, ensure_ascii=False).encode('utf-8'))
        for employee in employees_json:
            print("Sending {}".format(employee))
            producer.send('events', employee)
            time.sleep(0.1)
    except Exception:
        import traceback
        traceback.print_exc()
    finally:
        producer.close()

def consumeMessage():
    consumer = KafkaConsumer(bootstrap_servers=KAFKA_HOST_PORT, auto_offset_reset='earliest', consumer_timeout_ms=1000, value_deserializer=lambda m: loads(m.decode('utf-8')))
    consumer.subscribe(['events'])
    for message in consumer:
        print(message.value)
        time.sleep(0.1)
    consumer.close()

def main():
    # createTopic()
    produceMessage()
    # consumeMessage()

if __name__ == "__main__":
    main()
