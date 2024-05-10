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
- Clone this terraform script [repo](https://github.com/hoseakidane/gcp_databricks_terraform_deployment?tab=readme-ov-file#step-1-authentication) to your local machine or cloud shell 
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
-   Secure your [GCS buckets](https://docs.gcp.databricks.com/en/administration-guide/workspace/create-workspace.html#secure-the-workspaces-gcs-buckets-in-your-project)

-   Enable [Private Google Access](https://github.com/bhavink/databricks/blob/master/gcpdb4u/security/Configure-PrivateGoogleAccess.md) 

-   Setup [cluster policies](https://docs.gcp.databricks.com/en/administration-guide/clusters/policies.html#create-and-manage-compute-policies)

-   Setup [SSO](https://docs.gcp.databricks.com/en/security/auth-authz/index.html#single-sign-on) & SCIM

- Enable [Delta Sharing](https://docs.gcp.databricks.com/en/data-sharing/index.html#what-is-delta-sharing) on UC Metastore

  
### FAQ

-   I can't use a local terminal

    -   Launch a [Google Cloud shell](https://cloud.google.com/shell/docs/launching-cloud-shell) and clone the repo there.

-   What are my authentication options?

    -   "Privileged service account auth" or temporary two SA [Impersonation](https://github.com/bhavink/databricks/blob/master/gcpdb4u/templates/terraform-scripts/sa-impersonation.md) 

    -   We recommend using "privileged service account auth" for simplicity.  

-   I don't have access to an owner-privileged SA, what should I do? 

    -   We suggest reaching out to your IT team to request access or have them execute the terraform script.

-   I don't understand the terraform error log

    -   Most errors are due to authentication or insufficient permissions.
    - Make sure you have completed all the pre-requirement steps before running the script.
    - Enable debug mode and send screenshots of the entire stack trace to your account team. Explain what steps you have taken prior to the error. 


-   Will I need to increase my current quotas for Google Cloud resources?

    -   Consult Databricks [resource quotas](https://docs.gcp.databricks.com/en/administration-guide/account-settings-gcp/quotas.html) documentation to set proper quotas.

    -   For Example, clusters can fail if your project exceeds its CPU quota. 

-   How many subnets do I need?

    -   In total, a Databricks workspace needs 4 subnets.

        -   Node Subnet (primary)

        -   Pod Subnet (secondary1) - determines concurrent node limit

        -   Service Subnet (secondary2)

        -   Kube Master VPC - created and managed by GCP and is of fixed size /28

-   Can I share subnets among different Databricks workspaces?

    -   No, each workspace requires 3 dedicated subnets. 

    -   Pay close attention to subnet CIDR ranges. Once you create the workspace, you cannot change it.

    -   Consult [Subnet size calculator](https://docs.gcp.databricks.com/en/administration-guide/cloud-configurations/gcp/network-sizing.html). 
    -   We recommend using the largest possible CIDR range. 

-   Can I share a VPC among different Databricks workspaces?

    -   Yes, as long as you do not use subnets that other workspaces are already using.

-   What is the supported IP address range?

    -   10.0.0.0/8, 100.64.0.0/10, 172.16.0.0/12, 192.168.0.0/16, and 240.0.0.0/4