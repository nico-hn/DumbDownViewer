require 'dumb_dir_view/version'
require 'fileutils'
require 'find'
require 'nokogiri'

module DumbDirView
  def self.collect_directories_and_files(path)
    entries = Dir.entries(path) - ['.', '..']
    entries.partition do |entry|
      entry_path = File.expand_path(File.join(path, entry))
      File.directory? entry_path
    end
  end

  def self.build_node_tree(dir)
    dirname, filename = File.split(dir)
    DirNode.new(dirname, filename)
  end

  class Node
    attr_reader :directory, :name

    def initialize(pwd, name)
      @directory = pwd
      @name = name
      @name_with_path = pwd.empty? ? @name : File.join(pwd, name)
      setup
    end

    def setup
    end

    def accept(visitor, memo)
      visitor.visit(self, memo)
    end
  end

  class DirNode < Node
    attr_reader :sub_nodes, :directories, :files

    def setup
      collect_entries
    end

    def collect_entries
      dirs, files = DumbDirView.collect_directories_and_files(@name_with_path)
      @directories = dirs.map {|dir| DirNode.new(@name_with_path, dir) }
      @files = files.map {|file| FileNode.new(@name_with_path, file) }
      @sub_nodes = @files + @directories
    end
  end

  class FileNode < Node
  end
end
