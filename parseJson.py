
import sys
import requests
import json

def getData():
    data = requests.get("http://192.168.8.92:12000/console/?act=reload")
    print json.dumps(json.loads(data.content), ensure_ascii=False, encoding="utf -8", indent=4)

if __name__ == "__main__":
    getData()