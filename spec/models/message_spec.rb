# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Message do
  describe '#as_quote' do
    let(:message) do
      create :message,
             content: 'Hello, world!',
             user: create(:user, name: 'Mr. Test User')
    end

    subject { message.as_quote }

    it { is_expected.to eq '"Hello, world!" by Mr. Test User' }
  end
end
