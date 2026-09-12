;;; indent-bars.el -*- lexical-binding: t; -*-

(cfg-pkg indent-bars
  (:opt
   ;; Base parameters
   indent-bars-pattern " . . ."
   indent-bars-pad-frac 0.25
   indent-bars-width-frac 0.2

   ;; In scope settings
   ;; Base color used
   indent-bars-color '(highlight :face-bg t :blend 0.3)
   ;; Current on cursor depth
   indent-bars-highlight-current-depth '(:blend 1 :width 0.25 :pattern ".")
   ;; Blend with base color depending on depth
   indent-bars-color-by-depth '(:regexp "outline-\\([0-9]+\\)" :blend 0.75)

   ;; Out of scope settings
   ;; Base color used
   indent-bars-ts-color '(inherit "#595959" :face-bg nil :blend 0.2)
   ;; Current on cursor depth
   indent-bars-ts-highlight-current-depth '(no-inherit)
   ;; Blend with base color depending on depth
   indent-bars-ts-color-by-depth '(no-inherit)

   indent-bars-no-descend-lists 'skip
   indent-bars-starting-column 0
   indent-bars-display-on-blank-lines 'least

   indent-bars-treesit-support t
   indent-bars-treesit-scope-min-lines 3
   indent-bars-treesit-ignore-blank-lines-types '("module")

   ;; Don't show around these?
   indent-bars-treesit-wrap '((cpp argument_list parameter_list init_declarator parenthesized_expression)
                              (c argument_list parameter_list init_declarator parenthesized_expression)
                              (lua expression_list function_declaration if_statement
                                   elseif_statement else_statement while_statement for_statement
                                   repeat_statement comment)
                              (rust arguments parameters)
                              (toml table array comment)
                              (yaml block_mapping_pair comment)
                              (elisp quote special_form function_definition)
                              (python argument_list parameters
                                      list list_comprehension
                                      dictionary dictionary_comprehension
                                      parenthesized_expression subscript))

   ;; Active scope
   indent-bars-treesit-scope '((cpp compound_statement)
                               (rust trait_item impl_item
                                     macro_definition macro_invocation
                                     struct_item enum_item mod_item
                                     const_item let_declaration
                                     function_item for_expression
                                     if_expression loop_expression
                                     while_expression match_expression
                                     match_arm call_expression
                                     token_tree token_tree_pattern
                                     token_repetition)))

  ;; NOTE: Should enable after indent-tabs-mode therefore depth 1.
  (add-hook 'prog-mode-hook #'indent-bars-mode 1))

