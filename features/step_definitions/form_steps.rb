When("I fill in {string} with {string}") do |field, value|
  fill_in field, with: value
end

When("I select {string} from {string}") do |value, field|
  select value, from: field
end

When("I click {string}") do |button|
  click_button button
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end

Then("I should NOT see {string}") do |text|
  expect(page).to have_no_content(text)
end

Then("I should see an author with a name of {string} in the list") do |name|
  within("#authors") do
    expect(page).to have_content(name)
  end
end

Then("I should NOT see an author with a name of {string} in the list") do |name|
  within("#authors") do
    expect(page).to have_no_content(name)
  end
end
