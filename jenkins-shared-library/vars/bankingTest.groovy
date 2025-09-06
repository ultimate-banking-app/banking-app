def runUnitTests() {
    echo "🧪 Running unit tests..."
    sh '''
        mvn test -Dtest.profile=unit
        echo "✅ Unit tests completed"
    '''
}

def runIntegrationTests() {
    echo "🔗 Running integration tests..."
    sh '''
        mvn verify -Dtest.profile=integration
        echo "✅ Integration tests completed"
    '''
}

def runHealthChecks(String environment) {
    echo "🏥 Running health checks for ${environment}..."
    
    def services = [
        [name: 'api-gateway', port: 8080],
        [name: 'auth-service', port: 8081],
        [name: 'account-service', port: 8082],
        [name: 'payment-service', port: 8083],
        [name: 'balance-service', port: 8084],
        [name: 'transfer-service', port: 8085],
        [name: 'deposit-service', port: 8086],
        [name: 'withdrawal-service', port: 8087],
        [name: 'notification-service', port: 8088],
        [name: 'audit-service', port: 8089]
    ]
    
    def baseUrl = getEnvironmentUrl(environment)
    
    services.each { service ->
        retry(3) {
            sh """
                curl -f ${baseUrl}:${service.port}/actuator/health || exit 1
                echo "✅ ${service.name} health check passed"
            """
        }
    }
}

def runSmokeTests(String environment) {
    echo "💨 Running smoke tests for ${environment}..."
    
    def baseUrl = getEnvironmentUrl(environment)
    
    sh """
        # Test user registration
        curl -X POST ${baseUrl}:8081/auth/register \\
          -H "Content-Type: application/json" \\
          -d '{"username":"smoketest","email":"smoke@test.com","password":"test123"}'
        
        # Test account creation
        curl -X POST ${baseUrl}:8082/accounts \\
          -H "Content-Type: application/json" \\
          -d '{"userId":1,"accountType":"SAVINGS","initialBalance":1000.00}'
        
        # Test balance check
        curl -f ${baseUrl}:8084/balance/1
        
        echo "✅ Smoke tests passed"
    """
}

def getEnvironmentUrl(String environment) {
    switch(environment) {
        case 'dev':
            return 'http://dev-banking.local'
        case 'staging':
            return 'http://staging-banking.local'
        case 'prod':
            return 'https://banking.company.com'
        default:
            return 'http://localhost'
    }
}
