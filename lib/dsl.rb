module XSemVer
  
  module DSL
    
    def self.included(klass)
      klass.extend ClassMethods
      klass.send :include, InstanceMethods
    end

    # Raised when attempting to run a command that has not been defined
    # or when a command is run with an invalid or missing parameter.
    class CommandError < StandardError
    end    
    
    
    
    
    module InstanceMethods
      
      # Runs a command that has been defined via the +command+ class method.
      # 
      # @param [String] command The name of the command to be run.
      # @raise [CommandError] Raised if the command has not been defined.
      def run_command(command)
        method_name = "#{self.class.command_prefix}#{command}"
        if self.class.method_defined?(method_name)
          send method_name
        else
          raise CommandError, "invalid command #{command}"
        end
      end
      
    end




    module ClassMethods
      
      # Defines a command.
      # 
      # @param [String, Symbol] command_names One or more names by which this command is called.
      # @yield The code to be executed when this command is called.
      def command(*command_names, &block)
        method_name = "#{command_prefix}#{command_names.shift}"
        define_method method_name, &block
        command_names.each do |c|
          alias_method "#{command_prefix}#{c}", method_name
        end
      end
      
      # @return [Symbol] The prefix that is appended to the name of any instance method defined by the +command+ method.
      def command_prefix
        :_run_
      end
      
    end




  end
  
end