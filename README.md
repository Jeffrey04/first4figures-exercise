# First4Figures Coding Exercise

--

## Setting up

Application is tested with Ruby `3.3.5`, and `rails` gem installed out of bundle (`gem install rails`).

1. Set up running environment variables at `OrdersAPI/.env`, by referring to the following template:
   ```
   POSTGRES_HOST=localhost
   POSTGRES_USER=postgres
   POSTGRES_PASSWORD=password
   POSTGRES_DB=orders_api_development
   JWT_SECRET=hello
   ```
2. Pull packages
   ```
   cd OrdersAPI
   bundle install
   ```
3. Start up database through podman/docker
   ```
   podman compose up -d db
   ```
4. Run database migrations
   ```
   rails db:create db:migrate
   ```

## Running tests

1. Change directory into `OrdersAPI` if you haven't already
   ```
   cd OrdersAPI
   ```
2. Run test with
   ```
   rspec
   ```

## Running server

1. Change directory into `OrdersAPI` if you haven't already
   ```
   cd OrdersAPI
   ```
2. Run rails dev server
   ```
   rails server
   ```
3. You will need a token, currently in this proof-of-concept API website only authorizes payload with
   ```
   {
     "name": "jeffrey04"
   }
   ```
   to pass. Refer to https://jwt.io/ to generate a authorization token
4. You can now issue API calls to the endpoints
   ```
   http localhost:8080/orders Authorization:"Bearer ${TOKEN}"
   ```

## API Calls

### Orders

#### Creating order

```
$ http POST localhost:8080/orders \
    Authorization:"Bearer ${TOKEN}" \
    product_name=foo \
    quantity:=10 \
    price:=100

HTTP/1.1 302 Found
Cache-Control: no-cache
Content-Length: 0
Content-Type: text/html; charset=utf-8
Location: http://localhost:8080/orders/3
Referrer-Policy: strict-origin-when-cross-origin
Server-Timing: start_processing.action_controller;dur=0.01, sql.active_record;dur=27.08, start_transaction.active_record;dur=0.01, transaction.active_record;dur=31.07, redirect_to.action_controller;dur=5.71, process_action.action_controller;dur=91.16
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
X-Permitted-Cross-Domain-Policies: none
X-Request-Id: 5e707e1f-de95-49b8-8803-fc665982bf1c
X-Runtime: 0.096066
X-Xss-Protection: 0
```

#### Retrieve order

```
$ http localhost:8080/orders/3 \
    Authorization:"Bearer ${TOKEN}"

HTTP/1.1 200 OK
Cache-Control: max-age=0, private, must-revalidate
Content-Length: 172
Content-Type: application/json; charset=utf-8
Etag: W/"d48601e88a65ca966b819a7a9a5d58a9"
Referrer-Policy: strict-origin-when-cross-origin
Server-Timing: start_processing.action_controller;dur=0.01, sql.active_record;dur=0.81, instantiation.active_record;dur=0.13, process_action.action_controller;dur=22.95
Vary: Accept
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
X-Permitted-Cross-Domain-Policies: none
X-Request-Id: 07074516-c376-4111-858b-4ed68d7bdd8d
X-Runtime: 0.029186
X-Xss-Protection: 0

{
    "id": 3,
    "product_name": "foo",
    "quantity": 10,
    "price": "100.0",
    "created_at": "2024-11-14T12:31:34.322Z",
    "updated_at": "2024-11-14T12:31:34.322Z",
    "order_status": "pending_payment"
}
```

#### Update order

```
$ http PUT localhost:8080/orders/3 \
    Authorization:"Bearer ${TOKEN}" \
    product_name=bar

HTTP/1.1 302 Found
Cache-Control: no-cache
Content-Length: 0
Content-Type: text/html; charset=utf-8
Location: http://localhost:8080/orders/3
Referrer-Policy: strict-origin-when-cross-origin
Server-Timing: start_processing.action_controller;dur=0.01, sql.active_record;dur=28.14, instantiation.active_record;dur=0.06, start_transaction.active_record;dur=0.01, transaction.active_record;dur=30.52, redirect_to.action_controller;dur=0.96, process_action.action_controller;dur=55.47
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
X-Permitted-Cross-Domain-Policies: none
X-Request-Id: 63906dc7-f299-4b5e-b377-66b4a2e0ea0a
X-Runtime: 0.060381
X-Xss-Protection: 0
```

#### Delete order

```
$ http DELETE localhost:8080/orders/3 \
    Authorization:"Bearer ${TOKEN}"

HTTP/1.1 303 See Other
Cache-Control: no-cache
Content-Length: 0
Content-Type: text/html; charset=utf-8
Location: http://localhost:8080/orders
Referrer-Policy: strict-origin-when-cross-origin
Server-Timing: start_processing.action_controller;dur=0.01, sql.active_record;dur=32.80, instantiation.active_record;dur=0.13, start_transaction.active_record;dur=0.01, transaction.active_record;dur=34.84, redirect_to.action_controller;dur=0.47, process_action.action_controller;dur=43.52
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
X-Permitted-Cross-Domain-Policies: none
X-Request-Id: 87546ec3-9328-425f-a356-983df0d5a4f3
X-Runtime: 0.047518
X-Xss-Protection: 0
```

### Log for Orders

Endpoint recognizes GET parameter / SearchParam `order_id`

```
$ http localhost:8080/logs \
    Authorization:"Bearer ${TOKEN}" \
    order_id==4
HTTP/1.1 200 OK
Cache-Control: max-age=0, private, must-revalidate
Content-Length: 2
Content-Type: application/json; charset=utf-8
Etag: W/"4f53cda18c2baa0c0354bb5f9a3ecbe5"
Referrer-Policy: strict-origin-when-cross-origin
Server-Timing: start_processing.action_controller;dur=0.01, sql.active_record;dur=0.66, process_action.action_controller;dur=12.56
Vary: Accept
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
X-Permitted-Cross-Domain-Policies: none
X-Request-Id: 1c0a784c-0723-49b7-9ba1-7672f24f5e96
X-Runtime: 0.034930
X-Xss-Protection: 0

[]
```

### Create new Log for order

1. First authorize the order, only `order_id` and `is_authorized` are important here.

```
$ http POST localhost:8080/logs \
    Authorization:"Bearer ${TOKEN}" \
    order_id=4 \
    is_refund:=true \
    amount:=50 \
    is_authorized:=true

HTTP/1.1 302 Found
Cache-Control: no-cache
Content-Length: 0
Content-Type: text/html; charset=utf-8
Location: http://localhost:8080/logs/10
Referrer-Policy: strict-origin-when-cross-origin
Server-Timing: start_processing.action_controller;dur=0.01, sql.active_record;dur=22.65, instantiation.active_record;dur=0.16, start_transaction.active_record;dur=0.02, redirect_to.action_controller;dur=0.95, transaction.active_record;dur=54.97, process_action.action_controller;dur=75.70
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
X-Permitted-Cross-Domain-Policies: none
X-Request-Id: cbc4b182-b81c-4947-8a39-1bc47ab28b1e
X-Runtime: 0.081656
X-Xss-Protection: 0
```

2. Repeat authorization will fail

```
$ http POST localhost:8080/logs \
    Authorization:"Bearer ${TOKEN}" \
    order_id=4 \
    is_refund:=true \
    amount:=50 \
    is_authorized:=true

HTTP/1.1 400 Bad Request
Cache-Control: no-cache
Content-Length: 34
Content-Type: application/json; charset=utf-8
Referrer-Policy: strict-origin-when-cross-origin
Server-Timing: start_processing.action_controller;dur=0.01, sql.active_record;dur=0.69, instantiation.active_record;dur=0.09, process_action.action_controller;dur=6.05
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
X-Permitted-Cross-Domain-Policies: none
X-Request-Id: 5f061ff2-90f5-4e9d-9b66-a081066e748b
X-Runtime: 0.010066
X-Xss-Protection: 0

{
    "error": "Cannot authorize again"
}
```

3. Pay by specifying `order_id`, `is_refund=false`, a positive `amount`, and `is_authorized=false`

```
$ http POST localhost:8080/logs \
    Authorization:"Bearer ${TOKEN}" \
    order_id=4 \
    is_refund:=false \
    amount:=50 \
    is_authorized:=false

HTTP/1.1 302 Found
Cache-Control: no-cache
Content-Length: 0
Content-Type: text/html; charset=utf-8
Location: http://localhost:8080/logs/10
Referrer-Policy: strict-origin-when-cross-origin
Server-Timing: start_processing.action_controller;dur=0.01, sql.active_record;dur=22.65, instantiation.active_record;dur=0.16, start_transaction.active_record;dur=0.02, redirect_to.action_controller;dur=0.95, transaction.active_record;dur=54.97, process_action.action_controller;dur=75.70
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
X-Permitted-Cross-Domain-Policies: none
X-Request-Id: cbc4b182-b81c-4947-8a39-1bc47ab28b1e
X-Runtime: 0.081656
X-Xss-Protection: 0
```

4. Overpaying, or paying for an order that has prior refund log, will result in an error

```
$ http POST localhost:8080/logs \
    Authorization:"Bearer ${TOKEN}" \
    order_id=4 \
    is_refund:=false \
    amount:=500 \
    is_authorized:=false

HTTP/1.1 400 Bad Request
Cache-Control: no-cache
Content-Length: 45
Content-Type: application/json; charset=utf-8
Referrer-Policy: strict-origin-when-cross-origin
Server-Timing: start_processing.action_controller;dur=0.01, sql.active_record;dur=3.63, instantiation.active_record;dur=0.06, start_transaction.active_record;dur=0.01, transaction.active_record;dur=7.57, process_action.action_controller;dur=19.31
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
X-Permitted-Cross-Domain-Policies: none
X-Request-Id: 2b2f2c56-cd5b-4b8f-bf1d-6bdf41d058b4
X-Runtime: 0.023260
X-Xss-Protection: 0

{
    "error": "Cannot pay more than agreed price"
}
```

5. Refunding the customer by specifying `order_id`, `is_refund=true`, a positive `amount` and `is_authorized=false`

```
$ http POST localhost:8080/logs \
    Authorization:"Bearer ${TOKEN}" \
    order_id=4 \
    is_refund:=true \
    amount:=50 \
    is_authorized:=false

HTTP/1.1 302 Found
Cache-Control: no-cache
Content-Length: 0
Content-Type: text/html; charset=utf-8
Location: http://localhost:8080/logs/10
Referrer-Policy: strict-origin-when-cross-origin
Server-Timing: start_processing.action_controller;dur=0.01, sql.active_record;dur=22.65, instantiation.active_record;dur=0.16, start_transaction.active_record;dur=0.02, redirect_to.action_controller;dur=0.95, transaction.active_record;dur=54.97, process_action.action_controller;dur=75.70
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
X-Permitted-Cross-Domain-Policies: none
X-Request-Id: cbc4b182-b81c-4947-8a39-1bc47ab28b1e
X-Runtime: 0.081656
X-Xss-Protection: 0
```

6. Over-refunding will trigger an error

```
$ http POST localhost:8080/logs \
    Authorization:"Bearer ${TOKEN}" \
    order_id=4 \
    is_refund:=true \
    amount:=500 \
    is_authorized:=false

HTTP/1.1 400 Bad Request
Cache-Control: no-cache
Content-Length: 48
Content-Type: application/json; charset=utf-8
Referrer-Policy: strict-origin-when-cross-origin
Server-Timing: start_processing.action_controller;dur=0.01, sql.active_record;dur=14.78, instantiation.active_record;dur=0.15, start_transaction.active_record;dur=0.02, transaction.active_record;dur=9.32, process_action.action_controller;dur=28.24
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
X-Permitted-Cross-Domain-Policies: none
X-Request-Id: 0d2c9ec6-73fe-49b4-b0bf-59153ee71247
X-Runtime: 0.032286
X-Xss-Protection: 0

{
    "error": "Cannot refund more than agreed price"
}
```
