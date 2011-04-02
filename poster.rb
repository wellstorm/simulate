require 'optparse'
require 'net/http'
require 'net/https'
require 'uri'
require 'rexml/document'
require 'rexml/streamlistener'
require 'time'


options = {}

opts =OptionParser.new do |o|
  o.banner = "Usage: poster.rb [options]"
#  o.on("-v", "--verbose", "Run verbosely") do |v|
#    options[:verbose] = v
#  end
  o.on("-r", "--url url", "URL of the log") do |v|
    options[:url] = v
  end
  o.on("-u", "--username USER", "HTTP user name (optional)") do |v|
    options[:user_name] = v
  end
  o.on("-p", "--password PASS", "HTTP password (optional)") do |v|
    options[:password] = v
  end
  o.on("-l", "--log LOGFILE", "Path to the log data source") do |v|
    options[:log] = v
  end
  o.on_tail("-h", "--help", "Show this message") do
    puts o
    exit
  end
end


def upload(io, url, user, pass )    
 
  req = Net::HTTP::Post.new(url.path)
  req.basic_auth user, pass
  req.body_stream = io
  req.content_type = 'application/x.witsml+xml'
  req.content_length = io.stat.size
  http = Net::HTTP.new(url.host, url.port)  
  http.use_ssl = true
  http.read_timeout = 1800 # secs

  res = http.start {|http2| http2.request(req) }

  case res
  when Net::HTTPSuccess, Net::HTTPRedirection
    # OK
  else
    res.error!
  end
end

class MyListener
  include REXML::StreamListener

  attr_accessor :columns, :index_curve, :index_curve_column_index

  def initialize
    @state = :none
    @columns = {}
  end

  def tag_start name, attrs
    case name
    when "indexCurve" 
      @state = :index_curve
      @index_curve = ''
      @index_curve_column_index = attrs.assoc("columnIndex")[1].to_i
    when "mnemonic"
      @state = :mnemonic
      @mnemonic = ''
    when "columnIndex"
      @state = :column_index
      @column_index = ''
    when "data"
      @state = :data
      @data = ''
    else
      @state = :none
    end
  end
  
  def tag_end name
    case name
    when "data"
      @data = @data.strip
      vals = @data.split(',').map {|x| x.strip}
      this_time = Time.iso8601(vals[@index_curve_column_index- 1])
      delay = this_time.to_f - (@last_time || this_time).to_f
      now = Time.new.to_f
      loop_time = now - (@last_now || now).to_f
      #sleep [0, [60,  delay - (now - (@then || 0))].min].max
      sleep [0, [60,  delay - loop_time].min].max
      @last_now = Time.new
      @last_time = this_time
      
      puts (Time.new.iso8601)
      
    when "logCurveInfo" 
      @mnemonic = @mnemonic.strip
      @column_index = @column_index.strip
      @columns[@column_index.to_i-1] = @mnemonic;
    when "indexCurve"
      @indexCurve = @index_curve.strip
    end
  end

  def text(text)
    case @state 
    when :index_curve      
      @index_curve += text
    when :mnemonic
      @mnemonic += text
    when :column_index
      @column_index += text
    when :data
      @data += text
    end
  end
end

opts.parse!
if ( !options[:url]  ||!options[:log])
  puts(opts.help)
  exit 1
end


listener = MyListener.new 
source = File.new options[:log] 
REXML::Document.parse_stream(source, listener)

print "index curve #{listener.index_curve} #{listener.index_curve_column_index}"
print "columns #{listener.columns}"


