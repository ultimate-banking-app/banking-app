#!/bin/bash

echo "🚀 Installing ArgoCD for Banking Application"
echo "============================================"

# Create ArgoCD namespace
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD
echo "📦 Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Apply banking-specific configurations
echo "🏦 Applying banking application configurations..."
kubectl apply -k .

# Get ArgoCD admin password
echo "🔑 Getting ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Port forward ArgoCD server
echo "🌐 Setting up port forwarding..."
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
PORT_FORWARD_PID=$!

echo ""
echo "✅ ArgoCD Installation Complete!"
echo "================================"
echo "🌐 ArgoCD UI: https://localhost:8080"
echo "👤 Username: admin"
echo "🔑 Password: $ARGOCD_PASSWORD"
echo ""
echo "📋 Applications configured:"
echo "  - banking-dev (auto-sync enabled)"
echo "  - banking-prod (manual sync)"
echo "  - observability (auto-sync enabled)"
echo ""
echo "🛑 To stop port forwarding: kill $PORT_FORWARD_PID"
echo ""
echo "🔧 Next steps:"
echo "  1. Login to ArgoCD UI"
echo "  2. Update repository URLs in applications"
echo "  3. Sync applications to deploy"
