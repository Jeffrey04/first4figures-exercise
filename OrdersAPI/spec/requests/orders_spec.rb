require "rails_helper"
require "json"

RSpec.describe "Orders", type: :request do
  headers = { "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJuYW1lIjoiamVmZnJleTA0In0.gg9FblqVWREIVP4Dc34aUDTRP9fcx7IZBy8ifBKW3us" }

  describe "GET /orders" do
    it "Fail Authentication" do
      get orders_path
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "Test get all orders" do
    it "List orders" do
      get orders_path, headers: headers

      expect(response).to have_http_status(200)
      expect(response.body()).to eq("[]")
    end
  end

  describe "Test create a new order" do
    it "Create new order" do
      post orders_path, params: '{"product_name": "foo", "price": 100.0, "quantity": 10}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      expect(response).to have_http_status(302)

      # validate
      get response.location, headers: headers

      expect(response.content_type).to eq("application/json; charset=utf-8")

      order = JSON.parse(response.body())
      expect(order["product_name"]).to eq("foo")
      expect(order["price"]).to eq("100.0") # NOTE2SELF rails prefer storing floats as string
      expect(order["quantity"]).to eq(10)
      expect(order["order_status"]).to eq("pending_payment")

      get orders_path, headers: headers

      orders = JSON.parse(response.body())
      expect(orders.size()).to eq(1)
      expect(orders[0]["product_name"]).to eq("foo")
      expect(orders[0]["price"]).to eq("100.0") # NOTE2SELF rails prefer storing floats as string
      expect(orders[0]["quantity"]).to eq(10)
      expect(orders[0]["order_status"]).to eq("pending_payment")
    end
  end

  describe "Update an order" do
    it "Update an order" do
      # create a record
      post orders_path, params: '{"product_name": "foo", "price": 100.0, "quantity": 10}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      expect(response).to have_http_status(302)

      # update
      put response.location, params: '{"product_name": "bar", "price": 200.0, "quantity": 20}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      expect(response).to have_http_status(302)

      # validate through GET
      get response.location, headers: headers

      expect(response.content_type).to eq("application/json; charset=utf-8")

      order = JSON.parse(response.body())
      expect(order["product_name"]).to eq("bar")
      expect(order["price"]).to eq("200.0") # NOTE2SELF rails prefer storing floats as string
      expect(order["quantity"]).to eq(20)
      expect(order["order_status"]).to eq("pending_payment")
    end
  end

  describe "Delete an order" do
    it "Delete an order" do
      # create a record
      post orders_path, params: '{"product_name": "foo", "price": 100.0, "quantity": 10}', headers: { **headers, "CONTENT_TYPE": "application/json" }

      location = response.location
      expect(response).to have_http_status(302)

      # delete
      delete response.location, headers: { **headers, "CONTENT_TYPE": "application/json" }

      expect(response).to have_http_status(303)

      # validate through GET
      get location, headers: headers

      expect(response).to have_http_status(404)
    end
  end
end
