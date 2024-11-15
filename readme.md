
# MongoDB Wrapper for FiveM
### This Wrapper also includes a MongoDB connection pool to handle multiple connections
- set mongodbURL "mongodb://localhost:27017"
- set mongodbDatabase "jarvis"
- set mongodbPoolSize 5

This Wrapper also supports MySQL Queries , Scroll Down To See
## Installation

Download the files and drag and drop it in the resources folder

If you want to do any kind of changes in wrapper.
```bash
  cd resources && 
  yarn && yarn dev
```
### Server Side Exports :

- findOne
```lua
local result = exports['monogDB']:findOne("collection", {test = "test"})

exports['monogDB']:findOne("collection", {test = "test"}, function(result)
    print(json.encode(result, {indent = true}))
end)
```

```ts
const result = await global.exports['mongoDB'].findOne("test", { test: "test" })
console.log(result)

global.exports['mongoDB'].findOne("test", { test: "test" }).then((result: any) => {
    console.log(result)
})
```
- findMany
```lua
local result = exports['monogDB']:findMany("collection", {test = "test"})

exports['monogDB']:findMany("collection", {test = "test"}, function(result)
    print(json.encode(result, {indent = true}))
end)
```

```ts
const result = await global.exports['mongoDB'].findMany("test", { test: "test" })
console.log(result)

global.exports['mongoDB'].findMany("test", { test: "test" }).then((result: any) => {
    console.log(result)
})
```
- findAndReturnSpecificFields
```lua
local result = exports['monogDB']:findAndReturnSpecificFields("collection", {test = "test"}, {'test'})

exports['monogDB']:findAndReturnSpecificFields("collection", {test = "test"}, {'test'}, function(result)
    print(json.encode(result, {indent = true}))
end)
```

```ts
const result = await global.exports['mongoDB'].findAndReturnSpecificFields("test", { test: "test" }, ['test'])
console.log(result)

global.exports['mongoDB'].findAndReturnSpecificFields("test", { test: "test" }, ['test']).then((result: any) => {
    console.log(result)
})
```

- insertOne
```lua
local result = exports['monogDB']:insertOne("collection", {test = "test"})

exports['monogDB']:insertOne("collection", {test = "test"}, function(result)
    print(json.encode(result, {indent = true}))
end)
```
```ts
const result = await global.exports['mongoDB'].insertOne("test", { test: "test" })
console.log(result)

global.exports['mongoDB'].insertOne("test", { test: "test" }).then((result: any) => {
    console.log(result)
})
```
- insertMany
```lua
local result = exports['monogDB']:insertMany("collection", {test = "test"})

exports['monogDB']:insertMany("collection", {test = "test"}, function(result)
    print(json.encode(result, {indent = true}))
end)
```

```ts
const result = await global.exports['mongoDB'].insertMany("test", [{ test: "test" }])
console.log(result)

global.exports['mongoDB'].insertMany("test", [{ test: "test" }]).then((result: any) => {
    console.log(result)
})
```

- updateOne
```lua
local result = exports['monogDB']:updateOne("collection", {test = "test"}, {test = "test"})

exports['monogDB']:updateOne("collection", {test = "test"}, {test = "test"}, function(result)
    print(json.encode(result, {indent = true}))
end)
```
```ts
const result = await global.exports['mongoDB'].updateOne("test", { test: "test" }, { test: "test" })
console.log(result)

global.exports['mongoDB'].updateOne("test", { test: "test" }, { test: "test" }).then((result: any) => {
    console.log(result)
})
```

- updateMany
```lua
local result = exports['monogDB']:updateMany("collection", {test = "test"}, {test = "test"})

exports['monogDB']:updateMany("collection", {test = "test"}, {test = "test"}, function(result)
    print(json.encode(result, {indent = true}))
end)
```
```ts
const result = await global.exports['mongoDB'].updateMany("test", { test: "test" }, { test: "test" })
console.log(result)

global.exports['mongoDB'].updateMany("test", { test: "test" }, { test: "test" }).then((result: any) => {
    console.log(result)
})
```
- deleteOne
```lua
local result = exports['monogDB']:deleteOne("collection", {test = "test"})

exports['monogDB']:deleteOne("collection", {test = "test"}, function(result)
    print(json.encode(result, {indent = true}))
end)
```
```ts
const result = await global.exports['mongoDB'].deleteOne("test", { test: "test" })
console.log(result)

global.exports['mongoDB'].deleteOne("test", { test: "test" }).then((result: any) => {
    console.log(result)
})
```
- deleteMany
```lua
local result = exports['monogDB']:deleteMany("collection", {test = "test"})

exports['monogDB']:deleteMany("collection", {test = "test"}, function(result)
    print(json.encode(result, {indent = true}))
end)
```
```ts
const result = await global.exports['mongoDB'].deleteMany("test", { test: "test" })
console.log(result)

global.exports['mongoDB'].deleteMany("test", { test: "test" }).then((result: any) => {
    console.log(result)
})
```
## SQL Query Support
In order to get SQL support add this line to fxmanifest.lua
```lua
 '@mongoDB/lib/MySQL.lua',
```

- SELECT
```lua
local res = MySQL.query.await('SELECT test FROM test WHERE test = @test AND test1 = @test', { ['@test'] = 'test' })

local res = MySQL.query.await('SELECT test FROM test WHERE test = :test AND test1 = :test', { ['@test'] = 'test' })

local res = MySQL.query.await('SELECT * FROM test WHERE test = @test AND test1 = @test', { ['@test'] = 'test' })

local res = MySQL.query.await('SELECT * FROM test WHERE test = ? AND test1 = ?', { 'test', 'test' })
```

Also Support this
```lua
MySQL.query('SELECT * FROM test WHERE test = ? AND test1 = ?', { 'test', 'test' }, function(result)
    print(json.encode(result, {indent=true}))
end)
```

- INSERT
```lua
local res = MySQL.insert.await('INSERT INTO test (test, test1) VALUES (:test, :test1)', { ['@test'] = 'test', ['@test1'] = 'test' })

local res = MySQL.insert.await('INSERT INTO test (test, test1) VALUES (@test, @test1)', { ['@test'] = 'test', ['@test1'] = 'test' })

local res = MySQL.insert.await('INSERT INTO test (test, test1) VALUES (?, ?)', { 'test', 'test' })
```

- UPDATE
```lua
local res = MySQL.update.await('UPDATE test SET test = :test WHERE test = :test1', { ['@test'] = 'testAWERQSADSA', ['@test1'] = 'test' })

local res = MySQL.update.await('UPDATE test SET test = @test WHERE test = @test1', { ['@test'] = 'testAWERQSADSA', ['@test1'] = 'test' })

local res = MySQL.update.await('UPDATE test SET test = ? WHERE test = ?', {'testAWERQSADSA', 'test' })
```
- DELETE
```lua
local result = MySQL.query.await('DELETE FROM test WHERE test = @test', { ['@test'] = 'testAWERQSADSA' })

local result = MySQL.query.await('DELETE FROM test WHERE test = :test', { ['@test'] = 'testAWERQSADSA' })

local result = MySQL.query.await('DELETE FROM test WHERE test = ?', { 'testAWERQSADSA' })
```
I am looking to expand SQL query support for this project and would greatly appreciate contributions from the community. If you're interested, feel free to open a pull request. Your input and expertise are highly valued!