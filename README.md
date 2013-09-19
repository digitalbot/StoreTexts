#StoreTexts

- this is a practice of perl programming.

- clone of nopaste.

##How to use

    $ git clone THIS
    $ cd THIS
    $ carton install
    $ mysqladmin -uroot create store_texts
    $ mysql -uroot store_texts < sql/entry.sql
    $ carton exec plackup

###Before using

- install your own perl

- install App:cpanminus

- install Carton
