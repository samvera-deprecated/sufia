module Sufia
  module BreadcrumbHelperBehavior

    def crumbs
      if request.referer.match(/dashboard/)
        [link_to(t('sufia.dashboard.title'), sufia.dashboard_index_path)]
      else
        []
      end
    end

    def breadcrumb_links
      case request.referer
      when /collections/
        crumbs << link_to(t('sufia.dashboard.my.collections'), sufia.dashboard_collections_path)
      when /files/
        crumbs << link_to(t('sufia.dashboard.my.files'), sufia.dashboard_files_path)
      when /catalog/
        crumbs << link_to(t('sufia.bread_crumb.search_results'), request.referer)
      else
        crumbs
      end
    end

  end
end
