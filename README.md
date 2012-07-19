#arroyo-client - Gem for the Arroyo enterprise service bus
======

## Introduction
The [Arroyo ESB](http://github.com/GoodGuide/arroyo) is an enterprise service bus implemented in Ruby on Rails. This gem provides an interface to the job submission and management REST API provided by this bus. From here, users can create, read and destroy jobs installed on the bus and query for system.

For more details on the server component [please read this](http://github.com/GoodGuide/arroyo).

## Usage
* Download and install the [Arroyo ESB](http://github.com/GoodGuide/arroyo)
* Add some jobs to the bus system
* Install this gem or add it your Gemfile
```
gem install arroyo-client
```

* Configure the connection
```ruby
require 'arroyo'
Arroyo.configure do |config|
        config.endpoint = "http://arroyo.staging.goodguide.com/1.0/"     # Required
        config.adapter = :net_http                                       # Optional
        config.user_agent = "My Arroyo User Agent - #{Arroyo::VERSION}"  # Optional
end
```

* Add a job
```ruby
job_type="simple" # The name of the job_type as defined in the job to be executed on the ESB
job_parameters={:sample_param => "a test string"} # These may be any values that can be encoded into JSON via to_json
job_options={:priority => "high"} # See [POST /1.0/jobs](https://github.com/GoodGuide/arroyo#use-rest-interface-to-create-new-jobs-and-query-existing-or-completed-jobs) 
response=client.add_job(job_type, job_parameters, job_options)
# {
#   "job_type": "simple",
#   "job_id": "2a9b2ba9-e396-493a-9cbc-ca71a4d5d25d",
#   "priority": "high",
#   "job_parameters": {
#     "sample_param": "a test string"
#   },
#   "initialize_time": "2012-07-17T22:43:21Z",
#   "enqueue_time": "2012-07-17T22:43:21Z"
# }
```

* Delete a job
```ruby
# Replace the next line with the job id from the addition of the job
job_id="2a9b2ba9-e396-493a-9cbc-ca71a4d5d25d"
Arroyo.delete_job(job_id)
```

* Query the job
```ruby
# Replace the next line with the job id from the addition of the job
job_id="2a9b2ba9-e396-493a-9cbc-ca71a4d5d25d"
Arroyo.get_job(job_id)
```

* List previously run jobs and add some constraints
```ruby
constraints = {
        :start => 1, # must be > 0
        :num_jobs => 10, # must be >=0 and <= 100
        :filters => {
                queue: "low", # the result will match all constraints, fields to query are [here](https://github.com/GoodGuide/arroyo#internal-message-format) 
                job_parameters.sample_param: "A sample parameter"
        },  
        :sort => "initialize_time", # may be any field supported by filters and may be either a string or symbol
        :sort_order=:desc # may be either :asc or :desc and may be either a string or symbol
}
Arroyo.find_jobs(constraints)
# {
#   num_found: 427,
#   jobs: [{
#     job_type: "simple",
#     job_id: "2a9b2ba9-e396-493a-9cbc-ca71a4d5d25d",
#     job_parameters: {
#       sample_param: "A test string"
#     },
#     queue: "high",
#     initialize_time: "2012-07-17T22:43:21Z",
#     enqueue_time: "2012-07-17T22:43:21Z",
#     worker_hostname: "eris.goodguide.com",
#     start_time: "2012-07-17T22:43:21Z",
#     end_time: "2012-07-17T22:43:21Z"
#   },...]
# }
```

* Get the status of the system
```ruby
Arroyo.system
# {
#   global: {
#     pending: 0,
#     processed: 0,
#     queues: 0,
#     workers: 0,
#     working: 0,
#     failed: 0,
#     environment: "development",
#     queue_servers: ["redis://birdo:6379/0"],
#     logger_servers: ["mongodb://birdo:27017/arroyo_development"],
#     valid_job_types: [{
#       job_type: "simple",
#       job_class: "Arroyo::Sample::SimpleJob",
#       description: "A test job that demonstrates basic job structure"
#     }]
#   },
#   scheduled_jobs: [],
#   queues: {},
#   workers: {}
# }
```

## Errors
Errors are handled by throwing errors on non-200 responses from the REST interface.

## Credits
* Inspired by https://github.com/Instagram/instagram-ruby-gem