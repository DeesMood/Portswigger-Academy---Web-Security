## Approach

1. Play around a lot with params that have affects on sensitive functions like
	- Email, could be [admin access based on domain](#[1.%20Inconsistent%20handling%20of%20exceptional%20input](https%20//portswigger.net/web-security/logic-flaws/examples/lab-logic-flaws-inconsistent-handling-of-exceptional-input))
## Labs
### [1. Inconsistent handling of exceptional input](https://portswigger.net/web-security/logic-flaws/examples/lab-logic-flaws-inconsistent-handling-of-exceptional-input)

> [!NOTE] 
> Handling of very long string is using truncation which can be manipulated to bypass admin email restriction

**Very long string input**

```
email=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa@dontwannacry.com.exploit-0ac7003e03e8866d8053dedb01ae0035.exploit-server.net
```

> - **email** value is set to that because the server does a truncation due to maximum char at 256 characters, with that payload it gets truncated exactly at `...aaa@dontwannacry.com`
> - So we are registered at the server as a user from @dontwannacry.com allowing **admin access**
> - But we're still able to activate our account because the format treats **dontwannacry.com** as a subdomain of the [EXPLOIT_SERVER] 
![](attachments/Pasted%20image%2020260103225503.png)

**Confirming registered email**

![](attachments/Pasted%20image%2020260103231336.png)
![](attachments/Pasted%20image%2020260103231412.png)
### [2. Infinite money logic flaw](https://portswigger.net/web-security/logic-flaws/examples/lab-logic-flaws-infinite-money)

> [!NOTE] 
> There's a business logic flaw allowing infinite money, the process is like this:
> 1. Buy a **gift card** with a discount 30% 7$
> 2. Redeem for 10$
> 3. Profit 3$
> 
> Since discount code is unlimited, then unlimited money

**Setup macro**

> 1. Settings -> Sessions -> Session handling rules -> Add
> 2. Scope -> URL scope -> Include all URLs
> 3. Rule actions -> Add -> Run a macro
> 4. Select macro -> Add
> 5. Select the requests flow for the business logic flaw:
> 	- POST /cart
> 	- POST /cart/coupon
> 	- POST /cart/checkout
> 	- GET /cart/order-confirmation?order-confirmed=true
> 		- Configure item -> Custom parameter locations in response -> Add
> 			- Define customer parameter -> insert `gift-card` as **Parameter name**
> 			- Select the **gift card** code
> 	- POST /gift-card
> 		- Configure item -> Parameter handling -> `gift-card`, Derive from previous response (Response 4)

**Automation**

> - How the macro works is that every time there's a request made using ***Intruder, Scanner, etc.***, it will run the macro. Therefore we can use ***Intruder*** to spam null payloads
> - The delay and lower concurrent is for the macro to run one by one, to avoid too much request running possibly resulting in buying too much but not having the time to redeem
![](attachments/Pasted%20image%2020260104015938.png)

