require_relative 'builder'

class CNFTable
  @basic_productions = Hash[Builder.constants.map { |builder| Builder.const_get(builder).send(:terminals) }.flatten.map { |terminal| ["n_#{terminal}".to_sym, [terminal]] }]

  def self.basic_non_terminals
    @basic_productions
  end

  def self.non_terminals
    {
      :operation          => [:add, :sub, :mul, :div    ],
      :value              => [:integer, :real, :variable],

      :program_title_fold => [[:n_program,  :n_variable]],
      :uses_fold          => [[:n_uses,     :n_variable], [:n_uses, :uses_fold_1]],
      :uses_fold_1        => [[:n_variable, :n_coma],     [:uses_fold_1, :n_variable], [:uses_fold_1, :uses_fold_1]],

      :value_fold         => [[:value,      :operation], [:value_fold, :value], [:value_fold, :value_fold]],

      :common_expr_fold   => [[:n_variable,    :common_expr_fold_1    ]],
      :common_expr_fold_1 => [[:n_assignement, :value_fold       ], [:n_assignement, :value]],

      :block_fold         => [[:n_begin, :n_end], [:n_begin, :block_fold_1]],
      :block_fold_1       => [[:common_expr_fold, :n_end]]
    }
  end

  def self.table
    self.basic_non_terminals.merge self.non_terminals
  end
end
