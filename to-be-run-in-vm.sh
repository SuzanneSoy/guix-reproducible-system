#!/bin/sh

echo
{ read len_script; read len_tar; } < /dev/sdb
pwd
head -c "$len_tar" /dev/sdd | tar -xf -
sha1sum hello.nar
sha1sum signing-key.pub
