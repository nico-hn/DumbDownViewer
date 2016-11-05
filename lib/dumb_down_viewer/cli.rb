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
  description: Choose the output format other than default from csv, tsv, tree_csv, json or xml
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
  long: "--summary [=summary_type]"
  description: "Add summary information about directories. Available summary_type: default"
json:
  short: "-J"
  description: "Print out a JSON representation"
xml:
  short: "-X"
  description: "Print out an XML representation"
total_count:
  long: "--report-total-count"
  description: "Display file/directory count at the end of directory listing"
copy_to:
  long: "--copy-to [=dest_dir]"
  description: "Copy the directory tree to dest_dir"
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
        opt.on(:summary) {|summary_type| options[:summary] = summary_type.to_sym }
        opt.on(:json) { options[:json] = true }
        opt.on(:xml) { options[:xml] = true }
        opt.on(:total_count) { options[:total_count] = true }
        opt.on(:copy_to) {|dest_dir| options[:copy_to] = dest_dir }
        opt.parse!
      end
      options
    end

    def self.execute
      options = parse_command_line_options
      tree = DumbDownViewer.build_node_tree(ARGV[0] || '.')
      prune_dot_files(tree) unless options[:show_all]
      prune_dirs_with_more_than(tree, options[:file_limit]) if options[:file_limit]
      prune_level(tree, options[:level]) if options[:level]
      select_match(tree, options) if options[:match]
      ignore_match(tree, options) if options[:ignore_match]
      prune_files(tree) if options[:directories]
      copy_to(tree, options) if options[:copy_to]
      open_output(options[:output]) do |out|
        out.print format_tree(tree, options)
        out.puts total_count(tree) if options[:total_count]
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

    def self.format_json(tree, options)
      json = DumbDownViewer::JSONConverter.dump(tree)
      json + $/
    end

    def self.format_xml(tree, options)
      DumbDownViewer::XMLConverter.dump(tree)
    end

    def self.add_summary(tree, options)
      if summary_type = options[:summary] and summary_type != :default
        STDERR.puts "Unknown option #{summary_type} for --summary: default is used instead."
      end
      visitor = DumbDownViewer::FileCountSummary.new
      tree.accept(visitor, nil)
      DumbDownViewer::FileCountSummary::NodeFormat.new
    end

    def self.format_tree(tree, options)
      if options[:file_limit] and tree.sub_nodes.empty?
        ''
      elsif options[:json] or options[:format] == :json
        format_json(tree, options)
      elsif options[:xml] or options[:format] == :xml
        format_xml(tree, options)
      else
        format_tree_with_builder(tree, options)
      end
    end

    def self.format_tree_with_builder(tree, options)
      style = options[:style]
      col_sep = options[:format] == :tsv ? "\t" : ','
      node_format = options[:summary] ? add_summary(tree, options) : nil
      builder = TreeViewBuilder.create(tree)
      formatter = FORMATTER[options[:format]].new(style, col_sep, node_format)
      formatter.format_table(builder.tree_table)
    end

    def self.total_count(tree)
      count = DumbDownViewer::TotalNodeCount.count(tree)
      "#{$/}#{count[:directories]} directories, #{count[:files]} files"
    end

    def self.copy_to(tree, options)
      DumbDownViewer::TreeDuplicator.duplicate(tree, options[:copy_to])
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
