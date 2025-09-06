#!/bin/bash

echo "🚀 Deploying Banking App to EKS"
echo "==============================="

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

# Check prerequisites
print_info "Checking prerequisites..."
command -v kubectl >/dev/null 2>&1 || { print_error "kubectl required"; exit 1; }
command -v aws >/dev/null 2>&1 || { print_error "AWS CLI required"; exit 1; }
command -v terraform >/dev/null 2>&1 || { print_error "Terraform required"; exit 1; }

# Set variables
CLUSTER_NAME=${1:-banking-cluster}
AWS_REGION=${2:-us-east-1}
ECR_REGISTRY=${3:-your-account.dkr.ecr.us-east-1.amazonaws.com}

print_info "Cluster: $CLUSTER_NAME"
print_info "Region: $AWS_REGION"
print_info "ECR: $ECR_REGISTRY"

# Build and push images
print_info "Building and pushing Docker images..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

SERVICES=("auth-service" "account-service" "audit-service" "balance-service" "deposit-service" "notification-service" "transfer-service" "withdrawal-service" "api-gateway")

for service in "${SERVICES[@]}"; do
    print_info "Building $service..."
    cd $service
    docker build -t $ECR_REGISTRY/banking/$service:latest .
    docker push $ECR_REGISTRY/banking/$service:latest
    cd ..
    print_success "Pushed $service"
done

# Deploy infrastructure
print_info "Deploying EKS infrastructure..."
cd terraform
terraform init
terraform plan -var="aws_region=$AWS_REGION" -var="cluster_name=$CLUSTER_NAME"
terraform apply -auto-approve -var="aws_region=$AWS_REGION" -var="cluster_name=$CLUSTER_NAME"
cd ..

# Configure kubectl
print_info "Configuring kubectl..."
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

# Deploy applications
print_info "Deploying applications to EKS..."
kubectl apply -f k8s/eks/namespace.yaml
kubectl apply -f k8s/eks/rbac.yaml
kubectl apply -f k8s/eks/configmap.yaml
kubectl apply -f k8s/eks/deployments.yaml
kubectl apply -f k8s/eks/services.yaml
kubectl apply -f k8s/eks/hpa.yaml

# Wait for deployments
print_info "Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/auth-service -n banking-app
kubectl wait --for=condition=available --timeout=300s deployment/account-service -n banking-app
kubectl wait --for=condition=available --timeout=300s deployment/api-gateway -n banking-app

# Get LoadBalancer URL
print_info "Getting LoadBalancer URL..."
LB_URL=$(kubectl get svc api-gateway -n banking-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo ""
print_success "Deployment completed!"
echo ""
echo "📋 EKS Cluster Information:"
echo "  Cluster Name: $CLUSTER_NAME"
echo "  Region: $AWS_REGION"
echo "  Namespace: banking-app"
echo ""
echo "🌐 Access URLs:"
echo "  API Gateway: http://$LB_URL"
echo "  Health Check: http://$LB_URL/actuator/health"
echo ""
echo "🔧 Useful Commands:"
echo "  kubectl get pods -n banking-app"
echo "  kubectl logs -f deployment/auth-service -n banking-app"
echo "  kubectl describe hpa -n banking-app"
