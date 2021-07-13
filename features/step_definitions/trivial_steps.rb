module KnownPages
  KNOWN_PAGES = {
    "Users" => -> { users_path }
  }.freeze

  def visit_known_page(page_name)
    page = KNOWN_PAGES[page_name]
    page = self.instance_exec(&page) if page.is_a?(Proc)

    visit self.instance_exec(&KNOWN_PAGES.fetch(page_name))
  end
end

World(KnownPages)

Given 'I am on the {string} page' do |page|
  visit_known_page page
end

When 'I go to the {string} page' do |page|
  visit_known_page page
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
