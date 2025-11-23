pipeline {
    agent any
    
    stages {
        stage('Checkout Git') {
            steps {
                echo '🎯 PHASE 1: CHECKOUT - Récupération du code source'
                checkout scm
            }
        }
        
        stage('Build et Package') {
            steps {
                echo '🔨 PHASE 2: BUILD - Compilation et création du JAR'
                bat 'mvnw.cmd clean package -DskipTests'
            }
        }
        
        stage('Tests Unitaires') {
            steps {
                echo '🧪 PHASE 3: TEST - Exécution des tests'
                bat 'mvnw.cmd test'
            }
        }
        
        stage('Archive JAR') {
            steps {
                echo '📦 ARCHIVAGE - Sauvegarde du JAR généré'
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }
    }
    
    post {
        always {
            echo '📊 PIPELINE TERMINÉ - JAR généré avec succès!'
        }
        success {
            echo '🎉 SUCCÈS: Application Spring Boot packagée!'
            echo '📁 Le JAR est disponible dans les artifacts du build'
        }
    }
}
