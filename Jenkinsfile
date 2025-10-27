pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "shreya004/abc_technologies:latest"
        GIT_URL = "https://github.com/Khanduri004/ABC-Technologies.git"
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
              reportName: 'Code Coverage Report'])
            }
         }
        
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                    sh '''
                        echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin
                        docker push $DOCKER_IMAGE
                    '''
                }
            }
        }
    
        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl set image deployment/abc-technologies abc-technologies=${DOCKERHUB_REPO}:latest -n abc-technologies'     
               }
            }
        }
    
     post {
        success {
            emailext(
                subject: "✅ SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: "The build completed successfully.\nCheck it here: ${env.BUILD_URL}",
                recipientProviders: [[$class: 'DevelopersRecipientProvider']]
            )
        }

        failure {
            emailext(
                subject: "❌ FAILURE: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: "The build failed.\nCheck it here: ${env.BUILD_URL}",
                recipientProviders: [[$class: 'DevelopersRecipientProvider']]
            )
        }

        always {
            cleanWs()
         }
      }  
     
    }

}




