node {
   stage('SCM checkout'){
        checkout scm
    }
  stage ('Docker build') {
  docker.build('sb_app')
  }
 
  stage ('Docker push') {
  docker.withRegistry('234877069070.dkr.ecr.us-east-1.amazonaws.com', 'ecr:us-east-1:ecr-credentials') {
    docker.image('sb_app').push('latest')
  }
  }
}
