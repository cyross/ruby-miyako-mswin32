#calc3

total = 0
total255 = 0
(0..255).each{|r1|
  (0..255).each{|r2|
    (0..255).each{|a|
      a1 = a + 1
      a2 = 256 - a
      r = (r1 * a1 + r2 * a2) >> 8
      total += 1 if r > 255
      total255 += 1 if r == 255
    }
  }
}
puts "total : #{total} total255 : #{total255}"