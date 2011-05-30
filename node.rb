class Node
  attr_accessor :nterm, :children, :options

  def initialize nterm, children, options = {}
    @nterm    = nterm
    @children = children
    @options  = options
  end

  def find string
    unless string == :func
      finder(string).flatten.compact
    else
      find_func_proc :func_proc
    end
  end

  def finder string
    found = (nterm.name == string ? [self] : [])

    found + children.map do |child|
      if child.is_a?(Node)
        child.finder(string) if child.nterm.name != :func_proc_block
      elsif child.name == string
        child
      end
    end
  end

  def find_func_proc string
    found = (nterm.name == string ? [self] : [])

    return found unless found.empty?
    children.select { |c| c.is_a?(Node) }.map { |c| c.find_func_proc(string) }
  end
end
