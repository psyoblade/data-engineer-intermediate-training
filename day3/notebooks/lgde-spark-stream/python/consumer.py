from kafka import KafkaAdminClient, KafkaConsumer, KafkaProducer

consumer = KafkaConsumer(bootstrap_servers='kafka:9093', auto_offset_reset='earliest', consumer_timeout_ms=1000)
consumer.subscribe(['events'])
for message in consumer:
    print(message)
consumer.close()
