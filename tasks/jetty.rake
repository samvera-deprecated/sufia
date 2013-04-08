namespace :jetty do
  desc "Copies the default Solr & Fedora configs into the bundled Hydra Testing Server"
  task :config do
    Rake::Task["jetty:config_fedora"].invoke
    Rake::Task["jetty:config_solr"].invoke
  end

  desc "Copies the contents of solr_conf into the Solr development-core and test-core of Testing Server"
  task :config_solr do
    FileList['solr_conf/conf/*'].each do |f|
      cp("#{f}", 'jetty/solr/development-core/conf/', :verbose => true)
      cp("#{f}", 'jetty/solr/test-core/conf/', :verbose => true)
    end
  end

  desc "Copies a custom fedora config for the bundled Hydra Testing Server"
  task :config_fedora do
    # load a custom fedora.fcfg -
    if defined?(Rails.root)
      app_root = Rails.root
    else
      app_root = File.join(File.dirname(__FILE__),"..")
    end

    fcfg = File.join(app_root,"fedora_conf","conf","development","fedora.fcfg")
    if File.exists?(fcfg)
      puts "copying over development/fedora.fcfg"
      cp("#{fcfg}", 'jetty/fedora/default/server/config/', :verbose => true)
    else
      puts "#{fcfg} file not found -- skipping fedora config"
    end
    fcfg = File.join(app_root,"fedora_conf","conf","test","fedora.fcfg")
    if File.exists?(fcfg)
      puts "copying over test/fedora.fcfg"
      cp("#{fcfg}", 'jetty/fedora/test/server/config/', :verbose => true)
    else
      puts "#{fcfg} file not found -- skipping fedora config"
    end
  end
end
