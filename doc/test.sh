#!/bin/bash

# Basic認証のテスト
echo "-----Basic Authentication Test-----"
response_basic=$(curl -s -u user:password http://localhost/basic)
if echo "$response_basic" | grep -q "<title>Example Domain</title>"; then
    echo "Basic Authentication Success"
else
    echo "Basic Authentication Failed"
fi

# Digest認証のテスト
# TODO
