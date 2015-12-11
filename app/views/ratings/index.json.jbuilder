json.array!(@ratings) do |rating|
  json.extract! rating, :id, :activity_id, :user_id, :member_id, :rating
  json.url rating_url(rating, format: :json)
end
