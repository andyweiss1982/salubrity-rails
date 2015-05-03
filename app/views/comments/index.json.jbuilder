json.array!(@comments2) do |comment|
  json.extract! comment, :id, :author, :fbid, :text
  json.url comment_url(comment, format: :json)
end
