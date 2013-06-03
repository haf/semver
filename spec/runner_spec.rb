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
        end
      
        it "does not overwrite the existing file" do
          expect {
            described_class.new command
          }.to_not change{ File.mtime(TEST_FILE) }
        end
      
        it "displays an error message" do
          STDOUT.should_receive(:puts).with "#{TEST_FILE} already exists"
          described_class.new command
        end
      
      end
    
    end
    
  end




  %w( inc increment ).each do |command|
    
    describe command do
    
      describe "major" do
      
        it "increments the major version" do
          pending
        end
      
        it "sets the minor version to 0" do
          pending
        end
      
        it "sets the patch vesion to 0" do
          pending
        end
      
      end
    
      describe "minor" do
      
        it "does not change the major version" do
          pending
        end
      
        it "increments the minor version" do
          pending
        end
      
        it "sets the patch version to 0" do
          pending
        end
      
      end
    
      describe "patch" do
      
        it "does not change the major version" do
          pending
        end
      
        it "does not change the minor version" do
          pending
        end
      
        it "increments the patch version" do
          pending
        end
      
      end
    
      describe "without a valid subcommand" do
      
        it "raises an exception" do
          pending
        end
      
      end
    
    end
  
  end
  
  
  
  
  %w( spe special ).each do |command|
    
    describe command do
    
      describe "when a string argument is provided" do
      
        it "sets the pre-release of the SemVer" do
          pending
        end
      
      end
    
      describe "without a string argument" do
      
        it "raises an exception" do
          pending
        end
      
      end
    
    end
  
  end
  
  
  
  
  describe "format" do
    
    describe "when a format argument is provided" do
      
      it "returns the SemVer formatted according to the format string" do
        pending
      end
      
    end
    
    describe "without a format argument" do
      
      it "raises an exception" do
        pending
      end
      
    end
    
  end
  
  
  
  
  describe "tag" do
    
    it "outputs the SemVer with default formatting" do
      pending
    end
    
  end
  
  
  
  
end