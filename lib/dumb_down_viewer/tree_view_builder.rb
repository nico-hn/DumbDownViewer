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
        f_node = nil
        fr.each_with_index do |f, i|
          next unless f.kind_of? Node
          draw_lines(fr, sr, f, i, f.sub_nodes.size)
        end
      end


      root = table[0][0]

      if root.directory and not root.directory.empty?
        t[0][0] = "[#{File.join(root.directory, root.name)}]"
      end

      t = t.transpose.map do |row|
        (row.size - 1).downto(0) do |i|
          if row[i + 1] and row[i].nil?
            row[i] = @spacer
          end
        end
        row
      end

      t.map {|r| r.join }.join($/) + $/
    end

    def self.draw_lines(fr, sr, f_node, i, sub_count)
      j = i
      while sub_count > 0
        j += 1
        s_node = sr[j]
        if s_node and sub_count == 1
          fr[j] = @corner
          fr[i] = f_node.kind_of?(DirNode) ? "[#{f_node.name}]" : f_node.name
          sub_count -= 1
        elsif s_node
          fr[j] = @branch
          sub_count -= 1
        else
          fr[j] = @v_line
        end
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
