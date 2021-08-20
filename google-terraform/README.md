# TheGraph -  Public Cloud Abstraction

### Infrastructure deployment in Google Cloud

After installing all the prerequisites specified on [STEP 1](https://github.com/easy2stake/thegraph), follow the next steps in order to deploy on Google Cloud.

### 1. Install gCLOUD CLI

```sh
sudo apt install apt-transport-https ca-certificates gnupg
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt update
sudo apt install google-cloud-sdk

# Confirm it is installed
gcloud version
Google Cloud SDK 353.0.0
alpha 2021.08.13
beta 2021.08.13
bq 2.0.71
core 2021.08.13
gsutil 4.66

```

### 2. Configure gCLOUD cli
```sh
gcloud init --console-only
# Now follow all the instructions prompted on screen in order to login to your google cloud subscription.
```
** PAY ATTENTION TO THIS:**
On the step above, when initialising for the first time, you have to create a new cloud project. The console message will be similar to this one:
```sh
Pick cloud project to use:
[1] the-graph-322812
[2] thegraph-test
[3] Create a new project
Please enter numeric choice or text value (must exactly match list item):
```
When creating a new cloud project you have to **enable billing before using terraform!** More details here: https://cloud.google.com/billing/docs/how-to/modify-project

```sh
# The configuration will be stored here
$HOME/.config/gcloud/
```
**NOTE**: If needed, you can list / set your google project using the following commands:
```sh
# This only applies when you have any preexisting google cloud projects.

gcloud projects list
	PROJECT_ID        NAME           PROJECT_NUMBER
	the-graph-322812  The Graph      370190005632
	thegraph-test     thegraph-test  708662500019

gcloud config set project PROJECT_ID
```

### 3. Get the Google Application Default Credentials (ADC).

```sh
# Run the following command:
gcloud auth application-default login --no-launch-browser

#Then follow the "on-screen" wizard
```
If everything worked well you will be prompted with something similar:
```sh
Credentials saved to file: [$HOME/.config/gcloud/application_default_credentials.json]
These credentials will be used by any library that requests Application Default Credentials (ADC).
Quota project "the-graph-322812" was added to ADC which can be used by Google client libraries for billing and quota. Note that some services may still bill the project owning the resource.
```

### 4. Enable Cloud APIs
```sh
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable servicenetworking.googleapis.com
gcloud services enable sqladmin.googleapis.com
```
### 5. Deploy the kubernetes cluster:

You must cd into google-terraform directory before using the commands below.

```sh
# Edit terraform.tfvars file and enter your project name there:
project_id = "PROJECT-NAME-USED-AT-STEP-2-ABOVE"

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
When the deploy job finishes you'll be prompted with a similar output:
```sh
Output:
    Apply complete! Resources: 16 added, 0 changed, 0 destroyed.

    Outputs:

    kubernetes_cluster_host = "34.134.125.55"
    kubernetes_cluster_name = "the-graph-322812-gke"
    postgresql_database_server_internal_ip = tolist([
      {
        "ip_address" = "35.188.62.175"
        "time_to_retire" = ""
        "type" = "PRIMARY"
      },
      {
        "ip_address" = "10.76.0.2"
        "time_to_retire" = ""
        "type" = "PRIVATE"
      },
    ])
    project_id = "the-graph-322812"
    region = "us-central1"
```
Write down the **DB PRIVATE IP ADDRESS**. You will need it to configure the database variables inside graph containers when deploying the application using HELM (The DB URL value inside values.yml)

**Get the OUTBOUND PUBLIC IP address of you cluster:**
```sh
gcloud compute addresses list
NAME                                    ADDRESS/RANGE  TYPE      PURPOSE      NETWORK               REGION       SUBNET  STATUS
the-graph-322812-private-ip-address     10.76.0.0/16   INTERNAL  VPC_PEERING  the-graph-322812-vpc                       RESERVED
nat-auto-ip-5596425-1-1629455214317489  35.238.34.145  EXTERNAL  NAT_AUTO                           us-central1          IN_USE
```
"***nat-auto-ip-5596425-1-1629455214317489***" is the outbound IP addresses of your "thegraph-deployment". Whitelist where is needed depending on your needs. EX: You might want to whitelist this IP address under your ETH RPC NODES / Archive nodes and so on.

### 5. Configure kubectl

```sh
# List your Kubernetes cluster(s)
gcloud container clusters list
NAME                  LOCATION     MASTER_VERSION   MASTER_IP      MACHINE_TYPE   NODE_VERSION     NUM_NODES  STATUS
the-graph-322812-gke  us-central1  1.20.9-gke.1000  34.134.125.55  n2d-highmem-2  1.20.9-gke.1000  3          RUNNING

# Use the cluster name and location from above into the next command
gcloud container clusters get-credentials the-graph-322812-gke --region us-central1 --project PROJECT-NAME-USED-AT-STEP-2-ABOVE
Fetching cluster endpoint and auth data.
kubeconfig entry generated for the-graph-322812-gke.
```


**Confirm that you're connected to the Kubernetes Cluster:**
```sh
# You should see and output similar to this one
    kubectl get pods --all-namespaces
    NAMESPACE            NAME                                                             READY   STATUS    RESTARTS   AGE
    ingress-controller   ingress-nginx-controller-b65df6fbb-qzm67                         1/1     Running   0          17m
    kube-system          event-exporter-gke-67986489c8-28czg                              2/2     Running   0          23m
    kube-system          fluentbit-gke-gkxkr                                              2/2     Running   0          18m
    kube-system          fluentbit-gke-l8dnr                                              2/2     Running   0          18m
    kube-system          fluentbit-gke-nvs5k                                              2/2     Running   0          18m
    kube-system          gke-metrics-agent-9k65k                                          1/1     Running   0          18m
    kube-system          gke-metrics-agent-jvqzp                                          1/1     Running   0          18m
    kube-system          gke-metrics-agent-wx8pc                                          1/1     Running   0          18m
    kube-system          kube-dns-autoscaler-844c9d9448-q8s2g                             1/1     Running   0          23m
    kube-system          kube-dns-b4f5c58c7-dk6vs                                         4/4     Running   0          23m
    kube-system          kube-dns-b4f5c58c7-kzgm5                                         4/4     Running   0          23m
    kube-system          kube-proxy-gke-the-graph-322812-the-graph-322812-1b6393d0-gq7c   1/1     Running   0          18m
    kube-system          kube-proxy-gke-the-graph-322812-the-graph-322812-1e48fd2d-4gfv   1/1     Running   0          18m
    kube-system          kube-proxy-gke-the-graph-322812-the-graph-322812-885b3871-18pt   1/1     Running   0          18m
    kube-system          l7-default-backend-56cb9644f6-n6v26                              1/1     Running   0          23m
    kube-system          metrics-server-v0.3.6-9c5bbf784-gm78h                            2/2     Running   0          17m
    kube-system          pdcsi-node-kl62s                                                 2/2     Running   0          18m
    kube-system          pdcsi-node-tc9nm                                                 2/2     Running   0          18m
    kube-system          pdcsi-node-zctm6                                                 2/2     Running   0          18m
    kube-system          stackdriver-metadata-agent-cluster-level-f9cc4d849-m9js4         2/2     Running   0          23m
```
