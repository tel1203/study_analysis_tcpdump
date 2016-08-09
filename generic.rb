#
#
# Usage:
#   ssh 192.168.100.199 "sudo tcpdump -n -i eth1" | ruby urls.rb 
#

def parse_tcpdump(line)
  data = line.split(" ")

  # Check input data validation, null -> skip
  if (line == nil) then
    return (nil)
  end
  if (data == []) then
    return (nil)
  end

  src = data[2]
  dst = data[4]
  size = data[-1] 

  tmp1 = src.split(".")
  tmp2 = dst.split(".")
  if (tmp1.length == 5) then
  # IPv4
     src_ip = tmp1[0,4].join(".")
     src_port = tmp1[4]
     dst_ip = tmp2[0,4].join(".")
     dst_port = tmp2[4]
  else
  # IPv6
     src_ip = tmp1[0]
     src_port = tmp1[1]
     dst_ip = tmp2[0]
     dst_port = tmp2[1]
  end

  return ([src_ip, src_port, dst_ip, dst_port, size])
end

line = ""
count=0
protocols = Hash.new
while (line != nil) do
  line = STDIN.gets
  src_ip, src_port, dst_ip, dst_port, size = parse_tcpdump(line)
  if (src_ip == nil) then
    next
  end

  # To regulate targe traffic from KIC to server
  if (src_ip.index("172.16") == 0) then
#    p line
#    p src_ip
#    p src_port
#    protocols[dst_port] += 1
    if (protocols[dst_port] == nil) then
      protocols[dst_port] = Hash.new
      protocols[dst_port]["user"] = Array.new
      protocols[dst_port]["packet"] = 0
      protocols[dst_port]["size"] = 0
    end
    protocols[dst_port]["user"] |= [src_ip]
    protocols[dst_port]["packet"] += 1
    protocols[dst_port]["size"] += size.to_i

#p protocols
  end

  if (count%1000 == 0) then
    protocols.each_pair do |k,v|
      printf("%6s %5d %5d %5d\n", k, v["user"].size, v["packet"], v["size"])
    end
    puts()
  end

  count += 1
end

