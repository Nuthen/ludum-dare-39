#!/bin/bash
rm -rf releases
love-release --author "Nezumi Games" --email "gamesnezumi@gmail.com" --desc "Ludum Dare 39" --url "google.com" -v "1.0" --title "Squids On A Ship" --uti "nezumi-ld39" -D -M -W 32 -W 64 releases
