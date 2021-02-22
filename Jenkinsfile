pipeline {
    agent {
        label 'master'
    }
    parameters {
        choice(
            choices: ['core' , 'eks' , 'global'],
            description: 'specify the Infrastructure level to build the module',
            name: 'TFInfraLayer')

    // Add or remove modules in the parameters

        choice(
            choices: ['iam' , 'eks' , 'eks-sg', 'vpc' , 'worker-nodes'],
            description: 'specify the TF module',
            name: 'TFmod')
            
    // Add or remove environments 

        choice(
            choices: ['dev' , 'staging'],
            description: 'specify the environment',
            name: 'TFENV')
    }
    stages {

            // Run terraform init
       
            stage('TF-init') {
                 when {
                      expression { params.TFInfraLayer != 'global' }
                }
                steps {

                    sh '''#!/bin/bash

                            pushd environments/${TFENV}/${TFInfraLayer}
                            terraform init
                            TF_DIR=environments/${TFENV}/${TFInfraLayer}
                            popd
                    '''
                }
            }

            // Run terraform plan

            stage('plan') {
                when {
                      expression { params.TFInfraLayer != 'global' }
                }

                steps {

                    sh '''#!/bin/bash

                        if [ ${TFmod} == "eks" ];
                        then
                           export TF_TARGET_MODULE=module.eks-sg
                        elif [ ${TFmod} == "iam" ];
                        then
                            export TF_TARGET_MODULE=module.eks_iam_global
                        elif [ ${TFmod} == "eks-sg" ];
                        then
                            export TF_TARGET_MODULE=module.eks-sg
                        elif [ ${TFmod} == "vpc" ];
                        then
                            export TF_TARGET_MODULE=module.eks-vpc
                        else
                           export TF_TARGET_MODULE=module.worker_nodes
                        fi          
                        pushd environments/${TFENV}/${TFInfraLayer}
                        [ ! -d .terraform ] && >&2 echo "terraform project is not initialised " && exit 1
                        terraform plan -target=$TF_TARGET_MODULE -out tfplan
                        popd
                    '''
                }
            }

            // Approve or Dismiss the TF apply stage

            stage('Approval') {
                when {
                      expression { params.TFInfraLayer != 'global' }
                }

                steps {
                    script {
                        def userInput = input(id: 'confirm', message: 'Terraform Apply?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
                    }
                }
           }

          // Run Terraform Apply

           stage('TFApply') {
                when {
                      expression { params.TFInfraLayer != 'global' }
                }

                steps {

                    sh '''#!/bin/bash
                        
                        pushd environments/${TFENV}/${TFInfraLayer}
                        [ ! -d .terraform ] && >&2 echo "terraform project is not initialised " && exit 1
                        terraform apply -input=false tfplan
                        popd
                    '''
                }
            }

         // Run Terraform init and plan for IAM Roles

            stage('TF-init&plan-Global') {
                when {
                      expression { params.TFInfraLayer == 'global' }
                }
                steps {
                    sh '''#!/bin/bash
                        pushd environments/${TFInfraLayer}
                        terraform init
                        terraform plan -out tfplan
                        popd
                    '''
                }
            }

        // Approve or Dismiss the TF apply stage

            stage('TF-IAM-Approval') {
                when {
                      expression { params.TFInfraLayer == 'global' }
                }

                steps {
                    script {
                        def userInput = input(id: 'confirm', message: 'Apply Terraform?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
                    }
                }
           }
        // Run Terraform apply for IAM Roles

            stage('TF-IAM-Apply') {
                when {
                      expression { params.TFInfraLayer == 'global' }
                }
                steps {

                    sh '''#!/bin/bash
                        pushd environments/${TFInfraLayer}
                        [ ! -d .terraform ] && >&2 echo "terraform project is not initialised " && exit 1
                        terraform apply -input=false tfplan
                        popd
                    '''
                }
            }

    }
}