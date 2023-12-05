# Timeouts

1. Manager start instance termination.
2. systemd start instance shutdown.
3. systemd sends `SIGQUIT` (KillSignal) to runner for gracefull shutdown.
4. Runner waits indefinitely.
5. After `TimeoutStopSec` (5min) systemd sends `SIGTERM` (FinalKillSignal) to runner for forcefull (but not instant) shutdown.
6. Runner stops jobs immediately, but still sends updates to coordinator.
7. After `shutdown_timeout` (60s) runner stops itself without updating coordinator.