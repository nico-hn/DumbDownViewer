require "spec_helper"
require "dumb_dir_view"
require 'dumb_dir_view/tree_view_builder'

describe DumbDirView do
  describe DumbDirView::TreeViewBuilder do
    before do
      @tree = DumbDirView.build_node_tree('spec/data')
    end

    it '#setup determines the depth of tree' do
      builder = DumbDirView::TreeViewBuilder.new(@tree)

      expect(builder.instance_eval('@tree_depth')).to eq(3)
    end

    it "#new_table_row returns an array whose size is the depth of tree + 1" do
      builder = DumbDirView::TreeViewBuilder.new(@tree)
      table_row = builder.new_table_row
      expect(table_row).to eq([nil, nil, nil, nil])
    end

    it '#tree_table has rows and each of them corresponds to a file or directory entry in the tree' do
      builder = DumbDirView::TreeViewBuilder.new(@tree)
      @tree.accept(builder, nil)

      expect(builder.tree_table.size).to eq(18)
      expect(builder.tree_table[-1][-1].name).to eq('elephant.txt')
      expect(builder.tree_table[-2][-2].name).to eq('cannot_fly')
    end
  end
end

