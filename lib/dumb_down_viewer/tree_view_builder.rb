require 'dumb_down_viewer'
require 'dumb_down_viewer/visitor'

module DumbDownViewer
  class TreeViewBuilder < Visitor
    attr_reader :tree_table

    class << self
      attr_accessor :h_line, :v_line, :branch, :corner
    end

    @spacer = '     '
    @h_line = '── '
    @v_line = '│   '
    @branch = '├─ '
    @corner = '└─ '

    def self.format_table(table)
      t = table.transpose
      t.each_cons(2) do |fr, sr|
        fr.each_with_index do |f, i|
          next unless f.kind_of? Node
          draw_lines(fr, sr, f, i)
        end
      end

      update_root_directory_name(table[0][0], t)
      fill_spaces(t.transpose).map {|r| r.join }.join($/) + $/
    end

    def self.draw_lines(fr, sr, f_node, i)
      sub_count = f_node.sub_nodes.size
      j = i
      while sub_count > 0
        j += 1
        s_node = sr[j]
        if s_node
          fr[j] = sub_count == 1 ? @corner : @branch
          sub_count -= 1
        else
          fr[j] = @v_line
        end
      end
      fr[i] = f_node.kind_of?(DirNode) ? "[#{f_node.name}]" : f_node.name
    end

    def self.fill_spaces(table)
      table.map do |row|
        (row.size - 1).downto(0) do |i|
          row[i] = @spacer if row[i + 1] and row[i].nil?
        end
        row
      end
    end

    def self.update_root_directory_name(root, table)
      if root.directory and not root.directory.empty?
        table[0][0] = "[#{File.join(root.directory, root.name)}]"
      end
    end

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

      [node.files, node.directories].each do |nodes|
        nodes.sort_by {|n| n.name }.each {|n| n.accept(self, memo) }
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
