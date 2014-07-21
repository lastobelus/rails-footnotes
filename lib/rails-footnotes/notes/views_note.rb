module Footnotes
  module Notes
    class ViewsNote < AbstractNote
      cattr_accessor :views
      def initialize(controller)
        @controller = controller
      end

      def self.start!(controller)
        self.views = []
        @subscriber_views ||= ActiveSupport::Notifications.subscribe('render_template.action_view') do |*args|
          event = ActiveSupport::Notifications::Event.new *args
          self.views << {:file => event.payload[:identifier], :duration => event.duration}
        end
        @subscriber_partials ||= ActiveSupport::Notifications.subscribe('render_partial.action_view') do |*args|
          event = ActiveSupport::Notifications::Event.new *args
          self.views << {:file => event.payload[:identifier], :duration => event.duration}
        end
      end

      def row
        :edit
      end

      def title
        "Views (#{views.size})"
      end

      def content
        rows = self.class.views.map do |view|
          href = Footnotes::Filter.prefix(view[:file],1,1)
          shortened_name = view[:file].gsub(File.join(Rails.root,"app/views/"),"")
          [%{<a href="#{href}">#{shortened_name}</a>},"#{view[:duration]}ms"]
        end
        mount_table(rows.unshift(%w(View Time)), :summary => "Views for #{title}")
      end
    end
  end
end