package httpapi.authz

import input

default allow = false

rl_permissions := {
    "reader": [
        {"action": "s3:ListBucket"},
        {"action": "s3:GetObject"},
        {"action": "s3:ListAllMyBuckets"},
    ],
    "user": [
        {"action": "s3:CreateBucket"},
        {"action": "s3:DeleteBucket"},
        {"action": "s3:DeleteObject"},
        {"action": "s3:GetObject"},
        {"action": "s3:ListAllMyBuckets"},
        {"action": "s3:GetBucketObjectLockConfiguration"},
        {"action": "s3:ListBucket"},
        {"action": "s3:PutObject"},
    ],
    "shared": [
        {"action": "s3:ListAllMyBuckets"},
        {"action": "s3:GetObject"},
        {"action": "s3:ListBucket"},
    ],
}

##
## PRIVATE BUCKETS
##

# Allow access from OIDC
allow {
    print(input)
    trace(sprintf("input: %s", [input]))
    # print(sprintf("input: %s", [input]))
    # input.email == "admin@statcan.gc.ca"
    #input.given_name == "admin"
    #permissions := rl_permissions.user
    #p := permissions[_]
    #p == {"action": input.action}
}

allow {
    1 == 1
}