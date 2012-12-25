class Parser

	C_ARITHMETIC = 0
	C_PUSH = 1
	C_POP = 2
	C_LABEL = 3
	C_GOTO = 4
	C_IF = 5
	C_FUNCTION = 6
	C_RETURN = 7
	C_CALL = 8
	C_UNKNOWN = 9

	def initialize(file)
		@file = file
	end

	def has_more_commands?
		not @file.eof?
	end

	def advance
		# a command is between one and three words at the start of a line
		line = @file.gets[/^([\w\-\.]+\s*){1,3}/]
		if line.nil?
			advance
		else
			@command = line.rstrip
		end
	end

	def command_type
		case @command
		when /^return/
			return C_RETURN
		when /^[\w-]+$/ # only arithmetic commands are one word only
			return C_ARITHMETIC
		when /^push/
			return C_PUSH
		when /^pop/
			return C_POP
		when /^label/
			return C_LABEL
		when /^goto/
			return C_GOTO
		when /^if-goto/
			return C_IF
		when /^function/
			return C_FUNCTION
		when /^call/
			return C_CALL
		else
			return C_UNKNOWN
		end
	end

	def arg1
		if command_type == C_ARITHMETIC
			# arithmetic commands are their own argument
			return @command
		else
			# any non-arithmetic command, the second word is the first arg
			# i.e. "push local 1", "local" is the first arg
			return @command[/^[\w\-\.]+ (\w+)/, 1]
		end
	end

	def arg2
		# the second arg is the third word
		# i.e. "push local 1", "1" is the second arg
		return @command[/^[\w\-\.]+ [\w\-\.]+ (\w+)/, 1]
	end
end