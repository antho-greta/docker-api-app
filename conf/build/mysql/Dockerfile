FROM mysql:8-debian

ENV TERM=xterm

RUN gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys B7B3B788A8D3785C \
	&& rm /etc/apt/keyrings/mysql.gpg \
	&& gpg  --output /etc/apt/keyrings/mysql.gpg --export B7B3B788A8D3785C

RUN apt-get clean \
	&& apt-get update \
	&& apt-get install -y lsof nano less wget unzip

COPY mysql.cnf /etc/mysql/conf.d/

RUN apt-get clean \
	&& rm -rf /var/lib/apt/lists/
