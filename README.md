# Connected-Components-And-Page-Rank
Stored procedures in SQL to analyze a graph data set. The data set to analyze contains citation information for about 5000 papers from the Arxiv high-energy physics theory paper archive. The data set has around 14,400 citations between those papers. The data set is comprised of two database tables:

nodes (paperID, paperTitle); edges (paperID, citedPaperID);

The ﬁrst table gives a unique paper identiﬁer, as well as the paper title. The second table indicates citations between the papers (note that citations have a direction).

The first stored procedure treats the graph as being undirected (that is, do not worry about the direction of citation) and ﬁnds all connected components in the graph that have more than four and at most ten papers, printing out the associated lists of paper titles.

The second stored procedure computes the page rank for every paper in the data set. PageRank is a standard graph metric that is well-known as the basis for Google’s original search engine. The idea behind PageRank is simple: we want a metric that rewards web pages (or in our case, physics papers) that are often pointed to by other pages. The more popular the page, the greater the PageRank.
