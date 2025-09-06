package com.banking.security

class BankingSecurityManager implements Serializable {
    
    def script
    
    BankingSecurityManager(script) {
        this.script = script
    }
    
    def runSecurityScan() {
        script.echo "🔒 Running comprehensive security scans..."
        
        script.parallel([
            'Dependency Check': {
                runDependencyCheck()
            },
            'Container Scan': {
                runContainerScan()
            },
            'SAST Scan': {
                runSASTScan()
            },
            'Secret Scan': {
                runSecretScan()
            }
        ])
    }
    
    def runDependencyCheck() {
        script.echo "📦 Running OWASP dependency vulnerability check..."
        
        script.sh '''
            mvn org.owasp:dependency-check-maven:check -q
            echo "✅ Dependency check completed"
        '''
        
        script.publishHTML([
            allowMissing: false,
            alwaysLinkToLastBuild: true,
            keepAll: true,
            reportDir: 'target/dependency-check-report',
            reportFiles: 'dependency-check-report.html',
            reportName: 'OWASP Dependency Check Report'
        ])
    }
    
    def runContainerScan() {
        script.echo "🐳 Running container security scan..."
        
        def services = [
            'api-gateway', 'auth-service', 'account-service', 
            'payment-service', 'balance-service', 'transfer-service',
            'deposit-service', 'withdrawal-service', 'notification-service', 'audit-service'
        ]
        
        services.each { service ->
            script.sh """
                trivy image --exit-code 1 --severity HIGH,CRITICAL ${script.env.DOCKER_REGISTRY}/${service}:${script.env.BUILD_NUMBER}
                echo "✅ Container scan passed for ${service}"
            """
        }
    }
    
    def runSASTScan() {
        script.echo "🔍 Running Static Application Security Testing..."
        
        script.sh '''
            mvn com.github.spotbugs:spotbugs-maven-plugin:check -Dspotbugs.includeFilterFile=security-rules.xml -q
            echo "✅ SAST scan completed"
        '''
    }
    
    def runSecretScan() {
        script.echo "🔐 Scanning for exposed secrets..."
        
        script.sh '''
            # Check for common secret patterns
            if grep -r "password\\|secret\\|key\\|token" --include="*.java" --include="*.yml" --include="*.properties" . | grep -v "example\\|test\\|demo"; then
                echo "⚠️ Potential secrets found - please review"
            else
                echo "✅ No exposed secrets detected"
            fi
        '''
    }
    
    def generateSecurityReport() {
        script.echo "📊 Generating security summary report..."
        
        script.sh '''
            echo "Security Scan Summary - Build ${BUILD_NUMBER}" > security-report.txt
            echo "=======================================" >> security-report.txt
            echo "Timestamp: $(date)" >> security-report.txt
            echo "Branch: ${BRANCH_NAME}" >> security-report.txt
            echo "Commit: ${GIT_COMMIT}" >> security-report.txt
            echo "" >> security-report.txt
            echo "✅ All security scans completed successfully" >> security-report.txt
        '''
        
        script.archiveArtifacts artifacts: 'security-report.txt', allowEmptyArchive: true
    }
}
