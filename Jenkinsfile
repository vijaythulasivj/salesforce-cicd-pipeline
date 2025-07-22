
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
                            --set-default ^
                            --no-prompt
                    """
                    bat 'echo ✅ Authenticated successfully.'
                }
            }
        }

        stage('🔍 Step 0: Validate Deletion Readiness') {
            when {
                expression { return !params.REDEPLOY_METADATA }
            }
            steps {
                script {
                    echo '🧪 Validating potential impact of deletion using check-only deploy...'
        
                    withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY')]) {
                        def deployDir = 'destructive' // Folder containing package.xml and destructiveChanges.xml
        
                        def output = bat(
                            script: """
                                @echo on
                        
                                echo ">> Starting dry-run deploy from ${deployDir}..."
                                sf project deploy start ^
                                    --manifest destructive/package.xml ^
                                    --target-org ciOrg ^
                                    --validation ^
                                    --test-level NoTestRun ^
                                    --json > validate_deletion_log.json 2>&1
                                echo Deploy command exited with errorlevel: %ERRORLEVEL%
                                if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
                        
                                echo ">> ✅ Exited Deletion Validation Stage from GitHub Jenkinsfile"
                            """,
                            returnStdout: true
                        ).trim()
        
                        echo "🔍 Deploy command output:\n${output}"
        
                        // Read and parse the JSON log
                        def validationLog = readJSON file: 'validate_deletion_log.json'
        
                        // Extract status
                        def status = validationLog?.result?.status ?: 'UNKNOWN'
                        echo "🔍 Validation status: ${status}"
        
                        if (status != 'Succeeded') {
                            echo "❌ Deployment validation failed. Parsing errors..."
        
                            def failures = validationLog?.result?.details?.componentFailures ?: []
                            if (failures.size() == 0) {
                                echo "No componentFailures found, dumping full message:"
                                echo validationLog?.result?.message ?: 'No message in JSON'
                            } else {
                                failures.each { failure ->
                                    echo "Component failure in ${failure?.fileName ?: failure?.fullName ?: 'unknown'}"
                                    echo "  Problem: ${failure?.problem ?: 'No problem detail'}"
                                    echo "  ErrorType: ${failure?.errorType ?: 'Unknown'}"
                                }
                            }
        
                            error "Deployment validation failed, aborting pipeline."
                        } else {
                            echo "✅ Deployment validation succeeded, safe to proceed."
                        }
                    }
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
                        def deployDir = 'destructive' // Folder containing package.xml and destructiveChanges.xml
                               
                        def output = bat(
                            script: """
                                @echo on
                                
                                echo ">> Starting dry-run deploy from ${deployDir}..."
                                sf project deploy start ^
                                    --manifest destructive/package.xml ^
                                    --target-org ciOrg ^
                                    --validation ^
                                    --test-level NoTestRun ^
                                    --json > validate_deletion_log.json
                                echo Deploy command exited with errorlevel: %ERRORLEVEL%
                                if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
                        
                                echo ">> ✅ Exited Deletion Validation Stage from GitHub Jenkinsfile"
                            """,
                            returnStdout: true
                        ).trim()
        
                        echo "🔍 Deploy command output:\n${output}"
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
                               // --manifest manifest\\package.xml ^
                                --destructive destructive\\destructiveChanges.xml ^
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
        */
    }
}



