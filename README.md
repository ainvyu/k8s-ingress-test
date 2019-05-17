# Initialize
## Generate Keypair

    $ cd terraform
    $ mkdir keypair
    $ ssh-keygen -t rsa -f keypair/common_keypair_openssh -C 'for ec2 key'

## Terraform Initialize

### Define variables

    $ export AWS_PROFILE=YOUR_AWS_PROFILE
    $ export AWS_DEFAULT_REGION=YOUR_AWS_REGION
    $ export TF_VAR_region_name=YOUR_AWS_REGION
    $ terraform init
    $ terraform apply
    $ ls -alh k8s_artifacts                                                                          
    Permissions Size User Date Modified Name
    .rwxr-xr-x@  295 USER 16 May 15:12  config_map_aws_auth.yaml
    .rwxr-xr-x@ 1.9k USER 16 May 15:12  kubeconfig.yaml

    
 ## k8s Initialize
 
    $ export KUBECONFIG=$KUBECONFIG:k8s_artifacts/kubeconfig.yaml
    $ kubectl apply -f k8s_artifacts/config_map_aws_auth.yaml
    
    $ kubectl describe configmap -n kube-system aws-auth
    Name:         aws-auth
    Namespace:    kube-system
    Labels:       <none>
    ...
    
    $ kubectl get nodes
    NAME                                               STATUS    ROLES     AGE       VERSION
    ip-************.ap-northeast-2.compute.internal    Ready     <none>    1m        v1.12.7
    ip-************.ap-northeast-2.compute.internal    Ready     <none>    1m        v1.12.7
    ip-************.ap-northeast-2.compute.internal    Ready     <none>    2m        v1.12.7
    ip-************.ap-northeast-2.compute.internal    Ready     <none>    1m        v1.12.7


## Helm Initialize

    $ export KUBECONFIG=$KUBECONFIG:k8s_artifacts/kubeconfig.yaml
    $ helm init
    $ kubectl create serviceaccount --namespace kube-system tiller
    $ kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
    $ kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
    
    $ helm install stable/kube2iam --name kube2iam --namespace kube-system
    $ kubectl --namespace=kube-system get pods -l "app=kube2iam,release=kube2iam"
    NAME             READY     STATUS    RESTARTS   AGE
    kube2iam-ctlrq   1/1       Running   0          20s
    kube2iam-dqhgt   1/1       Running   0          20s
    kube2iam-dqpnz   1/1       Running   0          20s
    kube2iam-g246v   1/1       Running   0          20s

## Install Pods

    # Create a namespace for your ingress resources
    $ kubectl create namespace ingress-test

    # Use Helm to deploy an NGINX ingress controller
    $ helm install stable/nginx-ingress --namespace ingress-test --name nginx-ingress \
    	--set controller.replicaCount=2 \
    	--set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-type"=nlb
    	
    # Install ingress test chart
    $ cd helm/ingress-demo
    $ helm install . --namespace ingress-test --name ingress-demo
    
# Test

    $ curl $(kubectl get service --namespace=ingress-test --output json | jq -r '.items[].status.loadBalancer.ingress[0].hostname' | grep -v null | sort | uniq)/1
    "Hello World 1"
    $ curl $(kubectl get service --namespace=ingress-test --output json | jq -r '.items[].status.loadBalancer.ingress[0].hostname' | grep -v null | sort | uniq)/2
    "Hello World 2"


# Troubleshooting

    $ kubectl describe configmap -n kube-system aws-auth         
    usage: aws [options] <command> <subcommand> [<subcommand> ...] [parameters]
    To see help text, you can run:
    
      aws help
      aws <command> help
      aws <command> <subcommand> help
    aws: error: argument operation: Invalid choice, valid choices are:
    
    create-cluster                           | delete-cluster                          
    describe-cluster                         | describe-update                         
    list-clusters                            | list-updates                            
    update-cluster-config                    | update-cluster-version                  
    update-kubeconfig                        | wait                                    
    help                                    
    ...
    Unable to connect to the server: getting token: exec: exit status 2

Check your AWS CLI version

    $ aws --v      
    aws-cli/1.16.150 Python/3.7.3 Darwin/18.5.0 botocore/1.12.140
    $ aws eks get-token --cluster-name DUMMY
    usage: aws [options] <command> <subcommand> [<subcommand> ...] [parameters]
    To see help text, you can run:
    
      aws help
      aws <command> help
      aws <command> <subcommand> help
    aws: error: argument operation: Invalid choice, valid choices are:
    
    create-cluster                           | delete-cluster                          
    describe-cluster                         | describe-update                         
    list-clusters                            | list-updates                            
    update-cluster-config                    | update-cluster-version                  
    update-kubeconfig                        | wait                                    
    help            
    

`aws eks get-token` command added May 10, 2019.

    AWS CLI get-token command
    	
    
    The aws eks get-token command was added to the AWS CLI so that you no longer need to install the AWS IAM Authenticator for Kubernetes to create client security tokens for cluster API server communication. Upgrade your AWS CLI installation to the latest version to take advantage of this new functionality. For more information, see Installing the AWS Command Line Interface in the AWS Command Line Interface User Guide.
    	
    
    May 10, 2019

If you use the latest version, you will get the following output( (As of 16 May 2019):

    $ aws --v      
    aws-cli/1.16.159 Python/2.7.16 Darwin/18.5.0 botocore/1.12.149
    $ aws eks get-token --cluster-name DUMMY
    {"status": {"token": "k8s-aws-v1.SOME_TOKEN_STRING"}, "kind": "ExecCredential", "spec": {}, "apiVersion": "client.authentication.k8s.io/v1alpha1"}

