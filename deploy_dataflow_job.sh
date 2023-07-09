#!/bin/bash

PROJECT_ID="$1"

python source/dataflow/pipeline.py \
    --streaming \
    --runner DataflowRunner \
    --project "$PROJECT_ID" \
    --temp_location "gs://bucket_crypto_api_project_x999/temp" \
    --staging_location "gs://bucket_crypto_api_project_x999/stage" \
    --region "us-east1" \
    --job_name "cryptojob2" \
    --subscription "projects/$PROJECT_ID/subscriptions/dataflow" \
    --bq_path "$PROJECT_ID:crypto.crypto_price" \
    --num-workers 10
