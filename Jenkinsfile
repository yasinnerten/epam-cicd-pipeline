pipeline {
    agent any
    
    parameters {
        choice(
            name: 'BRANCH',
            choices: ['main', 'dev'],
            description: 'Select branch to deploy'
        )
        choice(
            name: 'ACTION',
            choices: ['deploy', 'stop', 'restart'],
            description: 'Select deployment action'
        )
    }
    
    environment {
        PORT = "${params.BRANCH == 'main' ? '3000' : '3001'}"
        REPO_URL = 'https://github.com/yasinnerten/epam-cicd-pipeline.git'
    }
    
    stages {
        stage('Checkout') {
            steps {
                script {
                    echo "Manually deploying ${params.BRANCH} branch"
                    git branch: "${params.BRANCH}", url: "${REPO_URL}"
                }
            }
        }
        
        stage('Pre-Build Cleanup') {
            steps {
                script {
                    echo "🧹 Pre-build cleanup for ${env.BRANCH_NAME} branch"
                    sh """
                        # Kill any processes using the target port
                        sudo lsof -ti:${PORT} | xargs -r kill -9 || true
                        
                        # Clean up old containers and images
                        docker container prune -f
                        docker image prune -f
                        
                        # Stop containers that might conflict
                        docker ps -q --filter "publish=${PORT}" | xargs -r docker stop || true
                        docker ps -aq --filter "publish=${PORT}" | xargs -r docker rm || true
                    """
                }
            }
        }

        stage('Build Docker Image') {
            when {
                expression { params.ACTION == 'deploy' || params.ACTION == 'restart' }
            }
            steps {
                script {
                    sh """
                        docker build -t manual-${params.BRANCH}:latest \
                        --build-arg PORT=${PORT} \
                        --build-arg BRANCH=${params.BRANCH} .
                    """
                }
            }
        }
        
        stage('Stop Existing') {
            when {
                expression { params.ACTION == 'stop' || params.ACTION == 'restart' || params.ACTION == 'deploy' }
            }
            steps {
                script {
                    sh """
                        docker stop manual-${params.BRANCH}-app || true
                        docker rm manual-${params.BRANCH}-app || true
                    """
                }
            }
        }
        
        stage('Deploy') {
            when {
                expression { params.ACTION == 'deploy' || params.ACTION == 'restart' }
            }
            steps {
                script {
                    sh """
                        docker run -d \
                        --name manual-${params.BRANCH}-app \
                        -p ${PORT}:${PORT} \
                        manual-${params.BRANCH}:latest
                    """
                    
                    echo "Manual deployment completed!"
                    echo "Application is running at http://localhost:${PORT}"
                }
            }
        }
    }
    
    post {
        success {
            echo "Manual deployment action '${params.ACTION}' completed successfully for ${params.BRANCH} branch"
        }
        failure {
            echo "Manual deployment failed!"
        }
    }
}
