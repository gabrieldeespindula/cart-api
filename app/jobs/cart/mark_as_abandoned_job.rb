class Cart::MarkAsAbandonedJob < ApplicationJob
  def perform
    Cart::MarkAsAbandoned.call
  end
end
