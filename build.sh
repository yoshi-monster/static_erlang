#!/bin/sh

set -xe
OTP_DOWNLOAD_URL="https://github.com/erlang/otp/releases/download/OTP-${OTP_VERSION}/otp_src_${OTP_VERSION}.tar.gz"
REBAR3_DOWNLOAD_URL="https://github.com/erlang/rebar3/archive/${REBAR3_VERSION}.tar.gz"
export ERL_TOP=/usr/src/otp_src
export BUILD_TOP="$(pwd)"

apk add --no-cache --virtual .fetch-deps \
	curl \
	ca-certificates

curl -fSL -o otp-src.tar.gz "$OTP_DOWNLOAD_URL"

apk add --no-cache --virtual .build-deps \
    perl \
    clang \
	libc-dev \
    linux-headers \
    make \
    ncurses-dev \
    ncurses-static \
    openssl-dev \
    openssl-libs-static \
    tar

mkdir -vp $ERL_TOP
tar xzf otp-src.tar.gz -C $ERL_TOP --strip-components=1
rm otp-src.tar.gz

( cd $ERL_TOP \
    && ./configure \
        CC=clang \
        CXX=clang \
        LIBS="-lncursesw -ltinfo -lcrypto -lssl -lstdc++" \
        CFLAGS="-Os" \
        LDFLAGS="-static -static-libgcc -static-libstdc++" \
        --enable-jit \
        --disable-pie \
        --with-termcap \
        --without-javac \
        --enable-builtin-zlib \
        --disable-dynamic-ssl-lib \
        --with-ssl \
        --enable-static-nifs \
        --enable-static-drivers \
        --without-wx \
        --without-observer \
        --without-reltool \
        --without-docs \
        --without-odbc \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install )

rm -fr $ERL_TOP
find /usr/local -regex '/usr/local/lib/erlang/\(lib/\|erts-\).*/\(man\|doc\|obj\|c_src\|emacs\|info\|examples\|priv/lib\)' | xargs rm -fr
find /usr/local -name src | xargs -r find | grep -v '\.hrl$' | xargs rm -v || true
find /usr/local -name src | xargs -r find | xargs rmdir -vp || true

scanelf --nobanner -E ET_EXEC -BF '%F' --recursive /usr/local | xargs -r strip --strip-all
scanelf --nobanner -E ET_DYN -BF '%F' --recursive /usr/local | xargs -r strip --strip-unneeded

curl -fSL -o rebar3-src.tar.gz "$REBAR3_DOWNLOAD_URL"
mkdir -p /usr/src/rebar3-src
tar -xzf rebar3-src.tar.gz -C /usr/src/rebar3-src --strip-components=1
rm rebar3-src.tar.gz

cd /usr/src/rebar3-src
HOME=$PWD ./bootstrap
install -v ./rebar3 /usr/local/lib/erlang/bin/
rm -rf /usr/src/rebar3-src

apk del .fetch-deps .build-deps
