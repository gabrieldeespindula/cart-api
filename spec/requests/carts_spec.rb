require 'rails_helper'

RSpec.describe "/carts", type: :request do
  describe 'GET /cart' do
    context 'when the cart exists' do
      let!(:cart) do
        get '/cart', as: :json
        Cart.last
      end

      it 'returns a successful response' do
        get '/cart', as: :json

        expect(response).to be_successful
      end

      it 'renders a JSON response with the cart' do
        get '/cart', as: :json
        expect(response.content_type).to match(a_string_including("application/json"))

        expected_body = CartSerializer.new(cart).to_json

        expect(response.body).to eq(expected_body)
      end
    end

    context 'when the cart does not exist' do
      it 'creates a new cart' do
        expect {
          get '/cart', as: :json
        }.to change { Cart.count }.by(1)
      end

      it 'returns a successful response' do
        get '/cart', as: :json
        expect(response).to be_successful
      end

      it 'renders a JSON response with the cart' do
        get '/cart', as: :json
        expect(response.content_type).to match(a_string_including("application/json"))

        cart = Cart.last
        expected_body = CartSerializer.new(cart).to_json

        expect(response.body).to eq(expected_body)
      end
    end
  end

  describe 'POST /cart' do
    let(:product) { create(:product, price: 10.0) }

    context "with valid parameters" do
      let(:valid_params) do
        { product_id: product.id, quantity: 1 }
      end

      context 'when the cart does not exists' do
        it 'creates a new cart' do
          expect {
            post '/cart', params: valid_params, as: :json
          }.to change { Cart.count }.by(1)
        end

        it 'adds a product to the cart' do
          post '/cart', params: valid_params, as: :json
          cart = Cart.last

          expect(cart.items.size).to eq(1)
          expect(cart.items.first.product_id).to eq(product.id)
          expect(cart.items.first.quantity).to eq(1)
        end

        it "renders a successful response" do
          post '/cart', params: valid_params, as: :json
          expect(response).to be_successful
        end

        it 'renders a JSON response with the cart' do
          post '/cart', params: valid_params, as: :json
          cart = Cart.last

          expect(response.content_type).to match(a_string_including("application/json"))
          expected_body = CartSerializer.new(cart).to_json
          expect(response.body).to eq(expected_body)
        end
      end

      context 'when the cart exists' do
        let!(:cart) do
          get '/cart', as: :json
          Cart.last
        end

        it 'does not create a new cart' do
          expect {
            post '/cart', params: valid_params, as: :json
          }.not_to change { Cart.count }
        end

        it 'adds a product to the cart' do
          post '/cart', params: valid_params, as: :json

          cart.reload

          expect(cart.items.size).to eq(1)
          expect(cart.items.first.product_id).to eq(product.id)
          expect(cart.items.first.quantity).to eq(1)
        end

        it "renders a successful response" do
          post '/cart', params: valid_params, as: :json
          expect(response).to be_successful
        end


        it 'renders a JSON response with the cart' do
          post '/cart', params: valid_params, as: :json

          expect(response.content_type).to match(a_string_including("application/json"))

          cart.reload
          expected_body = CartSerializer.new(cart).to_json

          expect(response.body).to eq(expected_body)
        end
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        { product_id: nil, quantity: 1 }
      end

      before do
        post '/cart', params: invalid_params, as: :json
      end

      it 'renders an error response' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'renders a JSON response with the errors' do
        expect(response.content_type).to match(a_string_including("application/json"))

        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include("Items is invalid")
      end
    end
  end


  describe "POST /add_item" do
    let(:product) { create(:product, price: 10.0) }

    context "with valid parameters" do
      let(:valid_params) do
        { product_id: product.id, quantity: 1 }
      end

      context "when the item does not exist" do
        it 'adds a new item to the cart' do
          expect do
            post '/cart/add_item', params: valid_params, as: :json
          end.to change { Cart::Item.count }.by(1)

          cart = Cart.last

          expect(cart.items.size).to eq(1)
          expect(cart.items.first.product_id).to eq(product.id)
          expect(cart.items.first.quantity).to eq(1)
        end

        it "renders a successful response" do
          post '/cart/add_item', params: valid_params, as: :json
          expect(response).to be_successful
        end

        it 'renders a JSON response with the cart' do
          post '/cart/add_item', params: valid_params, as: :json
          cart = Cart.last
          expect(response.content_type).to match(a_string_including("application/json"))
          expected_body = CartSerializer.new(cart).to_json
          expect(response.body).to eq(expected_body)
        end
      end

      context "when the item exists" do
        let!(:item) do
          post '/cart', params: valid_params, as: :json
          Cart::Item.last
        end

        it 'updates the item quantity' do
          expect do
            post '/cart/add_item', params: valid_params, as: :json
          end.not_to change { Cart::Item.count }

          item.reload

          expect(item.quantity).to eq(2)
        end

        it "renders a successful response" do
          post '/cart/add_item', params: valid_params, as: :json
          expect(response).to be_successful
        end

        it 'renders a JSON response with the cart' do
          post '/cart/add_item', params: valid_params, as: :json
          cart = Cart.last
          expect(response.content_type).to match(a_string_including("application/json"))
          expected_body = CartSerializer.new(cart).to_json
          expect(response.body).to eq(expected_body)
        end
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        { product_id: nil, quantity: 1 }
      end

      before do
        post '/cart', params: invalid_params, as: :json
      end

      it 'renders an error response' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'renders a JSON response with the errors' do
        expect(response.content_type).to match(a_string_including("application/json"))

        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include("Items is invalid")
      end
    end
  end

  describe "DELETE /carts/:product_id" do
    context "when the item exists" do
      let(:product) { create(:product) }
      let(:cart) do
        get '/cart', as: :json
        Cart.last
      end

      let!(:cart_item) { create(:cart_item, cart:, product:) }

      it 'deletes the item from the cart' do
        expect do
          delete "/cart/#{product.id}", as: :json
        end.to change { Cart::Item.count }.by(-1)

        cart.reload

        expect(cart.items.count).to eq(0)
      end

      it "renders a successful response" do
        delete "/cart/#{product.id}", as: :json
        expect(response).to be_successful
      end

      it 'renders a JSON response with the cart' do
        delete "/cart/#{product.id}", as: :json
        cart.reload
        expect(response.content_type).to match(a_string_including("application/json"))
        expected_body = CartSerializer.new(cart).to_json
        expect(response.body).to eq(expected_body)
      end
    end

    context "when the item does not exist" do
      before do
        delete '/cart/999', as: :json
      end

      it 'renders an error response' do
        expect(response).to have_http_status(:not_found)
      end

      it 'renders a JSON response with the errors' do
        expect(response.content_type).to match(a_string_including("application/json"))

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq("Product not found in cart")
      end
    end
  end
end
