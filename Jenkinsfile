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
                      "C:\\Program Files\\sf\\bin\\sf.cmd" auth jwt grant ^
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
                    // Define sfCmd variable here
                    def sfCmd = '"C:\\Program Files\\sf\\bin\\sf.cmd"'
                    echo 'Current working directory:'
                    bat 'cd'
                    echo '🔧 Checking that sf CLI runs and prints version...'
                    // Use sfCmd variable explicitly
                    def sfPath = bat(script: 'where sf', returnStdout: true).trim()
                    echo "🔍 sf executable path(s):\n${sfPath}"
                    def versionOutput = bat(script: "${sfCmd} --version", returnStdout: true).trim()
                    echo "📦 sf CLI version output:\n${versionOutput}"
        
                    echo '🔧 Checking deploy command prints something:'
        
                    def dryRunOutput = bat(
                        script: """
                            @echo off
                            echo >> Starting validation dry-run...
                            ${sfCmd} deploy metadata validate ^
                              --source-dir force-app/main/default/classes ^
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
/*
pipeline {
    agent any

    environment {
        CONSUMER_KEY = credentials('sf-consumer-key')
        SF_USERNAME = credentials('sf-username')
        SF_CMD = '"C:\\Program Files\\sf\\bin\\sf.cmd"'
        ALIAS = "myAlias"
        INSTANCE_URL = "https://test.salesforce.com"
        PYTHON_EXE = '"C:\\Users\\tsi082\\AppData\\Local\\Programs\\Python\\Python313\\python.exe"'
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
                    %SF_CMD% auth jwt grant ^
                        --client-id %CONSUMER_KEY% ^
                        --jwt-key-file "%JWT_KEY%" ^
                        --username %SF_USERNAME% ^
                        --instance-url %INSTANCE_URL% ^
                        --alias %ALIAS% ^
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
                    echo '📁 Current working directory:'
                    bat 'cd'

                    echo '📦 Preparing destructive deployment ZIP...'
                    bat '''
                        rmdir /s /q destructive-temp || exit 0
                        mkdir destructive-temp
                        copy destructive\\destructiveChanges.xml destructive-temp\\
                        copy destructive\\package.xml destructive-temp\\
                        powershell Compress-Archive -Path destructive-temp\\* -DestinationPath destructivePackage.zip -Force
                    '''

                    echo '📦 Listing contents of destructivePackage.zip:'
                    bat '''
                        powershell -command "Add-Type -AssemblyName System.IO.Compression.FileSystem; $zipPath = 'destructivePackage.zip'; $zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath); $zip.Entries | ForEach-Object { Write-Output $_.FullName }; $zip.Dispose()"
                    '''

                    echo '🔧 Validating destructiveChanges.xml using sfdx force:mdapi:deploy (check only)...'
                    bat """
                        "C:\\Users\\tsi082\\AppData\\Roaming\\npm\\sfdx.cmd" force:mdapi:deploy ^
                            --zipfile destructivePackage.zip ^
                            --targetusername %ALIAS% ^
                            --wait 10 ^
                            --checkonly ^
                            --json > deploy-result.json
                    """

                    echo '📂 Archiving deploy-result.json...'
                    archiveArtifacts artifacts: 'deploy-result.json', allowEmptyArchive: false

                    echo '✅ Validation of destructiveChanges.xml complete.'

                    bat """
                    %SF_CMD% deploy metadata validate ^
                        --source-dir force-app/main/default/classes ^
                        --target-org %ALIAS% ^
                        --test-level RunSpecifiedTests ^
                        --tests ASKYTightestMatchServiceImplTest ^
                        --json > deploy-result.json
                    """        
                    echo '🧪 Running Apex tests (initial run to get testRunId)...'
                    bat """
                    %SF_CMD% apex run test ^
                        --tests ASKYTightestMatchServiceImplTest ^
                        --target-org %ALIAS% ^
                        --code-coverage ^
                        --test-level RunSpecifiedTests ^
                        --json > test-run.json
                    """
        
                    // ✅ Extract testRunId from test-run.json using Jenkins readJSON
                    def testRunJson = readJSON file: 'test-run.json'
                    def testRunId = testRunJson?.result?.testRunId?.trim()
        
                    if (!testRunId) {
                        error "❌ testRunId not found in test-run.json! Failing pipeline."
                    }
        
                    echo "➡️ Test Run ID: ${testRunId}"
        
                    echo '🧪 Fetching detailed test results from REST API and generating Excel report...'
                    withEnv([
                        "TEST_RUN_ID=${testRunId}",
                        "SF_ALIAS=${env.ALIAS}",
                        "PYTHONIOENCODING=utf-8"
                    ]) {
                        bat "\"${env.PYTHON_EXE}\" scripts\\generate_validation_report.py"
                    }
        
                    echo '📂 Archiving Excel report...'
                    archiveArtifacts artifacts: 'test-results.xlsx', allowEmptyArchive: false
        
                    echo '✅ Excel report generated and archived.'
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
        SF_CMD = '"C:\\Program Files\\sf\\bin\\sf.cmd"'  // Full path to SFDX CLI
        SFDX_CMD = '"C:\\Users\\tsi082\\AppData\\Roaming\\npm\\sfdx.cmd"'
        ALIAS = "myAlias"
        INSTANCE_URL = "https://test.salesforce.com"
        PYTHON_EXE = '"C:\\Users\\tsi082\\AppData\\Local\\Programs\\Python\\Python313\\python.exe"'
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
                    %SF_CMD% auth jwt grant ^
                        --client-id %CONSUMER_KEY% ^
                        --jwt-key-file "%JWT_KEY%" ^
                        --username %SF_USERNAME% ^
                        --instance-url %INSTANCE_URL% ^
                        --alias %ALIAS% ^
                        --set-default ^
                        --no-prompt
                    """
                    bat 'echo Authenticated successfully.'
                }
            }
        }

        stage('Validate Destructive Deployment') {
            when { expression { !params.REDEPLOY_METADATA } }
            steps {
                script {
                    echo 'Preparing destructive deployment ZIP...'
                    bat '''
                        rmdir /s /q destructive-temp || exit 0
                        mkdir destructive-temp
                        copy destructive\\destructiveChanges.xml destructive-temp\\
                        copy destructive\\package.xml destructive-temp\\
                        powershell Compress-Archive -Path destructive-temp\\* -DestinationPath destructivePackage.zip -Force
                    '''

                    echo 'Contents of destructiveChanges.xml:'
                    bat 'type destructive\\destructiveChanges.xml'

                    echo 'Validating metadata existence in sandbox using Python...'

                    def validateScript = '''
                    import xml.etree.ElementTree as ET
                    import subprocess
                    import sys
                    import json
                    import os

                    ORG_ALIAS = os.environ.get('ALIAS')
                    SFDX_CLI = os.environ.get('SF_CMD', 'sfdx').strip('"')

                    SOQL_MAP = {
                        'ApexClass': "SELECT Id FROM ApexClass WHERE Name = '{}'",
                        'ApexTrigger': "SELECT Id FROM ApexTrigger WHERE Name = '{}'",
                        'ApexPage': "SELECT Id FROM ApexPage WHERE Name = '{}'"
                    }

                    def check_component_exists(metadata_type, component_name):
                        soql = SOQL_MAP.get(metadata_type)
                        if not soql:
                            print(f"Warning: Metadata type '{metadata_type}' not checked.")
                            return True

                        query = soql.format(component_name)
                        cmd = [SFDX_CLI, 'force:data:soql:query', '-q', query, '-u', ORG_ALIAS, '--json']
                        try:
                            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
                            data = json.loads(result.stdout)
                            records = data.get("result", {}).get("records", [])
                            if not records:
                                print(f"Component NOT FOUND: {metadata_type} - {component_name}")
                                return False
                            else:
                                print(f"Component found: {metadata_type} - {component_name}")
                                return True
                        except subprocess.CalledProcessError as e:
                            print("Error running sfdx:", e)
                            return False

                    def main():
                        tree = ET.parse("destructive/destructiveChanges.xml")
                        root = tree.getroot()
                        ns = {"sf": "http://soap.sforce.com/2006/04/metadata"}

                        all_exist = True
                        for types in root.findall("sf:types", ns):
                            metadata_type = types.find("sf:name", ns).text
                            for member in types.findall("sf:members", ns):
                                component = member.text
                                if not check_component_exists(metadata_type, component):
                                    all_exist = False

                        if not all_exist:
                            sys.exit(1)
                        else:
                            print("All metadata components exist.")

                    if __name__ == "__main__":
                        main()
                    '''.stripIndent()

                    writeFile file: 'validate_metadata.py', text: validateScript

                    echo 'Running Python validation script...'
                    withEnv(["SF_CMD=${env.SF_CMD}", "ALIAS=${env.ALIAS}"]) {
                        def validateResult = bat(script: "\"${env.PYTHON_EXE}\" validate_metadata.py", returnStatus: true)
                        if (validateResult != 0) {
                            error 'One or more metadata components listed in destructiveChanges.xml do not exist in the target org. Aborting deployment.'
                        }
                    }

                    echo 'All metadata components exist in sandbox. Proceeding with dry-run deployment...'

                    echo 'Listing contents of destructivePackage.zip:'
                    bat '''
                        powershell -command "Add-Type -AssemblyName System.IO.Compression.FileSystem; $zipPath = 'destructivePackage.zip'; $zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath); $zip.Entries | ForEach-Object { Write-Output $_.FullName }; $zip.Dispose()"
                    '''

                    echo 'Running dry-run validation (checkonly)...'
                    bat """
                        "${env.SFDX_CMD}" force:mdapi:deploy ^
                            --zipfile destructivePackage.zip ^
                            --targetusername %ALIAS% ^
                            --wait 10 ^
                            --checkonly ^
                            --json > deploy-result.json
                    """

                    echo 'Archiving deployment result...'
                    archiveArtifacts artifacts: 'deploy-result.json', allowEmptyArchive: false

                    echo 'Parsing result (component successes & failures)...'
                    bat """
                    echo import json > parse_deploy_result.py
                    echo with open('deploy-result.json') as f: >> parse_deploy_result.py
                    echo.    data = json.load(f) >> parse_deploy_result.py
                    echo.    details = data.get('result', {}).get('details', {}) >> parse_deploy_result.py
                    echo.    successes = details.get('componentSuccesses', []) >> parse_deploy_result.py
                    echo.    failures = details.get('componentFailures', []) >> parse_deploy_result.py
                    echo.    if isinstance(successes, dict): successes = [successes] >> parse_deploy_result.py
                    echo.    if isinstance(failures, dict): failures = [failures] >> parse_deploy_result.py
                    echo.    print('--- Component Successes ---') >> parse_deploy_result.py
                    echo.    [print(f"✓ {c.get('componentType')}: {c.get('fullName')}") for c in successes] >> parse_deploy_result.py
                    echo.    if not successes: print('No components were validated.') >> parse_deploy_result.py
                    echo.    print('\\n--- Component Failures ---') >> parse_deploy_result.py
                    echo.    [print(f" {c.get('componentType')}: {c.get('fullName')} — {c.get('problem')}") for c in failures] >> parse_deploy_result.py
                    ${env.PYTHON_EXE} parse_deploy_result.py
                    """

                    echo 'Validation complete. Ready for actual deployment if needed.'

                    echo 'Checking for orphaned references before deletion...'

                    def orphanRefScript = '''
                    import xml.etree.ElementTree as ET
                    import subprocess
                    import sys
                    import json
                    import os
                    
                    ORG_ALIAS = os.environ.get('ALIAS')
                    SFDX_CLI = os.environ.get('SF_CMD', 'sfdx').strip('"')
                    
                    def check_orphan_references(metadata_type, component_name):
                        # Get component Id
                        id_query = f"SELECT Id FROM {metadata_type} WHERE Name = '{component_name}'"
                        id_cmd = [SFDX_CLI, 'force:data:soql:query', '-q', id_query, '-u', ORG_ALIAS, '--json']
                        try:
                            id_result = subprocess.run(id_cmd, capture_output=True, text=True, check=True)
                            id_data = json.loads(id_result.stdout)
                            records = id_data.get("result", {}).get("records", [])
                            if not records:
                                return True
                            comp_id = records[0]['Id']
                    
                            # Query MetadataComponentDependency for references
                            ref_query = f"SELECT RefMetadataComponent.Name, RefMetadataComponent.Type FROM MetadataComponentDependency WHERE RefMetadataComponentId = '{comp_id}'"
                            ref_cmd = [SFDX_CLI, 'force:data:soql:query', '-q', ref_query, '-u', ORG_ALIAS, '--json']
                            ref_result = subprocess.run(ref_cmd, capture_output=True, text=True, check=True)
                            ref_data = json.loads(ref_result.stdout)
                            references = ref_data.get("result", {}).get("records", [])
                            if references:
                                print(f"Component {metadata_type} - {component_name} is referenced by:")
                                for ref in references:
                                    print(f"  {ref['RefMetadataComponent']['Type']} - {ref['RefMetadataComponent']['Name']}")
                                return False
                            return True
                        except subprocess.CalledProcessError as e:
                            print("Error querying sfdx:", e)
                            return False
                    
                    def main():
                        tree = ET.parse("destructive/destructiveChanges.xml")
                        root = tree.getroot()
                        ns = {"sf": "http://soap.sforce.com/2006/04/metadata"}
                    
                        all_clear = True
                        for types in root.findall("sf:types", ns):
                            metadata_type = types.find("sf:name", ns).text
                            for member in types.findall("sf:members", ns):
                                component = member.text
                                if not check_orphan_references(metadata_type, component):
                                    all_clear = False
                    
                        if not all_clear:
                            print("One or more components are referenced by other metadata. Aborting destructive deployment.")
                            sys.exit(1)
                        else:
                            print("No orphaned references found. Safe to proceed with destructive deployment.")
                    
                    if __name__ == "__main__":
                        main()
                    '''.stripIndent()
                    
                    writeFile file: 'check_orphan_refs.py', text: orphanRefScript
                    
                    echo 'Running orphan references validation...'
                    withEnv(["SF_CMD=${env.SF_CMD}", "ALIAS=${env.ALIAS}"]) {
                        def orphanCheckResult = bat(script: "\"${env.PYTHON_EXE}\" check_orphan_refs.py", returnStatus: true)
                        if (orphanCheckResult != 0) {
                            error 'Orphaned references detected. Aborting pipeline.'
                        }
                    }
                    
                    echo 'Orphan references check passed.'
                }
            }
        }
    }
}








