```
$ free -m # free memory in mebibytes

               total        used        free      shared  buff/cache   available
Mem:           31946       21591        3088        1423        9334       10354
Swap:              0           0           0

$ systemctl show controller-web.service | grep Memory

MemoryCurrent=726519808
MemoryPeak=829767680
MemorySwapCurrent=0
MemorySwapPeak=0
MemoryZSwapCurrent=0
MemoryAvailable=11060129792
EffectiveMemoryMax=33498275840
EffectiveMemoryHigh=33498275840
EffectiveMemoryNodes=0
MemoryAccounting=yes
MemoryMin=0
MemoryLow=0
StartupMemoryLow=0
MemoryHigh=infinity
StartupMemoryHigh=infinity
MemoryMax=infinity
StartupMemoryMax=infinity
MemorySwapMax=infinity
StartupMemorySwapMax=infinity
MemoryZSwapMax=infinity
StartupMemoryZSwapMax=infinity
MemoryZSwapWriteback=yes
ManagedOOMMemoryPressure=auto
ManagedOOMMemoryPressureLimit=0
ManagedOOMMemoryPressureDurationUSec=[not set]
MemoryPressureWatch=auto
MemoryPressureThresholdUSec=200ms
MemoryDenyWriteExecute=no
MemoryKSM=no
MemoryTHP=inherit

$ grep -E "^(low|high|max|oom)" /sys/fs/cgroup/system.slice/controller-web.service/memory.events

low 0
high 0
max 0
oom 0
oom_kill 0
oom_group_kill 0

$ cat /sys/fs/cgroup/system.slice/controller-web.service/memory.current
727498752

$ cat /sys/fs/cgroup/system.slice/controller-web.service/memory.peak
829767680


$ sudo awk '/^Size: *16384 kB/{f=1} f&&/^Rss:/{t+=$2; f=0} END{print t" kB resident in 16MB mappings"}' /proc/759545/smaps
kB resident in 16MB mappings
```

# Ruby Fibre Config

FIBER_POOL_ALLOCATION_FREE
FIBER_POOL_MINIMUM_COUNT
FIBER_POOL_MAXIMUM_ALLOCATIONS
RUBY_FIBER_VM_STACK_SIZE
RUBY_FIBER_MACHINE_STACK_SIZE

`FIBER_POOL_ALLOCATION_FREE` is **conditionally defined**:

```c
#ifdef COROUTINE_LIMITED_ADDRESS_SPACE
#define FIBER_POOL_ALLOCATION_FREE
...
#endif
#ifdef RB_EXPERIMENTAL_FIBER_POOL
#define FIBER_POOL_ALLOCATION_FREE
#endif
```

When enabled, `fiber_pool_allocation_free` unmaps all stacks in an allocation via `munmap(allocation->base, allocation->stride *
allocation->count)` and removes the allocation from the pool's linked list.

```
freed stacks are **returned to a free list**. The code shows:
> "pool->vacancies = fiber_pool_vacancy_push(vacancy, pool->vacancies)"

There is no "clear the cache" from inside Ruby. munmap only happens in fiber_pool_allocation_free, which is behind FIBER_POOL_ALLOCATION_FREE — defined only under COROUTINE_LIMITED_ADDRESS_SPACE (32-bit) or RB_EXPERIMENTAL_FIBER_POOL. On x86_64 Linux it's compiled out. No API, no GC hook.
```

```
  ! sudo awk '/^[0-9a-f]+-[0-9a-f]+ /{n=$6; if(n=="")n="[anon]"} /^Rss:/{r[n]+=$2} END{for(k in r) if(r[k]>2048) printf "%9d kB  %s\n", r[k], k}'
  /proc/759545/smaps | sort -rn | head -20

  How to read what comes back:

  - [heap] dominant → glibc brk arena. That's malloc from Ruby — strings, buffers, C-extension data (pg result sets, mail parsing, JSON). Points at
    large transient allocations retained by arena fragmentation, and malloc_trim/MALLOC_ARENA_MAX become relevant.
  - [anon] dominant, spread over many mappings → Ruby's GC heap pages. That's live Ruby objects, i.e. a genuine retention bug — something is holding
    references.
  - one or two huge [anon] mappings → a single oversized allocation (one big buffer or one huge structure), which is the easiest kind to find.
  - libruby/.so lines → just code, ignore them.
```

```
$ sudo awk '/^Rss:/{t+=$2} END{print t}' /proc/759545/smaps
671636
```

# What's this?

rb_vm_map_reusable_lazy
MADV_FREE
munmap
