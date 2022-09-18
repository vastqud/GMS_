--!strict
export type Vertex = {
    Parents: {[string]: Vertex},
    ValueData: {[string]: any?},
    Id: string,
    Graph: any,
    HasChildren: boolean,
    SetVertexData: (self: Vertex, dataIndex: string, data: any?) -> nil,
    HasParent: (self: Vertex, testVertex: Vertex) -> boolean,
    SetAsParentTo: (self: Vertex, vertex: Vertex) -> nil
};

local VertexClass = {};
VertexClass.prototype = {};

function VertexClass.new(id: string, graph: any): Vertex
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