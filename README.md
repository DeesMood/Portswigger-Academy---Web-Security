# Portswigger Web Academy

I have a complete note of all the topics and writeup of the labs (Apprentice and Practitioner):

https://docs.google.com/spreadsheets/d/1GMdZ_9Zq30h5Lz_y4O2846Mz3owlgRf3xGVpR5l7BgA/edit?usp=sharing

## Portswigger BSCP Guide

This resource is for anyone trying to study for the ***Burp Suite Certified Practitioner*** (**BSCP**) exam. I made the notes in stages for the exam. The notes can be seen from [here](https://github.com/DeesMood/Portswigger-Academy---Web-Security/tree/main/BSCP/Topics)

### Personal Tips

**1. Follow [the preparation methodology](https://portswigger.net/web-security/certification/how-to-prepare#:~:text=Still%20learning%20the%20fundamentals%20of%20web%20security%3F) given by Portswigger.**

It's quite crucial for the exam, that you do all the **Apprentice** and **Practitioner** labs. You will gain a good amount of knowledge on web vulnerabilities for the exam and real engagements.

**2. Make good notes that you can refer to fast.**

The exam is only 4 hours, everything should be structured efficiently for the exam. I personally uploaded all my notes in Google Sheets and Github.

**3. _Burp Scanner_ for the win**

The scanner helped me in so many ways:
- Immediately after starting the exam, I ran a scan for **HTTP Request Smuggling** on both apps. In less than 5 mins, the scanner detected the vulnerability in one of the apps.
- It helps in confirming injection vulnerabilities like SQL injection. I got an **advanced search** functionality that most likely contain an SQLi like in the practice exam.
- It tells you the working payload for a vulnerability it detected. This allows for fast exploitation by modifying the scanner payload.

_**DISCLAIMER: It will not find authentication vulnerabilities, API vulnerabilities, and user enumeration vulnerability**_

**4. Have a clear flow for testing**

During the exam I have a testing flow that I work with. This allowed me to detect vulnerabilities quickly. 

For example:
1. Do a _**Burp Scanner**_ for **HTTP Request Smuggling** on both apps in the home page.
2. Do a _**Burp Scanner**_ for vulnerabilities in stage 1 on both apps in the home page.
3. Check for user enumeration in **login page** and **forgot password page**.
4. ...

**5. Use a good device**

I don't know why but the proctoring service is really heavy on my device. This got so bad to the point that I was unable to run my VM.

**6. Understanding the technical process**

It is important you understand the process of the exam, so you don't make the same mistake I did. 

The process:
1. After purchasing the exam voucher, you can start the exam from the certification page accessed via my account page.
2. **Open that in the browser your using for your proctor as well**, since the proctor can only run on browsers other than the _**Burp Browser**_. This is the mistake I made, because the exam page will also be the page for submitting you project file. You will not be able to submit it if you're accessing it from your _**Burp Browser**_ that is tied to your current **_Burp_** session.
3.  Setup the proctor for the exam - It will ask for a goverment ID and permission to share you screens and webcam.
4.  Start the exam - It will generate 2 apps for you to finish and the timer will start running.
5.  Work on all the apps in your **_Burp Suite_**. The project file will be used to validate your attempt. (Save Intruder Attacks, I really recommend this as I think it could really help speed up the validation process)
6.  After submitting the final flag, the exam page will turn into a submission page for the project file. Zip and upload your project file.
> If you have any trouble email Portswigger immediately on hello@portswigger.net. I had trouble uploading the project file, so I emailed them my project file which they accepted.

7. You will get your result in 3-5 days. I got mine in 2 days via email. Some people didn't get one so you can check your certification page if it's updated or not.
