require 'json'

def error_to_json(err, msg = nil)
  { error: msg.nil? ? err.message : msg }.to_json
end

def parse_body(request, params)
  begin
    body = JSON.parse(request.body.read)
    params.each do |param|
      raise ArgumentError, "Missing body parameter: #{param}" if body[param].nil?
    end
  rescue JSON::ParserError
    raise ArgumentError, 'Must provide valid body'
  end
  body
end
