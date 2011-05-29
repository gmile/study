class Node
  attr_accessor :nterm, :children

  def initialize nterm, children
    @nterm     = nterm
    @children = children
  end

  def find nterm
    found = children.select { |child| (child.is_a?(Node) ? child.nterm : child) == nterm }

    found.empty? ? children.select { |child| child.is_a?(Node) }.map { |child| child.find(nterm) }.flatten : nterm
  end
end
