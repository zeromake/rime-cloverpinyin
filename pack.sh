#!/usr/bin/env bash
set -e

ver="$1"

cd data
rm -rf clover.schema-$ver.tar.gz
rm -rf clover.schema-build-$ver.tar.gz
tar -zcvf clover.schema-$ver.tar.gz *.yaml opencc/*
if [ -z "build" ]; then
    tar -zcvf clover.schema-build-$ver.tar.gz *.yaml opencc/* build/*
fi
