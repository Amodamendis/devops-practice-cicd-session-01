pipeline {
    agent any

    environment {
        // Define Docker image name as environment variable 
        DOCKER_IMAGE_NAME = "amodamendis/app"
    }

    stages {
        // STAGE 1: Build the React app
        stage('Build') {
            steps {
                echo 'Running build automation'
                // Install all npm packages (--legacy-peer-deps avoids version conflicts)
                // Use full path to npm
                sh '''
                    export PATH=$PATH:/usr/bin
                    npm install --legacy-peer-deps
                    npm run build
                '''
            }
        }
        // STAGE 2: Build Docker Image
        stage('Build Docker Image') {
            when {
                // Only run this stage when code is pushed to 'main' branch
                branch 'main'
            }
            steps {
                script {
                    // Build Docker image using Dockerfile in current directory
                    // Tags it as "amodamendis/app"
                    app = docker.build(DOCKER_IMAGE_NAME)
                    // Run a quick test inside the container to verify it works
                    app.inside {
                        sh 'echo Hello, World'
                    }
                }
            }
        }
        // STAGE 3: Push Docker Image to Docker Hub
        stage('Push Docker Image') {
            when {
                // Only push when on 'main' branch
                branch 'main'
            }
            steps {
                script {
                    // Login to Docker Hub using Jenkins credentials (id: docker-access-id)
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-access-id') {
                        // Push image with build number tag e.g. amodamendis/app:42
                        app.push("${env.BUILD_NUMBER}")
                        // Also push as 'latest' so it's always the most recent
                        app.push("latest")
                    }
                }
            }
        }
        // STAGE 4: Deploy to Kubernetes
        stage('Deploy to Production') {
            when {
                // Only deploy when on 'main' branch
                branch 'main'
            }
            steps {
                // Pause pipeline and wait for manual approval before deploying
                input 'Deploy to Production?'

                // Prevent older builds from deploying AFTER a newer build
                milestone(1)

                // Deploy to Kubernetes using the kubeconfig credential stored in Jenkins
                // kubeconfigId    → Jenkins credential ID that holds ~/.kube/config file
                // configs         → The Kubernetes YAML file to apply
                // enableConfigSubstitution → Replaces $DOCKER_IMAGE_NAME and $BUILD_NUMBER in yaml
                kubernetesDeploy(
                    kubeconfigId: 'k8s-kubeconfig',
                    configs: 'my-app-deploy.yaml',
                    enableConfigSubstitution: true
                )
            }
        }

    }
}