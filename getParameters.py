import os 
import json
import sys 

versionDict = {'6.0.14.0':'1.11.14','6.0.15.0':'1.11.15','6.0.16.0':'1.11.16','6.0.17.0':'1.11.17'}

dxEngine = sys.argv[1]
dxVersion = sys.argv[2]
emailAddress = sys.argv[3]
password = sys.argv[4]
PhoneHomeService = sys.argv[5]
UserInterfaceConfig = sys.argv[6]
ProxyConfiguration = sys.argv[7]
SMTPConfig = sys.argv[8]
NTPConfig = sys.argv[9]
engineType = sys.argv[10]
LDAP = sys.argv[11]

def getDiskReference():
    APIQuery = os.popen(f'curl -X GET -k http://{dxEngine}/resources/json/delphix/storage/device -b "cookies.txt" -H "Content-Type: application/json"').read()
    queryDict = json.loads(APIQuery)
    print(queryDict)
    myList = []
    for disk in queryDict["result"]:
        if disk['configured'] == False: 
            diskReference = disk["reference"]
            myList.append(diskReference)
        else: 
            print("Nope")
    myList = f"{myList}"
    myList = myList.replace('\'', '"')
    return myList

def getAPIVersion(delphixVersion):
    apiVersion = versionDict[delphixVersion]
    major,minor,micro = apiVersion.split('.')
    return major,minor,micro  

if __name__ == "__main__": 
    
    print("logging in")
    os.system("sh login.sh")
        
    theList = getDiskReference()
    with open("storageParams.txt", "w") as storageParams:
        storageParams.write(f"{theList}")

    major,minor,micro = getAPIVersion(dxVersion)
    os.system(f"sh POST_Commands.sh {dxEngine} {major} {minor} {micro} {emailAddress} {password} {PhoneHomeService} {UserInterfaceConfig} {ProxyConfiguration} {SMTPConfig} {NTPConfig} {engineType} {LDAP}")


