def printBanner(message) {
    echo """
    ╔══════════════════════════════════════════════════════════════╗
    ║                                                              ║
    ║  🏦 ${message.center(54)} 🏦  ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
    """
}

def checkoutCode() {
    echo "📥 Checking out source code"
    checkout scm

    sh '''
        echo "Repository information:"
        git log --oneline -5
        echo "Current branch: $(git branch --show-current)"
        echo "Last commit: $(git log -1 --pretty=format:'%h - %s (%an, %ar)')"
    '''
}

def detectChanges() {
    echo "🔍 Detecting changes in services and UI"

    def changes = [
        services: [],
        ui: false
    ]

    if (env.CHANGE_ID) {
        def changedFiles = sh(
            script: "git diff --name-only origin/${env.CHANGE_TARGET}...HEAD",
            returnStdout: true
        ).trim().split('\n')

        changes = analyzeChangedFiles(changedFiles)
    } else {
        def lastSuccessfulCommit = sh(
            script: "git log --format='%H' -n 1 --grep='Jenkins build.*SUCCESS' || git rev-parse HEAD~1",
            returnStdout: true
        ).trim()

        def changedFiles = sh(
            script: "git diff --name-only ${lastSuccessfulCommit}..HEAD",
            returnStdout: true
        ).trim().split('\n')

        changes = analyzeChangedFiles(changedFiles)
    }

    echo "Detected changes:"
    echo "- Services: ${changes.services}"
    echo "- UI: ${changes.ui}"

    return changes
}

def analyzeChangedFiles(changedFiles) {
    def changes = [
        services: [],
        ui: false
    ]

    def serviceDirectories = [
        'auth-service',
        'account-service',
        'payment-service',
        'api-gateway'
    ]

    changedFiles.each { file ->
        if (file) {
            if (file.startsWith('banking-ui/')) {
                changes.ui = true
            }

            serviceDirectories.each { service ->
                if (file.startsWith("${service}/")) {
                    if (!changes.services.contains(service)) {
                        changes.services.add(service)
                    }
                }
            }

            if (file.startsWith('shared/') ||
                file == 'pom.xml' ||
                file.startsWith('docker-compose') ||
                file == 'Jenkinsfile') {
                serviceDirectories.each { service ->
                    if (!changes.services.contains(service)) {
                        changes.services.add(service)
                    }
                }
                changes.ui = true
            }
        }
    }

    return changes
}

def notifySlack(status, message = '') {
    def color = status == 'SUCCESS' ? 'good' : 'danger'
    def emoji = status == 'SUCCESS' ? '✅' : '❌'

    slackSend(
        channel: '#banking-ci-cd',
        color: color,
        message: """
${emoji} Banking Application Pipeline ${status}
Branch: ${env.BRANCH_NAME}
Build: ${env.BUILD_NUMBER}
${message}
        """.trim()
    )
}

def sendEmail(recipients, subject, body) {
    emailext(
        to: recipients,
        subject: subject,
        body: body,
        mimeType: 'text/html'
    )
}
