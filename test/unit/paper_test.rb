require 'test_helper'

class PaperTest < ActiveSupport::TestCase
  test "A new paper" do
    paper = Fabricate(:paper)
    assert paper.version == "1.0"
    assert paper.state == "submitted"
  end
end
