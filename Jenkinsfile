pipeline {
    agent any

    parameters {
        choice(name: 'ACTION', choices: ['deploy', 'destroy'], description: 'Selecciona deploy o destroy')
    }

    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_SESSION_TOKEN = credentials('AWS_SESSION_TOKEN')
        AWS_REGION = 'us-east-1'
    }

    stages {
        stage('Checkout Código') {
            steps {
                git branch: 'main', url: 'https://github.com/Inereaa/LDAP.git'
            }
        }

        stage('Configurar AWS') {
            steps {
                script {
                    bat 'aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID'
                    bat 'aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY'
                    bat 'aws configure set region $AWS_REGION'
                }
            }
        }

        stage('Instalar Terraform') {
            steps {
                script {
                    bat '''
                    cd tf
                    curl -Lo terraform.zip --ssl-no-revoke https://releases.hashicorp.com/terraform/1.4.0/terraform_1.4.0_windows_amd64.zip
                    tar -xf terraform.zip
                    move terraform /usr/local/bin/
                    terraform --version
                    '''
                }
            }
        }

        stage('Terraform Init') {
            steps {
                bat 'cd tf && terraform init'
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'deploy' }
            }
            steps {
                bat 'cd tf && terraform apply -auto-approve'
                bat 'aws s3 cp tf/terraform.tfstate s3://nmr-bucket/terraform.tfstate'
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                bat 'aws s3 cp s3://nmr-bucket/terraform.tfstate tf/terraform.tfstate'
                bat 'cd tf && terraform destroy -auto-approve'
            }
        }
    }
}
