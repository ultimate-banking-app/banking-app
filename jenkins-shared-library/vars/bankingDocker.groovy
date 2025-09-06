def buildAndPushServices(services) {
    echo "🐳 Building and pushing backend service images"

    services.each { service ->
        if (service && service.trim()) {
            dir(service) {
                sh """
                    echo "Building Docker image for ${service}..."
                    docker build -t ${ECR_REGISTRY}/${ECR_REPO_PREFIX}-${service}:${BUILD_NUMBER} .
                    docker tag ${ECR_REGISTRY}/${ECR_REPO_PREFIX}-${service}:${BUILD_NUMBER} ${ECR_REGISTRY}/${ECR_REPO_PREFIX}-${service}:latest

                    echo "Pushing ${service} image to ECR..."
                    docker push ${ECR_REGISTRY}/${ECR_REPO_PREFIX}-${service}:${BUILD_NUMBER}
                    docker push ${ECR_REGISTRY}/${ECR_REPO_PREFIX}-${service}:latest
                """
            }
        }
    }
}

def buildAndPushUI() {
    echo "🎨 Building and pushing UI image"

    dir('banking-ui') {
        sh '''
            echo "Creating UI Dockerfile..."
            cat > Dockerfile << 'EOF'
FROM nginx:alpine

COPY dist/ /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \\
    CMD curl -f http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
EOF

            echo "Creating nginx configuration..."
            cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    sendfile        on;
    keepalive_timeout  65;

    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    server {
        listen       80;
        server_name  localhost;

        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
            try_files $uri $uri/ /index.html;
        }

        location /api/ {
            proxy_pass http://api-gateway:8090/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/share/nginx/html;
        }
    }
}
EOF

            echo "Building UI Docker image..."
            docker build -t ${ECR_REGISTRY}/${ECR_REPO_PREFIX}-ui:${BUILD_NUMBER} .
            docker tag ${ECR_REGISTRY}/${ECR_REPO_PREFIX}-ui:${BUILD_NUMBER} ${ECR_REGISTRY}/${ECR_REPO_PREFIX}-ui:latest

            echo "Pushing UI image to ECR..."
            docker push ${ECR_REGISTRY}/${ECR_REPO_PREFIX}-ui:${BUILD_NUMBER}
            docker push ${ECR_REGISTRY}/${ECR_REPO_PREFIX}-ui:latest
        '''
    }
}

def scanImages() {
    echo "🔍 Scanning Docker images for vulnerabilities"

    sh '''
        echo "Scanning backend images..."
        for service in auth-service account-service payment-service api-gateway; do
            if docker images | grep -q "${ECR_REGISTRY}/${ECR_REPO_PREFIX}-${service}:${BUILD_NUMBER}"; then
                echo "Scanning ${service} image..."
                trivy image --exit-code 0 --severity HIGH,CRITICAL --format json --output ${service}-scan.json ${ECR_REGISTRY}/${ECR_REPO_PREFIX}-${service}:${BUILD_NUMBER} || true
            fi
        done

        echo "Scanning UI image..."
        if docker images | grep -q "${ECR_REGISTRY}/${ECR_REPO_PREFIX}-ui:${BUILD_NUMBER}"; then
            trivy image --exit-code 0 --severity HIGH,CRITICAL --format json --output ui-scan.json ${ECR_REGISTRY}/${ECR_REPO_PREFIX}-ui:${BUILD_NUMBER} || true
        fi
    '''

    archiveArtifacts artifacts: '*-scan.json', allowEmptyArchive: true
}

def cleanupImages() {
    echo "🧹 Cleaning up local Docker images"

    sh '''
        echo "Removing local images..."
        docker images | grep "${ECR_REGISTRY}/${ECR_REPO_PREFIX}" | awk '{print $3}' | xargs -r docker rmi -f || true

        echo "Pruning unused images..."
        docker image prune -f || true
    '''
}
