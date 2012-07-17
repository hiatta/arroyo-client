module Arroyo
  module Client
    class Query
      attr_reader :type

      def initialize(type)
        @type = type
      end

      def to_hash
        h = {}

        h[:query] = query if query
        h[:filter] = dump_filters if filters.any?
        h[:rows] = rows if rows
        h[:start] = rows * (page-1) if rows && page
        h[:sort] = sort if sort
        h[:sort_order] = order if order
        h[:facet] = facet if facet

        h
      end

      def as_query
        to_hash
      end

      def to_query
        as_query.to_query
      end

      def to_s
        CGI.unescape(to_query)
      end

      def to_str
        to_s
      end

      def inspect
        "#<#{self.class.name} ?#{to_s}>"
      end

      attr_writer :filters
      def filters
        @filters ||= {}
      end

      attr_accessor :page
      def page!(p)
        @page = p
        self
      end

      attr_accessor :query
      def query!(q)
        @query = q
        self
      end

      attr_accessor :rows
      def rows!(r)
        @rows = r
        self
      end

      attr_accessor :sort
      def sort!(s)
        @sort = s
        self
      end

      attr_accessor :facet
      def facet!(f)
        @facet = f
        self
      end


      attr_accessor :order
      def order!(o)
        @order = o.to_s.downcase
        self
      end

      def dup
        dupd = super

        # deep_dup doesn't handle sets
        self.filters.each do |k, v|
          dupd.filters[k] = v.dup
        end

        dupd
      end

      def filter!(f={})
        f.each do |field, constraint|
          case constraint
          when Range
            filters[field.to_s] = [constraint.begin, constraint.end]
          else
            (filters[field.to_s] ||= Set.new).merge(Array.wrap(constraint))
          end
        end

        self
      end

      def filter_range!(f={})
        f.each do |field, range|
          filters[field.to_s] = case range
          when Range
            [range.begin, range.end]
          when Array
            range
          else
            error!("bad range filter: #{range.inspect}")
          end
        end

        self
      end

      def filter_gt!(f={})
        f.each do |field, min|
          filter_range!(field => [min, nil])
        end

        self
      end

      def filter_lt!(f={})
        f.each do |field, max|
          filter_range!(field => [nil, max])
        end

        self
      end

      %w(filter filter_range filter_gt filter_lt).each do |m|
        bang = "#{m}!"
        define_method(m) do |*a, &b|
          dup.send(bang, *a, &b)
        end
      end

      def result!
        Cacher.get("/nlpapi/#{type}?#{to_query}") do
          GoodGuide::NlpApi.search(type, as_query)
        end
      end

      def set!(q={})
        q.each do |field, value|
          send("#{field}!", value)
        end

        self
      end

      module Searchable
        extend ActiveSupport::Concern

        module ClassMethods
          # @override
          def wrap(o)
            case o
            when GoodGuide::NlpApi::Match
              new(id: o.id.to_i)
            else
              super
            end
          end

          def search(f={}, &b)
            type = self.name.split('::').last.underscore.pluralize.to_sym

            query = Query.new(type).set!(f)

            yield query if block_given?

            query.result!
          end
        end
      end

    private
      def dump_filters
        filters.map do |field, constraints|
          case constraints
          when Array
            start = constraints.first
            start = start ? start.inspect : '*'
            fin = constraints.last
            fin = fin ? fin.inspect : '*'

            "#{field}:[#{start} TO #{fin}]"
          when Set
            "#{field}:(#{constraints.map(&:inspect).join(',')})"
          end
        end.sort
      end
    end
  end
end
