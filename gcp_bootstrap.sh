#!/bin/bash
#GCP Bootstrapping
#Here we're creating the core of a project on GCP so that we can perform IaC tasks against it.  
#We'll create/do the following items:
#   -Assign a billing account
#   -Generate a terraform service account
#   -Create a storage bucket to store our Terraform state

#Default Settings if not provided on Command Line
export TF_VAR_org_id=<insert org id here>
export TF_VAR_billing_account=<insert billing account here>
export TF_ADMIN=<enter what will become project_id for terraform project>
export TF_CREDS=~/.config/secrets/${TF_ADMIN}.json


gcloud projects create $TF_ADMIN --organization ${TF_VAR_org_id} --set-as-default
gcloud beta billing projects link $TF_ADMIN --billing-account $TF_VAR_billing_account

gcloud iam service-accounts create terraform --description="IaC Service Account" --project=$TF_ADMIN
mkdir -p ~/.config/secrets
gcloud iam service-accounts keys create $TF_CREDS --iam-account=terraform@${TF_ADMIN}.iam.gserviceaccount.com
export GOOGLE_APPLICATION_CREDENTIALS=$TF_CREDS
gcloud projects add-iam-policy-binding ${TF_ADMIN} --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com --role roles/viewer
gcloud projects add-iam-policy-binding ${TF_ADMIN} --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com --role roles/storage.admin
gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com --role roles/resourcemanager.projectCreator
gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com --role roles/billing.user
gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com --role roles/resourcemanager.folderCreator
gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com --role roles/compute.xpnAdmin


gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable serviceusage.googleapis.com

gsutil mb -p $TF_ADMIN gs://${TF_ADMIN}-storage
#Disable ability to assign public access permission on storage bucket to protect state file
gsutil pap set enforced gs://${TF_ADMIN}-storage
gsutil versioning set on gs://${TF_ADMIN}-storage
