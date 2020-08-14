pipeline {
    environment { 
	        registry = "captainbelal/udacity_capstone" 
	        registryCredential = 'Docker'
            registryToken = 'token' 
	        dockerImage = '' 
	}
    agent any
    stages {
        stage('Linting HTML'){
            steps {
                sh 'echo "Linting HTML"'
                sh 'tidy -q -e *.html'
            }
        }
        stage('Linting DockerFile') { 
            steps { 
                sh 'hadolint Dockerfile' 
            }
        }
        stage('Build Docker Image') { 
            steps { 
                script{
                    dockerImage = docker.build registry+":$BUILD_NUMBER"
                }
            }
        }
        stage('Push Docker Image to Docker Hub'){
            steps{
                sh "$registryToken | docker login --username captainbelal --password-stdin"
                sh "docker push $registry:$BUILD_NUMBER"
            }
        }
        stage('Clean UP'){
            steps { 
                sh "docker rmi $registry:$BUILD_NUMBER" 
            }
        }        
    }      
}