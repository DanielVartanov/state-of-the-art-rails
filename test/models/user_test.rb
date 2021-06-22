require "test_helper"

class UserTest < ActiveSupport::TestCase
  test '.most_talkative, when only one user, even without messages' do
    user = create :user
    assert_equal User.most_talkative, user
  end

  test '.most_talkative, when two users with equal messages count' do
    users = 2.times.map { create :user }
    users.each { |user| create :message, user: user }

    silent_user = create :user

    assert_not_equal User.most_talkative, silent_user
  end

  test '.most_talkative, when two users' do
    first_user = create :user
    second_user = create :user

    create :message, user: first_user
    2.times { create :message, user: second_user }

    assert_equal User.most_talkative, second_user
  end
end
