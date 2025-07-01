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

        stage('Authenticate with Salesforce (JWT)') {
            steps {
                withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'PRIVATE_KEY_FILE')]) {
                    script {
                        def workspacePath = env.WORKSPACE.replace('\\', '/')

                        // Run the JWT authentication
                        bat """
                        docker run --rm -v ${workspacePath}:/workspace -v %PRIVATE_KEY_FILE%:/workspace/server.key -w /workspace salesforce-cli:latest sf org login jwt ^
                            --username ${env.SF_USERNAME} ^
                            --client-id ${env.CONSUMER_KEY} ^
                            --jwt-key-file /workspace/server.key ^
                            --instance-url https://login.salesforce.com ^
                            --set-default ^
                            --alias my-jwt-org
                        """
                    }
                }
            }
        }

        stage('Verify Authenticated Org') {
            steps {
                script {
                    def workspacePath = env.WORKSPACE.replace('\\', '/')

                    bat """
                    docker run --rm -v ${workspacePath}:/workspace -w /workspace salesforce-cli:latest sf org display --target-org my-jwt-org
                    """
                }
            }
        }
    }
}




