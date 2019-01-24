require 'yaml'
require 'semver/semvermissingerror'
require 'pre_release'

module XSemVer
  # sometimes a library that you are using has already put the class
  # 'SemVer' in global scope. Too Bad®. Use this symbol instead.
  class SemVer
    FILE_NAME = '.semver'.freeze
    TAG_FORMAT = 'v%M.%m.%p%s%d'.freeze

    def self.file_name
      FILE_NAME
    end

    def self.find(dir = nil)
      v = SemVer.new
      f = SemVer.find_file dir
      v.load f
      v
    end

    def self.find_file(dir = nil)
      dir ||= Dir.pwd
      raise "#{dir} is not a directory" unless File.directory? dir

      path = File.join dir, file_name

      Dir.chdir dir do
        until File.exist? path
          raise SemVerMissingError, "#{dir} is not semantic versioned", caller if File.dirname(path) =~ /(\w:\/|\/)$/i

          path = File.join File.dirname(path), ".."
          path = File.expand_path File.join(path, file_name)
          puts "semver: looking at #{path}"
        end
        return path
      end
    end

    attr_accessor :major, :minor, :patch, :special, :metadata

    def initialize(major = 0, minor = 0, patch = 0, special = '', metadata = '')
      major.is_a?(Integer) || raise("invalid major: #{major}")
      minor.is_a?(Integer) || raise("invalid minor: #{minor}")
      patch.is_a?(Integer) || raise("invalid patch: #{patch}")

      special =~ /[A-Za-z][0-9A-Za-z\.]+/ || raise("invalid special: #{special}") unless special.empty?
      metadata =~ /\A[A-Za-z0-9][0-9A-Za-z\.-]*\z/ || raise("invalid metadata: #{metadata}") unless metadata.empty?

      @major    = major
      @minor    = minor
      @patch    = patch
      @special  = special
      @metadata = metadata
    end

    def load(file)
      @file = file
      hash = YAML.load_file(file) || {}
      (@major = hash[:major]) || raise("invalid semver file: #{file}")
      (@minor = hash[:minor]) || raise("invalid semver file: #{file}")
      (@patch = hash[:patch]) || raise("invalid semver file: #{file}")
      (@special = hash[:special]) || raise("invalid semver file: #{file}")
      @metadata = hash[:metadata] || ""
    end

    def save(file = nil)
      file ||= @file

      hash = {
        major: @major,
        minor: @minor,
        patch: @patch,
        special: @special,
        metadata: @metadata
      }

      yaml = YAML.dump hash
      File.open(file, 'w') { |io| io.write yaml }
    end

    def format(fmt)
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

    # Compare version numbers according to SemVer 2.0.0-rc2
    def <=>(other)
      [:major, :minor, :patch].each do |method|
        comparison = (send(method) <=> other.send(method))
        return comparison unless comparison.zero?
      end
      PreRelease.new(prerelease) <=> PreRelease.new(other.prerelease)
    end

    include Comparable

    # Parses a semver from a string and format.
    def self.parse(version_string, format = nil, allow_missing = true)
      format ||= TAG_FORMAT
      regex_str = Regexp.escape format

      # Convert all the format characters to named capture groups
      regex_str = regex_str
        .gsub(/^v/, 'v?')
        .gsub('%M', '(?<major>\d+)')
        .gsub('%m', '(?<minor>\d+)')
        .gsub('%p', '(?<patch>\d+)')
        .gsub('%s', '(?:-(?<special>[A-Za-z][0-9A-Za-z\.]+))?')
        .gsub('%d', '(?:\\\+(?<metadata>[0-9A-Za-z][0-9A-Za-z\.]*))?')

      regex = Regexp.new(regex_str)
      match = regex.match version_string
      return nil unless match

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
      return nil if !allow_missing && [major, minor, patch].any?(&:nil?)

      # Otherwise, allow them to default to zero
      major ||= 0
      minor ||= 0
      patch ||= 0

      SemVer.new major, minor, patch, special, metadata
    end

    # Parses a rubygems string, such as 'v2.0.5.rc.3' or '2.0.5.rc.3' to 'v2.0.5-rc.3'
    def self.parse_rubygems(version_string)
      if /v?(?<major>\d+)
           (\.(?<minor>\d+)
            (\.(?<patch>\d+)
             (\.(?<pre>[A-Za-z]+\.[0-9A-Za-z]+)
           )?)?)?
          /x =~ version_string

        major = major.to_i
        minor = minor.to_i if minor
        minor ||= 0
        patch = patch.to_i if patch
        patch ||= 0
        pre ||= ''
        SemVer.new major, minor, patch, pre, ''
      else
        SemVer.new
      end
    end

    # SemVer specification 2.0.0-rc2 states that anything after the '-' character is prerelease data.
    # To be consistent with the specification verbage, #prerelease returns the same value as #special.
    # TODO: Deprecate #special in favor of #prerelease?
    def prerelease
      special
    end

    # SemVer specification 2.0.0-rc2 states that anything after the '-' character is prerelease data.
    # To be consistent with the specification verbage, #prerelease= sets the same value as #special.
    # TODO: Deprecate #special= in favor of #prerelease=?
    def prerelease=(pre)
      self.special = pre
    end

    # Return true if the SemVer has a non-empty #prerelease value. Otherwise, false.
    def prerelease?
      !(special.nil? || special.empty?)
    end

    # Return true if the SemVer has a non-empty #metadata value. Otherwise, false.
    def metadata?
      !(metadata.nil? || metadata.empty?)
    end
  end
end
