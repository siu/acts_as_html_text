require 'active_record'
require 'redcloth'

module Foo
  module Acts #:nodoc:
    module HtmlText #:nodoc:

      def self.append_features(base)
        super
        base.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_html_text
          class_eval do
            extend Foo::Acts::HtmlText::SingletonMethods
            before_save :filter_html_text
          end
          include Foo::Acts::HtmlText::InstanceMethods
        end
      end

      module SingletonMethods
        def html_columns
          @html_columns ||= columns.select { |c| c.name =~ /_html$/ }
        end
        def content_columns
          @content_columns ||= super.reject { |c| c.name =~ /_html$/ }
        end
      end
      
      module InstanceMethods
        def filter_html_text
          attrs = self.class.column_names.select { |c| c =~ /_html$/ }
          attrs.each do |a|
            self.send(a+'=', RedCloth.new(self.send(a.gsub(/_html$/, '')) || '').to_html)
          end
        end

      end

    end
  end
end

ActiveRecord::Base.class_eval do
  include Foo::Acts::HtmlText
end
