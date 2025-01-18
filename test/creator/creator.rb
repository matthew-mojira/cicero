if ARGV.length < 1
  puts "Usage: ruby program.rb <file>"
else
  for file_path in ARGV do
    mode = :preamble
    i = 0
    preamble = []
    test = []
    expect = []
    File.readlines(file_path).each do |line|
      case mode
      when :preamble
        if line == "==\n" then
          mode = :test
        else
          preamble << line
        end
      when :test
        if line == "--\n" then
          mode = :expect
        else
          test << line
        end
      when :expect
        if line == "--\n" then
          mode = :test
          File.write("#{file_path}#{i}.co", (preamble + test).join)
          File.write("#{file_path}#{i}.expect", expect.join)
          test = []
          expect = []
          i += 1
        else
          expect << line
        end
      end
    end
  end
end
