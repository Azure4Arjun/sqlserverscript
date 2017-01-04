--Cost Treeshold of paralelism

http://sqlblog.com/blogs/jonathan_kehayias/archive/2010/01/19/tuning-cost-threshold-of-parallelism-from-the-plan-cache.aspx
-- Cost number was the number of seconds it would take in a 1997 developer machine. Today this number is meaningless
Comments
 	
Paul White said:
Something that can work well in many environments, assuming a primarily OLTP-type workload:

1.  Server-wide setting to MAXDOP = 1

2.  Cost threshold set to zero

3.  Use the MAXDOP = N query hint on code that benefits from parallelism (even if it's just MAXDOP 2 to allow bitmap operators).

I also would dearly love to see an OPTION (USE_PARALLEL_PLAN) hint in SQL Server, but I can quite see why the SQL Server team would be reluctant to do this - sigh.

January 26, 2010 6:02 AM
 	
Jonathan Kehayias said:
Paul,

Your comment is exactly what Bob Ward said not to do in his Wait Stats Session at PASS.  In addition 'cost threshold for parallelism' is ignored as is the MAXDOP hint when you set the server wide setting for 'max degree of parallelism' to 1, so your #2 and #3 are overridden all the time by #1.

http://msdn.microsoft.com/en-us/library/ms188603.aspx

January 26, 2010 2:33 PM
 	
Paul White said:
Jonathan,

That is absolutely *not* correct.  A query hint MAXDOP overrides the server-wide setting, and the cost threshold for parallelism is still respected when overriding MAXDOP in this way.

Consider the following very simple query using data from the 2008 SR4 AdventureWorksDW sample database:

SELECT COUNT_BIG(*) FROM dbo.FactInternetSales;

On a server configured with Server MAXDOP = 1, cost threshold = 0, you get a simple serial plan as expected.

Adding OPTION (MAXDOP 2) to the query produces a parallel plan with an estimated plan cost of 0.17

Change the cost threshold for parallelism to 1 and we return to a serial plan.

Separately, Bob's point was to not set server-wide MAXDOP to 1 in an attempt to fix CXPACKET waits.  I could not agree more.  My point was, and continues to be, that OLTP environments can benefit from server MAXDOP = 1, with the DBA selectively overriding MAXDOP as shown.  That was why I heavily qualified my previous comment with the statement concerning OLTP workloads.

Paul