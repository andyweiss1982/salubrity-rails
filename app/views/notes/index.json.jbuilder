json.array!(@notes) do |note|
  json.extract! note, :id, :message
  json.url note_url(note, format: :json)
end