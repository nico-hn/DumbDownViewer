require 'dumb_dir_view/version'
require 'fileutils'
require 'find'
require 'nokogiri'

module DumbDirView
  class Node
    attr_reader :subnodes, :name

    def initialize(path)
      @subnodes = []
    end

    def accept(visitor, memo)
      visitor.visit(self, memo)
    end
  end

  class DirNode < Node
  end

  class FileNode < Node
  end
end
