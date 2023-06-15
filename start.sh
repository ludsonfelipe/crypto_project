#!/bin/bash

project_id="playground-s-11-c3a318ad"

gcloud config set project $project_id
gcloud services enable secretmanager.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable cloudbuild.googleapis.com
