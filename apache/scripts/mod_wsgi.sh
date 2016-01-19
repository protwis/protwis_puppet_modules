wget https://github.com/GrahamDumpleton/mod_wsgi/archive/4.4.21.tar.gz
tar xfz 4.4.21.tar.gz
cd mod_wsgi-4.4.21
./configure --with-python=/usr/local/bin/python3
make
make install
