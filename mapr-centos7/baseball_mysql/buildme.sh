#!/bin/bash

time docker build -t $(basename $(pwd)):5.6 .
