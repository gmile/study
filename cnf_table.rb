require_relative 'builder'

class CNFTable
  @basic_productions = Hash[Builder.constants.map { |builder| Builder.const_get(builder).send(:terminals) }.flatten.map { |terminal| ["n_#{terminal}".to_sym, [terminal]] }]

  def self.basic_non_terminals
    @basic_productions
  end

  def self.non_terminals
    {
      :var_and_coma      => [[:n_variable,   :n_coma]],
      :var_and_semicolon => [[:n_variable,   :n_semicolon]],

      :program_fold      => [[:n_program,    :var_and_semicolon]],

      :uses_fold         => [[:n_uses,       :var_and_semicolon], [:n_uses,       :uses_fold_1]],
      :uses_fold_1       => [[:var_and_coma, :var_and_semicolon], [:var_and_coma, :uses_fold_1]]
    }
  end

  def self.table
    self.basic_non_terminals.merge self.non_terminals
  end
end
