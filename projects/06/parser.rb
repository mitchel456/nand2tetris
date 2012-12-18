class Parser

  A_COMMAND = 0
  C_COMMAND = 1
  L_COMMAND = 2

  def initialize(filename)
    @file = File.new(filename)
    @command_no = 0
    @command = nil
  end

  def has_more_commands
    not @file.eof?
  end

  def advance
    line = @file.gets.gsub(/\/\/.*$/, '').strip
    if line.empty?
      advance 
    else 
      @command = line 
      # do not increment the command number for a loop variable declaration
      @command_no += 1 unless command_type == L_COMMAND
    end
  end

  def reset
    @file.rewind
    @command_no = 0
  end

  def current_line
    @command_no - 1
  end

  def command_type
    case @command
    when /^@.*/
      A_COMMAND
    when /^\(.*/
      L_COMMAND
    else
      C_COMMAND
    end
  end

  def symbol
    # the "symbol" is the part of the command after the @ or the (
    extract /^[@(](.*?)\)?$/
  end

  def dest
    dest = extract /^(.*?)=.*$/
    unless dest.nil? or Code::DEST_CODES.has_key?(dest)
      raise "Unknown destination code: '#{dest}'" 
    end
    dest
  end

  def comp
    comp = @command.sub(/^.*?=/, '')
    comp = comp.sub(/;\w*$/, '')
    unless Code::COMP_CODES.has_key?(comp)
      raise "Unknown compute code: '#{comp}'" 
    end
    comp
  end

  def jump
    jump = extract /^.*;(\w*)$/
    unless jump.nil? or Code::JUMP_CODES.has_key?(jump)
      raise "Unknown jump code: " + jump 
    end
    jump
  end

  private
  def extract(pattern)
    @command =~ pattern 
    $1
  end

end
