module Sufia
  module Messages
    extend ActiveSupport::Concern

    # Borrowed from AbstractController so we can render html content tags
    attr_accessor :output_buffer
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper

    def success_subject
      I18n.t("sufia.messages.success.subject")
    end

    def failure_subject
      I18n.t("sufia.messages.failure.subject")
    end

    def single_success id, file
      content_tag :span, id: "ss-"+id do
        [link_to_file(file), I18n.t("sufia.messages.success.single")].join(" ").html_safe
      end
    end

    def multiple_success id, files
      content_tag :span, id: "ss-"+id do
        [success_link(files), I18n.t("sufia.messages.success.multiple.tag")].join(" ").html_safe
      end
    end

    def single_failure id, file
      content_tag :span, id: "ss-"+id do
        [link_to_file(file), I18n.t("sufia.messages.failure.single")].join(" ").html_safe
      end
    end

    def multiple_failure id, files
      content_tag :span, id: "ss-"+id do
        [failure_link(files), I18n.t("sufia.messages.failure.multiple.tag")].join(" ").html_safe
      end
    end

    # Double-quotes are replaced with single ones so this list can be included in a data block. Ex:
    #   <a href="#" data-content="<a href='#'>embedded link</a>" rel="popover">Click me</a>
    def file_list files
      files.map { |gf| link_to_file(gf) }.join(', ').gsub(/"/, "'")
    end

    def link_to_file file
      link_to(file.to_s, Sufia::Engine.routes.url_helpers.generic_file_path(file.noid))
    end

    private

    def success_link files
      link_to I18n.t("sufia.messages.success.multiple.link"), "#", 
        rel: "popover", 
        data: { content: file_list(files).html_safe, title: I18n.t("sufia.messages.success.title") }
    end

    def failure_link files
      link_to I18n.t("sufia.messages.failure.multiple.link"), "#", 
        rel: "popover", 
        data: { content: file_list(files).html_safe, title: I18n.t("sufia.messages.failure.title") }
    end

  end
end
