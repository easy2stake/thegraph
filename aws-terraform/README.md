# TheGraph -  Public Cloud Abstraction

### Infrastructure deployment in AWS Cloud

After installing all the preerquisites specified on [STEP 1](https://github.com/easy2stake/thegraph), follow the next steps in order to deploy on Azure Cloud.

### 1. Install AWS CLI

```sh
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Confirm it is installed
aws --version
aws-cli/2.2.27 Python/3.8.8 Linux/5.11.0-25-generic exe/x86_64.ubuntu.20 prompt/off
```
>**MACOS USERS:** please use any version < 2.2.24. curently there is a bug in this version
**More details here:** https://github.com/aws/aws-cli/pull/6289


### 2. Configure aws cli
```sh
aws configure
AWS Access Key ID [None]: <YOUR-AWS-ACCESS-KEY>
AWS Secret Access Key [None]: <YOUR-AWS-SECRET-ACCESS-KEY>
Default region name [None]: us-west-2 #Choose your prefered default region here
Default output format [None]:

# The configuration will be stored here
$HOME/.aws #This is used by terraform to login and deploy the infrastructure
```
### 3. Install aws iam authenticator

```sh
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
sudo cp ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator

# Confirm it's working
aws-iam-authenticator version
{"Version":"v0.5.0","Commit":"1cfe2a90f68381eacd7b6dcfa2bf689e76eb8b4b"}
```

### 4. Deploy the kubernetes cluster:
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
When the deploy job finishes you'll be prompted with the "egress" ip addresses of your cluster.
Save the two IP addresses mentioned under the next line (your IPs will be different than the ones below):
```sh
IPs assigned to NAT Gateways that should be added in specific firewalls that protects ETH endpoints, other resources:
44.240.221.183
34.210.221.200
```
These are the outbound (public) IP addresses of your "thegraph-nodes". Whitelist where is needed depending on your needs. EX: You might want to whitelist these IP addresses under your ETH RPC NODES / Archive nodes and so on.

### 5. Configure kubectl

```sh
aws eks list-clusters
{
    "clusters": [
        "theGraph-EKS-CLS"
    ]
}

# Use the cluster name from above into the next command
aws eks update-kubeconfig --name theGraph-EKS-CLS
Added new context arn:aws:eks:us-west-2:069157684607:cluster/theGraph-EKS-CLS to /home/YOUR_USER/.kube/config
```


**Confirm that you're connected to the Kubernetes Cluster:**
```sh
kubectl get pods --all-namespaces
NAMESPACE            NAME                                       READY   STATUS    RESTARTS   AGE
ingress-controller   ingress-nginx-controller-b65df6fbb-2kpll   1/1     Running   0          6m40s
kube-system          aws-node-b7nkz                             1/1     Running   0          25m
kube-system          aws-node-xg6r6                             1/1     Running   0          25m
kube-system          coredns-86d9946576-h5v5f                   1/1     Running   0          28m
kube-system          coredns-86d9946576-vdplt                   1/1     Running   0          28m
kube-system          kube-proxy-p2lq2                           1/1     Running   0          25m
kube-system          kube-proxy-tpzxk                           1/1     Running   0          25m

# You should see and output similar to this one
```
