ARG BASE_CONTAINER=ubuntu:18.04
FROM $BASE_CONTAINER
LABEL maintainer="student@lg.com"

RUN apt-get update \
    && apt-get install locales \
    && sed -i 's/^# \(ko_KR.UTF-8\)/\1/' /etc/locale.gen \
    && localedef -f UTF-8 -i ko_KR ko_KR.UTF-8

RUN apt-get install -yq vim man manpages manpages-posix

RUN sed -i 's:^path-exclude=/usr/share/man:#path-exclude=/usr/share/man:' /etc/dpkg/dpkg.cfg.d/excludes \
    && apt-get install --reinstall manpages manpages-posix

RUN apt-get install -yq git ssh rsync tree

ENV LC_ALL ko_KR.UTF-8
