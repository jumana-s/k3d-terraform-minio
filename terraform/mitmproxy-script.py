#!/usr/bin/env python3

from mitmproxy import http
import json

def decodebytes(b):
    return b.decode('utf8')

def prettyprint(s):
    print(json.loads(s, indent=4, sort_keys=True))

def request(flow: http.HTTPFlow) -> None:
    print
    x = decodebytes(flow.request.content)
    try:
        prettyprint(x)
    except:
        print(x)
