pipeline {
    agent any
    stages {
       stage('Sonary quality check') {
            steps {
                script {
                    withSonarQubeEnv(credentialsId: 'sonar') {
                        sh 'chmod +x gradlew'
                        sh './gradlew sonarqube --stacktrace' /* it will push code to sonar qube for static quality check */
                    }
                }
            }
       
        }
    }
}