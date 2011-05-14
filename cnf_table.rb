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
      .merge(self.value_fold)
      .merge(self.assignement_statement)
      .merge(self.block_statement)
      .merge(self.statement_list)
      .merge(self.statement)
      .merge(self.if_then_else_statement)
      .merge(self.for_statement)
      .merge(self.while_statement)
      .merge(self.real_statement)
  end

  def self.operation
    { :operation => [:add, :sub, :mul, :div] }
  end

  def self.value
    { :value => [:integer, :real, :variable] }
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
      :real_statement_list => [
        [:real_statement,      :n_semicolon        ],
        [:real_statement_list, :n_semicolon        ],
        [:real_statement_list, :real_statement     ],
        [:real_statement_list, :real_statement_list]
      ]
    }
  end

  def self.statement
    {
      :statement => [
        [:for_statement_tail,         :n_semicolon],
        [:if_then_else_statement_tail,:n_semicolon],
        [:while_statement_tail,            :n_semicolon],
        [:assignement_statement_tail, :n_semicolon],
        [:block_statement_tail,       :n_semicolon]
      ]
    }
  end

  def self.real_statement
    {
      :real_statement => [
        [:n_variable, :assignement_statement_tail ],
        [:n_begin,    :block_statement_tail       ],
        [:n_if,       :if_then_else_statement_tail],
        [:n_while,    :while_statement_tail       ],
        [:n_for,      :for_statement_tail         ]
      ]
    }
  end

  def self.assignement_statement
    {
      :assignement_statement_tail => [
        [:n_assignement, :value_fold],
        [:n_assignement, :value     ]
      ]
    }
  end

  def self.block_statement
    {
      :block_statement_tail => [
        [:real_statement,      :n_end],
        [:real_statement_list, :n_end]
      ]
    }
  end

  def self.for_statement
    {
      :for_statement_tail => [
        [:n_variable,    :for_statement_tail],
        [:n_assignement, :for_statement_tail],
        [:value,         :for_statement_tail],
        [:value_fold,    :for_statement_tail],
        [:n_to,          :for_statement_tail],
        [:n_downto,      :for_statement_tail],
        [:n_do,          :real_statement    ]
      ]
    }
  end

  def self.if_then_else_statement
    {
      :if_then_else_statement_tail => [
        [:basic_boolean_expression,    :then],
        [:basic_boolean_expression_n,  :then],
        [:basic_boolean_expression_w,  :then],
        [:combined_boolean_expression, :then]
      ],
      :then => [
        [:n_then, :real_statement],
        [:then,   :else]
      ],
      :else => [
        [:n_else,    :real_statement]
      ]
    }
  end

  def self.while_statement
    {
      :while_statement_tail => [
        [:basic_boolean_expression,    :do],
        [:basic_boolean_expression_n,  :do],
        [:basic_boolean_expression_w,  :do],
        [:combined_boolean_expression, :do]
      ],
      :do => [
        [:n_do, :real_statement]
      ]
    }
  end

  def self.value_fold
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
