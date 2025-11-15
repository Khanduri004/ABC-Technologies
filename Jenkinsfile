pipeline {
    agent any
    tools {
        maven 'maven3'
        jdk 'JDK17'
    }

    environment {
        DOCKER_IMAGE = "shreya004/abc_technologies:latest"
        GIT_URL = "https://github.com/Khanduri004/ABC-Technologies.git"
        K8S_NAMESPACE = "abc-technologies"
    }

    stages {

        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Clone Repository') {
            steps {
                git branch: 'main', url: "${GIT_URL}"
            }
        }

        stage('Code Coverage Report') {
            steps {
                sh 'mvn clean test jacoco:report'
                publishHTML(target: [
                    allowMissing: true,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'target/site/jacoco',
                    reportFiles: 'index.html',
                    reportName: 'Code Coverage Report'
                ])
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

       stage('Push Docker Image to Docker Hub') {
          steps {
             withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
               sh """
                 docker --version
                 echo "Logging in to Docker Hub..."
                 echo "User: $DOCKERHUB_USER"

                 echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin

                 docker push $DOCKER_IMAGE
            """
        }
    }
}

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                    # Update kubeconfig
                    aws eks update-kubeconfig --name my-cluster --region eu-west-1
                    
                       # Create namespace if doesn't exist
                        kubectl get namespace ${K8S_NAMESPACE} || kubectl create namespace ${K8S_NAMESPACE}
                        
                        # Update image in deployment
                        sed -i 's|image: ${DOCKER_IMAGE}:.*|image: ${DOCKER_IMAGE}:${DOCKER_TAG}|g' kubernetes/deployment.yml
                        
                        # Apply manifests in correct order
                        echo "📦 Applying Kubernetes manifests..."
                        
                        kubectl apply -f kubernetes/namespace.yml || true
                        kubectl apply -f kubernetes/persistent_volume.yml
                        kubectl apply -f kubernetes/persistent_volume_claim.yml
                        kubectl apply -f kubernetes/deployment.yml
                        kubectl apply -f kubernetes/service.yml
                        kubectl apply -f kubernetes/hpa.yml
                        kubectl apply -f kubernetes/ingress.yml
                        kubectl apply -f kubernetes/cron_job.yml
                        
                        # Try to apply service monitor (skip if Prometheus not installed)
                        kubectl apply -f kubernetes/service_monitor.yml || echo "⚠️  ServiceMonitor skipped (Prometheus Operator not installed)"
                        
                        # Wait for rollout
                        kubectl rollout status deployment/abc-technologies -n ${K8S_NAMESPACE}
                        
                        # Show status
                        kubectl get pods -n ${K8S_NAMESPACE}
                    """
                }
                """
            }
        }
    }
     post {
        success {
          echo "✅ Deployment successful! Image: ${DOCKER_IMAGE}:${DOCKER_TAG}"
           emailext (
            subject: "✅ SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
            body: """
                <html>
                <body>
                  <p>Deployment successful!</p>
                  <p>Job: ${env.JOB_NAME}</p>
                  <p>Build Number: ${env.BUILD_NUMBER}</p>
                  <p>Docker Image: ${DOCKER_IMAGE}:${DOCKER_TAG}</p>
                  <p>Check console output at: ${env.BUILD_URL}</p>
               </body>
               </html>
             """,
             to: 'your-email@example.com',
             mimeType: 'text/html'
          )
       }
      failure {
        echo "❌ Deployment failed!"
        emailext (
            subject: "❌ FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
            body: """
                <html>
                <body>   
                <p>Deployment failed!</p>
                <p>Job: ${env.JOB_NAME}</p>
                <p>Build Number: ${env.BUILD_NUMBER}</p>
                <p>Check console output at: ${env.BUILD_URL}</p>
            </body>
            </html>
            """,
            to: 'your-email@example.com',
            mimeType: 'text/html'
        )
     }
   }
        always {
            cleanWs()
        }
    }
}
