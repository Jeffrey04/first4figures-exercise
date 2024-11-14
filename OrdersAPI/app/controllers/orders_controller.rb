class OrdersController < ApplicationController
  def index
    @orders = Order.all

    render json: @orders
  end

  def show
    @order = Order.find(params[:id])

    render json: @order
  end

  def create
    @order = Order.new({ **order_params, order_status: :pending_payment })

    if @order.save
      redirect_to @order
    else
      render status: 422
    end
  end

  def update
    @order = Order.find(params[:id])

    if @order.update(order_params)
      redirect_to @order
    else
      render status: 422
    end
  end

  def destroy
    @order = Order.find(params[:id])
    @order.destroy

    redirect_to orders_path, status: 303
  end

  private

  def order_params
    params.expect(order: [:product_name, :quantity, :price])
  end
end
