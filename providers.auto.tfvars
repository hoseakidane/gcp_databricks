/*
Make sure that the service account:
- Is added to databricks account console with admin role
- Has permissions listed over here 
https://docs.gcp.databricks.com/administration-guide/cloud-configurations/gcp/customer-managed-vpc.html#role-requirements
*/

google_service_account_email = "......." # replace with privilaged-sa service account email

/*
Service or Consumer Project, it contains Databricks managed:
Data plane (GKE)
DBFS Storage (GCS)
*/
google_project_name          = "...." # replace
/*
Host project aka Shared VPC
if not using shared vpc then use same project as google_project_name
*/
google_shared_vpc_project = "...." # replace
google_region                = "....." # replace

# run the following commands to authenticate via google cli gcloud auth login
# gcloud config set auth/impersonate_service_account <google service account email>
# export GOOGLE_OAUTH_ACCESS_TOKEN=$(gcloud auth print-access-token)