# frozen_string_literal: true

Given 'a user {string}' do |name|
  create(:user, name: name)
end

users_list_css = 'ul.list-group'

Then 'I should see a user with a name of {string} in the list' do |name|
  expect(find(users_list_css)).to have_content(name)
end

Then 'I should NOT see a user with a name of {string} in the list' do |name|
  expect(find(users_list_css)).to have_no_content(name)
end
