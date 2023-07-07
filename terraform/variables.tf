variable "project_id" {}

variable "region" {
    default = "us-east1"
}
variable "secret_id" {
    default = "api_crypto_key" 
}
variable "secret_api_key" {
    
}
variable "name_bucket_crypto" {
  default = "bucket_crypto_api_project_999"
}
variable "dataset_id" {
    default ="crypto"
}
variable "name_topic_crypto" {
  default = "crypto-topic"
}
variable "dataflow_sub" {
    default = "dataflow"
}
variable "name_crypto_function_zip" {
  default = "crypto_function"
}