module ParallelRequests
  struct Job
    property status : Status = Status::NEW
    property http_code : Int32?
    getter url : String
    getter id : Int64

    def initialize(@id, @url)
    end
  end
end
