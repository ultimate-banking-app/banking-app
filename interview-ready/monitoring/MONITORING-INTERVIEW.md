# Monitoring Interview Guide - Banking Application

## 📊 Monitoring Architecture Overview

### **4-Layer Observability Stack**
```
┌─────────────────────────────────────────────────────────────┐
│                 Alerting & Notification Layer               │
│            Slack + Email + PagerDuty + Webhooks            │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                 Visualization & Analytics Layer             │
│                        Grafana                              │
│              Dashboards + Alerts + Reports                 │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                   Metrics & Storage Layer                   │
│                       Prometheus                            │
│              Time-series DB + Query Engine                 │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                 Application & Infrastructure Layer          │
│    Spring Boot Actuator + JVM + OS + Container Metrics     │
└─────────────────────────────────────────────────────────────┘
```

### **Monitoring Scope**
- **10 Banking Microservices** with individual health monitoring
- **Infrastructure Metrics** (CPU, Memory, Disk, Network)
- **Application Performance** (Response time, Throughput, Errors)
- **Business Metrics** (Transactions, Account operations, Balances)
- **Security Monitoring** (Authentication failures, Suspicious activities)

## 🎤 Key Interview Questions & Answers

### **Q: Explain your monitoring strategy for a banking application.**
```
A: "Banking applications require comprehensive monitoring due to regulatory requirements and critical nature:

GOLDEN SIGNALS (SRE APPROACH):
1. LATENCY: How long requests take
   - 95th percentile response time < 500ms
   - 99th percentile response time < 1s
   - Critical operations (payments) < 200ms

2. TRAFFIC: Request volume and patterns
   - Requests per second per service
   - Peak hour traffic patterns
   - Geographic distribution of requests

3. ERRORS: Rate of failed requests
   - HTTP 4xx/5xx error rates
   - Business logic failures
   - Timeout and circuit breaker activations

4. SATURATION: Resource utilization
   - CPU usage < 70%
   - Memory usage < 80%
   - Database connection pool utilization
   - Queue depths and processing delays

BANKING-SPECIFIC MONITORING:
1. TRANSACTION INTEGRITY:
   - Transaction success/failure rates
   - Account balance consistency checks
   - Reconciliation monitoring

2. SECURITY MONITORING:
   - Failed authentication attempts
   - Suspicious transaction patterns
   - API rate limiting violations

3. COMPLIANCE MONITORING:
   - Audit trail completeness
   - Data retention compliance
   - Regulatory reporting metrics

4. BUSINESS METRICS:
   - Account creation rates
   - Transaction volumes by type
   - Revenue impact metrics"
```

### **Q: How do you implement application monitoring with Spring Boot?**
```
A: "Spring Boot Actuator provides comprehensive monitoring capabilities:

ACTUATOR ENDPOINTS CONFIGURATION:
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus,env
  endpoint:
    health:
      show-details: always
      show-components: always
  metrics:
    export:
      prometheus:
        enabled: true
    tags:
      application: \${spring.application.name}
      environment: \${DEPLOY_ENV}

CUSTOM BUSINESS METRICS:
@RestController
public class AccountController {
    private final MeterRegistry meterRegistry;
    private final Counter accountCreationCounter;
    private final Timer accountCreationTimer;
    
    public AccountController(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        this.accountCreationCounter = Counter.builder('accounts.created')
            .description('Number of accounts created')
            .register(meterRegistry);
        this.accountCreationTimer = Timer.builder('accounts.creation.time')
            .description('Time taken to create account')
            .register(meterRegistry);
    }
    
    @PostMapping('/accounts')
    public Account createAccount(@RequestBody CreateAccountRequest request) {
        return accountCreationTimer.recordCallable(() -> {
            Account account = accountService.createAccount(request);
            accountCreationCounter.increment();
            
            // Custom gauge for account balance
            Gauge.builder('account.balance')
                .tag('account.type', account.getType().toString())
                .register(meterRegistry, account, acc -> acc.getBalance().doubleValue());
            
            return account;
        });
    }
}

HEALTH CHECKS:
@Component
public class DatabaseHealthIndicator implements HealthIndicator {
    @Override
    public Health health() {
        try {
            // Check database connectivity and performance
            long startTime = System.currentTimeMillis();
            jdbcTemplate.queryForObject('SELECT 1', Integer.class);
            long responseTime = System.currentTimeMillis() - startTime;
            
            if (responseTime > 1000) {
                return Health.down()
                    .withDetail('database', 'Slow response: ' + responseTime + 'ms')
                    .build();
            }
            
            return Health.up()
                .withDetail('database', 'Available')
                .withDetail('responseTime', responseTime + 'ms')
                .build();
        } catch (Exception e) {
            return Health.down()
                .withDetail('database', 'Unavailable: ' + e.getMessage())
                .build();
        }
    }
}

METRICS COLLECTED:
- HTTP request metrics (count, duration, status codes)
- JVM metrics (memory, GC, threads)
- Database metrics (connection pool, query performance)
- Custom business metrics (accounts, transactions, balances)
- System metrics (CPU, memory, disk)"
```

### **Q: Describe your alerting strategy and implementation.**
```
A: "Multi-tiered alerting strategy based on severity and impact:

ALERT CATEGORIES:

1. CRITICAL ALERTS (Immediate Response):
   - Service completely down
   - Database connection failures
   - High error rates (>5% for 2 minutes)
   - Security breaches or suspicious activities
   - SLA violations (response time >1s for 99th percentile)

2. WARNING ALERTS (Monitor Closely):
   - High resource utilization (CPU >80%, Memory >80%)
   - Elevated response times (95th percentile >500ms)
   - Increased error rates (>1% for 5 minutes)
   - Database performance degradation

3. INFO ALERTS (Awareness):
   - Deployment notifications
   - Scheduled maintenance windows
   - Capacity planning thresholds reached

PROMETHEUS ALERTING RULES:
groups:
  - name: banking-critical
    rules:
      - alert: ServiceDown
        expr: up{job='banking-services'} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: 'Service {{ $labels.instance }} is down'
          
      - alert: HighErrorRate
        expr: |
          rate(http_server_requests_seconds_count{status=~'5..'}[5m]) /
          rate(http_server_requests_seconds_count[5m]) > 0.05
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: 'High error rate: {{ $value | humanizePercentage }}'

NOTIFICATION CHANNELS:
1. Slack Integration:
   - #banking-alerts for all alerts
   - #banking-critical for critical alerts only
   - Rich formatting with runbook links

2. Email Notifications:
   - On-call rotation integration
   - Escalation policies
   - Alert aggregation to prevent spam

3. PagerDuty Integration:
   - Critical alerts trigger pages
   - Automatic escalation if not acknowledged
   - Integration with incident management

ALERT FATIGUE PREVENTION:
- Proper alert thresholds based on historical data
- Alert grouping and deduplication
- Automatic resolution when conditions clear
- Regular alert review and tuning"
```

### **Q: How do you monitor database performance and connections?**
```
A: "Database monitoring is critical for banking applications:

HIKARICP CONNECTION POOL MONITORING:
spring:
  datasource:
    hikari:
      register-mbeans: true  # Enable JMX metrics
      maximum-pool-size: 20
      minimum-idle: 5
      leak-detection-threshold: 60000

METRICS COLLECTED:
- hikaricp.connections.active: Currently active connections
- hikaricp.connections.idle: Available idle connections
- hikaricp.connections.pending: Requests waiting for connections
- hikaricp.connections.timeout: Connection timeout events
- hikaricp.connections.usage: Connection usage duration

DATABASE PERFORMANCE METRICS:
@Component
public class DatabaseMetrics {
    private final MeterRegistry meterRegistry;
    private final JdbcTemplate jdbcTemplate;
    
    @EventListener
    public void handleQueryExecution(QueryExecutionEvent event) {
        Timer.Sample sample = Timer.start(meterRegistry);
        sample.stop(Timer.builder('database.query.duration')
            .tag('query.type', event.getQueryType())
            .tag('table', event.getTableName())
            .register(meterRegistry));
    }
    
    @Scheduled(fixedRate = 30000)
    public void recordDatabaseHealth() {
        try {
            long startTime = System.currentTimeMillis();
            jdbcTemplate.queryForObject('SELECT COUNT(*) FROM accounts', Long.class);
            long duration = System.currentTimeMillis() - startTime;
            
            Gauge.builder('database.health.response_time')
                .register(meterRegistry, duration);
        } catch (Exception e) {
            meterRegistry.counter('database.health.failures').increment();
        }
    }
}

SLOW QUERY MONITORING:
logging:
  level:
    org.hibernate.SQL: DEBUG
    org.hibernate.type.descriptor.sql.BasicBinder: TRACE

# Custom slow query detection
@Component
public class SlowQueryDetector {
    @EventListener
    public void detectSlowQueries(QueryExecutionEvent event) {
        if (event.getDuration() > Duration.ofSeconds(1)) {
            meterRegistry.counter('database.slow_queries',
                'query', event.getQuery(),
                'duration', String.valueOf(event.getDuration().toMillis())
            ).increment();
        }
    }
}

ALERTING FOR DATABASE ISSUES:
- Connection pool exhaustion (>90% utilization)
- Slow queries (>1 second execution time)
- High connection wait times
- Database connectivity failures
- Transaction rollback rates"
```

### **Q: Explain your Grafana dashboard design and key visualizations.**
```
A: "Designed role-based dashboards for different stakeholders:

EXECUTIVE DASHBOARD (Business View):
- Service availability overview (uptime %)
- Transaction volume trends
- Revenue impact metrics
- Customer experience indicators (response times)
- SLA compliance status

OPERATIONS DASHBOARD (Technical View):
- Service health matrix (all 10 services)
- Resource utilization (CPU, Memory, Disk)
- Error rates and response times
- Database performance metrics
- Alert status and recent incidents

DEVELOPER DASHBOARD (Service-Specific):
- Individual service deep-dive
- JVM metrics (heap, GC, threads)
- Custom business metrics
- Log correlation and error tracking
- Deployment and release tracking

KEY VISUALIZATIONS:

1. SERVICE HEALTH MATRIX:
   - Stat panels showing UP/DOWN status
   - Color coding: Green (UP), Red (DOWN)
   - Last update timestamp
   - Quick drill-down to service details

2. RESPONSE TIME HEATMAP:
   - 95th percentile response times
   - Time-based visualization
   - Service comparison
   - SLA threshold indicators

3. ERROR RATE TRENDS:
   - Time series of error rates
   - Breakdown by service and error type
   - Correlation with deployments
   - Threshold alerting visualization

4. BUSINESS METRICS:
   - Account creation rates
   - Transaction volumes by type
   - Revenue trending
   - Customer activity patterns

DASHBOARD QUERIES:
# Service availability
up{job='banking-services'}

# Request rate
rate(http_server_requests_seconds_count[5m])

# 95th percentile response time
histogram_quantile(0.95, rate(http_server_requests_seconds_bucket[5m]))

# Error rate
rate(http_server_requests_seconds_count{status=~'5..'}[5m]) / 
rate(http_server_requests_seconds_count[5m])

# JVM memory usage
jvm_memory_used_bytes{area='heap'} / jvm_memory_max_bytes{area='heap'}

DASHBOARD FEATURES:
- Auto-refresh every 30 seconds
- Time range selection (1h, 6h, 24h, 7d)
- Variable templating for service selection
- Drill-down capabilities
- Export and sharing functionality
- Mobile-responsive design"
```

## 🔧 Technical Implementation Details

### **Prometheus Configuration**
```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'banking-services'
    static_configs:
      - targets: 
        - 'localhost:8080'  # api-gateway
        - 'localhost:8081'  # auth-service
        - 'localhost:8082'  # account-service
        # ... all 10 services
    metrics_path: '/actuator/prometheus'
    scrape_interval: 15s
    scrape_timeout: 10s
```

### **Custom Metrics Implementation**
```java
// Business metric example
@Service
public class TransactionMetrics {
    private final MeterRegistry meterRegistry;
    
    public TransactionMetrics(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
    }
    
    public void recordTransaction(Transaction transaction) {
        // Counter for transaction volume
        Counter.builder("transactions.processed")
            .tag("type", transaction.getType().toString())
            .tag("status", transaction.getStatus().toString())
            .register(meterRegistry)
            .increment();
        
        // Gauge for transaction amount
        Gauge.builder("transactions.amount")
            .tag("type", transaction.getType().toString())
            .register(meterRegistry, transaction, 
                t -> t.getAmount().doubleValue());
        
        // Timer for transaction processing time
        Timer.builder("transactions.processing.time")
            .tag("type", transaction.getType().toString())
            .register(meterRegistry)
            .record(transaction.getProcessingDuration());
    }
}
```

## 📊 Monitoring Metrics & KPIs

### **SLA Metrics**
- **Availability**: 99.9% uptime (8.76 hours downtime/year)
- **Response Time**: 95th percentile < 500ms
- **Error Rate**: < 0.1% for critical operations
- **Recovery Time**: < 5 minutes for service restoration

### **Performance Metrics**
- **Throughput**: 1000+ requests/second per service
- **Latency**: P50 < 100ms, P95 < 500ms, P99 < 1s
- **Resource Utilization**: CPU < 70%, Memory < 80%
- **Database Performance**: Query time < 100ms average

### **Business Metrics**
- **Transaction Success Rate**: > 99.9%
- **Account Operations**: Creation, updates, closures
- **Balance Accuracy**: Real-time consistency checks
- **Customer Experience**: Response time impact on user satisfaction

## 📋 Monitoring Interview Checklist

- [ ] Can explain comprehensive monitoring strategy for banking applications
- [ ] Demonstrates knowledge of Spring Boot Actuator and Micrometer
- [ ] Shows understanding of Prometheus and Grafana integration
- [ ] Can design effective alerting strategies with proper thresholds
- [ ] Understands database performance monitoring
- [ ] Can create meaningful dashboards for different stakeholders
- [ ] Shows knowledge of SRE principles (Golden Signals, SLAs)
- [ ] Demonstrates understanding of business metrics in banking context
- [ ] Can explain monitoring automation and self-healing systems
- [ ] Understands compliance and audit requirements for monitoring

---

**Key Takeaway**: This monitoring implementation demonstrates enterprise-level observability engineering with comprehensive coverage of technical and business metrics, suitable for critical banking applications with regulatory requirements.
