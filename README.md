check_ntp_time
==============

  Nagios NTP synchronization check

Usage
-----
This script is intended to be called via a Nagios (or Nagios-based) monitoring system, probably via NRPE.

check_ntp_time.pl <-H ntpserver> <-w warnlevel> <-c critlevel>
###Options:
<table>
  <tr>
    <td>-H ntpserver</td>
    <td>Hostname or IP address of the ntp server</td>
  </tr>
  <tr>
    <td>-w seconds</td>
    <td>Difference in seconds from the ntpserver clock and the server clock which the plugin will emit a warning alarm - Default = 150 seconds (above or below)</td>
  </tr>
  <tr>
    <td>-c seconds</td>
    <td>Difference in seconds from the ntpserver clock and the server clock which the plugin will emit a critical alarm - Default = 300 seconds (above or below)</td>
  </tr>
</table>

Contribute
----------
Please see the [Github](https://github.com/jlk/check_ntp_time) page. Happy to accept pull requests! If the module don't do what you want, please explain your use case.

History
-------
check_ntp_time.pl was posted by Antonio Evangelista to the Nagios
Exchange at
http://exchange.nagios.org/directory/Plugins/System-Metrics/Time/check_ntp_time-2Epl/details.

Copyright
---------
Original Copyright (C) 2011 Antonio Fernando Evangelista
