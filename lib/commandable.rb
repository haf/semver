module XSemVer
  
  module Commandable
    
    

   
    COMMAND_PREFIX = :run_
    
    class CommandError < StandardError
    end    
    
    def run_command(command)
      method_name = "#{COMMAND_PREFIX}#{command}"
      if self.class.method_defined?(method_name)
        send method_name
      else
        raise CommandError, "invalid command #{command}"
      end
    end




    module ClassMethods
      
      def command(*commands, &block)
        method_name = "#{COMMAND_PREFIX}#{commands.shift}"
        define_method method_name, &block
        commands.each do |c|
          class_eval "alias :#{COMMAND_PREFIX}#{c} :#{method_name}"
        end
      end
      
    end



    
  end
  
end