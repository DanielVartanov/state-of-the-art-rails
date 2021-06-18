require "application_system_test_case"

class MessagesTest < ApplicationSystemTestCase
  def setup
    User.create!(name: 'Mr. Test').tap do |user|
      Message.create! content: 'First!', user: user
      Message.create! content: 'Second!', user: user
    end

    User.create! name: 'Mr. Second test'
  end

  test 'visit messages page' do
    visit messages_url
    assert_text '"First!" by Mr. Test'
    assert_text '"Second!" by Mr. Test'
  end

  test 'send a new message' do
    visit messages_url

    within 'turbo-frame#new_message' do
      fill_in 'Content', with: 'Hello from tests!'
      click_on 'Create Message'

      select 'Mr. Second test', from: 'Author'
      fill_in 'Content', with: 'Hello from another test author'
      click_on 'Create Message'
    end

    assert_text '"Hello from tests!" by Mr. Test'
    assert_text '"Hello from another test author" by Mr. Second test'
  end

  test 'messages appear in realtime when create from another browser window' do
    visit messages_url

    Capybara.using_session('another browser window') do
      visit messages_url

      within 'turbo-frame#new_message' do
        select 'Mr. Second test', from: 'Author'
        fill_in 'Content', with: 'Hello from another browser window'
        click_on 'Create Message'
      end
    end

    assert_text '"Hello from another browser window" by Mr. Second test'
  end
end
