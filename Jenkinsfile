pipeline{
    agent any
    stages{
        agent{
            docker{
                image 'openjdk:11'
            }
        }
        stage("sonar quality check"){
            steps{
                script{
                    withSonarQubeEnv(credentialsId: 'sonar-token') {
                        sh 'chmod +x gradlew'
                        sh './gradlew sonarqube'
                    }
                }

            }
        }
    }
  
}