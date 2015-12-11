require 'test_helper'

class UsersJoinActivityTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  test "valid join activity" do
    user = User.new( name: "Example User", email: "user@example.com", 
                     password: "123456", gender: "male", authtoken: rand_string(20) )
    user.save

    activity = Activity.new(user_id: 1,
    						memberNum: 1)
	activity.save
	  assert_difference 'activity.memberactivities.count', 1 do
      post '/activities/join', {ActID: activity.id,
      							UserID: user.id }
    end

    # post "/activities/post", { HostID:       user.id,
    #                              ActivityType: "Soccer",
    #                              Location:     "3900 N. Charles St.",
    #                              GroupSize:    10,
    #                              Comments:     "I love sports.",
    #                              Duration:     3600,
    #                              Lng:          3.2321,
    #                              Lat:          54.435345 }
    
    
    # print "\n~~~~~~~~~~~~~~~~~~~~\n"
    # print Activity.first.memberactivities.count
    # print "\n~~~~~~~~~~~~~~~~~~~~\n"
    # print Activity.first.memberNum
    # print "\n~~~~~~~~~~~~~~~~~~~~\n"
    # assert_difference 'Activity.first.memberactivities.count', 1 do
    #   post '/activities/join', {ActID: Activity.first.id,
    #   							UserID: user.id }
    # end
  end
end
