require 'psych/handler'

module Psych
  ###
  # This class builds an in-memory parse tree tree that represents a YAML
  # document.
  #
  # See Psych::Handler for documentation on the event methods used in this
  # class.
  class TreeBuilder < Psych::Handler
    def initialize
      @stack = []
    end

    def root
      @stack.first
    end

    %w{
      Sequence
      Mapping
    }.each do |node|
      class_eval %{
        def start_#{node.downcase}(*args)
          n = Nodes::#{node}.new(*args)
          @stack.last.children << n
          @stack.push n
        end

        def end_#{node.downcase}
          @stack.pop
        end
      }
    end

    def start_document(*args)
      n = Nodes::Document.new(*args)
      @stack.last.children << n
      @stack.push n
    end

    def end_document implicit_end
      @stack.pop.implicit_end = implicit_end
    end

    def start_stream encoding
      @stack.push Nodes::Stream.new(encoding)
    end

    def scalar(*args)
      @stack.last.children << Nodes::Scalar.new(*args)
    end

    def alias(*args)
      @stack.last.children << Nodes::Alias.new(*args)
    end
  end
end