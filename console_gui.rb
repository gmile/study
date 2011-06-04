require 'rainbow'

class GUI
  def self.generate_tree root
    root.is_a?(Symbol) ? root : [root.node.nterm, root.children.map { |c| generate_tree c }]
  end
=begin
  def self.combine
    r = Array.new(@n) { Array.new(@n) { Set.new } }
    matrix = @parse_tree

    for m in 0..@r-1
      for row in 0..@n-1
        for col in 0..@n-1
          unless matrix[col][row][m].nil?
            client = matrix[col][row][m]
            r[row][col].merge [client.is_a?(Symbol) ? client : client.node]
          end
        end
      end
    end

    r
  end
=end
  def self.show_tree roots
    roots.each { |root| puts show(root) }
  end

  def self.show item, depth = 0, symbol = '|'
    string = (' '*4*depth + symbol + '-- ').color('#333333')

    unless item.is_a?(NTerm)
      puts string << item.nterm.name.to_s.color("333333") + " " + item.class.to_s + " [#{item.options[:current_block]} #{item.options[:parent_block]}]"

      show(item.children.first, depth+1, '|')
      show(item.children.last,  depth+1, '`')
    else
      puts string << item.name.to_s.color("333333") + " " + item.class.to_s + " " + item.token.lexeme.color(:green) + " [#{item.token.x}, #{item.token.y}]".color('#999999')
    end
  end

#  def self.complexity
#    @n*@n*@
#  end
#
#  def tree
#    @roots.map { |root| generate_tree(root) }
#  end
end
