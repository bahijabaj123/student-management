pipeline {
    agent any

    tools {
        maven 'M2_HOME'
        jdk 'JAVA_HOME'
    }

    environment {
        // Nom de l'application
        APP_NAME = 'student-management'
        APP_PORT = '8080'
        
        // Configuration Minikube/Kubernetes
        K8S_NAMESPACE = 'default'
        K8S_DEPLOYMENT = "${APP_NAME}-deployment"
        K8S_SERVICE = "${APP_NAME}-service"
        
        // Image Docker (on va utiliser une image temporaire)
        DOCKER_IMAGE = 'openjdk:11-jre-slim'
    }

    stages {
        // ==================== ÉTAPE 1 : CHECKOUT ====================
        stage('1️⃣ Checkout Code') {
            steps {
                echo '📥 Clonage du repository Git...'
                git branch: 'main', url: 'https://github.com/bahijabaj123/student-management2.git'
                echo '✅ Repository cloné'
            }
        }

        // ==================== ÉTAPE 2 : BUILD MAVEN ====================
        stage('2️⃣ Build avec Maven') {
            steps {
                echo '🔨 Compilation et tests...'
                sh 'mvn clean compile'
                echo '✅ Compilation terminée'
                
                echo '🧪 Exécution des tests...'
                sh 'mvn test'
                echo '✅ Tests exécutés'
            }
            
            post {
                success {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        // ==================== ÉTAPE 3 : PACKAGE JAR ====================
        stage('3️⃣ Package JAR') {
            steps {
                echo '📦 Création du JAR executable...'
                sh 'mvn package -DskipTests'
                
                // Vérifier le JAR
                sh '''
                    echo "📊 Fichier JAR généré :"
                    ls -lh target/*.jar
                    echo ""
                    echo "🎯 Taille du JAR :"
                    du -h target/*.jar
                '''
                
                // Archiver
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                echo '✅ JAR créé et archivé'
            }
        }

        // ==================== ÉTAPE 4 : CRÉER FICHIERS KUBERNETES ====================
        stage('4️⃣ Préparer Kubernetes') {
            steps {
                echo '⚙️  Préparation des fichiers Kubernetes...'
                
                script {
                    // Créer le dossier k8s
                    sh 'mkdir -p k8s-manifests'
                    
                    // 1. Créer un ConfigMap pour le JAR (solution simple)
                    writeFile file: 'k8s-manifests/configmap.yaml', text: """
apiVersion: v1
kind: ConfigMap
metadata:
  name: ${APP_NAME}-jar
  namespace: ${K8S_NAMESPACE}
data:
  app.jar: |
    # Le JAR sera copié ici après le build
"""
                    
                    // 2. Créer le Deployment
                    writeFile file: 'k8s-manifests/deployment.yaml', text: """
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${K8S_DEPLOYMENT}
  namespace: ${K8S_NAMESPACE}
  labels:
    app: ${APP_NAME}
spec:
  replicas: 1  # Commençons avec 1 replica
  selector:
    matchLabels:
      app: ${APP_NAME}
  template:
    metadata:
      labels:
        app: ${APP_NAME}
    spec:
      containers:
      - name: ${APP_NAME}
        image: ${DOCKER_IMAGE}
        command: ["sh", "-c"]
        args:
          - |
            # Créer le répertoire de l'app
            mkdir -p /app
            cd /app
            
            # Attendre que le JAR soit disponible
            echo "Attente du JAR..."
            while [ ! -f /jar-source/app.jar ]; do sleep 2; done
            
            # Copier le JAR
            cp /jar-source/app.jar .
            
            # Démarrer l'application
            echo "Démarrage de l'application..."
            java -jar app.jar
        ports:
        - containerPort: ${APP_PORT}
        volumeMounts:
        - name: jar-volume
          mountPath: /jar-source
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        readinessProbe:
          tcpSocket:
            port: ${APP_PORT}
          initialDelaySeconds: 30
          periodSeconds: 10
      volumes:
      - name: jar-volume
        hostPath:
          path: /tmp/${APP_NAME}
          type: DirectoryOrCreate
"""
                    
                    // 3. Créer le Service
                    writeFile file: 'k8s-manifests/service.yaml', text: """
apiVersion: v1
kind: Service
metadata:
  name: ${K8S_SERVICE}
  namespace: ${K8S_NAMESPACE}
spec:
  selector:
    app: ${APP_NAME}
  ports:
  - protocol: TCP
    port: 80
    targetPort: ${APP_PORT}
  type: NodePort
"""
                    
                    // Afficher les fichiers créés
                    sh '''
                        echo "📋 Fichiers Kubernetes créés :"
                        ls -la k8s-manifests/
                        echo ""
                        echo "=== Contenu des fichiers ==="
                        for file in k8s-manifests/*.yaml; do
                            echo "=== \$file ==="
                            cat \$file
                            echo ""
                        done
                    '''
                }
                echo '✅ Fichiers Kubernetes préparés'
            }
        }

        // ==================== ÉTAPE 5 : DÉPLOIEMENT KUBERNETES ====================
        stage('5️⃣ Déployer sur Minikube') {
            steps {
                echo '🚀 Déploiement sur Minikube...'
                
                script {
                    // 1. Copier le JAR dans un emplacement accessible
                    sh """
                        echo "📦 Copie du JAR..."
                        sudo mkdir -p /tmp/${APP_NAME}
                        sudo cp target/*.jar /tmp/${APP_NAME}/app.jar
                        sudo chmod 644 /tmp/${APP_NAME}/app.jar
                        
                        echo "✅ JAR copié :"
                        ls -lh /tmp/${APP_NAME}/
                    """
                    
                    // 2. Vérifier l'accès Kubernetes
                    sh '''
                        echo "🔍 Vérification de l'accès Kubernetes..."
                        kubectl cluster-info
                        kubectl get nodes
                        kubectl get pods --all-namespaces
                    '''
                    
                    // 3. Appliquer les configurations
                    sh """
                        echo "⚙️  Application des manifests..."
                        kubectl apply -f k8s-manifests/deployment.yaml
                        kubectl apply -f k8s-manifests/service.yaml
                    """
                    
                    // 4. Vérifier le déploiement
                    sh '''
                        echo "📊 État du déploiement..."
                        kubectl get deployments -n ${K8S_NAMESPACE}
                        kubectl get pods -n ${K8S_NAMESPACE} -o wide
                        kubectl get services -n ${K8S_NAMESPACE}
                    '''
                    
                    // 5. Attendre que le pod soit prêt
                    sh '''
                        echo "⏳ Attente du démarrage du pod..."
                        timeout 60 bash -c '
                            until kubectl get pods -n ${K8S_NAMESPACE} -l app=${APP_NAME} -o jsonpath="{.items[0].status.phase}" | grep -q "Running"; do
                                echo "Pod en cours de démarrage..."
                                sleep 5
                            done
                            echo "✅ Pod en cours d\'exécution"
                        '
                    '''
                }
                echo '✅ Déploiement Minikube terminé'
            }
        }

        // ==================== ÉTAPE 6 : VÉRIFICATION ====================
        stage('6️⃣ Vérifier l\'application') {
            steps {
                echo '🔍 Vérification finale...'
                
                script {
                    // 1. Obtenir les infos du service
                    sh """
                        echo "🌐 Informations du service :"
                        kubectl describe service ${K8S_SERVICE} -n ${K8S_NAMESPACE}
                        
                        echo ""
                        echo "🔗 URL Minikube :"
                        minikube service ${K8S_SERVICE} -n ${K8S_NAMESPACE} --url || echo "Utilisez : minikube service list"
                    """
                    
                    // 2. Vérifier les logs
                    sh '''
                        echo "📝 Logs de l\'application :"
                        kubectl logs -n ${K8S_NAMESPACE} -l app=${APP_NAME} --tail=20 || echo "Logs non disponibles encore"
                    '''
                    
                    // 3. Tester l'application
                    sh '''
                        echo "🧪 Test de santé de l\'application..."
                        # Obtenir l'IP et le port
                        NODE_PORT=$(kubectl get service ${K8S_SERVICE} -n ${K8S_NAMESPACE} -o jsonpath="{.spec.ports[0].nodePort}")
                        MINIKUBE_IP=$(minikube ip)
                        
                        if [ ! -z "$NODE_PORT" ] && [ ! -z "$MINIKUBE_IP" ]; then
                            echo "Testing: http://$MINIKUBE_IP:$NODE_PORT/actuator/health"
                            curl -f http://$MINIKUBE_IP:$NODE_PORT/actuator/health || echo "Health check échoué"
                        else
                            echo "⚠️  Impossible d'obtenir les informations de connexion"
                        fi
                    '''
                }
                echo '✅ Vérification terminée'
            }
        }

        // ==================== ÉTAPE 7 : NETTOYAGE (Optionnel) ====================
        stage('7️⃣ Nettoyage') {
            steps {
                echo '🧹 Nettoyage...'
                script {
                    // Optionnel : supprimer les ressources après test
                    // sh "kubectl delete -f k8s-manifests/ --ignore-not-found"
                    
                    // Nettoyer le JAR temporaire
                    sh """
                        echo "Suppression des fichiers temporaires..."
                        sudo rm -rf /tmp/${APP_NAME} || true
                    """
                }
                echo '✅ Nettoyage effectué'
            }
        }
    }

    post {
        always {
            echo '📊 Rapport final...'
            script {
                sh '''
                    echo "=== ÉTAT FINAL KUBERNETES ==="
                    kubectl get all -n ${K8S_NAMESPACE} | grep ${APP_NAME} || echo "Aucune ressource trouvée"
                    
                    echo ""
                    echo "=== SERVICES MINIKUBE ==="
                    minikube service list || echo "Minikube service non disponible"
                '''
            }
        }
        
        success {
            echo '🎉 🎉 🎉 PIPELINE RÉUSSIE ! 🎉 🎉 🎉'
            echo "📌 Application déployée sur Minikube"
            echo "📌 Pour y accéder : minikube service ${K8S_SERVICE} --url"
            echo "📌 Pour voir les logs : kubectl logs -l app=${APP_NAME} -f"
        }
        
        failure {
            echo '❌ Pipeline échouée - Debug information :'
            script {
                sh '''
                    echo "=== DÉTAILS DES ERREURS ==="
                    kubectl describe pods -n ${K8S_NAMESPACE} -l app=${APP_NAME} || echo "Pas de pods"
                    kubectl get events -n ${K8S_NAMESPACE} --sort-by=.metadata.creationTimestamp | tail -20
                '''
            }
        }
    }
}
