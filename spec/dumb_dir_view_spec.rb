require "spec_helper"

describe DumbDownViewer do
  it "has a version number" do
    expect(DumbDownViewer::VERSION).not_to be nil
  end

  it '.build_node_tree builds a tree of instances of DirNode and FileNode' do
    tree = DumbDownViewer.build_node_tree('spec/data')
    dirnames = tree.directories.map {|dir| dir.name }
    filenames = tree.files.map {|file| file.name }
    sub_dirnames = tree.directories[0].directories.map {|dir| dir.name }
    expect(dirnames).to eq(%w(mammalia aves))
    expect(filenames).to eq(%w(README index.html))
    expect(sub_dirnames).to eq(%w(can_fly cannot_fly))
  end

  describe DumbDownViewer::Node do
    it '#depth is set to 0 for the root node' do
      tree = DumbDownViewer.build_node_tree('spec/data')

      expect(tree.depth).to eq(0)
    end

    it '#depth is set to 1 for nodes in the second level' do
      tree = DumbDownViewer.build_node_tree('spec/data')

      expect(tree.directories[0].depth).to eq(1)
      expect(tree.files[0].depth).to eq(1)
    end

    it '#depth is set to 2 for nodes in the third level' do
      tree = DumbDownViewer.build_node_tree('spec/data')

      expect(tree.directories[0].directories[0].depth).to eq(2)
      expect(tree.directories[0].files[0].depth).to eq(2)
    end
  end

  describe DumbDownViewer::FileNode do
    it '#extention returns file extention' do
      tree = DumbDownViewer.build_node_tree('spec/data')
      files = tree.files

      expect(files[0].extention).to eq('')
      expect(files[1].extention).to eq('html')
    end
  end
end
