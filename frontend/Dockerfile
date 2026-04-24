# Le frontend est pré-buildé localement (npm run build)
# Ce Dockerfile copie simplement dist/ dans Nginx

FROM nginx:alpine

RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY dist/ /usr/share/nginx/html/

EXPOSE 80
