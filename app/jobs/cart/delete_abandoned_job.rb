class Cart::DeleteAbandonedJob < ApplicationJob
  def perform
    Cart::DeleteAbandoned.call
  end
end
