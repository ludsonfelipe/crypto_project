import requests as re
from google.cloud import secretmanager
from google.cloud import pubsub_v1
import os
from time import sleep
import json

def get_crypto_data(request):
    topic_id = os.environ.get('TOPIC_ID')
    project_id = os.environ.get('PROJECT_ID')
    secret_id = os.environ.get('SECRET_ID')

    publisher = pubsub_v1.PublisherClient()
    topic_path = publisher.topic_path(project_id, topic_id)

    url = "https://api.livecoinwatch.com/coins/list"

    payload=json.dumps({
            'currency':'USD',
            'sort':'rank',
            'order':'ascending',
            'limit':10,
            'meta':True
            })

    headers = {
    'x-api-key':secret_id,
    'content-type': 'application/json'
    }

    while True:
        sleep(10)
        response = re.request("POST", url, headers=headers, data=payload)
        publisher.publish(topic_path, response.text.encode("utf-8"))
    return "Requisição foi um sucesso!"
