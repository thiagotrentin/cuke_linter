require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::TestWithNoNameLinter do

  it_should_behave_like 'a linter at the integration level'

end
