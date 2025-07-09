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
/*
pipeline {
    agent any

    environment {
        CONSUMER_KEY = credentials('sf-consumer-key')       // Consumer Key from Connected App
        SF_USERNAME = credentials('sf-username')            // Sandbox user (e.g., user@domain.sandbox)
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build('salesforce-cli:latest')
                }
            }
        }
        stage('Run Apex Tests') {
            steps {
                withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
        
                    // Authenticate via JWT
                    bat """
                        sf auth jwt grant ^
                            --client-id %CONSUMER_KEY% ^
                            --jwt-key-file "%JWT_KEY%" ^
                            --username %SF_USERNAME% ^
                            --instance-url https://test.salesforce.com ^
                            --set-default
                    """
        
                    bat 'echo ✅ Successfully authenticated.'
        
                    // Describe metadata types
                    bat """
                        echo 📄 Describing metadata types...
                        sf force mdapi describemetadata ^
                            --target-org %SF_USERNAME% ^
                            --json > metadata-types.json
                    """
        
                    bat 'echo ✅ Metadata description saved to metadata-types.json'
                }
            }
        }
    }
}
*/

pipeline {
    agent any

    environment {
        CONSUMER_KEY = credentials('sf-consumer-key')       // Consumer Key from Connected App
        SF_USERNAME = credentials('sf-username')            // Sandbox user (e.g., user@domain.sandbox)
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build('salesforce-cli:latest')
                }
            }
        }
        stage('Authenticate') {
            steps {
                withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                    bat """
                        sf auth jwt grant ^
                            --client-id %CONSUMER_KEY% ^
                            --jwt-key-file "%JWT_KEY%" ^
                            --username %SF_USERNAME% ^
                            --instance-url https://test.salesforce.com ^
                            --set-default
                    """
                    bat 'echo ✅ Successfully authenticated.'
                }
            }
        }
        stage('Get API Version') {
            steps {
                script {
                    echo "📡 Fetching API version from Salesforce org..."
        
                    def output = bat(
                        script: 'sf force mdapi describemetadata --target-org %SF_USERNAME% --json',
                        returnStdout: true
                    ).trim()
        
                    def parsedJson = readJSON text: output
                    def apiVersion = parsedJson.result.maxApiVersion
                    env.SF_API_VERSION = apiVersion.toString()
                    
                    echo "🎯 Org Max API Version: ${env.SF_API_VERSION}"
                }
            }
        }

        stage('Run Apex Tests') {
            steps {
                withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                    bat """
                        echo 📄 Describing metadata types...
                        sf force mdapi describemetadata ^
                            --target-org %SF_USERNAME% ^
                            --json > metadata-types.json
                    """
                    bat 'echo ✅ Metadata description saved to metadata-types.json'
                }
            }
        }
    }
}







