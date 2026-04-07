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
                branch 'main'
            }
            steps {
                // Pause and wait for manual approval
                input 'Deploy to Production?'
                milestone(1)

                // Use withKubeConfig instead of kubernetesDeploy
                withKubeConfig([credentialsId: 'k8s-kubeconfig']) {
                    // Replace variables in yaml and apply to Kubernetes
                    sh """
                        # Create temp yaml with actual values substituted
                        cp my-app-deploy.yaml my-app-deploy-temp.yaml
                        sed -i 's|\$DOCKER_IMAGE_NAME|${DOCKER_IMAGE_NAME}|g' my-app-deploy-temp.yaml
                        sed -i 's|\$BUILD_NUMBER|${BUILD_NUMBER}|g' my-app-deploy-temp.yaml

                        # Verify — should show: amodamendis/app:5
                        echo "Image being deployed:"
                        grep image my-app-deploy-temp.yaml

                        # Apply to kubernetes
                        kubectl apply -f my-app-deploy-temp.yaml
                        rm my-app-deploy-temp.yaml
                    """
                }
            }
        }



    }
}