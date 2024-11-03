# Server block for Jenkins routing to K3s on port 8080
server {
    listen 8080;
    #server_name jenkins.local;  # Replace with your DNS name for Jenkins

    location / {
        proxy_pass http://${k3s_private_ip}:80;
        proxy_set_header Host jenkins.local;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
