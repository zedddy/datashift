# This class provides a value map (hash) from a text mapping file
#
# The map file is  a text file of delimeted key -> values pairs
#
#  SUPPORTED FILE FORMATS:
#
#  2 column e.g. a,b
#   creates a simple hash {a => b)
#
#  3 column e.g. a,b,c
#   a,b becomes the key, c is the vaule
#   creates a hash { [a,b] => c }
#
#  4 column e.g. a,b,c,d
#   a,b  becomes the key, c,d the value
#   creates a hash { [a,b] => [c,d] }
#
#  TODO allow mapping file to be an xml file
#
module DataShift

  class ValueMapFromFile < Hash

    def intialize(file_path, delim = ',')
      @delegate_to = {}
      @delim = delim
      load_map(file_path)
    end

    def load_map(file_path = nil, delim = ',')
      @file = file_path unless file_path.nil?
      @delim = delim

      raise ArgumentError, "Can not read map file: #{@file}" unless File.readable?(@file)

      File.open(@file).each_line do |line|
        next unless line && line.chomp!

        values = line.split(@delim)

        case values.nitems
          when 2 then store(values[0], values[1])
          when 3 then store([values[0], values[1]], values[2])
          when 4 then store([values[0], values[1]], [values[2], values[3]])
          else
            raise ArgumentError, "Bad key,value row in #{@file}: #{values.nitems} number of columns not supported"
        end
      end

      self
    end
  end

=begin EXAMPLE USAGE

  # Inbound file of format
  #   [TradeType,LDN_TradeId,HUB_TradeId,LDN_AssetId,HUB_AssetId,LDN_StrutureId,HUB_StructureId]
  #
  # We require :
  #   [LDN_TradeId, LDN_AssetId, HUB_TradeId, HUB_AssetId]
  #
  class AssetMapFromFile < Array

    def intialize(file_path, delim = ',')
      @delegate_to = {}
      @delim = delim
      load_map(file_path)
    end

    def load_map(file_path = nil, delim = ',')
      @file = file_path unless file_path.nil?
      @delim = delim

      raise ArgumentError, "Can not read asset map file: #{@file}" unless File.readable?(@file)

      File.open(@file).each_line do |line|
        next unless line && line.chomp!
        # skip the header row
        next if line.include?('TradeType')

        values = line.split(@delim)

        push(Array[values[1], values[3], values[2], values[4]])
      end

      self
    end

    def write_map(file_path = nil, delim = ',')
      mapfile = File.open( file_path, 'w')
      each { |row| mapfile.write(row.join(delim) + "\n") }
    end

  end
=end

end
