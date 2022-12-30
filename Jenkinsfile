pipeline {
    agent any
    stages {
       stage('Sonary quality check'){
        agent {
            docker{
                image 'openjdk:11'
            }
        }
        steps {
            script {
                withSonarQubeEnv(credentialsId: 'sonar') {
                      sh 'chmod +x gradlew'
                      sh './gradlew sonarqube' /* it will push code to sonar qube for static quality check */
                    }
            }
        }
       
    }
}
}