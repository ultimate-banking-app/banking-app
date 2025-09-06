package com.banking.notification

class BankingNotificationManager implements Serializable {
    
    def script
    
    BankingNotificationManager(script) {
        this.script = script
    }
    
    def sendSuccessNotification() {
        script.echo "✅ Sending success notification..."
        
        def message = buildSuccessMessage()
        
        sendSlackNotification(message, 'good')
        sendEmailNotification(message, 'SUCCESS')
    }
    
    def sendFailureNotification() {
        script.echo "❌ Sending failure notification..."
        
        def message = buildFailureMessage()
        
        sendSlackNotification(message, 'danger')
        sendEmailNotification(message, 'FAILURE')
    }
    
    def sendDeploymentStartNotification(String environment) {
        script.echo "🚀 Sending deployment start notification..."
        
        def message = "🚀 Banking App deployment started for ${environment} - Build #${script.env.BUILD_NUMBER}"
        
        sendSlackNotification(message, 'warning')
    }
    
    private def buildSuccessMessage() {
        return """
🎉 Banking Application Deployment Successful!

📋 Build Details:
• Build Number: ${script.env.BUILD_NUMBER}
• Environment: ${script.params?.DEPLOY_ENV ?: 'N/A'}
• Branch: ${script.env.BRANCH_NAME ?: 'N/A'}
• Commit: ${script.env.GIT_COMMIT?.take(8) ?: 'N/A'}
• Duration: ${script.currentBuild.durationString}

🔗 Build URL: ${script.env.BUILD_URL}
        """.trim()
    }
    
    private def buildFailureMessage() {
        return """
🚨 Banking Application Deployment Failed!

📋 Build Details:
• Build Number: ${script.env.BUILD_NUMBER}
• Environment: ${script.params?.DEPLOY_ENV ?: 'N/A'}
• Branch: ${script.env.BRANCH_NAME ?: 'N/A'}
• Commit: ${script.env.GIT_COMMIT?.take(8) ?: 'N/A'}
• Duration: ${script.currentBuild.durationString}
• Failed Stage: ${script.env.STAGE_NAME ?: 'Unknown'}

🔗 Build URL: ${script.env.BUILD_URL}
📝 Console: ${script.env.BUILD_URL}console
        """.trim()
    }
    
    private def sendSlackNotification(String message, String color) {
        try {
            script.slackSend(
                channel: '#banking-deployments',
                color: color,
                message: message
            )
        } catch (Exception e) {
            script.echo "⚠️ Failed to send Slack notification: ${e.message}"
        }
    }
    
    private def sendEmailNotification(String message, String status) {
        try {
            def subject = "${status == 'SUCCESS' ? '✅' : '❌'} Banking App Deployment ${status} - Build #${script.env.BUILD_NUMBER}"
            
            script.emailext(
                subject: subject,
                body: message,
                to: '${DEFAULT_RECIPIENTS}',
                recipientProviders: [
                    script.developers(), 
                    script.requestor()
                ]
            )
            
            if (status == 'FAILURE') {
                // Add culprits for failures
                script.emailext(
                    subject: subject,
                    body: message,
                    to: '${DEFAULT_RECIPIENTS}',
                    recipientProviders: [
                        script.culprits()
                    ]
                )
            }
        } catch (Exception e) {
            script.echo "⚠️ Failed to send email notification: ${e.message}"
        }
    }
    
    def sendCustomNotification(String title, String message, String color = 'good') {
        def fullMessage = """
${title}

${message}

🔗 Build: ${script.env.BUILD_URL}
        """.trim()
        
        sendSlackNotification(fullMessage, color)
    }
}
