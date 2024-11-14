class Order < ApplicationRecord
  enum :order_status, [:pending_payment, :authorized, :partially_paid, :paid, :refunded, :partially_refunded]
end
