#!/usr/bin/env ruby

require 'erb'

def magic(magicv, magicm, magicM, magicV)
  return magicv if $magic == :very_magic
  return magicm if $magic == :magic
  return magicM if $magic == :non_magic
  return magicV if $magic == :very_non_magic
end

input = File.new(ARGV[0], "r")
template = ERB.new(input.read)

[:very_magic, :magic, :non_magic, :very_non_magic].each do | m |
  puts 'Processing "' + m.to_s() + '"...'
  $magic = m
  output = File.new(File.join(File.dirname(input.path), 'parser_' + $magic.to_s + '.vimpeg') , "w")
  output.write(template.result())
  output.close
  `vim -c 'VimPEG!' -e -c 'q!' #{output.path}`
end
