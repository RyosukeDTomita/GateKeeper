#!/bin/bash

# Basic認証のテスト
echo "-----Basic Authentication Test-----"
response_basic=$(curl -s -u user:password http://example.com/basic)
if echo "$response_basic" | grep -q "<title>Example Domain</title>"; then
    echo "Basic Authentication Success"
else
    echo "Basic Authentication Failed"
fi

# Digest認証のテスト
echo "-----Digest Authentication Test-----"
response_digest=$(curl -s --digest -u user:password http://example.com/digest)
if echo "$response_digest" | grep -q "<title>Example Domain</title>"; then
    echo "Digest Authentication Success"
else
    echo "Digest Authentication Failed"
fi
