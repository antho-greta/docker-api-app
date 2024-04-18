
CLIENT=<NOM_DU_PROJET>

DOCKERCOMPOSE := $(shell command -v docker-compose 2> /dev/null)
USAGE := Usage: make ENV={prod|preprod|dev} {docker-build|docker-start|docker-stop|docker-restart}

ifndef DOCKERCOMPOSE
$(error docker-compose is not available)
endif

ifndef ENV
$(info Environment variable is not set)
$(info $(USAGE))
$(error Exiting)
endif

DC_OVERRIDE := $(shell test -e conf/docker-compose.override.yml && echo "--file conf/docker-compose.override.yml")
DC_OVERRIDE_ENV := $(shell test -e conf/docker-compose.$(ENV).yml && echo "--file conf/docker-compose.$(ENV).yml")

DC=ENV=$(ENV) CLIENT=$(CLIENT) $(DOCKERCOMPOSE) --project-name "$(CLIENT)_$(ENV)" --file conf/docker-compose.yml $(DC_OVERRIDE) $(DC_OVERRIDE_ENV)

default:
	$(info $(USAGE))
	$(error Exiting)

docker-build:
	$(DC) pull
	$(DC) build
	$(DC) up -d

docker-start:
	$(DC) start

docker-stop:
	$(DC) stop

docker-restart: docker-stop docker-start

docker-rm: docker-stop
	$(DC) rm

config:
	@echo "Configuring docker for environment '$(ENV)'"

	$(eval SERVER_NAME := $(shell cat volume/www/website/conf/nginx-$(ENV).conf | grep server_name | awk '{print $$NF}' | sed 's/;$$//'))
	
	@echo "  --> Generating nginx symlink for '$(SERVER_NAME)'"
	@docker exec $(CLIENT).nginx.$(ENV) ln -s -f /home/www/website/conf/nginx-$(ENV).conf /home/www/website/conf/nginx.conf
	
	@docker exec $(CLIENT).nginx.$(ENV) ln -s -f /home/www/website/conf/nginx.conf /etc/nginx/sites-enabled/$(SERVER_NAME).conf

	@echo "  --> Generating symfony symlink"
	@docker exec $(CLIENT).php.$(ENV) ln -s -f /home/www/website/www/config/services-$(ENV).yaml /home/www/website/www/config/services.yml

	@echo "  --> Reloading nginx"
	@docker exec $(CLIENT).nginx.$(ENV) nginx -t && docker exec $(CLIENT).nginx.$(ENV) nginx -s reload

config-folders:
	@echo "---Init folders---"
	mkdir -p volume/www
	mkdir -p backup

config-permission:
	@conf/build/php/permissions.sh 

config-default-param:
	@echo "---Init default parameters---"
	cp conf/env/mysql.env.sample conf/env/mysql.env
	cp conf/parameters.yml.sample conf/parameters.yml

config-master: config-folders config-default-param

db-backup:
	@echo "Backing up database"
	@mkdir -p backup/
	@docker exec $(CLIENT).mysql.$(ENV) mysqldump -uroot database > backup/mysql_$(ENV)_$(NOW).sql

db-backup-script:
	@mkdir -p backup/
	@docker exec $(CLIENT).mysql.$(ENV) mysqldump -uroot database > backup/mysql_$(ENV)_`date +%d-%m-%Y"_"%H_%M_%S`.sql

db-restore:
	@echo "Restoring file to database (backup/mysql.sql)"
	@docker exec -i $(CLIENT).mysql.$(ENV) mysql -uroot database < backup/mysql.sql

config-db-root:
	@echo "  --> Generating mysql auth file"
	@cat conf/env/mysql.env \
		| python3 -c "import sys; import string; v=sys.stdin.readline().split('MYSQL_ROOT_PASSWORD=')[1]; print(string.Template(open('conf/build/mysql/my.cnf').read()).substitute({'PASSWORD':v}))" \
		| docker exec -i $(CLIENT).mysql.$(ENV) sh -c 'cat > /root/.my.cnf'

pull-website:
	git -C volume/www/website pull

db-diff:
	@docker exec -i $(CLIENT).php.$(ENV) su www-data -c "/home/www/website/www/bin/console doctrine:migrations:diff"

db-migrate:
	@docker exec -i $(CLIENT).php.$(ENV) su www-data --shell=/bin/bash -c "/home/www/website/www/bin/console doctrine:migrations:migrate"

db-deploy: db-diff db-migrate

cc:
	@echo "Clearing symfony cache"
	@docker exec -i $(CLIENT).php.$(ENV) su www-data --shell=/bin/bash -c "/home/www/website/www/bin/console cache:clear --env=prod"
	@docker exec -i $(CLIENT).php.$(ENV) su www-data --shell=/bin/bash -c "/home/www/website/www/bin/console cache:clear --env=dev"

sys:
	@echo $(SYS)
	@echo $(DC)
