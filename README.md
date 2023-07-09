# crypto_project

virtualenv crypto_env
git clone repo
chmod +x ./enable_services.sh

terraform init
terraform plan -out "crypto_setup"
project_id / api_key
terraform apply

pip install -r requirements.txt
chmod +x ./deploy_dataflow_job.sh