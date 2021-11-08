# typed: strict
# frozen_string_literal: true

require 'digest'
require_relative './aoc'

secret = AOC.get_input(4)
base_digest = Digest::MD5.new.update(secret)

part_1_found = T.let(false, T::Boolean)
part_2_found = T.let(false, T::Boolean)

(1..).each do |i|
  hash = base_digest.clone.update(i.to_s).hexdigest
  if !part_1_found && hash.start_with?('00000')
    puts "Part 1: #{i}"
    part_1_found = true
  end
  if !part_2_found && hash.start_with?('000000')
    puts "Part 2: #{i}"
    part_2_found = true
  end
  break if part_1_found && part_2_found
end
