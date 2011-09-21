
def traj_template uid_well, uid_wellbore, uid_traj, station
  template = <<EOF
<trajectorys xmlns="http://www.witsml.org/schemas/131" version="1.3.1.1">
  <trajectory uidWell="#{uid_well}" uidWellbore="#{uid_wellbore}" uid="#{uid_traj}">
    #{station}
  </trajectory>
</trajectorys>
EOF
end

def log_template uid_well, uid_wellbore, uid_log, start_index, end_index, vals_string
  template = <<EOF
<logs xmlns="http://www.witsml.org/schemas/131" version="1.3.1.1">
  <log uidWell="#{uid_well}" uidWellbore="#{uid_wellbore}" uid="#{uid_log}">
    <indexType>measured depth</indexType>
<!--
    <startIndex uom='f'>#{start_index}</startIndex>
    <endIndex uom='f'>#{end_index}</endIndex>
-->

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



    <logData>
      #{vals_string}
    </logData>
  </log>
</logs>
EOF

end


def mudlog_template uid_well, uid_wellbore, uid_mudlog, geology_interval
  template = <<EOF
<mudLogs xmlns="http://www.witsml.org/schemas/131" version="1.3.1.1">
  <mudLog uidWell="#{uid_well}" uidWellbore="#{uid_wellbore}" uid="#{uid_mudlog}">
    #{geology_interval}
  </mudLog>
</mudLogs>
EOF
end

