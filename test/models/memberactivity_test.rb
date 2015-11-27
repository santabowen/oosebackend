require 'test_helper'

class MemberactivityTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
	 	@member_activity = Memberactivity.new(user_id: 1, activity_id: 1)
	end
  	
	test "should be valid" do
		assert @member_activity.valid?
	end

	test "user id should be present" do
		@member_activity.user_id = nil
  	assert_not @member_activity.valid?
	end

	test "activity id should be present" do
		@member_activity.activity_id = nil
  	assert_not @member_activity.valid?
	end
end
