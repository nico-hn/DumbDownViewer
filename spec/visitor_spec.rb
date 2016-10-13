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

      it 'NodeFormat#[] handles appropriately summaries gathered by FileCountSummary' do
        tree = DumbDownViewer.build_node_tree('spec/data')
        visitor = DumbDownViewer::FileCountSummary.new
        tree.accept(visitor, nil)
        node_format = DumbDownViewer::FileCountSummary::NodeFormat.new
        expect(node_format[tree]).to eq('[data] => (misc): 1 file, html: 1 file')
        expect(node_format[tree.directories[1].directories[1]]).to eq('[cannot_fly] => jpg: 2 files, txt: 2 files')
      end

      it 'NodeFormat#[] does not add summary information if there is no file in a directory' do
        tree = DumbDownViewer.build_node_tree('spec/sample_dir/def')
        visitor = DumbDownViewer::FileCountSummary.new
        tree.accept(visitor, nil)
        node_format = DumbDownViewer::FileCountSummary::NodeFormat.new
        expect(node_format[tree]).to eq('[def]')
      end
    end

    describe DumbDownViewer::TotalNodeCount do
      it '.count returns a Hash that contains the number of directories/files under the given directory' do
        tree = DumbDownViewer.build_node_tree('spec/data')
        counter = DumbDownViewer::TotalNodeCount.count(tree)

        expect(counter).to eq({ directories: 6, files: 11 })
      end
    end

    describe DumbDownViewer::JSONConverter do
      it 'converts a given directory tree into a JSON representation' do
        expected_json = '{"type":"directory","name":"data","contents":[{"type":"file","name":"README"},{"type":"file","name":"index.html"},{"type":"directory","name":"mammalia","contents":[{"type":"file","name":"index.html"},{"type":"directory","name":"can_fly","contents":[{"type":"file","name":"bat.txt"}]},{"type":"directory","name":"cannot_fly","contents":[{"type":"file","name":"elephant.txt"}]}]},{"type":"directory","name":"aves","contents":[{"type":"file","name":"index.html"},{"type":"directory","name":"can_fly","contents":[{"type":"file","name":"sparrow.txt"}]},{"type":"directory","name":"cannot_fly","contents":[{"type":"file","name":"penguin.jpg"},{"type":"file","name":"penguin.txt"},{"type":"file","name":"ostrich.txt"},{"type":"file","name":"ostrich.jpg"}]}]}]}'

        tree = DumbDownViewer.build_node_tree('spec/data')
        json = DumbDownViewer::JSONConverter.dump(tree)

        expect(json).to eq(expected_json)
      end

      it 'appends path to the value of "name" field, when the second argument of #dump is true' do
        expected_json = '{"type":"directory","name":"spec/data","contents":[{"type":"file","name":"spec/data/README"},{"type":"file","name":"spec/data/index.html"},{"type":"directory","name":"spec/data/mammalia","contents":[{"type":"file","name":"spec/data/mammalia/index.html"},{"type":"directory","name":"spec/data/mammalia/can_fly","contents":[{"type":"file","name":"spec/data/mammalia/can_fly/bat.txt"}]},{"type":"directory","name":"spec/data/mammalia/cannot_fly","contents":[{"type":"file","name":"spec/data/mammalia/cannot_fly/elephant.txt"}]}]},{"type":"directory","name":"spec/data/aves","contents":[{"type":"file","name":"spec/data/aves/index.html"},{"type":"directory","name":"spec/data/aves/can_fly","contents":[{"type":"file","name":"spec/data/aves/can_fly/sparrow.txt"}]},{"type":"directory","name":"spec/data/aves/cannot_fly","contents":[{"type":"file","name":"spec/data/aves/cannot_fly/penguin.jpg"},{"type":"file","name":"spec/data/aves/cannot_fly/penguin.txt"},{"type":"file","name":"spec/data/aves/cannot_fly/ostrich.txt"},{"type":"file","name":"spec/data/aves/cannot_fly/ostrich.jpg"}]}]}]}'

        tree = DumbDownViewer.build_node_tree('spec/data')
        json = DumbDownViewer::JSONConverter.dump(tree, true)

        expect(json).to eq(expected_json)
      end
    end

    describe DumbDownViewer::XMLConverter do
      it '#create_doc assigns XMLConverter#doc and #tree_root' do
        expected_doc = <<DOC
<?xml version="1.0" encoding="UTF-8"?>
<tree/>
DOC
        expected_tree_root = '<tree/>'

        visitor = DumbDownViewer::XMLConverter.new
        doc = visitor.create_doc
        tree_root = visitor.tree_root

        expect(doc.to_xml).to eq(expected_doc)
        expect(tree_root.to_xml).to eq(expected_tree_root)
      end

      it '#visit returns tree of directories/files in XML representation' do
        expected_xml = <<XML
<directory name="data">
  <file name="README"> </file>
  <file name="index.html"> </file>
  <directory name="mammalia">
    <file name="index.html"> </file>
    <directory name="can_fly">
      <file name="bat.txt"> </file>
    </directory>
    <directory name="cannot_fly">
      <file name="elephant.txt"> </file>
    </directory>
  </directory>
  <directory name="aves">
    <file name="index.html"> </file>
    <directory name="can_fly">
      <file name="sparrow.txt"> </file>
    </directory>
    <directory name="cannot_fly">
      <file name="penguin.jpg"> </file>
      <file name="penguin.txt"> </file>
      <file name="ostrich.txt"> </file>
      <file name="ostrich.jpg"> </file>
    </directory>
  </directory>
</directory>
XML

        tree = DumbDownViewer.build_node_tree('spec/data')

        visitor = DumbDownViewer::XMLConverter.new
        visitor.create_doc
        xml = visitor.visit(tree, false)

        expect(xml.to_xml).to eq(expected_xml.chomp)
      end

      it '.dump returns tree of directories/files in XML representation' do
        expected_xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<tree>
  <directory name="data">
    <file name="README"></file>
    <file name="index.html"></file>
    <directory name="mammalia">
      <file name="index.html"></file>
      <directory name="can_fly">
        <file name="bat.txt"></file>
      </directory>
      <directory name="cannot_fly">
        <file name="elephant.txt"></file>
      </directory>
    </directory>
    <directory name="aves">
      <file name="index.html"></file>
      <directory name="can_fly">
        <file name="sparrow.txt"></file>
      </directory>
      <directory name="cannot_fly">
        <file name="penguin.jpg"></file>
        <file name="penguin.txt"></file>
        <file name="ostrich.txt"></file>
        <file name="ostrich.jpg"></file>
      </directory>
    </directory>
  </directory>
</tree>
XML

        tree = DumbDownViewer.build_node_tree('spec/data')

        xml = DumbDownViewer::XMLConverter.dump(tree, false)

        expect(xml).to eq(expected_xml)
      end

      it '.dump appends path to the value of "name" field, when the second argument of #dump is true' do
        expected_xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<tree>
  <directory name="spec/data">
    <file name="spec/data/README"></file>
    <file name="spec/data/index.html"></file>
    <directory name="spec/data/mammalia">
      <file name="spec/data/mammalia/index.html"></file>
      <directory name="spec/data/mammalia/can_fly">
        <file name="spec/data/mammalia/can_fly/bat.txt"></file>
      </directory>
      <directory name="spec/data/mammalia/cannot_fly">
        <file name="spec/data/mammalia/cannot_fly/elephant.txt"></file>
      </directory>
    </directory>
    <directory name="spec/data/aves">
      <file name="spec/data/aves/index.html"></file>
      <directory name="spec/data/aves/can_fly">
        <file name="spec/data/aves/can_fly/sparrow.txt"></file>
      </directory>
      <directory name="spec/data/aves/cannot_fly">
        <file name="spec/data/aves/cannot_fly/penguin.jpg"></file>
        <file name="spec/data/aves/cannot_fly/penguin.txt"></file>
        <file name="spec/data/aves/cannot_fly/ostrich.txt"></file>
        <file name="spec/data/aves/cannot_fly/ostrich.jpg"></file>
      </directory>
    </directory>
  </directory>
</tree>
XML

        tree = DumbDownViewer.build_node_tree('spec/data')

        xml = DumbDownViewer::XMLConverter.dump(tree, true)

        expect(xml).to eq(expected_xml)
      end
    end
  end
end
