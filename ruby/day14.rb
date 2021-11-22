# typed: strict
# frozen_string_literal: true

require_relative './aoc'
require_relative './parser'

class Reindeer
  extend T::Sig

  sig { returns(Integer) }
  attr_reader :pos

  sig { params(name: String, speed: Integer, speed_time: Integer, rest_time: Integer).void }
  def initialize(name:, speed:, speed_time:, rest_time:)
    @name = name
    @speed = speed
    @speed_time = speed_time
    @rest_time = rest_time

    @pos = T.let(0, Integer)
    @resting = T.let(false, T::Boolean)
    @time_left = speed_time
  end

  sig { params(line: String).returns(Reindeer) }
  def self.from_line(line)
    P.seq(P.word, ' can fly ', P.int, ' km/s for ', P.int,
          ' seconds, but then must rest for ', P.int, ' seconds.')
     .map {new(name: _1, speed: _2, speed_time: _3, rest_time: _4)}
     .parse_all(line)
  end

  sig { void }
  def advance_second!
    if @time_left.zero?
      @resting = !@resting
      @time_left = @resting ? @rest_time : @speed_time
    end

    @time_left -= 1
    @pos += @speed unless @resting
  end
end

input = AOC.get_input(14)
reindeer = input.split("\n").map { Reindeer.from_line(_1) }

scores = T.let({}, T::Hash[Reindeer, Integer])

2503.times do
  reindeer.each(&:advance_second!)
  max_pos = reindeer.map(&:pos).max
  reindeer.select { _1.pos == max_pos }.each do |lead_reindeer|
    scores[lead_reindeer] = scores.fetch(lead_reindeer, 0) + 1
  end
end

puts "Part 1: #{reindeer.map(&:pos).max}"
puts "Part 2: #{scores.values.max}"
