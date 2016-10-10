require 'dumb_down_viewer/version'
require 'fileutils'
require 'find'
require 'nokogiri'

module DumbDownViewer
  def self.collect_directories_and_files(path)
    entries = Dir.entries(path) - ['.', '..']
    entries.partition do |entry|
      entry_path = File.expand_path(File.join(path, entry))
      File.directory? entry_path
    end
  end

  def self.build_node_tree(dir)
    dirname, filename = File.split(dir)
    DirNode.new(dirname, filename, 0).tap {|dir| dir.collect_entries }
  end

  class Node
    attr_reader :sub_nodes, :directory, :name, :depth

    def initialize(pwd, name, depth)
      @directory = pwd
      @name = name
      @depth = depth
      @name_with_path = pwd.empty? ? @name : File.join(pwd, name)
      setup
    end

    def setup
    end

    def accept(visitor, memo)
      visitor.visit(self, memo)
    end

    def to_s
      @name
    end

    def directory?
      kind_of? DirNode
    end

    def file?
      kind_of? FileNode
    end
  end

  class DirNode < Node
    attr_reader :directories, :files

    def sub_nodes
      (@files + @directories).freeze
    end

    def collect_entries
      dirs, files = DumbDownViewer.collect_directories_and_files(@name_with_path)
      depth = @depth + 1
      @directories = entry_nodes(dirs, DirNode, depth)
      @directories.each {|dir| dir.collect_entries }
      @files = entry_nodes(files, FileNode, depth)
    end

    def entry_nodes(nodes, node_class, depth)
      nodes.map {|node| node_class.new(@name_with_path, node, depth) }
    end
  end

  class FileNode < Node
    attr_reader :extention
    def setup
      extract_extention
      @sub_nodes = [].freeze
    end

    private

    def extract_extention
      m = /\.([^.]+)\Z/.match(@name)
      @extention = m ? m[1] : ''
    end
  end
end
