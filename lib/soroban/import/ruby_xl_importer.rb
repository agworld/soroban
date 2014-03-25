require 'soroban/helpers'
require 'soroban/sheet'
require 'soroban/label_walker'

module Soroban

  module Import

    # Use the RubyXL gem to load an xlsx file, returning a new Soroban::Sheet
    # object. Specify the path to the xlsx file, the index of the sheet to be
    # imported, and a hash of name => label bindings.
    def self.rubyXL(path, sheet, bindings)
      RubyXLImporter.new(path, sheet, bindings).import
    end

    private

    class RubyXLImporter

      def initialize(path, index, bindings)
        @_path, @_index, @_bindings = path, index, bindings
        @_sheet = nil
        @_model = nil
      end

      def import
        workbook = RubyXL::Parser.parse(@_path)
        @_sheet = workbook.worksheets[@_index]
        @_model = Soroban::Sheet.new
        @_bindings.values.each do |label_or_range|
          if Soroban::Helpers::range?(label_or_range)
            Soroban::LabelWalker.new(label_or_range).each do |label|
              _addCell(label)
            end
          else
            _addCell(label_or_range)
          end
        end
        while label = @_model.missing.first
          _addCell(label)
        end
        @_model.bind(@_bindings)
        return @_model
      end

      private

      def _addCell(label)
        row, col = Soroban::Helpers::getPos(label)
        cell = @_sheet[row][col]
        data = cell.formula rescue nil
        data = "=#{data}" unless data.nil?
        data ||= cell.value.to_s rescue nil
        @_model.set(label.to_sym => data)
      end

    end

  end

end
