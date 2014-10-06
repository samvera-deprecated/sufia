module Sufia
  module RecordsHelperBehavior
    def add_field(key)
      more_or_less_button(key, 'adder', '+')
    end

    def subtract_field(key)
     more_or_less_button(key, 'remover', '-')
    end

    def help_icon(key, content = nil, title = nil)
      content = content || metadata_help(key)
      title = title || get_label(key)
      link_to '#', id: "generic_file_#{key.to_s}_help", rel: 'popover',
              'data-content' => content,
              'data-original-title' => title,
              'aria-label' => get_aria_label(key) do
        content_tag 'i', '', "aria-hidden" => true, class: "help-icon"
      end
    end

    def help_icon_modal(modal_id)
      link_to '#' + modal_id, id: "generic_file_#{modal_id}_help_modal", rel: 'button', 
              data: { toggle: 'modal' }, 'aria-label' => get_aria_label(modal_id) do
        content_tag 'i', '', "aria-hidden" => true, class: 'help-icon'
      end
    end

    def metadata_help(key)
      I18n.t("sufia.metadata_help.#{key}", default: key.to_s.humanize)
    end

    def get_label(key)
      I18n.t("sufia.field_label.#{key}", default: key.to_s.humanize)
    end

    def get_aria_label(key)
      I18n.t("sufia.aria_label.#{key}", default: default_aria_label(key.to_s.humanize))
    end
  
    private

    def more_or_less_button(key, html_class, symbol)
      # TODO, there could be more than one element with this id on the page, but the fuctionality doesn't work without it.
      content_tag('button', class: "#{html_class} btn", id: "additional_#{key}_submit", name: "additional_#{key}") do
        (sr_hidden(symbol) + content_tag('span', class: 'sr-only') do
          "add another #{key.to_s}"
        end).html_safe
      end
    end

    def sr_hidden text
      content_tag :span, text, "aria-hidden" => true
    end

    def default_aria_label text
      I18n.t("sufia.aria_label.default", title: text)
    end
  end
end
