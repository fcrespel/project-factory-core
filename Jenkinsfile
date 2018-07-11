pipeline {
  agent any
  parameters {
    string(name: 'product_groupId', defaultValue: 'fr.project-factory.core.products', description: 'Product groupId')
    string(name: 'product_artifactId', defaultValue: 'default', description: 'Product artifactId')
    string(name: 'product_version', defaultValue: '3.4.0-SNAPSHOT', description: 'Product version')
    string(name: 'product_file', defaultValue: 'product-dev.properties', description: 'Product file')
    booleanParam(name: 'build_centos7', defaultValue: true, description: 'Build packages for CentOS 7')
    booleanParam(name: 'build_debian9', defaultValue: true, description: 'Build packages for Debian 9')
    booleanParam(name: 'build_ubuntu1604', defaultValue: true, description: 'Build packages for Ubuntu 16.04')
  }
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
          when {
            beforeAgent true
            expression { params.build_centos7 == true }
          }
          steps {
            sh "mvn -Duser.home=/var/maven -Dbuild.dir=/var/maven/build -U -fae -f packages/pom.xml clean install -Dproperties.product.groupId=${params.product_groupId} -Dproperties.product.artifactId=${params.product_artifactId} -Dproperties.product.version=${params.product_version} -Dproperties.product.file=${params.product_file} -Dproperties.system.file=system-el7-x86_64.properties -P !deb"
          }
        }
        stage('Debian 9') {
          agent {
            dockerfile {
              dir 'build/debian9'
              args '-v $HOME/.m2:/var/maven/.m2 -v $HOME/.m2/settings.xml:/var/maven/.m2/settings.xml -v $HOME/.m2/repository:/var/maven/.m2/repository'
            }
          }
          when {
            beforeAgent true
            expression { params.build_debian9 == true }
          }
          steps {
            sh "mvn -Duser.home=/var/maven -Dbuild.dir=/var/maven/build -U -fae -f packages/pom.xml clean install -Dproperties.product.groupId=${params.product_groupId} -Dproperties.product.artifactId=${params.product_artifactId} -Dproperties.product.version=${params.product_version} -Dproperties.product.file=${params.product_file} -Dproperties.system.file=system-debian9-amd64.properties -P !rpm"
          }
        }
        stage('Ubuntu 16.04') {
          agent {
            dockerfile {
              dir 'build/ubuntu1604'
              args '-v $HOME/.m2:/var/maven/.m2 -v $HOME/.m2/settings.xml:/var/maven/.m2/settings.xml -v $HOME/.m2/repository:/var/maven/.m2/repository'
            }
          }
          when {
            beforeAgent true
            expression { params.build_ubuntu1604 == true }
          }
          steps {
            sh "mvn -Duser.home=/var/maven -Dbuild.dir=/var/maven/build -U -fae -f packages/pom.xml clean install -Dproperties.product.groupId=${params.product_groupId} -Dproperties.product.artifactId=${params.product_artifactId} -Dproperties.product.version=${params.product_version} -Dproperties.product.file=${params.product_file} -Dproperties.system.file=system-ubuntu1604-amd64.properties -P !rpm"
          }
        }
      }
    }
  }
}