require 'test_helper'

class ActivityTest < ActiveSupport::TestCase

  def setup
		@activity = Activity.new(id: 1, user_id: 1)
	end
  	
	test "should be valid" do
		assert @activity.valid?
	end

	test "owner id should be present" do
		@activity.user_id = nil
  	assert_not @activity.valid?
	end


end
