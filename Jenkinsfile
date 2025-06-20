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
                    // Fix Windows path for Docker volume mount
                    def workspacePath = env.WORKSPACE.replace('\\', '/')
                    docker.image('salesforce-cli:latest').inside("-v ${env.WORKSPACE}:/workspace") {
                        sh 'sf --version'
                    }
                }
            }
        }
    }
}
