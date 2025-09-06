# 📊 Custom Banking Metrics Implementation

## 🎯 Overview

Implementation guide for custom business metrics in the Banking Application using Micrometer and Prometheus.

## 🔧 Required Dependencies

Add to each service's `pom.xml`:

```xml
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

## 📊 Custom Metrics Implementation

### 🔐 Auth Service Metrics

```java
@Component
public class AuthMetrics {
    
    private final Counter loginAttempts;
    private final Counter loginSuccesses;
    private final Counter loginFailures;
    private final Timer loginDuration;
    
    public AuthMetrics(MeterRegistry meterRegistry) {
        this.loginAttempts = Counter.builder("banking_login_attempts_total")
            .description("Total login attempts")
            .tag("service", "auth")
            .register(meterRegistry);
            
        this.loginSuccesses = Counter.builder("banking_login_attempts_total")
            .description("Successful login attempts")
            .tag("service", "auth")
            .tag("status", "success")
            .register(meterRegistry);
            
        this.loginFailures = Counter.builder("banking_login_attempts_total")
            .description("Failed login attempts")
            .tag("service", "auth")
            .tag("status", "failure")
            .register(meterRegistry);
            
        this.loginDuration = Timer.builder("banking_login_duration_seconds")
            .description("Login processing time")
            .tag("service", "auth")
            .register(meterRegistry);
    }
    
    public void recordLoginAttempt() {
        loginAttempts.increment();
    }
    
    public void recordLoginSuccess() {
        loginSuccesses.increment();
    }
    
    public void recordLoginFailure() {
        loginFailures.increment();
    }
    
    public Timer.Sample startLoginTimer() {
        return Timer.start(loginDuration);
    }
}

// Usage in AuthController
@RestController
public class AuthController {
    
    @Autowired
    private AuthMetrics authMetrics;
    
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        Timer.Sample sample = authMetrics.startLoginTimer();
        authMetrics.recordLoginAttempt();
        
        try {
            // Login logic
            User user = authService.authenticate(request);
            authMetrics.recordLoginSuccess();
            return ResponseEntity.ok(new LoginResponse(user));
        } catch (AuthenticationException e) {
            authMetrics.recordLoginFailure();
            return ResponseEntity.status(401).body("Login failed");
        } finally {
            sample.stop();
        }
    }
}
```

### 💰 Account Service Metrics

```java
@Component
public class AccountMetrics {
    
    private final Gauge accountBalance;
    private final Counter transactionCount;
    private final Counter transactionAmount;
    
    public AccountMetrics(MeterRegistry meterRegistry) {
        this.accountBalance = Gauge.builder("banking_account_balance")
            .description("Current account balance")
            .tag("service", "account")
            .register(meterRegistry, this, AccountMetrics::getTotalBalance);
            
        this.transactionCount = Counter.builder("banking_transactions_total")
            .description("Total number of transactions")
            .tag("service", "account")
            .register(meterRegistry);
            
        this.transactionAmount = Counter.builder("banking_transaction_amount_total")
            .description("Total transaction amount")
            .tag("service", "account")
            .register(meterRegistry);
    }
    
    public void recordTransaction(String type, String status, double amount) {
        transactionCount.increment(
            Tags.of(
                "transaction_type", type,
                "status", status
            )
        );
        
        if ("success".equals(status)) {
            transactionAmount.increment(
                Tags.of("transaction_type", type),
                amount
            );
        }
    }
    
    private double getTotalBalance() {
        // Implementation to get total balance across all accounts
        return accountService.getTotalBalance();
    }
}

// Usage in AccountController
@RestController
public class AccountController {
    
    @Autowired
    private AccountMetrics accountMetrics;
    
    @PostMapping("/transfer")
    public ResponseEntity<?> transfer(@RequestBody TransferRequest request) {
        try {
            accountService.transfer(request);
            accountMetrics.recordTransaction("transfer", "success", request.getAmount());
            return ResponseEntity.ok("Transfer successful");
        } catch (Exception e) {
            accountMetrics.recordTransaction("transfer", "failure", request.getAmount());
            return ResponseEntity.status(500).body("Transfer failed");
        }
    }
}
```

### 💳 Payment Service Metrics

```java
@Component
public class PaymentMetrics {
    
    private final Counter paymentCount;
    private final Counter paymentAmount;
    private final Timer paymentProcessingTime;
    private final Gauge pendingPayments;
    
    public PaymentMetrics(MeterRegistry meterRegistry) {
        this.paymentCount = Counter.builder("banking_payments_total")
            .description("Total number of payments")
            .tag("service", "payment")
            .register(meterRegistry);
            
        this.paymentAmount = Counter.builder("banking_payment_amount_total")
            .description("Total payment amount")
            .tag("service", "payment")
            .register(meterRegistry);
            
        this.paymentProcessingTime = Timer.builder("banking_payment_processing_seconds")
            .description("Payment processing time")
            .tag("service", "payment")
            .register(meterRegistry);
            
        this.pendingPayments = Gauge.builder("banking_pending_payments")
            .description("Number of pending payments")
            .tag("service", "payment")
            .register(meterRegistry, this, PaymentMetrics::getPendingPaymentsCount);
    }
    
    public void recordPayment(String paymentType, String status, double amount) {
        paymentCount.increment(
            Tags.of(
                "payment_type", paymentType,
                "status", status
            )
        );
        
        if ("completed".equals(status)) {
            paymentAmount.increment(
                Tags.of("payment_type", paymentType),
                amount
            );
        }
    }
    
    public Timer.Sample startPaymentTimer() {
        return Timer.start(paymentProcessingTime);
    }
    
    private double getPendingPaymentsCount() {
        return paymentService.getPendingPaymentsCount();
    }
}
```

### 🌐 API Gateway Metrics

```java
@Component
public class GatewayMetrics {
    
    private final Counter requestCount;
    private final Timer requestDuration;
    private final Counter circuitBreakerEvents;
    
    public GatewayMetrics(MeterRegistry meterRegistry) {
        this.requestCount = Counter.builder("banking_gateway_requests_total")
            .description("Total gateway requests")
            .tag("service", "gateway")
            .register(meterRegistry);
            
        this.requestDuration = Timer.builder("banking_gateway_request_duration_seconds")
            .description("Gateway request processing time")
            .tag("service", "gateway")
            .register(meterRegistry);
            
        this.circuitBreakerEvents = Counter.builder("banking_circuit_breaker_events_total")
            .description("Circuit breaker events")
            .tag("service", "gateway")
            .register(meterRegistry);
    }
    
    public void recordRequest(String targetService, String method, int statusCode) {
        requestCount.increment(
            Tags.of(
                "target_service", targetService,
                "method", method,
                "status_code", String.valueOf(statusCode)
            )
        );
    }
    
    public void recordCircuitBreakerEvent(String service, String event) {
        circuitBreakerEvents.increment(
            Tags.of(
                "target_service", service,
                "event", event
            )
        );
    }
}
```

## ⚙️ Application Configuration

Add to `application.yml` for each service:

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: always
    prometheus:
      enabled: true
  metrics:
    export:
      prometheus:
        enabled: true
    tags:
      application: ${spring.application.name}
      environment: ${SPRING_PROFILES_ACTIVE:local}
```

## 📊 Custom Metrics Categories

### 🏦 Business Metrics
- `banking_login_attempts_total` - Login attempts by status
- `banking_transactions_total` - Transactions by type and status
- `banking_account_balance` - Current account balances
- `banking_payments_total` - Payments by type and status
- `banking_payment_amount_total` - Payment amounts by type

### ⚡ Technical Metrics
- `banking_login_duration_seconds` - Login processing time
- `banking_payment_processing_seconds` - Payment processing time
- `banking_gateway_requests_total` - Gateway request counts
- `banking_circuit_breaker_events_total` - Circuit breaker events
- `banking_pending_payments` - Current pending payments count

### 🔍 Operational Metrics
- `http_requests_total` - HTTP request counts (Spring Boot Actuator)
- `jvm_memory_used_bytes` - JVM memory usage
- `hikaricp_connections_active` - Database connection pool metrics
- `jvm_gc_collection_seconds` - Garbage collection metrics

## 🚨 Alert Rules

The custom metrics enable these business-critical alerts:

- **High Transaction Failure Rate**: < 95% success rate
- **Low Account Balance**: Balance < $100
- **High Login Failure Rate**: < 90% success rate
- **Service Down**: Service unavailable
- **High API Error Rate**: > 5% error rate

## 📈 Dashboard Panels

### Business Dashboard
- Transaction rate and success rate
- Payment volume by type
- Account balances by type
- Login success rate trends

### Technical Dashboard
- Service health status
- HTTP request rates
- Response time percentiles
- JVM memory and GC metrics
- Database connection metrics

---

**📊 These custom metrics provide comprehensive business and technical observability for the Banking Application with actionable alerts and detailed dashboards.**
