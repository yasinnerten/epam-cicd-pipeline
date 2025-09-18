pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "${env.JOB_NAME}:${env.BUILD_NUMBER}"
        PORT = "${env.BRANCH_NAME == 'main' ? '3000' : '3001'}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo "Checking out ${env.BRANCH_NAME} branch"
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                script {
                    echo "Building application for ${env.BRANCH_NAME} branch"
                    sh '''
                        echo "Building application..."
                        # Example: npm install (adjust based on your application)
                        # npm install
                    '''
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    echo "Running tests for ${env.BRANCH_NAME} branch"
                    sh '''
                        echo "Running tests..."
                        # Example: npm test (adjust based on your application)
                        # npm test
                    '''
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image for ${env.BRANCH_NAME} branch on port ${PORT}"
                    sh """
                        docker build -t ${DOCKER_IMAGE} \
                        --build-arg PORT=${PORT} \
                        --build-arg BRANCH=${env.BRANCH_NAME} .
                    """
                }
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    echo "Deploying ${env.BRANCH_NAME} branch on port ${PORT}"
                    
                    // Stop existing container if running
                    sh """
                        docker stop ${env.BRANCH_NAME}-app || true
                        docker rm ${env.BRANCH_NAME}-app || true
                    """
                    
                    // Run new container
                    sh """
                        docker run -d \
                        --name ${env.BRANCH_NAME}-app \
                        -p ${PORT}:${PORT} \
                        ${DOCKER_IMAGE}
                    """
                    
                    echo "Application deployed at http://localhost:${PORT}"
                }
            }
        }
    }
    
    post {
        always {
            echo "Pipeline completed for ${env.BRANCH_NAME} branch"
        }
        success {
            echo "Pipeline succeeded! Application is running on port ${PORT}"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}
