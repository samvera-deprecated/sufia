# Copyright © 2012 The Pennsylvania State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# -*- encoding : utf-8 -*-
module Sufia
  module SolrDocumentBehavior
    def title_or_label
      title || label
    end


    ##
    # Give our SolrDocument an ActiveModel::Naming appropriate route_key
    def route_key
      get('has_model_ssim').split(':').last.downcase
    end


    ##
    # Offer the source (ActiveFedora-based) model to Rails for some of the 
    # Rails methods (e.g. link_to). 
    # @example 
    #   link_to '...', SolrDocument(:id => 'bXXXXXX5').new => <a href="/dams_object/bXXXXXX5">...</a>
    def to_model
      m = ActiveFedora::Base.load_instance_from_solr(id, self)
      return self if m.class == ActiveFedora::Base
      m
    end

    def noid
      self[Solrizer.solr_name('noid', Sufia::GenericFile.noid_indexer)]
    end


    def date_uploaded
      field = self[Solrizer.solr_name("desc_metadata__date_uploaded", type: :date)]
      return unless field.present?
      Date.parse(field.first).to_formatted_s(:standard)
    end


    def depositor(default = '')
      val = Array(self[Solrizer.solr_name("depositor")]).first
      val.present? ? val : default
    end

    def title
      Array(self[Solrizer.solr_name('desc_metadata__title')]).first
    end

    def description
      Array(self[Solrizer.solr_name('desc_metadata__description')]).first
    end

    def label
      Array(self[Solrizer.solr_name('label')]).first
    end

    def file_format
       Array(self[Solrizer.solr_name('file_format')]).first
    end

    def creator
      Array(self[Solrizer.solr_name("desc_metadata__creator")]).first
    end

    def tags
      self[Solrizer.solr_name("desc_metadata__tag")]
    end

    def mime_type
      Array(self[Solrizer.solr_name("mime_type")]).first
    end

    def read_groups
      Array(self[Ability.read_group_field])
    end

    def edit_groups
      Array(self[Ability.edit_group_field])
    end

    def edit_people
      Array(self[Ability.edit_person_field])
    end

    def public?
      read_groups.include?('public')
    end

    def registered?
      read_groups.include?('registered')
    end
  end
end
