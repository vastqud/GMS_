task.wait(5);
--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");

--Containers
local Libraries = ReplicatedStorage.SharedUtilities.Libraries;

--Modules
local AcyclicGraphClass = require(Libraries.AcyclicGraph);
type AcyclicGraph = AcyclicGraphClass.AcyclicGraph;

local graph: AcyclicGraph = AcyclicGraphClass.new("TestingGraph");
graph:MapNewVertex("a", {
    MissionRef = "mission1"
} :: any);
graph:MapNewVertex("b", {
    MissionRef = "mission2"
} :: any);
graph:MapNewVertex("c", {
    MissionRef = "mission3"
} :: any);

graph:CreateEdge("a", "b");
graph:CreateEdge("a", "c");
graph:CreateEdge("c", "b");

print(graph.Vertices);