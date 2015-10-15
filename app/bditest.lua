require "bdi_agent"
require "blua"
a = BDI_Agent:new({})
a.knowledge.target = Vector:new({x = 373, z = -450, y = 63})
engine = Blua:new({ agent = a })
engine:step_once()