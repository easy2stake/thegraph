# TheGraph -  Public Cloud Abstraction

### Automated deployment using Terraform, Kubernetes and Helm

**Video Guide**: https://www.youtube.com/watch?v=ORr3yWBSn90

### Introduction
This is a Graph Protocol automated deployment using the following tools:
* Terraform - used to bring up the necessary cloud infrastructure
* Kubernetes - well known platform for managing containerized workloads and services
* Helm - a Kubernetes deployment tool for automating creation, configuration, and deployment of applications to Kubernetes clusters

**Public Clouds Supported:**

| Public Cloud | Supported |
| ------------ | ------------ |
| Azure Cloud | YES |
| AWS | YES |
| GKE | Work In Progress |

The aim of the project is to provide a fully automated method of deploying and managing TheGraph services while keeping the much needed modularity that the protocol needs.

This guide is also a work in progress and any feedback aiming to improve will be appreciated.


## HOW TO USE IT

**There are three simple steps (curently only Azure is supported):**
1. Install the tools (prerequisites)
2. Deploy the Cloud Infrastructure using Terraform
3. Deploy TheGraph containers using Helm

If you are a first time user we are strongly recommending to read through this guide and try to understand the differences step by step.

------------


### 1. Install prerequisites

| Tool | Recommended version |
| ------------ | ------------ |
| Terraform | 0.14.x - latest patch (now: 0.14.11) |
| Kubectl | Latest (now: v1.21.1) |
| Helm | Latest (now: v3.6.0) |

#### 1.A. The short version (commands used, in order):
```sh
cd $HOME
apt update && apt install curl wget unzip git

# Terraform
wget https://releases.hashicorp.com/terraform/0.14.11/terraform_0.14.11_linux_amd64.zip
unzip terraform_0.14.11_linux_amd64.zip
chmod 755 terraform
mv terraform /usr/local/bin/terraform

# Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod 755 kubectl
mv kubectl /usr/local/bin/kubectl

# Helm
wget https://get.helm.sh/helm-v3.6.0-linux-amd64.tar.gz
tar -xzvf helm-v3.6.0-linux-amd64.tar.gz
chmod 755 linux-amd64/helm
mv linux-amd64/helm /usr/local/bin/helm
```

#### 1.B. The long version (with command output and comments):
In order to install the following prerequisites make sure that you are logged as root.
```sh
cd $HOME
apt update && apt install curl wget unzip git
```

**Install Terraform**
```sh
wget https://releases.hashicorp.com/terraform/0.14.11/terraform_0.14.11_linux_amd64.zip
unzip terraform_0.14.11_linux_amd64.zip
chmod 755 terraform
mv terraform /usr/local/bin/terraform

# Confirm it's working:
terraform version
Terraform v0.14.11
```

**Install kubectl**
```sh
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod 755 kubectl
mv kubectl /usr/local/bin/kubectl

# Confirm it's working:
kubectl version
Client Version: version.Info{Major:"1", Minor:"21", GitVersion:"v1.21.1", GitCommit:"5e58841cce77d4bc13713ad2b91fa0d961e69192", GitTreeState:"clean", BuildDate:"2021-05-12T14:18:45Z", GoVersion:"go1.16.4", Compiler:"gc", Platform:"linux/amd64"}
```


**Install Helm**
```sh
wget https://get.helm.sh/helm-v3.6.0-linux-amd64.tar.gz
tar -xzvf helm-v3.6.0-linux-amd64.tar.gz
chmod 755 linux-amd64/helm
mv linux-amd64/helm /usr/local/bin/helm

# Confirm it's working:
helm version
version.BuildInfo{Version:"v3.6.0", GitCommit:"7f2df6467771a75f5646b7f12afb408590ed1755", GitTreeState:"clean", GoVersion:"go1.16.3"}
```
------------

### 2. Deploy your cloud infra using terraform

You can find the deployment instructions, depending on you chosen cloud provider, here:

- [DEPLOY ON AZURE](./azure-terraform/)
- [DEPLOY ON AWS](./aws-terraform)
- [DEPLOY ON Google Cloud](./google-terraform)

------------

### 3. Deploy TheGraph containers using helm

After deploying with terraform, the following steps are the same, independend of your chosen cloud provider.

#### 3.A. The short version (commands used, in order):
```sh
# Install
cd graphprotocol
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm dependency build .

# Edit the graphprotocol/values.yaml and install your deployment
helm install thegraph-deployment .

# Check
helm list
kubectl get pods

# Get the IPs
kubectl get ingress
```
#### 3.B. The long version (with command output and comments):
```sh
# Go the helm charts directory and install the dependencies
cd graphprotocol
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm dependency build .
```
**>>> Edit the graphprotocol\values.yaml file. <<<**
The **values.yaml** file contains all the variables needed by TheGraph in order to work.
Follow the comments inside the file in order to identify the variables that needs to be changed.


```sh
# Deploy TheGrap apps (remember to edit the values.yaml file before)
helm install thegraph-deployment .

# Confirm that the status of the deployment is "deployed"
helm list
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                           APP VERSION
ingress                 default         1               2021-06-16 15:35:18.666415289 +0000 UTC deployed        ingress-nginx-3.33.0            0.47.0
thegraph-deployment     default         1               2021-06-16 17:33:00.757097124 +0000 UTC deployed        graphprotocol-agent-0.1.0       0.1.0


# Check the status of the pods while the pods are beying created (imediately after issueing the helm deploy command)
kubectl get pods
NAME                                                           READY   STATUS              RESTARTS   AGE
index-node-0                                                   0/1     ContainerCreating   0          59s
indexer-agent-6b8787-z2gc7                                     0/1     ContainerCreating   0          59s
indexer-service-7887975b5c-fmhvs                               0/1     ContainerCreating   0          59s
ingress-ingress-nginx-controller-8f9b6b667-qf2z6               1/1     Running             0          118m
query-node-85457498fd-59tlz                                    0/2     ContainerCreating   0          59s
query-node-85457498fd-k5kz8                                    0/2     ContainerCreating   0          59s
thegraph-deployment-grafana-7d85cb59bc-m4zlz                   0/2     Init:0/1            0          59s
thegraph-deployment-kube-state-metrics-97bdc4d9c-ccv6q         0/1     ContainerCreating   0          59s
thegraph-deployment-prometheus-alertmanager-687dcf5b7f-ffg6k   0/2     ContainerCreating   0          59s
thegraph-deployment-prometheus-node-exporter-g2zxz             1/1     Running             0          59s
thegraph-deployment-prometheus-pushgateway-856dc495c-sjpgn     0/1     ContainerCreating   0          59s
thegraph-deployment-prometheus-server-585594ddd-x262r          0/2     ContainerCreating   0          59s
```
**NOTE**:
> Sometimes the indexer-service gets up faster than the index-node and it will fail on the first attempt.
It will automatically reload by itself when the index-node will be ready.
Due to this behaviour, in the next output we can notice a "3" on the RESTARTS column corespondig to the indexer-service.

```sh
# The initial deployment may take up to 5 minutes, when it's done all the pods should be running:
kubectl get pods
NAME                                                           READY   STATUS    RESTARTS   AGE
index-node-0                                                   1/1     Running   0          52m
indexer-agent-6b8787-jm8hq                                     1/1     Running   0          40m
indexer-service-7887975b5c-fmhvs                               1/1     Running   3          52m
ingress-ingress-nginx-controller-8f9b6b667-qf2z6               1/1     Running   0          170m
query-node-85457498fd-59tlz                                    2/2     Running   0          52m
query-node-85457498fd-k5kz8                                    2/2     Running   0          52m
thegraph-deployment-grafana-7d85cb59bc-m4zlz                   2/2     Running   0          52m
thegraph-deployment-kube-state-metrics-97bdc4d9c-ccv6q         1/1     Running   0          52m
thegraph-deployment-prometheus-alertmanager-687dcf5b7f-ffg6k   2/2     Running   0          52m
thegraph-deployment-prometheus-node-exporter-g2zxz             1/1     Running   0          52m
thegraph-deployment-prometheus-pushgateway-856dc495c-sjpgn     1/1     Running   0          52m
thegraph-deployment-prometheus-server-585594ddd-x262r          2/2     Running   0          52m

# Get the public IP of the ingress controller and add them to your DNS Zone and/or your hosts file
kubectl get ingress
NAME                         CLASS    HOSTS                                    ADDRESS         PORTS   AGE
indexer-agent                <none>   agent.thegraphtest.easy2stake.com        20.93.201.127   80      50m <- only if ingress is enabled. Disabled by default
indexer-service              <none>   service.thegraphtest.easy2stake.com      20.93.201.127   80      50m
new-test-grafana             <none>   grafana.thegraphtest.easy2stake.com      20.93.201.127   80      50m
new-test-prometheus-server   <none>   prometheus.thegraphtest.easy2stake.com   20.93.201.127   80      50m <- only if ingress is enabled. Disabled by default.
```

Access the ingress endpoints in your browser and confirm it's working.

#### Credentials for Grafana:
**Grafana user**: admin
**Grafana password**: `kubectl get secret --namespace default thegraph-deployment-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo`

#### Access Prometheus & Indexer Agent
**Prometheus:** No user and password defined. Use the whitelist inside values.yaml to control the access in case you activated the ingress for it, or access prometheus using PORT Forwarding:
kubectl get pods
kubectl port-forward pods/prometheus-server-<pod_id> 9090:9090

Browse: http://127.0.0.1:9090/

**Indexer Agent access**: Use the whitelist inside values.yaml to control the access in case you activated the ingress for it, or access Indexer Agent using PORT Forwarding:
kubectl get pods
kubectl port-forward pods/indexer-agent-<pod_id> 8000:8000

Browse: http://127.0.0.1:8000/

#### Security:
We strongly recommend that you enable HTTPS for all your services published via INGRESS controller. Once you have DNS records created for mentioned hosts (see above), you can use Cert-Manager (https://cert-manager.io/docs/) along with Let's Encrypt Certficate Authority (https://letsencrypt.org)

### 4. Troubleshooting
Work in progress.
