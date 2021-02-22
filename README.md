# tf-eks-deployment

Provision AWS EKS  Infrastructure Environment using Terraform and Jenkins

Tools/Cloud Services  used

    AWS EKS
    AWS s3
    AWS DynamoDB
    Terraform
    Jenkins

Project Structure  ---- Environments

                            ├── dev
                            │   ├── core
                            │   │   ├── main.tf
                            │   │   ├── outputs.tf
                            │   │   ├── providers.tf
                            │   │   ├── terraform.tf 
                            │   │   └── variables.tf
                            │   └── eks
                            │       ├── main.tf
                            │       ├── outputs.tf
                            │       ├── providers.tf
                            │       ├── terraform.tf
                            │       └── variables.tf
                            ├── global
                            │   ├── main.tf
                            │   ├── outputs.tf
                            │   ├── providers.tf
                            │   ├── terraform.tf
                            │   └── variables.tf
                            └── staging
                                ├── core
                                │   ├── main.tf
                                │   ├── outputs.tf
                                │   ├── providers.tf
                                │   ├── terraform.tf
                                │   └── variables.tf
                                └── eks
                                    ├── main.tf
                                    ├── outputs.tf
                                    ├── providers.tf
                                    ├── terraform.tf
                                    └── variables.tf


Project Structure  ---- Module

                                ├── eks
                                │   ├── eks-cluster.tf
                                │   ├── outputs.tf
                                │   └── vars.tf
                                ├── eks-sg
                                │   ├── master-sg.tf
                                │   ├── outputs.tf
                                │   ├── pub_ip_workstation.tf
                                │   ├── vars.tf
                                │   └── worker-nodes-sg.tf
                                ├── global-iam
                                │   ├── EKS-ControlPlane-role.tf
                                │   ├── EKS-WorkerNodes-role.tf
                                │   ├── outputs.tf
                                │   └── vars.tf
                                ├── vpc
                                │   ├── elastic-ips.tf
                                │   ├── internet-gateway.tf
                                │   ├── nat-gateways.tf
                                │   ├── outputs.tf
                                │   ├── route-table-association.tf
                                │   ├── routing-tables.tf
                                │   ├── subnets.tf
                                │   ├── vars.tf
                                │   └── vpc.tf
                                └── worker-nodes
                                    ├── eks-worker-nodes.tf
                                    └── vars.tf


This project is organized on the followung structure:

1.  environments: Contain the root module of the terraform deployment and divided as dev and staging 

     Main development environments used in this project : dev,staging

     Note// Create new environment by adding a new folder and add required variable files
     

2.  layers: eks, common, core. Each sub-directory will be used to call a group of Terraform modules sourcing from module/ directory

  Layer common - To provision required aws roles for the EKS and nodes

  Layer core   - To provision aws vpc, subnets and all required vpc resources + security groups

  Layer eks    - To provision aws EKS and node groups

Note//  For development purpose , I hosted the module repo within this Github project, use separate github projects for each module in production


3. Jenkinsfile: A modular approch to deploy terraform modules with a Declarative Jenkins pipelinefile

4. pre-terraform.sh: Shell script needed to bootstrap the project: create an s3 bucket to store terraform state files, create dynamoDB table for terraform state lock and checking the existency.


# Access to kubernetes cluster

Once the cluster is ready and worker nodes are up and running, you can use below aws cli command to merge the kubeconfig to local system

       aws eks --region <<region>>  update-kubeconfig --name <<eks-cluster-name>>

# Prerequisites for accessing eks cluster

    A local workstation configured with aws cli with necessay IAM permission for kubernetes cluster access. Initially, we need the IAM user which we used to create the eks cluster and its credential to access kubernetes cluster, afterwards we can add additional IAM users in the aws-auth-cm.yaml and apply.

    kubectl edit -n kube-system configmap/aws-auth

    we can add aws IAM users to map with kubernetes RBAC users, groups.

example :  
    
    Create  user user1 in aws console 

    Add to aws-auth configmap user1 user ARN.   



                      mapUsers: |
                        - userarn: arn:aws:iam::<<aws-account-id>>:user/user1
                          username: user1
                          groups: 
                          - reader



-----------------------------------------------------------------------

# To deploy the AWS Load Balancer Controller to an Amazon EKS cluster

We can automate the below steps either via bash script or terraform with helm and kubernetes providers.

 Determine if there already a OIDC provider for the cluster if not create it
 1. aws eks describe-cluster --name <cluster_name> --query "cluster.identity.oidc.issuer" --output text

 2. Create an iam policy for the AWS Load balancer controller that allows it to make calls to AWS APIs on your behalf.

    >> curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.1.2/docs/install/iam_policy.json

    >> aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

  3. Create an IAM role and annotate the Kubernetes service account named aws-load-balancer-controller in the kube-system namespace for the AWS Load Balancer Controller using eksctl or the AWS Management Console and kubectl.


      
  eksctl create iamserviceaccount \
  --cluster=my-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve
  4. install the controller 

     curl -o v2_1_2_full.yaml https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.1.2/docs/install/v2_1_2_full.yaml && kubectl apply -f v2_1_2_full.yaml

      or via helm

    helm repo add eks https://aws.github.io/eks-charts

    helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
  --set clusterName=<cluster-name> \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  -n kube-system


  # cluster autoscaler 

    Also automate the cluster autoscaler creattion along with ALB ingress controller

    Documentation available on : https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html









    