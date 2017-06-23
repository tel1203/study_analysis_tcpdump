#
# Usage:
#   $ tcpdump -tt -n -r 20160623-test.tcpdump | ruby check_serviceport.rb  | less
#   ssh 192.168.100.199 "sudo tcpdump -tt -n -i eth1" | ruby check_serviceport.rb 
#
require './lib_tcpdump_analysis.rb'

# Hash for analysis
list_serviceport = Hash.new 
internal_address = "172.20.10.5"
interval=60 # Analysys Interval in Seconds
last_slot = 0

line = ""
count=0
while (line != nil) do
  line = STDIN.gets
  count += 1
  time, proto0, src_ip, src_port, proto1, dst_ip, dst_port, size = parse_tcpdump(line)
  next if (src_ip == nil)
  next if (src_ip.index(internal_address) != 0)

  # Analysis part
  list_serviceport[dst_port] = Array.new if (list_serviceport[dst_port] == nil)
  list_serviceport[dst_port].push(src_ip)
  slot = (time.to_i / interval)

  # Output
  if (slot > last_slot) then
    # Print analysis result
    printf("\n%s %d\n", time, count)
    rank = create_arraylist(list_serviceport)

    # Sort the arraylist by #1 element in the element of the arraylist
    puts("Service Ports by Num of Access")
    tmp = sort_arraylist(rank, 1, 20, false)
    tmp.each do |e|
      p e
    end

    # Sort the arraylist by #1 element in the element of the arraylist
    puts("Service Ports by Unique Num of Access")
    tmp = sort_arraylist(rank, 2, 20, false)
    tmp.each do |e|
      p e
    end

    # Clear previous data
    list_srcip = Hash.new 
  end

  # Check time interval
  last_slot = slot
end

