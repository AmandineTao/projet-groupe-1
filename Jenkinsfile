pipeline{
    
     environment{
        IMAGE_NAME = "${BUILD_NAME}"
        IMAGE_TAG = "${BUILD_TAG}"
        CONTAINER_NAME = "${CONTAINER_NAME}"
        DOCKER_ID = "${DOCKER_ID}"
       

    }

    agent any

    stages{
        
        stage ('Build Image'){
            steps{
                script{
                    sh 'docker build -t ${DOCKER_ID}/${IMAGE_NAME}:${IMAGE_TAG} .'
                }
            }
        }

        stage('Test Scan Image') {
            steps {
                echo 'Testing...'
                snykSecurity(
                snykInstallation: 'snyk',
                snykTokenId: 'snyk_token',
                severity: 'high',
                )
            }
        }

        stage ('Run container based on Builded image'){
            steps{
                script{
                    sh '''
                        docker run --name ${CONTAINER_NAME} -d -p ${IMAGE_PORT}:8000 ${DOCKER_ID}/${IMAGE_NAME}:${IMAGE_TAG}
                        sleep 5
                    ''' 
                }
            }
        } 

        stage ('Test Image'){
            steps{
                script{
                    sh '''
                       #curl http://172.17.0.1 | grep -q "Présentation"
                       curl -sL -w '%{http_code}\n' http://172.17.0.1:${IMAGE_PORT} -o /dev/null | grep -q 200
                    '''
                }
            }
        }

        stage('Clean Container') {
            steps {
                script {
                    sh '''
                       docker stop ${CONTAINER_NAME}
                       docker rm ${CONTAINER_NAME}
                    '''
                }
            }
        }

        stage('Push image to Dockerhub') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'docker_pw', variable: 'SECRET')]) {
                        sh '''
                            docker login -u ${DOCKER_ID} -p ${SECRET}
                            docker push ${DOCKER_ID}/${IMAGE_NAME}:${IMAGE_TAG}
                        '''
                    }
                }
            }
        }

    }
}