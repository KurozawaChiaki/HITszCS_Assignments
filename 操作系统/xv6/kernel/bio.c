// Buffer cache.
//
// The buffer cache is a linked list of buf structures holding
// cached copies of disk block contents.  Caching disk blocks
// in memory reduces the number of disk reads and also provides
// a synchronization point for disk blocks used by multiple processes.
//
// Interface:
// * To get a buffer for a particular disk block, call bread.
// * After changing buffer data, call bwrite to write it to disk.
// * When done with the buffer, call brelse.
// * Do not use the buffer after calling brelse.
// * Only one process at a time can use a buffer,
//     so do not keep them longer than necessary.

#include "types.h"
#include "param.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "riscv.h"
#include "defs.h"
#include "fs.h"
#include "buf.h"

struct {
    struct spinlock lock;
    struct buf buf[NBUF];

    // Linked list of all buffers, through prev/next.
    // Sorted by how recently the buffer was used.
    // head.next is most recent, head.prev is least.
    struct buf head;
} bcache;

struct bucket {
    struct spinlock lock;
    struct buf head;
} hashtable[NBUCKET];

int hash(uint blockno)
{
    return blockno % NBUCKET;
}

void binit(void)
{
    struct buf* b;

    for (int i = 0; i < NBUCKET; i++) {
        initlock(&hashtable[i].lock, "bcache_bucket");
    }

    hashtable[0].head.next = bcache.buf;
    for (b = bcache.buf; b < bcache.buf + NBUF - 1; b++) {
        initsleeplock(&b->lock, "buffer");
        b->next = b + 1;
    }
    initsleeplock(&b->lock, "buffer");
}

void writeCache(struct buf* replace, uint dev, uint blockno)
{
    replace->dev = dev;
    replace->blockno = blockno;
    replace->valid = 0;
    replace->refcnt = 1;
    replace->timestamp = ticks;
}

// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
    struct buf *b, *last, *replace = 0;

    int index = hash(blockno);
    struct bucket* bucket = hashtable + index;
    acquire(&bucket->lock);

    // Is the block already cached?
    for (b = bucket->head.next, last = &bucket->head; b != 0; b = b->next, last = last->next) {
        if (b->dev == dev && b->blockno == blockno) {
            b->refcnt++;
            b->timestamp = ticks;
            release(&bucket->lock);
            acquiresleep(&b->lock);

            return b;
        }

        if (b->refcnt == 0) {
            replace = b;
        }
    }

    if (replace) {
        writeCache(replace, dev, blockno);
        release(&hashtable[index].lock);
        acquiresleep(&replace->lock);

        return replace;
    }

    int lockNum = -1;
    int minTime = 0x8fffffff;

    struct buf *tmp, *lastTake = 0;
    for (int i = 0; i < NBUCKET; i++) {
        if (i == index) {
            continue;
        }

        acquire(&hashtable[i].lock);
        for (b = hashtable[i].head.next, tmp = &hashtable[i].head; b != 0; b = b->next, tmp = tmp->next) {
            if (b->refcnt == 0 && b->timestamp < minTime) {
                minTime = b->timestamp;
                lastTake = tmp;
                replace = b;

                if (lockNum != -1 && lockNum != i && holding(&hashtable[lockNum].lock)) {
                    release(&hashtable[lockNum].lock);
                }
                lockNum = i;
            }
        }

        if (lockNum != i) {
            release(&hashtable[i].lock);
        }
    }

    if (replace == 0) {
        panic("bget: no buffer");
    }

    lastTake->next = replace->next;
    replace->next = 0;
    release(&hashtable[lockNum].lock);

    b = last;
    b->next = replace;
    writeCache(replace, dev, blockno);

    release(&hashtable[index].lock);
    acquiresleep(&replace->lock);

    return replace;
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    struct buf* b;

    b = bget(dev, blockno);
    if (!b->valid) {
        virtio_disk_rw(b, 0);
        b->valid = 1;
    }
    return b;
}

// Write b's contents to disk.  Must be locked.
void bwrite(struct buf* b)
{
    if (!holdingsleep(&b->lock))
        panic("bwrite");
    virtio_disk_rw(b, 1);
}

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void brelse(struct buf* b)
{
    if (!holdingsleep(&b->lock))
        panic("brelse");

    releasesleep(&b->lock);

    int index = hash(b->blockno);

    acquire(&hashtable[index].lock);

    b->refcnt--;

    release(&hashtable[index].lock);
}

void bpin(struct buf* b)
{
    int index = hash(b->blockno);

    acquire(&hashtable[index].lock);
    b->refcnt++;
    release(&hashtable[index].lock);
}

void bunpin(struct buf* b)
{
    int index = hash(b->blockno);

    acquire(&hashtable[index].lock);
    b->refcnt--;
    release(&hashtable[index].lock);
}
