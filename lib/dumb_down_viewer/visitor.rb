require 'dumb_down_viewer'

module DumbDownViewer
  class Visitor
    attr_accessor

    def self.create(*args, &memo_update)
      new(&memo_update).tap {|visitor| visitor.setup(*args) }
    end

    def initialize(&memo_update)
      @memo_update = memo_update
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

  class TreePruner < Visitor
    def setup(keep=true)
      criteria = @memo_update
      delete_method = keep ? :keep_if : :delete_if
      @memo_update = proc do |node, memo|
        unless node.kind_of? FileNode
          [node.directories, node.files].each do |nodes|
            nodes.send(delete_method) {|n| criteria.call(n) }
          end
        end
      end
    end
  end
end
