FROM frolvlad/alpine-glibc:alpine-3.12
LABEL MAINTAINER Kenji Yamada <kenji.yamada@gmail.com>

ARG UID=501
ARG GID=100
ARG GROUPNAME=users
ARG USERNAME=melito00
ARG USERPASSWORD=melito01

RUN apk add bash sudo
RUN adduser -u ${UID} -G ${GROUPNAME} -h /home/${USERNAME} -s /bin/bash -D ${USERNAME} \
  && adduser ${USERNAME} wheel \
  && echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo ${USERNAME}:${USERPASSWORD} | chpasswd

ARG setup_dir=/tmp/setup
RUN mkdir ${setup_dir} && \
    chmod 777 ${setup_dir}

# --- Roswellのインストール --- #
RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk add --no-cache git automake autoconf make gcc build-base curl-dev curl glib-dev libressl-dev ncurses-dev sqlite libev-dev su-exec libpq postgresql-client postgresql-dev postgresql-contrib rlwrap@testing && \
    mkdir /docker-entrypoint-initdb.d && \
    cd ${setup_dir} && \
    git clone --depth=1 -b release https://github.com/roswell/roswell.git && \
    cd roswell && \
    sh bootstrap && \
    ./configure --disable-manual-install && \
    make && \
    make install && \
    cd .. && \
    rm -rf roswell && \
    ros run -q

USER ${USERNAME}
WORKDIR /home/${USERNAME}

# --- .roswell/binにPATHを通す --- #
ENV PATH /home/${USERNAME}/.roswell/bin:${PATH}

# --- Caveman, Lem, Darkmatter をインストールする--- #
RUN ln -s /home/${USERNAME}/.roswell/local-projects sbcl-work && \
    ros install fukamachi/clack && \
    ros install fukamachi/caveman && \
    ros install cxxxr/lem && \
    ros install tamamu/darkmatter && \
    ros install Shinmera/dissect && \
    ros install fukamachi/qlot && \
    ros install fukamachi/utopian &&\
    mv /home/${USERNAME}/.roswell/bin/lem /home/${USERNAME}/.roswell/bin/lem2 && \
    mv /home/${USERNAME}/.roswell/bin/lem-ncurses /home/${USERNAME}/.roswell/bin/lem

# --- Webアプリケーションにアクセスできるようにポートを開ける --- #
EXPOSE 8888

CMD /bin/bash

