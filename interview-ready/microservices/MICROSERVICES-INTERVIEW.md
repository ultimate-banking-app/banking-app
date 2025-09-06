# Microservices Interview Guide - Banking Application

## 🏗️ Microservices Architecture Overview

### **Service Landscape**
```
┌─────────────────────────────────────────────────────────────┐
│                    API Gateway (8080)                      │
│              Single Entry Point + Cross-cutting            │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                 Core Banking Services                       │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐          │
│  │  Auth   │ │ Account │ │ Payment │ │ Balance │          │
│  │  8081   │ │  8082   │ │  8083   │ │  8084   │          │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘          │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│               Transaction Services                          │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐                      │
│  │Transfer │ │ Deposit │ │Withdraw │                      │
│  │  8085   │ │  8086   │ │  8087   │                      │
│  └─────────┘ └─────────┘ └─────────┘                      │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│               Support Services                              │
│  ┌─────────┐ ┌─────────┐                                  │
│  │ Notify  │ │  Audit  │                                  │
│  │  8088   │ │  8089   │                                  │
│  └─────────┘ └─────────┘                                  │
└─────────────────────────────────────────────────────────────┘
```

### **Service Responsibilities**
- **10 Independent Services** with clear domain boundaries
- **Database per Service** pattern for data isolation
- **Event-driven Communication** for loose coupling
- **Shared Libraries** for common functionality

## 🎤 Key Interview Questions & Answers

### **Q: Why did you decompose the banking application into these specific microservices?**
```
A: "I used Domain-Driven Design (DDD) principles to identify service boundaries:

BOUNDED CONTEXTS IDENTIFICATION:
1. AUTHENTICATION CONTEXT (Auth Service):
   - User identity and access management
   - JWT token lifecycle
   - Security policies and password management
   - Single responsibility: "Who is the user?"

2. ACCOUNT MANAGEMENT CONTEXT (Account Service):
   - Account lifecycle (create, update, close)
   - Account information and metadata
   - Account types and status management
   - Single responsibility: "What accounts exist?"

3. PAYMENT PROCESSING CONTEXT (Payment Service):
   - External payment gateway integration
   - Payment method validation
   - Payment routing and processing
   - Single responsibility: "How are payments processed?"

4. BALANCE INQUIRY CONTEXT (Balance Service):
   - Real-time balance calculations
   - Balance history and reporting
   - Account summary generation
   - Single responsibility: "What is the current balance?"

5. TRANSACTION CONTEXTS:
   - Transfer Service: Inter-account money movement
   - Deposit Service: Money coming into accounts
   - Withdrawal Service: Money leaving accounts
   - Each handles specific transaction types with unique business rules

6. SUPPORT CONTEXTS:
   - Notification Service: Multi-channel communication
   - Audit Service: Compliance and regulatory reporting

DECOMPOSITION PRINCIPLES APPLIED:
- Single Responsibility Principle
- High Cohesion within services
- Loose Coupling between services
- Business capability alignment
- Team ownership boundaries
- Independent deployment capability"
```

### **Q: How do you handle data consistency across microservices?**
```
A: "Banking requires careful consistency management due to financial regulations:

DATA CONSISTENCY PATTERNS:

1. STRONG CONSISTENCY (Within Service):
   - ACID transactions within service boundaries
   - Database constraints and validations
   - Optimistic locking for concurrent updates

Example - Account Service:
@Entity
public class Account {
    @Version
    private Long version;  // Optimistic locking
    
    @Column(precision = 19, scale = 2)
    private BigDecimal balance;
}

@Transactional
public Account updateBalance(Long accountId, BigDecimal amount) {
    Account account = accountRepository.findById(accountId);
    account.setBalance(account.getBalance().add(amount));
    return accountRepository.save(account);  // Version check prevents concurrent updates
}

2. EVENTUAL CONSISTENCY (Across Services):
   - Event-driven architecture
   - Saga pattern for distributed transactions
   - Compensating transactions for rollbacks

Example - Money Transfer Saga:
public class TransferSaga {
    public void executeTransfer(TransferRequest request) {
        try {
            // Step 1: Reserve funds in source account
            ReservationResult reservation = accountService.reserveFunds(
                request.getFromAccount(), request.getAmount());
            
            // Step 2: Credit destination account
            CreditResult credit = accountService.creditAccount(
                request.getToAccount(), request.getAmount());
            
            // Step 3: Confirm reservation (complete transfer)
            accountService.confirmReservation(reservation.getId());
            
            // Step 4: Log successful transfer
            auditService.logTransfer(request, SUCCESS);
            
        } catch (Exception e) {
            // Compensating transactions
            if (reservation != null) {
                accountService.cancelReservation(reservation.getId());
            }
            auditService.logTransfer(request, FAILED);
            throw new TransferFailedException(e);
        }
    }
}

3. EVENT SOURCING (Audit Service):
   - Store all events, not just current state
   - Rebuild state from event history
   - Complete audit trail for compliance

@Entity
public class AuditEvent {
    private String eventType;
    private String aggregateId;
    private String eventData;
    private LocalDateTime timestamp;
    private String userId;
}

CONSISTENCY GUARANTEES:
- Within Service: Strong consistency (ACID)
- Across Services: Eventual consistency (BASE)
- Critical Operations: Saga pattern with compensations
- Audit Trail: Event sourcing for complete history"
```

### **Q: Explain your service communication patterns and when you use each.**
```
A: "I use multiple communication patterns based on requirements:

COMMUNICATION PATTERNS:

1. SYNCHRONOUS REST APIs:
   WHEN: Real-time operations requiring immediate response
   EXAMPLES:
   - Authentication validation
   - Balance inquiries
   - Account information retrieval
   
   IMPLEMENTATION:
   @RestController
   public class BalanceController {
       @GetMapping("/balance/{accountId}")
       public BalanceResponse getBalance(@PathVariable Long accountId) {
           // Synchronous call - immediate response required
           return balanceService.getCurrentBalance(accountId);
       }
   }
   
   PROS: Simple, immediate feedback, easy debugging
   CONS: Tight coupling, cascade failures, blocking operations

2. ASYNCHRONOUS EVENT-DRIVEN:
   WHEN: Non-critical operations, eventual consistency acceptable
   EXAMPLES:
   - Audit logging
   - Notifications
   - Reporting and analytics
   
   IMPLEMENTATION:
   @EventListener
   public class AuditEventHandler {
       @Async
       public void handleTransactionEvent(TransactionCompletedEvent event) {
           auditService.logTransaction(event.getTransaction());
       }
   }
   
   PROS: Loose coupling, better resilience, scalability
   CONS: Complexity, eventual consistency, debugging challenges

3. CIRCUIT BREAKER PATTERN:
   WHEN: Protecting against cascade failures
   IMPLEMENTATION:
   @Component
   public class PaymentServiceClient {
       @CircuitBreaker(name = "payment-service", fallbackMethod = "fallbackPayment")
       public PaymentResult processPayment(PaymentRequest request) {
           return restTemplate.postForObject("/payments", request, PaymentResult.class);
       }
       
       public PaymentResult fallbackPayment(PaymentRequest request, Exception ex) {
           return PaymentResult.builder()
               .status(PENDING)
               .message("Payment queued for later processing")
               .build();
       }
   }

4. API GATEWAY PATTERN:
   WHEN: Cross-cutting concerns, service composition
   FEATURES:
   - Authentication and authorization
   - Rate limiting and throttling
   - Request/response transformation
   - Service discovery and load balancing
   
   IMPLEMENTATION:
   @Configuration
   public class GatewayConfig {
       @Bean
       public RouteLocator customRouteLocator(RouteLocatorBuilder builder) {
           return builder.routes()
               .route("auth-service", r -> r.path("/auth/**")
                   .uri("http://auth-service:8081"))
               .route("account-service", r -> r.path("/accounts/**")
                   .uri("http://account-service:8082"))
               .build();
       }
   }

COMMUNICATION MATRIX:
Service A → Service B: Communication Type
- API Gateway → All Services: Synchronous REST
- Auth Service → All Services: JWT validation (sync)
- Account Service ↔ Payment Service: Synchronous (balance check)
- All Services → Audit Service: Asynchronous events
- All Services → Notification Service: Asynchronous events
- Transfer Service → Account Service: Synchronous (SAGA steps)"
```

### **Q: How do you handle service discovery and configuration management?**
```
A: "Multi-layered approach for service discovery and configuration:

SERVICE DISCOVERY:

1. DEVELOPMENT ENVIRONMENT:
   - Static configuration with localhost ports
   - Docker Compose service names
   - Simple and fast for local development

2. KUBERNETES ENVIRONMENT:
   - Native Kubernetes service discovery
   - DNS-based service resolution
   - Service mesh integration (Istio)
   
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

3. SPRING CLOUD GATEWAY:
   - Dynamic routing based on service registry
   - Load balancing across service instances
   - Health-based routing decisions
   
   spring:
     cloud:
       gateway:
         routes:
         - id: account-service
           uri: lb://account-service
           predicates:
           - Path=/accounts/**

CONFIGURATION MANAGEMENT:

1. ENVIRONMENT-SPECIFIC CONFIGS:
   # application-dev.yml
   spring:
     datasource:
       url: jdbc:postgresql://localhost:5432/banking_dev
   
   # application-prod.yml
   spring:
     datasource:
       url: jdbc:postgresql://prod-db:5432/banking_prod

2. EXTERNALIZED CONFIGURATION:
   - ConfigMaps for non-sensitive data
   - Secrets for sensitive information
   - Environment variables for runtime config
   
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: account-service-config
   data:
     application.yml: |
       server:
         port: 8082
       management:
         endpoints:
           web:
             exposure:
               include: health,metrics

3. CONFIGURATION VALIDATION:
   @ConfigurationProperties(prefix = "banking")
   @Validated
   public class BankingProperties {
       @NotNull
       @Min(1)
       private Integer maxTransactionAmount;
       
       @NotEmpty
       private String encryptionKey;
   }

HEALTH CHECKS AND DISCOVERY:
@Component
public class ServiceHealthIndicator implements HealthIndicator {
    @Override
    public Health health() {
        // Check dependencies
        boolean dbHealthy = checkDatabaseHealth();
        boolean externalServiceHealthy = checkExternalServices();
        
        if (dbHealthy && externalServiceHealthy) {
            return Health.up()
                .withDetail("database", "Available")
                .withDetail("external-services", "Available")
                .build();
        }
        
        return Health.down()
            .withDetail("database", dbHealthy ? "Available" : "Unavailable")
            .withDetail("external-services", externalServiceHealthy ? "Available" : "Unavailable")
            .build();
    }
}"
```

### **Q: How do you handle microservices testing strategies?**
```
A: "Comprehensive testing pyramid for microservices:

TESTING PYRAMID:

1. UNIT TESTS (70% of tests):
   - Test individual components in isolation
   - Mock external dependencies
   - Fast execution and feedback
   
   @ExtendWith(MockitoExtension.class)
   class AccountServiceTest {
       @Mock
       private AccountRepository accountRepository;
       
       @InjectMocks
       private AccountService accountService;
       
       @Test
       void shouldCreateAccount() {
           // Given
           CreateAccountRequest request = new CreateAccountRequest(1L, SAVINGS, 1000.00);
           Account expectedAccount = new Account(1L, SAVINGS, 1000.00);
           when(accountRepository.save(any(Account.class))).thenReturn(expectedAccount);
           
           // When
           Account result = accountService.createAccount(request);
           
           // Then
           assertThat(result.getBalance()).isEqualTo(BigDecimal.valueOf(1000.00));
           verify(accountRepository).save(any(Account.class));
       }
   }

2. INTEGRATION TESTS (20% of tests):
   - Test service interactions with real dependencies
   - Use TestContainers for database testing
   - Verify API contracts
   
   @SpringBootTest(webEnvironment = RANDOM_PORT)
   @Testcontainers
   class AccountControllerIntegrationTest {
       @Container
       static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:13")
               .withDatabaseName("banking_test")
               .withUsername("test")
               .withPassword("test");
       
       @Autowired
       private TestRestTemplate restTemplate;
       
       @Test
       void shouldCreateAccountEndToEnd() {
           CreateAccountRequest request = new CreateAccountRequest(1L, SAVINGS, 1000.00);
           
           ResponseEntity<Account> response = restTemplate.postForEntity(
               "/accounts", request, Account.class);
           
           assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
           assertThat(response.getBody().getBalance()).isEqualTo(BigDecimal.valueOf(1000.00));
       }
   }

3. CONTRACT TESTS (5% of tests):
   - Verify service contracts between consumer and provider
   - Use Spring Cloud Contract or Pact
   - Prevent breaking changes
   
   @AutoConfigureWireMock
   class PaymentServiceContractTest {
       @Test
       void shouldProcessPaymentContract() {
           // Mock external payment service response
           stubFor(post(urlEqualTo("/payments"))
               .willReturn(aResponse()
                   .withStatus(200)
                   .withHeader("Content-Type", "application/json")
                   .withBody("{\"status\":\"SUCCESS\",\"transactionId\":\"12345\"}")));
           
           // Test our service against the contract
           PaymentResult result = paymentService.processPayment(paymentRequest);
           assertThat(result.getStatus()).isEqualTo(SUCCESS);
       }
   }

4. END-TO-END TESTS (5% of tests):
   - Test complete user journeys
   - Run against deployed environment
   - Validate business scenarios
   
   @SpringBootTest
   class BankingE2ETest {
       @Test
       void shouldCompleteMoneyTransferJourney() {
           // 1. Create source account
           Account sourceAccount = createAccount(CHECKING, 1000.00);
           
           // 2. Create destination account
           Account destAccount = createAccount(SAVINGS, 0.00);
           
           // 3. Initiate transfer
           TransferRequest transfer = new TransferRequest(
               sourceAccount.getId(), destAccount.getId(), 100.00);
           TransferResult result = transferService.initiateTransfer(transfer);
           
           // 4. Verify transfer completion
           assertThat(result.getStatus()).isEqualTo(COMPLETED);
           
           // 5. Verify balances updated
           assertThat(getBalance(sourceAccount.getId())).isEqualTo(900.00);
           assertThat(getBalance(destAccount.getId())).isEqualTo(100.00);
           
           // 6. Verify audit trail
           List<AuditEvent> events = auditService.getEvents(transfer.getId());
           assertThat(events).hasSize(3); // Debit, Credit, Complete
       }
   }

TESTING STRATEGIES:

1. SERVICE ISOLATION:
   - Each service has independent test suite
   - Mock external service dependencies
   - Use test doubles for database interactions

2. DATA MANAGEMENT:
   - Test data builders for consistent test setup
   - Database cleanup between tests
   - Isolated test databases per service

3. PERFORMANCE TESTING:
   - Load testing individual services
   - Stress testing critical paths
   - Chaos engineering for resilience

4. SECURITY TESTING:
   - Authentication and authorization tests
   - Input validation and sanitization
   - SQL injection and XSS prevention"
```

## 🔧 Technical Implementation Details

### **Service Structure Template**
```java
// Standard microservice structure
@SpringBootApplication
@EnableJpaRepositories
@EnableScheduling
public class AccountServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(AccountServiceApplication.class, args);
    }
}

@RestController
@RequestMapping("/accounts")
@Validated
public class AccountController {
    private final AccountService accountService;
    
    @PostMapping
    public ResponseEntity<Account> createAccount(@Valid @RequestBody CreateAccountRequest request) {
        Account account = accountService.createAccount(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(account);
    }
}

@Service
@Transactional
public class AccountService {
    private final AccountRepository accountRepository;
    
    public Account createAccount(CreateAccountRequest request) {
        Account account = new Account(request.getUserId(), request.getType(), request.getInitialBalance());
        return accountRepository.save(account);
    }
}
```

### **Shared Library Structure**
```java
// Common entities shared across services
@Entity
@Table(name = "accounts")
public class Account {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private Long userId;
    
    @Enumerated(EnumType.STRING)
    private AccountType accountType;
    
    @Column(precision = 19, scale = 2)
    private BigDecimal balance;
    
    @Version
    private Long version; // Optimistic locking
}

// Common enums
public enum TransactionType {
    DEPOSIT, WITHDRAWAL, TRANSFER, PAYMENT
}

// Shared utilities
public class ValidationUtils {
    public static boolean isValidAmount(BigDecimal amount) {
        return amount != null && amount.compareTo(BigDecimal.ZERO) > 0;
    }
}
```

## 📊 Microservices Benefits & Challenges

### **Benefits Achieved**
- **Independent Scaling**: Payment service scales differently than balance service
- **Technology Diversity**: Different databases and frameworks per service
- **Team Autonomy**: Clear ownership boundaries
- **Fault Isolation**: Service failures don't cascade
- **Deployment Independence**: Deploy services separately

### **Challenges Addressed**
- **Distributed Complexity**: Service mesh and monitoring
- **Data Consistency**: Saga pattern and event sourcing
- **Network Latency**: Caching and async communication
- **Testing Complexity**: Comprehensive testing pyramid
- **Operational Overhead**: Automation and tooling

## 📋 Microservices Interview Checklist

- [ ] Can explain service decomposition strategy using DDD principles
- [ ] Demonstrates understanding of data consistency patterns
- [ ] Shows knowledge of service communication patterns
- [ ] Understands service discovery and configuration management
- [ ] Can explain comprehensive testing strategies for microservices
- [ ] Shows awareness of microservices benefits and challenges
- [ ] Demonstrates knowledge of resilience patterns (Circuit Breaker, Bulkhead)
- [ ] Understands deployment and operational considerations
- [ ] Can discuss security implications in distributed systems
- [ ] Shows knowledge of monitoring and observability in microservices

---

**Key Takeaway**: This microservices implementation demonstrates deep understanding of distributed systems architecture, domain-driven design, and enterprise-level patterns suitable for critical banking applications.
