# typed: strict
# frozen_string_literal: true

require_relative './aoc'

extend T::Sig

input = T.let(AOC.get_input(10).chars.map(&:to_i), T.untyped)

sig { params(seq: T::Array[Integer]).returns(T::Array[Integer]) }
def step(seq)
  seq.chunk { _1 }.flat_map { |n, ns| [ns.length, n] }
end

# Part 1
res = input
40.times { res = step(res) }
puts "Part 1: #{res.length}"

# Part 2
10.times { res = step(res) }
puts "Part 2: #{res.length}"
