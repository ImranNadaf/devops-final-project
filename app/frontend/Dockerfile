FROM nginx:alpine

# Remove default html
RUN rm -rf /usr/share/nginx/html/*

# Copy your static frontend
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
