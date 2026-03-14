FROM nginx:alpine

ARG BUILD_TIME

COPY index.html /usr/share/nginx/html/index.html

RUN sed -i "s/__BUILD_TIME__/$BUILD_TIME/g" /usr/share/nginx/html/index.html
