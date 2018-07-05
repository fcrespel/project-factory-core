pipeline {
  agent any
  stages {
    stage('Build Parent') {
      steps {
        sh 'mvn -U -N clean install'
      }
    }
    stage('Build Modules') {
      parallel {
        stage('Build Archetypes') {
          steps {
            sh 'mvn -U -f archetypes/pom.xml clean install'
          }
        }
        stage('Build Plugins') {
          steps {
            sh 'mvn -U -f plugins/pom.xml clean install'
          }
        }
        stage('Build Products') {
          steps {
            sh 'mvn -U -f products/pom.xml clean install'
          }
        }
        stage('Build Resources') {
          steps {
            sh 'mvn -U -f resources/pom.xml clean install'
          }
        }
      }
    }
    stage('Build Packages') {
      steps {
        sh 'mvn -U -fae -f packages/pom.xml clean install -P !deb'
      }
    }
  }
}