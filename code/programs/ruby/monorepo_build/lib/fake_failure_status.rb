class FakeFailureStatus
  def success?
    false
  end

  def exitstatus
    1
  end
end