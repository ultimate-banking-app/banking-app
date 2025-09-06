def deployToEnvironment(String environment) {
    echo "🚀 Deploying to ${environment} environment..."
    
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
            error("Unknown environment: ${environment}")
    }
}

def deployToDev() {
    echo "🔧 Deploying to Development..."
    
    sh '''
        # Deploy using Docker Compose
        docker-compose -f docker-compose.dev.yml down
        docker-compose -f docker-compose.dev.yml pull
        docker-compose -f docker-compose.dev.yml up -d
        
        echo "✅ Development deployment completed"
    '''
}

def deployToStaging() {
    echo "🎭 Deploying to Staging..."
    
    sh '''
        # Deploy to Kubernetes staging namespace
        kubectl config use-context staging
        kubectl apply -f k8s/staging/ -n banking-staging
        kubectl rollout status deployment -n banking-staging
        
        echo "✅ Staging deployment completed"
    '''
}

def deployToProduction() {
    echo "🏭 Deploying to Production..."
    
    // Require manual approval for production
    input message: 'Deploy to Production?', ok: 'Deploy',
          submitterParameter: 'APPROVER'
    
    sh '''
        # Deploy to Kubernetes production namespace
        kubectl config use-context production
        kubectl apply -f k8s/production/ -n banking-prod
        kubectl rollout status deployment -n banking-prod
        
        echo "✅ Production deployment completed"
        echo "Approved by: ${APPROVER}"
    '''
}

def rollback(String environment, String version) {
    echo "⏪ Rolling back ${environment} to version ${version}..."
    
    sh """
        kubectl config use-context ${environment}
        kubectl rollout undo deployment -n banking-${environment} --to-revision=${version}
        kubectl rollout status deployment -n banking-${environment}
        
        echo "✅ Rollback completed"
    """
}
