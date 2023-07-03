#!/bin/bash

project_id="playground-s-11-e41e85ca"

gcloud config set project $project_id
gcloud services enable secretmanager.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable cloudbuild.googleapis.com
