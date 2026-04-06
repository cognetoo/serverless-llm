pipeline {
    agent any

    environment {
        IMAGE_NAME    = "neuraldock-llm"
        CONTAINER_NAME = "neuraldock-app"
        APP_PORT      = "5000"
        // Store your Gemini API key as a Jenkins credential (Secret Text) named GEMINI_API_KEY
        GEMINI_API_KEY = "AIzaSyAkXHALrN__eOQHYoBlYgXOn1ptv7U95k4"
    }

    stages {

        stage('Clone Repo') {
            steps {
                echo '📥 Cloning repository from GitHub...'
                // If running inside the repo already, just confirm
                checkout scm
                echo '✅ Repository cloned successfully.'
            }
        }

        stage('Build App') {
            steps {
                echo '🔍 Validating project structure...'
                sh '''
                    echo "── Project files ──"
                    ls -la
                    echo ""
                    echo "── Python syntax check ──"
                    python3 -c "import ast, sys; ast.parse(open('app.py').read()); print('app.py syntax OK')"
                    echo "── requirements.txt ──"
                    cat requirements.txt
                '''
                echo '✅ Build validation complete.'
            }
        }

        stage('Docker Build') {
            steps {
                echo '🐳 Building Docker image...'
                sh '''
                    # Stop and remove old container if running
                    docker stop ${CONTAINER_NAME} 2>/dev/null || true
                    docker rm   ${CONTAINER_NAME} 2>/dev/null || true

                    # Remove old image to force fresh build
                    docker rmi  ${IMAGE_NAME}:latest 2>/dev/null || true

                    # Build fresh image
                    docker build -t ${IMAGE_NAME}:latest .

                    echo ""
                    echo "── Built image ──"
                    docker images ${IMAGE_NAME}:latest
                '''
                echo '✅ Docker image built successfully.'
            }
        }

        stage('Run Container') {
            steps {
                echo '🚀 Starting Docker container...'
                sh '''
                    docker run -d \
                        --name  ${CONTAINER_NAME} \
                        -p      ${APP_PORT}:5000 \
                        -e      GEMINI_API_KEY=${GEMINI_API_KEY} \
                        --restart unless-stopped \
                        ${IMAGE_NAME}:latest

                    echo ""
                    echo "── Container status ──"
                    docker ps --filter name=${CONTAINER_NAME}

                    echo ""
                    echo "── Waiting 3s for app to start ──"
                    sleep 3

                    echo "── Health check ──"
                    curl -sf http://localhost:${APP_PORT}/ && echo "✅ App is UP at http://localhost:${APP_PORT}" || echo "⚠ App not responding yet — check logs"

                    echo ""
                    echo "── Last 20 container logs ──"
                    docker logs --tail 20 ${CONTAINER_NAME}
                '''
                echo '✅ Container is running!'
            }
        }
    }

    post {
        success {
            echo '''
╔══════════════════════════════════════════╗
║   ✅  PIPELINE SUCCEEDED                ║
║   App running at http://localhost:5000  ║
╚══════════════════════════════════════════╝
            '''
        }
        failure {
            echo '❌ Pipeline failed. Check stage logs above.'
            sh '''
                echo "── Container logs (if any) ──"
                docker logs ${CONTAINER_NAME} 2>/dev/null || echo "No container logs available"
            '''
        }
    }
}
