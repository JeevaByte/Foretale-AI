#!/bin/bash
# User data script for EC2 instances - AI/ML servers

set -e

# Logging
exec > >(tee /var/log/user-data.log)
exec 2>&1
echo "Starting user data script at $(date)"

# Update system
yum update -y

# Install CloudWatch agent
wget https://s3.${region}.amazonaws.com/amazoncloudwatch-agent-${region}/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm
rm amazon-cloudwatch-agent.rpm

# Install Docker
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Python 3.11
amazon-linux-extras install python3.11 -y

# Install nginx
amazon-linux-extras install nginx1 -y

# Create directories for logs
mkdir -p /var/log/foretale
mkdir -p /opt/foretale
mkdir -p /etc/nginx/ssl

# Generate self-signed SSL certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/nginx-selfsigned.key \
  -out /etc/nginx/ssl/nginx-selfsigned.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=${project_name}-${environment}"

# Configure nginx
cat > /etc/nginx/nginx.conf <<'NGINX_EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    server {
        listen 443 ssl http2 default_server;
        listen [::]:443 ssl http2 default_server;
        server_name _;

        ssl_certificate /etc/nginx/ssl/nginx-selfsigned.crt;
        ssl_certificate_key /etc/nginx/ssl/nginx-selfsigned.key;

        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;

        root /usr/share/nginx/html;

        location / {
            index index.html;
        }

        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
}
NGINX_EOF

# Create a simple index page
cat > /usr/share/nginx/html/index.html <<'HTML_EOF'
<!DOCTYPE html>
<html>
<head>
    <title>ForeTale AI Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; background: #f0f0f0; }
        .container { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #333; }
        .status { color: #28a745; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1>ForeTale AI/ML Server</h1>
        <p>Status: <span class="status">Running</span></p>
        <p>Instance ID: <span id="instance-id"></span></p>
        <p>Environment: ${environment}</p>
    </div>
    <script>
        fetch('http://169.254.169.254/latest/meta-data/instance-id')
            .then(r => r.text())
            .then(id => document.getElementById('instance-id').textContent = id)
            .catch(() => document.getElementById('instance-id').textContent = 'Unknown');
    </script>
</body>
</html>
HTML_EOF

# Start and enable nginx
systemctl start nginx
systemctl enable nginx

# CloudWatch agent configuration
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<EOF
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/foretale/*",
            "log_group_name": "/aws/ec2/${project_name}-${environment}",
            "log_stream_name": "{instance_id}-foretale"
          },
          {
            "file_path": "/var/log/docker",
            "log_group_name": "/aws/ec2/${project_name}-${environment}",
            "log_stream_name": "{instance_id}-docker"
          }
        ]
      }
    }
  },
  "metrics": {
    "namespace": "${project_name}-${environment}",
    "metrics_collected": {
      "cpu": {
        "measurement": [
          {
            "name": "cpu_usage_idle",
            "rename": "CPU_IDLE",
            "unit": "Percent"
          },
          "cpu_usage_iowait"
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          {
            "name": "used_percent",
            "rename": "DISK_USED",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "/"
        ]
      },
      "mem": {
        "measurement": [
          {
            "name": "mem_used_percent",
            "rename": "MEM_USED",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

echo "User data script completed at $(date)"
