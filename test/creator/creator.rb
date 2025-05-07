if ARGV.length < 1
  puts "Usage: ruby creator.rb <file>"
else
  for file_path in ARGV do
    mode = :preamble
    i = 0
    preamble = []
    test = []
    preamble_expect = []
    expect = []
    File.readlines(file_path).each do |line|
      case mode
      when :preamble
        if line == "==\n" then
          mode = :test
        elsif line == "--\n" then
          mode = :preamble_expect
        else
          preamble << line
        end
      when :preamble_expect
        if line == "==\n" then
          mode = :test
        else
          preamble_expect << line
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
          File.write("#{file_path}#{i.to_s.rjust(2, '0')}.co", (preamble + test).join)
          File.write("#{file_path}#{i.to_s.rjust(2, '0')}.expect", (preamble_expect + expect).join)
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
