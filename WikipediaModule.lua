--!strict
-- Wikipedia/MediaWiki Module - All APIs Support
-- Production-ready module with search, content, images, categories, and more

local HttpService = game:GetService("HttpService")

local WikiModule = {}
WikiModule.__index = WikiModule

-- Configuration
local DEFAULT_LANGUAGE = "en"
local API_ENDPOINTS = {
	wikipedia = "https://%s.wikipedia.org/w/api.php",
	wikimedia = "https://commons.wikimedia.org/w/api.php",
	wikidata = "https://www.wikidata.org/w/api.php"
}

-- Create new instance
function WikiModule.new(language: string?)
	local self = setmetatable({}, WikiModule)
	self.language = language or DEFAULT_LANGUAGE
	self.apiUrl = string.format(API_ENDPOINTS.wikipedia, self.language)
	return self
end

-- Helper: Make API request
function WikiModule:_request(params: {[string]: any})
	params.format = "json"
	params.origin = "*"
	
	local queryString = ""
	for key, value in pairs(params) do
		if queryString ~= "" then
			queryString = queryString .. "&"
		end
		queryString = queryString .. HttpService:UrlEncode(key) .. "=" .. HttpService:UrlEncode(tostring(value))
	end
	
	local url = self.apiUrl .. "?" .. queryString
	
	local success, response = pcall(function()
		return HttpService:GetAsync(url)
	end)
	
	if success then
		return HttpService:JSONDecode(response)
	end
	
	return nil
end

-- Search articles
function WikiModule:search(query: string, limit: number?)
	local params = {
		action = "query",
		list = "search",
		srsearch = query,
		srlimit = limit or 10,
		srprop = "snippet|titlesnippet|categorysnippet|timestamp|wordcount"
	}
	
	return self:_request(params)
end

-- Get page content
function WikiModule:getPage(title: string)
	local params = {
		action = "query",
		titles = title,
		prop = "extracts|info|pageimages|categories",
		exintro = "true",
		explaintext = "true",
		inprop = "url",
		piprop = "original|thumbnail",
		pithumbsize = 500
	}
	
	return self:_request(params)
end

-- Get page by ID
function WikiModule:getPageById(pageId: number)
	local params = {
		action = "query",
		pageids = pageId,
		prop = "extracts|info|pageimages|categories",
		exintro = "true",
		explaintext = "true",
		inprop = "url",
		piprop = "original|thumbnail",
		pithumbsize = 500
	}
	
	return self:_request(params)
end

-- Get full page content (not just intro)
function WikiModule:getFullPage(title: string)
	local params = {
		action = "query",
		titles = title,
		prop = "extracts|info|pageimages",
		explaintext = "true",
		inprop = "url",
		piprop = "original"
	}
	
	return self:_request(params)
end

-- Parse wikitext to HTML
function WikiModule:parse(title: string)
	local params = {
		action = "parse",
		page = title,
		prop = "text|images|categories|links|sections"
	}
	
	return self:_request(params)
end

-- Get page images
function WikiModule:getImages(title: string, limit: number?)
	local params = {
		action = "query",
		titles = title,
		prop = "images",
		imlimit = limit or 10
	}
	
	return self:_request(params)
end

-- Get image info
function WikiModule:getImageInfo(filename: string)
	local params = {
		action = "query",
		titles = "File:" .. filename,
		prop = "imageinfo",
		iiprop = "url|size|mime|extmetadata"
	}
	
	return self:_request(params)
end

-- Get categories for page
function WikiModule:getCategories(title: string, limit: number?)
	local params = {
		action = "query",
		titles = title,
		prop = "categories",
		cllimit = limit or 50
	}
	
	return self:_request(params)
end

-- Get pages in category
function WikiModule:getCategoryMembers(category: string, limit: number?)
	local params = {
		action = "query",
		list = "categorymembers",
		cmtitle = "Category:" .. category,
		cmlimit = limit or 50,
		cmprop = "title|ids|type"
	}
	
	return self:_request(params)
end

-- Get page links
function WikiModule:getLinks(title: string, limit: number?)
	local params = {
		action = "query",
		titles = title,
		prop = "links",
		pllimit = limit or 50
	}
	
	return self:_request(params)
end

-- Get backlinks (pages linking to this page)
function WikiModule:getBacklinks(title: string, limit: number?)
	local params = {
		action = "query",
		list = "backlinks",
		bltitle = title,
		bllimit = limit or 50
	}
	
	return self:_request(params)
end

-- Get random pages
function WikiModule:getRandom(limit: number?)
	local params = {
		action = "query",
		list = "random",
		rnlimit = limit or 5,
		rnnamespace = 0
	}
	
	return self:_request(params)
end

-- Get page revisions history
function WikiModule:getRevisions(title: string, limit: number?)
	local params = {
		action = "query",
		titles = title,
		prop = "revisions",
		rvprop = "timestamp|user|comment|size",
		rvlimit = limit or 10
	}
	
	return self:_request(params)
end

-- Opensearch (autocomplete suggestions)
function WikiModule:opensearch(query: string, limit: number?)
	local params = {
		action = "opensearch",
		search = query,
		limit = limit or 10
	}
	
	return self:_request(params)
end

-- Prefixsearch (search titles by prefix)
function WikiModule:prefixSearch(prefix: string, limit: number?)
	local params = {
		action = "query",
		list = "prefixsearch",
		pssearch = prefix,
		pslimit = limit or 10
	}
	
	return self:_request(params)
end

-- Geosearch (find pages near coordinates)
function WikiModule:geosearch(latitude: number, longitude: number, radius: number?, limit: number?)
	local params = {
		action = "query",
		list = "geosearch",
		gscoord = latitude .. "|" .. longitude,
		gsradius = radius or 10000,
		gslimit = limit or 10
	}
	
	return self:_request(params)
end

-- Get coordinates for page
function WikiModule:getCoordinates(title: string)
	local params = {
		action = "query",
		titles = title,
		prop = "coordinates"
	}
	
	return self:_request(params)
end

-- Get external links
function WikiModule:getExternalLinks(title: string, limit: number?)
	local params = {
		action = "query",
		titles = title,
		prop = "extlinks",
		ellimit = limit or 50
	}
	
	return self:_request(params)
end

-- Get page views statistics
function WikiModule:getPageViews(title: string)
	local params = {
		action = "query",
		titles = title,
		prop = "pageviews"
	}
	
	return self:_request(params)
end

-- Get interwiki links
function WikiModule:getInterwikiLinks(title: string)
	local params = {
		action = "query",
		titles = title,
		prop = "langlinks",
		lllimit = 500
	}
	
	return self:_request(params)
end

-- Get page properties
function WikiModule:getPageProps(title: string)
	local params = {
		action = "query",
		titles = title,
		prop = "pageprops"
	}
	
	return self:_request(params)
end

-- Get redirects
function WikiModule:getRedirects(title: string)
	local params = {
		action = "query",
		titles = title,
		redirects = "true"
	}
	
	return self:_request(params)
end

-- Get featured content
function WikiModule:getFeaturedContent(type: string?)
	local params = {
		action = "query",
		list = "querypage",
		qppage = type or "Featuredarticles",
		qplimit = 50
	}
	
	return self:_request(params)
end

-- Get recent changes
function WikiModule:getRecentChanges(limit: number?)
	local params = {
		action = "query",
		list = "recentchanges",
		rclimit = limit or 10,
		rcprop = "title|timestamp|user|comment|sizes"
	}
	
	return self:_request(params)
end

-- Get user contributions
function WikiModule:getUserContributions(username: string, limit: number?)
	local params = {
		action = "query",
		list = "usercontribs",
		ucuser = username,
		uclimit = limit or 10,
		ucprop = "title|timestamp|comment|size"
	}
	
	return self:_request(params)
end

-- Get all pages in namespace
function WikiModule:getAllPages(namespace: number?, limit: number?)
	local params = {
		action = "query",
		list = "allpages",
		apnamespace = namespace or 0,
		aplimit = limit or 50
	}
	
	return self:_request(params)
end

-- Get page sections
function WikiModule:getSections(title: string)
	local params = {
		action = "parse",
		page = title,
		prop = "sections"
	}
	
	return self:_request(params)
end

-- Get specific section content
function WikiModule:getSection(title: string, section: number)
	local params = {
		action = "parse",
		page = title,
		prop = "text",
		section = section
	}
	
	return self:_request(params)
end

-- Get page HTML
function WikiModule:getHTML(title: string)
	local params = {
		action = "parse",
		page = title,
		prop = "text"
	}
	
	return self:_request(params)
end

-- Get page summary (mobile API)
function WikiModule:getSummary(title: string)
	local mobileUrl = string.format("https://%s.wikipedia.org/api/rest_v1/page/summary/%s", 
		self.language, 
		HttpService:UrlEncode(title))
	
	local success, response = pcall(function()
		return HttpService:GetAsync(mobileUrl)
	end)
	
	if success then
		return HttpService:JSONDecode(response)
	end
	
	return nil
end

-- Get related pages
function WikiModule:getRelated(title: string)
	local mobileUrl = string.format("https://%s.wikipedia.org/api/rest_v1/page/related/%s", 
		self.language, 
		HttpService:UrlEncode(title))
	
	local success, response = pcall(function()
		return HttpService:GetAsync(mobileUrl)
	end)
	
	if success then
		return HttpService:JSONDecode(response)
	end
	
	return nil
end

-- Get trending articles
function WikiModule:getTrending()
	local feedUrl = string.format("https://%s.wikipedia.org/api/rest_v1/feed/featured/%s", 
		self.language,
		os.date("%Y/%m/%d"))
	
	local success, response = pcall(function()
		return HttpService:GetAsync(feedUrl)
	end)
	
	if success then
		return HttpService:JSONDecode(response)
	end
	
	return nil
end

-- Wikidata: Get entity data
function WikiModule:getWikidataEntity(entityId: string)
	local params = {
		action = "wbgetentities",
		ids = entityId,
		format = "json"
	}
	
	local queryString = ""
	for key, value in pairs(params) do
		if queryString ~= "" then
			queryString = queryString .. "&"
		end
		queryString = queryString .. HttpService:UrlEncode(key) .. "=" .. HttpService:UrlEncode(tostring(value))
	end
	
	local url = API_ENDPOINTS.wikidata .. "?" .. queryString
	
	local success, response = pcall(function()
		return HttpService:GetAsync(url)
	end)
	
	if success then
		return HttpService:JSONDecode(response)
	end
	
	return nil
end

-- Get page protection status
function WikiModule:getProtection(title: string)
	local params = {
		action = "query",
		titles = title,
		prop = "info",
		inprop = "protection"
	}
	
	return self:_request(params)
end

-- Get templates used on page
function WikiModule:getTemplates(title: string, limit: number?)
	local params = {
		action = "query",
		titles = title,
		prop = "templates",
		tllimit = limit or 50
	}
	
	return self:_request(params)
end

-- Compare revisions
function WikiModule:compareRevisions(fromRev: number, toRev: number)
	local params = {
		action = "compare",
		fromrev = fromRev,
		torev = toRev
	}
	
	return self:_request(params)
end

-- Utility: Clean HTML from snippet
function WikiModule:cleanSnippet(snippet: string)
	return snippet:gsub("<span.->", "")
		:gsub("</span>", "")
		:gsub("&quot;", '"')
		:gsub("&amp;", "&")
		:gsub("&lt;", "<")
		:gsub("&gt;", ">")
		:gsub("&#039;", "'")
end

-- Utility: Extract page from query result
function WikiModule:extractPage(queryResult: any)
	if not queryResult or not queryResult.query or not queryResult.query.pages then
		return nil
	end
	
	local pages = queryResult.query.pages
	for _, page in pairs(pages) do
		return page
	end
	
	return nil
end

-- Utility: Get page URL
function WikiModule:getPageUrl(title: string)
	return string.format("https://%s.wikipedia.org/wiki/%s", 
		self.language, 
		HttpService:UrlEncode(title:gsub(" ", "_")))
end

-- Change language
function WikiModule:setLanguage(language: string)
	self.language = language
	self.apiUrl = string.format(API_ENDPOINTS.wikipedia, language)
end

-- Get available languages
function WikiModule:getLanguages()
	local params = {
		action = "query",
		meta = "siteinfo",
		siprop = "languages"
	}
	
	return self:_request(params)
end

return WikiModule