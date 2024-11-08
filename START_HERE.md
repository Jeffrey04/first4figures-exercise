
# Senior Software Engineer Coding Exercise

Welcome! In this exercise, you'll build a simple Rails API application focused on basic CRUD operations with JWT-based authentication. This test will help us evaluate your skills with Ruby on Rails, Rails API mode, PostgreSQL, RSpec, and JSON Web Tokens (JWT).

---

### Objective

Create a basic Rails API with the following requirements:

- Set up a Rails API with PostgreSQL as the database.
- Implement a hardcoded JWT-based authentication.
- Create basic CRUD endpoints for an `Order` model.
- Implement an order status mechanism to track the payment state of an order.
- Write RSpec tests to verify your API functionality, authentication, and order status transitions.

### Time Estimate

**Approximately 1 hour** – Take the time you need to complete the exercise comfortably, but try to keep it concise.

---

## Instructions

### Step 1: Set Up the Rails API Application

1. **Create a New Rails API Project**:

   ```bash
   rails new OrdersAPI --api -d postgresql
   cd OrdersAPI
   ```

2. **Set Up Database**:

   - Update `config/database.yml` with your PostgreSQL credentials.
   - Create and migrate the database:

     ```bash
     rails db:create
     rails db:migrate
     ```

3. **Generate Order Model**:

   ```bash
   rails generate model Order product_name:string quantity:integer price:decimal
   rails db:migrate
   ```

### Step 2: Implement JWT Authentication

We'll use a simple JWT-based authentication mechanism with a hardcoded token.

1. **Add JWT to Gemfile**:

   ```ruby
   gem 'jwt'
   ```

   Run `bundle install` to install the gem.

2. **Set Up Authentication in ApplicationController**:

   In `app/controllers/application_controller.rb`, add a method to authenticate requests using a hardcoded JWT token.

   ```ruby
   class ApplicationController < ActionController::API
     before_action :authenticate_request

     private

     def authenticate_request
       token = request.headers['Authorization']
       render json: { error: 'Unauthorized' }, status: :unauthorized unless valid_token?(token)
     end

     def valid_token?(token)
       # Hardcoded token for this exercise
       token == 'your_test_token'
     end
   end
   ```

   **Note**: In this setup, replace `'your_test_token'` with the token you’ll use in testing.

### Step 3: Create the Orders Controller and Define Order Statuses

1. **Generate Orders Controller**:

   ```bash
   rails generate controller Orders
   ```

2. **Define CRUD Actions for Orders**:

   Implement the following actions in the `OrdersController`:
   - `create`: Creates a new order with attributes `product_name`, `quantity`, and `price`.
   - `show`: Retrieves an order by its ID.
   - `update`: Updates the attributes of an existing order.
   - `destroy`: Deletes an order.

   Each action should return a JSON response. Handle errors gracefully with appropriate HTTP status codes (e.g., 422 for validation errors).

3. **Implement Order Statuses**:

   Add a mechanism to track the status of an order through various payment states:
   - **Order Statuses**: The order can be in one of the following statuses:
     - `pending_payment`
     - `authorized`
     - `partially_paid`
     - `paid`
     - `refunded`
     - `partially_refunded`

   Use an `order_status` attribute (as an enum or a separate `OrderStatus` model) to represent these statuses. The status should be updatable to simulate a real-world order flow, allowing it to transition between these states.

4. **Apply Authentication**:

   Use the `authenticate_request` method you created in `ApplicationController` to secure these endpoints so that they only allow requests with a valid JWT token.

### Step 4: Add RSpec Tests for Order Status

Write tests to ensure:
- CRUD actions for the `Order` work as expected.
- The `order_status` attribute or status mechanism can be updated and responds correctly.
- Unauthorized requests return a `401 Unauthorized` response.

### Step 5: Set Up Docker for PostgreSQL

To simplify database setup, use Docker to run PostgreSQL. Here is a `docker-compose.yml` file to get started:

```yaml
version: '3.8'

services:
  db:
    image: postgres:13
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
      POSTGRES_DB: orders_api_development
    ports:
      - "5432:5432"
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - backend

networks:
  backend:
    driver: bridge

volumes:
  db_data:
```

1. **Start PostgreSQL**:
   Run the following command in the directory containing the `docker-compose.yml` file:

   ```bash
   docker-compose up -d
   ```

2. **Database Configuration**:
   In your Rails application, update the `config/database.yml` file with these settings:

   ```yaml
   default: &default
     adapter: postgresql
     encoding: unicode
     host: db
     username: postgres
     password: password
     pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

   development:
     <<: *default
     database: orders_api_development

   test:
     <<: *default
     database: orders_api_test

   production:
     <<: *default
     database: orders_api_production
     username: orders_api
     password: <%= ENV['ORDERS_API_DATABASE_PASSWORD'] %>
   ```

3. **Run Database Migrations**:
   Once PostgreSQL is running, run the migrations:

   ```bash
   rails db:create db:migrate
   ```

### Submission

1. **Code**: Submit your Rails application, including `OrdersController`, `Order` model, JWT authentication, and RSpec tests.
2. **README**: Include a brief README explaining how to set up and run your application.

---

### Evaluation Criteria

- **Correctness**: Does the API fulfill the requirements?
- **Security**: Is JWT authentication correctly implemented?
- **Code Quality**: Is the code well-organized and easy to understand?
- **Testing**: Are the RSpec tests comprehensive and passing?
- **Status Management**: Is the order status mechanism functional and correctly implemented?

---

Good luck, and feel free to reach out if you have any questions!
