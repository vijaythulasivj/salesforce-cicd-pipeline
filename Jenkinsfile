pipeline {
    agent any
    
    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build('salesforce-cli:latest')
                }
            }
        }
        
        stage('Run Salesforce CLI') {
            steps {
                script {
                    docker.image('salesforce-cli:latest').inside {
                        // Example SF CLI command
                        sh 'sf --version'
                        
                        // Add your SF CLI commands here, e.g.:
                        // sh 'sf auth login --use-device-code'
                        // sh 'sf project deploy start --target-org mySandboxAlias'
                    }
                }
            }
        }
    }
}
