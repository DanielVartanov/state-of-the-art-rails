Then 'I wait' do
  sleep 5
end

Then 'I wait for {int} seconds' do |seconds|
  sleep seconds
end

Then 'I stop until further notice' do
  Kernel.puts 'Press ENTER to continue...'
  STDIN.gets
end
