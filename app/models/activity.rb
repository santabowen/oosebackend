class Activity < ActiveRecord::Base
	belongs_to :user
	default_scope -> { order(created_at: :desc) }
	validates :user_id, presence: true

	has_many :member_activities, dependent: :destroy
end
