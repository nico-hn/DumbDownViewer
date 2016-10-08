require 'dumb_dir_view'

module DumbDirView
  class Visitor
    attr_accessor
    def initialize(*args, &memo_update)
      @memo_update = memo_update
      setup(*args)
    end

    def setup(*args)
    end

    def visit(node, memo)
      memo = @memo_update.call(node, memo) if @memo_update

      if node.kind_of? DirNode
        visit_dir_node(node, memo)
      else
        visit_file_node(node, memo)
      end
    end

    def visit_dir_node(node, memo)
      visit_sub_nodes(node, memo)
    end

    def visit_file_node(node, memo)
    end

    def visit_sub_nodes(node, memo)
      node.sub_nodes.each do |node|
        node.accept(self, memo)
      end
    end
  end
end
