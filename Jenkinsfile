def remote = [:]
pipeline {
    environment { 
	        registry = "captainbelal/udacity_capstone" 
	        registryCredential = 'Docker'
            registryToken = credentials('token') 
	        dockerImage = ''
            key = credentials('key') 
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
        stage('CloudFormation Create or Update'){
            steps {
                withAWS(region:'us-west-2',credentials:'aws-static') {
                    sh 'echo "Create CF Stack"'
                    sh '''
                        echo "\nChecking if stack exists ..."
                        if ! aws cloudformation describe-stacks --stack-name udacity-capstone ; then
                            echo -e "\nStack does not exist, creating ..."
                            aws cloudformation create-stack --stack-name udacity-capstone --template-body file://project.yml  --parameters file://project-parameters.json
                            echo "\nWaiting for stack to be created ..."
                            aws cloudformation wait stack-create-complete --stack-name udacity-capstone
                        else
                            echo -e "\nStack exists, attempting update ..."                    
                            set +e
                            update_output=$( aws cloudformation update-stack --stack-name udacity-capstone --template-body file://project.yml  --parameters file://project-parameters.json  2>&1)
                            status=$?
                            set -e                        
                            if [ $status -ne 0 ] ; then
                                echo -e "\nFinished create/update - no updates to be performed"
                            else
                                echo "\nWaiting for stack update to complete ..."
                                aws cloudformation wait stack-update-complete --stack-name udacity-capstone
                            fi                            
                        fi
                    '''
                }
            }
        }
        stage('Get EC2 IP'){
            steps {
                withAWS(region:'us-west-2',credentials:'aws-static') {
                    sh ''' 
                        EC2IP=$( aws ec2 describe-instances --filters "Name=tag-value,Values=KubernatesInstance" --query Reservations[*].Instances[*].[PublicIpAddress] --output text )
                        echo $EC2IP > /tmp/ec2ip.txt
                    '''
                }
            }
        }
        stage('Deploy to EC2'){
            steps{
                remote.name = "kubernates"
                remote.host = "35.166.218.78"
                remote.allowAnyHosts = true
                withCredentials([key(credentialsId: 'sshUser', keyFileVariable: 'identity', passphraseVariable: '', usernameVariable: 'userName')]) {
                    remote.user = userName
                    remote.identityFile = identity
                    sshCommand remote: remote, command: 'echo "Hello"'
                sh '''
                    EC2IP=$(cat /tmp/ec2ip.txt)
                    ssh -vvv -i $key -o StrictHostKeyChecking=no -T ubuntu@$EC2IP;
                    minikube start
                    kubectl create deployment udacity-capstone --image=$registry:$BUILD_NUMBER
                    kubectl port-forward deployment/udacity-capstone --address 0.0.0.0 80:80&
                '''
                }   
            }
        }        
    }      
}