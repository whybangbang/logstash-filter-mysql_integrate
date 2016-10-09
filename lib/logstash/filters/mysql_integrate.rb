# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require "logstash/plugin_mixins/jdbc"

# This example filter will replace the contents of the default
# message field with whatever you specify in the configuration.
#
# It is only intended to be used as an example.
class LogStash::Filters::Example < LogStash::Filters::Base
  include LogStash::PluginMixins::Jdbc
  config_name "mysql_integrate"
  default :codec, "plain"

  config :refer_field, :validate => :string

  config :require_field, :validate => :string

  config :statement, :validate => :string

  config :parameters, :validate => :hash, :default => {}

  config :f_debug, :validate => :boolean, :default => false

  config :lowercase_column_names, :validate => :boolean, :default => true


  public
  def register
    prepare_jdbc_connection
  end # def register

  public
  def filter(event)

    execute_query(event)

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter

  def execute_query(event)
    # update default parameters
    @parameters[@require_field] = event[@refer_field]
    execute_statement(@statement, @parameters) do |row|
      row.each do |k,v|
        event[k] = v
      end
    end
  end
end # class LogStash::Filters::Example
