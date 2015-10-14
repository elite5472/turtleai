require "bdi_agent"
a = BDI_Agent:new({})
engine = Blua:new({ agent = a })
engine:step_through()