#
# Usage:
#   $ tcpdump -tt -n -r 20160623-test.tcpdump | ruby check_srcip_by_dstport.rb  | less
#   ssh 192.168.100.199 "sudo tcpdump -tt -n -i eth1" | ruby check_srcip_by_dstport.rb 
#
require './lib_tcpdump_analysis.rb'

# Hash for analysis
list_srcip = Hash.new 
interval=60 # Analysys Interval in Seconds
last_slot = 0

line = ""
count=0
while (line != nil) do
  line = STDIN.gets
  count += 1
  time, proto0, src_ip, src_port, proto1, dst_ip, dst_port, size = parse_tcpdump(line)
  next if (src_ip == nil)
  #next if (src_ip.index("172.16") != 0)

  # Analysis part
  list_srcip[src_ip] = Array.new if (list_srcip[src_ip] == nil)
  list_srcip[src_ip].push(dst_port)
  slot = (time.to_i / interval)

  # Output
  if (slot > last_slot) then
    # Print analysis result
    printf("\n%s %d\n", time, count)
    rank = create_arraylist(list_srcip)

    # Sort the arraylist by #1 element in the element of the arraylist
    puts("SRC IP by Num of Access")
    tmp = sort_arraylist(rank, 1, 20, false)
    tmp.each do |e|
      p e
    end

    # Sort the arraylist by #1 element in the element of the arraylist
    puts("SRC IP by Type of Access")
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

