require 'singleton'
require 'ostruct'
require 'delegate'
require 'concurrent'

module Rukawa
  class Configuration < Delegator
    include Singleton

    def initialize
      @config = OpenStruct.new(log_file: "./rukawa.log", concurrency: Concurrent.processor_count)
      @config.graph = GraphConfig.new.tap { |c| c.rankdir = "LR" }
    end

    def __getobj__
      @config
    end

    def graph_attrs
      if @config.graph.rankdir || @config.graph.size || @config.graph
      end
    end
  end

  GraphConfig = Struct.new(:rankdir, :size, :rotate, :ranksep, :nodesep, :concentrate, :node) do
    def initialize(*args)
      super
      self.node = GraphNodeConfig.new
    end

    def attrs
      if rankdir || size || rotate || ranksep || nodesep || concentrate
        values = to_h.map { |k, v| "#{k} = #{v}" if k != :node && v }.compact
        "graph [#{values.join(",")}];\n"
      else
        ""
      end
    end
  end

  GraphNodeConfig = Struct.new(:shape, :style) do
    def attrs
      if shape || style
        values = to_h.map { |k, v| "#{k} = #{v}" if v }.compact
        "node [#{values.join(",")}];\n"
      else
        ""
      end
    end
  end
end
