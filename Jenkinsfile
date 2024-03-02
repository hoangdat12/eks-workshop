pipeline {
    agent any

    environment {
        USER_APP_NAME = "user-api"
        AUTH_APP_NAME = "auth-api"
        GATEWAY_APP_NAME = "api-gateway"
        RELEASE = "1.0.0"
        DOCKER_USER = "hoangdat12"
        DOCKER_PASS = "docker-crd"
        USER_IMAGE = "${DOCKER_USER}/${USER_APP_NAME}"
        AUTH_IMAGE = "${DOCKER_USER}/${AUTH_APP_NAME}"
        GATEWAY_IMAGE = "${DOCKER_USER}/${GATEWAY_APP_NAME}"
        IMAGE_TAG = "${RELEASE}-${BUILD_NUMBER}"
    }

    stages {
        stage("Checkout SCM") {
            steps {
                script {
                    checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/hoangdat12/eks-workshop.git']])
                }
            }
        }
        
        stage("Git Checkout") {
            steps {
                git branch: 'main', credentialsId: 'jenkins-git', url: 'https://github.com/hoangdat12/eks-workshop'
            }
        }
        
        stage("Build & Deploy Docker Image") {
            steps {
                script {
    
                    // Authenticate with Docker registry
                    withCredentials([usernamePassword(credentialsId: 'docker-crd', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                        // Build and push Docker image
                        sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
    
                        // Build and push Docker image
                        sh "docker build -t ${USER_IMAGE}:${IMAGE_TAG} -f users-api/Dockerfile users-api"
                        sh "docker push ${USER_IMAGE}:${IMAGE_TAG}"
                            
                        sh "docker build -t ${AUTH_IMAGE}:${IMAGE_TAG} -f auth-api/Dockerfile auth-api"
                        sh "docker push ${AUTH_IMAGE}:${IMAGE_TAG}"
                            
                        sh "docker build -t ${GATEWAY_IMAGE}:${IMAGE_TAG} -f api-gateway/Dockerfile api-gateway"
                        sh "docker push ${GATEWAY_IMAGE}:${IMAGE_TAG}"
                    }
                }
            }
        }
    } 
}