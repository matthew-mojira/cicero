def split_pairs(lines)
  lines.each_slice(2).to_a
end

def extract_preamble(lines)
  preamble = []
  if lines.first == "=="
    lines.shift
    while lines.first != "==" && !lines.empty?
      preamble << lines.shift
    end
    lines.shift if lines.first == "=="
  end
  preamble.join("\n")
end

def process_file(file_path)
  lines = File.readlines(file_path).map(&:rstrip)
  preamble = extract_preamble(lines)
  pairs = split_pairs(lines.reject { |line| line == "--" })

  pairs.each_with_index do |(co, expect), i|
    File.write("#{file_path}#{i}.co", preamble + "\n" + co + "\n")
    File.write("#{file_path}#{i}.expect", expect + "\n")
  end
end

if ARGV.length != 1
  puts "Usage: ruby program.rb <file>"
else
  process_file(ARGV[0])
end
