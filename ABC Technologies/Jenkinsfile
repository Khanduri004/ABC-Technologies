pipeline{
    agent any

    environment {
        DOCKER_IMAGE = "shreya004/abc_technologies:latest"
        GIT_URL = "https://github.com/Khanduri004/ABC-Technologies.git"
         }

    stages{

        stage('Clean Workspace'){
            steps{
                cleanWs()
            }
        }

        stage('Clone Repository'){
            steps{
                git branch: 'main', url: "${GIT_URL}" 
            }
        }

        stage('Build Docker Image'){
            steps{
                sh 'docker build -t $DOCKER_IMAGE .'
            }
         }

          stage('Push Docker Image to Docker Hub'){
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) 
                {
                    sh '''
                        echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin
                        docker push ${DOCKER_IMAGE} 
                    '''
                }
            }
          }
          stage('Code Coverage Report') {
            steps {
                publishHTML(target: [
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'target/site/jacoco',
                    reportFiles: 'index.html',
                    reportName: 'Code Coverage Report'
                ])
            }
        }
             stage('Deploy to Kubernetes (Placeholder)') {
            steps {
                echo 'Will add Kubernetes deployment steps later...'
            }
        }

        success {
            emailext(
                subject: "✅ SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: "The build completed successfully.\nCheck it here: ${env.BUILD_URL}",
                recipientProviders: [[$class: 'DevelopersRecipientProvider']]
            )
            slackSend(channel: '#builds', color: 'good', message: "✅ *SUCCESS:* Job ${env.JOB_NAME} #${env.BUILD_NUMBER}")
        }

        failure {
            emailext(
                subject: "❌ FAILURE: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: "The build failed.\nCheck it here: ${env.BUILD_URL}",
                recipientProviders: [[$class: 'DevelopersRecipientProvider']]
            )
            slackSend(channel: '#builds', color: 'danger', message: "❌ *FAILURE:* Job ${env.JOB_NAME} #${env.BUILD_NUMBER}")
        }

        always {
            cleanWs()
        }
    }
}     
