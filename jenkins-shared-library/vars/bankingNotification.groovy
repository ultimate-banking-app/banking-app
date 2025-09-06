def sendSuccessNotification() {
    echo "✅ Sending success notification..."
    
    def message = """
    🎉 Banking Application Deployment Successful!
    
    📋 Build Details:
    • Build Number: ${env.BUILD_NUMBER}
    • Environment: ${params.DEPLOY_ENV}
    • Branch: ${env.BRANCH_NAME}
    • Commit: ${env.GIT_COMMIT?.take(8)}
    • Duration: ${currentBuild.durationString}
    
    🔗 Build URL: ${env.BUILD_URL}
    """
    
    // Slack notification
    slackSend(
        channel: '#banking-deployments',
        color: 'good',
        message: message
    )
    
    // Email notification
    emailext(
        subject: "✅ Banking App Deployment Success - Build #${env.BUILD_NUMBER}",
        body: message,
        to: '${DEFAULT_RECIPIENTS}',
        recipientProviders: [developers(), requestor()]
    )
}

def sendFailureNotification() {
    echo "❌ Sending failure notification..."
    
    def message = """
    🚨 Banking Application Deployment Failed!
    
    📋 Build Details:
    • Build Number: ${env.BUILD_NUMBER}
    • Environment: ${params.DEPLOY_ENV}
    • Branch: ${env.BRANCH_NAME}
    • Commit: ${env.GIT_COMMIT?.take(8)}
    • Duration: ${currentBuild.durationString}
    • Failed Stage: ${env.STAGE_NAME}
    
    🔗 Build URL: ${env.BUILD_URL}
    📝 Console: ${env.BUILD_URL}console
    """
    
    // Slack notification
    slackSend(
        channel: '#banking-deployments',
        color: 'danger',
        message: message
    )
    
    // Email notification
    emailext(
        subject: "❌ Banking App Deployment Failed - Build #${env.BUILD_NUMBER}",
        body: message,
        to: '${DEFAULT_RECIPIENTS}',
        recipientProviders: [developers(), requestor(), culprits()]
    )
}

def sendDeploymentStartNotification() {
    echo "🚀 Sending deployment start notification..."
    
    slackSend(
        channel: '#banking-deployments',
        color: 'warning',
        message: "🚀 Banking App deployment started for ${params.DEPLOY_ENV} - Build #${env.BUILD_NUMBER}"
    )
}
