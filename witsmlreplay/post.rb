
require 'stringio'
require 'net/http'
require 'net/https'
require 'uri'

def post(io, url, user, pass)    
  url = URI.parse(url)  if url.is_a? String
  io = StringIO.new(io) if io.is_a? String

  req = Net::HTTP::Post.new(url.path)
  req.basic_auth user, pass if user && user.length > 0
  req.body_stream = io
  req.content_type = 'application/xml'
  #req.content_length = io.stat.size
  req.content_length = io.size   # specific to StringIO class ? why no stat on that class?
  http = Net::HTTP.new(url.host, url.port)  
  http.use_ssl = true
  http.read_timeout = 60 # secs
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  res = http.start {|http2| http2.request(req) }

  case res
  when Net::HTTPSuccess, Net::HTTPRedirection
    # OK
    res
  when Net::HTTPCreated
    res['Location'] 
  else
    res.error!
  end
end

def delete(io, url, user, pass)    
  url = URI.parse(url)  if url.is_a? String
  io = StringIO.new(io) if io.is_a? String

  req = Net::HTTP::Delete.new(url.path)
  req.basic_auth user, pass if user && user.length > 0
  http = Net::HTTP.new(url.host, url.port)  
  http.use_ssl = true
  http.read_timeout = 3600 # secs
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  res = http.start {|http2| http2.request(req) }

  case res
  when Net::HTTPSuccess, Net::HTTPRedirection
    # OK
    res
  else
    res.error!
  end
end
