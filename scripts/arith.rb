if ARGV.length != 6
  puts "args: CONST_PROB, MIN_NUM, MAX_NUM, FORCE_DEPTH, MAX_RECURSION, NUM_CASES"
  exit 1
end

class Integer
  def / other
    if (self < 0) ^ (other < 0) and div other != 0 then
      div other + 1
    else
      div other
    end
  end
end

def rand_op
  [:+, :-, :*, :+, :-, :*, :+, :-, :*, :/].sample
end

CONST_PROB    = ARGV[0].to_f
MIN_NUM       = ARGV[1].to_i
MAX_NUM       = ARGV[2].to_i
FORCE_DEPTH   = ARGV[3].to_i
MAX_RECURSION = ARGV[4].to_i
NUM_CASES     = ARGV[5].to_i

def rand_arith(rec=0)
  if rec > FORCE_DEPTH and (rand < CONST_PROB or rec > MAX_RECURSION) then
    { :op => :const, :value => rand(MAX_NUM - MIN_NUM) + MIN_NUM }
  else
    { :op => rand_op, :left => rand_arith(rec + 1), :right => rand_arith(rec + 1) }
  end
end

def interp_arith arith
  case arith[:op]
  when :const
    arith[:value]
  else
    left  = interp_arith arith[:left]
    right = interp_arith arith[:right]
    left.send arith[:op], right
  end
end

def str_arith arith
  case arith[:op]
  when :const
    arith[:value].to_s
  else
    left  = str_arith arith[:left]
    right = str_arith arith[:right]
    "(#{arith[:op]} #{left} #{right})"
  end
end

def make_case
  loop do
    arith = rand_arith
    begin
      val = interp_arith(arith)
      return arith, val
    rescue
      # continue
    end
  end
end

puts "; Arithmetic Tests generated using settings:"
puts "; CONST_PROB    #{CONST_PROB}"
puts "; MIN_NUM       #{MIN_NUM}"
puts "; MAX_NUM       #{MAX_NUM}"
puts "; FORCE_DEPTH   #{FORCE_DEPTH}"
puts "; MAX_RECURSION #{MAX_RECURSION}"
puts "; NUM_CASES     #{NUM_CASES}"
puts "=="
NUM_CASES.times do
  c = make_case
  puts str_arith(c[0])
  puts "--"
  puts "=> #{c[1]}"
  puts "--"
end
