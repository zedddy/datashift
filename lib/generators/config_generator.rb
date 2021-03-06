# Copyright:: (c) Autotelik Media Ltd 2015
# Author ::   Tom Statter
# Date ::     Mar 2015
# License::   MIT
#
# Details::   Create Configuraiton files for import and export
#
require 'generator_base'

module DataShift

  class ConfigGenerator < GeneratorBase

    include DataShift::Logging
    include ExcelBase

    def self.title
      @mappings_title ||= "datashift_mappings:\n"
    end

    attr_accessor :output_filename

    def initialize
      super
    end

    def import_template
      @import_template ||= File.join(DataShift.library_path, 'datashift/templates/standard_import_config.erb')
    end

    def write_import(file_name, klass_or_name, options = {})
      result = import(klass_or_name, options)

      logger.info("Writing Import Config File [#{file_name}]")

      File.open(file_name, 'w') { |f| f << result }
    end

    # Create an YAML Configuration template for Importing
    # includes available transformations and column mapping
    #
    # For other options See DataShift::Importers::Configuration
    #
    def import(klass_or_name, options = {})

      @klass = MapperUtils.ensure_class(klass_or_name)

      @title = @klass.name.to_s

      @defaults = options[:defaults] || []
      @overrides = options[:overrides] || []
      @substitutions = options[:substitutions] || []
      @prefixs = options[:prefixs] || []
      @postfixs = options[:postfixs] || []

      klass_to_headers(@klass)

      Erubis::Eruby.new( File.read(import_template)).result(binding)
    end

    # FOR EXPORTERS

    def export_template
      @export_template ||= File.join(DataShift.library_path, 'datashift/templates/standard_export_config.erb')
    end

    def write_export(file_name, klass_or_name, options = {})
      result = export(klass_or_name, options)

      logger.info("Writing Export Config File [#{config[:file]}]")

      File.open(file_name, 'w') { |f| f << result }
    end

    # Create an YAML Configuration template for Exporting
    # includes available transformations and column mapping
    #
    # For other options See DataShift::Exporters::Configuration
    #
    def export(klass_or_name, options = {})

      @klass = MapperUtils.ensure_class(klass_or_name)

      @title = @klass.name.to_s

      @defaults = options[:defaults] || []
      @overrides = options[:overrides] || []
      @substitutions = options[:substitutions] || []
      @prefixs = options[:prefixs] || []
      @postfixs = options[:postfixs] || []

      klass_to_headers(@klass)

      Erubis::Eruby.new( File.read(export_template)).result(binding)
    end

    # Create an YAML template from a Excel spreadsheet for mapping headers
    #
    #
    # * <tt>:title</tt> - Top level YAML node -defaults to ConfigGenerator.title
    #
    # * <tt>:model_as_dest</tt> - Override default treatment of using model as the SOURCE
    #
    # * <tt>:file</tt> - Write mappings direct to file name provided
    #
    def generate_from_excel(excel_file_name, options = {})

      excel = Excel.new

      puts "\n\n\nGenerating mapping from Excel file: #{excel_file_name}"

      excel.open(excel_file_name)

      sheet_number = options[:sheet_number] || 0

      sheet = excel.worksheet( sheet_number )

      @headers = parse_headers(sheet, options[:header_row] || 0)

      mappings = options[:title] || ConfigGenerator.title

      if options[:model_as_dest]
        headers.each_with_index { |s, i|  mappings += "       #srcs_column_heading_#{i}: #{s}\n" }
      else
        headers.each_with_index { |s, i|  mappings += "       #{s}: #dest_column_heading_#{i}\n" }
      end

      File.open(options[:file], 'w') { |f| f << mappings } if options[:file]

      mappings

    end

  end

end # DataShift
