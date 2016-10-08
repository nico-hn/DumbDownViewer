require "spec_helper"

describe DumbDirView do
  it "has a version number" do
    expect(DumbDirView::VERSION).not_to be nil
  end

  it '.build_node_tree builds a tree of instances of DirNode and FileNode' do
    tree = DumbDirView.build_node_tree('spec/data')
    dirnames = tree.directories.map {|dir| dir.name }
    filenames = tree.files.map {|file| file.name }
    sub_dirnames = tree.directories[0].directories.map {|dir| dir.name }
    expect(dirnames).to eq(%w(mammalia aves))
    expect(filenames).to eq(%w(README index.html))
    expect(sub_dirnames).to eq(%w(can_fly cannot_fly))
  end

  describe DumbDirView::FileNode do
    it '#extention returns file extention' do
      tree = DumbDirView.build_node_tree('spec/data')
      files = tree.files

      expect(files[0].extention).to eq('')
      expect(files[1].extention).to eq('html')
    end
  end
end
