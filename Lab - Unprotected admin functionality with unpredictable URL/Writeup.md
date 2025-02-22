
# Lab: Unprotected admin functionality with unpredictable URL

![](Pasted%20image%2020250105215620.png)

## Goal: accessing the admin panel, and using it to delete the user `carlos`

The clue we are given to this is that there is an unprotected admin panel but the location for it is disclosed somewhere in the app.

## Steps

1. So some ideas where an admin panel could be disclosed could be places like:
	- .htaccess
	- robots.txt
	- In this case, it's actually in the source code where there's JS validation to check if the user is an administrator.

	![](Pasted%20image%2020250223034815.png)
	
2. We can just go to the admin panel and delete the user `carlos`.
	![](Pasted%20image%2020250223035128.png)
	
