class Cart::MarkAsAbandoned < ApplicationService
  BATCH_SIZE = 1000

  def call
    carts_to_abandon = Cart.abandonable

    Rails.logger.info "Starting to mark carts as abandoned..."

    carts_to_abandon.in_batches(of: BATCH_SIZE).each_with_index do |batch_relation, index|
      Rails.logger.info "Processing batch ##{index + 1} (#{batch_relation.count} carts)..."

      batch_relation.update_all(abandoned: true)
    end

    Rails.logger.info "Finished marking carts as abandoned."
  end
end
