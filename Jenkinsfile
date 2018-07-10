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
      agent {
        dockerfile {
          dir 'build/centos7'
          args '-v $HOME/.m2:/var/maven/.m2 -v $HOME/.m2/settings.xml:/var/maven/.m2/settings.xml -v $HOME/.m2/repository:/var/maven/.m2/repository'
        }
      }
      steps {
        sh 'mvn -Duser.home=/var/maven -Dbuild.dir=/var/maven/build -U -fae -f packages/pom.xml clean install -P !deb'
      }
    }
  }
}