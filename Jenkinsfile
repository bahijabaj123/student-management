pipeline {
    agent any

    environment {
        DB_URL = "jdbc:mysql://localhost:3306/studentdb"
        DB_USER = "studentuser"
        DB_PASSWORD = "1234"
    }

    stages {
        stage('Clone') {
            steps {
                git branch: 'main', url: 'https://github.com/bahijabaj123/student-management.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Tests') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Optional: Build Docker') {
            steps {
                sh 'docker build -t student-management:latest .'
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline terminé avec succès !"
        }
        failure {
            echo "🚨 Le pipeline a échoué"
        }
    }
}
