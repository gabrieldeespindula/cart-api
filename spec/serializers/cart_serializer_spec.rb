require 'rails_helper'

RSpec.describe CartSerializer do
  let(:product) { build(:product, id: 1, name: 'Box', price: 10.0) }
  let(:cart) do
    build(:cart, id: 2, items: [
      build(:cart_item, id: 3, product:, quantity: 2)
    ], total_price: 20.0)
  end

  subject { described_class.new cart }

  it 'returns a json' do
    expected = {
      id: 2,
      total_price: '20.0',
      products: [
        { id: 1, name: 'Box', quantity: 2, unit_price: '10.0', total_price: '20.0' }
      ]
    }.to_json

    expect(subject.to_json).to eql expected
  end
end
