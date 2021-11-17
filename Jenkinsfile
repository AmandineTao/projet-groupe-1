pipeline{
<<<<<<< HEAD
     environment {
       IMAGE_NAME = "diranenodejs"
       IMAGE_TAG = "latest"
	     DOCKER_USER = "pintade"
       IMAGE_PORT = 8000
     }
    agent any
    stages {
        stage("Build Docker image"){
			agent any
            steps {
                sh """
                    docker build -t ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG} .
                """
            }
        }

    stage('Scan with Snyk') {
      steps {
        echo 'Testing...'
        snykSecurity(
          snykInstallation: 'Snyk',
          snykTokenId: 'snyk_token',
          severity: 'high',
        )
      }
    }

    stage("Run docker image"){
			agent any
            steps{
                sh """
                    docker run --name $IMAGE_NAME -d -p ${IMAGE_PORT}:8000 ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }
		
	stage('Test curl on localhost') {
           agent any
           steps {
              script {
                sh '''
                    sleep 10
                    curl -sL -w '%{http_code}\n' http://172.17.0.1:${IMAGE_PORT} -o /dev/null | grep -q 200
                '''
              }
           }
		   }
		
	stage('Clean Container') {
          agent any
          steps {
             script {
               sh '''
                 docker stop $IMAGE_NAME
                 docker rm $IMAGE_NAME
               '''
             }
          }
     }
	 
	 stage('Push image on docker') {
        agent any
         steps {
           script {
            withCredentials([string(credentialsId: 'docker_pw', variable: 'SECRET')]) {
              sh '''
                docker login -u ${DOCKER_USER} -p ${SECRET}
                docker image push ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}
              '''
            }
			}
        }
     }

  stage('Ansible dev') {
    agent any
    steps {
      withCredentials([file(credentialsId: 'pass_playbook_nodejs', variable: 'SECRET')]) {
        ansiColor('xterm') {
          ansiblePlaybook( 
              playbook: 'ansible/deploy.yml',
              inventory: 'ansible/hosts.yml',
              colorized: true,
              extras: "--vault-password-file ${SECRET}",
              extraVars: [
                namespace_default: 'dev',
                nodeport_default: 30009,
                node_Name: 'node2'
          ]) 
        }
      }
    }
  }

	stage('Test curl on node dev') {
           agent any
           steps {
              script {
                sh '''
                    sleep 20
                    curl -sL -w '%{http_code}\n' http://192.168.99.11:30009 -o /dev/null | grep -q 200
                '''
              }
           }
		   }

  stage("Run Jmeter") {
    agent any
    steps {
      bzt "./jmeter/plan.jmx"
      perfReport 'result.csv'
    }
  }

  stage('Ansible prod') {
    agent any
    steps {
      withCredentials([file(credentialsId: 'pass_playbook_nodejs', variable: 'SECRET')]) {
        ansiColor('xterm') {
          ansiblePlaybook( 
              playbook: 'ansible/deploy.yml',
              inventory: 'ansible/hosts.yml',
              colorized: true,
              extras: "--vault-password-file ${SECRET}",
              extraVars: [
                namespace_default: 'prod',
                nodeport_default: 30010,
                node_Name: 'node3'
          ]) 
        }
      }
    }
  }

	 
    }
=======
     // define the environment variables to use 
     environment {
       IMAGE_NAME = "node_app_devops"
       IMAGE_TAG = "latest"
	     DOCKER_ID = "matao39"
       IMAGE_PORT = 8000

       NODEPORT_DEV = 30009
       NODEPORT_PROD = 30010
     }

    // specify any agent, important for synk app to have an agent to work
    // (useful for "Scan with Snyk" stage to work)
    agent any

    // define stages for this pipeline
    stages {

      // define stages for CI(Continue Integration)
      stage("Build Docker image"){
        steps {
          echo 'Build docker image'
          sh """
              docker build -t ${DOCKER_ID}/${IMAGE_NAME}:${IMAGE_TAG} .
          """
        }
      }

      stage('Scan with Snyk') {
        steps {
          echo 'Testing...scan apps vulnerabilities'
          snykSecurity(
            snykInstallation: 'Snyk',
            snykTokenId: 'snyk_token',
            severity: 'high',
          )
        }
      }

      stage("Run docker image"){
        steps{
          echo 'Run docker container based on build image'
          sh """
              docker run --name $IMAGE_NAME -d -p ${IMAGE_PORT}:8000 ${DOCKER_ID}/${IMAGE_NAME}:${IMAGE_TAG}
          """
        }
      }
		
      stage('Curl Test on localhost') {
        steps {
          echo 'grab http header code 200: test if container up'
          script {
            sh '''
              sleep 10
              curl -sL -w '%{http_code}\n' http://172.17.0.1:${IMAGE_PORT} -o /dev/null | grep -q 200
            '''
          }
        }
      }
		
      stage('Clean Container') {
        steps {
          echo 'stop and remove docker container'
          script {
            sh '''
              docker stop $IMAGE_NAME
              docker rm $IMAGE_NAME
            '''
          }
        }
      }
	 
      // define stages for CD(Continue Deployment)
      stage('Push image on dockerhub') {
          steps {
            echo 'push the build docker image on dockerhub'
            script {
              withCredentials([string(credentialsId: 'docker_pw', variable: 'SECRET')]) {
                sh '''
                  docker login -u ${DOCKER_ID} -p ${SECRET}
                  docker image push ${DOCKER_ID}/${IMAGE_NAME}:${IMAGE_TAG}
                '''
              }
            }
          }
        }

        stage('Deploy app on k8s nm dev') {
          steps {
            echo 'Deploy app on k8s on dev namespace(nm) using ansible'
            withCredentials([file(credentialsId: 'pass_playbook_nodejs', variable: 'SECRET')]) {
              ansiColor('xterm') {
                ansiblePlaybook( 
                    playbook: 'ansible/deploy.yml',
                    inventory: 'ansible/hosts.yml',
                    colorized: true,
                    extras: "--vault-password-file ${SECRET}",
                    extraVars: [
                      namespace_default: 'dev',
                      nodeport_default: "${NODEPORT_DEV}",
                      node_Name: 'node2'
                ]) 
              }
            }
          }
        }

        stage('Curl Test on node dev') {
          steps {
            echo 'grab http header code 200: test if app up on dev'
            script {
              sh '''
                sleep 20
                curl -sL -w '%{http_code}\n' http://192.168.99.11:${NODEPORT_DEV} -o /dev/null | grep -q 200
              '''
            }
          }
        }

        stage("Run Jmeter") {
          steps {
            echo 'load test on dev namespace'
            bzt "./jmeter/plan.jmx"
            perfReport 'result.csv'
          }
        }

        stage('Deploy app on k8s nm prod') {
          steps {
            echo 'Deploy app on k8s on prod namespace(nm) using ansible'
            withCredentials([file(credentialsId: 'pass_playbook_nodejs', variable: 'SECRET')]) {
              ansiColor('xterm') {
                ansiblePlaybook( 
                    playbook: 'ansible/deploy.yml',
                    inventory: 'ansible/hosts.yml',
                    colorized: true,
                    extras: "--vault-password-file ${SECRET}",
                    extraVars: [
                      namespace_default: 'prod',
                      nodeport_default: "${NODEPORT_PROD}",
                      node_Name: 'node3'
                ]) 
              }
            }
          }
        }

	 
    }   // end stages
>>>>>>> origin/develop-Amandine
	  

	
	
<<<<<<< HEAD
}
=======
}   // end pipeline
>>>>>>> origin/develop-Amandine
