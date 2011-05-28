#  def generate_tree root
#    root.is_a?(Symbol) ? root : [root.node.nterm, root.children.map { |c| generate_tree c }]
#  end
#
#  def combine
#    r = Array.new(@n) { Array.new(@n) { Set.new } }
#    matrix = @parse_tree
#
#    for m in 0..@r-1
#      for row in 0..@n-1
#        for col in 0..@n-1
#          unless matrix[col][row][m].nil?
#            client = matrix[col][row][m]
#            r[row][col].merge [client.is_a?(Symbol) ? client : client.node]
#          end
#        end
#      end
#    end
#
#    r
#  end

#  def show_tree
#    @roots.each { |root| puts show(root) }
#  end

#  def show item, depth = 0, symbol = '|'
#    unless item.is_a?(Symbol)
#      puts "#{' '*4*depth}#{symbol}-- #{item.node.nterm}"
#
#      show(item.children.first, depth+1)
#      last = item.children.last
#      last.is_a?(Symbol) ? show(last, depth+1, '`') : show(last, depth+1)
#    else
#      puts "#{' '*4*depth}#{symbol}-- #{item}"
#    end
#  end

#  def complexity
#    @n*@n*@r
#  end

#  def tree
#    @roots.map { |root| generate_tree(root) }
#  end
