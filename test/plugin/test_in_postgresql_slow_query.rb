require 'helper'

class PostgreSQLSlowQueryInputTest < Test::Unit::TestCase
  TMP_DIR = File.expand_path("../tmp", File.dirname(__FILE__))
  LOG_FILE = TMP_DIR + "/postgresql.csv"
  TAG = "postgresql.slow_query"

  def setup
    Fluent::Test.setup
    FileUtils.rm_rf(TMP_DIR)
    FileUtils.mkdir_p(TMP_DIR)
    File.open(LOG_FILE, "w").close()
  end

  CONFIG = %[
    path #{LOG_FILE}
    tag #{TAG}
  ]

  def create_driver(conf=CONFIG)
    Fluent::Test::InputTestDriver.new(Fluent::PostgreSQLSlowQueryInput).configure(conf)
  end

  def test_emit
    d = create_driver

    time_string = "2012-01-29 23:04:34.000 UTC"
    time = Time.parse(time_string).to_i
    d.expect_emit TAG, time, {"duration"=>"11804.297"}

    d.run do
      d.expected_emits.each {|tag,time,record|
        text = generate_log_text(time_string)
        $stderr.puts text
        File.open(LOG_FILE, "w") {|f|
          f.write text
        }
      }
    end
  end

  private
  def generate_log_text(time)
    text = <<-LOG
#{time},"foo","postgres",56789,"[local]",4f2551e7.ddd5,1,"SELECT",2012-01-29 23:04:23 JST,2/0,0,LOG,00000,"duration: 11804.297 ms  statement: SELECT
  *
FROM
  tbl
;",,,,,,,,,"psql"
    LOG
  end
end
