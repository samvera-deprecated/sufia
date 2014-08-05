namespace :sufia do


  desc "Load Content Files from the 'CONTENT_FILE_DIRECTORY' directory (and sub-directories)... See ingest.log for results"
  task :load_content_files, [:content_files_directory] do |t, args|
    # You can run this task as follows:
    #   (from rake task): Rake sufia:load_content_files CONTENT_FILE_DIRECTORY=<file directory here, path included> OR Rake::Task["sufia:load_content_files"].invoke('<file directory here, path included>') 
    begin
      IngestLogger.info "********** START: load content files rake task **********"
      # called internally or via passed parameter
      cf_directory = args.content_files_directory ? args.content_files_directory : ENV['CONTENT_FILE_DIRECTORY']
      Sufia::Ingest.load_content_files(cf_directory)
      IngestLogger.info "********** FINISH load content files rake task **********"
    rescue 
      # Move it up the error chain
      raise
    end
  end

  desc "Checks then Ingests 'FOXML_DIRECTORY' directory (and sub-directories)... See ingest.log for results"
  task :check_and_ingest_foxml_directory, [:ingest_directory] do |t, args|
    # You can run this task 1 of 3 (main) ways:
    #   1 (from command line): rake sufia:check_and_ingest_foxml_directory FOXML_DIRECTORY='<file directory here, path included>'
    #   2 (from command line): rake sufia:check_and_ingest_foxml_directory['<file directory here, path included>']
    #   3 (from rake task): Rake::Task["sufia:check_and_ingest_foxml_directory"].invoke('<file directory here, path included>')
    begin
      IngestLogger.info "********** START: check & ingest directory rake task **********"
      # called internally or via passed parameter
      foxml_directory = args.ingest_directory ? args.ingest_directory : ENV['FOXML_DIRECTORY']
      if (!Sufia::Ingest.check_foxml_directory(foxml_directory))
        # if zero return code, do not run ingest
        IngestLogger.error "   PROBLEM: zero return code from directory_check, #{foxml_directory} not ingested"
        IngestLogger.info "********** FINISH check & ingest directory rake task **********"
        raise
      end 
      # no error... so ingest
      Sufia::Ingest.ingest_foxml_directory(foxml_directory)
      IngestLogger.info "********** FINISH check & ingest directory rake task **********"
    rescue 
      # Move it up the error chain
      raise
    end
  end


  desc "Checks then Ingests 'FOXML_FILE' file... See ingest.log for results"
  task :check_and_ingest_foxml_file, [:ingest_file] do |t, args|
    # You can run this task 1 of 3 (main) ways:
    #   1 (from command line): rake sufia:check_and_ingest_foxml_file FOXML_FILE=='<filename here, path included>'
    #   2 (from command line): rake sufia:check_and_ingest_foxml_file['<filename here, path included>']
    #   3 (from rake task): Rake::Task["sufia:check_and_ingest_foxml_file"].invoke('<filename here, path included>')
    begin 
      IngestLogger.info "********** START: check & ingest file rake task **********"
      # called internally or via passed parameter
      foxml_file = args.ingest_file ? args.ingest_file : ENV['FOXML_FILE']
      if (Sufia::Ingest.check_foxml_file(foxml_file))
        # if non-zero return code, do not run ingest
        IngestLogger.error "   PROBLEM: non-zero return code from file_check, #{foxml_file} not ingested"
        IngestLogger.info "********** FINISH: check & ingest file rake task **********"
        raise
      end   
      # no error... so ingest
      Sufia::Ingest.ingest_foxml_file(foxml_file)
      IngestLogger.info "********** FINISH: check & ingest file rake task **********"
    rescue 
      # Move it up the error chain
      raise
    end
  end


  desc "Ingests 'FOXML_DIRECTORY' directory (and sub-directories)... NO full, proper error-checking for this task"
  task :ingest_foxml_directory, [:ingest_directory] do |t, args|
    # You can run this task 1 of 3 (main) ways:
    #   1 (from command line): rake sufia:ingest_foxml_directory FOXML_DIRECTORY='<file directory here, path included>'
    #   2 (from command line): rake sufia:ingest_foxml_directory['<file directory here, path included>']
    #   3 (from rake task): Rake::Task["sufia:ingest_foxml_directory"].invoke('<file directory here, path included>')
    begin
      # called internally or via passed parameter
      #IngestLogger.info "********** START: ingest_foxml_directory rake task **********"
      foxml_directory = args.ingest_directory ? args.ingest_directory : ENV['FOXML_DIRECTORY']
      Sufia::Ingest.ingest_foxml_directory(foxml_directory)
      #IngestLogger.info "********** FINISH: check_foxml_directory rake task **********"
    rescue 
      # Move it up the error chain
      raise
    end
  end


  desc "Ingests Foxml file... NO full, proper error-checking for this task"
  task :ingest_foxml_file, [:ingest_file] do |t, args|
    # You can run this task 1 of 3 (main) ways:
    #   1 (from command line): rake sufia:ingest_foxml_file FOXML_FILE=='<filename here, path included>'
    #   2 (from command line): rake sufia:ingest_foxml_file['<filename here, path included>']
    #   3 (from rake task): Rake::Task["sufia:ingest_foxml_file"].invoke('<filename here, path included>')
    begin 
      # called internally or via passed parameter
      IngestLogger.info "********** START: ingest_foxml_file rake task **********"
      foxml_file = args.ingest_file ? args.ingest_file : ENV['FOXML_FILE']
      Sufia::Ingest.ingest_foxml_file(foxml_file)
      IngestLogger.info "********** FINISH: ingest_foxml_file rake task **********"
    rescue 
      # Move it up the error chain
      raise
    end
  end


  desc "Checks 'FOXML_DIRECTORY' directory (and sub-directories) to see if ok for ingest... See ingest.log for results"
  task :check_foxml_directory, [:ingest_directory] do |t, args|
    # You can run this task 1 of 3 (main) ways:
    #   1 (from command line): rake sufia:check_foxml_directory FOXML_DIRECTORY='<file directory here, path included>'
    #   2 (from command line): rake sufia:check_foxml_directory['<file directory here, path included>']
    #   3 (from rake task): Rake::Task["sufia:check_foxml_directory"].invoke('<file directory here, path included>')
    begin
      # called internally or via passed parameter
      #IngestLogger.info "***** START: check_foxml_directory rake task *****"
      foxml_directory = args.ingest_directory ? args.ingest_directory : ENV['FOXML_DIRECTORY']
      Batch::Ingest.check_foxml_directory(foxml_directory)
      #IngestLogger.info "***** FINISH: check_foxml_directory rake task *****"
    rescue 
      # Move it up the error chain
      raise
    end
  end


  desc "Checks Foxml file to see if ok for ingesti... See ingest.log for results"
  task :check_foxml_file, [:ingest_file] do |t, args|
    # You can run this task 1 of 3 (main) ways:
    #   1 (from command line): rake sufia:check_foxml_file FOXML_FILE=='<filename here, path included>'
    #   2 (from command line): rake sufia:check_foxml_file['<filename here, path included>']
    #   3 (from rake task): Rake::Task["sufia:check_foxml_file"].invoke('<filename here, path included>')
    begin 
      # called internally or via passed parameter
      #IngestLogger.info "********** START: check_foxml_file rake task **********"
      foxml_file = args.ingest_file ? args.ingest_file : ENV['FOXML_FILE']
      Sufia::Ingest.check_foxml_file(foxml_file)
      #IngestLogger.info "********** FINISH: check_foxml_file rake task **********"
    rescue 
      # Move it up the error chain
      raise
    end
  end
end 
