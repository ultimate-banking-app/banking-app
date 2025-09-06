# Technical Q&A Cheat Sheet - Banking Application

## 🏗️ Current Architecture

**Services & Ports:**
- API Gateway: 8090 (Entry point, service routing)
- Auth Service: 8081 (Authentication, user management)
- Account Service: 8084 (Account CRUD, balance management)
- Payment Service: 8083 (Payment processing, transfers)

**Tech Stack:**
- Spring Boot 3.2, Java 21, Maven
- H2 Database (in-memory for development)
- SpringDoc OpenAPI (Swagger documentation)
- Spring Security (authentication/authorization)
- Spring Boot Actuator (health checks, monitoring)

## 🔥 Quick Fire Technical Questions

### **Spring Boot & Java**

**Q: Why Spring Boot 3.2 over 2.x?**
```
A: "Spring Boot 3.x provides:
- Java 17+ requirement (modern JVM features)
- Native compilation support with GraalVM
- Improved observability with Micrometer
- Better security with Spring Security 6
- Performance improvements in startup time
- Jakarta EE migration (javax → jakarta packages)"
```

**Q: Explain @Transactional in your services.**
```
A: "I use @Transactional for ACID properties:
- Atomicity: All operations succeed or fail together
- Consistency: Database constraints maintained
- Isolation: Concurrent transactions don't interfere
- Durability: Committed changes persist

Example in AccountService:
@Transactional
public Account createAccount(CreateAccountRequest request) {
    // If any step fails, entire transaction rolls back
    validateRequest(request);
    Account account = new Account(...);
    return accountRepository.save(account);
}"
```

**Q: How do you handle exceptions across microservices?**
```
A: "Multi-layer exception handling:

1. Global Exception Handler:
@ControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(ValidationException.class)
    public ResponseEntity<ErrorResponse> handleValidation(ValidationException e) {
        return ResponseEntity.badRequest().body(new ErrorResponse(e.getMessage()));
    }
}

2. Custom Business Exceptions:
public class InsufficientFundsException extends RuntimeException {
    public InsufficientFundsException(String message) {
        super(message);
    }
}

3. Circuit Breaker for Service Calls:
@CircuitBreaker(name = "account-service")
public Account getAccount(Long id) {
    // Fallback method if service is down
}"
```

### **Database & JPA**

**Q: Why separate databases per service?**
```
A: "Database per service pattern provides:
- Service autonomy (teams own their data)
- Technology diversity (different DB types per need)
- Fault isolation (one DB failure doesn't affect all)
- Independent scaling (scale DB based on service load)
- Security boundaries (payment data separate from user data)

Trade-offs:
- No ACID transactions across services (use Saga pattern)
- Data consistency challenges (eventual consistency)
- Increased operational complexity (multiple DBs to manage)"
```

**Q: How do you handle database migrations?**
```
A: "Using Flyway for version-controlled migrations:

1. Migration Scripts:
-- V1__Create_accounts_table.sql
CREATE TABLE accounts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    account_type VARCHAR(20) NOT NULL,
    balance DECIMAL(19,2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

2. Spring Boot Configuration:
spring:
  flyway:
    enabled: true
    locations: classpath:db/migration
    baseline-on-migrate: true

3. CI/CD Integration:
- Migrations run automatically on deployment
- Rollback scripts for production safety
- Database state validation in pipeline"
```

### **Docker & Containerization**

**Q: Explain your Dockerfile strategy.**
```
A: "Multi-stage Docker builds for optimization:

FROM openjdk:17-jre-slim as base
WORKDIR /app

# Copy only dependencies first (better caching)
COPY target/lib/ ./lib/
COPY target/*.jar app.jar

# Security: Run as non-root user
RUN addgroup --system spring && adduser --system spring --ingroup spring
USER spring:spring

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]

Benefits:
- Smaller image size (JRE vs JDK)
- Layer caching for faster builds
- Security with non-root user
- Built-in health checks"
```

**Q: How do you handle container orchestration?**
```
A: "Kubernetes deployment strategy:

1. Deployment Manifest:
apiVersion: apps/v1
kind: Deployment
metadata:
  name: account-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: account-service
  template:
    spec:
      containers:
      - name: account-service
        image: banking/account-service:latest
        ports:
        - containerPort: 8082
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"

2. Service Discovery:
apiVersion: v1
kind: Service
metadata:
  name: account-service
spec:
  selector:
    app: account-service
  ports:
  - port: 8082
    targetPort: 8082

3. ConfigMap for Environment-specific configs
4. Secrets for sensitive data (DB passwords, API keys)"
```

### **Jenkins & CI/CD**

**Q: Explain Jenkins Shared Libraries architecture.**
```
A: "Shared Libraries provide reusable pipeline components:

Structure:
jenkins-shared-library/
├── vars/                    # Global pipeline steps
│   ├── bankingBuild.groovy  # Build operations
│   └── bankingTest.groovy   # Test operations
└── src/com/banking/         # Object-oriented classes
    ├── utils/BankingPipelineUtils.groovy
    └── build/BankingBuildManager.groovy

Usage in Jenkinsfile:
@Library('banking-shared-library') _

pipeline {
    stages {
        stage('Build') {
            steps {
                script {
                    bankingBuild.buildServices(['account-service', 'payment-service'])
                }
            }
        }
    }
}

Benefits:
- Code reuse across multiple pipelines
- Centralized pipeline logic
- Version control for pipeline code
- Easier maintenance and updates"
```

**Q: How do you optimize builds in a monorepo?**
```
A: "Several optimization strategies:

1. Change Detection:
def changedServices = sh(
    script: 'git diff --name-only HEAD~1 HEAD',
    returnStdout: true
).split('\n').findAll { it.contains('/') }
    .collect { it.split('/')[0] }
    .unique()

2. Parallel Execution:
parallel([
    'service1': { buildService('account-service') },
    'service2': { buildService('payment-service') },
    'service3': { buildService('balance-service') }
])

3. Caching Strategy:
- Maven dependency cache: ~/.m2/repository
- Docker layer cache: Multi-stage builds
- Workspace cache: Preserve between builds

4. Conditional Stages:
when {
    anyOf {
        changeset "account-service/**"
        changeset "shared/**"
    }
}

Results:
- 70% faster builds (only changed services)
- Parallel execution reduces total time
- Efficient resource utilization"
```

### **Security & Compliance**

**Q: How do you implement security scanning in CI/CD?**
```
A: "Multi-layered security approach:

1. OWASP Dependency Check:
mvn org.owasp:dependency-check-maven:check
- Scans for known vulnerabilities in dependencies
- Fails build on HIGH/CRITICAL vulnerabilities
- Generates HTML reports for review

2. Container Security Scanning:
trivy image --exit-code 1 --severity HIGH,CRITICAL banking/account-service:latest
- Scans container images for OS vulnerabilities
- Checks for malware and misconfigurations
- Integrates with CI/CD pipeline

3. Static Application Security Testing (SAST):
mvn com.github.spotbugs:spotbugs-maven-plugin:check
- Analyzes source code for security issues
- Detects SQL injection, XSS vulnerabilities
- Custom rules for banking-specific security

4. Secret Detection:
git-secrets --scan
- Prevents committing passwords, API keys
- Scans commit history for exposed secrets
- Blocks pushes containing sensitive data

Pipeline Integration:
stage('Security Scan') {
    parallel {
        'OWASP': { runDependencyCheck() }
        'Container': { runContainerScan() }
        'SAST': { runSASTScan() }
    }
}"
```

### **Testing Strategy**

**Q: Explain your testing pyramid implementation.**
```
A: "Comprehensive testing at multiple levels:

1. Unit Tests (70% of tests):
@SpringBootTest
@TestMethodOrder(OrderAnnotation.class)
class AccountServiceTest {
    @MockBean
    private AccountRepository accountRepository;
    
    @Test
    @Order(1)
    void shouldCreateAccount() {
        // Given
        CreateAccountRequest request = new CreateAccountRequest(1L, SAVINGS, 1000.00);
        Account expectedAccount = new Account(1L, SAVINGS, 1000.00);
        
        when(accountRepository.save(any(Account.class))).thenReturn(expectedAccount);
        
        // When
        Account result = accountService.createAccount(request);
        
        // Then
        assertThat(result.getBalance()).isEqualTo(BigDecimal.valueOf(1000.00));
    }
}

2. Integration Tests (20% of tests):
@SpringBootTest(webEnvironment = RANDOM_PORT)
@Testcontainers
class AccountControllerIntegrationTest {
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:13")
            .withDatabaseName("banking_test")
            .withUsername("test")
            .withPassword("test");
    
    @Test
    void shouldCreateAccountEndToEnd() {
        // Test actual HTTP endpoints with real database
    }
}

3. Contract Tests (5% of tests):
@AutoConfigureWireMock
class PaymentServiceContractTest {
    // Test service interactions with mocked external services
}

4. End-to-End Tests (5% of tests):
// Smoke tests in pipeline after deployment
curl -f http://localhost:8080/actuator/health

Benefits:
- Fast feedback (unit tests run in seconds)
- Confidence in integrations (integration tests)
- Production-like validation (E2E tests)"
```

### **Performance & Monitoring**

**Q: How do you monitor microservices performance?**
```
A: "Comprehensive observability stack:

1. Application Metrics (Micrometer + Prometheus):
@RestController
public class AccountController {
    private final MeterRegistry meterRegistry;
    
    @GetMapping("/accounts/{id}")
    @Timed(name = "account.get", description = "Time taken to get account")
    public Account getAccount(@PathVariable Long id) {
        Counter.builder("account.requests")
            .tag("operation", "get")
            .register(meterRegistry)
            .increment();
        
        return accountService.getAccount(id);
    }
}

2. Health Checks:
@Component
public class DatabaseHealthIndicator implements HealthIndicator {
    @Override
    public Health health() {
        try {
            // Check database connectivity
            return Health.up().withDetail("database", "Available").build();
        } catch (Exception e) {
            return Health.down().withDetail("database", "Unavailable").build();
        }
    }
}

3. Distributed Tracing (Sleuth + Zipkin):
- Trace requests across multiple services
- Identify performance bottlenecks
- Visualize service dependencies

4. Logging Strategy:
@Slf4j
@Service
public class AccountService {
    public Account createAccount(CreateAccountRequest request) {
        log.info("Creating account for user: {}", request.getUserId());
        
        try {
            Account account = new Account(request);
            Account saved = accountRepository.save(account);
            
            log.info("Account created successfully: {}", saved.getId());
            return saved;
        } catch (Exception e) {
            log.error("Failed to create account for user: {}", request.getUserId(), e);
            throw e;
        }
    }
}

5. Alerting Rules:
- High error rates (>5% in 5 minutes)
- Response time degradation (>2s average)
- Service unavailability (health check failures)
- Resource utilization (CPU >80%, Memory >90%)"
```

## 🎯 Scenario-Based Questions

### **Production Issues**

**Q: A payment service is down. How do you handle it?**
```
A: "Incident response process:

1. Immediate Response:
   - Check service health: kubectl get pods -n banking-prod
   - Review logs: kubectl logs payment-service-xxx -n banking-prod
   - Check dependencies: Database, Redis, external APIs

2. Mitigation:
   - Enable circuit breaker to prevent cascade failures
   - Scale up healthy instances: kubectl scale deployment payment-service --replicas=5
   - Route traffic to backup region if available

3. Investigation:
   - Check recent deployments: kubectl rollout history deployment/payment-service
   - Review monitoring dashboards (Grafana)
   - Analyze error patterns in logs

4. Resolution:
   - If deployment issue: kubectl rollout undo deployment/payment-service
   - If resource issue: Increase resource limits
   - If external dependency: Implement fallback mechanism

5. Post-Incident:
   - Root cause analysis
   - Update runbooks
   - Improve monitoring/alerting
   - Implement preventive measures"
```

**Q: How do you handle a database migration failure in production?**
```
A: "Database migration safety process:

1. Pre-Migration Safety:
   - Always test migrations in staging first
   - Create database backup before migration
   - Use backward-compatible changes when possible
   - Implement rollback scripts

2. Migration Failure Response:
   - Stop application deployments immediately
   - Assess data integrity impact
   - Check if rollback is safe (no data loss)
   - Communicate with stakeholders

3. Recovery Options:
   Option A - Rollback:
   - Restore from backup if data corruption
   - Run rollback migration script
   - Restart services with previous version
   
   Option B - Fix Forward:
   - Identify specific migration issue
   - Create corrective migration
   - Test in staging environment first
   - Apply fix with careful monitoring

4. Prevention Strategies:
   - Blue-green deployments for zero-downtime
   - Feature flags to decouple code and schema changes
   - Gradual rollout of schema changes
   - Automated testing of migrations in CI/CD"
```

## 📊 Performance Numbers to Remember

- **Build Time**: 3-5 minutes for full monorepo (with parallel execution)
- **Test Execution**: 30 seconds for unit tests, 2 minutes for integration tests
- **Deployment Time**: 2 minutes per environment with health checks
- **Service Startup**: 30-45 seconds per service with Spring Boot
- **Memory Usage**: 256MB-512MB per service container
- **Response Time**: <200ms for simple operations, <500ms for complex operations
- **Throughput**: 1000+ requests/second per service instance
- **Availability**: 99.9% uptime target with proper monitoring

---

**💡 Pro Tip**: Always relate technical decisions back to business value - faster deployments mean quicker feature delivery, better monitoring means less downtime, security scanning prevents costly breaches.
