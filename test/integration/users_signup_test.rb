require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "invalid signup information" do
		assert_no_difference 'User.count' do
      post users_path, {name:     "",
                        email:    "user@invalid",
                        password: "foo"}
		end
	end

	test "valid signup information" do
		assert_difference 'User.count', 1 do
      post users_path, {name:     "namenicai",
                        email:    "user2@invalid.com",
                        password: "whynot",
                        gender:   "male" }
		end
	end
end
