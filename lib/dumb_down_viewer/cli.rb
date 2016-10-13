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
level:
  short: "-L [level]"
  description: "Descend only level directories deep"
match:
  short: "-P [pattern]"
  description: "List only those files that match the pattern given"
ignore_match:
  short: "-I [pattern]"
  description: "Do not list files that match the given pattern"
show_all:
  short: "-a"
  long: "--all"
  description: "Show all files including dot files"
ignore_case:
  long: "--ignore-case"
  description: "Ignore case when pattern matching"
output:
  short: "-o [output_file]"
  long: "--output [=output_file]"
  description: "Output to file instead of stdout"
file_limit:
  long: "--filelimit [=number_of_files]"
  description: "Do not descend dirs with more than the specified number of files in them"
summary:
  long: "--summary"
  description: "Add summary information about directories"
json:
  short: "-J"
  description: "Print out a JSON representation"
xml:
  short: "-X"
  description: "Print out an XML representation"
YAML

    def self.parse_command_line_options
      options = { style: :default, format: :default }
      OptionParser.new_with_yaml(OPTIONS) do |opt|
        opt.version = DumbDownViewer::VERSION
        opt.inherit_ruby_options("E") # -E --encoding

        opt.on(:style) {|style| options[:style] = style.to_sym }
        opt.on(:format) {|format| options[:format] = format.to_sym }
        opt.on(:directories) {|directories| options[:directories] = true }
        opt.on(:level) {|level| options[:level] = level.to_i }
        opt.on(:match) {|pattern| options[:match] = pattern }
        opt.on(:ignore_match) {|pattern| options[:ignore_match] = pattern }
        opt.on(:show_all) { options[:show_all] = true }
        opt.on(:ignore_case) { options[:ignore_case] = true }
        opt.on(:output) {|output_file| options[:output] = output_file }
        opt.on(:file_limit) {|number_of_files| options[:file_limit] = number_of_files.to_i }
        opt.on(:summary) { options[:summary] = true }
        opt.on(:json) { options[:json] = true }
        opt.on(:xml) { options[:xml] = true }
        opt.parse!
      end
      options
    end

    def self.execute
      options = parse_command_line_options
      col_sep = options[:format] == :csv ? ',' : "\t"
      tree = DumbDownViewer.build_node_tree(ARGV[0])
      prune_dot_files(tree) unless options[:show_all]
      prune_dirs_with_more_than(tree, options[:file_limit]) if options[:file_limit]
      prune_level(tree, options[:level]) if options[:level]
      select_match(tree, options) if options[:match]
      ignore_match(tree, options) if options[:ignore_match]
      node_format = options[:summary] ? add_summary(tree) : nil
      prune_files(tree) if options[:directories]
      print_json(tree, options) if options[:json]
      print_xml(tree, options) if options[:xml]
      style = options[:style]
      builder = TreeViewBuilder.create(tree)
      formatter = FORMATTER[options[:format]].new(style, col_sep, node_format)
      open_output(options[:output]) do |out|
        result = if options[:file_limit] and tree.sub_nodes.empty?
                   ''
                 else
                   formatter.format_table(builder.tree_table)
                 end
        out.print result
      end
    end

    def self.prune_dot_files(tree)
      pruner = DumbDownViewer::TreePruner.create(false) {|node| node.name.start_with? '.' }
      pruner.visit(tree, nil)
    end

    def self.prune_files(tree)
      pruner = DumbDownViewer::TreePruner.create {|node| node.directory? }
      pruner.visit(tree, nil)
    end

    def self.prune_level(tree, level)
      pruner = DumbDownViewer::TreePruner.create {|node| node.depth <= level }
      pruner.visit(tree, nil)
    end

    def self.select_match(tree, options)
      pat = Regexp.compile(options[:match], options[:ignore_case])
      pruner = DumbDownViewer::TreePruner.create {|node| node.directory? or pat =~ node.name }
      pruner.visit(tree, nil)
    end

    def self.ignore_match(tree, options)
      pat = Regexp.compile(options[:ignore_match], options[:ignore_case])
      pruner = DumbDownViewer::TreePruner.create(false) {|node| not node.directory? and pat =~ node.name }
      pruner.visit(tree, nil)
    end

    def self.prune_dirs_with_more_than(tree, number_of_files)
      pruner = DumbDownViewer::TreePruner.create(false) do |node|
        node.directory? and node.sub_nodes.size > number_of_files
      end
      if tree.sub_nodes.size > number_of_files
        tree.directories.clear
        tree.files.clear
      end
      pruner.visit(tree, nil)
    end

    def self.print_json(tree, options)
      json = DumbDownViewer::JSONConverter.dump(tree)
      open_output(options[:output]) do |out|
        out.puts json
      end
      exit
    end

    def self.print_xml(tree, options)
      xml = DumbDownViewer::XMLConverter.dump(tree)
      open_output(options[:output]) do |out|
        out.puts xml
      end
      exit
    end

    def self.add_summary(tree)
      visitor = DumbDownViewer::FileCountSummary.new
      tree.accept(visitor, nil)
      DumbDownViewer::FileCountSummary::NodeFormat.new
    end

    def self.open_output(filename)
      if filename
        open(File.expand_path(filename), "wb") do |out|
          yield out
        end
      else
        yield STDOUT
      end
    end
  end
end
