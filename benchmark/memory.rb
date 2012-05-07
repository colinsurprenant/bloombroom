module Bloombroom
  class Process

    def self.rss
      `ps -o rss= -p #{::Process.pid}`.to_i
    end
  end
end
