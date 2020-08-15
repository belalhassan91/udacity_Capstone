pipeline {
    environment { 
	        registry = "captainbelal/udacity_capstone" 
	        registryCredential = 'Docker'
            registryToken = credentials('token') 
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
                sh("docker login --username captainbelal -p $registryToken")
                sh "docker push $registry:$BUILD_NUMBER"
            }
        }
        stage('Clean UP Docker Image from machine'){
            steps { 
                sh "docker rmi $registry:$BUILD_NUMBER" 
            }
        }
        stage('Upload to AWS'){
            steps {
                withAWS(region:'us-west-2',credentials:'aws-static') {
                    sh 'echo "Create CF Stack"'
                    sh 'aws iam get-user'
                    sh 'aws cloudformation create-stack --stack-name udacity-capstone --template-body file://project.yml  --parameters file://project-parameters.json'
                }
            }
        }        
    }      
}