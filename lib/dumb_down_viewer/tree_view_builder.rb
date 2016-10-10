require 'dumb_down_viewer'
require 'dumb_down_viewer/visitor'
require 'csv'

module DumbDownViewer
  class TreeViewBuilder < Visitor
    attr_reader :tree_table

    class PlainTextFormat
      attr_accessor :line

      LINE_PATTERN = {
        spacer: '     ',
        h_line: '── ',
        v_line: '│   ',
        branch: '├─ ',
        corner: '└─ ' }

      def initialize(line_pattern=LINE_PATTERN)
        @line = line_pattern
      end

      def format_table(tree_table)
        t = tree_table.transpose
        t.each_cons(2) do |fr, sr|
          fr.each_with_index do |f, i|
            next unless f.kind_of? Node
            draw_lines(fr, sr, f, i)
          end
        end

        update_root_directory_name(tree_table[0][0], t)
        table_to_output_format(t.transpose)
      end

      def draw_lines(fr, sr, f_node, i)
        sub_count = f_node.sub_nodes.size
        j = i
        while sub_count > 0
          j += 1
          s_node = sr[j]
          if s_node
            fr[j] = sub_count == 1 ? @line[:corner] : @line[:branch]
            sub_count -= 1
          else
            fr[j] = @line[:v_line]
          end
        end
        fr[i] = f_node.kind_of?(DirNode) ? "[#{f_node.name}]" : f_node.name
      end

      def fill_spaces(table)
        table.map do |row|
          (row.size - 1).downto(0) do |i|
            row[i] = @line[:spacer] if row[i + 1] and row[i].nil?
          end
          row
        end
      end

      def update_root_directory_name(root, table)
        if root.directory and not root.directory.empty?
          table[0][0] = "[#{File.join(root.directory, root.name)}]"
        end
      end

      def table_to_output_format(table)
        fill_spaces(table).map {|r| r.join }.join($/) + $/
      end
    end

    class TreeCSVFormat < PlainTextFormat
      def initialize(line_pattern=LINE_PATTERN, col_sep=',')
        @line = line_pattern
        @col_sep = col_sep
      end

      def table_to_output_format(table)
        CSV.generate('', col_sep: @col_sep) do |csv|
          table.each {|row| csv << row }
        end
      end
    end

    def format(formatter=PlainTextFormat.new)
      formatter.format_table(@tree_table)
    end

    def setup(tree)
      @tree_table = []
      determine_depth(tree)
      tree.accept(self, nil)
    end

    def determine_depth(tree)
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
