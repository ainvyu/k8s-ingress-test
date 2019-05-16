data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    #values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20190122"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "state"
    values = ["available"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "allow_ssh" {
  name = "${var.name}-bastion"
  description = "for Bastion security group"
  vpc_id = "${var.vpc_id}"

  # TCP access
  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(map("Name", format("%s-bastion-sg", var.name)), var.tags)}"
}

resource "aws_instance" "bastion" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.bastion_instance_type}"

  subnet_id = "${var.vpc_public_subnet}"
  associate_public_ip_address = true
  key_name = "${var.keypair_name}"
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]

  tags = "${merge(map("Name", format("%s-bastion", var.name)), var.tags)}"
}

resource "aws_eip" "this_eip" {
  instance = "${aws_instance.bastion.id}"

  tags = "${merge(map("Name", format("%s-bastion-eip", var.name)), var.tags)}"
}

