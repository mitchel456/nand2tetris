class Parser

  attr_reader :current_line

  A_COMMAND = 0
  C_COMMAND = 1
  L_COMMAND = 2

  def initialize(filename)
    @lines = IO.readlines(filename)
    @current_line = 0
  end

  def has_more_commands
    true unless @current_line >= @lines.count
  end

  def advance
    @current_command = @lines[@current_line].gsub(/\/\/.*$/, '').strip
    @current_line += 1 
    # skip blank lines and comments
    advance if @current_command.empty? or @current_command.start_with? '//'
  end

  def reset
    @current_command = nil
    @current_line = 0
  end

  def command_type
    case @current_command
    when /^@.*/
      A_COMMAND
    when /^\(.*/
      L_COMMAND
    else
      C_COMMAND
    end
  end

  def symbol
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
    comp = @current_command.sub(/^.*?=/, '')
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
    @current_command =~ pattern 
    $1
  end

end
