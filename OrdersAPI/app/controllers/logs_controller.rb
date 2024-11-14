class LogsController < ApplicationController
  def index
    @logs = Log.where("order_id = ?", params[:order_id])

    render json: @logs
  end

  def show
    @log = Log.find(params[:id])

    render json: @log
  end

  def create
    @log = Log.new(log_params)
    order = Order.find(params[:order_id])

    begin
      ActiveRecord::Base.transaction do
        if log_params[:is_authorized]
          raise "Cannot authorize again" unless check_is_pending_payment(order)

          order.update(order_status: :authorized)
          order.save
        elsif order.order_status != "authorized" and order.order_status != "partially_paid" and order.order_status != "partially_refunded"
          raise "Cannot proceed with payment"
        elsif params[:amount] <= 0
          raise "Amount must be positive"
        elsif not log_params[:is_refund]
          raise "Cannot pay further" if check_is_refunding(params[:order_id])

          total_paid = Log.where(order_id: params[:order_id], is_refund: false, is_authorized: false).sum(:amount) + @log.amount

          if total_paid == order.price
            order.update(order_status: :paid)
          elsif total_paid < order.price
            order.update(order_status: :partially_paid)
          else
            raise "Cannot pay more than agreed price"
          end

          order.save
        elsif log_params[:is_refund]
          total_paid = Log.where(order_id: params[:order_id], is_refund: false, is_authorized: false).sum(:amount)
          total_refunded = Log.where(order_id: params[:order_id], is_refund: true, is_authorized: false).sum(:amount) + @log.amount

          if total_paid - total_refunded == 0
            order.update(order_status: :refunded)
          elsif total_paid - total_refunded > 0
            order.update(order_status: :partially_refunded)
          else
            raise "Cannot refund more than agreed price"
          end

          order.save
        end

        if @log.save
          redirect_to @log
        else
          render status: 422
        end
      end
    rescue => error
      render json: { error: error.message }, status: 400
    end
  end

  def update
    redirect_to logs_path, status: 403
  end

  def destroy
    redirect_to logs_path, status: 403
  end

  private

  def check_is_refunding(order_id)
    Log.where("order_id = ? AND is_refund = TRUE and is_authorized = FALSE", order_id).exists?
  end

  def check_is_pending_payment(order)
    order.order_status == "pending_payment"
  end

  def log_params
    params.expect(log: [:order_id, :is_refund, :amount, :is_authorized])
  end
end
