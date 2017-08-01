#!/bin/bash
rm -rf releases
love-release --author "Nezumi Games" --email "gamesnezumi@gmail.com" --desc "Spacesquid Spaceship" --url "google.com" -v "1.0" --title "Spacesquid Spaceship" --uti "nezumi-space-squid" -D -M -W 32 -W 64 releases
