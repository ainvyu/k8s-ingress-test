/*
If you are planning on using kubectl to manage the Kubernetes cluster, now might be a great time to configure your client. After configuration, you can verify cluster access via kubectl version displaying server version information in addition to local client version information.
The AWS CLI eks update-kubeconfig command provides a simple method to create or update configuration files.
If you would rather update your configuration manually, the below Terraform output generates a sample kubectl configuration to connect to your cluster. This can be placed into a Kubernetes configuration file, e.g. ~/.kube/config
*/
resource "local_file" "airflow_eks_kubeconfig" {
  filename = "k8s_artifacts/kubeconfig.yaml"
  content = "${module.test_cluster.kubeconfig}"
}

/*
Run terraform output config_map_aws_auth and save the configuration into a file, e.g. config_map_aws_auth.yaml
Run kubectl apply -f config_map_aws_auth.yaml
You can verify the worker nodes are joining the cluster via: kubectl get nodes --watch

At this point, you should be able to utilize Kubernetes as expected!
*/
resource "local_file" "airflow_eks_config_map_aws_auth_yaml" {
  filename = "k8s_artifacts/config_map_aws_auth.yaml"
  content = "${module.test_cluster.config_map_aws_auth}"
}
