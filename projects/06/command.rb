class Command
  attr_reader :text

  def initialize(text)
    @text = text.gsub(/\/\/.*$/, '').strip
  end

  def to_s
    "[#{text}]"
  end

  def comment?
    text.start_with?('//')
  end

  def empty?
    text.empty?
  end

  def a_command?
    text.start_with?('@')
  end

  def l_command?
    text.start_with?('(')
  end

  def c_command?
    !a_command? && !l_command?
  end

  def symbol
    # text following @ or (, representing a variable or
    # loop label
    text[/^[@(](.*?)\)?$/, 1]
  end

  def constant?
    a_command? && symbol =~ /^\d+$/
  end

  def symbol?
    a_command? && !constant?
  end

  def dest
    # portion of the text before =
    # may be nil
    text[/^(.*?)=.*$/, 1]
  end

  def comp
    # optional combination of A, M, D, followed by = (destination instruction), followed by
    # characters NOT containing ; (compute instruction - our target), optionally
    # followed by J** (jump instruction)
    text[/([AMD]+=)?([^;]*)(;J\w{2})?/, 2]
  end

  def jump
    # portion of the text after ; (jump instruction)
    # may be nil
    text[/^.*;(\w*)$/, 1]
  end
end
