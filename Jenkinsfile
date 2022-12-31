pipeline {
    agent any
    environment{
        VERSION="${env.BUILD_ID}"
        DOCKER_USER= "admin"
    }
    stages {
       stage('Sonary quality check') {
            steps {

                script {

                    withSonarQubeEnv(credentialsId: 'sonar') {
                        sh 'chmod +x gradlew'
                        sh './gradlew sonarqube --stacktrace' /* it will push code to sonar qube for static quality check */

                    }

                    timeout(30) {

                        def qualityGate = waitForQualityGate()
                        if (qualityGate.status != 'OK') {

                            error "Pipeline aborted due to quality gate failure: ${qualityGate.status}"

                        }
                    }
                }
            }
       
        }

        stage("DOcker build and push") {
            steps{
                script{

                    withCredentials([string(credentialsId: 'nexus_pass', variable: 'nexus_pass')]) {
                         sh '''
                            docker build -t 23.20.71.185:8083/springapp:${VERSION} .
                            docker login -u admin -p --password-stdin < nexus_pass 23.20.71.185:8083
                            docker push 23.20.71.185:8083/springapp:${VERSION}
                            docker rmi 23.20.71.185:8083/springapp:${VERSION}
                        '''
                    }
                   
                }
            }
        }
    }
}