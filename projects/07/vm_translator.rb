require_relative 'parser'
require_relative 'code_writer'

vm_file = ARGV[0]
root_name = File.basename(vm_file, '.vm')
product_dir = File.directory?(vm_file) ? vm_file : File.dirname(vm_file)
code_writer = CodeWriter.new(File.open(product_dir + '/' + root_name + '.asm', 'w'))

def parse(file, code_writer)
	parser = Parser.new(File.new(file))
	code_writer.set_file_name(File.basename(file, '.vm'))
	while parser.has_more_commands? do
		parser.advance
		case parser.command_type
		when Parser::C_ARITHMETIC
			code_writer.write_arithmetic(parser.arg1)
		when Parser::C_PUSH
			code_writer.write_push_pop('push', parser.arg1, parser.arg2)
		when Parser::C_POP
			code_writer.write_push_pop('pop', parser.arg1, parser.arg2)
		when Parser::C_LABEL
			code_writer.write_label(parser.arg1)
		when Parser::C_GOTO
			code_writer.write_goto(parser.arg1)
		when Parser::C_IF
			code_writer.write_if(parser.arg1)
		when Parser::C_FUNCTION
			code_writer.write_function(parser.arg1, parser.arg2)
		when Parser::C_CALL
			code_writer.write_call(parser.arg1, parser.arg2)
		when Parser::C_RETURN
			code_writer.write_return
		else
			raise "Unknown command: " + parser.command_type
		end
	end
end

if File.file?(vm_file)
	parse vm_file, code_writer
elsif File.directory?(vm_file)
	code_writer.write_init
	vm_files = Dir.entries(vm_file).select {|file| file =~ /\.vm$/}
	vm_files.each do |file|
		parse vm_file + '/' + file, code_writer
	end
end

