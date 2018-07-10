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
        stage('Archetypes') {
          steps {
            sh 'mvn -U -f archetypes/pom.xml clean install'
          }
        }
        stage('Plugins') {
          steps {
            sh 'mvn -U -f plugins/pom.xml clean install'
          }
        }
        stage('Products') {
          steps {
            sh 'mvn -U -f products/pom.xml clean install'
          }
        }
        stage('Resources') {
          steps {
            sh 'mvn -U -f resources/pom.xml clean install'
          }
        }
      }
    }
    stage('Build Packages') {
      parallel {
        stage('CentOS 7') {
          agent {
            dockerfile {
              dir 'build/centos7'
              args '-v $HOME/.m2:/var/maven/.m2 -v $HOME/.m2/settings.xml:/var/maven/.m2/settings.xml -v $HOME/.m2/repository:/var/maven/.m2/repository'
            }
          }
          steps {
            sh 'mvn -Duser.home=/var/maven -Dbuild.dir=/var/maven/build -U -fae -f packages/pom.xml clean install -Dproperties.product.file=product-dev.properties -Dproperties.system.file=system-el7-x86_64.properties -P !deb'
          }
        }
        stage('Debian 9') {
          agent {
            dockerfile {
              dir 'build/debian9'
              args '-v $HOME/.m2:/var/maven/.m2 -v $HOME/.m2/settings.xml:/var/maven/.m2/settings.xml -v $HOME/.m2/repository:/var/maven/.m2/repository'
            }
          }
          steps {
            sh 'mvn -Duser.home=/var/maven -Dbuild.dir=/var/maven/build -U -fae -f packages/pom.xml clean install -Dproperties.product.file=product-dev.properties -Dproperties.system.file=system-debian9-amd64.properties -P !rpm'
          }
        }
        stage('Ubuntu 16.04') {
          agent {
            dockerfile {
              dir 'build/ubuntu1604'
              args '-v $HOME/.m2:/var/maven/.m2 -v $HOME/.m2/settings.xml:/var/maven/.m2/settings.xml -v $HOME/.m2/repository:/var/maven/.m2/repository'
            }
          }
          steps {
            sh 'mvn -Duser.home=/var/maven -Dbuild.dir=/var/maven/build -U -fae -f packages/pom.xml clean install -Dproperties.product.file=product-dev.properties -Dproperties.system.file=system-ubuntu1604-amd64.properties -P !rpm'
          }
        }
      }
    }
  }
}