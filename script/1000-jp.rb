#! ruby -EUTF-8
# encoding: utf-8

require 'pp'

hiragana = ("ぁ".."ゖ").to_a + ("゛".."ゟ").to_a
katakana = ("ァ".."ヺ").to_a + ("・".."ヿ").to_a

p hiragana
p katakana

dir = "../data/Kanji/"

fns = [
 "Thousand_Character_Classic.dat",
 "Regular_Current.dat",
 "Regular_Traditional.dat",
 "Name_Current.dat",
 "Name_Traditional.dat"
]

Kanji = Hash.new

fns.each do |fn|
	path = dir + fn
	name = fn.sub(".dat", "").split("_").map{|i| i[0]}.join.to_sym
	Kanji[name] = File.read(path).chomp.split("")
end

Kanji.each do |i, j|
	puts i.to_s + " " + j.size.to_s
end

p (Kanji[:TCC] & (Kanji[:RC] | Kanji[:NC])).size
