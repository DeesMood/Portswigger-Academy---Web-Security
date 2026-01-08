## Approach

1. Find any param accepting URL
2. Getting blocked by the server? check [this](#Cheat%20sheets)
3. Check for [parsing discrepancy](#[2.%20SSRF%20via%20flawed%20request%20parsing](https%20//portswigger.net/web-security/host-header/exploiting/lab-host-header-ssrf-via-flawed-request-parsing)) that allows supplying full URL but different `Host` header
4. If there's a use of `openid`, check for the ability to [register a client](#[3.%20SSRF%20via%20OpenID%20dynamic%20client%20registration](https%20//portswigger.net/web-security/oauth/openid/lab-oauth-ssrf-via-openid-dynamic-client-registration)) via `.well-known/openid-configuration`
5. Keep in mind of open redirection vuln, it can be used to facilitate **SSRF**
## Labs
### [1. SSRF with blacklist-based input filter](https://portswigger.net/web-security/ssrf/lab-ssrf-with-blacklist-filter)

> [!NOTE] 
> The stock check feature is using an API that accepts URL as param allowing access to admin panel

> - There's a few blacklist being done, it filters `admin`, so you can supply `ADmIn`
> - Referencing internal host like `localhost` and `127.0.0.1` is not possible so you can use `127.1`
```
stockApi=http://127.1/aDMin
```

### [2. SSRF via flawed request parsing](https://portswigger.net/web-security/host-header/exploiting/lab-host-header-ssrf-via-flawed-request-parsing)

> [!NOTE] 
> A parsing discrepancy between FE and BE allowing a bypass by supplying full URL and loading different controlled by the `Host` header allowing internal access to the admin panel

**Testing OOB on `Host` header**

> - ***Burp Collaborator*** is loaded showing it's possible to load resources from other `Host` as long as the actual target is part of the URL
> - This discrepancy exist due to the FE only looking if the URL contains the target while the BE processes request based on the `Host` header
![](attachments/Pasted%20image%2020260107142945.png)

**Enumerate internal IP**

> Use ***Burp Intruder*** to find the internal IP hosting the admin panel
![](attachments/Pasted%20image%2020260107144158.png)

**Access the admin panel**

![](attachments/Pasted%20image%2020260107143800.png)
### [3. SSRF via OpenID dynamic client registration](https://portswigger.net/web-security/oauth/openid/lab-oauth-ssrf-via-openid-dynamic-client-registration)

> [!NOTE] 
> **OpenID** allows registering of dynamic client that can be used as a vector for SSRF

**Checking `.well-known/openid-configuration`**

> There's a client registration path in `/reg`
![](attachments/Pasted%20image%2020260107151953.png)

**Register a dynamic client**

> We can supply an SSRF to the `logo_uri` param containing the secret key because of it loading static files
```json
POST /reg HTTP/2

...
{ "application_type": "web", "redirect_uris": [ "https://client-app.com/callback", "https://client-app.com/callback2" ], "client_name": "My Application", "logo_uri": "http://169.254.169.254/latest/meta-data/iam/security-credentials/admin/", "token_endpoint_auth_method": "client_secret_basic", "jwks_uri": "https://client-app.com/my_public_keys.jwks", "userinfo_encrypted_response_alg": "RSA1_5", "userinfo_encrypted_response_enc": "A128CBC-HS256" }
```

**Access the SSRF file**

```
GET /client/[CLIENT_ID]/logo
```

### [4. Routing-based SSRF](https://portswigger.net/web-security/host-header/exploiting/lab-host-header-routing-based-ssrf)

> [!NOTE] 
> An SSRF can be done on the `Host` header by specifying internal IP to access `/admin` 

**Detect SSRF via `Host` header**

> Collaborator was loaded by the target
![](attachments/Pasted%20image%2020260107155454.png)

**Enumerate internal IP**

> Gotten 192.168.0.186 as the internal IP
![](attachments/Pasted%20image%2020260107155733.png)

**Accessing admin panel**

> Accessing admin panel via `Host` header
![](attachments/Pasted%20image%2020260107155912.png)
### [5. SSRF with filter bypass via open redirection vulnerability](https://portswigger.net/web-security/ssrf/lab-ssrf-filter-bypass-via-open-redirection)

> [!NOTE] 
> **Stock check** API accepts a URL input that will serve the contain in that URL, this is a sign of possible SSRF, to exploit there's a open redirection when clicking next post, allowing SSRF to `/admin`

**Find open redirection**

> There's an open redirection when clicking next post
![](attachments/Pasted%20image%2020260107161034.png)

**SSRF via open redirection**

> SSRF can be done via open redirection
![](attachments/Pasted%20image%2020260107160842.png)
## Cheat sheets

https://portswigger.net/web-security/ssrf/url-validation-bypass-cheat-sheet
> Portswigger URL validation bypass