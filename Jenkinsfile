pipeline {
    agent any
    
    stages {
        stage('Checkout Git') {
            steps {
                echo '🎯 PHASE 1: CHECKOUT - Récupération du code source'
                checkout scm
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
                echo '🧪 PHASE 3: TEST - Exécution des tests'
                bat 'mvnw.cmd test'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo '🐳 PHASE 4: DOCKER BUILD - Construction de l image'
                bat 'docker build -t student-management .'
            }
        }
        
        stage('Deploy Docker Container') {
            steps {
                echo '🚀 PHASE 5: DOCKER DEPLOY - Lancement du conteneur'
                bat 'docker stop student-app || echo "Container not running"'
                bat 'docker rm student-app || echo "Container not found"'
                bat 'docker run -d -p 8082:8080 --name student-app student-management'
                echo '🌐 Application déployée sur: http://localhost:8082'
            }
        }
    }
    
    post {
        always {
            echo '📊 PIPELINE CI/CD TERMINÉ'
        }
        success {
            echo '🎉 SUCCÈS: Application Dockerisée et déployée!'
        }
    }
}
