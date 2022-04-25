# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  describe '.most_talkative' do
    subject { described_class.most_talkative }

    context 'when there is only one user, even without messages' do
      let!(:lonely_user) { create :user }

      it { is_expected.to eq lonely_user }
    end

    context 'when there are two users with the equal messages count' do
      before do
        2.times do
          create(:user).then { |user| create :message, user: }
        end
      end

      let!(:silent_user) { create :user }

      it { is_expected.not_to eq silent_user }
    end

    context 'when there are two users with unequal amount of messages' do
      let(:first_user) { create :user }
      let(:second_user) { create :user }

      before do
        2.times { create :message, user: first_user }
        3.times { create :message, user: second_user }
      end

      it { is_expected.to eq second_user }
    end
  end
end
