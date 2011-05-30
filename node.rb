class Node
  attr_accessor :nterm, :children, :options

  def initialize nterm, children, options = {}
    @nterm    = nterm
    @children = children
    @options  = options
  end

  def find string
    unless string == :func_name
      finder(string).flatten.compact
    else
      finder_2(string).flatten.compact
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

  def finder_2 string
    found = (nterm.name == string ? [self] : [])

    found + children.map do |child|
      if child.is_a?(Node)
        child.finder_2(string) if child.nterm.name != :func_ending_1
      elsif child.name == string
        child
      end
    end
  end
end
