FROM nginx:alpine

# Supprimer la config Nginx par défaut
RUN rm /etc/nginx/conf.d/default.conf

# Copier notre configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copier tous les fichiers du frontend
COPY . /usr/share/nginx/html/

EXPOSE 80
