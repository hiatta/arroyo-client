require File.expand_path('../connection', __FILE__)
require File.expand_path('../request', __FILE__)

module Arroyo
  class Client
    include Arroyo::Connection
    include Arroyo::Request

    attr_accessor *Configuration::VALID_OPTIONS_KEYS
    
    def initialize(options={})
      options = Arroyo.options.merge(options)
      Configuration::VALID_OPTIONS_KEYS.each do |key|
        send("#{key}=", options[key])
      end
    end
        
    def add_job(job_type, job_parameters={}, job_options={})
      raise Arroyo::Error, "job_type must be set" unless job_type
      job_parameters ||= {}
      job_options ||= {}
      job_body=add_job_body(job_type, job_parameters, job_options)
      return post("jobs",job_body)
    end

    def get_job(job_id)
      raise Arroyo::Error, "job_id must be set" unless job_id
      return get("jobs/#{job_id.to_s}")
    end

    def delete_job(job_id)
      raise Arroyo::Error, "job_id must be set" unless job_id
      return delete("jobs/#{job_id.to_s}")
    end
    
    def find_jobs(constraints={})
      raise Arroyo::Error, "constraints must not be nil" unless constraints
      return get("jobs",constraints)
    end

    def system
      return get("system")
    end

    def scheduled_jobs
      return system["scheduled_jobs"]
    end

    def queues
      return system["queues"]
    end

    def workers
      return system["workers"]
    end
    
  private
    def add_job_body(job_type, job_parameters, job_options)
      job_body={}
      job_body[:job_type]=job_type
      job_body[:job_parameters]=job_parameters
      job_body[:job_options]=job_options
      return job_body
    end
  end
end
