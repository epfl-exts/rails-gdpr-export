# frozen_string_literal: true

require "exts/gdpr/version"
require 'csv'

module Exts
  module Gdpr
    # Stores all the classes that have been tagged for gdpr collection
    @@klasses = []

    def self.get_klasses
      @@klasses
    end

    def self.add_klass(klass)
      @@klasses << klass
    end

    # Collects data through all the tagged models and generates a csv
    # formatted output
    def self.export(user_id)
      CSV.generate do |csv|
        get_klasses.each do |klass|
          rows = klass.gdpr_query(user_id)
          klass.gdpr_export(rows, csv)
        end
      end
    end

    # Instruments the classes implementing this module with instance and class
    # methods.
    def self.included base
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end

    module InstanceMethods
    end

    module ClassMethods
      # Declared in each model class with interest in collecting gdpr data.
      # Instruments the singleton of those classes so that gdpr data can be
      # collected and exported to csv.
      #
      # Arguments are:
      # - set of simple fields: i.e. fields that will be output as is
      # - a hash of params:
      # {renamed_fields: {<field_from_db> => <field_name_in_output>}
      #  table_name:     <the new table name in output>
      #  description:    <a comment>
      #  join:           <an association>}
      def gdpr_collect(*args)
        # Params handling
        if args.class == Hash # when user provides the hash_params only
          simple_fields, hash_params = [[], args]
        else
          simple_fields, hash_params = [args[0..-2], args.last]
        end

        unless hash_params.class == Hash
          raise "Gdpr fields collection error: last argument must be a hash!"
        end

        unless hash_params.key?(:user_id)
          raise "Gdpr fields collection error: the field aliasing user_id is not declared for '#{self}'!"
        end

        # Adds the eigen class to the set of classes eligible for gdpr data collection.
        Gdpr.add_klass(self)

        # Adds instance fields to the eigenclass. They store
        # all the fields and info we are interested in.
        @gdpr_simple_fields = simple_fields
        @gdpr_hash_params = hash_params
        # Add readers for the instance vars declared above (for testing reasons)
        self.class.send :attr_reader, :gdpr_simple_fields
        self.class.send :attr_reader, :gdpr_hash_params

        # Build the csv header and prepare the fields used for querying
        user_id_field = hash_params[:user_id]
        csv_headers = [:user_id].concat @gdpr_simple_fields
        query_fields = [user_id_field].concat @gdpr_simple_fields

        if hash_params[:renamed_fields]
          csv_headers.concat hash_params[:renamed_fields].values
          query_fields.concat hash_params[:renamed_fields].keys
        end

        # Adds the class method 'gdpr_query' to the eigenclass.
        # It will execute the query.
        self.define_singleton_method(:gdpr_query) do |_user_id|
          if hash_params[:join]
            self.select(query_fields).where(user_id_field => _user_id).
              joins(hash_params[:join])
          else
            self.select(query_fields).where(user_id_field => _user_id)
          end
        end

        # Adds a method to export to csv to the eigenclass.
        self.define_singleton_method(:gdpr_export) do |rows, csv|
          csv << (hash_params[:table_name] ? [hash_params[:table_name]] :
                    [self.to_s])
          csv << csv_headers
          rows.each do |r|
            csv << query_fields.map{ |f| r.send(f) }
          end
          csv << ['Comment:', hash_params[:desc]] if hash_params[:desc]
          csv << []
        end
      end
    end
  end
end
