#!/bin/bash

time docker build -t $(basename $(pwd)):1.10.3 .
#time docker build -t krb5:1.10.3 .
