def parse_tcpdump(line)
  data = line.split(" ")

  # Check input data validation, null -> skip
  if (line == nil) then
    return (nil)
  end
  if (data == []) then
    return (nil)
  end

  time = data[0]
  proto0 = data[1]
  proto1 = data[5]
  src = data[2]
  dst = data[4]
  size = data[-1] 

  if (proto1 == "ICMP") then
    # IPv4
       src_ip = src
       src_port = nil
       dst_ip = dst
       dst_port = nil
  else
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
  end
 
#  p line
#  p [time, proto0, src_ip, src_port, dst_ip, dst_port, size]
  return ([time, proto0, src_ip, src_port, proto1, dst_ip, dst_port, size])
end

def create_arraylist(list_src)
  ranking = Array.new

  list_src.each_key do |key|
    ranking.push([key, list_src[key].size, list_src[key].uniq.size])
  end

  return (ranking)
end

def sort_arraylist(ranking, row_num, limit=10, order=true)

  if (order == true) then
    result = ranking.sort do |x, y|
      x[row_num] <=> y[row_num]
    end
  else
    result = ranking.sort do |x, y|
      y[row_num] <=> x[row_num]
    end
  end
  
  return (result[0,limit])
end

