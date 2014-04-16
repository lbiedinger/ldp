##
# HTTP client methods for making requests to an LDP resource and getting a response back.
module Ldp::Client::Methods
  
  attr_reader :http
  def initialize_http_client *http_client
    if http_client.length == 1 and http_client.first.is_a? Faraday::Connection
      @http = http_client.first
    else 
      @http = Faraday.new *http_client  
    end
  end

  # Get a LDP Resource by URI
  def get url, options = {}
    logger.debug "LDP: GET [#{url}]"
    resp = http.get do |req|                          
      req.url url
      yield req if block_given?
    end

    if Ldp::Response.resource? resp
      Ldp::Response.wrap self, resp
    else
      resp
    end
  end

  # Delete a LDP Resource by URI
  def delete url
    logger.debug "LDP: DELETE [#{url}]"
    http.delete do |req|
      req.url url
      yield req if block_given?
    end
  end

  # Post TTL to an LDP Resource
  def post url, body = nil, headers = {}
    logger.debug "LDP: POST [#{url}]"
    http.post do |req|
      req.url url
      req.headers = default_headers.merge headers
      req.body = body
      yield req if block_given?
    end
  end

  # Update an LDP resource with TTL by URI
  def put url, body, headers = {}
    logger.debug "LDP: PUT [#{url}]"
    http.put do |req|
      req.url url
      req.headers = default_headers.merge headers
      req.body = body
      yield req if block_given?
    end
  end

  private

  def default_headers
    {"Content-Type"=>"text/turtle"}
  end
end
