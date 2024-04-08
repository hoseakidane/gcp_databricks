# Databricks GCP Workspace Setup - Terraform 

### Goal: Deploy Custom VPC workspace with Unity Catalog on GCP
- [Documentation](https://docs.gcp.databricks.com/en/administration-guide/workspace/index.html)
- Video Walkthrough (coming soon..)
- Check out [GCP Databricks Best practices](https://github.com/bhavink/databricks/blob/master/gcpdb4u/readme.md) for more details

### Pre-requirements:
- Google account owner permissions or access to service principal with owner permissions 
- Install [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) 
- Install [Google cli](https://cloud.google.com/sdk/docs/install) or use [Google Cloud Shell](https://cloud.google.com/shell/docs/launching-cloud-shell)  
- Create a databricks account via [databricks trial](https://docs.gcp.databricks.com/en/administration-guide/account-settings-gcp/create-subscription.html)
  - This step needs to be done by a Google Cloud billing account administrator (**billing admin**) and they will become the Databricks account owner. The account owner can add more users to the Databricks account.

### Step 1: Authentication
####   Option 1: login authentication 
- Via Terminal/cloud Shell/UI, create a service account named privileged-sa with a “Project Owner” role or skip this step if using an existing SA with those permissions 
  - `gcloud iam service-accounts create privileged-sa --display-name="Privileged Service Account"`
  - `gcloud projects add-iam-policy-binding YOUR_PROJECT_ID --member="service account:privileged-sa@YOUR_PROJECT_ID --role="roles/owner"`
- In databricks account console UI, add the privilaged SA in the service principals tab and enable admin permissions for it
- Via Terminal/Cloud Shell, authenticate interactively using user principal (login) and follow the prompt: 
  - `gcloud auth login`
- Set gcloud configuration to impersonate the privileged-sa service account: 
  - `gcloud config set auth/impersonate_service_account "<insert-privilaged-sa-email>"`
- Set the access token environment variable for creating GCP resources: 
  - `export GOOGLE_OAUTH_ACCESS_TOKEN=$(gcloud auth print-access-token)`
- You are now authenticated with your GCP account
  - If you run into authentication errors past this point, make sure to rerun the above commands as the token may have expired 

#### Option 2: two SA key file authentication
- Follow the instructions [here](https://github.com/bhavink/databricks/blob/master/gcpdb4u/templates/terraform-scripts/sa-impersonation.md#create-the-service-account). 

### Step 2: Workspace Deployment
- Clone the terraform script [repo](https://github.com/hoseakidane/gcp_databricks_terraform_deployment?tab=readme-ov-file#step-1-authentication) to your local machine or cloud shell 
  - `git clone https://github.com/hoseakidane/gcp_databricks_terraform_deployment.git`
- Before running the Terraform Script:
    - Check and/or replace all variables with “# replace” comment 
      - Variables in auto.tfvars files **MUST** be replaced. Replacing other variables is optional.
    - If using key file authentication, place your “caller-sa” key json file inside the project root folder 
- Run the terraform script with the following terminal commands in the project root folder:
      - `Terraform init`
      - `Terraform plan`
      - `Terraform apply`
  - Verify workspace creation: In account console→workspaces
  - Verify UC metastore creation: In account console→data
  - Verify User group creation: In account console→user management
  - Verify Users/groups assigned to workspace: In workspace->admin settings->Identity and access
  - Verify cluster/warehouse creation: In compute & SQL Warehouses tab respectively. Initial start up time is longer than usual, wait 10-15 minutes.
- Once you have completed the verification steps, your workspace is ready for action!

### Recommended next steps
- Setup [cluster policies](https://docs.gcp.databricks.com/en/administration-guide/clusters/policies.html)
- Add additional users & groups

  
