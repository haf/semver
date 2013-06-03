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
    
    
    
    
    def initialize(*args)
      @args = args
      command = @args.shift
      if VALID_COMMANDS.include?(command)
        self.send("run_#{command}")
      end
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
    
    
    
    
  end
  
end