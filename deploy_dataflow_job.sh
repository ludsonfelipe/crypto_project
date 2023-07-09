#!/bin/bash

PROJECT_ID=""

python pipeline.py \
    --streaming \
    --runner DataflowRunner \
    --project "$PROJECT_ID" \
    --temp_location "gs://bucket_crypto_api_project_9899/temp" \
    --staging_location "gs://bucket_crypto_api_project_9899/stage" \
    --region "us-east1" \
    --job_name "cryptojob" \
    --subscription "projects/$PROJECT_ID/subscriptions/dataflow" \
    --bq_path "$PROJECT_ID:crypto.crypto_price"
