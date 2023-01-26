#!/bin/bash

curl -s -X POST -k --data @- http://10.44.1.119/resources/json/delphix/session \
   -c "cookies.txt" -H "Content-Type: application/json" <<EOF
{
   "type": "APISession",
   "version": {
       "type": "APIVersion",
       "major": 1,
       "minor": 11,
       "micro": 14
  }
}
EOF

curl -s -X POST -k --data @- http://10.44.1.119/resources/json/delphix/login \
-b "cookies.txt" -c "cookies.txt" -H "Content-Type: application/json" <<EOF
{"username":"sysadmin","password":"sysadmin","keepAliveMode":"KEEP_ALIVE_HEADER_ONLY","target":"SYSTEM","type":"LoginRequest"}
EOF