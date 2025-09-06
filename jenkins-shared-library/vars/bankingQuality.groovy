def runSonarAnalysis() {
    echo "📊 Running SonarQube analysis for backend services"

    sh '''
        mvn sonar:sonar \
            -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
            -Dsonar.host.url=http://sonarqube:9000 \
            -Dsonar.login=${SONAR_TOKEN} \
            -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
    '''
}

def runUIQualityChecks() {
    echo "🎨 Running UI quality checks"

    dir('banking-ui') {
        sh '''
            echo "Running ESLint..."
            npm run lint -- --format=checkstyle --output-file=eslint-report.xml || true

            echo "Running UI tests with coverage..."
            npm run test:coverage || true

            echo "Running UI SonarQube analysis..."
            if command -v sonar-scanner &> /dev/null; then
                sonar-scanner \
                    -Dsonar.projectKey=${SONAR_PROJECT_KEY}-ui \
                    -Dsonar.sources=src \
                    -Dsonar.host.url=http://sonarqube:9000 \
                    -Dsonar.login=${SONAR_TOKEN} \
                    -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info \
                    -Dsonar.eslint.reportPaths=eslint-report.xml
            fi

            echo "Checking bundle size..."
            npm run analyze || true
        '''
    }

    publishHTML([
        allowMissing: false,
        alwaysLinkToLastBuild: true,
        keepAll: true,
        reportDir: 'banking-ui/coverage',
        reportFiles: 'index.html',
        reportName: 'UI Coverage Report'
    ])
}

def checkQualityGates() {
    echo "🚪 Checking quality gates"

    script {
        def qualityGate = waitForQualityGate()
        if (qualityGate.status != 'OK') {
            error "Pipeline aborted due to quality gate failure: ${qualityGate.status}"
        }
    }
}

def generateReports() {
    echo "📋 Generating quality reports"

    publishTestResults testResultsPattern: '**/target/surefire-reports/*.xml'
    publishHTML([
        allowMissing: false,
        alwaysLinkToLastBuild: true,
        keepAll: true,
        reportDir: 'target/site/jacoco',
        reportFiles: 'index.html',
        reportName: 'Backend Coverage Report'
    ])

    dir('banking-ui') {
        publishHTML([
            allowMissing: true,
            alwaysLinkToLastBuild: true,
            keepAll: true,
            reportDir: 'coverage',
            reportFiles: 'index.html',
            reportName: 'UI Coverage Report'
        ])
    }
}
