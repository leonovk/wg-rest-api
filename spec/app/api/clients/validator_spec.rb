# frozen_string_literal: true

RSpec.describe Api::Clients::Validator do
  subject(:validate) { described_class.new(params).validate! }

  context 'when all parameters are valid' do
    let(:params) do
      {
        'address' => '1.2.3.4',
        'private_key' => 'a',
        'public_key' => 'b',
        'preshared_key' => 'c',
        'enable' => false,
        'data' => {}
      }
    end

    it 'return true' do
      expect(validate).to be(true)
    end
  end

  context 'when parameters are empty' do
    let(:params) do
      {}
    end

    it 'return true' do
      expect(validate).to be(true)
    end
  end

  context 'when all parameters are valid but there are extra ones' do
    let(:params) do
      {
        'address' => '1.2.3.4',
        'private_key' => 'a',
        'public_key' => 'b',
        'preshared_key' => 'c',
        'enable' => false,
        'data' => {},
        'extra' => 123
      }
    end

    it 'raises a validation error' do
      expect { validate }.to raise_error(JSON::Schema::ValidationError)
    end
  end

  context 'when one parameter is not valid' do
    let(:params) do
      {
        'enable' => 'false'
      }
    end

    it 'raises a validation error' do
      expect { validate }.to raise_error(JSON::Schema::ValidationError)
    end
  end

  context 'when there were several parameters and they were valid' do
    let(:params) do
      {
        'preshared_key' => 'c',
        'enable' => false,
        'data' => {}
      }
    end

    it 'return true' do
      expect(validate).to be(true)
    end
  end
end
