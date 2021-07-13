Given 'a message {string} by {string}' do |message, author|
  create :message,
         content: message,
         user: User.find_by!(name: author)
end

When 'I send a message {string} on behalf of {string}' do |message, author|
  within 'turbo-frame#new_message' do
    select author, from: 'Author'
    fill_in 'Content', with: message
    click_on 'Create Message'
  end
end
