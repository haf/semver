module XSemVer
  
  # Contains the logic for performing SemVer operations from the command line.
  class Runner
    
    VALID_COMMANDS = %w(
      init
      initialize
      inc
      increment
      spe
      special
      format
      tag
      help
    )
    
    class CommandError < StandardError
    end
    
    
    
    
    def initialize(*args)
      @args = args
      command = @args.shift || :tag
      self.send("run_#{command}")
    end
        
    def run_init
      run_initialize
    end
    
    def run_initialize
      file = SemVer::FILE_NAME
      if File.exist? file
        puts "#{file} already exists"
      else
        version = SemVer.new
        version.save file
      end
    end
    
    def run_inc
      run_increment
    end
    
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
      version.save
    end
    
    def run_spe
      run_special
    end
    
    def run_special
      version = SemVer.find
      special_str = @args.shift or raise CommandError, "required: an arbitrary string (beta, alfa, romeo, etc)"
      version.special = special_str
      version.save
    end
    
    def run_format
      version = SemVer.find
      format_str = @args.shift or raise CommandError, "required: format string"
      puts version.format(format_str)
    end
    
    def run_tag
      version = SemVer.find
      puts version.to_s
    end
    
    
    
    
  end
  
end