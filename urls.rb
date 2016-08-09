#
#
# Usage:
#   ssh 192.168.100.199 "sudo tcpdump -n -i eth1 -X" | ruby urls.rb 
#

def parse_tcpdump(line)
  # Check input data validation, null -> skip
  return (nil) if (line == nil)

  data = line.split(" ")
  return nil if (data == [])

  src = data[2]
  dst = data[4]
  size = (line.index("length") != nil ? data[-1] : 0)

  tmp1 = src.split(".")
  tmp2 = dst.split(".")
  if (data[1] == "IP") then
  # IPv4
     src_ip = tmp1[0,4].join(".")
     dst_ip = tmp2[0,4].join(".")
     if (data[5] == "VRRPv2," or
         data[5] == "OSPFv2," or
         data[5] == "igmp" or
         data[5] == "ICMP"
       ) then
       src_port = 0
       dst_port = 0
     else
       src_port = tmp1[4].to_i
       dst_port = tmp2[4].to_i
     end
  elsif (data[1] == "IP6")
  # IPv6
     src_ip = tmp1[0]
     dst_ip = tmp2[0]
     if (data[5] == "ICMP6," or data[5] == "HBH") then
       src_port = 0
       dst_port = 0
     else
       src_port = tmp1[1].to_i
       dst_port = tmp2[1].to_i
     end
  end

  result = Hash.new
  result["src_ip"] = src_ip
  result["src_port"] = src_port
  result["dst_ip"] = dst_ip
  result["dst_port"] = dst_port
  result["size"] = size

  return (result)
end

line = ""
while (line != nil) do
  line = STDIN.gets

  if (line =~ /^[0-9]{9}/) then
    h = parse_tcpdump(line)
    line0 = line

    # reading following lines (packet contents in ASCII)
    begin
      line = STDIN.gets
      pattern = line.index("GET")
      if (pattern != nil) then
        path = line[pattern..-1].split(" ")[1]
        line = STDIN.gets
        host = line.split(" ")[1].strip
        printf("%s %s %s %s %s%s\n",
          h["src_ip"], h["src_port"], h["dst_ip"], h["dst_port"], host, path)
      end

      if (line.index("Content-Length:") != nil) then
        p line
        line.split(" ")[1]
      end
    end while (not line =~ /^[0-9]{9}/) 
  end
  
end

