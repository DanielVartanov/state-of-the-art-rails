Then 'I wait' do
  sleep 5
end

Then 'I wait for {int} seconds' do |seconds|
  sleep seconds
end

Then 'I run debugger' do
  byebug
end

Then 'I pause until further notice' do
  ask 'Press ENTER to continue...'
end

Then 'save and open screenshot' do
  save_and_open_screenshot
end
