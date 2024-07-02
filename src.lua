local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local Compressor = require(script.Compressor)

local Dynstore = {}

function Dynstore:New(identifier: string)
	local Database = DataStoreService:GetDataStore(identifier)
	local Storage = {
		Compressed = false,
	}
	
	function Storage:Save(Key, Value)
		local success, result = pcall(function()
			if Storage.Compressed then
				Database:SetAsync(Key, Compressor.compress(HttpService:JSONEncode(Value)))
			else
				Database:SetAsync(Key, Value)
			end
		end)

		if success then
			print("[Dynstore] Successfully saved key")
		else
			print("[Dynstore] Got error while saving key: "..result)
		end
	end

	function Storage:Load(Key)
		local success, result = pcall(function()
			Database:GetAsync(Key)
		end)

		if success then
			print("[Dynstore] Successfully got key")
			if Storage.Compressed then
				return HttpService:JSONDecode(Compressor.decompress(Database:GetAsync(Key)))
			else
				return Database:GetAsync(Key)
			end
		else
			print("[Dynstore] Got error while getting key: "..result)
		end
	end

	function Storage:Delete(Key)
		local success, result = pcall(function()
			Database:RemoveAsync(Key)
		end)

		if success then
			print("[Dynstore] Successfully removed key")
		else
			print("[Dynstore] Got error while removing key: "..result)
		end
	end
	
	return Storage
end

return Dynstore
