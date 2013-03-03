= Wukong-Meta

Wukong-Meta is a Wukong plugin which extracts metadata about models,
processors, flows, and jobs from a deploy pack.

== Installation

Just make sure Wukong-Meta is somewhere in your deploy pack's Gemfile

```ruby
# in Gemfile.rb
gem 'wukong-meta'
```

and do a `bundle update` to ensure the code is installed and availabl
locally within your deploy pack.

== Usage

Wukong-Meta provides the `wu-show` command which can be used to show
metadata.

Try it without any arguments to produce a listing of all models,
processors, flows, and jobs it can find within the deploy pack.

```
$ bundle exec wu-show
```

You can also pass a specific kind of object

```
$ bundle exec wu-show models
$ bundle exec wu-show processors
$ bundle exec wu-show dataflows
$ bundle exec wu-show jobs
```

Or the name of a specific model, processors, dataflow, or job (as
reported in the second column of the above output):

```
$ bundle exec wu-show regexp
```

=== Output Formats

The `wu-show` command can output its data in several different
formats, controlled by the `--to` option.

Try JSON output

```
$ bundle exec wu-show processors --to=json
```

Or TSV (which is 

The default behavior is equivalent to `--to=text`.
