class Node
  attr_accessor :nterm, :children

  def initialize nterm, children
    @nterm     = nterm
    @children = children
  end

  def find nterm
    found = children.select { |child| child.nterm == nterm }

    found.empty? ? children.map { |child| child.find(symbol) } : nterm
  end
end
