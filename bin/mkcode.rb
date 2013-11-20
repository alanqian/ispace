#!/usr/bin/env ruby

require 'hanzi_to_pinyin'

file = "/home/alan/tmp/region.txt"

dict = {} # id -> name
rdict = {} # name -> id

f = File.new(file, "r")
while (s = f.gets)
  s.chomp!
  if rdict.has_key?(s)
    code = rdict[s]
  else
    pinyin = HanziToPinyin.hanzi_to_pinyin(s)
    while (dict.has_key?(pinyin))
      pinyin += "_"
    end
    code = pinyin
    rdict[s] = pinyin
    dict[pinyin] = s
  end
  puts "#{s}\t#{code}"
end
