![[Pasted image 20250103192507.png]]
# Goal: retrieve the contents of the /etc/passwd file. 

This is a simple lab where we are introduced to **File Path Traversal**. In the description we're already told where is the location of the vulnerability.

> This lab contains a path traversal vulnerability in the display of product images. 

So if access the lab, we will be introduced to this homepage.

![[Pasted image 20250103193235.png]]

## Steps to solving

1. Based on the description of the lab we should look for the vulnerability in the image. we can select one of the product to see it's product page.

![[Pasted image 20250103193404.png]]

2. Next, we should try capture it in burp. We can see in burp the HTTP request. This is the response when you GET the product page.

![[Pasted image 20250103194514.png]]

Here we can see that the first request to get the content of the product page. But the next one is a HTTP request to get the image.

![[Pasted image 20250103194707.png]]

3. We can try path traversal here.

![[Pasted image 20250103194732.png]]

4. Okay we're done here, we got the content of passwd (the list of users in Linux system).

![[Pasted image 20250103194824.png]]








