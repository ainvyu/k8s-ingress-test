output "bastion_public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}

output "bastion_eip" {
  value = "${aws_eip.this_eip.public_ip}"
}

output "security_group_id" {
  value = "${aws_security_group.allow_ssh.id}"
}
