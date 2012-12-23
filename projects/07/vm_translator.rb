require_relative 'parser'
require_relative 'code_writer'

vm_file = ARGV[0]
root_name = File.basename(vm_file, '.vm')

if File.file?(vm_file)
	parser = Parser.new(File.new(vm_file))
end

code_writer = CodeWriter.new(File.open(File.dirname(vm_file) + '/' + root_name + '.asm', 'w'))
code_writer.set_file_name(root_name)

while parser.has_more_commands? do
	parser.advance
	case parser.command_type
	when Parser::C_ARITHMETIC
		code_writer.write_arithmetic(parser.arg1)
	when Parser::C_PUSH
		code_writer.write_push_pop('push', parser.arg1, parser.arg2)
	when Parser::C_POP
		code_writer.write_push_pop('pop', parser.arg1, parser.arg2)
	end
end