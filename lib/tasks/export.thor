# Copyright:: (c) Autotelik Media Ltd 2016
# Author ::   Tom Statter
# Date ::     March 2016
# License::   MIT.
#
# Usage::
#
#  To pull Datashift commands into your main application :
#
#     require 'datashift'
#
#     DataShift::load_commands
#
require_relative 'thor_export_base'

# Note, for thor not DataShift, case sensitive, want namespace for cmd line to be : datashift
module Datashift

  class Export < DataShift::ThorExportBase

    desc "excel", "export any active record model (with optional associations)"

    method_option :model, :aliases => '-m', :required => true, desc: "The active record model to export"
    method_option :result, :aliases => '-r', :required => true, desc: "Create template of model in supplied file"
    method_option :sheet_name, :type => :string, desc: "Name to use for Excel worksheet instead of model name"

    def excel()
      start_connections

      export(DataShift::ExcelExporter.new)

      puts "Datashift: Excel export COMPLETED to #{options[:result]}"
    end


    desc "csv", "export any active record model (with optional associations)"

    method_option :model, :aliases => '-m', :required => true, desc: "The active record model to export"
    method_option :result, :aliases => '-r', :required => true, desc: "Create template of model in supplied file"

    def csv()
      start_connections

      export(DataShift::CsvExporter.new)

      puts "Datashift: CSV export COMPLETED to #{options[:result]}"
    end


    desc "db", "Export every Active Record model"

    method_option :path, :aliases => '-p', :required => true, desc: "Path in which to create export files"
    method_option :csv, :aliases => '-c', desc: "Export to CSV instead - Excel is default."

    method_option :prefix_map, :aliases => '-x', type: :hash, :default => {},
                  desc: "For namespaced tables/models specify the table prefix to module map e.g spree_:Spree"

    method_option :modules, :aliases => '-m', type: :array, :default => [],
                  desc: "List of Modules to search for namespaced models"

    def db()

      start_connections

      unless File.directory?(options[:path])
        puts "WARNING : No such PATH found #{options[:path]} - trying mkdir"
        FileUtils::mkdir_p(options[:path])
      end

      exporter = options[:csv] ?  DataShift::CsvExporter.new :  DataShift::ExcelExporter.new

      DataShift::Exporters::Configuration.from_hash(options)

      ext = options[:csv] ? '.csv' : '.xls'

      modules = [nil] + options[:modules]

      ActiveRecord::Base.connection.tables.each do |table|

        modules.each do |m|
          @klass = DataShift::MapperUtils.table_to_arclass(table, m)
          break if(@klass)
        end

        options[:prefix_map].each do |p, m|
          @klass = DataShift::MapperUtils.table_to_arclass(table.gsub(p, ''), m)
          break if(@klass)
        end unless(@klass)

        if(@klass.nil?)
          puts  "ERROR: No Model found for Table [#{table}] - perhaps check modules/prefixes"
          next
        end

        result = File.join(options[:path], "#{table}#{ext}")

        puts "Datashift: Start export to #{result} for [#{table}]"

        begin

          if(options[:associations])
            logger.info("Datashift: Exporting with associations")
            exporter.export_with_associations(result, @klass, @klass.all)
          else
            exporter.export(result, @klass.all, :sheet_name => @klass.name)
          end
        rescue => e
          puts e
          puts e.backtrace
          puts "Warning: Error during export, data may be incomplete"
        end
      end
    end

    no_commands do

      def table_to_arclass(table, mod)

        find_table = mod.nil? ? table.classify : "#{mod}::#{table.classify}"

        begin
          DataShift::MapperUtils::class_from_string(find_table)
        rescue LoadError
        rescue
          nil
        end
      end

      def export(exporter)
        model = options[:model]
        result = options[:result]

        DataShift::Exporters::Configuration.from_hash(options)

        logger.info "Datashift: Starting export with #{exporter.class.name} to #{result}"

        klass = DataShift::MapperUtils::class_from_string(model)  #Kernel.const_get(model)

        raise "ERROR: No such Model [#{model}] found - check valid model supplied via -model <Class>" if(klass.nil?)

        begin

          if(options[:associations])
            logger.info("Datashift: Exporting with associations")
            exporter.export_with_associations(result, klass, klass.all)
          else
            exporter.export(result, klass.all, options)
          end
        rescue => e
          puts e
          puts e.backtrace
          puts "Warning: Error during export, data may be incomplete"
        end

      end

    end   # no_commands

  end

end
