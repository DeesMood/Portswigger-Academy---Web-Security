## Approach

1. 
## Labs
### [1. Forced OAuth profile linking](https://portswigger.net/web-security/oauth/lab-oauth-forced-oauth-profile-linking)

> [!NOTE] 
> No `state` param during OAuth process allows CSRF to be done, this case it's done on social linking, attaching our social account to a victim's account 

> **State** param is not used allowing CSRF attack on social linking feature
![](attachments/Pasted%20image%2020260104064948.png)

> Generating CSRF PoC from the previously generated auth token,
> **Host** the PoC on the **exploit server** and **Deliver the exploit to victim**
> Note: **Don't send the request yourself, it will use up the code**
![](attachments/Pasted%20image%2020260104065237.png)

>After delivering the exploit, our social account will be linked to the victim's account
![](attachments/Pasted%20image%2020260104070508.png)
## 2. 