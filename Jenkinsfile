/*
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
                    // Replace backslashes with forward slashes for Docker on Windows
                    def workspacePath = env.WORKSPACE.replace('\\', '/')

                    // Explicitly run docker run with volume and working directory in Linux style
                    bat """
                    docker run --rm -v ${workspacePath}:/workspace -w /workspace salesforce-cli:latest sf --version
                    """
                }
            }
        }
    }
}
*/
pipeline {
    agent any

    environment {
        CONSUMER_KEY = credentials('sf-consumer-key')
        SF_USERNAME = credentials('sf-username')
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build('salesforce-cli:latest')
                }
            }
        }

        stage('Test JWT Connection to Salesforce') {
            steps {
                withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                    bat """
                        echo Current user: %USERNAME%
                        echo PATH: %PATH%
                        where sf || echo sf not found
                        echo Testing JWT-based authentication to Salesforce...

                        sf auth jwt grant ^
                          --client-id %CONSUMER_KEY% ^
                          --jwt-key-file %JWT_KEY% ^
                          --username %SF_USERNAME% ^
                          --instance-url https://login.salesforce.com ^
                          --set-default

                        echo Successfully connected to Salesforce via JWT!
                        sf org display
                    """
                }
            }
        }
    }
}





