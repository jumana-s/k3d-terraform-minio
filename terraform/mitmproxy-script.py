#!/usr/bin/env python3

from mitmproxy import http
import json

print("heyyo")

def decodebytes(b):
    return b.decode('utf8')

def prettyprint(s):
    print(json.dumps(json.loads(s), indent=2))

def request(flow: http.HTTPFlow) -> None:
    x = decodebytes(flow.request.content)
    try:
        prettyprint(x)
    except:
        print(flow.request.content)
        print(x)
