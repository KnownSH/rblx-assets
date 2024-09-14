-- Fast Autocomplete
-- KnownSH Oct 2023

-- Uses binary search to return a result from a partial string
-- its also really fast lol
-- Based upon https://gist.github.com/n4ru/1029aca43f1272e1229d154a2accfc5a

local function rearrangeStrings(arr)
	local originals = {}
	local rearrangedStrings = table.create(#arr)

	for _, str in ipairs(arr) do
		local lowerStr = string.lower(str)

		-- NOTE: the orignal code includes "[string.gsub(lower, "%l+%.?", expansions)] = true" for replacing specific slang terms with other terms, however this isn't needed
		-- despite this, i have kept the for loop/table for future cases where this is needed
		for base in {[lowerStr] = true} do -- in truth base == lowerStr 🤷
			originals[base] = str
			table.insert(rearrangedStrings, base)

			-- honestly idk how the below stuff works but it does so im not changing it
			local a = string.split(base, " ")
			local N = #a
			local p = table.create(N, 1)
			local i = 2

			-- The Counting QuickPerm Algorithm
			-- https://www.quickperm.org/
			while i <= N do
				local pi = p[i]
				if pi < i then
					local j = if i % 2 == 1 then 1 else pi
					a[j], a[i] = a[i], a[j]

					local rearrangedString = table.concat(a, " ")
					originals[rearrangedString] = str
					table.insert(rearrangedStrings, rearrangedString)

					p[i] = pi + 1
					i = 2
				else
					p[i] = 1
					i += 1
				end
			end
		end
	end

	table.sort(rearrangedStrings)

	return rearrangedStrings, originals
end

local function binarySearchFirst(arr, targetCondition, left, right)
	while right >= left do
		local mid = left + math.floor((right - left) / 2)
		if targetCondition(arr[mid]) then
			right = mid - 1
		else
			left = mid + 1
		end
	end

	return left
end


local Autocomplete = {}

function Autocomplete.search(arr)
	local rearrangedStrings, originals = rearrangeStrings(arr)
	local rearrangedLength = #rearrangedStrings

	local self = {
		query = function(queryString)
			queryString = string.lower(queryString)

			local x = binarySearchFirst(rearrangedStrings, function(mid) return mid >= queryString end, 1, rearrangedLength)
			local y = binarySearchFirst(rearrangedStrings, function(mid) return string.sub(mid, 1, #queryString) ~= queryString end, x, rearrangedLength)
			local results, set = {}, {}

			for i = x, y - 1 do
				local result = originals[rearrangedStrings[i]]
				if not set[result] then
					set[result] = true
					table.insert(results, result)
				end
			end

			return results
		end
	}

	return self
end

return Autocomplete
