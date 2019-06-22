FROM httpd:2.4

# Create public_html directory before running docker build on this Dockerfile
# Script get_packages.sh in the build context does this
#
COPY ./public_html/ /usr/local/apache2/htdocs/

# Use AutoIndex module.  Allow full width file names in index.
RUN sed -i -e '/^#Include conf\/extra\/httpd-autoindex.conf/ s/#//' /usr/local/apache2/conf/httpd.conf && \
    sed -i -e '/^IndexOptions/ s/$/ NameWidth=*/' /usr/local/apache2/conf/extra/httpd-autoindex.conf 

EXPOSE 80

