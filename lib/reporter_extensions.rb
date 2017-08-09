require "apophenia_rspec_logger"

LoggableSpec = Struct.new(:parent, :group, :description, :result, :time)

module ReporterExtensions
  def example_finished(example)
    super
    ApopheniaRspecLogger.instance.log(loggable_object(example))
  end

private

  def loggable_object(example)
    LoggableSpec.new(
      example.metadata[:example_group][:parent_example_group][:full_description],
      example.metadata[:example_group][:full_description],
      example.full_description,
      example.execution_result.status.to_s,
      example.execution_result.run_time
    )
  end
end

module RSpec
  module Core
    class Reporter
      prepend ReporterExtensions
    end
  end
end
