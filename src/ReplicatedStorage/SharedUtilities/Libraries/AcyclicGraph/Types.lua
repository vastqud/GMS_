export type Vertex = {
    Parents: {[string]: Vertex},
    ValueData: {[string]: any?},
    Id: string,
    Graph: AcyclicGraph,
    HasChildren: boolean,
    SetVertexData: (self: Vertex, dataIndex: string, data: any?) -> nil,
    HasParent: (self: Vertex, testVertex: Vertex) -> boolean,
    SetAsParentTo: (self: Vertex, vertex: Vertex) -> nil
};
export type AcyclicGraph = {
    Vertices: {[string]: Vertex},
    Name: string,
    GetVertex: (self: Vertex, id: string) -> Vertex,
    MapNewVertex: (self: Vertex, id: string, data: {[string]: any?}?) -> Vertex,
    CreateEdge: (self: Vertex, startId: string, targetId: string) -> nil
};

return {};