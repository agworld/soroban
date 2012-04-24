module Soroban
  module Import

    # Use the RubyXL gem to load an xlsx file, returning a new Soroban::Sheet
    # object. Specify the path to the xlsx file, the index of the sheet to be
    # imported, and a hash of name => label bindings.
    def self.rubyXL(path, sheet, bindings)
      require 'rubyXL'
      require 'soroban/import/ruby_xl_patch'
      RubyXLImporter.new(path, sheet, bindings).import
    end

    private

    class RubyXLImporter

      def initialize(path, index, bindings)
        @path, @index, @bindings = path, index, bindings
      end

      def import
        workbook = RubyXL::Parser.parse(@path)
        @sheet = workbook.worksheets[@index]
        @model = Soroban::Sheet.new
        @bindings.values.each do |label_or_range|
          if Soroban::range?(label_or_range)
            LabelWalker.new(label_or_range).each do |label|
              _addCell(label)
            end
          else
            _addCell(label_or_range)
          end
        end
        while label = @model.missing.first
          _addCell(label)
        end
        @model.bind(@bindings)
        return @model
      end

      private

      def _addCell(label)
        row, col = Soroban::getPos(label)
        cell = @sheet[row][col]
        data = cell.formula rescue nil
        data = "=#{data}" unless data.nil?
        data ||= cell.value.to_s rescue nil
        @model.set(label.to_sym => data)
      end

    end

  end
end
