PAGES = {
  "Authors" => "authors_path",
  "Messages" => "messages_path"
}.freeze

When("I go to the {string} page") do |page_name|
  visit send(PAGES.fetch(page_name))
end

Given("I am on the {string} page") do |page_name|
  visit send(PAGES.fetch(page_name))
end
