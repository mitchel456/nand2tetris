class CodeWriter

	def initialize(file)
		@file = file
	end

	def set_file_name(vm_filename)
		@current_vm_file = vm_filename
	end

	def write_arithmetic(command)
		case command
		when 'add'
			write_add
		else
			raise "Unknown arithmetic command"
		end
	end

	def write_push_pop(command, segment, index)
		if (command == 'push')
			case segment
			when 'local'
				write(['@LCL', 'D=M', "@#{index}", 'A=D+A', 'D=M', '@SP', 'A=M', 'M=D', '@SP', 'M=M+1'])
			when 'argument'
				write(['@ARG', 'D=M', "@#{index}", 'A=D+A', 'D=M', '@SP', 'A=M', 'M=D', '@SP', 'M=M+1'])
			when 'this'
				write(['@THIS', 'D=M', "@#{index}", 'A=D+A', 'D=M', '@SP', 'A=M', 'M=D', '@SP', 'M=M+1'])
			when 'that'
				write(['@THAT', 'D=M', "@#{index}", 'A=D+A', 'D=M', '@SP', 'A=M', 'M=D', '@SP', 'M=M+1'])
			when 'pointer'
				write(['@THIS', 'D=A', "@#{index}", 'A=D+A', 'D=M', '@SP', 'A=M', 'M=D', '@SP', 'M=M+1'])
			when 'temp'
				write(['@R5', 'D=A', "@#{index}", 'A=D+A', 'D=M', '@SP', 'A=M', 'M=D', '@SP', 'M=M+1'])
			when 'constant'
				write(["@#{index}", 'D=A', '@SP', 'A=M', 'M=D', '@SP', 'M=M+1'])
			when 'static'
				write(["@#{@current_vm_file}.#{index}", 'D=M', '@SP', 'A=M', 'M=D', '@SP', 'M=M+1'])
			end
		elsif (command == 'pop')
			case segment
			when 'local'
				write(['@LCL', 'D=M', "@#{index}", 'D=D+A', '@R5', 'M=D', '@SP', 'A=M', 'M=M-1', 'D=M', '@R5', 'A=M', 'M=D n'])
				#write(['@SP', 'A=M', 'M=M-1', 'D=M', '@LCL', 'A=M', ]
			end
		end

	end

	private
	def symbol_for_segment(segment)
		case segment
		when 'local'
			'LCL'
		when 'argument'
			'ARG'
		when 'this'
			'THIS'
		when 'that'
			'THAT'
		else
			raise "Unknown segment"
		end
	end

	private
	def write_add
		write(['@SP', 'A=M-1', 'D=M', 'A=A-1', 'M=M+D', 'D=A', '@SP', 'M=D+1'])
	end

	private
	def write(commands)
		commands.each do |command|
			@file.puts(command)
		end
	end
end