class Cart::DeleteAbandoned < ApplicationService
  BATCH_SIZE = 1000

  def call
    carts_to_delete = Cart.deletable

    Rails.logger.info "Starting to delete abandoned carts..."

    carts_to_delete.in_batches(of: BATCH_SIZE).each_with_index do |batch_relation, index|
      Rails.logger.info "Processing batch ##{index + 1}: Deleting #{batch_relation.count} carts..."

      batch_relation.destroy_all
    end

    Rails.logger.info "Finished deleting abandoned carts."
  end
end
