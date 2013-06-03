require 'semver'
require 'runner'

# TODO: STDOUT.should_receive(:puts) is a shitty way to test expected output.
# See: http://ngauthier.com/2010/12/everything-that-is-wrong-with-mocking.html
# The solution is for XSemVer::Runner to accept an IO object to which
# it can output and which we can test against.




# Stub SemVer::FILE_NAME for testing.
TEST_FILE = 'semver_test_file'
module XSemVer
  class SemVer
    FILE_NAME = TEST_FILE
  end
end




describe XSemVer::Runner do
  
  after :each do
    FileUtils.rm_rf TEST_FILE
  end
  
  
  
  
  #######################
  # SEMVER INIT(IALIZE) #
  #######################
  
  %w( init initialize ).each do |command|
    
    describe command do
    
      describe "when no .semver file exists" do
      
        it "creates a new .semver file" do
          expect {
            described_class.new command
          }.to change{ File.exist?(TEST_FILE) }.from(false).to(true)
          v = SemVer.find
          v.major.should eq(0)
          v.minor.should eq(0)
          v.patch.should eq(0)
        end
      
      end
    
      describe "when a .semver file already exists" do
        
        before :each do
          FileUtils.touch TEST_FILE
          STDOUT.should_receive(:puts).with "#{TEST_FILE} already exists"
        end
      
        it "does not overwrite the existing file" do
          expect {
            described_class.new command
          }.to_not change{ File.mtime(TEST_FILE) }
        end
      
      end
    
    end
    
  end




  ######################
  # SEMVER INC(REMENT) #
  ######################
  
  %w( inc increment ).each do |command|
    
    describe command do
      
      before :each do
        SemVer.new(5,6,7,'foo').save TEST_FILE
      end
    
      describe "major" do
      
        it "increments the major version" do
          expect {
            described_class.new command, 'major'
          }.to change{ SemVer.find.major }.by(1)
        end
      
        it "sets the minor version to 0" do
          expect {
            described_class.new command, 'major'
          }.to change{ SemVer.find.minor }.to(0)
        end
      
        it "sets the patch vesion to 0" do
          expect {
            described_class.new command, 'major'
          }.to change{ SemVer.find.patch }.to(0)
        end
        
        it "sets the prerelease to an empty string" do
          expect {
            described_class.new command, 'major'
          }.to change{ SemVer.find.prerelease }.to('')
        end
      
      end
    
      describe "minor" do
      
        it "does not change the major version" do
          expect {
            described_class.new command, 'minor'
          }.to_not change{ SemVer.find.major }
        end
      
        it "increments the minor version" do
          expect {
            described_class.new command, 'minor'
          }.to change{ SemVer.find.minor }.by(1)
        end
      
        it "sets the patch version to 0" do
          expect {
            described_class.new command, 'minor'
          }.to change{ SemVer.find.patch }.to(0)
        end
      
        it "sets the prerelease to an empty string" do
          expect {
            described_class.new command, 'minor'
          }.to change{ SemVer.find.prerelease }.to('')
        end
      
      end
    
      describe "patch" do
      
        it "does not change the major version" do
          expect {
            described_class.new command, 'patch'
          }.to_not change{ SemVer.find.major }
        end
      
        it "does not change the minor version" do
          expect {
            described_class.new command, 'patch'
          }.to_not change{ SemVer.find.minor }
        end
      
        it "increments the patch version" do
          expect {
            described_class.new command, 'patch'
          }.to change{ SemVer.find.patch }.by(1)
        end
      
        it "sets the prerelease to an empty string" do
          expect {
            described_class.new command, 'patch'
          }.to change{ SemVer.find.prerelease }.to('')
        end
      
      end
    
      describe "without a valid subcommand" do
        
        before :each do
          @invalid_command = 'invalid'
        end
      
        it "raises an exception" do
          expect {
            described_class.new command, @invalid_command
          }.to raise_error(
            XSemVer::Runner::CommandError,
            "#{@invalid_command} is invalid: major | minor | patch"
          )
        end
        
        it "does not modify the .semver file" do
          expect {
            begin
              described_class.new command, @invalid_command
            rescue
            end
          }.to_not change{ File.mtime(TEST_FILE) }
        end
      
      end
      
      describe "without a subcommand" do
      
        it "raises an exception" do
          expect {
            described_class.new command
          }.to raise_error(
            XSemVer::Runner::CommandError,
            "required: major | minor | patch"
          )
        end
        
        it "does not modify the .semver file" do
          expect {
            begin
              described_class.new command
            rescue
            end
          }.to_not change{ File.mtime(TEST_FILE) }
        end
      
      end
    
    end
  
  end
  
  
  

  ####################
  # SEMVER SPE(CIAL) #
  ####################
    
  %w( spe special ).each do |command|
    
    describe command do
      
      before :each do
        SemVer.new.save TEST_FILE
      end
    
      describe "when a string argument is provided" do
      
        it "sets the pre-release of the SemVer" do
          prerelease = 'alpha'
          expect {
            described_class.new command, prerelease
          }.to change{ SemVer.find.prerelease }.to(prerelease)
        end
      
      end
    
      describe "without a string argument" do
      
        it "raises an exception" do
          expect {
            described_class.new command
          }.to raise_error(
            XSemVer::Runner::CommandError,
            "required: an arbitrary string (beta, alfa, romeo, etc)"
          )
        end
        
        it "does not modify the .semver file" do
          expect {
            begin
              described_class.new command
            rescue
            end
          }.to_not change{ File.mtime(TEST_FILE) }
        end

      end
    
    end
  
  end
  
  
  
  

  #################
  # SEMVER FORMAT #
  #################

  describe "format" do
    
    describe "when a format argument is provided" do
      
      it "returns the SemVer formatted according to the format string" do
        SemVer.new(5,6,7,'foo','bar').save TEST_FILE
        STDOUT.should_receive(:puts).with "5|6|7|-foo|+bar"
        described_class.new 'format', '%M|%m|%p|%s|%d'
      end
      
    end
    
    describe "without a format argument" do
      
      it "raises an exception" do
        SemVer.new.save TEST_FILE
        expect {
          described_class.new 'format'
        }.to raise_error(
          XSemVer::Runner::CommandError,
          "required: format string"
        )
      end
      
    end
    
  end
  
  
  
  
  ##############
  # SEMVER TAG #
  ##############

  describe "tag" do
    
    it "outputs the SemVer with default formatting" do
      SemVer.new(5,6,7,'foo','bar').save TEST_FILE
      STDOUT.should_receive(:puts).with "v5.6.7-foo+bar"
      described_class.new 'tag'
    end
    
  end
  
  describe "with no command" do
    
    it "outputs the SemVer with default formatting" do
      SemVer.new(5,6,7,'foo','bar').save TEST_FILE
      STDOUT.should_receive(:puts).with "v5.6.7-foo+bar"
      described_class.new
    end
    
  end
  
  
  
  
  ###############
  # SEMVER HELP #
  ###############

  describe "help" do
    
    it "outputs instructions for using the semvar commands" do
      stubbed_help_text = 'stubbed help text'
      described_class.stub(:help_text).and_return(stubbed_help_text)
      STDOUT.should_receive(:puts).with stubbed_help_text
      described_class.new 'help'
    end
    
  end
  
  
  
  
end