pipeline {
    agent any
    
    stages {
        stage('Checkout Git') {
            steps {
                echo ' Récupération du code source'
            }
        }
        
        stage('Build Maven') {
            steps {
                echo ' BUILD - Compilation du projet'
                bat 'mvnw.cmd clean package -DskipTests'
            }
        }
        
        stage('Tests Unitaires') {
            steps {
                echo 'TEST - Exécution des tests'
                bat 'mvnw.cmd test'
            }
        }
      
        stage('Build Docker Image') {
            steps {
                echo ' BUILD DOCKER - Création de l image'
                bat 'docker build -t student-management .'
            }
        }
        
        stage('Deploy Docker Container') {
            steps {
                echo 'DEPLOY - Lancement du conteneur'
                bat 'docker run -d -p 8080:8080 --name student-app student-management'
            }
        }
    }
    
    post {
        always {
            echo ' PIPELINE CI/CD TERMINÉ'
        }
        success {
            echo 'SUCCÈS: Application Dockerisée et déployée!'
        }
    }
}
