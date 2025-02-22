
# Lab: User role controlled by request parameter

![](Pasted%20image%2020250223041801.png)

## Goal: accessing the admin panel and deleting the user `carlos`

The clue that we are given here is that we can log in with another account. The credentials are as follow:
wiener:peter

## Steps

1. A good start would be testing the account we are given on the login page.
2. It seems we can try setting the Admin parameter to true. Maybe this could bypass the Admin validation.

	![](Pasted%20image%2020250223042451.png)
	![](Pasted%20image%2020250223042542.png)

3. Through further testing this parameter could just be modified when accessing the /admin page.
	![](Pasted%20image%2020250223042847.png)
	
	Yes, you don't to log in since it's processes the parameter `Admin` and validates only that parameter.
4. We can finally delete `carlos`.

	![](Pasted%20image%2020250223043209.png)
	![](Pasted%20image%2020250223043315.png)
	