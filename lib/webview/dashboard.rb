# -*- coding: utf-8 -*-

##########################################################################################
# @author Rodrigo Botafogo
#
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

require 'jrubyfx'

require_relative 'dcfx'

#==========================================================================================
#
#==========================================================================================

class Dashboard

  attr_reader :width
  attr_reader :height
  attr_reader :datasets
  attr_reader :graphs

  attr_reader :data
  attr_reader :dimension_labels
  attr_reader :base_dimensions  # dimensions used by crossfilter 

  #------------------------------------------------------------------------------------
  # Launches the UI and passes self so that it can add elements to it.
  #------------------------------------------------------------------------------------

  def initialize(width, height)

    @width = width
    @height = height
    @datasets = Array.new
    @graphs = Array.new
    @base_dimensions = Hash.new

  end

  #------------------------------------------------------------------------------------
  # 
  #------------------------------------------------------------------------------------

  def prepare_dimension(dim_name, dim, expr = "")
    @base_dimensions[dim_name] = dim + expr
    return self
  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def dimensions_spec

    dim_spec = String.new
    @base_dimensions.each_pair do |key, value|
      dim_spec << "var #{key} = facts.dimension(function(d) {return d[\"#{value}\"];});"
    end
    dim_spec

  end

  #------------------------------------------------------------------------------------
  # adds the data to the javascript environment
  #------------------------------------------------------------------------------------

  def add_data(data, dimension_labels)
    @data = data
    @dimension_labels = dimension_labels
  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def add_graph(g)
    @datasets << g
  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def spec

    spec = <<EOS
      graph = new DCGraph();
      graph.convert(["Date"]);
    
      // Make variable data accessible to all graphs
      var data = graph.getData();

      //$('#help').append(JSON.stringify(data));
      var timeFormat = d3.time.format("%d/%m/%Y");

      // Add data to crossfilter
      facts = crossfilter(data);
EOS

    spec << dimension

    @datasets.each do |g|
      # add spot
      spec << "d3.select(\"body\").append(\"div\").attr(\"id\", \"#{g.spot}\");"
      g.dimension("timeDimension")
      spec << g.spec + ";\n"
    end

    spec << "dc.renderAll();"

  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def run2(web_engine)

    @web_engine = web_engine
    @window = @web_engine.executeScript("window")
    @document = @window.eval("document")
    @web_engine.setJavaScriptEnabled(true)

    # Intitialize variable nc_array and dimension_labels on javascript
    @window.setMember("native_array", @data.nc_array)
    @window.setMember("labels", @dimension_labels.nc_array)

=begin
    output = File.open( "script.js","w" )
    output << spec
    f = Java::JavaIo.File.new("script.js")
    fil = f.toURI().toURL().toString()
    p fil
    @web_engine.load(fil)
=end

    # @web_engine.executeScript(spec)

  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def run(web_engine)

    @web_engine = web_engine
    @window = @web_engine.executeScript("window")
    @document = @window.eval("document")
    @web_engine.setJavaScriptEnabled(true)

    # Intitialize variable nc_array and dimension_labels on javascript
    @window.setMember("native_array", @data.nc_array)
    @window.setMember("labels", @dimension_labels.nc_array)

    # convert the data to JSON format
    scrpt = <<EOS
      graph = new DCGraph();
      graph.convert(["Date"]);
      // Make variable data accessible to all graphs
      var data = graph.getData();
      //$('#help').append(JSON.stringify(data));
      var timeFormat = d3.time.format("%d/%m/%Y");
      facts = crossfilter(data);
EOS

    graphs_spec = String.new

    graphs_spec << dimensions_spec

    @datasets.each do |g|
      # add spot
      graphs_spec << "d3.select(\"body\").append(\"div\").attr(\"id\", \"#{g.spot}\")"
      graphs_spec << g.js_spec
    end

    scrpt += graphs_spec + "dc.renderAll();"

    p scrpt

    @web_engine.executeScript(scrpt)

  end

  #------------------------------------------------------------------------------------
  # Launches the UI and passes self so that it can add elements to it.
  #------------------------------------------------------------------------------------

  def plot
    DCFX.launch(self, @width, @height)
  end

end

require_relative 'graph'
