# Rukawa
[![Build Status](https://travis-ci.org/joker1007/rukawa.svg?branch=master)](https://travis-ci.org/joker1007/rukawa)

Rukawa = (流川)

This gem is workflow engine and this is hyper simple.
Job is defined by Ruby class.
Dependency of each jobs is defined by Hash.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rukawa'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rukawa

## Usage

### Job Definition

```rb
# jobs/sample_job.rb

module ExecuteLog
  def self.store
    @store ||= {}
  end
end

class SampleJob < Rukawa::Job
  def run
    sleep rand(5)
    ExecuteLog.store[self.class] = Time.now
  end
end

class Job1 < SampleJob
end
class Job2 < SampleJob
end
class Job3 < SampleJob
end
class Job4 < SampleJob
end
class Job5 < SampleJob
  def run
    raise "job5 error"
  end
end
class Job6 < SampleJob
end
class Job7 < SampleJob
end
class Job8 < SampleJob
end

class InnerJob1 < SampleJob
end

class InnerJob2 < SampleJob
  def run
    raise "inner job2 error"
  end
end

class InnerJob3 < SampleJob
end

class InnerJob4 < SampleJob
end

class InnerJob5 < SampleJob
  add_skip_rule ->(job) { job.is_a?(SampleJob) }
end

class InnerJob6 < SampleJob
end
```

### JobNet Definition
```rb
# job_nets/sample_job_net.rb

class InnerJobNet < Rukawa::JobNet
  class << self
    def dependencies
      {
        InnerJob3 => [],
        InnerJob1 => [],
        InnerJob2 => [InnerJob1, InnerJob3],
      }
    end
  end
end

class InnerJobNet2 < Rukawa::JobNet
  class << self
    def dependencies
      {
        InnerJob4 => [],
        InnerJob5 => [],
        InnerJob6 => [InnerJob4, InnerJob5],
      }
    end
  end
end

class SampleJobNet < Rukawa::JobNet
  class << self
    def dependencies
      {
        Job1 => [],
        Job2 => [Job1], Job3 => [Job1],
        Job4 => [Job2, Job3],
        InnerJobNet => [Job3],
        Job8 => [InnerJobNet],
        Job5 => [Job3],
        Job6 => [Job4, Job5],
        Job7 => [Job6],
        InnerJobNet2 => [Job4],
      }
    end
  end
end
```

![jobnet.png](https://raw.githubusercontent.com/joker1007/rukawa/master/sample/jobnet.png)

### Execution

```
% cd rukawa/sample

# load ./jobs/**/*.rb, ./job_net/**/*.rb automatically
% bundle exec rukawa run SampleJobNet -r 5 -d result.dot
+--------------+---------+
| Job          | Status  |
+--------------+---------+
| Job1         | waiting |
| Job2         | waiting |
| Job3         | waiting |
| Job4         | waiting |
| InnerJobNet  | waiting |
|   InnerJob3  | waiting |
|   InnerJob1  | waiting |
|   InnerJob2  | waiting |
| Job8         | waiting |
| Job5         | waiting |
| Job6         | waiting |
| Job7         | waiting |
| InnerJobNet2 | waiting |
|   InnerJob4  | waiting |
|   InnerJob5  | waiting |
|   InnerJob6  | waiting |
+--------------+---------+
+--------------+----------+
| Job          | Status   |
+--------------+----------+
| Job1         | finished |
| Job2         | finished |
| Job3         | finished |
| Job4         | finished |
| InnerJobNet  | running  |
|   InnerJob3  | running  |
|   InnerJob1  | running  |
|   InnerJob2  | waiting  |
| Job8         | waiting  |
| Job5         | error    |
| Job6         | error    |
| Job7         | error    |
| InnerJobNet2 | running  |
|   InnerJob4  | running  |
|   InnerJob5  | skipped  |
|   InnerJob6  | waiting  |
+--------------+----------+
+--------------+----------+
| Job          | Status   |
+--------------+----------+
| Job1         | finished |
| Job2         | finished |
| Job3         | finished |
| Job4         | finished |
| InnerJobNet  | error    |
|   InnerJob3  | finished |
|   InnerJob1  | finished |
|   InnerJob2  | error    |
| Job8         | error    |
| Job5         | error    |
| Job6         | error    |
| Job7         | error    |
| InnerJobNet2 | finished |
|   InnerJob4  | finished |
|   InnerJob5  | skipped  |
|   InnerJob6  | skipped  |
+--------------+----------+

# generate result graph image
% dot -Tpng -o result.png result.dot
```

![jobnet.png](https://raw.githubusercontent.com/joker1007/rukawa/master/sample/result.png)


### Output jobnet graph (dot file)

```
% bundle exec rukawa graph -o SampleJobNet.dot SampleJobNet
% dot -Tpng -o SampleJobNet.png SampleJobNet.dot
```

### help
```
% bundle exec rukawa help run
Usage:
  rukawa run JOB_NET_NAME

Options:
  -c, [--concurrency=N]           # Default: cpu count
      [--variables=key:value]
      [--job-dirs=one two three]  # Load job directories
  -b, [--batch], [--no-batch]     # If batch mode, not display running status
  -l, [--log=LOG]
                                  # Default: ./rukawa.log
  -d, [--dot=DOT]                 # Output job status by dot format
  -r, [--refresh-interval=N]      # Refresh interval for running status information
                                  # Default: 3
```

## ToDo
- Write more tests
- Enable use variables

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec rukawa` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/joker1007/rukawa.

