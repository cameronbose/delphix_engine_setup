properties([parameters([string(defaultValue: '10.44.1.119', name: 'dxEngineAddress', trim: true), choice(choices: ['6.0.14.0', '6.0.15.0', '6.0.16.0', '6.0.17.0'], name: 'dxVersion'), choice(choices: ['true', 'false'], name: 'PhoneHomeService'), choice(choices: ['true', 'false'], name: 'UserInterfaceConfig'), choice(choices: ['true', 'false'], name: 'ProxyConfiguration'), choice(choices: ['true', 'false'], name: 'SMTPConfig'), choice(choices: ['true', 'false'], name: 'NTPConfig'), string(defaultValue: 'VIRTUALIZATION', name: 'engineType', trim: true)])])
pipeline { 
    agent any 
    environment { 
        SECRET_CREDS = credentials('delphix-engine-credentials')
    }
    stages { 
        stage('Git Checkout') {
            steps {
                bat 'rmdir /s /q delphix_engine_setup';
                bat 'git clone https://github.com/cameronbose/delphix_engine_setup.git';
            }
        }
        
        stage("Setting up Delphix Engine") { 
            steps {
                bat "python getParameters.py ${params.dxEngineAddress} ${params.dxVersion} ${SECRET_CREDS_USR} ${SECRET_CREDS_PSW} ${params.PhoneHomeService} ${params.UserInterfaceConfig} ${params.ProxyConfiguration} ${params.SMTPConfig} ${params.NTPConfig} ${params.engineType}";    
            }
        } 
    }
    post { 
        always { 
            echo "this will always run!"; 
        }
        success { 
            echo "VDB successfully Provisioned!"; 
        } 
        failure { 
            echo "VDB provisioning has failed - please look at the error logs."; 
        } 
        unstable { 
            echo "Jenkins run was unstable, please check logs."; 
        } 
        changed { 
            echo "VDB provisioning is now successful!"; 
            
        }
    }
}
