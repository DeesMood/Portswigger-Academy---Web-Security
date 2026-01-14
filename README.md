# Portswigger BSCP Guide

This resource is for anyone trying to study for the ***Burp Suite Certified Practitioner*** (**BSCP**) exam.

I've made it in two parts:

1. A complete note of all the topics and writeup of the labs:

https://docs.google.com/spreadsheets/d/1GMdZ_9Zq30h5Lz_y4O2846Mz3owlgRf3xGVpR5l7BgA/edit?usp=sharing

2. I also made a per stage for BSCP note written in obsidian markdown that can be seen from [here](https://github.com/DeesMood/Portswigger-Academy---Web-Security/tree/main/BSCP/Topics)

## Personal Tips

**1. Follow [the preparation methodology](https://portswigger.net/web-security/certification/how-to-prepare#:~:text=Still%20learning%20the%20fundamentals%20of%20web%20security%3F) as stated by Portswigger.**

It's very crucial for your own knowledge and for the exam that you do all the **Apprentice** and **Practitioner** labs. As you will gain a good amount of knowledge on web vulnerabilities in the exam and in real life for the most part.

**2. Make good notes that you can refer to fast.**

The exam is only 4 hours, you need a good methodology for doing the exam. I personally uploaded all my notes is in Google Sheets and Github as you can see in this repository.

**3. _Burp Scanner_ for the win**

The scanner helped me in so many ways:
- Immediately after starting the exam, I ran a scan for **HTTP Request Smuggling** on both apps and in less than 5 mins the scanner detected the vulnerability in one of the app.
- It helps confirm injection vulnerabilities like SQL injection, as I got an **advanced search** functionality that most likely contain an SQLi like in the practice exam.
- It tells you what payload works for the corresponding vulnerability it detected allowing for a fast exploitation via the scanner payload.

_**DISCLAIMER: It will not find authentication and API vulnerabilities, vulnerabilities like user enumerations and vulnerable API**_

**4. Have a clear flow in testing**

During the exam I have a testing flow I work with, this allowed me to detect vulnerabilities quickly. For example:
1. Do a _**Burp Scanner**_ for **HTTP Request Smuggling** on both apps in the home page
2. Do a _**Burp Scanner**_ for vulnerabilities in stage 1 on both apps in the home page
3. Check for user enumeration in **login page** and **forgot password page**
4. ...

**5. Use a good device**

One of the BIGGEST trouble I encounter during the exam is my potato device freezing on me intermittently during the entire exam. I was unable to use my LINUX VM (because I use Windows) during the exam due to my potato device.

**6. Understanding the technical process**

It is important you understand the process of the exam, so you don't make the same mistake I did. The process:
1. Start the exam from the certification page accessed 
