
FEBRUARY 8, 2011 BY PINAL DAVE
SQL SERVER – SOS_SCHEDULER_YIELD – Wait Type – Day 8 of 28
This is a very interesting wait type and quite often seen as one of the top wait types. Let us discuss this today.

From Book On-Line:

Occurs when a task voluntarily yields the scheduler for other tasks to execute. During this wait the task is waiting for its quantum to be renewed.

SOS_SCHEDULER_YIELD Explanation:

SQL Server has multiple threads, and the basic working methodology for SQL Server is that SQL Server does not let any “runnable” thread to starve. Now let us assume SQL Server OS is very busy running threads on all the scheduler. There are always new threads coming up which are ready to run (in other words, runnable). Thread management of the SQL Server is decided by SQL Server and not the operating system. SQL Server runs on non-preemptive mode most of the time, meaning the threads are co-operative and can let other threads to run from time to time by yielding itself. When any thread yields itself for another thread, it creates this wait. If there are more threads, it clearly indicates that the CPU is under pressure.

You can fun the following DMV to see how many runnable task counts there are in your system.

SELECT scheduler_id, current_tasks_count, runnable_tasks_count, work_queue_count, pending_disk_io_count
FROM sys.dm_os_schedulers
WHERE scheduler_id < 255
GO

If you notice a two-digit number in runnable_tasks_count continuously for long time (not once in a while), you will know that there is CPU pressure. The two-digit number is usually considered as a bad thing; you can read the description of the above DMV over here.

Additionally, there are several other counters (%Processor Time and other processor related counters), through which you can refer to so you can validate CPU pressure along with the method explained above.

Reducing SOS_SCHEDULER_YIELD wait:

This is the trickiest part of this procedure. As discussed, this particular wait type relates to CPU pressure. Increasing more CPU is the solution in simple terms; however, it is not easy to implement this solution. There are other things that you can consider when this wait type is very high. Here is the query where you can find the most expensive query related to CPU from the cache

Note: The query that used lots of resources but is not cached will not be caught here.

SELECT SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1,
((CASE qs.statement_end_offset
WHEN -1 THEN DATALENGTH(qt.TEXT)
ELSE qs.statement_end_offset
END - qs.statement_start_offset)/2)+1),
qs.execution_count,
qs.total_logical_reads, qs.last_logical_reads,
qs.total_logical_writes, qs.last_logical_writes,
qs.total_worker_time,
qs.last_worker_time,
qs.total_elapsed_time/1000000 total_elapsed_time_in_S,
qs.last_elapsed_time/1000000 last_elapsed_time_in_S,
qs.last_execution_time,
qp.query_plan
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY qs.total_worker_time DESC -- CPU time


You can find the most expensive queries that are utilizing lots of CPU (from the cache) and you can tune them accordingly. Moreover, you can find the longest running query and attempt to tune them if there is any processor offending code.

Additionally, pay attention to total_worker_time because if that is also consistently higher, then  the CPU under too much pressure.

You can also check perfmon counters of compilations as they tend to use good amount of CPU. Index rebuild is also a CPU intensive process but we should consider that main cause for this query because that is indeed needed on high transactions OLTP system utilized to reduce fragmentations.

Read all the post in the Wait Types and Queue series.

Note: The information presented here is from my experience and there is no way that I claim it to be accurate. I suggest reading Book OnLine for further clarification. All of the discussions of Wait Stats in this blog is generic and varies from system to system. It is recommended that you test this on a development server before implementing it to a production server.