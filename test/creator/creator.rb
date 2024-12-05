def split_pairs(lines)
  lines.each_slice(2).to_a
end

def process_file(file_path)
  lines = File.readlines(file_path).map(&:strip)
  pairs = split_pairs(lines.reject { |line| line == "--" })

  pairs.each_with_index do |(co, expect), i|
    File.write("../#{file_path}#{i}.co", co + "\n")
    File.write("../expect/#{file_path}#{i}.expect", expect + "\n")
  end
end

if ARGV.length != 1
  puts "Usage: ruby program.rb <file>"
else
  process_file(ARGV[0])
end
