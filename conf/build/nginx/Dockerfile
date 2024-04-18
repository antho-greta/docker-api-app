FROM nginx

ENV TERM=xterm

RUN apt-get clean \
	&& apt-get update \
	&& apt-get install -y lsof nano less

RUN rm /etc/nginx/conf.d/default.conf \
	&& sed -i 's|include /etc/nginx/conf.d/\*.conf;|include /etc/nginx/conf.d/\*.conf;\ninclude /etc/nginx/sites-enabled/\*.conf;\n|' /etc/nginx/nginx.conf

COPY log_format.conf /etc/nginx/conf.d/

RUN apt-get clean \
	&& rm -rf /var/lib/apt/lists/
