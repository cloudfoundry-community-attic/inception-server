module StdoutCapture
  # Captures stdout within the block
  # Usage:
  #
  #   out = capture_stdout do
  #     puts "this will not be shown"
  #   end
  #   out.should == "this will not be shown"
  def capture_stdout(&block)
    out = StringIO.new
    $stdout = out
    yield
    return out
  ensure
    $stdout = STDOUT
  end
end