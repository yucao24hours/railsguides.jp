module ActiveRecord
  module Associations
    class BelongsToAssociation < AssociationProxy #:nodoc:

      def reset
        @target = nil
        @loaded = false
      end

      def reload
        reset
        load_target
      end

      def create(attributes = {})
        record = build(attributes)
        record.save
        record
      end

      def build(attributes = {})
        record = @association_class.new(attributes)
        replace(record, true)
        record
      end

      def replace(obj, dont_save = false)
        if obj.nil?
          @target = @owner[@association_class_primary_key_name] = nil
        else
          raise_on_type_mismatch(obj) unless obj.nil?

          @target = obj
          @owner[@association_class_primary_key_name] = obj.id unless obj.new_record?
        end
        @loaded = true
      end

      # Ugly workaround - .nil? is done in C and the method_missing trick doesn't work when we pretend to be nil
      def nil?
        load_target
        @target.nil?
      end

      private
        def find_target
          if @options[:conditions]
            @association_class.find_on_conditions(@owner[@association_class_primary_key_name], @options[:conditions])
          else
            @association_class.find(@owner[@association_class_primary_key_name])
          end
        end

        def target_obsolete?
          @owner[@association_class_primary_key_name] != @target.id
        end

        def construct_sql
          # no sql to construct
        end
    end
  end
end

class NilClass #:nodoc:
  # Ugly workaround - nil comparison is usually done in C and so a proxy object pretending to be nil doesn't work.
  def ==(other)
    other.nil?
  end
end
