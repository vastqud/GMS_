--!strict
local Vertices = require(script.Vertex);
local Types = require(script.Types);

export type Vertex = Types.Vertex;
export type AcyclicGraph = Types.AcyclicGraph


local Graph = {};
Graph.prototype = {};

local function dfs(vertex: Vertex, fn: (Vertex, {string}) -> nil, visited: {[string]: boolean}?, path: {string}?)
	if not visited then
		visited = {}
	end

	if not path then
		path = {}
	end

	local name = vertex.Id

    assert(visited ~= nil, "Visited table doesn't exist");
    assert(path ~= nil, "Path table doesn't exist");

	if visited[name] then
		return
	end

	table.insert(path, name);
	visited[name] = true

	local parents = vertex.Parents
	for id, parentVertex in pairs(parents) do
		dfs(parentVertex, fn, visited, path)
	end

	fn(vertex, path)
	table.remove(path, #path)
end

function Graph.new(name: string): AcyclicGraph
    local self = setmetatable({
        Vertices = {},
        Name = name
    }, {__index = Graph.prototype});

    return self :: any;
end;
/
--  Internal method for retrieving a vertex with a given id or creating a new one
function Graph.prototype:GetVertex(id: string): Vertex
    if self.Vertices[id] then return self.Vertices[id]; end;  --  A vertex with that id already exists, return it

    local newVertex = Vertices.new(id, self);  --  Create a new vertex
    self.Vertices[id] = newVertex;

    return newVertex;
end;

--  Creates a new vertex (or returns an existing one), then sets its data
function Graph.prototype:MapNewVertex(id: string, data: {[string]: any}?): Vertex
    local thisVertex = self:GetVertex(id, data);

    if data then
        for index, data in pairs(data) do
            thisVertex:SetVertexData(index, data);
        end;
    end;

    return thisVertex;
end;

--  Creates a directional edge between two given vertices. If the new edge would create a cycle, this method throws an error
function Graph.prototype:CreateEdge(startId: string, targetId: string): nil
    if startId == targetId then return end;

    local startVertex, targetVertex = self:GetVertex(startId), self:GetVertex(targetId);
    if targetVertex:HasParent(startVertex) then return end; --  An edge between these two vertices already exists

    local function checkCycle(vertex, path)
		if vertex.Id == targetId then
			error("cycle detected: " .. targetId .. " <- " .. table.concat(path, " <- "));
		end;
	end;

    dfs(startVertex, checkCycle);

    startVertex:SetAsParentTo(targetVertex);
    return;
end;

return Graph;