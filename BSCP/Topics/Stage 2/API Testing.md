## Approach

1. Look for sensitive feature
2. Try using param you find somewhere else on a endpoint or even better find a param you notice reference at the point but not used, like maybe a `percentage` param that could let you control the discount
3. Try supplying query syntax characters such as `#`, `&` and `=`, to see if there's unique behavior
## Labs
### [1. Exploiting a mass assignment vulnerability](https://portswigger.net/web-security/api-testing/lab-exploiting-mass-assignment-vulnerability)

> [!NOTE] 
> We can specify manually a param we have seen on an endpoint to other endpoint or operations to force changes, like in this case the `percentage` param that is default at 0 but we can manually set it to 100 when checking out an item allowing us to get it for free

> During `GET /api/checkout` you can see an object that isn't called with a param `percentage` presumably to control discount value
```json
HTTP/2 200 OK
...

{"chosen_discount":{"percentage":0},"chosen_products":[{"product_id":"1","name":"Lightweight \"l33t\" Leather Jacket","quantity":4,"item_price":133700}]}
```

> On `/api/checkout` specify `percentage` object and set a value of 100 to buy the product with 100% discount
```json
{"chosen_products":[{"product_id":"1","quantity":1}],
"chosen_discount":{"percentage":100}
}
```

### [2. Exploiting server-side parameter pollution in a query string](https://portswigger.net/web-security/api-testing/server-side-parameter-pollution/lab-exploiting-server-side-parameter-pollution-in-query-string)

> [!NOTE] 
> There is a vulnerability where we can set another parameter on an endpoint by polluting an existing `username` param where we can get a password reset token due to an API returning the data for a dangerous field data `reset_token`

**Finding hidden param**

> We will get an error "Field not specified.", this actually tells us endpoint accepts another param called `field`
```
username=carlos#
```

**Figuring out value for field**

> - Enumerate value of field using **Simple list** with the wordlist **Server-side variable names**
> - You will get it accepts `email` and `username`, and it controls what data is being return by the endpoint based on that
```
username=carlos%26field=[INTRUDER]
```

**Finding hidden field**

> If we read the JS file, we can see that there's a param for password reset token written as `reset_token` giving us the reset token for that user
```
username=administrator%26field=reset_token
```

