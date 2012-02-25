module Fluent
class PostgreSQLSlowQueryInput < Fluent::TailInput
  Fluent::Plugin.register_input('postgresql_slow_query', self)

  def initialize
    super
    require 'csv'
    require 'time'
  end

  def configure_parser(conf)
    @_log = ""
  end

  def parse_line(line)
    @_log << "\n" if !@_log.empty?
    @_log << line

    csvlog = CsvLog.new(@_log)
    if csvlog.valid?
      if csvlog.slow_query_log?
        time = csvlog.get_log_time_as_int
        record = csvlog.get_fluent_record
        return time, record
      end
      @_log = ""
    end
    return nil, nil
  end

  private
  class CsvLog
    def initialize(line)
        begin
          csv = CSV.parse(line)[0]
          @_valid = true
          # csv log format is descriped at:
          # http://www.postgresql.jp/document/9.1/html/runtime-config-logging.html#RUNTIME-CONFIG-LOGGING-CSVLOG
          @log_time                 = csv[0]
          @user_name                = csv[1]
          @database_name            = csv[2]
          @process_id               = csv[3]
          @connection_from          = csv[4]
          @session_id               = csv[5]
          @session_line_num         = csv[6]
          @command_tag              = csv[7]
          @session_start_time       = csv[8]
          @virtual_transaction_id   = csv[9]
          @transaction_id           = csv[10]
          @error_severity           = csv[11]
          @sql_state_code           = csv[12]
          @message                  = csv[13]
          @detail                   = csv[14]
          @hint                     = csv[15]
          @internal_query           = csv[16]
          @internal_query_pos       = csv[17]
          @context                  = csv[18]
          @query                    = csv[19]
          @query_pos                = csv[20]
          @location                 = csv[21]
          @application_name         = csv[22]

          @duration, @slow_query = @message.scan(/duration: (\d+(?:\.\d+)?) ms  statement: (.+)/m)[0]
        rescue CSV::MalformedCSVError
          @_valid = false
        end
    end

    def get_log_time_as_int
      Time.parse(@log_time).to_i
    end

    def slow_query_log?
      !@duration.nil?
    end

    def valid?
      @_valid
    end

    def get_fluent_record
      record = {}
      record[:slow_query] = @slow_query
      record[:duration] = @duration
      record[:log_time] = @log_time
      record[:user_name] = @user_name
      record[:database_name] = @database_name
      record[:process_id] = @process_id
      record[:connection_from] = @connection_from
      record[:session_id] = @session_id
      record[:session_line_num] = @session_line_num
      record[:command_tag] = @command_tag
      record[:session_start_time] = @session_start_time
      record[:virtual_transaction_id] = @virtual_transaction_id
      record[:transaction_id] = @transaction_id
      record[:error_severity] = @error_severity
      record[:sql_state_code] = @sql_state_code
      record[:message] = @message
      record[:detail] = @detail
      record[:hint] = @hint
      record[:internal_query] = @internal_query
      record[:internal_query_pos] = @internal_query_pos
      record[:context] = @context
      record[:query] = @query
      record[:query_pos] = @query_pos
      record[:location] = @location
      record[:application_name] = @application_name
      return record
    end
  end
end
end
