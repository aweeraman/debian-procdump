#!/bin/sh

# Send a sleeper process into the background
sh -c "sleep 10" &
TASK_PID=$!
TASK_PGID=$(ps -o pgid= $TASK_PID)
echo "TASK PID = $TASK_PID"

# Procdump to kill the sleeper process. Needs root.
ls -l /usr/bin/procdump
procdump -pgid $TASK_PGID -n 1 &
PROCDUMP_PID=$!
echo "PROCDUMP PID = $PROCDUMP_PID"
ps aux | grep -i $PROCDUMP_PID

# Give procdump some time to do it's thing.
sleep 10

# Sleeper process may already be dead by this point
echo "Killing $TASK_PID"
kill -9 $TASK_PID 2>/dev/null

# This is to cleanup procdump if it is hanging
echo "Killing $PROCDUMP_PID"
kill -9 $PROCDUMP_PID 2>/dev/null

# Check if a core file has been created and clean it up
CORE_COUNT=$(ls -1 sh_time* | wc -l)
rm -f sh_time*
rm -f sleep_time*
echo "Cores dumped: $CORE_COUNT"

if [ $CORE_COUNT -gt 0 ]; then
	echo "Successful"
	exit 0
else
	echo "Failed"
	exit 1
fi
