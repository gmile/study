require_relative 'builder'

class CNFTable
  @basic_productions = Hash[Builder.constants.map { |builder| Builder.const_get(builder).send(:terminals) }.flatten.map { |terminal| ["n_#{terminal}".to_sym, [terminal]] }]

  def self.basic_non_terminals
    @basic_productions
  end

  def self.non_terminals
    {}.merge(self.value)
      .merge(self.operation)
      .merge(self.boolean_expression)
      .merge(self.program_title_block)
      .merge(self.uses_block)
      .merge(self.identifier_list)
      .merge(self.algebra_expression)
      .merge(self.assignement_statement)
      .merge(self.block_statement)
      .merge(self.statement_list)
      .merge(self.statement)
      .merge(self.if_then_else_statement)
  end

  def self.operation
    { :operation => [:add, :sub, :mul, :div] }
  end

  def self.value
    { :value => [:integer, :real, :variable] }
  end

  def self.block_statement
    {
      :block_statement => [
        [:n_begin,         :statement     ],
        [:n_begin,         :statement_list],
        [:n_begin,         :n_end         ],
        [:block_statement, :n_end         ]
      ]
    }
  end

  def self.program_title_block
    {
      :program_title_block    => [
        [:n_program,            :n_variable ],
        [:program_title_block,  :n_semicolon]
      ]
    }
  end

  def self.uses_block
    {
      :uses_fold => [
        [:n_uses,     :n_variable     ],
        [:n_uses,     :identifier_list],
        [:uses_fold,  :n_semicolon    ]
      ]
    }
  end

  def self.identifier_list
    {
      :identifier_list => [
        [:identifier_list, :n_variable],
        [:identifier_list, :n_coma    ],
        [:n_variable,      :n_coma    ]
      ]
    }
  end

  def self.statement_list
    {
      :statement_list => [
        [:statement,      :statement     ],
        [:statement_list, :statement     ],
        [:statement_list, :statement_list],
      ]
    }
  end

  def self.statement
    {
      :statement => [
        [:assignement_statement, :n_semicolon],
        [:block_statement,       :n_semicolon],
        [:block_statement,       :n_semicolon]
      ]
    }
  end

  def self.assignement_statement
    {
      :assignement_statement => [
        [:n_variable,            :n_assignement],
        [:assignement_statement, :value_fold   ],
        [:assignement_statement, :value        ]
      ]
    }
  end

  def self.if_then_else_statement
    {
      :if_then_else_statement => [
        [:n_if,                   :basic_boolean_expression   ],
        [:n_if,                   :basic_boolean_expression_n ],
        [:n_if,                   :basic_boolean_expression_w ],
        [:n_if,                   :combined_boolean_expression],
        [:if_then_else_statement, :then_statement             ]
      ]
    }.merge({
      :then_statement => [
        [:n_then,         :statement     ],
        [:then_statement, :else_statement]
      ],
      :else_statement => [
        [:n_else, :statement]
      ]
    })
  end

  def self.algebra_expression
    {
      :value_fold => [
        [:value_fold, :value    ],
        [:value_fold, :operation],
        [:value,      :operation]
      ]
    }
  end

  def self.boolean_expression
    {
      :boolean_operand => [
        :true,
        :false,
        :variable
      ],
      :boolean_operand_n => [
        [:boolean_not, :boolean_operand]
      ],
      :boolean_operation => [
        :not_equal,
        :less_or_equal,
        :greater_or_equal,
        :equal,
        :greater_then,
        :less_then
      ],
      :boolean_value => [
        :integer,
        :real
      ],
      :boolean_block_operation => [
        :and,
        :or
      ],
      :boolean_not => [:not],
      :basic_boolean_expression => [
        [:boolean_value,               :basic_boolean_expression   ],
        [:boolean_operand,             :basic_boolean_expression   ],
        [:boolean_operation,           :boolean_value              ],
        [:boolean_operation,           :boolean_operand            ]
      ],
      :basic_boolean_expression_n => [
        [:boolean_not, :basic_boolean_expression]
      ],
      :basic_boolean_expression_w => [
        [:n_left_bracket,              :basic_boolean_expression_w ],
        [:basic_boolean_expression,    :n_right_bracket            ],
        [:basic_boolean_expression_n,  :n_right_bracket            ],
        [:boolean_operand,             :n_right_bracket            ],
        [:boolean_operand_n,           :n_right_bracket            ]
      ],
      :combined_boolean_expression => [
        [:boolean_operand,             :boolean_block_operation    ],
        [:basic_boolean_expression,    :boolean_block_operation    ],
        [:basic_boolean_expression_w,  :boolean_block_operation    ],
        [:combined_boolean_expression, :boolean_operand            ],
        [:combined_boolean_expression, :boolean_operand_n          ],
        [:combined_boolean_expression, :basic_boolean_expression   ],
        [:combined_boolean_expression, :basic_boolean_expression_w ],
        [:combined_boolean_expression, :combined_boolean_expression]
      ]
    }
  end

  def self.table
    self.basic_non_terminals.merge self.non_terminals
  end
end
