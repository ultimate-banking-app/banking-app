#!/bin/bash

echo "📊 Setting up Banking Application Monitoring"
echo "============================================"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check if kubectl is available
if command -v kubectl >/dev/null 2>&1; then
    print_status 0 "kubectl is available"
else
    print_status 1 "kubectl is not available"
    echo "Please install kubectl: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

# Check if cluster is accessible
if kubectl cluster-info >/dev/null 2>&1; then
    print_status 0 "Kubernetes cluster is accessible"
else
    print_status 1 "Cannot access Kubernetes cluster"
    echo "Please configure kubectl to access your cluster"
    exit 1
fi

# Check if observability directory exists
if [ -d "observability" ]; then
    print_status 0 "Observability manifests directory exists"
else
    print_status 1 "Observability manifests directory not found"
    echo "Please ensure observability directory exists with monitoring manifests"
    exit 1
fi

echo ""
echo "🚀 Deploying observability stack..."

# Deploy observability namespace and RBAC
print_info "Creating observability namespace and RBAC..."
if kubectl apply -f observability/namespace.yaml; then
    print_status 0 "Observability namespace and RBAC created"
else
    print_status 1 "Failed to create observability namespace"
    exit 1
fi

# Deploy Prometheus
print_info "Deploying Prometheus with custom metrics..."
if kubectl apply -f observability/prometheus/; then
    print_status 0 "Prometheus deployed"
else
    print_status 1 "Failed to deploy Prometheus"
    exit 1
fi

# Deploy Grafana
print_info "Deploying Grafana with banking dashboards..."
if kubectl apply -f observability/grafana/; then
    print_status 0 "Grafana deployed"
else
    print_status 1 "Failed to deploy Grafana"
    exit 1
fi

# Deploy Jaeger
print_info "Deploying Jaeger for distributed tracing..."
if kubectl apply -f observability/jaeger/; then
    print_status 0 "Jaeger deployed"
else
    print_status 1 "Failed to deploy Jaeger"
    exit 1
fi

# Deploy Loki
print_info "Deploying Loki for log aggregation..."
if kubectl apply -f observability/loki/; then
    print_status 0 "Loki deployed"
else
    print_status 1 "Failed to deploy Loki"
    exit 1
fi

# Deploy Ingress
print_info "Deploying ingress for external access..."
if kubectl apply -f observability/ingress.yaml; then
    print_status 0 "Observability ingress deployed"
else
    print_status 1 "Failed to deploy observability ingress"
    exit 1
fi

echo ""
echo "⏳ Waiting for pods to be ready..."

# Wait for Prometheus
print_info "Waiting for Prometheus to be ready..."
if kubectl wait --for=condition=ready pod -l app=prometheus -n observability --timeout=300s; then
    print_status 0 "Prometheus is ready"
else
    print_status 1 "Prometheus failed to start"
fi

# Wait for Grafana
print_info "Waiting for Grafana to be ready..."
if kubectl wait --for=condition=ready pod -l app=grafana -n observability --timeout=300s; then
    print_status 0 "Grafana is ready"
else
    print_status 1 "Grafana failed to start"
fi

# Wait for Jaeger
print_info "Waiting for Jaeger to be ready..."
if kubectl wait --for=condition=ready pod -l app=jaeger -n observability --timeout=300s; then
    print_status 0 "Jaeger is ready"
else
    print_status 1 "Jaeger failed to start"
fi

# Wait for Loki
print_info "Waiting for Loki to be ready..."
if kubectl wait --for=condition=ready pod -l app=loki -n observability --timeout=300s; then
    print_status 0 "Loki is ready"
else
    print_status 1 "Loki failed to start"
fi

echo ""
echo "🔍 Checking deployment status..."

# Check all pods
kubectl get pods -n observability

echo ""
echo "🌐 Setting up access..."

# Check if ingress is available
if kubectl get ingress -n observability >/dev/null 2>&1; then
    print_info "Ingress is configured. Add these entries to your /etc/hosts:"
    echo "127.0.0.1 grafana.local prometheus.local jaeger.local"
else
    print_warning "Ingress not available. Use port forwarding:"
    echo ""
    echo "# Grafana (admin/admin123)"
    echo "kubectl port-forward -n observability svc/grafana 3000:3000"
    echo ""
    echo "# Prometheus"
    echo "kubectl port-forward -n observability svc/prometheus 9090:9090"
    echo ""
    echo "# Jaeger"
    echo "kubectl port-forward -n observability svc/jaeger-query 16686:16686"
fi

echo ""
echo "📊 Monitoring URLs:"
echo "==================="
if kubectl get ingress -n observability >/dev/null 2>&1; then
    echo "🎨 Grafana:    http://grafana.local (admin/admin123)"
    echo "📈 Prometheus: http://prometheus.local"
    echo "🔗 Jaeger:     http://jaeger.local"
else
    echo "🎨 Grafana:    http://localhost:3000 (admin/admin123)"
    echo "📈 Prometheus: http://localhost:9090"
    echo "🔗 Jaeger:     http://localhost:16686"
fi

echo ""
echo "📋 Custom Banking Metrics:"
echo "=========================="
echo "🏦 Business Metrics:"
echo "  - banking_login_attempts_total"
echo "  - banking_transactions_total"
echo "  - banking_account_balance"
echo "  - banking_payments_total"
echo "  - banking_payment_amount_total"
echo ""
echo "⚡ Technical Metrics:"
echo "  - banking_login_duration_seconds"
echo "  - banking_payment_processing_seconds"
echo "  - banking_gateway_requests_total"
echo "  - banking_circuit_breaker_events_total"

echo ""
echo "🚨 Automated Alerts Configured:"
echo "==============================="
echo "🔴 Critical:"
echo "  - Service Down (>1min)"
echo "  - Low Account Balance (<$100)"
echo ""
echo "🟡 Warning:"
echo "  - High Transaction Failure Rate (<95%)"
echo "  - High Login Failure Rate (<90%)"
echo "  - High API Error Rate (>5%)"

echo ""
echo "✅ Monitoring setup complete!"
echo ""
echo "🔧 Next steps:"
echo "1. Ensure banking services have Prometheus annotations"
echo "2. Deploy banking application: kubectl apply -k k8s/overlays/dev"
echo "3. Check metrics endpoints: curl http://service:port/actuator/prometheus"
echo "4. Access Grafana dashboards for banking metrics"
echo "5. Configure AlertManager for notifications (optional)"

echo ""
print_info "For troubleshooting, check:"
echo "  kubectl logs -n observability deployment/prometheus"
echo "  kubectl logs -n observability deployment/grafana"
echo "  kubectl get events -n observability"
