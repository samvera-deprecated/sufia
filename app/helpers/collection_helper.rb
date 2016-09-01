# -*- coding: utf-8 -*-
module CollectionHelper
  def render_collection_visibility_badge
    if can? :edit, @collection
      render_collection_visibility_link(@collection)
    else
      render_visibility_label(@collection)
    end
  end

  def render_collection_visibility_link(collection)
    link_to render_visibility_label(collection), collections.edit_collection_path(collection, anchor: "permissions_display"),
            id: "permission_" + collection.id, class: "visibility-link"
  end
end
