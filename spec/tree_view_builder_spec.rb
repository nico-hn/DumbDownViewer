require "spec_helper"
require "dumb_down_viewer"
require 'dumb_down_viewer/tree_view_builder'

describe DumbDownViewer do
  describe DumbDownViewer::TreeViewBuilder do
    before do
      @tree = DumbDownViewer.build_node_tree('spec/data')

      @expected_plain_text = <<TABLE
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

      @expected_ascii_art = <<TABLE
[spec/data]
|-- README
|-- index.html
|-- [aves]
|   |-- index.html
|   |-- [can_fly]
|   |   `-- sparrow.txt
|   `-- [cannot_fly]
|       |-- ostrich.jpg
|       |-- ostrich.txt
|       |-- penguin.jpg
|       `-- penguin.txt
`-- [mammalia]
    |-- index.html
    |-- [can_fly]
    |   `-- bat.txt
    `-- [cannot_fly]
        `-- elephant.txt
TABLE
      #` this comment is a workaround for syntax highlighting

      @expected_list = <<TABLE
[spec/data]
 * README
 * index.html
 * [aves]
    * index.html
    * [can_fly]
       * sparrow.txt
    * [cannot_fly]
       * ostrich.jpg
       * ostrich.txt
       * penguin.jpg
       * penguin.txt
 * [mammalia]
    * index.html
    * [can_fly]
       * bat.txt
    * [cannot_fly]
       * elephant.txt
TABLE

      @expected_zenkaku = <<TABLE
[spec/data]
├─ README
├─ index.html
├─ [aves]
│　 ├─ index.html
│　 ├─ [can_fly]
│　 │　 └─ sparrow.txt
│　 └─ [cannot_fly]
│　 　　 ├─ ostrich.jpg
│　 　　 ├─ ostrich.txt
│　 　　 ├─ penguin.jpg
│　 　　 └─ penguin.txt
└─ [mammalia]
　　 ├─ index.html
　　 ├─ [can_fly]
　　 │　 └─ bat.txt
　　 └─ [cannot_fly]
　　 　　 └─ elephant.txt
TABLE

      @expected_tree_compatible = <<TABLE
[spec/data]
├── README
├── index.html
├── [aves]
│   ├── index.html
│   ├── [can_fly]
│   │   └── sparrow.txt
│   └── [cannot_fly]
│       ├── ostrich.jpg
│       ├── ostrich.txt
│       ├── penguin.jpg
│       └── penguin.txt
└── [mammalia]
    ├── index.html
    ├── [can_fly]
    │   └── bat.txt
    └── [cannot_fly]
        └── elephant.txt
TABLE

      @expected_tree_csv = <<CSV
[spec/data],,,
├─ ,README,,
├─ ,index.html,,
├─ ,[aves],,
│   ,├─ ,index.html,
│   ,├─ ,[can_fly],
│   ,│   ,└─ ,sparrow.txt
│   ,└─ ,[cannot_fly],
│   ,,├─ ,ostrich.jpg
│   ,,├─ ,ostrich.txt
│   ,,├─ ,penguin.jpg
│   ,,└─ ,penguin.txt
└─ ,[mammalia],,
,├─ ,index.html,
,├─ ,[can_fly],
,│   ,└─ ,bat.txt
,└─ ,[cannot_fly],
,,└─ ,elephant.txt
CSV

      @expected_csv = <<CSV
data,,,
,README,,
,index.html,,
,aves,,
,,index.html,
,,can_fly,
,,,sparrow.txt
,,cannot_fly,
,,,ostrich.jpg
,,,ostrich.txt
,,,penguin.jpg
,,,penguin.txt
,mammalia,,
,,index.html,
,,can_fly,
,,,bat.txt
,,cannot_fly,
,,,elephant.txt
CSV
    end

    it '#setup determines the depth of tree' do
      builder = DumbDownViewer::TreeViewBuilder.new
      builder.determine_depth(@tree)

      expect(builder.instance_eval('@tree_depth')).to eq(3)
    end

    it '#directory? and #file? returns opposite value for a given node' do
      dir = @tree
      file = @tree.sub_nodes[0]

      expect(@tree.directory?).to be_truthy
      expect(file.directory?).to be_falsy
      expect(@tree.file?).to be_falsy
      expect(file.file?).to be_truthy
    end

    it "#new_table_row returns an array whose size is the depth of tree + 1" do
      builder = DumbDownViewer::TreeViewBuilder.create(@tree)
      table_row = builder.new_table_row
      expect(table_row).to eq([nil, nil, nil, nil])
    end

    it '#tree_table has rows and each of them corresponds to a file or directory entry in the tree' do
      builder = DumbDownViewer::TreeViewBuilder.create(@tree)

      expect(builder.tree_table.size).to eq(18)
      expect(builder.tree_table[-1][-1].name).to eq('elephant.txt')
      expect(builder.tree_table[-2][-2].name).to eq('cannot_fly')
    end

    it '#format returns a directory tree in plain text by default' do
      builder = DumbDownViewer::TreeViewBuilder.create(@tree)
      result = builder.format

      expect(result).to eq(@expected_plain_text)
    end

    it 'PlainTextFormat.format_table returns a directory tree in plain text' do
      builder = DumbDownViewer::TreeViewBuilder.create(@tree)
      table = builder.tree_table

      result = DumbDownViewer::TreeViewBuilder::PlainTextFormat.new.format_table(table)

      expect(result).to eq(@expected_plain_text)
    end

    it 'PlainTextFormat.format_table returns a directory tree in plain text -- ascii_art' do
      builder = DumbDownViewer::TreeViewBuilder.create(@tree)
      table = builder.tree_table

      result = DumbDownViewer::TreeViewBuilder::PlainTextFormat.new(:ascii_art).format_table(table)

      expect(result).to eq(@expected_ascii_art)
    end

    it 'PlainTextFormat.format_table returns a directory tree in plain text -- list' do
      builder = DumbDownViewer::TreeViewBuilder.create(@tree)
      table = builder.tree_table

      result = DumbDownViewer::TreeViewBuilder::PlainTextFormat.new(:list).format_table(table)

      expect(result).to eq(@expected_list)
    end

    it 'PlainTextFormat.format_table returns a directory tree in plain text -- zenkaku' do
      builder = DumbDownViewer::TreeViewBuilder.create(@tree)
      table = builder.tree_table

      result = DumbDownViewer::TreeViewBuilder::PlainTextFormat.new(:zenkaku).format_table(table)

      expect(result).to eq(@expected_zenkaku)
    end

    it 'PlainTextFormat.format_table returns a directory tree in plain text -- tree' do
      builder = DumbDownViewer::TreeViewBuilder.create(@tree)
      table = builder.tree_table

      result = DumbDownViewer::TreeViewBuilder::PlainTextFormat.new(:tree).format_table(table)

      expect(result).to eq(@expected_tree_compatible)
    end

    it 'TreeCSVFormat.format_table returns a directory tree in CSV format' do
      builder = DumbDownViewer::TreeViewBuilder.create(@tree)
      table = builder.tree_table

      result = DumbDownViewer::TreeViewBuilder::TreeCSVFormat.new.format_table(table)

      expect(result).to eq(@expected_tree_csv)
    end

    it 'CSVFormat.format_table returns a directory tree in CSV format' do
      builder = DumbDownViewer::TreeViewBuilder.create(@tree)
      table = builder.tree_table

      result = DumbDownViewer::TreeViewBuilder::CSVFormat.new.format_table(table)

      expect(result).to eq(@expected_csv)
    end

    it 'TreePruner removes nodes that match given criteria' do
      expected_result = <<TABLE
[spec/data]
├─ [aves]
│   ├─ [can_fly]
│   └─ [cannot_fly]
│        ├─ ostrich.jpg
│        └─ penguin.jpg
└─ [mammalia]
     ├─ [can_fly]
     └─ [cannot_fly]
TABLE

      tree = DumbDownViewer.build_node_tree('spec/data')
      pruner = DumbDownViewer::TreePruner.create {|node| node.kind_of? DumbDownViewer::DirNode or /\.jpg\Z/ =~ node.name }
      pruner.visit(tree, nil)
      builder = DumbDownViewer::TreeViewBuilder.create(tree)
      table = builder.tree_table

      result = DumbDownViewer::TreeViewBuilder::PlainTextFormat.new.format_table(table)
      expect(result).to eq(expected_result)
    end

    it 'with PlainTextFormat.format_table directories at the bottom of tree should be enclosed in [] ' do
      expected_result = <<TABLE
[spec/data]
├─ README
├─ index.html
├─ [aves]
│   ├─ index.html
│   ├─ [can_fly]
│   └─ [cannot_fly]
└─ [mammalia]
     ├─ index.html
     ├─ [can_fly]
     └─ [cannot_fly]
TABLE

      tree = DumbDownViewer.build_node_tree('spec/data')
      pruner = DumbDownViewer::TreePruner.create {|node| node.depth <= 2 }
      pruner.visit(tree, nil)
      builder = DumbDownViewer::TreeViewBuilder.create(tree)

      result = DumbDownViewer::TreeViewBuilder::PlainTextFormat.new.format_table(builder.tree_table)

      expect(result).to eq(expected_result)
    end
  end
end
