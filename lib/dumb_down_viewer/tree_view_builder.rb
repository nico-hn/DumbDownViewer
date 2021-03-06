require 'dumb_down_viewer'
require 'dumb_down_viewer/visitor'
require 'csv'
require 'yaml'

module DumbDownViewer
  class TreeViewBuilder < Visitor
    attr_reader :tree_table

    class PlainTextFormat
      attr_accessor :line

      LINE_PATTERNS = YAML.load(<<YAML_DATA)
:default:
  :spacer: '     '
  :h_line: '── '
  :v_line: '│   '
  :branch: '├─ '
  :corner: '└─ '
:ascii_art:
  :spacer: '    '
  :h_line: '--- '
  :v_line: '|   '
  :branch: '|-- '
  :corner: '`-- '
:list:
  :spacer: '   '
  :h_line: '   '
  :v_line: '   '
  :branch: ' * '
  :corner: ' * '
:zenkaku:
  :spacer: '　　 '
  :h_line: '── '
  :v_line: '│　 '
  :branch: '├─ '
  :corner: '└─ '
:tree:
  :spacer: '    '
  :h_line: '─── '
  :v_line: '│   '
  :branch: '├── '
  :corner: '└── '

YAML_DATA

      def initialize(line_pattern=:default, col_sep=nil, node_format=nil)
        # col_sep is just for having common interface
        @line = LINE_PATTERNS[line_pattern]
        @node_format = node_format || NodeFormat.new
      end

      def format_table(tree_table)
        t = tree_table.transpose
        t.each_cons(2) do |fr, sr|
          fr.each_with_index do |f, i|
            next unless f.kind_of? Node
            draw_lines(fr, sr, f, i)
          end
        end

        draw_last_line(t[-1])
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
        fr[i] = @node_format[f_node]
      end

      def draw_last_line(line)
        line.each_index do |i|
          node = line[i]
          line[i] = @node_format[node] if node.kind_of?(DirNode)
        end
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
      def initialize(line_pattern=:default, col_sep=',', node_format=nil)
        @line = LINE_PATTERNS[line_pattern]
        @col_sep = col_sep
        @node_format = node_format || NodeFormat.new
      end

      def table_to_output_format(table)
        CSV.generate('', col_sep: @col_sep) do |csv|
          table.each {|row| csv << row }
        end
      end
    end

    class CSVFormat
      def initialize(line_pattern=nil, col_sep=',', node_format=nil)
        @line_pattern = line_pattern
        @col_sep = col_sep
        @node_format = node_format || NodeFormat.new
      end

      def format_table(tree_table)
        root = tree_table[0][0]
        tree_table[0][0] = "#{File.join(root.directory, root.name)}"
        CSV.generate('', col_sep: @col_sep) do |csv|
          tree_table.each {|row| csv << row }
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

    def determine_depth(tree) # update of test necessary
      @tree_depth = 0
      depth_checker = Visitor.new do |node, memo|
        @tree_depth = node.depth > @tree_depth ? node.depth : @tree_depth
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
