require "http/client"
require "sqlite3"
require "./*"

module ParallelRequests
  VERSION            = "0.1.0"
  DATABASE_PATH      = "sqlite3:./data.db"
  MAX_TIMEOUT        = 30.seconds
  MAX_BATCH_REQUESTS = 10
  extend self

  Signal::INT.trap do
    # Should we wait for the final requests to finish before we exit ?
    # puts "Processing final requests..."
    exit
  end

  results_channel = Channel(Job).new
  jobs_channel = Channel(Array(Job)).new

  spawn do
    loop do
      jobs = jobs_channel.receive
      jobs.each do |job|
        spawn { results_channel.send JobProcessor.process(job) }
      end
    end
  end

  spawn do
    loop do
      begin
        jobs = JobRepository.get_pending
        if jobs.size > 0
          jobs_channel.send(jobs)
        end
      rescue ex
        puts ex
      end

      sleep 1
    end
  end

  loop do
    completed_job = results_channel.receive
    begin
      JobRepository.update(completed_job)
    rescue ex
      puts ex
    end
  end
end
