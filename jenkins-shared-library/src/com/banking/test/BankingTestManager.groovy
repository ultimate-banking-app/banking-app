package com.banking.test

class BankingTestManager implements Serializable {
    
    def script
    
    BankingTestManager(script) {
        this.script = script
    }
    
    def runUnitTests() {
        script.echo "🧪 Running unit tests..."
        script.sh '''
            mvn test -Dtest.profile=unit -q
            echo "✅ Unit tests completed"
        '''
    }
    
    def runIntegrationTests() {
        script.echo "🔗 Running integration tests..."
        script.sh '''
            mvn verify -Dtest.profile=integration -q
            echo "✅ Integration tests completed"
        '''
    }
    
    def runServiceHealthCheck(String service, int port, String environment = 'localhost') {
        script.echo "🏥 Health check for ${service} on port ${port}..."
        
        def baseUrl = getEnvironmentUrl(environment)
        
        script.retry(3) {
            script.sh """
                curl -f ${baseUrl}:${port}/actuator/health --max-time 30 || exit 1
                echo "✅ ${service} health check passed"
            """
        }
    }
    
    def runSmokeTests(String environment) {
        script.echo "💨 Running smoke tests for ${environment}..."
        
        def baseUrl = getEnvironmentUrl(environment)
        
        script.sh """
            # Test API Gateway
            curl -f ${baseUrl}:8080/actuator/health --max-time 10
            
            # Test Auth Service
            curl -f ${baseUrl}:8081/actuator/health --max-time 10
            
            # Test Account Service  
            curl -f ${baseUrl}:8082/actuator/health --max-time 10
            
            echo "✅ Smoke tests passed"
        """
    }
    
    private def getEnvironmentUrl(String environment) {
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
}
