require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  test 'visit index page' do
    visit users_url
    assert_text 'Users'
    assert_text 'Go to messages'
  end

  test 'create a new user' do
    visit users_url
    fill_in 'Name', with: 'Mr. Test'
    click_on 'Create User'

    assert_text 'Users'
    assert_text 'Mr. Test'
    assert_text 'Go to messages'
  end
end
