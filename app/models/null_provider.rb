class NullProvider
  def topics = Topic.none

  def present? = false
end
