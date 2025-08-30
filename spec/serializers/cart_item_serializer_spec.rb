require 'rails_helper'

RSpec.describe CartItemSerializer do
  let(:product) { build(:product, id: 1, name: 'Box', price: 10.0) }
  let(:cart_item) { build(:cart_item, id: 2, product:, quantity: 2) }

  subject { described_class.new cart_item }

  it 'returns a json' do
    expected = {
      id: 1,
      name: 'Box',
      quantity: 2,
      unit_price: '10.0',
      total_price: '20.0'
    }.to_json

    expect(subject.to_json).to eql expected
  end
end
