# -*- coding: utf-8 -*-

##########################################################################################
# Copyright © 2013 Rodrigo Botafogo. All Rights Reserved. Permission to use, copy, modify, 
# and distribute this software and its documentation, without fee and without a signed 
# licensing agreement, is hereby granted, provided that the above copyright notice, this 
# paragraph and the following two paragraphs appear in all copies, modifications, and 
# distributions.
#
# IN NO EVENT SHALL RODRIGO BOTAFOGO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, 
# INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF 
# THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF RODRIGO BOTAFOGO HAS BEEN ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
#
# RODRIGO BOTAFOGO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE 
# SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". 
# RODRIGO BOTAFOGO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, 
# OR MODIFICATIONS.
##########################################################################################

##########################################################################################
#
##########################################################################################

module FunctionCreation

  #------------------------------------------------------------------------------------
  # name is the name of the function being created
  # exec_type is the execution type.  The following execution types are defined default
  # in_place, fill and reduce 
  #------------------------------------------------------------------------------------

  def make_binary_op(name, exec_type, func, helper_class, force_type = nil, 
                     pre_condition = nil, post_condition = nil)

    define_method(name) do |op2, requested_type = nil, *args|
      if (@type == "lazy" || ((op2.is_a? MDArray) && op2.type == "lazy"))
        binary_op = LazyBinaryOperator
      else
        binary_op = get_binary_op
      end
      op = binary_op.new(name, exec_type, force_type, pre_condition, post_condition)
      op.exec(self, op2, requested_type, *args)
    end

    MDArray.register_function(name, func, 2, helper_class)

  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def make_unary_op(name, exec_type, func, helper_class, force_type = nil, 
                    pre_condition = nil, post_condition = nil)
    
    define_method(name) do |requested_type = nil, *args|
      unary_op = get_unary_op
      op = unary_op.new(name, exec_type, force_type, pre_condition, post_condition)
      op.exec(self, requested_type, *args)
    end

    MDArray.register_function(name, func, 1, helper_class)

  end

end # FunctionCreation
