require 'yaml'
require 'semver/semvermissingerror'

module XSemVer
# sometimes a library that you are using has already put the class
# 'SemVer' in global scope. Too Bad®. Use this symbol instead.
  class SemVer
    FILE_NAME = '.semver'
    TAG_FORMAT = 'v%M.%m.%p%s%d'

    def SemVer.find dir=nil
      v = SemVer.new
      f = SemVer.find_file dir
      v.load f
      v
    end

    def SemVer.find_file dir=nil
      dir ||= Dir.pwd
      raise "#{dir} is not a directory" unless File.directory? dir
      path = File.join dir, FILE_NAME

      Dir.chdir dir do
        while !File.exists? path do
          raise SemVerMissingError, "#{dir} is not semantic versioned", caller if File.dirname(path).match(/(\w:\/|\/)$/i)
          path = File.join File.dirname(path), ".."
          path = File.expand_path File.join(path, FILE_NAME)
          puts "semver: looking at #{path}"
        end
        return path
      end

    end

    attr_accessor :major, :minor, :patch, :special, :metadata

    def initialize major=0, minor=0, patch=0, special='', metadata=''
      major.kind_of? Integer or raise "invalid major: #{major}"
      minor.kind_of? Integer or raise "invalid minor: #{minor}"
      patch.kind_of? Integer or raise "invalid patch: #{patch}"

      unless special.empty?
        special =~ /[A-Za-z][0-9A-Za-z\.]+/ or raise "invalid special: #{special}"
      end

      unless metadata.empty?
        metadata =~ /\A[A-Za-z0-9][0-9A-Za-z\.-]*\z/ or raise "invalid metadata: #{metadata}"
      end

      @major, @minor, @patch, @special, @metadata = major, minor, patch, special, metadata
    end

    def load file
      @file = file
      hash = YAML.load_file(file) || {}
      @major = hash[:major] or raise "invalid semver file: #{file}"
      @minor = hash[:minor] or raise "invalid semver file: #{file}"
      @patch = hash[:patch] or raise "invalid semver file: #{file}"
      @special = hash[:special]  or raise "invalid semver file: #{file}"
    end

    def save file=nil
      file ||= @file

      hash = {
        :major => @major,
        :minor => @minor,
        :patch => @patch,
        :special => @special
      }

      yaml = YAML.dump hash
      open(file, 'w') { |io| io.write yaml }
    end

    def format fmt
      fmt = fmt.gsub '%M', @major.to_s
      fmt = fmt.gsub '%m', @minor.to_s
      fmt = fmt.gsub '%p', @patch.to_s
      fmt = fmt.gsub('%s', prerelease? ? "-#{@special}" : '')
      fmt = fmt.gsub('%d', metadata? ? "+#{@metadata}" : '')
      fmt
    end

    def to_s
      format TAG_FORMAT
    end

    def <=> other
      [:major, :minor, :patch].each do |method|
        comparison = (send(method) <=> other.send(method))
        return comparison unless comparison == 0
      end

      # Compare prerelease identifiers according to SemVer 2.0.0-rc2
      # TODO: extract prelease into its own class that implements Comparable
      return  1 if !prerelease? &&  other.prerelease?
      return -1 if  prerelease? && !other.prerelease?
      return  0 if !prerelease? && !other.prerelease?
      pre_ids = prerelease.split(".")
      other_pre_ids = other.prerelease.split(".")
      only_digits = /\A\d+\z/
      [pre_ids.size, other_pre_ids.size].max.times do |n|
        pid = pre_ids[n]
        opid = other_pre_ids[n]
        return 1 if opid.nil?
        return -1 if pid.nil?
        if pid =~ only_digits && opid =~ only_digits
          pid = pid.to_i
          opid = opid.to_i
        end
        comparison = (pid <=> opid)
        return comparison unless comparison == 0
      end
      
      0
    end

    include Comparable

    # Parses a semver from a string and format.
    def self.parse(version_string, format = nil, allow_missing = true)
      format ||= TAG_FORMAT
      regex_str = Regexp.escape format

      # Convert all the format characters to named capture groups
      regex_str = regex_str.
        gsub('%M', '(?<major>\d+)').
        gsub('%m', '(?<minor>\d+)').
        gsub('%p', '(?<patch>\d+)').
        gsub('%s', '(?:-(?<special>[A-Za-z][0-9A-Za-z\.]+))?').
        gsub('%d', '(?:\x2B(?<metadata>[0-9A-Za-z][0-9A-Za-z\.]*))?')

      regex = Regexp.new(regex_str)
      match = regex.match version_string

      if match
          major = minor = patch = nil
          special = metadata = ''

          # Extract out the version parts
          major = match[:major].to_i if match.names.include? 'major'
          minor = match[:minor].to_i if match.names.include? 'minor'
          patch = match[:patch].to_i if match.names.include? 'patch'
          special = match[:special] || '' if match.names.include? 'special'
          metadata = match[:metadata] || '' if match.names.include? 'metadata'

          # Failed parse if major, minor, or patch wasn't found
          # and allow_missing is false
          return nil if !allow_missing and [major, minor, patch].any? {|x| x.nil? }

          # Otherwise, allow them to default to zero
          major ||= 0
          minor ||= 0
          patch ||= 0

          SemVer.new major, minor, patch, special, metadata
      end
    end
    
    # SemVer specification 2.0.0-rc2 states that anything after the '-' character is prerelease data.
    # To be consistent with the specification verbage, #prerelease returns the same value as #special.
    def prerelease
      special
    end
    
    # SemVer specification 2.0.0-rc2 states that anything after the '-' character is prerelease data.
    # To be consistent with the specification verbage, #prerelease= sets the same value as #special.
    def prerelease=(pre)
      self.special = pre
    end
    
    # Return true if the SemVer has a non-empty #prerelease value. Otherwise, false.
    def prerelease?
      !special.nil? && special.length > 0
    end
    
    def metadata?
      !metadata.nil? && metadata.length > 0
    end    
    
  end
end
