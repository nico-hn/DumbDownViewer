require 'dumb_dir_view'
require 'dumb_dir_view/visitor'

module DumbDirView
  class TreeViewBuilder < Visitor
    def setup(tree)
      @tree_table = []
      depth_checker = Visitor.new do |node, memo|
        @tree_depth = node.depth > memo ? node.depth : memo
      end
      tree.accept(depth_checker, 0)
    end

    def new_table_row
      Array.new(@tree_depth + 1)
    end
  end
end
