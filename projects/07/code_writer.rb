class CodeWriter

	def initialize(file)
		@file = file
		@jump_no = 0
		@call_no = 0
	end

	def set_file_name(vm_filename)
		@current_vm_file = vm_filename
	end

	def start_function(function_name)
		@current_function_name = function_name
	end

	def end_function
		@current_function_name = nil
	end

	def write_init
		write(['@256', 'D=A', '@SP', 'M=D'])
		write_call 'Sys.init', '0'
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
				write_push_constant index
				#write(["@#{index}", 'D=A', '@SP', 'A=M', 'M=D', '@SP', 'M=M+1'])
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

	def write_label(label)
		write(["(#{function_scoped_label(label)})"])
	end

	def write_goto(location)
		write(["@#{function_scoped_label(location)}", '0;JMP'])
	end

	def write_if(location)
		write(['@SP', 'M=M-1', 'A=M', 'D=M', "@#{function_scoped_label(location)}", 'D;JNE'])
	end

	def write_call(function_name, num_arguments)
		return_label = 'return.' + @call_no.to_s
		@call_no += 1

		write_push_constant return_label
		write_push_pointer 'LCL'
		write_push_pointer 'ARG'
		write_push_pointer 'THIS'
		write_push_pointer 'THAT'

		# ARG = SP-n-5 (figure 8.5)
		write(['@5', 'D=A', '@' + num_arguments, 'D=D+A', '@SP', 'D=M-D', '@ARG', 'M=D'])

		# LCL = SP
		write(['@SP', 'D=M', '@LCL', 'M=D'])

		write_goto function_name
		write_label return_label
	end

	def write_function(function_name, num_locals)
		start_function function_name
		write_label function_name
		num_locals.to_i.times do
			write_push_pop('push', 'constant', 0)
		end
	end

	def write_return
		end_function
		# R6 = LCL (temporary pointer to frame)
		write(['@LCL', 'D=M', '@R6', 'M=D'])

		# R7 = *(FRAME-5) (hold return address in register temporarily
		write(['@5', 'A=D-A', 'D=M', '@R7', 'M=D'])

		write_pop 'ARG', 0

		# SP = ARG+1
		write(['@ARG', 'D=M', '@1', 'D=D+A', '@SP', 'M=D'])

		# THAT = *(FRAME-1)
		write(['@R6', 'D=M', '@1', 'A=D-A', 'D=M', '@THAT', 'M=D'])

		# THIS = *(FRAME-2)
		write(['@R6', 'D=M', '@2', 'A=D-A', 'D=M', '@THIS', 'M=D'])

		# ARG = *(FRAME-3)
		write(['@R6', 'D=M', '@3', 'A=D-A', 'D=M', '@ARG', 'M=D'])

		# LCL = *(FRAME-4)
		write(['@R6', 'D=M', '@4', 'A=D-A', 'D=M', '@LCL', 'M=D'])

		# goto R7
		write(['@R7', 'A=M', '0;JMP'])
	end

	private
	def function_scoped_label(label)
		if @function_name.nil?
			label
		else
			@function_name + '$' + label
		end
	end
	
	private
	def write_push_constant(constant)
		write(["@#{constant}", 'D=A', '@SP', 'A=M', 'M=D', '@SP', 'M=M+1'])
	end

	private
	def write_push_pointer(pointer)
		write(["@#{pointer}", 'D=M', '@SP', 'A=M', 'M=D', '@SP', 'M=M+1'])
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