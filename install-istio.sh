#!/bin/bash

echo "🔒 Installing Istio Service Mesh for Banking App"
echo "==============================================="

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

# Download and install Istio
print_info "Downloading Istio..."
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.20.0 sh -
export PATH=$PWD/istio-1.20.0/bin:$PATH

# Install Istio
print_info "Installing Istio control plane..."
istioctl install --set values.defaultRevision=default -y

# Enable sidecar injection for banking-app namespace
print_info "Enabling sidecar injection for banking-app namespace..."
kubectl label namespace banking-app istio-injection=enabled --overwrite

# Install Istio addons
print_info "Installing Istio addons (Kiali, Jaeger, Prometheus, Grafana)..."
kubectl apply -f istio-1.20.0/samples/addons/

# Wait for addons to be ready
kubectl wait --for=condition=available --timeout=300s deployment/kiali -n istio-system
kubectl wait --for=condition=available --timeout=300s deployment/jaeger -n istio-system

print_success "Istio installation completed!"

echo ""
echo "🔒 Istio Service Mesh Features:"
echo "  ✅ mTLS encryption between services"
echo "  ✅ Traffic management and routing"
echo "  ✅ Security policies and authorization"
echo "  ✅ Observability with Kiali and Jaeger"
echo ""
echo "🌐 Access URLs (after port-forward):"
echo "  Kiali: kubectl port-forward -n istio-system svc/kiali 20001:20001"
echo "  Jaeger: kubectl port-forward -n istio-system svc/jaeger 16686:16686"
echo "  Grafana: kubectl port-forward -n istio-system svc/grafana 3000:3000"
