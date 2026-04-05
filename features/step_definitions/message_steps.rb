Given("a message {string} by {string}") do |content, author_name|
  author = Author.find_by!(name: author_name)
  FactoryBot.create(:message, author: author, content: content)
end

When("I send a message {string} on behalf of {string}") do |content, author_name|
  within("#new_message") do
    select author_name, from: "Author"
    fill_in "Content", with: content
    click_button "Send"
  end
end

When("I press {string} button next to the message {string}") do |button, content|
  message = Message.find_by!(content: content)
  within("##{dom_id(message)}") do
    click_button button
  end
end

When("I edit the message content to {string}") do |content|
  within("#edit_message") do
    fill_in "Content", with: content
    click_button "Save"
  end
end

When("I open another browser window") do
  @original_window = page.current_window
  @new_window = open_new_window
  switch_to_window(@new_window)
end

When("I close another browser window") do
  switch_to_window(@original_window)
  @new_window.close
end
