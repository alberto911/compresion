module Subject
  def initialize
    @observers = []
  end

  def add_observer(observer)
    @observers << observer
  end

  def notify_all
    @observers.each { |obs| obs.update(self) }
  end
end
