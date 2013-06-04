require 'semver'

module XSemVer
  
  # Contains the logic for performing SemVer operations from the command line.
  class Runner
    
    class CommandError < StandardError
    end
    
    
    # Run a semver command. Raise a CommandError if the command does not exist.
    # Expects an array of commands, such as ARGV.
    def initialize(*args)
      @args = args
      command = @args.shift || :tag
      begin
        self.send("run_#{command}")
      rescue NoMethodError
        raise CommandError, "invalid command #{command}"
      end
    end
    
    
    # Return the text to be displayed when the 'help' command is run.
    def self.help_text
      <<-HELP
semver commands
---------------

init[ialze]                        # initialize semantic version tracking
inc[rement] major | minor | patch  # increment a specific version number
pre[release] [STRING]              # set a pre-release version suffix
spe[cial] [STRING]                 # set a pre-release version suffix (deprecated)
meta[data] [STRING]                # set a metadata version suffix
format                             # printf like format: %M, %m, %p, %s
tag                                # equivalent to format 'v%M.%m.%p%s'
help

PLEASE READ http://semver.org
      HELP
    end
    
    
    # Create a new .semver file if the file does not exist.
    def run_initialize
      file = SemVer::FILE_NAME
      if File.exist? file
        puts "#{file} already exists"
      else
        version = SemVer.new
        version.save file
      end
    end
    alias :run_init :run_initialize
    
    
    # Increment the major, minor, or patch of the .semver file.
    def run_increment
      version = SemVer.find
      dimension = @args.shift or raise CommandError, "required: major | minor | patch"
      case dimension
      when 'major'
        version.major += 1
        version.minor =  0
        version.patch =  0
      when 'minor'
        version.minor += 1
        version.patch =  0
      when 'patch'
        version.patch += 1
      else
        raise CommandError, "#{dimension} is invalid: major | minor | patch"
      end
      version.special = ''
      version.metadata = ''
      version.save
    end
    alias :run_inc :run_increment
    
    
    # Set the pre-release of the .semver file.
    def run_special
      version = SemVer.find
      special_str = @args.shift or raise CommandError, "required: an arbitrary string (beta, alfa, romeo, etc)"
      version.special = special_str
      version.save
    end
    alias :run_spe        :run_special
    alias :run_pre        :run_special
    alias :run_prerelease :run_special
    
    
    # Set the metadata of the .semver file.
    def run_metadata
      version = SemVer.find
      special_str = @args.shift or raise CommandError, "required: an arbitrary string (beta, alfa, romeo, etc)"
      version.metadata = special_str
      version.save
    end
    alias :run_meta :run_metadata
    
        
    # Output the semver as specified by a format string.
    # See: SemVer#format
    def run_format
      version = SemVer.find
      format_str = @args.shift or raise CommandError, "required: format string"
      puts version.format(format_str)
    end
    
    
    # Output the semver with the default formatting.
    # See: SemVer#to_s
    def run_tag
      version = SemVer.find
      puts version.to_s
    end
    
    
    # Output instructions for using the semvar command.
    def run_help
      puts self.class.help_text
    end
    
    
  end
  
end