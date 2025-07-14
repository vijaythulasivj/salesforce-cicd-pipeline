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

        stage('Retrieve Metadata') {
            steps {
                withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                    script {
                        echo '📦 Retrieving metadata from sandbox org...'
        
                        // Ensure directory exists
                        bat 'if not exist retrieved-metadata (mkdir retrieved-metadata)'
        
                        // Retrieve metadata using package.xml
                        bat """
                            sf project retrieve start ^
                                --target-org %SF_USERNAME% ^
                                --manifest manifest\\package.xml ^
                                --output-dir retrieved-metadata
                        """
                    }
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
                    /*    
                    // Describe metadata types
                    bat """
                        echo 📄 Describing metadata types...
                        sf force mdapi describemetadata ^
                            --target-org %SF_USERNAME% ^
                            --json > metadata-types.json
                    """

                    bat 'echo ✅ Metadata description saved to metadata-types.json'
                    */
                }
            }
        }

        stage('Retrieve Metadata') {
            steps {
                withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                    script {
                        echo '📦 Retrieving metadata from sandbox org...'

                        // Ensure directory exists
                        bat 'if not exist retrieved-metadata (mkdir retrieved-metadata)'

                        // Retrieve metadata using package.xml
                        bat """
                            sf project retrieve start ^
                                --target-org %SF_USERNAME% ^
                                --manifest manifest\\package.xml ^
                                --output-dir retrieved-metadata
                        """

                        // Zip the retrieved metadata folder (PowerShell command for Windows agent)
                        bat 'powershell Compress-Archive -Path retrieved-metadata\\* -DestinationPath retrieved-metadata.zip -Force'
                    }
                }
            }
            post {
                success {
                    // Archive the zipped metadata so it can be reused/downloaded later
                    archiveArtifacts artifacts: 'retrieved-metadata.zip', fingerprint: true
                }
            }
        }
    }
}










