pipeline{
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
	  

	
	
<<<<<<< HEAD
}
=======
}   // end pipeline
>>>>>>> origin/develop-Amandine
