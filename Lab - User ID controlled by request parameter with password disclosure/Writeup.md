# Lab: User ID controlled by request parameter with password disclosure

![](Pasted%20image%2020250226144616.png)

## Goal: retrieve the administrator's password and delete `carlos`

## Steps
1. Since this is relating to User ID we can try logging in with the credential given `wiener`. We can see two things in the URL there's a user ID in plain text and also in the my-account page we can change password.

	![](Pasted%20image%2020250226150106.png)
	
2. We can try changing the user ID from `wiener` to `carlos` to see if we can log in as `carlos` and maybe delete the account (if there's admin privileges).

	![](Pasted%20image%2020250226150427.png)

3. Further look shows that `carlos` doesn't have admin privileges. Guessing common names for admin such as `admin` or `administrator` gets us the id for the admin.

	![](Pasted%20image%2020250302062010.png)

4. Login as `administrator` shows us that there is an admin panel which could be used to delete `carlos`.
	![](Pasted%20image%2020250302062151.png)

	![](Pasted%20image%2020250302062237.png)

	Done


