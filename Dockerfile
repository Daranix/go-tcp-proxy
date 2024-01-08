FROM golang:1.20-alpine3.19

ARG VERSION=1.0.3
ARG REPOSITORY

RUN echo "Fetching version ${VERSION}"
RUN echo "Repository ${REPOSITORY}"
RUN PLATARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && echo "Platform: ${PLATARCH}"
RUN addgroup -S proxyuser \
 && adduser -D -S -h /var/proxyuser -s /sbin/nologin -G proxyuser proxyuser \
 && apk add --no-cache curl \
 && echo "Fetching version ${VERSION}" \
 && PLATARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) \
 && echo "Platform: ${PLATARCH}" \
 && curl -fSL https://github.com/${REPOSITORY}/releases/download/${VERSION}/go-tcp-proxy_${VERSION:1}_linux_${PLATARCH}.tar.gz -o proxy.tar.gz \
 && tar -zxv -f proxy.tar.gz \
 && mkdir /goproxy \
 && rm -rf proxy.tar.gz \
 && mv tcp-proxy /goproxy/tcp-proxy \
 && chown -R proxyuser:proxyuser /goproxy 

USER proxyuser
RUN ["chmod", "+x", "/goproxy/tcp-proxy"]

WORKDIR /goproxy

ENTRYPOINT ["/goproxy/tcp-proxy"]