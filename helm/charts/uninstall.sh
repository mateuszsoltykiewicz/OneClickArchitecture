#!/usr/bin/env bash

for folder in */; do helmname=${folder%/}; echo "$helmname"; helm uninstall "$helmname" -n dfai; (cd "$helmname" && helm dependency update); done

for folder in */; do helmname=${folder%/}; echo "$helmname"; helm install "$helmname" "$helmname" -n dfai; done

