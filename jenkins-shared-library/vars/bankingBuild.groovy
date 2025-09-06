def buildServices(services) {
    echo "🔨 Building Backend Services: ${services.join(', ')}"

    sh '''
        echo "Installing dependencies..."
        mvn clean compile -DskipTests -T 4

        echo "Running tests..."
        if [ "$SKIP_TESTS" != "true" ]; then
            mvn test -T 4 -Dmaven.test.failure.ignore=true
            publishTestResults testResultsPattern: '**/target/surefire-reports/*.xml'
        fi

        echo "Packaging applications..."
        mvn package -DskipTests -T 4
    '''

    services.each { service ->
        if (service && service.trim()) {
            echo "✅ Built service: ${service}"
        }
    }
}

def buildUI() {
    echo "🎨 Building Frontend UI"

    dir('banking-ui') {
        sh '''
            echo "Setting up Node.js environment..."
            node --version
            npm --version

            echo "Installing UI dependencies..."
            npm ci --prefer-offline --no-audit

            echo "Running UI linting..."
            npm run lint || true

            echo "Running UI tests..."
            if [ "$SKIP_TESTS" != "true" ]; then
                npm run test:unit || true
            fi

            echo "Building UI for production..."
            npm run build

            echo "UI build artifacts:"
            ls -la dist/
        '''
    }

    echo "✅ UI build completed successfully"
}

def buildOptimized() {
    echo "🚀 Running optimized build process"

    parallel(
        'Backend': {
            buildServices(['auth-service', 'account-service', 'payment-service', 'api-gateway'])
        },
        'Frontend': {
            buildUI()
        }
    )
}

def publishArtifacts() {
    echo "📦 Publishing build artifacts"

    sh '''
        find . -name "*.jar" -path "*/target/*" | while read jar; do
            echo "Publishing: $jar"
            mvn deploy:deploy-file \
                -DgroupId=com.banking \
                -DartifactId=$(basename $(dirname $(dirname $jar))) \
                -Dversion=${BUILD_NUMBER} \
                -Dpackaging=jar \
                -Dfile=$jar \
                -DrepositoryId=nexus \
                -Durl=${NEXUS_URL}/repository/${NEXUS_REPO}/
        done
    '''

    dir('banking-ui') {
        sh '''
            if [ -d "dist" ]; then
                echo "Creating UI artifact..."
                tar -czf banking-ui-${BUILD_NUMBER}.tar.gz -C dist .

                echo "Publishing UI artifact..."
                curl -v -u admin:admin123 \
                    --upload-file banking-ui-${BUILD_NUMBER}.tar.gz \
                    ${NEXUS_URL}/repository/banking-ui-repo/banking-ui-${BUILD_NUMBER}.tar.gz
            fi
        '''
    }
}
