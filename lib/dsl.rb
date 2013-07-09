module XSemVer
  
  module DSL
    
    def self.included(klass)
      klass.extend ClassMethods
    end




    COMMAND_PREFIX = :_run_
    
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
      
      def command(*command_names, &block)
        method_name = "#{COMMAND_PREFIX}#{command_names.shift}"
        define_method method_name, &block
        command_names.each do |c|
          class_eval "alias :#{COMMAND_PREFIX}#{c} :#{method_name}"
        end
      end
      
    end




  end
  
end