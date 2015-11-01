require_relative 'command'

class Parser
  attr_reader :current_command, :command_number

  def initialize(file)
    @file = file
    @command_number = 0
  end

  def parse
    reset
    while has_more_commands?
      advance
      @command_number += 1 unless current_command.l_command?
      yield @current_command
    end
  end

  def has_more_commands?
    !@file.eof?
  end

  def advance
    next_command = Command.new(@file.gets)
    if next_command.comment? || next_command.empty?
      advance
    else
      @current_command = next_command
    end
  end

  def reset
    @file.rewind
    @command_number = 0
  end
end
