package com.banking.deploy

class BankingDeploymentManager implements Serializable {
    
    def script
    
    BankingDeploymentManager(script) {
        this.script = script
    }
    
    def deployToEnvironment(String environment) {
        script.echo "🚀 Deploying to ${environment} environment..."
        
        switch(environment) {
            case 'dev':
                deployToDev()
                break
            case 'staging':
                deployToStaging()
                break
            case 'prod':
                deployToProduction()
                break
            default:
                script.error("Unknown environment: ${environment}")
        }
    }
    
    def deployToDev() {
        script.echo "🔧 Deploying to Development..."
        
        script.sh '''
            docker-compose -f docker-compose.dev.yml down || true
            docker-compose -f docker-compose.dev.yml pull
            docker-compose -f docker-compose.dev.yml up -d
            
            echo "✅ Development deployment completed"
        '''
    }
    
    def deployToStaging() {
        script.echo "🎭 Deploying to Staging..."
        
        script.sh '''
            kubectl config use-context staging
            kubectl apply -f k8s/staging/ -n banking-staging
            kubectl rollout status deployment -n banking-staging --timeout=300s
            
            echo "✅ Staging deployment completed"
        '''
    }
    
    def deployToProduction() {
        script.echo "🏭 Deploying to Production..."
        
        // Require manual approval for production
        script.input message: 'Deploy to Production?', ok: 'Deploy',
              submitterParameter: 'APPROVER'
        
        script.sh '''
            kubectl config use-context production
            kubectl apply -f k8s/production/ -n banking-prod
            kubectl rollout status deployment -n banking-prod --timeout=600s
            
            echo "✅ Production deployment completed"
        '''
        
        script.echo "Approved by: ${script.env.APPROVER}"
    }
    
    def rollback(String environment, String version) {
        script.echo "⏪ Rolling back ${environment} to version ${version}..."
        
        script.sh """
            kubectl config use-context ${environment}
            kubectl rollout undo deployment -n banking-${environment} --to-revision=${version}
            kubectl rollout status deployment -n banking-${environment} --timeout=300s
            
            echo "✅ Rollback completed"
        """
    }
    
    def getDeploymentStatus(String environment) {
        def status = script.sh(
            script: """
                kubectl config use-context ${environment}
                kubectl get deployments -n banking-${environment} -o jsonpath='{.items[*].status.readyReplicas}'
            """,
            returnStdout: true
        ).trim()
        
        return status
    }
}
