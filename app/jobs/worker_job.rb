class WorkerJob < ApplicationJob
  def perform
    puts "I'm done working"
  end
end
