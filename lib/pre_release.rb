module XSemVer
  
  # Represents the pre-release portion of a SemVer string.
  # Comparable to other pre-release strings according to the SemVer 2.0.0-rc2 specification.
  # 
  # @attribute [r] ids
  #   @return [Array<String>] An array of the dot-separated components of the pre-release string.
  class PreRelease
    
    # @return [Regexp] A regular expression that matches a string of only digits.
    ONLY_DIGITS = /\A\d+\z/
    
    attr_reader :ids
    
    include Comparable
    
    
    
    # @param [String] prerelease_string The pre-release data.
    # Individual components of the pre-release should be separated with dots.
    def initialize(prerelease_string)
      @ids = prerelease_string.split(".")
    end
    
    # @return [String] A string representation of the pre-release.
    def to_s
      ids.join "."
    end
    
    # @return [Boolean] True if this pre-release is empty.
    def empty?
      ids.empty?
    end    
    
    
    
    # Indicates whether this prerelease is greater, less than, or equal to another prerelease.
    # 
    # The SemVer 2.0.0-rc2 spec uses this example for determining pre-release precedence:
    #     1.0.0-alpha < 1.0.0-alpha.1 < 1.0.0-beta.2 < 1.0.0-beta.11 < 1.0.0-rc.1 < 1.0.0.
    # Pre-release precedence is calculated using the following rules:
    # - A SemVer with no prerelease data is 'greater' than a SemVer with any prerelease data.
    # - If both prereleases are empty, they are equal.
    # - A pre-release with fewer ids is less than a pre-release with more ids. (1.0.0-alpha < 1.0.0-alpha.1)
    # - If a pre-release id consists of only numbers, it is compared numerically.
    # - If a pre-release id contains one or more letters, it is compared alphabetically.
    # 
    # @param [PreRelease] other A prerelease to which this prerelease will be compared.
    # @return [Fixnum] Indicates whether this prerelease is greater, less than, or equal to another prerelease.
    def <=>(other)
      
      # A SemVer with no prerelease data is 'greater' than a SemVer with any prerelease data.
      # If both prereleases are empty, they are equal.
      return  1 if  empty? && !other.empty?
      return -1 if !empty? &&  other.empty?
      return  0 if  empty? &&  other.empty?
      
      [ids.size, other.ids.size].max.times do |n|
        id = ids[n]
        oid = other.ids[n]
        
        # A pre-release with fewer ids is less than a pre-release with more ids. (1.0.0-alpha < 1.0.0-alpha.1)
        return 1 if oid.nil?
        return -1 if id.nil?
        
        # If a pre-release id consists of only numbers, it is compared numerically.
        if id =~ ONLY_DIGITS && oid =~ ONLY_DIGITS
          id = id.to_i
          oid = oid.to_i
        end
        
        # If a pre-release id contains one or more letters, it is compared alphabetically.
        comparison = (id <=> oid)
        return comparison unless comparison == 0
      end
      
      0
    end
    
    
    
    
  end
  
end