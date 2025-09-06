# Karpenter Auto-Scaling Guide - Banking Application

## 🚀 Karpenter Overview

Karpenter is a Kubernetes cluster autoscaler that provisions nodes based on workload requirements. Unlike traditional cluster autoscalers, Karpenter:

- **Fast Provisioning**: Nodes ready in <30 seconds
- **Workload-Aware**: Provisions optimal instance types
- **Cost Optimization**: Automatic spot instance usage
- **Bin Packing**: Efficient resource utilization
- **Consolidation**: Removes underutilized nodes

## 🏗️ Architecture

### NodePools Configuration

#### General Purpose NodePool
```yaml
# For standard banking services
Instance Types: t3.medium, t3.large, t3.xlarge, m5.large, m5.xlarge
Capacity Types: Spot (preferred) + On-Demand
Consolidation: WhenUnderutilized (30s delay)
Expiration: 30 minutes
Limits: 1000 CPU, 1000Gi memory
```

#### Compute Optimized NodePool
```yaml
# For API Gateway and high-performance workloads
Instance Types: c5.large, c5.xlarge, c5.2xlarge, c5.4xlarge
Capacity Types: Spot only
Consolidation: WhenUnderutilized (15s delay)
Expiration: 10 minutes
Limits: 500 CPU, 500Gi memory
```

## 🎯 Banking Service Placement

### Service-to-NodePool Mapping

| Service | NodePool | Reasoning |
|---------|----------|-----------|
| **Auth Service** | General | Standard compute needs |
| **Account Service** | General | Database-heavy workload |
| **API Gateway** | Compute-Optimized | High throughput, low latency |
| **Audit Service** | General | Logging and compliance |
| **Other Services** | General | Standard microservice workloads |

### Tolerations & Affinity
```yaml
# Services tolerate Karpenter taints
tolerations:
- key: banking.com/general
  operator: Equal
  value: "true"
  effect: NoSchedule

# Prefer spot instances for cost optimization
affinity:
  nodeAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 50
      preference:
        matchExpressions:
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot"]
```

## 📊 Cost Optimization Features

### Spot Instance Strategy
- **Primary**: 80% spot instances for cost savings
- **Fallback**: On-demand for critical workloads
- **Interruption Handling**: SQS queue for graceful handling

### Node Consolidation
- **Trigger**: When nodes are underutilized
- **Delay**: 15-30 seconds before consolidation
- **Method**: Bin-packing to reduce node count

### Instance Selection
- **Multi-Type**: Diversified instance types
- **Right-Sizing**: Optimal CPU/memory ratio
- **Latest Generation**: Better price/performance

## 🔧 Installation & Deployment

### Quick Start
```bash
# Deploy with Karpenter
./deploy-eks-karpenter.sh banking-cluster us-east-1 your-ecr-registry

# Or install Karpenter separately
./install-karpenter.sh banking-cluster us-east-1
```

### Manual Installation
```bash
# Install Karpenter via Helm
helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter \
  --version v0.32.0 \
  --namespace karpenter \
  --create-namespace \
  --set settings.aws.clusterName=banking-cluster

# Apply NodePools
kubectl apply -f k8s/karpenter/nodepool.yaml

# Deploy banking services
kubectl apply -f k8s/karpenter/banking-deployments.yaml
```

## 📈 Monitoring & Observability

### Karpenter Metrics
```bash
# View Karpenter logs
kubectl logs -f -n karpenter -l app.kubernetes.io/name=karpenter

# Check NodePool status
kubectl get nodepools

# View provisioned nodes
kubectl get nodes -l karpenter.sh/nodepool

# Monitor scaling events
kubectl get events -n banking-app --sort-by='.lastTimestamp'
```

### Key Metrics to Monitor
- **Node Provisioning Time**: Target <30 seconds
- **Pod Scheduling Latency**: Time to schedule pods
- **Cost Savings**: Spot vs On-Demand usage
- **Node Utilization**: CPU/Memory efficiency

## 🎛️ Scaling Scenarios

### Traffic Spike Handling
1. **Pod Pending**: New pods can't be scheduled
2. **Karpenter Trigger**: Detects unschedulable pods
3. **Instance Selection**: Chooses optimal instance type
4. **Node Provisioning**: Launches EC2 instance
5. **Pod Scheduling**: Pods scheduled on new node
6. **Time**: Complete process in <30 seconds

### Cost Optimization
1. **Underutilization**: Nodes running below threshold
2. **Consolidation**: Karpenter identifies opportunity
3. **Bin Packing**: Reschedules pods efficiently
4. **Node Termination**: Removes unnecessary nodes
5. **Cost Savings**: Reduced infrastructure costs

## 🛡️ Security & Compliance

### IAM Permissions
- **Karpenter Controller**: EC2 instance management
- **Node Instance Profile**: EKS worker node permissions
- **Spot Interruption**: SQS queue access

### Security Features
- **IMDS v2**: Enforced metadata service
- **Encrypted Storage**: EBS volume encryption
- **Security Groups**: Network isolation
- **RBAC**: Kubernetes role-based access

## 🔍 Troubleshooting

### Common Issues

#### Pods Not Scheduling
```bash
# Check pending pods
kubectl get pods -n banking-app | grep Pending

# Describe pod for scheduling issues
kubectl describe pod <pod-name> -n banking-app

# Check NodePool constraints
kubectl describe nodepool banking-general
```

#### Node Provisioning Failures
```bash
# Check Karpenter logs
kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter

# Verify IAM permissions
aws sts get-caller-identity

# Check subnet/security group tags
aws ec2 describe-subnets --filters "Name=tag:karpenter.sh/discovery,Values=banking-cluster"
```

#### Cost Optimization Issues
```bash
# Check spot instance usage
kubectl get nodes -l karpenter.sh/capacity-type=spot

# Monitor node consolidation
kubectl get events -n karpenter

# Review NodePool limits
kubectl describe nodepool banking-general
```

## 📋 Best Practices

### Resource Requests
- **Always Set**: CPU and memory requests
- **Right-Size**: Avoid over/under provisioning
- **Burstable**: Use limits for burstable workloads

### NodePool Design
- **Workload-Specific**: Different pools for different needs
- **Instance Diversity**: Multiple instance types
- **Spot Strategy**: Prefer spot with on-demand fallback

### Monitoring
- **Scaling Events**: Track provisioning/termination
- **Cost Metrics**: Monitor spot savings
- **Performance**: Node utilization and pod density

## 🎯 Performance Tuning

### Karpenter Settings
```yaml
# Fast scaling for banking workloads
consolidateAfter: 15s  # Quick consolidation
expireAfter: 10m       # Short node lifetime
batchMaxDuration: 10s  # Fast batching
```

### Banking-Specific Optimizations
- **Database Connections**: Node-local connection pooling
- **Cache Locality**: Redis co-location preferences
- **Network Performance**: Enhanced networking instances
- **Storage**: GP3 volumes with provisioned IOPS

## 📊 Cost Analysis

### Expected Savings
- **Spot Instances**: 60-90% cost reduction
- **Right-Sizing**: 20-40% efficiency improvement
- **Consolidation**: 10-30% resource optimization
- **Overall**: 50-70% infrastructure cost reduction

### Cost Monitoring
```bash
# AWS Cost Explorer: Filter by Karpenter tags
# CloudWatch: Monitor EC2 instance costs
# Kubernetes: Resource utilization metrics
```
