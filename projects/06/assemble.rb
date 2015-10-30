require_relative 'assembler'

assembler = Assembler.new(ARGV[0], ARGV[1])
assembler.assemble
