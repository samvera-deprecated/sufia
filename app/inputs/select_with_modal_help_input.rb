class SelectWithModalHelpInput < SimpleForm::Inputs::CollectionSelectInput
  include WithHelpIcon

  def link_to_help
    template.link_to "##{attribute_name}Modal", id: "#{input_class}_help_modal", rel: 'button', data: { toggle: 'modal' }, 'aria-label' => aria_label do
      help_icon
    end
  end
end
