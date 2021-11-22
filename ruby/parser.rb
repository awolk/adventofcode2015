# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'

module P
  extend T::Sig

  class ParserError < StandardError; end

  class Parser
    extend T::Sig

    sig { params(blk: T.proc.params(i: String).returns([T.untyped, String])).void }
    def initialize(&blk)
      @blk = blk
    end

    sig { params(i: String).returns([T.untyped, String]) }
    def parse(i)
      @blk.call(i)
    end

    sig { params(blk: T.proc.params(_1: T.untyped).returns(T.untyped)).returns(Parser) }
    def map(&blk)
      Parser.new do |i|
        res, rest = parse(i)
        [blk.call(res), rest]
      end
    end

    # Parse self or other
    sig { params(other: Parser).returns(Parser) }
    def |(other)
      Parser.new do |i|
        parse(i)
      rescue ParserError
        other.parse(i)
      end
    end

    # Parse self then other, returning both results
    sig { params(other: Parser).returns(Parser) }
    def &(other)
      P.seq(self, other)
    end

    # Parse self then other, dropping result from self
    sig { params(other: Parser).returns(Parser) }
    def >>(other)
      (self & other).map(&:last)
    end

    # Parse self then other, dropping result from other
    sig { params(other: Parser).returns(Parser) }
    def <<(other)
      (self & other).map(&:first)
    end

    # Parse self repeated 0 or more times
    sig { returns(Parser) }
    def repeated
      Parser.new do |i|
        results = []
        rest = i
        loop do
          res, rest = parse(rest)
          results << res
        rescue ParserError
          break
        end
        [results, rest]
      end
    end

    # Parse self delimited by delimiter
    sig { params(delimiter: Parser).returns(Parser) }
    def delimited(delimiter)
      (self & (delimiter >> self).repeated)
        .map { |hd, tl| [hd] + tl }
        .optional
    end

    # Parse self on each line of input
    sig { returns(Parser) }
    def each_line
      delimited(P.str("\n"))
    end

    # Parse self or nothing
    sig { returns(Parser) }
    def optional
      Parser.new do |i|
        parse(i)
      rescue ParserError
        [nil, i]
      end
    end

    sig { params(i: String).returns(T.untyped) }
    def parse_all(i)
      res, rest = parse(i)
      raise ParserError, 'Expected complete parsing' unless rest.empty?

      res
    end
  end

  sig { params(s: String).returns(Parser) }
  def self.str(s)
    Parser.new do |i|
      raise ParserError, "Expected '#{s}'" unless i.start_with?(s)

      [s, T.must(i[s.length..])]
    end
  end

  sig { params(r: Regexp).returns(Parser) }
  def self.regexp(r)
    r = /\A#{r}/
    Parser.new do |i|
      raise ParserError, "Expected regular expression /#{r}/" unless (m = r.match(i))

      [T.must(m[0]), m.post_match]
    end
  end

  sig { returns(Parser) }
  def self.int
    regexp(/-?\d+/).map(&:to_i)
  end

  sig { returns(Parser) }
  def self.word
    regexp(/\w+/)
  end

  # Sequence of parsers in order. Drops raw string results
  sig { params(parsers: T.any(Parser, String)).returns(Parser) }
  def self.seq(*parsers)
    Parser.new do |i|
      results = []
      rest = i
      parsers.each do |p|
        if p.is_a?(String)
          _, rest = str(p).parse(rest)
        else
          res, rest = p.parse(rest)
          results << res
        end
      end
      [results, rest]
    end
  end
end
