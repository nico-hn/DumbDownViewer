require "spec_helper"
require "dumb_down_viewer"
require 'dumb_down_viewer/visitor'

describe DumbDownViewer do
  describe DumbDownViewer::Visitor do
    it 'takes a block and applies it to each node' do
      tree = DumbDownViewer.build_node_tree('spec/data')
      tree_depth = 0
      depth_checker = DumbDownViewer::Visitor.new do |node, memo|
        tree_depth = node.depth > memo ? node.depth : memo
      end

      tree.accept(depth_checker, 0)

      image_files = []
      image_file_collector = DumbDownViewer::Visitor.new do |node, memo|
         if node.kind_of? DumbDownViewer::FileNode and node.extention == 'jpg'
           image_files.push node.name
         end
      end

      tree.accept(image_file_collector, nil)

      expect(tree_depth).to eq(3)
      expect(image_files).to eq(%w(penguin.jpg ostrich.jpg))
    end

    describe DumbDownViewer::FileCountSummary do
      it 'set #summary of each instance of DirNodes' do
        tree = DumbDownViewer.build_node_tree('spec/data')
        visitor = DumbDownViewer::FileCountSummary.new
        tree.accept(visitor, nil)
        files_without_ext = tree.summary['']
        html_files = tree.summary['html']
        expect(files_without_ext.size).to eq(1)
        expect(files_without_ext[0].name).to eq('README')
        expect(html_files.size).to eq(1)
        expect(html_files[0].name).to eq('index.html')
      end
    end
  end
end
