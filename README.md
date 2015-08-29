# collectd-iostat-plugin-bash
There is collectd iostat plugin which collects metrics of disks and cpu and written in bash

Add this section into collectd.conf 
<Plugin exec>
    Exec "nobody" "/path/to/collectd-iostat-plugin.sh"
</Plugin>
