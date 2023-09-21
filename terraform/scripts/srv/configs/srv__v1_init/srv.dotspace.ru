server {
    listen 80 default_server;

    root /var/www/srv.dotspace.ru/html;
    index index.html;

    # server_name srv.dotspace.ru www.srv.dotspace.ru;
    server_name srv.dotspace.ru;

    location / {
        try_files $uri $uri/ =404;
    }

}
