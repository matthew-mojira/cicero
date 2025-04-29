RANGE = 500

if ARGV.length == 1
  nums = ARGV[0].to_i

  print "["
  nums.times do |i|
    print rand(RANGE)
    print " " if i != nums - 1
  end
  print "]"
  exit 0
else
  exit 1
end
