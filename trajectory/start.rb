#!/usr/bin/env ruby -w -I.
require 'optparse'
require 'wmls'

url =  'https://wsp1.local/witsml/services/store'

username = 'partner'
password = 'partner'

uid_well= 'bhl-1'
uid_wellbore='wb-1'
uid_log = 'log-1'
uid_traj = 'traj-1'

opts =OptionParser.new do |o|
  o.banner = "Usage: start_new.rb [options]"

  o.on("-r", "--url url", "URL of the repository") do |v|
    url = v
  end
  o.on("-u", "--username USER", "HTTP user name (optional)") do |v|
    user_name = v
  end
  o.on("-p", "--password PASS", "HTTP password (optional)") do |v|
    password = v
  end
  o.on_tail("-h", "--help", "Show this message") do
    puts o
    exit
  end
end


well = <<EOF
<wells xmlns="http://www.witsml.org/schemas/131" version="1.3.1.1">
  <well  uid="#{uid_well}">
    <name>DemoWell TRAJECTORY</name>
  </well>
</wells>
EOF

wellbore = <<EOF
<wellbores xmlns="http://www.witsml.org/schemas/131" version="1.3.1.1">
  <wellbore uid="#{uid_wellbore}" uidWell="#{uid_well}">
    <nameWell>DemoWell TRAJECTORY</nameWell>
    <name>WB-1</name>
  </wellbore>
</wellbores>
EOF

traj = <<EOF
<trajectorys xmlns="http://www.witsml.org/schemas/131" version="1.3.1.1">
  <trajectory uidWell="#{uid_well}" uidWellbore="#{uid_wellbore}" uid="#{uid_traj}">
  <nameWell>DemoWell TRAJECTORY</nameWell>
  <nameWellbore>WB-1</nameWellbore>
  <name>Trajectory</name>
  <dTimTrajStart/>
  <dTimTrajEnd/>
  <mdMn uom="ft">13892</mdMn>
  <mdMx uom="ft">18610</mdMx>
  </trajectory>
</trajectorys>
EOF

log = <<EOF
<logs xmlns="http://www.witsml.org/schemas/131" version="1.3.1.1">
<log  uidWell="#{uid_well}" uidWellbore="#{uid_wellbore}" uid="#{uid_log}">
  <nameWell>DemoWell DEPTH</nameWell>
  <nameWellbore>WB-1</nameWellbore>
  <name>Chalk GR</name>
  <objectGrowing>false</objectGrowing>
  <serviceCompany>Wellstorm</serviceCompany>
  <indexType>measured depth</indexType>
  <startIndex uom='f'>14024</startIndex>
  <endIndex uom='f'>18610</endIndex>
  <indexCurve columnIndex='1'>DEPTH</indexCurve>
  <nullValue>-999.25</nullValue>
  <logCurveInfo uid='DEPTH'>
    <mnemonic>DEPTH</mnemonic>
    <unit>f</unit>
    <minIndex uom='ft'>14024</minIndex>
    <maxIndex uom='ft'>18610</maxIndex>
    <columnIndex>1</columnIndex>
  </logCurveInfo>
  <logCurveInfo uid='MTTV'>
    <mnemonic>MTTV</mnemonic>
    <unit>f</unit>
    <minIndex uom='ft'>14024</minIndex>
    <maxIndex uom='ft'>14645.25</maxIndex>
    <columnIndex>2</columnIndex>
    <curveDescription>MWD Tool Measurement TVD</curveDescription>
  </logCurveInfo>
  <logCurveInfo uid='ROP'>
    <mnemonic>ROP</mnemonic>
    <unit>ft/h</unit>
    <minIndex uom='ft'>14024</minIndex>
    <maxIndex uom='ft'>18610</maxIndex>
    <columnIndex>3</columnIndex>
    <curveDescription>Rate of Penetration (MWD Depth Ave.)</curveDescription>
  </logCurveInfo>
  <logCurveInfo uid='SGR'>
    <mnemonic>SGR</mnemonic>
    <unit>gapi</unit>
    <minIndex uom='ft'>14024</minIndex>
    <maxIndex uom='ft'>18610</maxIndex>
    <columnIndex>4</columnIndex>
    <curveDescription>CWR Calibrated Gamma</curveDescription>
  </logCurveInfo>
  <logCurveInfo uid='VIBC'>
    <mnemonic>VIBC</mnemonic>
    <unit>cps</unit>
    <minIndex uom='ft'>14024</minIndex>
    <maxIndex uom='ft'>18605.75</maxIndex>
    <columnIndex>5</columnIndex>
    <curveDescription>Vibration Count</curveDescription>
  </logCurveInfo>
  </log>
</logs>
EOF

if username =~ /YOUR.*/ || password =~ /YOUR.*/
  abort 'FAIL you need to edit file start.rb with your username and password.'
end

wmls = Wmls.new url, username, password

status, supp_msg = wmls.delete_from_store well
puts "Delete well status = #{status} #{supp_msg}"

status, supp_msg = wmls.add_to_store well
puts "Add well status = #{status} #{supp_msg}"

status, supp_msg  = wmls.add_to_store wellbore
puts "Add wellbore status = #{status} #{supp_msg}"

status, supp_msg  = wmls.add_to_store traj
puts "Add traj status = #{status} #{supp_msg}"

status, supp_msg  = wmls.add_to_store log
puts "Add log status = #{status} #{supp_msg}"




