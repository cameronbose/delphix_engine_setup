#!/bin/bash

dxEngine=$1
shift
major=$1
shift 
minor=$1
shift 
micro=$1
shift
emailAddress=$1
shift 
password=$1 
shift 
PhoneHomeService=$1 
shift
UserInterfaceConfig=$1 
shift 
ProxyConfiguration=$1 
shift
SMTPConfig=$1
shift
NTPConfig=$1 
shift 
engineType=$1
shift 
LDAP=$1 

storageList=`cat storageParams.txt`

echo "this is it...... ${storageList}"

curl -s -X POST -k --data @- http://${dxEngine}/resources/json/delphix/session \
   -c "cookies.txt" -H "Content-Type: application/json" <<EOF
{
   "type": "APISession",
   "version": {
       "type": "APIVersion",
       "major": ${major},
       "minor": ${minor},
       "micro": ${micro}
  }
}
EOF

curl -s -X POST -k --data @- http://${dxEngine}/resources/json/delphix/login \
-b "cookies.txt" -c "cookies.txt" -H "Content-Type: application/json" <<EOF
{"username":"sysadmin","password":"sysadmin","keepAliveMode":"KEEP_ALIVE_HEADER_ONLY","target":"SYSTEM","type":"LoginRequest"}
EOF

sleep 10 
curl -s -X POST -k --data @- http://${dxEngine}/resources/json/delphix/user/USER-1 -b "cookies.txt" -H "Content-Type: application/json"<<EOF
{"emailAddress": "${emailAddress}", "type": "User"}
EOF

sleep 10 
curl -s -X POST -k --data @- http://${dxEngine}/resources/json/delphix/user/USER-1/updateCredential \
-b "cookies.txt" -c "cookies.txt" -H "Content-Type: application/json" <<EOF
{"newCredential": {"password": "${password}", "type": "PasswordCredential"}, "type": "CredentialUpdateParameters"}
EOF 
sleep 10 
curl -s -X POST -k --data @- http://${dxEngine}/resources/json/delphix/service/phonehome \
-b "cookies.txt" -c "cookies.txt" -H "Content-Type: application/json" <<EOF
{"enabled": ${PhoneHomeService}, "type": "PhoneHomeService"}
EOF
sleep 10 
curl -s -X POST -k --data @- http://${dxEngine}/resources/json/delphix/service/userInterface \
-b "cookies.txt" -c "cookies.txt" -H "Content-Type: application/json" <<EOF
{"analyticsEnabled": ${UserInterfaceConfig}, "type": "UserInterfaceConfig"}
EOF
sleep 10 
curl -s -X POST -k --data @- http://${dxEngine}/resources/json/delphix/service/proxy \
-b "cookies.txt" -c "cookies.txt" -H "Content-Type: application/json" <<EOF
{"https": {"enabled": ${ProxyConfiguration}, "type": "ProxyConfiguration"}, "type": "ProxyService"}
EOF
sleep 10 
curl -s -X POST -k --data @- http://${dxEngine}/resources/json/delphix/service/smtp \
-b "cookies.txt" -c "cookies.txt" -H "Content-Type: application/json" <<EOF
{"enabled": ${SMTPConfig}, "type": "SMTPConfig"}
EOF
sleep 10 
curl -s -X POST -k --data @- http://${dxEngine}/resources/json/delphix/system \
-b "cookies.txt" -c "cookies.txt" -H "Content-Type: application/json" <<EOF
{"engineType": "${engineType}", "type": "SystemInfo"}
EOF
sleep 10

if [ ${engineType} == "MASKING" ];then
    echo "this bit"
    authKey=$(curl -s -X POST -k --data @- http://${dxEngine}/masking/api/login \
    -b "cookies.txt" -c "cookies.txt" -H "Content-Type: application/json" <<EOF
    {"username":"admin","password":"Admin-12"}
EOF
)
fi

authKey=$(echo $authKey | cut -d ":" -f 2 | tr -d '",}')

if [ ${engineType} == "MASKING" ];then
    echo "then this bit ${authKey}"
    curl -s -X PUT -k --data @- http://${dxEngine}/masking/api/users/6 \
    -b "cookies.txt" -c "cookies.txt" -H "Content-Type: application/json" -H "Authorization: ${authKey}" <<EOF
    {"userName":"admin","password":"${password}","firstName":"","lastName":"","email":"${emailAddress}","isAdmin":true,"userStatus":"ACTIVE"}
EOF
fi 

if [ ${LDAP} != "NONE" ];then
    curl -s -X POST -k --data @- http://${dxEngine}/resources/json/delphix/service/ldap/server \
    -b "cookies.txt" -c "cookies.txt" -H "Content-Type: application/json" <<EOF
    {"host":"${LDAP}","port":389,"authMethod":"SIMPLE","useSSL":false,"type":"LdapServer"}
EOF
fi 

# curl -s -X POST -k --data @- http://${dxEngine}/resources/json/delphix/system \
# -b "cookies.txt" -c "cookies.txt" -H "Content-Type: application/json"
# http://${dxEngine}/resources/json/delphix/system/stopMasking
# no payload! 

current_date=$(date +"%Y-%m-%d")
current_time=$(date +"%H:%M:%S")

curl -s -X POST -k --data @- http://${dxEngine}/resources/json/delphix/service/time \
-b "cookies.txt" -c "cookies.txt" -H "Content-Type: application/json" <<EOF
{"currentTime":"${current_date}T${current_time}Z","systemTimeZone":"Europe/London","ntpConfig":{"enabled":${NTPConfig},"type":"NTPConfig"},"type":"TimeConfig"}
EOF

curl -s -X POST -k --data @- http://${dxEngine}/resources/json/delphix/domain/initializeSystem \
-b "cookies.txt" -c "cookies.txt" -H "Content-Type: application/json" <<EOF
{"defaultUser":"admin","defaultPassword":"${password}","defaultEmail":"${emailAddress}","devices":${storageList},"type":"SystemInitializationParameters"}
EOF 


