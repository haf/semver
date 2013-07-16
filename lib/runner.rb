require 'semver'
require 'dsl'

module XSemVer
  
  # Allows SemVer operations to be performed from the command line
  class Runner
    
    include XSemVer::DSL
    
    # Runs a command that performs an operation on a SemVer file. Runs the +tag+ command by default.
    # @param [String, Symbol] args One or more strings which represent the command to be performed and any parameters.
    def initialize(*args)
      @args = args
      run_command(@args.shift || :tag)
    end
    
    private
    
    # @return [String] The value of the next parameter. The parameter is delete from the array of remaining parameters.
    # @raise [CommandError] Raised if no parameters remain.
    def next_param_or_error(error_message)
      @args.shift || raise(CommandError, error_message)
    end
    
    # @return [String] The text to be displayed when the +help+ command is run.
    def help_text
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
    
    
    
    
    # Create a new .semver file in the current directory if the file does not exist.
    command :initialize, :init do
      file = SemVer.file_name
      if File.exist? file
        puts "#{file} already exists"
      else
        version = SemVer.new
        version.save file
      end
    end
    
    
    # Increment the major, minor, or patch of the .semver file.
    # Sets the minor, patch, pre-release, and metadata values accordingly.
    command :increment, :inc do
      version = SemVer.find
      dimension = next_param_or_error("required: major | minor | patch")
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
    
    
    # Sets the pre-release of the .semver file.
    command :special, :spe, :prerelease, :pre do
      version = SemVer.find
      version.special = next_param_or_error("required: an arbitrary string (beta, alfa, romeo, etc)")
      version.save
    end
    
    
    # Sets the metadata of the .semver file.
    command :metadata, :meta do
      version = SemVer.find
      version.metadata = next_param_or_error("required: an arbitrary string (beta, alfa, romeo, etc)")
      version.save
    end
    
        
    # Outputs the semver as specified by a format string.
    # See: SemVer#format
    command :format do
      version = SemVer.find
      puts version.format(next_param_or_error("required: format string"))
    end
    
    
    # Outputs the semver with default formatting.
    # See: SemVer#to_s
    command :tag do
      version = SemVer.find
      puts version.to_s
    end
    
    
    # Outputs instructions for using the semvar command.
    command :help do
      puts help_text
    end
    



  end
  
end