require "spec_helper"
require "dumb_dir_view"
require 'dumb_dir_view/visitor'

describe DumbDirView do
  describe DumbDirView::Visitor do
    it 'takes a block and applies it to each node' do
      tree = DumbDirView.build_node_tree('spec/data')
      tree_depth = 0
      depth_checker = DumbDirView::Visitor.new do |node, memo|
        tree_depth = node.depth > memo ? node.depth : memo
      end

      tree.accept(depth_checker, 0)

      image_files = []
      image_file_collector = DumbDirView::Visitor.new do |node, memo|
         if node.kind_of? DumbDirView::FileNode and node.extention == 'jpg'
           image_files.push node.name
         end
      end

      tree.accept(image_file_collector, nil)

      expect(tree_depth).to eq(3)
      expect(image_files).to eq(%w(penguin.jpg ostrich.jpg))
    end
  end
end
