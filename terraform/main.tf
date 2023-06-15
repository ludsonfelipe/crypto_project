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

resource "google_storage_bucket" "bucket_bitcoin_api" {
  name     = var.name_bucket_bitcoin
  location = var.region
}

resource "google_pubsub_topic" "bitcoin_topic" {
  name = var.name_topic_bitcoin
}

data "archive_file" "bitcoin_cloud_function_folder" {
  type        = "zip"
  output_path = "/tmp/${var.name_crypto_function_zip}.zip"
  source_dir  = "${path.module}/../source/crypto_api_function"
  #excludes    = var.excludes
}

resource "google_storage_bucket_object" "store_bitcoin_function" {
    name = "${var.name_crypto_function_zip}.${data.archive_file.bitcoin_cloud_function_folder.output_sha}.zip"
    bucket = google_storage_bucket.bucket_bitcoin_api.id
    source = data.archive_file.bitcoin_cloud_function_folder.output_path
    
}

resource "google_cloudfunctions_function" "bitcoin_function" {
    
    name         = "bitcoin-function"
    runtime      = "python310"
    entry_point  = "get_bitcoin_data"
    trigger_http = true     
    source_archive_bucket = google_storage_bucket.bucket_bitcoin_api.name
    source_archive_object = google_storage_bucket_object.store_bitcoin_function.name


    environment_variables = {
      TOPIC_ID   = var.name_topic_bitcoin
      PROJECT_ID = var.project_id
      SECRET_ID = google_secret_manager_secret_version.api_secret_key_version.secret_data
    }

    region = var.region
    timeout = 60    
    depends_on = [google_secret_manager_secret_version.api_secret_key_version, google_pubsub_topic.bitcoin_topic]  
}