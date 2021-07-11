When 'I go to the {string} page' do |page|
  known_pages = {
    "Users" => users_path
  }

  visit known_pages[page]
end

When 'I fill in {string} with {string}' do |input_field, value|
  fill_in input_field, with: value
end

When 'I click {string}' do |clickable|
  click_on clickable
end

Then 'I should see {string}' do |text|
  expect(page).to have_content text
end
