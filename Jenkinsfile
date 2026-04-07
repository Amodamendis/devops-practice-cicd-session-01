pipeline{
    agent any
    environment {
       DOCKER_IMAGE_NAME = "amodamendis/app"
    }
    stages {
        stage('Build') {
            steps {
                echo 'Running build automation'
                sh './gradlew build --no-daemon'
            }
        }
        stage(Build Docker Image) {
            when{
                branch 'main'
            }
            steps{
                script{
                    app = docker.build(DOCKER_IMAGE_NAME)
                    app.inside {
                        sh 'echo Hello,World'

                    }
                }
            }
        }
        stage('Push Docker Image') {
            when {
                branch 'main'
            }
            steps {
                script {
                    docker.withRegistery('https://registry.hub.docker.com','docker-access-id'){
                       app.push("${env.BUILD_NUMBER}")
                       app.push("latest")
                    }
                }
            }
        }
        stage('Deploy to production')
            when {
                branch 'main'
            }
            steps {
                input 'Deploy to Production?'
                milestone(1)
                kubernetesDeploy(
                    kubeconfigID: 'k8s-kubeconfig',
                    configs: 'my-app-deploy.yaml',
                    enableConfigSubstitution: true
                )
            }

        
    }

}