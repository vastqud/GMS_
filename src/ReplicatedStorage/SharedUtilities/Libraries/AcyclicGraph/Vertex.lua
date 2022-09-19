--!strict
local Types = require(script.Parent.Types);
type Vertex = Types.Vertex
type AcyclicGraph = Types.AcyclicGraph

local VertexClass = {};
VertexClass.prototype = {};

function VertexClass.new(id: string, graph: AcyclicGraph): Vertex
    local self = setmetatable({
        Parents = {},
        ValueData = {},
        Id = id,
        Graph = graph,
        HasChildren = false
    }, {__index = VertexClass.prototype});

    return self :: any;
end;

function VertexClass.prototype:SetVertexData(dataIndex: string, data: any?): nil
    self.ValueData[dataIndex] = data;

    return;
end;

function VertexClass.prototype:HasParent(testVertex: Vertex): boolean
    local id = testVertex.Id;

    if self.Graph ~= testVertex.Graph then return false end;
    if self.Parents[id] then return true end;

    return false;
end;

function VertexClass.prototype:SetAsParentTo(vertex: Vertex): nil
    self.HasChildren = true;

    vertex.Parents[self.Id] = self

    return;
end;

return VertexClass;