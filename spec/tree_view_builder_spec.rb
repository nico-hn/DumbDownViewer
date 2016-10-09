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
  end
end

