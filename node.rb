class Node
  attr_accessor :nterm, :children, :options

  def initialize nterm, children, options = {}
    @nterm    = nterm
    @children = children
    @options  = options
  end

  def find string
    found = children.select { |child| (child.is_a?(Node) ? child.nterm.name : child.name) == string }

    puts "---" if self.nterm.name == :block

    (children.select { |child| child.is_a?(Node) && child.nterm.name != string }.map { |child| child.find(string) } + found).flatten
  end
end
