pipeline {
  agent any
  parameters {
    string(name: 'product_groupId', defaultValue: 'fr.project-factory.core.products', description: 'Product groupId')
    string(name: 'product_artifactId', defaultValue: 'default', description: 'Product artifactId')
    string(name: 'product_version', defaultValue: '3.4.0-SNAPSHOT', description: 'Product version')
    string(name: 'product_file', defaultValue: 'product-dev.properties', description: 'Product file')
    string(name: 'mvn_opts', defaultValue: '-U', description: 'Maven build options')
    string(name: 'mvn_goals', defaultValue: 'clean install', description: 'Maven build goals')
    booleanParam(name: 'build_centos7', defaultValue: true, description: 'Build packages for CentOS 7')
    booleanParam(name: 'build_debian9', defaultValue: true, description: 'Build packages for Debian 9')
    booleanParam(name: 'build_opensuse423', defaultValue: true, description: 'Build packages for openSUSE 42.3')
    booleanParam(name: 'build_ubuntu1604', defaultValue: true, description: 'Build packages for Ubuntu 16.04')
  }
  stages {
    stage('Build Parent') {
      steps {
        withMaven() {
          sh "mvn -N ${params.mvn_opts} ${params.mvn_goals}"
        }
      }
    }
    stage('Build Modules') {
      parallel {
        stage('Archetypes') {
          steps {
            withMaven() {
              sh "mvn -f archetypes/pom.xml ${params.mvn_opts} ${params.mvn_goals}"
            }
          }
        }
        stage('Plugins') {
          steps {
            withMaven() {
              sh "mvn -f plugins/pom.xml ${params.mvn_opts} ${params.mvn_goals}"
            }
          }
        }
        stage('Products') {
          steps {
            withMaven() {
              sh "mvn -f products/pom.xml ${params.mvn_opts} ${params.mvn_goals}"
            }
          }
        }
        stage('Resources') {
          steps {
            withMaven() {
              sh "mvn -f resources/pom.xml ${params.mvn_opts} ${params.mvn_goals}"
            }
          }
        }
      }
    }
    stage('Build Docker images') {
      parallel {
        stage('CentOS 7') {
          agent { label 'docker' }
          when {
            expression { params.build_centos7 == true }
          }
          steps {
            script {
              def image = docker.build('projectfactory/build:centos7', 'build/centos7')
            }
          }
        }
        stage('Debian 9') {
          agent { label 'docker' }
          when {
            expression { params.build_debian9 == true }
          }
          steps {
            script {
              def image = docker.build('projectfactory/build:debian9', 'build/debian9')
            }
          }
        }
        stage('openSUSE 42.3') {
          agent { label 'docker' }
          when {
            expression { params.build_opensuse423 == true }
          }
          steps {
            script {
              def image = docker.build('projectfactory/build:opensuse423', 'build/opensuse423')
            }
          }
        }
        stage('Ubuntu 16.04') {
          agent { label 'docker' }
          when {
            expression { params.build_ubuntu1604 == true }
          }
          steps {
            script {
              def image = docker.build('projectfactory/build:ubuntu1604', 'build/ubuntu1604')
            }
          }
        }
      }
    }
    stage('Build Packages') {
      parallel {
        stage('CentOS 7') {
          agent {
            docker {
              image 'projectfactory/build:centos7'
              args '-v $HOME/.m2:/var/maven/.m2 -v $HOME/.m2/settings.xml:/var/maven/.m2/settings.xml -v $HOME/.m2/repository:/var/maven/.m2/repository -v $HOME/.gnupg:/var/maven/.gnupg'
            }
          }
          when {
            beforeAgent true
            expression { params.build_centos7 == true }
          }
          steps {
            sh "/bin/bash -l -c 'mvn -Duser.home=/var/maven -Dbuild.dir=/var/maven/build -Dgpg.homedir=/var/maven/.gnupg -fae -f packages/pom.xml ${params.mvn_opts} ${params.mvn_goals} -Dproperties.product.groupId=${params.product_groupId} -Dproperties.product.artifactId=${params.product_artifactId} -Dproperties.product.version=${params.product_version} -Dproperties.product.file=${params.product_file} -Dproperties.system.file=system-el7-x86_64.properties -P !deb'"
          }
        }
        stage('Debian 9') {
          agent {
            docker {
              image 'projectfactory/build:debian9'
              args '-v $HOME/.m2:/var/maven/.m2 -v $HOME/.m2/settings.xml:/var/maven/.m2/settings.xml -v $HOME/.m2/repository:/var/maven/.m2/repository -v $HOME/.gnupg:/var/maven/.gnupg'
            }
          }
          when {
            beforeAgent true
            expression { params.build_debian9 == true }
          }
          steps {
            sh "/bin/bash -l -c 'mvn -Duser.home=/var/maven -Dbuild.dir=/var/maven/build -Dgpg.homedir=/var/maven/.gnupg -fae -f packages/pom.xml ${params.mvn_opts} ${params.mvn_goals} -Dproperties.product.groupId=${params.product_groupId} -Dproperties.product.artifactId=${params.product_artifactId} -Dproperties.product.version=${params.product_version} -Dproperties.product.file=${params.product_file} -Dproperties.system.file=system-debian9-amd64.properties -P !rpm'"
          }
        }
        stage('openSUSE 42.3') {
          agent {
            docker {
              image 'projectfactory/build:opensuse423'
              args '-v $HOME/.m2:/var/maven/.m2 -v $HOME/.m2/settings.xml:/var/maven/.m2/settings.xml -v $HOME/.m2/repository:/var/maven/.m2/repository -v $HOME/.gnupg:/var/maven/.gnupg'
            }
          }
          when {
            beforeAgent true
            expression { params.build_opensuse423 == true }
          }
          steps {
            sh "/bin/bash -l -c 'mvn -Duser.home=/var/maven -Dbuild.dir=/var/maven/build -Dgpg.homedir=/var/maven/.gnupg -fae -f packages/pom.xml ${params.mvn_opts} ${params.mvn_goals} -Dproperties.product.groupId=${params.product_groupId} -Dproperties.product.artifactId=${params.product_artifactId} -Dproperties.product.version=${params.product_version} -Dproperties.product.file=${params.product_file} -Dproperties.system.file=system-opensuse423-x86_64.properties -P !deb'"
          }
        }
        stage('Ubuntu 16.04') {
          agent {
            docker {
              image 'projectfactory/build:ubuntu1604'
              args '-v $HOME/.m2:/var/maven/.m2 -v $HOME/.m2/settings.xml:/var/maven/.m2/settings.xml -v $HOME/.m2/repository:/var/maven/.m2/repository -v $HOME/.gnupg:/var/maven/.gnupg'
            }
          }
          when {
            beforeAgent true
            expression { params.build_ubuntu1604 == true }
          }
          steps {
            sh "/bin/bash -l -c 'mvn -Duser.home=/var/maven -Dbuild.dir=/var/maven/build -Dgpg.homedir=/var/maven/.gnupg -fae -f packages/pom.xml ${params.mvn_opts} ${params.mvn_goals} -Dproperties.product.groupId=${params.product_groupId} -Dproperties.product.artifactId=${params.product_artifactId} -Dproperties.product.version=${params.product_version} -Dproperties.product.file=${params.product_file} -Dproperties.system.file=system-ubuntu1604-amd64.properties -P !rpm'"
          }
        }
      }
    }
  }
}