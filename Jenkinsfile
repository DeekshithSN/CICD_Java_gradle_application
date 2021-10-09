pipeline {
  agent any 
    stages{
        stage("sonarqube static code check"){
            agent{
                docker{
                    image 'openjdk:11'
                }
            }

            steps{
                script{
                   withSonarQubeEnv(credentialsId: 'sonar-password') {
                       sh 'chmod +x gradlew'
                       sh './gradlew sonarqube'
                    }
                }
            }

        }
    }

}