class CartsController < ApplicationController
  before_action :set_cart

  def show
    render json: @cart
  end

  def create
    @cart.items.new(product_id: params[:product_id], quantity: params[:quantity])
    @cart.save!

    render json: @cart
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  def add_item
    item = Cart::Item.find_or_initialize_by(cart: @cart, product_id: params[:product_id])
    item.quantity += params[:quantity].to_i
    item.save!

    @cart.reload

    render json: @cart
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  def remove_item
    @cart.items.find_by!(product_id: params[:product_id]).destroy!

    @cart.reload

    render json: @cart
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Product not found in cart" }, status: :not_found
  end

  private

  def set_cart
    @cart = Cart.find_by(id: session[:cart_id]) || Cart.create!
    session[:cart_id] ||= @cart.id
  end
end
