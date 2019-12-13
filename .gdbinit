set gnutarget elf32-littlearm
target extended-remote :3333

monitor arm semihosting enable

define hook-run
    load
    set confirm off
end

define sync
    monitor gdb_sync
    si
end
