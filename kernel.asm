
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 30 c6 10 80       	mov    $0x8010c630,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 57 37 10 80       	mov    $0x80103757,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 20 84 10 	movl   $0x80108420,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 40 c6 10 80 	movl   $0x8010c640,(%esp)
80100049:	e8 fd 4c 00 00       	call   80104d4b <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 8c 0d 11 80 3c 	movl   $0x80110d3c,0x80110d8c
80100055:	0d 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 90 0d 11 80 3c 	movl   $0x80110d3c,0x80110d90
8010005f:	0d 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 74 c6 10 80 	movl   $0x8010c674,-0xc(%ebp)
80100069:	eb 46                	jmp    801000b1 <binit+0x7d>
    b->next = bcache.head.next;
8010006b:	8b 15 90 0d 11 80    	mov    0x80110d90,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 50 3c 0d 11 80 	movl   $0x80110d3c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	83 c0 0c             	add    $0xc,%eax
80100087:	c7 44 24 04 27 84 10 	movl   $0x80108427,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 78 4b 00 00       	call   80104c0f <initsleeplock>
    bcache.head.next->prev = b;
80100097:	a1 90 0d 11 80       	mov    0x80110d90,%eax
8010009c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010009f:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a5:	a3 90 0d 11 80       	mov    %eax,0x80110d90

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000aa:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b1:	81 7d f4 3c 0d 11 80 	cmpl   $0x80110d3c,-0xc(%ebp)
801000b8:	72 b1                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ba:	c9                   	leave  
801000bb:	c3                   	ret    

801000bc <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000bc:	55                   	push   %ebp
801000bd:	89 e5                	mov    %esp,%ebp
801000bf:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000c2:	c7 04 24 40 c6 10 80 	movl   $0x8010c640,(%esp)
801000c9:	e8 9e 4c 00 00       	call   80104d6c <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000ce:	a1 90 0d 11 80       	mov    0x80110d90,%eax
801000d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d6:	eb 50                	jmp    80100128 <bget+0x6c>
    if(b->dev == dev && b->blockno == blockno){
801000d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000db:	8b 40 04             	mov    0x4(%eax),%eax
801000de:	3b 45 08             	cmp    0x8(%ebp),%eax
801000e1:	75 3c                	jne    8010011f <bget+0x63>
801000e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e6:	8b 40 08             	mov    0x8(%eax),%eax
801000e9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000ec:	75 31                	jne    8010011f <bget+0x63>
      b->refcnt++;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 40 4c             	mov    0x4c(%eax),%eax
801000f4:	8d 50 01             	lea    0x1(%eax),%edx
801000f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fa:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
801000fd:	c7 04 24 40 c6 10 80 	movl   $0x8010c640,(%esp)
80100104:	e8 cb 4c 00 00       	call   80104dd4 <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 32 4b 00 00       	call   80104c49 <acquiresleep>
      return b;
80100117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011a:	e9 94 00 00 00       	jmp    801001b3 <bget+0xf7>
  struct buf *b;

  acquire(&bcache.lock);

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010011f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100122:	8b 40 54             	mov    0x54(%eax),%eax
80100125:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100128:	81 7d f4 3c 0d 11 80 	cmpl   $0x80110d3c,-0xc(%ebp)
8010012f:	75 a7                	jne    801000d8 <bget+0x1c>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100131:	a1 8c 0d 11 80       	mov    0x80110d8c,%eax
80100136:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100139:	eb 63                	jmp    8010019e <bget+0xe2>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010013b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010013e:	8b 40 4c             	mov    0x4c(%eax),%eax
80100141:	85 c0                	test   %eax,%eax
80100143:	75 50                	jne    80100195 <bget+0xd9>
80100145:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100148:	8b 00                	mov    (%eax),%eax
8010014a:	83 e0 04             	and    $0x4,%eax
8010014d:	85 c0                	test   %eax,%eax
8010014f:	75 44                	jne    80100195 <bget+0xd9>
      b->dev = dev;
80100151:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100154:	8b 55 08             	mov    0x8(%ebp),%edx
80100157:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 0c             	mov    0xc(%ebp),%edx
80100160:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
80100176:	c7 04 24 40 c6 10 80 	movl   $0x8010c640,(%esp)
8010017d:	e8 52 4c 00 00       	call   80104dd4 <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 b9 4a 00 00       	call   80104c49 <acquiresleep>
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1e                	jmp    801001b3 <bget+0xf7>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 50             	mov    0x50(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 3c 0d 11 80 	cmpl   $0x80110d3c,-0xc(%ebp)
801001a5:	75 94                	jne    8010013b <bget+0x7f>
      release(&bcache.lock);
      acquiresleep(&b->lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	c7 04 24 2e 84 10 80 	movl   $0x8010842e,(%esp)
801001ae:	e8 af 03 00 00       	call   80100562 <panic>
}
801001b3:	c9                   	leave  
801001b4:	c3                   	ret    

801001b5 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b5:	55                   	push   %ebp
801001b6:	89 e5                	mov    %esp,%ebp
801001b8:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801001be:	89 44 24 04          	mov    %eax,0x4(%esp)
801001c2:	8b 45 08             	mov    0x8(%ebp),%eax
801001c5:	89 04 24             	mov    %eax,(%esp)
801001c8:	e8 ef fe ff ff       	call   801000bc <bget>
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0b                	jne    801001e7 <bread+0x32>
    iderw(b);
801001dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001df:	89 04 24             	mov    %eax,(%esp)
801001e2:	e8 87 26 00 00       	call   8010286e <iderw>
  }
  return b;
801001e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ea:	c9                   	leave  
801001eb:	c3                   	ret    

801001ec <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
801001ec:	55                   	push   %ebp
801001ed:	89 e5                	mov    %esp,%ebp
801001ef:	83 ec 18             	sub    $0x18,%esp
  if(!holdingsleep(&b->lock))
801001f2:	8b 45 08             	mov    0x8(%ebp),%eax
801001f5:	83 c0 0c             	add    $0xc,%eax
801001f8:	89 04 24             	mov    %eax,(%esp)
801001fb:	e8 e6 4a 00 00       	call   80104ce6 <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 3f 84 10 80 	movl   $0x8010843f,(%esp)
8010020b:	e8 52 03 00 00       	call   80100562 <panic>
  b->flags |= B_DIRTY;
80100210:	8b 45 08             	mov    0x8(%ebp),%eax
80100213:	8b 00                	mov    (%eax),%eax
80100215:	83 c8 04             	or     $0x4,%eax
80100218:	89 c2                	mov    %eax,%edx
8010021a:	8b 45 08             	mov    0x8(%ebp),%eax
8010021d:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021f:	8b 45 08             	mov    0x8(%ebp),%eax
80100222:	89 04 24             	mov    %eax,(%esp)
80100225:	e8 44 26 00 00       	call   8010286e <iderw>
}
8010022a:	c9                   	leave  
8010022b:	c3                   	ret    

8010022c <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022c:	55                   	push   %ebp
8010022d:	89 e5                	mov    %esp,%ebp
8010022f:	83 ec 18             	sub    $0x18,%esp
  if(!holdingsleep(&b->lock))
80100232:	8b 45 08             	mov    0x8(%ebp),%eax
80100235:	83 c0 0c             	add    $0xc,%eax
80100238:	89 04 24             	mov    %eax,(%esp)
8010023b:	e8 a6 4a 00 00       	call   80104ce6 <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 46 84 10 80 	movl   $0x80108446,(%esp)
8010024b:	e8 12 03 00 00       	call   80100562 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 46 4a 00 00       	call   80104ca4 <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 40 c6 10 80 	movl   $0x8010c640,(%esp)
80100265:	e8 02 4b 00 00       	call   80104d6c <acquire>
  b->refcnt--;
8010026a:	8b 45 08             	mov    0x8(%ebp),%eax
8010026d:	8b 40 4c             	mov    0x4c(%eax),%eax
80100270:	8d 50 ff             	lea    -0x1(%eax),%edx
80100273:	8b 45 08             	mov    0x8(%ebp),%eax
80100276:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
80100279:	8b 45 08             	mov    0x8(%ebp),%eax
8010027c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010027f:	85 c0                	test   %eax,%eax
80100281:	75 47                	jne    801002ca <brelse+0x9e>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100283:	8b 45 08             	mov    0x8(%ebp),%eax
80100286:	8b 40 54             	mov    0x54(%eax),%eax
80100289:	8b 55 08             	mov    0x8(%ebp),%edx
8010028c:	8b 52 50             	mov    0x50(%edx),%edx
8010028f:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	8b 40 50             	mov    0x50(%eax),%eax
80100298:	8b 55 08             	mov    0x8(%ebp),%edx
8010029b:	8b 52 54             	mov    0x54(%edx),%edx
8010029e:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801002a1:	8b 15 90 0d 11 80    	mov    0x80110d90,%edx
801002a7:	8b 45 08             	mov    0x8(%ebp),%eax
801002aa:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002ad:	8b 45 08             	mov    0x8(%ebp),%eax
801002b0:	c7 40 50 3c 0d 11 80 	movl   $0x80110d3c,0x50(%eax)
    bcache.head.next->prev = b;
801002b7:	a1 90 0d 11 80       	mov    0x80110d90,%eax
801002bc:	8b 55 08             	mov    0x8(%ebp),%edx
801002bf:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801002c2:	8b 45 08             	mov    0x8(%ebp),%eax
801002c5:	a3 90 0d 11 80       	mov    %eax,0x80110d90
  }
  
  release(&bcache.lock);
801002ca:	c7 04 24 40 c6 10 80 	movl   $0x8010c640,(%esp)
801002d1:	e8 fe 4a 00 00       	call   80104dd4 <release>
}
801002d6:	c9                   	leave  
801002d7:	c3                   	ret    

801002d8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d8:	55                   	push   %ebp
801002d9:	89 e5                	mov    %esp,%ebp
801002db:	83 ec 14             	sub    $0x14,%esp
801002de:	8b 45 08             	mov    0x8(%ebp),%eax
801002e1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e5:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e9:	89 c2                	mov    %eax,%edx
801002eb:	ec                   	in     (%dx),%al
801002ec:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002ef:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002f3:	c9                   	leave  
801002f4:	c3                   	ret    

801002f5 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f5:	55                   	push   %ebp
801002f6:	89 e5                	mov    %esp,%ebp
801002f8:	83 ec 08             	sub    $0x8,%esp
801002fb:	8b 55 08             	mov    0x8(%ebp),%edx
801002fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80100301:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100305:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100308:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010030c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80100310:	ee                   	out    %al,(%dx)
}
80100311:	c9                   	leave  
80100312:	c3                   	ret    

80100313 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100313:	55                   	push   %ebp
80100314:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100316:	fa                   	cli    
}
80100317:	5d                   	pop    %ebp
80100318:	c3                   	ret    

80100319 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100319:	55                   	push   %ebp
8010031a:	89 e5                	mov    %esp,%ebp
8010031c:	56                   	push   %esi
8010031d:	53                   	push   %ebx
8010031e:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100321:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100325:	74 1c                	je     80100343 <printint+0x2a>
80100327:	8b 45 08             	mov    0x8(%ebp),%eax
8010032a:	c1 e8 1f             	shr    $0x1f,%eax
8010032d:	0f b6 c0             	movzbl %al,%eax
80100330:	89 45 10             	mov    %eax,0x10(%ebp)
80100333:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100337:	74 0a                	je     80100343 <printint+0x2a>
    x = -xx;
80100339:	8b 45 08             	mov    0x8(%ebp),%eax
8010033c:	f7 d8                	neg    %eax
8010033e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100341:	eb 06                	jmp    80100349 <printint+0x30>
  else
    x = xx;
80100343:	8b 45 08             	mov    0x8(%ebp),%eax
80100346:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100349:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100350:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100353:	8d 41 01             	lea    0x1(%ecx),%eax
80100356:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100359:	8b 5d 0c             	mov    0xc(%ebp),%ebx
8010035c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035f:	ba 00 00 00 00       	mov    $0x0,%edx
80100364:	f7 f3                	div    %ebx
80100366:	89 d0                	mov    %edx,%eax
80100368:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
8010036f:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100373:	8b 75 0c             	mov    0xc(%ebp),%esi
80100376:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100379:	ba 00 00 00 00       	mov    $0x0,%edx
8010037e:	f7 f6                	div    %esi
80100380:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100383:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100387:	75 c7                	jne    80100350 <printint+0x37>

  if(sign)
80100389:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038d:	74 10                	je     8010039f <printint+0x86>
    buf[i++] = '-';
8010038f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100392:	8d 50 01             	lea    0x1(%eax),%edx
80100395:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100398:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039d:	eb 18                	jmp    801003b7 <printint+0x9e>
8010039f:	eb 16                	jmp    801003b7 <printint+0x9e>
    consputc(buf[i]);
801003a1:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a7:	01 d0                	add    %edx,%eax
801003a9:	0f b6 00             	movzbl (%eax),%eax
801003ac:	0f be c0             	movsbl %al,%eax
801003af:	89 04 24             	mov    %eax,(%esp)
801003b2:	e8 d5 03 00 00       	call   8010078c <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003bf:	79 e0                	jns    801003a1 <printint+0x88>
    consputc(buf[i]);
}
801003c1:	83 c4 30             	add    $0x30,%esp
801003c4:	5b                   	pop    %ebx
801003c5:	5e                   	pop    %esi
801003c6:	5d                   	pop    %ebp
801003c7:	c3                   	ret    

801003c8 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c8:	55                   	push   %ebp
801003c9:	89 e5                	mov    %esp,%ebp
801003cb:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003ce:	a1 d4 b5 10 80       	mov    0x8010b5d4,%eax
801003d3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003da:	74 0c                	je     801003e8 <cprintf+0x20>
    acquire(&cons.lock);
801003dc:	c7 04 24 a0 b5 10 80 	movl   $0x8010b5a0,(%esp)
801003e3:	e8 84 49 00 00       	call   80104d6c <acquire>

  if (fmt == 0)
801003e8:	8b 45 08             	mov    0x8(%ebp),%eax
801003eb:	85 c0                	test   %eax,%eax
801003ed:	75 0c                	jne    801003fb <cprintf+0x33>
    panic("null fmt");
801003ef:	c7 04 24 4d 84 10 80 	movl   $0x8010844d,(%esp)
801003f6:	e8 67 01 00 00       	call   80100562 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fb:	8d 45 0c             	lea    0xc(%ebp),%eax
801003fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100401:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100408:	e9 21 01 00 00       	jmp    8010052e <cprintf+0x166>
    if(c != '%'){
8010040d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100411:	74 10                	je     80100423 <cprintf+0x5b>
      consputc(c);
80100413:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100416:	89 04 24             	mov    %eax,(%esp)
80100419:	e8 6e 03 00 00       	call   8010078c <consputc>
      continue;
8010041e:	e9 07 01 00 00       	jmp    8010052a <cprintf+0x162>
    }
    c = fmt[++i] & 0xff;
80100423:	8b 55 08             	mov    0x8(%ebp),%edx
80100426:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010042a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010042d:	01 d0                	add    %edx,%eax
8010042f:	0f b6 00             	movzbl (%eax),%eax
80100432:	0f be c0             	movsbl %al,%eax
80100435:	25 ff 00 00 00       	and    $0xff,%eax
8010043a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
8010043d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100441:	75 05                	jne    80100448 <cprintf+0x80>
      break;
80100443:	e9 06 01 00 00       	jmp    8010054e <cprintf+0x186>
    switch(c){
80100448:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010044b:	83 f8 70             	cmp    $0x70,%eax
8010044e:	74 4f                	je     8010049f <cprintf+0xd7>
80100450:	83 f8 70             	cmp    $0x70,%eax
80100453:	7f 13                	jg     80100468 <cprintf+0xa0>
80100455:	83 f8 25             	cmp    $0x25,%eax
80100458:	0f 84 a6 00 00 00    	je     80100504 <cprintf+0x13c>
8010045e:	83 f8 64             	cmp    $0x64,%eax
80100461:	74 14                	je     80100477 <cprintf+0xaf>
80100463:	e9 aa 00 00 00       	jmp    80100512 <cprintf+0x14a>
80100468:	83 f8 73             	cmp    $0x73,%eax
8010046b:	74 57                	je     801004c4 <cprintf+0xfc>
8010046d:	83 f8 78             	cmp    $0x78,%eax
80100470:	74 2d                	je     8010049f <cprintf+0xd7>
80100472:	e9 9b 00 00 00       	jmp    80100512 <cprintf+0x14a>
    case 'd':
      printint(*argp++, 10, 1);
80100477:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047a:	8d 50 04             	lea    0x4(%eax),%edx
8010047d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100480:	8b 00                	mov    (%eax),%eax
80100482:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100489:	00 
8010048a:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100491:	00 
80100492:	89 04 24             	mov    %eax,(%esp)
80100495:	e8 7f fe ff ff       	call   80100319 <printint>
      break;
8010049a:	e9 8b 00 00 00       	jmp    8010052a <cprintf+0x162>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010049f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004a2:	8d 50 04             	lea    0x4(%eax),%edx
801004a5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a8:	8b 00                	mov    (%eax),%eax
801004aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801004b1:	00 
801004b2:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801004b9:	00 
801004ba:	89 04 24             	mov    %eax,(%esp)
801004bd:	e8 57 fe ff ff       	call   80100319 <printint>
      break;
801004c2:	eb 66                	jmp    8010052a <cprintf+0x162>
    case 's':
      if((s = (char*)*argp++) == 0)
801004c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004c7:	8d 50 04             	lea    0x4(%eax),%edx
801004ca:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004cd:	8b 00                	mov    (%eax),%eax
801004cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004d2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004d6:	75 09                	jne    801004e1 <cprintf+0x119>
        s = "(null)";
801004d8:	c7 45 ec 56 84 10 80 	movl   $0x80108456,-0x14(%ebp)
      for(; *s; s++)
801004df:	eb 17                	jmp    801004f8 <cprintf+0x130>
801004e1:	eb 15                	jmp    801004f8 <cprintf+0x130>
        consputc(*s);
801004e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004e6:	0f b6 00             	movzbl (%eax),%eax
801004e9:	0f be c0             	movsbl %al,%eax
801004ec:	89 04 24             	mov    %eax,(%esp)
801004ef:	e8 98 02 00 00       	call   8010078c <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004f4:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004fb:	0f b6 00             	movzbl (%eax),%eax
801004fe:	84 c0                	test   %al,%al
80100500:	75 e1                	jne    801004e3 <cprintf+0x11b>
        consputc(*s);
      break;
80100502:	eb 26                	jmp    8010052a <cprintf+0x162>
    case '%':
      consputc('%');
80100504:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
8010050b:	e8 7c 02 00 00       	call   8010078c <consputc>
      break;
80100510:	eb 18                	jmp    8010052a <cprintf+0x162>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100512:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
80100519:	e8 6e 02 00 00       	call   8010078c <consputc>
      consputc(c);
8010051e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100521:	89 04 24             	mov    %eax,(%esp)
80100524:	e8 63 02 00 00       	call   8010078c <consputc>
      break;
80100529:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010052a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010052e:	8b 55 08             	mov    0x8(%ebp),%edx
80100531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100534:	01 d0                	add    %edx,%eax
80100536:	0f b6 00             	movzbl (%eax),%eax
80100539:	0f be c0             	movsbl %al,%eax
8010053c:	25 ff 00 00 00       	and    $0xff,%eax
80100541:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100544:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100548:	0f 85 bf fe ff ff    	jne    8010040d <cprintf+0x45>
      consputc(c);
      break;
    }
  }

  if(locking)
8010054e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100552:	74 0c                	je     80100560 <cprintf+0x198>
    release(&cons.lock);
80100554:	c7 04 24 a0 b5 10 80 	movl   $0x8010b5a0,(%esp)
8010055b:	e8 74 48 00 00       	call   80104dd4 <release>
}
80100560:	c9                   	leave  
80100561:	c3                   	ret    

80100562 <panic>:

void
panic(char *s)
{
80100562:	55                   	push   %ebp
80100563:	89 e5                	mov    %esp,%ebp
80100565:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];

  cli();
80100568:	e8 a6 fd ff ff       	call   80100313 <cli>
  cons.locking = 0;
8010056d:	c7 05 d4 b5 10 80 00 	movl   $0x0,0x8010b5d4
80100574:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
80100577:	e8 96 29 00 00       	call   80102f12 <lapicid>
8010057c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100580:	c7 04 24 5d 84 10 80 	movl   $0x8010845d,(%esp)
80100587:	e8 3c fe ff ff       	call   801003c8 <cprintf>
  cprintf(s);
8010058c:	8b 45 08             	mov    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 31 fe ff ff       	call   801003c8 <cprintf>
  cprintf("\n");
80100597:	c7 04 24 71 84 10 80 	movl   $0x80108471,(%esp)
8010059e:	e8 25 fe ff ff       	call   801003c8 <cprintf>
  getcallerpcs(&s, pcs);
801005a3:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801005aa:	8d 45 08             	lea    0x8(%ebp),%eax
801005ad:	89 04 24             	mov    %eax,(%esp)
801005b0:	e8 6a 48 00 00       	call   80104e1f <getcallerpcs>
  for(i=0; i<10; i++)
801005b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005bc:	eb 1b                	jmp    801005d9 <panic+0x77>
    cprintf(" %p", pcs[i]);
801005be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005c1:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801005c9:	c7 04 24 73 84 10 80 	movl   $0x80108473,(%esp)
801005d0:	e8 f3 fd ff ff       	call   801003c8 <cprintf>
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005d5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005d9:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005dd:	7e df                	jle    801005be <panic+0x5c>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005df:	c7 05 80 b5 10 80 01 	movl   $0x1,0x8010b580
801005e6:	00 00 00 
  for(;;)
    ;
801005e9:	eb fe                	jmp    801005e9 <panic+0x87>

801005eb <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005eb:	55                   	push   %ebp
801005ec:	89 e5                	mov    %esp,%ebp
801005ee:	83 ec 28             	sub    $0x28,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005f1:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005f8:	00 
801005f9:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100600:	e8 f0 fc ff ff       	call   801002f5 <outb>
  pos = inb(CRTPORT+1) << 8;
80100605:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010060c:	e8 c7 fc ff ff       	call   801002d8 <inb>
80100611:	0f b6 c0             	movzbl %al,%eax
80100614:	c1 e0 08             	shl    $0x8,%eax
80100617:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010061a:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100621:	00 
80100622:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100629:	e8 c7 fc ff ff       	call   801002f5 <outb>
  pos |= inb(CRTPORT+1);
8010062e:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100635:	e8 9e fc ff ff       	call   801002d8 <inb>
8010063a:	0f b6 c0             	movzbl %al,%eax
8010063d:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100640:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100644:	75 30                	jne    80100676 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100646:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100649:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010064e:	89 c8                	mov    %ecx,%eax
80100650:	f7 ea                	imul   %edx
80100652:	c1 fa 05             	sar    $0x5,%edx
80100655:	89 c8                	mov    %ecx,%eax
80100657:	c1 f8 1f             	sar    $0x1f,%eax
8010065a:	29 c2                	sub    %eax,%edx
8010065c:	89 d0                	mov    %edx,%eax
8010065e:	c1 e0 02             	shl    $0x2,%eax
80100661:	01 d0                	add    %edx,%eax
80100663:	c1 e0 04             	shl    $0x4,%eax
80100666:	29 c1                	sub    %eax,%ecx
80100668:	89 ca                	mov    %ecx,%edx
8010066a:	b8 50 00 00 00       	mov    $0x50,%eax
8010066f:	29 d0                	sub    %edx,%eax
80100671:	01 45 f4             	add    %eax,-0xc(%ebp)
80100674:	eb 35                	jmp    801006ab <cgaputc+0xc0>
  else if(c == BACKSPACE){
80100676:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010067d:	75 0c                	jne    8010068b <cgaputc+0xa0>
    if(pos > 0) --pos;
8010067f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100683:	7e 26                	jle    801006ab <cgaputc+0xc0>
80100685:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100689:	eb 20                	jmp    801006ab <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010068b:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
80100691:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100694:	8d 50 01             	lea    0x1(%eax),%edx
80100697:	89 55 f4             	mov    %edx,-0xc(%ebp)
8010069a:	01 c0                	add    %eax,%eax
8010069c:	8d 14 01             	lea    (%ecx,%eax,1),%edx
8010069f:	8b 45 08             	mov    0x8(%ebp),%eax
801006a2:	0f b6 c0             	movzbl %al,%eax
801006a5:	80 cc 07             	or     $0x7,%ah
801006a8:	66 89 02             	mov    %ax,(%edx)

  if(pos < 0 || pos > 25*80)
801006ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006af:	78 09                	js     801006ba <cgaputc+0xcf>
801006b1:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
801006b8:	7e 0c                	jle    801006c6 <cgaputc+0xdb>
    panic("pos under/overflow");
801006ba:	c7 04 24 77 84 10 80 	movl   $0x80108477,(%esp)
801006c1:	e8 9c fe ff ff       	call   80100562 <panic>

  if((pos/80) >= 24){  // Scroll up.
801006c6:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006cd:	7e 53                	jle    80100722 <cgaputc+0x137>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006cf:	a1 00 90 10 80       	mov    0x80109000,%eax
801006d4:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006da:	a1 00 90 10 80       	mov    0x80109000,%eax
801006df:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006e6:	00 
801006e7:	89 54 24 04          	mov    %edx,0x4(%esp)
801006eb:	89 04 24             	mov    %eax,(%esp)
801006ee:	e8 aa 49 00 00       	call   8010509d <memmove>
    pos -= 80;
801006f3:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006f7:	b8 80 07 00 00       	mov    $0x780,%eax
801006fc:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006ff:	8d 14 00             	lea    (%eax,%eax,1),%edx
80100702:	a1 00 90 10 80       	mov    0x80109000,%eax
80100707:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010070a:	01 c9                	add    %ecx,%ecx
8010070c:	01 c8                	add    %ecx,%eax
8010070e:	89 54 24 08          	mov    %edx,0x8(%esp)
80100712:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100719:	00 
8010071a:	89 04 24             	mov    %eax,(%esp)
8010071d:	e8 ac 48 00 00       	call   80104fce <memset>
  }

  outb(CRTPORT, 14);
80100722:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
80100729:	00 
8010072a:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100731:	e8 bf fb ff ff       	call   801002f5 <outb>
  outb(CRTPORT+1, pos>>8);
80100736:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100739:	c1 f8 08             	sar    $0x8,%eax
8010073c:	0f b6 c0             	movzbl %al,%eax
8010073f:	89 44 24 04          	mov    %eax,0x4(%esp)
80100743:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010074a:	e8 a6 fb ff ff       	call   801002f5 <outb>
  outb(CRTPORT, 15);
8010074f:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100756:	00 
80100757:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010075e:	e8 92 fb ff ff       	call   801002f5 <outb>
  outb(CRTPORT+1, pos);
80100763:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100766:	0f b6 c0             	movzbl %al,%eax
80100769:	89 44 24 04          	mov    %eax,0x4(%esp)
8010076d:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100774:	e8 7c fb ff ff       	call   801002f5 <outb>
  crt[pos] = ' ' | 0x0700;
80100779:	a1 00 90 10 80       	mov    0x80109000,%eax
8010077e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100781:	01 d2                	add    %edx,%edx
80100783:	01 d0                	add    %edx,%eax
80100785:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010078a:	c9                   	leave  
8010078b:	c3                   	ret    

8010078c <consputc>:

void
consputc(int c)
{
8010078c:	55                   	push   %ebp
8010078d:	89 e5                	mov    %esp,%ebp
8010078f:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100792:	a1 80 b5 10 80       	mov    0x8010b580,%eax
80100797:	85 c0                	test   %eax,%eax
80100799:	74 07                	je     801007a2 <consputc+0x16>
    cli();
8010079b:	e8 73 fb ff ff       	call   80100313 <cli>
    for(;;)
      ;
801007a0:	eb fe                	jmp    801007a0 <consputc+0x14>
  }

  if(c == BACKSPACE){
801007a2:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007a9:	75 26                	jne    801007d1 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007ab:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007b2:	e8 31 62 00 00       	call   801069e8 <uartputc>
801007b7:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801007be:	e8 25 62 00 00       	call   801069e8 <uartputc>
801007c3:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007ca:	e8 19 62 00 00       	call   801069e8 <uartputc>
801007cf:	eb 0b                	jmp    801007dc <consputc+0x50>
  } else
    uartputc(c);
801007d1:	8b 45 08             	mov    0x8(%ebp),%eax
801007d4:	89 04 24             	mov    %eax,(%esp)
801007d7:	e8 0c 62 00 00       	call   801069e8 <uartputc>
  cgaputc(c);
801007dc:	8b 45 08             	mov    0x8(%ebp),%eax
801007df:	89 04 24             	mov    %eax,(%esp)
801007e2:	e8 04 fe ff ff       	call   801005eb <cgaputc>
}
801007e7:	c9                   	leave  
801007e8:	c3                   	ret    

801007e9 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007e9:	55                   	push   %ebp
801007ea:	89 e5                	mov    %esp,%ebp
801007ec:	83 ec 28             	sub    $0x28,%esp
  int c, doprocdump = 0;
801007ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007f6:	c7 04 24 a0 b5 10 80 	movl   $0x8010b5a0,(%esp)
801007fd:	e8 6a 45 00 00       	call   80104d6c <acquire>
  while((c = getc()) >= 0){
80100802:	e9 39 01 00 00       	jmp    80100940 <consoleintr+0x157>
    switch(c){
80100807:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010080a:	83 f8 10             	cmp    $0x10,%eax
8010080d:	74 1e                	je     8010082d <consoleintr+0x44>
8010080f:	83 f8 10             	cmp    $0x10,%eax
80100812:	7f 0a                	jg     8010081e <consoleintr+0x35>
80100814:	83 f8 08             	cmp    $0x8,%eax
80100817:	74 66                	je     8010087f <consoleintr+0x96>
80100819:	e9 93 00 00 00       	jmp    801008b1 <consoleintr+0xc8>
8010081e:	83 f8 15             	cmp    $0x15,%eax
80100821:	74 31                	je     80100854 <consoleintr+0x6b>
80100823:	83 f8 7f             	cmp    $0x7f,%eax
80100826:	74 57                	je     8010087f <consoleintr+0x96>
80100828:	e9 84 00 00 00       	jmp    801008b1 <consoleintr+0xc8>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010082d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100834:	e9 07 01 00 00       	jmp    80100940 <consoleintr+0x157>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100839:	a1 28 10 11 80       	mov    0x80111028,%eax
8010083e:	83 e8 01             	sub    $0x1,%eax
80100841:	a3 28 10 11 80       	mov    %eax,0x80111028
        consputc(BACKSPACE);
80100846:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010084d:	e8 3a ff ff ff       	call   8010078c <consputc>
80100852:	eb 01                	jmp    80100855 <consoleintr+0x6c>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100854:	90                   	nop
80100855:	8b 15 28 10 11 80    	mov    0x80111028,%edx
8010085b:	a1 24 10 11 80       	mov    0x80111024,%eax
80100860:	39 c2                	cmp    %eax,%edx
80100862:	74 16                	je     8010087a <consoleintr+0x91>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100864:	a1 28 10 11 80       	mov    0x80111028,%eax
80100869:	83 e8 01             	sub    $0x1,%eax
8010086c:	83 e0 7f             	and    $0x7f,%eax
8010086f:	0f b6 80 a0 0f 11 80 	movzbl -0x7feef060(%eax),%eax
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100876:	3c 0a                	cmp    $0xa,%al
80100878:	75 bf                	jne    80100839 <consoleintr+0x50>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
8010087a:	e9 c1 00 00 00       	jmp    80100940 <consoleintr+0x157>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010087f:	8b 15 28 10 11 80    	mov    0x80111028,%edx
80100885:	a1 24 10 11 80       	mov    0x80111024,%eax
8010088a:	39 c2                	cmp    %eax,%edx
8010088c:	74 1e                	je     801008ac <consoleintr+0xc3>
        input.e--;
8010088e:	a1 28 10 11 80       	mov    0x80111028,%eax
80100893:	83 e8 01             	sub    $0x1,%eax
80100896:	a3 28 10 11 80       	mov    %eax,0x80111028
        consputc(BACKSPACE);
8010089b:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
801008a2:	e8 e5 fe ff ff       	call   8010078c <consputc>
      }
      break;
801008a7:	e9 94 00 00 00       	jmp    80100940 <consoleintr+0x157>
801008ac:	e9 8f 00 00 00       	jmp    80100940 <consoleintr+0x157>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008b5:	0f 84 84 00 00 00    	je     8010093f <consoleintr+0x156>
801008bb:	8b 15 28 10 11 80    	mov    0x80111028,%edx
801008c1:	a1 20 10 11 80       	mov    0x80111020,%eax
801008c6:	29 c2                	sub    %eax,%edx
801008c8:	89 d0                	mov    %edx,%eax
801008ca:	83 f8 7f             	cmp    $0x7f,%eax
801008cd:	77 70                	ja     8010093f <consoleintr+0x156>
        c = (c == '\r') ? '\n' : c;
801008cf:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008d3:	74 05                	je     801008da <consoleintr+0xf1>
801008d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008d8:	eb 05                	jmp    801008df <consoleintr+0xf6>
801008da:	b8 0a 00 00 00       	mov    $0xa,%eax
801008df:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008e2:	a1 28 10 11 80       	mov    0x80111028,%eax
801008e7:	8d 50 01             	lea    0x1(%eax),%edx
801008ea:	89 15 28 10 11 80    	mov    %edx,0x80111028
801008f0:	83 e0 7f             	and    $0x7f,%eax
801008f3:	89 c2                	mov    %eax,%edx
801008f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008f8:	88 82 a0 0f 11 80    	mov    %al,-0x7feef060(%edx)
        consputc(c);
801008fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100901:	89 04 24             	mov    %eax,(%esp)
80100904:	e8 83 fe ff ff       	call   8010078c <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100909:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010090d:	74 18                	je     80100927 <consoleintr+0x13e>
8010090f:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100913:	74 12                	je     80100927 <consoleintr+0x13e>
80100915:	a1 28 10 11 80       	mov    0x80111028,%eax
8010091a:	8b 15 20 10 11 80    	mov    0x80111020,%edx
80100920:	83 ea 80             	sub    $0xffffff80,%edx
80100923:	39 d0                	cmp    %edx,%eax
80100925:	75 18                	jne    8010093f <consoleintr+0x156>
          input.w = input.e;
80100927:	a1 28 10 11 80       	mov    0x80111028,%eax
8010092c:	a3 24 10 11 80       	mov    %eax,0x80111024
          wakeup(&input.r);
80100931:	c7 04 24 20 10 11 80 	movl   $0x80111020,(%esp)
80100938:	e8 38 41 00 00       	call   80104a75 <wakeup>
        }
      }
      break;
8010093d:	eb 00                	jmp    8010093f <consoleintr+0x156>
8010093f:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
80100940:	8b 45 08             	mov    0x8(%ebp),%eax
80100943:	ff d0                	call   *%eax
80100945:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100948:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010094c:	0f 89 b5 fe ff ff    	jns    80100807 <consoleintr+0x1e>
        }
      }
      break;
    }
  }
  release(&cons.lock);
80100952:	c7 04 24 a0 b5 10 80 	movl   $0x8010b5a0,(%esp)
80100959:	e8 76 44 00 00       	call   80104dd4 <release>
  if(doprocdump) {
8010095e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100962:	74 05                	je     80100969 <consoleintr+0x180>
    procdump();  // now call procdump() wo. cons.lock held
80100964:	e8 af 41 00 00       	call   80104b18 <procdump>
  }
}
80100969:	c9                   	leave  
8010096a:	c3                   	ret    

8010096b <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010096b:	55                   	push   %ebp
8010096c:	89 e5                	mov    %esp,%ebp
8010096e:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100971:	8b 45 08             	mov    0x8(%ebp),%eax
80100974:	89 04 24             	mov    %eax,(%esp)
80100977:	e8 d1 10 00 00       	call   80101a4d <iunlock>
  target = n;
8010097c:	8b 45 10             	mov    0x10(%ebp),%eax
8010097f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100982:	c7 04 24 a0 b5 10 80 	movl   $0x8010b5a0,(%esp)
80100989:	e8 de 43 00 00       	call   80104d6c <acquire>
  while(n > 0){
8010098e:	e9 a9 00 00 00       	jmp    80100a3c <consoleread+0xd1>
    while(input.r == input.w){
80100993:	eb 41                	jmp    801009d6 <consoleread+0x6b>
      if(myproc()->killed){
80100995:	e8 af 37 00 00       	call   80104149 <myproc>
8010099a:	8b 40 28             	mov    0x28(%eax),%eax
8010099d:	85 c0                	test   %eax,%eax
8010099f:	74 21                	je     801009c2 <consoleread+0x57>
        release(&cons.lock);
801009a1:	c7 04 24 a0 b5 10 80 	movl   $0x8010b5a0,(%esp)
801009a8:	e8 27 44 00 00       	call   80104dd4 <release>
        ilock(ip);
801009ad:	8b 45 08             	mov    0x8(%ebp),%eax
801009b0:	89 04 24             	mov    %eax,(%esp)
801009b3:	e8 88 0f 00 00       	call   80101940 <ilock>
        return -1;
801009b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009bd:	e9 a5 00 00 00       	jmp    80100a67 <consoleread+0xfc>
      }
      sleep(&input.r, &cons.lock);
801009c2:	c7 44 24 04 a0 b5 10 	movl   $0x8010b5a0,0x4(%esp)
801009c9:	80 
801009ca:	c7 04 24 20 10 11 80 	movl   $0x80111020,(%esp)
801009d1:	e8 cb 3f 00 00       	call   801049a1 <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
801009d6:	8b 15 20 10 11 80    	mov    0x80111020,%edx
801009dc:	a1 24 10 11 80       	mov    0x80111024,%eax
801009e1:	39 c2                	cmp    %eax,%edx
801009e3:	74 b0                	je     80100995 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009e5:	a1 20 10 11 80       	mov    0x80111020,%eax
801009ea:	8d 50 01             	lea    0x1(%eax),%edx
801009ed:	89 15 20 10 11 80    	mov    %edx,0x80111020
801009f3:	83 e0 7f             	and    $0x7f,%eax
801009f6:	0f b6 80 a0 0f 11 80 	movzbl -0x7feef060(%eax),%eax
801009fd:	0f be c0             	movsbl %al,%eax
80100a00:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a03:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a07:	75 19                	jne    80100a22 <consoleread+0xb7>
      if(n < target){
80100a09:	8b 45 10             	mov    0x10(%ebp),%eax
80100a0c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a0f:	73 0f                	jae    80100a20 <consoleread+0xb5>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a11:	a1 20 10 11 80       	mov    0x80111020,%eax
80100a16:	83 e8 01             	sub    $0x1,%eax
80100a19:	a3 20 10 11 80       	mov    %eax,0x80111020
      }
      break;
80100a1e:	eb 26                	jmp    80100a46 <consoleread+0xdb>
80100a20:	eb 24                	jmp    80100a46 <consoleread+0xdb>
    }
    *dst++ = c;
80100a22:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a25:	8d 50 01             	lea    0x1(%eax),%edx
80100a28:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a2b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a2e:	88 10                	mov    %dl,(%eax)
    --n;
80100a30:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a34:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a38:	75 02                	jne    80100a3c <consoleread+0xd1>
      break;
80100a3a:	eb 0a                	jmp    80100a46 <consoleread+0xdb>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100a3c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a40:	0f 8f 4d ff ff ff    	jg     80100993 <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&cons.lock);
80100a46:	c7 04 24 a0 b5 10 80 	movl   $0x8010b5a0,(%esp)
80100a4d:	e8 82 43 00 00       	call   80104dd4 <release>
  ilock(ip);
80100a52:	8b 45 08             	mov    0x8(%ebp),%eax
80100a55:	89 04 24             	mov    %eax,(%esp)
80100a58:	e8 e3 0e 00 00       	call   80101940 <ilock>

  return target - n;
80100a5d:	8b 45 10             	mov    0x10(%ebp),%eax
80100a60:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a63:	29 c2                	sub    %eax,%edx
80100a65:	89 d0                	mov    %edx,%eax
}
80100a67:	c9                   	leave  
80100a68:	c3                   	ret    

80100a69 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a69:	55                   	push   %ebp
80100a6a:	89 e5                	mov    %esp,%ebp
80100a6c:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100a6f:	8b 45 08             	mov    0x8(%ebp),%eax
80100a72:	89 04 24             	mov    %eax,(%esp)
80100a75:	e8 d3 0f 00 00       	call   80101a4d <iunlock>
  acquire(&cons.lock);
80100a7a:	c7 04 24 a0 b5 10 80 	movl   $0x8010b5a0,(%esp)
80100a81:	e8 e6 42 00 00       	call   80104d6c <acquire>
  for(i = 0; i < n; i++)
80100a86:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a8d:	eb 1d                	jmp    80100aac <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100a8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a92:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a95:	01 d0                	add    %edx,%eax
80100a97:	0f b6 00             	movzbl (%eax),%eax
80100a9a:	0f be c0             	movsbl %al,%eax
80100a9d:	0f b6 c0             	movzbl %al,%eax
80100aa0:	89 04 24             	mov    %eax,(%esp)
80100aa3:	e8 e4 fc ff ff       	call   8010078c <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100aa8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100aaf:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ab2:	7c db                	jl     80100a8f <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100ab4:	c7 04 24 a0 b5 10 80 	movl   $0x8010b5a0,(%esp)
80100abb:	e8 14 43 00 00       	call   80104dd4 <release>
  ilock(ip);
80100ac0:	8b 45 08             	mov    0x8(%ebp),%eax
80100ac3:	89 04 24             	mov    %eax,(%esp)
80100ac6:	e8 75 0e 00 00       	call   80101940 <ilock>

  return n;
80100acb:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100ace:	c9                   	leave  
80100acf:	c3                   	ret    

80100ad0 <consoleinit>:

void
consoleinit(void)
{
80100ad0:	55                   	push   %ebp
80100ad1:	89 e5                	mov    %esp,%ebp
80100ad3:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100ad6:	c7 44 24 04 8a 84 10 	movl   $0x8010848a,0x4(%esp)
80100add:	80 
80100ade:	c7 04 24 a0 b5 10 80 	movl   $0x8010b5a0,(%esp)
80100ae5:	e8 61 42 00 00       	call   80104d4b <initlock>

  devsw[CONSOLE].write = consolewrite;
80100aea:	c7 05 ec 19 11 80 69 	movl   $0x80100a69,0x801119ec
80100af1:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100af4:	c7 05 e8 19 11 80 6b 	movl   $0x8010096b,0x801119e8
80100afb:	09 10 80 
  cons.locking = 1;
80100afe:	c7 05 d4 b5 10 80 01 	movl   $0x1,0x8010b5d4
80100b05:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b08:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100b0f:	00 
80100b10:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100b17:	e8 06 1f 00 00       	call   80102a22 <ioapicenable>
}
80100b1c:	c9                   	leave  
80100b1d:	c3                   	ret    

80100b1e <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b1e:	55                   	push   %ebp
80100b1f:	89 e5                	mov    %esp,%ebp
80100b21:	81 ec 38 01 00 00    	sub    $0x138,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b27:	e8 1d 36 00 00       	call   80104149 <myproc>
80100b2c:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b2f:	e8 36 29 00 00       	call   8010346a <begin_op>

  if((ip = namei(path)) == 0){
80100b34:	8b 45 08             	mov    0x8(%ebp),%eax
80100b37:	89 04 24             	mov    %eax,(%esp)
80100b3a:	e8 3b 19 00 00       	call   8010247a <namei>
80100b3f:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b42:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b46:	75 1b                	jne    80100b63 <exec+0x45>
    end_op();
80100b48:	e8 a1 29 00 00       	call   801034ee <end_op>
    cprintf("exec: fail\n");
80100b4d:	c7 04 24 92 84 10 80 	movl   $0x80108492,(%esp)
80100b54:	e8 6f f8 ff ff       	call   801003c8 <cprintf>
    return -1;
80100b59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b5e:	e9 e7 03 00 00       	jmp    80100f4a <exec+0x42c>
  }
  ilock(ip);
80100b63:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b66:	89 04 24             	mov    %eax,(%esp)
80100b69:	e8 d2 0d 00 00       	call   80101940 <ilock>
  pgdir = 0;
80100b6e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100b75:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b7c:	00 
80100b7d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b84:	00 
80100b85:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100b8b:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b8f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b92:	89 04 24             	mov    %eax,(%esp)
80100b95:	e8 43 12 00 00       	call   80101ddd <readi>
80100b9a:	83 f8 34             	cmp    $0x34,%eax
80100b9d:	74 05                	je     80100ba4 <exec+0x86>
    goto bad;
80100b9f:	e9 7a 03 00 00       	jmp    80100f1e <exec+0x400>
  if(elf.magic != ELF_MAGIC)
80100ba4:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100baa:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100baf:	74 05                	je     80100bb6 <exec+0x98>
    goto bad;
80100bb1:	e9 68 03 00 00       	jmp    80100f1e <exec+0x400>

  if((pgdir = setupkvm()) == 0)
80100bb6:	e8 2a 6e 00 00       	call   801079e5 <setupkvm>
80100bbb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bbe:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100bc2:	75 05                	jne    80100bc9 <exec+0xab>
    goto bad;
80100bc4:	e9 55 03 00 00       	jmp    80100f1e <exec+0x400>

  // Load program into memory.
  sz = 0;
80100bc9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100bd0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100bd7:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100bdd:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100be0:	e9 fc 00 00 00       	jmp    80100ce1 <exec+0x1c3>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100be5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100be8:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100bef:	00 
80100bf0:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bf4:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100bfa:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bfe:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c01:	89 04 24             	mov    %eax,(%esp)
80100c04:	e8 d4 11 00 00       	call   80101ddd <readi>
80100c09:	83 f8 20             	cmp    $0x20,%eax
80100c0c:	74 05                	je     80100c13 <exec+0xf5>
      goto bad;
80100c0e:	e9 0b 03 00 00       	jmp    80100f1e <exec+0x400>
    if(ph.type != ELF_PROG_LOAD)
80100c13:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c19:	83 f8 01             	cmp    $0x1,%eax
80100c1c:	74 05                	je     80100c23 <exec+0x105>
      continue;
80100c1e:	e9 b1 00 00 00       	jmp    80100cd4 <exec+0x1b6>
    if(ph.memsz < ph.filesz)
80100c23:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c29:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c2f:	39 c2                	cmp    %eax,%edx
80100c31:	73 05                	jae    80100c38 <exec+0x11a>
      goto bad;
80100c33:	e9 e6 02 00 00       	jmp    80100f1e <exec+0x400>
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c38:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c3e:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c44:	01 c2                	add    %eax,%edx
80100c46:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c4c:	39 c2                	cmp    %eax,%edx
80100c4e:	73 05                	jae    80100c55 <exec+0x137>
      goto bad;
80100c50:	e9 c9 02 00 00       	jmp    80100f1e <exec+0x400>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c55:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c5b:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c61:	01 d0                	add    %edx,%eax
80100c63:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c67:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c6a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c6e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c71:	89 04 24             	mov    %eax,(%esp)
80100c74:	e8 42 71 00 00       	call   80107dbb <allocuvm>
80100c79:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c7c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c80:	75 05                	jne    80100c87 <exec+0x169>
      goto bad;
80100c82:	e9 97 02 00 00       	jmp    80100f1e <exec+0x400>
    if(ph.vaddr % PGSIZE != 0)
80100c87:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c8d:	25 ff 0f 00 00       	and    $0xfff,%eax
80100c92:	85 c0                	test   %eax,%eax
80100c94:	74 05                	je     80100c9b <exec+0x17d>
      goto bad;
80100c96:	e9 83 02 00 00       	jmp    80100f1e <exec+0x400>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c9b:	8b 8d f8 fe ff ff    	mov    -0x108(%ebp),%ecx
80100ca1:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100ca7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cad:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100cb1:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100cb5:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100cb8:	89 54 24 08          	mov    %edx,0x8(%esp)
80100cbc:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cc0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cc3:	89 04 24             	mov    %eax,(%esp)
80100cc6:	e8 0d 70 00 00       	call   80107cd8 <loaduvm>
80100ccb:	85 c0                	test   %eax,%eax
80100ccd:	79 05                	jns    80100cd4 <exec+0x1b6>
      goto bad;
80100ccf:	e9 4a 02 00 00       	jmp    80100f1e <exec+0x400>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100cd4:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100cd8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cdb:	83 c0 20             	add    $0x20,%eax
80100cde:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100ce1:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100ce8:	0f b7 c0             	movzwl %ax,%eax
80100ceb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100cee:	0f 8f f1 fe ff ff    	jg     80100be5 <exec+0xc7>
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100cf4:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100cf7:	89 04 24             	mov    %eax,(%esp)
80100cfa:	e8 43 0e 00 00       	call   80101b42 <iunlockput>
  end_op();
80100cff:	e8 ea 27 00 00       	call   801034ee <end_op>
  ip = 0;
80100d04:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d0b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d0e:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d13:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d18:	89 45 e0             	mov    %eax,-0x20(%ebp)

  //CS153 -- changed and added
  if((allocuvm(pgdir, STACKTOP-PGSIZE, STACKTOP)) == 0) //changing where the stack is initialized, KERNBASE-1 is where the new stack will start, and below it, allocate one page for the new stack
80100d1b:	c7 44 24 08 ff ff ff 	movl   $0x7fffffff,0x8(%esp)
80100d22:	7f 
80100d23:	c7 44 24 04 ff ef ff 	movl   $0x7fffefff,0x4(%esp)
80100d2a:	7f 
80100d2b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d2e:	89 04 24             	mov    %eax,(%esp)
80100d31:	e8 85 70 00 00       	call   80107dbb <allocuvm>
80100d36:	85 c0                	test   %eax,%eax
80100d38:	75 05                	jne    80100d3f <exec+0x221>
    goto bad;
80100d3a:	e9 df 01 00 00       	jmp    80100f1e <exec+0x400>
  sp = STACKTOP;
80100d3f:	c7 45 dc ff ff ff 7f 	movl   $0x7fffffff,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d46:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d4d:	e9 9a 00 00 00       	jmp    80100dec <exec+0x2ce>
    if(argc >= MAXARG)
80100d52:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d56:	76 05                	jbe    80100d5d <exec+0x23f>
      goto bad;
80100d58:	e9 c1 01 00 00       	jmp    80100f1e <exec+0x400>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d60:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d67:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d6a:	01 d0                	add    %edx,%eax
80100d6c:	8b 00                	mov    (%eax),%eax
80100d6e:	89 04 24             	mov    %eax,(%esp)
80100d71:	e8 c2 44 00 00       	call   80105238 <strlen>
80100d76:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100d79:	29 c2                	sub    %eax,%edx
80100d7b:	89 d0                	mov    %edx,%eax
80100d7d:	83 e8 01             	sub    $0x1,%eax
80100d80:	83 e0 fc             	and    $0xfffffffc,%eax
80100d83:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d89:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d90:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d93:	01 d0                	add    %edx,%eax
80100d95:	8b 00                	mov    (%eax),%eax
80100d97:	89 04 24             	mov    %eax,(%esp)
80100d9a:	e8 99 44 00 00       	call   80105238 <strlen>
80100d9f:	83 c0 01             	add    $0x1,%eax
80100da2:	89 c2                	mov    %eax,%edx
80100da4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100da7:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100dae:	8b 45 0c             	mov    0xc(%ebp),%eax
80100db1:	01 c8                	add    %ecx,%eax
80100db3:	8b 00                	mov    (%eax),%eax
80100db5:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100db9:	89 44 24 08          	mov    %eax,0x8(%esp)
80100dbd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dc0:	89 44 24 04          	mov    %eax,0x4(%esp)
80100dc4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100dc7:	89 04 24             	mov    %eax,(%esp)
80100dca:	e8 05 75 00 00       	call   801082d4 <copyout>
80100dcf:	85 c0                	test   %eax,%eax
80100dd1:	79 05                	jns    80100dd8 <exec+0x2ba>
      goto bad;
80100dd3:	e9 46 01 00 00       	jmp    80100f1e <exec+0x400>
    ustack[3+argc] = sp;
80100dd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ddb:	8d 50 03             	lea    0x3(%eax),%edx
80100dde:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100de1:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  if((allocuvm(pgdir, STACKTOP-PGSIZE, STACKTOP)) == 0) //changing where the stack is initialized, KERNBASE-1 is where the new stack will start, and below it, allocate one page for the new stack
    goto bad;
  sp = STACKTOP;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100de8:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100dec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100def:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100df6:	8b 45 0c             	mov    0xc(%ebp),%eax
80100df9:	01 d0                	add    %edx,%eax
80100dfb:	8b 00                	mov    (%eax),%eax
80100dfd:	85 c0                	test   %eax,%eax
80100dff:	0f 85 4d ff ff ff    	jne    80100d52 <exec+0x234>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100e05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e08:	83 c0 03             	add    $0x3,%eax
80100e0b:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e12:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e16:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e1d:	ff ff ff 
  ustack[1] = argc;
80100e20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e23:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2c:	83 c0 01             	add    $0x1,%eax
80100e2f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e36:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e39:	29 d0                	sub    %edx,%eax
80100e3b:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e44:	83 c0 04             	add    $0x4,%eax
80100e47:	c1 e0 02             	shl    $0x2,%eax
80100e4a:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e50:	83 c0 04             	add    $0x4,%eax
80100e53:	c1 e0 02             	shl    $0x2,%eax
80100e56:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100e5a:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100e60:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e64:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e67:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e6b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e6e:	89 04 24             	mov    %eax,(%esp)
80100e71:	e8 5e 74 00 00       	call   801082d4 <copyout>
80100e76:	85 c0                	test   %eax,%eax
80100e78:	79 05                	jns    80100e7f <exec+0x361>
    goto bad;
80100e7a:	e9 9f 00 00 00       	jmp    80100f1e <exec+0x400>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e7f:	8b 45 08             	mov    0x8(%ebp),%eax
80100e82:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e88:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e8b:	eb 17                	jmp    80100ea4 <exec+0x386>
    if(*s == '/')
80100e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e90:	0f b6 00             	movzbl (%eax),%eax
80100e93:	3c 2f                	cmp    $0x2f,%al
80100e95:	75 09                	jne    80100ea0 <exec+0x382>
      last = s+1;
80100e97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e9a:	83 c0 01             	add    $0x1,%eax
80100e9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ea0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ea4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ea7:	0f b6 00             	movzbl (%eax),%eax
80100eaa:	84 c0                	test   %al,%al
80100eac:	75 df                	jne    80100e8d <exec+0x36f>
    if(*s == '/')
      last = s+1;
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100eae:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100eb1:	8d 50 70             	lea    0x70(%eax),%edx
80100eb4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100ebb:	00 
80100ebc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100ebf:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ec3:	89 14 24             	mov    %edx,(%esp)
80100ec6:	e8 23 43 00 00       	call   801051ee <safestrcpy>

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100ecb:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ece:	8b 40 08             	mov    0x8(%eax),%eax
80100ed1:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100ed4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ed7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100eda:	89 50 08             	mov    %edx,0x8(%eax)
  curproc->sz = sz;
80100edd:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ee0:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100ee3:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->tf->eip = elf.entry;  // main
80100ee6:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ee9:	8b 40 1c             	mov    0x1c(%eax),%eax
80100eec:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100ef2:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100ef5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ef8:	8b 40 1c             	mov    0x1c(%eax),%eax
80100efb:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100efe:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f01:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f04:	89 04 24             	mov    %eax,(%esp)
80100f07:	e8 b3 6b 00 00       	call   80107abf <switchuvm>
  freevm(oldpgdir);
80100f0c:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100f0f:	89 04 24             	mov    %eax,(%esp)
80100f12:	e8 80 70 00 00       	call   80107f97 <freevm>
  return 0;
80100f17:	b8 00 00 00 00       	mov    $0x0,%eax
80100f1c:	eb 2c                	jmp    80100f4a <exec+0x42c>

 bad:
  if(pgdir)
80100f1e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f22:	74 0b                	je     80100f2f <exec+0x411>
    freevm(pgdir);
80100f24:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f27:	89 04 24             	mov    %eax,(%esp)
80100f2a:	e8 68 70 00 00       	call   80107f97 <freevm>
  if(ip){
80100f2f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f33:	74 10                	je     80100f45 <exec+0x427>
    iunlockput(ip);
80100f35:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f38:	89 04 24             	mov    %eax,(%esp)
80100f3b:	e8 02 0c 00 00       	call   80101b42 <iunlockput>
    end_op();
80100f40:	e8 a9 25 00 00       	call   801034ee <end_op>
  }
  return -1;
80100f45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f4a:	c9                   	leave  
80100f4b:	c3                   	ret    

80100f4c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f4c:	55                   	push   %ebp
80100f4d:	89 e5                	mov    %esp,%ebp
80100f4f:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f52:	c7 44 24 04 9e 84 10 	movl   $0x8010849e,0x4(%esp)
80100f59:	80 
80100f5a:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
80100f61:	e8 e5 3d 00 00       	call   80104d4b <initlock>
}
80100f66:	c9                   	leave  
80100f67:	c3                   	ret    

80100f68 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f68:	55                   	push   %ebp
80100f69:	89 e5                	mov    %esp,%ebp
80100f6b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f6e:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
80100f75:	e8 f2 3d 00 00       	call   80104d6c <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f7a:	c7 45 f4 74 10 11 80 	movl   $0x80111074,-0xc(%ebp)
80100f81:	eb 29                	jmp    80100fac <filealloc+0x44>
    if(f->ref == 0){
80100f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f86:	8b 40 04             	mov    0x4(%eax),%eax
80100f89:	85 c0                	test   %eax,%eax
80100f8b:	75 1b                	jne    80100fa8 <filealloc+0x40>
      f->ref = 1;
80100f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f90:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f97:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
80100f9e:	e8 31 3e 00 00       	call   80104dd4 <release>
      return f;
80100fa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fa6:	eb 1e                	jmp    80100fc6 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fa8:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100fac:	81 7d f4 d4 19 11 80 	cmpl   $0x801119d4,-0xc(%ebp)
80100fb3:	72 ce                	jb     80100f83 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100fb5:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
80100fbc:	e8 13 3e 00 00       	call   80104dd4 <release>
  return 0;
80100fc1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100fc6:	c9                   	leave  
80100fc7:	c3                   	ret    

80100fc8 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fc8:	55                   	push   %ebp
80100fc9:	89 e5                	mov    %esp,%ebp
80100fcb:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100fce:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
80100fd5:	e8 92 3d 00 00       	call   80104d6c <acquire>
  if(f->ref < 1)
80100fda:	8b 45 08             	mov    0x8(%ebp),%eax
80100fdd:	8b 40 04             	mov    0x4(%eax),%eax
80100fe0:	85 c0                	test   %eax,%eax
80100fe2:	7f 0c                	jg     80100ff0 <filedup+0x28>
    panic("filedup");
80100fe4:	c7 04 24 a5 84 10 80 	movl   $0x801084a5,(%esp)
80100feb:	e8 72 f5 ff ff       	call   80100562 <panic>
  f->ref++;
80100ff0:	8b 45 08             	mov    0x8(%ebp),%eax
80100ff3:	8b 40 04             	mov    0x4(%eax),%eax
80100ff6:	8d 50 01             	lea    0x1(%eax),%edx
80100ff9:	8b 45 08             	mov    0x8(%ebp),%eax
80100ffc:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fff:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
80101006:	e8 c9 3d 00 00       	call   80104dd4 <release>
  return f;
8010100b:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010100e:	c9                   	leave  
8010100f:	c3                   	ret    

80101010 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101010:	55                   	push   %ebp
80101011:	89 e5                	mov    %esp,%ebp
80101013:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80101016:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
8010101d:	e8 4a 3d 00 00       	call   80104d6c <acquire>
  if(f->ref < 1)
80101022:	8b 45 08             	mov    0x8(%ebp),%eax
80101025:	8b 40 04             	mov    0x4(%eax),%eax
80101028:	85 c0                	test   %eax,%eax
8010102a:	7f 0c                	jg     80101038 <fileclose+0x28>
    panic("fileclose");
8010102c:	c7 04 24 ad 84 10 80 	movl   $0x801084ad,(%esp)
80101033:	e8 2a f5 ff ff       	call   80100562 <panic>
  if(--f->ref > 0){
80101038:	8b 45 08             	mov    0x8(%ebp),%eax
8010103b:	8b 40 04             	mov    0x4(%eax),%eax
8010103e:	8d 50 ff             	lea    -0x1(%eax),%edx
80101041:	8b 45 08             	mov    0x8(%ebp),%eax
80101044:	89 50 04             	mov    %edx,0x4(%eax)
80101047:	8b 45 08             	mov    0x8(%ebp),%eax
8010104a:	8b 40 04             	mov    0x4(%eax),%eax
8010104d:	85 c0                	test   %eax,%eax
8010104f:	7e 11                	jle    80101062 <fileclose+0x52>
    release(&ftable.lock);
80101051:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
80101058:	e8 77 3d 00 00       	call   80104dd4 <release>
8010105d:	e9 82 00 00 00       	jmp    801010e4 <fileclose+0xd4>
    return;
  }
  ff = *f;
80101062:	8b 45 08             	mov    0x8(%ebp),%eax
80101065:	8b 10                	mov    (%eax),%edx
80101067:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010106a:	8b 50 04             	mov    0x4(%eax),%edx
8010106d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101070:	8b 50 08             	mov    0x8(%eax),%edx
80101073:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101076:	8b 50 0c             	mov    0xc(%eax),%edx
80101079:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010107c:	8b 50 10             	mov    0x10(%eax),%edx
8010107f:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101082:	8b 40 14             	mov    0x14(%eax),%eax
80101085:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101088:	8b 45 08             	mov    0x8(%ebp),%eax
8010108b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101092:	8b 45 08             	mov    0x8(%ebp),%eax
80101095:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010109b:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
801010a2:	e8 2d 3d 00 00       	call   80104dd4 <release>

  if(ff.type == FD_PIPE)
801010a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010aa:	83 f8 01             	cmp    $0x1,%eax
801010ad:	75 18                	jne    801010c7 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
801010af:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801010b3:	0f be d0             	movsbl %al,%edx
801010b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801010b9:	89 54 24 04          	mov    %edx,0x4(%esp)
801010bd:	89 04 24             	mov    %eax,(%esp)
801010c0:	e8 4b 2d 00 00       	call   80103e10 <pipeclose>
801010c5:	eb 1d                	jmp    801010e4 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
801010c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010ca:	83 f8 02             	cmp    $0x2,%eax
801010cd:	75 15                	jne    801010e4 <fileclose+0xd4>
    begin_op();
801010cf:	e8 96 23 00 00       	call   8010346a <begin_op>
    iput(ff.ip);
801010d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801010d7:	89 04 24             	mov    %eax,(%esp)
801010da:	e8 b2 09 00 00       	call   80101a91 <iput>
    end_op();
801010df:	e8 0a 24 00 00       	call   801034ee <end_op>
  }
}
801010e4:	c9                   	leave  
801010e5:	c3                   	ret    

801010e6 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010e6:	55                   	push   %ebp
801010e7:	89 e5                	mov    %esp,%ebp
801010e9:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801010ec:	8b 45 08             	mov    0x8(%ebp),%eax
801010ef:	8b 00                	mov    (%eax),%eax
801010f1:	83 f8 02             	cmp    $0x2,%eax
801010f4:	75 38                	jne    8010112e <filestat+0x48>
    ilock(f->ip);
801010f6:	8b 45 08             	mov    0x8(%ebp),%eax
801010f9:	8b 40 10             	mov    0x10(%eax),%eax
801010fc:	89 04 24             	mov    %eax,(%esp)
801010ff:	e8 3c 08 00 00       	call   80101940 <ilock>
    stati(f->ip, st);
80101104:	8b 45 08             	mov    0x8(%ebp),%eax
80101107:	8b 40 10             	mov    0x10(%eax),%eax
8010110a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010110d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101111:	89 04 24             	mov    %eax,(%esp)
80101114:	e8 7f 0c 00 00       	call   80101d98 <stati>
    iunlock(f->ip);
80101119:	8b 45 08             	mov    0x8(%ebp),%eax
8010111c:	8b 40 10             	mov    0x10(%eax),%eax
8010111f:	89 04 24             	mov    %eax,(%esp)
80101122:	e8 26 09 00 00       	call   80101a4d <iunlock>
    return 0;
80101127:	b8 00 00 00 00       	mov    $0x0,%eax
8010112c:	eb 05                	jmp    80101133 <filestat+0x4d>
  }
  return -1;
8010112e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101133:	c9                   	leave  
80101134:	c3                   	ret    

80101135 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101135:	55                   	push   %ebp
80101136:	89 e5                	mov    %esp,%ebp
80101138:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
8010113b:	8b 45 08             	mov    0x8(%ebp),%eax
8010113e:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101142:	84 c0                	test   %al,%al
80101144:	75 0a                	jne    80101150 <fileread+0x1b>
    return -1;
80101146:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010114b:	e9 9f 00 00 00       	jmp    801011ef <fileread+0xba>
  if(f->type == FD_PIPE)
80101150:	8b 45 08             	mov    0x8(%ebp),%eax
80101153:	8b 00                	mov    (%eax),%eax
80101155:	83 f8 01             	cmp    $0x1,%eax
80101158:	75 1e                	jne    80101178 <fileread+0x43>
    return piperead(f->pipe, addr, n);
8010115a:	8b 45 08             	mov    0x8(%ebp),%eax
8010115d:	8b 40 0c             	mov    0xc(%eax),%eax
80101160:	8b 55 10             	mov    0x10(%ebp),%edx
80101163:	89 54 24 08          	mov    %edx,0x8(%esp)
80101167:	8b 55 0c             	mov    0xc(%ebp),%edx
8010116a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010116e:	89 04 24             	mov    %eax,(%esp)
80101171:	e8 1a 2e 00 00       	call   80103f90 <piperead>
80101176:	eb 77                	jmp    801011ef <fileread+0xba>
  if(f->type == FD_INODE){
80101178:	8b 45 08             	mov    0x8(%ebp),%eax
8010117b:	8b 00                	mov    (%eax),%eax
8010117d:	83 f8 02             	cmp    $0x2,%eax
80101180:	75 61                	jne    801011e3 <fileread+0xae>
    ilock(f->ip);
80101182:	8b 45 08             	mov    0x8(%ebp),%eax
80101185:	8b 40 10             	mov    0x10(%eax),%eax
80101188:	89 04 24             	mov    %eax,(%esp)
8010118b:	e8 b0 07 00 00       	call   80101940 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101190:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	8b 50 14             	mov    0x14(%eax),%edx
80101199:	8b 45 08             	mov    0x8(%ebp),%eax
8010119c:	8b 40 10             	mov    0x10(%eax),%eax
8010119f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801011a3:	89 54 24 08          	mov    %edx,0x8(%esp)
801011a7:	8b 55 0c             	mov    0xc(%ebp),%edx
801011aa:	89 54 24 04          	mov    %edx,0x4(%esp)
801011ae:	89 04 24             	mov    %eax,(%esp)
801011b1:	e8 27 0c 00 00       	call   80101ddd <readi>
801011b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801011b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801011bd:	7e 11                	jle    801011d0 <fileread+0x9b>
      f->off += r;
801011bf:	8b 45 08             	mov    0x8(%ebp),%eax
801011c2:	8b 50 14             	mov    0x14(%eax),%edx
801011c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011c8:	01 c2                	add    %eax,%edx
801011ca:	8b 45 08             	mov    0x8(%ebp),%eax
801011cd:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801011d0:	8b 45 08             	mov    0x8(%ebp),%eax
801011d3:	8b 40 10             	mov    0x10(%eax),%eax
801011d6:	89 04 24             	mov    %eax,(%esp)
801011d9:	e8 6f 08 00 00       	call   80101a4d <iunlock>
    return r;
801011de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011e1:	eb 0c                	jmp    801011ef <fileread+0xba>
  }
  panic("fileread");
801011e3:	c7 04 24 b7 84 10 80 	movl   $0x801084b7,(%esp)
801011ea:	e8 73 f3 ff ff       	call   80100562 <panic>
}
801011ef:	c9                   	leave  
801011f0:	c3                   	ret    

801011f1 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011f1:	55                   	push   %ebp
801011f2:	89 e5                	mov    %esp,%ebp
801011f4:	53                   	push   %ebx
801011f5:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011f8:	8b 45 08             	mov    0x8(%ebp),%eax
801011fb:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801011ff:	84 c0                	test   %al,%al
80101201:	75 0a                	jne    8010120d <filewrite+0x1c>
    return -1;
80101203:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101208:	e9 20 01 00 00       	jmp    8010132d <filewrite+0x13c>
  if(f->type == FD_PIPE)
8010120d:	8b 45 08             	mov    0x8(%ebp),%eax
80101210:	8b 00                	mov    (%eax),%eax
80101212:	83 f8 01             	cmp    $0x1,%eax
80101215:	75 21                	jne    80101238 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101217:	8b 45 08             	mov    0x8(%ebp),%eax
8010121a:	8b 40 0c             	mov    0xc(%eax),%eax
8010121d:	8b 55 10             	mov    0x10(%ebp),%edx
80101220:	89 54 24 08          	mov    %edx,0x8(%esp)
80101224:	8b 55 0c             	mov    0xc(%ebp),%edx
80101227:	89 54 24 04          	mov    %edx,0x4(%esp)
8010122b:	89 04 24             	mov    %eax,(%esp)
8010122e:	e8 6f 2c 00 00       	call   80103ea2 <pipewrite>
80101233:	e9 f5 00 00 00       	jmp    8010132d <filewrite+0x13c>
  if(f->type == FD_INODE){
80101238:	8b 45 08             	mov    0x8(%ebp),%eax
8010123b:	8b 00                	mov    (%eax),%eax
8010123d:	83 f8 02             	cmp    $0x2,%eax
80101240:	0f 85 db 00 00 00    	jne    80101321 <filewrite+0x130>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101246:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
8010124d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101254:	e9 a8 00 00 00       	jmp    80101301 <filewrite+0x110>
      int n1 = n - i;
80101259:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010125c:	8b 55 10             	mov    0x10(%ebp),%edx
8010125f:	29 c2                	sub    %eax,%edx
80101261:	89 d0                	mov    %edx,%eax
80101263:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101266:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101269:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010126c:	7e 06                	jle    80101274 <filewrite+0x83>
        n1 = max;
8010126e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101271:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101274:	e8 f1 21 00 00       	call   8010346a <begin_op>
      ilock(f->ip);
80101279:	8b 45 08             	mov    0x8(%ebp),%eax
8010127c:	8b 40 10             	mov    0x10(%eax),%eax
8010127f:	89 04 24             	mov    %eax,(%esp)
80101282:	e8 b9 06 00 00       	call   80101940 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101287:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010128a:	8b 45 08             	mov    0x8(%ebp),%eax
8010128d:	8b 50 14             	mov    0x14(%eax),%edx
80101290:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101293:	8b 45 0c             	mov    0xc(%ebp),%eax
80101296:	01 c3                	add    %eax,%ebx
80101298:	8b 45 08             	mov    0x8(%ebp),%eax
8010129b:	8b 40 10             	mov    0x10(%eax),%eax
8010129e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801012a2:	89 54 24 08          	mov    %edx,0x8(%esp)
801012a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
801012aa:	89 04 24             	mov    %eax,(%esp)
801012ad:	e8 8f 0c 00 00       	call   80101f41 <writei>
801012b2:	89 45 e8             	mov    %eax,-0x18(%ebp)
801012b5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012b9:	7e 11                	jle    801012cc <filewrite+0xdb>
        f->off += r;
801012bb:	8b 45 08             	mov    0x8(%ebp),%eax
801012be:	8b 50 14             	mov    0x14(%eax),%edx
801012c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012c4:	01 c2                	add    %eax,%edx
801012c6:	8b 45 08             	mov    0x8(%ebp),%eax
801012c9:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801012cc:	8b 45 08             	mov    0x8(%ebp),%eax
801012cf:	8b 40 10             	mov    0x10(%eax),%eax
801012d2:	89 04 24             	mov    %eax,(%esp)
801012d5:	e8 73 07 00 00       	call   80101a4d <iunlock>
      end_op();
801012da:	e8 0f 22 00 00       	call   801034ee <end_op>

      if(r < 0)
801012df:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012e3:	79 02                	jns    801012e7 <filewrite+0xf6>
        break;
801012e5:	eb 26                	jmp    8010130d <filewrite+0x11c>
      if(r != n1)
801012e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012ea:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801012ed:	74 0c                	je     801012fb <filewrite+0x10a>
        panic("short filewrite");
801012ef:	c7 04 24 c0 84 10 80 	movl   $0x801084c0,(%esp)
801012f6:	e8 67 f2 ff ff       	call   80100562 <panic>
      i += r;
801012fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012fe:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101301:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101304:	3b 45 10             	cmp    0x10(%ebp),%eax
80101307:	0f 8c 4c ff ff ff    	jl     80101259 <filewrite+0x68>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
8010130d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101310:	3b 45 10             	cmp    0x10(%ebp),%eax
80101313:	75 05                	jne    8010131a <filewrite+0x129>
80101315:	8b 45 10             	mov    0x10(%ebp),%eax
80101318:	eb 05                	jmp    8010131f <filewrite+0x12e>
8010131a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010131f:	eb 0c                	jmp    8010132d <filewrite+0x13c>
  }
  panic("filewrite");
80101321:	c7 04 24 d0 84 10 80 	movl   $0x801084d0,(%esp)
80101328:	e8 35 f2 ff ff       	call   80100562 <panic>
}
8010132d:	83 c4 24             	add    $0x24,%esp
80101330:	5b                   	pop    %ebx
80101331:	5d                   	pop    %ebp
80101332:	c3                   	ret    

80101333 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101333:	55                   	push   %ebp
80101334:	89 e5                	mov    %esp,%ebp
80101336:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, 1);
80101339:	8b 45 08             	mov    0x8(%ebp),%eax
8010133c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101343:	00 
80101344:	89 04 24             	mov    %eax,(%esp)
80101347:	e8 69 ee ff ff       	call   801001b5 <bread>
8010134c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010134f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101352:	83 c0 5c             	add    $0x5c,%eax
80101355:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
8010135c:	00 
8010135d:	89 44 24 04          	mov    %eax,0x4(%esp)
80101361:	8b 45 0c             	mov    0xc(%ebp),%eax
80101364:	89 04 24             	mov    %eax,(%esp)
80101367:	e8 31 3d 00 00       	call   8010509d <memmove>
  brelse(bp);
8010136c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010136f:	89 04 24             	mov    %eax,(%esp)
80101372:	e8 b5 ee ff ff       	call   8010022c <brelse>
}
80101377:	c9                   	leave  
80101378:	c3                   	ret    

80101379 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101379:	55                   	push   %ebp
8010137a:	89 e5                	mov    %esp,%ebp
8010137c:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, bno);
8010137f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101382:	8b 45 08             	mov    0x8(%ebp),%eax
80101385:	89 54 24 04          	mov    %edx,0x4(%esp)
80101389:	89 04 24             	mov    %eax,(%esp)
8010138c:	e8 24 ee ff ff       	call   801001b5 <bread>
80101391:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101394:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101397:	83 c0 5c             	add    $0x5c,%eax
8010139a:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801013a1:	00 
801013a2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801013a9:	00 
801013aa:	89 04 24             	mov    %eax,(%esp)
801013ad:	e8 1c 3c 00 00       	call   80104fce <memset>
  log_write(bp);
801013b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013b5:	89 04 24             	mov    %eax,(%esp)
801013b8:	e8 b8 22 00 00       	call   80103675 <log_write>
  brelse(bp);
801013bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013c0:	89 04 24             	mov    %eax,(%esp)
801013c3:	e8 64 ee ff ff       	call   8010022c <brelse>
}
801013c8:	c9                   	leave  
801013c9:	c3                   	ret    

801013ca <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801013ca:	55                   	push   %ebp
801013cb:	89 e5                	mov    %esp,%ebp
801013cd:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801013d0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801013d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013de:	e9 07 01 00 00       	jmp    801014ea <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
801013e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013e6:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801013ec:	85 c0                	test   %eax,%eax
801013ee:	0f 48 c2             	cmovs  %edx,%eax
801013f1:	c1 f8 0c             	sar    $0xc,%eax
801013f4:	89 c2                	mov    %eax,%edx
801013f6:	a1 58 1a 11 80       	mov    0x80111a58,%eax
801013fb:	01 d0                	add    %edx,%eax
801013fd:	89 44 24 04          	mov    %eax,0x4(%esp)
80101401:	8b 45 08             	mov    0x8(%ebp),%eax
80101404:	89 04 24             	mov    %eax,(%esp)
80101407:	e8 a9 ed ff ff       	call   801001b5 <bread>
8010140c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010140f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101416:	e9 9d 00 00 00       	jmp    801014b8 <balloc+0xee>
      m = 1 << (bi % 8);
8010141b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010141e:	99                   	cltd   
8010141f:	c1 ea 1d             	shr    $0x1d,%edx
80101422:	01 d0                	add    %edx,%eax
80101424:	83 e0 07             	and    $0x7,%eax
80101427:	29 d0                	sub    %edx,%eax
80101429:	ba 01 00 00 00       	mov    $0x1,%edx
8010142e:	89 c1                	mov    %eax,%ecx
80101430:	d3 e2                	shl    %cl,%edx
80101432:	89 d0                	mov    %edx,%eax
80101434:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101437:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010143a:	8d 50 07             	lea    0x7(%eax),%edx
8010143d:	85 c0                	test   %eax,%eax
8010143f:	0f 48 c2             	cmovs  %edx,%eax
80101442:	c1 f8 03             	sar    $0x3,%eax
80101445:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101448:	0f b6 44 02 5c       	movzbl 0x5c(%edx,%eax,1),%eax
8010144d:	0f b6 c0             	movzbl %al,%eax
80101450:	23 45 e8             	and    -0x18(%ebp),%eax
80101453:	85 c0                	test   %eax,%eax
80101455:	75 5d                	jne    801014b4 <balloc+0xea>
        bp->data[bi/8] |= m;  // Mark block in use.
80101457:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010145a:	8d 50 07             	lea    0x7(%eax),%edx
8010145d:	85 c0                	test   %eax,%eax
8010145f:	0f 48 c2             	cmovs  %edx,%eax
80101462:	c1 f8 03             	sar    $0x3,%eax
80101465:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101468:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
8010146d:	89 d1                	mov    %edx,%ecx
8010146f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101472:	09 ca                	or     %ecx,%edx
80101474:	89 d1                	mov    %edx,%ecx
80101476:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101479:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
8010147d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101480:	89 04 24             	mov    %eax,(%esp)
80101483:	e8 ed 21 00 00       	call   80103675 <log_write>
        brelse(bp);
80101488:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010148b:	89 04 24             	mov    %eax,(%esp)
8010148e:	e8 99 ed ff ff       	call   8010022c <brelse>
        bzero(dev, b + bi);
80101493:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101496:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101499:	01 c2                	add    %eax,%edx
8010149b:	8b 45 08             	mov    0x8(%ebp),%eax
8010149e:	89 54 24 04          	mov    %edx,0x4(%esp)
801014a2:	89 04 24             	mov    %eax,(%esp)
801014a5:	e8 cf fe ff ff       	call   80101379 <bzero>
        return b + bi;
801014aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014b0:	01 d0                	add    %edx,%eax
801014b2:	eb 52                	jmp    80101506 <balloc+0x13c>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014b4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801014b8:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801014bf:	7f 17                	jg     801014d8 <balloc+0x10e>
801014c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014c7:	01 d0                	add    %edx,%eax
801014c9:	89 c2                	mov    %eax,%edx
801014cb:	a1 40 1a 11 80       	mov    0x80111a40,%eax
801014d0:	39 c2                	cmp    %eax,%edx
801014d2:	0f 82 43 ff ff ff    	jb     8010141b <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801014d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014db:	89 04 24             	mov    %eax,(%esp)
801014de:	e8 49 ed ff ff       	call   8010022c <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801014e3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801014ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014ed:	a1 40 1a 11 80       	mov    0x80111a40,%eax
801014f2:	39 c2                	cmp    %eax,%edx
801014f4:	0f 82 e9 fe ff ff    	jb     801013e3 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801014fa:	c7 04 24 dc 84 10 80 	movl   $0x801084dc,(%esp)
80101501:	e8 5c f0 ff ff       	call   80100562 <panic>
}
80101506:	c9                   	leave  
80101507:	c3                   	ret    

80101508 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101508:	55                   	push   %ebp
80101509:	89 e5                	mov    %esp,%ebp
8010150b:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
8010150e:	c7 44 24 04 40 1a 11 	movl   $0x80111a40,0x4(%esp)
80101515:	80 
80101516:	8b 45 08             	mov    0x8(%ebp),%eax
80101519:	89 04 24             	mov    %eax,(%esp)
8010151c:	e8 12 fe ff ff       	call   80101333 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
80101521:	8b 45 0c             	mov    0xc(%ebp),%eax
80101524:	c1 e8 0c             	shr    $0xc,%eax
80101527:	89 c2                	mov    %eax,%edx
80101529:	a1 58 1a 11 80       	mov    0x80111a58,%eax
8010152e:	01 c2                	add    %eax,%edx
80101530:	8b 45 08             	mov    0x8(%ebp),%eax
80101533:	89 54 24 04          	mov    %edx,0x4(%esp)
80101537:	89 04 24             	mov    %eax,(%esp)
8010153a:	e8 76 ec ff ff       	call   801001b5 <bread>
8010153f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101542:	8b 45 0c             	mov    0xc(%ebp),%eax
80101545:	25 ff 0f 00 00       	and    $0xfff,%eax
8010154a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010154d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101550:	99                   	cltd   
80101551:	c1 ea 1d             	shr    $0x1d,%edx
80101554:	01 d0                	add    %edx,%eax
80101556:	83 e0 07             	and    $0x7,%eax
80101559:	29 d0                	sub    %edx,%eax
8010155b:	ba 01 00 00 00       	mov    $0x1,%edx
80101560:	89 c1                	mov    %eax,%ecx
80101562:	d3 e2                	shl    %cl,%edx
80101564:	89 d0                	mov    %edx,%eax
80101566:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101569:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010156c:	8d 50 07             	lea    0x7(%eax),%edx
8010156f:	85 c0                	test   %eax,%eax
80101571:	0f 48 c2             	cmovs  %edx,%eax
80101574:	c1 f8 03             	sar    $0x3,%eax
80101577:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010157a:	0f b6 44 02 5c       	movzbl 0x5c(%edx,%eax,1),%eax
8010157f:	0f b6 c0             	movzbl %al,%eax
80101582:	23 45 ec             	and    -0x14(%ebp),%eax
80101585:	85 c0                	test   %eax,%eax
80101587:	75 0c                	jne    80101595 <bfree+0x8d>
    panic("freeing free block");
80101589:	c7 04 24 f2 84 10 80 	movl   $0x801084f2,(%esp)
80101590:	e8 cd ef ff ff       	call   80100562 <panic>
  bp->data[bi/8] &= ~m;
80101595:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101598:	8d 50 07             	lea    0x7(%eax),%edx
8010159b:	85 c0                	test   %eax,%eax
8010159d:	0f 48 c2             	cmovs  %edx,%eax
801015a0:	c1 f8 03             	sar    $0x3,%eax
801015a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015a6:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801015ab:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801015ae:	f7 d1                	not    %ecx
801015b0:	21 ca                	and    %ecx,%edx
801015b2:	89 d1                	mov    %edx,%ecx
801015b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015b7:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
801015bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015be:	89 04 24             	mov    %eax,(%esp)
801015c1:	e8 af 20 00 00       	call   80103675 <log_write>
  brelse(bp);
801015c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015c9:	89 04 24             	mov    %eax,(%esp)
801015cc:	e8 5b ec ff ff       	call   8010022c <brelse>
}
801015d1:	c9                   	leave  
801015d2:	c3                   	ret    

801015d3 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801015d3:	55                   	push   %ebp
801015d4:	89 e5                	mov    %esp,%ebp
801015d6:	57                   	push   %edi
801015d7:	56                   	push   %esi
801015d8:	53                   	push   %ebx
801015d9:	83 ec 4c             	sub    $0x4c,%esp
  int i = 0;
801015dc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
801015e3:	c7 44 24 04 05 85 10 	movl   $0x80108505,0x4(%esp)
801015ea:	80 
801015eb:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
801015f2:	e8 54 37 00 00       	call   80104d4b <initlock>
  for(i = 0; i < NINODE; i++) {
801015f7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801015fe:	eb 2c                	jmp    8010162c <iinit+0x59>
    initsleeplock(&icache.inode[i].lock, "inode");
80101600:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101603:	89 d0                	mov    %edx,%eax
80101605:	c1 e0 03             	shl    $0x3,%eax
80101608:	01 d0                	add    %edx,%eax
8010160a:	c1 e0 04             	shl    $0x4,%eax
8010160d:	83 c0 30             	add    $0x30,%eax
80101610:	05 60 1a 11 80       	add    $0x80111a60,%eax
80101615:	83 c0 10             	add    $0x10,%eax
80101618:	c7 44 24 04 0c 85 10 	movl   $0x8010850c,0x4(%esp)
8010161f:	80 
80101620:	89 04 24             	mov    %eax,(%esp)
80101623:	e8 e7 35 00 00       	call   80104c0f <initsleeplock>
iinit(int dev)
{
  int i = 0;
  
  initlock(&icache.lock, "icache");
  for(i = 0; i < NINODE; i++) {
80101628:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010162c:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101630:	7e ce                	jle    80101600 <iinit+0x2d>
    initsleeplock(&icache.inode[i].lock, "inode");
  }

  readsb(dev, &sb);
80101632:	c7 44 24 04 40 1a 11 	movl   $0x80111a40,0x4(%esp)
80101639:	80 
8010163a:	8b 45 08             	mov    0x8(%ebp),%eax
8010163d:	89 04 24             	mov    %eax,(%esp)
80101640:	e8 ee fc ff ff       	call   80101333 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101645:	a1 58 1a 11 80       	mov    0x80111a58,%eax
8010164a:	8b 3d 54 1a 11 80    	mov    0x80111a54,%edi
80101650:	8b 35 50 1a 11 80    	mov    0x80111a50,%esi
80101656:	8b 1d 4c 1a 11 80    	mov    0x80111a4c,%ebx
8010165c:	8b 0d 48 1a 11 80    	mov    0x80111a48,%ecx
80101662:	8b 15 44 1a 11 80    	mov    0x80111a44,%edx
80101668:	89 55 d4             	mov    %edx,-0x2c(%ebp)
8010166b:	8b 15 40 1a 11 80    	mov    0x80111a40,%edx
80101671:	89 44 24 1c          	mov    %eax,0x1c(%esp)
80101675:	89 7c 24 18          	mov    %edi,0x18(%esp)
80101679:	89 74 24 14          	mov    %esi,0x14(%esp)
8010167d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80101681:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101685:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101688:	89 44 24 08          	mov    %eax,0x8(%esp)
8010168c:	89 d0                	mov    %edx,%eax
8010168e:	89 44 24 04          	mov    %eax,0x4(%esp)
80101692:	c7 04 24 14 85 10 80 	movl   $0x80108514,(%esp)
80101699:	e8 2a ed ff ff       	call   801003c8 <cprintf>
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010169e:	83 c4 4c             	add    $0x4c,%esp
801016a1:	5b                   	pop    %ebx
801016a2:	5e                   	pop    %esi
801016a3:	5f                   	pop    %edi
801016a4:	5d                   	pop    %ebp
801016a5:	c3                   	ret    

801016a6 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
801016a6:	55                   	push   %ebp
801016a7:	89 e5                	mov    %esp,%ebp
801016a9:	83 ec 28             	sub    $0x28,%esp
801016ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801016af:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801016b3:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801016ba:	e9 9e 00 00 00       	jmp    8010175d <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801016bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016c2:	c1 e8 03             	shr    $0x3,%eax
801016c5:	89 c2                	mov    %eax,%edx
801016c7:	a1 54 1a 11 80       	mov    0x80111a54,%eax
801016cc:	01 d0                	add    %edx,%eax
801016ce:	89 44 24 04          	mov    %eax,0x4(%esp)
801016d2:	8b 45 08             	mov    0x8(%ebp),%eax
801016d5:	89 04 24             	mov    %eax,(%esp)
801016d8:	e8 d8 ea ff ff       	call   801001b5 <bread>
801016dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801016e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016e3:	8d 50 5c             	lea    0x5c(%eax),%edx
801016e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016e9:	83 e0 07             	and    $0x7,%eax
801016ec:	c1 e0 06             	shl    $0x6,%eax
801016ef:	01 d0                	add    %edx,%eax
801016f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801016f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016f7:	0f b7 00             	movzwl (%eax),%eax
801016fa:	66 85 c0             	test   %ax,%ax
801016fd:	75 4f                	jne    8010174e <ialloc+0xa8>
      memset(dip, 0, sizeof(*dip));
801016ff:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101706:	00 
80101707:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010170e:	00 
8010170f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101712:	89 04 24             	mov    %eax,(%esp)
80101715:	e8 b4 38 00 00       	call   80104fce <memset>
      dip->type = type;
8010171a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010171d:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101721:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101724:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101727:	89 04 24             	mov    %eax,(%esp)
8010172a:	e8 46 1f 00 00       	call   80103675 <log_write>
      brelse(bp);
8010172f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101732:	89 04 24             	mov    %eax,(%esp)
80101735:	e8 f2 ea ff ff       	call   8010022c <brelse>
      return iget(dev, inum);
8010173a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010173d:	89 44 24 04          	mov    %eax,0x4(%esp)
80101741:	8b 45 08             	mov    0x8(%ebp),%eax
80101744:	89 04 24             	mov    %eax,(%esp)
80101747:	e8 ed 00 00 00       	call   80101839 <iget>
8010174c:	eb 2b                	jmp    80101779 <ialloc+0xd3>
    }
    brelse(bp);
8010174e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101751:	89 04 24             	mov    %eax,(%esp)
80101754:	e8 d3 ea ff ff       	call   8010022c <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101759:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010175d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101760:	a1 48 1a 11 80       	mov    0x80111a48,%eax
80101765:	39 c2                	cmp    %eax,%edx
80101767:	0f 82 52 ff ff ff    	jb     801016bf <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
8010176d:	c7 04 24 67 85 10 80 	movl   $0x80108567,(%esp)
80101774:	e8 e9 ed ff ff       	call   80100562 <panic>
}
80101779:	c9                   	leave  
8010177a:	c3                   	ret    

8010177b <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
8010177b:	55                   	push   %ebp
8010177c:	89 e5                	mov    %esp,%ebp
8010177e:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101781:	8b 45 08             	mov    0x8(%ebp),%eax
80101784:	8b 40 04             	mov    0x4(%eax),%eax
80101787:	c1 e8 03             	shr    $0x3,%eax
8010178a:	89 c2                	mov    %eax,%edx
8010178c:	a1 54 1a 11 80       	mov    0x80111a54,%eax
80101791:	01 c2                	add    %eax,%edx
80101793:	8b 45 08             	mov    0x8(%ebp),%eax
80101796:	8b 00                	mov    (%eax),%eax
80101798:	89 54 24 04          	mov    %edx,0x4(%esp)
8010179c:	89 04 24             	mov    %eax,(%esp)
8010179f:	e8 11 ea ff ff       	call   801001b5 <bread>
801017a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801017a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017aa:	8d 50 5c             	lea    0x5c(%eax),%edx
801017ad:	8b 45 08             	mov    0x8(%ebp),%eax
801017b0:	8b 40 04             	mov    0x4(%eax),%eax
801017b3:	83 e0 07             	and    $0x7,%eax
801017b6:	c1 e0 06             	shl    $0x6,%eax
801017b9:	01 d0                	add    %edx,%eax
801017bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801017be:	8b 45 08             	mov    0x8(%ebp),%eax
801017c1:	0f b7 50 50          	movzwl 0x50(%eax),%edx
801017c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017c8:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801017cb:	8b 45 08             	mov    0x8(%ebp),%eax
801017ce:	0f b7 50 52          	movzwl 0x52(%eax),%edx
801017d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017d5:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801017d9:	8b 45 08             	mov    0x8(%ebp),%eax
801017dc:	0f b7 50 54          	movzwl 0x54(%eax),%edx
801017e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017e3:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801017e7:	8b 45 08             	mov    0x8(%ebp),%eax
801017ea:	0f b7 50 56          	movzwl 0x56(%eax),%edx
801017ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017f1:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801017f5:	8b 45 08             	mov    0x8(%ebp),%eax
801017f8:	8b 50 58             	mov    0x58(%eax),%edx
801017fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017fe:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101801:	8b 45 08             	mov    0x8(%ebp),%eax
80101804:	8d 50 5c             	lea    0x5c(%eax),%edx
80101807:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010180a:	83 c0 0c             	add    $0xc,%eax
8010180d:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101814:	00 
80101815:	89 54 24 04          	mov    %edx,0x4(%esp)
80101819:	89 04 24             	mov    %eax,(%esp)
8010181c:	e8 7c 38 00 00       	call   8010509d <memmove>
  log_write(bp);
80101821:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101824:	89 04 24             	mov    %eax,(%esp)
80101827:	e8 49 1e 00 00       	call   80103675 <log_write>
  brelse(bp);
8010182c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010182f:	89 04 24             	mov    %eax,(%esp)
80101832:	e8 f5 e9 ff ff       	call   8010022c <brelse>
}
80101837:	c9                   	leave  
80101838:	c3                   	ret    

80101839 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101839:	55                   	push   %ebp
8010183a:	89 e5                	mov    %esp,%ebp
8010183c:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
8010183f:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
80101846:	e8 21 35 00 00       	call   80104d6c <acquire>

  // Is the inode already cached?
  empty = 0;
8010184b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101852:	c7 45 f4 94 1a 11 80 	movl   $0x80111a94,-0xc(%ebp)
80101859:	eb 5c                	jmp    801018b7 <iget+0x7e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
8010185b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010185e:	8b 40 08             	mov    0x8(%eax),%eax
80101861:	85 c0                	test   %eax,%eax
80101863:	7e 35                	jle    8010189a <iget+0x61>
80101865:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101868:	8b 00                	mov    (%eax),%eax
8010186a:	3b 45 08             	cmp    0x8(%ebp),%eax
8010186d:	75 2b                	jne    8010189a <iget+0x61>
8010186f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101872:	8b 40 04             	mov    0x4(%eax),%eax
80101875:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101878:	75 20                	jne    8010189a <iget+0x61>
      ip->ref++;
8010187a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187d:	8b 40 08             	mov    0x8(%eax),%eax
80101880:	8d 50 01             	lea    0x1(%eax),%edx
80101883:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101886:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101889:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
80101890:	e8 3f 35 00 00       	call   80104dd4 <release>
      return ip;
80101895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101898:	eb 72                	jmp    8010190c <iget+0xd3>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010189a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010189e:	75 10                	jne    801018b0 <iget+0x77>
801018a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a3:	8b 40 08             	mov    0x8(%eax),%eax
801018a6:	85 c0                	test   %eax,%eax
801018a8:	75 06                	jne    801018b0 <iget+0x77>
      empty = ip;
801018aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ad:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018b0:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801018b7:	81 7d f4 b4 36 11 80 	cmpl   $0x801136b4,-0xc(%ebp)
801018be:	72 9b                	jb     8010185b <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801018c0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018c4:	75 0c                	jne    801018d2 <iget+0x99>
    panic("iget: no inodes");
801018c6:	c7 04 24 79 85 10 80 	movl   $0x80108579,(%esp)
801018cd:	e8 90 ec ff ff       	call   80100562 <panic>

  ip = empty;
801018d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801018d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018db:	8b 55 08             	mov    0x8(%ebp),%edx
801018de:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801018e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018e3:	8b 55 0c             	mov    0xc(%ebp),%edx
801018e6:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801018e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ec:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
801018f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f6:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
801018fd:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
80101904:	e8 cb 34 00 00       	call   80104dd4 <release>

  return ip;
80101909:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010190c:	c9                   	leave  
8010190d:	c3                   	ret    

8010190e <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
8010190e:	55                   	push   %ebp
8010190f:	89 e5                	mov    %esp,%ebp
80101911:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101914:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
8010191b:	e8 4c 34 00 00       	call   80104d6c <acquire>
  ip->ref++;
80101920:	8b 45 08             	mov    0x8(%ebp),%eax
80101923:	8b 40 08             	mov    0x8(%eax),%eax
80101926:	8d 50 01             	lea    0x1(%eax),%edx
80101929:	8b 45 08             	mov    0x8(%ebp),%eax
8010192c:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
8010192f:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
80101936:	e8 99 34 00 00       	call   80104dd4 <release>
  return ip;
8010193b:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010193e:	c9                   	leave  
8010193f:	c3                   	ret    

80101940 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101940:	55                   	push   %ebp
80101941:	89 e5                	mov    %esp,%ebp
80101943:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101946:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010194a:	74 0a                	je     80101956 <ilock+0x16>
8010194c:	8b 45 08             	mov    0x8(%ebp),%eax
8010194f:	8b 40 08             	mov    0x8(%eax),%eax
80101952:	85 c0                	test   %eax,%eax
80101954:	7f 0c                	jg     80101962 <ilock+0x22>
    panic("ilock");
80101956:	c7 04 24 89 85 10 80 	movl   $0x80108589,(%esp)
8010195d:	e8 00 ec ff ff       	call   80100562 <panic>

  acquiresleep(&ip->lock);
80101962:	8b 45 08             	mov    0x8(%ebp),%eax
80101965:	83 c0 0c             	add    $0xc,%eax
80101968:	89 04 24             	mov    %eax,(%esp)
8010196b:	e8 d9 32 00 00       	call   80104c49 <acquiresleep>

  if(ip->valid == 0){
80101970:	8b 45 08             	mov    0x8(%ebp),%eax
80101973:	8b 40 4c             	mov    0x4c(%eax),%eax
80101976:	85 c0                	test   %eax,%eax
80101978:	0f 85 cd 00 00 00    	jne    80101a4b <ilock+0x10b>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010197e:	8b 45 08             	mov    0x8(%ebp),%eax
80101981:	8b 40 04             	mov    0x4(%eax),%eax
80101984:	c1 e8 03             	shr    $0x3,%eax
80101987:	89 c2                	mov    %eax,%edx
80101989:	a1 54 1a 11 80       	mov    0x80111a54,%eax
8010198e:	01 c2                	add    %eax,%edx
80101990:	8b 45 08             	mov    0x8(%ebp),%eax
80101993:	8b 00                	mov    (%eax),%eax
80101995:	89 54 24 04          	mov    %edx,0x4(%esp)
80101999:	89 04 24             	mov    %eax,(%esp)
8010199c:	e8 14 e8 ff ff       	call   801001b5 <bread>
801019a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801019a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a7:	8d 50 5c             	lea    0x5c(%eax),%edx
801019aa:	8b 45 08             	mov    0x8(%ebp),%eax
801019ad:	8b 40 04             	mov    0x4(%eax),%eax
801019b0:	83 e0 07             	and    $0x7,%eax
801019b3:	c1 e0 06             	shl    $0x6,%eax
801019b6:	01 d0                	add    %edx,%eax
801019b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
801019bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019be:	0f b7 10             	movzwl (%eax),%edx
801019c1:	8b 45 08             	mov    0x8(%ebp),%eax
801019c4:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
801019c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019cb:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801019cf:	8b 45 08             	mov    0x8(%ebp),%eax
801019d2:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
801019d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019d9:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801019dd:	8b 45 08             	mov    0x8(%ebp),%eax
801019e0:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
801019e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019e7:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801019eb:	8b 45 08             	mov    0x8(%ebp),%eax
801019ee:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
801019f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019f5:	8b 50 08             	mov    0x8(%eax),%edx
801019f8:	8b 45 08             	mov    0x8(%ebp),%eax
801019fb:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801019fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a01:	8d 50 0c             	lea    0xc(%eax),%edx
80101a04:	8b 45 08             	mov    0x8(%ebp),%eax
80101a07:	83 c0 5c             	add    $0x5c,%eax
80101a0a:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101a11:	00 
80101a12:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a16:	89 04 24             	mov    %eax,(%esp)
80101a19:	e8 7f 36 00 00       	call   8010509d <memmove>
    brelse(bp);
80101a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a21:	89 04 24             	mov    %eax,(%esp)
80101a24:	e8 03 e8 ff ff       	call   8010022c <brelse>
    ip->valid = 1;
80101a29:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2c:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101a33:	8b 45 08             	mov    0x8(%ebp),%eax
80101a36:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101a3a:	66 85 c0             	test   %ax,%ax
80101a3d:	75 0c                	jne    80101a4b <ilock+0x10b>
      panic("ilock: no type");
80101a3f:	c7 04 24 8f 85 10 80 	movl   $0x8010858f,(%esp)
80101a46:	e8 17 eb ff ff       	call   80100562 <panic>
  }
}
80101a4b:	c9                   	leave  
80101a4c:	c3                   	ret    

80101a4d <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101a4d:	55                   	push   %ebp
80101a4e:	89 e5                	mov    %esp,%ebp
80101a50:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101a53:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a57:	74 1c                	je     80101a75 <iunlock+0x28>
80101a59:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5c:	83 c0 0c             	add    $0xc,%eax
80101a5f:	89 04 24             	mov    %eax,(%esp)
80101a62:	e8 7f 32 00 00       	call   80104ce6 <holdingsleep>
80101a67:	85 c0                	test   %eax,%eax
80101a69:	74 0a                	je     80101a75 <iunlock+0x28>
80101a6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6e:	8b 40 08             	mov    0x8(%eax),%eax
80101a71:	85 c0                	test   %eax,%eax
80101a73:	7f 0c                	jg     80101a81 <iunlock+0x34>
    panic("iunlock");
80101a75:	c7 04 24 9e 85 10 80 	movl   $0x8010859e,(%esp)
80101a7c:	e8 e1 ea ff ff       	call   80100562 <panic>

  releasesleep(&ip->lock);
80101a81:	8b 45 08             	mov    0x8(%ebp),%eax
80101a84:	83 c0 0c             	add    $0xc,%eax
80101a87:	89 04 24             	mov    %eax,(%esp)
80101a8a:	e8 15 32 00 00       	call   80104ca4 <releasesleep>
}
80101a8f:	c9                   	leave  
80101a90:	c3                   	ret    

80101a91 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101a91:	55                   	push   %ebp
80101a92:	89 e5                	mov    %esp,%ebp
80101a94:	83 ec 28             	sub    $0x28,%esp
  acquiresleep(&ip->lock);
80101a97:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9a:	83 c0 0c             	add    $0xc,%eax
80101a9d:	89 04 24             	mov    %eax,(%esp)
80101aa0:	e8 a4 31 00 00       	call   80104c49 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101aa5:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa8:	8b 40 4c             	mov    0x4c(%eax),%eax
80101aab:	85 c0                	test   %eax,%eax
80101aad:	74 5c                	je     80101b0b <iput+0x7a>
80101aaf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab2:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101ab6:	66 85 c0             	test   %ax,%ax
80101ab9:	75 50                	jne    80101b0b <iput+0x7a>
    acquire(&icache.lock);
80101abb:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
80101ac2:	e8 a5 32 00 00       	call   80104d6c <acquire>
    int r = ip->ref;
80101ac7:	8b 45 08             	mov    0x8(%ebp),%eax
80101aca:	8b 40 08             	mov    0x8(%eax),%eax
80101acd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101ad0:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
80101ad7:	e8 f8 32 00 00       	call   80104dd4 <release>
    if(r == 1){
80101adc:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101ae0:	75 29                	jne    80101b0b <iput+0x7a>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101ae2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae5:	89 04 24             	mov    %eax,(%esp)
80101ae8:	e8 86 01 00 00       	call   80101c73 <itrunc>
      ip->type = 0;
80101aed:	8b 45 08             	mov    0x8(%ebp),%eax
80101af0:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101af6:	8b 45 08             	mov    0x8(%ebp),%eax
80101af9:	89 04 24             	mov    %eax,(%esp)
80101afc:	e8 7a fc ff ff       	call   8010177b <iupdate>
      ip->valid = 0;
80101b01:	8b 45 08             	mov    0x8(%ebp),%eax
80101b04:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101b0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0e:	83 c0 0c             	add    $0xc,%eax
80101b11:	89 04 24             	mov    %eax,(%esp)
80101b14:	e8 8b 31 00 00       	call   80104ca4 <releasesleep>

  acquire(&icache.lock);
80101b19:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
80101b20:	e8 47 32 00 00       	call   80104d6c <acquire>
  ip->ref--;
80101b25:	8b 45 08             	mov    0x8(%ebp),%eax
80101b28:	8b 40 08             	mov    0x8(%eax),%eax
80101b2b:	8d 50 ff             	lea    -0x1(%eax),%edx
80101b2e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b31:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b34:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
80101b3b:	e8 94 32 00 00       	call   80104dd4 <release>
}
80101b40:	c9                   	leave  
80101b41:	c3                   	ret    

80101b42 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101b42:	55                   	push   %ebp
80101b43:	89 e5                	mov    %esp,%ebp
80101b45:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101b48:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4b:	89 04 24             	mov    %eax,(%esp)
80101b4e:	e8 fa fe ff ff       	call   80101a4d <iunlock>
  iput(ip);
80101b53:	8b 45 08             	mov    0x8(%ebp),%eax
80101b56:	89 04 24             	mov    %eax,(%esp)
80101b59:	e8 33 ff ff ff       	call   80101a91 <iput>
}
80101b5e:	c9                   	leave  
80101b5f:	c3                   	ret    

80101b60 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101b60:	55                   	push   %ebp
80101b61:	89 e5                	mov    %esp,%ebp
80101b63:	53                   	push   %ebx
80101b64:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101b67:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101b6b:	77 3e                	ja     80101bab <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b70:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b73:	83 c2 14             	add    $0x14,%edx
80101b76:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b7d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b81:	75 20                	jne    80101ba3 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b83:	8b 45 08             	mov    0x8(%ebp),%eax
80101b86:	8b 00                	mov    (%eax),%eax
80101b88:	89 04 24             	mov    %eax,(%esp)
80101b8b:	e8 3a f8 ff ff       	call   801013ca <balloc>
80101b90:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b93:	8b 45 08             	mov    0x8(%ebp),%eax
80101b96:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b99:	8d 4a 14             	lea    0x14(%edx),%ecx
80101b9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b9f:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ba6:	e9 c2 00 00 00       	jmp    80101c6d <bmap+0x10d>
  }
  bn -= NDIRECT;
80101bab:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101baf:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101bb3:	0f 87 a8 00 00 00    	ja     80101c61 <bmap+0x101>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101bc2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bc5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101bc9:	75 1c                	jne    80101be7 <bmap+0x87>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101bcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bce:	8b 00                	mov    (%eax),%eax
80101bd0:	89 04 24             	mov    %eax,(%esp)
80101bd3:	e8 f2 f7 ff ff       	call   801013ca <balloc>
80101bd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bdb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bde:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101be1:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101be7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bea:	8b 00                	mov    (%eax),%eax
80101bec:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bef:	89 54 24 04          	mov    %edx,0x4(%esp)
80101bf3:	89 04 24             	mov    %eax,(%esp)
80101bf6:	e8 ba e5 ff ff       	call   801001b5 <bread>
80101bfb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101bfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c01:	83 c0 5c             	add    $0x5c,%eax
80101c04:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101c07:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c0a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c11:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c14:	01 d0                	add    %edx,%eax
80101c16:	8b 00                	mov    (%eax),%eax
80101c18:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c1b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c1f:	75 30                	jne    80101c51 <bmap+0xf1>
      a[bn] = addr = balloc(ip->dev);
80101c21:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c24:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c2b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c2e:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101c31:	8b 45 08             	mov    0x8(%ebp),%eax
80101c34:	8b 00                	mov    (%eax),%eax
80101c36:	89 04 24             	mov    %eax,(%esp)
80101c39:	e8 8c f7 ff ff       	call   801013ca <balloc>
80101c3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c44:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101c46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c49:	89 04 24             	mov    %eax,(%esp)
80101c4c:	e8 24 1a 00 00       	call   80103675 <log_write>
    }
    brelse(bp);
80101c51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c54:	89 04 24             	mov    %eax,(%esp)
80101c57:	e8 d0 e5 ff ff       	call   8010022c <brelse>
    return addr;
80101c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c5f:	eb 0c                	jmp    80101c6d <bmap+0x10d>
  }

  panic("bmap: out of range");
80101c61:	c7 04 24 a6 85 10 80 	movl   $0x801085a6,(%esp)
80101c68:	e8 f5 e8 ff ff       	call   80100562 <panic>
}
80101c6d:	83 c4 24             	add    $0x24,%esp
80101c70:	5b                   	pop    %ebx
80101c71:	5d                   	pop    %ebp
80101c72:	c3                   	ret    

80101c73 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101c73:	55                   	push   %ebp
80101c74:	89 e5                	mov    %esp,%ebp
80101c76:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c79:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c80:	eb 44                	jmp    80101cc6 <itrunc+0x53>
    if(ip->addrs[i]){
80101c82:	8b 45 08             	mov    0x8(%ebp),%eax
80101c85:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c88:	83 c2 14             	add    $0x14,%edx
80101c8b:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c8f:	85 c0                	test   %eax,%eax
80101c91:	74 2f                	je     80101cc2 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101c93:	8b 45 08             	mov    0x8(%ebp),%eax
80101c96:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c99:	83 c2 14             	add    $0x14,%edx
80101c9c:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101ca0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca3:	8b 00                	mov    (%eax),%eax
80101ca5:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ca9:	89 04 24             	mov    %eax,(%esp)
80101cac:	e8 57 f8 ff ff       	call   80101508 <bfree>
      ip->addrs[i] = 0;
80101cb1:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cb7:	83 c2 14             	add    $0x14,%edx
80101cba:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101cc1:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101cc2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101cc6:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101cca:	7e b6                	jle    80101c82 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
80101ccc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ccf:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101cd5:	85 c0                	test   %eax,%eax
80101cd7:	0f 84 a4 00 00 00    	je     80101d81 <itrunc+0x10e>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101cdd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce0:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101ce6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce9:	8b 00                	mov    (%eax),%eax
80101ceb:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cef:	89 04 24             	mov    %eax,(%esp)
80101cf2:	e8 be e4 ff ff       	call   801001b5 <bread>
80101cf7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101cfa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cfd:	83 c0 5c             	add    $0x5c,%eax
80101d00:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101d03:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101d0a:	eb 3b                	jmp    80101d47 <itrunc+0xd4>
      if(a[j])
80101d0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d0f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d16:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101d19:	01 d0                	add    %edx,%eax
80101d1b:	8b 00                	mov    (%eax),%eax
80101d1d:	85 c0                	test   %eax,%eax
80101d1f:	74 22                	je     80101d43 <itrunc+0xd0>
        bfree(ip->dev, a[j]);
80101d21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d24:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101d2e:	01 d0                	add    %edx,%eax
80101d30:	8b 10                	mov    (%eax),%edx
80101d32:	8b 45 08             	mov    0x8(%ebp),%eax
80101d35:	8b 00                	mov    (%eax),%eax
80101d37:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d3b:	89 04 24             	mov    %eax,(%esp)
80101d3e:	e8 c5 f7 ff ff       	call   80101508 <bfree>
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101d43:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101d47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d4a:	83 f8 7f             	cmp    $0x7f,%eax
80101d4d:	76 bd                	jbe    80101d0c <itrunc+0x99>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101d4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d52:	89 04 24             	mov    %eax,(%esp)
80101d55:	e8 d2 e4 ff ff       	call   8010022c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101d5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5d:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101d63:	8b 45 08             	mov    0x8(%ebp),%eax
80101d66:	8b 00                	mov    (%eax),%eax
80101d68:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d6c:	89 04 24             	mov    %eax,(%esp)
80101d6f:	e8 94 f7 ff ff       	call   80101508 <bfree>
    ip->addrs[NDIRECT] = 0;
80101d74:	8b 45 08             	mov    0x8(%ebp),%eax
80101d77:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101d7e:	00 00 00 
  }

  ip->size = 0;
80101d81:	8b 45 08             	mov    0x8(%ebp),%eax
80101d84:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101d8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8e:	89 04 24             	mov    %eax,(%esp)
80101d91:	e8 e5 f9 ff ff       	call   8010177b <iupdate>
}
80101d96:	c9                   	leave  
80101d97:	c3                   	ret    

80101d98 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101d98:	55                   	push   %ebp
80101d99:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101d9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9e:	8b 00                	mov    (%eax),%eax
80101da0:	89 c2                	mov    %eax,%edx
80101da2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101da5:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101da8:	8b 45 08             	mov    0x8(%ebp),%eax
80101dab:	8b 50 04             	mov    0x4(%eax),%edx
80101dae:	8b 45 0c             	mov    0xc(%ebp),%eax
80101db1:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101db4:	8b 45 08             	mov    0x8(%ebp),%eax
80101db7:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101dbb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dbe:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101dc1:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc4:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101dc8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dcb:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101dcf:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd2:	8b 50 58             	mov    0x58(%eax),%edx
80101dd5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dd8:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ddb:	5d                   	pop    %ebp
80101ddc:	c3                   	ret    

80101ddd <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ddd:	55                   	push   %ebp
80101dde:	89 e5                	mov    %esp,%ebp
80101de0:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101de3:	8b 45 08             	mov    0x8(%ebp),%eax
80101de6:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101dea:	66 83 f8 03          	cmp    $0x3,%ax
80101dee:	75 60                	jne    80101e50 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101df0:	8b 45 08             	mov    0x8(%ebp),%eax
80101df3:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101df7:	66 85 c0             	test   %ax,%ax
80101dfa:	78 20                	js     80101e1c <readi+0x3f>
80101dfc:	8b 45 08             	mov    0x8(%ebp),%eax
80101dff:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101e03:	66 83 f8 09          	cmp    $0x9,%ax
80101e07:	7f 13                	jg     80101e1c <readi+0x3f>
80101e09:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0c:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101e10:	98                   	cwtl   
80101e11:	8b 04 c5 e0 19 11 80 	mov    -0x7feee620(,%eax,8),%eax
80101e18:	85 c0                	test   %eax,%eax
80101e1a:	75 0a                	jne    80101e26 <readi+0x49>
      return -1;
80101e1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e21:	e9 19 01 00 00       	jmp    80101f3f <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101e26:	8b 45 08             	mov    0x8(%ebp),%eax
80101e29:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101e2d:	98                   	cwtl   
80101e2e:	8b 04 c5 e0 19 11 80 	mov    -0x7feee620(,%eax,8),%eax
80101e35:	8b 55 14             	mov    0x14(%ebp),%edx
80101e38:	89 54 24 08          	mov    %edx,0x8(%esp)
80101e3c:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e3f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e43:	8b 55 08             	mov    0x8(%ebp),%edx
80101e46:	89 14 24             	mov    %edx,(%esp)
80101e49:	ff d0                	call   *%eax
80101e4b:	e9 ef 00 00 00       	jmp    80101f3f <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101e50:	8b 45 08             	mov    0x8(%ebp),%eax
80101e53:	8b 40 58             	mov    0x58(%eax),%eax
80101e56:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e59:	72 0d                	jb     80101e68 <readi+0x8b>
80101e5b:	8b 45 14             	mov    0x14(%ebp),%eax
80101e5e:	8b 55 10             	mov    0x10(%ebp),%edx
80101e61:	01 d0                	add    %edx,%eax
80101e63:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e66:	73 0a                	jae    80101e72 <readi+0x95>
    return -1;
80101e68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e6d:	e9 cd 00 00 00       	jmp    80101f3f <readi+0x162>
  if(off + n > ip->size)
80101e72:	8b 45 14             	mov    0x14(%ebp),%eax
80101e75:	8b 55 10             	mov    0x10(%ebp),%edx
80101e78:	01 c2                	add    %eax,%edx
80101e7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7d:	8b 40 58             	mov    0x58(%eax),%eax
80101e80:	39 c2                	cmp    %eax,%edx
80101e82:	76 0c                	jbe    80101e90 <readi+0xb3>
    n = ip->size - off;
80101e84:	8b 45 08             	mov    0x8(%ebp),%eax
80101e87:	8b 40 58             	mov    0x58(%eax),%eax
80101e8a:	2b 45 10             	sub    0x10(%ebp),%eax
80101e8d:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e90:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e97:	e9 94 00 00 00       	jmp    80101f30 <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e9c:	8b 45 10             	mov    0x10(%ebp),%eax
80101e9f:	c1 e8 09             	shr    $0x9,%eax
80101ea2:	89 44 24 04          	mov    %eax,0x4(%esp)
80101ea6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea9:	89 04 24             	mov    %eax,(%esp)
80101eac:	e8 af fc ff ff       	call   80101b60 <bmap>
80101eb1:	8b 55 08             	mov    0x8(%ebp),%edx
80101eb4:	8b 12                	mov    (%edx),%edx
80101eb6:	89 44 24 04          	mov    %eax,0x4(%esp)
80101eba:	89 14 24             	mov    %edx,(%esp)
80101ebd:	e8 f3 e2 ff ff       	call   801001b5 <bread>
80101ec2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101ec5:	8b 45 10             	mov    0x10(%ebp),%eax
80101ec8:	25 ff 01 00 00       	and    $0x1ff,%eax
80101ecd:	89 c2                	mov    %eax,%edx
80101ecf:	b8 00 02 00 00       	mov    $0x200,%eax
80101ed4:	29 d0                	sub    %edx,%eax
80101ed6:	89 c2                	mov    %eax,%edx
80101ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101edb:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101ede:	29 c1                	sub    %eax,%ecx
80101ee0:	89 c8                	mov    %ecx,%eax
80101ee2:	39 c2                	cmp    %eax,%edx
80101ee4:	0f 46 c2             	cmovbe %edx,%eax
80101ee7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101eea:	8b 45 10             	mov    0x10(%ebp),%eax
80101eed:	25 ff 01 00 00       	and    $0x1ff,%eax
80101ef2:	8d 50 50             	lea    0x50(%eax),%edx
80101ef5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ef8:	01 d0                	add    %edx,%eax
80101efa:	8d 50 0c             	lea    0xc(%eax),%edx
80101efd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f00:	89 44 24 08          	mov    %eax,0x8(%esp)
80101f04:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f08:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f0b:	89 04 24             	mov    %eax,(%esp)
80101f0e:	e8 8a 31 00 00       	call   8010509d <memmove>
    brelse(bp);
80101f13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f16:	89 04 24             	mov    %eax,(%esp)
80101f19:	e8 0e e3 ff ff       	call   8010022c <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f21:	01 45 f4             	add    %eax,-0xc(%ebp)
80101f24:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f27:	01 45 10             	add    %eax,0x10(%ebp)
80101f2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f2d:	01 45 0c             	add    %eax,0xc(%ebp)
80101f30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f33:	3b 45 14             	cmp    0x14(%ebp),%eax
80101f36:	0f 82 60 ff ff ff    	jb     80101e9c <readi+0xbf>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101f3c:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101f3f:	c9                   	leave  
80101f40:	c3                   	ret    

80101f41 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101f41:	55                   	push   %ebp
80101f42:	89 e5                	mov    %esp,%ebp
80101f44:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f47:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101f4e:	66 83 f8 03          	cmp    $0x3,%ax
80101f52:	75 60                	jne    80101fb4 <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101f54:	8b 45 08             	mov    0x8(%ebp),%eax
80101f57:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f5b:	66 85 c0             	test   %ax,%ax
80101f5e:	78 20                	js     80101f80 <writei+0x3f>
80101f60:	8b 45 08             	mov    0x8(%ebp),%eax
80101f63:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f67:	66 83 f8 09          	cmp    $0x9,%ax
80101f6b:	7f 13                	jg     80101f80 <writei+0x3f>
80101f6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f70:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f74:	98                   	cwtl   
80101f75:	8b 04 c5 e4 19 11 80 	mov    -0x7feee61c(,%eax,8),%eax
80101f7c:	85 c0                	test   %eax,%eax
80101f7e:	75 0a                	jne    80101f8a <writei+0x49>
      return -1;
80101f80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f85:	e9 44 01 00 00       	jmp    801020ce <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80101f8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f91:	98                   	cwtl   
80101f92:	8b 04 c5 e4 19 11 80 	mov    -0x7feee61c(,%eax,8),%eax
80101f99:	8b 55 14             	mov    0x14(%ebp),%edx
80101f9c:	89 54 24 08          	mov    %edx,0x8(%esp)
80101fa0:	8b 55 0c             	mov    0xc(%ebp),%edx
80101fa3:	89 54 24 04          	mov    %edx,0x4(%esp)
80101fa7:	8b 55 08             	mov    0x8(%ebp),%edx
80101faa:	89 14 24             	mov    %edx,(%esp)
80101fad:	ff d0                	call   *%eax
80101faf:	e9 1a 01 00 00       	jmp    801020ce <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
80101fb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb7:	8b 40 58             	mov    0x58(%eax),%eax
80101fba:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fbd:	72 0d                	jb     80101fcc <writei+0x8b>
80101fbf:	8b 45 14             	mov    0x14(%ebp),%eax
80101fc2:	8b 55 10             	mov    0x10(%ebp),%edx
80101fc5:	01 d0                	add    %edx,%eax
80101fc7:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fca:	73 0a                	jae    80101fd6 <writei+0x95>
    return -1;
80101fcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fd1:	e9 f8 00 00 00       	jmp    801020ce <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
80101fd6:	8b 45 14             	mov    0x14(%ebp),%eax
80101fd9:	8b 55 10             	mov    0x10(%ebp),%edx
80101fdc:	01 d0                	add    %edx,%eax
80101fde:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101fe3:	76 0a                	jbe    80101fef <writei+0xae>
    return -1;
80101fe5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fea:	e9 df 00 00 00       	jmp    801020ce <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101fef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ff6:	e9 9f 00 00 00       	jmp    8010209a <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101ffb:	8b 45 10             	mov    0x10(%ebp),%eax
80101ffe:	c1 e8 09             	shr    $0x9,%eax
80102001:	89 44 24 04          	mov    %eax,0x4(%esp)
80102005:	8b 45 08             	mov    0x8(%ebp),%eax
80102008:	89 04 24             	mov    %eax,(%esp)
8010200b:	e8 50 fb ff ff       	call   80101b60 <bmap>
80102010:	8b 55 08             	mov    0x8(%ebp),%edx
80102013:	8b 12                	mov    (%edx),%edx
80102015:	89 44 24 04          	mov    %eax,0x4(%esp)
80102019:	89 14 24             	mov    %edx,(%esp)
8010201c:	e8 94 e1 ff ff       	call   801001b5 <bread>
80102021:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102024:	8b 45 10             	mov    0x10(%ebp),%eax
80102027:	25 ff 01 00 00       	and    $0x1ff,%eax
8010202c:	89 c2                	mov    %eax,%edx
8010202e:	b8 00 02 00 00       	mov    $0x200,%eax
80102033:	29 d0                	sub    %edx,%eax
80102035:	89 c2                	mov    %eax,%edx
80102037:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010203a:	8b 4d 14             	mov    0x14(%ebp),%ecx
8010203d:	29 c1                	sub    %eax,%ecx
8010203f:	89 c8                	mov    %ecx,%eax
80102041:	39 c2                	cmp    %eax,%edx
80102043:	0f 46 c2             	cmovbe %edx,%eax
80102046:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102049:	8b 45 10             	mov    0x10(%ebp),%eax
8010204c:	25 ff 01 00 00       	and    $0x1ff,%eax
80102051:	8d 50 50             	lea    0x50(%eax),%edx
80102054:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102057:	01 d0                	add    %edx,%eax
80102059:	8d 50 0c             	lea    0xc(%eax),%edx
8010205c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010205f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102063:	8b 45 0c             	mov    0xc(%ebp),%eax
80102066:	89 44 24 04          	mov    %eax,0x4(%esp)
8010206a:	89 14 24             	mov    %edx,(%esp)
8010206d:	e8 2b 30 00 00       	call   8010509d <memmove>
    log_write(bp);
80102072:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102075:	89 04 24             	mov    %eax,(%esp)
80102078:	e8 f8 15 00 00       	call   80103675 <log_write>
    brelse(bp);
8010207d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102080:	89 04 24             	mov    %eax,(%esp)
80102083:	e8 a4 e1 ff ff       	call   8010022c <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102088:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010208b:	01 45 f4             	add    %eax,-0xc(%ebp)
8010208e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102091:	01 45 10             	add    %eax,0x10(%ebp)
80102094:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102097:	01 45 0c             	add    %eax,0xc(%ebp)
8010209a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010209d:	3b 45 14             	cmp    0x14(%ebp),%eax
801020a0:	0f 82 55 ff ff ff    	jb     80101ffb <writei+0xba>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
801020a6:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801020aa:	74 1f                	je     801020cb <writei+0x18a>
801020ac:	8b 45 08             	mov    0x8(%ebp),%eax
801020af:	8b 40 58             	mov    0x58(%eax),%eax
801020b2:	3b 45 10             	cmp    0x10(%ebp),%eax
801020b5:	73 14                	jae    801020cb <writei+0x18a>
    ip->size = off;
801020b7:	8b 45 08             	mov    0x8(%ebp),%eax
801020ba:	8b 55 10             	mov    0x10(%ebp),%edx
801020bd:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801020c0:	8b 45 08             	mov    0x8(%ebp),%eax
801020c3:	89 04 24             	mov    %eax,(%esp)
801020c6:	e8 b0 f6 ff ff       	call   8010177b <iupdate>
  }
  return n;
801020cb:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020ce:	c9                   	leave  
801020cf:	c3                   	ret    

801020d0 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801020d0:	55                   	push   %ebp
801020d1:	89 e5                	mov    %esp,%ebp
801020d3:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
801020d6:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801020dd:	00 
801020de:	8b 45 0c             	mov    0xc(%ebp),%eax
801020e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801020e5:	8b 45 08             	mov    0x8(%ebp),%eax
801020e8:	89 04 24             	mov    %eax,(%esp)
801020eb:	e8 50 30 00 00       	call   80105140 <strncmp>
}
801020f0:	c9                   	leave  
801020f1:	c3                   	ret    

801020f2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801020f2:	55                   	push   %ebp
801020f3:	89 e5                	mov    %esp,%ebp
801020f5:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801020f8:	8b 45 08             	mov    0x8(%ebp),%eax
801020fb:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801020ff:	66 83 f8 01          	cmp    $0x1,%ax
80102103:	74 0c                	je     80102111 <dirlookup+0x1f>
    panic("dirlookup not DIR");
80102105:	c7 04 24 b9 85 10 80 	movl   $0x801085b9,(%esp)
8010210c:	e8 51 e4 ff ff       	call   80100562 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102111:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102118:	e9 88 00 00 00       	jmp    801021a5 <dirlookup+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010211d:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102124:	00 
80102125:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102128:	89 44 24 08          	mov    %eax,0x8(%esp)
8010212c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010212f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102133:	8b 45 08             	mov    0x8(%ebp),%eax
80102136:	89 04 24             	mov    %eax,(%esp)
80102139:	e8 9f fc ff ff       	call   80101ddd <readi>
8010213e:	83 f8 10             	cmp    $0x10,%eax
80102141:	74 0c                	je     8010214f <dirlookup+0x5d>
      panic("dirlookup read");
80102143:	c7 04 24 cb 85 10 80 	movl   $0x801085cb,(%esp)
8010214a:	e8 13 e4 ff ff       	call   80100562 <panic>
    if(de.inum == 0)
8010214f:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102153:	66 85 c0             	test   %ax,%ax
80102156:	75 02                	jne    8010215a <dirlookup+0x68>
      continue;
80102158:	eb 47                	jmp    801021a1 <dirlookup+0xaf>
    if(namecmp(name, de.name) == 0){
8010215a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010215d:	83 c0 02             	add    $0x2,%eax
80102160:	89 44 24 04          	mov    %eax,0x4(%esp)
80102164:	8b 45 0c             	mov    0xc(%ebp),%eax
80102167:	89 04 24             	mov    %eax,(%esp)
8010216a:	e8 61 ff ff ff       	call   801020d0 <namecmp>
8010216f:	85 c0                	test   %eax,%eax
80102171:	75 2e                	jne    801021a1 <dirlookup+0xaf>
      // entry matches path element
      if(poff)
80102173:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102177:	74 08                	je     80102181 <dirlookup+0x8f>
        *poff = off;
80102179:	8b 45 10             	mov    0x10(%ebp),%eax
8010217c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010217f:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102181:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102185:	0f b7 c0             	movzwl %ax,%eax
80102188:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010218b:	8b 45 08             	mov    0x8(%ebp),%eax
8010218e:	8b 00                	mov    (%eax),%eax
80102190:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102193:	89 54 24 04          	mov    %edx,0x4(%esp)
80102197:	89 04 24             	mov    %eax,(%esp)
8010219a:	e8 9a f6 ff ff       	call   80101839 <iget>
8010219f:	eb 18                	jmp    801021b9 <dirlookup+0xc7>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
801021a1:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801021a5:	8b 45 08             	mov    0x8(%ebp),%eax
801021a8:	8b 40 58             	mov    0x58(%eax),%eax
801021ab:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801021ae:	0f 87 69 ff ff ff    	ja     8010211d <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
801021b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801021b9:	c9                   	leave  
801021ba:	c3                   	ret    

801021bb <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801021bb:	55                   	push   %ebp
801021bc:	89 e5                	mov    %esp,%ebp
801021be:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801021c1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801021c8:	00 
801021c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801021cc:	89 44 24 04          	mov    %eax,0x4(%esp)
801021d0:	8b 45 08             	mov    0x8(%ebp),%eax
801021d3:	89 04 24             	mov    %eax,(%esp)
801021d6:	e8 17 ff ff ff       	call   801020f2 <dirlookup>
801021db:	89 45 f0             	mov    %eax,-0x10(%ebp)
801021de:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801021e2:	74 15                	je     801021f9 <dirlink+0x3e>
    iput(ip);
801021e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021e7:	89 04 24             	mov    %eax,(%esp)
801021ea:	e8 a2 f8 ff ff       	call   80101a91 <iput>
    return -1;
801021ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021f4:	e9 b7 00 00 00       	jmp    801022b0 <dirlink+0xf5>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801021f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102200:	eb 46                	jmp    80102248 <dirlink+0x8d>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102202:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102205:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010220c:	00 
8010220d:	89 44 24 08          	mov    %eax,0x8(%esp)
80102211:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102214:	89 44 24 04          	mov    %eax,0x4(%esp)
80102218:	8b 45 08             	mov    0x8(%ebp),%eax
8010221b:	89 04 24             	mov    %eax,(%esp)
8010221e:	e8 ba fb ff ff       	call   80101ddd <readi>
80102223:	83 f8 10             	cmp    $0x10,%eax
80102226:	74 0c                	je     80102234 <dirlink+0x79>
      panic("dirlink read");
80102228:	c7 04 24 da 85 10 80 	movl   $0x801085da,(%esp)
8010222f:	e8 2e e3 ff ff       	call   80100562 <panic>
    if(de.inum == 0)
80102234:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102238:	66 85 c0             	test   %ax,%ax
8010223b:	75 02                	jne    8010223f <dirlink+0x84>
      break;
8010223d:	eb 16                	jmp    80102255 <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010223f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102242:	83 c0 10             	add    $0x10,%eax
80102245:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102248:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010224b:	8b 45 08             	mov    0x8(%ebp),%eax
8010224e:	8b 40 58             	mov    0x58(%eax),%eax
80102251:	39 c2                	cmp    %eax,%edx
80102253:	72 ad                	jb     80102202 <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
80102255:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010225c:	00 
8010225d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102260:	89 44 24 04          	mov    %eax,0x4(%esp)
80102264:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102267:	83 c0 02             	add    $0x2,%eax
8010226a:	89 04 24             	mov    %eax,(%esp)
8010226d:	e8 24 2f 00 00       	call   80105196 <strncpy>
  de.inum = inum;
80102272:	8b 45 10             	mov    0x10(%ebp),%eax
80102275:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102279:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010227c:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102283:	00 
80102284:	89 44 24 08          	mov    %eax,0x8(%esp)
80102288:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010228b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010228f:	8b 45 08             	mov    0x8(%ebp),%eax
80102292:	89 04 24             	mov    %eax,(%esp)
80102295:	e8 a7 fc ff ff       	call   80101f41 <writei>
8010229a:	83 f8 10             	cmp    $0x10,%eax
8010229d:	74 0c                	je     801022ab <dirlink+0xf0>
    panic("dirlink");
8010229f:	c7 04 24 e7 85 10 80 	movl   $0x801085e7,(%esp)
801022a6:	e8 b7 e2 ff ff       	call   80100562 <panic>

  return 0;
801022ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022b0:	c9                   	leave  
801022b1:	c3                   	ret    

801022b2 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801022b2:	55                   	push   %ebp
801022b3:	89 e5                	mov    %esp,%ebp
801022b5:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
801022b8:	eb 04                	jmp    801022be <skipelem+0xc>
    path++;
801022ba:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
801022be:	8b 45 08             	mov    0x8(%ebp),%eax
801022c1:	0f b6 00             	movzbl (%eax),%eax
801022c4:	3c 2f                	cmp    $0x2f,%al
801022c6:	74 f2                	je     801022ba <skipelem+0x8>
    path++;
  if(*path == 0)
801022c8:	8b 45 08             	mov    0x8(%ebp),%eax
801022cb:	0f b6 00             	movzbl (%eax),%eax
801022ce:	84 c0                	test   %al,%al
801022d0:	75 0a                	jne    801022dc <skipelem+0x2a>
    return 0;
801022d2:	b8 00 00 00 00       	mov    $0x0,%eax
801022d7:	e9 86 00 00 00       	jmp    80102362 <skipelem+0xb0>
  s = path;
801022dc:	8b 45 08             	mov    0x8(%ebp),%eax
801022df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801022e2:	eb 04                	jmp    801022e8 <skipelem+0x36>
    path++;
801022e4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801022e8:	8b 45 08             	mov    0x8(%ebp),%eax
801022eb:	0f b6 00             	movzbl (%eax),%eax
801022ee:	3c 2f                	cmp    $0x2f,%al
801022f0:	74 0a                	je     801022fc <skipelem+0x4a>
801022f2:	8b 45 08             	mov    0x8(%ebp),%eax
801022f5:	0f b6 00             	movzbl (%eax),%eax
801022f8:	84 c0                	test   %al,%al
801022fa:	75 e8                	jne    801022e4 <skipelem+0x32>
    path++;
  len = path - s;
801022fc:	8b 55 08             	mov    0x8(%ebp),%edx
801022ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102302:	29 c2                	sub    %eax,%edx
80102304:	89 d0                	mov    %edx,%eax
80102306:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102309:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010230d:	7e 1c                	jle    8010232b <skipelem+0x79>
    memmove(name, s, DIRSIZ);
8010230f:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102316:	00 
80102317:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010231a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010231e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102321:	89 04 24             	mov    %eax,(%esp)
80102324:	e8 74 2d 00 00       	call   8010509d <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102329:	eb 2a                	jmp    80102355 <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
8010232b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010232e:	89 44 24 08          	mov    %eax,0x8(%esp)
80102332:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102335:	89 44 24 04          	mov    %eax,0x4(%esp)
80102339:	8b 45 0c             	mov    0xc(%ebp),%eax
8010233c:	89 04 24             	mov    %eax,(%esp)
8010233f:	e8 59 2d 00 00       	call   8010509d <memmove>
    name[len] = 0;
80102344:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102347:	8b 45 0c             	mov    0xc(%ebp),%eax
8010234a:	01 d0                	add    %edx,%eax
8010234c:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010234f:	eb 04                	jmp    80102355 <skipelem+0xa3>
    path++;
80102351:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102355:	8b 45 08             	mov    0x8(%ebp),%eax
80102358:	0f b6 00             	movzbl (%eax),%eax
8010235b:	3c 2f                	cmp    $0x2f,%al
8010235d:	74 f2                	je     80102351 <skipelem+0x9f>
    path++;
  return path;
8010235f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102362:	c9                   	leave  
80102363:	c3                   	ret    

80102364 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102364:	55                   	push   %ebp
80102365:	89 e5                	mov    %esp,%ebp
80102367:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010236a:	8b 45 08             	mov    0x8(%ebp),%eax
8010236d:	0f b6 00             	movzbl (%eax),%eax
80102370:	3c 2f                	cmp    $0x2f,%al
80102372:	75 1c                	jne    80102390 <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
80102374:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010237b:	00 
8010237c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102383:	e8 b1 f4 ff ff       	call   80101839 <iget>
80102388:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
8010238b:	e9 ae 00 00 00       	jmp    8010243e <namex+0xda>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80102390:	e8 b4 1d 00 00       	call   80104149 <myproc>
80102395:	8b 40 6c             	mov    0x6c(%eax),%eax
80102398:	89 04 24             	mov    %eax,(%esp)
8010239b:	e8 6e f5 ff ff       	call   8010190e <idup>
801023a0:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801023a3:	e9 96 00 00 00       	jmp    8010243e <namex+0xda>
    ilock(ip);
801023a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023ab:	89 04 24             	mov    %eax,(%esp)
801023ae:	e8 8d f5 ff ff       	call   80101940 <ilock>
    if(ip->type != T_DIR){
801023b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023b6:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801023ba:	66 83 f8 01          	cmp    $0x1,%ax
801023be:	74 15                	je     801023d5 <namex+0x71>
      iunlockput(ip);
801023c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023c3:	89 04 24             	mov    %eax,(%esp)
801023c6:	e8 77 f7 ff ff       	call   80101b42 <iunlockput>
      return 0;
801023cb:	b8 00 00 00 00       	mov    $0x0,%eax
801023d0:	e9 a3 00 00 00       	jmp    80102478 <namex+0x114>
    }
    if(nameiparent && *path == '\0'){
801023d5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801023d9:	74 1d                	je     801023f8 <namex+0x94>
801023db:	8b 45 08             	mov    0x8(%ebp),%eax
801023de:	0f b6 00             	movzbl (%eax),%eax
801023e1:	84 c0                	test   %al,%al
801023e3:	75 13                	jne    801023f8 <namex+0x94>
      // Stop one level early.
      iunlock(ip);
801023e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023e8:	89 04 24             	mov    %eax,(%esp)
801023eb:	e8 5d f6 ff ff       	call   80101a4d <iunlock>
      return ip;
801023f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f3:	e9 80 00 00 00       	jmp    80102478 <namex+0x114>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801023f8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801023ff:	00 
80102400:	8b 45 10             	mov    0x10(%ebp),%eax
80102403:	89 44 24 04          	mov    %eax,0x4(%esp)
80102407:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010240a:	89 04 24             	mov    %eax,(%esp)
8010240d:	e8 e0 fc ff ff       	call   801020f2 <dirlookup>
80102412:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102415:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102419:	75 12                	jne    8010242d <namex+0xc9>
      iunlockput(ip);
8010241b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010241e:	89 04 24             	mov    %eax,(%esp)
80102421:	e8 1c f7 ff ff       	call   80101b42 <iunlockput>
      return 0;
80102426:	b8 00 00 00 00       	mov    $0x0,%eax
8010242b:	eb 4b                	jmp    80102478 <namex+0x114>
    }
    iunlockput(ip);
8010242d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102430:	89 04 24             	mov    %eax,(%esp)
80102433:	e8 0a f7 ff ff       	call   80101b42 <iunlockput>
    ip = next;
80102438:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010243b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
8010243e:	8b 45 10             	mov    0x10(%ebp),%eax
80102441:	89 44 24 04          	mov    %eax,0x4(%esp)
80102445:	8b 45 08             	mov    0x8(%ebp),%eax
80102448:	89 04 24             	mov    %eax,(%esp)
8010244b:	e8 62 fe ff ff       	call   801022b2 <skipelem>
80102450:	89 45 08             	mov    %eax,0x8(%ebp)
80102453:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102457:	0f 85 4b ff ff ff    	jne    801023a8 <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
8010245d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102461:	74 12                	je     80102475 <namex+0x111>
    iput(ip);
80102463:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102466:	89 04 24             	mov    %eax,(%esp)
80102469:	e8 23 f6 ff ff       	call   80101a91 <iput>
    return 0;
8010246e:	b8 00 00 00 00       	mov    $0x0,%eax
80102473:	eb 03                	jmp    80102478 <namex+0x114>
  }
  return ip;
80102475:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102478:	c9                   	leave  
80102479:	c3                   	ret    

8010247a <namei>:

struct inode*
namei(char *path)
{
8010247a:	55                   	push   %ebp
8010247b:	89 e5                	mov    %esp,%ebp
8010247d:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102480:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102483:	89 44 24 08          	mov    %eax,0x8(%esp)
80102487:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010248e:	00 
8010248f:	8b 45 08             	mov    0x8(%ebp),%eax
80102492:	89 04 24             	mov    %eax,(%esp)
80102495:	e8 ca fe ff ff       	call   80102364 <namex>
}
8010249a:	c9                   	leave  
8010249b:	c3                   	ret    

8010249c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010249c:	55                   	push   %ebp
8010249d:	89 e5                	mov    %esp,%ebp
8010249f:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
801024a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801024a5:	89 44 24 08          	mov    %eax,0x8(%esp)
801024a9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801024b0:	00 
801024b1:	8b 45 08             	mov    0x8(%ebp),%eax
801024b4:	89 04 24             	mov    %eax,(%esp)
801024b7:	e8 a8 fe ff ff       	call   80102364 <namex>
}
801024bc:	c9                   	leave  
801024bd:	c3                   	ret    

801024be <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801024be:	55                   	push   %ebp
801024bf:	89 e5                	mov    %esp,%ebp
801024c1:	83 ec 14             	sub    $0x14,%esp
801024c4:	8b 45 08             	mov    0x8(%ebp),%eax
801024c7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801024cb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801024cf:	89 c2                	mov    %eax,%edx
801024d1:	ec                   	in     (%dx),%al
801024d2:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801024d5:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801024d9:	c9                   	leave  
801024da:	c3                   	ret    

801024db <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801024db:	55                   	push   %ebp
801024dc:	89 e5                	mov    %esp,%ebp
801024de:	57                   	push   %edi
801024df:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801024e0:	8b 55 08             	mov    0x8(%ebp),%edx
801024e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024e6:	8b 45 10             	mov    0x10(%ebp),%eax
801024e9:	89 cb                	mov    %ecx,%ebx
801024eb:	89 df                	mov    %ebx,%edi
801024ed:	89 c1                	mov    %eax,%ecx
801024ef:	fc                   	cld    
801024f0:	f3 6d                	rep insl (%dx),%es:(%edi)
801024f2:	89 c8                	mov    %ecx,%eax
801024f4:	89 fb                	mov    %edi,%ebx
801024f6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024f9:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801024fc:	5b                   	pop    %ebx
801024fd:	5f                   	pop    %edi
801024fe:	5d                   	pop    %ebp
801024ff:	c3                   	ret    

80102500 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102500:	55                   	push   %ebp
80102501:	89 e5                	mov    %esp,%ebp
80102503:	83 ec 08             	sub    $0x8,%esp
80102506:	8b 55 08             	mov    0x8(%ebp),%edx
80102509:	8b 45 0c             	mov    0xc(%ebp),%eax
8010250c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102510:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102513:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102517:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010251b:	ee                   	out    %al,(%dx)
}
8010251c:	c9                   	leave  
8010251d:	c3                   	ret    

8010251e <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
8010251e:	55                   	push   %ebp
8010251f:	89 e5                	mov    %esp,%ebp
80102521:	56                   	push   %esi
80102522:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102523:	8b 55 08             	mov    0x8(%ebp),%edx
80102526:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102529:	8b 45 10             	mov    0x10(%ebp),%eax
8010252c:	89 cb                	mov    %ecx,%ebx
8010252e:	89 de                	mov    %ebx,%esi
80102530:	89 c1                	mov    %eax,%ecx
80102532:	fc                   	cld    
80102533:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102535:	89 c8                	mov    %ecx,%eax
80102537:	89 f3                	mov    %esi,%ebx
80102539:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010253c:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
8010253f:	5b                   	pop    %ebx
80102540:	5e                   	pop    %esi
80102541:	5d                   	pop    %ebp
80102542:	c3                   	ret    

80102543 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102543:	55                   	push   %ebp
80102544:	89 e5                	mov    %esp,%ebp
80102546:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102549:	90                   	nop
8010254a:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102551:	e8 68 ff ff ff       	call   801024be <inb>
80102556:	0f b6 c0             	movzbl %al,%eax
80102559:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010255c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010255f:	25 c0 00 00 00       	and    $0xc0,%eax
80102564:	83 f8 40             	cmp    $0x40,%eax
80102567:	75 e1                	jne    8010254a <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102569:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010256d:	74 11                	je     80102580 <idewait+0x3d>
8010256f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102572:	83 e0 21             	and    $0x21,%eax
80102575:	85 c0                	test   %eax,%eax
80102577:	74 07                	je     80102580 <idewait+0x3d>
    return -1;
80102579:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010257e:	eb 05                	jmp    80102585 <idewait+0x42>
  return 0;
80102580:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102585:	c9                   	leave  
80102586:	c3                   	ret    

80102587 <ideinit>:

void
ideinit(void)
{
80102587:	55                   	push   %ebp
80102588:	89 e5                	mov    %esp,%ebp
8010258a:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
8010258d:	c7 44 24 04 ef 85 10 	movl   $0x801085ef,0x4(%esp)
80102594:	80 
80102595:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
8010259c:	e8 aa 27 00 00       	call   80104d4b <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
801025a1:	a1 80 3d 11 80       	mov    0x80113d80,%eax
801025a6:	83 e8 01             	sub    $0x1,%eax
801025a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801025ad:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801025b4:	e8 69 04 00 00       	call   80102a22 <ioapicenable>
  idewait(0);
801025b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801025c0:	e8 7e ff ff ff       	call   80102543 <idewait>

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801025c5:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
801025cc:	00 
801025cd:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025d4:	e8 27 ff ff ff       	call   80102500 <outb>
  for(i=0; i<1000; i++){
801025d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025e0:	eb 20                	jmp    80102602 <ideinit+0x7b>
    if(inb(0x1f7) != 0){
801025e2:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801025e9:	e8 d0 fe ff ff       	call   801024be <inb>
801025ee:	84 c0                	test   %al,%al
801025f0:	74 0c                	je     801025fe <ideinit+0x77>
      havedisk1 = 1;
801025f2:	c7 05 18 b6 10 80 01 	movl   $0x1,0x8010b618
801025f9:	00 00 00 
      break;
801025fc:	eb 0d                	jmp    8010260b <ideinit+0x84>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801025fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102602:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102609:	7e d7                	jle    801025e2 <ideinit+0x5b>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010260b:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102612:	00 
80102613:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010261a:	e8 e1 fe ff ff       	call   80102500 <outb>
}
8010261f:	c9                   	leave  
80102620:	c3                   	ret    

80102621 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102621:	55                   	push   %ebp
80102622:	89 e5                	mov    %esp,%ebp
80102624:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
80102627:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010262b:	75 0c                	jne    80102639 <idestart+0x18>
    panic("idestart");
8010262d:	c7 04 24 f3 85 10 80 	movl   $0x801085f3,(%esp)
80102634:	e8 29 df ff ff       	call   80100562 <panic>
  if(b->blockno >= FSSIZE)
80102639:	8b 45 08             	mov    0x8(%ebp),%eax
8010263c:	8b 40 08             	mov    0x8(%eax),%eax
8010263f:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102644:	76 0c                	jbe    80102652 <idestart+0x31>
    panic("incorrect blockno");
80102646:	c7 04 24 fc 85 10 80 	movl   $0x801085fc,(%esp)
8010264d:	e8 10 df ff ff       	call   80100562 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102652:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102659:	8b 45 08             	mov    0x8(%ebp),%eax
8010265c:	8b 50 08             	mov    0x8(%eax),%edx
8010265f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102662:	0f af c2             	imul   %edx,%eax
80102665:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
80102668:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010266c:	75 07                	jne    80102675 <idestart+0x54>
8010266e:	b8 20 00 00 00       	mov    $0x20,%eax
80102673:	eb 05                	jmp    8010267a <idestart+0x59>
80102675:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010267a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
8010267d:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102681:	75 07                	jne    8010268a <idestart+0x69>
80102683:	b8 30 00 00 00       	mov    $0x30,%eax
80102688:	eb 05                	jmp    8010268f <idestart+0x6e>
8010268a:	b8 c5 00 00 00       	mov    $0xc5,%eax
8010268f:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102692:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102696:	7e 0c                	jle    801026a4 <idestart+0x83>
80102698:	c7 04 24 f3 85 10 80 	movl   $0x801085f3,(%esp)
8010269f:	e8 be de ff ff       	call   80100562 <panic>

  idewait(0);
801026a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801026ab:	e8 93 fe ff ff       	call   80102543 <idewait>
  outb(0x3f6, 0);  // generate interrupt
801026b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801026b7:	00 
801026b8:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
801026bf:	e8 3c fe ff ff       	call   80102500 <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
801026c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026c7:	0f b6 c0             	movzbl %al,%eax
801026ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801026ce:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
801026d5:	e8 26 fe ff ff       	call   80102500 <outb>
  outb(0x1f3, sector & 0xff);
801026da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026dd:	0f b6 c0             	movzbl %al,%eax
801026e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801026e4:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
801026eb:	e8 10 fe ff ff       	call   80102500 <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
801026f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026f3:	c1 f8 08             	sar    $0x8,%eax
801026f6:	0f b6 c0             	movzbl %al,%eax
801026f9:	89 44 24 04          	mov    %eax,0x4(%esp)
801026fd:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102704:	e8 f7 fd ff ff       	call   80102500 <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
80102709:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010270c:	c1 f8 10             	sar    $0x10,%eax
8010270f:	0f b6 c0             	movzbl %al,%eax
80102712:	89 44 24 04          	mov    %eax,0x4(%esp)
80102716:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
8010271d:	e8 de fd ff ff       	call   80102500 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102722:	8b 45 08             	mov    0x8(%ebp),%eax
80102725:	8b 40 04             	mov    0x4(%eax),%eax
80102728:	83 e0 01             	and    $0x1,%eax
8010272b:	c1 e0 04             	shl    $0x4,%eax
8010272e:	89 c2                	mov    %eax,%edx
80102730:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102733:	c1 f8 18             	sar    $0x18,%eax
80102736:	83 e0 0f             	and    $0xf,%eax
80102739:	09 d0                	or     %edx,%eax
8010273b:	83 c8 e0             	or     $0xffffffe0,%eax
8010273e:	0f b6 c0             	movzbl %al,%eax
80102741:	89 44 24 04          	mov    %eax,0x4(%esp)
80102745:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010274c:	e8 af fd ff ff       	call   80102500 <outb>
  if(b->flags & B_DIRTY){
80102751:	8b 45 08             	mov    0x8(%ebp),%eax
80102754:	8b 00                	mov    (%eax),%eax
80102756:	83 e0 04             	and    $0x4,%eax
80102759:	85 c0                	test   %eax,%eax
8010275b:	74 36                	je     80102793 <idestart+0x172>
    outb(0x1f7, write_cmd);
8010275d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102760:	0f b6 c0             	movzbl %al,%eax
80102763:	89 44 24 04          	mov    %eax,0x4(%esp)
80102767:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010276e:	e8 8d fd ff ff       	call   80102500 <outb>
    outsl(0x1f0, b->data, BSIZE/4);
80102773:	8b 45 08             	mov    0x8(%ebp),%eax
80102776:	83 c0 5c             	add    $0x5c,%eax
80102779:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102780:	00 
80102781:	89 44 24 04          	mov    %eax,0x4(%esp)
80102785:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010278c:	e8 8d fd ff ff       	call   8010251e <outsl>
80102791:	eb 16                	jmp    801027a9 <idestart+0x188>
  } else {
    outb(0x1f7, read_cmd);
80102793:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102796:	0f b6 c0             	movzbl %al,%eax
80102799:	89 44 24 04          	mov    %eax,0x4(%esp)
8010279d:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801027a4:	e8 57 fd ff ff       	call   80102500 <outb>
  }
}
801027a9:	c9                   	leave  
801027aa:	c3                   	ret    

801027ab <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801027ab:	55                   	push   %ebp
801027ac:	89 e5                	mov    %esp,%ebp
801027ae:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801027b1:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801027b8:	e8 af 25 00 00       	call   80104d6c <acquire>

  if((b = idequeue) == 0){
801027bd:	a1 14 b6 10 80       	mov    0x8010b614,%eax
801027c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801027c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027c9:	75 11                	jne    801027dc <ideintr+0x31>
    release(&idelock);
801027cb:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801027d2:	e8 fd 25 00 00       	call   80104dd4 <release>
    return;
801027d7:	e9 90 00 00 00       	jmp    8010286c <ideintr+0xc1>
  }
  idequeue = b->qnext;
801027dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027df:	8b 40 58             	mov    0x58(%eax),%eax
801027e2:	a3 14 b6 10 80       	mov    %eax,0x8010b614

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801027e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027ea:	8b 00                	mov    (%eax),%eax
801027ec:	83 e0 04             	and    $0x4,%eax
801027ef:	85 c0                	test   %eax,%eax
801027f1:	75 2e                	jne    80102821 <ideintr+0x76>
801027f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801027fa:	e8 44 fd ff ff       	call   80102543 <idewait>
801027ff:	85 c0                	test   %eax,%eax
80102801:	78 1e                	js     80102821 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
80102803:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102806:	83 c0 5c             	add    $0x5c,%eax
80102809:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102810:	00 
80102811:	89 44 24 04          	mov    %eax,0x4(%esp)
80102815:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010281c:	e8 ba fc ff ff       	call   801024db <insl>

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102821:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102824:	8b 00                	mov    (%eax),%eax
80102826:	83 c8 02             	or     $0x2,%eax
80102829:	89 c2                	mov    %eax,%edx
8010282b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282e:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102833:	8b 00                	mov    (%eax),%eax
80102835:	83 e0 fb             	and    $0xfffffffb,%eax
80102838:	89 c2                	mov    %eax,%edx
8010283a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010283d:	89 10                	mov    %edx,(%eax)
  wakeup(b);
8010283f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102842:	89 04 24             	mov    %eax,(%esp)
80102845:	e8 2b 22 00 00       	call   80104a75 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
8010284a:	a1 14 b6 10 80       	mov    0x8010b614,%eax
8010284f:	85 c0                	test   %eax,%eax
80102851:	74 0d                	je     80102860 <ideintr+0xb5>
    idestart(idequeue);
80102853:	a1 14 b6 10 80       	mov    0x8010b614,%eax
80102858:	89 04 24             	mov    %eax,(%esp)
8010285b:	e8 c1 fd ff ff       	call   80102621 <idestart>

  release(&idelock);
80102860:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80102867:	e8 68 25 00 00       	call   80104dd4 <release>
}
8010286c:	c9                   	leave  
8010286d:	c3                   	ret    

8010286e <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010286e:	55                   	push   %ebp
8010286f:	89 e5                	mov    %esp,%ebp
80102871:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102874:	8b 45 08             	mov    0x8(%ebp),%eax
80102877:	83 c0 0c             	add    $0xc,%eax
8010287a:	89 04 24             	mov    %eax,(%esp)
8010287d:	e8 64 24 00 00       	call   80104ce6 <holdingsleep>
80102882:	85 c0                	test   %eax,%eax
80102884:	75 0c                	jne    80102892 <iderw+0x24>
    panic("iderw: buf not locked");
80102886:	c7 04 24 0e 86 10 80 	movl   $0x8010860e,(%esp)
8010288d:	e8 d0 dc ff ff       	call   80100562 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102892:	8b 45 08             	mov    0x8(%ebp),%eax
80102895:	8b 00                	mov    (%eax),%eax
80102897:	83 e0 06             	and    $0x6,%eax
8010289a:	83 f8 02             	cmp    $0x2,%eax
8010289d:	75 0c                	jne    801028ab <iderw+0x3d>
    panic("iderw: nothing to do");
8010289f:	c7 04 24 24 86 10 80 	movl   $0x80108624,(%esp)
801028a6:	e8 b7 dc ff ff       	call   80100562 <panic>
  if(b->dev != 0 && !havedisk1)
801028ab:	8b 45 08             	mov    0x8(%ebp),%eax
801028ae:	8b 40 04             	mov    0x4(%eax),%eax
801028b1:	85 c0                	test   %eax,%eax
801028b3:	74 15                	je     801028ca <iderw+0x5c>
801028b5:	a1 18 b6 10 80       	mov    0x8010b618,%eax
801028ba:	85 c0                	test   %eax,%eax
801028bc:	75 0c                	jne    801028ca <iderw+0x5c>
    panic("iderw: ide disk 1 not present");
801028be:	c7 04 24 39 86 10 80 	movl   $0x80108639,(%esp)
801028c5:	e8 98 dc ff ff       	call   80100562 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801028ca:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801028d1:	e8 96 24 00 00       	call   80104d6c <acquire>

  // Append b to idequeue.
  b->qnext = 0;
801028d6:	8b 45 08             	mov    0x8(%ebp),%eax
801028d9:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801028e0:	c7 45 f4 14 b6 10 80 	movl   $0x8010b614,-0xc(%ebp)
801028e7:	eb 0b                	jmp    801028f4 <iderw+0x86>
801028e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ec:	8b 00                	mov    (%eax),%eax
801028ee:	83 c0 58             	add    $0x58,%eax
801028f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028f7:	8b 00                	mov    (%eax),%eax
801028f9:	85 c0                	test   %eax,%eax
801028fb:	75 ec                	jne    801028e9 <iderw+0x7b>
    ;
  *pp = b;
801028fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102900:	8b 55 08             	mov    0x8(%ebp),%edx
80102903:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102905:	a1 14 b6 10 80       	mov    0x8010b614,%eax
8010290a:	3b 45 08             	cmp    0x8(%ebp),%eax
8010290d:	75 0d                	jne    8010291c <iderw+0xae>
    idestart(b);
8010290f:	8b 45 08             	mov    0x8(%ebp),%eax
80102912:	89 04 24             	mov    %eax,(%esp)
80102915:	e8 07 fd ff ff       	call   80102621 <idestart>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010291a:	eb 15                	jmp    80102931 <iderw+0xc3>
8010291c:	eb 13                	jmp    80102931 <iderw+0xc3>
    sleep(b, &idelock);
8010291e:	c7 44 24 04 e0 b5 10 	movl   $0x8010b5e0,0x4(%esp)
80102925:	80 
80102926:	8b 45 08             	mov    0x8(%ebp),%eax
80102929:	89 04 24             	mov    %eax,(%esp)
8010292c:	e8 70 20 00 00       	call   801049a1 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102931:	8b 45 08             	mov    0x8(%ebp),%eax
80102934:	8b 00                	mov    (%eax),%eax
80102936:	83 e0 06             	and    $0x6,%eax
80102939:	83 f8 02             	cmp    $0x2,%eax
8010293c:	75 e0                	jne    8010291e <iderw+0xb0>
    sleep(b, &idelock);
  }


  release(&idelock);
8010293e:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80102945:	e8 8a 24 00 00       	call   80104dd4 <release>
}
8010294a:	c9                   	leave  
8010294b:	c3                   	ret    

8010294c <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
8010294c:	55                   	push   %ebp
8010294d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010294f:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102954:	8b 55 08             	mov    0x8(%ebp),%edx
80102957:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102959:	a1 b4 36 11 80       	mov    0x801136b4,%eax
8010295e:	8b 40 10             	mov    0x10(%eax),%eax
}
80102961:	5d                   	pop    %ebp
80102962:	c3                   	ret    

80102963 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102963:	55                   	push   %ebp
80102964:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102966:	a1 b4 36 11 80       	mov    0x801136b4,%eax
8010296b:	8b 55 08             	mov    0x8(%ebp),%edx
8010296e:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102970:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102975:	8b 55 0c             	mov    0xc(%ebp),%edx
80102978:	89 50 10             	mov    %edx,0x10(%eax)
}
8010297b:	5d                   	pop    %ebp
8010297c:	c3                   	ret    

8010297d <ioapicinit>:

void
ioapicinit(void)
{
8010297d:	55                   	push   %ebp
8010297e:	89 e5                	mov    %esp,%ebp
80102980:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102983:	c7 05 b4 36 11 80 00 	movl   $0xfec00000,0x801136b4
8010298a:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
8010298d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102994:	e8 b3 ff ff ff       	call   8010294c <ioapicread>
80102999:	c1 e8 10             	shr    $0x10,%eax
8010299c:	25 ff 00 00 00       	and    $0xff,%eax
801029a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801029a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801029ab:	e8 9c ff ff ff       	call   8010294c <ioapicread>
801029b0:	c1 e8 18             	shr    $0x18,%eax
801029b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801029b6:	0f b6 05 e0 37 11 80 	movzbl 0x801137e0,%eax
801029bd:	0f b6 c0             	movzbl %al,%eax
801029c0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801029c3:	74 0c                	je     801029d1 <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801029c5:	c7 04 24 58 86 10 80 	movl   $0x80108658,(%esp)
801029cc:	e8 f7 d9 ff ff       	call   801003c8 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801029d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801029d8:	eb 3e                	jmp    80102a18 <ioapicinit+0x9b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801029da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029dd:	83 c0 20             	add    $0x20,%eax
801029e0:	0d 00 00 01 00       	or     $0x10000,%eax
801029e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801029e8:	83 c2 08             	add    $0x8,%edx
801029eb:	01 d2                	add    %edx,%edx
801029ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801029f1:	89 14 24             	mov    %edx,(%esp)
801029f4:	e8 6a ff ff ff       	call   80102963 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
801029f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029fc:	83 c0 08             	add    $0x8,%eax
801029ff:	01 c0                	add    %eax,%eax
80102a01:	83 c0 01             	add    $0x1,%eax
80102a04:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102a0b:	00 
80102a0c:	89 04 24             	mov    %eax,(%esp)
80102a0f:	e8 4f ff ff ff       	call   80102963 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a14:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a1b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102a1e:	7e ba                	jle    801029da <ioapicinit+0x5d>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102a20:	c9                   	leave  
80102a21:	c3                   	ret    

80102a22 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102a22:	55                   	push   %ebp
80102a23:	89 e5                	mov    %esp,%ebp
80102a25:	83 ec 08             	sub    $0x8,%esp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102a28:	8b 45 08             	mov    0x8(%ebp),%eax
80102a2b:	83 c0 20             	add    $0x20,%eax
80102a2e:	8b 55 08             	mov    0x8(%ebp),%edx
80102a31:	83 c2 08             	add    $0x8,%edx
80102a34:	01 d2                	add    %edx,%edx
80102a36:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a3a:	89 14 24             	mov    %edx,(%esp)
80102a3d:	e8 21 ff ff ff       	call   80102963 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102a42:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a45:	c1 e0 18             	shl    $0x18,%eax
80102a48:	8b 55 08             	mov    0x8(%ebp),%edx
80102a4b:	83 c2 08             	add    $0x8,%edx
80102a4e:	01 d2                	add    %edx,%edx
80102a50:	83 c2 01             	add    $0x1,%edx
80102a53:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a57:	89 14 24             	mov    %edx,(%esp)
80102a5a:	e8 04 ff ff ff       	call   80102963 <ioapicwrite>
}
80102a5f:	c9                   	leave  
80102a60:	c3                   	ret    

80102a61 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102a61:	55                   	push   %ebp
80102a62:	89 e5                	mov    %esp,%ebp
80102a64:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102a67:	c7 44 24 04 8a 86 10 	movl   $0x8010868a,0x4(%esp)
80102a6e:	80 
80102a6f:	c7 04 24 c0 36 11 80 	movl   $0x801136c0,(%esp)
80102a76:	e8 d0 22 00 00       	call   80104d4b <initlock>
  kmem.use_lock = 0;
80102a7b:	c7 05 f4 36 11 80 00 	movl   $0x0,0x801136f4
80102a82:	00 00 00 
  freerange(vstart, vend);
80102a85:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a88:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a8c:	8b 45 08             	mov    0x8(%ebp),%eax
80102a8f:	89 04 24             	mov    %eax,(%esp)
80102a92:	e8 26 00 00 00       	call   80102abd <freerange>
}
80102a97:	c9                   	leave  
80102a98:	c3                   	ret    

80102a99 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102a99:	55                   	push   %ebp
80102a9a:	89 e5                	mov    %esp,%ebp
80102a9c:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102a9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102aa2:	89 44 24 04          	mov    %eax,0x4(%esp)
80102aa6:	8b 45 08             	mov    0x8(%ebp),%eax
80102aa9:	89 04 24             	mov    %eax,(%esp)
80102aac:	e8 0c 00 00 00       	call   80102abd <freerange>
  kmem.use_lock = 1;
80102ab1:	c7 05 f4 36 11 80 01 	movl   $0x1,0x801136f4
80102ab8:	00 00 00 
}
80102abb:	c9                   	leave  
80102abc:	c3                   	ret    

80102abd <freerange>:

void
freerange(void *vstart, void *vend)
{
80102abd:	55                   	push   %ebp
80102abe:	89 e5                	mov    %esp,%ebp
80102ac0:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102ac3:	8b 45 08             	mov    0x8(%ebp),%eax
80102ac6:	05 ff 0f 00 00       	add    $0xfff,%eax
80102acb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102ad0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102ad3:	eb 12                	jmp    80102ae7 <freerange+0x2a>
    kfree(p);
80102ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad8:	89 04 24             	mov    %eax,(%esp)
80102adb:	e8 16 00 00 00       	call   80102af6 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102ae0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aea:	05 00 10 00 00       	add    $0x1000,%eax
80102aef:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102af2:	76 e1                	jbe    80102ad5 <freerange+0x18>
    kfree(p);
}
80102af4:	c9                   	leave  
80102af5:	c3                   	ret    

80102af6 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102af6:	55                   	push   %ebp
80102af7:	89 e5                	mov    %esp,%ebp
80102af9:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102afc:	8b 45 08             	mov    0x8(%ebp),%eax
80102aff:	25 ff 0f 00 00       	and    $0xfff,%eax
80102b04:	85 c0                	test   %eax,%eax
80102b06:	75 18                	jne    80102b20 <kfree+0x2a>
80102b08:	81 7d 08 74 69 11 80 	cmpl   $0x80116974,0x8(%ebp)
80102b0f:	72 0f                	jb     80102b20 <kfree+0x2a>
80102b11:	8b 45 08             	mov    0x8(%ebp),%eax
80102b14:	05 00 00 00 80       	add    $0x80000000,%eax
80102b19:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102b1e:	76 0c                	jbe    80102b2c <kfree+0x36>
    panic("kfree");
80102b20:	c7 04 24 8f 86 10 80 	movl   $0x8010868f,(%esp)
80102b27:	e8 36 da ff ff       	call   80100562 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102b2c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102b33:	00 
80102b34:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102b3b:	00 
80102b3c:	8b 45 08             	mov    0x8(%ebp),%eax
80102b3f:	89 04 24             	mov    %eax,(%esp)
80102b42:	e8 87 24 00 00       	call   80104fce <memset>

  if(kmem.use_lock)
80102b47:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102b4c:	85 c0                	test   %eax,%eax
80102b4e:	74 0c                	je     80102b5c <kfree+0x66>
    acquire(&kmem.lock);
80102b50:	c7 04 24 c0 36 11 80 	movl   $0x801136c0,(%esp)
80102b57:	e8 10 22 00 00       	call   80104d6c <acquire>
  r = (struct run*)v;
80102b5c:	8b 45 08             	mov    0x8(%ebp),%eax
80102b5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102b62:	8b 15 f8 36 11 80    	mov    0x801136f8,%edx
80102b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b6b:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b70:	a3 f8 36 11 80       	mov    %eax,0x801136f8
  if(kmem.use_lock)
80102b75:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102b7a:	85 c0                	test   %eax,%eax
80102b7c:	74 0c                	je     80102b8a <kfree+0x94>
    release(&kmem.lock);
80102b7e:	c7 04 24 c0 36 11 80 	movl   $0x801136c0,(%esp)
80102b85:	e8 4a 22 00 00       	call   80104dd4 <release>
}
80102b8a:	c9                   	leave  
80102b8b:	c3                   	ret    

80102b8c <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102b8c:	55                   	push   %ebp
80102b8d:	89 e5                	mov    %esp,%ebp
80102b8f:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102b92:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102b97:	85 c0                	test   %eax,%eax
80102b99:	74 0c                	je     80102ba7 <kalloc+0x1b>
    acquire(&kmem.lock);
80102b9b:	c7 04 24 c0 36 11 80 	movl   $0x801136c0,(%esp)
80102ba2:	e8 c5 21 00 00       	call   80104d6c <acquire>
  r = kmem.freelist;
80102ba7:	a1 f8 36 11 80       	mov    0x801136f8,%eax
80102bac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102baf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102bb3:	74 0a                	je     80102bbf <kalloc+0x33>
    kmem.freelist = r->next;
80102bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bb8:	8b 00                	mov    (%eax),%eax
80102bba:	a3 f8 36 11 80       	mov    %eax,0x801136f8
  if(kmem.use_lock)
80102bbf:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102bc4:	85 c0                	test   %eax,%eax
80102bc6:	74 0c                	je     80102bd4 <kalloc+0x48>
    release(&kmem.lock);
80102bc8:	c7 04 24 c0 36 11 80 	movl   $0x801136c0,(%esp)
80102bcf:	e8 00 22 00 00       	call   80104dd4 <release>
  return (char*)r;
80102bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102bd7:	c9                   	leave  
80102bd8:	c3                   	ret    

80102bd9 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102bd9:	55                   	push   %ebp
80102bda:	89 e5                	mov    %esp,%ebp
80102bdc:	83 ec 14             	sub    $0x14,%esp
80102bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80102be2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102be6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102bea:	89 c2                	mov    %eax,%edx
80102bec:	ec                   	in     (%dx),%al
80102bed:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102bf0:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102bf4:	c9                   	leave  
80102bf5:	c3                   	ret    

80102bf6 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102bf6:	55                   	push   %ebp
80102bf7:	89 e5                	mov    %esp,%ebp
80102bf9:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102bfc:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102c03:	e8 d1 ff ff ff       	call   80102bd9 <inb>
80102c08:	0f b6 c0             	movzbl %al,%eax
80102c0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c11:	83 e0 01             	and    $0x1,%eax
80102c14:	85 c0                	test   %eax,%eax
80102c16:	75 0a                	jne    80102c22 <kbdgetc+0x2c>
    return -1;
80102c18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102c1d:	e9 25 01 00 00       	jmp    80102d47 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102c22:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102c29:	e8 ab ff ff ff       	call   80102bd9 <inb>
80102c2e:	0f b6 c0             	movzbl %al,%eax
80102c31:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102c34:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102c3b:	75 17                	jne    80102c54 <kbdgetc+0x5e>
    shift |= E0ESC;
80102c3d:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102c42:	83 c8 40             	or     $0x40,%eax
80102c45:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
    return 0;
80102c4a:	b8 00 00 00 00       	mov    $0x0,%eax
80102c4f:	e9 f3 00 00 00       	jmp    80102d47 <kbdgetc+0x151>
  } else if(data & 0x80){
80102c54:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c57:	25 80 00 00 00       	and    $0x80,%eax
80102c5c:	85 c0                	test   %eax,%eax
80102c5e:	74 45                	je     80102ca5 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102c60:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102c65:	83 e0 40             	and    $0x40,%eax
80102c68:	85 c0                	test   %eax,%eax
80102c6a:	75 08                	jne    80102c74 <kbdgetc+0x7e>
80102c6c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c6f:	83 e0 7f             	and    $0x7f,%eax
80102c72:	eb 03                	jmp    80102c77 <kbdgetc+0x81>
80102c74:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c77:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102c7a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c7d:	05 20 90 10 80       	add    $0x80109020,%eax
80102c82:	0f b6 00             	movzbl (%eax),%eax
80102c85:	83 c8 40             	or     $0x40,%eax
80102c88:	0f b6 c0             	movzbl %al,%eax
80102c8b:	f7 d0                	not    %eax
80102c8d:	89 c2                	mov    %eax,%edx
80102c8f:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102c94:	21 d0                	and    %edx,%eax
80102c96:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
    return 0;
80102c9b:	b8 00 00 00 00       	mov    $0x0,%eax
80102ca0:	e9 a2 00 00 00       	jmp    80102d47 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102ca5:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102caa:	83 e0 40             	and    $0x40,%eax
80102cad:	85 c0                	test   %eax,%eax
80102caf:	74 14                	je     80102cc5 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102cb1:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102cb8:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102cbd:	83 e0 bf             	and    $0xffffffbf,%eax
80102cc0:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
  }

  shift |= shiftcode[data];
80102cc5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cc8:	05 20 90 10 80       	add    $0x80109020,%eax
80102ccd:	0f b6 00             	movzbl (%eax),%eax
80102cd0:	0f b6 d0             	movzbl %al,%edx
80102cd3:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102cd8:	09 d0                	or     %edx,%eax
80102cda:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
  shift ^= togglecode[data];
80102cdf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ce2:	05 20 91 10 80       	add    $0x80109120,%eax
80102ce7:	0f b6 00             	movzbl (%eax),%eax
80102cea:	0f b6 d0             	movzbl %al,%edx
80102ced:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102cf2:	31 d0                	xor    %edx,%eax
80102cf4:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
  c = charcode[shift & (CTL | SHIFT)][data];
80102cf9:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102cfe:	83 e0 03             	and    $0x3,%eax
80102d01:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102d08:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d0b:	01 d0                	add    %edx,%eax
80102d0d:	0f b6 00             	movzbl (%eax),%eax
80102d10:	0f b6 c0             	movzbl %al,%eax
80102d13:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102d16:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102d1b:	83 e0 08             	and    $0x8,%eax
80102d1e:	85 c0                	test   %eax,%eax
80102d20:	74 22                	je     80102d44 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102d22:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102d26:	76 0c                	jbe    80102d34 <kbdgetc+0x13e>
80102d28:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102d2c:	77 06                	ja     80102d34 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102d2e:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102d32:	eb 10                	jmp    80102d44 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102d34:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102d38:	76 0a                	jbe    80102d44 <kbdgetc+0x14e>
80102d3a:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102d3e:	77 04                	ja     80102d44 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102d40:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102d44:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102d47:	c9                   	leave  
80102d48:	c3                   	ret    

80102d49 <kbdintr>:

void
kbdintr(void)
{
80102d49:	55                   	push   %ebp
80102d4a:	89 e5                	mov    %esp,%ebp
80102d4c:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102d4f:	c7 04 24 f6 2b 10 80 	movl   $0x80102bf6,(%esp)
80102d56:	e8 8e da ff ff       	call   801007e9 <consoleintr>
}
80102d5b:	c9                   	leave  
80102d5c:	c3                   	ret    

80102d5d <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d5d:	55                   	push   %ebp
80102d5e:	89 e5                	mov    %esp,%ebp
80102d60:	83 ec 14             	sub    $0x14,%esp
80102d63:	8b 45 08             	mov    0x8(%ebp),%eax
80102d66:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d6a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d6e:	89 c2                	mov    %eax,%edx
80102d70:	ec                   	in     (%dx),%al
80102d71:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d74:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d78:	c9                   	leave  
80102d79:	c3                   	ret    

80102d7a <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102d7a:	55                   	push   %ebp
80102d7b:	89 e5                	mov    %esp,%ebp
80102d7d:	83 ec 08             	sub    $0x8,%esp
80102d80:	8b 55 08             	mov    0x8(%ebp),%edx
80102d83:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d86:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102d8a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d8d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102d91:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102d95:	ee                   	out    %al,(%dx)
}
80102d96:	c9                   	leave  
80102d97:	c3                   	ret    

80102d98 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102d98:	55                   	push   %ebp
80102d99:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102d9b:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102da0:	8b 55 08             	mov    0x8(%ebp),%edx
80102da3:	c1 e2 02             	shl    $0x2,%edx
80102da6:	01 c2                	add    %eax,%edx
80102da8:	8b 45 0c             	mov    0xc(%ebp),%eax
80102dab:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102dad:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102db2:	83 c0 20             	add    $0x20,%eax
80102db5:	8b 00                	mov    (%eax),%eax
}
80102db7:	5d                   	pop    %ebp
80102db8:	c3                   	ret    

80102db9 <lapicinit>:

void
lapicinit(void)
{
80102db9:	55                   	push   %ebp
80102dba:	89 e5                	mov    %esp,%ebp
80102dbc:	83 ec 08             	sub    $0x8,%esp
  if(!lapic)
80102dbf:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102dc4:	85 c0                	test   %eax,%eax
80102dc6:	75 05                	jne    80102dcd <lapicinit+0x14>
    return;
80102dc8:	e9 43 01 00 00       	jmp    80102f10 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102dcd:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102dd4:	00 
80102dd5:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102ddc:	e8 b7 ff ff ff       	call   80102d98 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102de1:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102de8:	00 
80102de9:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102df0:	e8 a3 ff ff ff       	call   80102d98 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102df5:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102dfc:	00 
80102dfd:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102e04:	e8 8f ff ff ff       	call   80102d98 <lapicw>
  lapicw(TICR, 10000000);
80102e09:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102e10:	00 
80102e11:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102e18:	e8 7b ff ff ff       	call   80102d98 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102e1d:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e24:	00 
80102e25:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102e2c:	e8 67 ff ff ff       	call   80102d98 <lapicw>
  lapicw(LINT1, MASKED);
80102e31:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e38:	00 
80102e39:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102e40:	e8 53 ff ff ff       	call   80102d98 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102e45:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102e4a:	83 c0 30             	add    $0x30,%eax
80102e4d:	8b 00                	mov    (%eax),%eax
80102e4f:	c1 e8 10             	shr    $0x10,%eax
80102e52:	0f b6 c0             	movzbl %al,%eax
80102e55:	83 f8 03             	cmp    $0x3,%eax
80102e58:	76 14                	jbe    80102e6e <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102e5a:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e61:	00 
80102e62:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102e69:	e8 2a ff ff ff       	call   80102d98 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102e6e:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102e75:	00 
80102e76:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102e7d:	e8 16 ff ff ff       	call   80102d98 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102e82:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e89:	00 
80102e8a:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e91:	e8 02 ff ff ff       	call   80102d98 <lapicw>
  lapicw(ESR, 0);
80102e96:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e9d:	00 
80102e9e:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102ea5:	e8 ee fe ff ff       	call   80102d98 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102eaa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102eb1:	00 
80102eb2:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102eb9:	e8 da fe ff ff       	call   80102d98 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ebe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ec5:	00 
80102ec6:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102ecd:	e8 c6 fe ff ff       	call   80102d98 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102ed2:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102ed9:	00 
80102eda:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102ee1:	e8 b2 fe ff ff       	call   80102d98 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102ee6:	90                   	nop
80102ee7:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102eec:	05 00 03 00 00       	add    $0x300,%eax
80102ef1:	8b 00                	mov    (%eax),%eax
80102ef3:	25 00 10 00 00       	and    $0x1000,%eax
80102ef8:	85 c0                	test   %eax,%eax
80102efa:	75 eb                	jne    80102ee7 <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102efc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f03:	00 
80102f04:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102f0b:	e8 88 fe ff ff       	call   80102d98 <lapicw>
}
80102f10:	c9                   	leave  
80102f11:	c3                   	ret    

80102f12 <lapicid>:

int
lapicid(void)
{
80102f12:	55                   	push   %ebp
80102f13:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80102f15:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102f1a:	85 c0                	test   %eax,%eax
80102f1c:	75 07                	jne    80102f25 <lapicid+0x13>
    return 0;
80102f1e:	b8 00 00 00 00       	mov    $0x0,%eax
80102f23:	eb 0d                	jmp    80102f32 <lapicid+0x20>
  return lapic[ID] >> 24;
80102f25:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102f2a:	83 c0 20             	add    $0x20,%eax
80102f2d:	8b 00                	mov    (%eax),%eax
80102f2f:	c1 e8 18             	shr    $0x18,%eax
}
80102f32:	5d                   	pop    %ebp
80102f33:	c3                   	ret    

80102f34 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102f34:	55                   	push   %ebp
80102f35:	89 e5                	mov    %esp,%ebp
80102f37:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102f3a:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102f3f:	85 c0                	test   %eax,%eax
80102f41:	74 14                	je     80102f57 <lapiceoi+0x23>
    lapicw(EOI, 0);
80102f43:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f4a:	00 
80102f4b:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102f52:	e8 41 fe ff ff       	call   80102d98 <lapicw>
}
80102f57:	c9                   	leave  
80102f58:	c3                   	ret    

80102f59 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102f59:	55                   	push   %ebp
80102f5a:	89 e5                	mov    %esp,%ebp
}
80102f5c:	5d                   	pop    %ebp
80102f5d:	c3                   	ret    

80102f5e <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102f5e:	55                   	push   %ebp
80102f5f:	89 e5                	mov    %esp,%ebp
80102f61:	83 ec 1c             	sub    $0x1c,%esp
80102f64:	8b 45 08             	mov    0x8(%ebp),%eax
80102f67:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102f6a:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102f71:	00 
80102f72:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102f79:	e8 fc fd ff ff       	call   80102d7a <outb>
  outb(CMOS_PORT+1, 0x0A);
80102f7e:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102f85:	00 
80102f86:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102f8d:	e8 e8 fd ff ff       	call   80102d7a <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102f92:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102f99:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f9c:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102fa1:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102fa4:	8d 50 02             	lea    0x2(%eax),%edx
80102fa7:	8b 45 0c             	mov    0xc(%ebp),%eax
80102faa:	c1 e8 04             	shr    $0x4,%eax
80102fad:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102fb0:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102fb4:	c1 e0 18             	shl    $0x18,%eax
80102fb7:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fbb:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102fc2:	e8 d1 fd ff ff       	call   80102d98 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102fc7:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80102fce:	00 
80102fcf:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fd6:	e8 bd fd ff ff       	call   80102d98 <lapicw>
  microdelay(200);
80102fdb:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102fe2:	e8 72 ff ff ff       	call   80102f59 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80102fe7:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80102fee:	00 
80102fef:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102ff6:	e8 9d fd ff ff       	call   80102d98 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102ffb:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103002:	e8 52 ff ff ff       	call   80102f59 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103007:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010300e:	eb 40                	jmp    80103050 <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
80103010:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103014:	c1 e0 18             	shl    $0x18,%eax
80103017:	89 44 24 04          	mov    %eax,0x4(%esp)
8010301b:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103022:	e8 71 fd ff ff       	call   80102d98 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103027:	8b 45 0c             	mov    0xc(%ebp),%eax
8010302a:	c1 e8 0c             	shr    $0xc,%eax
8010302d:	80 cc 06             	or     $0x6,%ah
80103030:	89 44 24 04          	mov    %eax,0x4(%esp)
80103034:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010303b:	e8 58 fd ff ff       	call   80102d98 <lapicw>
    microdelay(200);
80103040:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103047:	e8 0d ff ff ff       	call   80102f59 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010304c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103050:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103054:	7e ba                	jle    80103010 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103056:	c9                   	leave  
80103057:	c3                   	ret    

80103058 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103058:	55                   	push   %ebp
80103059:	89 e5                	mov    %esp,%ebp
8010305b:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
8010305e:	8b 45 08             	mov    0x8(%ebp),%eax
80103061:	0f b6 c0             	movzbl %al,%eax
80103064:	89 44 24 04          	mov    %eax,0x4(%esp)
80103068:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
8010306f:	e8 06 fd ff ff       	call   80102d7a <outb>
  microdelay(200);
80103074:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010307b:	e8 d9 fe ff ff       	call   80102f59 <microdelay>

  return inb(CMOS_RETURN);
80103080:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103087:	e8 d1 fc ff ff       	call   80102d5d <inb>
8010308c:	0f b6 c0             	movzbl %al,%eax
}
8010308f:	c9                   	leave  
80103090:	c3                   	ret    

80103091 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103091:	55                   	push   %ebp
80103092:	89 e5                	mov    %esp,%ebp
80103094:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
80103097:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010309e:	e8 b5 ff ff ff       	call   80103058 <cmos_read>
801030a3:	8b 55 08             	mov    0x8(%ebp),%edx
801030a6:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
801030a8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801030af:	e8 a4 ff ff ff       	call   80103058 <cmos_read>
801030b4:	8b 55 08             	mov    0x8(%ebp),%edx
801030b7:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
801030ba:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801030c1:	e8 92 ff ff ff       	call   80103058 <cmos_read>
801030c6:	8b 55 08             	mov    0x8(%ebp),%edx
801030c9:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
801030cc:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
801030d3:	e8 80 ff ff ff       	call   80103058 <cmos_read>
801030d8:	8b 55 08             	mov    0x8(%ebp),%edx
801030db:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801030de:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801030e5:	e8 6e ff ff ff       	call   80103058 <cmos_read>
801030ea:	8b 55 08             	mov    0x8(%ebp),%edx
801030ed:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801030f0:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
801030f7:	e8 5c ff ff ff       	call   80103058 <cmos_read>
801030fc:	8b 55 08             	mov    0x8(%ebp),%edx
801030ff:	89 42 14             	mov    %eax,0x14(%edx)
}
80103102:	c9                   	leave  
80103103:	c3                   	ret    

80103104 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103104:	55                   	push   %ebp
80103105:	89 e5                	mov    %esp,%ebp
80103107:	83 ec 58             	sub    $0x58,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
8010310a:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
80103111:	e8 42 ff ff ff       	call   80103058 <cmos_read>
80103116:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010311c:	83 e0 04             	and    $0x4,%eax
8010311f:	85 c0                	test   %eax,%eax
80103121:	0f 94 c0             	sete   %al
80103124:	0f b6 c0             	movzbl %al,%eax
80103127:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
8010312a:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010312d:	89 04 24             	mov    %eax,(%esp)
80103130:	e8 5c ff ff ff       	call   80103091 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80103135:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
8010313c:	e8 17 ff ff ff       	call   80103058 <cmos_read>
80103141:	25 80 00 00 00       	and    $0x80,%eax
80103146:	85 c0                	test   %eax,%eax
80103148:	74 02                	je     8010314c <cmostime+0x48>
        continue;
8010314a:	eb 36                	jmp    80103182 <cmostime+0x7e>
    fill_rtcdate(&t2);
8010314c:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010314f:	89 04 24             	mov    %eax,(%esp)
80103152:	e8 3a ff ff ff       	call   80103091 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80103157:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
8010315e:	00 
8010315f:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103162:	89 44 24 04          	mov    %eax,0x4(%esp)
80103166:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103169:	89 04 24             	mov    %eax,(%esp)
8010316c:	e8 d4 1e 00 00       	call   80105045 <memcmp>
80103171:	85 c0                	test   %eax,%eax
80103173:	75 0d                	jne    80103182 <cmostime+0x7e>
      break;
80103175:	90                   	nop
  }

  // convert
  if(bcd) {
80103176:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010317a:	0f 84 ac 00 00 00    	je     8010322c <cmostime+0x128>
80103180:	eb 02                	jmp    80103184 <cmostime+0x80>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103182:	eb a6                	jmp    8010312a <cmostime+0x26>

  // convert
  if(bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103184:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103187:	c1 e8 04             	shr    $0x4,%eax
8010318a:	89 c2                	mov    %eax,%edx
8010318c:	89 d0                	mov    %edx,%eax
8010318e:	c1 e0 02             	shl    $0x2,%eax
80103191:	01 d0                	add    %edx,%eax
80103193:	01 c0                	add    %eax,%eax
80103195:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103198:	83 e2 0f             	and    $0xf,%edx
8010319b:	01 d0                	add    %edx,%eax
8010319d:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801031a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801031a3:	c1 e8 04             	shr    $0x4,%eax
801031a6:	89 c2                	mov    %eax,%edx
801031a8:	89 d0                	mov    %edx,%eax
801031aa:	c1 e0 02             	shl    $0x2,%eax
801031ad:	01 d0                	add    %edx,%eax
801031af:	01 c0                	add    %eax,%eax
801031b1:	8b 55 dc             	mov    -0x24(%ebp),%edx
801031b4:	83 e2 0f             	and    $0xf,%edx
801031b7:	01 d0                	add    %edx,%eax
801031b9:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
801031bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801031bf:	c1 e8 04             	shr    $0x4,%eax
801031c2:	89 c2                	mov    %eax,%edx
801031c4:	89 d0                	mov    %edx,%eax
801031c6:	c1 e0 02             	shl    $0x2,%eax
801031c9:	01 d0                	add    %edx,%eax
801031cb:	01 c0                	add    %eax,%eax
801031cd:	8b 55 e0             	mov    -0x20(%ebp),%edx
801031d0:	83 e2 0f             	and    $0xf,%edx
801031d3:	01 d0                	add    %edx,%eax
801031d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801031d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801031db:	c1 e8 04             	shr    $0x4,%eax
801031de:	89 c2                	mov    %eax,%edx
801031e0:	89 d0                	mov    %edx,%eax
801031e2:	c1 e0 02             	shl    $0x2,%eax
801031e5:	01 d0                	add    %edx,%eax
801031e7:	01 c0                	add    %eax,%eax
801031e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801031ec:	83 e2 0f             	and    $0xf,%edx
801031ef:	01 d0                	add    %edx,%eax
801031f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801031f4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801031f7:	c1 e8 04             	shr    $0x4,%eax
801031fa:	89 c2                	mov    %eax,%edx
801031fc:	89 d0                	mov    %edx,%eax
801031fe:	c1 e0 02             	shl    $0x2,%eax
80103201:	01 d0                	add    %edx,%eax
80103203:	01 c0                	add    %eax,%eax
80103205:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103208:	83 e2 0f             	and    $0xf,%edx
8010320b:	01 d0                	add    %edx,%eax
8010320d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103210:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103213:	c1 e8 04             	shr    $0x4,%eax
80103216:	89 c2                	mov    %eax,%edx
80103218:	89 d0                	mov    %edx,%eax
8010321a:	c1 e0 02             	shl    $0x2,%eax
8010321d:	01 d0                	add    %edx,%eax
8010321f:	01 c0                	add    %eax,%eax
80103221:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103224:	83 e2 0f             	and    $0xf,%edx
80103227:	01 d0                	add    %edx,%eax
80103229:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
8010322c:	8b 45 08             	mov    0x8(%ebp),%eax
8010322f:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103232:	89 10                	mov    %edx,(%eax)
80103234:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103237:	89 50 04             	mov    %edx,0x4(%eax)
8010323a:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010323d:	89 50 08             	mov    %edx,0x8(%eax)
80103240:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103243:	89 50 0c             	mov    %edx,0xc(%eax)
80103246:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103249:	89 50 10             	mov    %edx,0x10(%eax)
8010324c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010324f:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103252:	8b 45 08             	mov    0x8(%ebp),%eax
80103255:	8b 40 14             	mov    0x14(%eax),%eax
80103258:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010325e:	8b 45 08             	mov    0x8(%ebp),%eax
80103261:	89 50 14             	mov    %edx,0x14(%eax)
}
80103264:	c9                   	leave  
80103265:	c3                   	ret    

80103266 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103266:	55                   	push   %ebp
80103267:	89 e5                	mov    %esp,%ebp
80103269:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010326c:	c7 44 24 04 95 86 10 	movl   $0x80108695,0x4(%esp)
80103273:	80 
80103274:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
8010327b:	e8 cb 1a 00 00       	call   80104d4b <initlock>
  readsb(dev, &sb);
80103280:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103283:	89 44 24 04          	mov    %eax,0x4(%esp)
80103287:	8b 45 08             	mov    0x8(%ebp),%eax
8010328a:	89 04 24             	mov    %eax,(%esp)
8010328d:	e8 a1 e0 ff ff       	call   80101333 <readsb>
  log.start = sb.logstart;
80103292:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103295:	a3 34 37 11 80       	mov    %eax,0x80113734
  log.size = sb.nlog;
8010329a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010329d:	a3 38 37 11 80       	mov    %eax,0x80113738
  log.dev = dev;
801032a2:	8b 45 08             	mov    0x8(%ebp),%eax
801032a5:	a3 44 37 11 80       	mov    %eax,0x80113744
  recover_from_log();
801032aa:	e8 9a 01 00 00       	call   80103449 <recover_from_log>
}
801032af:	c9                   	leave  
801032b0:	c3                   	ret    

801032b1 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
801032b1:	55                   	push   %ebp
801032b2:	89 e5                	mov    %esp,%ebp
801032b4:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801032b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032be:	e9 8c 00 00 00       	jmp    8010334f <install_trans+0x9e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801032c3:	8b 15 34 37 11 80    	mov    0x80113734,%edx
801032c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032cc:	01 d0                	add    %edx,%eax
801032ce:	83 c0 01             	add    $0x1,%eax
801032d1:	89 c2                	mov    %eax,%edx
801032d3:	a1 44 37 11 80       	mov    0x80113744,%eax
801032d8:	89 54 24 04          	mov    %edx,0x4(%esp)
801032dc:	89 04 24             	mov    %eax,(%esp)
801032df:	e8 d1 ce ff ff       	call   801001b5 <bread>
801032e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801032e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032ea:	83 c0 10             	add    $0x10,%eax
801032ed:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
801032f4:	89 c2                	mov    %eax,%edx
801032f6:	a1 44 37 11 80       	mov    0x80113744,%eax
801032fb:	89 54 24 04          	mov    %edx,0x4(%esp)
801032ff:	89 04 24             	mov    %eax,(%esp)
80103302:	e8 ae ce ff ff       	call   801001b5 <bread>
80103307:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010330a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010330d:	8d 50 5c             	lea    0x5c(%eax),%edx
80103310:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103313:	83 c0 5c             	add    $0x5c,%eax
80103316:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010331d:	00 
8010331e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103322:	89 04 24             	mov    %eax,(%esp)
80103325:	e8 73 1d 00 00       	call   8010509d <memmove>
    bwrite(dbuf);  // write dst to disk
8010332a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010332d:	89 04 24             	mov    %eax,(%esp)
80103330:	e8 b7 ce ff ff       	call   801001ec <bwrite>
    brelse(lbuf);
80103335:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103338:	89 04 24             	mov    %eax,(%esp)
8010333b:	e8 ec ce ff ff       	call   8010022c <brelse>
    brelse(dbuf);
80103340:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103343:	89 04 24             	mov    %eax,(%esp)
80103346:	e8 e1 ce ff ff       	call   8010022c <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010334b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010334f:	a1 48 37 11 80       	mov    0x80113748,%eax
80103354:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103357:	0f 8f 66 ff ff ff    	jg     801032c3 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
8010335d:	c9                   	leave  
8010335e:	c3                   	ret    

8010335f <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010335f:	55                   	push   %ebp
80103360:	89 e5                	mov    %esp,%ebp
80103362:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103365:	a1 34 37 11 80       	mov    0x80113734,%eax
8010336a:	89 c2                	mov    %eax,%edx
8010336c:	a1 44 37 11 80       	mov    0x80113744,%eax
80103371:	89 54 24 04          	mov    %edx,0x4(%esp)
80103375:	89 04 24             	mov    %eax,(%esp)
80103378:	e8 38 ce ff ff       	call   801001b5 <bread>
8010337d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103380:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103383:	83 c0 5c             	add    $0x5c,%eax
80103386:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103389:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010338c:	8b 00                	mov    (%eax),%eax
8010338e:	a3 48 37 11 80       	mov    %eax,0x80113748
  for (i = 0; i < log.lh.n; i++) {
80103393:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010339a:	eb 1b                	jmp    801033b7 <read_head+0x58>
    log.lh.block[i] = lh->block[i];
8010339c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010339f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033a2:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801033a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033a9:	83 c2 10             	add    $0x10,%edx
801033ac:	89 04 95 0c 37 11 80 	mov    %eax,-0x7feec8f4(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801033b3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033b7:	a1 48 37 11 80       	mov    0x80113748,%eax
801033bc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033bf:	7f db                	jg     8010339c <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
801033c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033c4:	89 04 24             	mov    %eax,(%esp)
801033c7:	e8 60 ce ff ff       	call   8010022c <brelse>
}
801033cc:	c9                   	leave  
801033cd:	c3                   	ret    

801033ce <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801033ce:	55                   	push   %ebp
801033cf:	89 e5                	mov    %esp,%ebp
801033d1:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801033d4:	a1 34 37 11 80       	mov    0x80113734,%eax
801033d9:	89 c2                	mov    %eax,%edx
801033db:	a1 44 37 11 80       	mov    0x80113744,%eax
801033e0:	89 54 24 04          	mov    %edx,0x4(%esp)
801033e4:	89 04 24             	mov    %eax,(%esp)
801033e7:	e8 c9 cd ff ff       	call   801001b5 <bread>
801033ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801033ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033f2:	83 c0 5c             	add    $0x5c,%eax
801033f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801033f8:	8b 15 48 37 11 80    	mov    0x80113748,%edx
801033fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103401:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103403:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010340a:	eb 1b                	jmp    80103427 <write_head+0x59>
    hb->block[i] = log.lh.block[i];
8010340c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010340f:	83 c0 10             	add    $0x10,%eax
80103412:	8b 0c 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%ecx
80103419:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010341c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010341f:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103423:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103427:	a1 48 37 11 80       	mov    0x80113748,%eax
8010342c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010342f:	7f db                	jg     8010340c <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80103431:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103434:	89 04 24             	mov    %eax,(%esp)
80103437:	e8 b0 cd ff ff       	call   801001ec <bwrite>
  brelse(buf);
8010343c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010343f:	89 04 24             	mov    %eax,(%esp)
80103442:	e8 e5 cd ff ff       	call   8010022c <brelse>
}
80103447:	c9                   	leave  
80103448:	c3                   	ret    

80103449 <recover_from_log>:

static void
recover_from_log(void)
{
80103449:	55                   	push   %ebp
8010344a:	89 e5                	mov    %esp,%ebp
8010344c:	83 ec 08             	sub    $0x8,%esp
  read_head();
8010344f:	e8 0b ff ff ff       	call   8010335f <read_head>
  install_trans(); // if committed, copy from log to disk
80103454:	e8 58 fe ff ff       	call   801032b1 <install_trans>
  log.lh.n = 0;
80103459:	c7 05 48 37 11 80 00 	movl   $0x0,0x80113748
80103460:	00 00 00 
  write_head(); // clear the log
80103463:	e8 66 ff ff ff       	call   801033ce <write_head>
}
80103468:	c9                   	leave  
80103469:	c3                   	ret    

8010346a <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010346a:	55                   	push   %ebp
8010346b:	89 e5                	mov    %esp,%ebp
8010346d:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103470:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80103477:	e8 f0 18 00 00       	call   80104d6c <acquire>
  while(1){
    if(log.committing){
8010347c:	a1 40 37 11 80       	mov    0x80113740,%eax
80103481:	85 c0                	test   %eax,%eax
80103483:	74 16                	je     8010349b <begin_op+0x31>
      sleep(&log, &log.lock);
80103485:	c7 44 24 04 00 37 11 	movl   $0x80113700,0x4(%esp)
8010348c:	80 
8010348d:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80103494:	e8 08 15 00 00       	call   801049a1 <sleep>
80103499:	eb 4f                	jmp    801034ea <begin_op+0x80>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010349b:	8b 0d 48 37 11 80    	mov    0x80113748,%ecx
801034a1:	a1 3c 37 11 80       	mov    0x8011373c,%eax
801034a6:	8d 50 01             	lea    0x1(%eax),%edx
801034a9:	89 d0                	mov    %edx,%eax
801034ab:	c1 e0 02             	shl    $0x2,%eax
801034ae:	01 d0                	add    %edx,%eax
801034b0:	01 c0                	add    %eax,%eax
801034b2:	01 c8                	add    %ecx,%eax
801034b4:	83 f8 1e             	cmp    $0x1e,%eax
801034b7:	7e 16                	jle    801034cf <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801034b9:	c7 44 24 04 00 37 11 	movl   $0x80113700,0x4(%esp)
801034c0:	80 
801034c1:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
801034c8:	e8 d4 14 00 00       	call   801049a1 <sleep>
801034cd:	eb 1b                	jmp    801034ea <begin_op+0x80>
    } else {
      log.outstanding += 1;
801034cf:	a1 3c 37 11 80       	mov    0x8011373c,%eax
801034d4:	83 c0 01             	add    $0x1,%eax
801034d7:	a3 3c 37 11 80       	mov    %eax,0x8011373c
      release(&log.lock);
801034dc:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
801034e3:	e8 ec 18 00 00       	call   80104dd4 <release>
      break;
801034e8:	eb 02                	jmp    801034ec <begin_op+0x82>
    }
  }
801034ea:	eb 90                	jmp    8010347c <begin_op+0x12>
}
801034ec:	c9                   	leave  
801034ed:	c3                   	ret    

801034ee <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801034ee:	55                   	push   %ebp
801034ef:	89 e5                	mov    %esp,%ebp
801034f1:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
801034f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801034fb:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80103502:	e8 65 18 00 00       	call   80104d6c <acquire>
  log.outstanding -= 1;
80103507:	a1 3c 37 11 80       	mov    0x8011373c,%eax
8010350c:	83 e8 01             	sub    $0x1,%eax
8010350f:	a3 3c 37 11 80       	mov    %eax,0x8011373c
  if(log.committing)
80103514:	a1 40 37 11 80       	mov    0x80113740,%eax
80103519:	85 c0                	test   %eax,%eax
8010351b:	74 0c                	je     80103529 <end_op+0x3b>
    panic("log.committing");
8010351d:	c7 04 24 99 86 10 80 	movl   $0x80108699,(%esp)
80103524:	e8 39 d0 ff ff       	call   80100562 <panic>
  if(log.outstanding == 0){
80103529:	a1 3c 37 11 80       	mov    0x8011373c,%eax
8010352e:	85 c0                	test   %eax,%eax
80103530:	75 13                	jne    80103545 <end_op+0x57>
    do_commit = 1;
80103532:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103539:	c7 05 40 37 11 80 01 	movl   $0x1,0x80113740
80103540:	00 00 00 
80103543:	eb 0c                	jmp    80103551 <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103545:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
8010354c:	e8 24 15 00 00       	call   80104a75 <wakeup>
  }
  release(&log.lock);
80103551:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80103558:	e8 77 18 00 00       	call   80104dd4 <release>

  if(do_commit){
8010355d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103561:	74 33                	je     80103596 <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103563:	e8 de 00 00 00       	call   80103646 <commit>
    acquire(&log.lock);
80103568:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
8010356f:	e8 f8 17 00 00       	call   80104d6c <acquire>
    log.committing = 0;
80103574:	c7 05 40 37 11 80 00 	movl   $0x0,0x80113740
8010357b:	00 00 00 
    wakeup(&log);
8010357e:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80103585:	e8 eb 14 00 00       	call   80104a75 <wakeup>
    release(&log.lock);
8010358a:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80103591:	e8 3e 18 00 00       	call   80104dd4 <release>
  }
}
80103596:	c9                   	leave  
80103597:	c3                   	ret    

80103598 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103598:	55                   	push   %ebp
80103599:	89 e5                	mov    %esp,%ebp
8010359b:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010359e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035a5:	e9 8c 00 00 00       	jmp    80103636 <write_log+0x9e>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801035aa:	8b 15 34 37 11 80    	mov    0x80113734,%edx
801035b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035b3:	01 d0                	add    %edx,%eax
801035b5:	83 c0 01             	add    $0x1,%eax
801035b8:	89 c2                	mov    %eax,%edx
801035ba:	a1 44 37 11 80       	mov    0x80113744,%eax
801035bf:	89 54 24 04          	mov    %edx,0x4(%esp)
801035c3:	89 04 24             	mov    %eax,(%esp)
801035c6:	e8 ea cb ff ff       	call   801001b5 <bread>
801035cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801035ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d1:	83 c0 10             	add    $0x10,%eax
801035d4:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
801035db:	89 c2                	mov    %eax,%edx
801035dd:	a1 44 37 11 80       	mov    0x80113744,%eax
801035e2:	89 54 24 04          	mov    %edx,0x4(%esp)
801035e6:	89 04 24             	mov    %eax,(%esp)
801035e9:	e8 c7 cb ff ff       	call   801001b5 <bread>
801035ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801035f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035f4:	8d 50 5c             	lea    0x5c(%eax),%edx
801035f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035fa:	83 c0 5c             	add    $0x5c,%eax
801035fd:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103604:	00 
80103605:	89 54 24 04          	mov    %edx,0x4(%esp)
80103609:	89 04 24             	mov    %eax,(%esp)
8010360c:	e8 8c 1a 00 00       	call   8010509d <memmove>
    bwrite(to);  // write the log
80103611:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103614:	89 04 24             	mov    %eax,(%esp)
80103617:	e8 d0 cb ff ff       	call   801001ec <bwrite>
    brelse(from);
8010361c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010361f:	89 04 24             	mov    %eax,(%esp)
80103622:	e8 05 cc ff ff       	call   8010022c <brelse>
    brelse(to);
80103627:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010362a:	89 04 24             	mov    %eax,(%esp)
8010362d:	e8 fa cb ff ff       	call   8010022c <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103632:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103636:	a1 48 37 11 80       	mov    0x80113748,%eax
8010363b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010363e:	0f 8f 66 ff ff ff    	jg     801035aa <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
80103644:	c9                   	leave  
80103645:	c3                   	ret    

80103646 <commit>:

static void
commit()
{
80103646:	55                   	push   %ebp
80103647:	89 e5                	mov    %esp,%ebp
80103649:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010364c:	a1 48 37 11 80       	mov    0x80113748,%eax
80103651:	85 c0                	test   %eax,%eax
80103653:	7e 1e                	jle    80103673 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103655:	e8 3e ff ff ff       	call   80103598 <write_log>
    write_head();    // Write header to disk -- the real commit
8010365a:	e8 6f fd ff ff       	call   801033ce <write_head>
    install_trans(); // Now install writes to home locations
8010365f:	e8 4d fc ff ff       	call   801032b1 <install_trans>
    log.lh.n = 0;
80103664:	c7 05 48 37 11 80 00 	movl   $0x0,0x80113748
8010366b:	00 00 00 
    write_head();    // Erase the transaction from the log
8010366e:	e8 5b fd ff ff       	call   801033ce <write_head>
  }
}
80103673:	c9                   	leave  
80103674:	c3                   	ret    

80103675 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103675:	55                   	push   %ebp
80103676:	89 e5                	mov    %esp,%ebp
80103678:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010367b:	a1 48 37 11 80       	mov    0x80113748,%eax
80103680:	83 f8 1d             	cmp    $0x1d,%eax
80103683:	7f 12                	jg     80103697 <log_write+0x22>
80103685:	a1 48 37 11 80       	mov    0x80113748,%eax
8010368a:	8b 15 38 37 11 80    	mov    0x80113738,%edx
80103690:	83 ea 01             	sub    $0x1,%edx
80103693:	39 d0                	cmp    %edx,%eax
80103695:	7c 0c                	jl     801036a3 <log_write+0x2e>
    panic("too big a transaction");
80103697:	c7 04 24 a8 86 10 80 	movl   $0x801086a8,(%esp)
8010369e:	e8 bf ce ff ff       	call   80100562 <panic>
  if (log.outstanding < 1)
801036a3:	a1 3c 37 11 80       	mov    0x8011373c,%eax
801036a8:	85 c0                	test   %eax,%eax
801036aa:	7f 0c                	jg     801036b8 <log_write+0x43>
    panic("log_write outside of trans");
801036ac:	c7 04 24 be 86 10 80 	movl   $0x801086be,(%esp)
801036b3:	e8 aa ce ff ff       	call   80100562 <panic>

  acquire(&log.lock);
801036b8:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
801036bf:	e8 a8 16 00 00       	call   80104d6c <acquire>
  for (i = 0; i < log.lh.n; i++) {
801036c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036cb:	eb 1f                	jmp    801036ec <log_write+0x77>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801036cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036d0:	83 c0 10             	add    $0x10,%eax
801036d3:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
801036da:	89 c2                	mov    %eax,%edx
801036dc:	8b 45 08             	mov    0x8(%ebp),%eax
801036df:	8b 40 08             	mov    0x8(%eax),%eax
801036e2:	39 c2                	cmp    %eax,%edx
801036e4:	75 02                	jne    801036e8 <log_write+0x73>
      break;
801036e6:	eb 0e                	jmp    801036f6 <log_write+0x81>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
801036e8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801036ec:	a1 48 37 11 80       	mov    0x80113748,%eax
801036f1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036f4:	7f d7                	jg     801036cd <log_write+0x58>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
801036f6:	8b 45 08             	mov    0x8(%ebp),%eax
801036f9:	8b 40 08             	mov    0x8(%eax),%eax
801036fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801036ff:	83 c2 10             	add    $0x10,%edx
80103702:	89 04 95 0c 37 11 80 	mov    %eax,-0x7feec8f4(,%edx,4)
  if (i == log.lh.n)
80103709:	a1 48 37 11 80       	mov    0x80113748,%eax
8010370e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103711:	75 0d                	jne    80103720 <log_write+0xab>
    log.lh.n++;
80103713:	a1 48 37 11 80       	mov    0x80113748,%eax
80103718:	83 c0 01             	add    $0x1,%eax
8010371b:	a3 48 37 11 80       	mov    %eax,0x80113748
  b->flags |= B_DIRTY; // prevent eviction
80103720:	8b 45 08             	mov    0x8(%ebp),%eax
80103723:	8b 00                	mov    (%eax),%eax
80103725:	83 c8 04             	or     $0x4,%eax
80103728:	89 c2                	mov    %eax,%edx
8010372a:	8b 45 08             	mov    0x8(%ebp),%eax
8010372d:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010372f:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80103736:	e8 99 16 00 00       	call   80104dd4 <release>
}
8010373b:	c9                   	leave  
8010373c:	c3                   	ret    

8010373d <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010373d:	55                   	push   %ebp
8010373e:	89 e5                	mov    %esp,%ebp
80103740:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103743:	8b 55 08             	mov    0x8(%ebp),%edx
80103746:	8b 45 0c             	mov    0xc(%ebp),%eax
80103749:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010374c:	f0 87 02             	lock xchg %eax,(%edx)
8010374f:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103752:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103755:	c9                   	leave  
80103756:	c3                   	ret    

80103757 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103757:	55                   	push   %ebp
80103758:	89 e5                	mov    %esp,%ebp
8010375a:	83 e4 f0             	and    $0xfffffff0,%esp
8010375d:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103760:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103767:	80 
80103768:	c7 04 24 74 69 11 80 	movl   $0x80116974,(%esp)
8010376f:	e8 ed f2 ff ff       	call   80102a61 <kinit1>
  kvmalloc();      // kernel page table
80103774:	e8 15 43 00 00       	call   80107a8e <kvmalloc>
  mpinit();        // detect other processors
80103779:	e8 d0 03 00 00       	call   80103b4e <mpinit>
  lapicinit();     // interrupt controller
8010377e:	e8 36 f6 ff ff       	call   80102db9 <lapicinit>
  seginit();       // segment descriptors
80103783:	e8 d2 3d 00 00       	call   8010755a <seginit>
  picinit();       // disable pic
80103788:	e8 10 05 00 00       	call   80103c9d <picinit>
  ioapicinit();    // another interrupt controller
8010378d:	e8 eb f1 ff ff       	call   8010297d <ioapicinit>
  consoleinit();   // console hardware
80103792:	e8 39 d3 ff ff       	call   80100ad0 <consoleinit>
  uartinit();      // serial port
80103797:	e8 48 31 00 00       	call   801068e4 <uartinit>
  pinit();         // process table
8010379c:	e8 f5 08 00 00       	call   80104096 <pinit>
  shminit();       // shared memory
801037a1:	e8 d7 4b 00 00       	call   8010837d <shminit>
  tvinit();        // trap vectors
801037a6:	e8 6d 2c 00 00       	call   80106418 <tvinit>
  binit();         // buffer cache
801037ab:	e8 84 c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801037b0:	e8 97 d7 ff ff       	call   80100f4c <fileinit>
  ideinit();       // disk 
801037b5:	e8 cd ed ff ff       	call   80102587 <ideinit>
  startothers();   // start other processors
801037ba:	e8 83 00 00 00       	call   80103842 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801037bf:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801037c6:	8e 
801037c7:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801037ce:	e8 c6 f2 ff ff       	call   80102a99 <kinit2>
  userinit();      // first user process
801037d3:	e8 99 0a 00 00       	call   80104271 <userinit>
  mpmain();        // finish this processor's setup
801037d8:	e8 1a 00 00 00       	call   801037f7 <mpmain>

801037dd <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801037dd:	55                   	push   %ebp
801037de:	89 e5                	mov    %esp,%ebp
801037e0:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801037e3:	e8 bd 42 00 00       	call   80107aa5 <switchkvm>
  seginit();
801037e8:	e8 6d 3d 00 00       	call   8010755a <seginit>
  lapicinit();
801037ed:	e8 c7 f5 ff ff       	call   80102db9 <lapicinit>
  mpmain();
801037f2:	e8 00 00 00 00       	call   801037f7 <mpmain>

801037f7 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801037f7:	55                   	push   %ebp
801037f8:	89 e5                	mov    %esp,%ebp
801037fa:	53                   	push   %ebx
801037fb:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
801037fe:	e8 af 08 00 00       	call   801040b2 <cpuid>
80103803:	89 c3                	mov    %eax,%ebx
80103805:	e8 a8 08 00 00       	call   801040b2 <cpuid>
8010380a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010380e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103812:	c7 04 24 d9 86 10 80 	movl   $0x801086d9,(%esp)
80103819:	e8 aa cb ff ff       	call   801003c8 <cprintf>
  idtinit();       // load idt register
8010381e:	e8 69 2d 00 00       	call   8010658c <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103823:	e8 ab 08 00 00       	call   801040d3 <mycpu>
80103828:	05 a0 00 00 00       	add    $0xa0,%eax
8010382d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103834:	00 
80103835:	89 04 24             	mov    %eax,(%esp)
80103838:	e8 00 ff ff ff       	call   8010373d <xchg>
  scheduler();     // start running processes
8010383d:	e8 95 0f 00 00       	call   801047d7 <scheduler>

80103842 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103842:	55                   	push   %ebp
80103843:	89 e5                	mov    %esp,%ebp
80103845:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103848:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010384f:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103854:	89 44 24 08          	mov    %eax,0x8(%esp)
80103858:	c7 44 24 04 ec b4 10 	movl   $0x8010b4ec,0x4(%esp)
8010385f:	80 
80103860:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103863:	89 04 24             	mov    %eax,(%esp)
80103866:	e8 32 18 00 00       	call   8010509d <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
8010386b:	c7 45 f4 00 38 11 80 	movl   $0x80113800,-0xc(%ebp)
80103872:	eb 76                	jmp    801038ea <startothers+0xa8>
    if(c == mycpu())  // We've started already.
80103874:	e8 5a 08 00 00       	call   801040d3 <mycpu>
80103879:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010387c:	75 02                	jne    80103880 <startothers+0x3e>
      continue;
8010387e:	eb 63                	jmp    801038e3 <startothers+0xa1>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103880:	e8 07 f3 ff ff       	call   80102b8c <kalloc>
80103885:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103888:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010388b:	83 e8 04             	sub    $0x4,%eax
8010388e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103891:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103897:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103899:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010389c:	83 e8 08             	sub    $0x8,%eax
8010389f:	c7 00 dd 37 10 80    	movl   $0x801037dd,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801038a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038a8:	8d 50 f4             	lea    -0xc(%eax),%edx
801038ab:	b8 00 a0 10 80       	mov    $0x8010a000,%eax
801038b0:	05 00 00 00 80       	add    $0x80000000,%eax
801038b5:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
801038b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038ba:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801038c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038c3:	0f b6 00             	movzbl (%eax),%eax
801038c6:	0f b6 c0             	movzbl %al,%eax
801038c9:	89 54 24 04          	mov    %edx,0x4(%esp)
801038cd:	89 04 24             	mov    %eax,(%esp)
801038d0:	e8 89 f6 ff ff       	call   80102f5e <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801038d5:	90                   	nop
801038d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038d9:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801038df:	85 c0                	test   %eax,%eax
801038e1:	74 f3                	je     801038d6 <startothers+0x94>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801038e3:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
801038ea:	a1 80 3d 11 80       	mov    0x80113d80,%eax
801038ef:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801038f5:	05 00 38 11 80       	add    $0x80113800,%eax
801038fa:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038fd:	0f 87 71 ff ff ff    	ja     80103874 <startothers+0x32>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103903:	c9                   	leave  
80103904:	c3                   	ret    

80103905 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103905:	55                   	push   %ebp
80103906:	89 e5                	mov    %esp,%ebp
80103908:	83 ec 14             	sub    $0x14,%esp
8010390b:	8b 45 08             	mov    0x8(%ebp),%eax
8010390e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103912:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103916:	89 c2                	mov    %eax,%edx
80103918:	ec                   	in     (%dx),%al
80103919:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010391c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103920:	c9                   	leave  
80103921:	c3                   	ret    

80103922 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103922:	55                   	push   %ebp
80103923:	89 e5                	mov    %esp,%ebp
80103925:	83 ec 08             	sub    $0x8,%esp
80103928:	8b 55 08             	mov    0x8(%ebp),%edx
8010392b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010392e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103932:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103935:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103939:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010393d:	ee                   	out    %al,(%dx)
}
8010393e:	c9                   	leave  
8010393f:	c3                   	ret    

80103940 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103940:	55                   	push   %ebp
80103941:	89 e5                	mov    %esp,%ebp
80103943:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103946:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
8010394d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103954:	eb 15                	jmp    8010396b <sum+0x2b>
    sum += addr[i];
80103956:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103959:	8b 45 08             	mov    0x8(%ebp),%eax
8010395c:	01 d0                	add    %edx,%eax
8010395e:	0f b6 00             	movzbl (%eax),%eax
80103961:	0f b6 c0             	movzbl %al,%eax
80103964:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103967:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010396b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010396e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103971:	7c e3                	jl     80103956 <sum+0x16>
    sum += addr[i];
  return sum;
80103973:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103976:	c9                   	leave  
80103977:	c3                   	ret    

80103978 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103978:	55                   	push   %ebp
80103979:	89 e5                	mov    %esp,%ebp
8010397b:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
8010397e:	8b 45 08             	mov    0x8(%ebp),%eax
80103981:	05 00 00 00 80       	add    $0x80000000,%eax
80103986:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103989:	8b 55 0c             	mov    0xc(%ebp),%edx
8010398c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010398f:	01 d0                	add    %edx,%eax
80103991:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103994:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103997:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010399a:	eb 3f                	jmp    801039db <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
8010399c:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801039a3:	00 
801039a4:	c7 44 24 04 f0 86 10 	movl   $0x801086f0,0x4(%esp)
801039ab:	80 
801039ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039af:	89 04 24             	mov    %eax,(%esp)
801039b2:	e8 8e 16 00 00       	call   80105045 <memcmp>
801039b7:	85 c0                	test   %eax,%eax
801039b9:	75 1c                	jne    801039d7 <mpsearch1+0x5f>
801039bb:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801039c2:	00 
801039c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039c6:	89 04 24             	mov    %eax,(%esp)
801039c9:	e8 72 ff ff ff       	call   80103940 <sum>
801039ce:	84 c0                	test   %al,%al
801039d0:	75 05                	jne    801039d7 <mpsearch1+0x5f>
      return (struct mp*)p;
801039d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039d5:	eb 11                	jmp    801039e8 <mpsearch1+0x70>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
801039d7:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801039db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039de:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801039e1:	72 b9                	jb     8010399c <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
801039e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801039e8:	c9                   	leave  
801039e9:	c3                   	ret    

801039ea <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
801039ea:	55                   	push   %ebp
801039eb:	89 e5                	mov    %esp,%ebp
801039ed:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
801039f0:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
801039f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039fa:	83 c0 0f             	add    $0xf,%eax
801039fd:	0f b6 00             	movzbl (%eax),%eax
80103a00:	0f b6 c0             	movzbl %al,%eax
80103a03:	c1 e0 08             	shl    $0x8,%eax
80103a06:	89 c2                	mov    %eax,%edx
80103a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a0b:	83 c0 0e             	add    $0xe,%eax
80103a0e:	0f b6 00             	movzbl (%eax),%eax
80103a11:	0f b6 c0             	movzbl %al,%eax
80103a14:	09 d0                	or     %edx,%eax
80103a16:	c1 e0 04             	shl    $0x4,%eax
80103a19:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103a1c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103a20:	74 21                	je     80103a43 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103a22:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103a29:	00 
80103a2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a2d:	89 04 24             	mov    %eax,(%esp)
80103a30:	e8 43 ff ff ff       	call   80103978 <mpsearch1>
80103a35:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103a38:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103a3c:	74 50                	je     80103a8e <mpsearch+0xa4>
      return mp;
80103a3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a41:	eb 5f                	jmp    80103aa2 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	83 c0 14             	add    $0x14,%eax
80103a49:	0f b6 00             	movzbl (%eax),%eax
80103a4c:	0f b6 c0             	movzbl %al,%eax
80103a4f:	c1 e0 08             	shl    $0x8,%eax
80103a52:	89 c2                	mov    %eax,%edx
80103a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a57:	83 c0 13             	add    $0x13,%eax
80103a5a:	0f b6 00             	movzbl (%eax),%eax
80103a5d:	0f b6 c0             	movzbl %al,%eax
80103a60:	09 d0                	or     %edx,%eax
80103a62:	c1 e0 0a             	shl    $0xa,%eax
80103a65:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103a68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a6b:	2d 00 04 00 00       	sub    $0x400,%eax
80103a70:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103a77:	00 
80103a78:	89 04 24             	mov    %eax,(%esp)
80103a7b:	e8 f8 fe ff ff       	call   80103978 <mpsearch1>
80103a80:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103a83:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103a87:	74 05                	je     80103a8e <mpsearch+0xa4>
      return mp;
80103a89:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a8c:	eb 14                	jmp    80103aa2 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103a8e:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103a95:	00 
80103a96:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103a9d:	e8 d6 fe ff ff       	call   80103978 <mpsearch1>
}
80103aa2:	c9                   	leave  
80103aa3:	c3                   	ret    

80103aa4 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103aa4:	55                   	push   %ebp
80103aa5:	89 e5                	mov    %esp,%ebp
80103aa7:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103aaa:	e8 3b ff ff ff       	call   801039ea <mpsearch>
80103aaf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ab2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ab6:	74 0a                	je     80103ac2 <mpconfig+0x1e>
80103ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103abb:	8b 40 04             	mov    0x4(%eax),%eax
80103abe:	85 c0                	test   %eax,%eax
80103ac0:	75 0a                	jne    80103acc <mpconfig+0x28>
    return 0;
80103ac2:	b8 00 00 00 00       	mov    $0x0,%eax
80103ac7:	e9 80 00 00 00       	jmp    80103b4c <mpconfig+0xa8>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103acf:	8b 40 04             	mov    0x4(%eax),%eax
80103ad2:	05 00 00 00 80       	add    $0x80000000,%eax
80103ad7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103ada:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103ae1:	00 
80103ae2:	c7 44 24 04 f5 86 10 	movl   $0x801086f5,0x4(%esp)
80103ae9:	80 
80103aea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aed:	89 04 24             	mov    %eax,(%esp)
80103af0:	e8 50 15 00 00       	call   80105045 <memcmp>
80103af5:	85 c0                	test   %eax,%eax
80103af7:	74 07                	je     80103b00 <mpconfig+0x5c>
    return 0;
80103af9:	b8 00 00 00 00       	mov    $0x0,%eax
80103afe:	eb 4c                	jmp    80103b4c <mpconfig+0xa8>
  if(conf->version != 1 && conf->version != 4)
80103b00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b03:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b07:	3c 01                	cmp    $0x1,%al
80103b09:	74 12                	je     80103b1d <mpconfig+0x79>
80103b0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b0e:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b12:	3c 04                	cmp    $0x4,%al
80103b14:	74 07                	je     80103b1d <mpconfig+0x79>
    return 0;
80103b16:	b8 00 00 00 00       	mov    $0x0,%eax
80103b1b:	eb 2f                	jmp    80103b4c <mpconfig+0xa8>
  if(sum((uchar*)conf, conf->length) != 0)
80103b1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b20:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103b24:	0f b7 c0             	movzwl %ax,%eax
80103b27:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b2e:	89 04 24             	mov    %eax,(%esp)
80103b31:	e8 0a fe ff ff       	call   80103940 <sum>
80103b36:	84 c0                	test   %al,%al
80103b38:	74 07                	je     80103b41 <mpconfig+0x9d>
    return 0;
80103b3a:	b8 00 00 00 00       	mov    $0x0,%eax
80103b3f:	eb 0b                	jmp    80103b4c <mpconfig+0xa8>
  *pmp = mp;
80103b41:	8b 45 08             	mov    0x8(%ebp),%eax
80103b44:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b47:	89 10                	mov    %edx,(%eax)
  return conf;
80103b49:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103b4c:	c9                   	leave  
80103b4d:	c3                   	ret    

80103b4e <mpinit>:

void
mpinit(void)
{
80103b4e:	55                   	push   %ebp
80103b4f:	89 e5                	mov    %esp,%ebp
80103b51:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103b54:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103b57:	89 04 24             	mov    %eax,(%esp)
80103b5a:	e8 45 ff ff ff       	call   80103aa4 <mpconfig>
80103b5f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b62:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b66:	75 0c                	jne    80103b74 <mpinit+0x26>
    panic("Expect to run on an SMP");
80103b68:	c7 04 24 fa 86 10 80 	movl   $0x801086fa,(%esp)
80103b6f:	e8 ee c9 ff ff       	call   80100562 <panic>
  ismp = 1;
80103b74:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103b7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b7e:	8b 40 24             	mov    0x24(%eax),%eax
80103b81:	a3 fc 36 11 80       	mov    %eax,0x801136fc
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103b86:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b89:	83 c0 2c             	add    $0x2c,%eax
80103b8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b92:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103b96:	0f b7 d0             	movzwl %ax,%edx
80103b99:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b9c:	01 d0                	add    %edx,%eax
80103b9e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103ba1:	eb 7b                	jmp    80103c1e <mpinit+0xd0>
    switch(*p){
80103ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba6:	0f b6 00             	movzbl (%eax),%eax
80103ba9:	0f b6 c0             	movzbl %al,%eax
80103bac:	83 f8 04             	cmp    $0x4,%eax
80103baf:	77 65                	ja     80103c16 <mpinit+0xc8>
80103bb1:	8b 04 85 34 87 10 80 	mov    -0x7fef78cc(,%eax,4),%eax
80103bb8:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103bc0:	a1 80 3d 11 80       	mov    0x80113d80,%eax
80103bc5:	83 f8 07             	cmp    $0x7,%eax
80103bc8:	7f 28                	jg     80103bf2 <mpinit+0xa4>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103bca:	8b 15 80 3d 11 80    	mov    0x80113d80,%edx
80103bd0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103bd3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103bd7:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103bdd:	81 c2 00 38 11 80    	add    $0x80113800,%edx
80103be3:	88 02                	mov    %al,(%edx)
        ncpu++;
80103be5:	a1 80 3d 11 80       	mov    0x80113d80,%eax
80103bea:	83 c0 01             	add    $0x1,%eax
80103bed:	a3 80 3d 11 80       	mov    %eax,0x80113d80
      }
      p += sizeof(struct mpproc);
80103bf2:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103bf6:	eb 26                	jmp    80103c1e <mpinit+0xd0>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bfb:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103bfe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103c01:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c05:	a2 e0 37 11 80       	mov    %al,0x801137e0
      p += sizeof(struct mpioapic);
80103c0a:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103c0e:	eb 0e                	jmp    80103c1e <mpinit+0xd0>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103c10:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103c14:	eb 08                	jmp    80103c1e <mpinit+0xd0>
    default:
      ismp = 0;
80103c16:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103c1d:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c21:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103c24:	0f 82 79 ff ff ff    	jb     80103ba3 <mpinit+0x55>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103c2a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c2e:	75 0c                	jne    80103c3c <mpinit+0xee>
    panic("Didn't find a suitable machine");
80103c30:	c7 04 24 14 87 10 80 	movl   $0x80108714,(%esp)
80103c37:	e8 26 c9 ff ff       	call   80100562 <panic>

  if(mp->imcrp){
80103c3c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103c3f:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103c43:	84 c0                	test   %al,%al
80103c45:	74 36                	je     80103c7d <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103c47:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103c4e:	00 
80103c4f:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103c56:	e8 c7 fc ff ff       	call   80103922 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103c5b:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103c62:	e8 9e fc ff ff       	call   80103905 <inb>
80103c67:	83 c8 01             	or     $0x1,%eax
80103c6a:	0f b6 c0             	movzbl %al,%eax
80103c6d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c71:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103c78:	e8 a5 fc ff ff       	call   80103922 <outb>
  }
}
80103c7d:	c9                   	leave  
80103c7e:	c3                   	ret    

80103c7f <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103c7f:	55                   	push   %ebp
80103c80:	89 e5                	mov    %esp,%ebp
80103c82:	83 ec 08             	sub    $0x8,%esp
80103c85:	8b 55 08             	mov    0x8(%ebp),%edx
80103c88:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c8b:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103c8f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103c92:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103c96:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103c9a:	ee                   	out    %al,(%dx)
}
80103c9b:	c9                   	leave  
80103c9c:	c3                   	ret    

80103c9d <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103c9d:	55                   	push   %ebp
80103c9e:	89 e5                	mov    %esp,%ebp
80103ca0:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103ca3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103caa:	00 
80103cab:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103cb2:	e8 c8 ff ff ff       	call   80103c7f <outb>
  outb(IO_PIC2+1, 0xFF);
80103cb7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103cbe:	00 
80103cbf:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103cc6:	e8 b4 ff ff ff       	call   80103c7f <outb>
}
80103ccb:	c9                   	leave  
80103ccc:	c3                   	ret    

80103ccd <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103ccd:	55                   	push   %ebp
80103cce:	89 e5                	mov    %esp,%ebp
80103cd0:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103cd3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103cda:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cdd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103ce3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ce6:	8b 10                	mov    (%eax),%edx
80103ce8:	8b 45 08             	mov    0x8(%ebp),%eax
80103ceb:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103ced:	e8 76 d2 ff ff       	call   80100f68 <filealloc>
80103cf2:	8b 55 08             	mov    0x8(%ebp),%edx
80103cf5:	89 02                	mov    %eax,(%edx)
80103cf7:	8b 45 08             	mov    0x8(%ebp),%eax
80103cfa:	8b 00                	mov    (%eax),%eax
80103cfc:	85 c0                	test   %eax,%eax
80103cfe:	0f 84 c8 00 00 00    	je     80103dcc <pipealloc+0xff>
80103d04:	e8 5f d2 ff ff       	call   80100f68 <filealloc>
80103d09:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d0c:	89 02                	mov    %eax,(%edx)
80103d0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d11:	8b 00                	mov    (%eax),%eax
80103d13:	85 c0                	test   %eax,%eax
80103d15:	0f 84 b1 00 00 00    	je     80103dcc <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103d1b:	e8 6c ee ff ff       	call   80102b8c <kalloc>
80103d20:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d23:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d27:	75 05                	jne    80103d2e <pipealloc+0x61>
    goto bad;
80103d29:	e9 9e 00 00 00       	jmp    80103dcc <pipealloc+0xff>
  p->readopen = 1;
80103d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d31:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103d38:	00 00 00 
  p->writeopen = 1;
80103d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d3e:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103d45:	00 00 00 
  p->nwrite = 0;
80103d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d4b:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103d52:	00 00 00 
  p->nread = 0;
80103d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d58:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103d5f:	00 00 00 
  initlock(&p->lock, "pipe");
80103d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d65:	c7 44 24 04 48 87 10 	movl   $0x80108748,0x4(%esp)
80103d6c:	80 
80103d6d:	89 04 24             	mov    %eax,(%esp)
80103d70:	e8 d6 0f 00 00       	call   80104d4b <initlock>
  (*f0)->type = FD_PIPE;
80103d75:	8b 45 08             	mov    0x8(%ebp),%eax
80103d78:	8b 00                	mov    (%eax),%eax
80103d7a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103d80:	8b 45 08             	mov    0x8(%ebp),%eax
80103d83:	8b 00                	mov    (%eax),%eax
80103d85:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103d89:	8b 45 08             	mov    0x8(%ebp),%eax
80103d8c:	8b 00                	mov    (%eax),%eax
80103d8e:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103d92:	8b 45 08             	mov    0x8(%ebp),%eax
80103d95:	8b 00                	mov    (%eax),%eax
80103d97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d9a:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103d9d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103da0:	8b 00                	mov    (%eax),%eax
80103da2:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103da8:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dab:	8b 00                	mov    (%eax),%eax
80103dad:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103db1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103db4:	8b 00                	mov    (%eax),%eax
80103db6:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103dba:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dbd:	8b 00                	mov    (%eax),%eax
80103dbf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103dc2:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103dc5:	b8 00 00 00 00       	mov    $0x0,%eax
80103dca:	eb 42                	jmp    80103e0e <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80103dcc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103dd0:	74 0b                	je     80103ddd <pipealloc+0x110>
    kfree((char*)p);
80103dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dd5:	89 04 24             	mov    %eax,(%esp)
80103dd8:	e8 19 ed ff ff       	call   80102af6 <kfree>
  if(*f0)
80103ddd:	8b 45 08             	mov    0x8(%ebp),%eax
80103de0:	8b 00                	mov    (%eax),%eax
80103de2:	85 c0                	test   %eax,%eax
80103de4:	74 0d                	je     80103df3 <pipealloc+0x126>
    fileclose(*f0);
80103de6:	8b 45 08             	mov    0x8(%ebp),%eax
80103de9:	8b 00                	mov    (%eax),%eax
80103deb:	89 04 24             	mov    %eax,(%esp)
80103dee:	e8 1d d2 ff ff       	call   80101010 <fileclose>
  if(*f1)
80103df3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103df6:	8b 00                	mov    (%eax),%eax
80103df8:	85 c0                	test   %eax,%eax
80103dfa:	74 0d                	je     80103e09 <pipealloc+0x13c>
    fileclose(*f1);
80103dfc:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dff:	8b 00                	mov    (%eax),%eax
80103e01:	89 04 24             	mov    %eax,(%esp)
80103e04:	e8 07 d2 ff ff       	call   80101010 <fileclose>
  return -1;
80103e09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103e0e:	c9                   	leave  
80103e0f:	c3                   	ret    

80103e10 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103e10:	55                   	push   %ebp
80103e11:	89 e5                	mov    %esp,%ebp
80103e13:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80103e16:	8b 45 08             	mov    0x8(%ebp),%eax
80103e19:	89 04 24             	mov    %eax,(%esp)
80103e1c:	e8 4b 0f 00 00       	call   80104d6c <acquire>
  if(writable){
80103e21:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103e25:	74 1f                	je     80103e46 <pipeclose+0x36>
    p->writeopen = 0;
80103e27:	8b 45 08             	mov    0x8(%ebp),%eax
80103e2a:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103e31:	00 00 00 
    wakeup(&p->nread);
80103e34:	8b 45 08             	mov    0x8(%ebp),%eax
80103e37:	05 34 02 00 00       	add    $0x234,%eax
80103e3c:	89 04 24             	mov    %eax,(%esp)
80103e3f:	e8 31 0c 00 00       	call   80104a75 <wakeup>
80103e44:	eb 1d                	jmp    80103e63 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80103e46:	8b 45 08             	mov    0x8(%ebp),%eax
80103e49:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103e50:	00 00 00 
    wakeup(&p->nwrite);
80103e53:	8b 45 08             	mov    0x8(%ebp),%eax
80103e56:	05 38 02 00 00       	add    $0x238,%eax
80103e5b:	89 04 24             	mov    %eax,(%esp)
80103e5e:	e8 12 0c 00 00       	call   80104a75 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103e63:	8b 45 08             	mov    0x8(%ebp),%eax
80103e66:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103e6c:	85 c0                	test   %eax,%eax
80103e6e:	75 25                	jne    80103e95 <pipeclose+0x85>
80103e70:	8b 45 08             	mov    0x8(%ebp),%eax
80103e73:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103e79:	85 c0                	test   %eax,%eax
80103e7b:	75 18                	jne    80103e95 <pipeclose+0x85>
    release(&p->lock);
80103e7d:	8b 45 08             	mov    0x8(%ebp),%eax
80103e80:	89 04 24             	mov    %eax,(%esp)
80103e83:	e8 4c 0f 00 00       	call   80104dd4 <release>
    kfree((char*)p);
80103e88:	8b 45 08             	mov    0x8(%ebp),%eax
80103e8b:	89 04 24             	mov    %eax,(%esp)
80103e8e:	e8 63 ec ff ff       	call   80102af6 <kfree>
80103e93:	eb 0b                	jmp    80103ea0 <pipeclose+0x90>
  } else
    release(&p->lock);
80103e95:	8b 45 08             	mov    0x8(%ebp),%eax
80103e98:	89 04 24             	mov    %eax,(%esp)
80103e9b:	e8 34 0f 00 00       	call   80104dd4 <release>
}
80103ea0:	c9                   	leave  
80103ea1:	c3                   	ret    

80103ea2 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103ea2:	55                   	push   %ebp
80103ea3:	89 e5                	mov    %esp,%ebp
80103ea5:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
80103ea8:	8b 45 08             	mov    0x8(%ebp),%eax
80103eab:	89 04 24             	mov    %eax,(%esp)
80103eae:	e8 b9 0e 00 00       	call   80104d6c <acquire>
  for(i = 0; i < n; i++){
80103eb3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103eba:	e9 a5 00 00 00       	jmp    80103f64 <pipewrite+0xc2>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103ebf:	eb 56                	jmp    80103f17 <pipewrite+0x75>
      if(p->readopen == 0 || myproc()->killed){
80103ec1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ec4:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103eca:	85 c0                	test   %eax,%eax
80103ecc:	74 0c                	je     80103eda <pipewrite+0x38>
80103ece:	e8 76 02 00 00       	call   80104149 <myproc>
80103ed3:	8b 40 28             	mov    0x28(%eax),%eax
80103ed6:	85 c0                	test   %eax,%eax
80103ed8:	74 15                	je     80103eef <pipewrite+0x4d>
        release(&p->lock);
80103eda:	8b 45 08             	mov    0x8(%ebp),%eax
80103edd:	89 04 24             	mov    %eax,(%esp)
80103ee0:	e8 ef 0e 00 00       	call   80104dd4 <release>
        return -1;
80103ee5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103eea:	e9 9f 00 00 00       	jmp    80103f8e <pipewrite+0xec>
      }
      wakeup(&p->nread);
80103eef:	8b 45 08             	mov    0x8(%ebp),%eax
80103ef2:	05 34 02 00 00       	add    $0x234,%eax
80103ef7:	89 04 24             	mov    %eax,(%esp)
80103efa:	e8 76 0b 00 00       	call   80104a75 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103eff:	8b 45 08             	mov    0x8(%ebp),%eax
80103f02:	8b 55 08             	mov    0x8(%ebp),%edx
80103f05:	81 c2 38 02 00 00    	add    $0x238,%edx
80103f0b:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f0f:	89 14 24             	mov    %edx,(%esp)
80103f12:	e8 8a 0a 00 00       	call   801049a1 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103f17:	8b 45 08             	mov    0x8(%ebp),%eax
80103f1a:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103f20:	8b 45 08             	mov    0x8(%ebp),%eax
80103f23:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103f29:	05 00 02 00 00       	add    $0x200,%eax
80103f2e:	39 c2                	cmp    %eax,%edx
80103f30:	74 8f                	je     80103ec1 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103f32:	8b 45 08             	mov    0x8(%ebp),%eax
80103f35:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f3b:	8d 48 01             	lea    0x1(%eax),%ecx
80103f3e:	8b 55 08             	mov    0x8(%ebp),%edx
80103f41:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103f47:	25 ff 01 00 00       	and    $0x1ff,%eax
80103f4c:	89 c1                	mov    %eax,%ecx
80103f4e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f51:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f54:	01 d0                	add    %edx,%eax
80103f56:	0f b6 10             	movzbl (%eax),%edx
80103f59:	8b 45 08             	mov    0x8(%ebp),%eax
80103f5c:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80103f60:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103f64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f67:	3b 45 10             	cmp    0x10(%ebp),%eax
80103f6a:	0f 8c 4f ff ff ff    	jl     80103ebf <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103f70:	8b 45 08             	mov    0x8(%ebp),%eax
80103f73:	05 34 02 00 00       	add    $0x234,%eax
80103f78:	89 04 24             	mov    %eax,(%esp)
80103f7b:	e8 f5 0a 00 00       	call   80104a75 <wakeup>
  release(&p->lock);
80103f80:	8b 45 08             	mov    0x8(%ebp),%eax
80103f83:	89 04 24             	mov    %eax,(%esp)
80103f86:	e8 49 0e 00 00       	call   80104dd4 <release>
  return n;
80103f8b:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103f8e:	c9                   	leave  
80103f8f:	c3                   	ret    

80103f90 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103f90:	55                   	push   %ebp
80103f91:	89 e5                	mov    %esp,%ebp
80103f93:	53                   	push   %ebx
80103f94:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80103f97:	8b 45 08             	mov    0x8(%ebp),%eax
80103f9a:	89 04 24             	mov    %eax,(%esp)
80103f9d:	e8 ca 0d 00 00       	call   80104d6c <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103fa2:	eb 39                	jmp    80103fdd <piperead+0x4d>
    if(myproc()->killed){
80103fa4:	e8 a0 01 00 00       	call   80104149 <myproc>
80103fa9:	8b 40 28             	mov    0x28(%eax),%eax
80103fac:	85 c0                	test   %eax,%eax
80103fae:	74 15                	je     80103fc5 <piperead+0x35>
      release(&p->lock);
80103fb0:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb3:	89 04 24             	mov    %eax,(%esp)
80103fb6:	e8 19 0e 00 00       	call   80104dd4 <release>
      return -1;
80103fbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fc0:	e9 b5 00 00 00       	jmp    8010407a <piperead+0xea>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103fc5:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc8:	8b 55 08             	mov    0x8(%ebp),%edx
80103fcb:	81 c2 34 02 00 00    	add    $0x234,%edx
80103fd1:	89 44 24 04          	mov    %eax,0x4(%esp)
80103fd5:	89 14 24             	mov    %edx,(%esp)
80103fd8:	e8 c4 09 00 00       	call   801049a1 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103fdd:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe0:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103fe6:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe9:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103fef:	39 c2                	cmp    %eax,%edx
80103ff1:	75 0d                	jne    80104000 <piperead+0x70>
80103ff3:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff6:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103ffc:	85 c0                	test   %eax,%eax
80103ffe:	75 a4                	jne    80103fa4 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104000:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104007:	eb 4b                	jmp    80104054 <piperead+0xc4>
    if(p->nread == p->nwrite)
80104009:	8b 45 08             	mov    0x8(%ebp),%eax
8010400c:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104012:	8b 45 08             	mov    0x8(%ebp),%eax
80104015:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010401b:	39 c2                	cmp    %eax,%edx
8010401d:	75 02                	jne    80104021 <piperead+0x91>
      break;
8010401f:	eb 3b                	jmp    8010405c <piperead+0xcc>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104021:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104024:	8b 45 0c             	mov    0xc(%ebp),%eax
80104027:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010402a:	8b 45 08             	mov    0x8(%ebp),%eax
8010402d:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104033:	8d 48 01             	lea    0x1(%eax),%ecx
80104036:	8b 55 08             	mov    0x8(%ebp),%edx
80104039:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
8010403f:	25 ff 01 00 00       	and    $0x1ff,%eax
80104044:	89 c2                	mov    %eax,%edx
80104046:	8b 45 08             	mov    0x8(%ebp),%eax
80104049:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
8010404e:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104050:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104054:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104057:	3b 45 10             	cmp    0x10(%ebp),%eax
8010405a:	7c ad                	jl     80104009 <piperead+0x79>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010405c:	8b 45 08             	mov    0x8(%ebp),%eax
8010405f:	05 38 02 00 00       	add    $0x238,%eax
80104064:	89 04 24             	mov    %eax,(%esp)
80104067:	e8 09 0a 00 00       	call   80104a75 <wakeup>
  release(&p->lock);
8010406c:	8b 45 08             	mov    0x8(%ebp),%eax
8010406f:	89 04 24             	mov    %eax,(%esp)
80104072:	e8 5d 0d 00 00       	call   80104dd4 <release>
  return i;
80104077:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010407a:	83 c4 24             	add    $0x24,%esp
8010407d:	5b                   	pop    %ebx
8010407e:	5d                   	pop    %ebp
8010407f:	c3                   	ret    

80104080 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104080:	55                   	push   %ebp
80104081:	89 e5                	mov    %esp,%ebp
80104083:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104086:	9c                   	pushf  
80104087:	58                   	pop    %eax
80104088:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010408b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010408e:	c9                   	leave  
8010408f:	c3                   	ret    

80104090 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104090:	55                   	push   %ebp
80104091:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104093:	fb                   	sti    
}
80104094:	5d                   	pop    %ebp
80104095:	c3                   	ret    

80104096 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104096:	55                   	push   %ebp
80104097:	89 e5                	mov    %esp,%ebp
80104099:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
8010409c:	c7 44 24 04 50 87 10 	movl   $0x80108750,0x4(%esp)
801040a3:	80 
801040a4:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801040ab:	e8 9b 0c 00 00       	call   80104d4b <initlock>
}
801040b0:	c9                   	leave  
801040b1:	c3                   	ret    

801040b2 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
801040b2:	55                   	push   %ebp
801040b3:	89 e5                	mov    %esp,%ebp
801040b5:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801040b8:	e8 16 00 00 00       	call   801040d3 <mycpu>
801040bd:	89 c2                	mov    %eax,%edx
801040bf:	b8 00 38 11 80       	mov    $0x80113800,%eax
801040c4:	29 c2                	sub    %eax,%edx
801040c6:	89 d0                	mov    %edx,%eax
801040c8:	c1 f8 04             	sar    $0x4,%eax
801040cb:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801040d1:	c9                   	leave  
801040d2:	c3                   	ret    

801040d3 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801040d3:	55                   	push   %ebp
801040d4:	89 e5                	mov    %esp,%ebp
801040d6:	83 ec 28             	sub    $0x28,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
801040d9:	e8 a2 ff ff ff       	call   80104080 <readeflags>
801040de:	25 00 02 00 00       	and    $0x200,%eax
801040e3:	85 c0                	test   %eax,%eax
801040e5:	74 0c                	je     801040f3 <mycpu+0x20>
    panic("mycpu called with interrupts enabled\n");
801040e7:	c7 04 24 58 87 10 80 	movl   $0x80108758,(%esp)
801040ee:	e8 6f c4 ff ff       	call   80100562 <panic>
  
  apicid = lapicid();
801040f3:	e8 1a ee ff ff       	call   80102f12 <lapicid>
801040f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801040fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104102:	eb 2d                	jmp    80104131 <mycpu+0x5e>
    if (cpus[i].apicid == apicid)
80104104:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104107:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010410d:	05 00 38 11 80       	add    $0x80113800,%eax
80104112:	0f b6 00             	movzbl (%eax),%eax
80104115:	0f b6 c0             	movzbl %al,%eax
80104118:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010411b:	75 10                	jne    8010412d <mycpu+0x5a>
      return &cpus[i];
8010411d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104120:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80104126:	05 00 38 11 80       	add    $0x80113800,%eax
8010412b:	eb 1a                	jmp    80104147 <mycpu+0x74>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
8010412d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104131:	a1 80 3d 11 80       	mov    0x80113d80,%eax
80104136:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104139:	7c c9                	jl     80104104 <mycpu+0x31>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
8010413b:	c7 04 24 7e 87 10 80 	movl   $0x8010877e,(%esp)
80104142:	e8 1b c4 ff ff       	call   80100562 <panic>
}
80104147:	c9                   	leave  
80104148:	c3                   	ret    

80104149 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80104149:	55                   	push   %ebp
8010414a:	89 e5                	mov    %esp,%ebp
8010414c:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
8010414f:	e8 75 0d 00 00       	call   80104ec9 <pushcli>
  c = mycpu();
80104154:	e8 7a ff ff ff       	call   801040d3 <mycpu>
80104159:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
8010415c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010415f:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104165:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80104168:	e8 a8 0d 00 00       	call   80104f15 <popcli>
  return p;
8010416d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104170:	c9                   	leave  
80104171:	c3                   	ret    

80104172 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104172:	55                   	push   %ebp
80104173:	89 e5                	mov    %esp,%ebp
80104175:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104178:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
8010417f:	e8 e8 0b 00 00       	call   80104d6c <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104184:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
8010418b:	eb 50                	jmp    801041dd <allocproc+0x6b>
    if(p->state == UNUSED)
8010418d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104190:	8b 40 10             	mov    0x10(%eax),%eax
80104193:	85 c0                	test   %eax,%eax
80104195:	75 42                	jne    801041d9 <allocproc+0x67>
      goto found;
80104197:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104198:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010419b:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
  p->pid = nextpid++;
801041a2:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801041a7:	8d 50 01             	lea    0x1(%eax),%edx
801041aa:	89 15 00 b0 10 80    	mov    %edx,0x8010b000
801041b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041b3:	89 42 14             	mov    %eax,0x14(%edx)

  release(&ptable.lock);
801041b6:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801041bd:	e8 12 0c 00 00       	call   80104dd4 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801041c2:	e8 c5 e9 ff ff       	call   80102b8c <kalloc>
801041c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041ca:	89 42 0c             	mov    %eax,0xc(%edx)
801041cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041d0:	8b 40 0c             	mov    0xc(%eax),%eax
801041d3:	85 c0                	test   %eax,%eax
801041d5:	75 33                	jne    8010420a <allocproc+0x98>
801041d7:	eb 20                	jmp    801041f9 <allocproc+0x87>
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801041d9:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801041dd:	81 7d f4 d4 5d 11 80 	cmpl   $0x80115dd4,-0xc(%ebp)
801041e4:	72 a7                	jb     8010418d <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
801041e6:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801041ed:	e8 e2 0b 00 00       	call   80104dd4 <release>
  return 0;
801041f2:	b8 00 00 00 00       	mov    $0x0,%eax
801041f7:	eb 76                	jmp    8010426f <allocproc+0xfd>

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
801041f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041fc:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
    return 0;
80104203:	b8 00 00 00 00       	mov    $0x0,%eax
80104208:	eb 65                	jmp    8010426f <allocproc+0xfd>
  }
  sp = p->kstack + KSTACKSIZE;
8010420a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010420d:	8b 40 0c             	mov    0xc(%eax),%eax
80104210:	05 00 10 00 00       	add    $0x1000,%eax
80104215:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104218:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010421c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010421f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104222:	89 50 1c             	mov    %edx,0x1c(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104225:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104229:	ba d3 63 10 80       	mov    $0x801063d3,%edx
8010422e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104231:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104233:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104237:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010423a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010423d:	89 50 20             	mov    %edx,0x20(%eax)
  memset(p->context, 0, sizeof *p->context);
80104240:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104243:	8b 40 20             	mov    0x20(%eax),%eax
80104246:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010424d:	00 
8010424e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104255:	00 
80104256:	89 04 24             	mov    %eax,(%esp)
80104259:	e8 70 0d 00 00       	call   80104fce <memset>
  p->context->eip = (uint)forkret;
8010425e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104261:	8b 40 20             	mov    0x20(%eax),%eax
80104264:	ba 62 49 10 80       	mov    $0x80104962,%edx
80104269:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010426c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010426f:	c9                   	leave  
80104270:	c3                   	ret    

80104271 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104271:	55                   	push   %ebp
80104272:	89 e5                	mov    %esp,%ebp
80104274:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104277:	e8 f6 fe ff ff       	call   80104172 <allocproc>
8010427c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
8010427f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104282:	a3 20 b6 10 80       	mov    %eax,0x8010b620
  if((p->pgdir = setupkvm()) == 0)
80104287:	e8 59 37 00 00       	call   801079e5 <setupkvm>
8010428c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010428f:	89 42 08             	mov    %eax,0x8(%edx)
80104292:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104295:	8b 40 08             	mov    0x8(%eax),%eax
80104298:	85 c0                	test   %eax,%eax
8010429a:	75 0c                	jne    801042a8 <userinit+0x37>
    panic("userinit: out of memory?");
8010429c:	c7 04 24 8e 87 10 80 	movl   $0x8010878e,(%esp)
801042a3:	e8 ba c2 ff ff       	call   80100562 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801042a8:	ba 2c 00 00 00       	mov    $0x2c,%edx
801042ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042b0:	8b 40 08             	mov    0x8(%eax),%eax
801042b3:	89 54 24 08          	mov    %edx,0x8(%esp)
801042b7:	c7 44 24 04 c0 b4 10 	movl   $0x8010b4c0,0x4(%esp)
801042be:	80 
801042bf:	89 04 24             	mov    %eax,(%esp)
801042c2:	e8 89 39 00 00       	call   80107c50 <inituvm>
  p->sz = PGSIZE;
801042c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ca:	c7 40 04 00 10 00 00 	movl   $0x1000,0x4(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801042d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d4:	8b 40 1c             	mov    0x1c(%eax),%eax
801042d7:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801042de:	00 
801042df:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801042e6:	00 
801042e7:	89 04 24             	mov    %eax,(%esp)
801042ea:	e8 df 0c 00 00       	call   80104fce <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801042ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f2:	8b 40 1c             	mov    0x1c(%eax),%eax
801042f5:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801042fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042fe:	8b 40 1c             	mov    0x1c(%eax),%eax
80104301:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104307:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010430a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010430d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104310:	8b 52 1c             	mov    0x1c(%edx),%edx
80104313:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104317:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010431b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010431e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104321:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104324:	8b 52 1c             	mov    0x1c(%edx),%edx
80104327:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010432b:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010432f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104332:	8b 40 1c             	mov    0x1c(%eax),%eax
80104335:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010433c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010433f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104342:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104349:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010434f:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104356:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104359:	83 c0 70             	add    $0x70,%eax
8010435c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104363:	00 
80104364:	c7 44 24 04 a7 87 10 	movl   $0x801087a7,0x4(%esp)
8010436b:	80 
8010436c:	89 04 24             	mov    %eax,(%esp)
8010436f:	e8 7a 0e 00 00       	call   801051ee <safestrcpy>
  p->cwd = namei("/");
80104374:	c7 04 24 b0 87 10 80 	movl   $0x801087b0,(%esp)
8010437b:	e8 fa e0 ff ff       	call   8010247a <namei>
80104380:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104383:	89 42 6c             	mov    %eax,0x6c(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80104386:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
8010438d:	e8 da 09 00 00       	call   80104d6c <acquire>

  p->state = RUNNABLE;
80104392:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104395:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)

  release(&ptable.lock);
8010439c:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801043a3:	e8 2c 0a 00 00       	call   80104dd4 <release>
}
801043a8:	c9                   	leave  
801043a9:	c3                   	ret    

801043aa <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801043aa:	55                   	push   %ebp
801043ab:	89 e5                	mov    %esp,%ebp
801043ad:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
801043b0:	e8 94 fd ff ff       	call   80104149 <myproc>
801043b5:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
801043b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043bb:	8b 40 04             	mov    0x4(%eax),%eax
801043be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801043c1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801043c5:	7e 31                	jle    801043f8 <growproc+0x4e>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801043c7:	8b 55 08             	mov    0x8(%ebp),%edx
801043ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043cd:	01 c2                	add    %eax,%edx
801043cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043d2:	8b 40 08             	mov    0x8(%eax),%eax
801043d5:	89 54 24 08          	mov    %edx,0x8(%esp)
801043d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043dc:	89 54 24 04          	mov    %edx,0x4(%esp)
801043e0:	89 04 24             	mov    %eax,(%esp)
801043e3:	e8 d3 39 00 00       	call   80107dbb <allocuvm>
801043e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801043eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801043ef:	75 3e                	jne    8010442f <growproc+0x85>
      return -1;
801043f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043f6:	eb 50                	jmp    80104448 <growproc+0x9e>
  } else if(n < 0){
801043f8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801043fc:	79 31                	jns    8010442f <growproc+0x85>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801043fe:	8b 55 08             	mov    0x8(%ebp),%edx
80104401:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104404:	01 c2                	add    %eax,%edx
80104406:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104409:	8b 40 08             	mov    0x8(%eax),%eax
8010440c:	89 54 24 08          	mov    %edx,0x8(%esp)
80104410:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104413:	89 54 24 04          	mov    %edx,0x4(%esp)
80104417:	89 04 24             	mov    %eax,(%esp)
8010441a:	e8 b2 3a 00 00       	call   80107ed1 <deallocuvm>
8010441f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104422:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104426:	75 07                	jne    8010442f <growproc+0x85>
      return -1;
80104428:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010442d:	eb 19                	jmp    80104448 <growproc+0x9e>
  }
  curproc->sz = sz;
8010442f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104432:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104435:	89 50 04             	mov    %edx,0x4(%eax)
  switchuvm(curproc);
80104438:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010443b:	89 04 24             	mov    %eax,(%esp)
8010443e:	e8 7c 36 00 00       	call   80107abf <switchuvm>
  return 0;
80104443:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104448:	c9                   	leave  
80104449:	c3                   	ret    

8010444a <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010444a:	55                   	push   %ebp
8010444b:	89 e5                	mov    %esp,%ebp
8010444d:	57                   	push   %edi
8010444e:	56                   	push   %esi
8010444f:	53                   	push   %ebx
80104450:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80104453:	e8 f1 fc ff ff       	call   80104149 <myproc>
80104458:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
8010445b:	e8 12 fd ff ff       	call   80104172 <allocproc>
80104460:	89 45 dc             	mov    %eax,-0x24(%ebp)
80104463:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104467:	75 0a                	jne    80104473 <fork+0x29>
    return -1;
80104469:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010446e:	e9 46 01 00 00       	jmp    801045b9 <fork+0x16f>
  }

  // Copy process state from proc.
  // CS153 -- added
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz, curproc->tf->esp)) == 0){ //the added parameter updates the top of the stack; STACKTOP
80104473:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104476:	8b 40 1c             	mov    0x1c(%eax),%eax
80104479:	8b 48 44             	mov    0x44(%eax),%ecx
8010447c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010447f:	8b 50 04             	mov    0x4(%eax),%edx
80104482:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104485:	8b 40 08             	mov    0x8(%eax),%eax
80104488:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010448c:	89 54 24 04          	mov    %edx,0x4(%esp)
80104490:	89 04 24             	mov    %eax,(%esp)
80104493:	e8 dc 3b 00 00       	call   80108074 <copyuvm>
80104498:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010449b:	89 42 08             	mov    %eax,0x8(%edx)
8010449e:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044a1:	8b 40 08             	mov    0x8(%eax),%eax
801044a4:	85 c0                	test   %eax,%eax
801044a6:	75 2c                	jne    801044d4 <fork+0x8a>
    kfree(np->kstack);
801044a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044ab:	8b 40 0c             	mov    0xc(%eax),%eax
801044ae:	89 04 24             	mov    %eax,(%esp)
801044b1:	e8 40 e6 ff ff       	call   80102af6 <kfree>
    np->kstack = 0;
801044b6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044b9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    np->state = UNUSED;
801044c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044c3:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
    return -1;
801044ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044cf:	e9 e5 00 00 00       	jmp    801045b9 <fork+0x16f>
  }
  np->sz = curproc->sz;
801044d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044d7:	8b 50 04             	mov    0x4(%eax),%edx
801044da:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044dd:	89 50 04             	mov    %edx,0x4(%eax)
  np->parent = curproc;
801044e0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044e3:	8b 55 e0             	mov    -0x20(%ebp),%edx
801044e6:	89 50 18             	mov    %edx,0x18(%eax)
  *np->tf = *curproc->tf;
801044e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044ec:	8b 50 1c             	mov    0x1c(%eax),%edx
801044ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044f2:	8b 40 1c             	mov    0x1c(%eax),%eax
801044f5:	89 c3                	mov    %eax,%ebx
801044f7:	b8 13 00 00 00       	mov    $0x13,%eax
801044fc:	89 d7                	mov    %edx,%edi
801044fe:	89 de                	mov    %ebx,%esi
80104500:	89 c1                	mov    %eax,%ecx
80104502:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104504:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104507:	8b 40 1c             	mov    0x1c(%eax),%eax
8010450a:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104511:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104518:	eb 37                	jmp    80104551 <fork+0x107>
    if(curproc->ofile[i])
8010451a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010451d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104520:	83 c2 08             	add    $0x8,%edx
80104523:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104527:	85 c0                	test   %eax,%eax
80104529:	74 22                	je     8010454d <fork+0x103>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010452b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010452e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104531:	83 c2 08             	add    $0x8,%edx
80104534:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104538:	89 04 24             	mov    %eax,(%esp)
8010453b:	e8 88 ca ff ff       	call   80100fc8 <filedup>
80104540:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104543:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104546:	83 c1 08             	add    $0x8,%ecx
80104549:	89 44 8a 0c          	mov    %eax,0xc(%edx,%ecx,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010454d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104551:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104555:	7e c3                	jle    8010451a <fork+0xd0>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
80104557:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010455a:	8b 40 6c             	mov    0x6c(%eax),%eax
8010455d:	89 04 24             	mov    %eax,(%esp)
80104560:	e8 a9 d3 ff ff       	call   8010190e <idup>
80104565:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104568:	89 42 6c             	mov    %eax,0x6c(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010456b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010456e:	8d 50 70             	lea    0x70(%eax),%edx
80104571:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104574:	83 c0 70             	add    $0x70,%eax
80104577:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010457e:	00 
8010457f:	89 54 24 04          	mov    %edx,0x4(%esp)
80104583:	89 04 24             	mov    %eax,(%esp)
80104586:	e8 63 0c 00 00       	call   801051ee <safestrcpy>

  pid = np->pid;
8010458b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010458e:	8b 40 14             	mov    0x14(%eax),%eax
80104591:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104594:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
8010459b:	e8 cc 07 00 00       	call   80104d6c <acquire>

  np->state = RUNNABLE;
801045a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045a3:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)

  release(&ptable.lock);
801045aa:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801045b1:	e8 1e 08 00 00       	call   80104dd4 <release>

  return pid;
801045b6:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
801045b9:	83 c4 2c             	add    $0x2c,%esp
801045bc:	5b                   	pop    %ebx
801045bd:	5e                   	pop    %esi
801045be:	5f                   	pop    %edi
801045bf:	5d                   	pop    %ebp
801045c0:	c3                   	ret    

801045c1 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801045c1:	55                   	push   %ebp
801045c2:	89 e5                	mov    %esp,%ebp
801045c4:	83 ec 28             	sub    $0x28,%esp
  struct proc *curproc = myproc();
801045c7:	e8 7d fb ff ff       	call   80104149 <myproc>
801045cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
801045cf:	a1 20 b6 10 80       	mov    0x8010b620,%eax
801045d4:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801045d7:	75 0c                	jne    801045e5 <exit+0x24>
    panic("init exiting");
801045d9:	c7 04 24 b2 87 10 80 	movl   $0x801087b2,(%esp)
801045e0:	e8 7d bf ff ff       	call   80100562 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801045e5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801045ec:	eb 3b                	jmp    80104629 <exit+0x68>
    if(curproc->ofile[fd]){
801045ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045f1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045f4:	83 c2 08             	add    $0x8,%edx
801045f7:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801045fb:	85 c0                	test   %eax,%eax
801045fd:	74 26                	je     80104625 <exit+0x64>
      fileclose(curproc->ofile[fd]);
801045ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104602:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104605:	83 c2 08             	add    $0x8,%edx
80104608:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010460c:	89 04 24             	mov    %eax,(%esp)
8010460f:	e8 fc c9 ff ff       	call   80101010 <fileclose>
      curproc->ofile[fd] = 0;
80104614:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104617:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010461a:	83 c2 08             	add    $0x8,%edx
8010461d:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80104624:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104625:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104629:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010462d:	7e bf                	jle    801045ee <exit+0x2d>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
8010462f:	e8 36 ee ff ff       	call   8010346a <begin_op>
  iput(curproc->cwd);
80104634:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104637:	8b 40 6c             	mov    0x6c(%eax),%eax
8010463a:	89 04 24             	mov    %eax,(%esp)
8010463d:	e8 4f d4 ff ff       	call   80101a91 <iput>
  end_op();
80104642:	e8 a7 ee ff ff       	call   801034ee <end_op>
  curproc->cwd = 0;
80104647:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010464a:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)

  acquire(&ptable.lock);
80104651:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104658:	e8 0f 07 00 00       	call   80104d6c <acquire>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
8010465d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104660:	8b 40 18             	mov    0x18(%eax),%eax
80104663:	89 04 24             	mov    %eax,(%esp)
80104666:	e8 cc 03 00 00       	call   80104a37 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010466b:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
80104672:	eb 33                	jmp    801046a7 <exit+0xe6>
    if(p->parent == curproc){
80104674:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104677:	8b 40 18             	mov    0x18(%eax),%eax
8010467a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010467d:	75 24                	jne    801046a3 <exit+0xe2>
      p->parent = initproc;
8010467f:	8b 15 20 b6 10 80    	mov    0x8010b620,%edx
80104685:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104688:	89 50 18             	mov    %edx,0x18(%eax)
      if(p->state == ZOMBIE)
8010468b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468e:	8b 40 10             	mov    0x10(%eax),%eax
80104691:	83 f8 05             	cmp    $0x5,%eax
80104694:	75 0d                	jne    801046a3 <exit+0xe2>
        wakeup1(initproc);
80104696:	a1 20 b6 10 80       	mov    0x8010b620,%eax
8010469b:	89 04 24             	mov    %eax,(%esp)
8010469e:	e8 94 03 00 00       	call   80104a37 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046a3:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801046a7:	81 7d f4 d4 5d 11 80 	cmpl   $0x80115dd4,-0xc(%ebp)
801046ae:	72 c4                	jb     80104674 <exit+0xb3>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801046b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046b3:	c7 40 10 05 00 00 00 	movl   $0x5,0x10(%eax)
  sched();
801046ba:	e8 c3 01 00 00       	call   80104882 <sched>
  panic("zombie exit");
801046bf:	c7 04 24 bf 87 10 80 	movl   $0x801087bf,(%esp)
801046c6:	e8 97 be ff ff       	call   80100562 <panic>

801046cb <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801046cb:	55                   	push   %ebp
801046cc:	89 e5                	mov    %esp,%ebp
801046ce:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801046d1:	e8 73 fa ff ff       	call   80104149 <myproc>
801046d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801046d9:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801046e0:	e8 87 06 00 00       	call   80104d6c <acquire>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801046e5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046ec:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
801046f3:	e9 95 00 00 00       	jmp    8010478d <wait+0xc2>
      if(p->parent != curproc)
801046f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046fb:	8b 40 18             	mov    0x18(%eax),%eax
801046fe:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104701:	74 05                	je     80104708 <wait+0x3d>
        continue;
80104703:	e9 81 00 00 00       	jmp    80104789 <wait+0xbe>
      havekids = 1;
80104708:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010470f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104712:	8b 40 10             	mov    0x10(%eax),%eax
80104715:	83 f8 05             	cmp    $0x5,%eax
80104718:	75 6f                	jne    80104789 <wait+0xbe>
        // Found one.
        pid = p->pid;
8010471a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010471d:	8b 40 14             	mov    0x14(%eax),%eax
80104720:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104723:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104726:	8b 40 0c             	mov    0xc(%eax),%eax
80104729:	89 04 24             	mov    %eax,(%esp)
8010472c:	e8 c5 e3 ff ff       	call   80102af6 <kfree>
        p->kstack = 0;
80104731:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104734:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        freevm(p->pgdir);
8010473b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010473e:	8b 40 08             	mov    0x8(%eax),%eax
80104741:	89 04 24             	mov    %eax,(%esp)
80104744:	e8 4e 38 00 00       	call   80107f97 <freevm>
        p->pid = 0;
80104749:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010474c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->parent = 0;
80104753:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104756:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
        p->name[0] = 0;
8010475d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104760:	c6 40 70 00          	movb   $0x0,0x70(%eax)
        p->killed = 0;
80104764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104767:	c7 40 28 00 00 00 00 	movl   $0x0,0x28(%eax)
        p->state = UNUSED;
8010476e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104771:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        release(&ptable.lock);
80104778:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
8010477f:	e8 50 06 00 00       	call   80104dd4 <release>
        return pid;
80104784:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104787:	eb 4c                	jmp    801047d5 <wait+0x10a>
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104789:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010478d:	81 7d f4 d4 5d 11 80 	cmpl   $0x80115dd4,-0xc(%ebp)
80104794:	0f 82 5e ff ff ff    	jb     801046f8 <wait+0x2d>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
8010479a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010479e:	74 0a                	je     801047aa <wait+0xdf>
801047a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047a3:	8b 40 28             	mov    0x28(%eax),%eax
801047a6:	85 c0                	test   %eax,%eax
801047a8:	74 13                	je     801047bd <wait+0xf2>
      release(&ptable.lock);
801047aa:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801047b1:	e8 1e 06 00 00       	call   80104dd4 <release>
      return -1;
801047b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047bb:	eb 18                	jmp    801047d5 <wait+0x10a>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801047bd:	c7 44 24 04 a0 3d 11 	movl   $0x80113da0,0x4(%esp)
801047c4:	80 
801047c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047c8:	89 04 24             	mov    %eax,(%esp)
801047cb:	e8 d1 01 00 00       	call   801049a1 <sleep>
  }
801047d0:	e9 10 ff ff ff       	jmp    801046e5 <wait+0x1a>
}
801047d5:	c9                   	leave  
801047d6:	c3                   	ret    

801047d7 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801047d7:	55                   	push   %ebp
801047d8:	89 e5                	mov    %esp,%ebp
801047da:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801047dd:	e8 f1 f8 ff ff       	call   801040d3 <mycpu>
801047e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801047e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047e8:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801047ef:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801047f2:	e8 99 f8 ff ff       	call   80104090 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801047f7:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801047fe:	e8 69 05 00 00       	call   80104d6c <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104803:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
8010480a:	eb 5c                	jmp    80104868 <scheduler+0x91>
      if(p->state != RUNNABLE)
8010480c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010480f:	8b 40 10             	mov    0x10(%eax),%eax
80104812:	83 f8 03             	cmp    $0x3,%eax
80104815:	74 02                	je     80104819 <scheduler+0x42>
        continue;
80104817:	eb 4b                	jmp    80104864 <scheduler+0x8d>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104819:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010481c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010481f:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104825:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104828:	89 04 24             	mov    %eax,(%esp)
8010482b:	e8 8f 32 00 00       	call   80107abf <switchuvm>
      p->state = RUNNING;
80104830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104833:	c7 40 10 04 00 00 00 	movl   $0x4,0x10(%eax)

      swtch(&(c->scheduler), p->context);
8010483a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010483d:	8b 40 20             	mov    0x20(%eax),%eax
80104840:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104843:	83 c2 04             	add    $0x4,%edx
80104846:	89 44 24 04          	mov    %eax,0x4(%esp)
8010484a:	89 14 24             	mov    %edx,(%esp)
8010484d:	e8 0d 0a 00 00       	call   8010525f <swtch>
      switchkvm();
80104852:	e8 4e 32 00 00       	call   80107aa5 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104857:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010485a:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104861:	00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104864:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104868:	81 7d f4 d4 5d 11 80 	cmpl   $0x80115dd4,-0xc(%ebp)
8010486f:	72 9b                	jb     8010480c <scheduler+0x35>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
80104871:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104878:	e8 57 05 00 00       	call   80104dd4 <release>

  }
8010487d:	e9 70 ff ff ff       	jmp    801047f2 <scheduler+0x1b>

80104882 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104882:	55                   	push   %ebp
80104883:	89 e5                	mov    %esp,%ebp
80104885:	83 ec 28             	sub    $0x28,%esp
  int intena;
  struct proc *p = myproc();
80104888:	e8 bc f8 ff ff       	call   80104149 <myproc>
8010488d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104890:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104897:	e8 fc 05 00 00       	call   80104e98 <holding>
8010489c:	85 c0                	test   %eax,%eax
8010489e:	75 0c                	jne    801048ac <sched+0x2a>
    panic("sched ptable.lock");
801048a0:	c7 04 24 cb 87 10 80 	movl   $0x801087cb,(%esp)
801048a7:	e8 b6 bc ff ff       	call   80100562 <panic>
  if(mycpu()->ncli != 1)
801048ac:	e8 22 f8 ff ff       	call   801040d3 <mycpu>
801048b1:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801048b7:	83 f8 01             	cmp    $0x1,%eax
801048ba:	74 0c                	je     801048c8 <sched+0x46>
    panic("sched locks");
801048bc:	c7 04 24 dd 87 10 80 	movl   $0x801087dd,(%esp)
801048c3:	e8 9a bc ff ff       	call   80100562 <panic>
  if(p->state == RUNNING)
801048c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048cb:	8b 40 10             	mov    0x10(%eax),%eax
801048ce:	83 f8 04             	cmp    $0x4,%eax
801048d1:	75 0c                	jne    801048df <sched+0x5d>
    panic("sched running");
801048d3:	c7 04 24 e9 87 10 80 	movl   $0x801087e9,(%esp)
801048da:	e8 83 bc ff ff       	call   80100562 <panic>
  if(readeflags()&FL_IF)
801048df:	e8 9c f7 ff ff       	call   80104080 <readeflags>
801048e4:	25 00 02 00 00       	and    $0x200,%eax
801048e9:	85 c0                	test   %eax,%eax
801048eb:	74 0c                	je     801048f9 <sched+0x77>
    panic("sched interruptible");
801048ed:	c7 04 24 f7 87 10 80 	movl   $0x801087f7,(%esp)
801048f4:	e8 69 bc ff ff       	call   80100562 <panic>
  intena = mycpu()->intena;
801048f9:	e8 d5 f7 ff ff       	call   801040d3 <mycpu>
801048fe:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104904:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104907:	e8 c7 f7 ff ff       	call   801040d3 <mycpu>
8010490c:	8b 40 04             	mov    0x4(%eax),%eax
8010490f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104912:	83 c2 20             	add    $0x20,%edx
80104915:	89 44 24 04          	mov    %eax,0x4(%esp)
80104919:	89 14 24             	mov    %edx,(%esp)
8010491c:	e8 3e 09 00 00       	call   8010525f <swtch>
  mycpu()->intena = intena;
80104921:	e8 ad f7 ff ff       	call   801040d3 <mycpu>
80104926:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104929:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
8010492f:	c9                   	leave  
80104930:	c3                   	ret    

80104931 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104931:	55                   	push   %ebp
80104932:	89 e5                	mov    %esp,%ebp
80104934:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104937:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
8010493e:	e8 29 04 00 00       	call   80104d6c <acquire>
  myproc()->state = RUNNABLE;
80104943:	e8 01 f8 ff ff       	call   80104149 <myproc>
80104948:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
  sched();
8010494f:	e8 2e ff ff ff       	call   80104882 <sched>
  release(&ptable.lock);
80104954:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
8010495b:	e8 74 04 00 00       	call   80104dd4 <release>
}
80104960:	c9                   	leave  
80104961:	c3                   	ret    

80104962 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104962:	55                   	push   %ebp
80104963:	89 e5                	mov    %esp,%ebp
80104965:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104968:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
8010496f:	e8 60 04 00 00       	call   80104dd4 <release>

  if (first) {
80104974:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104979:	85 c0                	test   %eax,%eax
8010497b:	74 22                	je     8010499f <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
8010497d:	c7 05 04 b0 10 80 00 	movl   $0x0,0x8010b004
80104984:	00 00 00 
    iinit(ROOTDEV);
80104987:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010498e:	e8 40 cc ff ff       	call   801015d3 <iinit>
    initlog(ROOTDEV);
80104993:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010499a:	e8 c7 e8 ff ff       	call   80103266 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
8010499f:	c9                   	leave  
801049a0:	c3                   	ret    

801049a1 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801049a1:	55                   	push   %ebp
801049a2:	89 e5                	mov    %esp,%ebp
801049a4:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = myproc();
801049a7:	e8 9d f7 ff ff       	call   80104149 <myproc>
801049ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801049af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801049b3:	75 0c                	jne    801049c1 <sleep+0x20>
    panic("sleep");
801049b5:	c7 04 24 0b 88 10 80 	movl   $0x8010880b,(%esp)
801049bc:	e8 a1 bb ff ff       	call   80100562 <panic>

  if(lk == 0)
801049c1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801049c5:	75 0c                	jne    801049d3 <sleep+0x32>
    panic("sleep without lk");
801049c7:	c7 04 24 11 88 10 80 	movl   $0x80108811,(%esp)
801049ce:	e8 8f bb ff ff       	call   80100562 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801049d3:	81 7d 0c a0 3d 11 80 	cmpl   $0x80113da0,0xc(%ebp)
801049da:	74 17                	je     801049f3 <sleep+0x52>
    acquire(&ptable.lock);  //DOC: sleeplock1
801049dc:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801049e3:	e8 84 03 00 00       	call   80104d6c <acquire>
    release(lk);
801049e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801049eb:	89 04 24             	mov    %eax,(%esp)
801049ee:	e8 e1 03 00 00       	call   80104dd4 <release>
  }
  // Go to sleep.
  p->chan = chan;
801049f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f6:	8b 55 08             	mov    0x8(%ebp),%edx
801049f9:	89 50 24             	mov    %edx,0x24(%eax)
  p->state = SLEEPING;
801049fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ff:	c7 40 10 02 00 00 00 	movl   $0x2,0x10(%eax)

  sched();
80104a06:	e8 77 fe ff ff       	call   80104882 <sched>

  // Tidy up.
  p->chan = 0;
80104a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a0e:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104a15:	81 7d 0c a0 3d 11 80 	cmpl   $0x80113da0,0xc(%ebp)
80104a1c:	74 17                	je     80104a35 <sleep+0x94>
    release(&ptable.lock);
80104a1e:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104a25:	e8 aa 03 00 00       	call   80104dd4 <release>
    acquire(lk);
80104a2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a2d:	89 04 24             	mov    %eax,(%esp)
80104a30:	e8 37 03 00 00       	call   80104d6c <acquire>
  }
}
80104a35:	c9                   	leave  
80104a36:	c3                   	ret    

80104a37 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104a37:	55                   	push   %ebp
80104a38:	89 e5                	mov    %esp,%ebp
80104a3a:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104a3d:	c7 45 fc d4 3d 11 80 	movl   $0x80113dd4,-0x4(%ebp)
80104a44:	eb 24                	jmp    80104a6a <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104a46:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a49:	8b 40 10             	mov    0x10(%eax),%eax
80104a4c:	83 f8 02             	cmp    $0x2,%eax
80104a4f:	75 15                	jne    80104a66 <wakeup1+0x2f>
80104a51:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a54:	8b 40 24             	mov    0x24(%eax),%eax
80104a57:	3b 45 08             	cmp    0x8(%ebp),%eax
80104a5a:	75 0a                	jne    80104a66 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104a5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a5f:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104a66:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
80104a6a:	81 7d fc d4 5d 11 80 	cmpl   $0x80115dd4,-0x4(%ebp)
80104a71:	72 d3                	jb     80104a46 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104a73:	c9                   	leave  
80104a74:	c3                   	ret    

80104a75 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104a75:	55                   	push   %ebp
80104a76:	89 e5                	mov    %esp,%ebp
80104a78:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104a7b:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104a82:	e8 e5 02 00 00       	call   80104d6c <acquire>
  wakeup1(chan);
80104a87:	8b 45 08             	mov    0x8(%ebp),%eax
80104a8a:	89 04 24             	mov    %eax,(%esp)
80104a8d:	e8 a5 ff ff ff       	call   80104a37 <wakeup1>
  release(&ptable.lock);
80104a92:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104a99:	e8 36 03 00 00       	call   80104dd4 <release>
}
80104a9e:	c9                   	leave  
80104a9f:	c3                   	ret    

80104aa0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104aa0:	55                   	push   %ebp
80104aa1:	89 e5                	mov    %esp,%ebp
80104aa3:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104aa6:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104aad:	e8 ba 02 00 00       	call   80104d6c <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ab2:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
80104ab9:	eb 41                	jmp    80104afc <kill+0x5c>
    if(p->pid == pid){
80104abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104abe:	8b 40 14             	mov    0x14(%eax),%eax
80104ac1:	3b 45 08             	cmp    0x8(%ebp),%eax
80104ac4:	75 32                	jne    80104af8 <kill+0x58>
      p->killed = 1;
80104ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac9:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad3:	8b 40 10             	mov    0x10(%eax),%eax
80104ad6:	83 f8 02             	cmp    $0x2,%eax
80104ad9:	75 0a                	jne    80104ae5 <kill+0x45>
        p->state = RUNNABLE;
80104adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ade:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
      release(&ptable.lock);
80104ae5:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104aec:	e8 e3 02 00 00       	call   80104dd4 <release>
      return 0;
80104af1:	b8 00 00 00 00       	mov    $0x0,%eax
80104af6:	eb 1e                	jmp    80104b16 <kill+0x76>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104af8:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104afc:	81 7d f4 d4 5d 11 80 	cmpl   $0x80115dd4,-0xc(%ebp)
80104b03:	72 b6                	jb     80104abb <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104b05:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104b0c:	e8 c3 02 00 00       	call   80104dd4 <release>
  return -1;
80104b11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104b16:	c9                   	leave  
80104b17:	c3                   	ret    

80104b18 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104b18:	55                   	push   %ebp
80104b19:	89 e5                	mov    %esp,%ebp
80104b1b:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b1e:	c7 45 f0 d4 3d 11 80 	movl   $0x80113dd4,-0x10(%ebp)
80104b25:	e9 d6 00 00 00       	jmp    80104c00 <procdump+0xe8>
    if(p->state == UNUSED)
80104b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b2d:	8b 40 10             	mov    0x10(%eax),%eax
80104b30:	85 c0                	test   %eax,%eax
80104b32:	75 05                	jne    80104b39 <procdump+0x21>
      continue;
80104b34:	e9 c3 00 00 00       	jmp    80104bfc <procdump+0xe4>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104b39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b3c:	8b 40 10             	mov    0x10(%eax),%eax
80104b3f:	83 f8 05             	cmp    $0x5,%eax
80104b42:	77 23                	ja     80104b67 <procdump+0x4f>
80104b44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b47:	8b 40 10             	mov    0x10(%eax),%eax
80104b4a:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104b51:	85 c0                	test   %eax,%eax
80104b53:	74 12                	je     80104b67 <procdump+0x4f>
      state = states[p->state];
80104b55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b58:	8b 40 10             	mov    0x10(%eax),%eax
80104b5b:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104b62:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104b65:	eb 07                	jmp    80104b6e <procdump+0x56>
    else
      state = "???";
80104b67:	c7 45 ec 22 88 10 80 	movl   $0x80108822,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104b6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b71:	8d 50 70             	lea    0x70(%eax),%edx
80104b74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b77:	8b 40 14             	mov    0x14(%eax),%eax
80104b7a:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104b7e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104b81:	89 54 24 08          	mov    %edx,0x8(%esp)
80104b85:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b89:	c7 04 24 26 88 10 80 	movl   $0x80108826,(%esp)
80104b90:	e8 33 b8 ff ff       	call   801003c8 <cprintf>
    if(p->state == SLEEPING){
80104b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b98:	8b 40 10             	mov    0x10(%eax),%eax
80104b9b:	83 f8 02             	cmp    $0x2,%eax
80104b9e:	75 50                	jne    80104bf0 <procdump+0xd8>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104ba0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ba3:	8b 40 20             	mov    0x20(%eax),%eax
80104ba6:	8b 40 0c             	mov    0xc(%eax),%eax
80104ba9:	83 c0 08             	add    $0x8,%eax
80104bac:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104baf:	89 54 24 04          	mov    %edx,0x4(%esp)
80104bb3:	89 04 24             	mov    %eax,(%esp)
80104bb6:	e8 64 02 00 00       	call   80104e1f <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104bbb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104bc2:	eb 1b                	jmp    80104bdf <procdump+0xc7>
        cprintf(" %p", pc[i]);
80104bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc7:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104bcb:	89 44 24 04          	mov    %eax,0x4(%esp)
80104bcf:	c7 04 24 2f 88 10 80 	movl   $0x8010882f,(%esp)
80104bd6:	e8 ed b7 ff ff       	call   801003c8 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104bdb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104bdf:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104be3:	7f 0b                	jg     80104bf0 <procdump+0xd8>
80104be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be8:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104bec:	85 c0                	test   %eax,%eax
80104bee:	75 d4                	jne    80104bc4 <procdump+0xac>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104bf0:	c7 04 24 33 88 10 80 	movl   $0x80108833,(%esp)
80104bf7:	e8 cc b7 ff ff       	call   801003c8 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bfc:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80104c00:	81 7d f0 d4 5d 11 80 	cmpl   $0x80115dd4,-0x10(%ebp)
80104c07:	0f 82 1d ff ff ff    	jb     80104b2a <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104c0d:	c9                   	leave  
80104c0e:	c3                   	ret    

80104c0f <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104c0f:	55                   	push   %ebp
80104c10:	89 e5                	mov    %esp,%ebp
80104c12:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
80104c15:	8b 45 08             	mov    0x8(%ebp),%eax
80104c18:	83 c0 04             	add    $0x4,%eax
80104c1b:	c7 44 24 04 5f 88 10 	movl   $0x8010885f,0x4(%esp)
80104c22:	80 
80104c23:	89 04 24             	mov    %eax,(%esp)
80104c26:	e8 20 01 00 00       	call   80104d4b <initlock>
  lk->name = name;
80104c2b:	8b 45 08             	mov    0x8(%ebp),%eax
80104c2e:	8b 55 0c             	mov    0xc(%ebp),%edx
80104c31:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104c34:	8b 45 08             	mov    0x8(%ebp),%eax
80104c37:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104c3d:	8b 45 08             	mov    0x8(%ebp),%eax
80104c40:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104c47:	c9                   	leave  
80104c48:	c3                   	ret    

80104c49 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104c49:	55                   	push   %ebp
80104c4a:	89 e5                	mov    %esp,%ebp
80104c4c:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80104c4f:	8b 45 08             	mov    0x8(%ebp),%eax
80104c52:	83 c0 04             	add    $0x4,%eax
80104c55:	89 04 24             	mov    %eax,(%esp)
80104c58:	e8 0f 01 00 00       	call   80104d6c <acquire>
  while (lk->locked) {
80104c5d:	eb 15                	jmp    80104c74 <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
80104c5f:	8b 45 08             	mov    0x8(%ebp),%eax
80104c62:	83 c0 04             	add    $0x4,%eax
80104c65:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c69:	8b 45 08             	mov    0x8(%ebp),%eax
80104c6c:	89 04 24             	mov    %eax,(%esp)
80104c6f:	e8 2d fd ff ff       	call   801049a1 <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80104c74:	8b 45 08             	mov    0x8(%ebp),%eax
80104c77:	8b 00                	mov    (%eax),%eax
80104c79:	85 c0                	test   %eax,%eax
80104c7b:	75 e2                	jne    80104c5f <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
80104c7d:	8b 45 08             	mov    0x8(%ebp),%eax
80104c80:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104c86:	e8 be f4 ff ff       	call   80104149 <myproc>
80104c8b:	8b 50 14             	mov    0x14(%eax),%edx
80104c8e:	8b 45 08             	mov    0x8(%ebp),%eax
80104c91:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104c94:	8b 45 08             	mov    0x8(%ebp),%eax
80104c97:	83 c0 04             	add    $0x4,%eax
80104c9a:	89 04 24             	mov    %eax,(%esp)
80104c9d:	e8 32 01 00 00       	call   80104dd4 <release>
}
80104ca2:	c9                   	leave  
80104ca3:	c3                   	ret    

80104ca4 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104ca4:	55                   	push   %ebp
80104ca5:	89 e5                	mov    %esp,%ebp
80104ca7:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80104caa:	8b 45 08             	mov    0x8(%ebp),%eax
80104cad:	83 c0 04             	add    $0x4,%eax
80104cb0:	89 04 24             	mov    %eax,(%esp)
80104cb3:	e8 b4 00 00 00       	call   80104d6c <acquire>
  lk->locked = 0;
80104cb8:	8b 45 08             	mov    0x8(%ebp),%eax
80104cbb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104cc1:	8b 45 08             	mov    0x8(%ebp),%eax
80104cc4:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104ccb:	8b 45 08             	mov    0x8(%ebp),%eax
80104cce:	89 04 24             	mov    %eax,(%esp)
80104cd1:	e8 9f fd ff ff       	call   80104a75 <wakeup>
  release(&lk->lk);
80104cd6:	8b 45 08             	mov    0x8(%ebp),%eax
80104cd9:	83 c0 04             	add    $0x4,%eax
80104cdc:	89 04 24             	mov    %eax,(%esp)
80104cdf:	e8 f0 00 00 00       	call   80104dd4 <release>
}
80104ce4:	c9                   	leave  
80104ce5:	c3                   	ret    

80104ce6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104ce6:	55                   	push   %ebp
80104ce7:	89 e5                	mov    %esp,%ebp
80104ce9:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
80104cec:	8b 45 08             	mov    0x8(%ebp),%eax
80104cef:	83 c0 04             	add    $0x4,%eax
80104cf2:	89 04 24             	mov    %eax,(%esp)
80104cf5:	e8 72 00 00 00       	call   80104d6c <acquire>
  r = lk->locked;
80104cfa:	8b 45 08             	mov    0x8(%ebp),%eax
80104cfd:	8b 00                	mov    (%eax),%eax
80104cff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104d02:	8b 45 08             	mov    0x8(%ebp),%eax
80104d05:	83 c0 04             	add    $0x4,%eax
80104d08:	89 04 24             	mov    %eax,(%esp)
80104d0b:	e8 c4 00 00 00       	call   80104dd4 <release>
  return r;
80104d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104d13:	c9                   	leave  
80104d14:	c3                   	ret    

80104d15 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104d15:	55                   	push   %ebp
80104d16:	89 e5                	mov    %esp,%ebp
80104d18:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104d1b:	9c                   	pushf  
80104d1c:	58                   	pop    %eax
80104d1d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104d20:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d23:	c9                   	leave  
80104d24:	c3                   	ret    

80104d25 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104d25:	55                   	push   %ebp
80104d26:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104d28:	fa                   	cli    
}
80104d29:	5d                   	pop    %ebp
80104d2a:	c3                   	ret    

80104d2b <sti>:

static inline void
sti(void)
{
80104d2b:	55                   	push   %ebp
80104d2c:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104d2e:	fb                   	sti    
}
80104d2f:	5d                   	pop    %ebp
80104d30:	c3                   	ret    

80104d31 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104d31:	55                   	push   %ebp
80104d32:	89 e5                	mov    %esp,%ebp
80104d34:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104d37:	8b 55 08             	mov    0x8(%ebp),%edx
80104d3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d40:	f0 87 02             	lock xchg %eax,(%edx)
80104d43:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104d46:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d49:	c9                   	leave  
80104d4a:	c3                   	ret    

80104d4b <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104d4b:	55                   	push   %ebp
80104d4c:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104d4e:	8b 45 08             	mov    0x8(%ebp),%eax
80104d51:	8b 55 0c             	mov    0xc(%ebp),%edx
80104d54:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104d57:	8b 45 08             	mov    0x8(%ebp),%eax
80104d5a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104d60:	8b 45 08             	mov    0x8(%ebp),%eax
80104d63:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104d6a:	5d                   	pop    %ebp
80104d6b:	c3                   	ret    

80104d6c <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104d6c:	55                   	push   %ebp
80104d6d:	89 e5                	mov    %esp,%ebp
80104d6f:	53                   	push   %ebx
80104d70:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104d73:	e8 51 01 00 00       	call   80104ec9 <pushcli>
  if(holding(lk))
80104d78:	8b 45 08             	mov    0x8(%ebp),%eax
80104d7b:	89 04 24             	mov    %eax,(%esp)
80104d7e:	e8 15 01 00 00       	call   80104e98 <holding>
80104d83:	85 c0                	test   %eax,%eax
80104d85:	74 0c                	je     80104d93 <acquire+0x27>
    panic("acquire");
80104d87:	c7 04 24 6a 88 10 80 	movl   $0x8010886a,(%esp)
80104d8e:	e8 cf b7 ff ff       	call   80100562 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104d93:	90                   	nop
80104d94:	8b 45 08             	mov    0x8(%ebp),%eax
80104d97:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104d9e:	00 
80104d9f:	89 04 24             	mov    %eax,(%esp)
80104da2:	e8 8a ff ff ff       	call   80104d31 <xchg>
80104da7:	85 c0                	test   %eax,%eax
80104da9:	75 e9                	jne    80104d94 <acquire+0x28>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104dab:	0f ae f0             	mfence 

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104dae:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104db1:	e8 1d f3 ff ff       	call   801040d3 <mycpu>
80104db6:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104db9:	8b 45 08             	mov    0x8(%ebp),%eax
80104dbc:	83 c0 0c             	add    $0xc,%eax
80104dbf:	89 44 24 04          	mov    %eax,0x4(%esp)
80104dc3:	8d 45 08             	lea    0x8(%ebp),%eax
80104dc6:	89 04 24             	mov    %eax,(%esp)
80104dc9:	e8 51 00 00 00       	call   80104e1f <getcallerpcs>
}
80104dce:	83 c4 14             	add    $0x14,%esp
80104dd1:	5b                   	pop    %ebx
80104dd2:	5d                   	pop    %ebp
80104dd3:	c3                   	ret    

80104dd4 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104dd4:	55                   	push   %ebp
80104dd5:	89 e5                	mov    %esp,%ebp
80104dd7:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80104dda:	8b 45 08             	mov    0x8(%ebp),%eax
80104ddd:	89 04 24             	mov    %eax,(%esp)
80104de0:	e8 b3 00 00 00       	call   80104e98 <holding>
80104de5:	85 c0                	test   %eax,%eax
80104de7:	75 0c                	jne    80104df5 <release+0x21>
    panic("release");
80104de9:	c7 04 24 72 88 10 80 	movl   $0x80108872,(%esp)
80104df0:	e8 6d b7 ff ff       	call   80100562 <panic>

  lk->pcs[0] = 0;
80104df5:	8b 45 08             	mov    0x8(%ebp),%eax
80104df8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104dff:	8b 45 08             	mov    0x8(%ebp),%eax
80104e02:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104e09:	0f ae f0             	mfence 

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104e0c:	8b 45 08             	mov    0x8(%ebp),%eax
80104e0f:	8b 55 08             	mov    0x8(%ebp),%edx
80104e12:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104e18:	e8 f8 00 00 00       	call   80104f15 <popcli>
}
80104e1d:	c9                   	leave  
80104e1e:	c3                   	ret    

80104e1f <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104e1f:	55                   	push   %ebp
80104e20:	89 e5                	mov    %esp,%ebp
80104e22:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104e25:	8b 45 08             	mov    0x8(%ebp),%eax
80104e28:	83 e8 08             	sub    $0x8,%eax
80104e2b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104e2e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104e35:	eb 38                	jmp    80104e6f <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104e37:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104e3b:	74 38                	je     80104e75 <getcallerpcs+0x56>
80104e3d:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104e44:	76 2f                	jbe    80104e75 <getcallerpcs+0x56>
80104e46:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104e4a:	74 29                	je     80104e75 <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104e4c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e4f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104e56:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e59:	01 c2                	add    %eax,%edx
80104e5b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e5e:	8b 40 04             	mov    0x4(%eax),%eax
80104e61:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104e63:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e66:	8b 00                	mov    (%eax),%eax
80104e68:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104e6b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104e6f:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104e73:	7e c2                	jle    80104e37 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104e75:	eb 19                	jmp    80104e90 <getcallerpcs+0x71>
    pcs[i] = 0;
80104e77:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e7a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104e81:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e84:	01 d0                	add    %edx,%eax
80104e86:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104e8c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104e90:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104e94:	7e e1                	jle    80104e77 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80104e96:	c9                   	leave  
80104e97:	c3                   	ret    

80104e98 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104e98:	55                   	push   %ebp
80104e99:	89 e5                	mov    %esp,%ebp
80104e9b:	53                   	push   %ebx
80104e9c:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104e9f:	8b 45 08             	mov    0x8(%ebp),%eax
80104ea2:	8b 00                	mov    (%eax),%eax
80104ea4:	85 c0                	test   %eax,%eax
80104ea6:	74 16                	je     80104ebe <holding+0x26>
80104ea8:	8b 45 08             	mov    0x8(%ebp),%eax
80104eab:	8b 58 08             	mov    0x8(%eax),%ebx
80104eae:	e8 20 f2 ff ff       	call   801040d3 <mycpu>
80104eb3:	39 c3                	cmp    %eax,%ebx
80104eb5:	75 07                	jne    80104ebe <holding+0x26>
80104eb7:	b8 01 00 00 00       	mov    $0x1,%eax
80104ebc:	eb 05                	jmp    80104ec3 <holding+0x2b>
80104ebe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ec3:	83 c4 04             	add    $0x4,%esp
80104ec6:	5b                   	pop    %ebx
80104ec7:	5d                   	pop    %ebp
80104ec8:	c3                   	ret    

80104ec9 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104ec9:	55                   	push   %ebp
80104eca:	89 e5                	mov    %esp,%ebp
80104ecc:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104ecf:	e8 41 fe ff ff       	call   80104d15 <readeflags>
80104ed4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104ed7:	e8 49 fe ff ff       	call   80104d25 <cli>
  if(mycpu()->ncli == 0)
80104edc:	e8 f2 f1 ff ff       	call   801040d3 <mycpu>
80104ee1:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104ee7:	85 c0                	test   %eax,%eax
80104ee9:	75 14                	jne    80104eff <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104eeb:	e8 e3 f1 ff ff       	call   801040d3 <mycpu>
80104ef0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ef3:	81 e2 00 02 00 00    	and    $0x200,%edx
80104ef9:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104eff:	e8 cf f1 ff ff       	call   801040d3 <mycpu>
80104f04:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104f0a:	83 c2 01             	add    $0x1,%edx
80104f0d:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104f13:	c9                   	leave  
80104f14:	c3                   	ret    

80104f15 <popcli>:

void
popcli(void)
{
80104f15:	55                   	push   %ebp
80104f16:	89 e5                	mov    %esp,%ebp
80104f18:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80104f1b:	e8 f5 fd ff ff       	call   80104d15 <readeflags>
80104f20:	25 00 02 00 00       	and    $0x200,%eax
80104f25:	85 c0                	test   %eax,%eax
80104f27:	74 0c                	je     80104f35 <popcli+0x20>
    panic("popcli - interruptible");
80104f29:	c7 04 24 7a 88 10 80 	movl   $0x8010887a,(%esp)
80104f30:	e8 2d b6 ff ff       	call   80100562 <panic>
  if(--mycpu()->ncli < 0)
80104f35:	e8 99 f1 ff ff       	call   801040d3 <mycpu>
80104f3a:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104f40:	83 ea 01             	sub    $0x1,%edx
80104f43:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104f49:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104f4f:	85 c0                	test   %eax,%eax
80104f51:	79 0c                	jns    80104f5f <popcli+0x4a>
    panic("popcli");
80104f53:	c7 04 24 91 88 10 80 	movl   $0x80108891,(%esp)
80104f5a:	e8 03 b6 ff ff       	call   80100562 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104f5f:	e8 6f f1 ff ff       	call   801040d3 <mycpu>
80104f64:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104f6a:	85 c0                	test   %eax,%eax
80104f6c:	75 14                	jne    80104f82 <popcli+0x6d>
80104f6e:	e8 60 f1 ff ff       	call   801040d3 <mycpu>
80104f73:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104f79:	85 c0                	test   %eax,%eax
80104f7b:	74 05                	je     80104f82 <popcli+0x6d>
    sti();
80104f7d:	e8 a9 fd ff ff       	call   80104d2b <sti>
}
80104f82:	c9                   	leave  
80104f83:	c3                   	ret    

80104f84 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80104f84:	55                   	push   %ebp
80104f85:	89 e5                	mov    %esp,%ebp
80104f87:	57                   	push   %edi
80104f88:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104f89:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104f8c:	8b 55 10             	mov    0x10(%ebp),%edx
80104f8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f92:	89 cb                	mov    %ecx,%ebx
80104f94:	89 df                	mov    %ebx,%edi
80104f96:	89 d1                	mov    %edx,%ecx
80104f98:	fc                   	cld    
80104f99:	f3 aa                	rep stos %al,%es:(%edi)
80104f9b:	89 ca                	mov    %ecx,%edx
80104f9d:	89 fb                	mov    %edi,%ebx
80104f9f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104fa2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80104fa5:	5b                   	pop    %ebx
80104fa6:	5f                   	pop    %edi
80104fa7:	5d                   	pop    %ebp
80104fa8:	c3                   	ret    

80104fa9 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80104fa9:	55                   	push   %ebp
80104faa:	89 e5                	mov    %esp,%ebp
80104fac:	57                   	push   %edi
80104fad:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104fae:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104fb1:	8b 55 10             	mov    0x10(%ebp),%edx
80104fb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fb7:	89 cb                	mov    %ecx,%ebx
80104fb9:	89 df                	mov    %ebx,%edi
80104fbb:	89 d1                	mov    %edx,%ecx
80104fbd:	fc                   	cld    
80104fbe:	f3 ab                	rep stos %eax,%es:(%edi)
80104fc0:	89 ca                	mov    %ecx,%edx
80104fc2:	89 fb                	mov    %edi,%ebx
80104fc4:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104fc7:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80104fca:	5b                   	pop    %ebx
80104fcb:	5f                   	pop    %edi
80104fcc:	5d                   	pop    %ebp
80104fcd:	c3                   	ret    

80104fce <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104fce:	55                   	push   %ebp
80104fcf:	89 e5                	mov    %esp,%ebp
80104fd1:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80104fd4:	8b 45 08             	mov    0x8(%ebp),%eax
80104fd7:	83 e0 03             	and    $0x3,%eax
80104fda:	85 c0                	test   %eax,%eax
80104fdc:	75 49                	jne    80105027 <memset+0x59>
80104fde:	8b 45 10             	mov    0x10(%ebp),%eax
80104fe1:	83 e0 03             	and    $0x3,%eax
80104fe4:	85 c0                	test   %eax,%eax
80104fe6:	75 3f                	jne    80105027 <memset+0x59>
    c &= 0xFF;
80104fe8:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104fef:	8b 45 10             	mov    0x10(%ebp),%eax
80104ff2:	c1 e8 02             	shr    $0x2,%eax
80104ff5:	89 c2                	mov    %eax,%edx
80104ff7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ffa:	c1 e0 18             	shl    $0x18,%eax
80104ffd:	89 c1                	mov    %eax,%ecx
80104fff:	8b 45 0c             	mov    0xc(%ebp),%eax
80105002:	c1 e0 10             	shl    $0x10,%eax
80105005:	09 c1                	or     %eax,%ecx
80105007:	8b 45 0c             	mov    0xc(%ebp),%eax
8010500a:	c1 e0 08             	shl    $0x8,%eax
8010500d:	09 c8                	or     %ecx,%eax
8010500f:	0b 45 0c             	or     0xc(%ebp),%eax
80105012:	89 54 24 08          	mov    %edx,0x8(%esp)
80105016:	89 44 24 04          	mov    %eax,0x4(%esp)
8010501a:	8b 45 08             	mov    0x8(%ebp),%eax
8010501d:	89 04 24             	mov    %eax,(%esp)
80105020:	e8 84 ff ff ff       	call   80104fa9 <stosl>
80105025:	eb 19                	jmp    80105040 <memset+0x72>
  } else
    stosb(dst, c, n);
80105027:	8b 45 10             	mov    0x10(%ebp),%eax
8010502a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010502e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105031:	89 44 24 04          	mov    %eax,0x4(%esp)
80105035:	8b 45 08             	mov    0x8(%ebp),%eax
80105038:	89 04 24             	mov    %eax,(%esp)
8010503b:	e8 44 ff ff ff       	call   80104f84 <stosb>
  return dst;
80105040:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105043:	c9                   	leave  
80105044:	c3                   	ret    

80105045 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105045:	55                   	push   %ebp
80105046:	89 e5                	mov    %esp,%ebp
80105048:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
8010504b:	8b 45 08             	mov    0x8(%ebp),%eax
8010504e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105051:	8b 45 0c             	mov    0xc(%ebp),%eax
80105054:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105057:	eb 30                	jmp    80105089 <memcmp+0x44>
    if(*s1 != *s2)
80105059:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010505c:	0f b6 10             	movzbl (%eax),%edx
8010505f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105062:	0f b6 00             	movzbl (%eax),%eax
80105065:	38 c2                	cmp    %al,%dl
80105067:	74 18                	je     80105081 <memcmp+0x3c>
      return *s1 - *s2;
80105069:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010506c:	0f b6 00             	movzbl (%eax),%eax
8010506f:	0f b6 d0             	movzbl %al,%edx
80105072:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105075:	0f b6 00             	movzbl (%eax),%eax
80105078:	0f b6 c0             	movzbl %al,%eax
8010507b:	29 c2                	sub    %eax,%edx
8010507d:	89 d0                	mov    %edx,%eax
8010507f:	eb 1a                	jmp    8010509b <memcmp+0x56>
    s1++, s2++;
80105081:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105085:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105089:	8b 45 10             	mov    0x10(%ebp),%eax
8010508c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010508f:	89 55 10             	mov    %edx,0x10(%ebp)
80105092:	85 c0                	test   %eax,%eax
80105094:	75 c3                	jne    80105059 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105096:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010509b:	c9                   	leave  
8010509c:	c3                   	ret    

8010509d <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010509d:	55                   	push   %ebp
8010509e:	89 e5                	mov    %esp,%ebp
801050a0:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801050a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801050a6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801050a9:	8b 45 08             	mov    0x8(%ebp),%eax
801050ac:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801050af:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050b2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801050b5:	73 3d                	jae    801050f4 <memmove+0x57>
801050b7:	8b 45 10             	mov    0x10(%ebp),%eax
801050ba:	8b 55 fc             	mov    -0x4(%ebp),%edx
801050bd:	01 d0                	add    %edx,%eax
801050bf:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801050c2:	76 30                	jbe    801050f4 <memmove+0x57>
    s += n;
801050c4:	8b 45 10             	mov    0x10(%ebp),%eax
801050c7:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801050ca:	8b 45 10             	mov    0x10(%ebp),%eax
801050cd:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801050d0:	eb 13                	jmp    801050e5 <memmove+0x48>
      *--d = *--s;
801050d2:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801050d6:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801050da:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050dd:	0f b6 10             	movzbl (%eax),%edx
801050e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050e3:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801050e5:	8b 45 10             	mov    0x10(%ebp),%eax
801050e8:	8d 50 ff             	lea    -0x1(%eax),%edx
801050eb:	89 55 10             	mov    %edx,0x10(%ebp)
801050ee:	85 c0                	test   %eax,%eax
801050f0:	75 e0                	jne    801050d2 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801050f2:	eb 26                	jmp    8010511a <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801050f4:	eb 17                	jmp    8010510d <memmove+0x70>
      *d++ = *s++;
801050f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050f9:	8d 50 01             	lea    0x1(%eax),%edx
801050fc:	89 55 f8             	mov    %edx,-0x8(%ebp)
801050ff:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105102:	8d 4a 01             	lea    0x1(%edx),%ecx
80105105:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105108:	0f b6 12             	movzbl (%edx),%edx
8010510b:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010510d:	8b 45 10             	mov    0x10(%ebp),%eax
80105110:	8d 50 ff             	lea    -0x1(%eax),%edx
80105113:	89 55 10             	mov    %edx,0x10(%ebp)
80105116:	85 c0                	test   %eax,%eax
80105118:	75 dc                	jne    801050f6 <memmove+0x59>
      *d++ = *s++;

  return dst;
8010511a:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010511d:	c9                   	leave  
8010511e:	c3                   	ret    

8010511f <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010511f:	55                   	push   %ebp
80105120:	89 e5                	mov    %esp,%ebp
80105122:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105125:	8b 45 10             	mov    0x10(%ebp),%eax
80105128:	89 44 24 08          	mov    %eax,0x8(%esp)
8010512c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010512f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105133:	8b 45 08             	mov    0x8(%ebp),%eax
80105136:	89 04 24             	mov    %eax,(%esp)
80105139:	e8 5f ff ff ff       	call   8010509d <memmove>
}
8010513e:	c9                   	leave  
8010513f:	c3                   	ret    

80105140 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105140:	55                   	push   %ebp
80105141:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105143:	eb 0c                	jmp    80105151 <strncmp+0x11>
    n--, p++, q++;
80105145:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105149:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010514d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105151:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105155:	74 1a                	je     80105171 <strncmp+0x31>
80105157:	8b 45 08             	mov    0x8(%ebp),%eax
8010515a:	0f b6 00             	movzbl (%eax),%eax
8010515d:	84 c0                	test   %al,%al
8010515f:	74 10                	je     80105171 <strncmp+0x31>
80105161:	8b 45 08             	mov    0x8(%ebp),%eax
80105164:	0f b6 10             	movzbl (%eax),%edx
80105167:	8b 45 0c             	mov    0xc(%ebp),%eax
8010516a:	0f b6 00             	movzbl (%eax),%eax
8010516d:	38 c2                	cmp    %al,%dl
8010516f:	74 d4                	je     80105145 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105171:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105175:	75 07                	jne    8010517e <strncmp+0x3e>
    return 0;
80105177:	b8 00 00 00 00       	mov    $0x0,%eax
8010517c:	eb 16                	jmp    80105194 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
8010517e:	8b 45 08             	mov    0x8(%ebp),%eax
80105181:	0f b6 00             	movzbl (%eax),%eax
80105184:	0f b6 d0             	movzbl %al,%edx
80105187:	8b 45 0c             	mov    0xc(%ebp),%eax
8010518a:	0f b6 00             	movzbl (%eax),%eax
8010518d:	0f b6 c0             	movzbl %al,%eax
80105190:	29 c2                	sub    %eax,%edx
80105192:	89 d0                	mov    %edx,%eax
}
80105194:	5d                   	pop    %ebp
80105195:	c3                   	ret    

80105196 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105196:	55                   	push   %ebp
80105197:	89 e5                	mov    %esp,%ebp
80105199:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010519c:	8b 45 08             	mov    0x8(%ebp),%eax
8010519f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801051a2:	90                   	nop
801051a3:	8b 45 10             	mov    0x10(%ebp),%eax
801051a6:	8d 50 ff             	lea    -0x1(%eax),%edx
801051a9:	89 55 10             	mov    %edx,0x10(%ebp)
801051ac:	85 c0                	test   %eax,%eax
801051ae:	7e 1e                	jle    801051ce <strncpy+0x38>
801051b0:	8b 45 08             	mov    0x8(%ebp),%eax
801051b3:	8d 50 01             	lea    0x1(%eax),%edx
801051b6:	89 55 08             	mov    %edx,0x8(%ebp)
801051b9:	8b 55 0c             	mov    0xc(%ebp),%edx
801051bc:	8d 4a 01             	lea    0x1(%edx),%ecx
801051bf:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801051c2:	0f b6 12             	movzbl (%edx),%edx
801051c5:	88 10                	mov    %dl,(%eax)
801051c7:	0f b6 00             	movzbl (%eax),%eax
801051ca:	84 c0                	test   %al,%al
801051cc:	75 d5                	jne    801051a3 <strncpy+0xd>
    ;
  while(n-- > 0)
801051ce:	eb 0c                	jmp    801051dc <strncpy+0x46>
    *s++ = 0;
801051d0:	8b 45 08             	mov    0x8(%ebp),%eax
801051d3:	8d 50 01             	lea    0x1(%eax),%edx
801051d6:	89 55 08             	mov    %edx,0x8(%ebp)
801051d9:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801051dc:	8b 45 10             	mov    0x10(%ebp),%eax
801051df:	8d 50 ff             	lea    -0x1(%eax),%edx
801051e2:	89 55 10             	mov    %edx,0x10(%ebp)
801051e5:	85 c0                	test   %eax,%eax
801051e7:	7f e7                	jg     801051d0 <strncpy+0x3a>
    *s++ = 0;
  return os;
801051e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801051ec:	c9                   	leave  
801051ed:	c3                   	ret    

801051ee <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801051ee:	55                   	push   %ebp
801051ef:	89 e5                	mov    %esp,%ebp
801051f1:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801051f4:	8b 45 08             	mov    0x8(%ebp),%eax
801051f7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801051fa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051fe:	7f 05                	jg     80105205 <safestrcpy+0x17>
    return os;
80105200:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105203:	eb 31                	jmp    80105236 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105205:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105209:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010520d:	7e 1e                	jle    8010522d <safestrcpy+0x3f>
8010520f:	8b 45 08             	mov    0x8(%ebp),%eax
80105212:	8d 50 01             	lea    0x1(%eax),%edx
80105215:	89 55 08             	mov    %edx,0x8(%ebp)
80105218:	8b 55 0c             	mov    0xc(%ebp),%edx
8010521b:	8d 4a 01             	lea    0x1(%edx),%ecx
8010521e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105221:	0f b6 12             	movzbl (%edx),%edx
80105224:	88 10                	mov    %dl,(%eax)
80105226:	0f b6 00             	movzbl (%eax),%eax
80105229:	84 c0                	test   %al,%al
8010522b:	75 d8                	jne    80105205 <safestrcpy+0x17>
    ;
  *s = 0;
8010522d:	8b 45 08             	mov    0x8(%ebp),%eax
80105230:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105233:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105236:	c9                   	leave  
80105237:	c3                   	ret    

80105238 <strlen>:

int
strlen(const char *s)
{
80105238:	55                   	push   %ebp
80105239:	89 e5                	mov    %esp,%ebp
8010523b:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010523e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105245:	eb 04                	jmp    8010524b <strlen+0x13>
80105247:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010524b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010524e:	8b 45 08             	mov    0x8(%ebp),%eax
80105251:	01 d0                	add    %edx,%eax
80105253:	0f b6 00             	movzbl (%eax),%eax
80105256:	84 c0                	test   %al,%al
80105258:	75 ed                	jne    80105247 <strlen+0xf>
    ;
  return n;
8010525a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010525d:	c9                   	leave  
8010525e:	c3                   	ret    

8010525f <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010525f:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105263:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105267:	55                   	push   %ebp
  pushl %ebx
80105268:	53                   	push   %ebx
  pushl %esi
80105269:	56                   	push   %esi
  pushl %edi
8010526a:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010526b:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010526d:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010526f:	5f                   	pop    %edi
  popl %esi
80105270:	5e                   	pop    %esi
  popl %ebx
80105271:	5b                   	pop    %ebx
  popl %ebp
80105272:	5d                   	pop    %ebp
  ret
80105273:	c3                   	ret    

80105274 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105274:	55                   	push   %ebp
80105275:	89 e5                	mov    %esp,%ebp
  //struct proc *curproc = myproc();

  if(addr >= STACKTOP || addr+4 > STACKTOP)
80105277:	81 7d 08 fe ff ff 7f 	cmpl   $0x7ffffffe,0x8(%ebp)
8010527e:	77 0a                	ja     8010528a <fetchint+0x16>
80105280:	8b 45 08             	mov    0x8(%ebp),%eax
80105283:	83 c0 04             	add    $0x4,%eax
80105286:	85 c0                	test   %eax,%eax
80105288:	79 07                	jns    80105291 <fetchint+0x1d>
    return -1;
8010528a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010528f:	eb 0f                	jmp    801052a0 <fetchint+0x2c>
  *ip = *(int*)(addr);
80105291:	8b 45 08             	mov    0x8(%ebp),%eax
80105294:	8b 10                	mov    (%eax),%edx
80105296:	8b 45 0c             	mov    0xc(%ebp),%eax
80105299:	89 10                	mov    %edx,(%eax)
  return 0;
8010529b:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052a0:	5d                   	pop    %ebp
801052a1:	c3                   	ret    

801052a2 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801052a2:	55                   	push   %ebp
801052a3:	89 e5                	mov    %esp,%ebp
801052a5:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;
  //struct proc *curproc = myproc();

  if(addr >= STACKTOP)
801052a8:	81 7d 08 fe ff ff 7f 	cmpl   $0x7ffffffe,0x8(%ebp)
801052af:	76 07                	jbe    801052b8 <fetchstr+0x16>
    return -1;
801052b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052b6:	eb 42                	jmp    801052fa <fetchstr+0x58>
  *pp = (char*)addr;
801052b8:	8b 55 08             	mov    0x8(%ebp),%edx
801052bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801052be:	89 10                	mov    %edx,(%eax)
  ep = (char*)STACKTOP;
801052c0:	c7 45 f8 ff ff ff 7f 	movl   $0x7fffffff,-0x8(%ebp)
  for(s = *pp; s < ep; s++){
801052c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801052ca:	8b 00                	mov    (%eax),%eax
801052cc:	89 45 fc             	mov    %eax,-0x4(%ebp)
801052cf:	eb 1c                	jmp    801052ed <fetchstr+0x4b>
    if(*s == 0)
801052d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052d4:	0f b6 00             	movzbl (%eax),%eax
801052d7:	84 c0                	test   %al,%al
801052d9:	75 0e                	jne    801052e9 <fetchstr+0x47>
      return s - *pp;
801052db:	8b 55 fc             	mov    -0x4(%ebp),%edx
801052de:	8b 45 0c             	mov    0xc(%ebp),%eax
801052e1:	8b 00                	mov    (%eax),%eax
801052e3:	29 c2                	sub    %eax,%edx
801052e5:	89 d0                	mov    %edx,%eax
801052e7:	eb 11                	jmp    801052fa <fetchstr+0x58>

  if(addr >= STACKTOP)
    return -1;
  *pp = (char*)addr;
  ep = (char*)STACKTOP;
  for(s = *pp; s < ep; s++){
801052e9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801052ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052f0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801052f3:	72 dc                	jb     801052d1 <fetchstr+0x2f>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
801052f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801052fa:	c9                   	leave  
801052fb:	c3                   	ret    

801052fc <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801052fc:	55                   	push   %ebp
801052fd:	89 e5                	mov    %esp,%ebp
801052ff:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105302:	e8 42 ee ff ff       	call   80104149 <myproc>
80105307:	8b 40 1c             	mov    0x1c(%eax),%eax
8010530a:	8b 50 44             	mov    0x44(%eax),%edx
8010530d:	8b 45 08             	mov    0x8(%ebp),%eax
80105310:	c1 e0 02             	shl    $0x2,%eax
80105313:	01 d0                	add    %edx,%eax
80105315:	8d 50 04             	lea    0x4(%eax),%edx
80105318:	8b 45 0c             	mov    0xc(%ebp),%eax
8010531b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010531f:	89 14 24             	mov    %edx,(%esp)
80105322:	e8 4d ff ff ff       	call   80105274 <fetchint>
}
80105327:	c9                   	leave  
80105328:	c3                   	ret    

80105329 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105329:	55                   	push   %ebp
8010532a:	89 e5                	mov    %esp,%ebp
8010532c:	83 ec 28             	sub    $0x28,%esp
  int i;
  //struct proc *curproc = myproc();
 
  if(argint(n, &i) < 0)
8010532f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105332:	89 44 24 04          	mov    %eax,0x4(%esp)
80105336:	8b 45 08             	mov    0x8(%ebp),%eax
80105339:	89 04 24             	mov    %eax,(%esp)
8010533c:	e8 bb ff ff ff       	call   801052fc <argint>
80105341:	85 c0                	test   %eax,%eax
80105343:	79 07                	jns    8010534c <argptr+0x23>
    return -1;
80105345:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010534a:	eb 34                	jmp    80105380 <argptr+0x57>
  if(size < 0 || (uint)i >= STACKTOP || (uint)i+size > STACKTOP)
8010534c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105350:	78 18                	js     8010536a <argptr+0x41>
80105352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105355:	3d fe ff ff 7f       	cmp    $0x7ffffffe,%eax
8010535a:	77 0e                	ja     8010536a <argptr+0x41>
8010535c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010535f:	89 c2                	mov    %eax,%edx
80105361:	8b 45 10             	mov    0x10(%ebp),%eax
80105364:	01 d0                	add    %edx,%eax
80105366:	85 c0                	test   %eax,%eax
80105368:	79 07                	jns    80105371 <argptr+0x48>
    return -1;
8010536a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010536f:	eb 0f                	jmp    80105380 <argptr+0x57>
  *pp = (char*)i;
80105371:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105374:	89 c2                	mov    %eax,%edx
80105376:	8b 45 0c             	mov    0xc(%ebp),%eax
80105379:	89 10                	mov    %edx,(%eax)
  return 0;
8010537b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105380:	c9                   	leave  
80105381:	c3                   	ret    

80105382 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105382:	55                   	push   %ebp
80105383:	89 e5                	mov    %esp,%ebp
80105385:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105388:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010538b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010538f:	8b 45 08             	mov    0x8(%ebp),%eax
80105392:	89 04 24             	mov    %eax,(%esp)
80105395:	e8 62 ff ff ff       	call   801052fc <argint>
8010539a:	85 c0                	test   %eax,%eax
8010539c:	79 07                	jns    801053a5 <argstr+0x23>
    return -1;
8010539e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053a3:	eb 12                	jmp    801053b7 <argstr+0x35>
  return fetchstr(addr, pp);
801053a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053a8:	8b 55 0c             	mov    0xc(%ebp),%edx
801053ab:	89 54 24 04          	mov    %edx,0x4(%esp)
801053af:	89 04 24             	mov    %eax,(%esp)
801053b2:	e8 eb fe ff ff       	call   801052a2 <fetchstr>
}
801053b7:	c9                   	leave  
801053b8:	c3                   	ret    

801053b9 <syscall>:
[SYS_shm_close] sys_shm_close
};

void
syscall(void)
{
801053b9:	55                   	push   %ebp
801053ba:	89 e5                	mov    %esp,%ebp
801053bc:	53                   	push   %ebx
801053bd:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
801053c0:	e8 84 ed ff ff       	call   80104149 <myproc>
801053c5:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801053c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053cb:	8b 40 1c             	mov    0x1c(%eax),%eax
801053ce:	8b 40 1c             	mov    0x1c(%eax),%eax
801053d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801053d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801053d8:	7e 2d                	jle    80105407 <syscall+0x4e>
801053da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053dd:	83 f8 17             	cmp    $0x17,%eax
801053e0:	77 25                	ja     80105407 <syscall+0x4e>
801053e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053e5:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
801053ec:	85 c0                	test   %eax,%eax
801053ee:	74 17                	je     80105407 <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
801053f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053f3:	8b 58 1c             	mov    0x1c(%eax),%ebx
801053f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053f9:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
80105400:	ff d0                	call   *%eax
80105402:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105405:	eb 34                	jmp    8010543b <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105407:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010540a:	8d 48 70             	lea    0x70(%eax),%ecx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
8010540d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105410:	8b 40 14             	mov    0x14(%eax),%eax
80105413:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105416:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010541a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010541e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105422:	c7 04 24 98 88 10 80 	movl   $0x80108898,(%esp)
80105429:	e8 9a af ff ff       	call   801003c8 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
8010542e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105431:	8b 40 1c             	mov    0x1c(%eax),%eax
80105434:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010543b:	83 c4 24             	add    $0x24,%esp
8010543e:	5b                   	pop    %ebx
8010543f:	5d                   	pop    %ebp
80105440:	c3                   	ret    

80105441 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105441:	55                   	push   %ebp
80105442:	89 e5                	mov    %esp,%ebp
80105444:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105447:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010544a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010544e:	8b 45 08             	mov    0x8(%ebp),%eax
80105451:	89 04 24             	mov    %eax,(%esp)
80105454:	e8 a3 fe ff ff       	call   801052fc <argint>
80105459:	85 c0                	test   %eax,%eax
8010545b:	79 07                	jns    80105464 <argfd+0x23>
    return -1;
8010545d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105462:	eb 4f                	jmp    801054b3 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105464:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105467:	85 c0                	test   %eax,%eax
80105469:	78 20                	js     8010548b <argfd+0x4a>
8010546b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010546e:	83 f8 0f             	cmp    $0xf,%eax
80105471:	7f 18                	jg     8010548b <argfd+0x4a>
80105473:	e8 d1 ec ff ff       	call   80104149 <myproc>
80105478:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010547b:	83 c2 08             	add    $0x8,%edx
8010547e:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80105482:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105485:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105489:	75 07                	jne    80105492 <argfd+0x51>
    return -1;
8010548b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105490:	eb 21                	jmp    801054b3 <argfd+0x72>
  if(pfd)
80105492:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105496:	74 08                	je     801054a0 <argfd+0x5f>
    *pfd = fd;
80105498:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010549b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010549e:	89 10                	mov    %edx,(%eax)
  if(pf)
801054a0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054a4:	74 08                	je     801054ae <argfd+0x6d>
    *pf = f;
801054a6:	8b 45 10             	mov    0x10(%ebp),%eax
801054a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054ac:	89 10                	mov    %edx,(%eax)
  return 0;
801054ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054b3:	c9                   	leave  
801054b4:	c3                   	ret    

801054b5 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801054b5:	55                   	push   %ebp
801054b6:	89 e5                	mov    %esp,%ebp
801054b8:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801054bb:	e8 89 ec ff ff       	call   80104149 <myproc>
801054c0:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801054c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801054ca:	eb 2a                	jmp    801054f6 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
801054cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054d2:	83 c2 08             	add    $0x8,%edx
801054d5:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801054d9:	85 c0                	test   %eax,%eax
801054db:	75 15                	jne    801054f2 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
801054dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054e3:	8d 4a 08             	lea    0x8(%edx),%ecx
801054e6:	8b 55 08             	mov    0x8(%ebp),%edx
801054e9:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
      return fd;
801054ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054f0:	eb 0f                	jmp    80105501 <fdalloc+0x4c>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
801054f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801054f6:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801054fa:	7e d0                	jle    801054cc <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801054fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105501:	c9                   	leave  
80105502:	c3                   	ret    

80105503 <sys_dup>:

int
sys_dup(void)
{
80105503:	55                   	push   %ebp
80105504:	89 e5                	mov    %esp,%ebp
80105506:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105509:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010550c:	89 44 24 08          	mov    %eax,0x8(%esp)
80105510:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105517:	00 
80105518:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010551f:	e8 1d ff ff ff       	call   80105441 <argfd>
80105524:	85 c0                	test   %eax,%eax
80105526:	79 07                	jns    8010552f <sys_dup+0x2c>
    return -1;
80105528:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010552d:	eb 29                	jmp    80105558 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010552f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105532:	89 04 24             	mov    %eax,(%esp)
80105535:	e8 7b ff ff ff       	call   801054b5 <fdalloc>
8010553a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010553d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105541:	79 07                	jns    8010554a <sys_dup+0x47>
    return -1;
80105543:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105548:	eb 0e                	jmp    80105558 <sys_dup+0x55>
  filedup(f);
8010554a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010554d:	89 04 24             	mov    %eax,(%esp)
80105550:	e8 73 ba ff ff       	call   80100fc8 <filedup>
  return fd;
80105555:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105558:	c9                   	leave  
80105559:	c3                   	ret    

8010555a <sys_read>:

int
sys_read(void)
{
8010555a:	55                   	push   %ebp
8010555b:	89 e5                	mov    %esp,%ebp
8010555d:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105560:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105563:	89 44 24 08          	mov    %eax,0x8(%esp)
80105567:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010556e:	00 
8010556f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105576:	e8 c6 fe ff ff       	call   80105441 <argfd>
8010557b:	85 c0                	test   %eax,%eax
8010557d:	78 35                	js     801055b4 <sys_read+0x5a>
8010557f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105582:	89 44 24 04          	mov    %eax,0x4(%esp)
80105586:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010558d:	e8 6a fd ff ff       	call   801052fc <argint>
80105592:	85 c0                	test   %eax,%eax
80105594:	78 1e                	js     801055b4 <sys_read+0x5a>
80105596:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105599:	89 44 24 08          	mov    %eax,0x8(%esp)
8010559d:	8d 45 ec             	lea    -0x14(%ebp),%eax
801055a0:	89 44 24 04          	mov    %eax,0x4(%esp)
801055a4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801055ab:	e8 79 fd ff ff       	call   80105329 <argptr>
801055b0:	85 c0                	test   %eax,%eax
801055b2:	79 07                	jns    801055bb <sys_read+0x61>
    return -1;
801055b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055b9:	eb 19                	jmp    801055d4 <sys_read+0x7a>
  return fileread(f, p, n);
801055bb:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801055be:	8b 55 ec             	mov    -0x14(%ebp),%edx
801055c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801055c8:	89 54 24 04          	mov    %edx,0x4(%esp)
801055cc:	89 04 24             	mov    %eax,(%esp)
801055cf:	e8 61 bb ff ff       	call   80101135 <fileread>
}
801055d4:	c9                   	leave  
801055d5:	c3                   	ret    

801055d6 <sys_write>:

int
sys_write(void)
{
801055d6:	55                   	push   %ebp
801055d7:	89 e5                	mov    %esp,%ebp
801055d9:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801055dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
801055df:	89 44 24 08          	mov    %eax,0x8(%esp)
801055e3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801055ea:	00 
801055eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801055f2:	e8 4a fe ff ff       	call   80105441 <argfd>
801055f7:	85 c0                	test   %eax,%eax
801055f9:	78 35                	js     80105630 <sys_write+0x5a>
801055fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801055fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80105602:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105609:	e8 ee fc ff ff       	call   801052fc <argint>
8010560e:	85 c0                	test   %eax,%eax
80105610:	78 1e                	js     80105630 <sys_write+0x5a>
80105612:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105615:	89 44 24 08          	mov    %eax,0x8(%esp)
80105619:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010561c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105620:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105627:	e8 fd fc ff ff       	call   80105329 <argptr>
8010562c:	85 c0                	test   %eax,%eax
8010562e:	79 07                	jns    80105637 <sys_write+0x61>
    return -1;
80105630:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105635:	eb 19                	jmp    80105650 <sys_write+0x7a>
  return filewrite(f, p, n);
80105637:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010563a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010563d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105640:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105644:	89 54 24 04          	mov    %edx,0x4(%esp)
80105648:	89 04 24             	mov    %eax,(%esp)
8010564b:	e8 a1 bb ff ff       	call   801011f1 <filewrite>
}
80105650:	c9                   	leave  
80105651:	c3                   	ret    

80105652 <sys_close>:

int
sys_close(void)
{
80105652:	55                   	push   %ebp
80105653:	89 e5                	mov    %esp,%ebp
80105655:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105658:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010565b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010565f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105662:	89 44 24 04          	mov    %eax,0x4(%esp)
80105666:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010566d:	e8 cf fd ff ff       	call   80105441 <argfd>
80105672:	85 c0                	test   %eax,%eax
80105674:	79 07                	jns    8010567d <sys_close+0x2b>
    return -1;
80105676:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010567b:	eb 23                	jmp    801056a0 <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
8010567d:	e8 c7 ea ff ff       	call   80104149 <myproc>
80105682:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105685:	83 c2 08             	add    $0x8,%edx
80105688:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
8010568f:	00 
  fileclose(f);
80105690:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105693:	89 04 24             	mov    %eax,(%esp)
80105696:	e8 75 b9 ff ff       	call   80101010 <fileclose>
  return 0;
8010569b:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056a0:	c9                   	leave  
801056a1:	c3                   	ret    

801056a2 <sys_fstat>:

int
sys_fstat(void)
{
801056a2:	55                   	push   %ebp
801056a3:	89 e5                	mov    %esp,%ebp
801056a5:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801056a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801056ab:	89 44 24 08          	mov    %eax,0x8(%esp)
801056af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801056b6:	00 
801056b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801056be:	e8 7e fd ff ff       	call   80105441 <argfd>
801056c3:	85 c0                	test   %eax,%eax
801056c5:	78 1f                	js     801056e6 <sys_fstat+0x44>
801056c7:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801056ce:	00 
801056cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056d2:	89 44 24 04          	mov    %eax,0x4(%esp)
801056d6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801056dd:	e8 47 fc ff ff       	call   80105329 <argptr>
801056e2:	85 c0                	test   %eax,%eax
801056e4:	79 07                	jns    801056ed <sys_fstat+0x4b>
    return -1;
801056e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056eb:	eb 12                	jmp    801056ff <sys_fstat+0x5d>
  return filestat(f, st);
801056ed:	8b 55 f0             	mov    -0x10(%ebp),%edx
801056f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056f3:	89 54 24 04          	mov    %edx,0x4(%esp)
801056f7:	89 04 24             	mov    %eax,(%esp)
801056fa:	e8 e7 b9 ff ff       	call   801010e6 <filestat>
}
801056ff:	c9                   	leave  
80105700:	c3                   	ret    

80105701 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105701:	55                   	push   %ebp
80105702:	89 e5                	mov    %esp,%ebp
80105704:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105707:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010570a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010570e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105715:	e8 68 fc ff ff       	call   80105382 <argstr>
8010571a:	85 c0                	test   %eax,%eax
8010571c:	78 17                	js     80105735 <sys_link+0x34>
8010571e:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105721:	89 44 24 04          	mov    %eax,0x4(%esp)
80105725:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010572c:	e8 51 fc ff ff       	call   80105382 <argstr>
80105731:	85 c0                	test   %eax,%eax
80105733:	79 0a                	jns    8010573f <sys_link+0x3e>
    return -1;
80105735:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010573a:	e9 42 01 00 00       	jmp    80105881 <sys_link+0x180>

  begin_op();
8010573f:	e8 26 dd ff ff       	call   8010346a <begin_op>
  if((ip = namei(old)) == 0){
80105744:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105747:	89 04 24             	mov    %eax,(%esp)
8010574a:	e8 2b cd ff ff       	call   8010247a <namei>
8010574f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105752:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105756:	75 0f                	jne    80105767 <sys_link+0x66>
    end_op();
80105758:	e8 91 dd ff ff       	call   801034ee <end_op>
    return -1;
8010575d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105762:	e9 1a 01 00 00       	jmp    80105881 <sys_link+0x180>
  }

  ilock(ip);
80105767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010576a:	89 04 24             	mov    %eax,(%esp)
8010576d:	e8 ce c1 ff ff       	call   80101940 <ilock>
  if(ip->type == T_DIR){
80105772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105775:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105779:	66 83 f8 01          	cmp    $0x1,%ax
8010577d:	75 1a                	jne    80105799 <sys_link+0x98>
    iunlockput(ip);
8010577f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105782:	89 04 24             	mov    %eax,(%esp)
80105785:	e8 b8 c3 ff ff       	call   80101b42 <iunlockput>
    end_op();
8010578a:	e8 5f dd ff ff       	call   801034ee <end_op>
    return -1;
8010578f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105794:	e9 e8 00 00 00       	jmp    80105881 <sys_link+0x180>
  }

  ip->nlink++;
80105799:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010579c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801057a0:	8d 50 01             	lea    0x1(%eax),%edx
801057a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057a6:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801057aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057ad:	89 04 24             	mov    %eax,(%esp)
801057b0:	e8 c6 bf ff ff       	call   8010177b <iupdate>
  iunlock(ip);
801057b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057b8:	89 04 24             	mov    %eax,(%esp)
801057bb:	e8 8d c2 ff ff       	call   80101a4d <iunlock>

  if((dp = nameiparent(new, name)) == 0)
801057c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801057c3:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801057c6:	89 54 24 04          	mov    %edx,0x4(%esp)
801057ca:	89 04 24             	mov    %eax,(%esp)
801057cd:	e8 ca cc ff ff       	call   8010249c <nameiparent>
801057d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801057d5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801057d9:	75 02                	jne    801057dd <sys_link+0xdc>
    goto bad;
801057db:	eb 68                	jmp    80105845 <sys_link+0x144>
  ilock(dp);
801057dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057e0:	89 04 24             	mov    %eax,(%esp)
801057e3:	e8 58 c1 ff ff       	call   80101940 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801057e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057eb:	8b 10                	mov    (%eax),%edx
801057ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057f0:	8b 00                	mov    (%eax),%eax
801057f2:	39 c2                	cmp    %eax,%edx
801057f4:	75 20                	jne    80105816 <sys_link+0x115>
801057f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057f9:	8b 40 04             	mov    0x4(%eax),%eax
801057fc:	89 44 24 08          	mov    %eax,0x8(%esp)
80105800:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105803:	89 44 24 04          	mov    %eax,0x4(%esp)
80105807:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010580a:	89 04 24             	mov    %eax,(%esp)
8010580d:	e8 a9 c9 ff ff       	call   801021bb <dirlink>
80105812:	85 c0                	test   %eax,%eax
80105814:	79 0d                	jns    80105823 <sys_link+0x122>
    iunlockput(dp);
80105816:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105819:	89 04 24             	mov    %eax,(%esp)
8010581c:	e8 21 c3 ff ff       	call   80101b42 <iunlockput>
    goto bad;
80105821:	eb 22                	jmp    80105845 <sys_link+0x144>
  }
  iunlockput(dp);
80105823:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105826:	89 04 24             	mov    %eax,(%esp)
80105829:	e8 14 c3 ff ff       	call   80101b42 <iunlockput>
  iput(ip);
8010582e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105831:	89 04 24             	mov    %eax,(%esp)
80105834:	e8 58 c2 ff ff       	call   80101a91 <iput>

  end_op();
80105839:	e8 b0 dc ff ff       	call   801034ee <end_op>

  return 0;
8010583e:	b8 00 00 00 00       	mov    $0x0,%eax
80105843:	eb 3c                	jmp    80105881 <sys_link+0x180>

bad:
  ilock(ip);
80105845:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105848:	89 04 24             	mov    %eax,(%esp)
8010584b:	e8 f0 c0 ff ff       	call   80101940 <ilock>
  ip->nlink--;
80105850:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105853:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105857:	8d 50 ff             	lea    -0x1(%eax),%edx
8010585a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010585d:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105861:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105864:	89 04 24             	mov    %eax,(%esp)
80105867:	e8 0f bf ff ff       	call   8010177b <iupdate>
  iunlockput(ip);
8010586c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010586f:	89 04 24             	mov    %eax,(%esp)
80105872:	e8 cb c2 ff ff       	call   80101b42 <iunlockput>
  end_op();
80105877:	e8 72 dc ff ff       	call   801034ee <end_op>
  return -1;
8010587c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105881:	c9                   	leave  
80105882:	c3                   	ret    

80105883 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105883:	55                   	push   %ebp
80105884:	89 e5                	mov    %esp,%ebp
80105886:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105889:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105890:	eb 4b                	jmp    801058dd <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105892:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105895:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010589c:	00 
8010589d:	89 44 24 08          	mov    %eax,0x8(%esp)
801058a1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801058a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801058a8:	8b 45 08             	mov    0x8(%ebp),%eax
801058ab:	89 04 24             	mov    %eax,(%esp)
801058ae:	e8 2a c5 ff ff       	call   80101ddd <readi>
801058b3:	83 f8 10             	cmp    $0x10,%eax
801058b6:	74 0c                	je     801058c4 <isdirempty+0x41>
      panic("isdirempty: readi");
801058b8:	c7 04 24 b4 88 10 80 	movl   $0x801088b4,(%esp)
801058bf:	e8 9e ac ff ff       	call   80100562 <panic>
    if(de.inum != 0)
801058c4:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801058c8:	66 85 c0             	test   %ax,%ax
801058cb:	74 07                	je     801058d4 <isdirempty+0x51>
      return 0;
801058cd:	b8 00 00 00 00       	mov    $0x0,%eax
801058d2:	eb 1b                	jmp    801058ef <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801058d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058d7:	83 c0 10             	add    $0x10,%eax
801058da:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058e0:	8b 45 08             	mov    0x8(%ebp),%eax
801058e3:	8b 40 58             	mov    0x58(%eax),%eax
801058e6:	39 c2                	cmp    %eax,%edx
801058e8:	72 a8                	jb     80105892 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
801058ea:	b8 01 00 00 00       	mov    $0x1,%eax
}
801058ef:	c9                   	leave  
801058f0:	c3                   	ret    

801058f1 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801058f1:	55                   	push   %ebp
801058f2:	89 e5                	mov    %esp,%ebp
801058f4:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801058f7:	8d 45 cc             	lea    -0x34(%ebp),%eax
801058fa:	89 44 24 04          	mov    %eax,0x4(%esp)
801058fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105905:	e8 78 fa ff ff       	call   80105382 <argstr>
8010590a:	85 c0                	test   %eax,%eax
8010590c:	79 0a                	jns    80105918 <sys_unlink+0x27>
    return -1;
8010590e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105913:	e9 af 01 00 00       	jmp    80105ac7 <sys_unlink+0x1d6>

  begin_op();
80105918:	e8 4d db ff ff       	call   8010346a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010591d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105920:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105923:	89 54 24 04          	mov    %edx,0x4(%esp)
80105927:	89 04 24             	mov    %eax,(%esp)
8010592a:	e8 6d cb ff ff       	call   8010249c <nameiparent>
8010592f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105932:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105936:	75 0f                	jne    80105947 <sys_unlink+0x56>
    end_op();
80105938:	e8 b1 db ff ff       	call   801034ee <end_op>
    return -1;
8010593d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105942:	e9 80 01 00 00       	jmp    80105ac7 <sys_unlink+0x1d6>
  }

  ilock(dp);
80105947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010594a:	89 04 24             	mov    %eax,(%esp)
8010594d:	e8 ee bf ff ff       	call   80101940 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105952:	c7 44 24 04 c6 88 10 	movl   $0x801088c6,0x4(%esp)
80105959:	80 
8010595a:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010595d:	89 04 24             	mov    %eax,(%esp)
80105960:	e8 6b c7 ff ff       	call   801020d0 <namecmp>
80105965:	85 c0                	test   %eax,%eax
80105967:	0f 84 45 01 00 00    	je     80105ab2 <sys_unlink+0x1c1>
8010596d:	c7 44 24 04 c8 88 10 	movl   $0x801088c8,0x4(%esp)
80105974:	80 
80105975:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105978:	89 04 24             	mov    %eax,(%esp)
8010597b:	e8 50 c7 ff ff       	call   801020d0 <namecmp>
80105980:	85 c0                	test   %eax,%eax
80105982:	0f 84 2a 01 00 00    	je     80105ab2 <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105988:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010598b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010598f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105992:	89 44 24 04          	mov    %eax,0x4(%esp)
80105996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105999:	89 04 24             	mov    %eax,(%esp)
8010599c:	e8 51 c7 ff ff       	call   801020f2 <dirlookup>
801059a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059a4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059a8:	75 05                	jne    801059af <sys_unlink+0xbe>
    goto bad;
801059aa:	e9 03 01 00 00       	jmp    80105ab2 <sys_unlink+0x1c1>
  ilock(ip);
801059af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059b2:	89 04 24             	mov    %eax,(%esp)
801059b5:	e8 86 bf ff ff       	call   80101940 <ilock>

  if(ip->nlink < 1)
801059ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059bd:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801059c1:	66 85 c0             	test   %ax,%ax
801059c4:	7f 0c                	jg     801059d2 <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
801059c6:	c7 04 24 cb 88 10 80 	movl   $0x801088cb,(%esp)
801059cd:	e8 90 ab ff ff       	call   80100562 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801059d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059d5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801059d9:	66 83 f8 01          	cmp    $0x1,%ax
801059dd:	75 1f                	jne    801059fe <sys_unlink+0x10d>
801059df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059e2:	89 04 24             	mov    %eax,(%esp)
801059e5:	e8 99 fe ff ff       	call   80105883 <isdirempty>
801059ea:	85 c0                	test   %eax,%eax
801059ec:	75 10                	jne    801059fe <sys_unlink+0x10d>
    iunlockput(ip);
801059ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059f1:	89 04 24             	mov    %eax,(%esp)
801059f4:	e8 49 c1 ff ff       	call   80101b42 <iunlockput>
    goto bad;
801059f9:	e9 b4 00 00 00       	jmp    80105ab2 <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
801059fe:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105a05:	00 
80105a06:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a0d:	00 
80105a0e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105a11:	89 04 24             	mov    %eax,(%esp)
80105a14:	e8 b5 f5 ff ff       	call   80104fce <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105a19:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105a1c:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105a23:	00 
80105a24:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a28:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105a2b:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a32:	89 04 24             	mov    %eax,(%esp)
80105a35:	e8 07 c5 ff ff       	call   80101f41 <writei>
80105a3a:	83 f8 10             	cmp    $0x10,%eax
80105a3d:	74 0c                	je     80105a4b <sys_unlink+0x15a>
    panic("unlink: writei");
80105a3f:	c7 04 24 dd 88 10 80 	movl   $0x801088dd,(%esp)
80105a46:	e8 17 ab ff ff       	call   80100562 <panic>
  if(ip->type == T_DIR){
80105a4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a4e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a52:	66 83 f8 01          	cmp    $0x1,%ax
80105a56:	75 1c                	jne    80105a74 <sys_unlink+0x183>
    dp->nlink--;
80105a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a5b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a5f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a65:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a6c:	89 04 24             	mov    %eax,(%esp)
80105a6f:	e8 07 bd ff ff       	call   8010177b <iupdate>
  }
  iunlockput(dp);
80105a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a77:	89 04 24             	mov    %eax,(%esp)
80105a7a:	e8 c3 c0 ff ff       	call   80101b42 <iunlockput>

  ip->nlink--;
80105a7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a82:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a86:	8d 50 ff             	lea    -0x1(%eax),%edx
80105a89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a8c:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105a90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a93:	89 04 24             	mov    %eax,(%esp)
80105a96:	e8 e0 bc ff ff       	call   8010177b <iupdate>
  iunlockput(ip);
80105a9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a9e:	89 04 24             	mov    %eax,(%esp)
80105aa1:	e8 9c c0 ff ff       	call   80101b42 <iunlockput>

  end_op();
80105aa6:	e8 43 da ff ff       	call   801034ee <end_op>

  return 0;
80105aab:	b8 00 00 00 00       	mov    $0x0,%eax
80105ab0:	eb 15                	jmp    80105ac7 <sys_unlink+0x1d6>

bad:
  iunlockput(dp);
80105ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab5:	89 04 24             	mov    %eax,(%esp)
80105ab8:	e8 85 c0 ff ff       	call   80101b42 <iunlockput>
  end_op();
80105abd:	e8 2c da ff ff       	call   801034ee <end_op>
  return -1;
80105ac2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ac7:	c9                   	leave  
80105ac8:	c3                   	ret    

80105ac9 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105ac9:	55                   	push   %ebp
80105aca:	89 e5                	mov    %esp,%ebp
80105acc:	83 ec 48             	sub    $0x48,%esp
80105acf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105ad2:	8b 55 10             	mov    0x10(%ebp),%edx
80105ad5:	8b 45 14             	mov    0x14(%ebp),%eax
80105ad8:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105adc:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105ae0:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105ae4:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ae7:	89 44 24 04          	mov    %eax,0x4(%esp)
80105aeb:	8b 45 08             	mov    0x8(%ebp),%eax
80105aee:	89 04 24             	mov    %eax,(%esp)
80105af1:	e8 a6 c9 ff ff       	call   8010249c <nameiparent>
80105af6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105af9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105afd:	75 0a                	jne    80105b09 <create+0x40>
    return 0;
80105aff:	b8 00 00 00 00       	mov    $0x0,%eax
80105b04:	e9 7e 01 00 00       	jmp    80105c87 <create+0x1be>
  ilock(dp);
80105b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b0c:	89 04 24             	mov    %eax,(%esp)
80105b0f:	e8 2c be ff ff       	call   80101940 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105b14:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b17:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b1b:	8d 45 de             	lea    -0x22(%ebp),%eax
80105b1e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b25:	89 04 24             	mov    %eax,(%esp)
80105b28:	e8 c5 c5 ff ff       	call   801020f2 <dirlookup>
80105b2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b30:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b34:	74 47                	je     80105b7d <create+0xb4>
    iunlockput(dp);
80105b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b39:	89 04 24             	mov    %eax,(%esp)
80105b3c:	e8 01 c0 ff ff       	call   80101b42 <iunlockput>
    ilock(ip);
80105b41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b44:	89 04 24             	mov    %eax,(%esp)
80105b47:	e8 f4 bd ff ff       	call   80101940 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105b4c:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105b51:	75 15                	jne    80105b68 <create+0x9f>
80105b53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b56:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105b5a:	66 83 f8 02          	cmp    $0x2,%ax
80105b5e:	75 08                	jne    80105b68 <create+0x9f>
      return ip;
80105b60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b63:	e9 1f 01 00 00       	jmp    80105c87 <create+0x1be>
    iunlockput(ip);
80105b68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b6b:	89 04 24             	mov    %eax,(%esp)
80105b6e:	e8 cf bf ff ff       	call   80101b42 <iunlockput>
    return 0;
80105b73:	b8 00 00 00 00       	mov    $0x0,%eax
80105b78:	e9 0a 01 00 00       	jmp    80105c87 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105b7d:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b84:	8b 00                	mov    (%eax),%eax
80105b86:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b8a:	89 04 24             	mov    %eax,(%esp)
80105b8d:	e8 14 bb ff ff       	call   801016a6 <ialloc>
80105b92:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b95:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b99:	75 0c                	jne    80105ba7 <create+0xde>
    panic("create: ialloc");
80105b9b:	c7 04 24 ec 88 10 80 	movl   $0x801088ec,(%esp)
80105ba2:	e8 bb a9 ff ff       	call   80100562 <panic>

  ilock(ip);
80105ba7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105baa:	89 04 24             	mov    %eax,(%esp)
80105bad:	e8 8e bd ff ff       	call   80101940 <ilock>
  ip->major = major;
80105bb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bb5:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105bb9:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105bbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bc0:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105bc4:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105bc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bcb:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bd4:	89 04 24             	mov    %eax,(%esp)
80105bd7:	e8 9f bb ff ff       	call   8010177b <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105bdc:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105be1:	75 6a                	jne    80105c4d <create+0x184>
    dp->nlink++;  // for ".."
80105be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be6:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105bea:	8d 50 01             	lea    0x1(%eax),%edx
80105bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf0:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf7:	89 04 24             	mov    %eax,(%esp)
80105bfa:	e8 7c bb ff ff       	call   8010177b <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105bff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c02:	8b 40 04             	mov    0x4(%eax),%eax
80105c05:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c09:	c7 44 24 04 c6 88 10 	movl   $0x801088c6,0x4(%esp)
80105c10:	80 
80105c11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c14:	89 04 24             	mov    %eax,(%esp)
80105c17:	e8 9f c5 ff ff       	call   801021bb <dirlink>
80105c1c:	85 c0                	test   %eax,%eax
80105c1e:	78 21                	js     80105c41 <create+0x178>
80105c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c23:	8b 40 04             	mov    0x4(%eax),%eax
80105c26:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c2a:	c7 44 24 04 c8 88 10 	movl   $0x801088c8,0x4(%esp)
80105c31:	80 
80105c32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c35:	89 04 24             	mov    %eax,(%esp)
80105c38:	e8 7e c5 ff ff       	call   801021bb <dirlink>
80105c3d:	85 c0                	test   %eax,%eax
80105c3f:	79 0c                	jns    80105c4d <create+0x184>
      panic("create dots");
80105c41:	c7 04 24 fb 88 10 80 	movl   $0x801088fb,(%esp)
80105c48:	e8 15 a9 ff ff       	call   80100562 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105c4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c50:	8b 40 04             	mov    0x4(%eax),%eax
80105c53:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c57:	8d 45 de             	lea    -0x22(%ebp),%eax
80105c5a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c61:	89 04 24             	mov    %eax,(%esp)
80105c64:	e8 52 c5 ff ff       	call   801021bb <dirlink>
80105c69:	85 c0                	test   %eax,%eax
80105c6b:	79 0c                	jns    80105c79 <create+0x1b0>
    panic("create: dirlink");
80105c6d:	c7 04 24 07 89 10 80 	movl   $0x80108907,(%esp)
80105c74:	e8 e9 a8 ff ff       	call   80100562 <panic>

  iunlockput(dp);
80105c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c7c:	89 04 24             	mov    %eax,(%esp)
80105c7f:	e8 be be ff ff       	call   80101b42 <iunlockput>

  return ip;
80105c84:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105c87:	c9                   	leave  
80105c88:	c3                   	ret    

80105c89 <sys_open>:

int
sys_open(void)
{
80105c89:	55                   	push   %ebp
80105c8a:	89 e5                	mov    %esp,%ebp
80105c8c:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105c8f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105c92:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c96:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c9d:	e8 e0 f6 ff ff       	call   80105382 <argstr>
80105ca2:	85 c0                	test   %eax,%eax
80105ca4:	78 17                	js     80105cbd <sys_open+0x34>
80105ca6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ca9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105cb4:	e8 43 f6 ff ff       	call   801052fc <argint>
80105cb9:	85 c0                	test   %eax,%eax
80105cbb:	79 0a                	jns    80105cc7 <sys_open+0x3e>
    return -1;
80105cbd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cc2:	e9 5c 01 00 00       	jmp    80105e23 <sys_open+0x19a>

  begin_op();
80105cc7:	e8 9e d7 ff ff       	call   8010346a <begin_op>

  if(omode & O_CREATE){
80105ccc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ccf:	25 00 02 00 00       	and    $0x200,%eax
80105cd4:	85 c0                	test   %eax,%eax
80105cd6:	74 3b                	je     80105d13 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80105cd8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105cdb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105ce2:	00 
80105ce3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105cea:	00 
80105ceb:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105cf2:	00 
80105cf3:	89 04 24             	mov    %eax,(%esp)
80105cf6:	e8 ce fd ff ff       	call   80105ac9 <create>
80105cfb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105cfe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d02:	75 6b                	jne    80105d6f <sys_open+0xe6>
      end_op();
80105d04:	e8 e5 d7 ff ff       	call   801034ee <end_op>
      return -1;
80105d09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d0e:	e9 10 01 00 00       	jmp    80105e23 <sys_open+0x19a>
    }
  } else {
    if((ip = namei(path)) == 0){
80105d13:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d16:	89 04 24             	mov    %eax,(%esp)
80105d19:	e8 5c c7 ff ff       	call   8010247a <namei>
80105d1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d21:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d25:	75 0f                	jne    80105d36 <sys_open+0xad>
      end_op();
80105d27:	e8 c2 d7 ff ff       	call   801034ee <end_op>
      return -1;
80105d2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d31:	e9 ed 00 00 00       	jmp    80105e23 <sys_open+0x19a>
    }
    ilock(ip);
80105d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d39:	89 04 24             	mov    %eax,(%esp)
80105d3c:	e8 ff bb ff ff       	call   80101940 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105d41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d44:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d48:	66 83 f8 01          	cmp    $0x1,%ax
80105d4c:	75 21                	jne    80105d6f <sys_open+0xe6>
80105d4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d51:	85 c0                	test   %eax,%eax
80105d53:	74 1a                	je     80105d6f <sys_open+0xe6>
      iunlockput(ip);
80105d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d58:	89 04 24             	mov    %eax,(%esp)
80105d5b:	e8 e2 bd ff ff       	call   80101b42 <iunlockput>
      end_op();
80105d60:	e8 89 d7 ff ff       	call   801034ee <end_op>
      return -1;
80105d65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d6a:	e9 b4 00 00 00       	jmp    80105e23 <sys_open+0x19a>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105d6f:	e8 f4 b1 ff ff       	call   80100f68 <filealloc>
80105d74:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d77:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d7b:	74 14                	je     80105d91 <sys_open+0x108>
80105d7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d80:	89 04 24             	mov    %eax,(%esp)
80105d83:	e8 2d f7 ff ff       	call   801054b5 <fdalloc>
80105d88:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105d8b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105d8f:	79 28                	jns    80105db9 <sys_open+0x130>
    if(f)
80105d91:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d95:	74 0b                	je     80105da2 <sys_open+0x119>
      fileclose(f);
80105d97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d9a:	89 04 24             	mov    %eax,(%esp)
80105d9d:	e8 6e b2 ff ff       	call   80101010 <fileclose>
    iunlockput(ip);
80105da2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105da5:	89 04 24             	mov    %eax,(%esp)
80105da8:	e8 95 bd ff ff       	call   80101b42 <iunlockput>
    end_op();
80105dad:	e8 3c d7 ff ff       	call   801034ee <end_op>
    return -1;
80105db2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105db7:	eb 6a                	jmp    80105e23 <sys_open+0x19a>
  }
  iunlock(ip);
80105db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dbc:	89 04 24             	mov    %eax,(%esp)
80105dbf:	e8 89 bc ff ff       	call   80101a4d <iunlock>
  end_op();
80105dc4:	e8 25 d7 ff ff       	call   801034ee <end_op>

  f->type = FD_INODE;
80105dc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dcc:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105dd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dd5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105dd8:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105ddb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dde:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105de5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105de8:	83 e0 01             	and    $0x1,%eax
80105deb:	85 c0                	test   %eax,%eax
80105ded:	0f 94 c0             	sete   %al
80105df0:	89 c2                	mov    %eax,%edx
80105df2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105df5:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105df8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105dfb:	83 e0 01             	and    $0x1,%eax
80105dfe:	85 c0                	test   %eax,%eax
80105e00:	75 0a                	jne    80105e0c <sys_open+0x183>
80105e02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e05:	83 e0 02             	and    $0x2,%eax
80105e08:	85 c0                	test   %eax,%eax
80105e0a:	74 07                	je     80105e13 <sys_open+0x18a>
80105e0c:	b8 01 00 00 00       	mov    $0x1,%eax
80105e11:	eb 05                	jmp    80105e18 <sys_open+0x18f>
80105e13:	b8 00 00 00 00       	mov    $0x0,%eax
80105e18:	89 c2                	mov    %eax,%edx
80105e1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e1d:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105e20:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105e23:	c9                   	leave  
80105e24:	c3                   	ret    

80105e25 <sys_mkdir>:

int
sys_mkdir(void)
{
80105e25:	55                   	push   %ebp
80105e26:	89 e5                	mov    %esp,%ebp
80105e28:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105e2b:	e8 3a d6 ff ff       	call   8010346a <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105e30:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e33:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e3e:	e8 3f f5 ff ff       	call   80105382 <argstr>
80105e43:	85 c0                	test   %eax,%eax
80105e45:	78 2c                	js     80105e73 <sys_mkdir+0x4e>
80105e47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e4a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105e51:	00 
80105e52:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105e59:	00 
80105e5a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105e61:	00 
80105e62:	89 04 24             	mov    %eax,(%esp)
80105e65:	e8 5f fc ff ff       	call   80105ac9 <create>
80105e6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e6d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e71:	75 0c                	jne    80105e7f <sys_mkdir+0x5a>
    end_op();
80105e73:	e8 76 d6 ff ff       	call   801034ee <end_op>
    return -1;
80105e78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e7d:	eb 15                	jmp    80105e94 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80105e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e82:	89 04 24             	mov    %eax,(%esp)
80105e85:	e8 b8 bc ff ff       	call   80101b42 <iunlockput>
  end_op();
80105e8a:	e8 5f d6 ff ff       	call   801034ee <end_op>
  return 0;
80105e8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e94:	c9                   	leave  
80105e95:	c3                   	ret    

80105e96 <sys_mknod>:

int
sys_mknod(void)
{
80105e96:	55                   	push   %ebp
80105e97:	89 e5                	mov    %esp,%ebp
80105e99:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105e9c:	e8 c9 d5 ff ff       	call   8010346a <begin_op>
  if((argstr(0, &path)) < 0 ||
80105ea1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ea4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ea8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105eaf:	e8 ce f4 ff ff       	call   80105382 <argstr>
80105eb4:	85 c0                	test   %eax,%eax
80105eb6:	78 5e                	js     80105f16 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80105eb8:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ebb:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ebf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105ec6:	e8 31 f4 ff ff       	call   801052fc <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
80105ecb:	85 c0                	test   %eax,%eax
80105ecd:	78 47                	js     80105f16 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105ecf:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ed2:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ed6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105edd:	e8 1a f4 ff ff       	call   801052fc <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80105ee2:	85 c0                	test   %eax,%eax
80105ee4:	78 30                	js     80105f16 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80105ee6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ee9:	0f bf c8             	movswl %ax,%ecx
80105eec:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105eef:	0f bf d0             	movswl %ax,%edx
80105ef2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105ef5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80105ef9:	89 54 24 08          	mov    %edx,0x8(%esp)
80105efd:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80105f04:	00 
80105f05:	89 04 24             	mov    %eax,(%esp)
80105f08:	e8 bc fb ff ff       	call   80105ac9 <create>
80105f0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f10:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f14:	75 0c                	jne    80105f22 <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80105f16:	e8 d3 d5 ff ff       	call   801034ee <end_op>
    return -1;
80105f1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f20:	eb 15                	jmp    80105f37 <sys_mknod+0xa1>
  }
  iunlockput(ip);
80105f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f25:	89 04 24             	mov    %eax,(%esp)
80105f28:	e8 15 bc ff ff       	call   80101b42 <iunlockput>
  end_op();
80105f2d:	e8 bc d5 ff ff       	call   801034ee <end_op>
  return 0;
80105f32:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f37:	c9                   	leave  
80105f38:	c3                   	ret    

80105f39 <sys_chdir>:

int
sys_chdir(void)
{
80105f39:	55                   	push   %ebp
80105f3a:	89 e5                	mov    %esp,%ebp
80105f3c:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105f3f:	e8 05 e2 ff ff       	call   80104149 <myproc>
80105f44:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105f47:	e8 1e d5 ff ff       	call   8010346a <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105f4c:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f4f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f5a:	e8 23 f4 ff ff       	call   80105382 <argstr>
80105f5f:	85 c0                	test   %eax,%eax
80105f61:	78 14                	js     80105f77 <sys_chdir+0x3e>
80105f63:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f66:	89 04 24             	mov    %eax,(%esp)
80105f69:	e8 0c c5 ff ff       	call   8010247a <namei>
80105f6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f71:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f75:	75 0c                	jne    80105f83 <sys_chdir+0x4a>
    end_op();
80105f77:	e8 72 d5 ff ff       	call   801034ee <end_op>
    return -1;
80105f7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f81:	eb 5b                	jmp    80105fde <sys_chdir+0xa5>
  }
  ilock(ip);
80105f83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f86:	89 04 24             	mov    %eax,(%esp)
80105f89:	e8 b2 b9 ff ff       	call   80101940 <ilock>
  if(ip->type != T_DIR){
80105f8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f91:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105f95:	66 83 f8 01          	cmp    $0x1,%ax
80105f99:	74 17                	je     80105fb2 <sys_chdir+0x79>
    iunlockput(ip);
80105f9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f9e:	89 04 24             	mov    %eax,(%esp)
80105fa1:	e8 9c bb ff ff       	call   80101b42 <iunlockput>
    end_op();
80105fa6:	e8 43 d5 ff ff       	call   801034ee <end_op>
    return -1;
80105fab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fb0:	eb 2c                	jmp    80105fde <sys_chdir+0xa5>
  }
  iunlock(ip);
80105fb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fb5:	89 04 24             	mov    %eax,(%esp)
80105fb8:	e8 90 ba ff ff       	call   80101a4d <iunlock>
  iput(curproc->cwd);
80105fbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc0:	8b 40 6c             	mov    0x6c(%eax),%eax
80105fc3:	89 04 24             	mov    %eax,(%esp)
80105fc6:	e8 c6 ba ff ff       	call   80101a91 <iput>
  end_op();
80105fcb:	e8 1e d5 ff ff       	call   801034ee <end_op>
  curproc->cwd = ip;
80105fd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fd3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105fd6:	89 50 6c             	mov    %edx,0x6c(%eax)
  return 0;
80105fd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fde:	c9                   	leave  
80105fdf:	c3                   	ret    

80105fe0 <sys_exec>:

int
sys_exec(void)
{
80105fe0:	55                   	push   %ebp
80105fe1:	89 e5                	mov    %esp,%ebp
80105fe3:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105fe9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105fec:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ff0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ff7:	e8 86 f3 ff ff       	call   80105382 <argstr>
80105ffc:	85 c0                	test   %eax,%eax
80105ffe:	78 1a                	js     8010601a <sys_exec+0x3a>
80106000:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106006:	89 44 24 04          	mov    %eax,0x4(%esp)
8010600a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106011:	e8 e6 f2 ff ff       	call   801052fc <argint>
80106016:	85 c0                	test   %eax,%eax
80106018:	79 0a                	jns    80106024 <sys_exec+0x44>
    return -1;
8010601a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010601f:	e9 c8 00 00 00       	jmp    801060ec <sys_exec+0x10c>
  }
  memset(argv, 0, sizeof(argv));
80106024:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010602b:	00 
8010602c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106033:	00 
80106034:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010603a:	89 04 24             	mov    %eax,(%esp)
8010603d:	e8 8c ef ff ff       	call   80104fce <memset>
  for(i=0;; i++){
80106042:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106049:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010604c:	83 f8 1f             	cmp    $0x1f,%eax
8010604f:	76 0a                	jbe    8010605b <sys_exec+0x7b>
      return -1;
80106051:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106056:	e9 91 00 00 00       	jmp    801060ec <sys_exec+0x10c>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010605b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010605e:	c1 e0 02             	shl    $0x2,%eax
80106061:	89 c2                	mov    %eax,%edx
80106063:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106069:	01 c2                	add    %eax,%edx
8010606b:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106071:	89 44 24 04          	mov    %eax,0x4(%esp)
80106075:	89 14 24             	mov    %edx,(%esp)
80106078:	e8 f7 f1 ff ff       	call   80105274 <fetchint>
8010607d:	85 c0                	test   %eax,%eax
8010607f:	79 07                	jns    80106088 <sys_exec+0xa8>
      return -1;
80106081:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106086:	eb 64                	jmp    801060ec <sys_exec+0x10c>
    if(uarg == 0){
80106088:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010608e:	85 c0                	test   %eax,%eax
80106090:	75 26                	jne    801060b8 <sys_exec+0xd8>
      argv[i] = 0;
80106092:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106095:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010609c:	00 00 00 00 
      break;
801060a0:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801060a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060a4:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801060aa:	89 54 24 04          	mov    %edx,0x4(%esp)
801060ae:	89 04 24             	mov    %eax,(%esp)
801060b1:	e8 68 aa ff ff       	call   80100b1e <exec>
801060b6:	eb 34                	jmp    801060ec <sys_exec+0x10c>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801060b8:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801060be:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060c1:	c1 e2 02             	shl    $0x2,%edx
801060c4:	01 c2                	add    %eax,%edx
801060c6:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801060cc:	89 54 24 04          	mov    %edx,0x4(%esp)
801060d0:	89 04 24             	mov    %eax,(%esp)
801060d3:	e8 ca f1 ff ff       	call   801052a2 <fetchstr>
801060d8:	85 c0                	test   %eax,%eax
801060da:	79 07                	jns    801060e3 <sys_exec+0x103>
      return -1;
801060dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060e1:	eb 09                	jmp    801060ec <sys_exec+0x10c>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801060e3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801060e7:	e9 5d ff ff ff       	jmp    80106049 <sys_exec+0x69>
  return exec(path, argv);
}
801060ec:	c9                   	leave  
801060ed:	c3                   	ret    

801060ee <sys_pipe>:

int
sys_pipe(void)
{
801060ee:	55                   	push   %ebp
801060ef:	89 e5                	mov    %esp,%ebp
801060f1:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801060f4:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801060fb:	00 
801060fc:	8d 45 ec             	lea    -0x14(%ebp),%eax
801060ff:	89 44 24 04          	mov    %eax,0x4(%esp)
80106103:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010610a:	e8 1a f2 ff ff       	call   80105329 <argptr>
8010610f:	85 c0                	test   %eax,%eax
80106111:	79 0a                	jns    8010611d <sys_pipe+0x2f>
    return -1;
80106113:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106118:	e9 9a 00 00 00       	jmp    801061b7 <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
8010611d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106120:	89 44 24 04          	mov    %eax,0x4(%esp)
80106124:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106127:	89 04 24             	mov    %eax,(%esp)
8010612a:	e8 9e db ff ff       	call   80103ccd <pipealloc>
8010612f:	85 c0                	test   %eax,%eax
80106131:	79 07                	jns    8010613a <sys_pipe+0x4c>
    return -1;
80106133:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106138:	eb 7d                	jmp    801061b7 <sys_pipe+0xc9>
  fd0 = -1;
8010613a:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106141:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106144:	89 04 24             	mov    %eax,(%esp)
80106147:	e8 69 f3 ff ff       	call   801054b5 <fdalloc>
8010614c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010614f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106153:	78 14                	js     80106169 <sys_pipe+0x7b>
80106155:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106158:	89 04 24             	mov    %eax,(%esp)
8010615b:	e8 55 f3 ff ff       	call   801054b5 <fdalloc>
80106160:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106163:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106167:	79 36                	jns    8010619f <sys_pipe+0xb1>
    if(fd0 >= 0)
80106169:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010616d:	78 13                	js     80106182 <sys_pipe+0x94>
      myproc()->ofile[fd0] = 0;
8010616f:	e8 d5 df ff ff       	call   80104149 <myproc>
80106174:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106177:	83 c2 08             	add    $0x8,%edx
8010617a:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80106181:	00 
    fileclose(rf);
80106182:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106185:	89 04 24             	mov    %eax,(%esp)
80106188:	e8 83 ae ff ff       	call   80101010 <fileclose>
    fileclose(wf);
8010618d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106190:	89 04 24             	mov    %eax,(%esp)
80106193:	e8 78 ae ff ff       	call   80101010 <fileclose>
    return -1;
80106198:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010619d:	eb 18                	jmp    801061b7 <sys_pipe+0xc9>
  }
  fd[0] = fd0;
8010619f:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061a5:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801061a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061aa:	8d 50 04             	lea    0x4(%eax),%edx
801061ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061b0:	89 02                	mov    %eax,(%edx)
  return 0;
801061b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061b7:	c9                   	leave  
801061b8:	c3                   	ret    

801061b9 <sys_shm_open>:
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int sys_shm_open(void) {
801061b9:	55                   	push   %ebp
801061ba:	89 e5                	mov    %esp,%ebp
801061bc:	83 ec 28             	sub    $0x28,%esp
  int id;
  char **pointer;

  if(argint(0, &id) < 0)
801061bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
801061c2:	89 44 24 04          	mov    %eax,0x4(%esp)
801061c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801061cd:	e8 2a f1 ff ff       	call   801052fc <argint>
801061d2:	85 c0                	test   %eax,%eax
801061d4:	79 07                	jns    801061dd <sys_shm_open+0x24>
    return -1;
801061d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061db:	eb 38                	jmp    80106215 <sys_shm_open+0x5c>

  if(argptr(1, (char **) (&pointer),4)<0)
801061dd:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801061e4:	00 
801061e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061e8:	89 44 24 04          	mov    %eax,0x4(%esp)
801061ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801061f3:	e8 31 f1 ff ff       	call   80105329 <argptr>
801061f8:	85 c0                	test   %eax,%eax
801061fa:	79 07                	jns    80106203 <sys_shm_open+0x4a>
    return -1;
801061fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106201:	eb 12                	jmp    80106215 <sys_shm_open+0x5c>
  return shm_open(id, pointer);
80106203:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106206:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106209:	89 54 24 04          	mov    %edx,0x4(%esp)
8010620d:	89 04 24             	mov    %eax,(%esp)
80106210:	e8 f4 21 00 00       	call   80108409 <shm_open>
}
80106215:	c9                   	leave  
80106216:	c3                   	ret    

80106217 <sys_shm_close>:

int sys_shm_close(void) {
80106217:	55                   	push   %ebp
80106218:	89 e5                	mov    %esp,%ebp
8010621a:	83 ec 28             	sub    $0x28,%esp
  int id;

  if(argint(0, &id) < 0)
8010621d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106220:	89 44 24 04          	mov    %eax,0x4(%esp)
80106224:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010622b:	e8 cc f0 ff ff       	call   801052fc <argint>
80106230:	85 c0                	test   %eax,%eax
80106232:	79 07                	jns    8010623b <sys_shm_close+0x24>
    return -1;
80106234:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106239:	eb 0b                	jmp    80106246 <sys_shm_close+0x2f>

  
  return shm_close(id);
8010623b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010623e:	89 04 24             	mov    %eax,(%esp)
80106241:	e8 cd 21 00 00       	call   80108413 <shm_close>
}
80106246:	c9                   	leave  
80106247:	c3                   	ret    

80106248 <sys_fork>:

int
sys_fork(void)
{
80106248:	55                   	push   %ebp
80106249:	89 e5                	mov    %esp,%ebp
8010624b:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010624e:	e8 f7 e1 ff ff       	call   8010444a <fork>
}
80106253:	c9                   	leave  
80106254:	c3                   	ret    

80106255 <sys_exit>:

int
sys_exit(void)
{
80106255:	55                   	push   %ebp
80106256:	89 e5                	mov    %esp,%ebp
80106258:	83 ec 08             	sub    $0x8,%esp
  exit();
8010625b:	e8 61 e3 ff ff       	call   801045c1 <exit>
  return 0;  // not reached
80106260:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106265:	c9                   	leave  
80106266:	c3                   	ret    

80106267 <sys_wait>:

int
sys_wait(void)
{
80106267:	55                   	push   %ebp
80106268:	89 e5                	mov    %esp,%ebp
8010626a:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010626d:	e8 59 e4 ff ff       	call   801046cb <wait>
}
80106272:	c9                   	leave  
80106273:	c3                   	ret    

80106274 <sys_kill>:

int
sys_kill(void)
{
80106274:	55                   	push   %ebp
80106275:	89 e5                	mov    %esp,%ebp
80106277:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010627a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010627d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106281:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106288:	e8 6f f0 ff ff       	call   801052fc <argint>
8010628d:	85 c0                	test   %eax,%eax
8010628f:	79 07                	jns    80106298 <sys_kill+0x24>
    return -1;
80106291:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106296:	eb 0b                	jmp    801062a3 <sys_kill+0x2f>
  return kill(pid);
80106298:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010629b:	89 04 24             	mov    %eax,(%esp)
8010629e:	e8 fd e7 ff ff       	call   80104aa0 <kill>
}
801062a3:	c9                   	leave  
801062a4:	c3                   	ret    

801062a5 <sys_getpid>:

int
sys_getpid(void)
{
801062a5:	55                   	push   %ebp
801062a6:	89 e5                	mov    %esp,%ebp
801062a8:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801062ab:	e8 99 de ff ff       	call   80104149 <myproc>
801062b0:	8b 40 14             	mov    0x14(%eax),%eax
}
801062b3:	c9                   	leave  
801062b4:	c3                   	ret    

801062b5 <sys_sbrk>:

int
sys_sbrk(void)
{
801062b5:	55                   	push   %ebp
801062b6:	89 e5                	mov    %esp,%ebp
801062b8:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801062bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062be:	89 44 24 04          	mov    %eax,0x4(%esp)
801062c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062c9:	e8 2e f0 ff ff       	call   801052fc <argint>
801062ce:	85 c0                	test   %eax,%eax
801062d0:	79 07                	jns    801062d9 <sys_sbrk+0x24>
    return -1;
801062d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062d7:	eb 24                	jmp    801062fd <sys_sbrk+0x48>
  addr = myproc()->sz;
801062d9:	e8 6b de ff ff       	call   80104149 <myproc>
801062de:	8b 40 04             	mov    0x4(%eax),%eax
801062e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801062e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062e7:	89 04 24             	mov    %eax,(%esp)
801062ea:	e8 bb e0 ff ff       	call   801043aa <growproc>
801062ef:	85 c0                	test   %eax,%eax
801062f1:	79 07                	jns    801062fa <sys_sbrk+0x45>
    return -1;
801062f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062f8:	eb 03                	jmp    801062fd <sys_sbrk+0x48>
  return addr;
801062fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801062fd:	c9                   	leave  
801062fe:	c3                   	ret    

801062ff <sys_sleep>:

int
sys_sleep(void)
{
801062ff:	55                   	push   %ebp
80106300:	89 e5                	mov    %esp,%ebp
80106302:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106305:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106308:	89 44 24 04          	mov    %eax,0x4(%esp)
8010630c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106313:	e8 e4 ef ff ff       	call   801052fc <argint>
80106318:	85 c0                	test   %eax,%eax
8010631a:	79 07                	jns    80106323 <sys_sleep+0x24>
    return -1;
8010631c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106321:	eb 6b                	jmp    8010638e <sys_sleep+0x8f>
  acquire(&tickslock);
80106323:	c7 04 24 e0 5d 11 80 	movl   $0x80115de0,(%esp)
8010632a:	e8 3d ea ff ff       	call   80104d6c <acquire>
  ticks0 = ticks;
8010632f:	a1 20 66 11 80       	mov    0x80116620,%eax
80106334:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106337:	eb 33                	jmp    8010636c <sys_sleep+0x6d>
    if(myproc()->killed){
80106339:	e8 0b de ff ff       	call   80104149 <myproc>
8010633e:	8b 40 28             	mov    0x28(%eax),%eax
80106341:	85 c0                	test   %eax,%eax
80106343:	74 13                	je     80106358 <sys_sleep+0x59>
      release(&tickslock);
80106345:	c7 04 24 e0 5d 11 80 	movl   $0x80115de0,(%esp)
8010634c:	e8 83 ea ff ff       	call   80104dd4 <release>
      return -1;
80106351:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106356:	eb 36                	jmp    8010638e <sys_sleep+0x8f>
    }
    sleep(&ticks, &tickslock);
80106358:	c7 44 24 04 e0 5d 11 	movl   $0x80115de0,0x4(%esp)
8010635f:	80 
80106360:	c7 04 24 20 66 11 80 	movl   $0x80116620,(%esp)
80106367:	e8 35 e6 ff ff       	call   801049a1 <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010636c:	a1 20 66 11 80       	mov    0x80116620,%eax
80106371:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106374:	89 c2                	mov    %eax,%edx
80106376:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106379:	39 c2                	cmp    %eax,%edx
8010637b:	72 bc                	jb     80106339 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
8010637d:	c7 04 24 e0 5d 11 80 	movl   $0x80115de0,(%esp)
80106384:	e8 4b ea ff ff       	call   80104dd4 <release>
  return 0;
80106389:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010638e:	c9                   	leave  
8010638f:	c3                   	ret    

80106390 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106390:	55                   	push   %ebp
80106391:	89 e5                	mov    %esp,%ebp
80106393:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
80106396:	c7 04 24 e0 5d 11 80 	movl   $0x80115de0,(%esp)
8010639d:	e8 ca e9 ff ff       	call   80104d6c <acquire>
  xticks = ticks;
801063a2:	a1 20 66 11 80       	mov    0x80116620,%eax
801063a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801063aa:	c7 04 24 e0 5d 11 80 	movl   $0x80115de0,(%esp)
801063b1:	e8 1e ea ff ff       	call   80104dd4 <release>
  return xticks;
801063b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801063b9:	c9                   	leave  
801063ba:	c3                   	ret    

801063bb <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801063bb:	1e                   	push   %ds
  pushl %es
801063bc:	06                   	push   %es
  pushl %fs
801063bd:	0f a0                	push   %fs
  pushl %gs
801063bf:	0f a8                	push   %gs
  pushal
801063c1:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801063c2:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801063c6:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801063c8:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801063ca:	54                   	push   %esp
  call trap
801063cb:	e8 d8 01 00 00       	call   801065a8 <trap>
  addl $4, %esp
801063d0:	83 c4 04             	add    $0x4,%esp

801063d3 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801063d3:	61                   	popa   
  popl %gs
801063d4:	0f a9                	pop    %gs
  popl %fs
801063d6:	0f a1                	pop    %fs
  popl %es
801063d8:	07                   	pop    %es
  popl %ds
801063d9:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801063da:	83 c4 08             	add    $0x8,%esp
  iret
801063dd:	cf                   	iret   

801063de <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801063de:	55                   	push   %ebp
801063df:	89 e5                	mov    %esp,%ebp
801063e1:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801063e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801063e7:	83 e8 01             	sub    $0x1,%eax
801063ea:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801063ee:	8b 45 08             	mov    0x8(%ebp),%eax
801063f1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801063f5:	8b 45 08             	mov    0x8(%ebp),%eax
801063f8:	c1 e8 10             	shr    $0x10,%eax
801063fb:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801063ff:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106402:	0f 01 18             	lidtl  (%eax)
}
80106405:	c9                   	leave  
80106406:	c3                   	ret    

80106407 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106407:	55                   	push   %ebp
80106408:	89 e5                	mov    %esp,%ebp
8010640a:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010640d:	0f 20 d0             	mov    %cr2,%eax
80106410:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106413:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106416:	c9                   	leave  
80106417:	c3                   	ret    

80106418 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106418:	55                   	push   %ebp
80106419:	89 e5                	mov    %esp,%ebp
8010641b:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
8010641e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106425:	e9 c3 00 00 00       	jmp    801064ed <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010642a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010642d:	8b 04 85 80 b0 10 80 	mov    -0x7fef4f80(,%eax,4),%eax
80106434:	89 c2                	mov    %eax,%edx
80106436:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106439:	66 89 14 c5 20 5e 11 	mov    %dx,-0x7feea1e0(,%eax,8)
80106440:	80 
80106441:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106444:	66 c7 04 c5 22 5e 11 	movw   $0x8,-0x7feea1de(,%eax,8)
8010644b:	80 08 00 
8010644e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106451:	0f b6 14 c5 24 5e 11 	movzbl -0x7feea1dc(,%eax,8),%edx
80106458:	80 
80106459:	83 e2 e0             	and    $0xffffffe0,%edx
8010645c:	88 14 c5 24 5e 11 80 	mov    %dl,-0x7feea1dc(,%eax,8)
80106463:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106466:	0f b6 14 c5 24 5e 11 	movzbl -0x7feea1dc(,%eax,8),%edx
8010646d:	80 
8010646e:	83 e2 1f             	and    $0x1f,%edx
80106471:	88 14 c5 24 5e 11 80 	mov    %dl,-0x7feea1dc(,%eax,8)
80106478:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010647b:	0f b6 14 c5 25 5e 11 	movzbl -0x7feea1db(,%eax,8),%edx
80106482:	80 
80106483:	83 e2 f0             	and    $0xfffffff0,%edx
80106486:	83 ca 0e             	or     $0xe,%edx
80106489:	88 14 c5 25 5e 11 80 	mov    %dl,-0x7feea1db(,%eax,8)
80106490:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106493:	0f b6 14 c5 25 5e 11 	movzbl -0x7feea1db(,%eax,8),%edx
8010649a:	80 
8010649b:	83 e2 ef             	and    $0xffffffef,%edx
8010649e:	88 14 c5 25 5e 11 80 	mov    %dl,-0x7feea1db(,%eax,8)
801064a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064a8:	0f b6 14 c5 25 5e 11 	movzbl -0x7feea1db(,%eax,8),%edx
801064af:	80 
801064b0:	83 e2 9f             	and    $0xffffff9f,%edx
801064b3:	88 14 c5 25 5e 11 80 	mov    %dl,-0x7feea1db(,%eax,8)
801064ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064bd:	0f b6 14 c5 25 5e 11 	movzbl -0x7feea1db(,%eax,8),%edx
801064c4:	80 
801064c5:	83 ca 80             	or     $0xffffff80,%edx
801064c8:	88 14 c5 25 5e 11 80 	mov    %dl,-0x7feea1db(,%eax,8)
801064cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064d2:	8b 04 85 80 b0 10 80 	mov    -0x7fef4f80(,%eax,4),%eax
801064d9:	c1 e8 10             	shr    $0x10,%eax
801064dc:	89 c2                	mov    %eax,%edx
801064de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064e1:	66 89 14 c5 26 5e 11 	mov    %dx,-0x7feea1da(,%eax,8)
801064e8:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801064e9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801064ed:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801064f4:	0f 8e 30 ff ff ff    	jle    8010642a <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801064fa:	a1 80 b1 10 80       	mov    0x8010b180,%eax
801064ff:	66 a3 20 60 11 80    	mov    %ax,0x80116020
80106505:	66 c7 05 22 60 11 80 	movw   $0x8,0x80116022
8010650c:	08 00 
8010650e:	0f b6 05 24 60 11 80 	movzbl 0x80116024,%eax
80106515:	83 e0 e0             	and    $0xffffffe0,%eax
80106518:	a2 24 60 11 80       	mov    %al,0x80116024
8010651d:	0f b6 05 24 60 11 80 	movzbl 0x80116024,%eax
80106524:	83 e0 1f             	and    $0x1f,%eax
80106527:	a2 24 60 11 80       	mov    %al,0x80116024
8010652c:	0f b6 05 25 60 11 80 	movzbl 0x80116025,%eax
80106533:	83 c8 0f             	or     $0xf,%eax
80106536:	a2 25 60 11 80       	mov    %al,0x80116025
8010653b:	0f b6 05 25 60 11 80 	movzbl 0x80116025,%eax
80106542:	83 e0 ef             	and    $0xffffffef,%eax
80106545:	a2 25 60 11 80       	mov    %al,0x80116025
8010654a:	0f b6 05 25 60 11 80 	movzbl 0x80116025,%eax
80106551:	83 c8 60             	or     $0x60,%eax
80106554:	a2 25 60 11 80       	mov    %al,0x80116025
80106559:	0f b6 05 25 60 11 80 	movzbl 0x80116025,%eax
80106560:	83 c8 80             	or     $0xffffff80,%eax
80106563:	a2 25 60 11 80       	mov    %al,0x80116025
80106568:	a1 80 b1 10 80       	mov    0x8010b180,%eax
8010656d:	c1 e8 10             	shr    $0x10,%eax
80106570:	66 a3 26 60 11 80    	mov    %ax,0x80116026

  initlock(&tickslock, "time");
80106576:	c7 44 24 04 18 89 10 	movl   $0x80108918,0x4(%esp)
8010657d:	80 
8010657e:	c7 04 24 e0 5d 11 80 	movl   $0x80115de0,(%esp)
80106585:	e8 c1 e7 ff ff       	call   80104d4b <initlock>
}
8010658a:	c9                   	leave  
8010658b:	c3                   	ret    

8010658c <idtinit>:

void
idtinit(void)
{
8010658c:	55                   	push   %ebp
8010658d:	89 e5                	mov    %esp,%ebp
8010658f:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106592:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106599:	00 
8010659a:	c7 04 24 20 5e 11 80 	movl   $0x80115e20,(%esp)
801065a1:	e8 38 fe ff ff       	call   801063de <lidt>
}
801065a6:	c9                   	leave  
801065a7:	c3                   	ret    

801065a8 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801065a8:	55                   	push   %ebp
801065a9:	89 e5                	mov    %esp,%ebp
801065ab:	57                   	push   %edi
801065ac:	56                   	push   %esi
801065ad:	53                   	push   %ebx
801065ae:	83 ec 4c             	sub    $0x4c,%esp
  if(tf->trapno == T_SYSCALL){
801065b1:	8b 45 08             	mov    0x8(%ebp),%eax
801065b4:	8b 40 30             	mov    0x30(%eax),%eax
801065b7:	83 f8 40             	cmp    $0x40,%eax
801065ba:	75 3c                	jne    801065f8 <trap+0x50>
    if(myproc()->killed)
801065bc:	e8 88 db ff ff       	call   80104149 <myproc>
801065c1:	8b 40 28             	mov    0x28(%eax),%eax
801065c4:	85 c0                	test   %eax,%eax
801065c6:	74 05                	je     801065cd <trap+0x25>
      exit();
801065c8:	e8 f4 df ff ff       	call   801045c1 <exit>
    myproc()->tf = tf;
801065cd:	e8 77 db ff ff       	call   80104149 <myproc>
801065d2:	8b 55 08             	mov    0x8(%ebp),%edx
801065d5:	89 50 1c             	mov    %edx,0x1c(%eax)
    syscall();
801065d8:	e8 dc ed ff ff       	call   801053b9 <syscall>
    if(myproc()->killed)
801065dd:	e8 67 db ff ff       	call   80104149 <myproc>
801065e2:	8b 40 28             	mov    0x28(%eax),%eax
801065e5:	85 c0                	test   %eax,%eax
801065e7:	74 0a                	je     801065f3 <trap+0x4b>
      exit();
801065e9:	e8 d3 df ff ff       	call   801045c1 <exit>
    return;
801065ee:	e9 ae 02 00 00       	jmp    801068a1 <trap+0x2f9>
801065f3:	e9 a9 02 00 00       	jmp    801068a1 <trap+0x2f9>
  }

  switch(tf->trapno){
801065f8:	8b 45 08             	mov    0x8(%ebp),%eax
801065fb:	8b 40 30             	mov    0x30(%eax),%eax
801065fe:	83 e8 0e             	sub    $0xe,%eax
80106601:	83 f8 31             	cmp    $0x31,%eax
80106604:	0f 87 46 01 00 00    	ja     80106750 <trap+0x1a8>
8010660a:	8b 04 85 cc 89 10 80 	mov    -0x7fef7634(,%eax,4),%eax
80106611:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106613:	e8 9a da ff ff       	call   801040b2 <cpuid>
80106618:	85 c0                	test   %eax,%eax
8010661a:	75 31                	jne    8010664d <trap+0xa5>
      acquire(&tickslock);
8010661c:	c7 04 24 e0 5d 11 80 	movl   $0x80115de0,(%esp)
80106623:	e8 44 e7 ff ff       	call   80104d6c <acquire>
      ticks++;
80106628:	a1 20 66 11 80       	mov    0x80116620,%eax
8010662d:	83 c0 01             	add    $0x1,%eax
80106630:	a3 20 66 11 80       	mov    %eax,0x80116620
      wakeup(&ticks);
80106635:	c7 04 24 20 66 11 80 	movl   $0x80116620,(%esp)
8010663c:	e8 34 e4 ff ff       	call   80104a75 <wakeup>
      release(&tickslock);
80106641:	c7 04 24 e0 5d 11 80 	movl   $0x80115de0,(%esp)
80106648:	e8 87 e7 ff ff       	call   80104dd4 <release>
    }
    lapiceoi();
8010664d:	e8 e2 c8 ff ff       	call   80102f34 <lapiceoi>
    break;
80106652:	e9 cc 01 00 00       	jmp    80106823 <trap+0x27b>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106657:	e8 4f c1 ff ff       	call   801027ab <ideintr>
    lapiceoi();
8010665c:	e8 d3 c8 ff ff       	call   80102f34 <lapiceoi>
    break;
80106661:	e9 bd 01 00 00       	jmp    80106823 <trap+0x27b>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106666:	e8 de c6 ff ff       	call   80102d49 <kbdintr>
    lapiceoi();
8010666b:	e8 c4 c8 ff ff       	call   80102f34 <lapiceoi>
    break;
80106670:	e9 ae 01 00 00       	jmp    80106823 <trap+0x27b>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106675:	e8 10 04 00 00       	call   80106a8a <uartintr>
    lapiceoi();
8010667a:	e8 b5 c8 ff ff       	call   80102f34 <lapiceoi>
    break;
8010667f:	e9 9f 01 00 00       	jmp    80106823 <trap+0x27b>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106684:	8b 45 08             	mov    0x8(%ebp),%eax
80106687:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
8010668a:	8b 45 08             	mov    0x8(%ebp),%eax
8010668d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106691:	0f b7 d8             	movzwl %ax,%ebx
80106694:	e8 19 da ff ff       	call   801040b2 <cpuid>
80106699:	89 74 24 0c          	mov    %esi,0xc(%esp)
8010669d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801066a1:	89 44 24 04          	mov    %eax,0x4(%esp)
801066a5:	c7 04 24 20 89 10 80 	movl   $0x80108920,(%esp)
801066ac:	e8 17 9d ff ff       	call   801003c8 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
801066b1:	e8 7e c8 ff ff       	call   80102f34 <lapiceoi>
    break;
801066b6:	e9 68 01 00 00       	jmp    80106823 <trap+0x27b>
  //CS153 -- added case
  case T_PGFLT: ;
    uint address = rcr2();
801066bb:	e8 47 fd ff ff       	call   80106407 <rcr2>
801066c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    uint sp = myproc()->tf->esp; //myProcess trapframe; esp is the top of the stack
801066c3:	e8 81 da ff ff       	call   80104149 <myproc>
801066c8:	8b 40 1c             	mov    0x1c(%eax),%eax
801066cb:	8b 40 44             	mov    0x44(%eax),%eax
801066ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (address > PGROUNDDOWN(sp) - PGSIZE && address < PGROUNDDOWN(sp)) { //give an address and it'll round down to the start of the page
801066d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801066d4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801066d9:	2d 00 10 00 00       	sub    $0x1000,%eax
801066de:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
801066e1:	73 68                	jae    8010674b <trap+0x1a3>
801066e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801066e6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801066eb:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
801066ee:	76 5b                	jbe    8010674b <trap+0x1a3>
      pte_t*pgdir = myproc()->pgdir;
801066f0:	e8 54 da ff ff       	call   80104149 <myproc>
801066f5:	8b 40 08             	mov    0x8(%eax),%eax
801066f8:	89 45 dc             	mov    %eax,-0x24(%ebp)
      
      if (allocuvm(pgdir, PGROUNDDOWN(sp) - PGSIZE, PGROUNDDOWN(sp)) == 0) { //checks if the allocation is valid 
801066fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801066fe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106703:	89 c2                	mov    %eax,%edx
80106705:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106708:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010670d:	2d 00 10 00 00       	sub    $0x1000,%eax
80106712:	89 54 24 08          	mov    %edx,0x8(%esp)
80106716:	89 44 24 04          	mov    %eax,0x4(%esp)
8010671a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010671d:	89 04 24             	mov    %eax,(%esp)
80106720:	e8 96 16 00 00       	call   80107dbb <allocuvm>
80106725:	85 c0                	test   %eax,%eax
80106727:	75 11                	jne    8010673a <trap+0x192>
        cprintf("Oh noes! \n");
80106729:	c7 04 24 44 89 10 80 	movl   $0x80108944,(%esp)
80106730:	e8 93 9c ff ff       	call   801003c8 <cprintf>
        exit();
80106735:	e8 87 de ff ff       	call   801045c1 <exit>
      }
      myproc()->pages += 1;
8010673a:	e8 0a da ff ff       	call   80104149 <myproc>
8010673f:	8b 10                	mov    (%eax),%edx
80106741:	83 c2 01             	add    $0x1,%edx
80106744:	89 10                	mov    %edx,(%eax)
    }
    break;
80106746:	e9 d8 00 00 00       	jmp    80106823 <trap+0x27b>
8010674b:	e9 d3 00 00 00       	jmp    80106823 <trap+0x27b>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106750:	e8 f4 d9 ff ff       	call   80104149 <myproc>
80106755:	85 c0                	test   %eax,%eax
80106757:	74 11                	je     8010676a <trap+0x1c2>
80106759:	8b 45 08             	mov    0x8(%ebp),%eax
8010675c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106760:	0f b7 c0             	movzwl %ax,%eax
80106763:	83 e0 03             	and    $0x3,%eax
80106766:	85 c0                	test   %eax,%eax
80106768:	75 40                	jne    801067aa <trap+0x202>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010676a:	e8 98 fc ff ff       	call   80106407 <rcr2>
8010676f:	89 c3                	mov    %eax,%ebx
80106771:	8b 45 08             	mov    0x8(%ebp),%eax
80106774:	8b 70 38             	mov    0x38(%eax),%esi
80106777:	e8 36 d9 ff ff       	call   801040b2 <cpuid>
8010677c:	8b 55 08             	mov    0x8(%ebp),%edx
8010677f:	8b 52 30             	mov    0x30(%edx),%edx
80106782:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106786:	89 74 24 0c          	mov    %esi,0xc(%esp)
8010678a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010678e:	89 54 24 04          	mov    %edx,0x4(%esp)
80106792:	c7 04 24 50 89 10 80 	movl   $0x80108950,(%esp)
80106799:	e8 2a 9c ff ff       	call   801003c8 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
8010679e:	c7 04 24 82 89 10 80 	movl   $0x80108982,(%esp)
801067a5:	e8 b8 9d ff ff       	call   80100562 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801067aa:	e8 58 fc ff ff       	call   80106407 <rcr2>
801067af:	89 c6                	mov    %eax,%esi
801067b1:	8b 45 08             	mov    0x8(%ebp),%eax
801067b4:	8b 40 38             	mov    0x38(%eax),%eax
801067b7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801067ba:	e8 f3 d8 ff ff       	call   801040b2 <cpuid>
801067bf:	89 c3                	mov    %eax,%ebx
801067c1:	8b 45 08             	mov    0x8(%ebp),%eax
801067c4:	8b 78 34             	mov    0x34(%eax),%edi
801067c7:	89 7d d0             	mov    %edi,-0x30(%ebp)
801067ca:	8b 45 08             	mov    0x8(%ebp),%eax
801067cd:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801067d0:	e8 74 d9 ff ff       	call   80104149 <myproc>
801067d5:	8d 50 70             	lea    0x70(%eax),%edx
801067d8:	89 55 cc             	mov    %edx,-0x34(%ebp)
801067db:	e8 69 d9 ff ff       	call   80104149 <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801067e0:	8b 40 14             	mov    0x14(%eax),%eax
801067e3:	89 74 24 1c          	mov    %esi,0x1c(%esp)
801067e7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
801067ea:	89 4c 24 18          	mov    %ecx,0x18(%esp)
801067ee:	89 5c 24 14          	mov    %ebx,0x14(%esp)
801067f2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
801067f5:	89 4c 24 10          	mov    %ecx,0x10(%esp)
801067f9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
801067fd:	8b 55 cc             	mov    -0x34(%ebp),%edx
80106800:	89 54 24 08          	mov    %edx,0x8(%esp)
80106804:	89 44 24 04          	mov    %eax,0x4(%esp)
80106808:	c7 04 24 88 89 10 80 	movl   $0x80108988,(%esp)
8010680f:	e8 b4 9b ff ff       	call   801003c8 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106814:	e8 30 d9 ff ff       	call   80104149 <myproc>
80106819:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
80106820:	eb 01                	jmp    80106823 <trap+0x27b>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106822:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106823:	e8 21 d9 ff ff       	call   80104149 <myproc>
80106828:	85 c0                	test   %eax,%eax
8010682a:	74 23                	je     8010684f <trap+0x2a7>
8010682c:	e8 18 d9 ff ff       	call   80104149 <myproc>
80106831:	8b 40 28             	mov    0x28(%eax),%eax
80106834:	85 c0                	test   %eax,%eax
80106836:	74 17                	je     8010684f <trap+0x2a7>
80106838:	8b 45 08             	mov    0x8(%ebp),%eax
8010683b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010683f:	0f b7 c0             	movzwl %ax,%eax
80106842:	83 e0 03             	and    $0x3,%eax
80106845:	83 f8 03             	cmp    $0x3,%eax
80106848:	75 05                	jne    8010684f <trap+0x2a7>
    exit();
8010684a:	e8 72 dd ff ff       	call   801045c1 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010684f:	e8 f5 d8 ff ff       	call   80104149 <myproc>
80106854:	85 c0                	test   %eax,%eax
80106856:	74 1d                	je     80106875 <trap+0x2cd>
80106858:	e8 ec d8 ff ff       	call   80104149 <myproc>
8010685d:	8b 40 10             	mov    0x10(%eax),%eax
80106860:	83 f8 04             	cmp    $0x4,%eax
80106863:	75 10                	jne    80106875 <trap+0x2cd>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106865:	8b 45 08             	mov    0x8(%ebp),%eax
80106868:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010686b:	83 f8 20             	cmp    $0x20,%eax
8010686e:	75 05                	jne    80106875 <trap+0x2cd>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
80106870:	e8 bc e0 ff ff       	call   80104931 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106875:	e8 cf d8 ff ff       	call   80104149 <myproc>
8010687a:	85 c0                	test   %eax,%eax
8010687c:	74 23                	je     801068a1 <trap+0x2f9>
8010687e:	e8 c6 d8 ff ff       	call   80104149 <myproc>
80106883:	8b 40 28             	mov    0x28(%eax),%eax
80106886:	85 c0                	test   %eax,%eax
80106888:	74 17                	je     801068a1 <trap+0x2f9>
8010688a:	8b 45 08             	mov    0x8(%ebp),%eax
8010688d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106891:	0f b7 c0             	movzwl %ax,%eax
80106894:	83 e0 03             	and    $0x3,%eax
80106897:	83 f8 03             	cmp    $0x3,%eax
8010689a:	75 05                	jne    801068a1 <trap+0x2f9>
    exit();
8010689c:	e8 20 dd ff ff       	call   801045c1 <exit>
}
801068a1:	83 c4 4c             	add    $0x4c,%esp
801068a4:	5b                   	pop    %ebx
801068a5:	5e                   	pop    %esi
801068a6:	5f                   	pop    %edi
801068a7:	5d                   	pop    %ebp
801068a8:	c3                   	ret    

801068a9 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801068a9:	55                   	push   %ebp
801068aa:	89 e5                	mov    %esp,%ebp
801068ac:	83 ec 14             	sub    $0x14,%esp
801068af:	8b 45 08             	mov    0x8(%ebp),%eax
801068b2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801068b6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801068ba:	89 c2                	mov    %eax,%edx
801068bc:	ec                   	in     (%dx),%al
801068bd:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801068c0:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801068c4:	c9                   	leave  
801068c5:	c3                   	ret    

801068c6 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801068c6:	55                   	push   %ebp
801068c7:	89 e5                	mov    %esp,%ebp
801068c9:	83 ec 08             	sub    $0x8,%esp
801068cc:	8b 55 08             	mov    0x8(%ebp),%edx
801068cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801068d2:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801068d6:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801068d9:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801068dd:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801068e1:	ee                   	out    %al,(%dx)
}
801068e2:	c9                   	leave  
801068e3:	c3                   	ret    

801068e4 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801068e4:	55                   	push   %ebp
801068e5:	89 e5                	mov    %esp,%ebp
801068e7:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801068ea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801068f1:	00 
801068f2:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801068f9:	e8 c8 ff ff ff       	call   801068c6 <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801068fe:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106905:	00 
80106906:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
8010690d:	e8 b4 ff ff ff       	call   801068c6 <outb>
  outb(COM1+0, 115200/9600);
80106912:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106919:	00 
8010691a:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106921:	e8 a0 ff ff ff       	call   801068c6 <outb>
  outb(COM1+1, 0);
80106926:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010692d:	00 
8010692e:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106935:	e8 8c ff ff ff       	call   801068c6 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010693a:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106941:	00 
80106942:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106949:	e8 78 ff ff ff       	call   801068c6 <outb>
  outb(COM1+4, 0);
8010694e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106955:	00 
80106956:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
8010695d:	e8 64 ff ff ff       	call   801068c6 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106962:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106969:	00 
8010696a:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106971:	e8 50 ff ff ff       	call   801068c6 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106976:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010697d:	e8 27 ff ff ff       	call   801068a9 <inb>
80106982:	3c ff                	cmp    $0xff,%al
80106984:	75 02                	jne    80106988 <uartinit+0xa4>
    return;
80106986:	eb 5e                	jmp    801069e6 <uartinit+0x102>
  uart = 1;
80106988:	c7 05 24 b6 10 80 01 	movl   $0x1,0x8010b624
8010698f:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106992:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106999:	e8 0b ff ff ff       	call   801068a9 <inb>
  inb(COM1+0);
8010699e:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801069a5:	e8 ff fe ff ff       	call   801068a9 <inb>
  ioapicenable(IRQ_COM1, 0);
801069aa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801069b1:	00 
801069b2:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801069b9:	e8 64 c0 ff ff       	call   80102a22 <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801069be:	c7 45 f4 94 8a 10 80 	movl   $0x80108a94,-0xc(%ebp)
801069c5:	eb 15                	jmp    801069dc <uartinit+0xf8>
    uartputc(*p);
801069c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ca:	0f b6 00             	movzbl (%eax),%eax
801069cd:	0f be c0             	movsbl %al,%eax
801069d0:	89 04 24             	mov    %eax,(%esp)
801069d3:	e8 10 00 00 00       	call   801069e8 <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801069d8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801069dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069df:	0f b6 00             	movzbl (%eax),%eax
801069e2:	84 c0                	test   %al,%al
801069e4:	75 e1                	jne    801069c7 <uartinit+0xe3>
    uartputc(*p);
}
801069e6:	c9                   	leave  
801069e7:	c3                   	ret    

801069e8 <uartputc>:

void
uartputc(int c)
{
801069e8:	55                   	push   %ebp
801069e9:	89 e5                	mov    %esp,%ebp
801069eb:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
801069ee:	a1 24 b6 10 80       	mov    0x8010b624,%eax
801069f3:	85 c0                	test   %eax,%eax
801069f5:	75 02                	jne    801069f9 <uartputc+0x11>
    return;
801069f7:	eb 4b                	jmp    80106a44 <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801069f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106a00:	eb 10                	jmp    80106a12 <uartputc+0x2a>
    microdelay(10);
80106a02:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106a09:	e8 4b c5 ff ff       	call   80102f59 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106a0e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a12:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106a16:	7f 16                	jg     80106a2e <uartputc+0x46>
80106a18:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106a1f:	e8 85 fe ff ff       	call   801068a9 <inb>
80106a24:	0f b6 c0             	movzbl %al,%eax
80106a27:	83 e0 20             	and    $0x20,%eax
80106a2a:	85 c0                	test   %eax,%eax
80106a2c:	74 d4                	je     80106a02 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106a2e:	8b 45 08             	mov    0x8(%ebp),%eax
80106a31:	0f b6 c0             	movzbl %al,%eax
80106a34:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a38:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106a3f:	e8 82 fe ff ff       	call   801068c6 <outb>
}
80106a44:	c9                   	leave  
80106a45:	c3                   	ret    

80106a46 <uartgetc>:

static int
uartgetc(void)
{
80106a46:	55                   	push   %ebp
80106a47:	89 e5                	mov    %esp,%ebp
80106a49:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106a4c:	a1 24 b6 10 80       	mov    0x8010b624,%eax
80106a51:	85 c0                	test   %eax,%eax
80106a53:	75 07                	jne    80106a5c <uartgetc+0x16>
    return -1;
80106a55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a5a:	eb 2c                	jmp    80106a88 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106a5c:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106a63:	e8 41 fe ff ff       	call   801068a9 <inb>
80106a68:	0f b6 c0             	movzbl %al,%eax
80106a6b:	83 e0 01             	and    $0x1,%eax
80106a6e:	85 c0                	test   %eax,%eax
80106a70:	75 07                	jne    80106a79 <uartgetc+0x33>
    return -1;
80106a72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a77:	eb 0f                	jmp    80106a88 <uartgetc+0x42>
  return inb(COM1+0);
80106a79:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106a80:	e8 24 fe ff ff       	call   801068a9 <inb>
80106a85:	0f b6 c0             	movzbl %al,%eax
}
80106a88:	c9                   	leave  
80106a89:	c3                   	ret    

80106a8a <uartintr>:

void
uartintr(void)
{
80106a8a:	55                   	push   %ebp
80106a8b:	89 e5                	mov    %esp,%ebp
80106a8d:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106a90:	c7 04 24 46 6a 10 80 	movl   $0x80106a46,(%esp)
80106a97:	e8 4d 9d ff ff       	call   801007e9 <consoleintr>
}
80106a9c:	c9                   	leave  
80106a9d:	c3                   	ret    

80106a9e <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106a9e:	6a 00                	push   $0x0
  pushl $0
80106aa0:	6a 00                	push   $0x0
  jmp alltraps
80106aa2:	e9 14 f9 ff ff       	jmp    801063bb <alltraps>

80106aa7 <vector1>:
.globl vector1
vector1:
  pushl $0
80106aa7:	6a 00                	push   $0x0
  pushl $1
80106aa9:	6a 01                	push   $0x1
  jmp alltraps
80106aab:	e9 0b f9 ff ff       	jmp    801063bb <alltraps>

80106ab0 <vector2>:
.globl vector2
vector2:
  pushl $0
80106ab0:	6a 00                	push   $0x0
  pushl $2
80106ab2:	6a 02                	push   $0x2
  jmp alltraps
80106ab4:	e9 02 f9 ff ff       	jmp    801063bb <alltraps>

80106ab9 <vector3>:
.globl vector3
vector3:
  pushl $0
80106ab9:	6a 00                	push   $0x0
  pushl $3
80106abb:	6a 03                	push   $0x3
  jmp alltraps
80106abd:	e9 f9 f8 ff ff       	jmp    801063bb <alltraps>

80106ac2 <vector4>:
.globl vector4
vector4:
  pushl $0
80106ac2:	6a 00                	push   $0x0
  pushl $4
80106ac4:	6a 04                	push   $0x4
  jmp alltraps
80106ac6:	e9 f0 f8 ff ff       	jmp    801063bb <alltraps>

80106acb <vector5>:
.globl vector5
vector5:
  pushl $0
80106acb:	6a 00                	push   $0x0
  pushl $5
80106acd:	6a 05                	push   $0x5
  jmp alltraps
80106acf:	e9 e7 f8 ff ff       	jmp    801063bb <alltraps>

80106ad4 <vector6>:
.globl vector6
vector6:
  pushl $0
80106ad4:	6a 00                	push   $0x0
  pushl $6
80106ad6:	6a 06                	push   $0x6
  jmp alltraps
80106ad8:	e9 de f8 ff ff       	jmp    801063bb <alltraps>

80106add <vector7>:
.globl vector7
vector7:
  pushl $0
80106add:	6a 00                	push   $0x0
  pushl $7
80106adf:	6a 07                	push   $0x7
  jmp alltraps
80106ae1:	e9 d5 f8 ff ff       	jmp    801063bb <alltraps>

80106ae6 <vector8>:
.globl vector8
vector8:
  pushl $8
80106ae6:	6a 08                	push   $0x8
  jmp alltraps
80106ae8:	e9 ce f8 ff ff       	jmp    801063bb <alltraps>

80106aed <vector9>:
.globl vector9
vector9:
  pushl $0
80106aed:	6a 00                	push   $0x0
  pushl $9
80106aef:	6a 09                	push   $0x9
  jmp alltraps
80106af1:	e9 c5 f8 ff ff       	jmp    801063bb <alltraps>

80106af6 <vector10>:
.globl vector10
vector10:
  pushl $10
80106af6:	6a 0a                	push   $0xa
  jmp alltraps
80106af8:	e9 be f8 ff ff       	jmp    801063bb <alltraps>

80106afd <vector11>:
.globl vector11
vector11:
  pushl $11
80106afd:	6a 0b                	push   $0xb
  jmp alltraps
80106aff:	e9 b7 f8 ff ff       	jmp    801063bb <alltraps>

80106b04 <vector12>:
.globl vector12
vector12:
  pushl $12
80106b04:	6a 0c                	push   $0xc
  jmp alltraps
80106b06:	e9 b0 f8 ff ff       	jmp    801063bb <alltraps>

80106b0b <vector13>:
.globl vector13
vector13:
  pushl $13
80106b0b:	6a 0d                	push   $0xd
  jmp alltraps
80106b0d:	e9 a9 f8 ff ff       	jmp    801063bb <alltraps>

80106b12 <vector14>:
.globl vector14
vector14:
  pushl $14
80106b12:	6a 0e                	push   $0xe
  jmp alltraps
80106b14:	e9 a2 f8 ff ff       	jmp    801063bb <alltraps>

80106b19 <vector15>:
.globl vector15
vector15:
  pushl $0
80106b19:	6a 00                	push   $0x0
  pushl $15
80106b1b:	6a 0f                	push   $0xf
  jmp alltraps
80106b1d:	e9 99 f8 ff ff       	jmp    801063bb <alltraps>

80106b22 <vector16>:
.globl vector16
vector16:
  pushl $0
80106b22:	6a 00                	push   $0x0
  pushl $16
80106b24:	6a 10                	push   $0x10
  jmp alltraps
80106b26:	e9 90 f8 ff ff       	jmp    801063bb <alltraps>

80106b2b <vector17>:
.globl vector17
vector17:
  pushl $17
80106b2b:	6a 11                	push   $0x11
  jmp alltraps
80106b2d:	e9 89 f8 ff ff       	jmp    801063bb <alltraps>

80106b32 <vector18>:
.globl vector18
vector18:
  pushl $0
80106b32:	6a 00                	push   $0x0
  pushl $18
80106b34:	6a 12                	push   $0x12
  jmp alltraps
80106b36:	e9 80 f8 ff ff       	jmp    801063bb <alltraps>

80106b3b <vector19>:
.globl vector19
vector19:
  pushl $0
80106b3b:	6a 00                	push   $0x0
  pushl $19
80106b3d:	6a 13                	push   $0x13
  jmp alltraps
80106b3f:	e9 77 f8 ff ff       	jmp    801063bb <alltraps>

80106b44 <vector20>:
.globl vector20
vector20:
  pushl $0
80106b44:	6a 00                	push   $0x0
  pushl $20
80106b46:	6a 14                	push   $0x14
  jmp alltraps
80106b48:	e9 6e f8 ff ff       	jmp    801063bb <alltraps>

80106b4d <vector21>:
.globl vector21
vector21:
  pushl $0
80106b4d:	6a 00                	push   $0x0
  pushl $21
80106b4f:	6a 15                	push   $0x15
  jmp alltraps
80106b51:	e9 65 f8 ff ff       	jmp    801063bb <alltraps>

80106b56 <vector22>:
.globl vector22
vector22:
  pushl $0
80106b56:	6a 00                	push   $0x0
  pushl $22
80106b58:	6a 16                	push   $0x16
  jmp alltraps
80106b5a:	e9 5c f8 ff ff       	jmp    801063bb <alltraps>

80106b5f <vector23>:
.globl vector23
vector23:
  pushl $0
80106b5f:	6a 00                	push   $0x0
  pushl $23
80106b61:	6a 17                	push   $0x17
  jmp alltraps
80106b63:	e9 53 f8 ff ff       	jmp    801063bb <alltraps>

80106b68 <vector24>:
.globl vector24
vector24:
  pushl $0
80106b68:	6a 00                	push   $0x0
  pushl $24
80106b6a:	6a 18                	push   $0x18
  jmp alltraps
80106b6c:	e9 4a f8 ff ff       	jmp    801063bb <alltraps>

80106b71 <vector25>:
.globl vector25
vector25:
  pushl $0
80106b71:	6a 00                	push   $0x0
  pushl $25
80106b73:	6a 19                	push   $0x19
  jmp alltraps
80106b75:	e9 41 f8 ff ff       	jmp    801063bb <alltraps>

80106b7a <vector26>:
.globl vector26
vector26:
  pushl $0
80106b7a:	6a 00                	push   $0x0
  pushl $26
80106b7c:	6a 1a                	push   $0x1a
  jmp alltraps
80106b7e:	e9 38 f8 ff ff       	jmp    801063bb <alltraps>

80106b83 <vector27>:
.globl vector27
vector27:
  pushl $0
80106b83:	6a 00                	push   $0x0
  pushl $27
80106b85:	6a 1b                	push   $0x1b
  jmp alltraps
80106b87:	e9 2f f8 ff ff       	jmp    801063bb <alltraps>

80106b8c <vector28>:
.globl vector28
vector28:
  pushl $0
80106b8c:	6a 00                	push   $0x0
  pushl $28
80106b8e:	6a 1c                	push   $0x1c
  jmp alltraps
80106b90:	e9 26 f8 ff ff       	jmp    801063bb <alltraps>

80106b95 <vector29>:
.globl vector29
vector29:
  pushl $0
80106b95:	6a 00                	push   $0x0
  pushl $29
80106b97:	6a 1d                	push   $0x1d
  jmp alltraps
80106b99:	e9 1d f8 ff ff       	jmp    801063bb <alltraps>

80106b9e <vector30>:
.globl vector30
vector30:
  pushl $0
80106b9e:	6a 00                	push   $0x0
  pushl $30
80106ba0:	6a 1e                	push   $0x1e
  jmp alltraps
80106ba2:	e9 14 f8 ff ff       	jmp    801063bb <alltraps>

80106ba7 <vector31>:
.globl vector31
vector31:
  pushl $0
80106ba7:	6a 00                	push   $0x0
  pushl $31
80106ba9:	6a 1f                	push   $0x1f
  jmp alltraps
80106bab:	e9 0b f8 ff ff       	jmp    801063bb <alltraps>

80106bb0 <vector32>:
.globl vector32
vector32:
  pushl $0
80106bb0:	6a 00                	push   $0x0
  pushl $32
80106bb2:	6a 20                	push   $0x20
  jmp alltraps
80106bb4:	e9 02 f8 ff ff       	jmp    801063bb <alltraps>

80106bb9 <vector33>:
.globl vector33
vector33:
  pushl $0
80106bb9:	6a 00                	push   $0x0
  pushl $33
80106bbb:	6a 21                	push   $0x21
  jmp alltraps
80106bbd:	e9 f9 f7 ff ff       	jmp    801063bb <alltraps>

80106bc2 <vector34>:
.globl vector34
vector34:
  pushl $0
80106bc2:	6a 00                	push   $0x0
  pushl $34
80106bc4:	6a 22                	push   $0x22
  jmp alltraps
80106bc6:	e9 f0 f7 ff ff       	jmp    801063bb <alltraps>

80106bcb <vector35>:
.globl vector35
vector35:
  pushl $0
80106bcb:	6a 00                	push   $0x0
  pushl $35
80106bcd:	6a 23                	push   $0x23
  jmp alltraps
80106bcf:	e9 e7 f7 ff ff       	jmp    801063bb <alltraps>

80106bd4 <vector36>:
.globl vector36
vector36:
  pushl $0
80106bd4:	6a 00                	push   $0x0
  pushl $36
80106bd6:	6a 24                	push   $0x24
  jmp alltraps
80106bd8:	e9 de f7 ff ff       	jmp    801063bb <alltraps>

80106bdd <vector37>:
.globl vector37
vector37:
  pushl $0
80106bdd:	6a 00                	push   $0x0
  pushl $37
80106bdf:	6a 25                	push   $0x25
  jmp alltraps
80106be1:	e9 d5 f7 ff ff       	jmp    801063bb <alltraps>

80106be6 <vector38>:
.globl vector38
vector38:
  pushl $0
80106be6:	6a 00                	push   $0x0
  pushl $38
80106be8:	6a 26                	push   $0x26
  jmp alltraps
80106bea:	e9 cc f7 ff ff       	jmp    801063bb <alltraps>

80106bef <vector39>:
.globl vector39
vector39:
  pushl $0
80106bef:	6a 00                	push   $0x0
  pushl $39
80106bf1:	6a 27                	push   $0x27
  jmp alltraps
80106bf3:	e9 c3 f7 ff ff       	jmp    801063bb <alltraps>

80106bf8 <vector40>:
.globl vector40
vector40:
  pushl $0
80106bf8:	6a 00                	push   $0x0
  pushl $40
80106bfa:	6a 28                	push   $0x28
  jmp alltraps
80106bfc:	e9 ba f7 ff ff       	jmp    801063bb <alltraps>

80106c01 <vector41>:
.globl vector41
vector41:
  pushl $0
80106c01:	6a 00                	push   $0x0
  pushl $41
80106c03:	6a 29                	push   $0x29
  jmp alltraps
80106c05:	e9 b1 f7 ff ff       	jmp    801063bb <alltraps>

80106c0a <vector42>:
.globl vector42
vector42:
  pushl $0
80106c0a:	6a 00                	push   $0x0
  pushl $42
80106c0c:	6a 2a                	push   $0x2a
  jmp alltraps
80106c0e:	e9 a8 f7 ff ff       	jmp    801063bb <alltraps>

80106c13 <vector43>:
.globl vector43
vector43:
  pushl $0
80106c13:	6a 00                	push   $0x0
  pushl $43
80106c15:	6a 2b                	push   $0x2b
  jmp alltraps
80106c17:	e9 9f f7 ff ff       	jmp    801063bb <alltraps>

80106c1c <vector44>:
.globl vector44
vector44:
  pushl $0
80106c1c:	6a 00                	push   $0x0
  pushl $44
80106c1e:	6a 2c                	push   $0x2c
  jmp alltraps
80106c20:	e9 96 f7 ff ff       	jmp    801063bb <alltraps>

80106c25 <vector45>:
.globl vector45
vector45:
  pushl $0
80106c25:	6a 00                	push   $0x0
  pushl $45
80106c27:	6a 2d                	push   $0x2d
  jmp alltraps
80106c29:	e9 8d f7 ff ff       	jmp    801063bb <alltraps>

80106c2e <vector46>:
.globl vector46
vector46:
  pushl $0
80106c2e:	6a 00                	push   $0x0
  pushl $46
80106c30:	6a 2e                	push   $0x2e
  jmp alltraps
80106c32:	e9 84 f7 ff ff       	jmp    801063bb <alltraps>

80106c37 <vector47>:
.globl vector47
vector47:
  pushl $0
80106c37:	6a 00                	push   $0x0
  pushl $47
80106c39:	6a 2f                	push   $0x2f
  jmp alltraps
80106c3b:	e9 7b f7 ff ff       	jmp    801063bb <alltraps>

80106c40 <vector48>:
.globl vector48
vector48:
  pushl $0
80106c40:	6a 00                	push   $0x0
  pushl $48
80106c42:	6a 30                	push   $0x30
  jmp alltraps
80106c44:	e9 72 f7 ff ff       	jmp    801063bb <alltraps>

80106c49 <vector49>:
.globl vector49
vector49:
  pushl $0
80106c49:	6a 00                	push   $0x0
  pushl $49
80106c4b:	6a 31                	push   $0x31
  jmp alltraps
80106c4d:	e9 69 f7 ff ff       	jmp    801063bb <alltraps>

80106c52 <vector50>:
.globl vector50
vector50:
  pushl $0
80106c52:	6a 00                	push   $0x0
  pushl $50
80106c54:	6a 32                	push   $0x32
  jmp alltraps
80106c56:	e9 60 f7 ff ff       	jmp    801063bb <alltraps>

80106c5b <vector51>:
.globl vector51
vector51:
  pushl $0
80106c5b:	6a 00                	push   $0x0
  pushl $51
80106c5d:	6a 33                	push   $0x33
  jmp alltraps
80106c5f:	e9 57 f7 ff ff       	jmp    801063bb <alltraps>

80106c64 <vector52>:
.globl vector52
vector52:
  pushl $0
80106c64:	6a 00                	push   $0x0
  pushl $52
80106c66:	6a 34                	push   $0x34
  jmp alltraps
80106c68:	e9 4e f7 ff ff       	jmp    801063bb <alltraps>

80106c6d <vector53>:
.globl vector53
vector53:
  pushl $0
80106c6d:	6a 00                	push   $0x0
  pushl $53
80106c6f:	6a 35                	push   $0x35
  jmp alltraps
80106c71:	e9 45 f7 ff ff       	jmp    801063bb <alltraps>

80106c76 <vector54>:
.globl vector54
vector54:
  pushl $0
80106c76:	6a 00                	push   $0x0
  pushl $54
80106c78:	6a 36                	push   $0x36
  jmp alltraps
80106c7a:	e9 3c f7 ff ff       	jmp    801063bb <alltraps>

80106c7f <vector55>:
.globl vector55
vector55:
  pushl $0
80106c7f:	6a 00                	push   $0x0
  pushl $55
80106c81:	6a 37                	push   $0x37
  jmp alltraps
80106c83:	e9 33 f7 ff ff       	jmp    801063bb <alltraps>

80106c88 <vector56>:
.globl vector56
vector56:
  pushl $0
80106c88:	6a 00                	push   $0x0
  pushl $56
80106c8a:	6a 38                	push   $0x38
  jmp alltraps
80106c8c:	e9 2a f7 ff ff       	jmp    801063bb <alltraps>

80106c91 <vector57>:
.globl vector57
vector57:
  pushl $0
80106c91:	6a 00                	push   $0x0
  pushl $57
80106c93:	6a 39                	push   $0x39
  jmp alltraps
80106c95:	e9 21 f7 ff ff       	jmp    801063bb <alltraps>

80106c9a <vector58>:
.globl vector58
vector58:
  pushl $0
80106c9a:	6a 00                	push   $0x0
  pushl $58
80106c9c:	6a 3a                	push   $0x3a
  jmp alltraps
80106c9e:	e9 18 f7 ff ff       	jmp    801063bb <alltraps>

80106ca3 <vector59>:
.globl vector59
vector59:
  pushl $0
80106ca3:	6a 00                	push   $0x0
  pushl $59
80106ca5:	6a 3b                	push   $0x3b
  jmp alltraps
80106ca7:	e9 0f f7 ff ff       	jmp    801063bb <alltraps>

80106cac <vector60>:
.globl vector60
vector60:
  pushl $0
80106cac:	6a 00                	push   $0x0
  pushl $60
80106cae:	6a 3c                	push   $0x3c
  jmp alltraps
80106cb0:	e9 06 f7 ff ff       	jmp    801063bb <alltraps>

80106cb5 <vector61>:
.globl vector61
vector61:
  pushl $0
80106cb5:	6a 00                	push   $0x0
  pushl $61
80106cb7:	6a 3d                	push   $0x3d
  jmp alltraps
80106cb9:	e9 fd f6 ff ff       	jmp    801063bb <alltraps>

80106cbe <vector62>:
.globl vector62
vector62:
  pushl $0
80106cbe:	6a 00                	push   $0x0
  pushl $62
80106cc0:	6a 3e                	push   $0x3e
  jmp alltraps
80106cc2:	e9 f4 f6 ff ff       	jmp    801063bb <alltraps>

80106cc7 <vector63>:
.globl vector63
vector63:
  pushl $0
80106cc7:	6a 00                	push   $0x0
  pushl $63
80106cc9:	6a 3f                	push   $0x3f
  jmp alltraps
80106ccb:	e9 eb f6 ff ff       	jmp    801063bb <alltraps>

80106cd0 <vector64>:
.globl vector64
vector64:
  pushl $0
80106cd0:	6a 00                	push   $0x0
  pushl $64
80106cd2:	6a 40                	push   $0x40
  jmp alltraps
80106cd4:	e9 e2 f6 ff ff       	jmp    801063bb <alltraps>

80106cd9 <vector65>:
.globl vector65
vector65:
  pushl $0
80106cd9:	6a 00                	push   $0x0
  pushl $65
80106cdb:	6a 41                	push   $0x41
  jmp alltraps
80106cdd:	e9 d9 f6 ff ff       	jmp    801063bb <alltraps>

80106ce2 <vector66>:
.globl vector66
vector66:
  pushl $0
80106ce2:	6a 00                	push   $0x0
  pushl $66
80106ce4:	6a 42                	push   $0x42
  jmp alltraps
80106ce6:	e9 d0 f6 ff ff       	jmp    801063bb <alltraps>

80106ceb <vector67>:
.globl vector67
vector67:
  pushl $0
80106ceb:	6a 00                	push   $0x0
  pushl $67
80106ced:	6a 43                	push   $0x43
  jmp alltraps
80106cef:	e9 c7 f6 ff ff       	jmp    801063bb <alltraps>

80106cf4 <vector68>:
.globl vector68
vector68:
  pushl $0
80106cf4:	6a 00                	push   $0x0
  pushl $68
80106cf6:	6a 44                	push   $0x44
  jmp alltraps
80106cf8:	e9 be f6 ff ff       	jmp    801063bb <alltraps>

80106cfd <vector69>:
.globl vector69
vector69:
  pushl $0
80106cfd:	6a 00                	push   $0x0
  pushl $69
80106cff:	6a 45                	push   $0x45
  jmp alltraps
80106d01:	e9 b5 f6 ff ff       	jmp    801063bb <alltraps>

80106d06 <vector70>:
.globl vector70
vector70:
  pushl $0
80106d06:	6a 00                	push   $0x0
  pushl $70
80106d08:	6a 46                	push   $0x46
  jmp alltraps
80106d0a:	e9 ac f6 ff ff       	jmp    801063bb <alltraps>

80106d0f <vector71>:
.globl vector71
vector71:
  pushl $0
80106d0f:	6a 00                	push   $0x0
  pushl $71
80106d11:	6a 47                	push   $0x47
  jmp alltraps
80106d13:	e9 a3 f6 ff ff       	jmp    801063bb <alltraps>

80106d18 <vector72>:
.globl vector72
vector72:
  pushl $0
80106d18:	6a 00                	push   $0x0
  pushl $72
80106d1a:	6a 48                	push   $0x48
  jmp alltraps
80106d1c:	e9 9a f6 ff ff       	jmp    801063bb <alltraps>

80106d21 <vector73>:
.globl vector73
vector73:
  pushl $0
80106d21:	6a 00                	push   $0x0
  pushl $73
80106d23:	6a 49                	push   $0x49
  jmp alltraps
80106d25:	e9 91 f6 ff ff       	jmp    801063bb <alltraps>

80106d2a <vector74>:
.globl vector74
vector74:
  pushl $0
80106d2a:	6a 00                	push   $0x0
  pushl $74
80106d2c:	6a 4a                	push   $0x4a
  jmp alltraps
80106d2e:	e9 88 f6 ff ff       	jmp    801063bb <alltraps>

80106d33 <vector75>:
.globl vector75
vector75:
  pushl $0
80106d33:	6a 00                	push   $0x0
  pushl $75
80106d35:	6a 4b                	push   $0x4b
  jmp alltraps
80106d37:	e9 7f f6 ff ff       	jmp    801063bb <alltraps>

80106d3c <vector76>:
.globl vector76
vector76:
  pushl $0
80106d3c:	6a 00                	push   $0x0
  pushl $76
80106d3e:	6a 4c                	push   $0x4c
  jmp alltraps
80106d40:	e9 76 f6 ff ff       	jmp    801063bb <alltraps>

80106d45 <vector77>:
.globl vector77
vector77:
  pushl $0
80106d45:	6a 00                	push   $0x0
  pushl $77
80106d47:	6a 4d                	push   $0x4d
  jmp alltraps
80106d49:	e9 6d f6 ff ff       	jmp    801063bb <alltraps>

80106d4e <vector78>:
.globl vector78
vector78:
  pushl $0
80106d4e:	6a 00                	push   $0x0
  pushl $78
80106d50:	6a 4e                	push   $0x4e
  jmp alltraps
80106d52:	e9 64 f6 ff ff       	jmp    801063bb <alltraps>

80106d57 <vector79>:
.globl vector79
vector79:
  pushl $0
80106d57:	6a 00                	push   $0x0
  pushl $79
80106d59:	6a 4f                	push   $0x4f
  jmp alltraps
80106d5b:	e9 5b f6 ff ff       	jmp    801063bb <alltraps>

80106d60 <vector80>:
.globl vector80
vector80:
  pushl $0
80106d60:	6a 00                	push   $0x0
  pushl $80
80106d62:	6a 50                	push   $0x50
  jmp alltraps
80106d64:	e9 52 f6 ff ff       	jmp    801063bb <alltraps>

80106d69 <vector81>:
.globl vector81
vector81:
  pushl $0
80106d69:	6a 00                	push   $0x0
  pushl $81
80106d6b:	6a 51                	push   $0x51
  jmp alltraps
80106d6d:	e9 49 f6 ff ff       	jmp    801063bb <alltraps>

80106d72 <vector82>:
.globl vector82
vector82:
  pushl $0
80106d72:	6a 00                	push   $0x0
  pushl $82
80106d74:	6a 52                	push   $0x52
  jmp alltraps
80106d76:	e9 40 f6 ff ff       	jmp    801063bb <alltraps>

80106d7b <vector83>:
.globl vector83
vector83:
  pushl $0
80106d7b:	6a 00                	push   $0x0
  pushl $83
80106d7d:	6a 53                	push   $0x53
  jmp alltraps
80106d7f:	e9 37 f6 ff ff       	jmp    801063bb <alltraps>

80106d84 <vector84>:
.globl vector84
vector84:
  pushl $0
80106d84:	6a 00                	push   $0x0
  pushl $84
80106d86:	6a 54                	push   $0x54
  jmp alltraps
80106d88:	e9 2e f6 ff ff       	jmp    801063bb <alltraps>

80106d8d <vector85>:
.globl vector85
vector85:
  pushl $0
80106d8d:	6a 00                	push   $0x0
  pushl $85
80106d8f:	6a 55                	push   $0x55
  jmp alltraps
80106d91:	e9 25 f6 ff ff       	jmp    801063bb <alltraps>

80106d96 <vector86>:
.globl vector86
vector86:
  pushl $0
80106d96:	6a 00                	push   $0x0
  pushl $86
80106d98:	6a 56                	push   $0x56
  jmp alltraps
80106d9a:	e9 1c f6 ff ff       	jmp    801063bb <alltraps>

80106d9f <vector87>:
.globl vector87
vector87:
  pushl $0
80106d9f:	6a 00                	push   $0x0
  pushl $87
80106da1:	6a 57                	push   $0x57
  jmp alltraps
80106da3:	e9 13 f6 ff ff       	jmp    801063bb <alltraps>

80106da8 <vector88>:
.globl vector88
vector88:
  pushl $0
80106da8:	6a 00                	push   $0x0
  pushl $88
80106daa:	6a 58                	push   $0x58
  jmp alltraps
80106dac:	e9 0a f6 ff ff       	jmp    801063bb <alltraps>

80106db1 <vector89>:
.globl vector89
vector89:
  pushl $0
80106db1:	6a 00                	push   $0x0
  pushl $89
80106db3:	6a 59                	push   $0x59
  jmp alltraps
80106db5:	e9 01 f6 ff ff       	jmp    801063bb <alltraps>

80106dba <vector90>:
.globl vector90
vector90:
  pushl $0
80106dba:	6a 00                	push   $0x0
  pushl $90
80106dbc:	6a 5a                	push   $0x5a
  jmp alltraps
80106dbe:	e9 f8 f5 ff ff       	jmp    801063bb <alltraps>

80106dc3 <vector91>:
.globl vector91
vector91:
  pushl $0
80106dc3:	6a 00                	push   $0x0
  pushl $91
80106dc5:	6a 5b                	push   $0x5b
  jmp alltraps
80106dc7:	e9 ef f5 ff ff       	jmp    801063bb <alltraps>

80106dcc <vector92>:
.globl vector92
vector92:
  pushl $0
80106dcc:	6a 00                	push   $0x0
  pushl $92
80106dce:	6a 5c                	push   $0x5c
  jmp alltraps
80106dd0:	e9 e6 f5 ff ff       	jmp    801063bb <alltraps>

80106dd5 <vector93>:
.globl vector93
vector93:
  pushl $0
80106dd5:	6a 00                	push   $0x0
  pushl $93
80106dd7:	6a 5d                	push   $0x5d
  jmp alltraps
80106dd9:	e9 dd f5 ff ff       	jmp    801063bb <alltraps>

80106dde <vector94>:
.globl vector94
vector94:
  pushl $0
80106dde:	6a 00                	push   $0x0
  pushl $94
80106de0:	6a 5e                	push   $0x5e
  jmp alltraps
80106de2:	e9 d4 f5 ff ff       	jmp    801063bb <alltraps>

80106de7 <vector95>:
.globl vector95
vector95:
  pushl $0
80106de7:	6a 00                	push   $0x0
  pushl $95
80106de9:	6a 5f                	push   $0x5f
  jmp alltraps
80106deb:	e9 cb f5 ff ff       	jmp    801063bb <alltraps>

80106df0 <vector96>:
.globl vector96
vector96:
  pushl $0
80106df0:	6a 00                	push   $0x0
  pushl $96
80106df2:	6a 60                	push   $0x60
  jmp alltraps
80106df4:	e9 c2 f5 ff ff       	jmp    801063bb <alltraps>

80106df9 <vector97>:
.globl vector97
vector97:
  pushl $0
80106df9:	6a 00                	push   $0x0
  pushl $97
80106dfb:	6a 61                	push   $0x61
  jmp alltraps
80106dfd:	e9 b9 f5 ff ff       	jmp    801063bb <alltraps>

80106e02 <vector98>:
.globl vector98
vector98:
  pushl $0
80106e02:	6a 00                	push   $0x0
  pushl $98
80106e04:	6a 62                	push   $0x62
  jmp alltraps
80106e06:	e9 b0 f5 ff ff       	jmp    801063bb <alltraps>

80106e0b <vector99>:
.globl vector99
vector99:
  pushl $0
80106e0b:	6a 00                	push   $0x0
  pushl $99
80106e0d:	6a 63                	push   $0x63
  jmp alltraps
80106e0f:	e9 a7 f5 ff ff       	jmp    801063bb <alltraps>

80106e14 <vector100>:
.globl vector100
vector100:
  pushl $0
80106e14:	6a 00                	push   $0x0
  pushl $100
80106e16:	6a 64                	push   $0x64
  jmp alltraps
80106e18:	e9 9e f5 ff ff       	jmp    801063bb <alltraps>

80106e1d <vector101>:
.globl vector101
vector101:
  pushl $0
80106e1d:	6a 00                	push   $0x0
  pushl $101
80106e1f:	6a 65                	push   $0x65
  jmp alltraps
80106e21:	e9 95 f5 ff ff       	jmp    801063bb <alltraps>

80106e26 <vector102>:
.globl vector102
vector102:
  pushl $0
80106e26:	6a 00                	push   $0x0
  pushl $102
80106e28:	6a 66                	push   $0x66
  jmp alltraps
80106e2a:	e9 8c f5 ff ff       	jmp    801063bb <alltraps>

80106e2f <vector103>:
.globl vector103
vector103:
  pushl $0
80106e2f:	6a 00                	push   $0x0
  pushl $103
80106e31:	6a 67                	push   $0x67
  jmp alltraps
80106e33:	e9 83 f5 ff ff       	jmp    801063bb <alltraps>

80106e38 <vector104>:
.globl vector104
vector104:
  pushl $0
80106e38:	6a 00                	push   $0x0
  pushl $104
80106e3a:	6a 68                	push   $0x68
  jmp alltraps
80106e3c:	e9 7a f5 ff ff       	jmp    801063bb <alltraps>

80106e41 <vector105>:
.globl vector105
vector105:
  pushl $0
80106e41:	6a 00                	push   $0x0
  pushl $105
80106e43:	6a 69                	push   $0x69
  jmp alltraps
80106e45:	e9 71 f5 ff ff       	jmp    801063bb <alltraps>

80106e4a <vector106>:
.globl vector106
vector106:
  pushl $0
80106e4a:	6a 00                	push   $0x0
  pushl $106
80106e4c:	6a 6a                	push   $0x6a
  jmp alltraps
80106e4e:	e9 68 f5 ff ff       	jmp    801063bb <alltraps>

80106e53 <vector107>:
.globl vector107
vector107:
  pushl $0
80106e53:	6a 00                	push   $0x0
  pushl $107
80106e55:	6a 6b                	push   $0x6b
  jmp alltraps
80106e57:	e9 5f f5 ff ff       	jmp    801063bb <alltraps>

80106e5c <vector108>:
.globl vector108
vector108:
  pushl $0
80106e5c:	6a 00                	push   $0x0
  pushl $108
80106e5e:	6a 6c                	push   $0x6c
  jmp alltraps
80106e60:	e9 56 f5 ff ff       	jmp    801063bb <alltraps>

80106e65 <vector109>:
.globl vector109
vector109:
  pushl $0
80106e65:	6a 00                	push   $0x0
  pushl $109
80106e67:	6a 6d                	push   $0x6d
  jmp alltraps
80106e69:	e9 4d f5 ff ff       	jmp    801063bb <alltraps>

80106e6e <vector110>:
.globl vector110
vector110:
  pushl $0
80106e6e:	6a 00                	push   $0x0
  pushl $110
80106e70:	6a 6e                	push   $0x6e
  jmp alltraps
80106e72:	e9 44 f5 ff ff       	jmp    801063bb <alltraps>

80106e77 <vector111>:
.globl vector111
vector111:
  pushl $0
80106e77:	6a 00                	push   $0x0
  pushl $111
80106e79:	6a 6f                	push   $0x6f
  jmp alltraps
80106e7b:	e9 3b f5 ff ff       	jmp    801063bb <alltraps>

80106e80 <vector112>:
.globl vector112
vector112:
  pushl $0
80106e80:	6a 00                	push   $0x0
  pushl $112
80106e82:	6a 70                	push   $0x70
  jmp alltraps
80106e84:	e9 32 f5 ff ff       	jmp    801063bb <alltraps>

80106e89 <vector113>:
.globl vector113
vector113:
  pushl $0
80106e89:	6a 00                	push   $0x0
  pushl $113
80106e8b:	6a 71                	push   $0x71
  jmp alltraps
80106e8d:	e9 29 f5 ff ff       	jmp    801063bb <alltraps>

80106e92 <vector114>:
.globl vector114
vector114:
  pushl $0
80106e92:	6a 00                	push   $0x0
  pushl $114
80106e94:	6a 72                	push   $0x72
  jmp alltraps
80106e96:	e9 20 f5 ff ff       	jmp    801063bb <alltraps>

80106e9b <vector115>:
.globl vector115
vector115:
  pushl $0
80106e9b:	6a 00                	push   $0x0
  pushl $115
80106e9d:	6a 73                	push   $0x73
  jmp alltraps
80106e9f:	e9 17 f5 ff ff       	jmp    801063bb <alltraps>

80106ea4 <vector116>:
.globl vector116
vector116:
  pushl $0
80106ea4:	6a 00                	push   $0x0
  pushl $116
80106ea6:	6a 74                	push   $0x74
  jmp alltraps
80106ea8:	e9 0e f5 ff ff       	jmp    801063bb <alltraps>

80106ead <vector117>:
.globl vector117
vector117:
  pushl $0
80106ead:	6a 00                	push   $0x0
  pushl $117
80106eaf:	6a 75                	push   $0x75
  jmp alltraps
80106eb1:	e9 05 f5 ff ff       	jmp    801063bb <alltraps>

80106eb6 <vector118>:
.globl vector118
vector118:
  pushl $0
80106eb6:	6a 00                	push   $0x0
  pushl $118
80106eb8:	6a 76                	push   $0x76
  jmp alltraps
80106eba:	e9 fc f4 ff ff       	jmp    801063bb <alltraps>

80106ebf <vector119>:
.globl vector119
vector119:
  pushl $0
80106ebf:	6a 00                	push   $0x0
  pushl $119
80106ec1:	6a 77                	push   $0x77
  jmp alltraps
80106ec3:	e9 f3 f4 ff ff       	jmp    801063bb <alltraps>

80106ec8 <vector120>:
.globl vector120
vector120:
  pushl $0
80106ec8:	6a 00                	push   $0x0
  pushl $120
80106eca:	6a 78                	push   $0x78
  jmp alltraps
80106ecc:	e9 ea f4 ff ff       	jmp    801063bb <alltraps>

80106ed1 <vector121>:
.globl vector121
vector121:
  pushl $0
80106ed1:	6a 00                	push   $0x0
  pushl $121
80106ed3:	6a 79                	push   $0x79
  jmp alltraps
80106ed5:	e9 e1 f4 ff ff       	jmp    801063bb <alltraps>

80106eda <vector122>:
.globl vector122
vector122:
  pushl $0
80106eda:	6a 00                	push   $0x0
  pushl $122
80106edc:	6a 7a                	push   $0x7a
  jmp alltraps
80106ede:	e9 d8 f4 ff ff       	jmp    801063bb <alltraps>

80106ee3 <vector123>:
.globl vector123
vector123:
  pushl $0
80106ee3:	6a 00                	push   $0x0
  pushl $123
80106ee5:	6a 7b                	push   $0x7b
  jmp alltraps
80106ee7:	e9 cf f4 ff ff       	jmp    801063bb <alltraps>

80106eec <vector124>:
.globl vector124
vector124:
  pushl $0
80106eec:	6a 00                	push   $0x0
  pushl $124
80106eee:	6a 7c                	push   $0x7c
  jmp alltraps
80106ef0:	e9 c6 f4 ff ff       	jmp    801063bb <alltraps>

80106ef5 <vector125>:
.globl vector125
vector125:
  pushl $0
80106ef5:	6a 00                	push   $0x0
  pushl $125
80106ef7:	6a 7d                	push   $0x7d
  jmp alltraps
80106ef9:	e9 bd f4 ff ff       	jmp    801063bb <alltraps>

80106efe <vector126>:
.globl vector126
vector126:
  pushl $0
80106efe:	6a 00                	push   $0x0
  pushl $126
80106f00:	6a 7e                	push   $0x7e
  jmp alltraps
80106f02:	e9 b4 f4 ff ff       	jmp    801063bb <alltraps>

80106f07 <vector127>:
.globl vector127
vector127:
  pushl $0
80106f07:	6a 00                	push   $0x0
  pushl $127
80106f09:	6a 7f                	push   $0x7f
  jmp alltraps
80106f0b:	e9 ab f4 ff ff       	jmp    801063bb <alltraps>

80106f10 <vector128>:
.globl vector128
vector128:
  pushl $0
80106f10:	6a 00                	push   $0x0
  pushl $128
80106f12:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106f17:	e9 9f f4 ff ff       	jmp    801063bb <alltraps>

80106f1c <vector129>:
.globl vector129
vector129:
  pushl $0
80106f1c:	6a 00                	push   $0x0
  pushl $129
80106f1e:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106f23:	e9 93 f4 ff ff       	jmp    801063bb <alltraps>

80106f28 <vector130>:
.globl vector130
vector130:
  pushl $0
80106f28:	6a 00                	push   $0x0
  pushl $130
80106f2a:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106f2f:	e9 87 f4 ff ff       	jmp    801063bb <alltraps>

80106f34 <vector131>:
.globl vector131
vector131:
  pushl $0
80106f34:	6a 00                	push   $0x0
  pushl $131
80106f36:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106f3b:	e9 7b f4 ff ff       	jmp    801063bb <alltraps>

80106f40 <vector132>:
.globl vector132
vector132:
  pushl $0
80106f40:	6a 00                	push   $0x0
  pushl $132
80106f42:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106f47:	e9 6f f4 ff ff       	jmp    801063bb <alltraps>

80106f4c <vector133>:
.globl vector133
vector133:
  pushl $0
80106f4c:	6a 00                	push   $0x0
  pushl $133
80106f4e:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106f53:	e9 63 f4 ff ff       	jmp    801063bb <alltraps>

80106f58 <vector134>:
.globl vector134
vector134:
  pushl $0
80106f58:	6a 00                	push   $0x0
  pushl $134
80106f5a:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106f5f:	e9 57 f4 ff ff       	jmp    801063bb <alltraps>

80106f64 <vector135>:
.globl vector135
vector135:
  pushl $0
80106f64:	6a 00                	push   $0x0
  pushl $135
80106f66:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106f6b:	e9 4b f4 ff ff       	jmp    801063bb <alltraps>

80106f70 <vector136>:
.globl vector136
vector136:
  pushl $0
80106f70:	6a 00                	push   $0x0
  pushl $136
80106f72:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106f77:	e9 3f f4 ff ff       	jmp    801063bb <alltraps>

80106f7c <vector137>:
.globl vector137
vector137:
  pushl $0
80106f7c:	6a 00                	push   $0x0
  pushl $137
80106f7e:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106f83:	e9 33 f4 ff ff       	jmp    801063bb <alltraps>

80106f88 <vector138>:
.globl vector138
vector138:
  pushl $0
80106f88:	6a 00                	push   $0x0
  pushl $138
80106f8a:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106f8f:	e9 27 f4 ff ff       	jmp    801063bb <alltraps>

80106f94 <vector139>:
.globl vector139
vector139:
  pushl $0
80106f94:	6a 00                	push   $0x0
  pushl $139
80106f96:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106f9b:	e9 1b f4 ff ff       	jmp    801063bb <alltraps>

80106fa0 <vector140>:
.globl vector140
vector140:
  pushl $0
80106fa0:	6a 00                	push   $0x0
  pushl $140
80106fa2:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106fa7:	e9 0f f4 ff ff       	jmp    801063bb <alltraps>

80106fac <vector141>:
.globl vector141
vector141:
  pushl $0
80106fac:	6a 00                	push   $0x0
  pushl $141
80106fae:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106fb3:	e9 03 f4 ff ff       	jmp    801063bb <alltraps>

80106fb8 <vector142>:
.globl vector142
vector142:
  pushl $0
80106fb8:	6a 00                	push   $0x0
  pushl $142
80106fba:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106fbf:	e9 f7 f3 ff ff       	jmp    801063bb <alltraps>

80106fc4 <vector143>:
.globl vector143
vector143:
  pushl $0
80106fc4:	6a 00                	push   $0x0
  pushl $143
80106fc6:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106fcb:	e9 eb f3 ff ff       	jmp    801063bb <alltraps>

80106fd0 <vector144>:
.globl vector144
vector144:
  pushl $0
80106fd0:	6a 00                	push   $0x0
  pushl $144
80106fd2:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106fd7:	e9 df f3 ff ff       	jmp    801063bb <alltraps>

80106fdc <vector145>:
.globl vector145
vector145:
  pushl $0
80106fdc:	6a 00                	push   $0x0
  pushl $145
80106fde:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106fe3:	e9 d3 f3 ff ff       	jmp    801063bb <alltraps>

80106fe8 <vector146>:
.globl vector146
vector146:
  pushl $0
80106fe8:	6a 00                	push   $0x0
  pushl $146
80106fea:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106fef:	e9 c7 f3 ff ff       	jmp    801063bb <alltraps>

80106ff4 <vector147>:
.globl vector147
vector147:
  pushl $0
80106ff4:	6a 00                	push   $0x0
  pushl $147
80106ff6:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106ffb:	e9 bb f3 ff ff       	jmp    801063bb <alltraps>

80107000 <vector148>:
.globl vector148
vector148:
  pushl $0
80107000:	6a 00                	push   $0x0
  pushl $148
80107002:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107007:	e9 af f3 ff ff       	jmp    801063bb <alltraps>

8010700c <vector149>:
.globl vector149
vector149:
  pushl $0
8010700c:	6a 00                	push   $0x0
  pushl $149
8010700e:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107013:	e9 a3 f3 ff ff       	jmp    801063bb <alltraps>

80107018 <vector150>:
.globl vector150
vector150:
  pushl $0
80107018:	6a 00                	push   $0x0
  pushl $150
8010701a:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010701f:	e9 97 f3 ff ff       	jmp    801063bb <alltraps>

80107024 <vector151>:
.globl vector151
vector151:
  pushl $0
80107024:	6a 00                	push   $0x0
  pushl $151
80107026:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010702b:	e9 8b f3 ff ff       	jmp    801063bb <alltraps>

80107030 <vector152>:
.globl vector152
vector152:
  pushl $0
80107030:	6a 00                	push   $0x0
  pushl $152
80107032:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107037:	e9 7f f3 ff ff       	jmp    801063bb <alltraps>

8010703c <vector153>:
.globl vector153
vector153:
  pushl $0
8010703c:	6a 00                	push   $0x0
  pushl $153
8010703e:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107043:	e9 73 f3 ff ff       	jmp    801063bb <alltraps>

80107048 <vector154>:
.globl vector154
vector154:
  pushl $0
80107048:	6a 00                	push   $0x0
  pushl $154
8010704a:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010704f:	e9 67 f3 ff ff       	jmp    801063bb <alltraps>

80107054 <vector155>:
.globl vector155
vector155:
  pushl $0
80107054:	6a 00                	push   $0x0
  pushl $155
80107056:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010705b:	e9 5b f3 ff ff       	jmp    801063bb <alltraps>

80107060 <vector156>:
.globl vector156
vector156:
  pushl $0
80107060:	6a 00                	push   $0x0
  pushl $156
80107062:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107067:	e9 4f f3 ff ff       	jmp    801063bb <alltraps>

8010706c <vector157>:
.globl vector157
vector157:
  pushl $0
8010706c:	6a 00                	push   $0x0
  pushl $157
8010706e:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107073:	e9 43 f3 ff ff       	jmp    801063bb <alltraps>

80107078 <vector158>:
.globl vector158
vector158:
  pushl $0
80107078:	6a 00                	push   $0x0
  pushl $158
8010707a:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010707f:	e9 37 f3 ff ff       	jmp    801063bb <alltraps>

80107084 <vector159>:
.globl vector159
vector159:
  pushl $0
80107084:	6a 00                	push   $0x0
  pushl $159
80107086:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010708b:	e9 2b f3 ff ff       	jmp    801063bb <alltraps>

80107090 <vector160>:
.globl vector160
vector160:
  pushl $0
80107090:	6a 00                	push   $0x0
  pushl $160
80107092:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107097:	e9 1f f3 ff ff       	jmp    801063bb <alltraps>

8010709c <vector161>:
.globl vector161
vector161:
  pushl $0
8010709c:	6a 00                	push   $0x0
  pushl $161
8010709e:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801070a3:	e9 13 f3 ff ff       	jmp    801063bb <alltraps>

801070a8 <vector162>:
.globl vector162
vector162:
  pushl $0
801070a8:	6a 00                	push   $0x0
  pushl $162
801070aa:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801070af:	e9 07 f3 ff ff       	jmp    801063bb <alltraps>

801070b4 <vector163>:
.globl vector163
vector163:
  pushl $0
801070b4:	6a 00                	push   $0x0
  pushl $163
801070b6:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801070bb:	e9 fb f2 ff ff       	jmp    801063bb <alltraps>

801070c0 <vector164>:
.globl vector164
vector164:
  pushl $0
801070c0:	6a 00                	push   $0x0
  pushl $164
801070c2:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801070c7:	e9 ef f2 ff ff       	jmp    801063bb <alltraps>

801070cc <vector165>:
.globl vector165
vector165:
  pushl $0
801070cc:	6a 00                	push   $0x0
  pushl $165
801070ce:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801070d3:	e9 e3 f2 ff ff       	jmp    801063bb <alltraps>

801070d8 <vector166>:
.globl vector166
vector166:
  pushl $0
801070d8:	6a 00                	push   $0x0
  pushl $166
801070da:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801070df:	e9 d7 f2 ff ff       	jmp    801063bb <alltraps>

801070e4 <vector167>:
.globl vector167
vector167:
  pushl $0
801070e4:	6a 00                	push   $0x0
  pushl $167
801070e6:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801070eb:	e9 cb f2 ff ff       	jmp    801063bb <alltraps>

801070f0 <vector168>:
.globl vector168
vector168:
  pushl $0
801070f0:	6a 00                	push   $0x0
  pushl $168
801070f2:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801070f7:	e9 bf f2 ff ff       	jmp    801063bb <alltraps>

801070fc <vector169>:
.globl vector169
vector169:
  pushl $0
801070fc:	6a 00                	push   $0x0
  pushl $169
801070fe:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107103:	e9 b3 f2 ff ff       	jmp    801063bb <alltraps>

80107108 <vector170>:
.globl vector170
vector170:
  pushl $0
80107108:	6a 00                	push   $0x0
  pushl $170
8010710a:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010710f:	e9 a7 f2 ff ff       	jmp    801063bb <alltraps>

80107114 <vector171>:
.globl vector171
vector171:
  pushl $0
80107114:	6a 00                	push   $0x0
  pushl $171
80107116:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010711b:	e9 9b f2 ff ff       	jmp    801063bb <alltraps>

80107120 <vector172>:
.globl vector172
vector172:
  pushl $0
80107120:	6a 00                	push   $0x0
  pushl $172
80107122:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107127:	e9 8f f2 ff ff       	jmp    801063bb <alltraps>

8010712c <vector173>:
.globl vector173
vector173:
  pushl $0
8010712c:	6a 00                	push   $0x0
  pushl $173
8010712e:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107133:	e9 83 f2 ff ff       	jmp    801063bb <alltraps>

80107138 <vector174>:
.globl vector174
vector174:
  pushl $0
80107138:	6a 00                	push   $0x0
  pushl $174
8010713a:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010713f:	e9 77 f2 ff ff       	jmp    801063bb <alltraps>

80107144 <vector175>:
.globl vector175
vector175:
  pushl $0
80107144:	6a 00                	push   $0x0
  pushl $175
80107146:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010714b:	e9 6b f2 ff ff       	jmp    801063bb <alltraps>

80107150 <vector176>:
.globl vector176
vector176:
  pushl $0
80107150:	6a 00                	push   $0x0
  pushl $176
80107152:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107157:	e9 5f f2 ff ff       	jmp    801063bb <alltraps>

8010715c <vector177>:
.globl vector177
vector177:
  pushl $0
8010715c:	6a 00                	push   $0x0
  pushl $177
8010715e:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107163:	e9 53 f2 ff ff       	jmp    801063bb <alltraps>

80107168 <vector178>:
.globl vector178
vector178:
  pushl $0
80107168:	6a 00                	push   $0x0
  pushl $178
8010716a:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010716f:	e9 47 f2 ff ff       	jmp    801063bb <alltraps>

80107174 <vector179>:
.globl vector179
vector179:
  pushl $0
80107174:	6a 00                	push   $0x0
  pushl $179
80107176:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010717b:	e9 3b f2 ff ff       	jmp    801063bb <alltraps>

80107180 <vector180>:
.globl vector180
vector180:
  pushl $0
80107180:	6a 00                	push   $0x0
  pushl $180
80107182:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107187:	e9 2f f2 ff ff       	jmp    801063bb <alltraps>

8010718c <vector181>:
.globl vector181
vector181:
  pushl $0
8010718c:	6a 00                	push   $0x0
  pushl $181
8010718e:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107193:	e9 23 f2 ff ff       	jmp    801063bb <alltraps>

80107198 <vector182>:
.globl vector182
vector182:
  pushl $0
80107198:	6a 00                	push   $0x0
  pushl $182
8010719a:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010719f:	e9 17 f2 ff ff       	jmp    801063bb <alltraps>

801071a4 <vector183>:
.globl vector183
vector183:
  pushl $0
801071a4:	6a 00                	push   $0x0
  pushl $183
801071a6:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801071ab:	e9 0b f2 ff ff       	jmp    801063bb <alltraps>

801071b0 <vector184>:
.globl vector184
vector184:
  pushl $0
801071b0:	6a 00                	push   $0x0
  pushl $184
801071b2:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801071b7:	e9 ff f1 ff ff       	jmp    801063bb <alltraps>

801071bc <vector185>:
.globl vector185
vector185:
  pushl $0
801071bc:	6a 00                	push   $0x0
  pushl $185
801071be:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801071c3:	e9 f3 f1 ff ff       	jmp    801063bb <alltraps>

801071c8 <vector186>:
.globl vector186
vector186:
  pushl $0
801071c8:	6a 00                	push   $0x0
  pushl $186
801071ca:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801071cf:	e9 e7 f1 ff ff       	jmp    801063bb <alltraps>

801071d4 <vector187>:
.globl vector187
vector187:
  pushl $0
801071d4:	6a 00                	push   $0x0
  pushl $187
801071d6:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801071db:	e9 db f1 ff ff       	jmp    801063bb <alltraps>

801071e0 <vector188>:
.globl vector188
vector188:
  pushl $0
801071e0:	6a 00                	push   $0x0
  pushl $188
801071e2:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801071e7:	e9 cf f1 ff ff       	jmp    801063bb <alltraps>

801071ec <vector189>:
.globl vector189
vector189:
  pushl $0
801071ec:	6a 00                	push   $0x0
  pushl $189
801071ee:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801071f3:	e9 c3 f1 ff ff       	jmp    801063bb <alltraps>

801071f8 <vector190>:
.globl vector190
vector190:
  pushl $0
801071f8:	6a 00                	push   $0x0
  pushl $190
801071fa:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801071ff:	e9 b7 f1 ff ff       	jmp    801063bb <alltraps>

80107204 <vector191>:
.globl vector191
vector191:
  pushl $0
80107204:	6a 00                	push   $0x0
  pushl $191
80107206:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010720b:	e9 ab f1 ff ff       	jmp    801063bb <alltraps>

80107210 <vector192>:
.globl vector192
vector192:
  pushl $0
80107210:	6a 00                	push   $0x0
  pushl $192
80107212:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107217:	e9 9f f1 ff ff       	jmp    801063bb <alltraps>

8010721c <vector193>:
.globl vector193
vector193:
  pushl $0
8010721c:	6a 00                	push   $0x0
  pushl $193
8010721e:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107223:	e9 93 f1 ff ff       	jmp    801063bb <alltraps>

80107228 <vector194>:
.globl vector194
vector194:
  pushl $0
80107228:	6a 00                	push   $0x0
  pushl $194
8010722a:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010722f:	e9 87 f1 ff ff       	jmp    801063bb <alltraps>

80107234 <vector195>:
.globl vector195
vector195:
  pushl $0
80107234:	6a 00                	push   $0x0
  pushl $195
80107236:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010723b:	e9 7b f1 ff ff       	jmp    801063bb <alltraps>

80107240 <vector196>:
.globl vector196
vector196:
  pushl $0
80107240:	6a 00                	push   $0x0
  pushl $196
80107242:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107247:	e9 6f f1 ff ff       	jmp    801063bb <alltraps>

8010724c <vector197>:
.globl vector197
vector197:
  pushl $0
8010724c:	6a 00                	push   $0x0
  pushl $197
8010724e:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107253:	e9 63 f1 ff ff       	jmp    801063bb <alltraps>

80107258 <vector198>:
.globl vector198
vector198:
  pushl $0
80107258:	6a 00                	push   $0x0
  pushl $198
8010725a:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010725f:	e9 57 f1 ff ff       	jmp    801063bb <alltraps>

80107264 <vector199>:
.globl vector199
vector199:
  pushl $0
80107264:	6a 00                	push   $0x0
  pushl $199
80107266:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010726b:	e9 4b f1 ff ff       	jmp    801063bb <alltraps>

80107270 <vector200>:
.globl vector200
vector200:
  pushl $0
80107270:	6a 00                	push   $0x0
  pushl $200
80107272:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107277:	e9 3f f1 ff ff       	jmp    801063bb <alltraps>

8010727c <vector201>:
.globl vector201
vector201:
  pushl $0
8010727c:	6a 00                	push   $0x0
  pushl $201
8010727e:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107283:	e9 33 f1 ff ff       	jmp    801063bb <alltraps>

80107288 <vector202>:
.globl vector202
vector202:
  pushl $0
80107288:	6a 00                	push   $0x0
  pushl $202
8010728a:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010728f:	e9 27 f1 ff ff       	jmp    801063bb <alltraps>

80107294 <vector203>:
.globl vector203
vector203:
  pushl $0
80107294:	6a 00                	push   $0x0
  pushl $203
80107296:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010729b:	e9 1b f1 ff ff       	jmp    801063bb <alltraps>

801072a0 <vector204>:
.globl vector204
vector204:
  pushl $0
801072a0:	6a 00                	push   $0x0
  pushl $204
801072a2:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801072a7:	e9 0f f1 ff ff       	jmp    801063bb <alltraps>

801072ac <vector205>:
.globl vector205
vector205:
  pushl $0
801072ac:	6a 00                	push   $0x0
  pushl $205
801072ae:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801072b3:	e9 03 f1 ff ff       	jmp    801063bb <alltraps>

801072b8 <vector206>:
.globl vector206
vector206:
  pushl $0
801072b8:	6a 00                	push   $0x0
  pushl $206
801072ba:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801072bf:	e9 f7 f0 ff ff       	jmp    801063bb <alltraps>

801072c4 <vector207>:
.globl vector207
vector207:
  pushl $0
801072c4:	6a 00                	push   $0x0
  pushl $207
801072c6:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801072cb:	e9 eb f0 ff ff       	jmp    801063bb <alltraps>

801072d0 <vector208>:
.globl vector208
vector208:
  pushl $0
801072d0:	6a 00                	push   $0x0
  pushl $208
801072d2:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801072d7:	e9 df f0 ff ff       	jmp    801063bb <alltraps>

801072dc <vector209>:
.globl vector209
vector209:
  pushl $0
801072dc:	6a 00                	push   $0x0
  pushl $209
801072de:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801072e3:	e9 d3 f0 ff ff       	jmp    801063bb <alltraps>

801072e8 <vector210>:
.globl vector210
vector210:
  pushl $0
801072e8:	6a 00                	push   $0x0
  pushl $210
801072ea:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801072ef:	e9 c7 f0 ff ff       	jmp    801063bb <alltraps>

801072f4 <vector211>:
.globl vector211
vector211:
  pushl $0
801072f4:	6a 00                	push   $0x0
  pushl $211
801072f6:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801072fb:	e9 bb f0 ff ff       	jmp    801063bb <alltraps>

80107300 <vector212>:
.globl vector212
vector212:
  pushl $0
80107300:	6a 00                	push   $0x0
  pushl $212
80107302:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107307:	e9 af f0 ff ff       	jmp    801063bb <alltraps>

8010730c <vector213>:
.globl vector213
vector213:
  pushl $0
8010730c:	6a 00                	push   $0x0
  pushl $213
8010730e:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107313:	e9 a3 f0 ff ff       	jmp    801063bb <alltraps>

80107318 <vector214>:
.globl vector214
vector214:
  pushl $0
80107318:	6a 00                	push   $0x0
  pushl $214
8010731a:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010731f:	e9 97 f0 ff ff       	jmp    801063bb <alltraps>

80107324 <vector215>:
.globl vector215
vector215:
  pushl $0
80107324:	6a 00                	push   $0x0
  pushl $215
80107326:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010732b:	e9 8b f0 ff ff       	jmp    801063bb <alltraps>

80107330 <vector216>:
.globl vector216
vector216:
  pushl $0
80107330:	6a 00                	push   $0x0
  pushl $216
80107332:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107337:	e9 7f f0 ff ff       	jmp    801063bb <alltraps>

8010733c <vector217>:
.globl vector217
vector217:
  pushl $0
8010733c:	6a 00                	push   $0x0
  pushl $217
8010733e:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107343:	e9 73 f0 ff ff       	jmp    801063bb <alltraps>

80107348 <vector218>:
.globl vector218
vector218:
  pushl $0
80107348:	6a 00                	push   $0x0
  pushl $218
8010734a:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010734f:	e9 67 f0 ff ff       	jmp    801063bb <alltraps>

80107354 <vector219>:
.globl vector219
vector219:
  pushl $0
80107354:	6a 00                	push   $0x0
  pushl $219
80107356:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010735b:	e9 5b f0 ff ff       	jmp    801063bb <alltraps>

80107360 <vector220>:
.globl vector220
vector220:
  pushl $0
80107360:	6a 00                	push   $0x0
  pushl $220
80107362:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107367:	e9 4f f0 ff ff       	jmp    801063bb <alltraps>

8010736c <vector221>:
.globl vector221
vector221:
  pushl $0
8010736c:	6a 00                	push   $0x0
  pushl $221
8010736e:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107373:	e9 43 f0 ff ff       	jmp    801063bb <alltraps>

80107378 <vector222>:
.globl vector222
vector222:
  pushl $0
80107378:	6a 00                	push   $0x0
  pushl $222
8010737a:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010737f:	e9 37 f0 ff ff       	jmp    801063bb <alltraps>

80107384 <vector223>:
.globl vector223
vector223:
  pushl $0
80107384:	6a 00                	push   $0x0
  pushl $223
80107386:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010738b:	e9 2b f0 ff ff       	jmp    801063bb <alltraps>

80107390 <vector224>:
.globl vector224
vector224:
  pushl $0
80107390:	6a 00                	push   $0x0
  pushl $224
80107392:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107397:	e9 1f f0 ff ff       	jmp    801063bb <alltraps>

8010739c <vector225>:
.globl vector225
vector225:
  pushl $0
8010739c:	6a 00                	push   $0x0
  pushl $225
8010739e:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801073a3:	e9 13 f0 ff ff       	jmp    801063bb <alltraps>

801073a8 <vector226>:
.globl vector226
vector226:
  pushl $0
801073a8:	6a 00                	push   $0x0
  pushl $226
801073aa:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801073af:	e9 07 f0 ff ff       	jmp    801063bb <alltraps>

801073b4 <vector227>:
.globl vector227
vector227:
  pushl $0
801073b4:	6a 00                	push   $0x0
  pushl $227
801073b6:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801073bb:	e9 fb ef ff ff       	jmp    801063bb <alltraps>

801073c0 <vector228>:
.globl vector228
vector228:
  pushl $0
801073c0:	6a 00                	push   $0x0
  pushl $228
801073c2:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801073c7:	e9 ef ef ff ff       	jmp    801063bb <alltraps>

801073cc <vector229>:
.globl vector229
vector229:
  pushl $0
801073cc:	6a 00                	push   $0x0
  pushl $229
801073ce:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801073d3:	e9 e3 ef ff ff       	jmp    801063bb <alltraps>

801073d8 <vector230>:
.globl vector230
vector230:
  pushl $0
801073d8:	6a 00                	push   $0x0
  pushl $230
801073da:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801073df:	e9 d7 ef ff ff       	jmp    801063bb <alltraps>

801073e4 <vector231>:
.globl vector231
vector231:
  pushl $0
801073e4:	6a 00                	push   $0x0
  pushl $231
801073e6:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801073eb:	e9 cb ef ff ff       	jmp    801063bb <alltraps>

801073f0 <vector232>:
.globl vector232
vector232:
  pushl $0
801073f0:	6a 00                	push   $0x0
  pushl $232
801073f2:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801073f7:	e9 bf ef ff ff       	jmp    801063bb <alltraps>

801073fc <vector233>:
.globl vector233
vector233:
  pushl $0
801073fc:	6a 00                	push   $0x0
  pushl $233
801073fe:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107403:	e9 b3 ef ff ff       	jmp    801063bb <alltraps>

80107408 <vector234>:
.globl vector234
vector234:
  pushl $0
80107408:	6a 00                	push   $0x0
  pushl $234
8010740a:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010740f:	e9 a7 ef ff ff       	jmp    801063bb <alltraps>

80107414 <vector235>:
.globl vector235
vector235:
  pushl $0
80107414:	6a 00                	push   $0x0
  pushl $235
80107416:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010741b:	e9 9b ef ff ff       	jmp    801063bb <alltraps>

80107420 <vector236>:
.globl vector236
vector236:
  pushl $0
80107420:	6a 00                	push   $0x0
  pushl $236
80107422:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107427:	e9 8f ef ff ff       	jmp    801063bb <alltraps>

8010742c <vector237>:
.globl vector237
vector237:
  pushl $0
8010742c:	6a 00                	push   $0x0
  pushl $237
8010742e:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107433:	e9 83 ef ff ff       	jmp    801063bb <alltraps>

80107438 <vector238>:
.globl vector238
vector238:
  pushl $0
80107438:	6a 00                	push   $0x0
  pushl $238
8010743a:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010743f:	e9 77 ef ff ff       	jmp    801063bb <alltraps>

80107444 <vector239>:
.globl vector239
vector239:
  pushl $0
80107444:	6a 00                	push   $0x0
  pushl $239
80107446:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010744b:	e9 6b ef ff ff       	jmp    801063bb <alltraps>

80107450 <vector240>:
.globl vector240
vector240:
  pushl $0
80107450:	6a 00                	push   $0x0
  pushl $240
80107452:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107457:	e9 5f ef ff ff       	jmp    801063bb <alltraps>

8010745c <vector241>:
.globl vector241
vector241:
  pushl $0
8010745c:	6a 00                	push   $0x0
  pushl $241
8010745e:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107463:	e9 53 ef ff ff       	jmp    801063bb <alltraps>

80107468 <vector242>:
.globl vector242
vector242:
  pushl $0
80107468:	6a 00                	push   $0x0
  pushl $242
8010746a:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010746f:	e9 47 ef ff ff       	jmp    801063bb <alltraps>

80107474 <vector243>:
.globl vector243
vector243:
  pushl $0
80107474:	6a 00                	push   $0x0
  pushl $243
80107476:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010747b:	e9 3b ef ff ff       	jmp    801063bb <alltraps>

80107480 <vector244>:
.globl vector244
vector244:
  pushl $0
80107480:	6a 00                	push   $0x0
  pushl $244
80107482:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107487:	e9 2f ef ff ff       	jmp    801063bb <alltraps>

8010748c <vector245>:
.globl vector245
vector245:
  pushl $0
8010748c:	6a 00                	push   $0x0
  pushl $245
8010748e:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107493:	e9 23 ef ff ff       	jmp    801063bb <alltraps>

80107498 <vector246>:
.globl vector246
vector246:
  pushl $0
80107498:	6a 00                	push   $0x0
  pushl $246
8010749a:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010749f:	e9 17 ef ff ff       	jmp    801063bb <alltraps>

801074a4 <vector247>:
.globl vector247
vector247:
  pushl $0
801074a4:	6a 00                	push   $0x0
  pushl $247
801074a6:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801074ab:	e9 0b ef ff ff       	jmp    801063bb <alltraps>

801074b0 <vector248>:
.globl vector248
vector248:
  pushl $0
801074b0:	6a 00                	push   $0x0
  pushl $248
801074b2:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801074b7:	e9 ff ee ff ff       	jmp    801063bb <alltraps>

801074bc <vector249>:
.globl vector249
vector249:
  pushl $0
801074bc:	6a 00                	push   $0x0
  pushl $249
801074be:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801074c3:	e9 f3 ee ff ff       	jmp    801063bb <alltraps>

801074c8 <vector250>:
.globl vector250
vector250:
  pushl $0
801074c8:	6a 00                	push   $0x0
  pushl $250
801074ca:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801074cf:	e9 e7 ee ff ff       	jmp    801063bb <alltraps>

801074d4 <vector251>:
.globl vector251
vector251:
  pushl $0
801074d4:	6a 00                	push   $0x0
  pushl $251
801074d6:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801074db:	e9 db ee ff ff       	jmp    801063bb <alltraps>

801074e0 <vector252>:
.globl vector252
vector252:
  pushl $0
801074e0:	6a 00                	push   $0x0
  pushl $252
801074e2:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801074e7:	e9 cf ee ff ff       	jmp    801063bb <alltraps>

801074ec <vector253>:
.globl vector253
vector253:
  pushl $0
801074ec:	6a 00                	push   $0x0
  pushl $253
801074ee:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801074f3:	e9 c3 ee ff ff       	jmp    801063bb <alltraps>

801074f8 <vector254>:
.globl vector254
vector254:
  pushl $0
801074f8:	6a 00                	push   $0x0
  pushl $254
801074fa:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801074ff:	e9 b7 ee ff ff       	jmp    801063bb <alltraps>

80107504 <vector255>:
.globl vector255
vector255:
  pushl $0
80107504:	6a 00                	push   $0x0
  pushl $255
80107506:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
8010750b:	e9 ab ee ff ff       	jmp    801063bb <alltraps>

80107510 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107510:	55                   	push   %ebp
80107511:	89 e5                	mov    %esp,%ebp
80107513:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107516:	8b 45 0c             	mov    0xc(%ebp),%eax
80107519:	83 e8 01             	sub    $0x1,%eax
8010751c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107520:	8b 45 08             	mov    0x8(%ebp),%eax
80107523:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107527:	8b 45 08             	mov    0x8(%ebp),%eax
8010752a:	c1 e8 10             	shr    $0x10,%eax
8010752d:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107531:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107534:	0f 01 10             	lgdtl  (%eax)
}
80107537:	c9                   	leave  
80107538:	c3                   	ret    

80107539 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107539:	55                   	push   %ebp
8010753a:	89 e5                	mov    %esp,%ebp
8010753c:	83 ec 04             	sub    $0x4,%esp
8010753f:	8b 45 08             	mov    0x8(%ebp),%eax
80107542:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107546:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010754a:	0f 00 d8             	ltr    %ax
}
8010754d:	c9                   	leave  
8010754e:	c3                   	ret    

8010754f <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
8010754f:	55                   	push   %ebp
80107550:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107552:	8b 45 08             	mov    0x8(%ebp),%eax
80107555:	0f 22 d8             	mov    %eax,%cr3
}
80107558:	5d                   	pop    %ebp
80107559:	c3                   	ret    

8010755a <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010755a:	55                   	push   %ebp
8010755b:	89 e5                	mov    %esp,%ebp
8010755d:	83 ec 28             	sub    $0x28,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107560:	e8 4d cb ff ff       	call   801040b2 <cpuid>
80107565:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010756b:	05 00 38 11 80       	add    $0x80113800,%eax
80107570:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107573:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107576:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010757c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010757f:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107585:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107588:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010758c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010758f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107593:	83 e2 f0             	and    $0xfffffff0,%edx
80107596:	83 ca 0a             	or     $0xa,%edx
80107599:	88 50 7d             	mov    %dl,0x7d(%eax)
8010759c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010759f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801075a3:	83 ca 10             	or     $0x10,%edx
801075a6:	88 50 7d             	mov    %dl,0x7d(%eax)
801075a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ac:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801075b0:	83 e2 9f             	and    $0xffffff9f,%edx
801075b3:	88 50 7d             	mov    %dl,0x7d(%eax)
801075b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801075bd:	83 ca 80             	or     $0xffffff80,%edx
801075c0:	88 50 7d             	mov    %dl,0x7d(%eax)
801075c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c6:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075ca:	83 ca 0f             	or     $0xf,%edx
801075cd:	88 50 7e             	mov    %dl,0x7e(%eax)
801075d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d3:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075d7:	83 e2 ef             	and    $0xffffffef,%edx
801075da:	88 50 7e             	mov    %dl,0x7e(%eax)
801075dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e0:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075e4:	83 e2 df             	and    $0xffffffdf,%edx
801075e7:	88 50 7e             	mov    %dl,0x7e(%eax)
801075ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ed:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075f1:	83 ca 40             	or     $0x40,%edx
801075f4:	88 50 7e             	mov    %dl,0x7e(%eax)
801075f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075fa:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075fe:	83 ca 80             	or     $0xffffff80,%edx
80107601:	88 50 7e             	mov    %dl,0x7e(%eax)
80107604:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107607:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010760b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010760e:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107615:	ff ff 
80107617:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010761a:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107621:	00 00 
80107623:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107626:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010762d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107630:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107637:	83 e2 f0             	and    $0xfffffff0,%edx
8010763a:	83 ca 02             	or     $0x2,%edx
8010763d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107643:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107646:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010764d:	83 ca 10             	or     $0x10,%edx
80107650:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107656:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107659:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107660:	83 e2 9f             	and    $0xffffff9f,%edx
80107663:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107669:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010766c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107673:	83 ca 80             	or     $0xffffff80,%edx
80107676:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010767c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010767f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107686:	83 ca 0f             	or     $0xf,%edx
80107689:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010768f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107692:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107699:	83 e2 ef             	and    $0xffffffef,%edx
8010769c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a5:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076ac:	83 e2 df             	and    $0xffffffdf,%edx
801076af:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b8:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076bf:	83 ca 40             	or     $0x40,%edx
801076c2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076cb:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076d2:	83 ca 80             	or     $0xffffff80,%edx
801076d5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076de:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801076e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e8:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801076ef:	ff ff 
801076f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f4:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801076fb:	00 00 
801076fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107700:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010770a:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107711:	83 e2 f0             	and    $0xfffffff0,%edx
80107714:	83 ca 0a             	or     $0xa,%edx
80107717:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010771d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107720:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107727:	83 ca 10             	or     $0x10,%edx
8010772a:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107730:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107733:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010773a:	83 ca 60             	or     $0x60,%edx
8010773d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107743:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107746:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010774d:	83 ca 80             	or     $0xffffff80,%edx
80107750:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107756:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107759:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107760:	83 ca 0f             	or     $0xf,%edx
80107763:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010776c:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107773:	83 e2 ef             	and    $0xffffffef,%edx
80107776:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010777c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010777f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107786:	83 e2 df             	and    $0xffffffdf,%edx
80107789:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010778f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107792:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107799:	83 ca 40             	or     $0x40,%edx
8010779c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801077a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a5:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801077ac:	83 ca 80             	or     $0xffffff80,%edx
801077af:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801077b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b8:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801077bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c2:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801077c9:	ff ff 
801077cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ce:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801077d5:	00 00 
801077d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077da:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801077e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e4:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801077eb:	83 e2 f0             	and    $0xfffffff0,%edx
801077ee:	83 ca 02             	or     $0x2,%edx
801077f1:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801077f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077fa:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107801:	83 ca 10             	or     $0x10,%edx
80107804:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010780a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010780d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107814:	83 ca 60             	or     $0x60,%edx
80107817:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010781d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107820:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107827:	83 ca 80             	or     $0xffffff80,%edx
8010782a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107833:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010783a:	83 ca 0f             	or     $0xf,%edx
8010783d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107843:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107846:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010784d:	83 e2 ef             	and    $0xffffffef,%edx
80107850:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107856:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107859:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107860:	83 e2 df             	and    $0xffffffdf,%edx
80107863:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107869:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010786c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107873:	83 ca 40             	or     $0x40,%edx
80107876:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010787c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107886:	83 ca 80             	or     $0xffffff80,%edx
80107889:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010788f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107892:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107899:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010789c:	83 c0 70             	add    $0x70,%eax
8010789f:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
801078a6:	00 
801078a7:	89 04 24             	mov    %eax,(%esp)
801078aa:	e8 61 fc ff ff       	call   80107510 <lgdt>
}
801078af:	c9                   	leave  
801078b0:	c3                   	ret    

801078b1 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801078b1:	55                   	push   %ebp
801078b2:	89 e5                	mov    %esp,%ebp
801078b4:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801078b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801078ba:	c1 e8 16             	shr    $0x16,%eax
801078bd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801078c4:	8b 45 08             	mov    0x8(%ebp),%eax
801078c7:	01 d0                	add    %edx,%eax
801078c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801078cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078cf:	8b 00                	mov    (%eax),%eax
801078d1:	83 e0 01             	and    $0x1,%eax
801078d4:	85 c0                	test   %eax,%eax
801078d6:	74 14                	je     801078ec <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801078d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078db:	8b 00                	mov    (%eax),%eax
801078dd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078e2:	05 00 00 00 80       	add    $0x80000000,%eax
801078e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801078ea:	eb 48                	jmp    80107934 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801078ec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801078f0:	74 0e                	je     80107900 <walkpgdir+0x4f>
801078f2:	e8 95 b2 ff ff       	call   80102b8c <kalloc>
801078f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801078fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801078fe:	75 07                	jne    80107907 <walkpgdir+0x56>
      return 0;
80107900:	b8 00 00 00 00       	mov    $0x0,%eax
80107905:	eb 44                	jmp    8010794b <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107907:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010790e:	00 
8010790f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107916:	00 
80107917:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791a:	89 04 24             	mov    %eax,(%esp)
8010791d:	e8 ac d6 ff ff       	call   80104fce <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107922:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107925:	05 00 00 00 80       	add    $0x80000000,%eax
8010792a:	83 c8 07             	or     $0x7,%eax
8010792d:	89 c2                	mov    %eax,%edx
8010792f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107932:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107934:	8b 45 0c             	mov    0xc(%ebp),%eax
80107937:	c1 e8 0c             	shr    $0xc,%eax
8010793a:	25 ff 03 00 00       	and    $0x3ff,%eax
8010793f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107946:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107949:	01 d0                	add    %edx,%eax
}
8010794b:	c9                   	leave  
8010794c:	c3                   	ret    

8010794d <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010794d:	55                   	push   %ebp
8010794e:	89 e5                	mov    %esp,%ebp
80107950:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107953:	8b 45 0c             	mov    0xc(%ebp),%eax
80107956:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010795b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010795e:	8b 55 0c             	mov    0xc(%ebp),%edx
80107961:	8b 45 10             	mov    0x10(%ebp),%eax
80107964:	01 d0                	add    %edx,%eax
80107966:	83 e8 01             	sub    $0x1,%eax
80107969:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010796e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107971:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107978:	00 
80107979:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010797c:	89 44 24 04          	mov    %eax,0x4(%esp)
80107980:	8b 45 08             	mov    0x8(%ebp),%eax
80107983:	89 04 24             	mov    %eax,(%esp)
80107986:	e8 26 ff ff ff       	call   801078b1 <walkpgdir>
8010798b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010798e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107992:	75 07                	jne    8010799b <mappages+0x4e>
      return -1;
80107994:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107999:	eb 48                	jmp    801079e3 <mappages+0x96>
    if(*pte & PTE_P)
8010799b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010799e:	8b 00                	mov    (%eax),%eax
801079a0:	83 e0 01             	and    $0x1,%eax
801079a3:	85 c0                	test   %eax,%eax
801079a5:	74 0c                	je     801079b3 <mappages+0x66>
      panic("remap");
801079a7:	c7 04 24 9c 8a 10 80 	movl   $0x80108a9c,(%esp)
801079ae:	e8 af 8b ff ff       	call   80100562 <panic>
    *pte = pa | perm | PTE_P;
801079b3:	8b 45 18             	mov    0x18(%ebp),%eax
801079b6:	0b 45 14             	or     0x14(%ebp),%eax
801079b9:	83 c8 01             	or     $0x1,%eax
801079bc:	89 c2                	mov    %eax,%edx
801079be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801079c1:	89 10                	mov    %edx,(%eax)
    if(a == last)
801079c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801079c9:	75 08                	jne    801079d3 <mappages+0x86>
      break;
801079cb:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801079cc:	b8 00 00 00 00       	mov    $0x0,%eax
801079d1:	eb 10                	jmp    801079e3 <mappages+0x96>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
801079d3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801079da:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801079e1:	eb 8e                	jmp    80107971 <mappages+0x24>
  return 0;
}
801079e3:	c9                   	leave  
801079e4:	c3                   	ret    

801079e5 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801079e5:	55                   	push   %ebp
801079e6:	89 e5                	mov    %esp,%ebp
801079e8:	53                   	push   %ebx
801079e9:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801079ec:	e8 9b b1 ff ff       	call   80102b8c <kalloc>
801079f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801079f4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801079f8:	75 0a                	jne    80107a04 <setupkvm+0x1f>
    return 0;
801079fa:	b8 00 00 00 00       	mov    $0x0,%eax
801079ff:	e9 84 00 00 00       	jmp    80107a88 <setupkvm+0xa3>
  memset(pgdir, 0, PGSIZE);
80107a04:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107a0b:	00 
80107a0c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107a13:	00 
80107a14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a17:	89 04 24             	mov    %eax,(%esp)
80107a1a:	e8 af d5 ff ff       	call   80104fce <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107a1f:	c7 45 f4 80 b4 10 80 	movl   $0x8010b480,-0xc(%ebp)
80107a26:	eb 54                	jmp    80107a7c <setupkvm+0x97>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a2b:	8b 48 0c             	mov    0xc(%eax),%ecx
80107a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a31:	8b 50 04             	mov    0x4(%eax),%edx
80107a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a37:	8b 58 08             	mov    0x8(%eax),%ebx
80107a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a3d:	8b 40 04             	mov    0x4(%eax),%eax
80107a40:	29 c3                	sub    %eax,%ebx
80107a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a45:	8b 00                	mov    (%eax),%eax
80107a47:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107a4b:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107a4f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107a53:	89 44 24 04          	mov    %eax,0x4(%esp)
80107a57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a5a:	89 04 24             	mov    %eax,(%esp)
80107a5d:	e8 eb fe ff ff       	call   8010794d <mappages>
80107a62:	85 c0                	test   %eax,%eax
80107a64:	79 12                	jns    80107a78 <setupkvm+0x93>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
80107a66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a69:	89 04 24             	mov    %eax,(%esp)
80107a6c:	e8 26 05 00 00       	call   80107f97 <freevm>
      return 0;
80107a71:	b8 00 00 00 00       	mov    $0x0,%eax
80107a76:	eb 10                	jmp    80107a88 <setupkvm+0xa3>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107a78:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107a7c:	81 7d f4 c0 b4 10 80 	cmpl   $0x8010b4c0,-0xc(%ebp)
80107a83:	72 a3                	jb     80107a28 <setupkvm+0x43>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
80107a85:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107a88:	83 c4 34             	add    $0x34,%esp
80107a8b:	5b                   	pop    %ebx
80107a8c:	5d                   	pop    %ebp
80107a8d:	c3                   	ret    

80107a8e <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107a8e:	55                   	push   %ebp
80107a8f:	89 e5                	mov    %esp,%ebp
80107a91:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107a94:	e8 4c ff ff ff       	call   801079e5 <setupkvm>
80107a99:	a3 24 66 11 80       	mov    %eax,0x80116624
  switchkvm();
80107a9e:	e8 02 00 00 00       	call   80107aa5 <switchkvm>
}
80107aa3:	c9                   	leave  
80107aa4:	c3                   	ret    

80107aa5 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107aa5:	55                   	push   %ebp
80107aa6:	89 e5                	mov    %esp,%ebp
80107aa8:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107aab:	a1 24 66 11 80       	mov    0x80116624,%eax
80107ab0:	05 00 00 00 80       	add    $0x80000000,%eax
80107ab5:	89 04 24             	mov    %eax,(%esp)
80107ab8:	e8 92 fa ff ff       	call   8010754f <lcr3>
}
80107abd:	c9                   	leave  
80107abe:	c3                   	ret    

80107abf <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107abf:	55                   	push   %ebp
80107ac0:	89 e5                	mov    %esp,%ebp
80107ac2:	57                   	push   %edi
80107ac3:	56                   	push   %esi
80107ac4:	53                   	push   %ebx
80107ac5:	83 ec 1c             	sub    $0x1c,%esp
  if(p == 0)
80107ac8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107acc:	75 0c                	jne    80107ada <switchuvm+0x1b>
    panic("switchuvm: no process");
80107ace:	c7 04 24 a2 8a 10 80 	movl   $0x80108aa2,(%esp)
80107ad5:	e8 88 8a ff ff       	call   80100562 <panic>
  if(p->kstack == 0)
80107ada:	8b 45 08             	mov    0x8(%ebp),%eax
80107add:	8b 40 0c             	mov    0xc(%eax),%eax
80107ae0:	85 c0                	test   %eax,%eax
80107ae2:	75 0c                	jne    80107af0 <switchuvm+0x31>
    panic("switchuvm: no kstack");
80107ae4:	c7 04 24 b8 8a 10 80 	movl   $0x80108ab8,(%esp)
80107aeb:	e8 72 8a ff ff       	call   80100562 <panic>
  if(p->pgdir == 0)
80107af0:	8b 45 08             	mov    0x8(%ebp),%eax
80107af3:	8b 40 08             	mov    0x8(%eax),%eax
80107af6:	85 c0                	test   %eax,%eax
80107af8:	75 0c                	jne    80107b06 <switchuvm+0x47>
    panic("switchuvm: no pgdir");
80107afa:	c7 04 24 cd 8a 10 80 	movl   $0x80108acd,(%esp)
80107b01:	e8 5c 8a ff ff       	call   80100562 <panic>

  pushcli();
80107b06:	e8 be d3 ff ff       	call   80104ec9 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107b0b:	e8 c3 c5 ff ff       	call   801040d3 <mycpu>
80107b10:	89 c3                	mov    %eax,%ebx
80107b12:	e8 bc c5 ff ff       	call   801040d3 <mycpu>
80107b17:	83 c0 08             	add    $0x8,%eax
80107b1a:	89 c7                	mov    %eax,%edi
80107b1c:	e8 b2 c5 ff ff       	call   801040d3 <mycpu>
80107b21:	83 c0 08             	add    $0x8,%eax
80107b24:	c1 e8 10             	shr    $0x10,%eax
80107b27:	89 c6                	mov    %eax,%esi
80107b29:	e8 a5 c5 ff ff       	call   801040d3 <mycpu>
80107b2e:	83 c0 08             	add    $0x8,%eax
80107b31:	c1 e8 18             	shr    $0x18,%eax
80107b34:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107b3b:	67 00 
80107b3d:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80107b44:	89 f1                	mov    %esi,%ecx
80107b46:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80107b4c:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80107b53:	83 e2 f0             	and    $0xfffffff0,%edx
80107b56:	83 ca 09             	or     $0x9,%edx
80107b59:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107b5f:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80107b66:	83 ca 10             	or     $0x10,%edx
80107b69:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107b6f:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80107b76:	83 e2 9f             	and    $0xffffff9f,%edx
80107b79:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107b7f:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80107b86:	83 ca 80             	or     $0xffffff80,%edx
80107b89:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107b8f:	0f b6 93 9e 00 00 00 	movzbl 0x9e(%ebx),%edx
80107b96:	83 e2 f0             	and    $0xfffffff0,%edx
80107b99:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107b9f:	0f b6 93 9e 00 00 00 	movzbl 0x9e(%ebx),%edx
80107ba6:	83 e2 ef             	and    $0xffffffef,%edx
80107ba9:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107baf:	0f b6 93 9e 00 00 00 	movzbl 0x9e(%ebx),%edx
80107bb6:	83 e2 df             	and    $0xffffffdf,%edx
80107bb9:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107bbf:	0f b6 93 9e 00 00 00 	movzbl 0x9e(%ebx),%edx
80107bc6:	83 ca 40             	or     $0x40,%edx
80107bc9:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107bcf:	0f b6 93 9e 00 00 00 	movzbl 0x9e(%ebx),%edx
80107bd6:	83 e2 7f             	and    $0x7f,%edx
80107bd9:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107bdf:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107be5:	e8 e9 c4 ff ff       	call   801040d3 <mycpu>
80107bea:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107bf1:	83 e2 ef             	and    $0xffffffef,%edx
80107bf4:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107bfa:	e8 d4 c4 ff ff       	call   801040d3 <mycpu>
80107bff:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107c05:	e8 c9 c4 ff ff       	call   801040d3 <mycpu>
80107c0a:	8b 55 08             	mov    0x8(%ebp),%edx
80107c0d:	8b 52 0c             	mov    0xc(%edx),%edx
80107c10:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107c16:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107c19:	e8 b5 c4 ff ff       	call   801040d3 <mycpu>
80107c1e:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107c24:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
80107c2b:	e8 09 f9 ff ff       	call   80107539 <ltr>
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107c30:	8b 45 08             	mov    0x8(%ebp),%eax
80107c33:	8b 40 08             	mov    0x8(%eax),%eax
80107c36:	05 00 00 00 80       	add    $0x80000000,%eax
80107c3b:	89 04 24             	mov    %eax,(%esp)
80107c3e:	e8 0c f9 ff ff       	call   8010754f <lcr3>
  popcli();
80107c43:	e8 cd d2 ff ff       	call   80104f15 <popcli>
}
80107c48:	83 c4 1c             	add    $0x1c,%esp
80107c4b:	5b                   	pop    %ebx
80107c4c:	5e                   	pop    %esi
80107c4d:	5f                   	pop    %edi
80107c4e:	5d                   	pop    %ebp
80107c4f:	c3                   	ret    

80107c50 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107c50:	55                   	push   %ebp
80107c51:	89 e5                	mov    %esp,%ebp
80107c53:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
80107c56:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107c5d:	76 0c                	jbe    80107c6b <inituvm+0x1b>
    panic("inituvm: more than a page");
80107c5f:	c7 04 24 e1 8a 10 80 	movl   $0x80108ae1,(%esp)
80107c66:	e8 f7 88 ff ff       	call   80100562 <panic>
  mem = kalloc();
80107c6b:	e8 1c af ff ff       	call   80102b8c <kalloc>
80107c70:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107c73:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107c7a:	00 
80107c7b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107c82:	00 
80107c83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c86:	89 04 24             	mov    %eax,(%esp)
80107c89:	e8 40 d3 ff ff       	call   80104fce <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c91:	05 00 00 00 80       	add    $0x80000000,%eax
80107c96:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107c9d:	00 
80107c9e:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107ca2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107ca9:	00 
80107caa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107cb1:	00 
80107cb2:	8b 45 08             	mov    0x8(%ebp),%eax
80107cb5:	89 04 24             	mov    %eax,(%esp)
80107cb8:	e8 90 fc ff ff       	call   8010794d <mappages>
  memmove(mem, init, sz);
80107cbd:	8b 45 10             	mov    0x10(%ebp),%eax
80107cc0:	89 44 24 08          	mov    %eax,0x8(%esp)
80107cc4:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cc7:	89 44 24 04          	mov    %eax,0x4(%esp)
80107ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cce:	89 04 24             	mov    %eax,(%esp)
80107cd1:	e8 c7 d3 ff ff       	call   8010509d <memmove>
}
80107cd6:	c9                   	leave  
80107cd7:	c3                   	ret    

80107cd8 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107cd8:	55                   	push   %ebp
80107cd9:	89 e5                	mov    %esp,%ebp
80107cdb:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107cde:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ce1:	25 ff 0f 00 00       	and    $0xfff,%eax
80107ce6:	85 c0                	test   %eax,%eax
80107ce8:	74 0c                	je     80107cf6 <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
80107cea:	c7 04 24 fc 8a 10 80 	movl   $0x80108afc,(%esp)
80107cf1:	e8 6c 88 ff ff       	call   80100562 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107cf6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107cfd:	e9 a6 00 00 00       	jmp    80107da8 <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d05:	8b 55 0c             	mov    0xc(%ebp),%edx
80107d08:	01 d0                	add    %edx,%eax
80107d0a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107d11:	00 
80107d12:	89 44 24 04          	mov    %eax,0x4(%esp)
80107d16:	8b 45 08             	mov    0x8(%ebp),%eax
80107d19:	89 04 24             	mov    %eax,(%esp)
80107d1c:	e8 90 fb ff ff       	call   801078b1 <walkpgdir>
80107d21:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107d24:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d28:	75 0c                	jne    80107d36 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80107d2a:	c7 04 24 1f 8b 10 80 	movl   $0x80108b1f,(%esp)
80107d31:	e8 2c 88 ff ff       	call   80100562 <panic>
    pa = PTE_ADDR(*pte);
80107d36:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d39:	8b 00                	mov    (%eax),%eax
80107d3b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d40:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d46:	8b 55 18             	mov    0x18(%ebp),%edx
80107d49:	29 c2                	sub    %eax,%edx
80107d4b:	89 d0                	mov    %edx,%eax
80107d4d:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107d52:	77 0f                	ja     80107d63 <loaduvm+0x8b>
      n = sz - i;
80107d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d57:	8b 55 18             	mov    0x18(%ebp),%edx
80107d5a:	29 c2                	sub    %eax,%edx
80107d5c:	89 d0                	mov    %edx,%eax
80107d5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107d61:	eb 07                	jmp    80107d6a <loaduvm+0x92>
    else
      n = PGSIZE;
80107d63:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107d6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6d:	8b 55 14             	mov    0x14(%ebp),%edx
80107d70:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80107d73:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107d76:	05 00 00 00 80       	add    $0x80000000,%eax
80107d7b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107d7e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107d82:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80107d86:	89 44 24 04          	mov    %eax,0x4(%esp)
80107d8a:	8b 45 10             	mov    0x10(%ebp),%eax
80107d8d:	89 04 24             	mov    %eax,(%esp)
80107d90:	e8 48 a0 ff ff       	call   80101ddd <readi>
80107d95:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107d98:	74 07                	je     80107da1 <loaduvm+0xc9>
      return -1;
80107d9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d9f:	eb 18                	jmp    80107db9 <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80107da1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107da8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dab:	3b 45 18             	cmp    0x18(%ebp),%eax
80107dae:	0f 82 4e ff ff ff    	jb     80107d02 <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80107db4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107db9:	c9                   	leave  
80107dba:	c3                   	ret    

80107dbb <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107dbb:	55                   	push   %ebp
80107dbc:	89 e5                	mov    %esp,%ebp
80107dbe:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107dc1:	8b 45 10             	mov    0x10(%ebp),%eax
80107dc4:	85 c0                	test   %eax,%eax
80107dc6:	79 0a                	jns    80107dd2 <allocuvm+0x17>
    return 0;
80107dc8:	b8 00 00 00 00       	mov    $0x0,%eax
80107dcd:	e9 fd 00 00 00       	jmp    80107ecf <allocuvm+0x114>
  if(newsz < oldsz)
80107dd2:	8b 45 10             	mov    0x10(%ebp),%eax
80107dd5:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107dd8:	73 08                	jae    80107de2 <allocuvm+0x27>
    return oldsz;
80107dda:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ddd:	e9 ed 00 00 00       	jmp    80107ecf <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
80107de2:	8b 45 0c             	mov    0xc(%ebp),%eax
80107de5:	05 ff 0f 00 00       	add    $0xfff,%eax
80107dea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107def:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107df2:	e9 c9 00 00 00       	jmp    80107ec0 <allocuvm+0x105>
    mem = kalloc();
80107df7:	e8 90 ad ff ff       	call   80102b8c <kalloc>
80107dfc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107dff:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e03:	75 2f                	jne    80107e34 <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
80107e05:	c7 04 24 3d 8b 10 80 	movl   $0x80108b3d,(%esp)
80107e0c:	e8 b7 85 ff ff       	call   801003c8 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80107e11:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e14:	89 44 24 08          	mov    %eax,0x8(%esp)
80107e18:	8b 45 10             	mov    0x10(%ebp),%eax
80107e1b:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e1f:	8b 45 08             	mov    0x8(%ebp),%eax
80107e22:	89 04 24             	mov    %eax,(%esp)
80107e25:	e8 a7 00 00 00       	call   80107ed1 <deallocuvm>
      return 0;
80107e2a:	b8 00 00 00 00       	mov    $0x0,%eax
80107e2f:	e9 9b 00 00 00       	jmp    80107ecf <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
80107e34:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107e3b:	00 
80107e3c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107e43:	00 
80107e44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e47:	89 04 24             	mov    %eax,(%esp)
80107e4a:	e8 7f d1 ff ff       	call   80104fce <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107e4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e52:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107e58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5b:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107e62:	00 
80107e63:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107e67:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107e6e:	00 
80107e6f:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e73:	8b 45 08             	mov    0x8(%ebp),%eax
80107e76:	89 04 24             	mov    %eax,(%esp)
80107e79:	e8 cf fa ff ff       	call   8010794d <mappages>
80107e7e:	85 c0                	test   %eax,%eax
80107e80:	79 37                	jns    80107eb9 <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
80107e82:	c7 04 24 55 8b 10 80 	movl   $0x80108b55,(%esp)
80107e89:	e8 3a 85 ff ff       	call   801003c8 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80107e8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e91:	89 44 24 08          	mov    %eax,0x8(%esp)
80107e95:	8b 45 10             	mov    0x10(%ebp),%eax
80107e98:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e9c:	8b 45 08             	mov    0x8(%ebp),%eax
80107e9f:	89 04 24             	mov    %eax,(%esp)
80107ea2:	e8 2a 00 00 00       	call   80107ed1 <deallocuvm>
      kfree(mem);
80107ea7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107eaa:	89 04 24             	mov    %eax,(%esp)
80107ead:	e8 44 ac ff ff       	call   80102af6 <kfree>
      return 0;
80107eb2:	b8 00 00 00 00       	mov    $0x0,%eax
80107eb7:	eb 16                	jmp    80107ecf <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80107eb9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107ec0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec3:	3b 45 10             	cmp    0x10(%ebp),%eax
80107ec6:	0f 82 2b ff ff ff    	jb     80107df7 <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
80107ecc:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107ecf:	c9                   	leave  
80107ed0:	c3                   	ret    

80107ed1 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107ed1:	55                   	push   %ebp
80107ed2:	89 e5                	mov    %esp,%ebp
80107ed4:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107ed7:	8b 45 10             	mov    0x10(%ebp),%eax
80107eda:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107edd:	72 08                	jb     80107ee7 <deallocuvm+0x16>
    return oldsz;
80107edf:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ee2:	e9 ae 00 00 00       	jmp    80107f95 <deallocuvm+0xc4>

  a = PGROUNDUP(newsz);
80107ee7:	8b 45 10             	mov    0x10(%ebp),%eax
80107eea:	05 ff 0f 00 00       	add    $0xfff,%eax
80107eef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ef4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107ef7:	e9 8a 00 00 00       	jmp    80107f86 <deallocuvm+0xb5>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107f06:	00 
80107f07:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f0b:	8b 45 08             	mov    0x8(%ebp),%eax
80107f0e:	89 04 24             	mov    %eax,(%esp)
80107f11:	e8 9b f9 ff ff       	call   801078b1 <walkpgdir>
80107f16:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107f19:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f1d:	75 16                	jne    80107f35 <deallocuvm+0x64>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107f1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f22:	c1 e8 16             	shr    $0x16,%eax
80107f25:	83 c0 01             	add    $0x1,%eax
80107f28:	c1 e0 16             	shl    $0x16,%eax
80107f2b:	2d 00 10 00 00       	sub    $0x1000,%eax
80107f30:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f33:	eb 4a                	jmp    80107f7f <deallocuvm+0xae>
    else if((*pte & PTE_P) != 0){
80107f35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f38:	8b 00                	mov    (%eax),%eax
80107f3a:	83 e0 01             	and    $0x1,%eax
80107f3d:	85 c0                	test   %eax,%eax
80107f3f:	74 3e                	je     80107f7f <deallocuvm+0xae>
      pa = PTE_ADDR(*pte);
80107f41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f44:	8b 00                	mov    (%eax),%eax
80107f46:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107f4e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f52:	75 0c                	jne    80107f60 <deallocuvm+0x8f>
        panic("kfree");
80107f54:	c7 04 24 71 8b 10 80 	movl   $0x80108b71,(%esp)
80107f5b:	e8 02 86 ff ff       	call   80100562 <panic>
      char *v = P2V(pa);
80107f60:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f63:	05 00 00 00 80       	add    $0x80000000,%eax
80107f68:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107f6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107f6e:	89 04 24             	mov    %eax,(%esp)
80107f71:	e8 80 ab ff ff       	call   80102af6 <kfree>
      *pte = 0;
80107f76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f79:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80107f7f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f89:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f8c:	0f 82 6a ff ff ff    	jb     80107efc <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80107f92:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107f95:	c9                   	leave  
80107f96:	c3                   	ret    

80107f97 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107f97:	55                   	push   %ebp
80107f98:	89 e5                	mov    %esp,%ebp
80107f9a:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80107f9d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107fa1:	75 0c                	jne    80107faf <freevm+0x18>
    panic("freevm: no pgdir");
80107fa3:	c7 04 24 77 8b 10 80 	movl   $0x80108b77,(%esp)
80107faa:	e8 b3 85 ff ff       	call   80100562 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107faf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107fb6:	00 
80107fb7:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80107fbe:	80 
80107fbf:	8b 45 08             	mov    0x8(%ebp),%eax
80107fc2:	89 04 24             	mov    %eax,(%esp)
80107fc5:	e8 07 ff ff ff       	call   80107ed1 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80107fca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107fd1:	eb 45                	jmp    80108018 <freevm+0x81>
    if(pgdir[i] & PTE_P){
80107fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107fdd:	8b 45 08             	mov    0x8(%ebp),%eax
80107fe0:	01 d0                	add    %edx,%eax
80107fe2:	8b 00                	mov    (%eax),%eax
80107fe4:	83 e0 01             	and    $0x1,%eax
80107fe7:	85 c0                	test   %eax,%eax
80107fe9:	74 29                	je     80108014 <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107feb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ff5:	8b 45 08             	mov    0x8(%ebp),%eax
80107ff8:	01 d0                	add    %edx,%eax
80107ffa:	8b 00                	mov    (%eax),%eax
80107ffc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108001:	05 00 00 00 80       	add    $0x80000000,%eax
80108006:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108009:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010800c:	89 04 24             	mov    %eax,(%esp)
8010800f:	e8 e2 aa ff ff       	call   80102af6 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108014:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108018:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010801f:	76 b2                	jbe    80107fd3 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108021:	8b 45 08             	mov    0x8(%ebp),%eax
80108024:	89 04 24             	mov    %eax,(%esp)
80108027:	e8 ca aa ff ff       	call   80102af6 <kfree>
}
8010802c:	c9                   	leave  
8010802d:	c3                   	ret    

8010802e <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010802e:	55                   	push   %ebp
8010802f:	89 e5                	mov    %esp,%ebp
80108031:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108034:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010803b:	00 
8010803c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010803f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108043:	8b 45 08             	mov    0x8(%ebp),%eax
80108046:	89 04 24             	mov    %eax,(%esp)
80108049:	e8 63 f8 ff ff       	call   801078b1 <walkpgdir>
8010804e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108051:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108055:	75 0c                	jne    80108063 <clearpteu+0x35>
    panic("clearpteu");
80108057:	c7 04 24 88 8b 10 80 	movl   $0x80108b88,(%esp)
8010805e:	e8 ff 84 ff ff       	call   80100562 <panic>
  *pte &= ~PTE_U;
80108063:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108066:	8b 00                	mov    (%eax),%eax
80108068:	83 e0 fb             	and    $0xfffffffb,%eax
8010806b:	89 c2                	mov    %eax,%edx
8010806d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108070:	89 10                	mov    %edx,(%eax)
}
80108072:	c9                   	leave  
80108073:	c3                   	ret    

80108074 <copyuvm>:
// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
//CS153 -- added
copyuvm(pde_t *pgdir, uint sz, uint sp) //uint sp is STACKTOP
{
80108074:	55                   	push   %ebp
80108075:	89 e5                	mov    %esp,%ebp
80108077:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010807a:	e8 66 f9 ff ff       	call   801079e5 <setupkvm>
8010807f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108082:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108086:	75 0a                	jne    80108092 <copyuvm+0x1e>
    return 0;
80108088:	b8 00 00 00 00       	mov    $0x0,%eax
8010808d:	e9 e6 01 00 00       	jmp    80108278 <copyuvm+0x204>
  for(i = 0; i < sz; i += PGSIZE){
80108092:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108099:	e9 d1 00 00 00       	jmp    8010816f <copyuvm+0xfb>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010809e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801080a8:	00 
801080a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801080ad:	8b 45 08             	mov    0x8(%ebp),%eax
801080b0:	89 04 24             	mov    %eax,(%esp)
801080b3:	e8 f9 f7 ff ff       	call   801078b1 <walkpgdir>
801080b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
801080bb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801080bf:	75 0c                	jne    801080cd <copyuvm+0x59>
      panic("copyuvm: pte should exist");
801080c1:	c7 04 24 92 8b 10 80 	movl   $0x80108b92,(%esp)
801080c8:	e8 95 84 ff ff       	call   80100562 <panic>
    if(!(*pte & PTE_P))
801080cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080d0:	8b 00                	mov    (%eax),%eax
801080d2:	83 e0 01             	and    $0x1,%eax
801080d5:	85 c0                	test   %eax,%eax
801080d7:	75 0c                	jne    801080e5 <copyuvm+0x71>
      panic("copyuvm: page not present");
801080d9:	c7 04 24 ac 8b 10 80 	movl   $0x80108bac,(%esp)
801080e0:	e8 7d 84 ff ff       	call   80100562 <panic>
    pa = PTE_ADDR(*pte);
801080e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080e8:	8b 00                	mov    (%eax),%eax
801080ea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080ef:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801080f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080f5:	8b 00                	mov    (%eax),%eax
801080f7:	25 ff 0f 00 00       	and    $0xfff,%eax
801080fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801080ff:	e8 88 aa ff ff       	call   80102b8c <kalloc>
80108104:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108107:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010810b:	75 05                	jne    80108112 <copyuvm+0x9e>
      goto bad;
8010810d:	e9 56 01 00 00       	jmp    80108268 <copyuvm+0x1f4>
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108112:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108115:	05 00 00 00 80       	add    $0x80000000,%eax
8010811a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108121:	00 
80108122:	89 44 24 04          	mov    %eax,0x4(%esp)
80108126:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108129:	89 04 24             	mov    %eax,(%esp)
8010812c:	e8 6c cf ff ff       	call   8010509d <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108131:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108134:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108137:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
8010813d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108140:	89 54 24 10          	mov    %edx,0x10(%esp)
80108144:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80108148:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010814f:	00 
80108150:	89 44 24 04          	mov    %eax,0x4(%esp)
80108154:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108157:	89 04 24             	mov    %eax,(%esp)
8010815a:	e8 ee f7 ff ff       	call   8010794d <mappages>
8010815f:	85 c0                	test   %eax,%eax
80108161:	79 05                	jns    80108168 <copyuvm+0xf4>
      goto bad;
80108163:	e9 00 01 00 00       	jmp    80108268 <copyuvm+0x1f4>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108168:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010816f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108172:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108175:	0f 82 23 ff ff ff    	jb     8010809e <copyuvm+0x2a>
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  //CS153 -- added 
  for(i = PGROUNDDOWN(sp); i < STACKTOP; i += PGSIZE){
8010817b:	8b 45 10             	mov    0x10(%ebp),%eax
8010817e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108183:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108186:	e9 cb 00 00 00       	jmp    80108256 <copyuvm+0x1e2>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010818b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010818e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108195:	00 
80108196:	89 44 24 04          	mov    %eax,0x4(%esp)
8010819a:	8b 45 08             	mov    0x8(%ebp),%eax
8010819d:	89 04 24             	mov    %eax,(%esp)
801081a0:	e8 0c f7 ff ff       	call   801078b1 <walkpgdir>
801081a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
801081a8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801081ac:	75 0c                	jne    801081ba <copyuvm+0x146>
      panic("copyuvm: pte should exist");
801081ae:	c7 04 24 92 8b 10 80 	movl   $0x80108b92,(%esp)
801081b5:	e8 a8 83 ff ff       	call   80100562 <panic>
    if(!(*pte & PTE_P))
801081ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081bd:	8b 00                	mov    (%eax),%eax
801081bf:	83 e0 01             	and    $0x1,%eax
801081c2:	85 c0                	test   %eax,%eax
801081c4:	75 0c                	jne    801081d2 <copyuvm+0x15e>
      panic("copyuvm: page not present");
801081c6:	c7 04 24 ac 8b 10 80 	movl   $0x80108bac,(%esp)
801081cd:	e8 90 83 ff ff       	call   80100562 <panic>
    pa = PTE_ADDR(*pte);
801081d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081d5:	8b 00                	mov    (%eax),%eax
801081d7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081dc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801081df:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081e2:	8b 00                	mov    (%eax),%eax
801081e4:	25 ff 0f 00 00       	and    $0xfff,%eax
801081e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801081ec:	e8 9b a9 ff ff       	call   80102b8c <kalloc>
801081f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
801081f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801081f8:	75 02                	jne    801081fc <copyuvm+0x188>
      goto bad;
801081fa:	eb 6c                	jmp    80108268 <copyuvm+0x1f4>
    memmove(mem, (char*)P2V(pa), PGSIZE);
801081fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801081ff:	05 00 00 00 80       	add    $0x80000000,%eax
80108204:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010820b:	00 
8010820c:	89 44 24 04          	mov    %eax,0x4(%esp)
80108210:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108213:	89 04 24             	mov    %eax,(%esp)
80108216:	e8 82 ce ff ff       	call   8010509d <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
8010821b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010821e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108221:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108227:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010822a:	89 54 24 10          	mov    %edx,0x10(%esp)
8010822e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80108232:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108239:	00 
8010823a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010823e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108241:	89 04 24             	mov    %eax,(%esp)
80108244:	e8 04 f7 ff ff       	call   8010794d <mappages>
80108249:	85 c0                	test   %eax,%eax
8010824b:	79 02                	jns    8010824f <copyuvm+0x1db>
      goto bad;
8010824d:	eb 19                	jmp    80108268 <copyuvm+0x1f4>
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  //CS153 -- added 
  for(i = PGROUNDDOWN(sp); i < STACKTOP; i += PGSIZE){
8010824f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108256:	81 7d f4 fe ff ff 7f 	cmpl   $0x7ffffffe,-0xc(%ebp)
8010825d:	0f 86 28 ff ff ff    	jbe    8010818b <copyuvm+0x117>
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }

  return d;
80108263:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108266:	eb 10                	jmp    80108278 <copyuvm+0x204>

bad:
  freevm(d);
80108268:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010826b:	89 04 24             	mov    %eax,(%esp)
8010826e:	e8 24 fd ff ff       	call   80107f97 <freevm>
  return 0;
80108273:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108278:	c9                   	leave  
80108279:	c3                   	ret    

8010827a <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010827a:	55                   	push   %ebp
8010827b:	89 e5                	mov    %esp,%ebp
8010827d:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108280:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108287:	00 
80108288:	8b 45 0c             	mov    0xc(%ebp),%eax
8010828b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010828f:	8b 45 08             	mov    0x8(%ebp),%eax
80108292:	89 04 24             	mov    %eax,(%esp)
80108295:	e8 17 f6 ff ff       	call   801078b1 <walkpgdir>
8010829a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010829d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082a0:	8b 00                	mov    (%eax),%eax
801082a2:	83 e0 01             	and    $0x1,%eax
801082a5:	85 c0                	test   %eax,%eax
801082a7:	75 07                	jne    801082b0 <uva2ka+0x36>
    return 0;
801082a9:	b8 00 00 00 00       	mov    $0x0,%eax
801082ae:	eb 22                	jmp    801082d2 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
801082b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082b3:	8b 00                	mov    (%eax),%eax
801082b5:	83 e0 04             	and    $0x4,%eax
801082b8:	85 c0                	test   %eax,%eax
801082ba:	75 07                	jne    801082c3 <uva2ka+0x49>
    return 0;
801082bc:	b8 00 00 00 00       	mov    $0x0,%eax
801082c1:	eb 0f                	jmp    801082d2 <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
801082c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082c6:	8b 00                	mov    (%eax),%eax
801082c8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082cd:	05 00 00 00 80       	add    $0x80000000,%eax
}
801082d2:	c9                   	leave  
801082d3:	c3                   	ret    

801082d4 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801082d4:	55                   	push   %ebp
801082d5:	89 e5                	mov    %esp,%ebp
801082d7:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801082da:	8b 45 10             	mov    0x10(%ebp),%eax
801082dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801082e0:	e9 87 00 00 00       	jmp    8010836c <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
801082e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801082e8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801082f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801082f7:	8b 45 08             	mov    0x8(%ebp),%eax
801082fa:	89 04 24             	mov    %eax,(%esp)
801082fd:	e8 78 ff ff ff       	call   8010827a <uva2ka>
80108302:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108305:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108309:	75 07                	jne    80108312 <copyout+0x3e>
      return -1;
8010830b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108310:	eb 69                	jmp    8010837b <copyout+0xa7>
    n = PGSIZE - (va - va0);
80108312:	8b 45 0c             	mov    0xc(%ebp),%eax
80108315:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108318:	29 c2                	sub    %eax,%edx
8010831a:	89 d0                	mov    %edx,%eax
8010831c:	05 00 10 00 00       	add    $0x1000,%eax
80108321:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108324:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108327:	3b 45 14             	cmp    0x14(%ebp),%eax
8010832a:	76 06                	jbe    80108332 <copyout+0x5e>
      n = len;
8010832c:	8b 45 14             	mov    0x14(%ebp),%eax
8010832f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108332:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108335:	8b 55 0c             	mov    0xc(%ebp),%edx
80108338:	29 c2                	sub    %eax,%edx
8010833a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010833d:	01 c2                	add    %eax,%edx
8010833f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108342:	89 44 24 08          	mov    %eax,0x8(%esp)
80108346:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108349:	89 44 24 04          	mov    %eax,0x4(%esp)
8010834d:	89 14 24             	mov    %edx,(%esp)
80108350:	e8 48 cd ff ff       	call   8010509d <memmove>
    len -= n;
80108355:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108358:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010835b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010835e:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108361:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108364:	05 00 10 00 00       	add    $0x1000,%eax
80108369:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010836c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108370:	0f 85 6f ff ff ff    	jne    801082e5 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108376:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010837b:	c9                   	leave  
8010837c:	c3                   	ret    

8010837d <shminit>:
    char *frame;
    int refcnt;
  } shm_pages[64];
} shm_table;

void shminit() {
8010837d:	55                   	push   %ebp
8010837e:	89 e5                	mov    %esp,%ebp
80108380:	83 ec 28             	sub    $0x28,%esp
  int i;
  initlock(&(shm_table.lock), "SHM lock");
80108383:	c7 44 24 04 c6 8b 10 	movl   $0x80108bc6,0x4(%esp)
8010838a:	80 
8010838b:	c7 04 24 40 66 11 80 	movl   $0x80116640,(%esp)
80108392:	e8 b4 c9 ff ff       	call   80104d4b <initlock>
  acquire(&(shm_table.lock));
80108397:	c7 04 24 40 66 11 80 	movl   $0x80116640,(%esp)
8010839e:	e8 c9 c9 ff ff       	call   80104d6c <acquire>
  for (i = 0; i< 64; i++) {
801083a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083aa:	eb 49                	jmp    801083f5 <shminit+0x78>
    shm_table.shm_pages[i].id =0;
801083ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801083af:	89 d0                	mov    %edx,%eax
801083b1:	01 c0                	add    %eax,%eax
801083b3:	01 d0                	add    %edx,%eax
801083b5:	c1 e0 02             	shl    $0x2,%eax
801083b8:	05 74 66 11 80       	add    $0x80116674,%eax
801083bd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    shm_table.shm_pages[i].frame =0;
801083c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801083c6:	89 d0                	mov    %edx,%eax
801083c8:	01 c0                	add    %eax,%eax
801083ca:	01 d0                	add    %edx,%eax
801083cc:	c1 e0 02             	shl    $0x2,%eax
801083cf:	05 78 66 11 80       	add    $0x80116678,%eax
801083d4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    shm_table.shm_pages[i].refcnt =0;
801083da:	8b 55 f4             	mov    -0xc(%ebp),%edx
801083dd:	89 d0                	mov    %edx,%eax
801083df:	01 c0                	add    %eax,%eax
801083e1:	01 d0                	add    %edx,%eax
801083e3:	c1 e0 02             	shl    $0x2,%eax
801083e6:	05 7c 66 11 80       	add    $0x8011667c,%eax
801083eb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

void shminit() {
  int i;
  initlock(&(shm_table.lock), "SHM lock");
  acquire(&(shm_table.lock));
  for (i = 0; i< 64; i++) {
801083f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801083f5:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801083f9:	7e b1                	jle    801083ac <shminit+0x2f>
    shm_table.shm_pages[i].id =0;
    shm_table.shm_pages[i].frame =0;
    shm_table.shm_pages[i].refcnt =0;
  }
  release(&(shm_table.lock));
801083fb:	c7 04 24 40 66 11 80 	movl   $0x80116640,(%esp)
80108402:	e8 cd c9 ff ff       	call   80104dd4 <release>
}
80108407:	c9                   	leave  
80108408:	c3                   	ret    

80108409 <shm_open>:

int shm_open(int id, char **pointer) {
80108409:	55                   	push   %ebp
8010840a:	89 e5                	mov    %esp,%ebp
//you write this




return 0; //added to remove compiler warning -- you should decide what to return
8010840c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108411:	5d                   	pop    %ebp
80108412:	c3                   	ret    

80108413 <shm_close>:


int shm_close(int id) {
80108413:	55                   	push   %ebp
80108414:	89 e5                	mov    %esp,%ebp
//you write this too!




return 0; //added to remove compiler warning -- you should decide what to return
80108416:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010841b:	5d                   	pop    %ebp
8010841c:	c3                   	ret    
