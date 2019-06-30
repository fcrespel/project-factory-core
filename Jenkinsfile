pipeline {
  agent { label 'docker' }
  parameters {
    string(name: 'product_groupId', defaultValue: 'fr.project-factory.core.products', description: 'Product groupId')
    string(name: 'product_artifactId', defaultValue: 'default', description: 'Product artifactId')
    string(name: 'product_version', defaultValue: '3.4.0', description: 'Product version')
    string(name: 'product_file', defaultValue: 'product-dev.properties', description: 'Product file')
    string(name: 'maven_opts', defaultValue: '', description: 'Maven environment options')
    string(name: 'maven_cli_opts', defaultValue: '-U -B -s .mvn/settings.xml', description: 'Maven CLI options')
    string(name: 'maven_goals', defaultValue: 'clean install', description: 'Maven build goals')
    string(name: 'maven_repo_creds', defaultValue: 'project-factory-maven-repo-creds', description: 'Maven distribution repository credentials')
    string(name: 'docker_repo', defaultValue: 'projectfactory', description: 'Docker build image repository')
    string(name: 'docker_image', defaultValue: 'build', description: 'Docker build image name')
    booleanParam(name: 'build_centos7', defaultValue: true, description: 'Build packages for CentOS 7')
    booleanParam(name: 'build_debian9', defaultValue: true, description: 'Build packages for Debian 9')
    booleanParam(name: 'build_opensuse423', defaultValue: true, description: 'Build packages for openSUSE 42.3')
    booleanParam(name: 'build_ubuntu1604', defaultValue: true, description: 'Build packages for Ubuntu 16.04')
  }
  environment {
    MAVEN_OPTS = "${params.maven_opts}"
    MAVEN_REPO_CREDS = credentials("${params.maven_repo_creds}")
  }
  stages {
    stage('Build Parent') {
      steps {
        sh "./mvnw -N ${params.maven_cli_opts} ${params.maven_goals}"
      }
    }
    stage('Build Modules') {
      parallel {
        stage('Archetypes') {
          steps {
            sh "./mvnw -f archetypes/pom.xml ${params.maven_cli_opts} ${params.maven_goals}"
          }
        }
        stage('Plugins') {
          steps {
            sh "./mvnw -f plugins/pom.xml ${params.maven_cli_opts} ${params.maven_goals}"
          }
        }
        stage('Products') {
          steps {
            sh "./mvnw -f products/pom.xml ${params.maven_cli_opts} ${params.maven_goals}"
          }
        }
        stage('Resources') {
          steps {
            sh "./mvnw -f resources/pom.xml ${params.maven_cli_opts} ${params.maven_goals}"
          }
        }
      }
    }
    stage('Build Packages') {
      parallel {
        stage('CentOS 7') {
          agent {
            docker {
              image "${params.docker_repo}/${params.docker_image}:centos7"
              args '-v $HOME/.m2:/var/maven/.m2 -v $HOME/.m2/repository:/var/maven/.m2/repository -v $HOME/.gnupg:/var/maven/.gnupg'
            }
          }
          when {
            beforeAgent true
            expression { params.build_centos7 == true }
          }
          steps {
            sh "/bin/bash -l -c './mvnw -Duser.home=/var/maven -Dbuild.dir=/var/maven/build -Dgpg.homedir=/var/maven/.gnupg -fae -f packages/pom.xml ${params.maven_cli_opts} ${params.maven_goals} -Dproperties.product.groupId=${params.product_groupId} -Dproperties.product.artifactId=${params.product_artifactId} -Dproperties.product.version=${params.product_version} -Dproperties.product.file=${params.product_file} -Dproperties.system.file=system-el7-x86_64.properties -P !deb'"
          }
        }
        stage('Debian 9') {
          agent {
            docker {
              image "${params.docker_repo}/${params.docker_image}:debian9"
              args '-v $HOME/.m2:/var/maven/.m2 -v $HOME/.m2/repository:/var/maven/.m2/repository -v $HOME/.gnupg:/var/maven/.gnupg'
            }
          }
          when {
            beforeAgent true
            expression { params.build_debian9 == true }
          }
          steps {
            sh "/bin/bash -l -c './mvnw -Duser.home=/var/maven -Dbuild.dir=/var/maven/build -Dgpg.homedir=/var/maven/.gnupg -fae -f packages/pom.xml ${params.maven_cli_opts} ${params.maven_goals} -Dproperties.product.groupId=${params.product_groupId} -Dproperties.product.artifactId=${params.product_artifactId} -Dproperties.product.version=${params.product_version} -Dproperties.product.file=${params.product_file} -Dproperties.system.file=system-debian9-amd64.properties -P !rpm'"
          }
        }
        stage('openSUSE 42.3') {
          agent {
            docker {
              image "${params.docker_repo}/${params.docker_image}:opensuse423"
              args '-v $HOME/.m2:/var/maven/.m2 -v $HOME/.m2/repository:/var/maven/.m2/repository -v $HOME/.gnupg:/var/maven/.gnupg'
            }
          }
          when {
            beforeAgent true
            expression { params.build_opensuse423 == true }
          }
          steps {
            sh "/bin/bash -l -c './mvnw -Duser.home=/var/maven -Dbuild.dir=/var/maven/build -Dgpg.homedir=/var/maven/.gnupg -fae -f packages/pom.xml ${params.maven_cli_opts} ${params.maven_goals} -Dproperties.product.groupId=${params.product_groupId} -Dproperties.product.artifactId=${params.product_artifactId} -Dproperties.product.version=${params.product_version} -Dproperties.product.file=${params.product_file} -Dproperties.system.file=system-opensuse423-x86_64.properties -P !deb'"
          }
        }
        stage('Ubuntu 16.04') {
          agent {
            docker {
              image "${params.docker_repo}/${params.docker_image}:ubuntu1604"
              args '-v $HOME/.m2:/var/maven/.m2 -v $HOME/.m2/repository:/var/maven/.m2/repository -v $HOME/.gnupg:/var/maven/.gnupg'
            }
          }
          when {
            beforeAgent true
            expression { params.build_ubuntu1604 == true }
          }
          steps {
            sh "/bin/bash -l -c './mvnw -Duser.home=/var/maven -Dbuild.dir=/var/maven/build -Dgpg.homedir=/var/maven/.gnupg -fae -f packages/pom.xml ${params.maven_cli_opts} ${params.maven_goals} -Dproperties.product.groupId=${params.product_groupId} -Dproperties.product.artifactId=${params.product_artifactId} -Dproperties.product.version=${params.product_version} -Dproperties.product.file=${params.product_file} -Dproperties.system.file=system-ubuntu1604-amd64.properties -P !rpm'"
          }
        }
      }
    }
  }
}
