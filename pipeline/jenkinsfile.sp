node {
   def commit_id
   stage('Source Code Preparation') {
     checkout scm
     sh "git rev-parse --short HEAD > .git/commit-id"
     commit_id = readFile('.git/commit-id').trim()
   }
   dir ('./app'){
      stage('Unit test') {
        def myTestContainer = docker.image('node:9.11.1')
        myTestContainer.pull()
        myTestContainer.inside {
          sh 'npm install --only=dev'
          sh 'npm test'
        }
      }
      //  stage('Quality Check') {
      //     def sonarqubeScannerHome = tool name: 'sonar', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
      //     withCredentials([string(credentialsId: 'sonar', variable: 'sonarLogin')]) {
      //       sh "${sonarqubeScannerHome}/bin/sonar-scanner -e -Dsonar.host.url=http://sonarqube:9000 -Dsonar.login=${sonarLogin} -Dsonar.projectName=demodevops -Dsonar.projectVersion=${env.BUILD_NUMBER} -Dsonar.projectKey=JS:version0.1 -Dsonar.sources=. -Dsonar.inclusions=*.js,public/*.html,test/*.js"
      //     }
      //   }
      stage('Quality Check') {
          def sonarqubeScannerHome = tool name: 'sonarqube-scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
          withCredentials([string(credentialsId: 'sonar', variable: 'sonarLogin')]) {
            sh "${sonarqubeScannerHome}/bin/sonar-scanner -e -Dsonar.host.url=http://sonarqube:9000 -Dsonar.login=${sonarLogin} -Dsonar.projectName=owaspweb -Dsonar.projectVersion=${env.BUILD_NUMBER} -Dsonar.projectKey=owaspweb -Dsonar.sources=."
        }
      }
      //  stage('Quality Check') {
      //     def scannerHome = tool 'sonarqube-scanner';
      //     withSonarQubeEnv('sonarqube') {
      //     sh "${scannerHome}/bin/sonar-scanner"
      //   }
      //  }
      stage('Security Check') {
          withCredentials([string(credentialsId: 'SRCCLR_API_TOKEN', variable: 'SRCCLR_API_TOKEN')]) {
            sh "curl -sSL https://download.sourceclear.com/ci.sh | sh"
        }
      }
      // stage('Push Docker Image') {            
      //   docker.withRegistry('https://137.116.133.205:8443/v2/', 'DTRcredential') {
      //     def app = docker.build("admin/owaspweb:${commit_id}", '.').push()
      //   }                                     
      // }
      // stage('Deploy to Docker Cluster') {            
      //   sh "commit_id=${commit_id} docker stack deploy --compose-file docker-compose.yml owaspweb"                                    
      // }
   } 
}    