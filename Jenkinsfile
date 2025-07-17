pipeline {
    agent any

    environment {
        CONSUMER_KEY = credentials('sf-consumer-key')
        SF_USERNAME = credentials('sf-username')
    }

    parameters {
        booleanParam(name: 'REDEPLOY_METADATA', defaultValue: false, description: 'Redeploy previously backed-up metadata?')
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build('salesforce-cli:latest')
                }
            }
        }

        stage('Authenticate Salesforce') {
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
                    bat 'echo ✅ Authenticated successfully.'
                }
            }
        }
        /*
        stage('🔍 Step 0: Validate Deletion Readiness') {
            when {
                expression { return !params.REDEPLOY_METADATA }
            }
            steps {
                script {
                    echo '🧪 Validating potential impact of deletion using check-only deploy...'
        
                    withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                        def result = bat(
                            script: """
                                sf project deploy start ^
                                    --target-org %SF_USERNAME% ^
                                    --manifest destructive/package.xml ^
                                    --post-destructive-changes destructive/destructiveChanges.xml ^
                                    --check-only ^
                                    --ignore-warnings ^
                                    --wait 10
                            """,
                            returnStatus: true
                        )
        
                        if (result != 0) {
                            error "❌ Validation failed. Deletion would cause errors or dependency issues."
                        } else {
                            echo '✅ Validation passed. No critical dependencies found for deletion.'
                        }
                    }
                }
            }
        }
        */

        stage('🔍 Step 0: Validate Deletion Readiness') {
            when {
                expression { return !params.REDEPLOY_METADATA }
            }
            steps {
                script {
                    echo '🧪 Validating potential impact of deletion using check-only deploy...'
        
                    withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                        def result = bat(
                            script: """
                                sfdx force:mdapi:deploy ^
                                    -u %SF_USERNAME% ^
                                    -d destructive ^
                                    -w 10 ^
                                    -c ^
                                    -g destructive/destructiveChanges.xml ^
                                    --ignorewarnings
                            """,
                            returnStatus: true
                        )
        
                        if (result != 0) {
                            error "❌ Validation failed. Deletion would cause errors or dependency issues."
                        } else {
                            echo '✅ Validation passed. No critical dependencies found for deletion.'
                        }
                    }
                }
            }
        }
        
        stage('🔐 Step 1: Retrieve Metadata (Backup)') {
            when {
                expression { return !params.REDEPLOY_METADATA }
            }
            steps {
                withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                    script {
                        echo '📦 Backing up metadata before deletion...'

                        bat 'if exist retrieved-metadata (rmdir /s /q retrieved-metadata)'
                        bat 'mkdir retrieved-metadata'

                        bat """
                            sf project retrieve start ^
                                --target-org %SF_USERNAME% ^
                                --manifest manifest\\package.xml ^
                                --output-dir retrieved-metadata
                        """

                        bat 'powershell Compress-Archive -Path retrieved-metadata\\* -DestinationPath retrieved-metadata.zip -Force'
                    }
                }
            }
            post {
                success {
                    archiveArtifacts artifacts: 'retrieved-metadata.zip', fingerprint: true
                }
            }
        }

        stage('🗑️ Step 2: Delete Metadata (Destructive Deployment)') {
            when {
                expression { return !params.REDEPLOY_METADATA }
            }
            steps {
                withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                    script {
                        echo '🚨 Deleting metadata using destructiveChanges.xml...'
        
                        bat """
                            sf project deploy start ^
                                --target-org %SF_USERNAME% ^
                                --manifest destructive\\package.xml ^
                                --post-destructive-changes destructive\\destructiveChanges.xml ^
                                --ignore-warnings ^
                                --wait 10
                        """
                    }
                }
            }
        }
        
        stage('📦 Step 4: Redeploy from Backup (Optional Manual Trigger)') {
            when {
                expression { return params.REDEPLOY_METADATA }
            }
            steps {
                echo "📤 Redeploying previously retrieved metadata…"
        
                // Use last successful build to copy artifacts
                copyArtifacts(
                    projectName: env.JOB_NAME,
                    filter: 'retrieved-metadata.zip',
                    selector: lastSuccessful()
                )
        
                // Check if artifact exists
                script {
                    if (!fileExists('retrieved-metadata.zip')) {
                        error "❌ Could not retrieve 'retrieved-metadata.zip'. Redeploy cancelled."
                    }
                }
        
                // Expand and deploy
                bat 'powershell Expand-Archive -Path retrieved-metadata.zip -DestinationPath retrieved-metadata -Force'
        
                withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                    bat """
                        sf project deploy start ^
                            --target-org %SF_USERNAME% ^
                            --source-dir retrieved-metadata ^
                            --ignore-warnings ^
                            --wait 10
                    """
                }
            }
        }
    }
}


