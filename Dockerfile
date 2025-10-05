FROM alpine

ENV OTP_VERSION="28.1" \
    REBAR3_VERSION="3.25.0"

LABEL org.opencontainers.image.version=$OTP_VERSION

COPY build.sh .
RUN set -xe \
    && chmod +x build.sh \
    && exec ./build.sh

CMD ["erl"]
