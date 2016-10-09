require "spec_helper"
require "dumb_down_viewer"
require 'dumb_down_viewer/tree_view_builder'

describe DumbDownViewer do
  describe DumbDownViewer::TreeViewBuilder do
    before do
      @tree = DumbDownViewer.build_node_tree('spec/data')
    end

    it '#setup determines the depth of tree' do
      builder = DumbDownViewer::TreeViewBuilder.new(@tree)

      expect(builder.instance_eval('@tree_depth')).to eq(3)
    end

    it "#new_table_row returns an array whose size is the depth of tree + 1" do
      builder = DumbDownViewer::TreeViewBuilder.new(@tree)
      table_row = builder.new_table_row
      expect(table_row).to eq([nil, nil, nil, nil])
    end

    it '#tree_table has rows and each of them corresponds to a file or directory entry in the tree' do
      builder = DumbDownViewer::TreeViewBuilder.new(@tree)
      @tree.accept(builder, nil)

      expect(builder.tree_table.size).to eq(18)
      expect(builder.tree_table[-1][-1].name).to eq('elephant.txt')
      expect(builder.tree_table[-2][-2].name).to eq('cannot_fly')
    end

    it '.format_table returns a directory tree in plain text' do
      expected_result = <<TABLE
[spec/data]
├─ README
├─ index.html
├─ [aves]
│   ├─ index.html
│   ├─ [can_fly]
│   │   └─ sparrow.txt
│   └─ [cannot_fly]
│        ├─ ostrich.jpg
│        ├─ ostrich.txt
│        ├─ penguin.jpg
│        └─ penguin.txt
└─ [mammalia]
     ├─ index.html
     ├─ [can_fly]
     │   └─ bat.txt
     └─ [cannot_fly]
          └─ elephant.txt
TABLE

      builder = DumbDownViewer::TreeViewBuilder.new(@tree)
      @tree.accept(builder, nil)
      table = builder.tree_table

      result = DumbDownViewer::TreeViewBuilder.format_table(table)

      expect(result).to eq(expected_result)
    end
  end
end

