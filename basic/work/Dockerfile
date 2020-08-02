ARG BASE_CONTAINER=mysql:5.7
FROM $BASE_CONTAINER
LABEL maintainer="my@email.com"

ADD ./init /docker-entrypoint-initdb.d

EXPOSE 3306

CMD ["mysqld"]
