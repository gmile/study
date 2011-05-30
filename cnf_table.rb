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
      .merge(self.if_then_else_statement)
      .merge(self.for_statement)
      .merge(self.while_statement)
      .merge(self.repeat_statement)
      .merge(self.statement)
      .merge(self.subscription_value)
      .merge(self.type)
      .merge(self.var_definition_block)
      .merge(self.const_definition_block)
      .merge(self.block_sequence)
      .merge(self.program)
      .merge(self.func_proc_params)
      .merge(self.func_proc_block)
      .merge(self.procedure)
      .merge(self.function)
      .merge(self.parameters)
  end

  def self.operation
    { :operation => [:add, :sub, :mul, :div] }
  end

  def self.value
    { :value => [:integer, :real, :variable, :string, [:n_variable, :subs_value], [:n_variable, :parameters]] }
  end

  def self.program
    {
      :program => [
        [:program_title_block, :program],
        [:block,                :n_dot ],
        [:code_block,           :n_dot ]
      ]
    }
  end

  def self.block_sequence
    {
      :c_block => [
        [:const_block, :var_block],
        [:const_block, :func_proc_block],
        [:c_block,     :func_proc_block]
      ],
      :v_block => [
        [:var_block, :func_proc_block],
      ],
      :block => [
        [:c_block,     :code_block],
        [:v_block,     :code_block],
        [:var_block,   :code_block],
        [:const_block, :code_block],
        [:func_proc_block, :code_block]
      ],
      :code_block => [
        [:n_begin, :block_statement_tail]
      ]
    }
  end

  def self.func_proc_block
    {
      :func_proc_block => [
        [:func_proc,      :n_semicolon],
        [:func_proc_list, :n_semicolon]
      ],
      :func_proc => [
        [:n_procedure, :proc_ending],
        [:n_function,  :func_ending]
      ],
      :func_proc_list => [
        [:n_semicolon, :func_proc     ],
        [:func_proc,   :func_proc_list],
        [:func_proc,   :func_proc_list]
      ]
    }
  end

  def self.func_proc_params
    {
      :func_proc_params => [
        [:n_left_bracket,     :func_proc_params],
        [:var_with_type,      :n_right_bracket ],
        [:var_with_type_list, :n_right_bracket ]
      ]
    }
  end

  def self.parameters
    {
      :parameters => [
        [:n_left_bracket, :parameters     ],
        [:value,          :n_coma         ],
        [:value_fold,     :n_coma         ],
        [:parameters,     :n_coma         ],
        [:parameters,     :value          ],
        [:parameters,     :value_fold     ],
        [:value,          :n_right_bracket],
        [:value_fold,     :n_right_bracket],
        [:parameters,     :n_right_bracket]
      ]
    }
  end

  def self.function
    {
      :func_ending => [
        [:n_variable,       :func_ending_1   ]
      ],
      :func_ending_1 => [
        [:func_proc_params, :func_ending_2   ]
      ],
      :func_ending_2 => [
        [:var_with_type,    :proc_func_ending]
      ]
    }
  end

  def self.procedure
    {
      :proc_ending => [
        [:n_variable,       :proc_ending     ],
        [:func_proc_params, :proc_func_ending]
      ],
      :proc_func_ending => [
        [:n_semicolon, :block     ],
        [:n_semicolon, :code_block]
      ]
    }
  end

  def self.type
    {
      :type => [:ordinar, :real, :boolean, :string, [:n_array, :array_type]],
      :array_type => [[:array_range, :of_type]],
      :range => [
        [:n_integer,  :range],
        [:n_variable, :range],
        [:n_range,    :n_integer ],
        [:n_range,    :n_variable]
      ],
      :array_range => [
        [:n_sq_left_bracket, :range             ],
        [:array_range,       :n_sq_right_bracket]
      ],
      :of_type => [[:n_of, :type]]
    }
  end

  def self.subscription_value
    {
      :subs_value => [
        [:n_sq_left_bracket, :value             ],
        [:n_sq_left_bracket, :value_fold        ],
        [:subs_value,        :n_sq_right_bracket]
      ]
    }
  end

  def self.program_title_block
    {
      :program_title_block    => [
        [:n_program,           :n_variable ],
        [:program_title_block, :n_semicolon]
      ]
    }
  end

  def self.uses_block
    {
      :uses_block => [
        [:n_uses,     :n_variable     ],
        [:n_uses,     :identifier_list],
        [:uses_block, :n_semicolon    ]
      ]
    }
  end

  def self.var_definition_block
    {
      :var_block => [
        [:n_var, :var_tail],
      ],
      :var_tail => [
        [:var_with_type,      :n_semicolon],
        [:var_with_type_list, :n_semicolon]
      ],
      :var_with_type => [
        [:identifier_list, :var_with_type],
        [:n_variable,      :var_with_type],
        [:n_colon,         :type         ]
      ],
      :var_with_type_list => [
        [:n_semicolon,        :var_with_type     ],
        [:var_with_type,      :var_with_type_list],
        [:var_with_type_list, :var_with_type_list]
      ]
    }
  end

  def self.const_definition_block
    {
      :const_block => [
        [:n_const, :const_tail],
      ],
      :const_tail => [
        [:constant,      :n_semicolon],
        [:constant_list, :n_semicolon]
      ],
      :const_start => [
        [:n_variable,      :n_equal],
        [:identifier_list, :n_equal]
      ],
      :constant => [
        [:const_start, :const_value]
      ],
      :constant_list => [
        [:n_semicolon,   :constant     ],
        [:constant,      :constant_list],
        [:constant_list, :constant_list]
      ],
      :const_value => [:integer, :real, :string]
    }
  end

  def self.identifier_list
    {
      :identifier_list => [
        [:n_variable, :add_identifier],
      ],
      :add_identifier => [
        [:n_coma,         :n_variable    ],
        [:add_identifier, :add_identifier]
      ]
    }
  end

  def self.statement_list
    {
      :statement_list => [
        [:statement,      :n_semicolon   ],
        [:statement_list, :n_semicolon   ],
        [:statement_list, :statement     ],
        [:statement_list, :statement_list]
      ]
    }
  end

  def self.statement
    {
      :statement => [
        [:n_variable, :assignement_statement_tail ],
        [:n_begin,    :block_statement_tail       ],
        [:n_if,       :if_then_else_statement_tail],
        [:n_while,    :while_statement_tail       ],
        [:n_repeat,   :repeat_statement_tail      ],
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
        [:statement,      :n_end],
        [:statement_list, :n_end]
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
        [:n_do,          :statement         ]
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
        [:n_then, :statement],
        [:then,   :else]
      ],
      :else => [[:n_else, :statement]]
    }
  end

  def self.repeat_statement
    {
      :repeat_statement_tail => [
        [:statement,      :until],
        [:statement_list, :until]
      ],
      :until => [
        [:n_until, :boolean_operand            ],
        [:n_until, :basic_boolean_expression   ],
        [:n_until, :basic_boolean_expression_n ],
        [:n_until, :basic_boolean_expression_w ],
        [:n_until, :combined_boolean_expression]
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
      :do => [[:n_do, :statement]]
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
