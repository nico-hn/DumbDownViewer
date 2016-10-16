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

    describe '-P' do
      it '-P displays files whose name matchs a given pattern -- names contain "o"' do
        expected_result = <<RESULT
[spec/data]
├─ [aves]
│   ├─ [can_fly]
│   │   └─ sparrow.txt
│   └─ [cannot_fly]
│        ├─ ostrich.jpg
│        └─ ostrich.txt
└─ [mammalia]
     ├─ [can_fly]
     └─ [cannot_fly]
RESULT

        allow(STDOUT).to receive(:print).with(expected_result)
        set_argv('-P "o" spec/data')
        DumbDownViewer::Cli.execute
      end

      it '-P displays files whose name matchs a given pattern -- names end with ".txt"' do
        expected_result = <<RESULT
[spec/data]
├─ [aves]
│   ├─ [can_fly]
│   │   └─ sparrow.txt
│   └─ [cannot_fly]
│        ├─ ostrich.txt
│        └─ penguin.txt
└─ [mammalia]
     ├─ [can_fly]
     │   └─ bat.txt
     └─ [cannot_fly]
          └─ elephant.txt
RESULT

        allow(STDOUT).to receive(:print).with(expected_result)
        set_argv("-P '\\.txt\\Z' spec/data")
        DumbDownViewer::Cli.execute
      end
    end

    describe '-I' do
      it '-I does not display files whose name matchs a given pattern -- names contain "o"' do
        expected_result = <<RESULT
[spec/data]
├─ README
├─ index.html
├─ [aves]
│   ├─ index.html
│   ├─ [can_fly]
│   └─ [cannot_fly]
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
        set_argv('-I "o" spec/data')
        DumbDownViewer::Cli.execute
      end

      it '-I does not display files whose name matchs a given pattern -- names end with ".txt"' do
        expected_result = <<RESULT
[spec/data]
├─ README
├─ index.html
├─ [aves]
│   ├─ index.html
│   ├─ [can_fly]
│   └─ [cannot_fly]
│        ├─ ostrich.jpg
│        └─ penguin.jpg
└─ [mammalia]
     ├─ index.html
     ├─ [can_fly]
     └─ [cannot_fly]
RESULT

        allow(STDOUT).to receive(:print).with(expected_result)
        set_argv("-I '\\.txt\\Z' spec/data")
        DumbDownViewer::Cli.execute
      end
    end

    describe '--ignore-case' do
      it '-P displays files whose name matchs a given pattern -- with --ignore-case' do
        expected_result = <<RESULT
[spec/data]
├─ [aves]
│   ├─ [can_fly]
│   │   └─ sparrow.txt
│   └─ [cannot_fly]
│        ├─ ostrich.txt
│        └─ penguin.txt
└─ [mammalia]
     ├─ [can_fly]
     │   └─ bat.txt
     └─ [cannot_fly]
          └─ elephant.txt
RESULT

        allow(STDOUT).to receive(:print).with(expected_result)
        set_argv("-P '\\.Txt\\Z' --ignore-case spec/data")
        DumbDownViewer::Cli.execute
      end

      it '-I does not display files whose name matchs a given pattern -- with --ignore-case' do
        expected_result = <<RESULT
[spec/data]
├─ README
├─ index.html
├─ [aves]
│   ├─ index.html
│   ├─ [can_fly]
│   └─ [cannot_fly]
│        ├─ ostrich.jpg
│        └─ penguin.jpg
└─ [mammalia]
     ├─ index.html
     ├─ [can_fly]
     └─ [cannot_fly]
RESULT

        allow(STDOUT).to receive(:print).with(expected_result)
        set_argv("-I '\\.Txt\\Z' --ignore-case spec/data")
        DumbDownViewer::Cli.execute
      end
    end

    describe '--all' do
      it 'dot files are not displayed without --all' do
        expected_result = <<RESULT
[spec/sample_dir]
├─ [abc]
└─ [def]
     ├─ [ghi]
     │   └─ a.html
     └─ [jkl]
          ├─ alpha.png
          ├─ alpha.txt
          ├─ beta.jpg
          └─ beta.txt
RESULT

        allow(STDOUT).to receive(:print).with(expected_result)
        set_argv("spec/sample_dir")
        DumbDownViewer::Cli.execute
      end

      it 'dot files are displayed with --all' do
        expected_result = <<RESULT
[spec/sample_dir]
├─ [abc]
│   └─ .dot_file
└─ [def]
     ├─ [ghi]
     │   └─ a.html
     └─ [jkl]
          ├─ alpha.png
          ├─ alpha.txt
          ├─ beta.jpg
          └─ beta.txt
RESULT

        allow(STDOUT).to receive(:print).with(expected_result)
        set_argv("--all spec/sample_dir")
        DumbDownViewer::Cli.execute
      end
    end

    describe '--filelimit' do
      it '--filelimit 3 does not display directories that have more than 3 entries' do
        expected_result = <<RESULT
[spec/sample_dir]
├─ [abc]
└─ [def]
     └─ [ghi]
          └─ a.html
RESULT

        allow(STDOUT).to receive(:print).with(expected_result)
        set_argv("--filelimit 3 spec/sample_dir")
        DumbDownViewer::Cli.execute
      end

      it '--filelimit 4 directories that have less than 5 entries' do
        expected_result = <<RESULT
[spec/sample_dir]
├─ [abc]
└─ [def]
     ├─ [ghi]
     │   └─ a.html
     └─ [jkl]
          ├─ alpha.png
          ├─ alpha.txt
          ├─ beta.jpg
          └─ beta.txt
RESULT

        allow(STDOUT).to receive(:print).with(expected_result)
        set_argv("--filelimit 4 spec/sample_dir")
        DumbDownViewer::Cli.execute
      end
    end

    describe '--summary' do
      it '--summary adds summary information after the directories that contain files' do
        expected_result = <<RESULT
[spec/sample_dir]
├─ [abc]
└─ [def]
     ├─ [ghi] => html: 1 file
     │   └─ a.html
     └─ [jkl] => png: 1 file, txt: 2 files, jpg: 1 file
          ├─ alpha.png
          ├─ alpha.txt
          ├─ beta.jpg
          └─ beta.txt
RESULT

        allow(STDOUT).to receive(:print).with(expected_result)
        set_argv("--summary spec/sample_dir")
        DumbDownViewer::Cli.execute
      end
    end

    describe '-J' do
      it '-J converts the format of output into JSON' do
        expected_result = <<RESULT
{"type":"directory","name":"sample_dir","contents":[{"type":"directory","name":"abc","contents":[]},{"type":"directory","name":"def","contents":[{"type":"directory","name":"jkl","contents":[{"type":"file","name":"alpha.png"},{"type":"file","name":"beta.txt"},{"type":"file","name":"alpha.txt"},{"type":"file","name":"beta.jpg"}]},{"type":"directory","name":"ghi","contents":[{"type":"file","name":"a.html"}]}]}]}
RESULT

        allow(STDOUT).to receive(:puts).with(expected_result.chomp)
        set_argv("-J spec/sample_dir")
        DumbDownViewer::Cli.execute
      end
    end
  end
end
