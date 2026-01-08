## Approach

1. Check for sensitive functionality that controls a user's account like **change email**, check if there's params that control user access like `roleid`
2. Study the process of a sensitive function well, like if a login process also has a role select process it could be using **admin access** to apply roles
3. Test `TRACE` method and `X-Original-URL` header to bypass `/admin`  
## Labs
### [1. User role can be modified in user profile](https://portswigger.net/web-security/access-control/lab-user-role-can-be-modified-in-user-profile)

> [!NOTE] 
> While changing email you can control the **roleId** of your user allowing admin access

**Gain admin**

> You can see the response of change email by the response as it contains a param `roleid`, if we specify `roleid` param and set it to 2, this will give admin
```json
{"email":"a@a",
"roleid":2
}
```

### [2. Authentication bypass via flawed state machine](https://portswigger.net/web-security/logic-flaws/examples/lab-logic-flaws-authentication-bypass-via-flawed-state-machine)

> [!NOTE] 
> During login process, we can select a role during this process the session you are given is actually admin

> We are given the admin account when login, I think this is because role select is an admin only feature
![](attachments/Pasted%20image%2020260107083536.png)

> We got admin panel access if we use the session to go back to `/`
![](attachments/Pasted%20image%2020260107083724.png)

### [3. URL-based access control can be circumvented](https://portswigger.net/web-security/access-control/lab-url-based-access-control-can-be-circumvented)

> [!NOTE] 
> Unauthorized access to `/admin` but is blocked by FE, we can circumvent with `X-Original-URL` header allowing access

> We access `/` but tells the server with the `X-Original-URL` header that we were actually accessing `/admin`, this allows bypass of FE due it not using `X-Original-URL` but the BE accepts it
![](attachments/Pasted%20image%2020260107085054.png)

### [4. Authentication bypass via information disclosure](https://portswigger.net/web-security/information-disclosure/exploiting/lab-infoleak-authentication-bypass)

> [!NOTE] 
> There's information disclosure via `TRACE` method that shows we can specify IP with a custom header `X-Custom-Ip-Authorization` which allows us to specify a internal IP `localhost` to be able to access `/admin`

> Using `TRACE` http method to echo back the actual request used by the server containing a custom header `X-Custom-Ip-Authorization`
![](attachments/Pasted%20image%2020260107091124.png)

> Using the custom header to tell the server we're accessing from `localhost`
![](attachments/Pasted%20image%2020260107090810.png)