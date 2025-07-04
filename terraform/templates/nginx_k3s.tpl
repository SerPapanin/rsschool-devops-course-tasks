# Template nginx reverse proxy configuration
stream {
        upstream api {
                server ${k3s_private_ip}:6443;
        }
        server {
                listen 6443; # this is the port exposed by nginx on reverse proxy server
                proxy_pass api;
                proxy_timeout 20s;
        }
}
