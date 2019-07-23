# BatchProcessor

Define your collection, job, and callbacks all in one clear and concise object

[![Gem Version](https://badge.fury.io/rb/batch_processor.svg)](https://badge.fury.io/rb/batch_processor)
[![Build Status](https://semaphoreci.com/api/v1/freshly/batch_processor/branches/master/badge.svg)](https://semaphoreci.com/freshly/batch_processor)
[![Maintainability](https://api.codeclimate.com/v1/badges/fbdaeaf118a16a55ab7d/maintainability)](https://codeclimate.com/github/Freshly/batch_processor/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/fbdaeaf118a16a55ab7d/test_coverage)](https://codeclimate.com/github/Freshly/batch_processor/test_coverage)

* [Installation](#installation)
* [Getting Started](#getting-started)
* [What is BatchProcessor?](#what-is-batchprocessor)
* [How It Works](#how-it-works)
   * [Batches](#batches)
      * [Collection](#collection)
         * [Input](#input)
         * [Validations](#validations)
      * [ActiveJob](#activejob)
      * [Details](#details)
      * [Status](#status)
      * [Callbacks](#callbacks)
   * [Processors](#processors)
      * [Parallel Processor](#parallel-processor)
         * [Processor Options](#processor-options)
      * [Sequential Processor](#sequential-processor)
         * [Processor Options](#processor-options-1)
   * [Jobs](#jobs)
      * [Handling Errors](#handling-errors)
* [Testing](#testing)
   * [Testing Setup](#testing-setup)
   * [Testing Batches](#testing-batches)
   * [Testing Jobs](#testing-jobs)
   * [Integration Testing](#integration-testing)
* [Custom Processors](#custom-processors)
   * [Testing Processors](#testing-processors)
* [Contributing](#contributing)
   * [Development](#development)
* [License](#license)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'batch_processor'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install batch_processor

## Getting Started

BatchProcessor comes with some nice rails generators. You are encouraged to use them!

```bash
$ rails g batch_processor foo
  invoke  rspec
  create    spec/batches/foo_batch_spec.rb
  create  app/batches/foo_batch.rb
```

## What is BatchProcessor?

BatchProcessor is a framework for the sequential or parallel processing of jobs in Ruby on Rails.

BatchProcessor helps monitor, control, and orchestrate the work done by `ActiveJob`.

💁‍ This requires [Redis](https://github.com/redis/redis-rb) and a properly configured `ActiveJob` queue adapter (like [Sidekiq](https://github.com/mperham/sidekiq)).

## How It Works

TODO: Batch Lifecycle / Workflow Diagram

There are three important concepts to distinguish here: [Batches](#Batches), [Processors](#Processors), and [Jobs](#Jobs).

### Batches

A **Batch** defines, controls, and monitors the processing of a collection of items with an `ActiveJob`.

All Batches should be named with the `Batch` suffix (ex: `FooBatch`).

```ruby
class PodSprintCalculationBatch < ApplicationBatch
  set_callback(:batch_started, :before) { raise CalculationsNotRunning unless Calculator.busy? }

  on_batch_finished { Calculator.done! }

  class Collection < BatchCollection
    argument :sprint, allow_nil: false
    option :recalculate, default: false

    def items
      recalculate ? items_for_recalculation : items_for_calculation
    end

    def items_for_calculation
      items_for_recalculation.without_performance_metrics
    end

    def items_for_recalculation
      sprint.pod_sprints.with_performance_plans
    end
  end
end
```

A batch is a synthesis of four concepts: a [Collection](#Collection), an [ActiveJob](#ActiveJob), granular [Details](#Details), a summary [Status](#Status), and some [Callbacks](#Callbacks).

#### Collection

A `Collection` takes input to validate and build a (possibly ordered) list of items to process with the Batch's job.

Batches accept a unique identifier and input representing the arguments and options which define it's collection.

```ruby
batch_id = SecureRandom.hex
PodSprintCalculationBatch.process(batch_id: batch_id, sprint: Sprint.last)
```

##### Input

TODO

##### Validations

TODO

#### ActiveJob

When `.process` is called on a Batch, `.execute` is called on the `Processor` specified in the Batch's definition.

Unless otherwise specified a **Batch** assumes its Job class shares a common name.

Ex: `FooBarBazBatch` assumes there is a defined `FooBarBazJob`.

If you want to customize this behavior, define the job class explicitly:

```ruby
class ExampleBatch < ApplicationBatch
  process_with_job SomeOtherJob
end
```

#### Details

The **Details** of a batch are the times of critical lifecycle events and the summary counts of processed jobs.

TODO: List of Details

#### Status

The **Status** of a batch is manifested by a collection of predicates which track certain lifecycle events.

TODO: Table of Statuses

#### Callbacks

Batches have a status which is driven by the jobs it is processing. Callbacks are fired in response to status changes.

TODO: Table Of Callbacks

### Processors

A **Processor** is a service object which determines how to perform a Batch's jobs to properly process its collection.

Unless otherwise specified a **Batch** uses the `default` **Parallel** Processor.

```ruby
class DefaultBatch < ApplicationBatch; end
DefaultBatch.processor_class # => BatchProcessor::Processors::Parallel

class ExampleBatch < ApplicationBatch
  with_sequential_processor
end
ExampleBatch.processor_class # => BatchProcessor::Processors::Sequential

class OtherBatch < ApplicationBatch
  with_parallel_processor
end
OtherBatch.processor_class # => BatchProcessor::Processors::Parallel
```

The default processors can be redefined and new [custom processors](#custom-processors) can be added as well.

Create a `config/initializers/batch_processor.rb` to define these:

```ruby
# Make sequential processor the default
ApplicationBatch::PROCESSOR_CLASS_BY_STRATEGY[:default] = BatchProcessor::Processors::Sequential
```

Certain processors have configurable options; this configuration is specified in the Batch's definition.

```ruby
class ExampleBatch < ApplicationBatch
  with_sequential_processor
  processor_option :continue_after_exception, true
end
```

BatchProcessor comes with two standard processors: **Parallel** and **Sequential**.

#### Parallel Processor

![parallel](docs/images/parallel-processor.png)

The Parallel Processor enqueues jobs to be performed later.

##### Processor Options

None

#### Sequential Processor

![sequential](docs/images/sequential-processor.png)

The Sequential Processor uses `.perform_now` to procedurally process each job within the current thread.

##### Processor Options

| Name                       | Description                                 |
| -------------------------- | ------------------------------------------- |
| `continue_after_exception` | If true, batch continues after job error.   |
| `sorted`*                  | If true, `#find_each` will **not** be used. |

💁‍ Note: `find_each` is used when possible, which ignores `order`; the flag only forces `#each`.

### Jobs

BatchProcessor depends on ActiveJob for handling the processing of individual items in a collection.

Only a **BatchJob** can be used to perform work, but it can be run outside of a batch as well.
 
Therefore, the recommendation is to make `ApplicationJob` inherit from `BatchJob`.

The `rails g batch_processor:install` does this for you:

```ruby
class ApplicationJob < BatchProcessor::BatchJob; end
```

A BatchJob calls into the Batch to report on it's lifecycle from start to finish, including on success and failure.

#### Handling Errors

TODO

## Testing

TODO

### Testing Setup

TODO

### Testing Batches

TODO

### Testing Jobs

TODO

### Integration Testing

TODO

## Custom Processors

TODO

### Testing Processors

TODO

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Freshly/batch_processor.

### Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
