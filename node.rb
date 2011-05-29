class Node
  attr_accessor :nterm, :children, :options

  def initialize nterm, children, options = {}
    @nterm    = nterm
    @children = children
    @options  = options
  end

  def find string
    found = children.select { |child| (child.is_a?(Node) ? child.nterm.name : child.name) == string }

    found.empty? ? children.select { |child| child.is_a?(Node) }.map { |child| child.find(string) }.flatten : found
  end
end
