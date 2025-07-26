
# Lab: Username enumeration via different responses

![](Pasted%20image%2020250302064939.png)

## Goal: enumerate a valid username, brute force the password, and access the account

Hint given is that the website is vulnerable to username enumeration and password brute force. and there's a wordlist given.

| Usernames      | Passwords  |
| -------------- | ---------- |
| carlos         | 123456     |
| root           | password   |
| admin          | 12345678   |
| test           | qwerty     |
| guest          | 1,23E+08   |
| info           | 12345      |
| adm            | 1234       |
| mysql          | 111111     |
| user           | 1234567    |
| administrator  | dragon     |
| oracle         | 123123     |
| ftp            | baseball   |
| pi             | abc123     |
| puppet         | football   |
| ansible        | monkey     |
| ec2-user       | letmein    |
| vagrant        | shadow     |
| azureuser      | master     |
| academico      | 666666     |
| acceso         | qwertyuiop |
| access         | 123321     |
| accounting     | mustang    |
| accounts       | 1,23E+09   |
| acid           | michael    |
| activestat     | 654321     |
| ad             | superman   |
| adam           | 1qaz2wsx   |
| adkit          | 7777777    |
| admin          | 121212     |
| administracion | 0          |
| administrador  | qazwsx     |
| administrator  | 123qwe     |
| administrators | killer     |
| admins         | trustno1   |
| ads            | jordan     |
| adserver       | jennifer   |
| adsl           | zxcvbnm    |
| ae             | asdfgh     |
| af             | hunter     |
| affiliate      | buster     |
| affiliates     | soccer     |
| afiliados      | harley     |
| ag             | batman     |
| agenda         | andrew     |
| agent          | tigger     |
| ai             | sunshine   |
| aix            | iloveyou   |
| ajax           | 2000       |
| ak             | charlie    |
| akamai         | robert     |
| al             | thomas     |
| alabama        | hockey     |
| alaska         | ranger     |
| albuquerque    | daniel     |
| alerts         | starwars   |
| alpha          | klaster    |
| alterwind      | 112233     |
| am             | george     |
| amarillo       | computer   |
| americas       | michelle   |
| an             | jessica    |
| anaheim        | pepper     |
| analyzer       | 1111       |
| announce       | zxcvbn     |
| announcements  | 555555     |
| antivirus      | 11111111   |
| ao             | 131313     |
| ap             | freedom    |
| apache         | 777777     |
| apollo         | pass       |
| app            | maggie     |
| app01          | 159753     |
| app1           | aaaaaa     |
| apple          | ginger     |
| application    | princess   |
| applications   | joshua     |
| apps           | cheese     |
| appserver      | amanda     |
| aq             | summer     |
| ar             | love       |
| archie         | ashley     |
| arcsight       | nicole     |
| argentina      | chelsea    |
| arizona        | biteme     |
| arkansas       | matthew    |
| arlington      | access     |
| as             | yankees    |
| as400          | 9,88E+08   |
| asia           | dallas     |
| asterix        | austin     |
| at             | thunder    |
| athena         | taylor     |
| atlanta        | matrix     |
| atlas          | mobilemail |
| att            | mom        |
| au             | monitor    |
| auction        | monitoring |
| austin         | montana    |
| auth           | moon       |
| auto           | moscow     |
| autodiscover   |            |

Since it's stated that we should try brute force, what we can do is capture the request for login on burp.

![](attachments/Pasted%20image%2020250726185031.png)

From the image above, we can see that there's a chance we could enumerate this due to the system telling us "Invalid username". Next we can throw this request to the intruder.

![](attachments/Pasted%20image%2020250726185352.png)

We can first enumerate a valid username like the image above. The payload can be for the username and password are stated in the link on the lab question. Here are the links:
- For [username](https://portswigger.net/web-security/authentication/auth-lab-usernames)
- For [password](https://portswigger.net/web-security/authentication/auth-lab-passwords)

If the intruder payload above is executed, you will end up with a username "atlas". Which you can filter by **length** on burp and it will reveal the response **length**. By finding a different one we can guess that it will probably be a different response that the usual "Invalid username".

![](attachments/Pasted%20image%2020250726191203.png)

Since we have known the username "atlas", we can try brute forcing it's password with the payload given. 

![](attachments/Pasted%20image%2020250726191334.png)

Done we got the pass which is "harley"

![](attachments/Pasted%20image%2020250726191408.png)

Just login and we should be done.

