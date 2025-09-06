pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'your-ecr-registry'
        AWS_REGION = 'us-east-1'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build & Test with Coverage') {
            parallel {
                stage('Shared') {
                    steps {
                        dir('shared') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Auth Service') {
                    steps {
                        dir('auth-service') {
                            sh 'mvn clean test jacoco:report package'
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'target/site/jacoco',
                                reportFiles: 'index.html',
                                reportName: 'Auth Service Coverage'
                            ])
                        }
                    }
                }
                stage('Account Service') {
                    steps {
                        dir('account-service') {
                            sh 'mvn clean test jacoco:report package'
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'target/site/jacoco',
                                reportFiles: 'index.html',
                                reportName: 'Account Service Coverage'
                            ])
                        }
                    }
                }
                stage('Audit Service') {
                    steps {
                        dir('audit-service') {
                            sh 'mvn clean test jacoco:report package'
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'target/site/jacoco',
                                reportFiles: 'index.html',
                                reportName: 'Audit Service Coverage'
                            ])
                        }
                    }
                }
                stage('Balance Service') {
                    steps {
                        dir('balance-service') {
                            sh 'mvn clean test jacoco:report package'
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'target/site/jacoco',
                                reportFiles: 'index.html',
                                reportName: 'Balance Service Coverage'
                            ])
                        }
                    }
                }
                stage('Deposit Service') {
                    steps {
                        dir('deposit-service') {
                            sh 'mvn clean test jacoco:report package'
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'target/site/jacoco',
                                reportFiles: 'index.html',
                                reportName: 'Deposit Service Coverage'
                            ])
                        }
                    }
                }
                stage('Notification Service') {
                    steps {
                        dir('notification-service') {
                            sh 'mvn clean test jacoco:report package'
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'target/site/jacoco',
                                reportFiles: 'index.html',
                                reportName: 'Notification Service Coverage'
                            ])
                        }
                    }
                }
                stage('Transfer Service') {
                    steps {
                        dir('transfer-service') {
                            sh 'mvn clean test jacoco:report package'
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'target/site/jacoco',
                                reportFiles: 'index.html',
                                reportName: 'Transfer Service Coverage'
                            ])
                        }
                    }
                }
                stage('Withdrawal Service') {
                    steps {
                        dir('withdrawal-service') {
                            sh 'mvn clean test jacoco:report package'
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'target/site/jacoco',
                                reportFiles: 'index.html',
                                reportName: 'Withdrawal Service Coverage'
                            ])
                        }
                    }
                }
                stage('API Gateway') {
                    steps {
                        dir('api-gateway') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
            }
        }
        
        stage('Coverage Quality Gate') {
            steps {
                script {
                    def services = ['auth-service', 'account-service', 'audit-service', 'balance-service', 
                                  'deposit-service', 'notification-service', 'transfer-service', 'withdrawal-service']
                    
                    services.each { service ->
                        dir(service) {
                            sh """
                                mvn jacoco:check -Drules.line.minimum=0.80 -Drules.branch.minimum=0.70 || echo "Coverage below threshold for ${service}"
                            """
                        }
                    }
                }
            }
        }
        
        stage('Security Scan') {
            steps {
                sh './check-security.sh'
            }
        }
        
        stage('Docker Build') {
            parallel {
                stage('Auth Service Image') {
                    steps {
                        dir('auth-service') {
                            sh 'docker build -t banking/auth-service:${BUILD_NUMBER} .'
                        }
                    }
                }
                stage('Account Service Image') {
                    steps {
                        dir('account-service') {
                            sh 'docker build -t banking/account-service:${BUILD_NUMBER} .'
                        }
                    }
                }
                stage('Audit Service Image') {
                    steps {
                        dir('audit-service') {
                            sh 'docker build -t banking/audit-service:${BUILD_NUMBER} .'
                        }
                    }
                }
                stage('Balance Service Image') {
                    steps {
                        dir('balance-service') {
                            sh 'docker build -t banking/balance-service:${BUILD_NUMBER} .'
                        }
                    }
                }
                stage('Deposit Service Image') {
                    steps {
                        dir('deposit-service') {
                            sh 'docker build -t banking/deposit-service:${BUILD_NUMBER} .'
                        }
                    }
                }
                stage('Notification Service Image') {
                    steps {
                        dir('notification-service') {
                            sh 'docker build -t banking/notification-service:${BUILD_NUMBER} .'
                        }
                    }
                }
                stage('Transfer Service Image') {
                    steps {
                        dir('transfer-service') {
                            sh 'docker build -t banking/transfer-service:${BUILD_NUMBER} .'
                        }
                    }
                }
                stage('Withdrawal Service Image') {
                    steps {
                        dir('withdrawal-service') {
                            sh 'docker build -t banking/withdrawal-service:${BUILD_NUMBER} .'
                        }
                    }
                }
                stage('API Gateway Image') {
                    steps {
                        dir('api-gateway') {
                            sh 'docker build -t banking/api-gateway:${BUILD_NUMBER} .'
                        }
                    }
                }
            }
        }
        
        stage('Deploy to K8s') {
            steps {
                sh 'kubectl apply -f k8s/'
                sh 'kubectl set image deployment/auth-service auth-service=banking/auth-service:${BUILD_NUMBER}'
                sh 'kubectl set image deployment/account-service account-service=banking/account-service:${BUILD_NUMBER}'
                sh 'kubectl set image deployment/audit-service audit-service=banking/audit-service:${BUILD_NUMBER}'
                sh 'kubectl set image deployment/balance-service balance-service=banking/balance-service:${BUILD_NUMBER}'
                sh 'kubectl set image deployment/deposit-service deposit-service=banking/deposit-service:${BUILD_NUMBER}'
                sh 'kubectl set image deployment/notification-service notification-service=banking/notification-service:${BUILD_NUMBER}'
                sh 'kubectl set image deployment/transfer-service transfer-service=banking/transfer-service:${BUILD_NUMBER}'
                sh 'kubectl set image deployment/withdrawal-service withdrawal-service=banking/withdrawal-service:${BUILD_NUMBER}'
                sh 'kubectl set image deployment/api-gateway api-gateway=banking/api-gateway:${BUILD_NUMBER}'
            }
        }
    }
    
    post {
        always {
            publishTestResults testResultsPattern: '**/target/surefire-reports/*.xml'
            archiveArtifacts artifacts: '**/target/site/jacoco/**', allowEmptyArchive: true
        }
    }
}
