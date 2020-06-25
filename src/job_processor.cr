module ParallelRequests
  class JobProcessor
    def self.get_uri_info(url)
      uri = URI.parse url
      if uri.host.nil?
        return nil
      end

      uri
    end

    def self.fetch_result(url)
      puts "processing #{url}"

      uri = self.get_uri_info(url)
      if !uri
        return nil
      end

      begin
        client = HTTP::Client.new uri.host.not_nil!
        client.read_timeout = MAX_TIMEOUT
        client.head(url).status_code
      rescue ex
        puts ex
        nil
      end
    end

    def self.mark_as_processing(job)
      job.status = Status::PROCESSING
      JobRepository.update(job)

      job
    end

    def self.process(job)
      job = self.mark_as_processing(job)
      result = self.fetch_result(job.url)

      if !result
        job.status = Status::ERROR
        return job
      end

      job.status = Status::DONE
      job.http_code = result
      job
    end
  end
end
