#!/bin/sh

for service in $@; do
    case $service in
      *)    # unknown option
        logger "ERROR:snap-TAF: restart unknown service $service" 
      ;;
    esac
  done     