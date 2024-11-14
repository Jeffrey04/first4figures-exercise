require "rails_helper"

RSpec.describe "Logs", type: :request do
  headers = { "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJuYW1lIjoiamVmZnJleTA0In0.gg9FblqVWREIVP4Dc34aUDTRP9fcx7IZBy8ifBKW3us" }

  describe "GET /logs" do
    it "Fail Authentication" do
      get logs_path
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET all logs" do
    it "Get all logs" do
      get logs_path, headers: headers

      expect(response).to have_http_status(200)
      expect(response.body).to eq("[]")
    end
  end

  describe "Create Authorize" do
    it "Create authorization" do
      post orders_path, params: '{"product_name": "foo", "price": 100.0, "quantity": 10}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      order_location = response.location
      expect(response).to have_http_status(302)

      get order_location, headers: headers

      order = JSON.parse(response.body())
      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(order["order_status"]).to eq("pending_payment")

      # authorize
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": false, "amount": 0, "is_authorized": true}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      expect(response).to have_http_status(302)

      # verify
      get response.location, headers: headers

      log = JSON.parse(response.body())

      get order_location, headers: headers
      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(log["order_id"]).to eq(order["id"])
      expect(log["is_refund"]).to eq(false)
      expect(log["amount"]).to eq("0.0")
      expect(log["is_authorized"]).to eq(true)

      order = JSON.parse(response.body())
      expect(order["order_status"]).to eq("authorized")

      # cannot reauthorize
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": false, "amount": 0, "is_authorized": true}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      expect(response).to have_http_status(400)
    end
  end

  describe "Pay" do
    it "Create new payment" do
      # create order
      post orders_path, params: '{"product_name": "foo", "price": 100.0, "quantity": 10}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      order_location = response.location
      expect(response).to have_http_status(302)

      get order_location, headers: headers

      order = JSON.parse(response.body())
      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(order["order_status"]).to eq("pending_payment")

      # authorize
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": false, "amount": 0, "is_authorized": true}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      # pay partially
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": false, "amount": 50, "is_authorized": false}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      expect(response).to have_http_status(302)

      get order_location, headers: headers

      order = JSON.parse(response.body())
      expect(order["order_status"]).to eq("partially_paid")

      # Pay fully
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": false, "amount": 50, "is_authorized": false}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      expect(response).to have_http_status(302)

      get order_location, headers: headers

      order = JSON.parse(response.body())
      expect(order["order_status"]).to eq("paid")

      # Pay too much
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": false, "amount": 50, "is_authorized": false}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      expect(response).to have_http_status(400)
    end
  end

  describe "Pay more" do
    it "Create new payment" do
      # create order
      post orders_path, params: '{"product_name": "foo", "price": 100.0, "quantity": 10}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      get response.location, headers: headers

      order = JSON.parse(response.body())

      # authorize
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": false, "amount": 0, "is_authorized": true}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      # pay more
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": false, "amount": 120, "is_authorized": false}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      expect(response).to have_http_status(400)
    end
  end

  describe "Pay more (installment)" do
    it "Create new payment" do
      # create order
      post orders_path, params: '{"product_name": "foo", "price": 100.0, "quantity": 10}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      get response.location, headers: headers

      order = JSON.parse(response.body())

      # authorize
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": false, "amount": 0, "is_authorized": true}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      # pay more
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": false, "amount": 80, "is_authorized": false}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      # pay more
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": false, "amount": 30, "is_authorized": false}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      expect(response).to have_http_status(400)
    end
  end

  describe "Refund" do
    it "Create new payment" do
      # create order
      post orders_path, params: '{"product_name": "foo", "price": 100.0, "quantity": 10}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      order_location = response.location
      expect(response).to have_http_status(302)

      get order_location, headers: headers

      order = JSON.parse(response.body())
      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(order["order_status"]).to eq("pending_payment")

      # authorize
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": false, "amount": 0, "is_authorized": true}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      # pay partially
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": false, "amount": 80, "is_authorized": false}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      # refund partially
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": true, "amount": 40, "is_authorized": false}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      expect(response).to have_http_status(302)

      get order_location, headers: headers

      order = JSON.parse(response.body())
      expect(order["order_status"]).to eq("partially_refunded")

      # Attempt to pay
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": false, "amount": 50, "is_authorized": false}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      expect(response).to have_http_status(400)

      # refund fully
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": true, "amount": 40, "is_authorized": false}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      expect(response).to have_http_status(302)

      # verify
      get order_location, headers: headers

      order = JSON.parse(response.body())
      expect(order["order_status"]).to eq("refunded")

      # refund more
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": true, "amount": 40, "is_authorized": false}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      expect(response).to have_http_status(400)
    end
  end

  describe "Refund more (fully paid)" do
    it "Create new payment" do
      # create order
      post orders_path, params: '{"product_name": "foo", "price": 100.0, "quantity": 10}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      get response.location, headers: headers

      order = JSON.parse(response.body())

      # authorize
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": false, "amount": 0, "is_authorized": true}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      # pay more
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": false, "amount": 100, "is_authorized": false}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      # refund more
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": true, "amount": 120, "is_authorized": false}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      expect(response).to have_http_status(400)
    end
  end

  describe "Refund more (partially paid)" do
    it "Create new payment" do
      # create order
      post orders_path, params: '{"product_name": "foo", "price": 100.0, "quantity": 10}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      get response.location, headers: headers

      order = JSON.parse(response.body())

      # authorize
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": false, "amount": 0, "is_authorized": true}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      # pay more
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": false, "amount": 80, "is_authorized": false}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      # refund more
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": true, "amount": 120, "is_authorized": false}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      expect(response).to have_http_status(400)
    end
  end

  describe "Refund more (installment)" do
    it "Create new payment" do
      # create order
      post orders_path, params: '{"product_name": "foo", "price": 100.0, "quantity": 10}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      get response.location, headers: headers

      order = JSON.parse(response.body())

      # authorize
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": false, "amount": 0, "is_authorized": true}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      # pay more
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": false, "amount": 80, "is_authorized": false}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      # refund more
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": true, "amount": 50, "is_authorized": false}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      expect(response).to have_http_status(302)

      # refund more
      post logs_path, params: '{"order_id": ' + order["id"].to_s + ', "is_refund": true, "amount": 50, "is_authorized": false}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      expect(response).to have_http_status(400)
    end
  end
end
