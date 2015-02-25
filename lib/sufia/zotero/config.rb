 module Sufia
   module Zotero
     def self.config
       @config ||= reload_config!
     end

     def self.reload_config!
       @config = YAML.load(ERB.new(IO.read(File.join(Rails.root, 'config', 'zotero.yml'))).result)['zotero']
     end

     def self.publications_url(zotero_userid)
       # TODO: Restore this when supported on the Zotero server
       #"/users/#{zotero_userid}/publications/items"
       "/users/#{zotero_userid}/collections/UD96QSU4"
     end
   end
 end
