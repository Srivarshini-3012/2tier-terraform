resource "aws_instance" "web" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [var.ec2_sg_id]

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install apache2 php libapache2-mod-php php-mysql -y
    systemctl start apache2
    systemctl enable apache2
    rm /var/www/html/index.html

    echo "<?php
    \$host = '${var.rds_endpoint}';
    \$db_user = '${var.db_username}';
    \$db_pass = '${var.db_password}';
    \$db_name = 'LoginDB';
    \$conn = new mysqli(\$host, \$db_user, \$db_pass);
    if (\$conn->connect_error) { die('Database connection failed: ' . \$conn->connect_error); }
    echo '<h2>Connected Successfully to RDS MySQL Database!</h2>';
    ?>" > /var/www/html/index.php
  EOF

  tags = {
    Name = "LoginApp-EC2"
  }
}

output "public_ip" {
  value = aws_instance.web.public_ip
}

