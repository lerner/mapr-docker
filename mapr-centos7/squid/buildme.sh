#!/bin/bash

#time docker build -t squid:3.1.23 .
time docker build -t $(basename $(pwd)):3.1.23 .
