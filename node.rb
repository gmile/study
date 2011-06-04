class Node
  attr_accessor :nterm, :children, :options

  def initialize nterm, children, options = {}
    @nterm    = nterm
    @children = children
    @options  = options
  end

  def find string
    unless string == :func_name
      finder_2(string).flatten.compact
    else
      finder_2(string).flatten.compact
    end
  end

  def finder_2 string
    found = (nterm.name == string ? [self] : [])

    found + children.map do |child|
      if child.is_a?(Node)
        if child.nterm.name != :func_ending_1
          child.finder_2(string)
        else
          child.find(:func_proc_params)
        end
      elsif child.name == string
        child
      end
    end
  end

  def find_deeper
    finder_2(:find_block_params).first.find
  end

  def set_block current_block, parent_block, blocks_array
    nterm_children = self.children.select { |child| !child.is_a?(Node) }
    rest           = self.children - nterm_children

    unless nterm_children.empty?
      nterm_children.each do |child|
        child.options[:current_block] = current_block
        child.options[:parent_block]  = parent_block
      end
    end

    if [:func_ending, :proc_ending].include?(self.nterm.name)
      blocks_array << []

      rest.each do |child|
        child.set_block blocks_array.size, current_block, blocks_array
      end
    else
      rest.each do |child|
        child.set_block current_block, parent_block, blocks_array
      end
    end
  end
end
