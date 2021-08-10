# TheGraph -  Public Cloud Abstraction

### Infrastructure deployment in Azure Cloud

After installing all the preerquisites specified on [STEP 1](../), follow the next steps in order to deploy on Azure Cloud.

**Install az-cli** (optional)
```sh
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Confirm it's working:.
az version
{
  "azure-cli": "2.25.0",
  "azure-cli-core": "2.25.0",
  "azure-cli-telemetry": "1.0.6",
  "extensions": {}
}

```
**Grab the credentials from your Azure Tenant:**
```sh
# Clone the repo and enter the terraform dir
git clone https://github.com/easy2stake/thegraph
cd thegraph/azure-terraform

# Edit the azure-terraform/terraform.tfvars file and add your azure credentials.
# YOU NEED AN AZURE ACCOUNT IN ORDER TO PROCEED
client_id = "YOUR_AAD_APPLICATION_CLIENT_ID"
client_secret = "YOUR_AAD_APPLICATION_CLIENT_SECRET"
tenant_id = "YOUR_AAD_TENANT_ID"
subscription_id = "YOUR_AAD_SUBSCRIPTION_ID"
public_ssh_key = "RSA_SSH_PUBKEY_FOR_DIRECT_NODE_ACCESS"
```

> The data above can be obtained by creating a new Service Principal in Azure Active Directory.
Example: The output of the following command (az cli) will contain the client_id, client_secret and the tenant_id:
`az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<YOUR-SUBSCRIPTION-ID-HERE>"`
Please check the documentation here: https://docs.microsoft.com/en-us/cli/azure/ad/sp?view=azure-cli-latest#
Step by step documentation on our **Video Guide**: https://www.youtube.com/watch?v=ORr3yWBSn90

**Deploy the kubernetes cluster:**
```sh
# Initialize the working directory
terraform init
# Look for the "Terraform has been successfully initialized!" to confirm everything worked

# Preview the changes that Terraform plans to make to your infrastructure
terraform plan  -out=myplan.zip
# The output will be big, listing all the resources pending to be deployed on the public cloud

# Execute the actions proposed in a Terraform plan.
terraform apply "myplan.zip"
# Run and wait. It needs time to create the kubernetes cluster, the DB and all other necessary resources.
```


**Go to azure CLI and get K8S credentials**
This step is necessary in order to get access from the local kubectl shell to Azure K8S Cluster deployed with Terraform in the previous step.
```sh
mkdir -p $HOME/.kube
az aks get-credentials --resource-group RG-graphprotocol-aks --name graph-aks --file -
```
**Create and paste the output of the above command to: $HOME/.kube/config file**


**Confirm that you're connected to the Kubernetes Cluster:**
```sh
kubectl get pods --all-namespaces
NAMESPACE            NAME                                       READY   STATUS    RESTARTS   AGE
ingress-controller   ingress-nginx-controller-b65df6fbb-2kpll   1/1     Running   0          6m40s

# You should see and output similar to this one
```
