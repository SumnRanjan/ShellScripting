#!/bin/bash

# EKS Three-Tier Setup Script
# File name: eks-setup.sh

set -e

# -----------------------------
# Variables - change if needed
# -----------------------------
CLUSTER_NAME="three-tier-cluster"
REGION="us-west-2"
NODE_TYPE="t2.medium"
NODES_MIN=2
NODES_MAX=2
NAMESPACE="workshop"
AWS_ACCOUNT_ID="626072240565"

# -----------------------------
# Step 1: IAM Configuration
# -----------------------------
# Create IAM user manually from AWS Console:
# User: eks-admin
# Permission: AdministratorAccess
# Then generate Access Key and Secret Access Key

# -----------------------------
# Step 2: EC2 Setup
# -----------------------------
# Launch Ubuntu EC2 instance manually
# SSH into the instance before running this script

# -----------------------------
# Step 3: Install AWS CLI v2
# -----------------------------
sudo apt-get update -y
sudo apt-get install unzip curl -y

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -o awscliv2.zip
sudo ./aws/install -i /usr/local/aws-cli -b /usr/local/bin --update

aws --version

# Configure AWS credentials manually
aws configure

# -----------------------------
# Step 4: Install Docker
# -----------------------------
sudo apt-get update -y
sudo apt-get install docker.io -y

sudo systemctl enable docker
sudo systemctl start docker

sudo chown $USER /var/run/docker.sock

docker ps

# -----------------------------
# Step 5: Install kubectl
# -----------------------------
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl

chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin

kubectl version --short --client

# -----------------------------
# Step 6: Install eksctl
# -----------------------------
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

sudo mv /tmp/eksctl /usr/local/bin

eksctl version

# -----------------------------
# Step 7: Create EKS Cluster
# -----------------------------
eksctl create cluster \
  --name $CLUSTER_NAME \
  --region $REGION \
  --node-type $NODE_TYPE \
  --nodes-min $NODES_MIN \
  --nodes-max $NODES_MAX

aws eks update-kubeconfig \
  --region $REGION \
  --name $CLUSTER_NAME

kubectl get nodes

# -----------------------------
# Step 8: Run Kubernetes Manifests
# -----------------------------
kubectl create namespace $NAMESPACE || true

# Apply all manifest files from current directory
kubectl apply -f .

# To delete manifests later, run manually:
# kubectl delete -f .

# -----------------------------
# Step 9: Install AWS Load Balancer Controller IAM Policy
# -----------------------------
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json

aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam_policy.json || true

eksctl utils associate-iam-oidc-provider \
  --region=$REGION \
  --cluster=$CLUSTER_NAME \
  --approve

eksctl create iamserviceaccount \
  --cluster=$CLUSTER_NAME \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::$AWS_ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve \
  --region=$REGION

# -----------------------------
# Step 10: Deploy AWS Load Balancer Controller
# -----------------------------
sudo snap install helm --classic || true

helm repo add eks https://aws.github.io/eks-charts
helm repo update eks

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

kubectl get deployment -n kube-system aws-load-balancer-controller

# Apply Load Balancer manifest
kubectl apply -f full_stack_lb.yaml

# -----------------------------
# Cleanup Commands
# -----------------------------
# Delete EKS cluster:
# eksctl delete cluster --name three-tier-cluster --region us-west-2
#
# Also manually:
# 1. Stop or terminate EC2 instance
# 2. Delete Load Balancer
# 3. Delete Security Groups
# 4. Delete unused IAM roles/policies if not needed