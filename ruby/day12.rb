# typed: strict
# frozen_string_literal: true

require 'json'
require_relative './aoc'

extend T::Sig

sig { params(obj: Object, ignore_red: T::Boolean).returns(Integer) }
def sum_obj(obj, ignore_red: false)
  case obj
  when Integer
    obj
  when Array
    obj.sum { sum_obj(_1, ignore_red: ignore_red) }
  when Hash
    if ignore_red && obj.values.include?('red')
      0
    else
      obj.keys.sum { sum_obj(_1, ignore_red: ignore_red) } +
        obj.values.sum { sum_obj(_1, ignore_red: ignore_red) }
    end
  else
    0
  end
end

input = JSON.parse(AOC.get_input(12))
puts "Part 1: #{sum_obj(input)}"
puts "Part 2: #{sum_obj(input, ignore_red: true)}"
