require 'optparse'
require 'wmls'

url =  'https://wsp1.local:24443/witsml/services/store'

username = 'partner'
password = 'partner'

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

uid_well= 'geologix-1'
uid_wellbore='wb-1'
uid_log = 'log-1'
uid_mudlog = 'mudlog-1'

well = <<EOF
<wells xmlns="http://www.witsml.org/schemas/131" version="1.3.1.1">
  <well  uid="#{uid_well}">
    <name>DemoWell MUDLOG</name>
  </well>
</wells>
EOF

wellbore = <<EOF
<wellbores xmlns="http://www.witsml.org/schemas/131" version="1.3.1.1">
  <wellbore uid="#{uid_wellbore}" uidWell="#{uid_well}">
    <nameWell>DemoWell MUDLOG</nameWell>
    <name>WB-1</name>
  </wellbore>
</wellbores>
EOF

log = <<EOF
<logs xmlns="http://www.witsml.org/schemas/131" version="1.3.1.1">
<log uid="#{uid_log}"  uidWellbore="#{uid_wellbore}" uidWell="#{uid_well}" xmlns='http://www.witsml.org/schemas/131'>
  <nameWell>DemoWell MUDLOG</nameWell>
  <nameWellbore>WB1</nameWellbore>
  <name>Edward v6 WellOps</name>
  <objectGrowing>false</objectGrowing>
  <dataRowCount>1283</dataRowCount>
  <runNumber>none</runNumber>
  <indexType>measured depth</indexType>
  <startIndex uom='ft'>0</startIndex>
  <endIndex uom='ft'>6410</endIndex>
  <indexCurve columnIndex='1'>__INDEX_MD__</indexCurve>
  <nullValue>-999.250</nullValue>
  <logCurveInfo uid='000'>
    <mnemonic>__INDEX_MD__</mnemonic>
    <unit>ft</unit>
    <columnIndex>1</columnIndex>
  </logCurveInfo>
  <logCurveInfo uid='001'>
    <mnemonic>ROP</mnemonic>
    <unit>FT/HR</unit>
    <columnIndex>2</columnIndex>
    <curveDescription>Rate of Penetration</curveDescription>
  </logCurveInfo>
  <logCurveInfo uid='002'>
    <mnemonic>WOB</mnemonic>
    <unit>KLBS</unit>
    <columnIndex>3</columnIndex>
    <curveDescription>Weight on Bit</curveDescription>
  </logCurveInfo>
  <logCurveInfo uid='003'>
    <mnemonic>RPM</mnemonic>
    <unit>RPM</unit>
    <columnIndex>4</columnIndex>
    <curveDescription>Revolutions per Minute</curveDescription>
  </logCurveInfo>
  <logCurveInfo uid='004'>
    <mnemonic>TRQ</mnemonic>
    <unit>AMPS</unit>
    <columnIndex>5</columnIndex>
    <curveDescription>Torque</curveDescription>
  </logCurveInfo>
  <logCurveInfo uid='005'>
    <mnemonic>SPP</mnemonic>
    <unit>PSI</unit>
    <columnIndex>6</columnIndex>
    <curveDescription>Stand Pipe Pressure</curveDescription>
  </logCurveInfo>
  <logCurveInfo uid='006'>
    <mnemonic>TG</mnemonic>
    <unit>%</unit>
    <columnIndex>7</columnIndex>
    <curveDescription>Total Gas</curveDescription>
  </logCurveInfo>
  <logCurveInfo uid='007'>
    <mnemonic>C1</mnemonic>
    <unit>(ppm)</unit>
    <columnIndex>8</columnIndex>
    <curveDescription>Methane</curveDescription>
  </logCurveInfo>
  <logCurveInfo uid='008'>
    <mnemonic>C2</mnemonic>
    <unit>(ppm)</unit>
    <columnIndex>9</columnIndex>
    <curveDescription>Ethane</curveDescription>
  </logCurveInfo>
  <logCurveInfo uid='009'>
    <mnemonic>C3</mnemonic>
    <unit>(ppm)</unit>
    <columnIndex>10</columnIndex>
    <curveDescription>Propane</curveDescription>
  </logCurveInfo>
  <logCurveInfo uid='010'>
    <mnemonic>IC4</mnemonic>
    <unit>(ppm)</unit>
    <columnIndex>11</columnIndex>
    <curveDescription>Iso-Butane</curveDescription>
  </logCurveInfo>
  <logCurveInfo uid='011'>
    <mnemonic>NC4</mnemonic>
    <unit>(ppm)</unit>
    <columnIndex>12</columnIndex>
    <curveDescription>Normal Butane</curveDescription>
  </logCurveInfo>
  <logCurveInfo uid='012'>
    <mnemonic>IC5</mnemonic>
    <unit>PPM</unit>
    <columnIndex>13</columnIndex>
    <curveDescription>Iso-Pentane</curveDescription>
  </logCurveInfo>
  <logCurveInfo uid='013'>
    <mnemonic>NC5</mnemonic>
    <unit>PPM</unit>
    <columnIndex>14</columnIndex>
    <curveDescription>Normal Pentane</curveDescription>
  </logCurveInfo>
</log>
</logs>
EOF

mudlog = <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<mudLogs xmlns="http://www.witsml.org/schemas/131" version="1.3.1.1">
<mudLog xmlns="http://www.witsml.org/schemas/131" uidWell="#{uid_well}" uidWellbore="#{uid_wellbore}" uid="#{uid_mudlog}">
  <nameWell>DemoWell MUDLOG</nameWell>
  <nameWellbore>WB 1</nameWellbore>
  <name>Edward v6 WellOps</name>
  <startMd uom="ft">0</startMd>
  <endMd uom="ft">6539</endMd>
  <parameter uid="00000">
    <type>casing point comment</type>
    <mdTop uom="ft">1093.3941</mdTop>
    <mdBottom uom="ft">1093.3941</mdBottom>
    <text>20" Casing 1012ft</text>
  </parameter>
  <parameter uid="00001">
    <type>casing point comment</type>
    <mdTop uom="ft">2641.3453</mdTop>
    <mdBottom uom="ft">2641.3453</mdBottom>
    <text>13 3/8" Casing 2503ft</text>
  </parameter>
  <parameter uid="00003">
    <type>casing point comment</type>
    <mdTop uom="ft">3079.7415</mdTop>
    <mdBottom uom="ft">3079.7415</mdBottom>
    <text>7" Liner 3657.2ft</text>
  </parameter>
  <parameter uid="00002">
    <type>casing point comment</type>
    <mdTop uom="ft">4454.3581</mdTop>
    <mdBottom uom="ft">4454.3581</mdBottom>
    <text>9 5/8" Casing 2503ft</text>
  </parameter>
</mudLog>
</mudLogs>
EOF


wmls = Wmls.new url, username, password

status, supp_msg = wmls.delete_from_store well
puts "Delete well status = #{status} #{supp_msg}"

status, supp_msg = wmls.add_to_store well
puts "Add well status = #{status} #{supp_msg}"

status, supp_msg  = wmls.add_to_store wellbore
puts "Add wellbore status = #{status} #{supp_msg}"

status, supp_msg  = wmls.add_to_store mudlog
puts "Add mudLog status = #{status} #{supp_msg}"

status, supp_msg  = wmls.add_to_store log
puts "Add log status = #{status} #{supp_msg}"

