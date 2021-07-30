node {
   stage('SCM checkout'){
        checkout scm
    }
  stage ('Docker build') {
  docker.build('springboot-ecs')
  }
 
  stage ('Docker push') {
  docker.withRegistry('https://234877069070.dkr.ecr.us-east-1.amazonaws.com/springboot-ecs', 'ecr:us-east-1:aws creds') {
    docker.image('springboot-ecs').push('latest')
  }
  }
}
