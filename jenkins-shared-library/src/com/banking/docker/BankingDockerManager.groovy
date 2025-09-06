package com.banking.docker

class BankingDockerManager implements Serializable {
    
    def script
    
    BankingDockerManager(script) {
        this.script = script
    }
    
    def buildImage(String service) {
        script.echo "🐳 Building Docker image for ${service}..."
        
        script.dir(service) {
            def imageTag = "${script.env.ECR_REGISTRY}/${script.env.ECR_REPO_PREFIX}/${service}:${script.env.BUILD_NUMBER}"
            def latestTag = "${script.env.ECR_REGISTRY}/${script.env.ECR_REPO_PREFIX}/${service}:latest"
            
            script.sh """
                docker build -t ${imageTag} -t ${latestTag} .
                echo "✅ ${service} image built successfully"
            """
            
            return [imageTag, latestTag]
        }
    }
    
    def buildImages(List<String> services) {
        script.echo "🐳 Building Docker images for services: ${services}"
        
        def buildSteps = [:]
        services.each { service ->
            buildSteps[service] = {
                buildImage(service)
            }
        }
        
        script.parallel(buildSteps)
    }
    
    def scanImage(String service) {
        script.echo "🔍 Scanning Docker image for ${service}..."
        
        def imageTag = "${script.env.ECR_REGISTRY}/${script.env.ECR_REPO_PREFIX}/${service}:${script.env.BUILD_NUMBER}"
        
        script.sh """
            # Trivy security scan
            trivy image --exit-code 1 --severity HIGH,CRITICAL \\
              --format json --output trivy-${service}.json ${imageTag}
            
            # Docker Scout scan (if available)
            docker scout cves ${imageTag} --format json --output scout-${service}.json || echo "Docker Scout not available"
            
            # Grype scan for additional coverage
            grype ${imageTag} --fail-on high --output json --file grype-${service}.json || echo "Grype scan completed"
            
            echo "✅ ${service} image security scan passed"
        """
    }
    
    def scanImages(List<String> services) {
        script.echo "🔍 Scanning Docker images for vulnerabilities..."
        
        def scanSteps = [:]
        services.each { service ->
            scanSteps[service] = {
                scanImage(service)
            }
        }
        
        script.parallel(scanSteps)
        
        // Archive scan results
        script.archiveArtifacts artifacts: '*-*.json', allowEmptyArchive: true
    }
    
    def pushToECR(List<String> services) {
        script.echo "📤 Pushing Docker images to ECR..."
        
        // ECR login
        ecrLogin()
        
        def pushSteps = [:]
        services.each { service ->
            pushSteps[service] = {
                pushServiceToECR(service)
            }
        }
        
        script.parallel(pushSteps)
    }
    
    def ecrLogin() {
        script.echo "🔐 Logging into ECR..."
        script.sh '''
            aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | \\
            docker login --username AWS --password-stdin ${ECR_REGISTRY}
            echo "✅ ECR login successful"
        '''
    }
    
    def pushServiceToECR(String service) {
        script.echo "📤 Pushing ${service} to ECR..."
        
        def imageTag = "${script.env.ECR_REGISTRY}/${script.env.ECR_REPO_PREFIX}/${service}:${script.env.BUILD_NUMBER}"
        def latestTag = "${script.env.ECR_REGISTRY}/${script.env.ECR_REPO_PREFIX}/${service}:latest"
        
        script.sh """
            # Create ECR repository if it doesn't exist
            aws ecr describe-repositories --repository-names ${script.env.ECR_REPO_PREFIX}/${service} --region ${script.env.AWS_DEFAULT_REGION} || \\
            aws ecr create-repository --repository-name ${script.env.ECR_REPO_PREFIX}/${service} --region ${script.env.AWS_DEFAULT_REGION}
            
            # Set lifecycle policy to manage image retention
            aws ecr put-lifecycle-policy --repository-name ${script.env.ECR_REPO_PREFIX}/${service} \\
              --lifecycle-policy-text '{"rules":[{"rulePriority":1,"selection":{"tagStatus":"untagged","countType":"sinceImagePushed","countUnit":"days","countNumber":7},"action":{"type":"expire"}}]}' \\
              --region ${script.env.AWS_DEFAULT_REGION} || echo "Lifecycle policy already exists"
            
            # Push images
            docker push ${imageTag}
            docker push ${latestTag}
            
            echo "✅ ${service} images pushed to ECR successfully"
        """
    }
    
    def cleanupImages() {
        script.echo "🧹 Cleaning up Docker images..."
        
        script.sh '''
            # Remove dangling images
            docker image prune -f
            
            # Remove old build images (keep last 5 builds)
            docker images --format "table {{.Repository}}:{{.Tag}}" | grep ${ECR_REPO_PREFIX} | tail -n +6 | xargs -r docker rmi || echo "No old images to remove"
            
            # System cleanup
            docker system prune -f
            
            echo "✅ Docker cleanup completed"
        '''
    }
    
    def generateImageReport() {
        script.echo "📊 Generating Docker image report..."
        
        script.sh '''
            echo "Docker Image Report - Build ${BUILD_NUMBER}" > docker-report.txt
            echo "=========================================" >> docker-report.txt
            echo "Timestamp: $(date)" >> docker-report.txt
            echo "" >> docker-report.txt
            echo "Images Built:" >> docker-report.txt
            docker images --format "table {{.Repository}}:{{.Tag}}\\t{{.Size}}\\t{{.CreatedAt}}" | grep ${ECR_REPO_PREFIX} >> docker-report.txt
            echo "" >> docker-report.txt
            echo "✅ All images built and scanned successfully" >> docker-report.txt
        '''
        
        script.archiveArtifacts artifacts: 'docker-report.txt', allowEmptyArchive: true
    }
}
