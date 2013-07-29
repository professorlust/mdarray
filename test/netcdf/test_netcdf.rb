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

require 'rubygems'
require "test/unit"
require 'shoulda'

require 'mdarray'

class MDArrayTest < Test::Unit::TestCase

  context "NetCDF implementation" do

    setup do

      @directory = "/home/zxb3/tmp"

    end


    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------
=begin
    should "Open a file for redefinition" do

      # opening an existing file and adding dimensions to it

      NetCDF.redefine(cygpath(@directory), "nc_output", self) do
        
      end

    end
=end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "Allow definition of a NetCDF-3 file" do

      # Opens a file for definition, passing the directory and file name.
      # Creates a new scope for defining the NetCDF file.  In order to access the 
      # ouside scope, that is, "here", we pass self as the third argument to define.
      # When self is passed as argument, @outside_scope is available inside the block.
      
      NetCDF.define(cygpath(@directory), "nc_output", "netcdf3", self) do
        
        # can add global attributes by adding a single valued attribute or an array of 
        # attributes.  When adding an array of attributes all elements of the array must
        # be of the same type, i.e, fixnum, floats or strings. Attributes with long numbers
        # are not allowed. This seems to be a restriction of Java-NetCDF.

        global_att :fixnums, "Values", [1, 2, 3, 4]
        @outside_scope.assert_equal(2, @fixnums.numeric_value(1))

        global_att :strings, "Strings", ["abc", "efg"]
        @outside_scope.assert_equal("abc", @strings.string_value(0))

        global_att :floats, "Floats", [1.34, 2.45]

        global_att :fixnum, "Fixnum", 3
        @outside_scope.assert_equal(3, @fixnum.numeric_value)

        global_att :string, "String", "this is a string"
        global_att :float, "Float", 3.45

        global_att :desc, "Description", "This is a test file created by MDArray"

        @outside_scope.assert_equal("String", @desc.data_type)
        @outside_scope.assert_equal("Description", @desc.name)
        @outside_scope.assert_equal("This is a test file created by MDArray", 
                                    @desc.string_value)
        @outside_scope.assert_equal(true, @desc.string?)
        @outside_scope.assert_equal(false, @desc.unsigned?)

        att = find_global_attribute("Fixnum")
        @outside_scope.assert_equal("Fixnum", att.name)

        att = find_global_attribute("doesnotexists")
        @outside_scope.assert_equal(nil, att)

        # print all global attributes
        global_attributes.each do |att|
          p att.name
        end

        #=================================================================================
        # Adding dimensions
        #=================================================================================

        dimension :dim1, "dim1", 5
        @outside_scope.assert_equal(5, @dim1.length)
        @outside_scope.assert_equal("dim1", @dim1.name)
        @outside_scope.assert_equal(true, @dim1.shared?)
        @outside_scope.assert_equal(false, @dim1.unlimited?)
        @outside_scope.assert_equal(false, @dim1.variable_length?)

        dimension :dim2, "dim2", 10
        @outside_scope.assert_equal(true, @dim2.shared?)

        # create an unlimited dimension by setting the size to 0
        dimension :dim3, "dim3", 0
        @outside_scope.assert_equal(true, @dim3.shared?)
        @outside_scope.assert_equal(true, @dim3.unlimited?)
        @outside_scope.assert_equal(false, @dim3.variable_length?)

        # Cannot create a variable_length dimension in NetCDF-3 file.  Might
        # work on NetCDF-4.  Not tested.
        # dimension :dim4, "dim4", -1
        # @outside_scope.assert_equal(true, @dim4.variable_length?)

        # Create a dimension that is not shared. Don't know exactly what happens
        # in NetCDF-3 files.  It does not give any bugs but the dimension does
        # not appear on a write_cdl call.
        dimension :dim5, "dim5", 5, false
        @outside_scope.assert_equal("dim5", @dim5.name)
        @outside_scope.assert_equal(false, @dim5.shared?)

        #=================================================================================
        # Adding variables
        #=================================================================================

        variable :var1, "arr1", "int", [:dim1]
        variable_att :att1, @var1, "description", "this is a variable"
=begin
        variable_att :att2, "arr1", "size", 5
        variable_att :att3, "arr1", "date", 10

        variable :var2, "unlimited", "string", [:dim3, :dim2]
        # variable :var3, "variable_length", "double", [:dim4]

        @outside_scope.assert_equal(true, define_mode?)

        large_file = true
        p get_file_type_description
=end      
      end

    end

    #-------------------------------------------------------------------------------------
    # Opens a NetCDF file for reading only
    #-------------------------------------------------------------------------------------

    should "open a file just for reading" do

      # Opens a file for definition, passing the directory and file name.
      # Creates a new scope for defining the NetCDF file.  In order to access the 
      # ouside scope, that is, "here", we pass self as the third argument to define.
      # When self is passed as argument, @outside_scope is available inside the block.
      
      reader = NetCDF.read(cygpath(@directory), "nc_output", self) do
=begin      
        # print all global attributes
        global_attributes.each do |att|
          p att.name
        end

        att = find_global_attribute("Fixnum")
        @outside_scope.assert_equal("Fixnum", att.name)

        # att 

        dim1 = find_dimension("dim1")
        @outside_scope.assert_equal(5, dim1.length)
        @outside_scope.assert_equal("dim1", dim1.name)
        @outside_scope.assert_equal(true, dim1.shared?)
        @outside_scope.assert_equal(false, dim1.unlimited?)
        @outside_scope.assert_equal(false, dim1.variable_length?)

        unlimited = find_unlimited_dimension
        @outside_scope.assert_equal("dim3", unlimited.name)

        # Although adding an unshared dimension seemed to work on NetCDF-3 file, 
        # trying to retrieve this dimension does not work.
        # unshared = find_dimension("dim5")
        # @outside_scope.assert_equal("dim5", unshared.name)

        write_cdl
=end
=begin
        p detail_info
        p file_type_description
        p file_type_id
        p id
        p last_modified
        p location
        p title
        p unlimited_dimension?
=end

      end
      
    end
      
  end
  
end
