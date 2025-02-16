
# Uso una imagen base de Apache
FROM httpd:2.4

# Instalo Node.js
RUN apt-get update && \
    apt-get install -y npm && \
    apt-get install -y nodejs

# Copio los archivos de la página web al directorio de Apache
COPY ./index.html /usr/local/apache2/htdocs/
COPY ./css/ /usr/local/apache2/htdocs/css/
COPY ./scss/ /usr/local/apache2/htdocs/scss/

# Copio los certificados al directorio de Apache
COPY ./tf/certificate.crt /usr/local/apache2/conf/
COPY ./tf/ca_bundle.crt /usr/local/apache2/conf/
COPY ./tf/private.key /usr/local/apache2/conf/

# Copio mi configuración SSL personalizada
COPY ./tf/httpd-ssl.conf /usr/local/apache2/conf/extra/

# Habilito el módulo SSL y configuro el puerto 443
RUN apt-get update && apt-get install -y ssl-cert && \
    sed -i 's/#LoadModule ssl_module/LoadModule ssl_module/' /usr/local/apache2/conf/httpd.conf && \
    echo "Include /usr/local/apache2/conf/extra/httpd-ssl.conf" >> /usr/local/apache2/conf/httpd.conf

# Expongo los puertos necesarios
EXPOSE 80
EXPOSE 443
EXPOSE 389

# Instrucción por defecto
CMD ["httpd-foreground"]
