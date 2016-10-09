require 'dumb_dir_view'
require 'dumb_dir_view/visitor'

module DumbDirView
  class TreeViewBuilder < Visitor
    attr_reader :tree_table

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

    def visit_dir_node(node, memo)
      add_current_node_row(node)

      node.files.sort_by {|f| f.name }.each do |file|
        file.accept(self, memo)
      end

      node.directories.sort_by {|d| d.name }.each do |dir|
        dir.accept(self, memo)
      end
    end

    def visit_file_node(node, memo)
      add_current_node_row(node)
    end

    def add_current_node_row(node)
      row = new_table_row
      row[node.depth] = node
      @tree_table.push row
    end
  end
end
