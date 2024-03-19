# Databricks GCP Workspace Setup - Terraform 

### Goal: Deploy Custom VPC workspace with Unity Catalog on GCP
- [Documentation](https://docs.gcp.databricks.com/en/administration-guide/workspace/index.html)
- Video Walkthrough (coming soon..)
- Check out [GCP Databricks Best practices](https://github.com/bhavink/databricks/blob/master/gcpdb4u/readme.md) for more details

### Pre-requirements:
- Google account owner permissions or access to service principal with owner permissions 
- Install [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) 
- Install [Google cli](https://cloud.google.com/sdk/docs/install)
- Create a databricks account via [databricks trial](https://docs.gcp.databricks.com/en/administration-guide/account-settings-gcp/create-subscription.html)

### Step 1: Authentication
####   Option 1: login authentication via terminal 
- Create a service account named privileged-sa with a “Project Owner” role or use an existing SA with those permissions 
  - `gcloud iam service-accounts create privileged-sa --display-name="Privileged Service Account"`
  - `gcloud projects add-iam-policy-binding YOUR_PROJECT_ID --member="service account:privileged-sa@YOUR_PROJECT_ID --role="roles/owner"`
- Authenticate interactively using user principal (login) and follow the prompt: 
  - `gcloud auth login`
- Set gcloud configuration to impersonate the privileged-sa service account: 
    - `gcloud config set auth/impersonate_service_account <insert-privilaged-sa-email>`
- Set the access token environment variable for creating GCP resources: 
    - `export GOOGLE_OAUTH_ACCESS_TOKEN=$(gcloud auth print-access-token)`
- You are now authenticated with your GCP account
    - If you run into authentication errors past this point, make sure to rerun the above commands as the token may have expired 

#### Option 2: key file authentication
- Follow the instructions [here](https://github.com/bhavink/databricks/blob/master/gcpdb4u/templates/terraform-scripts/sa-impersonation.md#create-the-service-account). 

### Step 2: Workspace Deployment
- Pull this repo to your local machine (## add git link here)
- Before running the Terraform Script:
    - Check and/or replace all variables with “# replace” comment 
    - If using key file authentication, place your “caller-sa” key json file inside the project root folder 
    - Run the terraform script with the following terminal commands in the project root folder:
        - `Terraform init`
        - `Terraform plan`
        - `Terraform apply`
- Verify workspace creation: In account console→workspaces tab
- Verify UC metastore creation: In account console→data tab
- Verify User group creation: In account console→user management tab
  
 