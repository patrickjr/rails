json.array!(@box_users) do |box_user|
  json.extract! box_user, :id
  json.url box_user_url(box_user, format: :json)
end
