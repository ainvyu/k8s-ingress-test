output "config_map_aws_auth" {
  value = "${local.config_map_aws_auth}"
}

output "kubeconfig" {
  value = "${local.kubeconfig}"
}

output "alb_ingress_controller_helm_values_yaml" {
  value = "${data.template_file.alb_ingress_controller_value_yaml.rendered}"
}

output "lb_dns_name" {
  value = "${aws_lb.k8s_cluster_endpoint.dns_name}"
}

output "lb_dns_zone_id" {
  value = "${aws_lb.k8s_cluster_endpoint.zone_id}"
}
