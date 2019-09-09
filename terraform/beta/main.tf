provider "aws" {
  profile = "default"
  region  = "ap-southeast-1"
  access_key = "AKIAISHJF3S2WDZ3BXOQ"
  secret_key = "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"
}

resource "aws_security_group" "gateway-beta" {
  name        = "gateway-beta"
  description = "Allow ssh inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "influxdb_grafana-beta" {
  name        = "influxdb_grafana"
  description = "Allow ssh inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.gateway-beta.id}"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    security_groups = ["${aws_security_group.front-end-beta.id}","${aws_security_group.newsfeed-beta.id}","${aws_security_group.quotes-beta.id}"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "front-end-beta" {
  name        = "front-end"
  description = "Allow ssh inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.gateway-beta.id}"]
  }

  ingress {
    from_port   = 7878
    to_port     = 7878
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "newsfeed-beta" {
  name        = "newsfeed"
  description = "Allow ssh inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.gateway-beta.id}"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "quotes-beta" {
  name        = "quotes"
  description = "Allow ssh inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.gateway-beta.id}"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "gateway-beta" {
  connection {
    user = "ec2-user"
    host = "${self.public_ip}"
  }

  count = "1"

  tags = {
    application  = "gateway"
    env = "beta"
  }

  instance_type = "t2.micro"
  ami = "ami-01f7527546b557442"
  key_name   = "assignment"
  vpc_security_group_ids = ["${aws_security_group.gateway-beta.id}"]
}

resource "aws_instance" "influxdb_grafana-beta" {
  connection {
    user = "ec2-user"
    host = "${self.public_ip}"
  }

  tags = {
    application  = "influxdb_grafana"
    env = "beta"
  }

  count = "1"

  instance_type = "t2.micro"
  ami = "ami-01f7527546b557442"
  key_name   = "assignment"
  vpc_security_group_ids = ["${aws_security_group.influxdb_grafana-beta.id}"]
}

resource "aws_instance" "front-end-beta" {
  connection {
    user = "ec2-user"
    host = "${self.public_ip}"
  }

  tags = {
    application  = "front-end"
    env = "beta"
  }

  count = "1"

  instance_type = "t2.micro"
  ami = "ami-01f7527546b557442"
  key_name   = "assignment"
  vpc_security_group_ids = ["${aws_security_group.front-end-beta.id}"]
}

resource "aws_instance" "newsfeed-beta" {
  connection {
    user = "ec2-user"
    host = "${self.public_ip}"
  }
  
  tags = {
    application  = "newsfeed"
    env = "beta"
  }

  count = "1"

  instance_type = "t2.micro"
  ami = "ami-01f7527546b557442"
  key_name   = "assignment"
  vpc_security_group_ids = ["${aws_security_group.newsfeed-beta.id}"]
}

resource "aws_instance" "quotes-beta" {
  connection {
    user = "ec2-user"
    host = "${self.public_ip}"
  }

  tags = {
    application  = "quotes"
    env = "beta"
  }

  count = "1"

  instance_type = "t3a.medium"
  ami = "ami-01f7527546b557442"
  key_name   = "assignment"
  vpc_security_group_ids = ["${aws_security_group.quotes-beta.id}"]
}

resource "aws_elb" "influxdb_grafana-beta" {
  availability_zones = ["ap-southeast-1a"]

  listener {
    instance_port     = 3000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_elb" "front-end-beta" {
  availability_zones = ["ap-southeast-1a"]

  listener {
    instance_port     = 7878
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_elb" "newsfeed-beta" {
  availability_zones = ["ap-southeast-1a"]

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_elb" "quotes-beta" {
  availability_zones = ["ap-southeast-1a"]

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_elb_attachment" "influxdb_grafana-beta" {
  elb      = "${aws_elb.influxdb_grafana-beta.id}"
  instance = "${aws_instance.influxdb_grafana-beta.id}"
}

resource "aws_elb_attachment" "front-end-beta" {
  elb      = "${aws_elb.front-end-beta.id}"
  instance = "${aws_instance.front-end-beta.id}"
}

resource "aws_elb_attachment" "newsfeed-beta" {
  elb      = "${aws_elb.newsfeed-beta.id}"
  instance = "${aws_instance.newsfeed-beta.id}"
}

resource "aws_elb_attachment" "quotes-beta" {
  elb      = "${aws_elb.quotes-beta.id}"
  instance = "${aws_instance.quotes-beta.id}"
}
