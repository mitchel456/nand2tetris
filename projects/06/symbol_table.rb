
class SymbolTable

  def initialize
    @table = {} 
  end

  def add_entry(symbol, address)
    @table[symbol] = address
  end

  def contains?(symbol)
    @table.has_key?(symbol)
  end

  def get_address(symbol)
    @table[symbol]
  end

end
