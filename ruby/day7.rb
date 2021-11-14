# typed: strict
# frozen_string_literal: true

require_relative './aoc'

extend T::Sig

Input = T.type_alias { T.any(Integer, String) }

class And < T::Struct
  const :l, Input
  const :r, Input
end

class Or < T::Struct
  const :l, Input
  const :r, Input
end

class Rshift < T::Struct
  const :i, Input
  const :a, Integer
end

class Lshift < T::Struct
  const :i, Input
  const :a, Integer
end

class Not < T::Struct
  const :i, Input
end

Expr = T.type_alias do
  T.any(
    Input,
    And,
    Or,
    Lshift,
    Rshift,
    Not
  )
end

sig { params(input: String).returns(Input) }
def parse_input(input)
  case input
  when /\A\d+\z/
    input.to_i
  when /\A[a-z]+\z/
    input
  else
    raise "Invalid input: #{input}" # should be unreachable
  end
end

INPUT_RE = T.let(/([a-z]+|[0-9]+)/, Regexp)

sig { params(expr: String).returns(Expr) }
def parse_expr(expr)
  if (c = /\A#{INPUT_RE} AND #{INPUT_RE}\z/.match(expr)&.captures)
    And.new(l: parse_input(c.fetch(0)), r: parse_input(c.fetch(1)))
  elsif (c = /\A#{INPUT_RE} OR #{INPUT_RE}\z/.match(expr)&.captures)
    Or.new(l: parse_input(c.fetch(0)), r: parse_input(c.fetch(1)))
  elsif (c = /\A#{INPUT_RE} LSHIFT ([0-9]+)\z/.match(expr)&.captures)
    Lshift.new(i: parse_input(c.fetch(0)), a: c.fetch(1).to_i)
  elsif (c = /\A#{INPUT_RE} RSHIFT ([0-9]+)\z/.match(expr)&.captures)
    Rshift.new(i: parse_input(c.fetch(0)), a: c.fetch(1).to_i)
  elsif (c = /\ANOT #{INPUT_RE}\z/.match(expr)&.captures)
    Not.new(i: parse_input(c.fetch(0)))
  elsif (c = /\A#{INPUT_RE}\z/.match(expr)&.captures)
    parse_input(c.fetch(0))
  else
    raise "Invalid line: #{expr}"
  end
end

wiring = T.let({}, T::Hash[String, Expr])

AOC.get_input(7).split("\n").each do |line|
  expr, target = T.must(/\A(.+) -> ([a-z]+)\z/.match(line)).captures

  wiring[T.must(target)] = parse_expr(T.must(expr))
end

class Circuit
  extend T::Sig

  sig { params(wiring: T::Hash[String, Expr]).void }
  def initialize(wiring)
    @wiring = wiring
    @cached = T.let({}, T::Hash[String, Integer])
  end

  sig { params(target: String).returns(Integer) }
  def get(target)
    if (res = @cached[target])
      return res
    end

    expr = @wiring.fetch(target)
    res =
      case expr
      when Integer
        expr
      when String
        get(expr)
      when And
        eval_input(expr.l) & eval_input(expr.r)
      when Or
        eval_input(expr.l) | eval_input(expr.r)
      when Lshift
        eval_input(expr.i) << expr.a
      when Rshift
        eval_input(expr.i) >> expr.a
      when Not
        ~eval_input(expr.i)
      else
        T.absurd(expr)
      end

    @cached[target] = res
  end

  private

  sig { params(input: Input).returns(Integer) }
  def eval_input(input)
    case input
    when String
      get(input)
    when Integer
      input
    else
      T.absurd(input)
    end
  end
end

signal_a = Circuit.new(wiring).get('a')

puts "Part 1: #{signal_a}"

new_wiring = wiring.merge('b' => signal_a)
new_signal_a = Circuit.new(new_wiring).get('a')
puts "Part 2: #{new_signal_a}"
