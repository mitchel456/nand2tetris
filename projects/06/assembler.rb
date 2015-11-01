require_relative 'parser'
require_relative 'code'
require_relative 'symbol_table'

class Assembler
  attr_reader :file, :parser, :symbol_table

  def initialize(infile_name, outfile_name = nil)
    @file = File.new(infile_name)
    @parser = Parser.new(@file)
    @symbol_table = SymbolTable.new
    @outfile_name = outfile_name
  end

  def parse_for_labels
    parser.parse do |command|
      if command.l_command?
        symbol_table.add_entry(command.symbol, parser.command_number)
      end
    end
  end

  def assemble
    parse_for_labels

    File.open(outfile_name, 'w') do |file|
      parser.parse do |command|
        if command.constant?
          file.puts(address_command(command.symbol))
        elsif command.symbol?
          symbol_table.add_entry(command.symbol) unless symbol_table.contains?(command.symbol)
          symbol_address = symbol_table.get_address(command.symbol)
          file.puts(address_command(symbol_address))
        elsif command.c_command?
          file.puts(compute_command(command.comp, command.dest, command.jump))
        end
      end
    end
  end

  private

  def outfile_name
    @outfile_name ||= File.join(File.dirname(infile_name), "#{File.basename(infile_name, '.asm')}.hack")
  end

  def address_command(address)
    "%016d" % address.to_i.to_s(2)
  end

  def compute_command(comp, dest, jump)
    "111#{Code.comp(comp)}#{Code.dest(dest)}#{Code.jump(jump)}"
  end
end
