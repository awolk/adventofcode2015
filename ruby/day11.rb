# typed: strict
# frozen_string_literal: true

require_relative './aoc'

extend T::Sig

STRAIGHTS_RE = T.let(Regexp.new(('a'..'x').map { |c| "#{c}#{c.next}#{c.next.next}" }.join('|')), Regexp)
DOUBLES_RE = T.let(Regexp.new(('a'..'z').map { |c| c * 2 }.join('|')), Regexp)

sig { params(password: String).returns(T::Boolean) }
def valid_password?(password)
  return false if password.match?(/[iol]/)

  return false unless STRAIGHTS_RE.match?(password)

  doubles = password.scan(DOUBLES_RE).uniq
  doubles.length >= 2
end

sig { params(password: String).returns(String) }
def next_valid_password(password)
  loop do
    password = password.next
    return password if valid_password?(password)
  end
end

input = AOC.get_input(11)
p1 = next_valid_password(input)
p2 = next_valid_password(p1)
puts "Part 1: #{p1}"
puts "Part 2: #{p2}"
