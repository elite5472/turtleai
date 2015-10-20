require "bdi_agent"
require "blua"
a = BDI_Agent:new({})
engine = Blua:new({ agent = a })
engine:step_through()