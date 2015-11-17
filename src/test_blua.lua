require "blua"

Agent = Class:new({
	
	knowledge = {
		a =  false;
		b =  false;
		c =  false;
		bval = 0;
	};
	
	desires = {
		da = {
			conditions = "a";
			priority = 10;
		};
		
		db = {
			conditions = "b";
			priority = function(self, agent)
				return agent.knowledge.bval * 2
			end;
		};
		
		dba = {
			conditions = "!b&!a&!c";
			priority = 100;
		}
	};
	
	plans = {
		pa = {
		};
	};
	
	update_counter = 0;
	update_knowledge =  function(self)
		self.update_counter = self.update_counter + 1;
	end;
});

blua = Blua:new()

lu = require("luaunit")

TestBlua = {
	test_parse_condition_string = function()
		result = blua:parse_condition_string("!hello&world&look&!and&listen")
		assert(type(result) == "table")
		assert(result["hello"] == false)
		assert(result["world"] == true)
		assert(result["look"] == true)
		assert(result["and"] == false)
		assert(result["listen"] == true)
	end;
	
	test_evaluate_conditions = function()
		assert(blua:evaluate_conditions("!hello", "hello") == false)
		assert(blua:evaluate_conditions("hello", "hello") == true)
		assert(blua:evaluate_conditions("hello", "hello&cookies") == true)
		assert(blua:evaluate_conditions("!hello", "cookies") == true)
		assert(blua:evaluate_conditions("hello&!world", "hello&world") == false)
	end;
	
	test_check_desire = function()
		blua.agent = Agent:new()
		local da = blua:check_desire("da")
		local db = blua:check_desire("db")
		local dba = blua:check_desire("dba")
		assert(da.name == "da")
		assert(da.conditions == "a")
		assert(da.priority == 10)
		assert(db.name == "db")
		assert(db.conditions == "b")
		assert(db.priority == 0)
		assert(dba.name == "dba")
		assert(dba.conditions == "!b&!a&!c")
		assert(dba.priority == 100)
	end;
	
	test_check_desires = function()
		blua.agent = Agent:new()
		assert(blua:check_desires().name == "da")
		blua.agent.knowledge.bval = 10
		assert(blua:check_desires().name == "db")
		blua.agent.knowledge.c = true
		assert(blua:check_desires().name == "dba")
	end
}

lu.Run("TestBlua")