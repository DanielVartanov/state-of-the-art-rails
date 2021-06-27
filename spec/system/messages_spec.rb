require 'rails_helper'

RSpec.describe '/messages', type: :system do
  before do
    create(:user, name: 'Mr. Test').tap do |user|
      create :message, content: 'First!', user: user
      create :message, content: 'Second!', user: user
    end

    create :user, name: 'Mr. Second test'
  end

  describe 'index page' do
    specify do
      visit messages_path
      expect(page).to have_content '"First!" by Mr. Test'
      expect(page).to have_content '"Second!" by Mr. Test'
    end
  end

  describe 'sending a message' do
    specify do
      visit messages_path

      within 'turbo-frame#new_message' do
        fill_in 'Content', with: 'Hello from tests!'
        click_on 'Create Message'

        select 'Mr. Second test', from: 'Author'
        fill_in 'Content', with: 'Hello from another test author'
        click_on 'Create Message'
      end

      expect(page).to have_content '"Hello from tests!" by Mr. Test'
      expect(page).to have_content '"Hello from another test author" by Mr. Second test'
    end
  end

  describe 'messages appear in realtime when create from another browser window' do
    specify do
      visit messages_path

      Capybara.using_session('another browser window') do
        visit messages_path

        within 'turbo-frame#new_message' do
          select 'Mr. Second test', from: 'Author'
          fill_in 'Content', with: 'Hello from another browser window'
          click_on 'Create Message'
        end
      end

      expect(page).to have_content '"Hello from another browser window" by Mr. Second test'
    end
  end
end
