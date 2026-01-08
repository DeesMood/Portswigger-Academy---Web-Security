## Approach

1. Use `HTTP Request Smuggler` > `Connection State` probe, for [this](#[2.%20Host%20validation%20bypass%20via%20connection%20state%20attack](https%20//portswigger.net/web-security/host-header/exploiting/lab-host-header-host-validation-bypass-via-connection-state-attack))
2. Things to check:
	- [ ] Double `Host` headers
	- [ ] `X-Forwarded-Host` header supported
3. Do the above on:
	- `GET /`
	- Sensitive endpoints [**forgot password**](#[1.%20Password%20reset%20poisoning%20via%20middleware](https%20//portswigger.net/web-security/authentication/other-mechanisms/lab-password-reset-poisoning-via-middleware))
## Labs
### [1. Password reset poisoning via middleware](https://portswigger.net/web-security/authentication/other-mechanisms/lab-password-reset-poisoning-via-middleware)

> [!NOTE] 
> `X-Forwarded-Host` header is supported based on 200 response when using it, poison the password reset request by changing host to exploit server
> 

![](attachments/Pasted%20image%2020260103080832.png)
![](attachments/Pasted%20image%2020260103081002.png)
### [2. Host validation bypass via connection state attack](https://portswigger.net/web-security/host-header/exploiting/lab-host-header-host-validation-bypass-via-connection-state-attack)

> [!NOTE] 
> It treats the **second request** of a **single connection** as **safe**, you can access the **admin panel** by sending **a safe request and an admin panel request in a single connection**
> 
> Note: the `/admin` request has to have a session, if not you'll get a `421`

**Request 1**

```
GET / HTTP/1.1
Host: 0a78009c04c0742f801544ed006f0094.h1-web-security-academy.net
...
```

**Request 2**

```
GET /admin HTTP/1.1
Host: 192.168.0.1
Cookie: session=[SESSION]; _lab=[LAB]
```

![](attachments/Pasted%20image%2020260103083757.png)
