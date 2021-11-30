# typed: strict
# frozen_string_literal: true

require 'prime'
require_relative './aoc'

extend T::Sig

sig { params(n: Integer).returns(T::Array[Integer]) }
def factors(n)
  factors = [1]
  Prime.prime_division(n).each do |prime, exponent|
    new_factors = factors.flat_map do |factor|
      (1..exponent).map do |e|
        factor * (prime**e)
      end
    end
    factors.concat(new_factors)
  end
  factors
end

input = AOC.get_input(20).to_i

pt1 = T.let(nil, T.nilable(Integer))
pt2 = T.let(nil, T.nilable(Integer))
(1..).each do |n|
  break if !pt1.nil? && !pt2.nil?

  f = factors(n)
  if pt1.nil?
    num_presents_pt1 = f.sum * 10
    pt1 = n if num_presents_pt1 >= input
  end
  if pt2.nil?
    num_presents_pt2 = f.select { _1 * 50 >= n }.sum * 11
    pt2 = n if num_presents_pt2 >= input
  end
end

puts "Part 1: #{pt1}"
puts "Part 2: #{pt2}"
