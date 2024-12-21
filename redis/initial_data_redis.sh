#!/bin/bash
redis-cli -h redis_app -p 6379 SET "USER|user" "password"
redis-cli -h redis_app -p 6379 HSET "ACL|basic" "proxy_pass" "https://example.com" "authentication_type" "basic"
redis-cli -h redis_app -p 6379 HSET "ACL|digest" "proxy_pass" "https://example.com" "authentication_type" "digest"
