server {
    listen 80 default_server;

    root /var/www/host.dotspace.ru/html;
    index index.html;

    server_name host.dotspace.ru;

    location / {
        try_files $uri $uri/ =404;
    }

}
