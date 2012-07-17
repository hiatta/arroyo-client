module Arroyo
  module Client
    extend self

    ROOT_PATH = "nlpapi"
    VALID_ENTITY_TYPES = [
      :products,
      :companies,
      :brands,
      :ingredients,
      :categories,
      :terms,
      :sentiment,
      :user_reviews
    ]

    VALID_ENTITY_TYPES_FOR_EXTRACTION = [
      :companies,
      :brands,
      :categories
    ]
    VALID_ENTITY_TYPES_FOR_CLASSIFICATION = [
      :categories,
      :sentiment
    ]
    VALID_ENTITY_TYPES_FOR_GROUPING = [
      :company,
      :brand,
      :primary_category
    ]
    VALID_ENTITY_TYPES_FOR_SUMMARIZATION = [
      :user_reviews
    ]

    def config
      @config ||= default_config.dup
    end

    def config=(options)
      @config = default_config.merge(options)
    end

    def reset
      @connection = nil
    end

  private

    def default_config
      { host: 'http://nlpapi.production.goodguide.com', adapter: :net_http }
    end

  public

    extend GoodGuide::NlpApi::EntityExtraction


    class Match < Hashie::Mash
    end

    class GroupMatch
      attr_reader :id, :group_type, :matches

      def initialize(id, group_type, matches)
        @id = id
        @group_type = group_type.gsub(/_id/,'').gsub(/^primary_/,'').classify
        @matches = matches.map { |m| Match.new(m) }
      end

      def count
        @matches.size
      end
    end

    # valid options are :query => <query string>
    def entity_extraction(entity_type, options)
      raise "Entity type must be in list #{VALID_ENTITY_TYPES_FOR_EXTRACTION}" unless VALID_ENTITY_TYPES_FOR_EXTRACTION.include?(entity_type)
      return api_request(entity_type, "entity_extraction", options)
    end

    # valid options are :query => <query string>
    def spellcheck(entity_type, options)
      return api_request(entity_type, "spellcheck", options)
    end

    # valid options are :query => <query string>, :rows => <row count integer>, :start => <start index integer>
    def morelikethis(entity_type, options)
      return api_request(entity_type, "morelikethis", options)
    end

    # valid options are :query => <query string>, :rows => <row count integer>, :start => <start index integer>
    def search(entity_type, options)
      return api_request(entity_type, "search", options)
    end

    # valid options are :query => <query string>
    def match(entity_type, options)
      return api_request(entity_type, "match", options)
    end

    # valid options are 
    #       :query => <query string>, 
    #       :rows => <row count integer>, 
    #       :start => <start index integer>, 
    #       :filter => "entity_type:(<Ingredient, Brand, Company, Product, or Category>)"
    def autocomplete(options)
      return api_request(:terms, "autocomplete", options)
    end

    # valid option is :num_blurbs => <number of summary blurbs to return>
    # valid body is :reviews => <url encoded string of json array of hashes with fields, "rating" and "review">
    def summary(entity_type, options, body)
      raise "Entity type must be in list #{VALID_ENTITY_TYPES_FOR_SUMMARIZATION}" unless VALID_ENTITY_TYPES_FOR_SUMMARIZATION.include?(entity_type)
      return api_request(entity_type, "summary", options, body)
    end

    # valid options are :query => <query string>
    def classification(entity_type, options)
      raise "Entity type must be in list #{VALID_ENTITY_TYPES_FOR_CLASSIFICATION}" unless VALID_ENTITY_TYPES_FOR_CLASSIFICATION.include?(entity_type)
      return api_request(entity_type, "classification", options)
    end

    def api_request(entity_type, request_path, options, body=nil)
      ApiRequest.new(entity_type, request_path, options, body).results
    end

    class ApiRequest
      def initialize(entity_type, request_path, options, body)
        @entity_type = entity_type
        @request_path = request_path
        @options = options
        @path = "/#{ROOT_PATH}/#{@entity_type.to_s}/#{@request_path}"
        @body = body
      end

      def results
        validate_request
        unless @body
          connection.get(@path) { |req|
            req.params = request_params
          }.on_complete(&method(:process_response))
        else
          connection.post(@path) { |req|
            req.params = request_params
            req.body = @body
          }.on_complete(&method(:process_response))          
        end
        return result_set
      end

      private

      def connection
        # TODO: Move connection into ApiRequest?
        NlpApi.send(:connection)
      end

      def request_params
        @options
      end

      def process_response(response)
        response_json = Yajl::Parser.parse(response[:body])
        if response_json['total'].to_i > 0
          result_set.total = response_json['total'].to_i
          result_set.facets = Hashie::Mash.new response_json['facets']
          
          resp_entries = response_json['entities'] || response_json['summary']
          resp_entries.map do |match|
            result_set << build_match(match)
          end
        end

        return result_set
      rescue StandardError => ex
        msg="Response parsing failed: [#{ex.message}] on response body [#{response[:body]}]"
        if defined?(Rails)
          Rails.logger.error(msg)
        else
          puts msg
        end
      end

      def build_match(match)
        if grouped?(match)
          GroupMatch.new(match.first, grouped_by, match.last)
        else
          Match.new(match)
        end
      end

      def grouped?(match)
        match.is_a?(Array) && match.size == 2 && grouped_by
      end

      def grouped_by
        @options[:result_grouping]
      end

      def validate_request
        raise "Options must never be nil" unless @options
        raise "Query must never be nil" unless @options[:query] or @entity_type==:user_reviews
        raise "Entity type must never be nil" unless @entity_type
        raise "Request path must never be nil" unless @request_path
        raise "Entity type must be in list #{VALID_ENTITY_TYPES}" unless VALID_ENTITY_TYPES.include?(@entity_type)
        raise "Group by type must be in list #{VALID_ENTITY_TYPES_FOR_GROUPING}" if grouped_by && VALID_ENTITY_TYPES_FOR_GROUPING.include?(grouped_by.to_sym)
      end

      def result_set
        @result_set ||= ResultSet.new
      end
    end

    def in_parallel(&block)
      return yield unless config[:adapter] == :typhoeus

      manager = Typhoeus::Hydra.new(:max_concurrency => 10)
      connection.in_parallel(manager, &block)
    end

  private

    def connection
      @connection ||= Faraday.new(url: config[:host]) do |b|
        b.adapter *config[:adapter]
      end
    end
  end
end
