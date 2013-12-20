FROM klaemo/couchdb-base

MAINTAINER Clemens Stolle clemens.stolle@gmail.com

# Get the source
RUN cd /opt && \
wget http://apache.openmirror.de/couchdb/source/1.5.0/apache-couchdb-1.5.0.tar.gz && \
tar xzf /opt/apache-couchdb-1.5.0.tar.gz

RUN cd /opt/apache-couchdb-1.5.0 && ./configure && make && make install

RUN apt-get remove -y build-essential wget libmozjs185-dev libicu-dev libcurl4-gnutls-dev && \
apt-get autoremove -y && apt-get clean -y && \
rm -rf /opt/apache-couchdb-*

# Configuration
ADD couchdb-config /opt/
ADD local.ini /usr/local/etc/couchdb/
RUN chmod +x /opt/couchdb-config && ./opt/couchdb-config
RUN sed -e 's/^bind_address = .*$/bind_address = 0.0.0.0/' -i /usr/local/etc/couchdb/default.ini

ADD supervisord.conf /etc/supervisord.conf

# Use volume dir for database files and config
VOLUME ["/usr/local/var/lib/couchdb", "/usr/local/etc/couchdb"]

# USER couchdb
CMD ["/usr/local/bin/supervisord"]
# CMD ["couchdb", "-r 5", "-p /usr/local/var/run/couchdb/couchdb.pid"]

EXPOSE 5984
