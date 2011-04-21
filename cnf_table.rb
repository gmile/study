require_relative 'builder'

class CNFTable
  @basic_productions = Hash[Builder.constants.map { |builder| Builder.const_get(builder).send(:terminals) }.flatten.map { |terminal| ["n_#{terminal}".to_sym, [terminal]] }]

  def self.basic_non_terminals
    @basic_productions
  end

  def self.non_terminals
    {
      :program_fold   => [[:program_fold_1, :n_semicolon]],
      :program_fold_1 => [[:n_program,      :n_variable ]]
    }
  end

  def self.table
    self.basic_non_terminals.merge self.non_terminals
  end
end
