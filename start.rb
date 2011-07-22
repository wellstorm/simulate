#!/usr/bin/env ruby -w -I.
require 'optparse'
require 'wmls'

url =  'https://witsml.wellstorm.com/witsml/services/store'
username = 'admin'
password = 'quateraf'
uid_well= 'bhl-test'
uid_wellbore='wb-1'
uid_log = 'log-1'
uid_traj = 'traj-1'

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
<log  uidWell="#{uid_well}" uidWellbore="#{uid_wellbore}" uid="#{uid_traj}">
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




