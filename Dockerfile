# Use the official Nginx image as the base
FROM nginx:alpine

# Install necessary packages for building the module
RUN apk add --no-cache git build-base pcre-dev zlib-dev openssl-dev

# Clone the nginx-rtmp-module repository
RUN git clone https://github.com/arut/nginx-rtmp-module.git /tmp/nginx-rtmp-module

# Download the Nginx source code that matches the version used in the base image
RUN wget http://nginx.org/download/nginx-$(nginx -v 2>&1 | grep -o '[0-9.]*').tar.gz -O /tmp/nginx.tar.gz \
    && tar -zxvf /tmp/nginx.tar.gz -C /tmp

# Build the RTMP module
RUN cd /tmp/nginx-* \
    && ./configure --with-compat --add-dynamic-module=/tmp/nginx-rtmp-module \
    && make modules \
    && cp objs/ngx_rtmp_module.so /etc/nginx/modules

# Remove unnecessary files
RUN rm -rf /tmp/nginx-* /tmp/nginx-rtmp-module

# Create necessary directories
RUN mkdir -p /var/log/nginx /var/www/hls /etc/nginx/logs

# Copy Nginx configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Expose ports
EXPOSE 8888 1935

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
