# DumbDownViewer

DumbDownViewer (ddv) is a recursive directory listing command with limited functionality.

In some case, you can use ddv like "[tree](http://mama.indstate.edu/users/ice/tree/)" command, even though these commands are not compatible:

Several options of "tree" are missing in ddv, but there are also some options that are available only in ddv (such as --copy-to).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dumb_down_viewer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dumb_down_viewer

## Usage

Suppose you have a directory `spec/data`

    $ find spec/data
    spec/data
    spec/data/README
    spec/data/index.html
    spec/data/mammalia
    spec/data/mammalia/can_fly
    spec/data/mammalia/can_fly/bat.txt
    spec/data/mammalia/index.html
    spec/data/mammalia/cannot_fly
    spec/data/mammalia/cannot_fly/elephant.txt
    spec/data/aves
    spec/data/aves/can_fly
    spec/data/aves/can_fly/sparrow.txt
    spec/data/aves/index.html
    spec/data/aves/cannot_fly
    spec/data/aves/cannot_fly/penguin.jpg
    spec/data/aves/cannot_fly/penguin.txt
    spec/data/aves/cannot_fly/ostrich.txt
    spec/data/aves/cannot_fly/ostrich.jpg


Then type at the command line (or replace `spec/data` with a directory name which is on your system):

    $ ddv spec/data

And you will get something like the following

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

### Options

The following is the list of available options:

|Short |Long |Description |
|------|-----|------------|
|-s [style_name] |--style [=style_name] |Choose the style of output other than default from ascii_art, list, zenkaku or tree |
|-f [format_name] |--format [=format_name] |Choose the output format other than default from csv, tsv or tree_csv |
|-d |--directories-only |List directories only |
|-L [level] |- |Descend only level directories deep |
|-P [pattern] |- |List only those files that match the given pattern |
|-I [pattern] |- |Do not list files that match the given pattern |
|-a |--all |Show all files including dot files |
|- |--ignore-case |Ignore case when pattern matching |
|-o [output_file] |--output [=output_file] |Output to file instead of stdout |
|- |--filelimit [=number_of_files] |Do not descend dirs with more than the specified number of files in them |
|- |--summary [=summary_type] |Add summary information about directories. Available summary_type: default |
|-J |- |Print out a JSON representation |
|-X |- |Print out an XML representation |
|- |--report-total-count |Display file/directory count at the end of directory listing |
|- |--copy-to [=dest_dir] |Copy the directory tree to dest_dir |


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nico-hn/DumbDownViewer.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

