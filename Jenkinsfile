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
        S3_BUCKET = 'nmr-bucket'
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
                    sh 'aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID'
                    sh 'aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY'
                    sh 'aws configure set region $AWS_REGION'
                }
            }
        }

        stage('Instalar Terraform') {
            steps {
                script {
                    sh '''
                    cd tf
                    curl -Lo terraform.zip https://releases.hashicorp.com/terraform/1.4.0/terraform_1.4.0_linux_amd64.zip
                    unzip terraform.zip
                    sudo mv terraform /usr/local/bin/
                    terraform --version
                    '''
                }
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'cd tf && terraform init'
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'deploy' }
            }
            steps {
                sh 'cd tf && terraform apply -auto-approve'
                sh 'aws s3 cp tf/terraform.tfstate s3://$S3_BUCKET/terraform.tfstate'
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                sh 'aws s3 cp s3://$S3_BUCKET/terraform.tfstate tf/terraform.tfstate'
                sh 'cd tf && terraform destroy -auto-approve'
            }
        }
    }
}
