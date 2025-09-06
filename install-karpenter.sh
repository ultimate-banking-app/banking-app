#!/bin/bash

echo "🚀 Installing Karpenter for EKS Auto-Scaling"
echo "============================================"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Set variables
CLUSTER_NAME=${1:-banking-cluster}
AWS_REGION=${2:-us-east-1}
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

print_info "Cluster: $CLUSTER_NAME"
print_info "Region: $AWS_REGION"
print_info "Account: $AWS_ACCOUNT_ID"

# Install Karpenter using Helm
print_info "Installing Karpenter using Helm..."
helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter \
  --version v0.32.0 \
  --namespace karpenter \
  --create-namespace \
  --set settings.aws.clusterName=$CLUSTER_NAME \
  --set settings.aws.defaultInstanceProfile=KarpenterNodeInstanceProfile-$CLUSTER_NAME \
  --set settings.aws.interruptionQueueName=Karpenter-$CLUSTER_NAME \
  --set controller.resources.requests.cpu=1 \
  --set controller.resources.requests.memory=1Gi \
  --set controller.resources.limits.cpu=1 \
  --set controller.resources.limits.memory=1Gi \
  --wait

if [ $? -eq 0 ]; then
    print_success "Karpenter installed successfully"
else
    print_error "Karpenter installation failed"
    exit 1
fi

# Apply Karpenter NodePools
print_info "Applying Karpenter NodePools..."

# Update the nodepool YAML with actual values
sed -i.bak "s/YOUR-ACCOUNT/$AWS_ACCOUNT_ID/g" k8s/karpenter/nodepool.yaml
sed -i.bak "s/banking-cluster/$CLUSTER_NAME/g" k8s/karpenter/nodepool.yaml

kubectl apply -f k8s/karpenter/nodepool.yaml

if [ $? -eq 0 ]; then
    print_success "NodePools created successfully"
else
    print_error "NodePool creation failed"
    exit 1
fi

# Tag subnets and security groups for Karpenter discovery
print_info "Tagging subnets and security groups for Karpenter discovery..."

# Get VPC ID
VPC_ID=$(aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION --query "cluster.resourcesVpcConfig.vpcId" --output text)

# Tag private subnets
PRIVATE_SUBNETS=$(aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=*private*" \
  --query "Subnets[].SubnetId" --output text)

for subnet in $PRIVATE_SUBNETS; do
    aws ec2 create-tags --resources $subnet --tags Key=karpenter.sh/discovery,Value=$CLUSTER_NAME
done

# Tag security groups
CLUSTER_SG=$(aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION --query "cluster.resourcesVpcConfig.clusterSecurityGroupId" --output text)
aws ec2 create-tags --resources $CLUSTER_SG --tags Key=karpenter.sh/discovery,Value=$CLUSTER_NAME

# Get additional security groups
ADDITIONAL_SGS=$(aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION --query "cluster.resourcesVpcConfig.securityGroupIds[]" --output text)
for sg in $ADDITIONAL_SGS; do
    aws ec2 create-tags --resources $sg --tags Key=karpenter.sh/discovery,Value=$CLUSTER_NAME
done

print_success "Subnets and security groups tagged"

# Wait for Karpenter to be ready
print_info "Waiting for Karpenter to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/karpenter -n karpenter

# Apply banking deployments with Karpenter node affinity
print_info "Applying banking deployments with Karpenter configuration..."
kubectl apply -f k8s/karpenter/banking-deployments.yaml

print_success "Karpenter installation completed!"

echo ""
echo "📋 Karpenter Configuration:"
echo "  NodePools: banking-general, banking-compute-optimized"
echo "  Instance Types: t3.medium-xlarge, m5.large-xlarge, c5.large-4xlarge"
echo "  Capacity Types: Spot and On-Demand"
echo "  Auto-scaling: CPU/Memory based with consolidation"
echo ""
echo "🔧 Useful Commands:"
echo "  kubectl get nodepools"
echo "  kubectl get nodes -l karpenter.sh/nodepool"
echo "  kubectl logs -f -n karpenter -l app.kubernetes.io/name=karpenter"
echo "  kubectl describe nodepool banking-general"
echo ""
echo "📊 Monitor Scaling:"
echo "  kubectl get events -n banking-app --sort-by='.lastTimestamp'"
echo "  kubectl top nodes"
