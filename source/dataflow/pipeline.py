import argparse
import apache_beam as beam
from apache_beam.transforms.userstate import BagStateSpec
from apache_beam.coders.coders import TupleCoder, FloatCoder
from apache_beam.options.pipeline_options import PipelineOptions

# Constantes
SCHEMA = 'code:STRING,rate:FLOAT,volume:INTEGER,cap:INTEGER,circulatingSupply:INTEGER\
,totalSupply:INTEGER,maxSupply:INTEGER,max_price:FLOAT,min_price:FLOAT,timestamp:TIMESTAMP'
SUBSCRIPTION = 'projects/playground-s-11-cdfc0c33/subscriptions/dataflow'

# Funções de transformação
def to_json(data):
    import json
    """Converte uma string JSON em um objeto Python."""
    data = json.loads(data)
    return data

def streaming_columns(crypto_dict):
    """Filtra e renomeia as colunas do dicionário de criptomoedas."""
    return {
        'code':crypto_dict.get('code'),
        'rate':crypto_dict.get('rate'),
        'volume':crypto_dict.get('volume'),
        'cap':crypto_dict.get('cap'),
        'circulatingSupply':crypto_dict.get('circulatingSupply'),
        'totalSupply':crypto_dict.get('totalSupply'),
        'maxSupply':crypto_dict.get('maxSupply')}

class SetCoinKey(beam.DoFn):
    """Define a chave para cada elemento com base no código."""
    def process(self, element, *args, **kwargs):
        yield element['code'], element

class MinMaxBitcoinPriceFn(beam.DoFn):
    """Calcula os preços máximo e mínimo do Bitcoin."""
    PRICE_STATE = BagStateSpec('price_state', TupleCoder((FloatCoder(), FloatCoder())))

    def process(self, element, prev_state=beam.DoFn.StateParam(PRICE_STATE), *args, **kwargs):
        current_price = element[1]['rate']
        previous_prices = list(prev_state.read())

        if previous_prices:
            if current_price > previous_prices[0][0]:
                prev_state.clear()
                prev_state.add((current_price, previous_prices[0][1]))
            elif current_price < previous_prices[0][1]:
                prev_state.clear()
                prev_state.add((previous_prices[0][0], current_price))
        else:
            prev_state.add((current_price, current_price))

        actual_prices = list(prev_state.read())
        element[1]['max_price'] = actual_prices[0][0]
        element[1]['min_price'] = actual_prices[0][1]
        yield element

def format_for_bigquery(element):
    """Formata o elemento para o formato adequado do BigQuery."""
    _, data = element
    return {
        'code': data['code'],
        'rate': data['rate'],
        'volume': data['volume'],
        'cap': data['cap'],
        'circulatingSupply': data['circulatingSupply'],
        'totalSupply': data['totalSupply'],
        'maxSupply': data['maxSupply'],
        'max_price': data['max_price'],
        'min_price': data['min_price'],
    }

def add_timestamp(element):
    from datetime import datetime
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    element['timestamp'] = timestamp

    return element

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    known_args = parser.parse_known_args()
    p = beam.Pipeline(options=PipelineOptions())

    (p | beam.io.ReadFromPubSub(subscription=SUBSCRIPTION).with_output_types(bytes)
    
    | beam.Map(lambda x: x.decode('utf-8'))
    | beam.FlatMap(to_json)
    | beam.Map(streaming_columns)
    | beam.ParDo(SetCoinKey())
    | beam.ParDo(MinMaxBitcoinPriceFn())
    | beam.Map(format_for_bigquery)
    | beam.Map(add_timestamp)
    | beam.io.WriteToBigQuery('playground-s-11-cdfc0c33:crypto.crypto_price',
                            create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED,
                            write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND,
                            schema=SCHEMA))
    result = p.run()
    result.wait_until_finish()

#python pipeline.py --streaming --runner DataflowRunner --project playground-s-11-7b1242ce --temp_location gs://bucket_bitcoin_api_project_99/temp --staging_location gs://bucket_bitcoin_api_project_99/stage --region us-east1 --job_name cryptoz