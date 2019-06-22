#!/bin/bash
SAP_VORA_VER=$1

if [[ ! -d ./public_html/sapvora ]]; then
  mkdir -p ./public_html/sapvora
  if [[ -d /selfhosting/home/alerner/SAP/VORA/Software/$SAP_VORA_VER ]]; then
    cp -r /selfhosting/home/alerner/SAP/VORA/Software/$SAP_VORA_VER/* ./public_html/sapvora/
  elif [[ -d ../../VORA/Software/$SAP_VORA_VER ]]; then
    cp -r ../../VORA/Software/$SAP_VORA_VER/*.rpm ./public_html/sapvora/
  fi
  cd ./public_html/sapvora
  createrepo .
fi
