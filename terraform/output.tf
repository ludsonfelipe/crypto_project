#output "function_url" {
#  value = google_cloudfunctions_function.crypto_function.https_trigger_url
#}
#
output "topic_name" {
  value = google_pubsub_topic.crypto_topic.name
}

output "bucket_name" {
  value = google_storage_bucket.bucket_crypto_api.name
}

output "secret_name" {
  value = google_secret_manager_secret.api_secret_key.name
}

output "secret_version" {
  value = google_secret_manager_secret_version.api_secret_key_version.version
}
