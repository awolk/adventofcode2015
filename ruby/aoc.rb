# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'

# Helper methods for Advent of Code solutions
module AOC
  extend T::Sig

  sig { params(day: Integer).returns(String) }
  def self.get_input(day)
    File.read(File.expand_path("../input/day#{day}.txt", __dir__))
  end
end
