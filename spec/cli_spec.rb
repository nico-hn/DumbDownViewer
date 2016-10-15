require "spec_helper"
require "dumb_down_viewer"
require "dumb_down_viewer/cli"

describe DumbDownViewer do
  describe DumbDownViewer::Cli do
    describe '--style' do
      it '--style default' do
        expected_result = <<RESULT
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
RESULT

        allow(STDOUT).to receive(:print).with(expected_result)
        set_argv('-s default spec/data')
        DumbDownViewer::Cli.execute
      end

      it '--style ascii_art' do
        expected_result = <<RESULT
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
RESULT

        allow(STDOUT).to receive(:print).with(expected_result)
        set_argv('-s ascii_art spec/data')
        DumbDownViewer::Cli.execute
      end
    end

    describe '--format' do
      it '--format csv' do
        expected_result = <<RESULT
spec/data,,,
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
RESULT

        allow(STDOUT).to receive(:print).with(expected_result)
        set_argv('--format csv spec/data')
        DumbDownViewer::Cli.execute
      end

      it '--format tsv' do
        expected_result = <<RESULT
spec/data			
	README		
	index.html		
	aves		
		index.html	
		can_fly	
			sparrow.txt
		cannot_fly	
			ostrich.jpg
			ostrich.txt
			penguin.jpg
			penguin.txt
	mammalia		
		index.html	
		can_fly	
			bat.txt
		cannot_fly	
			elephant.txt
RESULT

        allow(STDOUT).to receive(:print).with(expected_result)
        set_argv('--format tsv spec/data')
        DumbDownViewer::Cli.execute
      end

      it '--format tree_csv' do
        expected_result = <<RESULT
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
RESULT

        allow(STDOUT).to receive(:print).with(expected_result)
        set_argv('--format tree_csv spec/data')
        DumbDownViewer::Cli.execute
      end
    end

    describe '--directories-only' do
      it '-d returns a tree of directories' do
        expected_result = <<RESULT
[spec/data]
├─ [aves]
│   ├─ [can_fly]
│   └─ [cannot_fly]
└─ [mammalia]
     ├─ [can_fly]
     └─ [cannot_fly]
RESULT

        allow(STDOUT).to receive(:print).with(expected_result)
        set_argv('-d spec/data')
        DumbDownViewer::Cli.execute
      end
    end

    describe '-L' do
      it '-L 2 displays until the second level of directory tree' do
        expected_result = <<RESULT
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
RESULT

        allow(STDOUT).to receive(:print).with(expected_result)
        set_argv('-L 2 spec/data')
        DumbDownViewer::Cli.execute
      end

      it '-L 1 displays until the first level of directory tree' do
        expected_result = <<RESULT
[spec/data]
├─ README
├─ index.html
├─ [aves]
└─ [mammalia]
RESULT

        allow(STDOUT).to receive(:print).with(expected_result)
        set_argv('-L 1 spec/data')
        DumbDownViewer::Cli.execute
      end

      it '-L 0 returns the root directory' do
        expected_result = <<RESULT
[spec/data]
RESULT

        allow(STDOUT).to receive(:print).with(expected_result)
        set_argv('-L 0 spec/data')
        DumbDownViewer::Cli.execute
      end
    end
  end
end
