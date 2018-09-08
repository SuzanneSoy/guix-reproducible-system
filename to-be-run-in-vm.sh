#!/bin/sh

echo LALALA
{ read len_script; read len_nar; read len_key; } < /dev/sdb
echo x $len_script y $len_nar z $len_key t
head -c "$len_nar" /dev/sdd | sha1sum
echo DONE
# dd if=/dev/sde bs=1 count=$len_key | sha1sum
#
