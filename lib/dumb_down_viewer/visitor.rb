require 'dumb_down_viewer'
require 'json'

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

  class NodeFormat
    def [](node)
      case node
      when DumbDownViewer::DirNode
        format_dir(node)
      when DumbDownViewer::FileNode
        format_file(node)
      end
    end

    def format_dir(node)
      "[#{node.name}]"
    end

    def format_file(node)
      node.name
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

  class FileCountSummary < Visitor
    class NodeFormat < DumbDownViewer::NodeFormat
      def format_dir(node)
        report = "[#{node.name}]"
        data = node.summary
        counts = data.keys.map {|ext| file_count(data, ext) }.join(', ')
        report << " => #{counts}" unless counts.empty?
        report
      end

      def file_count(data, ext)
        count = data[ext].size
        unit = count == 1 ? 'file'.freeze : 'files'.freeze
        ext = '(misc)'.freeze if ext.empty?
        "#{ext}: #{count} #{unit}"
      end
    end

    def visit_dir_node(node, memo)
      node.summary = node.files.group_by {|file| file.extention }
      visit_sub_nodes(node, memo)
    end
  end

  TotalNodeCount = Visitor.create do |node, memo|
    memo[node.class] += 1
    memo
  end

  def TotalNodeCount.count(tree)
    counter = Hash.new(0)
    tree.accept(self, counter)
    { directories: counter[DirNode] - 1, files: counter[FileNode] }
  end

  class JSONConverter
    def self.dump(tree, with_path=false)
      JSON.dump(new.visit(tree, with_path))
    end

    def visit(node, with_path=false)
      case node
      when DirNode
        {
          type: 'directory', name: name_value(node, with_path),
          contents: node.sub_nodes.map {|n| n.accept(self, with_path) }
        }
      when FileNode
        { type: 'file', name: name_value(node, with_path) }
      end
    end

    private

    def name_value(node, with_path)
      if with_path
        File.join(node.directory, node.name)
      else
        node.name
      end
    end
  end

  class XMLConverter
    attr_reader :doc, :tree_root
    XML_TEMPLATE = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<tree>
</tree>
XML

    def visit(node, with_path)
      case node
      when DirNode
        create_dir_element(node, with_path).tap do |elm|
          node.sub_nodes.each do |n|
            n.accept(self, with_path).parent = elm
          end
        end
      when FileNode
        create_file_element(node, with_path)
      end
    end

    def create_doc
      @doc = Nokogiri::XML(XML_TEMPLATE).tap do |doc|
        @tree_root = doc.at_xpath('//tree')
      end
    end

    def create_dir_element(node, with_path)
      Nokogiri::XML::Node.new('directory'.freeze, @doc).tap do |elm|
        elm['name'.freeze] = node.name
      end
    end

    def create_file_element(node, with_path)
      Nokogiri::XML::Node.new('file'.freeze, @doc).tap do |elm|
        elm['name'.freeze] = node.name
        elm.content = ' '.freeze
      end
    end
  end
end
