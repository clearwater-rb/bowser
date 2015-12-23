require "bowser/version"
require "opal"

module Bowser
end

Opal.append_path(File.expand_path(File.join("..", "..", "opal"), __FILE__).untaint)
