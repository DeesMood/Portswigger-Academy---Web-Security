## Approach

1. Look for sensitive functions like **forgot password** that: 
	- We can [set the **username**](#[1.%20Password%20reset%20broken%20logic](https%20//portswigger.net/web-security/authentication/other-mechanisms/lab-password-reset-broken-logic)) of especially during the final setup of a new password
	- Check for [time sensitive token generation](#[3.%20Exploiting%20time-sensitive%20vulnerabilities](https%20//portswigger.net/web-security/race-conditions/lab-race-conditions-exploiting-time-sensitive-vulnerabiltiesulnerabilities)) for **forgot password** link
2. Look for **change password** functionality, [try removing the `current-password` param](#[2.%20Weak%20isolation%20on%20dual-use%20endpoint](https%20//portswigger.net/web-security/logic-flaws/examples/lab-logic-flaws-weak-isolation-on-dual-use-endpoint))
## Labs
### [1. Password reset broken logic](https://portswigger.net/web-security/authentication/other-mechanisms/lab-password-reset-broken-logic)

> [!NOTE] 
> When using **forgot password** at the final request to set a new password, you can actually set the user allowing us to change other user's password

![](attachments/Pasted%20image%2020260104180123.png)
### [2. Weak isolation on dual-use endpoint](https://portswigger.net/web-security/logic-flaws/examples/lab-logic-flaws-weak-isolation-on-dual-use-endpoint)

> [!NOTE] 
> Weak current password validation, if you **remove it**, it does no validation allowing bypass to change other user's password

![](attachments/Pasted%20image%2020260104181831.png)

> Removed `current-password` param
![](attachments/Pasted%20image%2020260104181928.png)
### [3. Exploiting time-sensitive vulnerabilities](https://portswigger.net/web-security/race-conditions/lab-race-conditions-exploiting-time-sensitive-vulnerabiltiesulnerabilities)

> [!NOTE] 
> - This lab involve time sensitive vulnerabilities where the forgot password link token generation is based on **time** where generating the forgot password link at the exact **same time will result in the same token**
> - This lab uses **PHP session** where there is a quirk, it only **one request at a time per session**

**Benchmarking**

> In sequence (single connection) request test, to compare with parallel request
![](attachments/Pasted%20image%2020260104184228.png)
![](attachments/Pasted%20image%2020260104184314.png)

> - In parallel test, sending both request **at the same time**
> - Each request different session due to PHP session quirk
![](attachments/Pasted%20image%2020260104184508.png)
![](attachments/Pasted%20image%2020260104184648.png)

> - Also we need to do a **connection warming**, so that our first request that initiates the connection to the server does not delay our parallel request
> - We do this by adding a simple **GET / request**, so it can be the dummy for taking on the delay when first making a connection to the server
> - **Note: when sending the group request do it from the GET / tab so it is first during connection**
![](attachments/Pasted%20image%2020260104185151.png)

> Same token, indicating if it's requested at the **same time then same token**
![](attachments/Pasted%20image%2020260104185444.png)

> Same token as victim
![](attachments/Pasted%20image%2020260104185853.png)
![](attachments/Pasted%20image%2020260104185940.png)