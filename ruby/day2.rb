# typed: strict
# frozen_string_literal: true

require_relative './aoc'
extend T::Sig

# A cubic present
class Cube < T::Struct
  extend T::Sig
  const :l, Integer
  const :w, Integer
  const :h, Integer

  sig { returns(Integer) }
  def surface_area
    2 * ((l * w) + (w * h) + (h * l))
  end

  sig { returns(Integer) }
  def volume
    l * w * h
  end

  sig { returns([Integer, Integer]) }
  def smaller_side_lengths
    T.cast([l, w, h].sort.take(2), [Integer, Integer])
  end

  sig { returns(Integer) }
  def wrapping_paper
    surface_area + smaller_side_lengths.reduce(&:*)
  end

  sig { returns(Integer) }
  def bow_length
    a, b = smaller_side_lengths
    (a * 2) + (b * 2) + volume
  end
end

input = AOC.get_input(2)

cubes = input.split("\n").map do |line|
  l, w, h = T.cast(line.split('x').map(&:to_i), [Integer, Integer, Integer])
  Cube.new(l: l, w: w, h: h)
end

# Part 1
total_paper = cubes.sum(&:wrapping_paper)
puts "Part 1: #{total_paper} square feet"

# Part 2
total_bow_length = cubes.sum(&:bow_length)
puts "Part 2: #{total_bow_length} feet"
