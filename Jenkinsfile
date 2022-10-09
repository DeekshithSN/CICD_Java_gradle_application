pipeline{
    agent any
    stages{
        stage("sonar quality check"){
            agent {
                docker{
                    image 'openjdk:11'
                }
        }
            steps{
                script{
                    withSonarQubeEnv(credentialsId: 'sonar-token') {
                        sh 'chmod +x gradlew'
                        sh './gradlew sonarqube'
                    }
                    timeout(5) {
                        def qg = waitForQualityGate()
                        if(qg.status != 'OK'){
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }

                }

            }
        }
    }
  
}