require 'test_helper'

class ActivitypostTest < ActionDispatch::IntegrationTest
    
  test "invalid activity post" do
    assert_no_difference 'Activity.count' do
      post "/activities/post", { HostID:       nil,
                                 ActivityType: "Soccer",
                                 Location:     "3900 N. Charles St.",
                                 GroupSize:    10,
                                 Comments:     "I love sports.",
                                 Duration:     3600,
                                 Lng:          3.2321,
                                 Lat:          54.435345 }
    end
  end

  test "valid activity post" do
    user = User.new( name: "Example User", email: "user@example.com", 
                     password: "123456", gender: "male", authtoken: rand_string(20) )
    user.save
    assert_difference 'Activity.count', 1 do
      post '/activities/post', { HostID:       User.first.id,
                                 ActivityType: "Soccer",
                                 Location:     "3900 North Charles Street",
                                 GroupSize:    10,
                                 Comments:     "I love sports.",
                                 Duration:     3600,
                                 Lng:          3.2321123,
                                 Lat:          54.435345 }
    end
  end
end
