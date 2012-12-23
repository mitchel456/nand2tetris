class CodeWriter

	def initialize(file)
		@file = file
		@jump_no = 0
	end

	def set_file_name(vm_filename)
		@current_vm_file = vm_filename
	end

	def write_arithmetic(command)
		case command
		when 'add'
			write(['@SP', 'A=M-1', 'D=M', 'A=A-1', 'M=M+D', 'D=A', '@SP', 'M=D+1'])
		when 'sub'
			write(['@SP', 'A=M-1', 'D=M', 'A=A-1', 'M=M-D', 'D=A', '@SP', 'M=D+1'])
		when 'neg'
			write(['@SP', 'A=M-1', 'M=-M', 'D=A', '@SP', 'M=D+1'])
		when 'eq'
			write_comparison 'JEQ'
		when 'gt'
			write_comparison 'JGT'
		when 'lt'
			write_comparison 'JLT'
		when 'and'
			write(['@SP', 'A=M-1', 'D=M', 'A=A-1', 'M=D&M', 'D=A', '@SP', 'M=D+1'])
		when 'or'
			write(['@SP', 'A=M-1', 'D=M', 'A=A-1', 'M=D|M', 'D=A', '@SP', 'M=D+1'])
		when 'not'
			write(['@SP', 'A=M-1', 'M=!M', 'D=A', '@SP', 'M=D+1'])
		end
	end

	def write_push_pop(command, segment, index)
		if (command == 'push')
			case segment
			when 'local'
				write_push 'LCL', index
			when 'argument'
				write_push 'ARG', index
			when 'this'
				write_push 'THIS', index
			when 'that'
				write_push 'THAT', index
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
				write_pop 'LCL', index
			when 'argument'
				write_pop 'ARG', index
			when 'this'
				write_pop 'THIS', index
			when 'that'
				write_pop 'THAT', index
			when 'pointer'
				write_pop 'POINTER', index
			when 'temp'
				write_pop 'TEMP', index
			when 'static'
				write(['@SP', 'A=M-1', 'D=M', "@#{@current_vm_file}.#{index}", 'M=D', '@SP', 'M=M-1'])
			end
		end

	end

	private
	def write(commands)
		commands.each do |command|
			@file.puts(command)
		end
	end

	private
	def write_push(segment, index)
		write(["@#{segment}", 'D=M', "@#{index}", 'A=D+A', 'D=M', '@SP', 'A=M', 'M=D', '@SP', 'M=M+1'])
	end

	private
	def write_pop(segment, index)
		# pointer and temp both pop into the actual register, while the rest of the segments
		# are pointed to by their registers
		if segment == 'POINTER'
			write(['@THIS', 'D=A'])
		elsif segment == 'TEMP'
			write(['@R5', 'D=A'])
		else
			write(["@#{segment}", 'D=M'])
		end
		write(["@#{index}", 'D=D+A', '@R5', 'M=D', '@SP', 'A=M-1', 'D=M', '@R5', 'A=M', 'M=D', '@SP', 'M=M-1'])
	end

	private
	def write_comparison(jump_op)
		write([
			'@SP', 
			'A=M-1', 
			'D=M', 
			'A=A-1', 
			'D=M-D', 
			"@comparison_true.#{@jump_no}", 
			"D;#{jump_op}", 
			'D=0', 
			"@comparison_done.#{@jump_no}", 
			'0;JMP', 
			"(comparison_true.#{@jump_no})",
			'D=-1',
			"(comparison_done.#{@jump_no})",
			'@SP',
			'M=M-1',
			'M=M-1',
			'A=M',
			'M=D',
			'@SP',
			'M=M+1'
		])
		@jump_no += 1
	end
end