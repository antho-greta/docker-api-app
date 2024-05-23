# UTILISATION

Ce repo contient l'infrastructure docker de symfony

## paramétrage

1. Copier le fichier `./conf/env/sample/mysql.env` dans `./conf/env/mysql.env` et le remplir en se servant du fichier d'example (sample) :

```
MYSQL_ROOT_PASSWORD=edcl56
MYSQL_DATABASE=database
MYSQL_USER=user
MYSQL_PASSWORD=edcl56
```

2. dans le Makefile changer `CLIENT=` avec celui souhaité

## lancer le build des images

1. `$ make ENV=xxx docker-build`

## lancement des containers

1. `$ make ENV=xxx docker-start`

## installation de symfony dans le répertoire volume

## (option 1) : Création du nouveau projet

1. `$ composer create-project symfony/skeleton:^7.0 www/website/www`
2. `$ cd www/website`
3. choisir quelle config on veux pour le projet symfony (une webapp ou une api)
   `$ composer require webapp` / ou `$ composer require api`

4. créer dans le dossier www/website/www un dossier conf
5. dans le nouveau dossier www créer un fichier nginx-dev.conf
6. dans ce fichier copier le code ci-dessous
7. remplacer your_project_name par votre projet

```
upstream website_php {
    server your_project_name.php.dev:9000;
}

server {
    listen 80;
    #listen 443 ssl;
    server_name your_project_name.localhost;
    root /home/www/website/www/public;
    index index.php index.html index.htm;
    client_max_body_size 500M;
    sendfile off;
    #ssl_certificate /etc/nginx/ssl/server.crt;
    #ssl_certificate_key /etc/nginx/ssl/server.key;

    location / {
        # try to serve file directly, fallback to index.php
        try_files $uri /index.php$is_args$args;
    }

    # optionally disable falling back to PHP script for the asset directories;
    # nginx will return a 404 error when files are not found instead of passing the
    # request to Symfony (improves performance but Symfony's 404 page is not displayed)
    # location /bundles {
    #     try_files $uri =404;
    # }

    location ~ ^/index\.php(/|$) {
        fastcgi_pass website_php;
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;

        # optionally set the value of the environment variables used in the application
        # fastcgi_param APP_ENV prod;
        # fastcgi_param APP_SECRET <app-secret-id>;
        # fastcgi_param DATABASE_URL "mysql://db_user:db_pass@host:3306/db_name";

        # When you are using symlinks to link the document root to the
        # current version of your application, you should pass the real
        # application path instead of the path to the symlink to PHP
        # FPM.
        # Otherwise, PHP's OPcache may not properly detect changes to
        # your PHP files (see https://github.com/zendtech/ZendOptimizerPlus/issues/126
        # for more information).
        # Caveat: When PHP-FPM is hosted on a different machine from nginx
        #         $realpath_root may not resolve as you expect! In this case try using
        #         $document_root instead.
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT $realpath_root;
        # Prevents URIs that include the front controller. This will 404:
        # http://domain.tld/index.php/some-path
        # Remove the internal directive to allow URIs like this
        internal;
        #fastcgi_param  HTTPS on;
    }

    # return 404 for all other php files not matching the front controller
    # this prevents access to other php files you don't want to be accessible.
    location ~ \.php$ {
        return 404;
    }

    access_log /dev/stdout vhosts;
    error_log  /dev/stderr;
}
```

## (option 2) : Cloner un projet pour l'inculre dans cet environnement

1. Se positionner dans le dossier volume/www -> `cd volume/www`
2. Dans ce dossier cloner le projet depuis git :
   a ) clone depuis un projet total -> `git clone <URL_DU_PROJET> website`
   b ) clone depuis une branch spécifique du projet -> `git --branch <NOM_DE_LA_BRANCHE> <URL_DU_PROJET> website`
3. Modifer si besoins le nginx-dev.conf

## lancer la configuration

1. placer vous au niveau du fichier Makefile
2. lancer `$ make ENV=dev config`

## Détails de l'infrastructure

Celle-ci contient 3 container :

- PHP ([8.1-fpm-buster](https://hub.docker.com/_/php/))
- MYSQL ([8](https://hub.docker.com/_/mysql/))
- NGINX ([latest](https://hub.docker.com/_/nginx/))

## installation des différentes dépendances utiles pour un projet webapp

! Ce placer dans le projet !
-> `docker exec -it <NOM_DU_PROJET_PHP bash`
-> `cd /home`
-> `cd www/website/www`

- commande pour installer les dépendances globales ->`composer install`
- commande pour installer les dépendances node -> `npm install`
- commande pour configurer le webpack -> `./node_modules/.bin/encore dev`

- (autres commande utiles individuel en cas de besoins)
- Doctrine -> `composer require doctrine`
- ORM (collection de bibliothèque de symfony) -> `composer require symfony/orm-pack`
- Collection de commande de symfony -> `composer require --dev symfony/maker-bundle`
