variable "project_id" {
    default = "playground-s-11-608e6f82"
}
variable "region" {
    default = "us-east1"
}
variable "secret_id" {
    default = "api_bitcoin_key" 
}
variable "secret_api_key" {
    
}
variable "name_bucket_bitcoin" {
  default = "bucket_bitcoin_api"
}
variable "name_topic_bitcoin" {
  default = "bitcoin-topic"
}
variable "name_bitcoin_function_zip" {
  default = "bitcoin_function"
}
#variable "excludes" {
#  default = "readme.md"
#}