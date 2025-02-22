# Lab: User ID controlled by request parameter, with unpredictable user IDs

![](Pasted%20image%2020250223044247.png)

## Goal: Find GUID for `carlos`, submit the API key as the solution.

The clue here is to find `carlos's` GUID somewhere in the website through IDOR.

## Steps

1. Let's look around for `carlos's` GUID.
2. If we log in with the credentials given. We can see that the API key is shown in the account page of the user. We can also see the GUID for our user which give's us a clue to what we're looking for.

	![](Pasted%20image%2020250223044617.png)
	![](Pasted%20image%2020250223044721.png)

3. So luckily for us, carlos see to have a post on the website and the website groups the posts made by a user based on GUID.

	![](Pasted%20image%2020250223045544.png)

4. Done.
	![](Pasted%20image%2020250223045852.png)
	![](Pasted%20image%2020250223045920.png)
	