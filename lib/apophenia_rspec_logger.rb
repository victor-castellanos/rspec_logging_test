require "apophenia_field_dictionary_core"
require "apophenia_field_dictionary_qa_test"
require "apophenia_logger"
require "logstash-logger"
require "securerandom"
require "singleton"
require "dotenv"

class ApopheniaRspecLogger
  include Apophenia::FieldDictionary::Core
  include Apophenia::FieldDictionary::QaTest
  include Apophenia::Logger
  include Singleton
  Dotenv.load

  def initialize
    ctx = OpenSSL::SSL::SSLContext.new
    ctx.set_params(verify_mode: OpenSSL::SSL::VERIFY_NONE)
    @log = LogStashLogger.new(
      type: :tcp,
      host: ENV["LOGS_HOST"],
      port: 6514,
      ssl_context: ctx,
      verify_hostname: false,
      sync: true
    )
  end

  def log(msg)
    @msg = msg
    @log.info(base.merge(dictionaries).merge(fields))
  end

private

  def base
    {
      "time" => Time.now.utc.iso8601,
      "action" => action,
      "event_id" => SecureRandom.uuid,
      "app_id" => Apophenia::FieldDictionary::QaTest::AppId::QA_TEST_EVERYDOLLAR
    }
  end

  def dictionaries
    {
      "field_dictionary_uris" => [
        Apophenia::FieldDictionary::Core::SCHEMA_URL,
        Apophenia::FieldDictionary::QaTest::SCHEMA_URL
      ]
    }
  end

  def fields
    {
      "test_description" => @msg.description,
      "test_execution_time" => (@msg.time * 1000).ceil,
      "test_group" => @msg.group,
      "test_group_parent" => @msg.parent
    }
  end

  def action
    if @msg.result == "success"
      Apophenia::FieldDictionary::QaTest::Action::TEST_RESULT_SUCCESS
    else
      Apophenia::FieldDictionary::QaTest::Action::TEST_RESULT_FAILURE
    end
  end
end
