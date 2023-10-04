provider "google" {
    project = var.project_id
    region = var.region
}

resource "google_secret_manager_secret" "api_secret_key" {
    secret_id = var.secret_id
    
    replication {
      user_managed {
            replicas {
                location = var.region
            }
        }
    }
    }
resource "google_secret_manager_secret_version" "api_secret_key_version" {
    secret = google_secret_manager_secret.api_secret_key.id
    secret_data = var.secret_api_key
    depends_on = [
      google_secret_manager_secret.api_secret_key
    ]
}

resource "google_storage_bucket" "bucket_crypto_api" {
  name     = var.name_bucket_crypto
  location = var.region
}

resource "google_pubsub_topic" "crypto_topic" {
  name = var.name_topic_crypto
}

resource "google_pubsub_subscription" "dataflow_sub" {
  name = var.dataflow_sub
  topic = google_pubsub_topic.crypto_topic.name
}

data "archive_file" "crypto_cloud_function_folder" {
  type        = "zip"
  output_path = "/tmp/${var.name_crypto_function_zip}.zip"
  source_dir  = "${path.module}/../source/crypto_api_function"
}

resource "google_storage_bucket_object" "store_crypto_function" {
    name = "${var.name_crypto_function_zip}.${data.archive_file.crypto_cloud_function_folder.output_sha}.zip"
    bucket = google_storage_bucket.bucket_crypto_api.id
    source = data.archive_file.crypto_cloud_function_folder.output_path
    
}

resource "google_cloudfunctions_function" "crypto_function" {
    
    name         = "crypto-function"
    runtime      = "python310"
    entry_point  = "get_crypto_data"
    trigger_http = true     
    source_archive_bucket = google_storage_bucket.bucket_crypto_api.name
    source_archive_object = google_storage_bucket_object.store_crypto_function.name


    environment_variables = {
      TOPIC_ID   = var.name_topic_crypto
      PROJECT_ID = var.project_id
      SECRET_ID = google_secret_manager_secret_version.api_secret_key_version.secret_data
    }

    region = var.region
    timeout = 60    
    depends_on = [google_secret_manager_secret_version.api_secret_key_version, google_pubsub_topic.crypto_topic]  
}

resource "google_bigquery_dataset" "crypto_dataset" {
  dataset_id                  = var.dataset_id
  description                 = "Dataset that contains rates about crypto coins"
}
