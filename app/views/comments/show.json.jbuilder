json.array!(@comments) do |ccomment|
  json.extract! comment, :id, :author, :text
end