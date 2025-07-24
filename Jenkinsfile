/*
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
                            --alias myAlias ^
                            --set-default ^
                            --no-prompt
                    """
                    bat 'echo ✅ Authenticated successfully.'
                }
            }
        }

        stage('🔍 Step 0: Validate CLI Execution') {
            when { expression { !params.REDEPLOY_METADATA } }
            steps {
                script {
                    echo '🔧 Checking that sf CLI runs and prints version...'
        
                    def versionOutput = bat(script: 'sf --version', returnStdout: true).trim()
                    echo "📦 sf CLI version output:\n${versionOutput}"
        
                    echo '🔧 Checking deploy command prints something:'
        
                    def dryRunOutput = bat(
                        script: """
                            @echo off
                            echo >> Starting validation dry-run...
                            sf deploy metadata validate ^
                                --manifest destructive/package.xml ^
                                --destructive-changes destructive/destructiveChanges.xml ^
                                --target-org myAlias ^
                                --test-level RunSpecifiedTests ^
                                --tests ASKYTightestMatchServiceImplTest ^
                                --json
        
                            echo >> End of dry-run CLI output
                        """,
                        returnStdout: true
                    ).trim()
        
                    echo "🖨️ Raw deploy output:\n${dryRunOutput}"
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
    }
}
*/
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
                    // Build the salesforce CLI Docker image from Dockerfile in workspace
                    docker.build('salesforce-cli:latest')
                }
            }
        }

        stage('Authenticate Salesforce') {
            steps {
                script {
                    // Convert Windows workspace path to Docker-compatible path (Unix style)
                    def workspaceWinPath = env.WORKSPACE.replaceAll('\\\\', '/')
                    def containerWorkspace = '/ws'

                    withCredentials([file(credentialsId: 'sf-jwt-private-key', variable: 'JWT_KEY_FILE')]) {
                        // Convert JWT key path for Docker mount
                        def jwtKeyHostPath = env.JWT_KEY_FILE.replaceAll('\\\\', '/')
                        def jwtKeyContainerPath = '/tmp/jwt_key.pem'

                        // Run container with mounts and working directory
                        def container = docker.image('salesforce-cli:latest').run(
                            "-v ${workspaceWinPath}:${containerWorkspace} " +
                            "-v ${jwtKeyHostPath}:${jwtKeyContainerPath} " +
                            "-w ${containerWorkspace}"
                        )

                        try {
                            // Execute the Salesforce CLI JWT auth command inside the running container
                            container.exec([
                                'sf', 'auth', 'jwt', 'grant',
                                '--client-id', CONSUMER_KEY,
                                '--jwt-key-file', jwtKeyContainerPath,
                                '--username', SF_USERNAME,
                                '--instance-url', 'https://test.salesforce.com',
                                '--alias', 'myAlias',
                                '--set-default',
                                '--no-prompt'
                            ])
                            echo "✅ Authenticated successfully."
                        } finally {
                            // Clean up the container after the command completes
                            container.stop()
                            container.remove()
                        }
                    }
                }
            }
        }

        stage('🔍 Step 0: Validate CLI Execution') {
            when { expression { !params.REDEPLOY_METADATA } }
            steps {
                script {
                    def workspaceWinPath = env.WORKSPACE.replaceAll('\\\\', '/')
                    def containerWorkspace = '/ws'

                    def container = docker.image('salesforce-cli:latest').run(
                        "-v ${workspaceWinPath}:${containerWorkspace} -w ${containerWorkspace}"
                    )

                    try {
                        echo '🔧 Checking that sf CLI runs and prints version...'

                        // Run sf --version and capture output
                        def versionOutput = container.exec(['sf', '--version']).trim()
                        echo "📦 sf CLI version output:\n${versionOutput}"

                        echo '🔧 Checking deploy command prints something:'

                        // Run the deploy validation dry-run inside container shell
                        def dryRunOutput = container.exec([
                            'sh', '-c',
                            '''set -e
                            echo "Starting validation dry-run..."
                            sf deploy metadata validate \
                                --manifest destructive/package.xml \
                                --destructive-changes destructive/destructiveChanges.xml \
                                --target-org myAlias \
                                --test-level RunSpecifiedTests \
                                --tests ASKYTightestMatchServiceImplTest \
                                --json
                            echo "End of dry-run CLI output"'''
                        ]).trim()

                        echo "🖨️ Raw deploy output:\n${dryRunOutput}"
                    } finally {
                        container.stop()
                        container.remove()
                    }
                }
            }
        }

        // Add additional stages here, following same container lifecycle pattern
    }
}






