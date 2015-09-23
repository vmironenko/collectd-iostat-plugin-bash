# collectd-iostat-plugin-bash
There is collectd iostat plugin which collects metrics of disks and cpu and written in bash

Add this section into collectd.conf 
<br>
<pre>
&lt;Plugin exec&gt;
    Exec "nobody" "/path/to/collectd-iostat-plugin.sh"
&lt;Plugin&gt;
&lt;Plugin exec&gt;
    Exec "nobody" "/path/to/collectd-vmstat-plugin.sh"
&lt;Plugin&gt;
</pre>
