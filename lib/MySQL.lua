local GetResourceState = GetResourceState
local queryStore = {}
local Await = Citizen.Await
local GetCurrentResourceName = GetCurrentResourceName()
local GetResourceState = GetResourceState

local function await(fn, query, parameters)
	local p = promise.new()
	fn(nil, query, parameters, function(result, error)
		if error then
			return p:reject(error)
		end

		p:resolve(result)
	end, GetCurrentResourceName, true)
	return Await(p)
end

local MySQL = {} -- MySQL wrapper table

local function parseInsertQuery(query, parameters)
	local result = {
		collection = nil,
		operation = "insert",
		data = {}
	}

	if query:match("^INSERT INTO") then
		result.collection = query:match("^INSERT INTO (%w+)")

		local fieldsPart = query:match("%((.-)%) VALUES")
		local valuesPart = query:match("VALUES %((.-)%)")

		if fieldsPart and valuesPart then
			local fields = {}
			local values = {}
			local positionalIndex = 1

			for field in fieldsPart:gmatch("[^,%s]+") do
				table.insert(fields, field)
			end

			for value in valuesPart:gmatch("([^,%s]+)") do
				local paramName = value:match("^[@:](.+)$")
				if paramName and parameters and type(parameters) == "table" then
					table.insert(values, parameters["@" .. paramName] or parameters[paramName])
				elseif value == "?" and parameters and type(parameters) == "table" then
					table.insert(values, parameters[positionalIndex])
					positionalIndex = positionalIndex + 1
				else
					table.insert(values, value:gsub("'", ""))
				end
			end

			for i = 1, #fields do
				result.data[fields[i]] = values[i]
			end
		end
	end
	local res = exports["mongoDB"]:insertOne(result.collection, result.data)
	return res
end

local function parse_select_query(query, parameters)
	local result = {
		select = {},
		from = {},
		where = {}
	}

	query = query:gsub("%s+", " ")

	local select_clause = query:match("SELECT (.-) FROM")
	if select_clause then
		for column in select_clause:gmatch("[^, ]+") do
			table.insert(result.select, column)
		end
	end

	local from_clause = query:match("FROM (.-) WHERE")
	if from_clause then
		for table_name in from_clause:gmatch("[^, ]+") do
			table.insert(result.from, table_name)
		end
	else
		from_clause = query:match("FROM (.+)")
		if from_clause then
			for table_name in from_clause:gmatch("[^, ]+") do
				table.insert(result.from, table_name)
			end
		end
	end

	local where_clause = query:match("WHERE (.+)")
	if where_clause then
		local index = 1
		for condition in where_clause:gmatch("[^%s]+%s*=%s*[^%s]+") do
			local key, placeholder = condition:match("([^=]+)%s*=%s*(.+)")
			key = key and key:match("^%s*(.-)%s*$")

			if key and placeholder then
				placeholder = placeholder:match("^%s*(.-)%s*$")

				local param_name = placeholder:match("^[@:](.+)$") -- Match @ or :
				if param_name and parameters then
					result.where[key] = parameters["@" .. param_name] or parameters[param_name]
				elseif placeholder == "?" and parameters then
					result.where[key] = parameters[index]
					index = index + 1
				else
					result.where[key] = placeholder:gsub("'", "")
				end
			end
		end
	end

	print(json.encode(result, { indent = true }))
	--[[ local res
	if result.select[1] == '*' then
		res = exports["mongoDB"]:findMany(result.from[1], result.where)
	else
		res = exports["mongoDB"]:findAndReturnSpecificFields(result.from[1], result.where, result.select)
	end
	return res ]]
end

local function parse_update_query(query, parameters)
	local result = {
		table = nil,
		set = {},
		where = {}
	}

	query = query:gsub("%s+", " ")

	local table_clause = query:match("UPDATE (%S+)")
	if table_clause then
		result.table = table_clause
	end

	local set_clause = query:match("SET (.-) WHERE")
	if set_clause then
		for assignment in set_clause:gmatch("([^,]+)") do
			local column, value = assignment:match("([^=]+)=([^=]+)")
			column = column and column:match("^%s*(.-)%s*$")
			value = value and value:match("^%s*(.-)%s*$")

			if column and value then
				local param_name = value:match("^[@:](.+)$")
				if param_name and parameters then
					result.set[column] = parameters["@" .. param_name] or parameters[param_name]
				elseif value == "?" and parameters then
					result.set[column] = parameters[1]
					table.remove(parameters, 1)
				else
					result.set[column] = value:gsub("'", "")
				end
			end
		end
	end

	local where_clause = query:match("WHERE (.+)")
	if where_clause then
		local index = 1
		for condition in where_clause:gmatch("[^%s]+%s*=%s*[^%s]+") do
			local key, placeholder = condition:match("([^=]+)%s*=%s*(.+)")
			key = key and key:match("^%s*(.-)%s*$")

			if key and placeholder then
				placeholder = placeholder:match("^%s*(.-)%s*$")

				local param_name = placeholder:match("^[@:](.+)$")
				if param_name and parameters then
					result.where[key] = parameters["@" .. param_name] or parameters[param_name]
				elseif placeholder == "?" and parameters then
					result.where[key] = parameters[index]
					index = index + 1
				else
					result.where[key] = placeholder:gsub("'", "")
				end
			end
		end
	end

	print(json.encode(result, { indent = true }))
	--[[ local res = exports["mongoDB"]:updateOne(result.table, result.where, result.set)
	return res.matchedCount ]]
end

local function parse_delete_query(query, parameters)
	local result = {
		table = nil,
		where = {}
	}
	query = query:gsub("%s+", " ")

	local table_clause = query:match("DELETE FROM (%S+)")
	if table_clause then
		result.table = table_clause
	end

	local where_clause = query:match("WHERE (.+)")
	if where_clause then
		local index = 1
		for condition in where_clause:gmatch("[^%s]+%s*=%s*[^%s]+") do
			local key, placeholder = condition:match("([^=]+)%s*=%s*(.+)")
			key = key and key:match("^%s*(.-)%s*$")

			if key and placeholder then
				placeholder = placeholder:match("^%s*(.-)%s*$")

				local param_name = placeholder:match("^[@:](.+)$") -- Match @ or :
				if param_name and parameters then
					result.where[key] = parameters["@" .. param_name] or parameters[param_name]
				elseif placeholder == "?" and parameters then
					result.where[key] = parameters[index]
					index = index + 1
				else
					result.where[key] = placeholder:gsub("'", "")
				end
			end
		end
	end

	print(json.encode(result, { indent = true }))
	--[[ local res = exports["mongoDB"]:deleteMany(result.table, result.where)
	return res.deletedCount > 0 and true or false ]]
end

local mysql_method_mt = {
	__call = function(self, query, parameters, cb)
		if self.method == 'insert' then
			local result = parseInsertQuery(query, parameters)
			cb(result)
		elseif self.method == 'update' then
			local result = parse_update_query(query, parameters)
			cb(result)
		else
			if query:match("^SELECT") then
				local queryData = parse_select_query(query, parameters)
				cb(queryData)
			elseif query:match("^UPDATE") then
				local result = parse_update_query(query, parameters)
				cb(result)
			elseif query:match("^INSERT") then
				local result = parseInsertQuery(query, parameters)
				cb(result)
			elseif query:match("^DELETE") then
				local result = parse_delete_query(query, parameters)
				cb(result)
			end
		end
	end
}

for _, method in pairs({
	'scalar', 'single', 'query', 'insert', 'update', 'prepare', 'transaction', 'rawExecute',
}) do
	MySQL[method] = setmetatable({
		method = method,
		await = function(query, parameters)
			if method == 'insert' then
				local result = parseInsertQuery(query, parameters)
				return result
			elseif method == 'update' then
				local result = parse_update_query(query, parameters)
				return result
			else
				if query:match("^SELECT") then
					local queryData = parse_select_query(query, parameters)
					return queryData
				elseif query:match("^UPDATE") then
					local result = parse_update_query(query, parameters)
					return result
				elseif query:match("^INSERT") then
					return await(parseInsertQuery, query, parameters)
				elseif query:match("^DELETE") then
					local result = parse_delete_query(query, parameters)
					return result
				end
			end
		end
	}, mysql_method_mt)
end

local alias = {
	fetchAll = 'query',
	fetchScalar = 'scalar',
	fetchSingle = 'single',
	insert = 'insert',
	execute = 'update',
	transaction = 'transaction',
	prepare = 'prepare'
}

local alias_mt = {
	__index = function(self, key)
		if alias[key] then
			local method = MySQL[alias[key]]
			MySQL.Async[key] = method
			MySQL.Sync[key] = method.await
			alias[key] = nil
			return self[key]
		end
	end
}

local function addStore(query, cb)
	assert(type(query) == 'string', 'The MySQL Query must be a string')

	local storeN = #queryStore + 1
	queryStore[storeN] = query

	return cb and cb(storeN) or storeN
end

MySQL.Sync = setmetatable({ store = addStore }, alias_mt)
MySQL.Async = setmetatable({ store = addStore }, alias_mt)

local function onReady(cb)
	while GetResourceState('mongoDB') ~= 'started' do
		Wait(50)
	end

	-- MySQL ready to handle requests
	return cb and cb() or true
end

MySQL.ready = setmetatable({
	await = onReady
}, {
	__call = function(_, cb)
		Citizen.CreateThreadNow(function() onReady(cb) end)
	end,
})

_ENV.MySQL = MySQL
