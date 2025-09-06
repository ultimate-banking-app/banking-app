package com.banking.utils

class BankingPipelineUtils implements Serializable {
    
    def script
    
    BankingPipelineUtils(script) {
        this.script = script
    }
    
    def getChangedServices() {
        def changedFiles = script.sh(
            script: 'git diff --name-only HEAD~1 HEAD || echo "all"',
            returnStdout: true
        ).trim()
        
        def services = []
        def allServices = getAllServices()
        
        if (changedFiles == "all") {
            return allServices
        }
        
        allServices.each { service ->
            if (changedFiles.contains("${service}/") || changedFiles.contains("shared/")) {
                services.add(service)
            }
        }
        
        return services.isEmpty() ? allServices : services
    }
    
    def getAllServices() {
        return [
            'api-gateway',
            'auth-service', 
            'account-service',
            'payment-service',
            'balance-service',
            'transfer-service',
            'deposit-service',
            'withdrawal-service',
            'notification-service',
            'audit-service'
        ]
    }
    
    def getServicePort(String service) {
        def portMap = [
            'api-gateway': 8080,
            'auth-service': 8081,
            'account-service': 8082,
            'payment-service': 8083,
            'balance-service': 8084,
            'transfer-service': 8085,
            'deposit-service': 8086,
            'withdrawal-service': 8087,
            'notification-service': 8088,
            'audit-service': 8089
        ]
        return portMap[service] ?: 8080
    }
}
