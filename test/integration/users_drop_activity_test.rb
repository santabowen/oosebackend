require 'test_helper'

class UsersDropActivityTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  test "valid drop activity" do
    host = User.new( name: "Example Host", email: "host@example.com", 
                     password: "123456", gender: "male", authtoken: rand_string(20) )
    host.save

    user = User.new( name: "Example User", email: "user@example.com", 
                     password: "123456", gender: "male", authtoken: rand_string(20) )
    user.save

    activity = Activity.new(user_id: host.id,
    						memberNum: 1)
    activity.save

    post '/activities/join', {ActID: activity.id,
      						  UserID: user.id }


	# print "\n~~~~~~~~~~~~~~~~~~~~\n"
	# print activity.memberactivities.count
	# print Activity.count
 #    print Activity.first.memberNum
 #    print "\n~~~~~~~~~~~~~~~~~~~~\n"


	assert_difference 'activity.memberactivities.count', -1 do
      delete '/activities/drop', {ActID: activity.id,
      							  UserID: user.id }
    end
  end

end
