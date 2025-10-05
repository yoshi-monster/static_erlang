FROM alpine

ENV OTP_VERSION="28.1" \
    REBAR3_VERSION="3.25.0"

LABEL org.opencontainers.image.version=$OTP_VERSION

RUN set -xe \
    && OTP_DOWNLOAD_URL="https://github.com/erlang/otp/releases/download/OTP-${OTP_VERSION}/otp_src_${OTP_VERSION}.tar.gz" \
	&& REBAR3_DOWNLOAD_URL="https://github.com/erlang/rebar3/archive/${REBAR3_VERSION}.tar.gz" \
    && OTP_DOWNLOAD_SHA256="c7c6fe06a3bf0031187d4cb10d30e11de119b38bdba7cd277898f75d53bdb218" \
	&& REBAR3_DOWNLOAD_SHA256="7d3f42dc0e126e18fb73e4366129f11dd37bad14d404f461e0a3129ce8903440" \
	&& apk add --no-cache --virtual .fetch-deps \
		curl \
		ca-certificates \
	&& curl -fSL -o otp-src.tar.gz "$OTP_DOWNLOAD_URL" \
	&& echo "$OTP_DOWNLOAD_SHA256  otp-src.tar.gz" | sha256sum -c - \
	&& apk add --no-cache --virtual .build-deps \
	    perl \
		gcc \
		g++ \
		libc-dev \
        linux-headers \
        make \
        ncurses-dev \
        ncurses-static \
        openssl-dev \
        openssl-libs-static \
        tar \
    && export ERL_TOP=/usr/src/otp_src \
    && mkdir -vp $ERL_TOP \
    && tar xzf otp-src.tar.gz -C $ERL_TOP --strip-components=1 \
    && rm otp-src.tar.gz \
    && ( cd $ERL_TOP \
        && ./configure \
            LIBS="-lncursesw -ltinfo -lcrypto -lssl" \
            CFLAGS="-Os" \
            LDFLAGS="-static -static-libgcc -static-libstdc++" \
            --enable-jit \
            --enable-pie \
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
        && make -j$(getconf _NPROCESSORS_ONLN) \
        && make install ) \
    && rm -fr $ERL_TOP \
    && find /usr/local -regex '/usr/local/lib/erlang/\(lib/\|erts-\).*/\(man\|doc\|obj\|c_src\|emacs\|info\|examples\|priv/lib\)' | xargs rm -rf \
	&& find /usr/local -name src | xargs -r find | grep -v '\.hrl$' | xargs rm -v || true \
	&& find /usr/local -name src | xargs -r find | xargs rmdir -vp || true \
	&& scanelf --nobanner -E ET_EXEC -BF '%F' --recursive /usr/local | xargs -r strip --strip-all \
	&& scanelf --nobanner -E ET_DYN -BF '%F' --recursive /usr/local | xargs -r strip --strip-unneeded \
	&& curl -fSL -o rebar3-src.tar.gz "$REBAR3_DOWNLOAD_URL" \
	&& echo "${REBAR3_DOWNLOAD_SHA256}  rebar3-src.tar.gz" | sha256sum -c - \
	&& mkdir -p /usr/src/rebar3-src \
	&& tar -xzf rebar3-src.tar.gz -C /usr/src/rebar3-src --strip-components=1 \
	&& rm rebar3-src.tar.gz \
	&& cd /usr/src/rebar3-src \
	&& HOME=$PWD ./bootstrap \
	&& install -v ./rebar3 /usr/local/bin/ \
	&& rm -rf /usr/src/rebar3-src \
	&& apk del .fetch-deps .build-deps
	
CMD ["erl"]
