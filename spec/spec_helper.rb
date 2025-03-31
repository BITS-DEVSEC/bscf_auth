require "simplecov"
# require "./spec/support/models/shared_examples"
# require "./spec/support/requests/shared_requests"
# require "rspec/retry"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.formatter = RSpec::Core::Formatters::DocumentationFormatter

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed

  #  config.verbose_retry = true
  # config.display_try_failure_messages = true
  config.around :each, :js do |ex|
    ex.run_with_retry retry: 3
  end
end

SimpleCov.start("rails") do
  add_filter("/lib/")
  add_filter("/bin/")
  add_filter("/db/")
  add_filter("/spec/")
end
