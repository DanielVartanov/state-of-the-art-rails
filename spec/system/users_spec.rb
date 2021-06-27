require 'rails_helper'

RSpec.describe '/users' do
  describe 'index page' do
    specify do
      visit users_path
      expect(page).to have_content 'Users'
      expect(page).to have_content 'Go to messages'
    end
  end

  describe 'new user creation' do
    specify do
      visit users_path
      fill_in 'Name', with: 'Mr. Test'
      click_on 'Create User'

      expect(page).to have_content 'Users'
      expect(page).to have_content 'Mr. Test'
      expect(page).to have_content 'Go to messages'
    end
  end
end
