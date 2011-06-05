class Node
  attr_accessor :nterm, :children, :options

  def initialize nterm, children, options = {}
    @nterm    = nterm
    @children = children
    @options  = options
    get_lines
  end

  def get_lines
    @options[:lines] = {}
    first_child, second_child = @children
    @options[:lines][:first] =  first_child.is_a?(Node) ?  first_child.options[:lines][:first] : first_child.token.y
    @options[:lines][:last]  = second_child.is_a?(Node) ? second_child.options[:lines][:last]  : second_child.token.y
  end

  def set_block current_block, parent_block, blocks_array
    nterm_children = self.children.select { |child| !child.is_a?(Node) }
    rest           = self.children - nterm_children

    unless nterm_children.empty?
      nterm_children.each do |child|
        child.options[:current_block] = current_block
        child.options[:parent_block]  = parent_block
        # child.options[:used]          = true if :code_block
      end
    end

    if [:func_ending, :proc_ending].include?(self.nterm.name)
      blocks_array << template

      rest.each do |child|
        child.set_block blocks_array.size-1, current_block, blocks_array
      end
    else
      rest.each do |child|
        child.set_block current_block, parent_block, blocks_array
      end
    end
  end

  def template
    {
      :block_info => {
        :parent => nil,
        :self   => nil,
        :lines  => {
          :first => self.options[:lines][:first],
          :last  => self.options[:lines][:last]
        }
      },
      :constants => [],
      :variables => [],
      :functions => [],
      :procedures => [],
      :used      => []
    }
  end

  def extract
    nterm_children = self.children.select { |child| !child.is_a?(Node) }
    rest           = self.children - nterm_children

    found = nterm_children.select { |child| [:var_name, :const_name, :func_name, :proc_name].include?(child.name) || child.token.type == :variable }
    (found + rest.select { |child| child.is_a?(Node) }.map { |child| child.extract }).flatten
  end
end
