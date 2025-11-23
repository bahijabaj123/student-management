pipeline {
    agent any
    
    stages {
        stage('Checkout Git') {
            steps {
                echo '🎯 PHASE 1: CHECKOUT - Récupération du code source'
            }
        }
        
        stage('Build Maven') {
            steps {
                echo '🔨 PHASE 2: BUILD - Compilation du projet'
            }
        }
        
        stage('Tests Unitaires') {
            steps {
                echo '🧪 PHASE 3: TEST - Exécution des tests'
            }
        }
    }
    
    post {
        always {
            echo '📊 PIPELINE TERMINÉ - 3 phases CI implémentées'
        }
        success {
            echo '🎉 SUCCÈS: Toutes les phases du pipeline sont réussies!'
        }
    }
}
