#!/bin/bash

project_id="my_project_id"

gcloud config set project $project_id
gcloud services enable secretmanager.googleapis.com
