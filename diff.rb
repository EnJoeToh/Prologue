#! ruby -EUTF-8
# encoding: utf-8

a = (1..12).to_a.map do |n|
	("00" + n.to_s)[-2..-1]
end


a.each do |n|
	system( "docdiff ./doc/ch_" + n + ".dat ./doc2/ch_" + n + ".dat > ./diff/ch_" + n + ".html") 
end

