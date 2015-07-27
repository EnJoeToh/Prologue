#! ruby -EUTF-8
# encoding: utf-8


body = Array.new
(1..12).each do |ch_num|
	num = sprintf("%02d", ch_num)
	fn = "ch_" + num + ".dat"
	body << {ch: ch_num, doc: File.read(fn)} 
end

body.each do |ch|
	puts ch[:doc]
	puts "\n"
end