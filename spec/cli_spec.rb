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
  end
end
