require_relative 'builder'

class CNFTable
  @basic_productions = Hash[Builder.constants.map { |builder| Builder.const_get(builder).send(:terminals) }.flatten.map { |terminal| ["n_#{terminal}".to_sym, [terminal]] }]

  def self.basic_non_terminals
    @basic_productions
  end

  def self.non_terminals
    {
      :var_and_coma      => [[:n_variable,    :n_coma           ]],
      :var_and_semicolon => [[:n_variable,    :n_semicolon      ]],

      :program_fold      => [[:n_program,     :var_and_semicolon]],

      :uses_fold         => [[:n_uses,        :var_and_semicolon], [:n_uses,       :uses_fold_1]],
      :uses_fold_1       => [[:var_and_coma,  :var_and_semicolon], [:var_and_coma, :uses_fold_1]],

      :block_fold        => [[:n_begin,       :n_end            ]],

      :operation         => [:add, :sub, :mul, :div              ],
      :value             => [:integer, :real, :variable          ],
      :value_fold        => [[:value_fold_1,  :value            ]],
      :value_fold_1      => [[:value,         :operation        ]],

      :common_expr       => [[:n_variable,    :common_expr_1    ]],
      :common_expr_1     => [[:n_assignement, :value_fold       ]]
    }
  end

  def self.table
    self.basic_non_terminals.merge self.non_terminals
  end
end
