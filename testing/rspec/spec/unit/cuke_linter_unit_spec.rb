require_relative '../../../../environments/rspec_env'


RSpec.describe 'the gem' do

  let(:root_dir) { "#{__dir__}/../../../.." }
  let(:gemspec) { eval(File.read "#{root_dir}/cuke_linter.gemspec") }
  let(:lib_folder) { "#{root_dir}/lib" }
  let(:exe_folder) { "#{root_dir}/exe" }
  let(:features_folder) { "#{root_dir}/testing/cucumber/features" }

  it 'has an executable' do
    expect(gemspec.executables).to eq(['cuke_linter'])
  end

  it 'validates cleanly' do
    mock_ui = Gem::MockGemUi.new
    Gem::DefaultUserInteraction.use_ui(mock_ui) { gemspec.validate }

    expect(mock_ui.error).to_not match(/warn/i)
  end

  describe 'included files' do

    it 'does not include files that are not source controlled' do
      bad_file_1 = File.absolute_path("#{lib_folder}/foo.txt")
      bad_file_2 = File.absolute_path("#{exe_folder}/foo.txt")
      bad_file_3 = File.absolute_path("#{features_folder}/foo.txt")

      begin
        FileUtils.touch(bad_file_1)
        FileUtils.touch(bad_file_2)
        FileUtils.touch(bad_file_3)

        gem_files = gemspec.files.map { |file| File.absolute_path(file) }

        expect(gem_files).to_not include(bad_file_1, bad_file_2, bad_file_3)
      ensure
        FileUtils.rm([bad_file_1, bad_file_2, bad_file_3])
      end
    end

    it 'includes all of the library files' do
      lib_files = Dir.chdir(root_dir) do
        Dir.glob('lib/**/*').reject { |file| File.directory?(file) }
      end

      expect(gemspec.files).to include(*lib_files)
    end

    it 'includes all of the executable files' do
      exe_files = Dir.chdir(root_dir) do
        Dir.glob('exe/**/*').reject { |file| File.directory?(file) }
      end

      expect(gemspec.files).to include(*exe_files)
    end

    it 'includes all of the documentation files' do
      feature_files = Dir.chdir(root_dir) do
        Dir.glob('testing/cucumber/features/**/*').reject { |file| File.directory?(file) }
      end

      expect(gemspec.files).to include(*feature_files)
    end

    it 'includes the README file' do
      readme_file = 'README.md'

      expect(gemspec.files).to include(readme_file)
    end

    it 'includes the license file' do
      license_file = 'LICENSE.txt'

      expect(gemspec.files).to include(license_file)
    end

    it 'includes the CHANGELOG file' do
      changelog_file = 'CHANGELOG.md'

      expect(gemspec.files).to include(changelog_file)
    end

    it 'includes the gemspec file' do
      gemspec_file = 'cuke_linter.gemspec'

      expect(gemspec.files).to include(gemspec_file)
    end

  end

end


RSpec.describe CukeLinter do

  it "has a version number" do
    expect(CukeLinter::VERSION).not_to be nil
  end

  it "has a default keyword for 'Given'" do
    expect(CukeLinter::DEFAULT_GIVEN_KEYWORD).to eq('Given')
  end

  it "has a default keyword for 'When'" do
    expect(CukeLinter::DEFAULT_WHEN_KEYWORD).to eq('When')
  end

  it "has a default keyword for 'Then'" do
    expect(CukeLinter::DEFAULT_THEN_KEYWORD).to eq('Then')
  end

  it 'can lint' do
    expect(CukeLinter).to respond_to(:lint)
  end

  it 'lints the (optionally) given model trees and (optionally) file paths using the (optionally) provided set of linters and formats the output with the (optionally) provided formatters' do
    expect(CukeLinter.method(:lint).arity).to eq(-1)
    expect(CukeLinter.method(:lint).parameters).to match_array([[:key, :model_trees],
                                                                [:key, :linters],
                                                                [:key, :formatters],
                                                                [:key, :file_paths]])
  end

  it 'can register a linter' do
    expect(CukeLinter).to respond_to(:register_linter)
  end

  it 'can unregister a linter' do
    expect(CukeLinter).to respond_to(:unregister_linter)
  end

  it 'registers a linter by name' do
    expect(CukeLinter.method(:register_linter).arity).to eq(1)
    expect(CukeLinter.method(:register_linter).parameters).to match_array([[:keyreq, :linter],
                                                                           [:keyreq, :name]])
  end

  it 'unregisters a linter by name' do
    expect(CukeLinter.method(:unregister_linter).arity).to eq(1)
    expect(CukeLinter.method(:unregister_linter).parameters).to match_array([[:req, :name]])
  end

  it 'knows its currently registered linters' do
    expect(CukeLinter).to respond_to(:registered_linters)
  end

  it 'correctly registers, unregisters, and tracks linters', :linter_registration do
    CukeLinter.clear_registered_linters
    CukeLinter.register_linter(name: 'foo', linter: :linter_1)
    CukeLinter.register_linter(name: 'bar', linter: :linter_2)
    CukeLinter.register_linter(name: 'baz', linter: :linter_3)

    CukeLinter.unregister_linter('bar')

    expect(CukeLinter.registered_linters).to eq({ 'foo' => :linter_1,
                                                  'baz' => :linter_3, })
  end

  it 'can clear all of its currently registered linters', :linter_registration do
    expect(CukeLinter).to respond_to(:clear_registered_linters)

    CukeLinter.register_linter(name: 'some_linter', linter: :the_linter)
    CukeLinter.clear_registered_linters

    expect(CukeLinter.registered_linters).to eq({})
  end

  it 'can reset to its default set of linters' do
    expect(CukeLinter).to respond_to(:reset_linters)
  end

  describe 'configuration' do

    it 'can load a configuration' do
      expect(CukeLinter).to respond_to(:load_configuration)
    end

    it 'is configured optionally via a file or a directly provided configuration' do
      expect(CukeLinter.method(:load_configuration).arity).to eq(-1)
      expect(CukeLinter.method(:load_configuration).parameters).to match_array([[:key, :config_file_path],
                                                                                [:key, :config]])
    end

  end

end
