pipeline {
    environment { 
	        registry = "captainbelal/udacity_capstone" 
	        registryCredential = 'Docker' 
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
                script{
                    docker.withRegistery( '', registryCredential ) { 
                        dockerImage.push() 
                    }
                }
            }
        }
        stage('Clean UP'){
            steps { 
                sh "docker rmi $registry:$BUILD_NUMBER" 
            }
        }        
    }      
}