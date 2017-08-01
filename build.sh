#!/bin/bash
rm -rf releases
love-release -D -M -W 32 -W 64 releases .
ls -al releases
