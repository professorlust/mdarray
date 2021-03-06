# -*- coding: utf-8 -*-

##########################################################################################
# Copyright © 2013 Rodrigo Botafogo. All Rights Reserved. Permission to use, copy, modify, 
# and distribute this software and its documentation for educational, research, and 
# not-for-profit purposes, without fee and without a signed licensing agreement, is hereby 
# granted, provided that the above copyright notice, this paragraph and the following two 
# paragraphs appear in all copies, modifications, and distributions. Contact Rodrigo
# Botafogo - rodrigo.a.botafogo@gmail.com for commercial licensing opportunities.
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

require 'java'

class MDMatrix
  include_package "cern.colt.matrix.tdouble.impl"
  include_package "cern.colt.matrix.tdouble.algo"

  include_package "cern.colt.matrix.tfloat.impl"
  include_package "cern.colt.matrix.tfloat.algo"

  include_package "cern.colt.matrix.tlong.impl"
  include_package "cern.colt.matrix.tlong.algo"

  include_package "cern.colt.matrix.tint.impl"
  include_package "cern.colt.matrix.tint.algo"


  attr_reader :colt_matrix
  attr_reader :colt_algebra
  attr_reader :colt_property
  attr_reader :mdarray
  attr_accessor :coerced

  #------------------------------------------------------------------------------------
  # 
  #------------------------------------------------------------------------------------

  def coerce(num)

    matrix = MDMatrix.from_mdarray(@mdarray)
    matrix.coerced = true
    [matrix, num]

  end

  #------------------------------------------------------------------------------------
  # 
  #------------------------------------------------------------------------------------

  def add(other_val)
    if (other_val.is_a? Numeric)
      MDMatrix.from_mdarray(@mdarray + other_val)
    elsif (other_val.is_a? MDMatrix)
      MDMatrix.from_mdarray(@mdarray + other_val.mdarray)
    else
      raise "Cannot add a matrix to the given value"
    end
  end

  alias :+ :add

  #------------------------------------------------------------------------------------
  # 
  #------------------------------------------------------------------------------------

  def div(other_val)
    
    if (other_val.is_a? Numeric)
      val1, val2 = (@coerced)? [other_val, @mdarray] : [@mdarray, other_val] 
      MDMatrix.from_mdarray(val1 / val2)
    elsif (other_val.is_a? MDMatrix)
      begin
        self * other_val.inverse
      rescue Exception => e
        puts e.message
        raise "Dividing by singular matrix is not possible"
      end
    else
      raise "Cannot divide the given value from matrix"
    end

  end

  alias :/ :div

  #------------------------------------------------------------------------------------
  # 
  #------------------------------------------------------------------------------------

  def sub(other_val)
    if (other_val.is_a? Numeric)
      val1, val2 = (@coerced)? [other_val, @mdarray] : [@mdarray, other_val] 
      MDMatrix.from_mdarray(val1 - val2)
    elsif (other_val.is_a? MDMatrix)
      MDMatrix.from_mdarray(@mdarray - matrix.mdarray)
    else
      raise "Cannot subtract the given value from matrix"
    end
  end

  alias :- :sub

  #------------------------------------------------------------------------------------
  # 
  #------------------------------------------------------------------------------------

  def each(&block)
    @mdarray.each(&block)
  end

  #------------------------------------------------------------------------------------
  # 
  #------------------------------------------------------------------------------------

  def each_with_counter(&block)
    @mdarray.each_with_counter(&block)
  end

  #------------------------------------------------------------------------------------
  # 
  #------------------------------------------------------------------------------------

  def reset_traversal
    @mdarray.reset_traversal
  end

  #------------------------------------------------------------------------------------
  # 
  #------------------------------------------------------------------------------------

  def next
    @mdarray.next
  end

  #------------------------------------------------------------------------------------
  # Fills the array with the given value
  #------------------------------------------------------------------------------------

  def fill(val, func = nil)

    if (func)
      return MDMatrix.from_colt_matrix(@colt_matrix.assign(val.colt_matrix, func))
    end

    if ((val.is_a? Numeric) || (val.is_a? Proc) || (val.is_a? Class))
      MDMatrix.from_colt_matrix(@colt_matrix.assign(val))
    elsif (val.is_a? MDMatrix)
      MDMatrix.from_colt_matrix(@colt_matrix.assign(val.colt_matrix))
    else
      raise "Cannot fill a Matrix with the given value"
    end
  end

  #------------------------------------------------------------------------------------
  # Fills the matrix based on a given condition
  #------------------------------------------------------------------------------------

  def fill_cond(cond, val)
    return MDMatrix.from_colt_matrix(@colt_matrix.assign(cond, val))
  end

  #------------------------------------------------------------------------------------
  # Applies a function to each cell and aggregates the results. Returns a value v such 
  # that v==a(size()) where a(i) == aggr( a(i-1), f(get(row,column)) ) and terminators 
  # are a(1) == f(get(0,0)), a(0)==Double.NaN. 
  #------------------------------------------------------------------------------------

  def reduce(aggr, func, cond = nil)
    (cond)? @colt_matrix.aggregate(aggr, func, cond) : 
      @colt_matrix.aggregate(aggr, func)
  end

  #------------------------------------------------------------------------------------
  # Reshapes the Matrix.
  #------------------------------------------------------------------------------------

  def reshape!(shape)
    @mdarray.reshape!(shape)
    @colt_matrix = MDMatrix.from_mdarray(@mdarray).colt_matrix
    self
  end

  #------------------------------------------------------------------------------------
  # 
  #------------------------------------------------------------------------------------

  def set(row, column, val)
    @colt_matrix.set(row, column, val)
  end

  alias :[]= :set

  #------------------------------------------------------------------------------------
  # 
  #------------------------------------------------------------------------------------

  def get(*index)
    @colt_matrix.get(*index)
  end

  alias :[] :get

  #------------------------------------------------------------------------------------
  # Create a new Array using same backing store as this Array, by flipping the index 
  # so that it runs from shape[index]-1 to 0.
  #------------------------------------------------------------------------------------
  
  def flip(dim)
    MDMatrix.from_mdarray(@mdarray.flip(dim))
  end
  
  #------------------------------------------------------------------------------------
  # 
  #------------------------------------------------------------------------------------

  def normalize!
    @colt_matrix.normalize
  end

  #------------------------------------------------------------------------------------
  # 
  #------------------------------------------------------------------------------------

  def rank
    @mdarray.rank
  end

  #------------------------------------------------------------------------------------
  # 
  #------------------------------------------------------------------------------------

  def shape
    @mdarray.shape
  end

  #------------------------------------------------------------------------------------
  # 
  #------------------------------------------------------------------------------------

  def size
    @mdarray.size
  end

  #------------------------------------------------------------------------------------
  # Makes a view of this array based on the given parameters
  # shape
  # origin
  # size
  # stride
  # range
  # section
  # spec
  #------------------------------------------------------------------------------------
  
  def region(*args)
    MDMatrix.from_mdarray(@mdarray.region(*args))
  end
  
  #------------------------------------------------------------------------------------
  # 
  #------------------------------------------------------------------------------------
  
  def sum
    @colt_matrix.zSum
  end

  #------------------------------------------------------------------------------------
  # 
  #------------------------------------------------------------------------------------

  def print

    case mdarray.type

    when "double"
      formatter = DoubleFormatter.new
    when "float"
      formatter = FloatFormatter.new
    when "long"
      formatter = LongFormatter.new
    when "int"
      formatter = IntFormatter.new

    end

    printf(formatter.toString(@colt_matrix))

  end

end # MDMatrix

require_relative 'creation'
require_relative 'hierarchy'
require_relative 'algebra'
require_relative 'property'
