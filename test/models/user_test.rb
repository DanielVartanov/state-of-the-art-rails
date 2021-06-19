require "test_helper"

class UserTest < ActiveSupport::TestCase
  test '.most_talkative, when only one user, even without messages' do
    user = User.create!
    assert_equal User.most_talkative, user
  end

  test '.most_talkative, when two users with equal messages count' do
    users = 2.times.map { User.create! }
    users.each { |user| user.messages.create! }

    silent_user = User.create!

    assert_not_equal User.most_talkative, silent_user
  end

  test '.most_talkative, when two users' do
    first_user = User.create!
    second_user = User.create!

    first_user.messages.create!
    2.times { second_user.messages.create! }

    assert_equal User.most_talkative, second_user
  end
end
