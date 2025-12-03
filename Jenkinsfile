pipeline {
    agent any

    environment {
        // Infos pour MySQL
        MYSQL_USER = 'jenkins'
        MYSQL_PASS = 'jenkinspass'
        MYSQL_DB   = 'studentdb'
        MYSQL_HOST = 'localhost'
    }

    stages {

        stage('Checkout Git') {
            steps {
                echo "Cloning the Git repository..."
                git branch: 'main', url: 'https://github.com/ton-repo.git'
            }
        }

        stage('Build') {
            steps {
                echo "Building the project..."
                // Exemple pour projet Java avec Maven
                sh 'mvn clean package'
            }
        }

        stage('Test MySQL Connection') {
            steps {
                echo "Testing MySQL database..."
                sh """
                    mysql -u $MYSQL_USER -p$MYSQL_PASS -h $MYSQL_HOST $MYSQL_DB <<EOF
                    SHOW TABLES;
EOF
                """
            }
        }

        stage('Run SQL Script') {
            steps {
                echo "Running SQL test script..."
                sh "mysql -u $MYSQL_USER -p$MYSQL_PASS -h $MYSQL_HOST $MYSQL_DB < test_db.sql"
            }
        }

    }

    post {
        success {
            echo "Pipeline finished successfully ✅"
        }
        failure {
            echo "Pipeline failed ❌"
        }
    }
}
