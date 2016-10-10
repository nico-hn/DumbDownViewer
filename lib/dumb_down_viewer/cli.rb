require 'dumb_down_viewer'
require 'dumb_down_viewer/tree_view_builder'
require 'optparse_plus'

module DumbDownViewer
  module Cli
    FORMATTER = {
      default: DumbDownViewer::TreeViewBuilder::PlainTextFormat,
      csv: DumbDownViewer::TreeViewBuilder::CSVFormat,
      tsv: DumbDownViewer::TreeViewBuilder::CSVFormat,
      tree_csv: DumbDownViewer::TreeViewBuilder::TreeCSVFormat
    }

    OPTIONS = <<YAML
banner: "USAGE: #{File.basename($0)} [OPTION]... DIRECTORY"
style:
  short: "-s [style_name]"
  long: "--style [=style_name]"
  description: "Choose the style of output other than default from ascii_art, list, zenkaku or tree"
format:
  short: "-f [format_name]"
  long: "--format [=format_name]"
  description: Choose the output format other than default from csv, tsv, tree_csv
directories:
  short: "-d"
  long: "--directories-only"
  description: "List directories only"
YAML

    def self.parse_command_line_options
      options = { style: :default, format: :default }
      OptionParser.new_with_yaml(OPTIONS) do |opt|
        opt.inherit_ruby_options("E") # -E --encoding

        opt.on(:style) {|style| options[:style] = style.to_sym }
        opt.on(:format) {|format| options[:format] = format.to_sym }
        opt.on(:directories) {|directories| options[:directories] = true }
        opt.parse!
      end
      options
    end

    def self.execute
      options = parse_command_line_options
      col_sep = options[:format] == :csv ? ',' : "\t"
      tree = DumbDownViewer.build_node_tree(ARGV[0])
      prune_files(tree) if options[:directories]
      style = options[:style]
      builder = TreeViewBuilder.create(tree)
      formatter = FORMATTER[options[:format]].new(style, col_sep)
      print formatter.format_table(builder.tree_table)
    end

    def self.prune_files(tree)
      pruner = DumbDownViewer::TreePruner.create {|node| node.directory? }
      pruner.visit(tree, nil)
    end
  end
end
