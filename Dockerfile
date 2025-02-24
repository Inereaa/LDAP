
# Uso una imagen base de Apache
FROM httpd:2.4

# Instalo Node.js y otras dependencias necesarias
RUN apt-get update && \
    apt-get install -y npm && \
    apt-get install -y nodejs && \
    apt-get install -y libapache2-mod-ldap-userdir && \
    apt-get install -y apache2-utils ssl-cert && \
    apt-get install -y slapd ldap-utils

RUN echo "LoadModule ssl_module modules/mod_ssl.so" >> /usr/local/apache2/conf/httpd.conf && \
    echo "LoadModule ldap_module modules/mod_ldap.so" >> /usr/local/apache2/conf/httpd.conf && \
    echo "LoadModule authnz_ldap_module modules/mod_authnz_ldap.so" >> /usr/local/apache2/conf/httpd.conf

# Copio los archivos de la página web al directorio de Apache
COPY ./index.html /usr/local/apache2/htdocs/
COPY ./error.html /usr/local/apache2/htdocs/
COPY ./admin.html /usr/local/apache2/htdocs/
COPY ./css/ /usr/local/apache2/htdocs/css/
COPY ./scss/ /usr/local/apache2/htdocs/scss/
COPY ./assets/ /usr/local/apache2/htdocs/assets/

# Copio los certificados al directorio de Apache
COPY ./tf/certificate.crt /usr/local/apache2/conf/
COPY ./tf/ca_bundle.crt /usr/local/apache2/conf/
COPY ./tf/private.key /usr/local/apache2/conf/

# Copio mi configuración SSL personalizada
COPY ./tf/httpd-ssl.conf /usr/local/apache2/conf/extra/

# Copio el script de inicialización LDAP y el archivo LDIF
COPY ./init-ldap.sh /docker-entrypoint.d/
COPY ./admin.ldif /etc/ldap/admin.ldif

# Habilito el módulo SSL y configuro el puerto 443
RUN apt-get update && apt-get install -y ssl-cert && \
    sed -i 's/#LoadModule ssl_module/LoadModule ssl_module/' /usr/local/apache2/conf/httpd.conf && \
    echo "Include /usr/local/apache2/conf/extra/httpd-ssl.conf" >> /usr/local/apache2/conf/httpd.conf

# Ejecuto el .sh de LDAP
RUN chmod +x /docker-entrypoint.d/init-ldap.sh

# Expongo los puertos necesarios
EXPOSE 80
EXPOSE 443
EXPOSE 389

# Instrucción por defecto
CMD ["httpd-foreground"]
