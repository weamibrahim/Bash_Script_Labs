#!/bin/bash

NUM1=2.6
NUM2=3.7
RES=$(echo "$NUM1+$NUM2"| bc)

echo  "result of sum $NUM1 and $NUM2 is $RES"
