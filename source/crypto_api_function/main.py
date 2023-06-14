import requests as re
import json
from google.cloud import secretmanager
import os
from time import sleep
from google.cloud import pubsub_v1


def get_bitcoin_data(request):
    topic_id = os.environ.get('TOPIC_ID')
    project_id = os.environ.get('PROJECT_ID')
    secret_id = os.environ.get('SECRET_ID')

    secret = get_secret_value(secret_id, project_id)

    publisher = pubsub_v1.PublisherClient()
    topic_path = publisher.topic_path(project_id, topic_id)

    url = "https://api.livecoinwatch.com/coins/list"

    payload=json.dumps({
            'currency':'USD',
            'sort':'rank',
            'order':'ascending',
            'limit':100,
            'meta':True
            })

    headers = {
    'x-api-key':secret,
    'content-type': 'application/json'
    }

    while True:
        sleep(1)
        response = re.request("POST", url, headers=headers, data=payload)
        publisher.publish(topic_path, response.text.encode("utf-8"))
    
    return "Requisição foi um sucesso!"
