variable "project_id" {}

variable "region" {
    default = "us-east1"
}
variable "secret_id" {
    default = "api_bitcoin_key" 
}
variable "secret_api_key" {
    
}
variable "name_bucket_bitcoin" {
  default = "bucket_bitcoin_api_project__99"
}
variable "dataset_id" {
    default ="crypto"
}
variable "name_topic_bitcoin" {
  default = "bitcoin-topic"
}
variable "dataflow_sub" {
    default = "dataflow"
}
variable "name_crypto_function_zip" {
  default = "bitcoin_function"
}