require 'rails_helper'

RSpec.describe "/products", type: :request do
  let(:valid_attributes) {
    {
      name: 'A product',
      price: 1
    }
  }

  let(:invalid_attributes) {
    {
      price: -1
    }
  }

  describe "GET /index" do
    let!(:products) { create_list(:product, 3) }

    before do
      get products_url, as: :json
    end

    it "renders a successful response" do
      expect(response).to be_successful
    end

    it 'renders a JSON response with all products' do

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to match(a_string_including("application/json"))

      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(3)
      expect(json_response.first['id']).to eq(products.first.id)
      expect(json_response.second['id']).to eq(products.second.id)
      expect(json_response.third['id']).to eq(products.third.id)
    end
  end

  describe "GET /show" do
    context 'when the product exists' do
      let(:product) { create(:product) }

      before do
        get product_url(product), as: :json
      end

      it "renders a successful response" do
        expect(response).to be_successful
      end

      it "renders a JSON response with the product" do
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))

        json_response = JSON.parse(response.body)

        expect(json_response['id']).to eq(product.id)
        expect(json_response['name']).to eq(product.name)
        expect(json_response['price']).to eq(product.price.to_s)
      end
    end

    context 'when the product does not exist' do
      let(:non_existent_product_id) { 0 }

      before do
        get product_url(non_existent_product_id), as: :json
      end

      it "renders a not Found response" do
        expect(response).to have_http_status(:not_found)
      end

      it "renders a JSON response with an error message" do
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq("Not Found")
      end
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new product" do
        expect {
          post products_url,
               params: { product: valid_attributes }, as: :json
        }.to change(Product, :count).by(1)
      end

      it "renders a JSON response with the new product" do
        post products_url,
             params: { product: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))

        json_response = JSON.parse(response.body)
        expect(json_response['id']).to be_present
        expect(json_response['name']).to eq('A product')
        expect(json_response['price']).to eq('1.0')
      end
    end

    context "with invalid parameters" do
      it "does not create a new product" do
        expect {
          post products_url,
               params: { product: invalid_attributes }, as: :json
        }.to change(Product, :count).by(0)
      end

      it "renders a JSON response with errors for the new product" do
        post products_url,
             params: { product: invalid_attributes }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))

        json_response = JSON.parse(response.body)
        expect(json_response['name']).to include("can't be blank")
        expect(json_response['price']).to include("must be greater than or equal to 0")
      end
    end
  end

  describe "PATCH /update" do
    context 'when the product exists' do
      let(:product) { create(:product, name: 'Old name', price: 1.0) }

      context "with valid parameters" do
        let(:new_attributes) {
          {
            name: 'Another name',
            price: 2
          }
        }

        before do
          patch product_url(product),
                params: { product: new_attributes }, as: :json
        end

        it "updates the requested product" do
          product.reload
          expect(product.name).to eq('Another name')
          expect(product.price).to eq(2.0)
        end

        it "renders a JSON response with the product" do
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to match(a_string_including("application/json"))

          json_response = JSON.parse(response.body)
          expect(json_response['id']).to eq(product.id)
          expect(json_response['name']).to eq('Another name')
          expect(json_response['price']).to eq('2.0')
        end
      end

      context "with invalid parameters" do
        it "renders a JSON response with errors for the product" do
          patch product_url(product),
                params: { product: invalid_attributes }, as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including("application/json"))

          json_response = JSON.parse(response.body)
          expect(json_response['price']).to include("must be greater than or equal to 0")
        end
      end
    end

    context "when the product does not exist" do
      let(:non_existent_product_id) { 0 }

      it "renders a JSON response with an error message" do
        patch product_url(non_existent_product_id),
              params: { product: invalid_attributes }, as: :json
        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to match(a_string_including("application/json"))

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq("Not Found")
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested product" do
      product = create(:product)
      expect {
        delete product_url(product), as: :json
      }.to change(Product, :count).by(-1)
    end
  end
end
