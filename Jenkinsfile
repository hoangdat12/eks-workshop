pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = "ap-southeast-1"

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
                    checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'github-crd', url: 'https://github.com/hoangdat12/eks-workshop.git']])
                }
            }
        }
        
        stage("Git Checkout") {
            steps {
                git branch: 'main', credentialsId: 'gtihub-crd', url: 'https://github.com/hoangdat12/eks-workshop'
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

         stage('Deploying Application To EKS') {
            steps{
                script{
                    // Config EKS
                    dir("kubernetes") {
                      
                        sh "kubectl apply -f api-gateway/Deployment.yaml"  sh "kubectl apply -f api-gateway/Deployment.yaml -f auth-api/Deployment.yaml -f user-api/Deployment.yaml"
                        sh "kubectl apply -f api-gateway/Service.yaml -f auth-api/Service.yaml -f user-api/Service.yaml"
                        sh "kubectl apply -f api-gateway/Service.yaml"
                    }
                }
            }
        }
    } 
}