require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "invalid signup information" do
		assert_no_difference 'User.count' do
      post users_path, user: { name:     " ",
                               email:    "user@invalid",
                               password: "foo"}
		end
	end
end
