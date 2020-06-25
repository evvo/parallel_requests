module ParallelRequests
  class JobRepository
    def self.get_pending(limit = MAX_BATCH_REQUESTS)
      pending_jobs = [] of Job
      DB.open DATABASE_PATH do |db|
        db.query "SELECT id, url
        FROM jobs
        WHERE status = ?
        ORDER by id ASC
        LIMIT #{limit}", Status::NEW.to_s do |rs|
          rs.each do
            id, url = rs.read(Int64, String)
            pending_jobs << Job.new id, url
          end
        end
      end

      pending_jobs
    end

    # That is needed on SQLite database, as the database might
    # be locked when the request is made
    def self.wait_for_lock(proc)
      loop do
        begin
          proc.call
          break
        rescue ex
          puts ex
          if ex.message != "database is locked"
            raise ex
          end

          sleep 0.5
        end
      end
    end

    def self.update(job : Job)
      self.wait_for_lock(->{
        DB.open DATABASE_PATH do |db|
          db.exec "UPDATE jobs
          SET status = ?,
              http_code = ?
          WHERE
            id = ? ", job.status.to_s, job.http_code, job.id
        end
      })
    end
  end
end
