require 'optparse'
require 'rexml/document'
require 'rexml/streamlistener'
require 'time'
require 'post'

$options = {}

opts =OptionParser.new do |o|
  o.banner = "Usage: poster.rb [options]"
#  o.on("-v", "--verbose", "Run verbosely") do |v|
#    options[:verbose] = v
#  end
  o.on("-r", "--url url", "URL of the log") do |v|
    $options[:url] = v
  end
  o.on("-u", "--username USER", "HTTP user name (optional)") do |v|
    $options[:user_name] = v
  end
  o.on("-p", "--password PASS", "HTTP password (optional)") do |v|
    $options[:password] = v
  end
  o.on("-l", "--log LOGFILE", "Path to the log data source") do |v|
    $options[:log] = v
  end
      
    
  o.on_tail("-h", "--help", "Show this message") do
    puts o
    exit
  end
end



class MyListener
  include REXML::StreamListener

  attr_accessor :columns, :index_curve, :index_curve_column_index

  def initialize
    @state = :none
    @columns = {}

    re = /.*\/well\/([^\/]+)\/wellbore\/([^\/]+)\/log\/([^\/]+)/
    @url = $options[:url]
    @uid_well = re.match(@url)[1]
    @uid_wellbore = re.match(@url)[2]
    @uid_log = re.match(@url)[3]

    restore_state @uid_well, @uid_wellbore, @uid_log

  end

  def save_state (uid_well, uid_wellbore, uid_log, this_time)
    begin 
      Dir.mkdir ".witsml-replay"
    rescue 
    end

    f = File.new ".witsml-replay/#{uid_well}.#{uid_wellbore}.#{uid_log}", "w"
    begin
      f.puts this_time.iso8601
    rescue
    end
    f.close if f
  end

  def restore_state (uid_well, uid_wellbore, uid_log)
     begin
       f = File.new ".witsml-replay/#{uid_well}.#{uid_wellbore}.#{uid_log}", "r"
       @last_time = Time.iso8601 f.gets

       print "restored state #{@last_time}"
    rescue
    end
    f.close if f
  end

  def tag_start name, attrs
    case name
    when "indexCurve" 
      @state = :index_curve
      @index_curve = ''
      @index_curve_column_index = attrs["columnIndex"].to_i
      #puts "attrs = #{attrs['columnIndex']}"
   when "mnemonic"
      @state = :mnemonic
      @mnemonic = ''
    when "columnIndex"
      @state = :column_index
      @column_index = ''
    when "data"
      @state = :data
      @data = ''
    when "nullValue"
      @state = :null_value
      @null_value = ''
    else
      @state = :none
    end
  end
  
  def tag_end name
    case name
    when "data"


      @null_value = (@null_value || '').strip # how come this didnt work above?
      @data = @data.strip
      vals = @data.split(',').map {|x| x.strip}
      this_time = Time.iso8601(vals[@index_curve_column_index- 1])
      
      # skip this line if we have restored state and have not yet reached the time we last did
      if (!@last_time || (@last_time && this_time.to_f > @last_time.to_f))

        delay = this_time.to_f - (@last_time || this_time).to_f
        now = Time.new.to_f
        loop_time = now - (@last_now || now).to_f
        
        sleep [0, [60,  delay - loop_time].min].max
        @last_now = Time.new
        @last_time = this_time
      
        fake_time = Time.new.iso8601;
        puts "#{this_time.iso8601} => #{fake_time}"
      
        keys = @columns.keys.sort
        good_keys = keys.find_all {|i| vals[i] != '' && vals[i] != @null_value && i != (@index_curve_column_index - 1) }
        
        #puts "removed null #{@null_value} -- #{(keys.length - good_keys.length)}"
        channels = good_keys.map {|i| "    <channel><mnemonic>#{@columns[i]}</mnemonic><value>#{vals[i]}</value></channel>"}


  
        rt = <<EOF
<realtimes xmlns="http://www.witsml.org/schemas/131">
  <realtime uidWell="#{@uid_well}" uidWellbore="#{@uid_wellbore}" >
    <dTim>#{fake_time}</dTim>
     #{channels.join("\r\n")}
  </realtime>
</realtimes>
EOF

        # print rt
        post rt, @url, $options[:user_name], $options[:password]

      
        save_state @uid_well, @uid_wellbore, @uid_log, this_time
      else
        puts "skipped #{this_time} < #{@last_time}"
      end
    when "logCurveInfo" 
      @mnemonic = @mnemonic.strip
      @column_index = @column_index.strip
      @columns[@column_index.to_i-1] = @mnemonic;
    when "indexCurve"
      @index_curve = @index_curve.strip
    when "nullValue"
      @null_value = @null_value.strip
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
    when :null_value
      @null_value += text
    end
  end
end

opts.parse!
if ( !$options[:url]  ||!$options[:log])
  puts(opts.help)
  exit 1
end


listener = MyListener.new 
source = File.new $options[:log] 
REXML::Document.parse_stream(source, listener)

print "index curve #{listener.index_curve} #{listener.index_curve_column_index}"
print "columns #{listener.columns}"


