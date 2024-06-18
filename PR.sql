DROP PROCEDURE page_rank

CREATE PROCEDURE page_rank

AS BEGIN DECLARE @total_nodes int SET @total_nodes = (SELECT count(paperID) FROM nodes)

CREATE TABLE #sinks ( paperID int )

-- Find the sink nodes INSERT INTO #sinks SELECT DISTINCT n3.paperID FROM nodes n3 WHERE NOT EXISTS (SELECT e1.paperID FROM edges e1 WHERE e1.citedPaperID = n3.paperID)

DECLARE @sinks_cnt FLOAT SET @sinks_cnt = (SELECT count(*) FROM #sinks)

CREATE TABLE #PR ( paperID int, PR FLOAT, citations int )

-- Initialize the PR INSERT INTO #PR SELECT n.paperID, 1.0 / @total_nodes, (SELECT count(e.citedPaperID) FROM edges e WHERE e.paperID = n.paperID) FROM nodes n

DECLARE @sum_diff FLOAT SET @sum_diff = 1 DECLARE @sink_sum FLOAT

CREATE TABLE #score_sums ( paperID int, score FLOAT )

-- PR table after the current iteration CREATE TABLE #temp_PR ( paperID int, PR FLOAT, citations int )

WHILE @sum_diff > 0.01

BEGIN -- Clear score_sums and temp_PR table TRUNCATE TABLE #score_sums TRUNCATE TABLE #temp_PR

SET @sink_sum = (SELECT sum(x.PR) FROM #PR x WHERE x.citations = 0)

-- Processing normal (not sink) nodes INSERT INTO #score_sums SELECT pr.paperID, ( SELECT sum(pr1.PR / pr1.citations) FROM #PR pr1 WHERE EXISTS ( SELECT e2.citedPaperID FROM edges e2 WHERE e2.citedPaperID = pr.paperID AND e2.paperID = pr1.paperID ) ) AS score FROM #PR pr WHERE pr.paperID NOT IN (SELECT s.paperID FROM #sinks s)

-- Processing sink nodes INSERT INTO #score_sums SELECT pr.paperID, 0 AS score FROM #PR pr WHERE (pr.paperID IN (SELECT s.paperID FROM #sinks s))

-- Compute the final PR INSERT INTO #temp_PR SELECT pr.paperID, (0.15 / @total_nodes + 0.85 * ((SELECT ss.score FROM #score_sums ss WHERE ss.paperID = pr.paperID) + @sink_sum / (@total_nodes - 1))) AS PR, pr.citations

FROM #PR pr

SET @sum_diff = (SELECT sum(ABS(temp_pr.PR - pr.PR)) FROM #temp_PR temp_pr JOIN #PR pr ON temp_pr.paperID = pr.paperID)

-- Update PR table TRUNCATE TABLE #PR INSERT INTO #PR SELECT * FROM #temp_PR

END

-- Select top 10 page rank papers SELECT TOP(10) pr.paperID, n.paperTitle, pr.PR FROM #PR pr JOIN nodes n ON n.paperID = pr.paperID ORDER BY pr.PR DESC

END

EXECUTE page_rank