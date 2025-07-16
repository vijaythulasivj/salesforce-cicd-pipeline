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
        stage('🔍 Step 3: Verify Deletion of Apex Classes') {
            steps {
                withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                    script {
                        echo '🔎 Verifying that deleted Apex classes are no longer in the org...'
        
                        // Write the Apex verification script (no exceptions thrown)
                        writeFile file: 'verifyDeletion.apex', text: '''
        List<String> classNamesToCheck = new List<String>{'ASKYTightestMatchServiceImpl', 'AccountTest2'};
        List<ApexClass> foundClasses = [SELECT Name FROM ApexClass WHERE Name IN :classNamesToCheck];
        if (foundClasses.isEmpty()) {
            System.debug('✅ All targeted classes were successfully deleted.');
        } else {
            System.debug('❌ Some classes are still present: ' + foundClasses);
        }
                        '''
        
                        // Run the Apex script, capturing logs in 'apex-logs' folder
                        bat """
                            sf apex run ^
                                --target-org %SF_USERNAME% ^
                                --file verifyDeletion.apex ^
                                --loglevel debug ^
                                --output-dir apex-logs ^
                                --json
                        """
        
                        // Read the generated debug log file (assuming only one log, 'apex.log')
                        def logFileContent = readFile('apex-logs/apex.log').trim()
        
                        // Check log content for success or failure messages
                        if (logFileContent.contains('✅ All targeted classes were successfully deleted.')) {
                            echo '✅ Verification Result: All targeted classes were successfully deleted.'
                        } else if (logFileContent.contains('❌ Some classes are still present')) {
                            echo '❌ Verification Result: Some classes are still present in the org.'
                        } else {
                            echo '⚠️ Verification Result: Unexpected output in debug logs.'
                        }
                    }
                }
            }
        }
        
        stage('📦 Step 4: Redeploy from Backup (Optional Manual Trigger)') {
            when {
                expression { return params.REDEPLOY_METADATA }
            }
            steps {
                withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                    script {
                        echo '📤 Redeploying previously retrieved metadata from backup zip...'

                        // Extract the archived metadata
                        bat 'powershell Expand-Archive -Path retrieved-metadata.zip -DestinationPath retrieved-metadata -Force'

                        // Redeploy the unzipped metadata
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
        */
        stage('📦 Step 4: Redeploy from Backup (Optional Manual Trigger)') {
            when {
                expression { return params.REDEPLOY_METADATA }
            }
            steps {
                script {
                    echo "📤 Redeploying previously retrieved metadata…"
        
                    // Get the last successful build number
                    def lastSuccessfulBuild = currentBuild.rawBuild.getPreviousSuccessfulBuild()
                    if (lastSuccessfulBuild == null) {
                        error "❌ No previous successful build found. Redeploy cancelled."
                    }
        
                    def buildNumber = lastSuccessfulBuild.getNumber()
                    echo "✅ Found last successful build: #${buildNumber}"
        
                    // Copy the backup zip from the last successful build
                    copyArtifacts(
                        projectName: env.JOB_NAME,
                        filter: 'retrieved-metadata.zip',
                        selector: specific("${buildNumber}")
                    )
        
                    // Make sure the artifact exists
                    if (!fileExists('retrieved-metadata.zip')) {
                        error "❌ Could not retrieve 'retrieved-metadata.zip' from last successful build #${buildNumber}. Redeploy cancelled."
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
}


