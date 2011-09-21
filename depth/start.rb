#!/usr/bin/env ruby -w -I.
require 'optparse'
require 'wmls'

url =  'https://witsml.wellstorm.com/witsml/services/store'

username = 'YOUR.USER.NAME'
password = 'YOUR.PASSWORD'

uid_well= 'bhl-test-1'
uid_wellbore='wb-1'
uid_log = 'log-1'
uid_traj = 'traj-1'
uid_traj = 'mudlog-1'

well = <<EOF
<wells xmlns="http://www.witsml.org/schemas/131" version="1.3.1.1">
  <well  uid="#{uid_well}">
    <name>BHL TEST 1</name>
  </well>
</wells>
EOF



wellbore = <<EOF
<wellbores xmlns="http://www.witsml.org/schemas/131" version="1.3.1.1">
  <wellbore uid="#{uid_wellbore}" uidWell="#{uid_well}">
    <nameWell>BHL TEST 1</nameWell>
    <name>WB-1</name>
  </wellbore>
</wellbores>
EOF



traj = <<EOF
<trajectorys xmlns="http://www.witsml.org/schemas/131" version="1.3.1.1">
  <trajectory uidWell="#{uid_well}" uidWellbore="#{uid_wellbore}" uid="#{uid_traj}">
  <nameWell>BHL TEST 1</nameWell>
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
  <nameWell>BHL TEST 1</nameWell>
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

mudlog = <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<mudLogs xmlns="http://www.witsml.org/schemas/131" version="1.3.1.1">
<mudLog xmlns="http://www.witsml.org/schemas/131" uidWell="#{uid_well}" uidWellbore="#{uid_wellbore}" uid="#{uid_mudlog}">
  <nameWell>Geologix 1</nameWell>
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




