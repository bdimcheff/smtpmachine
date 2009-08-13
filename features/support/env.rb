$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'smtpmachine'

require 'micronaut/expectations'

World(Micronaut::Matchers)
