# require 'set'
require 'fileutils'
require "active-fedora"
require "active_support" # This is just to load ActiveSupport::CoreExtensions::String::Inflections

module Batch::Ingest

  def check_foxml_file(foxml_file_full)
    begin
      # return code is zero if duplication (and no RAISE condition) encountered 
      rc = 1
      # Assume foxml_file_full is full path and formed using forward slashes regardless of the separator used on the local file system
      foxml_file = File.basename(foxml_file_full)
      if (foxml_file.nil? || foxml_file.blank?)
        IngestLogger.error "  ingest_check NOT ok: #{foxml_file_full}."
        raise StandardError, "PROBLEM: At least one improper ingest file (#{foxml_file_full}).  To fix, make sure file exists and is not blank.  Once these conditions are verified, run task again", caller
      end

      # check if foxml standard name... prefix=foxml_ and extension=.xml
      if (foxml_file =~ /^ *foxml\_.+\.xml *$/)

        # if ingest foxml file
        if ( !(File.size?(foxml_file_full)) || !(File.readable?(foxml_file_full)) )
          IngestLogger.error "  ingest_check NOT ok: #{foxml_file_full}."
          raise StandardError, "PROBLEM: At least one improper ingest file (#{foxml_file_full}).  To fix, make sure file 1) has size > 0 and 2) is readable.  Once these conditions are verified, run task again", caller
        else 
          # Duplicate check below
          # IngestLogger.info "  ingest_check ok (before dup check): #{foxml_file_full}"
        end

        # check to see if duplicate
        file_to_check = File.new(foxml_file_full, "r")
        pid = Nokogiri::XML(file_to_check).at_css("digitalObject").attribute("PID").content
        # the following statement will throw an error if not there (to make it more like ActiveRecord... eventually, there may be an .exists?)
        fed_rec = ActiveFedora::Base.find(pid)

        # If duplicate record, we get here
        IngestLogger.warn "   Likely DUPLICATE pid record here: #{foxml_file_full}"  
        rc = 0 
      else 

        # if not ingest foxml file
        if ( !(File.size?(foxml_file_full)) || !(File.readable?(foxml_file_full)) )
          IngestLogger.warn "  file_check NOT ok: #{foxml_file_full}"
          raise StandardError, "WARNING: At least one possible improper file (#{foxml_file_full}) in ingest directory.  To fix, make sure file 1) has size > 0 and 2) is readable.  Once these conditions are verified, run task again", caller
        else 
          IngestLogger.info "  file_check ok: #{foxml_file_full}"
        end
      end 
      # return code
      return rc

    rescue ActiveFedora::ObjectNotFoundError => e
      IngestLogger.info "  ingest_check ok: #{foxml_file_full}"
      # Could not find PID in Fedora... so good-to-go
      # do NOT raise exception to higher level.  Keep on processing.  Note: Non-zero error condition is returned
    rescue 
      raise
    end
  end

  def ingest_foxml_file(foxml_file_full)
    # Assume foxml_file_full is full path and formed using forward slashes regardless of the separator used on the local file system
    # for testing...
    IngestLogger.info "   +++  START: file ingest #{foxml_file_full}"

    # Assume foxml_file_full is full path and formed using forward slashes regardless of the separator used on the local file system
    foxml_file = File.basename(foxml_file_full)

    # check if foxml standard name... prefix=foxml_ and extension=.xml
    if (foxml_file =~ /^ *foxml\_.+\.xml *$/)
      # file to ingest
      file = File.new(foxml_file_full, "r")
      # check to see if duplicate
      pid = Nokogiri::XML(file).at_css("digitalObject").attribute("PID").content
      begin
        # the following statement will throw an error if not there (to make it more like ActiveRecord... eventually, there may be an .exists?)
        fed_rec = ActiveFedora::Base.find(pid)

        # If duplicate record, we get here
        IngestLogger.error "   Likely DUPLICATE pid record here: #{foxml_file_full}"  
        raise StandardError, "ERROR: Likely Duplicate pid record here: #{foxml_file_full}", caller
      rescue ActiveFedora::ObjectNotFoundError => e
        # Could not find PID in Fedora... so good-to-go
        # do NOT raise exception to higher level.  Keep on processing
      rescue 
        raise
      end
      begin
        file = File.new(foxml_file_full, "r")
        result = ActiveFedora::Base.connection_for_pid('0').ingest(:file=>file.read)
        raise "--- Failed to ingest #{foxml_file_full}" unless result

        ActiveFedora::Base.find(result.body, :cast=>true).update_index

        # for testing...
        IngestLogger.info "   +++  FINISH: file ingest ok"

      rescue => bang
        IngestLogger.error "PROBLEM: file ingest error... #{bang}" 
        raise
      # rescue Rubydora::FedoraInvalidRequest => e
      #   IngestLogger.error "in Rubydora rescue\n"
      #   IngestLogger.error e.message  
      #   raise
      end 
    else
      # for testing...
      IngestLogger.info "   +++  FINISH: file not ingested"
    end 
  end

  def check_foxml_directory(foxml_directory)
    # NOTE: recusrsive method here
    begin
      # NOTE: only need one rc=0 to propogate it up recursively
      rc = 1
      # do some sanity checks
      if (foxml_directory.nil? || foxml_directory.blank?)
        raise StandardError, "PROBLEM: Directory (#{foxml_directory}).  To fix, make sure directory exists & is not blank.  Once these conditions are verified, run task again", caller
      end

      # normalize & get rid of slash at end of path
      foxml_directory = foxml_directory.gsub(/\/+$/,'')

      if (!(File.directory?(foxml_directory))) 
        raise StandardError, "PROBLEM: Directory (#{foxml_directory}).  To fix, make sure directory is actually a directory.  Once condition is verified, run task again", caller
      end

      if (!(File.executable?(foxml_directory))) 
        raise StandardError, "PROBLEM: Directory (#{foxml_directory}).  To fix, make sure directory is executable (so able to process it).  Once condition is verified, run task again", caller
      end

      IngestLogger.info "*** Checking ingest directory #{foxml_directory}"
      # Find all files and directories in the source directory
      sources = (Dir["#{foxml_directory}/*"] + Dir["#{foxml_directory}/.*"].reject { |f| ['.', '..'].include?(File.basename(f)) }).sort
      source_dirs = sources.select { |s| File.directory?(s) }
      source_files = sources.select { |s| File.file?(s) }

      # check each file in the present directory
      source_files.each do |subfile|
        if (!self.check_foxml_file(subfile))
          rc = 0
        end
      end
      
      # recursively check each subdirectory
      source_dirs.each do |subdir|
        Dir.chdir(subdir) do
          # subdir.check_foxml_directory(File.join(foxml_directory, subdir))
          if (!self.check_foxml_directory(subdir))
            rc = 0 
          end
        end
      end
      IngestLogger.info "*** Finished checking ingest directory #{foxml_directory}"
      return rc
    rescue
      raise
    end
  end 

  def ingest_foxml_directory(foxml_directory)
    # NOTE: 1) recusrsive method here and 2) assume the check has already run
    begin
      IngestLogger.info "*** START: ingesting directory #{foxml_directory}"
      # Find all files and directories in the source directory
      sources = (Dir["#{foxml_directory}/*"] + Dir["#{foxml_directory}/.*"].reject { |f| ['.', '..'].include?(File.basename(f)) }).sort
      source_dirs = sources.select { |s| File.directory?(s) }
      source_files = sources.select { |s| File.file?(s) }

      # check each file in the present directory
      source_files.each do |subfile|
        self.ingest_foxml_file(subfile)
      end
      
      # recursively check each subdirectory
      source_dirs.each do |subdir|
        Dir.chdir(subdir) do
          # subdir.check_foxml_directory(File.join(foxml_directory, subdir))
          self.ingest_foxml_directory(subdir)
        end
      end
      IngestLogger.info "*** FINISH: ingesting directory #{foxml_directory}"
    rescue
      raise
    end
  end 

  def load_content_files(cf_directory)
    # NOTE: 1) recusrsive method here
    begin
      IngestLogger.info "*** START: loading directory #{cf_directory}"

      # do some directory sanity checks
      if (cf_directory.nil? || cf_directory.blank?)
        raise StandardError, "PROBLEM: Directory (#{cf_directory}).  To fix, make sure directory exists & is not blank.  Once these conditions are verified, run task again", caller
      end

      # normalize & get rid of slash at end of path
      cf_directory = cf_directory.gsub(/\/+$/,'')

      if (!(File.directory?(cf_directory))) 
        raise StandardError, "PROBLEM: Directory (#{cf_directory}).  To fix, make sure directory is actually a directory.  Once condition is verified, run task again", caller
      end

      if (!(File.executable?(cf_directory))) 
        raise StandardError, "PROBLEM: Directory (#{cf_directory}).  To fix, make sure directory is executable (so able to process it).  Once condition is verified, run task again", caller
      end

      # Find all files and directories in the source directory
      sources = (Dir["#{cf_directory}/*"] + Dir["#{cf_directory}/.*"].reject { |f| ['.', '..'].include?(File.basename(f)) }).sort
      source_dirs = sources.select { |s| File.directory?(s) }
      source_files = sources.select { |s| File.file?(s) }
    rescue
      raise
    end

    # check each file in the present directory
    source_files.each do |subfile|

      begin 
        # do some sanity checks
        # Assume subfile is full path and formed using forward slashes regardless of the separator used on the local file system
        content_file = File.basename(subfile)
        if (content_file.nil? || content_file.blank?)
          IngestLogger.error "  NOT ok (nil or blank file): #{content_file}."
          next 
        end

        # check if our "standard" name... prefix=cm_ and extension=.xml
        if (content_file =~ /^ *cm\_.+\.xml *$/)
          # if size <= 0 OR not readable
          if ( !(File.size?(subfile)) || !(File.readable?(subfile)) )
            IngestLogger.error "  NOT ok (bad size or not readable): #{content_file}."
            next
          end 
        end
      rescue
        raise
      end  
    
      # check if content model file standard name... prefix=cm_ and extension=.xml
      if (content_file =~ /^ *cm\_.+\.xml *$/)
        # skip looking for duplicates, let that happen when ingesting
        begin
          # ingest file
          file = File.new(subfile, "r")
          result = ActiveFedora::Base.connection_for_pid('0').ingest(:file=>file.read)
          raise "--- Failed to ingest #{content_file}" unless result

          ActiveFedora::Base.find(result.body, :cast=>true).update_index
          IngestLogger.info "  ok: #{content_file}."

        rescue => bang
          IngestLogger.error "PROBLEM: content file ingest error... #{bang}" 
          raise
        end 
      else
        IngestLogger.info "  NOT ok (not in standard name format): #{content_file}."
      end
    end
      
    # recursively check each subdirectory
    source_dirs.each do |subdir|
      Dir.chdir(subdir) do
        self.load_content_files(subdir)
      end
    end
    IngestLogger.info "*** FINISH: loading directory #{cf_directory}"
  end 

  # expose the methods... associate with the module class (Batch::Ingest)-- refenced as self-- with the instance methods
  extend self

end
