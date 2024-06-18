DROP PROCEDURE bfs

-- Table to store the final result CREATE TABLE res ( paperID int, compID int -- The connected component ID )

-- Create a table type used to store connected components CREATE TYPE [dbo].[comp] AS TABLE (paperId int)

-- The bfs procedure CREATE PROCEDURE bfs @prevComp comp READONLY, @compID int

AS BEGIN DECLARE @tempComp comp -- Store the previous connected component count in order to compare with the current count DECLARE @prevCnt int = (SELECT count(*) FROM @prevComp)

-- Copy components in the prevComp into curComp INSERT INTO @tempComp(paperID) ( SELECT * FROM @prevComp )

-- Consider the graph to be undirected so we need to insert both cited paper id and paper

id

INSERT INTO @tempComp(paperID) ( SELECT e.paperID FROM edges e join @prevComp p on e.citedPaperID = p.paperID ) INSERT INTO @tempComp(paperID) ( SELECT e.citedPaperID FROM edges e join @prevComp p on e.paperID = p.paperID )

-- copy distinct paperId to DECLARE @curComp comp INSERT INTO @curComp(paperID) ( SELECT DISTINCT paperID FROM @tempComp )

-- Obtain the current component count to compare it with the previous one DECLARE @curCnt int = (SELECT count(*) FROM @curComp)

-- Compare current count with previous count in order to determine if the loop ends if (@prevCnt <> @curCnt) BEGIN EXECUTE bfs @curComp, @compID END ELSE

-- All elements in this connected component have been found BEGIN INSERT INTO res(paperID, compID) ( SELECT paperID, @compID from @curComp ) if (@curCnt > 4 AND @curCnt <= 10) BEGIN

-- print the paperID and the paperTitle SELECT n.paperID, n.paperTitle FROM nodes n JOIN @curComp cc ON n.paperID = cc.paperID END END END

-- Start BFS BEGIN

-- Initialization

DECLARE @next_node comp DECLARE @compID int = 0 DELETE FROM res -- clear the res table DECLARE @visitedCnt int = (

SELECT count(*) FROM res

) DECLARE @totalCnt int = (

SELECT count(*) FROM nodes

) -- Start the BFS while loop

while (@visitedCnt < @totalCnt) BEGIN

DELETE FROM @next_node INSERT INTO @next_node(paperID) ( SELECT TOP(1) x.paperID FROM (SELECT n2.paperID FROM nodes n2 WHERE n2.paperID NOT IN (SELECT r.paperID FROM res r)) AS x ) EXECUTE bfs @next_node, @compID SET @compID = @compID + 1

-- Update visitedCnt

SET @visitedCnt = (SELECT count(*) FROM res) END END