#!/bin/python3

import numpy as np
import os
import aes



key = [ \
  0x17, \
  0x9f, \
  0xd5, \
  0x6c, \
  0x84, \
  0xa2, \
  0xef, \
  0xda, \
  0x17, \
  0x5e, \
  0x50, \
  0x7a, \
  0x68, \
  0xbb, \
  0xf6, \
  0x72]

iv = [ \
  0x00, \
  0x01, \
  0x02, \
  0x03, \
  0x04, \
  0x05, \
  0x06, \
  0x07, \
  0x08, \
  0x09, \
  0x0a, \
  0x0b, \
  0x0c, \
  0x0d, \
  0x0e, \
  0x0f]

flist = []

ls = os.listdir(__file__[:__file__.rfind("/")])
for l in ls:
  if os.path.isfile(l):
    if l.find(".bin") != -1:
      flist.append(l)

for f in flist:
  f_no_ext = f[:f.rfind(".")]
  print(f_no_ext)
  encrypted = np.fromfile(f_no_ext+".bin", dtype=np.uint8)
  decrypted = np.frombuffer(aes.AES(key).decrypt_ctr(encrypted, iv), np.uint8)
  decrypted.tofile(f_no_ext+".txt")

