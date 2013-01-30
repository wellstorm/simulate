require 'optparse'
require 'post'

$options = {}

opts =OptionParser.new do |o|
  o.banner = "Usage: start_we;;.rb [options]"

  o.on("-r", "--url url", "URL of the repository") do |v|
    $options[:url] = v
  end
  o.on("-u", "--username USER", "HTTP user name (optional)") do |v|
    $options[:user_name] = v
  end
  o.on("-p", "--password PASS", "HTTP password (optional)") do |v|
    $options[:password] = v
  end
  o.on("-w", "--well WELLFILE", "Path to the well WITSML file") do |v|
    $options[:well] = v
  end
  o.on("-b", "--wellbore WELLBOREFILE", "Path to the wellbore WITSML file") do |v|
    $options[:wellbore] = v
  end
  o.on("-i", "--uidWell  UIDWELL", "uid of the well") do |v|
    $options[:uidWell] = v
  end    
  o.on("-n", "--nameWell  NAMEWELL", "name of the well") do |v|
    $options[:nameWell] = v
  end      
  o.on_tail("-h", "--help", "Show this message") do
    puts o
    exit
  end
end

def delete_state (uid_well, uid_wellbore, uid_log)
  begin
    File.delete ".witsml-replay/#{uid_well}.#{uid_wellbore}.#{uid_log}"
  rescue
  end
end

def replace_well_object_text(s, uid_well, name_well)
  begin
    s["@UID_WELL@"] = uid_well
    s["@NAME_WELL@"] = name_well
  rescue
  end
end

def replace_wellbore_object_text(s, uid_well, uid_wellbore, name_well, name_wellbore)
  begin
    s["@UID_WELL@"] = uid_well
    s["@NAME_WELL@"] = name_well
    s["@UID_WELLBORE@"] = uid_wellbore
    s["@NAME_WELLBORE@"] = name_wellbore    
  rescue
  end
end

opts.parse!

well_file =  IO.read($options[:well], 200000)
wellbore_file = IO.read($options[:wellbore], 200000)
uid_well = $options[:uidWell]
uid_wellbore = "#{uid_well}-wb1"
name_well = $options[:nameWell]
name_wellbore = name_well

puts "uidWell     : #{uid_well}"
puts "uidWellbore : #{uid_wellbore}"
puts "nameWell    : #{name_well}"
puts "nameWellbore: #{name_wellbore}"

replace_well_object_text(well_file, uid_well, name_well)
replace_wellbore_object_text(wellbore_file, uid_well, uid_wellbore, name_well, name_wellbore)

  
# we use these for the delete template
well=<<EOF
<wells xmlns="http://www.witsml.org/schemas/131">
  <well uid="#{uid_well}">
  </well>
</wells>
EOF


wellbore=<<EOF
<wellbores xmlns="http://www.witsml.org/schemas/131">
  <wellbore uidWell="#{uid_well}" uid="#{uid_wellbore}" >
  </wellbore>
</wellbores>
EOF

url_base = $options[:url]
url_well = "#{url_base}/well/#{uid_well}"
url_wellbore = "#{url_well}/wellbore/#{uid_wellbore}"



puts "This progam will wipe any existing data under the specified well."
puts "If the well with uid #{uid_well} exists, we are going to nuke it."
puts "Are you sure you are ready for a fresh clean start using a "
print "new empty well and wellbore? If so, type 'yes': "

yes = gets.chomp

if yes != "yes"
  puts "Well, I'm glad I asked. Quitting now. No harm done."
  exit 0
end


#delete_state uid_well, uid_wellbore, uid_log


puts "deleting well  #{url_well}"
puts "this can take 10 - 20 minutes if there is a lot of data to delete"
begin
  delete well, url_well, $options[:user_name], $options[:password] 
rescue
  puts '...that well does not exist. No problem.'
end

sleep(5)


puts "posting well to #{url_base}"
begin
  post well_file, url_base + "/", $options[:user_name], $options[:password] 
rescue 
  puts "EXPLANATION: Deletes happen asynchronously. So what's likely happened is"
  puts "you see an error 409 when we try to upload the well. Don't sweat it."
  puts "It means, Try again later. Give it a few minutes and try again."
  puts "It might take a few minutes to completely delete the well and its contents. "
  puts "Eventually, one of these tries will succeed. "
  puts "I'm quitting now."
  exit(1)
end

sleep(5)

puts "posting wellbore to #{url_well}"
post wellbore_file, url_well, $options[:user_name], $options[:password] 


puts 
puts "It looks like everything succeeded."
puts "You have a well named \"#{name_well}\", and wellbore name \"#{name_wellbore}\"."

