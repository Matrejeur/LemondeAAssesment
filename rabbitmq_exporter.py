import os
import time
import requests
from prometheus_client import start_http_server, Gauge

# Environment variables
RABBITMQ_HOST = os.getenv('RABBITMQ_HOST', 'localhost')
RABBITMQ_USER = os.getenv('RABBITMQ_USER', 'rabmq_user')
RABBITMQ_PASSWORD = os.getenv('RABBITMQ_PASSWORD', 'rabmq_passwd')
RABBITMQ_API_URL = f'http://{RABBITMQ_HOST}:15672/api/queues'

# Prometheus metrics
messages_gauge = Gauge('rabbitmq_individual_queue_messages', 'Total count of messages', ['host', 'vhost', 'name'])
messages_ready_gauge = Gauge('rabbitmq_individual_queue_messages_ready', 'Count of ready messages', ['host', 'vhost', 'name'])
messages_unack_gauge = Gauge('rabbitmq_individual_queue_messages_unacknowledged', 'Count of unacknowledged messages', ['host', 'vhost', 'name'])

def fetch_queue_metrics():
    response = requests.get(RABBITMQ_API_URL, auth=(RABBITMQ_USER, RABBITMQ_PASSWORD))
    response.raise_for_status()
    queues = response.json()

    for queue in queues:
        host = RABBITMQ_HOST
        vhost = queue['vhost']
        name = queue['name']
        messages = queue['messages']
        messages_ready = queue['messages_ready']
        messages_unack = queue['messages_unacknowledged']

        messages_gauge.labels(host, vhost, name).set(messages)
        messages_ready_gauge.labels(host, vhost, name).set(messages_ready)
        messages_unack_gauge.labels(host, vhost, name).set(messages_unack)

if __name__ == '__main__':
    start_http_server(8000)
    while True:
        fetch_queue_metrics()
        time.sleep(30)
