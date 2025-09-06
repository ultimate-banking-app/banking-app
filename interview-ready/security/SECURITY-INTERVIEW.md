# Security Interview Guide - Banking Application

## 🔒 Security Architecture Overview

### **Defense in Depth Strategy**
```
┌─────────────────────────────────────────────────────────────┐
│                    Network Security Layer                   │
│              Firewalls + WAF + DDoS Protection             │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                 Application Security Layer                  │
│           Authentication + Authorization + Input Validation │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                   Data Security Layer                       │
│              Encryption + Masking + Access Controls        │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                Infrastructure Security Layer                │
│           Container Security + Secrets Management          │
└─────────────────────────────────────────────────────────────┘
```

### **Security Domains Covered**
- **Authentication & Authorization** - JWT, RBAC, OAuth2
- **Data Protection** - Encryption, PII masking, secure storage
- **API Security** - Rate limiting, input validation, CORS
- **Container Security** - Image scanning, runtime protection
- **CI/CD Security** - SAST, DAST, dependency scanning
- **Compliance** - PCI DSS, SOX, GDPR requirements

## 🎤 Key Interview Questions & Answers

### **Q: How do you implement authentication and authorization in a banking microservices architecture?**
```
A: "Multi-layered security approach with JWT and RBAC:

AUTHENTICATION STRATEGY:

1. JWT TOKEN-BASED AUTHENTICATION:
   - Stateless authentication across microservices
   - Short-lived access tokens (1 hour)
   - Refresh token rotation for security
   - Digital signature verification

@Service
public class AuthenticationService {
    private final JwtTokenProvider jwtTokenProvider;
    private final PasswordEncoder passwordEncoder;
    
    public AuthenticationResponse authenticate(LoginRequest request) {
        User user = userRepository.findByUsername(request.getUsername())
            .orElseThrow(() -> new BadCredentialsException("Invalid credentials"));
        
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            // Log failed attempt for security monitoring
            securityEventService.logFailedLogin(request.getUsername(), request.getIpAddress());
            throw new BadCredentialsException("Invalid credentials");
        }
        
        // Generate tokens
        String accessToken = jwtTokenProvider.generateAccessToken(user);
        String refreshToken = jwtTokenProvider.generateRefreshToken(user);
        
        // Log successful authentication
        securityEventService.logSuccessfulLogin(user.getUsername(), request.getIpAddress());
        
        return AuthenticationResponse.builder()
            .accessToken(accessToken)
            .refreshToken(refreshToken)
            .expiresIn(3600) // 1 hour
            .build();
    }
}

2. ROLE-BASED ACCESS CONTROL (RBAC):
   - Hierarchical role structure
   - Fine-grained permissions
   - Service-level authorization

@Entity
public class User {
    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(name = "user_roles")
    private Set<Role> roles = new HashSet<>();
}

@Entity
public class Role {
    @Enumerated(EnumType.STRING)
    private RoleType roleType; // CUSTOMER, TELLER, MANAGER, ADMIN
    
    @ManyToMany
    @JoinTable(name = "role_permissions")
    private Set<Permission> permissions = new HashSet<>();
}

@PreAuthorize("hasPermission(#accountId, 'ACCOUNT', 'READ')")
public Account getAccount(Long accountId) {
    return accountRepository.findById(accountId);
}

3. API GATEWAY SECURITY:
   - Centralized authentication enforcement
   - Rate limiting per user/IP
   - Request/response filtering

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    @Override
    protected void doFilterInternal(HttpServletRequest request, 
                                  HttpServletResponse response, 
                                  FilterChain filterChain) {
        String token = extractTokenFromRequest(request);
        
        if (token != null && jwtTokenProvider.validateToken(token)) {
            Authentication auth = jwtTokenProvider.getAuthentication(token);
            SecurityContextHolder.getContext().setAuthentication(auth);
        }
        
        filterChain.doFilter(request, response);
    }
}

AUTHORIZATION PATTERNS:

1. METHOD-LEVEL SECURITY:
@PreAuthorize("hasRole('TELLER') or (hasRole('CUSTOMER') and #accountId == authentication.principal.accountId)")
public Balance getBalance(Long accountId) {
    return balanceService.getBalance(accountId);
}

2. DATA-LEVEL SECURITY:
@PostFilter("hasPermission(filterObject, 'READ')")
public List<Account> getUserAccounts(Long userId) {
    return accountRepository.findByUserId(userId);
}

SECURITY FEATURES:
- Multi-factor authentication for privileged operations
- Session management with concurrent session limits
- Account lockout after failed attempts
- Password complexity requirements
- Regular password rotation policies"
```

### **Q: How do you protect sensitive data in a banking application?**
```
A: "Comprehensive data protection strategy:

DATA CLASSIFICATION:
1. PUBLIC: Marketing information, general terms
2. INTERNAL: Business processes, non-sensitive operations
3. CONFIDENTIAL: Account numbers, transaction details
4. RESTRICTED: SSNs, credit card numbers, authentication data

ENCRYPTION STRATEGY:

1. ENCRYPTION AT REST:
   - Database-level encryption (TDE)
   - Application-level field encryption
   - Key rotation and management

@Entity
public class Account {
    @Convert(converter = EncryptedStringConverter.class)
    @Column(name = "account_number")
    private String accountNumber;
    
    @Convert(converter = EncryptedBigDecimalConverter.class)
    @Column(name = "balance")
    private BigDecimal balance;
}

@Converter
public class EncryptedStringConverter implements AttributeConverter<String, String> {
    private final AESUtil aesUtil;
    
    @Override
    public String convertToDatabaseColumn(String attribute) {
        return aesUtil.encrypt(attribute);
    }
    
    @Override
    public String convertToEntityAttribute(String dbData) {
        return aesUtil.decrypt(dbData);
    }
}

2. ENCRYPTION IN TRANSIT:
   - TLS 1.3 for all communications
   - Certificate pinning for mobile apps
   - mTLS for service-to-service communication

server:
  ssl:
    enabled: true
    key-store: classpath:keystore.p12
    key-store-password: ${SSL_KEYSTORE_PASSWORD}
    key-store-type: PKCS12
    protocol: TLS
    enabled-protocols: TLSv1.3

3. PII DATA MASKING:
   - Automatic masking in logs and responses
   - Dynamic masking based on user roles
   - Tokenization for sensitive data

@JsonSerialize(using = AccountNumberMaskingSerializer.class)
public class AccountResponse {
    private String accountNumber; // Masked as ****1234
    private BigDecimal balance;
}

public class AccountNumberMaskingSerializer extends JsonSerializer<String> {
    @Override
    public void serialize(String value, JsonGenerator gen, SerializerProvider serializers) {
        if (value != null && value.length() > 4) {
            String masked = "****" + value.substring(value.length() - 4);
            gen.writeString(masked);
        }
    }
}

KEY MANAGEMENT:
- Hardware Security Modules (HSM) for key storage
- Key rotation every 90 days
- Separate keys per environment
- Key escrow for disaster recovery

@Service
public class KeyManagementService {
    public String getEncryptionKey(String keyId) {
        // Retrieve from HSM or secure key vault
        return hsmClient.getKey(keyId);
    }
    
    @Scheduled(cron = "0 0 0 1 */3 *") // Every 3 months
    public void rotateKeys() {
        keyRotationService.rotateAllKeys();
    }
}

DATA LOSS PREVENTION (DLP):
- Automated PII detection in code and logs
- Data classification and labeling
- Egress monitoring and controls
- Regular data inventory and mapping"
```

### **Q: Describe your approach to API security in microservices.**
```
A: "Comprehensive API security framework:

API SECURITY LAYERS:

1. INPUT VALIDATION & SANITIZATION:
   - Request validation at multiple levels
   - SQL injection prevention
   - XSS protection
   - Parameter tampering prevention

@RestController
@Validated
public class AccountController {
    
    @PostMapping("/accounts")
    public ResponseEntity<Account> createAccount(
            @Valid @RequestBody CreateAccountRequest request,
            HttpServletRequest httpRequest) {
        
        // Input validation
        validateRequest(request);
        
        // Rate limiting check
        if (!rateLimitService.isAllowed(httpRequest.getRemoteAddr())) {
            throw new RateLimitExceededException("Too many requests");
        }
        
        // Sanitize inputs
        request = sanitizeRequest(request);
        
        Account account = accountService.createAccount(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(account);
    }
}

@Component
public class RequestValidator {
    public void validateRequest(CreateAccountRequest request) {
        // Business rule validation
        if (request.getInitialBalance().compareTo(BigDecimal.ZERO) < 0) {
            throw new ValidationException("Initial balance cannot be negative");
        }
        
        // Format validation
        if (!isValidAccountType(request.getAccountType())) {
            throw new ValidationException("Invalid account type");
        }
    }
}

2. RATE LIMITING & THROTTLING:
   - Per-user rate limits
   - IP-based throttling
   - API endpoint-specific limits
   - Burst protection

@Component
public class RateLimitService {
    private final RedisTemplate<String, String> redisTemplate;
    
    public boolean isAllowed(String clientId, String endpoint) {
        String key = "rate_limit:" + clientId + ":" + endpoint;
        String currentCount = redisTemplate.opsForValue().get(key);
        
        if (currentCount == null) {
            redisTemplate.opsForValue().set(key, "1", Duration.ofMinutes(1));
            return true;
        }
        
        int count = Integer.parseInt(currentCount);
        int limit = getRateLimitForEndpoint(endpoint);
        
        if (count >= limit) {
            return false;
        }
        
        redisTemplate.opsForValue().increment(key);
        return true;
    }
}

3. CORS & SECURITY HEADERS:
   - Strict CORS policies
   - Security headers implementation
   - Content Security Policy (CSP)

@Configuration
public class SecurityConfig {
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOriginPatterns(Arrays.asList("https://*.banking.com"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE"));
        configuration.setAllowedHeaders(Arrays.asList("*"));
        configuration.setAllowCredentials(true);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http.headers(headers -> headers
            .frameOptions().deny()
            .contentTypeOptions().and()
            .httpStrictTransportSecurity(hstsConfig -> hstsConfig
                .maxAgeInSeconds(31536000)
                .includeSubdomains(true))
            .and()
        );
        return http.build();
    }
}

4. API VERSIONING & DEPRECATION:
   - Backward compatibility maintenance
   - Graceful deprecation process
   - Security patch distribution

@RestController
@RequestMapping("/v1/accounts")
public class AccountControllerV1 {
    // Legacy implementation with security patches
}

@RestController
@RequestMapping("/v2/accounts")
public class AccountControllerV2 {
    // Enhanced security implementation
}

OAUTH2 & OPENID CONNECT:
- Standard-based authentication
- Scope-based authorization
- Token introspection and validation

@EnableResourceServer
@Configuration
public class ResourceServerConfig extends ResourceServerConfigurerAdapter {
    @Override
    public void configure(HttpSecurity http) throws Exception {
        http.authorizeRequests()
            .antMatchers("/accounts/**").hasScope("account:read")
            .antMatchers("/payments/**").hasScope("payment:write")
            .anyRequest().authenticated();
    }
}"
```

### **Q: How do you implement security in your CI/CD pipeline?**
```
A: "Security integrated throughout the entire pipeline:

SHIFT-LEFT SECURITY APPROACH:

1. SOURCE CODE SECURITY:
   - Pre-commit hooks for secret detection
   - Branch protection rules
   - Signed commits for production

# .pre-commit-config.yaml
repos:
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']

2. STATIC APPLICATION SECURITY TESTING (SAST):
   - Multiple SAST tools for comprehensive coverage
   - Custom security rules for banking domain
   - Quality gates for security findings

stage('Security Scan') {
    parallel {
        'OWASP Dependency Check': {
            sh '''
                mvn org.owasp:dependency-check-maven:check \\
                  -DfailBuildOnCVSS=7 \\
                  -DsuppressionsFile=owasp-suppressions.xml
            '''
        }
        'SpotBugs Security': {
            sh '''
                mvn com.github.spotbugs:spotbugs-maven-plugin:check \\
                  -Dspotbugs.includeFilterFile=security-rules.xml
            '''
        }
        'Semgrep SAST': {
            sh '''
                semgrep --config=auto --error --json \\
                  --output=semgrep-results.json .
            '''
        }
    }
}

3. DEPENDENCY SECURITY:
   - Automated vulnerability scanning
   - License compliance checking
   - Supply chain security validation

def runDependencyCheck() {
    sh '''
        # OWASP Dependency Check
        mvn org.owasp:dependency-check-maven:check
        
        # Snyk vulnerability scanning
        snyk test --severity-threshold=high
        
        # License compliance
        mvn org.codehaus.mojo:license-maven-plugin:check-file-header
    '''
}

4. CONTAINER SECURITY:
   - Multi-tool image scanning
   - Base image vulnerability assessment
   - Runtime security policies

def scanContainerImages(services) {
    services.each { service ->
        sh """
            # Trivy comprehensive scan
            trivy image --exit-code 1 --severity HIGH,CRITICAL \\
              --format json --output trivy-${service}.json \\
              ${ECR_REGISTRY}/${service}:${BUILD_NUMBER}
            
            # Grype additional scanning
            grype ${ECR_REGISTRY}/${service}:${BUILD_NUMBER} \\
              --fail-on high --output json --file grype-${service}.json
            
            # Docker Scout (if available)
            docker scout cves ${ECR_REGISTRY}/${service}:${BUILD_NUMBER} \\
              --format json --output scout-${service}.json
        """
    }
}

5. SECRETS MANAGEMENT:
   - No hardcoded secrets in code
   - Encrypted secrets in CI/CD
   - Runtime secret injection

# Kubernetes secrets management
apiVersion: v1
kind: Secret
metadata:
  name: banking-secrets
type: Opaque
data:
  database-password: <base64-encoded-password>
  jwt-secret: <base64-encoded-jwt-secret>

# Application configuration
spring:
  datasource:
    password: ${DATABASE_PASSWORD}
  security:
    jwt:
      secret: ${JWT_SECRET}

SECURITY QUALITY GATES:
- HIGH/CRITICAL vulnerabilities fail the build
- Security test coverage > 80%
- No secrets detected in code
- Container images pass security scan
- Compliance checks pass

COMPLIANCE AUTOMATION:
- PCI DSS compliance validation
- SOX controls verification
- GDPR privacy impact assessment
- Automated compliance reporting"
```

### **Q: How do you handle security monitoring and incident response?**
```
A: "Comprehensive security monitoring and response framework:

SECURITY MONITORING:

1. REAL-TIME THREAT DETECTION:
   - Behavioral analytics for anomaly detection
   - Machine learning for fraud detection
   - Real-time alerting for security events

@Component
public class SecurityMonitoringService {
    
    @EventListener
    public void handleLoginAttempt(LoginAttemptEvent event) {
        // Detect suspicious login patterns
        if (isAnomalousLogin(event)) {
            securityAlertService.raiseAlert(
                SecurityAlert.builder()
                    .type(SUSPICIOUS_LOGIN)
                    .severity(HIGH)
                    .userId(event.getUserId())
                    .ipAddress(event.getIpAddress())
                    .details(event.getDetails())
                    .build()
            );
        }
    }
    
    private boolean isAnomalousLogin(LoginAttemptEvent event) {
        // Check for unusual patterns
        return isUnusualLocation(event.getIpAddress()) ||
               isUnusualTime(event.getTimestamp()) ||
               hasMultipleFailedAttempts(event.getUserId());
    }
}

2. AUDIT LOGGING:
   - Comprehensive audit trail
   - Immutable log storage
   - Real-time log analysis

@Component
@Slf4j
public class AuditLogger {
    
    @EventListener
    public void logSecurityEvent(SecurityEvent event) {
        AuditLog auditLog = AuditLog.builder()
            .eventType(event.getType())
            .userId(event.getUserId())
            .timestamp(Instant.now())
            .ipAddress(event.getIpAddress())
            .userAgent(event.getUserAgent())
            .details(event.getDetails())
            .build();
        
        // Store in immutable audit store
        auditRepository.save(auditLog);
        
        // Send to SIEM for real-time analysis
        siemService.sendEvent(auditLog);
        
        log.info("Security event logged: {}", auditLog);
    }
}

3. FRAUD DETECTION:
   - Transaction pattern analysis
   - Velocity checks
   - Geographic anomaly detection

@Service
public class FraudDetectionService {
    
    public FraudAssessment assessTransaction(Transaction transaction) {
        FraudScore score = calculateFraudScore(transaction);
        
        if (score.getValue() > FRAUD_THRESHOLD) {
            // Block transaction and alert
            alertService.sendFraudAlert(transaction, score);
            return FraudAssessment.BLOCKED;
        } else if (score.getValue() > REVIEW_THRESHOLD) {
            // Flag for manual review
            reviewService.flagForReview(transaction, score);
            return FraudAssessment.REVIEW_REQUIRED;
        }
        
        return FraudAssessment.APPROVED;
    }
    
    private FraudScore calculateFraudScore(Transaction transaction) {
        double score = 0.0;
        
        // Velocity checks
        score += velocityAnalyzer.analyze(transaction);
        
        // Geographic analysis
        score += geographicAnalyzer.analyze(transaction);
        
        // Behavioral analysis
        score += behavioralAnalyzer.analyze(transaction);
        
        return new FraudScore(score);
    }
}

INCIDENT RESPONSE:

1. AUTOMATED RESPONSE:
   - Account lockout for suspicious activity
   - Automatic transaction blocking
   - Service isolation for compromised components

@Component
public class IncidentResponseService {
    
    @EventListener
    public void handleSecurityIncident(SecurityIncident incident) {
        switch (incident.getSeverity()) {
            case CRITICAL:
                executeCriticalResponse(incident);
                break;
            case HIGH:
                executeHighSeverityResponse(incident);
                break;
            case MEDIUM:
                executeMediumSeverityResponse(incident);
                break;
        }
    }
    
    private void executeCriticalResponse(SecurityIncident incident) {
        // Immediate containment
        if (incident.getType() == ACCOUNT_COMPROMISE) {
            accountService.lockAccount(incident.getAffectedAccountId());
            notificationService.sendSecurityAlert(incident.getUserId());
        }
        
        // Escalate to security team
        escalationService.escalateToSecurityTeam(incident);
        
        // Log for forensics
        forensicsService.preserveEvidence(incident);
    }
}

2. FORENSICS & INVESTIGATION:
   - Evidence preservation
   - Timeline reconstruction
   - Impact assessment

@Service
public class ForensicsService {
    
    public void preserveEvidence(SecurityIncident incident) {
        // Preserve relevant logs
        List<AuditLog> relevantLogs = auditRepository.findByTimeRange(
            incident.getStartTime().minus(Duration.ofHours(1)),
            incident.getEndTime().plus(Duration.ofHours(1))
        );
        
        // Create forensics package
        ForensicsPackage forensicsPackage = ForensicsPackage.builder()
            .incidentId(incident.getId())
            .auditLogs(relevantLogs)
            .systemSnapshots(captureSystemSnapshots())
            .networkLogs(captureNetworkLogs(incident))
            .build();
        
        // Store in secure, immutable storage
        forensicsRepository.store(forensicsPackage);
    }
}

SECURITY METRICS & KPIs:
- Mean Time to Detection (MTTD): < 5 minutes
- Mean Time to Response (MTTR): < 15 minutes
- False Positive Rate: < 5%
- Security Event Coverage: > 95%
- Compliance Score: > 98%

COMPLIANCE REPORTING:
- Automated regulatory reporting
- Real-time compliance dashboards
- Audit trail completeness verification
- Privacy impact assessments"
```

## 🔧 Security Implementation Details

### **JWT Token Implementation**
```java
@Component
public class JwtTokenProvider {
    private final String jwtSecret;
    private final int jwtExpirationInMs;
    
    public String generateToken(UserPrincipal userPrincipal) {
        Date expiryDate = new Date(System.currentTimeMillis() + jwtExpirationInMs);
        
        return Jwts.builder()
                .setSubject(Long.toString(userPrincipal.getId()))
                .setIssuedAt(new Date())
                .setExpiration(expiryDate)
                .signWith(SignatureAlgorithm.HS512, jwtSecret)
                .compact();
    }
    
    public boolean validateToken(String authToken) {
        try {
            Jwts.parser().setSigningKey(jwtSecret).parseClaimsJws(authToken);
            return true;
        } catch (SignatureException ex) {
            logger.error("Invalid JWT signature");
        } catch (MalformedJwtException ex) {
            logger.error("Invalid JWT token");
        } catch (ExpiredJwtException ex) {
            logger.error("Expired JWT token");
        }
        return false;
    }
}
```

### **Encryption Utilities**
```java
@Component
public class AESUtil {
    private final String encryptionKey;
    
    public String encrypt(String plainText) {
        try {
            Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            SecretKeySpec keySpec = new SecretKeySpec(encryptionKey.getBytes(), "AES");
            cipher.init(Cipher.ENCRYPT_MODE, keySpec);
            
            byte[] encryptedBytes = cipher.doFinal(plainText.getBytes());
            return Base64.getEncoder().encodeToString(encryptedBytes);
        } catch (Exception e) {
            throw new EncryptionException("Failed to encrypt data", e);
        }
    }
    
    public String decrypt(String encryptedText) {
        try {
            Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            SecretKeySpec keySpec = new SecretKeySpec(encryptionKey.getBytes(), "AES");
            cipher.init(Cipher.DECRYPT_MODE, keySpec);
            
            byte[] decryptedBytes = cipher.doFinal(Base64.getDecoder().decode(encryptedText));
            return new String(decryptedBytes);
        } catch (Exception e) {
            throw new DecryptionException("Failed to decrypt data", e);
        }
    }
}
```

## 📊 Security Metrics & Compliance

### **Security KPIs**
- **Authentication Success Rate**: > 99.5%
- **Failed Login Attempts**: < 0.1% of total attempts
- **Token Validation Success**: > 99.9%
- **Encryption Coverage**: 100% of sensitive data
- **Vulnerability Remediation**: < 24 hours for CRITICAL

### **Compliance Standards**
- **PCI DSS**: Payment card data protection
- **SOX**: Financial reporting controls
- **GDPR**: Privacy and data protection
- **ISO 27001**: Information security management
- **NIST Cybersecurity Framework**: Risk management

## 📋 Security Interview Checklist

- [ ] Can explain comprehensive authentication and authorization strategy
- [ ] Demonstrates understanding of data protection and encryption
- [ ] Shows knowledge of API security best practices
- [ ] Understands CI/CD security integration (DevSecOps)
- [ ] Can explain security monitoring and incident response
- [ ] Shows awareness of compliance requirements for banking
- [ ] Demonstrates knowledge of threat modeling and risk assessment
- [ ] Understands container and infrastructure security
- [ ] Can discuss security testing strategies (SAST, DAST, IAST)
- [ ] Shows knowledge of security architecture patterns

---

**Key Takeaway**: This security implementation demonstrates enterprise-level security engineering with comprehensive coverage of authentication, data protection, API security, and compliance requirements suitable for critical banking applications.
