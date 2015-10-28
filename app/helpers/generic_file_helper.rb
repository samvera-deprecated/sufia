# -*- coding: utf-8 -*-
module GenericFileHelper
  def display_title(gf)
    gf.to_s
  end

  def present_terms(presenter, terms = :all, &block)
    terms = presenter.terms if terms == :all
    Sufia::PresenterRenderer.new(presenter, self).fields(terms, &block)
  end

  def render_download_icon(title = nil)
    if title.nil?
      link_to download_image_tag, sufia.download_path(@generic_file), target: "_blank", title: "Download the document", id: "file_download", data: { label: @generic_file.id }
    else
      label = download_image_tag(title)
      link_to label, sufia.download_path(@generic_file), target: "_blank", title: title, id: "file_download", data: { label: @generic_file.id }
    end
  end

  def render_download_link(text = nil)
    label = text || 'Download'
    link_to label, sufia.download_path(@generic_file), id: "file_download", target: "_new", data: { label: @generic_file.id }
  end

  def render_collection_list(gf)
    ("Is part of: " + gf.collections.map { |c| link_to(c.title, collections.collection_path(c)) }.join(", ")).html_safe unless gf.collections.empty?
  end

  def display_multiple(value)
    auto_link(value.join(" | "))
  end

  private

    def download_image_tag(title = nil)
      content_tag :figure do
        if title.nil?
          concat image_tag "default.png", alt: "No preview available", class: "img-responsive"
        else
          concat image_tag sufia.download_path(@generic_file, file: 'thumbnail'), class: "img-responsive", alt: "#{title} of #{@generic_file.title.first}"
        end
        concat content_tag :figcaption, "Download the full sized image"
      end
    end

    def render_visibility_badge
      if can? :edit, @generic_file
        render_visibility_link @generic_file
      else
        render_visibility_label @generic_file
      end
    end
end
