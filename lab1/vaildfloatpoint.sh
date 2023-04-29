#!/bin/bash

NUM=2.6
if echo "$NUM" | grep -qE '^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$'; then
   echo "$NUM is vaild floating point "
else 
   echo "$NUM is not vaild floating point"
fi
