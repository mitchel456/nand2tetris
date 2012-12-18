require '.\parser'
require '.\code'
require '.\symbol_table'

assembly_file = ARGV[0]
root_name = File.basename(assembly_file, '.asm')
parser = Parser.new(assembly_file)

def binary_string(decimal, bits)
  integer = decimal.to_i
  binary = integer.to_s(2)
  "%0#{bits}d" % binary
end

# first pass - build symbol table with labels
symbol_table = SymbolTable.new
while parser.has_more_commands
  parser.advance
  if (parser.command_type == Parser::L_COMMAND)
    symbol_table.add_entry(parser.symbol, parser.current_line + 1) 
  end
end

# second pass - replace symbols with addresses
next_ram_address = 16
machine_codes = []
parser.reset
while parser.has_more_commands

  parser.advance
  
  if (parser.command_type == Parser::A_COMMAND)

    if parser.symbol =~ /^\d+$/ # if the symbol is a constant
      machine_codes.push('0' + binary_string(parser.symbol, 15))
    else
      unless symbol_table.contains? parser.symbol
        symbol_table.add_entry(parser.symbol, next_ram_address)
        next_ram_address += 1 
      end
      machine_codes.push('0' + binary_string(symbol_table.get_address(parser.symbol), 15))
    end

  elsif (parser.command_type == Parser::C_COMMAND)
    machine_codes.push('111' + Code.comp(parser.comp) + Code.dest(parser.dest) + Code.jump(parser.jump))
   end
end

File.open(File.dirname(assembly_file) + '/' + root_name + '.hack', 'w') do |file|
  file.puts machine_codes
end
