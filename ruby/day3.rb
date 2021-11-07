# typed: strict
# frozen_string_literal: true

require 'matrix'
require 'set'
require_relative './aoc'

deltas = {
  '<' => Vector[-1, 0],
  '>' => Vector[1, 0],
  '^' => Vector[0, 1],
  'v' => Vector[0, -1]
}

input = AOC.get_input(3)

# Part 1
pos = Vector[0, 0]
houses = Set[pos]
input.each_char do |c|
  pos += deltas.fetch(c)
  houses << pos
end

puts "Part 1: #{houses.length}"

# Part 2
p1 = Vector[0, 0]
p2 = Vector[0, 0]
houses = Set[p1]
input.chars.each_slice(2) do |c1, c2|
  p1 += deltas.fetch(c1)
  houses << p1

  if !c2.nil?
    p2 += deltas.fetch(c2)
    houses << p2
  end
end

puts "Part 2: #{houses.length}"
