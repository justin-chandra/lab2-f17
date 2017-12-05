
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
8010002d:	b8 60 37 10 80       	mov    $0x80103760,%eax
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
8010003a:	c7 44 24 04 18 85 10 	movl   $0x80108518,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 40 c6 10 80 	movl   $0x8010c640,(%esp)
80100049:	e8 06 4d 00 00       	call   80104d54 <initlock>

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
80100087:	c7 44 24 04 1f 85 10 	movl   $0x8010851f,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 81 4b 00 00       	call   80104c18 <initsleeplock>
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
801000c9:	e8 a7 4c 00 00       	call   80104d75 <acquire>

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
80100104:	e8 d4 4c 00 00       	call   80104ddd <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 3b 4b 00 00       	call   80104c52 <acquiresleep>
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
8010017d:	e8 5b 4c 00 00       	call   80104ddd <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 c2 4a 00 00       	call   80104c52 <acquiresleep>
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
801001a7:	c7 04 24 26 85 10 80 	movl   $0x80108526,(%esp)
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
801001e2:	e8 90 26 00 00       	call   80102877 <iderw>
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
801001fb:	e8 ef 4a 00 00       	call   80104cef <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 37 85 10 80 	movl   $0x80108537,(%esp)
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
80100225:	e8 4d 26 00 00       	call   80102877 <iderw>
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
8010023b:	e8 af 4a 00 00       	call   80104cef <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 3e 85 10 80 	movl   $0x8010853e,(%esp)
8010024b:	e8 12 03 00 00       	call   80100562 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 4f 4a 00 00       	call   80104cad <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 40 c6 10 80 	movl   $0x8010c640,(%esp)
80100265:	e8 0b 4b 00 00       	call   80104d75 <acquire>
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
801002d1:	e8 07 4b 00 00       	call   80104ddd <release>
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
801003e3:	e8 8d 49 00 00       	call   80104d75 <acquire>

  if (fmt == 0)
801003e8:	8b 45 08             	mov    0x8(%ebp),%eax
801003eb:	85 c0                	test   %eax,%eax
801003ed:	75 0c                	jne    801003fb <cprintf+0x33>
    panic("null fmt");
801003ef:	c7 04 24 45 85 10 80 	movl   $0x80108545,(%esp)
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
801004d8:	c7 45 ec 4e 85 10 80 	movl   $0x8010854e,-0x14(%ebp)
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
8010055b:	e8 7d 48 00 00       	call   80104ddd <release>
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
80100577:	e8 9f 29 00 00       	call   80102f1b <lapicid>
8010057c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100580:	c7 04 24 55 85 10 80 	movl   $0x80108555,(%esp)
80100587:	e8 3c fe ff ff       	call   801003c8 <cprintf>
  cprintf(s);
8010058c:	8b 45 08             	mov    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 31 fe ff ff       	call   801003c8 <cprintf>
  cprintf("\n");
80100597:	c7 04 24 69 85 10 80 	movl   $0x80108569,(%esp)
8010059e:	e8 25 fe ff ff       	call   801003c8 <cprintf>
  getcallerpcs(&s, pcs);
801005a3:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801005aa:	8d 45 08             	lea    0x8(%ebp),%eax
801005ad:	89 04 24             	mov    %eax,(%esp)
801005b0:	e8 73 48 00 00       	call   80104e28 <getcallerpcs>
  for(i=0; i<10; i++)
801005b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005bc:	eb 1b                	jmp    801005d9 <panic+0x77>
    cprintf(" %p", pcs[i]);
801005be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005c1:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801005c9:	c7 04 24 6b 85 10 80 	movl   $0x8010856b,(%esp)
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
801006ba:	c7 04 24 6f 85 10 80 	movl   $0x8010856f,(%esp)
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
801006ee:	e8 b3 49 00 00       	call   801050a6 <memmove>
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
8010071d:	e8 b5 48 00 00       	call   80104fd7 <memset>
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
801007b2:	e8 3a 62 00 00       	call   801069f1 <uartputc>
801007b7:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801007be:	e8 2e 62 00 00       	call   801069f1 <uartputc>
801007c3:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007ca:	e8 22 62 00 00       	call   801069f1 <uartputc>
801007cf:	eb 0b                	jmp    801007dc <consputc+0x50>
  } else
    uartputc(c);
801007d1:	8b 45 08             	mov    0x8(%ebp),%eax
801007d4:	89 04 24             	mov    %eax,(%esp)
801007d7:	e8 15 62 00 00       	call   801069f1 <uartputc>
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
801007fd:	e8 73 45 00 00       	call   80104d75 <acquire>
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
80100938:	e8 41 41 00 00       	call   80104a7e <wakeup>
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
80100959:	e8 7f 44 00 00       	call   80104ddd <release>
  if(doprocdump) {
8010095e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100962:	74 05                	je     80100969 <consoleintr+0x180>
    procdump();  // now call procdump() wo. cons.lock held
80100964:	e8 b8 41 00 00       	call   80104b21 <procdump>
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
80100977:	e8 da 10 00 00       	call   80101a56 <iunlock>
  target = n;
8010097c:	8b 45 10             	mov    0x10(%ebp),%eax
8010097f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100982:	c7 04 24 a0 b5 10 80 	movl   $0x8010b5a0,(%esp)
80100989:	e8 e7 43 00 00       	call   80104d75 <acquire>
  while(n > 0){
8010098e:	e9 a9 00 00 00       	jmp    80100a3c <consoleread+0xd1>
    while(input.r == input.w){
80100993:	eb 41                	jmp    801009d6 <consoleread+0x6b>
      if(myproc()->killed){
80100995:	e8 b8 37 00 00       	call   80104152 <myproc>
8010099a:	8b 40 28             	mov    0x28(%eax),%eax
8010099d:	85 c0                	test   %eax,%eax
8010099f:	74 21                	je     801009c2 <consoleread+0x57>
        release(&cons.lock);
801009a1:	c7 04 24 a0 b5 10 80 	movl   $0x8010b5a0,(%esp)
801009a8:	e8 30 44 00 00       	call   80104ddd <release>
        ilock(ip);
801009ad:	8b 45 08             	mov    0x8(%ebp),%eax
801009b0:	89 04 24             	mov    %eax,(%esp)
801009b3:	e8 91 0f 00 00       	call   80101949 <ilock>
        return -1;
801009b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009bd:	e9 a5 00 00 00       	jmp    80100a67 <consoleread+0xfc>
      }
      sleep(&input.r, &cons.lock);
801009c2:	c7 44 24 04 a0 b5 10 	movl   $0x8010b5a0,0x4(%esp)
801009c9:	80 
801009ca:	c7 04 24 20 10 11 80 	movl   $0x80111020,(%esp)
801009d1:	e8 d4 3f 00 00       	call   801049aa <sleep>

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
80100a4d:	e8 8b 43 00 00       	call   80104ddd <release>
  ilock(ip);
80100a52:	8b 45 08             	mov    0x8(%ebp),%eax
80100a55:	89 04 24             	mov    %eax,(%esp)
80100a58:	e8 ec 0e 00 00       	call   80101949 <ilock>

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
80100a75:	e8 dc 0f 00 00       	call   80101a56 <iunlock>
  acquire(&cons.lock);
80100a7a:	c7 04 24 a0 b5 10 80 	movl   $0x8010b5a0,(%esp)
80100a81:	e8 ef 42 00 00       	call   80104d75 <acquire>
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
80100abb:	e8 1d 43 00 00       	call   80104ddd <release>
  ilock(ip);
80100ac0:	8b 45 08             	mov    0x8(%ebp),%eax
80100ac3:	89 04 24             	mov    %eax,(%esp)
80100ac6:	e8 7e 0e 00 00       	call   80101949 <ilock>

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
80100ad6:	c7 44 24 04 82 85 10 	movl   $0x80108582,0x4(%esp)
80100add:	80 
80100ade:	c7 04 24 a0 b5 10 80 	movl   $0x8010b5a0,(%esp)
80100ae5:	e8 6a 42 00 00       	call   80104d54 <initlock>

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
80100b17:	e8 0f 1f 00 00       	call   80102a2b <ioapicenable>
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
80100b27:	e8 26 36 00 00       	call   80104152 <myproc>
80100b2c:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b2f:	e8 3f 29 00 00       	call   80103473 <begin_op>

  if((ip = namei(path)) == 0){
80100b34:	8b 45 08             	mov    0x8(%ebp),%eax
80100b37:	89 04 24             	mov    %eax,(%esp)
80100b3a:	e8 44 19 00 00       	call   80102483 <namei>
80100b3f:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b42:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b46:	75 1b                	jne    80100b63 <exec+0x45>
    end_op();
80100b48:	e8 aa 29 00 00       	call   801034f7 <end_op>
    cprintf("exec: fail\n");
80100b4d:	c7 04 24 8a 85 10 80 	movl   $0x8010858a,(%esp)
80100b54:	e8 6f f8 ff ff       	call   801003c8 <cprintf>
    return -1;
80100b59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b5e:	e9 f0 03 00 00       	jmp    80100f53 <exec+0x435>
  }
  ilock(ip);
80100b63:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b66:	89 04 24             	mov    %eax,(%esp)
80100b69:	e8 db 0d 00 00       	call   80101949 <ilock>
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
80100b95:	e8 4c 12 00 00       	call   80101de6 <readi>
80100b9a:	83 f8 34             	cmp    $0x34,%eax
80100b9d:	74 05                	je     80100ba4 <exec+0x86>
    goto bad;
80100b9f:	e9 83 03 00 00       	jmp    80100f27 <exec+0x409>
  if(elf.magic != ELF_MAGIC)
80100ba4:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100baa:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100baf:	74 05                	je     80100bb6 <exec+0x98>
    goto bad;
80100bb1:	e9 71 03 00 00       	jmp    80100f27 <exec+0x409>

  if((pgdir = setupkvm()) == 0)
80100bb6:	e8 33 6e 00 00       	call   801079ee <setupkvm>
80100bbb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bbe:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100bc2:	75 05                	jne    80100bc9 <exec+0xab>
    goto bad;
80100bc4:	e9 5e 03 00 00       	jmp    80100f27 <exec+0x409>

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
80100c04:	e8 dd 11 00 00       	call   80101de6 <readi>
80100c09:	83 f8 20             	cmp    $0x20,%eax
80100c0c:	74 05                	je     80100c13 <exec+0xf5>
      goto bad;
80100c0e:	e9 14 03 00 00       	jmp    80100f27 <exec+0x409>
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
80100c33:	e9 ef 02 00 00       	jmp    80100f27 <exec+0x409>
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c38:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c3e:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c44:	01 c2                	add    %eax,%edx
80100c46:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c4c:	39 c2                	cmp    %eax,%edx
80100c4e:	73 05                	jae    80100c55 <exec+0x137>
      goto bad;
80100c50:	e9 d2 02 00 00       	jmp    80100f27 <exec+0x409>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c55:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c5b:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c61:	01 d0                	add    %edx,%eax
80100c63:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c67:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c6a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c6e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c71:	89 04 24             	mov    %eax,(%esp)
80100c74:	e8 4b 71 00 00       	call   80107dc4 <allocuvm>
80100c79:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c7c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c80:	75 05                	jne    80100c87 <exec+0x169>
      goto bad;
80100c82:	e9 a0 02 00 00       	jmp    80100f27 <exec+0x409>
    if(ph.vaddr % PGSIZE != 0)
80100c87:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c8d:	25 ff 0f 00 00       	and    $0xfff,%eax
80100c92:	85 c0                	test   %eax,%eax
80100c94:	74 05                	je     80100c9b <exec+0x17d>
      goto bad;
80100c96:	e9 8c 02 00 00       	jmp    80100f27 <exec+0x409>
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
80100cc6:	e8 16 70 00 00       	call   80107ce1 <loaduvm>
80100ccb:	85 c0                	test   %eax,%eax
80100ccd:	79 05                	jns    80100cd4 <exec+0x1b6>
      goto bad;
80100ccf:	e9 53 02 00 00       	jmp    80100f27 <exec+0x409>
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
80100cfa:	e8 4c 0e 00 00       	call   80101b4b <iunlockput>
  end_op();
80100cff:	e8 f3 27 00 00       	call   801034f7 <end_op>
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
80100d31:	e8 8e 70 00 00       	call   80107dc4 <allocuvm>
80100d36:	85 c0                	test   %eax,%eax
80100d38:	75 05                	jne    80100d3f <exec+0x221>
    goto bad;
80100d3a:	e9 e8 01 00 00       	jmp    80100f27 <exec+0x409>
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
80100d58:	e9 ca 01 00 00       	jmp    80100f27 <exec+0x409>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d60:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d67:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d6a:	01 d0                	add    %edx,%eax
80100d6c:	8b 00                	mov    (%eax),%eax
80100d6e:	89 04 24             	mov    %eax,(%esp)
80100d71:	e8 cb 44 00 00       	call   80105241 <strlen>
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
80100d9a:	e8 a2 44 00 00       	call   80105241 <strlen>
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
80100dca:	e8 0e 75 00 00       	call   801082dd <copyout>
80100dcf:	85 c0                	test   %eax,%eax
80100dd1:	79 05                	jns    80100dd8 <exec+0x2ba>
      goto bad;
80100dd3:	e9 4f 01 00 00       	jmp    80100f27 <exec+0x409>
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
80100e71:	e8 67 74 00 00       	call   801082dd <copyout>
80100e76:	85 c0                	test   %eax,%eax
80100e78:	79 05                	jns    80100e7f <exec+0x361>
    goto bad;
80100e7a:	e9 a8 00 00 00       	jmp    80100f27 <exec+0x409>

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
80100ec6:	e8 2c 43 00 00       	call   801051f7 <safestrcpy>

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
80100f07:	e8 bc 6b 00 00       	call   80107ac8 <switchuvm>
  freevm(oldpgdir);
80100f0c:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100f0f:	89 04 24             	mov    %eax,(%esp)
80100f12:	e8 89 70 00 00       	call   80107fa0 <freevm>
  curproc->pages = 1;
80100f17:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f1a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  return 0;
80100f20:	b8 00 00 00 00       	mov    $0x0,%eax
80100f25:	eb 2c                	jmp    80100f53 <exec+0x435>

 bad:
  if(pgdir)
80100f27:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f2b:	74 0b                	je     80100f38 <exec+0x41a>
    freevm(pgdir);
80100f2d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f30:	89 04 24             	mov    %eax,(%esp)
80100f33:	e8 68 70 00 00       	call   80107fa0 <freevm>
  if(ip){
80100f38:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f3c:	74 10                	je     80100f4e <exec+0x430>
    iunlockput(ip);
80100f3e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f41:	89 04 24             	mov    %eax,(%esp)
80100f44:	e8 02 0c 00 00       	call   80101b4b <iunlockput>
    end_op();
80100f49:	e8 a9 25 00 00       	call   801034f7 <end_op>
  }
  return -1;
80100f4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f53:	c9                   	leave  
80100f54:	c3                   	ret    

80100f55 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f55:	55                   	push   %ebp
80100f56:	89 e5                	mov    %esp,%ebp
80100f58:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f5b:	c7 44 24 04 96 85 10 	movl   $0x80108596,0x4(%esp)
80100f62:	80 
80100f63:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
80100f6a:	e8 e5 3d 00 00       	call   80104d54 <initlock>
}
80100f6f:	c9                   	leave  
80100f70:	c3                   	ret    

80100f71 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f71:	55                   	push   %ebp
80100f72:	89 e5                	mov    %esp,%ebp
80100f74:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f77:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
80100f7e:	e8 f2 3d 00 00       	call   80104d75 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f83:	c7 45 f4 74 10 11 80 	movl   $0x80111074,-0xc(%ebp)
80100f8a:	eb 29                	jmp    80100fb5 <filealloc+0x44>
    if(f->ref == 0){
80100f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f8f:	8b 40 04             	mov    0x4(%eax),%eax
80100f92:	85 c0                	test   %eax,%eax
80100f94:	75 1b                	jne    80100fb1 <filealloc+0x40>
      f->ref = 1;
80100f96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f99:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100fa0:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
80100fa7:	e8 31 3e 00 00       	call   80104ddd <release>
      return f;
80100fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100faf:	eb 1e                	jmp    80100fcf <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fb1:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100fb5:	81 7d f4 d4 19 11 80 	cmpl   $0x801119d4,-0xc(%ebp)
80100fbc:	72 ce                	jb     80100f8c <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100fbe:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
80100fc5:	e8 13 3e 00 00       	call   80104ddd <release>
  return 0;
80100fca:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100fcf:	c9                   	leave  
80100fd0:	c3                   	ret    

80100fd1 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fd1:	55                   	push   %ebp
80100fd2:	89 e5                	mov    %esp,%ebp
80100fd4:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100fd7:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
80100fde:	e8 92 3d 00 00       	call   80104d75 <acquire>
  if(f->ref < 1)
80100fe3:	8b 45 08             	mov    0x8(%ebp),%eax
80100fe6:	8b 40 04             	mov    0x4(%eax),%eax
80100fe9:	85 c0                	test   %eax,%eax
80100feb:	7f 0c                	jg     80100ff9 <filedup+0x28>
    panic("filedup");
80100fed:	c7 04 24 9d 85 10 80 	movl   $0x8010859d,(%esp)
80100ff4:	e8 69 f5 ff ff       	call   80100562 <panic>
  f->ref++;
80100ff9:	8b 45 08             	mov    0x8(%ebp),%eax
80100ffc:	8b 40 04             	mov    0x4(%eax),%eax
80100fff:	8d 50 01             	lea    0x1(%eax),%edx
80101002:	8b 45 08             	mov    0x8(%ebp),%eax
80101005:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101008:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
8010100f:	e8 c9 3d 00 00       	call   80104ddd <release>
  return f;
80101014:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101017:	c9                   	leave  
80101018:	c3                   	ret    

80101019 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101019:	55                   	push   %ebp
8010101a:	89 e5                	mov    %esp,%ebp
8010101c:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
8010101f:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
80101026:	e8 4a 3d 00 00       	call   80104d75 <acquire>
  if(f->ref < 1)
8010102b:	8b 45 08             	mov    0x8(%ebp),%eax
8010102e:	8b 40 04             	mov    0x4(%eax),%eax
80101031:	85 c0                	test   %eax,%eax
80101033:	7f 0c                	jg     80101041 <fileclose+0x28>
    panic("fileclose");
80101035:	c7 04 24 a5 85 10 80 	movl   $0x801085a5,(%esp)
8010103c:	e8 21 f5 ff ff       	call   80100562 <panic>
  if(--f->ref > 0){
80101041:	8b 45 08             	mov    0x8(%ebp),%eax
80101044:	8b 40 04             	mov    0x4(%eax),%eax
80101047:	8d 50 ff             	lea    -0x1(%eax),%edx
8010104a:	8b 45 08             	mov    0x8(%ebp),%eax
8010104d:	89 50 04             	mov    %edx,0x4(%eax)
80101050:	8b 45 08             	mov    0x8(%ebp),%eax
80101053:	8b 40 04             	mov    0x4(%eax),%eax
80101056:	85 c0                	test   %eax,%eax
80101058:	7e 11                	jle    8010106b <fileclose+0x52>
    release(&ftable.lock);
8010105a:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
80101061:	e8 77 3d 00 00       	call   80104ddd <release>
80101066:	e9 82 00 00 00       	jmp    801010ed <fileclose+0xd4>
    return;
  }
  ff = *f;
8010106b:	8b 45 08             	mov    0x8(%ebp),%eax
8010106e:	8b 10                	mov    (%eax),%edx
80101070:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101073:	8b 50 04             	mov    0x4(%eax),%edx
80101076:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101079:	8b 50 08             	mov    0x8(%eax),%edx
8010107c:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010107f:	8b 50 0c             	mov    0xc(%eax),%edx
80101082:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101085:	8b 50 10             	mov    0x10(%eax),%edx
80101088:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010108b:	8b 40 14             	mov    0x14(%eax),%eax
8010108e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101091:	8b 45 08             	mov    0x8(%ebp),%eax
80101094:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010109b:	8b 45 08             	mov    0x8(%ebp),%eax
8010109e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801010a4:	c7 04 24 40 10 11 80 	movl   $0x80111040,(%esp)
801010ab:	e8 2d 3d 00 00       	call   80104ddd <release>

  if(ff.type == FD_PIPE)
801010b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010b3:	83 f8 01             	cmp    $0x1,%eax
801010b6:	75 18                	jne    801010d0 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
801010b8:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801010bc:	0f be d0             	movsbl %al,%edx
801010bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801010c2:	89 54 24 04          	mov    %edx,0x4(%esp)
801010c6:	89 04 24             	mov    %eax,(%esp)
801010c9:	e8 4b 2d 00 00       	call   80103e19 <pipeclose>
801010ce:	eb 1d                	jmp    801010ed <fileclose+0xd4>
  else if(ff.type == FD_INODE){
801010d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010d3:	83 f8 02             	cmp    $0x2,%eax
801010d6:	75 15                	jne    801010ed <fileclose+0xd4>
    begin_op();
801010d8:	e8 96 23 00 00       	call   80103473 <begin_op>
    iput(ff.ip);
801010dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801010e0:	89 04 24             	mov    %eax,(%esp)
801010e3:	e8 b2 09 00 00       	call   80101a9a <iput>
    end_op();
801010e8:	e8 0a 24 00 00       	call   801034f7 <end_op>
  }
}
801010ed:	c9                   	leave  
801010ee:	c3                   	ret    

801010ef <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010ef:	55                   	push   %ebp
801010f0:	89 e5                	mov    %esp,%ebp
801010f2:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801010f5:	8b 45 08             	mov    0x8(%ebp),%eax
801010f8:	8b 00                	mov    (%eax),%eax
801010fa:	83 f8 02             	cmp    $0x2,%eax
801010fd:	75 38                	jne    80101137 <filestat+0x48>
    ilock(f->ip);
801010ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101102:	8b 40 10             	mov    0x10(%eax),%eax
80101105:	89 04 24             	mov    %eax,(%esp)
80101108:	e8 3c 08 00 00       	call   80101949 <ilock>
    stati(f->ip, st);
8010110d:	8b 45 08             	mov    0x8(%ebp),%eax
80101110:	8b 40 10             	mov    0x10(%eax),%eax
80101113:	8b 55 0c             	mov    0xc(%ebp),%edx
80101116:	89 54 24 04          	mov    %edx,0x4(%esp)
8010111a:	89 04 24             	mov    %eax,(%esp)
8010111d:	e8 7f 0c 00 00       	call   80101da1 <stati>
    iunlock(f->ip);
80101122:	8b 45 08             	mov    0x8(%ebp),%eax
80101125:	8b 40 10             	mov    0x10(%eax),%eax
80101128:	89 04 24             	mov    %eax,(%esp)
8010112b:	e8 26 09 00 00       	call   80101a56 <iunlock>
    return 0;
80101130:	b8 00 00 00 00       	mov    $0x0,%eax
80101135:	eb 05                	jmp    8010113c <filestat+0x4d>
  }
  return -1;
80101137:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010113c:	c9                   	leave  
8010113d:	c3                   	ret    

8010113e <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010113e:	55                   	push   %ebp
8010113f:	89 e5                	mov    %esp,%ebp
80101141:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
80101144:	8b 45 08             	mov    0x8(%ebp),%eax
80101147:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010114b:	84 c0                	test   %al,%al
8010114d:	75 0a                	jne    80101159 <fileread+0x1b>
    return -1;
8010114f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101154:	e9 9f 00 00 00       	jmp    801011f8 <fileread+0xba>
  if(f->type == FD_PIPE)
80101159:	8b 45 08             	mov    0x8(%ebp),%eax
8010115c:	8b 00                	mov    (%eax),%eax
8010115e:	83 f8 01             	cmp    $0x1,%eax
80101161:	75 1e                	jne    80101181 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101163:	8b 45 08             	mov    0x8(%ebp),%eax
80101166:	8b 40 0c             	mov    0xc(%eax),%eax
80101169:	8b 55 10             	mov    0x10(%ebp),%edx
8010116c:	89 54 24 08          	mov    %edx,0x8(%esp)
80101170:	8b 55 0c             	mov    0xc(%ebp),%edx
80101173:	89 54 24 04          	mov    %edx,0x4(%esp)
80101177:	89 04 24             	mov    %eax,(%esp)
8010117a:	e8 1a 2e 00 00       	call   80103f99 <piperead>
8010117f:	eb 77                	jmp    801011f8 <fileread+0xba>
  if(f->type == FD_INODE){
80101181:	8b 45 08             	mov    0x8(%ebp),%eax
80101184:	8b 00                	mov    (%eax),%eax
80101186:	83 f8 02             	cmp    $0x2,%eax
80101189:	75 61                	jne    801011ec <fileread+0xae>
    ilock(f->ip);
8010118b:	8b 45 08             	mov    0x8(%ebp),%eax
8010118e:	8b 40 10             	mov    0x10(%eax),%eax
80101191:	89 04 24             	mov    %eax,(%esp)
80101194:	e8 b0 07 00 00       	call   80101949 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101199:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010119c:	8b 45 08             	mov    0x8(%ebp),%eax
8010119f:	8b 50 14             	mov    0x14(%eax),%edx
801011a2:	8b 45 08             	mov    0x8(%ebp),%eax
801011a5:	8b 40 10             	mov    0x10(%eax),%eax
801011a8:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801011ac:	89 54 24 08          	mov    %edx,0x8(%esp)
801011b0:	8b 55 0c             	mov    0xc(%ebp),%edx
801011b3:	89 54 24 04          	mov    %edx,0x4(%esp)
801011b7:	89 04 24             	mov    %eax,(%esp)
801011ba:	e8 27 0c 00 00       	call   80101de6 <readi>
801011bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801011c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801011c6:	7e 11                	jle    801011d9 <fileread+0x9b>
      f->off += r;
801011c8:	8b 45 08             	mov    0x8(%ebp),%eax
801011cb:	8b 50 14             	mov    0x14(%eax),%edx
801011ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011d1:	01 c2                	add    %eax,%edx
801011d3:	8b 45 08             	mov    0x8(%ebp),%eax
801011d6:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801011d9:	8b 45 08             	mov    0x8(%ebp),%eax
801011dc:	8b 40 10             	mov    0x10(%eax),%eax
801011df:	89 04 24             	mov    %eax,(%esp)
801011e2:	e8 6f 08 00 00       	call   80101a56 <iunlock>
    return r;
801011e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011ea:	eb 0c                	jmp    801011f8 <fileread+0xba>
  }
  panic("fileread");
801011ec:	c7 04 24 af 85 10 80 	movl   $0x801085af,(%esp)
801011f3:	e8 6a f3 ff ff       	call   80100562 <panic>
}
801011f8:	c9                   	leave  
801011f9:	c3                   	ret    

801011fa <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011fa:	55                   	push   %ebp
801011fb:	89 e5                	mov    %esp,%ebp
801011fd:	53                   	push   %ebx
801011fe:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
80101201:	8b 45 08             	mov    0x8(%ebp),%eax
80101204:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101208:	84 c0                	test   %al,%al
8010120a:	75 0a                	jne    80101216 <filewrite+0x1c>
    return -1;
8010120c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101211:	e9 20 01 00 00       	jmp    80101336 <filewrite+0x13c>
  if(f->type == FD_PIPE)
80101216:	8b 45 08             	mov    0x8(%ebp),%eax
80101219:	8b 00                	mov    (%eax),%eax
8010121b:	83 f8 01             	cmp    $0x1,%eax
8010121e:	75 21                	jne    80101241 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101220:	8b 45 08             	mov    0x8(%ebp),%eax
80101223:	8b 40 0c             	mov    0xc(%eax),%eax
80101226:	8b 55 10             	mov    0x10(%ebp),%edx
80101229:	89 54 24 08          	mov    %edx,0x8(%esp)
8010122d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101230:	89 54 24 04          	mov    %edx,0x4(%esp)
80101234:	89 04 24             	mov    %eax,(%esp)
80101237:	e8 6f 2c 00 00       	call   80103eab <pipewrite>
8010123c:	e9 f5 00 00 00       	jmp    80101336 <filewrite+0x13c>
  if(f->type == FD_INODE){
80101241:	8b 45 08             	mov    0x8(%ebp),%eax
80101244:	8b 00                	mov    (%eax),%eax
80101246:	83 f8 02             	cmp    $0x2,%eax
80101249:	0f 85 db 00 00 00    	jne    8010132a <filewrite+0x130>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010124f:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101256:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010125d:	e9 a8 00 00 00       	jmp    8010130a <filewrite+0x110>
      int n1 = n - i;
80101262:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101265:	8b 55 10             	mov    0x10(%ebp),%edx
80101268:	29 c2                	sub    %eax,%edx
8010126a:	89 d0                	mov    %edx,%eax
8010126c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010126f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101272:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101275:	7e 06                	jle    8010127d <filewrite+0x83>
        n1 = max;
80101277:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010127a:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010127d:	e8 f1 21 00 00       	call   80103473 <begin_op>
      ilock(f->ip);
80101282:	8b 45 08             	mov    0x8(%ebp),%eax
80101285:	8b 40 10             	mov    0x10(%eax),%eax
80101288:	89 04 24             	mov    %eax,(%esp)
8010128b:	e8 b9 06 00 00       	call   80101949 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101290:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101293:	8b 45 08             	mov    0x8(%ebp),%eax
80101296:	8b 50 14             	mov    0x14(%eax),%edx
80101299:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010129c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010129f:	01 c3                	add    %eax,%ebx
801012a1:	8b 45 08             	mov    0x8(%ebp),%eax
801012a4:	8b 40 10             	mov    0x10(%eax),%eax
801012a7:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801012ab:	89 54 24 08          	mov    %edx,0x8(%esp)
801012af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
801012b3:	89 04 24             	mov    %eax,(%esp)
801012b6:	e8 8f 0c 00 00       	call   80101f4a <writei>
801012bb:	89 45 e8             	mov    %eax,-0x18(%ebp)
801012be:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012c2:	7e 11                	jle    801012d5 <filewrite+0xdb>
        f->off += r;
801012c4:	8b 45 08             	mov    0x8(%ebp),%eax
801012c7:	8b 50 14             	mov    0x14(%eax),%edx
801012ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012cd:	01 c2                	add    %eax,%edx
801012cf:	8b 45 08             	mov    0x8(%ebp),%eax
801012d2:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801012d5:	8b 45 08             	mov    0x8(%ebp),%eax
801012d8:	8b 40 10             	mov    0x10(%eax),%eax
801012db:	89 04 24             	mov    %eax,(%esp)
801012de:	e8 73 07 00 00       	call   80101a56 <iunlock>
      end_op();
801012e3:	e8 0f 22 00 00       	call   801034f7 <end_op>

      if(r < 0)
801012e8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012ec:	79 02                	jns    801012f0 <filewrite+0xf6>
        break;
801012ee:	eb 26                	jmp    80101316 <filewrite+0x11c>
      if(r != n1)
801012f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012f3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801012f6:	74 0c                	je     80101304 <filewrite+0x10a>
        panic("short filewrite");
801012f8:	c7 04 24 b8 85 10 80 	movl   $0x801085b8,(%esp)
801012ff:	e8 5e f2 ff ff       	call   80100562 <panic>
      i += r;
80101304:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101307:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
8010130a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010130d:	3b 45 10             	cmp    0x10(%ebp),%eax
80101310:	0f 8c 4c ff ff ff    	jl     80101262 <filewrite+0x68>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101316:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101319:	3b 45 10             	cmp    0x10(%ebp),%eax
8010131c:	75 05                	jne    80101323 <filewrite+0x129>
8010131e:	8b 45 10             	mov    0x10(%ebp),%eax
80101321:	eb 05                	jmp    80101328 <filewrite+0x12e>
80101323:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101328:	eb 0c                	jmp    80101336 <filewrite+0x13c>
  }
  panic("filewrite");
8010132a:	c7 04 24 c8 85 10 80 	movl   $0x801085c8,(%esp)
80101331:	e8 2c f2 ff ff       	call   80100562 <panic>
}
80101336:	83 c4 24             	add    $0x24,%esp
80101339:	5b                   	pop    %ebx
8010133a:	5d                   	pop    %ebp
8010133b:	c3                   	ret    

8010133c <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010133c:	55                   	push   %ebp
8010133d:	89 e5                	mov    %esp,%ebp
8010133f:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, 1);
80101342:	8b 45 08             	mov    0x8(%ebp),%eax
80101345:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010134c:	00 
8010134d:	89 04 24             	mov    %eax,(%esp)
80101350:	e8 60 ee ff ff       	call   801001b5 <bread>
80101355:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101358:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010135b:	83 c0 5c             	add    $0x5c,%eax
8010135e:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
80101365:	00 
80101366:	89 44 24 04          	mov    %eax,0x4(%esp)
8010136a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010136d:	89 04 24             	mov    %eax,(%esp)
80101370:	e8 31 3d 00 00       	call   801050a6 <memmove>
  brelse(bp);
80101375:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101378:	89 04 24             	mov    %eax,(%esp)
8010137b:	e8 ac ee ff ff       	call   8010022c <brelse>
}
80101380:	c9                   	leave  
80101381:	c3                   	ret    

80101382 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101382:	55                   	push   %ebp
80101383:	89 e5                	mov    %esp,%ebp
80101385:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101388:	8b 55 0c             	mov    0xc(%ebp),%edx
8010138b:	8b 45 08             	mov    0x8(%ebp),%eax
8010138e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101392:	89 04 24             	mov    %eax,(%esp)
80101395:	e8 1b ee ff ff       	call   801001b5 <bread>
8010139a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010139d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013a0:	83 c0 5c             	add    $0x5c,%eax
801013a3:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801013aa:	00 
801013ab:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801013b2:	00 
801013b3:	89 04 24             	mov    %eax,(%esp)
801013b6:	e8 1c 3c 00 00       	call   80104fd7 <memset>
  log_write(bp);
801013bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013be:	89 04 24             	mov    %eax,(%esp)
801013c1:	e8 b8 22 00 00       	call   8010367e <log_write>
  brelse(bp);
801013c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013c9:	89 04 24             	mov    %eax,(%esp)
801013cc:	e8 5b ee ff ff       	call   8010022c <brelse>
}
801013d1:	c9                   	leave  
801013d2:	c3                   	ret    

801013d3 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801013d3:	55                   	push   %ebp
801013d4:	89 e5                	mov    %esp,%ebp
801013d6:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801013d9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801013e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013e7:	e9 07 01 00 00       	jmp    801014f3 <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
801013ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ef:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801013f5:	85 c0                	test   %eax,%eax
801013f7:	0f 48 c2             	cmovs  %edx,%eax
801013fa:	c1 f8 0c             	sar    $0xc,%eax
801013fd:	89 c2                	mov    %eax,%edx
801013ff:	a1 58 1a 11 80       	mov    0x80111a58,%eax
80101404:	01 d0                	add    %edx,%eax
80101406:	89 44 24 04          	mov    %eax,0x4(%esp)
8010140a:	8b 45 08             	mov    0x8(%ebp),%eax
8010140d:	89 04 24             	mov    %eax,(%esp)
80101410:	e8 a0 ed ff ff       	call   801001b5 <bread>
80101415:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101418:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010141f:	e9 9d 00 00 00       	jmp    801014c1 <balloc+0xee>
      m = 1 << (bi % 8);
80101424:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101427:	99                   	cltd   
80101428:	c1 ea 1d             	shr    $0x1d,%edx
8010142b:	01 d0                	add    %edx,%eax
8010142d:	83 e0 07             	and    $0x7,%eax
80101430:	29 d0                	sub    %edx,%eax
80101432:	ba 01 00 00 00       	mov    $0x1,%edx
80101437:	89 c1                	mov    %eax,%ecx
80101439:	d3 e2                	shl    %cl,%edx
8010143b:	89 d0                	mov    %edx,%eax
8010143d:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101440:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101443:	8d 50 07             	lea    0x7(%eax),%edx
80101446:	85 c0                	test   %eax,%eax
80101448:	0f 48 c2             	cmovs  %edx,%eax
8010144b:	c1 f8 03             	sar    $0x3,%eax
8010144e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101451:	0f b6 44 02 5c       	movzbl 0x5c(%edx,%eax,1),%eax
80101456:	0f b6 c0             	movzbl %al,%eax
80101459:	23 45 e8             	and    -0x18(%ebp),%eax
8010145c:	85 c0                	test   %eax,%eax
8010145e:	75 5d                	jne    801014bd <balloc+0xea>
        bp->data[bi/8] |= m;  // Mark block in use.
80101460:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101463:	8d 50 07             	lea    0x7(%eax),%edx
80101466:	85 c0                	test   %eax,%eax
80101468:	0f 48 c2             	cmovs  %edx,%eax
8010146b:	c1 f8 03             	sar    $0x3,%eax
8010146e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101471:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101476:	89 d1                	mov    %edx,%ecx
80101478:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010147b:	09 ca                	or     %ecx,%edx
8010147d:	89 d1                	mov    %edx,%ecx
8010147f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101482:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101486:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101489:	89 04 24             	mov    %eax,(%esp)
8010148c:	e8 ed 21 00 00       	call   8010367e <log_write>
        brelse(bp);
80101491:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101494:	89 04 24             	mov    %eax,(%esp)
80101497:	e8 90 ed ff ff       	call   8010022c <brelse>
        bzero(dev, b + bi);
8010149c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010149f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014a2:	01 c2                	add    %eax,%edx
801014a4:	8b 45 08             	mov    0x8(%ebp),%eax
801014a7:	89 54 24 04          	mov    %edx,0x4(%esp)
801014ab:	89 04 24             	mov    %eax,(%esp)
801014ae:	e8 cf fe ff ff       	call   80101382 <bzero>
        return b + bi;
801014b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014b9:	01 d0                	add    %edx,%eax
801014bb:	eb 52                	jmp    8010150f <balloc+0x13c>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014bd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801014c1:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801014c8:	7f 17                	jg     801014e1 <balloc+0x10e>
801014ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014d0:	01 d0                	add    %edx,%eax
801014d2:	89 c2                	mov    %eax,%edx
801014d4:	a1 40 1a 11 80       	mov    0x80111a40,%eax
801014d9:	39 c2                	cmp    %eax,%edx
801014db:	0f 82 43 ff ff ff    	jb     80101424 <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801014e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014e4:	89 04 24             	mov    %eax,(%esp)
801014e7:	e8 40 ed ff ff       	call   8010022c <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801014ec:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801014f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014f6:	a1 40 1a 11 80       	mov    0x80111a40,%eax
801014fb:	39 c2                	cmp    %eax,%edx
801014fd:	0f 82 e9 fe ff ff    	jb     801013ec <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101503:	c7 04 24 d4 85 10 80 	movl   $0x801085d4,(%esp)
8010150a:	e8 53 f0 ff ff       	call   80100562 <panic>
}
8010150f:	c9                   	leave  
80101510:	c3                   	ret    

80101511 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101511:	55                   	push   %ebp
80101512:	89 e5                	mov    %esp,%ebp
80101514:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101517:	c7 44 24 04 40 1a 11 	movl   $0x80111a40,0x4(%esp)
8010151e:	80 
8010151f:	8b 45 08             	mov    0x8(%ebp),%eax
80101522:	89 04 24             	mov    %eax,(%esp)
80101525:	e8 12 fe ff ff       	call   8010133c <readsb>
  bp = bread(dev, BBLOCK(b, sb));
8010152a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010152d:	c1 e8 0c             	shr    $0xc,%eax
80101530:	89 c2                	mov    %eax,%edx
80101532:	a1 58 1a 11 80       	mov    0x80111a58,%eax
80101537:	01 c2                	add    %eax,%edx
80101539:	8b 45 08             	mov    0x8(%ebp),%eax
8010153c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101540:	89 04 24             	mov    %eax,(%esp)
80101543:	e8 6d ec ff ff       	call   801001b5 <bread>
80101548:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010154b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010154e:	25 ff 0f 00 00       	and    $0xfff,%eax
80101553:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101556:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101559:	99                   	cltd   
8010155a:	c1 ea 1d             	shr    $0x1d,%edx
8010155d:	01 d0                	add    %edx,%eax
8010155f:	83 e0 07             	and    $0x7,%eax
80101562:	29 d0                	sub    %edx,%eax
80101564:	ba 01 00 00 00       	mov    $0x1,%edx
80101569:	89 c1                	mov    %eax,%ecx
8010156b:	d3 e2                	shl    %cl,%edx
8010156d:	89 d0                	mov    %edx,%eax
8010156f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101572:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101575:	8d 50 07             	lea    0x7(%eax),%edx
80101578:	85 c0                	test   %eax,%eax
8010157a:	0f 48 c2             	cmovs  %edx,%eax
8010157d:	c1 f8 03             	sar    $0x3,%eax
80101580:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101583:	0f b6 44 02 5c       	movzbl 0x5c(%edx,%eax,1),%eax
80101588:	0f b6 c0             	movzbl %al,%eax
8010158b:	23 45 ec             	and    -0x14(%ebp),%eax
8010158e:	85 c0                	test   %eax,%eax
80101590:	75 0c                	jne    8010159e <bfree+0x8d>
    panic("freeing free block");
80101592:	c7 04 24 ea 85 10 80 	movl   $0x801085ea,(%esp)
80101599:	e8 c4 ef ff ff       	call   80100562 <panic>
  bp->data[bi/8] &= ~m;
8010159e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015a1:	8d 50 07             	lea    0x7(%eax),%edx
801015a4:	85 c0                	test   %eax,%eax
801015a6:	0f 48 c2             	cmovs  %edx,%eax
801015a9:	c1 f8 03             	sar    $0x3,%eax
801015ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015af:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801015b4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801015b7:	f7 d1                	not    %ecx
801015b9:	21 ca                	and    %ecx,%edx
801015bb:	89 d1                	mov    %edx,%ecx
801015bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015c0:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
801015c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015c7:	89 04 24             	mov    %eax,(%esp)
801015ca:	e8 af 20 00 00       	call   8010367e <log_write>
  brelse(bp);
801015cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015d2:	89 04 24             	mov    %eax,(%esp)
801015d5:	e8 52 ec ff ff       	call   8010022c <brelse>
}
801015da:	c9                   	leave  
801015db:	c3                   	ret    

801015dc <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801015dc:	55                   	push   %ebp
801015dd:	89 e5                	mov    %esp,%ebp
801015df:	57                   	push   %edi
801015e0:	56                   	push   %esi
801015e1:	53                   	push   %ebx
801015e2:	83 ec 4c             	sub    $0x4c,%esp
  int i = 0;
801015e5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
801015ec:	c7 44 24 04 fd 85 10 	movl   $0x801085fd,0x4(%esp)
801015f3:	80 
801015f4:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
801015fb:	e8 54 37 00 00       	call   80104d54 <initlock>
  for(i = 0; i < NINODE; i++) {
80101600:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101607:	eb 2c                	jmp    80101635 <iinit+0x59>
    initsleeplock(&icache.inode[i].lock, "inode");
80101609:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010160c:	89 d0                	mov    %edx,%eax
8010160e:	c1 e0 03             	shl    $0x3,%eax
80101611:	01 d0                	add    %edx,%eax
80101613:	c1 e0 04             	shl    $0x4,%eax
80101616:	83 c0 30             	add    $0x30,%eax
80101619:	05 60 1a 11 80       	add    $0x80111a60,%eax
8010161e:	83 c0 10             	add    $0x10,%eax
80101621:	c7 44 24 04 04 86 10 	movl   $0x80108604,0x4(%esp)
80101628:	80 
80101629:	89 04 24             	mov    %eax,(%esp)
8010162c:	e8 e7 35 00 00       	call   80104c18 <initsleeplock>
iinit(int dev)
{
  int i = 0;
  
  initlock(&icache.lock, "icache");
  for(i = 0; i < NINODE; i++) {
80101631:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101635:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101639:	7e ce                	jle    80101609 <iinit+0x2d>
    initsleeplock(&icache.inode[i].lock, "inode");
  }

  readsb(dev, &sb);
8010163b:	c7 44 24 04 40 1a 11 	movl   $0x80111a40,0x4(%esp)
80101642:	80 
80101643:	8b 45 08             	mov    0x8(%ebp),%eax
80101646:	89 04 24             	mov    %eax,(%esp)
80101649:	e8 ee fc ff ff       	call   8010133c <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010164e:	a1 58 1a 11 80       	mov    0x80111a58,%eax
80101653:	8b 3d 54 1a 11 80    	mov    0x80111a54,%edi
80101659:	8b 35 50 1a 11 80    	mov    0x80111a50,%esi
8010165f:	8b 1d 4c 1a 11 80    	mov    0x80111a4c,%ebx
80101665:	8b 0d 48 1a 11 80    	mov    0x80111a48,%ecx
8010166b:	8b 15 44 1a 11 80    	mov    0x80111a44,%edx
80101671:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101674:	8b 15 40 1a 11 80    	mov    0x80111a40,%edx
8010167a:	89 44 24 1c          	mov    %eax,0x1c(%esp)
8010167e:	89 7c 24 18          	mov    %edi,0x18(%esp)
80101682:	89 74 24 14          	mov    %esi,0x14(%esp)
80101686:	89 5c 24 10          	mov    %ebx,0x10(%esp)
8010168a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010168e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101691:	89 44 24 08          	mov    %eax,0x8(%esp)
80101695:	89 d0                	mov    %edx,%eax
80101697:	89 44 24 04          	mov    %eax,0x4(%esp)
8010169b:	c7 04 24 0c 86 10 80 	movl   $0x8010860c,(%esp)
801016a2:	e8 21 ed ff ff       	call   801003c8 <cprintf>
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
801016a7:	83 c4 4c             	add    $0x4c,%esp
801016aa:	5b                   	pop    %ebx
801016ab:	5e                   	pop    %esi
801016ac:	5f                   	pop    %edi
801016ad:	5d                   	pop    %ebp
801016ae:	c3                   	ret    

801016af <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
801016af:	55                   	push   %ebp
801016b0:	89 e5                	mov    %esp,%ebp
801016b2:	83 ec 28             	sub    $0x28,%esp
801016b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801016b8:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801016bc:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801016c3:	e9 9e 00 00 00       	jmp    80101766 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801016c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016cb:	c1 e8 03             	shr    $0x3,%eax
801016ce:	89 c2                	mov    %eax,%edx
801016d0:	a1 54 1a 11 80       	mov    0x80111a54,%eax
801016d5:	01 d0                	add    %edx,%eax
801016d7:	89 44 24 04          	mov    %eax,0x4(%esp)
801016db:	8b 45 08             	mov    0x8(%ebp),%eax
801016de:	89 04 24             	mov    %eax,(%esp)
801016e1:	e8 cf ea ff ff       	call   801001b5 <bread>
801016e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801016e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016ec:	8d 50 5c             	lea    0x5c(%eax),%edx
801016ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016f2:	83 e0 07             	and    $0x7,%eax
801016f5:	c1 e0 06             	shl    $0x6,%eax
801016f8:	01 d0                	add    %edx,%eax
801016fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801016fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101700:	0f b7 00             	movzwl (%eax),%eax
80101703:	66 85 c0             	test   %ax,%ax
80101706:	75 4f                	jne    80101757 <ialloc+0xa8>
      memset(dip, 0, sizeof(*dip));
80101708:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
8010170f:	00 
80101710:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101717:	00 
80101718:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010171b:	89 04 24             	mov    %eax,(%esp)
8010171e:	e8 b4 38 00 00       	call   80104fd7 <memset>
      dip->type = type;
80101723:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101726:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010172a:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010172d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101730:	89 04 24             	mov    %eax,(%esp)
80101733:	e8 46 1f 00 00       	call   8010367e <log_write>
      brelse(bp);
80101738:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010173b:	89 04 24             	mov    %eax,(%esp)
8010173e:	e8 e9 ea ff ff       	call   8010022c <brelse>
      return iget(dev, inum);
80101743:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101746:	89 44 24 04          	mov    %eax,0x4(%esp)
8010174a:	8b 45 08             	mov    0x8(%ebp),%eax
8010174d:	89 04 24             	mov    %eax,(%esp)
80101750:	e8 ed 00 00 00       	call   80101842 <iget>
80101755:	eb 2b                	jmp    80101782 <ialloc+0xd3>
    }
    brelse(bp);
80101757:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010175a:	89 04 24             	mov    %eax,(%esp)
8010175d:	e8 ca ea ff ff       	call   8010022c <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101762:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101766:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101769:	a1 48 1a 11 80       	mov    0x80111a48,%eax
8010176e:	39 c2                	cmp    %eax,%edx
80101770:	0f 82 52 ff ff ff    	jb     801016c8 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101776:	c7 04 24 5f 86 10 80 	movl   $0x8010865f,(%esp)
8010177d:	e8 e0 ed ff ff       	call   80100562 <panic>
}
80101782:	c9                   	leave  
80101783:	c3                   	ret    

80101784 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101784:	55                   	push   %ebp
80101785:	89 e5                	mov    %esp,%ebp
80101787:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010178a:	8b 45 08             	mov    0x8(%ebp),%eax
8010178d:	8b 40 04             	mov    0x4(%eax),%eax
80101790:	c1 e8 03             	shr    $0x3,%eax
80101793:	89 c2                	mov    %eax,%edx
80101795:	a1 54 1a 11 80       	mov    0x80111a54,%eax
8010179a:	01 c2                	add    %eax,%edx
8010179c:	8b 45 08             	mov    0x8(%ebp),%eax
8010179f:	8b 00                	mov    (%eax),%eax
801017a1:	89 54 24 04          	mov    %edx,0x4(%esp)
801017a5:	89 04 24             	mov    %eax,(%esp)
801017a8:	e8 08 ea ff ff       	call   801001b5 <bread>
801017ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801017b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017b3:	8d 50 5c             	lea    0x5c(%eax),%edx
801017b6:	8b 45 08             	mov    0x8(%ebp),%eax
801017b9:	8b 40 04             	mov    0x4(%eax),%eax
801017bc:	83 e0 07             	and    $0x7,%eax
801017bf:	c1 e0 06             	shl    $0x6,%eax
801017c2:	01 d0                	add    %edx,%eax
801017c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801017c7:	8b 45 08             	mov    0x8(%ebp),%eax
801017ca:	0f b7 50 50          	movzwl 0x50(%eax),%edx
801017ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017d1:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801017d4:	8b 45 08             	mov    0x8(%ebp),%eax
801017d7:	0f b7 50 52          	movzwl 0x52(%eax),%edx
801017db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017de:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801017e2:	8b 45 08             	mov    0x8(%ebp),%eax
801017e5:	0f b7 50 54          	movzwl 0x54(%eax),%edx
801017e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017ec:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801017f0:	8b 45 08             	mov    0x8(%ebp),%eax
801017f3:	0f b7 50 56          	movzwl 0x56(%eax),%edx
801017f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017fa:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801017fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101801:	8b 50 58             	mov    0x58(%eax),%edx
80101804:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101807:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010180a:	8b 45 08             	mov    0x8(%ebp),%eax
8010180d:	8d 50 5c             	lea    0x5c(%eax),%edx
80101810:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101813:	83 c0 0c             	add    $0xc,%eax
80101816:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
8010181d:	00 
8010181e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101822:	89 04 24             	mov    %eax,(%esp)
80101825:	e8 7c 38 00 00       	call   801050a6 <memmove>
  log_write(bp);
8010182a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010182d:	89 04 24             	mov    %eax,(%esp)
80101830:	e8 49 1e 00 00       	call   8010367e <log_write>
  brelse(bp);
80101835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101838:	89 04 24             	mov    %eax,(%esp)
8010183b:	e8 ec e9 ff ff       	call   8010022c <brelse>
}
80101840:	c9                   	leave  
80101841:	c3                   	ret    

80101842 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101842:	55                   	push   %ebp
80101843:	89 e5                	mov    %esp,%ebp
80101845:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101848:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
8010184f:	e8 21 35 00 00       	call   80104d75 <acquire>

  // Is the inode already cached?
  empty = 0;
80101854:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010185b:	c7 45 f4 94 1a 11 80 	movl   $0x80111a94,-0xc(%ebp)
80101862:	eb 5c                	jmp    801018c0 <iget+0x7e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101864:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101867:	8b 40 08             	mov    0x8(%eax),%eax
8010186a:	85 c0                	test   %eax,%eax
8010186c:	7e 35                	jle    801018a3 <iget+0x61>
8010186e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101871:	8b 00                	mov    (%eax),%eax
80101873:	3b 45 08             	cmp    0x8(%ebp),%eax
80101876:	75 2b                	jne    801018a3 <iget+0x61>
80101878:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187b:	8b 40 04             	mov    0x4(%eax),%eax
8010187e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101881:	75 20                	jne    801018a3 <iget+0x61>
      ip->ref++;
80101883:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101886:	8b 40 08             	mov    0x8(%eax),%eax
80101889:	8d 50 01             	lea    0x1(%eax),%edx
8010188c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010188f:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101892:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
80101899:	e8 3f 35 00 00       	call   80104ddd <release>
      return ip;
8010189e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a1:	eb 72                	jmp    80101915 <iget+0xd3>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801018a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018a7:	75 10                	jne    801018b9 <iget+0x77>
801018a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ac:	8b 40 08             	mov    0x8(%eax),%eax
801018af:	85 c0                	test   %eax,%eax
801018b1:	75 06                	jne    801018b9 <iget+0x77>
      empty = ip;
801018b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b6:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018b9:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801018c0:	81 7d f4 b4 36 11 80 	cmpl   $0x801136b4,-0xc(%ebp)
801018c7:	72 9b                	jb     80101864 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801018c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018cd:	75 0c                	jne    801018db <iget+0x99>
    panic("iget: no inodes");
801018cf:	c7 04 24 71 86 10 80 	movl   $0x80108671,(%esp)
801018d6:	e8 87 ec ff ff       	call   80100562 <panic>

  ip = empty;
801018db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018de:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801018e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018e4:	8b 55 08             	mov    0x8(%ebp),%edx
801018e7:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801018e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ec:	8b 55 0c             	mov    0xc(%ebp),%edx
801018ef:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801018f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
801018fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ff:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101906:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
8010190d:	e8 cb 34 00 00       	call   80104ddd <release>

  return ip;
80101912:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101915:	c9                   	leave  
80101916:	c3                   	ret    

80101917 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101917:	55                   	push   %ebp
80101918:	89 e5                	mov    %esp,%ebp
8010191a:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
8010191d:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
80101924:	e8 4c 34 00 00       	call   80104d75 <acquire>
  ip->ref++;
80101929:	8b 45 08             	mov    0x8(%ebp),%eax
8010192c:	8b 40 08             	mov    0x8(%eax),%eax
8010192f:	8d 50 01             	lea    0x1(%eax),%edx
80101932:	8b 45 08             	mov    0x8(%ebp),%eax
80101935:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101938:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
8010193f:	e8 99 34 00 00       	call   80104ddd <release>
  return ip;
80101944:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101947:	c9                   	leave  
80101948:	c3                   	ret    

80101949 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101949:	55                   	push   %ebp
8010194a:	89 e5                	mov    %esp,%ebp
8010194c:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
8010194f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101953:	74 0a                	je     8010195f <ilock+0x16>
80101955:	8b 45 08             	mov    0x8(%ebp),%eax
80101958:	8b 40 08             	mov    0x8(%eax),%eax
8010195b:	85 c0                	test   %eax,%eax
8010195d:	7f 0c                	jg     8010196b <ilock+0x22>
    panic("ilock");
8010195f:	c7 04 24 81 86 10 80 	movl   $0x80108681,(%esp)
80101966:	e8 f7 eb ff ff       	call   80100562 <panic>

  acquiresleep(&ip->lock);
8010196b:	8b 45 08             	mov    0x8(%ebp),%eax
8010196e:	83 c0 0c             	add    $0xc,%eax
80101971:	89 04 24             	mov    %eax,(%esp)
80101974:	e8 d9 32 00 00       	call   80104c52 <acquiresleep>

  if(ip->valid == 0){
80101979:	8b 45 08             	mov    0x8(%ebp),%eax
8010197c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010197f:	85 c0                	test   %eax,%eax
80101981:	0f 85 cd 00 00 00    	jne    80101a54 <ilock+0x10b>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101987:	8b 45 08             	mov    0x8(%ebp),%eax
8010198a:	8b 40 04             	mov    0x4(%eax),%eax
8010198d:	c1 e8 03             	shr    $0x3,%eax
80101990:	89 c2                	mov    %eax,%edx
80101992:	a1 54 1a 11 80       	mov    0x80111a54,%eax
80101997:	01 c2                	add    %eax,%edx
80101999:	8b 45 08             	mov    0x8(%ebp),%eax
8010199c:	8b 00                	mov    (%eax),%eax
8010199e:	89 54 24 04          	mov    %edx,0x4(%esp)
801019a2:	89 04 24             	mov    %eax,(%esp)
801019a5:	e8 0b e8 ff ff       	call   801001b5 <bread>
801019aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801019ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019b0:	8d 50 5c             	lea    0x5c(%eax),%edx
801019b3:	8b 45 08             	mov    0x8(%ebp),%eax
801019b6:	8b 40 04             	mov    0x4(%eax),%eax
801019b9:	83 e0 07             	and    $0x7,%eax
801019bc:	c1 e0 06             	shl    $0x6,%eax
801019bf:	01 d0                	add    %edx,%eax
801019c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
801019c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019c7:	0f b7 10             	movzwl (%eax),%edx
801019ca:	8b 45 08             	mov    0x8(%ebp),%eax
801019cd:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
801019d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019d4:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801019d8:	8b 45 08             	mov    0x8(%ebp),%eax
801019db:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
801019df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019e2:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801019e6:	8b 45 08             	mov    0x8(%ebp),%eax
801019e9:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
801019ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019f0:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801019f4:	8b 45 08             	mov    0x8(%ebp),%eax
801019f7:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
801019fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019fe:	8b 50 08             	mov    0x8(%eax),%edx
80101a01:	8b 45 08             	mov    0x8(%ebp),%eax
80101a04:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a0a:	8d 50 0c             	lea    0xc(%eax),%edx
80101a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a10:	83 c0 5c             	add    $0x5c,%eax
80101a13:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101a1a:	00 
80101a1b:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a1f:	89 04 24             	mov    %eax,(%esp)
80101a22:	e8 7f 36 00 00       	call   801050a6 <memmove>
    brelse(bp);
80101a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a2a:	89 04 24             	mov    %eax,(%esp)
80101a2d:	e8 fa e7 ff ff       	call   8010022c <brelse>
    ip->valid = 1;
80101a32:	8b 45 08             	mov    0x8(%ebp),%eax
80101a35:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101a3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a3f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101a43:	66 85 c0             	test   %ax,%ax
80101a46:	75 0c                	jne    80101a54 <ilock+0x10b>
      panic("ilock: no type");
80101a48:	c7 04 24 87 86 10 80 	movl   $0x80108687,(%esp)
80101a4f:	e8 0e eb ff ff       	call   80100562 <panic>
  }
}
80101a54:	c9                   	leave  
80101a55:	c3                   	ret    

80101a56 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101a56:	55                   	push   %ebp
80101a57:	89 e5                	mov    %esp,%ebp
80101a59:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101a5c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a60:	74 1c                	je     80101a7e <iunlock+0x28>
80101a62:	8b 45 08             	mov    0x8(%ebp),%eax
80101a65:	83 c0 0c             	add    $0xc,%eax
80101a68:	89 04 24             	mov    %eax,(%esp)
80101a6b:	e8 7f 32 00 00       	call   80104cef <holdingsleep>
80101a70:	85 c0                	test   %eax,%eax
80101a72:	74 0a                	je     80101a7e <iunlock+0x28>
80101a74:	8b 45 08             	mov    0x8(%ebp),%eax
80101a77:	8b 40 08             	mov    0x8(%eax),%eax
80101a7a:	85 c0                	test   %eax,%eax
80101a7c:	7f 0c                	jg     80101a8a <iunlock+0x34>
    panic("iunlock");
80101a7e:	c7 04 24 96 86 10 80 	movl   $0x80108696,(%esp)
80101a85:	e8 d8 ea ff ff       	call   80100562 <panic>

  releasesleep(&ip->lock);
80101a8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8d:	83 c0 0c             	add    $0xc,%eax
80101a90:	89 04 24             	mov    %eax,(%esp)
80101a93:	e8 15 32 00 00       	call   80104cad <releasesleep>
}
80101a98:	c9                   	leave  
80101a99:	c3                   	ret    

80101a9a <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101a9a:	55                   	push   %ebp
80101a9b:	89 e5                	mov    %esp,%ebp
80101a9d:	83 ec 28             	sub    $0x28,%esp
  acquiresleep(&ip->lock);
80101aa0:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa3:	83 c0 0c             	add    $0xc,%eax
80101aa6:	89 04 24             	mov    %eax,(%esp)
80101aa9:	e8 a4 31 00 00       	call   80104c52 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101aae:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab1:	8b 40 4c             	mov    0x4c(%eax),%eax
80101ab4:	85 c0                	test   %eax,%eax
80101ab6:	74 5c                	je     80101b14 <iput+0x7a>
80101ab8:	8b 45 08             	mov    0x8(%ebp),%eax
80101abb:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101abf:	66 85 c0             	test   %ax,%ax
80101ac2:	75 50                	jne    80101b14 <iput+0x7a>
    acquire(&icache.lock);
80101ac4:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
80101acb:	e8 a5 32 00 00       	call   80104d75 <acquire>
    int r = ip->ref;
80101ad0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad3:	8b 40 08             	mov    0x8(%eax),%eax
80101ad6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101ad9:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
80101ae0:	e8 f8 32 00 00       	call   80104ddd <release>
    if(r == 1){
80101ae5:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101ae9:	75 29                	jne    80101b14 <iput+0x7a>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101aeb:	8b 45 08             	mov    0x8(%ebp),%eax
80101aee:	89 04 24             	mov    %eax,(%esp)
80101af1:	e8 86 01 00 00       	call   80101c7c <itrunc>
      ip->type = 0;
80101af6:	8b 45 08             	mov    0x8(%ebp),%eax
80101af9:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101aff:	8b 45 08             	mov    0x8(%ebp),%eax
80101b02:	89 04 24             	mov    %eax,(%esp)
80101b05:	e8 7a fc ff ff       	call   80101784 <iupdate>
      ip->valid = 0;
80101b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0d:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101b14:	8b 45 08             	mov    0x8(%ebp),%eax
80101b17:	83 c0 0c             	add    $0xc,%eax
80101b1a:	89 04 24             	mov    %eax,(%esp)
80101b1d:	e8 8b 31 00 00       	call   80104cad <releasesleep>

  acquire(&icache.lock);
80101b22:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
80101b29:	e8 47 32 00 00       	call   80104d75 <acquire>
  ip->ref--;
80101b2e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b31:	8b 40 08             	mov    0x8(%eax),%eax
80101b34:	8d 50 ff             	lea    -0x1(%eax),%edx
80101b37:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3a:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b3d:	c7 04 24 60 1a 11 80 	movl   $0x80111a60,(%esp)
80101b44:	e8 94 32 00 00       	call   80104ddd <release>
}
80101b49:	c9                   	leave  
80101b4a:	c3                   	ret    

80101b4b <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101b4b:	55                   	push   %ebp
80101b4c:	89 e5                	mov    %esp,%ebp
80101b4e:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101b51:	8b 45 08             	mov    0x8(%ebp),%eax
80101b54:	89 04 24             	mov    %eax,(%esp)
80101b57:	e8 fa fe ff ff       	call   80101a56 <iunlock>
  iput(ip);
80101b5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5f:	89 04 24             	mov    %eax,(%esp)
80101b62:	e8 33 ff ff ff       	call   80101a9a <iput>
}
80101b67:	c9                   	leave  
80101b68:	c3                   	ret    

80101b69 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101b69:	55                   	push   %ebp
80101b6a:	89 e5                	mov    %esp,%ebp
80101b6c:	53                   	push   %ebx
80101b6d:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101b70:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101b74:	77 3e                	ja     80101bb4 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101b76:	8b 45 08             	mov    0x8(%ebp),%eax
80101b79:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b7c:	83 c2 14             	add    $0x14,%edx
80101b7f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b83:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b86:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b8a:	75 20                	jne    80101bac <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8f:	8b 00                	mov    (%eax),%eax
80101b91:	89 04 24             	mov    %eax,(%esp)
80101b94:	e8 3a f8 ff ff       	call   801013d3 <balloc>
80101b99:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101ba2:	8d 4a 14             	lea    0x14(%edx),%ecx
80101ba5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ba8:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101baf:	e9 c2 00 00 00       	jmp    80101c76 <bmap+0x10d>
  }
  bn -= NDIRECT;
80101bb4:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101bb8:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101bbc:	0f 87 a8 00 00 00    	ja     80101c6a <bmap+0x101>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101bc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc5:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101bcb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101bd2:	75 1c                	jne    80101bf0 <bmap+0x87>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101bd4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd7:	8b 00                	mov    (%eax),%eax
80101bd9:	89 04 24             	mov    %eax,(%esp)
80101bdc:	e8 f2 f7 ff ff       	call   801013d3 <balloc>
80101be1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101be4:	8b 45 08             	mov    0x8(%ebp),%eax
80101be7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bea:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf3:	8b 00                	mov    (%eax),%eax
80101bf5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bf8:	89 54 24 04          	mov    %edx,0x4(%esp)
80101bfc:	89 04 24             	mov    %eax,(%esp)
80101bff:	e8 b1 e5 ff ff       	call   801001b5 <bread>
80101c04:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101c07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c0a:	83 c0 5c             	add    $0x5c,%eax
80101c0d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101c10:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c13:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c1d:	01 d0                	add    %edx,%eax
80101c1f:	8b 00                	mov    (%eax),%eax
80101c21:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c24:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c28:	75 30                	jne    80101c5a <bmap+0xf1>
      a[bn] = addr = balloc(ip->dev);
80101c2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c2d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c34:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c37:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101c3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3d:	8b 00                	mov    (%eax),%eax
80101c3f:	89 04 24             	mov    %eax,(%esp)
80101c42:	e8 8c f7 ff ff       	call   801013d3 <balloc>
80101c47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c4d:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101c4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c52:	89 04 24             	mov    %eax,(%esp)
80101c55:	e8 24 1a 00 00       	call   8010367e <log_write>
    }
    brelse(bp);
80101c5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c5d:	89 04 24             	mov    %eax,(%esp)
80101c60:	e8 c7 e5 ff ff       	call   8010022c <brelse>
    return addr;
80101c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c68:	eb 0c                	jmp    80101c76 <bmap+0x10d>
  }

  panic("bmap: out of range");
80101c6a:	c7 04 24 9e 86 10 80 	movl   $0x8010869e,(%esp)
80101c71:	e8 ec e8 ff ff       	call   80100562 <panic>
}
80101c76:	83 c4 24             	add    $0x24,%esp
80101c79:	5b                   	pop    %ebx
80101c7a:	5d                   	pop    %ebp
80101c7b:	c3                   	ret    

80101c7c <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101c7c:	55                   	push   %ebp
80101c7d:	89 e5                	mov    %esp,%ebp
80101c7f:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c82:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c89:	eb 44                	jmp    80101ccf <itrunc+0x53>
    if(ip->addrs[i]){
80101c8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c91:	83 c2 14             	add    $0x14,%edx
80101c94:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c98:	85 c0                	test   %eax,%eax
80101c9a:	74 2f                	je     80101ccb <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101c9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ca2:	83 c2 14             	add    $0x14,%edx
80101ca5:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101ca9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cac:	8b 00                	mov    (%eax),%eax
80101cae:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cb2:	89 04 24             	mov    %eax,(%esp)
80101cb5:	e8 57 f8 ff ff       	call   80101511 <bfree>
      ip->addrs[i] = 0;
80101cba:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cc0:	83 c2 14             	add    $0x14,%edx
80101cc3:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101cca:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101ccb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101ccf:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101cd3:	7e b6                	jle    80101c8b <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
80101cd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd8:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101cde:	85 c0                	test   %eax,%eax
80101ce0:	0f 84 a4 00 00 00    	je     80101d8a <itrunc+0x10e>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101ce6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce9:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101cef:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf2:	8b 00                	mov    (%eax),%eax
80101cf4:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cf8:	89 04 24             	mov    %eax,(%esp)
80101cfb:	e8 b5 e4 ff ff       	call   801001b5 <bread>
80101d00:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101d03:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d06:	83 c0 5c             	add    $0x5c,%eax
80101d09:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101d0c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101d13:	eb 3b                	jmp    80101d50 <itrunc+0xd4>
      if(a[j])
80101d15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d18:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101d22:	01 d0                	add    %edx,%eax
80101d24:	8b 00                	mov    (%eax),%eax
80101d26:	85 c0                	test   %eax,%eax
80101d28:	74 22                	je     80101d4c <itrunc+0xd0>
        bfree(ip->dev, a[j]);
80101d2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d2d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d34:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101d37:	01 d0                	add    %edx,%eax
80101d39:	8b 10                	mov    (%eax),%edx
80101d3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3e:	8b 00                	mov    (%eax),%eax
80101d40:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d44:	89 04 24             	mov    %eax,(%esp)
80101d47:	e8 c5 f7 ff ff       	call   80101511 <bfree>
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101d4c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101d50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d53:	83 f8 7f             	cmp    $0x7f,%eax
80101d56:	76 bd                	jbe    80101d15 <itrunc+0x99>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101d58:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d5b:	89 04 24             	mov    %eax,(%esp)
80101d5e:	e8 c9 e4 ff ff       	call   8010022c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101d63:	8b 45 08             	mov    0x8(%ebp),%eax
80101d66:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101d6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6f:	8b 00                	mov    (%eax),%eax
80101d71:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d75:	89 04 24             	mov    %eax,(%esp)
80101d78:	e8 94 f7 ff ff       	call   80101511 <bfree>
    ip->addrs[NDIRECT] = 0;
80101d7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d80:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101d87:	00 00 00 
  }

  ip->size = 0;
80101d8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8d:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101d94:	8b 45 08             	mov    0x8(%ebp),%eax
80101d97:	89 04 24             	mov    %eax,(%esp)
80101d9a:	e8 e5 f9 ff ff       	call   80101784 <iupdate>
}
80101d9f:	c9                   	leave  
80101da0:	c3                   	ret    

80101da1 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101da1:	55                   	push   %ebp
80101da2:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101da4:	8b 45 08             	mov    0x8(%ebp),%eax
80101da7:	8b 00                	mov    (%eax),%eax
80101da9:	89 c2                	mov    %eax,%edx
80101dab:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dae:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101db1:	8b 45 08             	mov    0x8(%ebp),%eax
80101db4:	8b 50 04             	mov    0x4(%eax),%edx
80101db7:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dba:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101dbd:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc0:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101dc4:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dc7:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101dca:	8b 45 08             	mov    0x8(%ebp),%eax
80101dcd:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101dd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dd4:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101dd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddb:	8b 50 58             	mov    0x58(%eax),%edx
80101dde:	8b 45 0c             	mov    0xc(%ebp),%eax
80101de1:	89 50 10             	mov    %edx,0x10(%eax)
}
80101de4:	5d                   	pop    %ebp
80101de5:	c3                   	ret    

80101de6 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101de6:	55                   	push   %ebp
80101de7:	89 e5                	mov    %esp,%ebp
80101de9:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101dec:	8b 45 08             	mov    0x8(%ebp),%eax
80101def:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101df3:	66 83 f8 03          	cmp    $0x3,%ax
80101df7:	75 60                	jne    80101e59 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101df9:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfc:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101e00:	66 85 c0             	test   %ax,%ax
80101e03:	78 20                	js     80101e25 <readi+0x3f>
80101e05:	8b 45 08             	mov    0x8(%ebp),%eax
80101e08:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101e0c:	66 83 f8 09          	cmp    $0x9,%ax
80101e10:	7f 13                	jg     80101e25 <readi+0x3f>
80101e12:	8b 45 08             	mov    0x8(%ebp),%eax
80101e15:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101e19:	98                   	cwtl   
80101e1a:	8b 04 c5 e0 19 11 80 	mov    -0x7feee620(,%eax,8),%eax
80101e21:	85 c0                	test   %eax,%eax
80101e23:	75 0a                	jne    80101e2f <readi+0x49>
      return -1;
80101e25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e2a:	e9 19 01 00 00       	jmp    80101f48 <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101e2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e32:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101e36:	98                   	cwtl   
80101e37:	8b 04 c5 e0 19 11 80 	mov    -0x7feee620(,%eax,8),%eax
80101e3e:	8b 55 14             	mov    0x14(%ebp),%edx
80101e41:	89 54 24 08          	mov    %edx,0x8(%esp)
80101e45:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e48:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e4c:	8b 55 08             	mov    0x8(%ebp),%edx
80101e4f:	89 14 24             	mov    %edx,(%esp)
80101e52:	ff d0                	call   *%eax
80101e54:	e9 ef 00 00 00       	jmp    80101f48 <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101e59:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5c:	8b 40 58             	mov    0x58(%eax),%eax
80101e5f:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e62:	72 0d                	jb     80101e71 <readi+0x8b>
80101e64:	8b 45 14             	mov    0x14(%ebp),%eax
80101e67:	8b 55 10             	mov    0x10(%ebp),%edx
80101e6a:	01 d0                	add    %edx,%eax
80101e6c:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e6f:	73 0a                	jae    80101e7b <readi+0x95>
    return -1;
80101e71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e76:	e9 cd 00 00 00       	jmp    80101f48 <readi+0x162>
  if(off + n > ip->size)
80101e7b:	8b 45 14             	mov    0x14(%ebp),%eax
80101e7e:	8b 55 10             	mov    0x10(%ebp),%edx
80101e81:	01 c2                	add    %eax,%edx
80101e83:	8b 45 08             	mov    0x8(%ebp),%eax
80101e86:	8b 40 58             	mov    0x58(%eax),%eax
80101e89:	39 c2                	cmp    %eax,%edx
80101e8b:	76 0c                	jbe    80101e99 <readi+0xb3>
    n = ip->size - off;
80101e8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e90:	8b 40 58             	mov    0x58(%eax),%eax
80101e93:	2b 45 10             	sub    0x10(%ebp),%eax
80101e96:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ea0:	e9 94 00 00 00       	jmp    80101f39 <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101ea5:	8b 45 10             	mov    0x10(%ebp),%eax
80101ea8:	c1 e8 09             	shr    $0x9,%eax
80101eab:	89 44 24 04          	mov    %eax,0x4(%esp)
80101eaf:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb2:	89 04 24             	mov    %eax,(%esp)
80101eb5:	e8 af fc ff ff       	call   80101b69 <bmap>
80101eba:	8b 55 08             	mov    0x8(%ebp),%edx
80101ebd:	8b 12                	mov    (%edx),%edx
80101ebf:	89 44 24 04          	mov    %eax,0x4(%esp)
80101ec3:	89 14 24             	mov    %edx,(%esp)
80101ec6:	e8 ea e2 ff ff       	call   801001b5 <bread>
80101ecb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101ece:	8b 45 10             	mov    0x10(%ebp),%eax
80101ed1:	25 ff 01 00 00       	and    $0x1ff,%eax
80101ed6:	89 c2                	mov    %eax,%edx
80101ed8:	b8 00 02 00 00       	mov    $0x200,%eax
80101edd:	29 d0                	sub    %edx,%eax
80101edf:	89 c2                	mov    %eax,%edx
80101ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ee4:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101ee7:	29 c1                	sub    %eax,%ecx
80101ee9:	89 c8                	mov    %ecx,%eax
80101eeb:	39 c2                	cmp    %eax,%edx
80101eed:	0f 46 c2             	cmovbe %edx,%eax
80101ef0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101ef3:	8b 45 10             	mov    0x10(%ebp),%eax
80101ef6:	25 ff 01 00 00       	and    $0x1ff,%eax
80101efb:	8d 50 50             	lea    0x50(%eax),%edx
80101efe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f01:	01 d0                	add    %edx,%eax
80101f03:	8d 50 0c             	lea    0xc(%eax),%edx
80101f06:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f09:	89 44 24 08          	mov    %eax,0x8(%esp)
80101f0d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f11:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f14:	89 04 24             	mov    %eax,(%esp)
80101f17:	e8 8a 31 00 00       	call   801050a6 <memmove>
    brelse(bp);
80101f1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f1f:	89 04 24             	mov    %eax,(%esp)
80101f22:	e8 05 e3 ff ff       	call   8010022c <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f27:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f2a:	01 45 f4             	add    %eax,-0xc(%ebp)
80101f2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f30:	01 45 10             	add    %eax,0x10(%ebp)
80101f33:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f36:	01 45 0c             	add    %eax,0xc(%ebp)
80101f39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f3c:	3b 45 14             	cmp    0x14(%ebp),%eax
80101f3f:	0f 82 60 ff ff ff    	jb     80101ea5 <readi+0xbf>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101f45:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101f48:	c9                   	leave  
80101f49:	c3                   	ret    

80101f4a <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101f4a:	55                   	push   %ebp
80101f4b:	89 e5                	mov    %esp,%ebp
80101f4d:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f50:	8b 45 08             	mov    0x8(%ebp),%eax
80101f53:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101f57:	66 83 f8 03          	cmp    $0x3,%ax
80101f5b:	75 60                	jne    80101fbd <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101f5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f60:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f64:	66 85 c0             	test   %ax,%ax
80101f67:	78 20                	js     80101f89 <writei+0x3f>
80101f69:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6c:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f70:	66 83 f8 09          	cmp    $0x9,%ax
80101f74:	7f 13                	jg     80101f89 <writei+0x3f>
80101f76:	8b 45 08             	mov    0x8(%ebp),%eax
80101f79:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f7d:	98                   	cwtl   
80101f7e:	8b 04 c5 e4 19 11 80 	mov    -0x7feee61c(,%eax,8),%eax
80101f85:	85 c0                	test   %eax,%eax
80101f87:	75 0a                	jne    80101f93 <writei+0x49>
      return -1;
80101f89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f8e:	e9 44 01 00 00       	jmp    801020d7 <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80101f93:	8b 45 08             	mov    0x8(%ebp),%eax
80101f96:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f9a:	98                   	cwtl   
80101f9b:	8b 04 c5 e4 19 11 80 	mov    -0x7feee61c(,%eax,8),%eax
80101fa2:	8b 55 14             	mov    0x14(%ebp),%edx
80101fa5:	89 54 24 08          	mov    %edx,0x8(%esp)
80101fa9:	8b 55 0c             	mov    0xc(%ebp),%edx
80101fac:	89 54 24 04          	mov    %edx,0x4(%esp)
80101fb0:	8b 55 08             	mov    0x8(%ebp),%edx
80101fb3:	89 14 24             	mov    %edx,(%esp)
80101fb6:	ff d0                	call   *%eax
80101fb8:	e9 1a 01 00 00       	jmp    801020d7 <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
80101fbd:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc0:	8b 40 58             	mov    0x58(%eax),%eax
80101fc3:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fc6:	72 0d                	jb     80101fd5 <writei+0x8b>
80101fc8:	8b 45 14             	mov    0x14(%ebp),%eax
80101fcb:	8b 55 10             	mov    0x10(%ebp),%edx
80101fce:	01 d0                	add    %edx,%eax
80101fd0:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fd3:	73 0a                	jae    80101fdf <writei+0x95>
    return -1;
80101fd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fda:	e9 f8 00 00 00       	jmp    801020d7 <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
80101fdf:	8b 45 14             	mov    0x14(%ebp),%eax
80101fe2:	8b 55 10             	mov    0x10(%ebp),%edx
80101fe5:	01 d0                	add    %edx,%eax
80101fe7:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101fec:	76 0a                	jbe    80101ff8 <writei+0xae>
    return -1;
80101fee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ff3:	e9 df 00 00 00       	jmp    801020d7 <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101ff8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101fff:	e9 9f 00 00 00       	jmp    801020a3 <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102004:	8b 45 10             	mov    0x10(%ebp),%eax
80102007:	c1 e8 09             	shr    $0x9,%eax
8010200a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010200e:	8b 45 08             	mov    0x8(%ebp),%eax
80102011:	89 04 24             	mov    %eax,(%esp)
80102014:	e8 50 fb ff ff       	call   80101b69 <bmap>
80102019:	8b 55 08             	mov    0x8(%ebp),%edx
8010201c:	8b 12                	mov    (%edx),%edx
8010201e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102022:	89 14 24             	mov    %edx,(%esp)
80102025:	e8 8b e1 ff ff       	call   801001b5 <bread>
8010202a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010202d:	8b 45 10             	mov    0x10(%ebp),%eax
80102030:	25 ff 01 00 00       	and    $0x1ff,%eax
80102035:	89 c2                	mov    %eax,%edx
80102037:	b8 00 02 00 00       	mov    $0x200,%eax
8010203c:	29 d0                	sub    %edx,%eax
8010203e:	89 c2                	mov    %eax,%edx
80102040:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102043:	8b 4d 14             	mov    0x14(%ebp),%ecx
80102046:	29 c1                	sub    %eax,%ecx
80102048:	89 c8                	mov    %ecx,%eax
8010204a:	39 c2                	cmp    %eax,%edx
8010204c:	0f 46 c2             	cmovbe %edx,%eax
8010204f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102052:	8b 45 10             	mov    0x10(%ebp),%eax
80102055:	25 ff 01 00 00       	and    $0x1ff,%eax
8010205a:	8d 50 50             	lea    0x50(%eax),%edx
8010205d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102060:	01 d0                	add    %edx,%eax
80102062:	8d 50 0c             	lea    0xc(%eax),%edx
80102065:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102068:	89 44 24 08          	mov    %eax,0x8(%esp)
8010206c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010206f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102073:	89 14 24             	mov    %edx,(%esp)
80102076:	e8 2b 30 00 00       	call   801050a6 <memmove>
    log_write(bp);
8010207b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010207e:	89 04 24             	mov    %eax,(%esp)
80102081:	e8 f8 15 00 00       	call   8010367e <log_write>
    brelse(bp);
80102086:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102089:	89 04 24             	mov    %eax,(%esp)
8010208c:	e8 9b e1 ff ff       	call   8010022c <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102091:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102094:	01 45 f4             	add    %eax,-0xc(%ebp)
80102097:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010209a:	01 45 10             	add    %eax,0x10(%ebp)
8010209d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020a0:	01 45 0c             	add    %eax,0xc(%ebp)
801020a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020a6:	3b 45 14             	cmp    0x14(%ebp),%eax
801020a9:	0f 82 55 ff ff ff    	jb     80102004 <writei+0xba>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
801020af:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801020b3:	74 1f                	je     801020d4 <writei+0x18a>
801020b5:	8b 45 08             	mov    0x8(%ebp),%eax
801020b8:	8b 40 58             	mov    0x58(%eax),%eax
801020bb:	3b 45 10             	cmp    0x10(%ebp),%eax
801020be:	73 14                	jae    801020d4 <writei+0x18a>
    ip->size = off;
801020c0:	8b 45 08             	mov    0x8(%ebp),%eax
801020c3:	8b 55 10             	mov    0x10(%ebp),%edx
801020c6:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801020c9:	8b 45 08             	mov    0x8(%ebp),%eax
801020cc:	89 04 24             	mov    %eax,(%esp)
801020cf:	e8 b0 f6 ff ff       	call   80101784 <iupdate>
  }
  return n;
801020d4:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020d7:	c9                   	leave  
801020d8:	c3                   	ret    

801020d9 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801020d9:	55                   	push   %ebp
801020da:	89 e5                	mov    %esp,%ebp
801020dc:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
801020df:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801020e6:	00 
801020e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801020ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801020ee:	8b 45 08             	mov    0x8(%ebp),%eax
801020f1:	89 04 24             	mov    %eax,(%esp)
801020f4:	e8 50 30 00 00       	call   80105149 <strncmp>
}
801020f9:	c9                   	leave  
801020fa:	c3                   	ret    

801020fb <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801020fb:	55                   	push   %ebp
801020fc:	89 e5                	mov    %esp,%ebp
801020fe:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102101:	8b 45 08             	mov    0x8(%ebp),%eax
80102104:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102108:	66 83 f8 01          	cmp    $0x1,%ax
8010210c:	74 0c                	je     8010211a <dirlookup+0x1f>
    panic("dirlookup not DIR");
8010210e:	c7 04 24 b1 86 10 80 	movl   $0x801086b1,(%esp)
80102115:	e8 48 e4 ff ff       	call   80100562 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010211a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102121:	e9 88 00 00 00       	jmp    801021ae <dirlookup+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102126:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010212d:	00 
8010212e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102131:	89 44 24 08          	mov    %eax,0x8(%esp)
80102135:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102138:	89 44 24 04          	mov    %eax,0x4(%esp)
8010213c:	8b 45 08             	mov    0x8(%ebp),%eax
8010213f:	89 04 24             	mov    %eax,(%esp)
80102142:	e8 9f fc ff ff       	call   80101de6 <readi>
80102147:	83 f8 10             	cmp    $0x10,%eax
8010214a:	74 0c                	je     80102158 <dirlookup+0x5d>
      panic("dirlookup read");
8010214c:	c7 04 24 c3 86 10 80 	movl   $0x801086c3,(%esp)
80102153:	e8 0a e4 ff ff       	call   80100562 <panic>
    if(de.inum == 0)
80102158:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010215c:	66 85 c0             	test   %ax,%ax
8010215f:	75 02                	jne    80102163 <dirlookup+0x68>
      continue;
80102161:	eb 47                	jmp    801021aa <dirlookup+0xaf>
    if(namecmp(name, de.name) == 0){
80102163:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102166:	83 c0 02             	add    $0x2,%eax
80102169:	89 44 24 04          	mov    %eax,0x4(%esp)
8010216d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102170:	89 04 24             	mov    %eax,(%esp)
80102173:	e8 61 ff ff ff       	call   801020d9 <namecmp>
80102178:	85 c0                	test   %eax,%eax
8010217a:	75 2e                	jne    801021aa <dirlookup+0xaf>
      // entry matches path element
      if(poff)
8010217c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102180:	74 08                	je     8010218a <dirlookup+0x8f>
        *poff = off;
80102182:	8b 45 10             	mov    0x10(%ebp),%eax
80102185:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102188:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010218a:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010218e:	0f b7 c0             	movzwl %ax,%eax
80102191:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102194:	8b 45 08             	mov    0x8(%ebp),%eax
80102197:	8b 00                	mov    (%eax),%eax
80102199:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010219c:	89 54 24 04          	mov    %edx,0x4(%esp)
801021a0:	89 04 24             	mov    %eax,(%esp)
801021a3:	e8 9a f6 ff ff       	call   80101842 <iget>
801021a8:	eb 18                	jmp    801021c2 <dirlookup+0xc7>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
801021aa:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801021ae:	8b 45 08             	mov    0x8(%ebp),%eax
801021b1:	8b 40 58             	mov    0x58(%eax),%eax
801021b4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801021b7:	0f 87 69 ff ff ff    	ja     80102126 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
801021bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801021c2:	c9                   	leave  
801021c3:	c3                   	ret    

801021c4 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801021c4:	55                   	push   %ebp
801021c5:	89 e5                	mov    %esp,%ebp
801021c7:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801021ca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801021d1:	00 
801021d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801021d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801021d9:	8b 45 08             	mov    0x8(%ebp),%eax
801021dc:	89 04 24             	mov    %eax,(%esp)
801021df:	e8 17 ff ff ff       	call   801020fb <dirlookup>
801021e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801021e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801021eb:	74 15                	je     80102202 <dirlink+0x3e>
    iput(ip);
801021ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021f0:	89 04 24             	mov    %eax,(%esp)
801021f3:	e8 a2 f8 ff ff       	call   80101a9a <iput>
    return -1;
801021f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021fd:	e9 b7 00 00 00       	jmp    801022b9 <dirlink+0xf5>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102202:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102209:	eb 46                	jmp    80102251 <dirlink+0x8d>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010220b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010220e:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102215:	00 
80102216:	89 44 24 08          	mov    %eax,0x8(%esp)
8010221a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010221d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102221:	8b 45 08             	mov    0x8(%ebp),%eax
80102224:	89 04 24             	mov    %eax,(%esp)
80102227:	e8 ba fb ff ff       	call   80101de6 <readi>
8010222c:	83 f8 10             	cmp    $0x10,%eax
8010222f:	74 0c                	je     8010223d <dirlink+0x79>
      panic("dirlink read");
80102231:	c7 04 24 d2 86 10 80 	movl   $0x801086d2,(%esp)
80102238:	e8 25 e3 ff ff       	call   80100562 <panic>
    if(de.inum == 0)
8010223d:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102241:	66 85 c0             	test   %ax,%ax
80102244:	75 02                	jne    80102248 <dirlink+0x84>
      break;
80102246:	eb 16                	jmp    8010225e <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102248:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010224b:	83 c0 10             	add    $0x10,%eax
8010224e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102251:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102254:	8b 45 08             	mov    0x8(%ebp),%eax
80102257:	8b 40 58             	mov    0x58(%eax),%eax
8010225a:	39 c2                	cmp    %eax,%edx
8010225c:	72 ad                	jb     8010220b <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
8010225e:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102265:	00 
80102266:	8b 45 0c             	mov    0xc(%ebp),%eax
80102269:	89 44 24 04          	mov    %eax,0x4(%esp)
8010226d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102270:	83 c0 02             	add    $0x2,%eax
80102273:	89 04 24             	mov    %eax,(%esp)
80102276:	e8 24 2f 00 00       	call   8010519f <strncpy>
  de.inum = inum;
8010227b:	8b 45 10             	mov    0x10(%ebp),%eax
8010227e:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102282:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102285:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010228c:	00 
8010228d:	89 44 24 08          	mov    %eax,0x8(%esp)
80102291:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102294:	89 44 24 04          	mov    %eax,0x4(%esp)
80102298:	8b 45 08             	mov    0x8(%ebp),%eax
8010229b:	89 04 24             	mov    %eax,(%esp)
8010229e:	e8 a7 fc ff ff       	call   80101f4a <writei>
801022a3:	83 f8 10             	cmp    $0x10,%eax
801022a6:	74 0c                	je     801022b4 <dirlink+0xf0>
    panic("dirlink");
801022a8:	c7 04 24 df 86 10 80 	movl   $0x801086df,(%esp)
801022af:	e8 ae e2 ff ff       	call   80100562 <panic>

  return 0;
801022b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022b9:	c9                   	leave  
801022ba:	c3                   	ret    

801022bb <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801022bb:	55                   	push   %ebp
801022bc:	89 e5                	mov    %esp,%ebp
801022be:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
801022c1:	eb 04                	jmp    801022c7 <skipelem+0xc>
    path++;
801022c3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
801022c7:	8b 45 08             	mov    0x8(%ebp),%eax
801022ca:	0f b6 00             	movzbl (%eax),%eax
801022cd:	3c 2f                	cmp    $0x2f,%al
801022cf:	74 f2                	je     801022c3 <skipelem+0x8>
    path++;
  if(*path == 0)
801022d1:	8b 45 08             	mov    0x8(%ebp),%eax
801022d4:	0f b6 00             	movzbl (%eax),%eax
801022d7:	84 c0                	test   %al,%al
801022d9:	75 0a                	jne    801022e5 <skipelem+0x2a>
    return 0;
801022db:	b8 00 00 00 00       	mov    $0x0,%eax
801022e0:	e9 86 00 00 00       	jmp    8010236b <skipelem+0xb0>
  s = path;
801022e5:	8b 45 08             	mov    0x8(%ebp),%eax
801022e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801022eb:	eb 04                	jmp    801022f1 <skipelem+0x36>
    path++;
801022ed:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801022f1:	8b 45 08             	mov    0x8(%ebp),%eax
801022f4:	0f b6 00             	movzbl (%eax),%eax
801022f7:	3c 2f                	cmp    $0x2f,%al
801022f9:	74 0a                	je     80102305 <skipelem+0x4a>
801022fb:	8b 45 08             	mov    0x8(%ebp),%eax
801022fe:	0f b6 00             	movzbl (%eax),%eax
80102301:	84 c0                	test   %al,%al
80102303:	75 e8                	jne    801022ed <skipelem+0x32>
    path++;
  len = path - s;
80102305:	8b 55 08             	mov    0x8(%ebp),%edx
80102308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010230b:	29 c2                	sub    %eax,%edx
8010230d:	89 d0                	mov    %edx,%eax
8010230f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102312:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102316:	7e 1c                	jle    80102334 <skipelem+0x79>
    memmove(name, s, DIRSIZ);
80102318:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010231f:	00 
80102320:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102323:	89 44 24 04          	mov    %eax,0x4(%esp)
80102327:	8b 45 0c             	mov    0xc(%ebp),%eax
8010232a:	89 04 24             	mov    %eax,(%esp)
8010232d:	e8 74 2d 00 00       	call   801050a6 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102332:	eb 2a                	jmp    8010235e <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102334:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102337:	89 44 24 08          	mov    %eax,0x8(%esp)
8010233b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010233e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102342:	8b 45 0c             	mov    0xc(%ebp),%eax
80102345:	89 04 24             	mov    %eax,(%esp)
80102348:	e8 59 2d 00 00       	call   801050a6 <memmove>
    name[len] = 0;
8010234d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102350:	8b 45 0c             	mov    0xc(%ebp),%eax
80102353:	01 d0                	add    %edx,%eax
80102355:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102358:	eb 04                	jmp    8010235e <skipelem+0xa3>
    path++;
8010235a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010235e:	8b 45 08             	mov    0x8(%ebp),%eax
80102361:	0f b6 00             	movzbl (%eax),%eax
80102364:	3c 2f                	cmp    $0x2f,%al
80102366:	74 f2                	je     8010235a <skipelem+0x9f>
    path++;
  return path;
80102368:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010236b:	c9                   	leave  
8010236c:	c3                   	ret    

8010236d <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010236d:	55                   	push   %ebp
8010236e:	89 e5                	mov    %esp,%ebp
80102370:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102373:	8b 45 08             	mov    0x8(%ebp),%eax
80102376:	0f b6 00             	movzbl (%eax),%eax
80102379:	3c 2f                	cmp    $0x2f,%al
8010237b:	75 1c                	jne    80102399 <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
8010237d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102384:	00 
80102385:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010238c:	e8 b1 f4 ff ff       	call   80101842 <iget>
80102391:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
80102394:	e9 ae 00 00 00       	jmp    80102447 <namex+0xda>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80102399:	e8 b4 1d 00 00       	call   80104152 <myproc>
8010239e:	8b 40 6c             	mov    0x6c(%eax),%eax
801023a1:	89 04 24             	mov    %eax,(%esp)
801023a4:	e8 6e f5 ff ff       	call   80101917 <idup>
801023a9:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801023ac:	e9 96 00 00 00       	jmp    80102447 <namex+0xda>
    ilock(ip);
801023b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023b4:	89 04 24             	mov    %eax,(%esp)
801023b7:	e8 8d f5 ff ff       	call   80101949 <ilock>
    if(ip->type != T_DIR){
801023bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023bf:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801023c3:	66 83 f8 01          	cmp    $0x1,%ax
801023c7:	74 15                	je     801023de <namex+0x71>
      iunlockput(ip);
801023c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023cc:	89 04 24             	mov    %eax,(%esp)
801023cf:	e8 77 f7 ff ff       	call   80101b4b <iunlockput>
      return 0;
801023d4:	b8 00 00 00 00       	mov    $0x0,%eax
801023d9:	e9 a3 00 00 00       	jmp    80102481 <namex+0x114>
    }
    if(nameiparent && *path == '\0'){
801023de:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801023e2:	74 1d                	je     80102401 <namex+0x94>
801023e4:	8b 45 08             	mov    0x8(%ebp),%eax
801023e7:	0f b6 00             	movzbl (%eax),%eax
801023ea:	84 c0                	test   %al,%al
801023ec:	75 13                	jne    80102401 <namex+0x94>
      // Stop one level early.
      iunlock(ip);
801023ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f1:	89 04 24             	mov    %eax,(%esp)
801023f4:	e8 5d f6 ff ff       	call   80101a56 <iunlock>
      return ip;
801023f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023fc:	e9 80 00 00 00       	jmp    80102481 <namex+0x114>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102401:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102408:	00 
80102409:	8b 45 10             	mov    0x10(%ebp),%eax
8010240c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102410:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102413:	89 04 24             	mov    %eax,(%esp)
80102416:	e8 e0 fc ff ff       	call   801020fb <dirlookup>
8010241b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010241e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102422:	75 12                	jne    80102436 <namex+0xc9>
      iunlockput(ip);
80102424:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102427:	89 04 24             	mov    %eax,(%esp)
8010242a:	e8 1c f7 ff ff       	call   80101b4b <iunlockput>
      return 0;
8010242f:	b8 00 00 00 00       	mov    $0x0,%eax
80102434:	eb 4b                	jmp    80102481 <namex+0x114>
    }
    iunlockput(ip);
80102436:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102439:	89 04 24             	mov    %eax,(%esp)
8010243c:	e8 0a f7 ff ff       	call   80101b4b <iunlockput>
    ip = next;
80102441:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102444:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
80102447:	8b 45 10             	mov    0x10(%ebp),%eax
8010244a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010244e:	8b 45 08             	mov    0x8(%ebp),%eax
80102451:	89 04 24             	mov    %eax,(%esp)
80102454:	e8 62 fe ff ff       	call   801022bb <skipelem>
80102459:	89 45 08             	mov    %eax,0x8(%ebp)
8010245c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102460:	0f 85 4b ff ff ff    	jne    801023b1 <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102466:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010246a:	74 12                	je     8010247e <namex+0x111>
    iput(ip);
8010246c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010246f:	89 04 24             	mov    %eax,(%esp)
80102472:	e8 23 f6 ff ff       	call   80101a9a <iput>
    return 0;
80102477:	b8 00 00 00 00       	mov    $0x0,%eax
8010247c:	eb 03                	jmp    80102481 <namex+0x114>
  }
  return ip;
8010247e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102481:	c9                   	leave  
80102482:	c3                   	ret    

80102483 <namei>:

struct inode*
namei(char *path)
{
80102483:	55                   	push   %ebp
80102484:	89 e5                	mov    %esp,%ebp
80102486:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102489:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010248c:	89 44 24 08          	mov    %eax,0x8(%esp)
80102490:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102497:	00 
80102498:	8b 45 08             	mov    0x8(%ebp),%eax
8010249b:	89 04 24             	mov    %eax,(%esp)
8010249e:	e8 ca fe ff ff       	call   8010236d <namex>
}
801024a3:	c9                   	leave  
801024a4:	c3                   	ret    

801024a5 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801024a5:	55                   	push   %ebp
801024a6:	89 e5                	mov    %esp,%ebp
801024a8:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
801024ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801024ae:	89 44 24 08          	mov    %eax,0x8(%esp)
801024b2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801024b9:	00 
801024ba:	8b 45 08             	mov    0x8(%ebp),%eax
801024bd:	89 04 24             	mov    %eax,(%esp)
801024c0:	e8 a8 fe ff ff       	call   8010236d <namex>
}
801024c5:	c9                   	leave  
801024c6:	c3                   	ret    

801024c7 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801024c7:	55                   	push   %ebp
801024c8:	89 e5                	mov    %esp,%ebp
801024ca:	83 ec 14             	sub    $0x14,%esp
801024cd:	8b 45 08             	mov    0x8(%ebp),%eax
801024d0:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801024d4:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801024d8:	89 c2                	mov    %eax,%edx
801024da:	ec                   	in     (%dx),%al
801024db:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801024de:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801024e2:	c9                   	leave  
801024e3:	c3                   	ret    

801024e4 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801024e4:	55                   	push   %ebp
801024e5:	89 e5                	mov    %esp,%ebp
801024e7:	57                   	push   %edi
801024e8:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801024e9:	8b 55 08             	mov    0x8(%ebp),%edx
801024ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024ef:	8b 45 10             	mov    0x10(%ebp),%eax
801024f2:	89 cb                	mov    %ecx,%ebx
801024f4:	89 df                	mov    %ebx,%edi
801024f6:	89 c1                	mov    %eax,%ecx
801024f8:	fc                   	cld    
801024f9:	f3 6d                	rep insl (%dx),%es:(%edi)
801024fb:	89 c8                	mov    %ecx,%eax
801024fd:	89 fb                	mov    %edi,%ebx
801024ff:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102502:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102505:	5b                   	pop    %ebx
80102506:	5f                   	pop    %edi
80102507:	5d                   	pop    %ebp
80102508:	c3                   	ret    

80102509 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102509:	55                   	push   %ebp
8010250a:	89 e5                	mov    %esp,%ebp
8010250c:	83 ec 08             	sub    $0x8,%esp
8010250f:	8b 55 08             	mov    0x8(%ebp),%edx
80102512:	8b 45 0c             	mov    0xc(%ebp),%eax
80102515:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102519:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010251c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102520:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102524:	ee                   	out    %al,(%dx)
}
80102525:	c9                   	leave  
80102526:	c3                   	ret    

80102527 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102527:	55                   	push   %ebp
80102528:	89 e5                	mov    %esp,%ebp
8010252a:	56                   	push   %esi
8010252b:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010252c:	8b 55 08             	mov    0x8(%ebp),%edx
8010252f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102532:	8b 45 10             	mov    0x10(%ebp),%eax
80102535:	89 cb                	mov    %ecx,%ebx
80102537:	89 de                	mov    %ebx,%esi
80102539:	89 c1                	mov    %eax,%ecx
8010253b:	fc                   	cld    
8010253c:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010253e:	89 c8                	mov    %ecx,%eax
80102540:	89 f3                	mov    %esi,%ebx
80102542:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102545:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102548:	5b                   	pop    %ebx
80102549:	5e                   	pop    %esi
8010254a:	5d                   	pop    %ebp
8010254b:	c3                   	ret    

8010254c <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010254c:	55                   	push   %ebp
8010254d:	89 e5                	mov    %esp,%ebp
8010254f:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102552:	90                   	nop
80102553:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010255a:	e8 68 ff ff ff       	call   801024c7 <inb>
8010255f:	0f b6 c0             	movzbl %al,%eax
80102562:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102565:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102568:	25 c0 00 00 00       	and    $0xc0,%eax
8010256d:	83 f8 40             	cmp    $0x40,%eax
80102570:	75 e1                	jne    80102553 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102572:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102576:	74 11                	je     80102589 <idewait+0x3d>
80102578:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010257b:	83 e0 21             	and    $0x21,%eax
8010257e:	85 c0                	test   %eax,%eax
80102580:	74 07                	je     80102589 <idewait+0x3d>
    return -1;
80102582:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102587:	eb 05                	jmp    8010258e <idewait+0x42>
  return 0;
80102589:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010258e:	c9                   	leave  
8010258f:	c3                   	ret    

80102590 <ideinit>:

void
ideinit(void)
{
80102590:	55                   	push   %ebp
80102591:	89 e5                	mov    %esp,%ebp
80102593:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102596:	c7 44 24 04 e7 86 10 	movl   $0x801086e7,0x4(%esp)
8010259d:	80 
8010259e:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801025a5:	e8 aa 27 00 00       	call   80104d54 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
801025aa:	a1 80 3d 11 80       	mov    0x80113d80,%eax
801025af:	83 e8 01             	sub    $0x1,%eax
801025b2:	89 44 24 04          	mov    %eax,0x4(%esp)
801025b6:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801025bd:	e8 69 04 00 00       	call   80102a2b <ioapicenable>
  idewait(0);
801025c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801025c9:	e8 7e ff ff ff       	call   8010254c <idewait>

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801025ce:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
801025d5:	00 
801025d6:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025dd:	e8 27 ff ff ff       	call   80102509 <outb>
  for(i=0; i<1000; i++){
801025e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025e9:	eb 20                	jmp    8010260b <ideinit+0x7b>
    if(inb(0x1f7) != 0){
801025eb:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801025f2:	e8 d0 fe ff ff       	call   801024c7 <inb>
801025f7:	84 c0                	test   %al,%al
801025f9:	74 0c                	je     80102607 <ideinit+0x77>
      havedisk1 = 1;
801025fb:	c7 05 18 b6 10 80 01 	movl   $0x1,0x8010b618
80102602:	00 00 00 
      break;
80102605:	eb 0d                	jmp    80102614 <ideinit+0x84>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102607:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010260b:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102612:	7e d7                	jle    801025eb <ideinit+0x5b>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102614:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
8010261b:	00 
8010261c:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102623:	e8 e1 fe ff ff       	call   80102509 <outb>
}
80102628:	c9                   	leave  
80102629:	c3                   	ret    

8010262a <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
8010262a:	55                   	push   %ebp
8010262b:	89 e5                	mov    %esp,%ebp
8010262d:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
80102630:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102634:	75 0c                	jne    80102642 <idestart+0x18>
    panic("idestart");
80102636:	c7 04 24 eb 86 10 80 	movl   $0x801086eb,(%esp)
8010263d:	e8 20 df ff ff       	call   80100562 <panic>
  if(b->blockno >= FSSIZE)
80102642:	8b 45 08             	mov    0x8(%ebp),%eax
80102645:	8b 40 08             	mov    0x8(%eax),%eax
80102648:	3d e7 03 00 00       	cmp    $0x3e7,%eax
8010264d:	76 0c                	jbe    8010265b <idestart+0x31>
    panic("incorrect blockno");
8010264f:	c7 04 24 f4 86 10 80 	movl   $0x801086f4,(%esp)
80102656:	e8 07 df ff ff       	call   80100562 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
8010265b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102662:	8b 45 08             	mov    0x8(%ebp),%eax
80102665:	8b 50 08             	mov    0x8(%eax),%edx
80102668:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010266b:	0f af c2             	imul   %edx,%eax
8010266e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
80102671:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102675:	75 07                	jne    8010267e <idestart+0x54>
80102677:	b8 20 00 00 00       	mov    $0x20,%eax
8010267c:	eb 05                	jmp    80102683 <idestart+0x59>
8010267e:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102683:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
80102686:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010268a:	75 07                	jne    80102693 <idestart+0x69>
8010268c:	b8 30 00 00 00       	mov    $0x30,%eax
80102691:	eb 05                	jmp    80102698 <idestart+0x6e>
80102693:	b8 c5 00 00 00       	mov    $0xc5,%eax
80102698:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
8010269b:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
8010269f:	7e 0c                	jle    801026ad <idestart+0x83>
801026a1:	c7 04 24 eb 86 10 80 	movl   $0x801086eb,(%esp)
801026a8:	e8 b5 de ff ff       	call   80100562 <panic>

  idewait(0);
801026ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801026b4:	e8 93 fe ff ff       	call   8010254c <idewait>
  outb(0x3f6, 0);  // generate interrupt
801026b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801026c0:	00 
801026c1:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
801026c8:	e8 3c fe ff ff       	call   80102509 <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
801026cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026d0:	0f b6 c0             	movzbl %al,%eax
801026d3:	89 44 24 04          	mov    %eax,0x4(%esp)
801026d7:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
801026de:	e8 26 fe ff ff       	call   80102509 <outb>
  outb(0x1f3, sector & 0xff);
801026e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026e6:	0f b6 c0             	movzbl %al,%eax
801026e9:	89 44 24 04          	mov    %eax,0x4(%esp)
801026ed:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
801026f4:	e8 10 fe ff ff       	call   80102509 <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
801026f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026fc:	c1 f8 08             	sar    $0x8,%eax
801026ff:	0f b6 c0             	movzbl %al,%eax
80102702:	89 44 24 04          	mov    %eax,0x4(%esp)
80102706:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
8010270d:	e8 f7 fd ff ff       	call   80102509 <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
80102712:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102715:	c1 f8 10             	sar    $0x10,%eax
80102718:	0f b6 c0             	movzbl %al,%eax
8010271b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010271f:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102726:	e8 de fd ff ff       	call   80102509 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010272b:	8b 45 08             	mov    0x8(%ebp),%eax
8010272e:	8b 40 04             	mov    0x4(%eax),%eax
80102731:	83 e0 01             	and    $0x1,%eax
80102734:	c1 e0 04             	shl    $0x4,%eax
80102737:	89 c2                	mov    %eax,%edx
80102739:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010273c:	c1 f8 18             	sar    $0x18,%eax
8010273f:	83 e0 0f             	and    $0xf,%eax
80102742:	09 d0                	or     %edx,%eax
80102744:	83 c8 e0             	or     $0xffffffe0,%eax
80102747:	0f b6 c0             	movzbl %al,%eax
8010274a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010274e:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102755:	e8 af fd ff ff       	call   80102509 <outb>
  if(b->flags & B_DIRTY){
8010275a:	8b 45 08             	mov    0x8(%ebp),%eax
8010275d:	8b 00                	mov    (%eax),%eax
8010275f:	83 e0 04             	and    $0x4,%eax
80102762:	85 c0                	test   %eax,%eax
80102764:	74 36                	je     8010279c <idestart+0x172>
    outb(0x1f7, write_cmd);
80102766:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102769:	0f b6 c0             	movzbl %al,%eax
8010276c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102770:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102777:	e8 8d fd ff ff       	call   80102509 <outb>
    outsl(0x1f0, b->data, BSIZE/4);
8010277c:	8b 45 08             	mov    0x8(%ebp),%eax
8010277f:	83 c0 5c             	add    $0x5c,%eax
80102782:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102789:	00 
8010278a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010278e:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102795:	e8 8d fd ff ff       	call   80102527 <outsl>
8010279a:	eb 16                	jmp    801027b2 <idestart+0x188>
  } else {
    outb(0x1f7, read_cmd);
8010279c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010279f:	0f b6 c0             	movzbl %al,%eax
801027a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801027a6:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801027ad:	e8 57 fd ff ff       	call   80102509 <outb>
  }
}
801027b2:	c9                   	leave  
801027b3:	c3                   	ret    

801027b4 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801027b4:	55                   	push   %ebp
801027b5:	89 e5                	mov    %esp,%ebp
801027b7:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801027ba:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801027c1:	e8 af 25 00 00       	call   80104d75 <acquire>

  if((b = idequeue) == 0){
801027c6:	a1 14 b6 10 80       	mov    0x8010b614,%eax
801027cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801027ce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027d2:	75 11                	jne    801027e5 <ideintr+0x31>
    release(&idelock);
801027d4:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801027db:	e8 fd 25 00 00       	call   80104ddd <release>
    return;
801027e0:	e9 90 00 00 00       	jmp    80102875 <ideintr+0xc1>
  }
  idequeue = b->qnext;
801027e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027e8:	8b 40 58             	mov    0x58(%eax),%eax
801027eb:	a3 14 b6 10 80       	mov    %eax,0x8010b614

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801027f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027f3:	8b 00                	mov    (%eax),%eax
801027f5:	83 e0 04             	and    $0x4,%eax
801027f8:	85 c0                	test   %eax,%eax
801027fa:	75 2e                	jne    8010282a <ideintr+0x76>
801027fc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102803:	e8 44 fd ff ff       	call   8010254c <idewait>
80102808:	85 c0                	test   %eax,%eax
8010280a:	78 1e                	js     8010282a <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
8010280c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010280f:	83 c0 5c             	add    $0x5c,%eax
80102812:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102819:	00 
8010281a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010281e:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102825:	e8 ba fc ff ff       	call   801024e4 <insl>

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
8010282a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282d:	8b 00                	mov    (%eax),%eax
8010282f:	83 c8 02             	or     $0x2,%eax
80102832:	89 c2                	mov    %eax,%edx
80102834:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102837:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010283c:	8b 00                	mov    (%eax),%eax
8010283e:	83 e0 fb             	and    $0xfffffffb,%eax
80102841:	89 c2                	mov    %eax,%edx
80102843:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102846:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102848:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010284b:	89 04 24             	mov    %eax,(%esp)
8010284e:	e8 2b 22 00 00       	call   80104a7e <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102853:	a1 14 b6 10 80       	mov    0x8010b614,%eax
80102858:	85 c0                	test   %eax,%eax
8010285a:	74 0d                	je     80102869 <ideintr+0xb5>
    idestart(idequeue);
8010285c:	a1 14 b6 10 80       	mov    0x8010b614,%eax
80102861:	89 04 24             	mov    %eax,(%esp)
80102864:	e8 c1 fd ff ff       	call   8010262a <idestart>

  release(&idelock);
80102869:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80102870:	e8 68 25 00 00       	call   80104ddd <release>
}
80102875:	c9                   	leave  
80102876:	c3                   	ret    

80102877 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102877:	55                   	push   %ebp
80102878:	89 e5                	mov    %esp,%ebp
8010287a:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
8010287d:	8b 45 08             	mov    0x8(%ebp),%eax
80102880:	83 c0 0c             	add    $0xc,%eax
80102883:	89 04 24             	mov    %eax,(%esp)
80102886:	e8 64 24 00 00       	call   80104cef <holdingsleep>
8010288b:	85 c0                	test   %eax,%eax
8010288d:	75 0c                	jne    8010289b <iderw+0x24>
    panic("iderw: buf not locked");
8010288f:	c7 04 24 06 87 10 80 	movl   $0x80108706,(%esp)
80102896:	e8 c7 dc ff ff       	call   80100562 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010289b:	8b 45 08             	mov    0x8(%ebp),%eax
8010289e:	8b 00                	mov    (%eax),%eax
801028a0:	83 e0 06             	and    $0x6,%eax
801028a3:	83 f8 02             	cmp    $0x2,%eax
801028a6:	75 0c                	jne    801028b4 <iderw+0x3d>
    panic("iderw: nothing to do");
801028a8:	c7 04 24 1c 87 10 80 	movl   $0x8010871c,(%esp)
801028af:	e8 ae dc ff ff       	call   80100562 <panic>
  if(b->dev != 0 && !havedisk1)
801028b4:	8b 45 08             	mov    0x8(%ebp),%eax
801028b7:	8b 40 04             	mov    0x4(%eax),%eax
801028ba:	85 c0                	test   %eax,%eax
801028bc:	74 15                	je     801028d3 <iderw+0x5c>
801028be:	a1 18 b6 10 80       	mov    0x8010b618,%eax
801028c3:	85 c0                	test   %eax,%eax
801028c5:	75 0c                	jne    801028d3 <iderw+0x5c>
    panic("iderw: ide disk 1 not present");
801028c7:	c7 04 24 31 87 10 80 	movl   $0x80108731,(%esp)
801028ce:	e8 8f dc ff ff       	call   80100562 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801028d3:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801028da:	e8 96 24 00 00       	call   80104d75 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
801028df:	8b 45 08             	mov    0x8(%ebp),%eax
801028e2:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801028e9:	c7 45 f4 14 b6 10 80 	movl   $0x8010b614,-0xc(%ebp)
801028f0:	eb 0b                	jmp    801028fd <iderw+0x86>
801028f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028f5:	8b 00                	mov    (%eax),%eax
801028f7:	83 c0 58             	add    $0x58,%eax
801028fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102900:	8b 00                	mov    (%eax),%eax
80102902:	85 c0                	test   %eax,%eax
80102904:	75 ec                	jne    801028f2 <iderw+0x7b>
    ;
  *pp = b;
80102906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102909:	8b 55 08             	mov    0x8(%ebp),%edx
8010290c:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
8010290e:	a1 14 b6 10 80       	mov    0x8010b614,%eax
80102913:	3b 45 08             	cmp    0x8(%ebp),%eax
80102916:	75 0d                	jne    80102925 <iderw+0xae>
    idestart(b);
80102918:	8b 45 08             	mov    0x8(%ebp),%eax
8010291b:	89 04 24             	mov    %eax,(%esp)
8010291e:	e8 07 fd ff ff       	call   8010262a <idestart>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102923:	eb 15                	jmp    8010293a <iderw+0xc3>
80102925:	eb 13                	jmp    8010293a <iderw+0xc3>
    sleep(b, &idelock);
80102927:	c7 44 24 04 e0 b5 10 	movl   $0x8010b5e0,0x4(%esp)
8010292e:	80 
8010292f:	8b 45 08             	mov    0x8(%ebp),%eax
80102932:	89 04 24             	mov    %eax,(%esp)
80102935:	e8 70 20 00 00       	call   801049aa <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010293a:	8b 45 08             	mov    0x8(%ebp),%eax
8010293d:	8b 00                	mov    (%eax),%eax
8010293f:	83 e0 06             	and    $0x6,%eax
80102942:	83 f8 02             	cmp    $0x2,%eax
80102945:	75 e0                	jne    80102927 <iderw+0xb0>
    sleep(b, &idelock);
  }


  release(&idelock);
80102947:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
8010294e:	e8 8a 24 00 00       	call   80104ddd <release>
}
80102953:	c9                   	leave  
80102954:	c3                   	ret    

80102955 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102955:	55                   	push   %ebp
80102956:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102958:	a1 b4 36 11 80       	mov    0x801136b4,%eax
8010295d:	8b 55 08             	mov    0x8(%ebp),%edx
80102960:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102962:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102967:	8b 40 10             	mov    0x10(%eax),%eax
}
8010296a:	5d                   	pop    %ebp
8010296b:	c3                   	ret    

8010296c <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010296c:	55                   	push   %ebp
8010296d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010296f:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102974:	8b 55 08             	mov    0x8(%ebp),%edx
80102977:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102979:	a1 b4 36 11 80       	mov    0x801136b4,%eax
8010297e:	8b 55 0c             	mov    0xc(%ebp),%edx
80102981:	89 50 10             	mov    %edx,0x10(%eax)
}
80102984:	5d                   	pop    %ebp
80102985:	c3                   	ret    

80102986 <ioapicinit>:

void
ioapicinit(void)
{
80102986:	55                   	push   %ebp
80102987:	89 e5                	mov    %esp,%ebp
80102989:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010298c:	c7 05 b4 36 11 80 00 	movl   $0xfec00000,0x801136b4
80102993:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102996:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010299d:	e8 b3 ff ff ff       	call   80102955 <ioapicread>
801029a2:	c1 e8 10             	shr    $0x10,%eax
801029a5:	25 ff 00 00 00       	and    $0xff,%eax
801029aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801029ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801029b4:	e8 9c ff ff ff       	call   80102955 <ioapicread>
801029b9:	c1 e8 18             	shr    $0x18,%eax
801029bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801029bf:	0f b6 05 e0 37 11 80 	movzbl 0x801137e0,%eax
801029c6:	0f b6 c0             	movzbl %al,%eax
801029c9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801029cc:	74 0c                	je     801029da <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801029ce:	c7 04 24 50 87 10 80 	movl   $0x80108750,(%esp)
801029d5:	e8 ee d9 ff ff       	call   801003c8 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801029da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801029e1:	eb 3e                	jmp    80102a21 <ioapicinit+0x9b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801029e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029e6:	83 c0 20             	add    $0x20,%eax
801029e9:	0d 00 00 01 00       	or     $0x10000,%eax
801029ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801029f1:	83 c2 08             	add    $0x8,%edx
801029f4:	01 d2                	add    %edx,%edx
801029f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801029fa:	89 14 24             	mov    %edx,(%esp)
801029fd:	e8 6a ff ff ff       	call   8010296c <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102a02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a05:	83 c0 08             	add    $0x8,%eax
80102a08:	01 c0                	add    %eax,%eax
80102a0a:	83 c0 01             	add    $0x1,%eax
80102a0d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102a14:	00 
80102a15:	89 04 24             	mov    %eax,(%esp)
80102a18:	e8 4f ff ff ff       	call   8010296c <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a1d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102a21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a24:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102a27:	7e ba                	jle    801029e3 <ioapicinit+0x5d>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102a29:	c9                   	leave  
80102a2a:	c3                   	ret    

80102a2b <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102a2b:	55                   	push   %ebp
80102a2c:	89 e5                	mov    %esp,%ebp
80102a2e:	83 ec 08             	sub    $0x8,%esp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102a31:	8b 45 08             	mov    0x8(%ebp),%eax
80102a34:	83 c0 20             	add    $0x20,%eax
80102a37:	8b 55 08             	mov    0x8(%ebp),%edx
80102a3a:	83 c2 08             	add    $0x8,%edx
80102a3d:	01 d2                	add    %edx,%edx
80102a3f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a43:	89 14 24             	mov    %edx,(%esp)
80102a46:	e8 21 ff ff ff       	call   8010296c <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102a4b:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a4e:	c1 e0 18             	shl    $0x18,%eax
80102a51:	8b 55 08             	mov    0x8(%ebp),%edx
80102a54:	83 c2 08             	add    $0x8,%edx
80102a57:	01 d2                	add    %edx,%edx
80102a59:	83 c2 01             	add    $0x1,%edx
80102a5c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a60:	89 14 24             	mov    %edx,(%esp)
80102a63:	e8 04 ff ff ff       	call   8010296c <ioapicwrite>
}
80102a68:	c9                   	leave  
80102a69:	c3                   	ret    

80102a6a <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102a6a:	55                   	push   %ebp
80102a6b:	89 e5                	mov    %esp,%ebp
80102a6d:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102a70:	c7 44 24 04 82 87 10 	movl   $0x80108782,0x4(%esp)
80102a77:	80 
80102a78:	c7 04 24 c0 36 11 80 	movl   $0x801136c0,(%esp)
80102a7f:	e8 d0 22 00 00       	call   80104d54 <initlock>
  kmem.use_lock = 0;
80102a84:	c7 05 f4 36 11 80 00 	movl   $0x0,0x801136f4
80102a8b:	00 00 00 
  freerange(vstart, vend);
80102a8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a91:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a95:	8b 45 08             	mov    0x8(%ebp),%eax
80102a98:	89 04 24             	mov    %eax,(%esp)
80102a9b:	e8 26 00 00 00       	call   80102ac6 <freerange>
}
80102aa0:	c9                   	leave  
80102aa1:	c3                   	ret    

80102aa2 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102aa2:	55                   	push   %ebp
80102aa3:	89 e5                	mov    %esp,%ebp
80102aa5:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
80102aab:	89 44 24 04          	mov    %eax,0x4(%esp)
80102aaf:	8b 45 08             	mov    0x8(%ebp),%eax
80102ab2:	89 04 24             	mov    %eax,(%esp)
80102ab5:	e8 0c 00 00 00       	call   80102ac6 <freerange>
  kmem.use_lock = 1;
80102aba:	c7 05 f4 36 11 80 01 	movl   $0x1,0x801136f4
80102ac1:	00 00 00 
}
80102ac4:	c9                   	leave  
80102ac5:	c3                   	ret    

80102ac6 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102ac6:	55                   	push   %ebp
80102ac7:	89 e5                	mov    %esp,%ebp
80102ac9:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102acc:	8b 45 08             	mov    0x8(%ebp),%eax
80102acf:	05 ff 0f 00 00       	add    $0xfff,%eax
80102ad4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102ad9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102adc:	eb 12                	jmp    80102af0 <freerange+0x2a>
    kfree(p);
80102ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae1:	89 04 24             	mov    %eax,(%esp)
80102ae4:	e8 16 00 00 00       	call   80102aff <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102ae9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102af3:	05 00 10 00 00       	add    $0x1000,%eax
80102af8:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102afb:	76 e1                	jbe    80102ade <freerange+0x18>
    kfree(p);
}
80102afd:	c9                   	leave  
80102afe:	c3                   	ret    

80102aff <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102aff:	55                   	push   %ebp
80102b00:	89 e5                	mov    %esp,%ebp
80102b02:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102b05:	8b 45 08             	mov    0x8(%ebp),%eax
80102b08:	25 ff 0f 00 00       	and    $0xfff,%eax
80102b0d:	85 c0                	test   %eax,%eax
80102b0f:	75 18                	jne    80102b29 <kfree+0x2a>
80102b11:	81 7d 08 74 69 11 80 	cmpl   $0x80116974,0x8(%ebp)
80102b18:	72 0f                	jb     80102b29 <kfree+0x2a>
80102b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b1d:	05 00 00 00 80       	add    $0x80000000,%eax
80102b22:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102b27:	76 0c                	jbe    80102b35 <kfree+0x36>
    panic("kfree");
80102b29:	c7 04 24 87 87 10 80 	movl   $0x80108787,(%esp)
80102b30:	e8 2d da ff ff       	call   80100562 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102b35:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102b3c:	00 
80102b3d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102b44:	00 
80102b45:	8b 45 08             	mov    0x8(%ebp),%eax
80102b48:	89 04 24             	mov    %eax,(%esp)
80102b4b:	e8 87 24 00 00       	call   80104fd7 <memset>

  if(kmem.use_lock)
80102b50:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102b55:	85 c0                	test   %eax,%eax
80102b57:	74 0c                	je     80102b65 <kfree+0x66>
    acquire(&kmem.lock);
80102b59:	c7 04 24 c0 36 11 80 	movl   $0x801136c0,(%esp)
80102b60:	e8 10 22 00 00       	call   80104d75 <acquire>
  r = (struct run*)v;
80102b65:	8b 45 08             	mov    0x8(%ebp),%eax
80102b68:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102b6b:	8b 15 f8 36 11 80    	mov    0x801136f8,%edx
80102b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b74:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b79:	a3 f8 36 11 80       	mov    %eax,0x801136f8
  if(kmem.use_lock)
80102b7e:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102b83:	85 c0                	test   %eax,%eax
80102b85:	74 0c                	je     80102b93 <kfree+0x94>
    release(&kmem.lock);
80102b87:	c7 04 24 c0 36 11 80 	movl   $0x801136c0,(%esp)
80102b8e:	e8 4a 22 00 00       	call   80104ddd <release>
}
80102b93:	c9                   	leave  
80102b94:	c3                   	ret    

80102b95 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102b95:	55                   	push   %ebp
80102b96:	89 e5                	mov    %esp,%ebp
80102b98:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102b9b:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102ba0:	85 c0                	test   %eax,%eax
80102ba2:	74 0c                	je     80102bb0 <kalloc+0x1b>
    acquire(&kmem.lock);
80102ba4:	c7 04 24 c0 36 11 80 	movl   $0x801136c0,(%esp)
80102bab:	e8 c5 21 00 00       	call   80104d75 <acquire>
  r = kmem.freelist;
80102bb0:	a1 f8 36 11 80       	mov    0x801136f8,%eax
80102bb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102bb8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102bbc:	74 0a                	je     80102bc8 <kalloc+0x33>
    kmem.freelist = r->next;
80102bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bc1:	8b 00                	mov    (%eax),%eax
80102bc3:	a3 f8 36 11 80       	mov    %eax,0x801136f8
  if(kmem.use_lock)
80102bc8:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102bcd:	85 c0                	test   %eax,%eax
80102bcf:	74 0c                	je     80102bdd <kalloc+0x48>
    release(&kmem.lock);
80102bd1:	c7 04 24 c0 36 11 80 	movl   $0x801136c0,(%esp)
80102bd8:	e8 00 22 00 00       	call   80104ddd <release>
  return (char*)r;
80102bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102be0:	c9                   	leave  
80102be1:	c3                   	ret    

80102be2 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102be2:	55                   	push   %ebp
80102be3:	89 e5                	mov    %esp,%ebp
80102be5:	83 ec 14             	sub    $0x14,%esp
80102be8:	8b 45 08             	mov    0x8(%ebp),%eax
80102beb:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bef:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102bf3:	89 c2                	mov    %eax,%edx
80102bf5:	ec                   	in     (%dx),%al
80102bf6:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102bf9:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102bfd:	c9                   	leave  
80102bfe:	c3                   	ret    

80102bff <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102bff:	55                   	push   %ebp
80102c00:	89 e5                	mov    %esp,%ebp
80102c02:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102c05:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102c0c:	e8 d1 ff ff ff       	call   80102be2 <inb>
80102c11:	0f b6 c0             	movzbl %al,%eax
80102c14:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c1a:	83 e0 01             	and    $0x1,%eax
80102c1d:	85 c0                	test   %eax,%eax
80102c1f:	75 0a                	jne    80102c2b <kbdgetc+0x2c>
    return -1;
80102c21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102c26:	e9 25 01 00 00       	jmp    80102d50 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102c2b:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102c32:	e8 ab ff ff ff       	call   80102be2 <inb>
80102c37:	0f b6 c0             	movzbl %al,%eax
80102c3a:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102c3d:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102c44:	75 17                	jne    80102c5d <kbdgetc+0x5e>
    shift |= E0ESC;
80102c46:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102c4b:	83 c8 40             	or     $0x40,%eax
80102c4e:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
    return 0;
80102c53:	b8 00 00 00 00       	mov    $0x0,%eax
80102c58:	e9 f3 00 00 00       	jmp    80102d50 <kbdgetc+0x151>
  } else if(data & 0x80){
80102c5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c60:	25 80 00 00 00       	and    $0x80,%eax
80102c65:	85 c0                	test   %eax,%eax
80102c67:	74 45                	je     80102cae <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102c69:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102c6e:	83 e0 40             	and    $0x40,%eax
80102c71:	85 c0                	test   %eax,%eax
80102c73:	75 08                	jne    80102c7d <kbdgetc+0x7e>
80102c75:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c78:	83 e0 7f             	and    $0x7f,%eax
80102c7b:	eb 03                	jmp    80102c80 <kbdgetc+0x81>
80102c7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c80:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102c83:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c86:	05 20 90 10 80       	add    $0x80109020,%eax
80102c8b:	0f b6 00             	movzbl (%eax),%eax
80102c8e:	83 c8 40             	or     $0x40,%eax
80102c91:	0f b6 c0             	movzbl %al,%eax
80102c94:	f7 d0                	not    %eax
80102c96:	89 c2                	mov    %eax,%edx
80102c98:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102c9d:	21 d0                	and    %edx,%eax
80102c9f:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
    return 0;
80102ca4:	b8 00 00 00 00       	mov    $0x0,%eax
80102ca9:	e9 a2 00 00 00       	jmp    80102d50 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102cae:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102cb3:	83 e0 40             	and    $0x40,%eax
80102cb6:	85 c0                	test   %eax,%eax
80102cb8:	74 14                	je     80102cce <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102cba:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102cc1:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102cc6:	83 e0 bf             	and    $0xffffffbf,%eax
80102cc9:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
  }

  shift |= shiftcode[data];
80102cce:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cd1:	05 20 90 10 80       	add    $0x80109020,%eax
80102cd6:	0f b6 00             	movzbl (%eax),%eax
80102cd9:	0f b6 d0             	movzbl %al,%edx
80102cdc:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102ce1:	09 d0                	or     %edx,%eax
80102ce3:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
  shift ^= togglecode[data];
80102ce8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ceb:	05 20 91 10 80       	add    $0x80109120,%eax
80102cf0:	0f b6 00             	movzbl (%eax),%eax
80102cf3:	0f b6 d0             	movzbl %al,%edx
80102cf6:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102cfb:	31 d0                	xor    %edx,%eax
80102cfd:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
  c = charcode[shift & (CTL | SHIFT)][data];
80102d02:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102d07:	83 e0 03             	and    $0x3,%eax
80102d0a:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102d11:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d14:	01 d0                	add    %edx,%eax
80102d16:	0f b6 00             	movzbl (%eax),%eax
80102d19:	0f b6 c0             	movzbl %al,%eax
80102d1c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102d1f:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102d24:	83 e0 08             	and    $0x8,%eax
80102d27:	85 c0                	test   %eax,%eax
80102d29:	74 22                	je     80102d4d <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102d2b:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102d2f:	76 0c                	jbe    80102d3d <kbdgetc+0x13e>
80102d31:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102d35:	77 06                	ja     80102d3d <kbdgetc+0x13e>
      c += 'A' - 'a';
80102d37:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102d3b:	eb 10                	jmp    80102d4d <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102d3d:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102d41:	76 0a                	jbe    80102d4d <kbdgetc+0x14e>
80102d43:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102d47:	77 04                	ja     80102d4d <kbdgetc+0x14e>
      c += 'a' - 'A';
80102d49:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102d4d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102d50:	c9                   	leave  
80102d51:	c3                   	ret    

80102d52 <kbdintr>:

void
kbdintr(void)
{
80102d52:	55                   	push   %ebp
80102d53:	89 e5                	mov    %esp,%ebp
80102d55:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102d58:	c7 04 24 ff 2b 10 80 	movl   $0x80102bff,(%esp)
80102d5f:	e8 85 da ff ff       	call   801007e9 <consoleintr>
}
80102d64:	c9                   	leave  
80102d65:	c3                   	ret    

80102d66 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d66:	55                   	push   %ebp
80102d67:	89 e5                	mov    %esp,%ebp
80102d69:	83 ec 14             	sub    $0x14,%esp
80102d6c:	8b 45 08             	mov    0x8(%ebp),%eax
80102d6f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d73:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d77:	89 c2                	mov    %eax,%edx
80102d79:	ec                   	in     (%dx),%al
80102d7a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d7d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d81:	c9                   	leave  
80102d82:	c3                   	ret    

80102d83 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102d83:	55                   	push   %ebp
80102d84:	89 e5                	mov    %esp,%ebp
80102d86:	83 ec 08             	sub    $0x8,%esp
80102d89:	8b 55 08             	mov    0x8(%ebp),%edx
80102d8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d8f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102d93:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d96:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102d9a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102d9e:	ee                   	out    %al,(%dx)
}
80102d9f:	c9                   	leave  
80102da0:	c3                   	ret    

80102da1 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102da1:	55                   	push   %ebp
80102da2:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102da4:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102da9:	8b 55 08             	mov    0x8(%ebp),%edx
80102dac:	c1 e2 02             	shl    $0x2,%edx
80102daf:	01 c2                	add    %eax,%edx
80102db1:	8b 45 0c             	mov    0xc(%ebp),%eax
80102db4:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102db6:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102dbb:	83 c0 20             	add    $0x20,%eax
80102dbe:	8b 00                	mov    (%eax),%eax
}
80102dc0:	5d                   	pop    %ebp
80102dc1:	c3                   	ret    

80102dc2 <lapicinit>:

void
lapicinit(void)
{
80102dc2:	55                   	push   %ebp
80102dc3:	89 e5                	mov    %esp,%ebp
80102dc5:	83 ec 08             	sub    $0x8,%esp
  if(!lapic)
80102dc8:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102dcd:	85 c0                	test   %eax,%eax
80102dcf:	75 05                	jne    80102dd6 <lapicinit+0x14>
    return;
80102dd1:	e9 43 01 00 00       	jmp    80102f19 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102dd6:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102ddd:	00 
80102dde:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102de5:	e8 b7 ff ff ff       	call   80102da1 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102dea:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102df1:	00 
80102df2:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102df9:	e8 a3 ff ff ff       	call   80102da1 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102dfe:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102e05:	00 
80102e06:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102e0d:	e8 8f ff ff ff       	call   80102da1 <lapicw>
  lapicw(TICR, 10000000);
80102e12:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102e19:	00 
80102e1a:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102e21:	e8 7b ff ff ff       	call   80102da1 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102e26:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e2d:	00 
80102e2e:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102e35:	e8 67 ff ff ff       	call   80102da1 <lapicw>
  lapicw(LINT1, MASKED);
80102e3a:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e41:	00 
80102e42:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102e49:	e8 53 ff ff ff       	call   80102da1 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102e4e:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102e53:	83 c0 30             	add    $0x30,%eax
80102e56:	8b 00                	mov    (%eax),%eax
80102e58:	c1 e8 10             	shr    $0x10,%eax
80102e5b:	0f b6 c0             	movzbl %al,%eax
80102e5e:	83 f8 03             	cmp    $0x3,%eax
80102e61:	76 14                	jbe    80102e77 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102e63:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e6a:	00 
80102e6b:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102e72:	e8 2a ff ff ff       	call   80102da1 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102e77:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102e7e:	00 
80102e7f:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102e86:	e8 16 ff ff ff       	call   80102da1 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102e8b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e92:	00 
80102e93:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e9a:	e8 02 ff ff ff       	call   80102da1 <lapicw>
  lapicw(ESR, 0);
80102e9f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ea6:	00 
80102ea7:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102eae:	e8 ee fe ff ff       	call   80102da1 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102eb3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102eba:	00 
80102ebb:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102ec2:	e8 da fe ff ff       	call   80102da1 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ec7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ece:	00 
80102ecf:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102ed6:	e8 c6 fe ff ff       	call   80102da1 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102edb:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102ee2:	00 
80102ee3:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102eea:	e8 b2 fe ff ff       	call   80102da1 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102eef:	90                   	nop
80102ef0:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102ef5:	05 00 03 00 00       	add    $0x300,%eax
80102efa:	8b 00                	mov    (%eax),%eax
80102efc:	25 00 10 00 00       	and    $0x1000,%eax
80102f01:	85 c0                	test   %eax,%eax
80102f03:	75 eb                	jne    80102ef0 <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102f05:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f0c:	00 
80102f0d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102f14:	e8 88 fe ff ff       	call   80102da1 <lapicw>
}
80102f19:	c9                   	leave  
80102f1a:	c3                   	ret    

80102f1b <lapicid>:

int
lapicid(void)
{
80102f1b:	55                   	push   %ebp
80102f1c:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80102f1e:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102f23:	85 c0                	test   %eax,%eax
80102f25:	75 07                	jne    80102f2e <lapicid+0x13>
    return 0;
80102f27:	b8 00 00 00 00       	mov    $0x0,%eax
80102f2c:	eb 0d                	jmp    80102f3b <lapicid+0x20>
  return lapic[ID] >> 24;
80102f2e:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102f33:	83 c0 20             	add    $0x20,%eax
80102f36:	8b 00                	mov    (%eax),%eax
80102f38:	c1 e8 18             	shr    $0x18,%eax
}
80102f3b:	5d                   	pop    %ebp
80102f3c:	c3                   	ret    

80102f3d <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102f3d:	55                   	push   %ebp
80102f3e:	89 e5                	mov    %esp,%ebp
80102f40:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102f43:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102f48:	85 c0                	test   %eax,%eax
80102f4a:	74 14                	je     80102f60 <lapiceoi+0x23>
    lapicw(EOI, 0);
80102f4c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f53:	00 
80102f54:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102f5b:	e8 41 fe ff ff       	call   80102da1 <lapicw>
}
80102f60:	c9                   	leave  
80102f61:	c3                   	ret    

80102f62 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102f62:	55                   	push   %ebp
80102f63:	89 e5                	mov    %esp,%ebp
}
80102f65:	5d                   	pop    %ebp
80102f66:	c3                   	ret    

80102f67 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102f67:	55                   	push   %ebp
80102f68:	89 e5                	mov    %esp,%ebp
80102f6a:	83 ec 1c             	sub    $0x1c,%esp
80102f6d:	8b 45 08             	mov    0x8(%ebp),%eax
80102f70:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102f73:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102f7a:	00 
80102f7b:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102f82:	e8 fc fd ff ff       	call   80102d83 <outb>
  outb(CMOS_PORT+1, 0x0A);
80102f87:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102f8e:	00 
80102f8f:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102f96:	e8 e8 fd ff ff       	call   80102d83 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102f9b:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102fa2:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102fa5:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102faa:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102fad:	8d 50 02             	lea    0x2(%eax),%edx
80102fb0:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fb3:	c1 e8 04             	shr    $0x4,%eax
80102fb6:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102fb9:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102fbd:	c1 e0 18             	shl    $0x18,%eax
80102fc0:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fc4:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102fcb:	e8 d1 fd ff ff       	call   80102da1 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102fd0:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80102fd7:	00 
80102fd8:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fdf:	e8 bd fd ff ff       	call   80102da1 <lapicw>
  microdelay(200);
80102fe4:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102feb:	e8 72 ff ff ff       	call   80102f62 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80102ff0:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80102ff7:	00 
80102ff8:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fff:	e8 9d fd ff ff       	call   80102da1 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103004:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
8010300b:	e8 52 ff ff ff       	call   80102f62 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103010:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103017:	eb 40                	jmp    80103059 <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
80103019:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010301d:	c1 e0 18             	shl    $0x18,%eax
80103020:	89 44 24 04          	mov    %eax,0x4(%esp)
80103024:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010302b:	e8 71 fd ff ff       	call   80102da1 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103030:	8b 45 0c             	mov    0xc(%ebp),%eax
80103033:	c1 e8 0c             	shr    $0xc,%eax
80103036:	80 cc 06             	or     $0x6,%ah
80103039:	89 44 24 04          	mov    %eax,0x4(%esp)
8010303d:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103044:	e8 58 fd ff ff       	call   80102da1 <lapicw>
    microdelay(200);
80103049:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103050:	e8 0d ff ff ff       	call   80102f62 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103055:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103059:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010305d:	7e ba                	jle    80103019 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010305f:	c9                   	leave  
80103060:	c3                   	ret    

80103061 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103061:	55                   	push   %ebp
80103062:	89 e5                	mov    %esp,%ebp
80103064:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
80103067:	8b 45 08             	mov    0x8(%ebp),%eax
8010306a:	0f b6 c0             	movzbl %al,%eax
8010306d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103071:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103078:	e8 06 fd ff ff       	call   80102d83 <outb>
  microdelay(200);
8010307d:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103084:	e8 d9 fe ff ff       	call   80102f62 <microdelay>

  return inb(CMOS_RETURN);
80103089:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103090:	e8 d1 fc ff ff       	call   80102d66 <inb>
80103095:	0f b6 c0             	movzbl %al,%eax
}
80103098:	c9                   	leave  
80103099:	c3                   	ret    

8010309a <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010309a:	55                   	push   %ebp
8010309b:	89 e5                	mov    %esp,%ebp
8010309d:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
801030a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801030a7:	e8 b5 ff ff ff       	call   80103061 <cmos_read>
801030ac:	8b 55 08             	mov    0x8(%ebp),%edx
801030af:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
801030b1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801030b8:	e8 a4 ff ff ff       	call   80103061 <cmos_read>
801030bd:	8b 55 08             	mov    0x8(%ebp),%edx
801030c0:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
801030c3:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801030ca:	e8 92 ff ff ff       	call   80103061 <cmos_read>
801030cf:	8b 55 08             	mov    0x8(%ebp),%edx
801030d2:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
801030d5:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
801030dc:	e8 80 ff ff ff       	call   80103061 <cmos_read>
801030e1:	8b 55 08             	mov    0x8(%ebp),%edx
801030e4:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801030e7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801030ee:	e8 6e ff ff ff       	call   80103061 <cmos_read>
801030f3:	8b 55 08             	mov    0x8(%ebp),%edx
801030f6:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801030f9:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
80103100:	e8 5c ff ff ff       	call   80103061 <cmos_read>
80103105:	8b 55 08             	mov    0x8(%ebp),%edx
80103108:	89 42 14             	mov    %eax,0x14(%edx)
}
8010310b:	c9                   	leave  
8010310c:	c3                   	ret    

8010310d <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010310d:	55                   	push   %ebp
8010310e:	89 e5                	mov    %esp,%ebp
80103110:	83 ec 58             	sub    $0x58,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103113:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
8010311a:	e8 42 ff ff ff       	call   80103061 <cmos_read>
8010311f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103122:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103125:	83 e0 04             	and    $0x4,%eax
80103128:	85 c0                	test   %eax,%eax
8010312a:	0f 94 c0             	sete   %al
8010312d:	0f b6 c0             	movzbl %al,%eax
80103130:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80103133:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103136:	89 04 24             	mov    %eax,(%esp)
80103139:	e8 5c ff ff ff       	call   8010309a <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
8010313e:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80103145:	e8 17 ff ff ff       	call   80103061 <cmos_read>
8010314a:	25 80 00 00 00       	and    $0x80,%eax
8010314f:	85 c0                	test   %eax,%eax
80103151:	74 02                	je     80103155 <cmostime+0x48>
        continue;
80103153:	eb 36                	jmp    8010318b <cmostime+0x7e>
    fill_rtcdate(&t2);
80103155:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103158:	89 04 24             	mov    %eax,(%esp)
8010315b:	e8 3a ff ff ff       	call   8010309a <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80103160:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
80103167:	00 
80103168:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010316b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010316f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103172:	89 04 24             	mov    %eax,(%esp)
80103175:	e8 d4 1e 00 00       	call   8010504e <memcmp>
8010317a:	85 c0                	test   %eax,%eax
8010317c:	75 0d                	jne    8010318b <cmostime+0x7e>
      break;
8010317e:	90                   	nop
  }

  // convert
  if(bcd) {
8010317f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103183:	0f 84 ac 00 00 00    	je     80103235 <cmostime+0x128>
80103189:	eb 02                	jmp    8010318d <cmostime+0x80>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
8010318b:	eb a6                	jmp    80103133 <cmostime+0x26>

  // convert
  if(bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010318d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103190:	c1 e8 04             	shr    $0x4,%eax
80103193:	89 c2                	mov    %eax,%edx
80103195:	89 d0                	mov    %edx,%eax
80103197:	c1 e0 02             	shl    $0x2,%eax
8010319a:	01 d0                	add    %edx,%eax
8010319c:	01 c0                	add    %eax,%eax
8010319e:	8b 55 d8             	mov    -0x28(%ebp),%edx
801031a1:	83 e2 0f             	and    $0xf,%edx
801031a4:	01 d0                	add    %edx,%eax
801031a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801031a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801031ac:	c1 e8 04             	shr    $0x4,%eax
801031af:	89 c2                	mov    %eax,%edx
801031b1:	89 d0                	mov    %edx,%eax
801031b3:	c1 e0 02             	shl    $0x2,%eax
801031b6:	01 d0                	add    %edx,%eax
801031b8:	01 c0                	add    %eax,%eax
801031ba:	8b 55 dc             	mov    -0x24(%ebp),%edx
801031bd:	83 e2 0f             	and    $0xf,%edx
801031c0:	01 d0                	add    %edx,%eax
801031c2:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
801031c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801031c8:	c1 e8 04             	shr    $0x4,%eax
801031cb:	89 c2                	mov    %eax,%edx
801031cd:	89 d0                	mov    %edx,%eax
801031cf:	c1 e0 02             	shl    $0x2,%eax
801031d2:	01 d0                	add    %edx,%eax
801031d4:	01 c0                	add    %eax,%eax
801031d6:	8b 55 e0             	mov    -0x20(%ebp),%edx
801031d9:	83 e2 0f             	and    $0xf,%edx
801031dc:	01 d0                	add    %edx,%eax
801031de:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801031e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801031e4:	c1 e8 04             	shr    $0x4,%eax
801031e7:	89 c2                	mov    %eax,%edx
801031e9:	89 d0                	mov    %edx,%eax
801031eb:	c1 e0 02             	shl    $0x2,%eax
801031ee:	01 d0                	add    %edx,%eax
801031f0:	01 c0                	add    %eax,%eax
801031f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801031f5:	83 e2 0f             	and    $0xf,%edx
801031f8:	01 d0                	add    %edx,%eax
801031fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801031fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103200:	c1 e8 04             	shr    $0x4,%eax
80103203:	89 c2                	mov    %eax,%edx
80103205:	89 d0                	mov    %edx,%eax
80103207:	c1 e0 02             	shl    $0x2,%eax
8010320a:	01 d0                	add    %edx,%eax
8010320c:	01 c0                	add    %eax,%eax
8010320e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103211:	83 e2 0f             	and    $0xf,%edx
80103214:	01 d0                	add    %edx,%eax
80103216:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103219:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010321c:	c1 e8 04             	shr    $0x4,%eax
8010321f:	89 c2                	mov    %eax,%edx
80103221:	89 d0                	mov    %edx,%eax
80103223:	c1 e0 02             	shl    $0x2,%eax
80103226:	01 d0                	add    %edx,%eax
80103228:	01 c0                	add    %eax,%eax
8010322a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010322d:	83 e2 0f             	and    $0xf,%edx
80103230:	01 d0                	add    %edx,%eax
80103232:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103235:	8b 45 08             	mov    0x8(%ebp),%eax
80103238:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010323b:	89 10                	mov    %edx,(%eax)
8010323d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103240:	89 50 04             	mov    %edx,0x4(%eax)
80103243:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103246:	89 50 08             	mov    %edx,0x8(%eax)
80103249:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010324c:	89 50 0c             	mov    %edx,0xc(%eax)
8010324f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103252:	89 50 10             	mov    %edx,0x10(%eax)
80103255:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103258:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
8010325b:	8b 45 08             	mov    0x8(%ebp),%eax
8010325e:	8b 40 14             	mov    0x14(%eax),%eax
80103261:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103267:	8b 45 08             	mov    0x8(%ebp),%eax
8010326a:	89 50 14             	mov    %edx,0x14(%eax)
}
8010326d:	c9                   	leave  
8010326e:	c3                   	ret    

8010326f <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
8010326f:	55                   	push   %ebp
80103270:	89 e5                	mov    %esp,%ebp
80103272:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103275:	c7 44 24 04 8d 87 10 	movl   $0x8010878d,0x4(%esp)
8010327c:	80 
8010327d:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80103284:	e8 cb 1a 00 00       	call   80104d54 <initlock>
  readsb(dev, &sb);
80103289:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010328c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103290:	8b 45 08             	mov    0x8(%ebp),%eax
80103293:	89 04 24             	mov    %eax,(%esp)
80103296:	e8 a1 e0 ff ff       	call   8010133c <readsb>
  log.start = sb.logstart;
8010329b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010329e:	a3 34 37 11 80       	mov    %eax,0x80113734
  log.size = sb.nlog;
801032a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032a6:	a3 38 37 11 80       	mov    %eax,0x80113738
  log.dev = dev;
801032ab:	8b 45 08             	mov    0x8(%ebp),%eax
801032ae:	a3 44 37 11 80       	mov    %eax,0x80113744
  recover_from_log();
801032b3:	e8 9a 01 00 00       	call   80103452 <recover_from_log>
}
801032b8:	c9                   	leave  
801032b9:	c3                   	ret    

801032ba <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
801032ba:	55                   	push   %ebp
801032bb:	89 e5                	mov    %esp,%ebp
801032bd:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801032c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032c7:	e9 8c 00 00 00       	jmp    80103358 <install_trans+0x9e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801032cc:	8b 15 34 37 11 80    	mov    0x80113734,%edx
801032d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032d5:	01 d0                	add    %edx,%eax
801032d7:	83 c0 01             	add    $0x1,%eax
801032da:	89 c2                	mov    %eax,%edx
801032dc:	a1 44 37 11 80       	mov    0x80113744,%eax
801032e1:	89 54 24 04          	mov    %edx,0x4(%esp)
801032e5:	89 04 24             	mov    %eax,(%esp)
801032e8:	e8 c8 ce ff ff       	call   801001b5 <bread>
801032ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801032f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032f3:	83 c0 10             	add    $0x10,%eax
801032f6:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
801032fd:	89 c2                	mov    %eax,%edx
801032ff:	a1 44 37 11 80       	mov    0x80113744,%eax
80103304:	89 54 24 04          	mov    %edx,0x4(%esp)
80103308:	89 04 24             	mov    %eax,(%esp)
8010330b:	e8 a5 ce ff ff       	call   801001b5 <bread>
80103310:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103313:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103316:	8d 50 5c             	lea    0x5c(%eax),%edx
80103319:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010331c:	83 c0 5c             	add    $0x5c,%eax
8010331f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103326:	00 
80103327:	89 54 24 04          	mov    %edx,0x4(%esp)
8010332b:	89 04 24             	mov    %eax,(%esp)
8010332e:	e8 73 1d 00 00       	call   801050a6 <memmove>
    bwrite(dbuf);  // write dst to disk
80103333:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103336:	89 04 24             	mov    %eax,(%esp)
80103339:	e8 ae ce ff ff       	call   801001ec <bwrite>
    brelse(lbuf);
8010333e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103341:	89 04 24             	mov    %eax,(%esp)
80103344:	e8 e3 ce ff ff       	call   8010022c <brelse>
    brelse(dbuf);
80103349:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010334c:	89 04 24             	mov    %eax,(%esp)
8010334f:	e8 d8 ce ff ff       	call   8010022c <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103354:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103358:	a1 48 37 11 80       	mov    0x80113748,%eax
8010335d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103360:	0f 8f 66 ff ff ff    	jg     801032cc <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
80103366:	c9                   	leave  
80103367:	c3                   	ret    

80103368 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103368:	55                   	push   %ebp
80103369:	89 e5                	mov    %esp,%ebp
8010336b:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010336e:	a1 34 37 11 80       	mov    0x80113734,%eax
80103373:	89 c2                	mov    %eax,%edx
80103375:	a1 44 37 11 80       	mov    0x80113744,%eax
8010337a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010337e:	89 04 24             	mov    %eax,(%esp)
80103381:	e8 2f ce ff ff       	call   801001b5 <bread>
80103386:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103389:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010338c:	83 c0 5c             	add    $0x5c,%eax
8010338f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103392:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103395:	8b 00                	mov    (%eax),%eax
80103397:	a3 48 37 11 80       	mov    %eax,0x80113748
  for (i = 0; i < log.lh.n; i++) {
8010339c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033a3:	eb 1b                	jmp    801033c0 <read_head+0x58>
    log.lh.block[i] = lh->block[i];
801033a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033ab:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801033af:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033b2:	83 c2 10             	add    $0x10,%edx
801033b5:	89 04 95 0c 37 11 80 	mov    %eax,-0x7feec8f4(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801033bc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033c0:	a1 48 37 11 80       	mov    0x80113748,%eax
801033c5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033c8:	7f db                	jg     801033a5 <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
801033ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033cd:	89 04 24             	mov    %eax,(%esp)
801033d0:	e8 57 ce ff ff       	call   8010022c <brelse>
}
801033d5:	c9                   	leave  
801033d6:	c3                   	ret    

801033d7 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801033d7:	55                   	push   %ebp
801033d8:	89 e5                	mov    %esp,%ebp
801033da:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801033dd:	a1 34 37 11 80       	mov    0x80113734,%eax
801033e2:	89 c2                	mov    %eax,%edx
801033e4:	a1 44 37 11 80       	mov    0x80113744,%eax
801033e9:	89 54 24 04          	mov    %edx,0x4(%esp)
801033ed:	89 04 24             	mov    %eax,(%esp)
801033f0:	e8 c0 cd ff ff       	call   801001b5 <bread>
801033f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801033f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033fb:	83 c0 5c             	add    $0x5c,%eax
801033fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103401:	8b 15 48 37 11 80    	mov    0x80113748,%edx
80103407:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010340a:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010340c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103413:	eb 1b                	jmp    80103430 <write_head+0x59>
    hb->block[i] = log.lh.block[i];
80103415:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103418:	83 c0 10             	add    $0x10,%eax
8010341b:	8b 0c 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%ecx
80103422:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103425:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103428:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010342c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103430:	a1 48 37 11 80       	mov    0x80113748,%eax
80103435:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103438:	7f db                	jg     80103415 <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
8010343a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010343d:	89 04 24             	mov    %eax,(%esp)
80103440:	e8 a7 cd ff ff       	call   801001ec <bwrite>
  brelse(buf);
80103445:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103448:	89 04 24             	mov    %eax,(%esp)
8010344b:	e8 dc cd ff ff       	call   8010022c <brelse>
}
80103450:	c9                   	leave  
80103451:	c3                   	ret    

80103452 <recover_from_log>:

static void
recover_from_log(void)
{
80103452:	55                   	push   %ebp
80103453:	89 e5                	mov    %esp,%ebp
80103455:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103458:	e8 0b ff ff ff       	call   80103368 <read_head>
  install_trans(); // if committed, copy from log to disk
8010345d:	e8 58 fe ff ff       	call   801032ba <install_trans>
  log.lh.n = 0;
80103462:	c7 05 48 37 11 80 00 	movl   $0x0,0x80113748
80103469:	00 00 00 
  write_head(); // clear the log
8010346c:	e8 66 ff ff ff       	call   801033d7 <write_head>
}
80103471:	c9                   	leave  
80103472:	c3                   	ret    

80103473 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103473:	55                   	push   %ebp
80103474:	89 e5                	mov    %esp,%ebp
80103476:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103479:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80103480:	e8 f0 18 00 00       	call   80104d75 <acquire>
  while(1){
    if(log.committing){
80103485:	a1 40 37 11 80       	mov    0x80113740,%eax
8010348a:	85 c0                	test   %eax,%eax
8010348c:	74 16                	je     801034a4 <begin_op+0x31>
      sleep(&log, &log.lock);
8010348e:	c7 44 24 04 00 37 11 	movl   $0x80113700,0x4(%esp)
80103495:	80 
80103496:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
8010349d:	e8 08 15 00 00       	call   801049aa <sleep>
801034a2:	eb 4f                	jmp    801034f3 <begin_op+0x80>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801034a4:	8b 0d 48 37 11 80    	mov    0x80113748,%ecx
801034aa:	a1 3c 37 11 80       	mov    0x8011373c,%eax
801034af:	8d 50 01             	lea    0x1(%eax),%edx
801034b2:	89 d0                	mov    %edx,%eax
801034b4:	c1 e0 02             	shl    $0x2,%eax
801034b7:	01 d0                	add    %edx,%eax
801034b9:	01 c0                	add    %eax,%eax
801034bb:	01 c8                	add    %ecx,%eax
801034bd:	83 f8 1e             	cmp    $0x1e,%eax
801034c0:	7e 16                	jle    801034d8 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801034c2:	c7 44 24 04 00 37 11 	movl   $0x80113700,0x4(%esp)
801034c9:	80 
801034ca:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
801034d1:	e8 d4 14 00 00       	call   801049aa <sleep>
801034d6:	eb 1b                	jmp    801034f3 <begin_op+0x80>
    } else {
      log.outstanding += 1;
801034d8:	a1 3c 37 11 80       	mov    0x8011373c,%eax
801034dd:	83 c0 01             	add    $0x1,%eax
801034e0:	a3 3c 37 11 80       	mov    %eax,0x8011373c
      release(&log.lock);
801034e5:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
801034ec:	e8 ec 18 00 00       	call   80104ddd <release>
      break;
801034f1:	eb 02                	jmp    801034f5 <begin_op+0x82>
    }
  }
801034f3:	eb 90                	jmp    80103485 <begin_op+0x12>
}
801034f5:	c9                   	leave  
801034f6:	c3                   	ret    

801034f7 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801034f7:	55                   	push   %ebp
801034f8:	89 e5                	mov    %esp,%ebp
801034fa:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
801034fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103504:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
8010350b:	e8 65 18 00 00       	call   80104d75 <acquire>
  log.outstanding -= 1;
80103510:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80103515:	83 e8 01             	sub    $0x1,%eax
80103518:	a3 3c 37 11 80       	mov    %eax,0x8011373c
  if(log.committing)
8010351d:	a1 40 37 11 80       	mov    0x80113740,%eax
80103522:	85 c0                	test   %eax,%eax
80103524:	74 0c                	je     80103532 <end_op+0x3b>
    panic("log.committing");
80103526:	c7 04 24 91 87 10 80 	movl   $0x80108791,(%esp)
8010352d:	e8 30 d0 ff ff       	call   80100562 <panic>
  if(log.outstanding == 0){
80103532:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80103537:	85 c0                	test   %eax,%eax
80103539:	75 13                	jne    8010354e <end_op+0x57>
    do_commit = 1;
8010353b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103542:	c7 05 40 37 11 80 01 	movl   $0x1,0x80113740
80103549:	00 00 00 
8010354c:	eb 0c                	jmp    8010355a <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
8010354e:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80103555:	e8 24 15 00 00       	call   80104a7e <wakeup>
  }
  release(&log.lock);
8010355a:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80103561:	e8 77 18 00 00       	call   80104ddd <release>

  if(do_commit){
80103566:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010356a:	74 33                	je     8010359f <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010356c:	e8 de 00 00 00       	call   8010364f <commit>
    acquire(&log.lock);
80103571:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80103578:	e8 f8 17 00 00       	call   80104d75 <acquire>
    log.committing = 0;
8010357d:	c7 05 40 37 11 80 00 	movl   $0x0,0x80113740
80103584:	00 00 00 
    wakeup(&log);
80103587:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
8010358e:	e8 eb 14 00 00       	call   80104a7e <wakeup>
    release(&log.lock);
80103593:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
8010359a:	e8 3e 18 00 00       	call   80104ddd <release>
  }
}
8010359f:	c9                   	leave  
801035a0:	c3                   	ret    

801035a1 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801035a1:	55                   	push   %ebp
801035a2:	89 e5                	mov    %esp,%ebp
801035a4:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801035a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035ae:	e9 8c 00 00 00       	jmp    8010363f <write_log+0x9e>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801035b3:	8b 15 34 37 11 80    	mov    0x80113734,%edx
801035b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035bc:	01 d0                	add    %edx,%eax
801035be:	83 c0 01             	add    $0x1,%eax
801035c1:	89 c2                	mov    %eax,%edx
801035c3:	a1 44 37 11 80       	mov    0x80113744,%eax
801035c8:	89 54 24 04          	mov    %edx,0x4(%esp)
801035cc:	89 04 24             	mov    %eax,(%esp)
801035cf:	e8 e1 cb ff ff       	call   801001b5 <bread>
801035d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801035d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035da:	83 c0 10             	add    $0x10,%eax
801035dd:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
801035e4:	89 c2                	mov    %eax,%edx
801035e6:	a1 44 37 11 80       	mov    0x80113744,%eax
801035eb:	89 54 24 04          	mov    %edx,0x4(%esp)
801035ef:	89 04 24             	mov    %eax,(%esp)
801035f2:	e8 be cb ff ff       	call   801001b5 <bread>
801035f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801035fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035fd:	8d 50 5c             	lea    0x5c(%eax),%edx
80103600:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103603:	83 c0 5c             	add    $0x5c,%eax
80103606:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010360d:	00 
8010360e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103612:	89 04 24             	mov    %eax,(%esp)
80103615:	e8 8c 1a 00 00       	call   801050a6 <memmove>
    bwrite(to);  // write the log
8010361a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010361d:	89 04 24             	mov    %eax,(%esp)
80103620:	e8 c7 cb ff ff       	call   801001ec <bwrite>
    brelse(from);
80103625:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103628:	89 04 24             	mov    %eax,(%esp)
8010362b:	e8 fc cb ff ff       	call   8010022c <brelse>
    brelse(to);
80103630:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103633:	89 04 24             	mov    %eax,(%esp)
80103636:	e8 f1 cb ff ff       	call   8010022c <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010363b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010363f:	a1 48 37 11 80       	mov    0x80113748,%eax
80103644:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103647:	0f 8f 66 ff ff ff    	jg     801035b3 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
8010364d:	c9                   	leave  
8010364e:	c3                   	ret    

8010364f <commit>:

static void
commit()
{
8010364f:	55                   	push   %ebp
80103650:	89 e5                	mov    %esp,%ebp
80103652:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103655:	a1 48 37 11 80       	mov    0x80113748,%eax
8010365a:	85 c0                	test   %eax,%eax
8010365c:	7e 1e                	jle    8010367c <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
8010365e:	e8 3e ff ff ff       	call   801035a1 <write_log>
    write_head();    // Write header to disk -- the real commit
80103663:	e8 6f fd ff ff       	call   801033d7 <write_head>
    install_trans(); // Now install writes to home locations
80103668:	e8 4d fc ff ff       	call   801032ba <install_trans>
    log.lh.n = 0;
8010366d:	c7 05 48 37 11 80 00 	movl   $0x0,0x80113748
80103674:	00 00 00 
    write_head();    // Erase the transaction from the log
80103677:	e8 5b fd ff ff       	call   801033d7 <write_head>
  }
}
8010367c:	c9                   	leave  
8010367d:	c3                   	ret    

8010367e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010367e:	55                   	push   %ebp
8010367f:	89 e5                	mov    %esp,%ebp
80103681:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103684:	a1 48 37 11 80       	mov    0x80113748,%eax
80103689:	83 f8 1d             	cmp    $0x1d,%eax
8010368c:	7f 12                	jg     801036a0 <log_write+0x22>
8010368e:	a1 48 37 11 80       	mov    0x80113748,%eax
80103693:	8b 15 38 37 11 80    	mov    0x80113738,%edx
80103699:	83 ea 01             	sub    $0x1,%edx
8010369c:	39 d0                	cmp    %edx,%eax
8010369e:	7c 0c                	jl     801036ac <log_write+0x2e>
    panic("too big a transaction");
801036a0:	c7 04 24 a0 87 10 80 	movl   $0x801087a0,(%esp)
801036a7:	e8 b6 ce ff ff       	call   80100562 <panic>
  if (log.outstanding < 1)
801036ac:	a1 3c 37 11 80       	mov    0x8011373c,%eax
801036b1:	85 c0                	test   %eax,%eax
801036b3:	7f 0c                	jg     801036c1 <log_write+0x43>
    panic("log_write outside of trans");
801036b5:	c7 04 24 b6 87 10 80 	movl   $0x801087b6,(%esp)
801036bc:	e8 a1 ce ff ff       	call   80100562 <panic>

  acquire(&log.lock);
801036c1:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
801036c8:	e8 a8 16 00 00       	call   80104d75 <acquire>
  for (i = 0; i < log.lh.n; i++) {
801036cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036d4:	eb 1f                	jmp    801036f5 <log_write+0x77>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801036d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036d9:	83 c0 10             	add    $0x10,%eax
801036dc:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
801036e3:	89 c2                	mov    %eax,%edx
801036e5:	8b 45 08             	mov    0x8(%ebp),%eax
801036e8:	8b 40 08             	mov    0x8(%eax),%eax
801036eb:	39 c2                	cmp    %eax,%edx
801036ed:	75 02                	jne    801036f1 <log_write+0x73>
      break;
801036ef:	eb 0e                	jmp    801036ff <log_write+0x81>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
801036f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801036f5:	a1 48 37 11 80       	mov    0x80113748,%eax
801036fa:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036fd:	7f d7                	jg     801036d6 <log_write+0x58>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
801036ff:	8b 45 08             	mov    0x8(%ebp),%eax
80103702:	8b 40 08             	mov    0x8(%eax),%eax
80103705:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103708:	83 c2 10             	add    $0x10,%edx
8010370b:	89 04 95 0c 37 11 80 	mov    %eax,-0x7feec8f4(,%edx,4)
  if (i == log.lh.n)
80103712:	a1 48 37 11 80       	mov    0x80113748,%eax
80103717:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010371a:	75 0d                	jne    80103729 <log_write+0xab>
    log.lh.n++;
8010371c:	a1 48 37 11 80       	mov    0x80113748,%eax
80103721:	83 c0 01             	add    $0x1,%eax
80103724:	a3 48 37 11 80       	mov    %eax,0x80113748
  b->flags |= B_DIRTY; // prevent eviction
80103729:	8b 45 08             	mov    0x8(%ebp),%eax
8010372c:	8b 00                	mov    (%eax),%eax
8010372e:	83 c8 04             	or     $0x4,%eax
80103731:	89 c2                	mov    %eax,%edx
80103733:	8b 45 08             	mov    0x8(%ebp),%eax
80103736:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103738:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
8010373f:	e8 99 16 00 00       	call   80104ddd <release>
}
80103744:	c9                   	leave  
80103745:	c3                   	ret    

80103746 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103746:	55                   	push   %ebp
80103747:	89 e5                	mov    %esp,%ebp
80103749:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010374c:	8b 55 08             	mov    0x8(%ebp),%edx
8010374f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103752:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103755:	f0 87 02             	lock xchg %eax,(%edx)
80103758:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010375b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010375e:	c9                   	leave  
8010375f:	c3                   	ret    

80103760 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103760:	55                   	push   %ebp
80103761:	89 e5                	mov    %esp,%ebp
80103763:	83 e4 f0             	and    $0xfffffff0,%esp
80103766:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103769:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103770:	80 
80103771:	c7 04 24 74 69 11 80 	movl   $0x80116974,(%esp)
80103778:	e8 ed f2 ff ff       	call   80102a6a <kinit1>
  kvmalloc();      // kernel page table
8010377d:	e8 15 43 00 00       	call   80107a97 <kvmalloc>
  mpinit();        // detect other processors
80103782:	e8 d0 03 00 00       	call   80103b57 <mpinit>
  lapicinit();     // interrupt controller
80103787:	e8 36 f6 ff ff       	call   80102dc2 <lapicinit>
  seginit();       // segment descriptors
8010378c:	e8 d2 3d 00 00       	call   80107563 <seginit>
  picinit();       // disable pic
80103791:	e8 10 05 00 00       	call   80103ca6 <picinit>
  ioapicinit();    // another interrupt controller
80103796:	e8 eb f1 ff ff       	call   80102986 <ioapicinit>
  consoleinit();   // console hardware
8010379b:	e8 30 d3 ff ff       	call   80100ad0 <consoleinit>
  uartinit();      // serial port
801037a0:	e8 48 31 00 00       	call   801068ed <uartinit>
  pinit();         // process table
801037a5:	e8 f5 08 00 00       	call   8010409f <pinit>
  shminit();       // shared memory
801037aa:	e8 d7 4b 00 00       	call   80108386 <shminit>
  tvinit();        // trap vectors
801037af:	e8 6d 2c 00 00       	call   80106421 <tvinit>
  binit();         // buffer cache
801037b4:	e8 7b c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801037b9:	e8 97 d7 ff ff       	call   80100f55 <fileinit>
  ideinit();       // disk 
801037be:	e8 cd ed ff ff       	call   80102590 <ideinit>
  startothers();   // start other processors
801037c3:	e8 83 00 00 00       	call   8010384b <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801037c8:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801037cf:	8e 
801037d0:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801037d7:	e8 c6 f2 ff ff       	call   80102aa2 <kinit2>
  userinit();      // first user process
801037dc:	e8 99 0a 00 00       	call   8010427a <userinit>
  mpmain();        // finish this processor's setup
801037e1:	e8 1a 00 00 00       	call   80103800 <mpmain>

801037e6 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801037e6:	55                   	push   %ebp
801037e7:	89 e5                	mov    %esp,%ebp
801037e9:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801037ec:	e8 bd 42 00 00       	call   80107aae <switchkvm>
  seginit();
801037f1:	e8 6d 3d 00 00       	call   80107563 <seginit>
  lapicinit();
801037f6:	e8 c7 f5 ff ff       	call   80102dc2 <lapicinit>
  mpmain();
801037fb:	e8 00 00 00 00       	call   80103800 <mpmain>

80103800 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103800:	55                   	push   %ebp
80103801:	89 e5                	mov    %esp,%ebp
80103803:	53                   	push   %ebx
80103804:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103807:	e8 af 08 00 00       	call   801040bb <cpuid>
8010380c:	89 c3                	mov    %eax,%ebx
8010380e:	e8 a8 08 00 00       	call   801040bb <cpuid>
80103813:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80103817:	89 44 24 04          	mov    %eax,0x4(%esp)
8010381b:	c7 04 24 d1 87 10 80 	movl   $0x801087d1,(%esp)
80103822:	e8 a1 cb ff ff       	call   801003c8 <cprintf>
  idtinit();       // load idt register
80103827:	e8 69 2d 00 00       	call   80106595 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
8010382c:	e8 ab 08 00 00       	call   801040dc <mycpu>
80103831:	05 a0 00 00 00       	add    $0xa0,%eax
80103836:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010383d:	00 
8010383e:	89 04 24             	mov    %eax,(%esp)
80103841:	e8 00 ff ff ff       	call   80103746 <xchg>
  scheduler();     // start running processes
80103846:	e8 95 0f 00 00       	call   801047e0 <scheduler>

8010384b <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010384b:	55                   	push   %ebp
8010384c:	89 e5                	mov    %esp,%ebp
8010384e:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103851:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103858:	b8 8a 00 00 00       	mov    $0x8a,%eax
8010385d:	89 44 24 08          	mov    %eax,0x8(%esp)
80103861:	c7 44 24 04 ec b4 10 	movl   $0x8010b4ec,0x4(%esp)
80103868:	80 
80103869:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010386c:	89 04 24             	mov    %eax,(%esp)
8010386f:	e8 32 18 00 00       	call   801050a6 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103874:	c7 45 f4 00 38 11 80 	movl   $0x80113800,-0xc(%ebp)
8010387b:	eb 76                	jmp    801038f3 <startothers+0xa8>
    if(c == mycpu())  // We've started already.
8010387d:	e8 5a 08 00 00       	call   801040dc <mycpu>
80103882:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103885:	75 02                	jne    80103889 <startothers+0x3e>
      continue;
80103887:	eb 63                	jmp    801038ec <startothers+0xa1>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103889:	e8 07 f3 ff ff       	call   80102b95 <kalloc>
8010388e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103891:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103894:	83 e8 04             	sub    $0x4,%eax
80103897:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010389a:	81 c2 00 10 00 00    	add    $0x1000,%edx
801038a0:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801038a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038a5:	83 e8 08             	sub    $0x8,%eax
801038a8:	c7 00 e6 37 10 80    	movl   $0x801037e6,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801038ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038b1:	8d 50 f4             	lea    -0xc(%eax),%edx
801038b4:	b8 00 a0 10 80       	mov    $0x8010a000,%eax
801038b9:	05 00 00 00 80       	add    $0x80000000,%eax
801038be:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
801038c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038c3:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801038c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038cc:	0f b6 00             	movzbl (%eax),%eax
801038cf:	0f b6 c0             	movzbl %al,%eax
801038d2:	89 54 24 04          	mov    %edx,0x4(%esp)
801038d6:	89 04 24             	mov    %eax,(%esp)
801038d9:	e8 89 f6 ff ff       	call   80102f67 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801038de:	90                   	nop
801038df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038e2:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801038e8:	85 c0                	test   %eax,%eax
801038ea:	74 f3                	je     801038df <startothers+0x94>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801038ec:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
801038f3:	a1 80 3d 11 80       	mov    0x80113d80,%eax
801038f8:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801038fe:	05 00 38 11 80       	add    $0x80113800,%eax
80103903:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103906:	0f 87 71 ff ff ff    	ja     8010387d <startothers+0x32>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
8010390c:	c9                   	leave  
8010390d:	c3                   	ret    

8010390e <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010390e:	55                   	push   %ebp
8010390f:	89 e5                	mov    %esp,%ebp
80103911:	83 ec 14             	sub    $0x14,%esp
80103914:	8b 45 08             	mov    0x8(%ebp),%eax
80103917:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010391b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010391f:	89 c2                	mov    %eax,%edx
80103921:	ec                   	in     (%dx),%al
80103922:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103925:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103929:	c9                   	leave  
8010392a:	c3                   	ret    

8010392b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010392b:	55                   	push   %ebp
8010392c:	89 e5                	mov    %esp,%ebp
8010392e:	83 ec 08             	sub    $0x8,%esp
80103931:	8b 55 08             	mov    0x8(%ebp),%edx
80103934:	8b 45 0c             	mov    0xc(%ebp),%eax
80103937:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010393b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010393e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103942:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103946:	ee                   	out    %al,(%dx)
}
80103947:	c9                   	leave  
80103948:	c3                   	ret    

80103949 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103949:	55                   	push   %ebp
8010394a:	89 e5                	mov    %esp,%ebp
8010394c:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
8010394f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103956:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010395d:	eb 15                	jmp    80103974 <sum+0x2b>
    sum += addr[i];
8010395f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103962:	8b 45 08             	mov    0x8(%ebp),%eax
80103965:	01 d0                	add    %edx,%eax
80103967:	0f b6 00             	movzbl (%eax),%eax
8010396a:	0f b6 c0             	movzbl %al,%eax
8010396d:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103970:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103974:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103977:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010397a:	7c e3                	jl     8010395f <sum+0x16>
    sum += addr[i];
  return sum;
8010397c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010397f:	c9                   	leave  
80103980:	c3                   	ret    

80103981 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103981:	55                   	push   %ebp
80103982:	89 e5                	mov    %esp,%ebp
80103984:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103987:	8b 45 08             	mov    0x8(%ebp),%eax
8010398a:	05 00 00 00 80       	add    $0x80000000,%eax
8010398f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103992:	8b 55 0c             	mov    0xc(%ebp),%edx
80103995:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103998:	01 d0                	add    %edx,%eax
8010399a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
8010399d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801039a3:	eb 3f                	jmp    801039e4 <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801039a5:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801039ac:	00 
801039ad:	c7 44 24 04 e8 87 10 	movl   $0x801087e8,0x4(%esp)
801039b4:	80 
801039b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039b8:	89 04 24             	mov    %eax,(%esp)
801039bb:	e8 8e 16 00 00       	call   8010504e <memcmp>
801039c0:	85 c0                	test   %eax,%eax
801039c2:	75 1c                	jne    801039e0 <mpsearch1+0x5f>
801039c4:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801039cb:	00 
801039cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039cf:	89 04 24             	mov    %eax,(%esp)
801039d2:	e8 72 ff ff ff       	call   80103949 <sum>
801039d7:	84 c0                	test   %al,%al
801039d9:	75 05                	jne    801039e0 <mpsearch1+0x5f>
      return (struct mp*)p;
801039db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039de:	eb 11                	jmp    801039f1 <mpsearch1+0x70>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
801039e0:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801039e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039e7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801039ea:	72 b9                	jb     801039a5 <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
801039ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
801039f1:	c9                   	leave  
801039f2:	c3                   	ret    

801039f3 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
801039f3:	55                   	push   %ebp
801039f4:	89 e5                	mov    %esp,%ebp
801039f6:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
801039f9:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a03:	83 c0 0f             	add    $0xf,%eax
80103a06:	0f b6 00             	movzbl (%eax),%eax
80103a09:	0f b6 c0             	movzbl %al,%eax
80103a0c:	c1 e0 08             	shl    $0x8,%eax
80103a0f:	89 c2                	mov    %eax,%edx
80103a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a14:	83 c0 0e             	add    $0xe,%eax
80103a17:	0f b6 00             	movzbl (%eax),%eax
80103a1a:	0f b6 c0             	movzbl %al,%eax
80103a1d:	09 d0                	or     %edx,%eax
80103a1f:	c1 e0 04             	shl    $0x4,%eax
80103a22:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103a25:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103a29:	74 21                	je     80103a4c <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103a2b:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103a32:	00 
80103a33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a36:	89 04 24             	mov    %eax,(%esp)
80103a39:	e8 43 ff ff ff       	call   80103981 <mpsearch1>
80103a3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103a41:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103a45:	74 50                	je     80103a97 <mpsearch+0xa4>
      return mp;
80103a47:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a4a:	eb 5f                	jmp    80103aab <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a4f:	83 c0 14             	add    $0x14,%eax
80103a52:	0f b6 00             	movzbl (%eax),%eax
80103a55:	0f b6 c0             	movzbl %al,%eax
80103a58:	c1 e0 08             	shl    $0x8,%eax
80103a5b:	89 c2                	mov    %eax,%edx
80103a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a60:	83 c0 13             	add    $0x13,%eax
80103a63:	0f b6 00             	movzbl (%eax),%eax
80103a66:	0f b6 c0             	movzbl %al,%eax
80103a69:	09 d0                	or     %edx,%eax
80103a6b:	c1 e0 0a             	shl    $0xa,%eax
80103a6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103a71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a74:	2d 00 04 00 00       	sub    $0x400,%eax
80103a79:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103a80:	00 
80103a81:	89 04 24             	mov    %eax,(%esp)
80103a84:	e8 f8 fe ff ff       	call   80103981 <mpsearch1>
80103a89:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103a8c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103a90:	74 05                	je     80103a97 <mpsearch+0xa4>
      return mp;
80103a92:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a95:	eb 14                	jmp    80103aab <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103a97:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103a9e:	00 
80103a9f:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103aa6:	e8 d6 fe ff ff       	call   80103981 <mpsearch1>
}
80103aab:	c9                   	leave  
80103aac:	c3                   	ret    

80103aad <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103aad:	55                   	push   %ebp
80103aae:	89 e5                	mov    %esp,%ebp
80103ab0:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103ab3:	e8 3b ff ff ff       	call   801039f3 <mpsearch>
80103ab8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103abb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103abf:	74 0a                	je     80103acb <mpconfig+0x1e>
80103ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ac4:	8b 40 04             	mov    0x4(%eax),%eax
80103ac7:	85 c0                	test   %eax,%eax
80103ac9:	75 0a                	jne    80103ad5 <mpconfig+0x28>
    return 0;
80103acb:	b8 00 00 00 00       	mov    $0x0,%eax
80103ad0:	e9 80 00 00 00       	jmp    80103b55 <mpconfig+0xa8>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad8:	8b 40 04             	mov    0x4(%eax),%eax
80103adb:	05 00 00 00 80       	add    $0x80000000,%eax
80103ae0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103ae3:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103aea:	00 
80103aeb:	c7 44 24 04 ed 87 10 	movl   $0x801087ed,0x4(%esp)
80103af2:	80 
80103af3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103af6:	89 04 24             	mov    %eax,(%esp)
80103af9:	e8 50 15 00 00       	call   8010504e <memcmp>
80103afe:	85 c0                	test   %eax,%eax
80103b00:	74 07                	je     80103b09 <mpconfig+0x5c>
    return 0;
80103b02:	b8 00 00 00 00       	mov    $0x0,%eax
80103b07:	eb 4c                	jmp    80103b55 <mpconfig+0xa8>
  if(conf->version != 1 && conf->version != 4)
80103b09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b0c:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b10:	3c 01                	cmp    $0x1,%al
80103b12:	74 12                	je     80103b26 <mpconfig+0x79>
80103b14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b17:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b1b:	3c 04                	cmp    $0x4,%al
80103b1d:	74 07                	je     80103b26 <mpconfig+0x79>
    return 0;
80103b1f:	b8 00 00 00 00       	mov    $0x0,%eax
80103b24:	eb 2f                	jmp    80103b55 <mpconfig+0xa8>
  if(sum((uchar*)conf, conf->length) != 0)
80103b26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b29:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103b2d:	0f b7 c0             	movzwl %ax,%eax
80103b30:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b37:	89 04 24             	mov    %eax,(%esp)
80103b3a:	e8 0a fe ff ff       	call   80103949 <sum>
80103b3f:	84 c0                	test   %al,%al
80103b41:	74 07                	je     80103b4a <mpconfig+0x9d>
    return 0;
80103b43:	b8 00 00 00 00       	mov    $0x0,%eax
80103b48:	eb 0b                	jmp    80103b55 <mpconfig+0xa8>
  *pmp = mp;
80103b4a:	8b 45 08             	mov    0x8(%ebp),%eax
80103b4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b50:	89 10                	mov    %edx,(%eax)
  return conf;
80103b52:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103b55:	c9                   	leave  
80103b56:	c3                   	ret    

80103b57 <mpinit>:

void
mpinit(void)
{
80103b57:	55                   	push   %ebp
80103b58:	89 e5                	mov    %esp,%ebp
80103b5a:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103b5d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103b60:	89 04 24             	mov    %eax,(%esp)
80103b63:	e8 45 ff ff ff       	call   80103aad <mpconfig>
80103b68:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b6b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b6f:	75 0c                	jne    80103b7d <mpinit+0x26>
    panic("Expect to run on an SMP");
80103b71:	c7 04 24 f2 87 10 80 	movl   $0x801087f2,(%esp)
80103b78:	e8 e5 c9 ff ff       	call   80100562 <panic>
  ismp = 1;
80103b7d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103b84:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b87:	8b 40 24             	mov    0x24(%eax),%eax
80103b8a:	a3 fc 36 11 80       	mov    %eax,0x801136fc
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103b8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b92:	83 c0 2c             	add    $0x2c,%eax
80103b95:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b98:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b9b:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103b9f:	0f b7 d0             	movzwl %ax,%edx
80103ba2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ba5:	01 d0                	add    %edx,%eax
80103ba7:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103baa:	eb 7b                	jmp    80103c27 <mpinit+0xd0>
    switch(*p){
80103bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103baf:	0f b6 00             	movzbl (%eax),%eax
80103bb2:	0f b6 c0             	movzbl %al,%eax
80103bb5:	83 f8 04             	cmp    $0x4,%eax
80103bb8:	77 65                	ja     80103c1f <mpinit+0xc8>
80103bba:	8b 04 85 2c 88 10 80 	mov    -0x7fef77d4(,%eax,4),%eax
80103bc1:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103bc9:	a1 80 3d 11 80       	mov    0x80113d80,%eax
80103bce:	83 f8 07             	cmp    $0x7,%eax
80103bd1:	7f 28                	jg     80103bfb <mpinit+0xa4>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103bd3:	8b 15 80 3d 11 80    	mov    0x80113d80,%edx
80103bd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103bdc:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103be0:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103be6:	81 c2 00 38 11 80    	add    $0x80113800,%edx
80103bec:	88 02                	mov    %al,(%edx)
        ncpu++;
80103bee:	a1 80 3d 11 80       	mov    0x80113d80,%eax
80103bf3:	83 c0 01             	add    $0x1,%eax
80103bf6:	a3 80 3d 11 80       	mov    %eax,0x80113d80
      }
      p += sizeof(struct mpproc);
80103bfb:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103bff:	eb 26                	jmp    80103c27 <mpinit+0xd0>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c04:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103c07:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103c0a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c0e:	a2 e0 37 11 80       	mov    %al,0x801137e0
      p += sizeof(struct mpioapic);
80103c13:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103c17:	eb 0e                	jmp    80103c27 <mpinit+0xd0>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103c19:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103c1d:	eb 08                	jmp    80103c27 <mpinit+0xd0>
    default:
      ismp = 0;
80103c1f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103c26:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2a:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103c2d:	0f 82 79 ff ff ff    	jb     80103bac <mpinit+0x55>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103c33:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c37:	75 0c                	jne    80103c45 <mpinit+0xee>
    panic("Didn't find a suitable machine");
80103c39:	c7 04 24 0c 88 10 80 	movl   $0x8010880c,(%esp)
80103c40:	e8 1d c9 ff ff       	call   80100562 <panic>

  if(mp->imcrp){
80103c45:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103c48:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103c4c:	84 c0                	test   %al,%al
80103c4e:	74 36                	je     80103c86 <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103c50:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103c57:	00 
80103c58:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103c5f:	e8 c7 fc ff ff       	call   8010392b <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103c64:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103c6b:	e8 9e fc ff ff       	call   8010390e <inb>
80103c70:	83 c8 01             	or     $0x1,%eax
80103c73:	0f b6 c0             	movzbl %al,%eax
80103c76:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c7a:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103c81:	e8 a5 fc ff ff       	call   8010392b <outb>
  }
}
80103c86:	c9                   	leave  
80103c87:	c3                   	ret    

80103c88 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103c88:	55                   	push   %ebp
80103c89:	89 e5                	mov    %esp,%ebp
80103c8b:	83 ec 08             	sub    $0x8,%esp
80103c8e:	8b 55 08             	mov    0x8(%ebp),%edx
80103c91:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c94:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103c98:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103c9b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103c9f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103ca3:	ee                   	out    %al,(%dx)
}
80103ca4:	c9                   	leave  
80103ca5:	c3                   	ret    

80103ca6 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103ca6:	55                   	push   %ebp
80103ca7:	89 e5                	mov    %esp,%ebp
80103ca9:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103cac:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103cb3:	00 
80103cb4:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103cbb:	e8 c8 ff ff ff       	call   80103c88 <outb>
  outb(IO_PIC2+1, 0xFF);
80103cc0:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103cc7:	00 
80103cc8:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ccf:	e8 b4 ff ff ff       	call   80103c88 <outb>
}
80103cd4:	c9                   	leave  
80103cd5:	c3                   	ret    

80103cd6 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103cd6:	55                   	push   %ebp
80103cd7:	89 e5                	mov    %esp,%ebp
80103cd9:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103cdc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103ce3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ce6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103cec:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cef:	8b 10                	mov    (%eax),%edx
80103cf1:	8b 45 08             	mov    0x8(%ebp),%eax
80103cf4:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103cf6:	e8 76 d2 ff ff       	call   80100f71 <filealloc>
80103cfb:	8b 55 08             	mov    0x8(%ebp),%edx
80103cfe:	89 02                	mov    %eax,(%edx)
80103d00:	8b 45 08             	mov    0x8(%ebp),%eax
80103d03:	8b 00                	mov    (%eax),%eax
80103d05:	85 c0                	test   %eax,%eax
80103d07:	0f 84 c8 00 00 00    	je     80103dd5 <pipealloc+0xff>
80103d0d:	e8 5f d2 ff ff       	call   80100f71 <filealloc>
80103d12:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d15:	89 02                	mov    %eax,(%edx)
80103d17:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d1a:	8b 00                	mov    (%eax),%eax
80103d1c:	85 c0                	test   %eax,%eax
80103d1e:	0f 84 b1 00 00 00    	je     80103dd5 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103d24:	e8 6c ee ff ff       	call   80102b95 <kalloc>
80103d29:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d2c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d30:	75 05                	jne    80103d37 <pipealloc+0x61>
    goto bad;
80103d32:	e9 9e 00 00 00       	jmp    80103dd5 <pipealloc+0xff>
  p->readopen = 1;
80103d37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d3a:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103d41:	00 00 00 
  p->writeopen = 1;
80103d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d47:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103d4e:	00 00 00 
  p->nwrite = 0;
80103d51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d54:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103d5b:	00 00 00 
  p->nread = 0;
80103d5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d61:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103d68:	00 00 00 
  initlock(&p->lock, "pipe");
80103d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d6e:	c7 44 24 04 40 88 10 	movl   $0x80108840,0x4(%esp)
80103d75:	80 
80103d76:	89 04 24             	mov    %eax,(%esp)
80103d79:	e8 d6 0f 00 00       	call   80104d54 <initlock>
  (*f0)->type = FD_PIPE;
80103d7e:	8b 45 08             	mov    0x8(%ebp),%eax
80103d81:	8b 00                	mov    (%eax),%eax
80103d83:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103d89:	8b 45 08             	mov    0x8(%ebp),%eax
80103d8c:	8b 00                	mov    (%eax),%eax
80103d8e:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103d92:	8b 45 08             	mov    0x8(%ebp),%eax
80103d95:	8b 00                	mov    (%eax),%eax
80103d97:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103d9b:	8b 45 08             	mov    0x8(%ebp),%eax
80103d9e:	8b 00                	mov    (%eax),%eax
80103da0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103da3:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103da6:	8b 45 0c             	mov    0xc(%ebp),%eax
80103da9:	8b 00                	mov    (%eax),%eax
80103dab:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103db1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103db4:	8b 00                	mov    (%eax),%eax
80103db6:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103dba:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dbd:	8b 00                	mov    (%eax),%eax
80103dbf:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103dc3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dc6:	8b 00                	mov    (%eax),%eax
80103dc8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103dcb:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103dce:	b8 00 00 00 00       	mov    $0x0,%eax
80103dd3:	eb 42                	jmp    80103e17 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80103dd5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103dd9:	74 0b                	je     80103de6 <pipealloc+0x110>
    kfree((char*)p);
80103ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dde:	89 04 24             	mov    %eax,(%esp)
80103de1:	e8 19 ed ff ff       	call   80102aff <kfree>
  if(*f0)
80103de6:	8b 45 08             	mov    0x8(%ebp),%eax
80103de9:	8b 00                	mov    (%eax),%eax
80103deb:	85 c0                	test   %eax,%eax
80103ded:	74 0d                	je     80103dfc <pipealloc+0x126>
    fileclose(*f0);
80103def:	8b 45 08             	mov    0x8(%ebp),%eax
80103df2:	8b 00                	mov    (%eax),%eax
80103df4:	89 04 24             	mov    %eax,(%esp)
80103df7:	e8 1d d2 ff ff       	call   80101019 <fileclose>
  if(*f1)
80103dfc:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dff:	8b 00                	mov    (%eax),%eax
80103e01:	85 c0                	test   %eax,%eax
80103e03:	74 0d                	je     80103e12 <pipealloc+0x13c>
    fileclose(*f1);
80103e05:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e08:	8b 00                	mov    (%eax),%eax
80103e0a:	89 04 24             	mov    %eax,(%esp)
80103e0d:	e8 07 d2 ff ff       	call   80101019 <fileclose>
  return -1;
80103e12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103e17:	c9                   	leave  
80103e18:	c3                   	ret    

80103e19 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103e19:	55                   	push   %ebp
80103e1a:	89 e5                	mov    %esp,%ebp
80103e1c:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80103e1f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e22:	89 04 24             	mov    %eax,(%esp)
80103e25:	e8 4b 0f 00 00       	call   80104d75 <acquire>
  if(writable){
80103e2a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103e2e:	74 1f                	je     80103e4f <pipeclose+0x36>
    p->writeopen = 0;
80103e30:	8b 45 08             	mov    0x8(%ebp),%eax
80103e33:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103e3a:	00 00 00 
    wakeup(&p->nread);
80103e3d:	8b 45 08             	mov    0x8(%ebp),%eax
80103e40:	05 34 02 00 00       	add    $0x234,%eax
80103e45:	89 04 24             	mov    %eax,(%esp)
80103e48:	e8 31 0c 00 00       	call   80104a7e <wakeup>
80103e4d:	eb 1d                	jmp    80103e6c <pipeclose+0x53>
  } else {
    p->readopen = 0;
80103e4f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e52:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103e59:	00 00 00 
    wakeup(&p->nwrite);
80103e5c:	8b 45 08             	mov    0x8(%ebp),%eax
80103e5f:	05 38 02 00 00       	add    $0x238,%eax
80103e64:	89 04 24             	mov    %eax,(%esp)
80103e67:	e8 12 0c 00 00       	call   80104a7e <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103e6c:	8b 45 08             	mov    0x8(%ebp),%eax
80103e6f:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103e75:	85 c0                	test   %eax,%eax
80103e77:	75 25                	jne    80103e9e <pipeclose+0x85>
80103e79:	8b 45 08             	mov    0x8(%ebp),%eax
80103e7c:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103e82:	85 c0                	test   %eax,%eax
80103e84:	75 18                	jne    80103e9e <pipeclose+0x85>
    release(&p->lock);
80103e86:	8b 45 08             	mov    0x8(%ebp),%eax
80103e89:	89 04 24             	mov    %eax,(%esp)
80103e8c:	e8 4c 0f 00 00       	call   80104ddd <release>
    kfree((char*)p);
80103e91:	8b 45 08             	mov    0x8(%ebp),%eax
80103e94:	89 04 24             	mov    %eax,(%esp)
80103e97:	e8 63 ec ff ff       	call   80102aff <kfree>
80103e9c:	eb 0b                	jmp    80103ea9 <pipeclose+0x90>
  } else
    release(&p->lock);
80103e9e:	8b 45 08             	mov    0x8(%ebp),%eax
80103ea1:	89 04 24             	mov    %eax,(%esp)
80103ea4:	e8 34 0f 00 00       	call   80104ddd <release>
}
80103ea9:	c9                   	leave  
80103eaa:	c3                   	ret    

80103eab <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103eab:	55                   	push   %ebp
80103eac:	89 e5                	mov    %esp,%ebp
80103eae:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
80103eb1:	8b 45 08             	mov    0x8(%ebp),%eax
80103eb4:	89 04 24             	mov    %eax,(%esp)
80103eb7:	e8 b9 0e 00 00       	call   80104d75 <acquire>
  for(i = 0; i < n; i++){
80103ebc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103ec3:	e9 a5 00 00 00       	jmp    80103f6d <pipewrite+0xc2>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103ec8:	eb 56                	jmp    80103f20 <pipewrite+0x75>
      if(p->readopen == 0 || myproc()->killed){
80103eca:	8b 45 08             	mov    0x8(%ebp),%eax
80103ecd:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103ed3:	85 c0                	test   %eax,%eax
80103ed5:	74 0c                	je     80103ee3 <pipewrite+0x38>
80103ed7:	e8 76 02 00 00       	call   80104152 <myproc>
80103edc:	8b 40 28             	mov    0x28(%eax),%eax
80103edf:	85 c0                	test   %eax,%eax
80103ee1:	74 15                	je     80103ef8 <pipewrite+0x4d>
        release(&p->lock);
80103ee3:	8b 45 08             	mov    0x8(%ebp),%eax
80103ee6:	89 04 24             	mov    %eax,(%esp)
80103ee9:	e8 ef 0e 00 00       	call   80104ddd <release>
        return -1;
80103eee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ef3:	e9 9f 00 00 00       	jmp    80103f97 <pipewrite+0xec>
      }
      wakeup(&p->nread);
80103ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80103efb:	05 34 02 00 00       	add    $0x234,%eax
80103f00:	89 04 24             	mov    %eax,(%esp)
80103f03:	e8 76 0b 00 00       	call   80104a7e <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103f08:	8b 45 08             	mov    0x8(%ebp),%eax
80103f0b:	8b 55 08             	mov    0x8(%ebp),%edx
80103f0e:	81 c2 38 02 00 00    	add    $0x238,%edx
80103f14:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f18:	89 14 24             	mov    %edx,(%esp)
80103f1b:	e8 8a 0a 00 00       	call   801049aa <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103f20:	8b 45 08             	mov    0x8(%ebp),%eax
80103f23:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103f29:	8b 45 08             	mov    0x8(%ebp),%eax
80103f2c:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103f32:	05 00 02 00 00       	add    $0x200,%eax
80103f37:	39 c2                	cmp    %eax,%edx
80103f39:	74 8f                	je     80103eca <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103f3b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f3e:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f44:	8d 48 01             	lea    0x1(%eax),%ecx
80103f47:	8b 55 08             	mov    0x8(%ebp),%edx
80103f4a:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103f50:	25 ff 01 00 00       	and    $0x1ff,%eax
80103f55:	89 c1                	mov    %eax,%ecx
80103f57:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f5d:	01 d0                	add    %edx,%eax
80103f5f:	0f b6 10             	movzbl (%eax),%edx
80103f62:	8b 45 08             	mov    0x8(%ebp),%eax
80103f65:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80103f69:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103f6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f70:	3b 45 10             	cmp    0x10(%ebp),%eax
80103f73:	0f 8c 4f ff ff ff    	jl     80103ec8 <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103f79:	8b 45 08             	mov    0x8(%ebp),%eax
80103f7c:	05 34 02 00 00       	add    $0x234,%eax
80103f81:	89 04 24             	mov    %eax,(%esp)
80103f84:	e8 f5 0a 00 00       	call   80104a7e <wakeup>
  release(&p->lock);
80103f89:	8b 45 08             	mov    0x8(%ebp),%eax
80103f8c:	89 04 24             	mov    %eax,(%esp)
80103f8f:	e8 49 0e 00 00       	call   80104ddd <release>
  return n;
80103f94:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103f97:	c9                   	leave  
80103f98:	c3                   	ret    

80103f99 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103f99:	55                   	push   %ebp
80103f9a:	89 e5                	mov    %esp,%ebp
80103f9c:	53                   	push   %ebx
80103f9d:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80103fa0:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa3:	89 04 24             	mov    %eax,(%esp)
80103fa6:	e8 ca 0d 00 00       	call   80104d75 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103fab:	eb 39                	jmp    80103fe6 <piperead+0x4d>
    if(myproc()->killed){
80103fad:	e8 a0 01 00 00       	call   80104152 <myproc>
80103fb2:	8b 40 28             	mov    0x28(%eax),%eax
80103fb5:	85 c0                	test   %eax,%eax
80103fb7:	74 15                	je     80103fce <piperead+0x35>
      release(&p->lock);
80103fb9:	8b 45 08             	mov    0x8(%ebp),%eax
80103fbc:	89 04 24             	mov    %eax,(%esp)
80103fbf:	e8 19 0e 00 00       	call   80104ddd <release>
      return -1;
80103fc4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fc9:	e9 b5 00 00 00       	jmp    80104083 <piperead+0xea>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103fce:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd1:	8b 55 08             	mov    0x8(%ebp),%edx
80103fd4:	81 c2 34 02 00 00    	add    $0x234,%edx
80103fda:	89 44 24 04          	mov    %eax,0x4(%esp)
80103fde:	89 14 24             	mov    %edx,(%esp)
80103fe1:	e8 c4 09 00 00       	call   801049aa <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103fe6:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe9:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103fef:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff2:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103ff8:	39 c2                	cmp    %eax,%edx
80103ffa:	75 0d                	jne    80104009 <piperead+0x70>
80103ffc:	8b 45 08             	mov    0x8(%ebp),%eax
80103fff:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104005:	85 c0                	test   %eax,%eax
80104007:	75 a4                	jne    80103fad <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104009:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104010:	eb 4b                	jmp    8010405d <piperead+0xc4>
    if(p->nread == p->nwrite)
80104012:	8b 45 08             	mov    0x8(%ebp),%eax
80104015:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010401b:	8b 45 08             	mov    0x8(%ebp),%eax
8010401e:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104024:	39 c2                	cmp    %eax,%edx
80104026:	75 02                	jne    8010402a <piperead+0x91>
      break;
80104028:	eb 3b                	jmp    80104065 <piperead+0xcc>
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010402a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010402d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104030:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104033:	8b 45 08             	mov    0x8(%ebp),%eax
80104036:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010403c:	8d 48 01             	lea    0x1(%eax),%ecx
8010403f:	8b 55 08             	mov    0x8(%ebp),%edx
80104042:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104048:	25 ff 01 00 00       	and    $0x1ff,%eax
8010404d:	89 c2                	mov    %eax,%edx
8010404f:	8b 45 08             	mov    0x8(%ebp),%eax
80104052:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104057:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104059:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010405d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104060:	3b 45 10             	cmp    0x10(%ebp),%eax
80104063:	7c ad                	jl     80104012 <piperead+0x79>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104065:	8b 45 08             	mov    0x8(%ebp),%eax
80104068:	05 38 02 00 00       	add    $0x238,%eax
8010406d:	89 04 24             	mov    %eax,(%esp)
80104070:	e8 09 0a 00 00       	call   80104a7e <wakeup>
  release(&p->lock);
80104075:	8b 45 08             	mov    0x8(%ebp),%eax
80104078:	89 04 24             	mov    %eax,(%esp)
8010407b:	e8 5d 0d 00 00       	call   80104ddd <release>
  return i;
80104080:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104083:	83 c4 24             	add    $0x24,%esp
80104086:	5b                   	pop    %ebx
80104087:	5d                   	pop    %ebp
80104088:	c3                   	ret    

80104089 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104089:	55                   	push   %ebp
8010408a:	89 e5                	mov    %esp,%ebp
8010408c:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010408f:	9c                   	pushf  
80104090:	58                   	pop    %eax
80104091:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104094:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104097:	c9                   	leave  
80104098:	c3                   	ret    

80104099 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104099:	55                   	push   %ebp
8010409a:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010409c:	fb                   	sti    
}
8010409d:	5d                   	pop    %ebp
8010409e:	c3                   	ret    

8010409f <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010409f:	55                   	push   %ebp
801040a0:	89 e5                	mov    %esp,%ebp
801040a2:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
801040a5:	c7 44 24 04 48 88 10 	movl   $0x80108848,0x4(%esp)
801040ac:	80 
801040ad:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801040b4:	e8 9b 0c 00 00       	call   80104d54 <initlock>
}
801040b9:	c9                   	leave  
801040ba:	c3                   	ret    

801040bb <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
801040bb:	55                   	push   %ebp
801040bc:	89 e5                	mov    %esp,%ebp
801040be:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801040c1:	e8 16 00 00 00       	call   801040dc <mycpu>
801040c6:	89 c2                	mov    %eax,%edx
801040c8:	b8 00 38 11 80       	mov    $0x80113800,%eax
801040cd:	29 c2                	sub    %eax,%edx
801040cf:	89 d0                	mov    %edx,%eax
801040d1:	c1 f8 04             	sar    $0x4,%eax
801040d4:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801040da:	c9                   	leave  
801040db:	c3                   	ret    

801040dc <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801040dc:	55                   	push   %ebp
801040dd:	89 e5                	mov    %esp,%ebp
801040df:	83 ec 28             	sub    $0x28,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
801040e2:	e8 a2 ff ff ff       	call   80104089 <readeflags>
801040e7:	25 00 02 00 00       	and    $0x200,%eax
801040ec:	85 c0                	test   %eax,%eax
801040ee:	74 0c                	je     801040fc <mycpu+0x20>
    panic("mycpu called with interrupts enabled\n");
801040f0:	c7 04 24 50 88 10 80 	movl   $0x80108850,(%esp)
801040f7:	e8 66 c4 ff ff       	call   80100562 <panic>
  
  apicid = lapicid();
801040fc:	e8 1a ee ff ff       	call   80102f1b <lapicid>
80104101:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104104:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010410b:	eb 2d                	jmp    8010413a <mycpu+0x5e>
    if (cpus[i].apicid == apicid)
8010410d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104110:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80104116:	05 00 38 11 80       	add    $0x80113800,%eax
8010411b:	0f b6 00             	movzbl (%eax),%eax
8010411e:	0f b6 c0             	movzbl %al,%eax
80104121:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104124:	75 10                	jne    80104136 <mycpu+0x5a>
      return &cpus[i];
80104126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104129:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010412f:	05 00 38 11 80       	add    $0x80113800,%eax
80104134:	eb 1a                	jmp    80104150 <mycpu+0x74>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104136:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010413a:	a1 80 3d 11 80       	mov    0x80113d80,%eax
8010413f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104142:	7c c9                	jl     8010410d <mycpu+0x31>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
80104144:	c7 04 24 76 88 10 80 	movl   $0x80108876,(%esp)
8010414b:	e8 12 c4 ff ff       	call   80100562 <panic>
}
80104150:	c9                   	leave  
80104151:	c3                   	ret    

80104152 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80104152:	55                   	push   %ebp
80104153:	89 e5                	mov    %esp,%ebp
80104155:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80104158:	e8 75 0d 00 00       	call   80104ed2 <pushcli>
  c = mycpu();
8010415d:	e8 7a ff ff ff       	call   801040dc <mycpu>
80104162:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80104165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104168:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010416e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80104171:	e8 a8 0d 00 00       	call   80104f1e <popcli>
  return p;
80104176:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104179:	c9                   	leave  
8010417a:	c3                   	ret    

8010417b <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010417b:	55                   	push   %ebp
8010417c:	89 e5                	mov    %esp,%ebp
8010417e:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104181:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104188:	e8 e8 0b 00 00       	call   80104d75 <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010418d:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
80104194:	eb 50                	jmp    801041e6 <allocproc+0x6b>
    if(p->state == UNUSED)
80104196:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104199:	8b 40 10             	mov    0x10(%eax),%eax
8010419c:	85 c0                	test   %eax,%eax
8010419e:	75 42                	jne    801041e2 <allocproc+0x67>
      goto found;
801041a0:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801041a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041a4:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
  p->pid = nextpid++;
801041ab:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801041b0:	8d 50 01             	lea    0x1(%eax),%edx
801041b3:	89 15 00 b0 10 80    	mov    %edx,0x8010b000
801041b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041bc:	89 42 14             	mov    %eax,0x14(%edx)

  release(&ptable.lock);
801041bf:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801041c6:	e8 12 0c 00 00       	call   80104ddd <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801041cb:	e8 c5 e9 ff ff       	call   80102b95 <kalloc>
801041d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041d3:	89 42 0c             	mov    %eax,0xc(%edx)
801041d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041d9:	8b 40 0c             	mov    0xc(%eax),%eax
801041dc:	85 c0                	test   %eax,%eax
801041de:	75 33                	jne    80104213 <allocproc+0x98>
801041e0:	eb 20                	jmp    80104202 <allocproc+0x87>
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801041e2:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801041e6:	81 7d f4 d4 5d 11 80 	cmpl   $0x80115dd4,-0xc(%ebp)
801041ed:	72 a7                	jb     80104196 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
801041ef:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801041f6:	e8 e2 0b 00 00       	call   80104ddd <release>
  return 0;
801041fb:	b8 00 00 00 00       	mov    $0x0,%eax
80104200:	eb 76                	jmp    80104278 <allocproc+0xfd>

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
80104202:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104205:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
    return 0;
8010420c:	b8 00 00 00 00       	mov    $0x0,%eax
80104211:	eb 65                	jmp    80104278 <allocproc+0xfd>
  }
  sp = p->kstack + KSTACKSIZE;
80104213:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104216:	8b 40 0c             	mov    0xc(%eax),%eax
80104219:	05 00 10 00 00       	add    $0x1000,%eax
8010421e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104221:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104225:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104228:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010422b:	89 50 1c             	mov    %edx,0x1c(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010422e:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104232:	ba dc 63 10 80       	mov    $0x801063dc,%edx
80104237:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010423a:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010423c:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104240:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104243:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104246:	89 50 20             	mov    %edx,0x20(%eax)
  memset(p->context, 0, sizeof *p->context);
80104249:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010424c:	8b 40 20             	mov    0x20(%eax),%eax
8010424f:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104256:	00 
80104257:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010425e:	00 
8010425f:	89 04 24             	mov    %eax,(%esp)
80104262:	e8 70 0d 00 00       	call   80104fd7 <memset>
  p->context->eip = (uint)forkret;
80104267:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010426a:	8b 40 20             	mov    0x20(%eax),%eax
8010426d:	ba 6b 49 10 80       	mov    $0x8010496b,%edx
80104272:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104275:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104278:	c9                   	leave  
80104279:	c3                   	ret    

8010427a <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010427a:	55                   	push   %ebp
8010427b:	89 e5                	mov    %esp,%ebp
8010427d:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104280:	e8 f6 fe ff ff       	call   8010417b <allocproc>
80104285:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80104288:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010428b:	a3 20 b6 10 80       	mov    %eax,0x8010b620
  if((p->pgdir = setupkvm()) == 0)
80104290:	e8 59 37 00 00       	call   801079ee <setupkvm>
80104295:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104298:	89 42 08             	mov    %eax,0x8(%edx)
8010429b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010429e:	8b 40 08             	mov    0x8(%eax),%eax
801042a1:	85 c0                	test   %eax,%eax
801042a3:	75 0c                	jne    801042b1 <userinit+0x37>
    panic("userinit: out of memory?");
801042a5:	c7 04 24 86 88 10 80 	movl   $0x80108886,(%esp)
801042ac:	e8 b1 c2 ff ff       	call   80100562 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801042b1:	ba 2c 00 00 00       	mov    $0x2c,%edx
801042b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042b9:	8b 40 08             	mov    0x8(%eax),%eax
801042bc:	89 54 24 08          	mov    %edx,0x8(%esp)
801042c0:	c7 44 24 04 c0 b4 10 	movl   $0x8010b4c0,0x4(%esp)
801042c7:	80 
801042c8:	89 04 24             	mov    %eax,(%esp)
801042cb:	e8 89 39 00 00       	call   80107c59 <inituvm>
  p->sz = PGSIZE;
801042d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d3:	c7 40 04 00 10 00 00 	movl   $0x1000,0x4(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801042da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042dd:	8b 40 1c             	mov    0x1c(%eax),%eax
801042e0:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801042e7:	00 
801042e8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801042ef:	00 
801042f0:	89 04 24             	mov    %eax,(%esp)
801042f3:	e8 df 0c 00 00       	call   80104fd7 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801042f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042fb:	8b 40 1c             	mov    0x1c(%eax),%eax
801042fe:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104307:	8b 40 1c             	mov    0x1c(%eax),%eax
8010430a:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104310:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104313:	8b 40 1c             	mov    0x1c(%eax),%eax
80104316:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104319:	8b 52 1c             	mov    0x1c(%edx),%edx
8010431c:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104320:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104324:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104327:	8b 40 1c             	mov    0x1c(%eax),%eax
8010432a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010432d:	8b 52 1c             	mov    0x1c(%edx),%edx
80104330:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104334:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010433b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010433e:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104345:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104348:	8b 40 1c             	mov    0x1c(%eax),%eax
8010434b:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104355:	8b 40 1c             	mov    0x1c(%eax),%eax
80104358:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010435f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104362:	83 c0 70             	add    $0x70,%eax
80104365:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010436c:	00 
8010436d:	c7 44 24 04 9f 88 10 	movl   $0x8010889f,0x4(%esp)
80104374:	80 
80104375:	89 04 24             	mov    %eax,(%esp)
80104378:	e8 7a 0e 00 00       	call   801051f7 <safestrcpy>
  p->cwd = namei("/");
8010437d:	c7 04 24 a8 88 10 80 	movl   $0x801088a8,(%esp)
80104384:	e8 fa e0 ff ff       	call   80102483 <namei>
80104389:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010438c:	89 42 6c             	mov    %eax,0x6c(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
8010438f:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104396:	e8 da 09 00 00       	call   80104d75 <acquire>

  p->state = RUNNABLE;
8010439b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010439e:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)

  release(&ptable.lock);
801043a5:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801043ac:	e8 2c 0a 00 00       	call   80104ddd <release>
}
801043b1:	c9                   	leave  
801043b2:	c3                   	ret    

801043b3 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801043b3:	55                   	push   %ebp
801043b4:	89 e5                	mov    %esp,%ebp
801043b6:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
801043b9:	e8 94 fd ff ff       	call   80104152 <myproc>
801043be:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
801043c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043c4:	8b 40 04             	mov    0x4(%eax),%eax
801043c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801043ca:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801043ce:	7e 31                	jle    80104401 <growproc+0x4e>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801043d0:	8b 55 08             	mov    0x8(%ebp),%edx
801043d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d6:	01 c2                	add    %eax,%edx
801043d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043db:	8b 40 08             	mov    0x8(%eax),%eax
801043de:	89 54 24 08          	mov    %edx,0x8(%esp)
801043e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043e5:	89 54 24 04          	mov    %edx,0x4(%esp)
801043e9:	89 04 24             	mov    %eax,(%esp)
801043ec:	e8 d3 39 00 00       	call   80107dc4 <allocuvm>
801043f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801043f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801043f8:	75 3e                	jne    80104438 <growproc+0x85>
      return -1;
801043fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043ff:	eb 50                	jmp    80104451 <growproc+0x9e>
  } else if(n < 0){
80104401:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104405:	79 31                	jns    80104438 <growproc+0x85>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104407:	8b 55 08             	mov    0x8(%ebp),%edx
8010440a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440d:	01 c2                	add    %eax,%edx
8010440f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104412:	8b 40 08             	mov    0x8(%eax),%eax
80104415:	89 54 24 08          	mov    %edx,0x8(%esp)
80104419:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010441c:	89 54 24 04          	mov    %edx,0x4(%esp)
80104420:	89 04 24             	mov    %eax,(%esp)
80104423:	e8 b2 3a 00 00       	call   80107eda <deallocuvm>
80104428:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010442b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010442f:	75 07                	jne    80104438 <growproc+0x85>
      return -1;
80104431:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104436:	eb 19                	jmp    80104451 <growproc+0x9e>
  }
  curproc->sz = sz;
80104438:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010443b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010443e:	89 50 04             	mov    %edx,0x4(%eax)
  switchuvm(curproc);
80104441:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104444:	89 04 24             	mov    %eax,(%esp)
80104447:	e8 7c 36 00 00       	call   80107ac8 <switchuvm>
  return 0;
8010444c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104451:	c9                   	leave  
80104452:	c3                   	ret    

80104453 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104453:	55                   	push   %ebp
80104454:	89 e5                	mov    %esp,%ebp
80104456:	57                   	push   %edi
80104457:	56                   	push   %esi
80104458:	53                   	push   %ebx
80104459:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
8010445c:	e8 f1 fc ff ff       	call   80104152 <myproc>
80104461:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80104464:	e8 12 fd ff ff       	call   8010417b <allocproc>
80104469:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010446c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104470:	75 0a                	jne    8010447c <fork+0x29>
    return -1;
80104472:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104477:	e9 46 01 00 00       	jmp    801045c2 <fork+0x16f>
  }

  // Copy process state from proc.
  // CS153 -- added
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz, curproc->tf->esp)) == 0){ //the added parameter updates the top of the stack; STACKTOP
8010447c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010447f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104482:	8b 48 44             	mov    0x44(%eax),%ecx
80104485:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104488:	8b 50 04             	mov    0x4(%eax),%edx
8010448b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010448e:	8b 40 08             	mov    0x8(%eax),%eax
80104491:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80104495:	89 54 24 04          	mov    %edx,0x4(%esp)
80104499:	89 04 24             	mov    %eax,(%esp)
8010449c:	e8 dc 3b 00 00       	call   8010807d <copyuvm>
801044a1:	8b 55 dc             	mov    -0x24(%ebp),%edx
801044a4:	89 42 08             	mov    %eax,0x8(%edx)
801044a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044aa:	8b 40 08             	mov    0x8(%eax),%eax
801044ad:	85 c0                	test   %eax,%eax
801044af:	75 2c                	jne    801044dd <fork+0x8a>
    kfree(np->kstack);
801044b1:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044b4:	8b 40 0c             	mov    0xc(%eax),%eax
801044b7:	89 04 24             	mov    %eax,(%esp)
801044ba:	e8 40 e6 ff ff       	call   80102aff <kfree>
    np->kstack = 0;
801044bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044c2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    np->state = UNUSED;
801044c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044cc:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
    return -1;
801044d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044d8:	e9 e5 00 00 00       	jmp    801045c2 <fork+0x16f>
  }
  np->sz = curproc->sz;
801044dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044e0:	8b 50 04             	mov    0x4(%eax),%edx
801044e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044e6:	89 50 04             	mov    %edx,0x4(%eax)
  np->parent = curproc;
801044e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044ec:	8b 55 e0             	mov    -0x20(%ebp),%edx
801044ef:	89 50 18             	mov    %edx,0x18(%eax)
  *np->tf = *curproc->tf;
801044f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044f5:	8b 50 1c             	mov    0x1c(%eax),%edx
801044f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044fb:	8b 40 1c             	mov    0x1c(%eax),%eax
801044fe:	89 c3                	mov    %eax,%ebx
80104500:	b8 13 00 00 00       	mov    $0x13,%eax
80104505:	89 d7                	mov    %edx,%edi
80104507:	89 de                	mov    %ebx,%esi
80104509:	89 c1                	mov    %eax,%ecx
8010450b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010450d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104510:	8b 40 1c             	mov    0x1c(%eax),%eax
80104513:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010451a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104521:	eb 37                	jmp    8010455a <fork+0x107>
    if(curproc->ofile[i])
80104523:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104526:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104529:	83 c2 08             	add    $0x8,%edx
8010452c:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104530:	85 c0                	test   %eax,%eax
80104532:	74 22                	je     80104556 <fork+0x103>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104534:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104537:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010453a:	83 c2 08             	add    $0x8,%edx
8010453d:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104541:	89 04 24             	mov    %eax,(%esp)
80104544:	e8 88 ca ff ff       	call   80100fd1 <filedup>
80104549:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010454c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010454f:	83 c1 08             	add    $0x8,%ecx
80104552:	89 44 8a 0c          	mov    %eax,0xc(%edx,%ecx,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104556:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010455a:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010455e:	7e c3                	jle    80104523 <fork+0xd0>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
80104560:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104563:	8b 40 6c             	mov    0x6c(%eax),%eax
80104566:	89 04 24             	mov    %eax,(%esp)
80104569:	e8 a9 d3 ff ff       	call   80101917 <idup>
8010456e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104571:	89 42 6c             	mov    %eax,0x6c(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104574:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104577:	8d 50 70             	lea    0x70(%eax),%edx
8010457a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010457d:	83 c0 70             	add    $0x70,%eax
80104580:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104587:	00 
80104588:	89 54 24 04          	mov    %edx,0x4(%esp)
8010458c:	89 04 24             	mov    %eax,(%esp)
8010458f:	e8 63 0c 00 00       	call   801051f7 <safestrcpy>

  pid = np->pid;
80104594:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104597:	8b 40 14             	mov    0x14(%eax),%eax
8010459a:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
8010459d:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801045a4:	e8 cc 07 00 00       	call   80104d75 <acquire>

  np->state = RUNNABLE;
801045a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045ac:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)

  release(&ptable.lock);
801045b3:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801045ba:	e8 1e 08 00 00       	call   80104ddd <release>

  return pid;
801045bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
801045c2:	83 c4 2c             	add    $0x2c,%esp
801045c5:	5b                   	pop    %ebx
801045c6:	5e                   	pop    %esi
801045c7:	5f                   	pop    %edi
801045c8:	5d                   	pop    %ebp
801045c9:	c3                   	ret    

801045ca <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801045ca:	55                   	push   %ebp
801045cb:	89 e5                	mov    %esp,%ebp
801045cd:	83 ec 28             	sub    $0x28,%esp
  struct proc *curproc = myproc();
801045d0:	e8 7d fb ff ff       	call   80104152 <myproc>
801045d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
801045d8:	a1 20 b6 10 80       	mov    0x8010b620,%eax
801045dd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801045e0:	75 0c                	jne    801045ee <exit+0x24>
    panic("init exiting");
801045e2:	c7 04 24 aa 88 10 80 	movl   $0x801088aa,(%esp)
801045e9:	e8 74 bf ff ff       	call   80100562 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801045ee:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801045f5:	eb 3b                	jmp    80104632 <exit+0x68>
    if(curproc->ofile[fd]){
801045f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045fd:	83 c2 08             	add    $0x8,%edx
80104600:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104604:	85 c0                	test   %eax,%eax
80104606:	74 26                	je     8010462e <exit+0x64>
      fileclose(curproc->ofile[fd]);
80104608:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010460b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010460e:	83 c2 08             	add    $0x8,%edx
80104611:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104615:	89 04 24             	mov    %eax,(%esp)
80104618:	e8 fc c9 ff ff       	call   80101019 <fileclose>
      curproc->ofile[fd] = 0;
8010461d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104620:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104623:	83 c2 08             	add    $0x8,%edx
80104626:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
8010462d:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010462e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104632:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104636:	7e bf                	jle    801045f7 <exit+0x2d>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
80104638:	e8 36 ee ff ff       	call   80103473 <begin_op>
  iput(curproc->cwd);
8010463d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104640:	8b 40 6c             	mov    0x6c(%eax),%eax
80104643:	89 04 24             	mov    %eax,(%esp)
80104646:	e8 4f d4 ff ff       	call   80101a9a <iput>
  end_op();
8010464b:	e8 a7 ee ff ff       	call   801034f7 <end_op>
  curproc->cwd = 0;
80104650:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104653:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)

  acquire(&ptable.lock);
8010465a:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104661:	e8 0f 07 00 00       	call   80104d75 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104666:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104669:	8b 40 18             	mov    0x18(%eax),%eax
8010466c:	89 04 24             	mov    %eax,(%esp)
8010466f:	e8 cc 03 00 00       	call   80104a40 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104674:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
8010467b:	eb 33                	jmp    801046b0 <exit+0xe6>
    if(p->parent == curproc){
8010467d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104680:	8b 40 18             	mov    0x18(%eax),%eax
80104683:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104686:	75 24                	jne    801046ac <exit+0xe2>
      p->parent = initproc;
80104688:	8b 15 20 b6 10 80    	mov    0x8010b620,%edx
8010468e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104691:	89 50 18             	mov    %edx,0x18(%eax)
      if(p->state == ZOMBIE)
80104694:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104697:	8b 40 10             	mov    0x10(%eax),%eax
8010469a:	83 f8 05             	cmp    $0x5,%eax
8010469d:	75 0d                	jne    801046ac <exit+0xe2>
        wakeup1(initproc);
8010469f:	a1 20 b6 10 80       	mov    0x8010b620,%eax
801046a4:	89 04 24             	mov    %eax,(%esp)
801046a7:	e8 94 03 00 00       	call   80104a40 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046ac:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801046b0:	81 7d f4 d4 5d 11 80 	cmpl   $0x80115dd4,-0xc(%ebp)
801046b7:	72 c4                	jb     8010467d <exit+0xb3>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801046b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046bc:	c7 40 10 05 00 00 00 	movl   $0x5,0x10(%eax)
  sched();
801046c3:	e8 c3 01 00 00       	call   8010488b <sched>
  panic("zombie exit");
801046c8:	c7 04 24 b7 88 10 80 	movl   $0x801088b7,(%esp)
801046cf:	e8 8e be ff ff       	call   80100562 <panic>

801046d4 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801046d4:	55                   	push   %ebp
801046d5:	89 e5                	mov    %esp,%ebp
801046d7:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801046da:	e8 73 fa ff ff       	call   80104152 <myproc>
801046df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801046e2:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801046e9:	e8 87 06 00 00       	call   80104d75 <acquire>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801046ee:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046f5:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
801046fc:	e9 95 00 00 00       	jmp    80104796 <wait+0xc2>
      if(p->parent != curproc)
80104701:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104704:	8b 40 18             	mov    0x18(%eax),%eax
80104707:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010470a:	74 05                	je     80104711 <wait+0x3d>
        continue;
8010470c:	e9 81 00 00 00       	jmp    80104792 <wait+0xbe>
      havekids = 1;
80104711:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104718:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010471b:	8b 40 10             	mov    0x10(%eax),%eax
8010471e:	83 f8 05             	cmp    $0x5,%eax
80104721:	75 6f                	jne    80104792 <wait+0xbe>
        // Found one.
        pid = p->pid;
80104723:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104726:	8b 40 14             	mov    0x14(%eax),%eax
80104729:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
8010472c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010472f:	8b 40 0c             	mov    0xc(%eax),%eax
80104732:	89 04 24             	mov    %eax,(%esp)
80104735:	e8 c5 e3 ff ff       	call   80102aff <kfree>
        p->kstack = 0;
8010473a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010473d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        freevm(p->pgdir);
80104744:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104747:	8b 40 08             	mov    0x8(%eax),%eax
8010474a:	89 04 24             	mov    %eax,(%esp)
8010474d:	e8 4e 38 00 00       	call   80107fa0 <freevm>
        p->pid = 0;
80104752:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104755:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->parent = 0;
8010475c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010475f:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
        p->name[0] = 0;
80104766:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104769:	c6 40 70 00          	movb   $0x0,0x70(%eax)
        p->killed = 0;
8010476d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104770:	c7 40 28 00 00 00 00 	movl   $0x0,0x28(%eax)
        p->state = UNUSED;
80104777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010477a:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        release(&ptable.lock);
80104781:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104788:	e8 50 06 00 00       	call   80104ddd <release>
        return pid;
8010478d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104790:	eb 4c                	jmp    801047de <wait+0x10a>
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104792:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104796:	81 7d f4 d4 5d 11 80 	cmpl   $0x80115dd4,-0xc(%ebp)
8010479d:	0f 82 5e ff ff ff    	jb     80104701 <wait+0x2d>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801047a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801047a7:	74 0a                	je     801047b3 <wait+0xdf>
801047a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047ac:	8b 40 28             	mov    0x28(%eax),%eax
801047af:	85 c0                	test   %eax,%eax
801047b1:	74 13                	je     801047c6 <wait+0xf2>
      release(&ptable.lock);
801047b3:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801047ba:	e8 1e 06 00 00       	call   80104ddd <release>
      return -1;
801047bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047c4:	eb 18                	jmp    801047de <wait+0x10a>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801047c6:	c7 44 24 04 a0 3d 11 	movl   $0x80113da0,0x4(%esp)
801047cd:	80 
801047ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047d1:	89 04 24             	mov    %eax,(%esp)
801047d4:	e8 d1 01 00 00       	call   801049aa <sleep>
  }
801047d9:	e9 10 ff ff ff       	jmp    801046ee <wait+0x1a>
}
801047de:	c9                   	leave  
801047df:	c3                   	ret    

801047e0 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801047e0:	55                   	push   %ebp
801047e1:	89 e5                	mov    %esp,%ebp
801047e3:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801047e6:	e8 f1 f8 ff ff       	call   801040dc <mycpu>
801047eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801047ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047f1:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801047f8:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801047fb:	e8 99 f8 ff ff       	call   80104099 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104800:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104807:	e8 69 05 00 00       	call   80104d75 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010480c:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
80104813:	eb 5c                	jmp    80104871 <scheduler+0x91>
      if(p->state != RUNNABLE)
80104815:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104818:	8b 40 10             	mov    0x10(%eax),%eax
8010481b:	83 f8 03             	cmp    $0x3,%eax
8010481e:	74 02                	je     80104822 <scheduler+0x42>
        continue;
80104820:	eb 4b                	jmp    8010486d <scheduler+0x8d>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104822:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104825:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104828:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
8010482e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104831:	89 04 24             	mov    %eax,(%esp)
80104834:	e8 8f 32 00 00       	call   80107ac8 <switchuvm>
      p->state = RUNNING;
80104839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010483c:	c7 40 10 04 00 00 00 	movl   $0x4,0x10(%eax)

      swtch(&(c->scheduler), p->context);
80104843:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104846:	8b 40 20             	mov    0x20(%eax),%eax
80104849:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010484c:	83 c2 04             	add    $0x4,%edx
8010484f:	89 44 24 04          	mov    %eax,0x4(%esp)
80104853:	89 14 24             	mov    %edx,(%esp)
80104856:	e8 0d 0a 00 00       	call   80105268 <swtch>
      switchkvm();
8010485b:	e8 4e 32 00 00       	call   80107aae <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104860:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104863:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010486a:	00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010486d:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104871:	81 7d f4 d4 5d 11 80 	cmpl   $0x80115dd4,-0xc(%ebp)
80104878:	72 9b                	jb     80104815 <scheduler+0x35>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
8010487a:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104881:	e8 57 05 00 00       	call   80104ddd <release>

  }
80104886:	e9 70 ff ff ff       	jmp    801047fb <scheduler+0x1b>

8010488b <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
8010488b:	55                   	push   %ebp
8010488c:	89 e5                	mov    %esp,%ebp
8010488e:	83 ec 28             	sub    $0x28,%esp
  int intena;
  struct proc *p = myproc();
80104891:	e8 bc f8 ff ff       	call   80104152 <myproc>
80104896:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104899:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801048a0:	e8 fc 05 00 00       	call   80104ea1 <holding>
801048a5:	85 c0                	test   %eax,%eax
801048a7:	75 0c                	jne    801048b5 <sched+0x2a>
    panic("sched ptable.lock");
801048a9:	c7 04 24 c3 88 10 80 	movl   $0x801088c3,(%esp)
801048b0:	e8 ad bc ff ff       	call   80100562 <panic>
  if(mycpu()->ncli != 1)
801048b5:	e8 22 f8 ff ff       	call   801040dc <mycpu>
801048ba:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801048c0:	83 f8 01             	cmp    $0x1,%eax
801048c3:	74 0c                	je     801048d1 <sched+0x46>
    panic("sched locks");
801048c5:	c7 04 24 d5 88 10 80 	movl   $0x801088d5,(%esp)
801048cc:	e8 91 bc ff ff       	call   80100562 <panic>
  if(p->state == RUNNING)
801048d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048d4:	8b 40 10             	mov    0x10(%eax),%eax
801048d7:	83 f8 04             	cmp    $0x4,%eax
801048da:	75 0c                	jne    801048e8 <sched+0x5d>
    panic("sched running");
801048dc:	c7 04 24 e1 88 10 80 	movl   $0x801088e1,(%esp)
801048e3:	e8 7a bc ff ff       	call   80100562 <panic>
  if(readeflags()&FL_IF)
801048e8:	e8 9c f7 ff ff       	call   80104089 <readeflags>
801048ed:	25 00 02 00 00       	and    $0x200,%eax
801048f2:	85 c0                	test   %eax,%eax
801048f4:	74 0c                	je     80104902 <sched+0x77>
    panic("sched interruptible");
801048f6:	c7 04 24 ef 88 10 80 	movl   $0x801088ef,(%esp)
801048fd:	e8 60 bc ff ff       	call   80100562 <panic>
  intena = mycpu()->intena;
80104902:	e8 d5 f7 ff ff       	call   801040dc <mycpu>
80104907:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010490d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104910:	e8 c7 f7 ff ff       	call   801040dc <mycpu>
80104915:	8b 40 04             	mov    0x4(%eax),%eax
80104918:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010491b:	83 c2 20             	add    $0x20,%edx
8010491e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104922:	89 14 24             	mov    %edx,(%esp)
80104925:	e8 3e 09 00 00       	call   80105268 <swtch>
  mycpu()->intena = intena;
8010492a:	e8 ad f7 ff ff       	call   801040dc <mycpu>
8010492f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104932:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104938:	c9                   	leave  
80104939:	c3                   	ret    

8010493a <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010493a:	55                   	push   %ebp
8010493b:	89 e5                	mov    %esp,%ebp
8010493d:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104940:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104947:	e8 29 04 00 00       	call   80104d75 <acquire>
  myproc()->state = RUNNABLE;
8010494c:	e8 01 f8 ff ff       	call   80104152 <myproc>
80104951:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
  sched();
80104958:	e8 2e ff ff ff       	call   8010488b <sched>
  release(&ptable.lock);
8010495d:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104964:	e8 74 04 00 00       	call   80104ddd <release>
}
80104969:	c9                   	leave  
8010496a:	c3                   	ret    

8010496b <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010496b:	55                   	push   %ebp
8010496c:	89 e5                	mov    %esp,%ebp
8010496e:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104971:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104978:	e8 60 04 00 00       	call   80104ddd <release>

  if (first) {
8010497d:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104982:	85 c0                	test   %eax,%eax
80104984:	74 22                	je     801049a8 <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104986:	c7 05 04 b0 10 80 00 	movl   $0x0,0x8010b004
8010498d:	00 00 00 
    iinit(ROOTDEV);
80104990:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104997:	e8 40 cc ff ff       	call   801015dc <iinit>
    initlog(ROOTDEV);
8010499c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801049a3:	e8 c7 e8 ff ff       	call   8010326f <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
801049a8:	c9                   	leave  
801049a9:	c3                   	ret    

801049aa <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801049aa:	55                   	push   %ebp
801049ab:	89 e5                	mov    %esp,%ebp
801049ad:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = myproc();
801049b0:	e8 9d f7 ff ff       	call   80104152 <myproc>
801049b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801049b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801049bc:	75 0c                	jne    801049ca <sleep+0x20>
    panic("sleep");
801049be:	c7 04 24 03 89 10 80 	movl   $0x80108903,(%esp)
801049c5:	e8 98 bb ff ff       	call   80100562 <panic>

  if(lk == 0)
801049ca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801049ce:	75 0c                	jne    801049dc <sleep+0x32>
    panic("sleep without lk");
801049d0:	c7 04 24 09 89 10 80 	movl   $0x80108909,(%esp)
801049d7:	e8 86 bb ff ff       	call   80100562 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801049dc:	81 7d 0c a0 3d 11 80 	cmpl   $0x80113da0,0xc(%ebp)
801049e3:	74 17                	je     801049fc <sleep+0x52>
    acquire(&ptable.lock);  //DOC: sleeplock1
801049e5:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
801049ec:	e8 84 03 00 00       	call   80104d75 <acquire>
    release(lk);
801049f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801049f4:	89 04 24             	mov    %eax,(%esp)
801049f7:	e8 e1 03 00 00       	call   80104ddd <release>
  }
  // Go to sleep.
  p->chan = chan;
801049fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ff:	8b 55 08             	mov    0x8(%ebp),%edx
80104a02:	89 50 24             	mov    %edx,0x24(%eax)
  p->state = SLEEPING;
80104a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a08:	c7 40 10 02 00 00 00 	movl   $0x2,0x10(%eax)

  sched();
80104a0f:	e8 77 fe ff ff       	call   8010488b <sched>

  // Tidy up.
  p->chan = 0;
80104a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a17:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104a1e:	81 7d 0c a0 3d 11 80 	cmpl   $0x80113da0,0xc(%ebp)
80104a25:	74 17                	je     80104a3e <sleep+0x94>
    release(&ptable.lock);
80104a27:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104a2e:	e8 aa 03 00 00       	call   80104ddd <release>
    acquire(lk);
80104a33:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a36:	89 04 24             	mov    %eax,(%esp)
80104a39:	e8 37 03 00 00       	call   80104d75 <acquire>
  }
}
80104a3e:	c9                   	leave  
80104a3f:	c3                   	ret    

80104a40 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104a40:	55                   	push   %ebp
80104a41:	89 e5                	mov    %esp,%ebp
80104a43:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104a46:	c7 45 fc d4 3d 11 80 	movl   $0x80113dd4,-0x4(%ebp)
80104a4d:	eb 24                	jmp    80104a73 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104a4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a52:	8b 40 10             	mov    0x10(%eax),%eax
80104a55:	83 f8 02             	cmp    $0x2,%eax
80104a58:	75 15                	jne    80104a6f <wakeup1+0x2f>
80104a5a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a5d:	8b 40 24             	mov    0x24(%eax),%eax
80104a60:	3b 45 08             	cmp    0x8(%ebp),%eax
80104a63:	75 0a                	jne    80104a6f <wakeup1+0x2f>
      p->state = RUNNABLE;
80104a65:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a68:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104a6f:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
80104a73:	81 7d fc d4 5d 11 80 	cmpl   $0x80115dd4,-0x4(%ebp)
80104a7a:	72 d3                	jb     80104a4f <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104a7c:	c9                   	leave  
80104a7d:	c3                   	ret    

80104a7e <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104a7e:	55                   	push   %ebp
80104a7f:	89 e5                	mov    %esp,%ebp
80104a81:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104a84:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104a8b:	e8 e5 02 00 00       	call   80104d75 <acquire>
  wakeup1(chan);
80104a90:	8b 45 08             	mov    0x8(%ebp),%eax
80104a93:	89 04 24             	mov    %eax,(%esp)
80104a96:	e8 a5 ff ff ff       	call   80104a40 <wakeup1>
  release(&ptable.lock);
80104a9b:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104aa2:	e8 36 03 00 00       	call   80104ddd <release>
}
80104aa7:	c9                   	leave  
80104aa8:	c3                   	ret    

80104aa9 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104aa9:	55                   	push   %ebp
80104aaa:	89 e5                	mov    %esp,%ebp
80104aac:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104aaf:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104ab6:	e8 ba 02 00 00       	call   80104d75 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104abb:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
80104ac2:	eb 41                	jmp    80104b05 <kill+0x5c>
    if(p->pid == pid){
80104ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac7:	8b 40 14             	mov    0x14(%eax),%eax
80104aca:	3b 45 08             	cmp    0x8(%ebp),%eax
80104acd:	75 32                	jne    80104b01 <kill+0x58>
      p->killed = 1;
80104acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad2:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104adc:	8b 40 10             	mov    0x10(%eax),%eax
80104adf:	83 f8 02             	cmp    $0x2,%eax
80104ae2:	75 0a                	jne    80104aee <kill+0x45>
        p->state = RUNNABLE;
80104ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae7:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
      release(&ptable.lock);
80104aee:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104af5:	e8 e3 02 00 00       	call   80104ddd <release>
      return 0;
80104afa:	b8 00 00 00 00       	mov    $0x0,%eax
80104aff:	eb 1e                	jmp    80104b1f <kill+0x76>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b01:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104b05:	81 7d f4 d4 5d 11 80 	cmpl   $0x80115dd4,-0xc(%ebp)
80104b0c:	72 b6                	jb     80104ac4 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104b0e:	c7 04 24 a0 3d 11 80 	movl   $0x80113da0,(%esp)
80104b15:	e8 c3 02 00 00       	call   80104ddd <release>
  return -1;
80104b1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104b1f:	c9                   	leave  
80104b20:	c3                   	ret    

80104b21 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104b21:	55                   	push   %ebp
80104b22:	89 e5                	mov    %esp,%ebp
80104b24:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b27:	c7 45 f0 d4 3d 11 80 	movl   $0x80113dd4,-0x10(%ebp)
80104b2e:	e9 d6 00 00 00       	jmp    80104c09 <procdump+0xe8>
    if(p->state == UNUSED)
80104b33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b36:	8b 40 10             	mov    0x10(%eax),%eax
80104b39:	85 c0                	test   %eax,%eax
80104b3b:	75 05                	jne    80104b42 <procdump+0x21>
      continue;
80104b3d:	e9 c3 00 00 00       	jmp    80104c05 <procdump+0xe4>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104b42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b45:	8b 40 10             	mov    0x10(%eax),%eax
80104b48:	83 f8 05             	cmp    $0x5,%eax
80104b4b:	77 23                	ja     80104b70 <procdump+0x4f>
80104b4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b50:	8b 40 10             	mov    0x10(%eax),%eax
80104b53:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104b5a:	85 c0                	test   %eax,%eax
80104b5c:	74 12                	je     80104b70 <procdump+0x4f>
      state = states[p->state];
80104b5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b61:	8b 40 10             	mov    0x10(%eax),%eax
80104b64:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104b6b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104b6e:	eb 07                	jmp    80104b77 <procdump+0x56>
    else
      state = "???";
80104b70:	c7 45 ec 1a 89 10 80 	movl   $0x8010891a,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104b77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b7a:	8d 50 70             	lea    0x70(%eax),%edx
80104b7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b80:	8b 40 14             	mov    0x14(%eax),%eax
80104b83:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104b87:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104b8a:	89 54 24 08          	mov    %edx,0x8(%esp)
80104b8e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b92:	c7 04 24 1e 89 10 80 	movl   $0x8010891e,(%esp)
80104b99:	e8 2a b8 ff ff       	call   801003c8 <cprintf>
    if(p->state == SLEEPING){
80104b9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ba1:	8b 40 10             	mov    0x10(%eax),%eax
80104ba4:	83 f8 02             	cmp    $0x2,%eax
80104ba7:	75 50                	jne    80104bf9 <procdump+0xd8>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104ba9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bac:	8b 40 20             	mov    0x20(%eax),%eax
80104baf:	8b 40 0c             	mov    0xc(%eax),%eax
80104bb2:	83 c0 08             	add    $0x8,%eax
80104bb5:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104bb8:	89 54 24 04          	mov    %edx,0x4(%esp)
80104bbc:	89 04 24             	mov    %eax,(%esp)
80104bbf:	e8 64 02 00 00       	call   80104e28 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104bc4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104bcb:	eb 1b                	jmp    80104be8 <procdump+0xc7>
        cprintf(" %p", pc[i]);
80104bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd0:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104bd4:	89 44 24 04          	mov    %eax,0x4(%esp)
80104bd8:	c7 04 24 27 89 10 80 	movl   $0x80108927,(%esp)
80104bdf:	e8 e4 b7 ff ff       	call   801003c8 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104be4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104be8:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104bec:	7f 0b                	jg     80104bf9 <procdump+0xd8>
80104bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf1:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104bf5:	85 c0                	test   %eax,%eax
80104bf7:	75 d4                	jne    80104bcd <procdump+0xac>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104bf9:	c7 04 24 2b 89 10 80 	movl   $0x8010892b,(%esp)
80104c00:	e8 c3 b7 ff ff       	call   801003c8 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c05:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80104c09:	81 7d f0 d4 5d 11 80 	cmpl   $0x80115dd4,-0x10(%ebp)
80104c10:	0f 82 1d ff ff ff    	jb     80104b33 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104c16:	c9                   	leave  
80104c17:	c3                   	ret    

80104c18 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104c18:	55                   	push   %ebp
80104c19:	89 e5                	mov    %esp,%ebp
80104c1b:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
80104c1e:	8b 45 08             	mov    0x8(%ebp),%eax
80104c21:	83 c0 04             	add    $0x4,%eax
80104c24:	c7 44 24 04 57 89 10 	movl   $0x80108957,0x4(%esp)
80104c2b:	80 
80104c2c:	89 04 24             	mov    %eax,(%esp)
80104c2f:	e8 20 01 00 00       	call   80104d54 <initlock>
  lk->name = name;
80104c34:	8b 45 08             	mov    0x8(%ebp),%eax
80104c37:	8b 55 0c             	mov    0xc(%ebp),%edx
80104c3a:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104c3d:	8b 45 08             	mov    0x8(%ebp),%eax
80104c40:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104c46:	8b 45 08             	mov    0x8(%ebp),%eax
80104c49:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104c50:	c9                   	leave  
80104c51:	c3                   	ret    

80104c52 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104c52:	55                   	push   %ebp
80104c53:	89 e5                	mov    %esp,%ebp
80104c55:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80104c58:	8b 45 08             	mov    0x8(%ebp),%eax
80104c5b:	83 c0 04             	add    $0x4,%eax
80104c5e:	89 04 24             	mov    %eax,(%esp)
80104c61:	e8 0f 01 00 00       	call   80104d75 <acquire>
  while (lk->locked) {
80104c66:	eb 15                	jmp    80104c7d <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
80104c68:	8b 45 08             	mov    0x8(%ebp),%eax
80104c6b:	83 c0 04             	add    $0x4,%eax
80104c6e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c72:	8b 45 08             	mov    0x8(%ebp),%eax
80104c75:	89 04 24             	mov    %eax,(%esp)
80104c78:	e8 2d fd ff ff       	call   801049aa <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80104c7d:	8b 45 08             	mov    0x8(%ebp),%eax
80104c80:	8b 00                	mov    (%eax),%eax
80104c82:	85 c0                	test   %eax,%eax
80104c84:	75 e2                	jne    80104c68 <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
80104c86:	8b 45 08             	mov    0x8(%ebp),%eax
80104c89:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104c8f:	e8 be f4 ff ff       	call   80104152 <myproc>
80104c94:	8b 50 14             	mov    0x14(%eax),%edx
80104c97:	8b 45 08             	mov    0x8(%ebp),%eax
80104c9a:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104c9d:	8b 45 08             	mov    0x8(%ebp),%eax
80104ca0:	83 c0 04             	add    $0x4,%eax
80104ca3:	89 04 24             	mov    %eax,(%esp)
80104ca6:	e8 32 01 00 00       	call   80104ddd <release>
}
80104cab:	c9                   	leave  
80104cac:	c3                   	ret    

80104cad <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104cad:	55                   	push   %ebp
80104cae:	89 e5                	mov    %esp,%ebp
80104cb0:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80104cb3:	8b 45 08             	mov    0x8(%ebp),%eax
80104cb6:	83 c0 04             	add    $0x4,%eax
80104cb9:	89 04 24             	mov    %eax,(%esp)
80104cbc:	e8 b4 00 00 00       	call   80104d75 <acquire>
  lk->locked = 0;
80104cc1:	8b 45 08             	mov    0x8(%ebp),%eax
80104cc4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104cca:	8b 45 08             	mov    0x8(%ebp),%eax
80104ccd:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104cd4:	8b 45 08             	mov    0x8(%ebp),%eax
80104cd7:	89 04 24             	mov    %eax,(%esp)
80104cda:	e8 9f fd ff ff       	call   80104a7e <wakeup>
  release(&lk->lk);
80104cdf:	8b 45 08             	mov    0x8(%ebp),%eax
80104ce2:	83 c0 04             	add    $0x4,%eax
80104ce5:	89 04 24             	mov    %eax,(%esp)
80104ce8:	e8 f0 00 00 00       	call   80104ddd <release>
}
80104ced:	c9                   	leave  
80104cee:	c3                   	ret    

80104cef <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104cef:	55                   	push   %ebp
80104cf0:	89 e5                	mov    %esp,%ebp
80104cf2:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
80104cf5:	8b 45 08             	mov    0x8(%ebp),%eax
80104cf8:	83 c0 04             	add    $0x4,%eax
80104cfb:	89 04 24             	mov    %eax,(%esp)
80104cfe:	e8 72 00 00 00       	call   80104d75 <acquire>
  r = lk->locked;
80104d03:	8b 45 08             	mov    0x8(%ebp),%eax
80104d06:	8b 00                	mov    (%eax),%eax
80104d08:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104d0b:	8b 45 08             	mov    0x8(%ebp),%eax
80104d0e:	83 c0 04             	add    $0x4,%eax
80104d11:	89 04 24             	mov    %eax,(%esp)
80104d14:	e8 c4 00 00 00       	call   80104ddd <release>
  return r;
80104d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104d1c:	c9                   	leave  
80104d1d:	c3                   	ret    

80104d1e <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104d1e:	55                   	push   %ebp
80104d1f:	89 e5                	mov    %esp,%ebp
80104d21:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104d24:	9c                   	pushf  
80104d25:	58                   	pop    %eax
80104d26:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104d29:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d2c:	c9                   	leave  
80104d2d:	c3                   	ret    

80104d2e <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104d2e:	55                   	push   %ebp
80104d2f:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104d31:	fa                   	cli    
}
80104d32:	5d                   	pop    %ebp
80104d33:	c3                   	ret    

80104d34 <sti>:

static inline void
sti(void)
{
80104d34:	55                   	push   %ebp
80104d35:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104d37:	fb                   	sti    
}
80104d38:	5d                   	pop    %ebp
80104d39:	c3                   	ret    

80104d3a <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104d3a:	55                   	push   %ebp
80104d3b:	89 e5                	mov    %esp,%ebp
80104d3d:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104d40:	8b 55 08             	mov    0x8(%ebp),%edx
80104d43:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d46:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d49:	f0 87 02             	lock xchg %eax,(%edx)
80104d4c:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104d4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d52:	c9                   	leave  
80104d53:	c3                   	ret    

80104d54 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104d54:	55                   	push   %ebp
80104d55:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104d57:	8b 45 08             	mov    0x8(%ebp),%eax
80104d5a:	8b 55 0c             	mov    0xc(%ebp),%edx
80104d5d:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104d60:	8b 45 08             	mov    0x8(%ebp),%eax
80104d63:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104d69:	8b 45 08             	mov    0x8(%ebp),%eax
80104d6c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104d73:	5d                   	pop    %ebp
80104d74:	c3                   	ret    

80104d75 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104d75:	55                   	push   %ebp
80104d76:	89 e5                	mov    %esp,%ebp
80104d78:	53                   	push   %ebx
80104d79:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104d7c:	e8 51 01 00 00       	call   80104ed2 <pushcli>
  if(holding(lk))
80104d81:	8b 45 08             	mov    0x8(%ebp),%eax
80104d84:	89 04 24             	mov    %eax,(%esp)
80104d87:	e8 15 01 00 00       	call   80104ea1 <holding>
80104d8c:	85 c0                	test   %eax,%eax
80104d8e:	74 0c                	je     80104d9c <acquire+0x27>
    panic("acquire");
80104d90:	c7 04 24 62 89 10 80 	movl   $0x80108962,(%esp)
80104d97:	e8 c6 b7 ff ff       	call   80100562 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104d9c:	90                   	nop
80104d9d:	8b 45 08             	mov    0x8(%ebp),%eax
80104da0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104da7:	00 
80104da8:	89 04 24             	mov    %eax,(%esp)
80104dab:	e8 8a ff ff ff       	call   80104d3a <xchg>
80104db0:	85 c0                	test   %eax,%eax
80104db2:	75 e9                	jne    80104d9d <acquire+0x28>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104db4:	0f ae f0             	mfence 

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104db7:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104dba:	e8 1d f3 ff ff       	call   801040dc <mycpu>
80104dbf:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104dc2:	8b 45 08             	mov    0x8(%ebp),%eax
80104dc5:	83 c0 0c             	add    $0xc,%eax
80104dc8:	89 44 24 04          	mov    %eax,0x4(%esp)
80104dcc:	8d 45 08             	lea    0x8(%ebp),%eax
80104dcf:	89 04 24             	mov    %eax,(%esp)
80104dd2:	e8 51 00 00 00       	call   80104e28 <getcallerpcs>
}
80104dd7:	83 c4 14             	add    $0x14,%esp
80104dda:	5b                   	pop    %ebx
80104ddb:	5d                   	pop    %ebp
80104ddc:	c3                   	ret    

80104ddd <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104ddd:	55                   	push   %ebp
80104dde:	89 e5                	mov    %esp,%ebp
80104de0:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80104de3:	8b 45 08             	mov    0x8(%ebp),%eax
80104de6:	89 04 24             	mov    %eax,(%esp)
80104de9:	e8 b3 00 00 00       	call   80104ea1 <holding>
80104dee:	85 c0                	test   %eax,%eax
80104df0:	75 0c                	jne    80104dfe <release+0x21>
    panic("release");
80104df2:	c7 04 24 6a 89 10 80 	movl   $0x8010896a,(%esp)
80104df9:	e8 64 b7 ff ff       	call   80100562 <panic>

  lk->pcs[0] = 0;
80104dfe:	8b 45 08             	mov    0x8(%ebp),%eax
80104e01:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104e08:	8b 45 08             	mov    0x8(%ebp),%eax
80104e0b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104e12:	0f ae f0             	mfence 

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104e15:	8b 45 08             	mov    0x8(%ebp),%eax
80104e18:	8b 55 08             	mov    0x8(%ebp),%edx
80104e1b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104e21:	e8 f8 00 00 00       	call   80104f1e <popcli>
}
80104e26:	c9                   	leave  
80104e27:	c3                   	ret    

80104e28 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104e28:	55                   	push   %ebp
80104e29:	89 e5                	mov    %esp,%ebp
80104e2b:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104e2e:	8b 45 08             	mov    0x8(%ebp),%eax
80104e31:	83 e8 08             	sub    $0x8,%eax
80104e34:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104e37:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104e3e:	eb 38                	jmp    80104e78 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104e40:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104e44:	74 38                	je     80104e7e <getcallerpcs+0x56>
80104e46:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104e4d:	76 2f                	jbe    80104e7e <getcallerpcs+0x56>
80104e4f:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104e53:	74 29                	je     80104e7e <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104e55:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e58:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104e5f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e62:	01 c2                	add    %eax,%edx
80104e64:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e67:	8b 40 04             	mov    0x4(%eax),%eax
80104e6a:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104e6c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e6f:	8b 00                	mov    (%eax),%eax
80104e71:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104e74:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104e78:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104e7c:	7e c2                	jle    80104e40 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104e7e:	eb 19                	jmp    80104e99 <getcallerpcs+0x71>
    pcs[i] = 0;
80104e80:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e83:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104e8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e8d:	01 d0                	add    %edx,%eax
80104e8f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104e95:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104e99:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104e9d:	7e e1                	jle    80104e80 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80104e9f:	c9                   	leave  
80104ea0:	c3                   	ret    

80104ea1 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104ea1:	55                   	push   %ebp
80104ea2:	89 e5                	mov    %esp,%ebp
80104ea4:	53                   	push   %ebx
80104ea5:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104ea8:	8b 45 08             	mov    0x8(%ebp),%eax
80104eab:	8b 00                	mov    (%eax),%eax
80104ead:	85 c0                	test   %eax,%eax
80104eaf:	74 16                	je     80104ec7 <holding+0x26>
80104eb1:	8b 45 08             	mov    0x8(%ebp),%eax
80104eb4:	8b 58 08             	mov    0x8(%eax),%ebx
80104eb7:	e8 20 f2 ff ff       	call   801040dc <mycpu>
80104ebc:	39 c3                	cmp    %eax,%ebx
80104ebe:	75 07                	jne    80104ec7 <holding+0x26>
80104ec0:	b8 01 00 00 00       	mov    $0x1,%eax
80104ec5:	eb 05                	jmp    80104ecc <holding+0x2b>
80104ec7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ecc:	83 c4 04             	add    $0x4,%esp
80104ecf:	5b                   	pop    %ebx
80104ed0:	5d                   	pop    %ebp
80104ed1:	c3                   	ret    

80104ed2 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104ed2:	55                   	push   %ebp
80104ed3:	89 e5                	mov    %esp,%ebp
80104ed5:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104ed8:	e8 41 fe ff ff       	call   80104d1e <readeflags>
80104edd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104ee0:	e8 49 fe ff ff       	call   80104d2e <cli>
  if(mycpu()->ncli == 0)
80104ee5:	e8 f2 f1 ff ff       	call   801040dc <mycpu>
80104eea:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104ef0:	85 c0                	test   %eax,%eax
80104ef2:	75 14                	jne    80104f08 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104ef4:	e8 e3 f1 ff ff       	call   801040dc <mycpu>
80104ef9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104efc:	81 e2 00 02 00 00    	and    $0x200,%edx
80104f02:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104f08:	e8 cf f1 ff ff       	call   801040dc <mycpu>
80104f0d:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104f13:	83 c2 01             	add    $0x1,%edx
80104f16:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104f1c:	c9                   	leave  
80104f1d:	c3                   	ret    

80104f1e <popcli>:

void
popcli(void)
{
80104f1e:	55                   	push   %ebp
80104f1f:	89 e5                	mov    %esp,%ebp
80104f21:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80104f24:	e8 f5 fd ff ff       	call   80104d1e <readeflags>
80104f29:	25 00 02 00 00       	and    $0x200,%eax
80104f2e:	85 c0                	test   %eax,%eax
80104f30:	74 0c                	je     80104f3e <popcli+0x20>
    panic("popcli - interruptible");
80104f32:	c7 04 24 72 89 10 80 	movl   $0x80108972,(%esp)
80104f39:	e8 24 b6 ff ff       	call   80100562 <panic>
  if(--mycpu()->ncli < 0)
80104f3e:	e8 99 f1 ff ff       	call   801040dc <mycpu>
80104f43:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104f49:	83 ea 01             	sub    $0x1,%edx
80104f4c:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104f52:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104f58:	85 c0                	test   %eax,%eax
80104f5a:	79 0c                	jns    80104f68 <popcli+0x4a>
    panic("popcli");
80104f5c:	c7 04 24 89 89 10 80 	movl   $0x80108989,(%esp)
80104f63:	e8 fa b5 ff ff       	call   80100562 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104f68:	e8 6f f1 ff ff       	call   801040dc <mycpu>
80104f6d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104f73:	85 c0                	test   %eax,%eax
80104f75:	75 14                	jne    80104f8b <popcli+0x6d>
80104f77:	e8 60 f1 ff ff       	call   801040dc <mycpu>
80104f7c:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104f82:	85 c0                	test   %eax,%eax
80104f84:	74 05                	je     80104f8b <popcli+0x6d>
    sti();
80104f86:	e8 a9 fd ff ff       	call   80104d34 <sti>
}
80104f8b:	c9                   	leave  
80104f8c:	c3                   	ret    

80104f8d <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80104f8d:	55                   	push   %ebp
80104f8e:	89 e5                	mov    %esp,%ebp
80104f90:	57                   	push   %edi
80104f91:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104f92:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104f95:	8b 55 10             	mov    0x10(%ebp),%edx
80104f98:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f9b:	89 cb                	mov    %ecx,%ebx
80104f9d:	89 df                	mov    %ebx,%edi
80104f9f:	89 d1                	mov    %edx,%ecx
80104fa1:	fc                   	cld    
80104fa2:	f3 aa                	rep stos %al,%es:(%edi)
80104fa4:	89 ca                	mov    %ecx,%edx
80104fa6:	89 fb                	mov    %edi,%ebx
80104fa8:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104fab:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80104fae:	5b                   	pop    %ebx
80104faf:	5f                   	pop    %edi
80104fb0:	5d                   	pop    %ebp
80104fb1:	c3                   	ret    

80104fb2 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80104fb2:	55                   	push   %ebp
80104fb3:	89 e5                	mov    %esp,%ebp
80104fb5:	57                   	push   %edi
80104fb6:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104fb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104fba:	8b 55 10             	mov    0x10(%ebp),%edx
80104fbd:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fc0:	89 cb                	mov    %ecx,%ebx
80104fc2:	89 df                	mov    %ebx,%edi
80104fc4:	89 d1                	mov    %edx,%ecx
80104fc6:	fc                   	cld    
80104fc7:	f3 ab                	rep stos %eax,%es:(%edi)
80104fc9:	89 ca                	mov    %ecx,%edx
80104fcb:	89 fb                	mov    %edi,%ebx
80104fcd:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104fd0:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80104fd3:	5b                   	pop    %ebx
80104fd4:	5f                   	pop    %edi
80104fd5:	5d                   	pop    %ebp
80104fd6:	c3                   	ret    

80104fd7 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104fd7:	55                   	push   %ebp
80104fd8:	89 e5                	mov    %esp,%ebp
80104fda:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80104fdd:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe0:	83 e0 03             	and    $0x3,%eax
80104fe3:	85 c0                	test   %eax,%eax
80104fe5:	75 49                	jne    80105030 <memset+0x59>
80104fe7:	8b 45 10             	mov    0x10(%ebp),%eax
80104fea:	83 e0 03             	and    $0x3,%eax
80104fed:	85 c0                	test   %eax,%eax
80104fef:	75 3f                	jne    80105030 <memset+0x59>
    c &= 0xFF;
80104ff1:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104ff8:	8b 45 10             	mov    0x10(%ebp),%eax
80104ffb:	c1 e8 02             	shr    $0x2,%eax
80104ffe:	89 c2                	mov    %eax,%edx
80105000:	8b 45 0c             	mov    0xc(%ebp),%eax
80105003:	c1 e0 18             	shl    $0x18,%eax
80105006:	89 c1                	mov    %eax,%ecx
80105008:	8b 45 0c             	mov    0xc(%ebp),%eax
8010500b:	c1 e0 10             	shl    $0x10,%eax
8010500e:	09 c1                	or     %eax,%ecx
80105010:	8b 45 0c             	mov    0xc(%ebp),%eax
80105013:	c1 e0 08             	shl    $0x8,%eax
80105016:	09 c8                	or     %ecx,%eax
80105018:	0b 45 0c             	or     0xc(%ebp),%eax
8010501b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010501f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105023:	8b 45 08             	mov    0x8(%ebp),%eax
80105026:	89 04 24             	mov    %eax,(%esp)
80105029:	e8 84 ff ff ff       	call   80104fb2 <stosl>
8010502e:	eb 19                	jmp    80105049 <memset+0x72>
  } else
    stosb(dst, c, n);
80105030:	8b 45 10             	mov    0x10(%ebp),%eax
80105033:	89 44 24 08          	mov    %eax,0x8(%esp)
80105037:	8b 45 0c             	mov    0xc(%ebp),%eax
8010503a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010503e:	8b 45 08             	mov    0x8(%ebp),%eax
80105041:	89 04 24             	mov    %eax,(%esp)
80105044:	e8 44 ff ff ff       	call   80104f8d <stosb>
  return dst;
80105049:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010504c:	c9                   	leave  
8010504d:	c3                   	ret    

8010504e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010504e:	55                   	push   %ebp
8010504f:	89 e5                	mov    %esp,%ebp
80105051:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105054:	8b 45 08             	mov    0x8(%ebp),%eax
80105057:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010505a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010505d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105060:	eb 30                	jmp    80105092 <memcmp+0x44>
    if(*s1 != *s2)
80105062:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105065:	0f b6 10             	movzbl (%eax),%edx
80105068:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010506b:	0f b6 00             	movzbl (%eax),%eax
8010506e:	38 c2                	cmp    %al,%dl
80105070:	74 18                	je     8010508a <memcmp+0x3c>
      return *s1 - *s2;
80105072:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105075:	0f b6 00             	movzbl (%eax),%eax
80105078:	0f b6 d0             	movzbl %al,%edx
8010507b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010507e:	0f b6 00             	movzbl (%eax),%eax
80105081:	0f b6 c0             	movzbl %al,%eax
80105084:	29 c2                	sub    %eax,%edx
80105086:	89 d0                	mov    %edx,%eax
80105088:	eb 1a                	jmp    801050a4 <memcmp+0x56>
    s1++, s2++;
8010508a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010508e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105092:	8b 45 10             	mov    0x10(%ebp),%eax
80105095:	8d 50 ff             	lea    -0x1(%eax),%edx
80105098:	89 55 10             	mov    %edx,0x10(%ebp)
8010509b:	85 c0                	test   %eax,%eax
8010509d:	75 c3                	jne    80105062 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010509f:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050a4:	c9                   	leave  
801050a5:	c3                   	ret    

801050a6 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801050a6:	55                   	push   %ebp
801050a7:	89 e5                	mov    %esp,%ebp
801050a9:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801050ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801050af:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801050b2:	8b 45 08             	mov    0x8(%ebp),%eax
801050b5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801050b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050bb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801050be:	73 3d                	jae    801050fd <memmove+0x57>
801050c0:	8b 45 10             	mov    0x10(%ebp),%eax
801050c3:	8b 55 fc             	mov    -0x4(%ebp),%edx
801050c6:	01 d0                	add    %edx,%eax
801050c8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801050cb:	76 30                	jbe    801050fd <memmove+0x57>
    s += n;
801050cd:	8b 45 10             	mov    0x10(%ebp),%eax
801050d0:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801050d3:	8b 45 10             	mov    0x10(%ebp),%eax
801050d6:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801050d9:	eb 13                	jmp    801050ee <memmove+0x48>
      *--d = *--s;
801050db:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801050df:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801050e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050e6:	0f b6 10             	movzbl (%eax),%edx
801050e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050ec:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801050ee:	8b 45 10             	mov    0x10(%ebp),%eax
801050f1:	8d 50 ff             	lea    -0x1(%eax),%edx
801050f4:	89 55 10             	mov    %edx,0x10(%ebp)
801050f7:	85 c0                	test   %eax,%eax
801050f9:	75 e0                	jne    801050db <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801050fb:	eb 26                	jmp    80105123 <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801050fd:	eb 17                	jmp    80105116 <memmove+0x70>
      *d++ = *s++;
801050ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105102:	8d 50 01             	lea    0x1(%eax),%edx
80105105:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105108:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010510b:	8d 4a 01             	lea    0x1(%edx),%ecx
8010510e:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105111:	0f b6 12             	movzbl (%edx),%edx
80105114:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105116:	8b 45 10             	mov    0x10(%ebp),%eax
80105119:	8d 50 ff             	lea    -0x1(%eax),%edx
8010511c:	89 55 10             	mov    %edx,0x10(%ebp)
8010511f:	85 c0                	test   %eax,%eax
80105121:	75 dc                	jne    801050ff <memmove+0x59>
      *d++ = *s++;

  return dst;
80105123:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105126:	c9                   	leave  
80105127:	c3                   	ret    

80105128 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105128:	55                   	push   %ebp
80105129:	89 e5                	mov    %esp,%ebp
8010512b:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010512e:	8b 45 10             	mov    0x10(%ebp),%eax
80105131:	89 44 24 08          	mov    %eax,0x8(%esp)
80105135:	8b 45 0c             	mov    0xc(%ebp),%eax
80105138:	89 44 24 04          	mov    %eax,0x4(%esp)
8010513c:	8b 45 08             	mov    0x8(%ebp),%eax
8010513f:	89 04 24             	mov    %eax,(%esp)
80105142:	e8 5f ff ff ff       	call   801050a6 <memmove>
}
80105147:	c9                   	leave  
80105148:	c3                   	ret    

80105149 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105149:	55                   	push   %ebp
8010514a:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010514c:	eb 0c                	jmp    8010515a <strncmp+0x11>
    n--, p++, q++;
8010514e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105152:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105156:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
8010515a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010515e:	74 1a                	je     8010517a <strncmp+0x31>
80105160:	8b 45 08             	mov    0x8(%ebp),%eax
80105163:	0f b6 00             	movzbl (%eax),%eax
80105166:	84 c0                	test   %al,%al
80105168:	74 10                	je     8010517a <strncmp+0x31>
8010516a:	8b 45 08             	mov    0x8(%ebp),%eax
8010516d:	0f b6 10             	movzbl (%eax),%edx
80105170:	8b 45 0c             	mov    0xc(%ebp),%eax
80105173:	0f b6 00             	movzbl (%eax),%eax
80105176:	38 c2                	cmp    %al,%dl
80105178:	74 d4                	je     8010514e <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
8010517a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010517e:	75 07                	jne    80105187 <strncmp+0x3e>
    return 0;
80105180:	b8 00 00 00 00       	mov    $0x0,%eax
80105185:	eb 16                	jmp    8010519d <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105187:	8b 45 08             	mov    0x8(%ebp),%eax
8010518a:	0f b6 00             	movzbl (%eax),%eax
8010518d:	0f b6 d0             	movzbl %al,%edx
80105190:	8b 45 0c             	mov    0xc(%ebp),%eax
80105193:	0f b6 00             	movzbl (%eax),%eax
80105196:	0f b6 c0             	movzbl %al,%eax
80105199:	29 c2                	sub    %eax,%edx
8010519b:	89 d0                	mov    %edx,%eax
}
8010519d:	5d                   	pop    %ebp
8010519e:	c3                   	ret    

8010519f <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010519f:	55                   	push   %ebp
801051a0:	89 e5                	mov    %esp,%ebp
801051a2:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801051a5:	8b 45 08             	mov    0x8(%ebp),%eax
801051a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801051ab:	90                   	nop
801051ac:	8b 45 10             	mov    0x10(%ebp),%eax
801051af:	8d 50 ff             	lea    -0x1(%eax),%edx
801051b2:	89 55 10             	mov    %edx,0x10(%ebp)
801051b5:	85 c0                	test   %eax,%eax
801051b7:	7e 1e                	jle    801051d7 <strncpy+0x38>
801051b9:	8b 45 08             	mov    0x8(%ebp),%eax
801051bc:	8d 50 01             	lea    0x1(%eax),%edx
801051bf:	89 55 08             	mov    %edx,0x8(%ebp)
801051c2:	8b 55 0c             	mov    0xc(%ebp),%edx
801051c5:	8d 4a 01             	lea    0x1(%edx),%ecx
801051c8:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801051cb:	0f b6 12             	movzbl (%edx),%edx
801051ce:	88 10                	mov    %dl,(%eax)
801051d0:	0f b6 00             	movzbl (%eax),%eax
801051d3:	84 c0                	test   %al,%al
801051d5:	75 d5                	jne    801051ac <strncpy+0xd>
    ;
  while(n-- > 0)
801051d7:	eb 0c                	jmp    801051e5 <strncpy+0x46>
    *s++ = 0;
801051d9:	8b 45 08             	mov    0x8(%ebp),%eax
801051dc:	8d 50 01             	lea    0x1(%eax),%edx
801051df:	89 55 08             	mov    %edx,0x8(%ebp)
801051e2:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801051e5:	8b 45 10             	mov    0x10(%ebp),%eax
801051e8:	8d 50 ff             	lea    -0x1(%eax),%edx
801051eb:	89 55 10             	mov    %edx,0x10(%ebp)
801051ee:	85 c0                	test   %eax,%eax
801051f0:	7f e7                	jg     801051d9 <strncpy+0x3a>
    *s++ = 0;
  return os;
801051f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801051f5:	c9                   	leave  
801051f6:	c3                   	ret    

801051f7 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801051f7:	55                   	push   %ebp
801051f8:	89 e5                	mov    %esp,%ebp
801051fa:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801051fd:	8b 45 08             	mov    0x8(%ebp),%eax
80105200:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105203:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105207:	7f 05                	jg     8010520e <safestrcpy+0x17>
    return os;
80105209:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010520c:	eb 31                	jmp    8010523f <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
8010520e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105212:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105216:	7e 1e                	jle    80105236 <safestrcpy+0x3f>
80105218:	8b 45 08             	mov    0x8(%ebp),%eax
8010521b:	8d 50 01             	lea    0x1(%eax),%edx
8010521e:	89 55 08             	mov    %edx,0x8(%ebp)
80105221:	8b 55 0c             	mov    0xc(%ebp),%edx
80105224:	8d 4a 01             	lea    0x1(%edx),%ecx
80105227:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010522a:	0f b6 12             	movzbl (%edx),%edx
8010522d:	88 10                	mov    %dl,(%eax)
8010522f:	0f b6 00             	movzbl (%eax),%eax
80105232:	84 c0                	test   %al,%al
80105234:	75 d8                	jne    8010520e <safestrcpy+0x17>
    ;
  *s = 0;
80105236:	8b 45 08             	mov    0x8(%ebp),%eax
80105239:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010523c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010523f:	c9                   	leave  
80105240:	c3                   	ret    

80105241 <strlen>:

int
strlen(const char *s)
{
80105241:	55                   	push   %ebp
80105242:	89 e5                	mov    %esp,%ebp
80105244:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105247:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010524e:	eb 04                	jmp    80105254 <strlen+0x13>
80105250:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105254:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105257:	8b 45 08             	mov    0x8(%ebp),%eax
8010525a:	01 d0                	add    %edx,%eax
8010525c:	0f b6 00             	movzbl (%eax),%eax
8010525f:	84 c0                	test   %al,%al
80105261:	75 ed                	jne    80105250 <strlen+0xf>
    ;
  return n;
80105263:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105266:	c9                   	leave  
80105267:	c3                   	ret    

80105268 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105268:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010526c:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105270:	55                   	push   %ebp
  pushl %ebx
80105271:	53                   	push   %ebx
  pushl %esi
80105272:	56                   	push   %esi
  pushl %edi
80105273:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105274:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105276:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105278:	5f                   	pop    %edi
  popl %esi
80105279:	5e                   	pop    %esi
  popl %ebx
8010527a:	5b                   	pop    %ebx
  popl %ebp
8010527b:	5d                   	pop    %ebp
  ret
8010527c:	c3                   	ret    

8010527d <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010527d:	55                   	push   %ebp
8010527e:	89 e5                	mov    %esp,%ebp
  //struct proc *curproc = myproc();

  if(addr >= STACKTOP || addr+4 > STACKTOP)
80105280:	81 7d 08 fe ff ff 7f 	cmpl   $0x7ffffffe,0x8(%ebp)
80105287:	77 0a                	ja     80105293 <fetchint+0x16>
80105289:	8b 45 08             	mov    0x8(%ebp),%eax
8010528c:	83 c0 04             	add    $0x4,%eax
8010528f:	85 c0                	test   %eax,%eax
80105291:	79 07                	jns    8010529a <fetchint+0x1d>
    return -1;
80105293:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105298:	eb 0f                	jmp    801052a9 <fetchint+0x2c>
  *ip = *(int*)(addr);
8010529a:	8b 45 08             	mov    0x8(%ebp),%eax
8010529d:	8b 10                	mov    (%eax),%edx
8010529f:	8b 45 0c             	mov    0xc(%ebp),%eax
801052a2:	89 10                	mov    %edx,(%eax)
  return 0;
801052a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052a9:	5d                   	pop    %ebp
801052aa:	c3                   	ret    

801052ab <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801052ab:	55                   	push   %ebp
801052ac:	89 e5                	mov    %esp,%ebp
801052ae:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;
  //struct proc *curproc = myproc();

  if(addr >= STACKTOP)
801052b1:	81 7d 08 fe ff ff 7f 	cmpl   $0x7ffffffe,0x8(%ebp)
801052b8:	76 07                	jbe    801052c1 <fetchstr+0x16>
    return -1;
801052ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052bf:	eb 42                	jmp    80105303 <fetchstr+0x58>
  *pp = (char*)addr;
801052c1:	8b 55 08             	mov    0x8(%ebp),%edx
801052c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801052c7:	89 10                	mov    %edx,(%eax)
  ep = (char*)STACKTOP;
801052c9:	c7 45 f8 ff ff ff 7f 	movl   $0x7fffffff,-0x8(%ebp)
  for(s = *pp; s < ep; s++){
801052d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801052d3:	8b 00                	mov    (%eax),%eax
801052d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
801052d8:	eb 1c                	jmp    801052f6 <fetchstr+0x4b>
    if(*s == 0)
801052da:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052dd:	0f b6 00             	movzbl (%eax),%eax
801052e0:	84 c0                	test   %al,%al
801052e2:	75 0e                	jne    801052f2 <fetchstr+0x47>
      return s - *pp;
801052e4:	8b 55 fc             	mov    -0x4(%ebp),%edx
801052e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801052ea:	8b 00                	mov    (%eax),%eax
801052ec:	29 c2                	sub    %eax,%edx
801052ee:	89 d0                	mov    %edx,%eax
801052f0:	eb 11                	jmp    80105303 <fetchstr+0x58>

  if(addr >= STACKTOP)
    return -1;
  *pp = (char*)addr;
  ep = (char*)STACKTOP;
  for(s = *pp; s < ep; s++){
801052f2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801052f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052f9:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801052fc:	72 dc                	jb     801052da <fetchstr+0x2f>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
801052fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105303:	c9                   	leave  
80105304:	c3                   	ret    

80105305 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105305:	55                   	push   %ebp
80105306:	89 e5                	mov    %esp,%ebp
80105308:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010530b:	e8 42 ee ff ff       	call   80104152 <myproc>
80105310:	8b 40 1c             	mov    0x1c(%eax),%eax
80105313:	8b 50 44             	mov    0x44(%eax),%edx
80105316:	8b 45 08             	mov    0x8(%ebp),%eax
80105319:	c1 e0 02             	shl    $0x2,%eax
8010531c:	01 d0                	add    %edx,%eax
8010531e:	8d 50 04             	lea    0x4(%eax),%edx
80105321:	8b 45 0c             	mov    0xc(%ebp),%eax
80105324:	89 44 24 04          	mov    %eax,0x4(%esp)
80105328:	89 14 24             	mov    %edx,(%esp)
8010532b:	e8 4d ff ff ff       	call   8010527d <fetchint>
}
80105330:	c9                   	leave  
80105331:	c3                   	ret    

80105332 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105332:	55                   	push   %ebp
80105333:	89 e5                	mov    %esp,%ebp
80105335:	83 ec 28             	sub    $0x28,%esp
  int i;
  //struct proc *curproc = myproc();
 
  if(argint(n, &i) < 0)
80105338:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010533b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010533f:	8b 45 08             	mov    0x8(%ebp),%eax
80105342:	89 04 24             	mov    %eax,(%esp)
80105345:	e8 bb ff ff ff       	call   80105305 <argint>
8010534a:	85 c0                	test   %eax,%eax
8010534c:	79 07                	jns    80105355 <argptr+0x23>
    return -1;
8010534e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105353:	eb 34                	jmp    80105389 <argptr+0x57>
  if(size < 0 || (uint)i >= STACKTOP || (uint)i+size > STACKTOP)
80105355:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105359:	78 18                	js     80105373 <argptr+0x41>
8010535b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010535e:	3d fe ff ff 7f       	cmp    $0x7ffffffe,%eax
80105363:	77 0e                	ja     80105373 <argptr+0x41>
80105365:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105368:	89 c2                	mov    %eax,%edx
8010536a:	8b 45 10             	mov    0x10(%ebp),%eax
8010536d:	01 d0                	add    %edx,%eax
8010536f:	85 c0                	test   %eax,%eax
80105371:	79 07                	jns    8010537a <argptr+0x48>
    return -1;
80105373:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105378:	eb 0f                	jmp    80105389 <argptr+0x57>
  *pp = (char*)i;
8010537a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010537d:	89 c2                	mov    %eax,%edx
8010537f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105382:	89 10                	mov    %edx,(%eax)
  return 0;
80105384:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105389:	c9                   	leave  
8010538a:	c3                   	ret    

8010538b <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010538b:	55                   	push   %ebp
8010538c:	89 e5                	mov    %esp,%ebp
8010538e:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105391:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105394:	89 44 24 04          	mov    %eax,0x4(%esp)
80105398:	8b 45 08             	mov    0x8(%ebp),%eax
8010539b:	89 04 24             	mov    %eax,(%esp)
8010539e:	e8 62 ff ff ff       	call   80105305 <argint>
801053a3:	85 c0                	test   %eax,%eax
801053a5:	79 07                	jns    801053ae <argstr+0x23>
    return -1;
801053a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053ac:	eb 12                	jmp    801053c0 <argstr+0x35>
  return fetchstr(addr, pp);
801053ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053b1:	8b 55 0c             	mov    0xc(%ebp),%edx
801053b4:	89 54 24 04          	mov    %edx,0x4(%esp)
801053b8:	89 04 24             	mov    %eax,(%esp)
801053bb:	e8 eb fe ff ff       	call   801052ab <fetchstr>
}
801053c0:	c9                   	leave  
801053c1:	c3                   	ret    

801053c2 <syscall>:
[SYS_shm_close] sys_shm_close
};

void
syscall(void)
{
801053c2:	55                   	push   %ebp
801053c3:	89 e5                	mov    %esp,%ebp
801053c5:	53                   	push   %ebx
801053c6:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
801053c9:	e8 84 ed ff ff       	call   80104152 <myproc>
801053ce:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801053d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053d4:	8b 40 1c             	mov    0x1c(%eax),%eax
801053d7:	8b 40 1c             	mov    0x1c(%eax),%eax
801053da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801053dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801053e1:	7e 2d                	jle    80105410 <syscall+0x4e>
801053e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053e6:	83 f8 17             	cmp    $0x17,%eax
801053e9:	77 25                	ja     80105410 <syscall+0x4e>
801053eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053ee:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
801053f5:	85 c0                	test   %eax,%eax
801053f7:	74 17                	je     80105410 <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
801053f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053fc:	8b 58 1c             	mov    0x1c(%eax),%ebx
801053ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105402:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
80105409:	ff d0                	call   *%eax
8010540b:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010540e:	eb 34                	jmp    80105444 <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105410:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105413:	8d 48 70             	lea    0x70(%eax),%ecx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105416:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105419:	8b 40 14             	mov    0x14(%eax),%eax
8010541c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010541f:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105423:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105427:	89 44 24 04          	mov    %eax,0x4(%esp)
8010542b:	c7 04 24 90 89 10 80 	movl   $0x80108990,(%esp)
80105432:	e8 91 af ff ff       	call   801003c8 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
80105437:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010543a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010543d:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105444:	83 c4 24             	add    $0x24,%esp
80105447:	5b                   	pop    %ebx
80105448:	5d                   	pop    %ebp
80105449:	c3                   	ret    

8010544a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010544a:	55                   	push   %ebp
8010544b:	89 e5                	mov    %esp,%ebp
8010544d:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105450:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105453:	89 44 24 04          	mov    %eax,0x4(%esp)
80105457:	8b 45 08             	mov    0x8(%ebp),%eax
8010545a:	89 04 24             	mov    %eax,(%esp)
8010545d:	e8 a3 fe ff ff       	call   80105305 <argint>
80105462:	85 c0                	test   %eax,%eax
80105464:	79 07                	jns    8010546d <argfd+0x23>
    return -1;
80105466:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010546b:	eb 4f                	jmp    801054bc <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010546d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105470:	85 c0                	test   %eax,%eax
80105472:	78 20                	js     80105494 <argfd+0x4a>
80105474:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105477:	83 f8 0f             	cmp    $0xf,%eax
8010547a:	7f 18                	jg     80105494 <argfd+0x4a>
8010547c:	e8 d1 ec ff ff       	call   80104152 <myproc>
80105481:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105484:	83 c2 08             	add    $0x8,%edx
80105487:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010548b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010548e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105492:	75 07                	jne    8010549b <argfd+0x51>
    return -1;
80105494:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105499:	eb 21                	jmp    801054bc <argfd+0x72>
  if(pfd)
8010549b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010549f:	74 08                	je     801054a9 <argfd+0x5f>
    *pfd = fd;
801054a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801054a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801054a7:	89 10                	mov    %edx,(%eax)
  if(pf)
801054a9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054ad:	74 08                	je     801054b7 <argfd+0x6d>
    *pf = f;
801054af:	8b 45 10             	mov    0x10(%ebp),%eax
801054b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054b5:	89 10                	mov    %edx,(%eax)
  return 0;
801054b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054bc:	c9                   	leave  
801054bd:	c3                   	ret    

801054be <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801054be:	55                   	push   %ebp
801054bf:	89 e5                	mov    %esp,%ebp
801054c1:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801054c4:	e8 89 ec ff ff       	call   80104152 <myproc>
801054c9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801054cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801054d3:	eb 2a                	jmp    801054ff <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
801054d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054db:	83 c2 08             	add    $0x8,%edx
801054de:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801054e2:	85 c0                	test   %eax,%eax
801054e4:	75 15                	jne    801054fb <fdalloc+0x3d>
      curproc->ofile[fd] = f;
801054e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054ec:	8d 4a 08             	lea    0x8(%edx),%ecx
801054ef:	8b 55 08             	mov    0x8(%ebp),%edx
801054f2:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
      return fd;
801054f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054f9:	eb 0f                	jmp    8010550a <fdalloc+0x4c>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
801054fb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801054ff:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105503:	7e d0                	jle    801054d5 <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105505:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010550a:	c9                   	leave  
8010550b:	c3                   	ret    

8010550c <sys_dup>:

int
sys_dup(void)
{
8010550c:	55                   	push   %ebp
8010550d:	89 e5                	mov    %esp,%ebp
8010550f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105512:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105515:	89 44 24 08          	mov    %eax,0x8(%esp)
80105519:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105520:	00 
80105521:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105528:	e8 1d ff ff ff       	call   8010544a <argfd>
8010552d:	85 c0                	test   %eax,%eax
8010552f:	79 07                	jns    80105538 <sys_dup+0x2c>
    return -1;
80105531:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105536:	eb 29                	jmp    80105561 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105538:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010553b:	89 04 24             	mov    %eax,(%esp)
8010553e:	e8 7b ff ff ff       	call   801054be <fdalloc>
80105543:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105546:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010554a:	79 07                	jns    80105553 <sys_dup+0x47>
    return -1;
8010554c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105551:	eb 0e                	jmp    80105561 <sys_dup+0x55>
  filedup(f);
80105553:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105556:	89 04 24             	mov    %eax,(%esp)
80105559:	e8 73 ba ff ff       	call   80100fd1 <filedup>
  return fd;
8010555e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105561:	c9                   	leave  
80105562:	c3                   	ret    

80105563 <sys_read>:

int
sys_read(void)
{
80105563:	55                   	push   %ebp
80105564:	89 e5                	mov    %esp,%ebp
80105566:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105569:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010556c:	89 44 24 08          	mov    %eax,0x8(%esp)
80105570:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105577:	00 
80105578:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010557f:	e8 c6 fe ff ff       	call   8010544a <argfd>
80105584:	85 c0                	test   %eax,%eax
80105586:	78 35                	js     801055bd <sys_read+0x5a>
80105588:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010558b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010558f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105596:	e8 6a fd ff ff       	call   80105305 <argint>
8010559b:	85 c0                	test   %eax,%eax
8010559d:	78 1e                	js     801055bd <sys_read+0x5a>
8010559f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055a2:	89 44 24 08          	mov    %eax,0x8(%esp)
801055a6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801055a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801055ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801055b4:	e8 79 fd ff ff       	call   80105332 <argptr>
801055b9:	85 c0                	test   %eax,%eax
801055bb:	79 07                	jns    801055c4 <sys_read+0x61>
    return -1;
801055bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055c2:	eb 19                	jmp    801055dd <sys_read+0x7a>
  return fileread(f, p, n);
801055c4:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801055c7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801055ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801055d1:	89 54 24 04          	mov    %edx,0x4(%esp)
801055d5:	89 04 24             	mov    %eax,(%esp)
801055d8:	e8 61 bb ff ff       	call   8010113e <fileread>
}
801055dd:	c9                   	leave  
801055de:	c3                   	ret    

801055df <sys_write>:

int
sys_write(void)
{
801055df:	55                   	push   %ebp
801055e0:	89 e5                	mov    %esp,%ebp
801055e2:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801055e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801055e8:	89 44 24 08          	mov    %eax,0x8(%esp)
801055ec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801055f3:	00 
801055f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801055fb:	e8 4a fe ff ff       	call   8010544a <argfd>
80105600:	85 c0                	test   %eax,%eax
80105602:	78 35                	js     80105639 <sys_write+0x5a>
80105604:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105607:	89 44 24 04          	mov    %eax,0x4(%esp)
8010560b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105612:	e8 ee fc ff ff       	call   80105305 <argint>
80105617:	85 c0                	test   %eax,%eax
80105619:	78 1e                	js     80105639 <sys_write+0x5a>
8010561b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010561e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105622:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105625:	89 44 24 04          	mov    %eax,0x4(%esp)
80105629:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105630:	e8 fd fc ff ff       	call   80105332 <argptr>
80105635:	85 c0                	test   %eax,%eax
80105637:	79 07                	jns    80105640 <sys_write+0x61>
    return -1;
80105639:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010563e:	eb 19                	jmp    80105659 <sys_write+0x7a>
  return filewrite(f, p, n);
80105640:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105643:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105646:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105649:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010564d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105651:	89 04 24             	mov    %eax,(%esp)
80105654:	e8 a1 bb ff ff       	call   801011fa <filewrite>
}
80105659:	c9                   	leave  
8010565a:	c3                   	ret    

8010565b <sys_close>:

int
sys_close(void)
{
8010565b:	55                   	push   %ebp
8010565c:	89 e5                	mov    %esp,%ebp
8010565e:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105661:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105664:	89 44 24 08          	mov    %eax,0x8(%esp)
80105668:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010566b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010566f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105676:	e8 cf fd ff ff       	call   8010544a <argfd>
8010567b:	85 c0                	test   %eax,%eax
8010567d:	79 07                	jns    80105686 <sys_close+0x2b>
    return -1;
8010567f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105684:	eb 23                	jmp    801056a9 <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
80105686:	e8 c7 ea ff ff       	call   80104152 <myproc>
8010568b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010568e:	83 c2 08             	add    $0x8,%edx
80105691:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80105698:	00 
  fileclose(f);
80105699:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010569c:	89 04 24             	mov    %eax,(%esp)
8010569f:	e8 75 b9 ff ff       	call   80101019 <fileclose>
  return 0;
801056a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056a9:	c9                   	leave  
801056aa:	c3                   	ret    

801056ab <sys_fstat>:

int
sys_fstat(void)
{
801056ab:	55                   	push   %ebp
801056ac:	89 e5                	mov    %esp,%ebp
801056ae:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801056b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801056b4:	89 44 24 08          	mov    %eax,0x8(%esp)
801056b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801056bf:	00 
801056c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801056c7:	e8 7e fd ff ff       	call   8010544a <argfd>
801056cc:	85 c0                	test   %eax,%eax
801056ce:	78 1f                	js     801056ef <sys_fstat+0x44>
801056d0:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801056d7:	00 
801056d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056db:	89 44 24 04          	mov    %eax,0x4(%esp)
801056df:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801056e6:	e8 47 fc ff ff       	call   80105332 <argptr>
801056eb:	85 c0                	test   %eax,%eax
801056ed:	79 07                	jns    801056f6 <sys_fstat+0x4b>
    return -1;
801056ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056f4:	eb 12                	jmp    80105708 <sys_fstat+0x5d>
  return filestat(f, st);
801056f6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801056f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056fc:	89 54 24 04          	mov    %edx,0x4(%esp)
80105700:	89 04 24             	mov    %eax,(%esp)
80105703:	e8 e7 b9 ff ff       	call   801010ef <filestat>
}
80105708:	c9                   	leave  
80105709:	c3                   	ret    

8010570a <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010570a:	55                   	push   %ebp
8010570b:	89 e5                	mov    %esp,%ebp
8010570d:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105710:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105713:	89 44 24 04          	mov    %eax,0x4(%esp)
80105717:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010571e:	e8 68 fc ff ff       	call   8010538b <argstr>
80105723:	85 c0                	test   %eax,%eax
80105725:	78 17                	js     8010573e <sys_link+0x34>
80105727:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010572a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010572e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105735:	e8 51 fc ff ff       	call   8010538b <argstr>
8010573a:	85 c0                	test   %eax,%eax
8010573c:	79 0a                	jns    80105748 <sys_link+0x3e>
    return -1;
8010573e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105743:	e9 42 01 00 00       	jmp    8010588a <sys_link+0x180>

  begin_op();
80105748:	e8 26 dd ff ff       	call   80103473 <begin_op>
  if((ip = namei(old)) == 0){
8010574d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105750:	89 04 24             	mov    %eax,(%esp)
80105753:	e8 2b cd ff ff       	call   80102483 <namei>
80105758:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010575b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010575f:	75 0f                	jne    80105770 <sys_link+0x66>
    end_op();
80105761:	e8 91 dd ff ff       	call   801034f7 <end_op>
    return -1;
80105766:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010576b:	e9 1a 01 00 00       	jmp    8010588a <sys_link+0x180>
  }

  ilock(ip);
80105770:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105773:	89 04 24             	mov    %eax,(%esp)
80105776:	e8 ce c1 ff ff       	call   80101949 <ilock>
  if(ip->type == T_DIR){
8010577b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010577e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105782:	66 83 f8 01          	cmp    $0x1,%ax
80105786:	75 1a                	jne    801057a2 <sys_link+0x98>
    iunlockput(ip);
80105788:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010578b:	89 04 24             	mov    %eax,(%esp)
8010578e:	e8 b8 c3 ff ff       	call   80101b4b <iunlockput>
    end_op();
80105793:	e8 5f dd ff ff       	call   801034f7 <end_op>
    return -1;
80105798:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010579d:	e9 e8 00 00 00       	jmp    8010588a <sys_link+0x180>
  }

  ip->nlink++;
801057a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057a5:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801057a9:	8d 50 01             	lea    0x1(%eax),%edx
801057ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057af:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801057b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057b6:	89 04 24             	mov    %eax,(%esp)
801057b9:	e8 c6 bf ff ff       	call   80101784 <iupdate>
  iunlock(ip);
801057be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057c1:	89 04 24             	mov    %eax,(%esp)
801057c4:	e8 8d c2 ff ff       	call   80101a56 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
801057c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801057cc:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801057cf:	89 54 24 04          	mov    %edx,0x4(%esp)
801057d3:	89 04 24             	mov    %eax,(%esp)
801057d6:	e8 ca cc ff ff       	call   801024a5 <nameiparent>
801057db:	89 45 f0             	mov    %eax,-0x10(%ebp)
801057de:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801057e2:	75 02                	jne    801057e6 <sys_link+0xdc>
    goto bad;
801057e4:	eb 68                	jmp    8010584e <sys_link+0x144>
  ilock(dp);
801057e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057e9:	89 04 24             	mov    %eax,(%esp)
801057ec:	e8 58 c1 ff ff       	call   80101949 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801057f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f4:	8b 10                	mov    (%eax),%edx
801057f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057f9:	8b 00                	mov    (%eax),%eax
801057fb:	39 c2                	cmp    %eax,%edx
801057fd:	75 20                	jne    8010581f <sys_link+0x115>
801057ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105802:	8b 40 04             	mov    0x4(%eax),%eax
80105805:	89 44 24 08          	mov    %eax,0x8(%esp)
80105809:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010580c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105810:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105813:	89 04 24             	mov    %eax,(%esp)
80105816:	e8 a9 c9 ff ff       	call   801021c4 <dirlink>
8010581b:	85 c0                	test   %eax,%eax
8010581d:	79 0d                	jns    8010582c <sys_link+0x122>
    iunlockput(dp);
8010581f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105822:	89 04 24             	mov    %eax,(%esp)
80105825:	e8 21 c3 ff ff       	call   80101b4b <iunlockput>
    goto bad;
8010582a:	eb 22                	jmp    8010584e <sys_link+0x144>
  }
  iunlockput(dp);
8010582c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010582f:	89 04 24             	mov    %eax,(%esp)
80105832:	e8 14 c3 ff ff       	call   80101b4b <iunlockput>
  iput(ip);
80105837:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010583a:	89 04 24             	mov    %eax,(%esp)
8010583d:	e8 58 c2 ff ff       	call   80101a9a <iput>

  end_op();
80105842:	e8 b0 dc ff ff       	call   801034f7 <end_op>

  return 0;
80105847:	b8 00 00 00 00       	mov    $0x0,%eax
8010584c:	eb 3c                	jmp    8010588a <sys_link+0x180>

bad:
  ilock(ip);
8010584e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105851:	89 04 24             	mov    %eax,(%esp)
80105854:	e8 f0 c0 ff ff       	call   80101949 <ilock>
  ip->nlink--;
80105859:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010585c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105860:	8d 50 ff             	lea    -0x1(%eax),%edx
80105863:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105866:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010586a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010586d:	89 04 24             	mov    %eax,(%esp)
80105870:	e8 0f bf ff ff       	call   80101784 <iupdate>
  iunlockput(ip);
80105875:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105878:	89 04 24             	mov    %eax,(%esp)
8010587b:	e8 cb c2 ff ff       	call   80101b4b <iunlockput>
  end_op();
80105880:	e8 72 dc ff ff       	call   801034f7 <end_op>
  return -1;
80105885:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010588a:	c9                   	leave  
8010588b:	c3                   	ret    

8010588c <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010588c:	55                   	push   %ebp
8010588d:	89 e5                	mov    %esp,%ebp
8010588f:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105892:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105899:	eb 4b                	jmp    801058e6 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010589b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010589e:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801058a5:	00 
801058a6:	89 44 24 08          	mov    %eax,0x8(%esp)
801058aa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801058ad:	89 44 24 04          	mov    %eax,0x4(%esp)
801058b1:	8b 45 08             	mov    0x8(%ebp),%eax
801058b4:	89 04 24             	mov    %eax,(%esp)
801058b7:	e8 2a c5 ff ff       	call   80101de6 <readi>
801058bc:	83 f8 10             	cmp    $0x10,%eax
801058bf:	74 0c                	je     801058cd <isdirempty+0x41>
      panic("isdirempty: readi");
801058c1:	c7 04 24 ac 89 10 80 	movl   $0x801089ac,(%esp)
801058c8:	e8 95 ac ff ff       	call   80100562 <panic>
    if(de.inum != 0)
801058cd:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801058d1:	66 85 c0             	test   %ax,%ax
801058d4:	74 07                	je     801058dd <isdirempty+0x51>
      return 0;
801058d6:	b8 00 00 00 00       	mov    $0x0,%eax
801058db:	eb 1b                	jmp    801058f8 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801058dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058e0:	83 c0 10             	add    $0x10,%eax
801058e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058e9:	8b 45 08             	mov    0x8(%ebp),%eax
801058ec:	8b 40 58             	mov    0x58(%eax),%eax
801058ef:	39 c2                	cmp    %eax,%edx
801058f1:	72 a8                	jb     8010589b <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
801058f3:	b8 01 00 00 00       	mov    $0x1,%eax
}
801058f8:	c9                   	leave  
801058f9:	c3                   	ret    

801058fa <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801058fa:	55                   	push   %ebp
801058fb:	89 e5                	mov    %esp,%ebp
801058fd:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105900:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105903:	89 44 24 04          	mov    %eax,0x4(%esp)
80105907:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010590e:	e8 78 fa ff ff       	call   8010538b <argstr>
80105913:	85 c0                	test   %eax,%eax
80105915:	79 0a                	jns    80105921 <sys_unlink+0x27>
    return -1;
80105917:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010591c:	e9 af 01 00 00       	jmp    80105ad0 <sys_unlink+0x1d6>

  begin_op();
80105921:	e8 4d db ff ff       	call   80103473 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105926:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105929:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010592c:	89 54 24 04          	mov    %edx,0x4(%esp)
80105930:	89 04 24             	mov    %eax,(%esp)
80105933:	e8 6d cb ff ff       	call   801024a5 <nameiparent>
80105938:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010593b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010593f:	75 0f                	jne    80105950 <sys_unlink+0x56>
    end_op();
80105941:	e8 b1 db ff ff       	call   801034f7 <end_op>
    return -1;
80105946:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010594b:	e9 80 01 00 00       	jmp    80105ad0 <sys_unlink+0x1d6>
  }

  ilock(dp);
80105950:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105953:	89 04 24             	mov    %eax,(%esp)
80105956:	e8 ee bf ff ff       	call   80101949 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010595b:	c7 44 24 04 be 89 10 	movl   $0x801089be,0x4(%esp)
80105962:	80 
80105963:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105966:	89 04 24             	mov    %eax,(%esp)
80105969:	e8 6b c7 ff ff       	call   801020d9 <namecmp>
8010596e:	85 c0                	test   %eax,%eax
80105970:	0f 84 45 01 00 00    	je     80105abb <sys_unlink+0x1c1>
80105976:	c7 44 24 04 c0 89 10 	movl   $0x801089c0,0x4(%esp)
8010597d:	80 
8010597e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105981:	89 04 24             	mov    %eax,(%esp)
80105984:	e8 50 c7 ff ff       	call   801020d9 <namecmp>
80105989:	85 c0                	test   %eax,%eax
8010598b:	0f 84 2a 01 00 00    	je     80105abb <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105991:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105994:	89 44 24 08          	mov    %eax,0x8(%esp)
80105998:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010599b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010599f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059a2:	89 04 24             	mov    %eax,(%esp)
801059a5:	e8 51 c7 ff ff       	call   801020fb <dirlookup>
801059aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059ad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059b1:	75 05                	jne    801059b8 <sys_unlink+0xbe>
    goto bad;
801059b3:	e9 03 01 00 00       	jmp    80105abb <sys_unlink+0x1c1>
  ilock(ip);
801059b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059bb:	89 04 24             	mov    %eax,(%esp)
801059be:	e8 86 bf ff ff       	call   80101949 <ilock>

  if(ip->nlink < 1)
801059c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059c6:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801059ca:	66 85 c0             	test   %ax,%ax
801059cd:	7f 0c                	jg     801059db <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
801059cf:	c7 04 24 c3 89 10 80 	movl   $0x801089c3,(%esp)
801059d6:	e8 87 ab ff ff       	call   80100562 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801059db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059de:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801059e2:	66 83 f8 01          	cmp    $0x1,%ax
801059e6:	75 1f                	jne    80105a07 <sys_unlink+0x10d>
801059e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059eb:	89 04 24             	mov    %eax,(%esp)
801059ee:	e8 99 fe ff ff       	call   8010588c <isdirempty>
801059f3:	85 c0                	test   %eax,%eax
801059f5:	75 10                	jne    80105a07 <sys_unlink+0x10d>
    iunlockput(ip);
801059f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059fa:	89 04 24             	mov    %eax,(%esp)
801059fd:	e8 49 c1 ff ff       	call   80101b4b <iunlockput>
    goto bad;
80105a02:	e9 b4 00 00 00       	jmp    80105abb <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80105a07:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105a0e:	00 
80105a0f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a16:	00 
80105a17:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105a1a:	89 04 24             	mov    %eax,(%esp)
80105a1d:	e8 b5 f5 ff ff       	call   80104fd7 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105a22:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105a25:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105a2c:	00 
80105a2d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a31:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105a34:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a3b:	89 04 24             	mov    %eax,(%esp)
80105a3e:	e8 07 c5 ff ff       	call   80101f4a <writei>
80105a43:	83 f8 10             	cmp    $0x10,%eax
80105a46:	74 0c                	je     80105a54 <sys_unlink+0x15a>
    panic("unlink: writei");
80105a48:	c7 04 24 d5 89 10 80 	movl   $0x801089d5,(%esp)
80105a4f:	e8 0e ab ff ff       	call   80100562 <panic>
  if(ip->type == T_DIR){
80105a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a57:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a5b:	66 83 f8 01          	cmp    $0x1,%ax
80105a5f:	75 1c                	jne    80105a7d <sys_unlink+0x183>
    dp->nlink--;
80105a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a64:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a68:	8d 50 ff             	lea    -0x1(%eax),%edx
80105a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a6e:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a75:	89 04 24             	mov    %eax,(%esp)
80105a78:	e8 07 bd ff ff       	call   80101784 <iupdate>
  }
  iunlockput(dp);
80105a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a80:	89 04 24             	mov    %eax,(%esp)
80105a83:	e8 c3 c0 ff ff       	call   80101b4b <iunlockput>

  ip->nlink--;
80105a88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a8b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a8f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105a92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a95:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105a99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a9c:	89 04 24             	mov    %eax,(%esp)
80105a9f:	e8 e0 bc ff ff       	call   80101784 <iupdate>
  iunlockput(ip);
80105aa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aa7:	89 04 24             	mov    %eax,(%esp)
80105aaa:	e8 9c c0 ff ff       	call   80101b4b <iunlockput>

  end_op();
80105aaf:	e8 43 da ff ff       	call   801034f7 <end_op>

  return 0;
80105ab4:	b8 00 00 00 00       	mov    $0x0,%eax
80105ab9:	eb 15                	jmp    80105ad0 <sys_unlink+0x1d6>

bad:
  iunlockput(dp);
80105abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105abe:	89 04 24             	mov    %eax,(%esp)
80105ac1:	e8 85 c0 ff ff       	call   80101b4b <iunlockput>
  end_op();
80105ac6:	e8 2c da ff ff       	call   801034f7 <end_op>
  return -1;
80105acb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ad0:	c9                   	leave  
80105ad1:	c3                   	ret    

80105ad2 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105ad2:	55                   	push   %ebp
80105ad3:	89 e5                	mov    %esp,%ebp
80105ad5:	83 ec 48             	sub    $0x48,%esp
80105ad8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105adb:	8b 55 10             	mov    0x10(%ebp),%edx
80105ade:	8b 45 14             	mov    0x14(%ebp),%eax
80105ae1:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105ae5:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105ae9:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105aed:	8d 45 de             	lea    -0x22(%ebp),%eax
80105af0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105af4:	8b 45 08             	mov    0x8(%ebp),%eax
80105af7:	89 04 24             	mov    %eax,(%esp)
80105afa:	e8 a6 c9 ff ff       	call   801024a5 <nameiparent>
80105aff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b06:	75 0a                	jne    80105b12 <create+0x40>
    return 0;
80105b08:	b8 00 00 00 00       	mov    $0x0,%eax
80105b0d:	e9 7e 01 00 00       	jmp    80105c90 <create+0x1be>
  ilock(dp);
80105b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b15:	89 04 24             	mov    %eax,(%esp)
80105b18:	e8 2c be ff ff       	call   80101949 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105b1d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b20:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b24:	8d 45 de             	lea    -0x22(%ebp),%eax
80105b27:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b2e:	89 04 24             	mov    %eax,(%esp)
80105b31:	e8 c5 c5 ff ff       	call   801020fb <dirlookup>
80105b36:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b39:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b3d:	74 47                	je     80105b86 <create+0xb4>
    iunlockput(dp);
80105b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b42:	89 04 24             	mov    %eax,(%esp)
80105b45:	e8 01 c0 ff ff       	call   80101b4b <iunlockput>
    ilock(ip);
80105b4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b4d:	89 04 24             	mov    %eax,(%esp)
80105b50:	e8 f4 bd ff ff       	call   80101949 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105b55:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105b5a:	75 15                	jne    80105b71 <create+0x9f>
80105b5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b5f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105b63:	66 83 f8 02          	cmp    $0x2,%ax
80105b67:	75 08                	jne    80105b71 <create+0x9f>
      return ip;
80105b69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b6c:	e9 1f 01 00 00       	jmp    80105c90 <create+0x1be>
    iunlockput(ip);
80105b71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b74:	89 04 24             	mov    %eax,(%esp)
80105b77:	e8 cf bf ff ff       	call   80101b4b <iunlockput>
    return 0;
80105b7c:	b8 00 00 00 00       	mov    $0x0,%eax
80105b81:	e9 0a 01 00 00       	jmp    80105c90 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105b86:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b8d:	8b 00                	mov    (%eax),%eax
80105b8f:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b93:	89 04 24             	mov    %eax,(%esp)
80105b96:	e8 14 bb ff ff       	call   801016af <ialloc>
80105b9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b9e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ba2:	75 0c                	jne    80105bb0 <create+0xde>
    panic("create: ialloc");
80105ba4:	c7 04 24 e4 89 10 80 	movl   $0x801089e4,(%esp)
80105bab:	e8 b2 a9 ff ff       	call   80100562 <panic>

  ilock(ip);
80105bb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bb3:	89 04 24             	mov    %eax,(%esp)
80105bb6:	e8 8e bd ff ff       	call   80101949 <ilock>
  ip->major = major;
80105bbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bbe:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105bc2:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105bc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bc9:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105bcd:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bd4:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105bda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bdd:	89 04 24             	mov    %eax,(%esp)
80105be0:	e8 9f bb ff ff       	call   80101784 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105be5:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105bea:	75 6a                	jne    80105c56 <create+0x184>
    dp->nlink++;  // for ".."
80105bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bef:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105bf3:	8d 50 01             	lea    0x1(%eax),%edx
80105bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf9:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c00:	89 04 24             	mov    %eax,(%esp)
80105c03:	e8 7c bb ff ff       	call   80101784 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105c08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c0b:	8b 40 04             	mov    0x4(%eax),%eax
80105c0e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c12:	c7 44 24 04 be 89 10 	movl   $0x801089be,0x4(%esp)
80105c19:	80 
80105c1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c1d:	89 04 24             	mov    %eax,(%esp)
80105c20:	e8 9f c5 ff ff       	call   801021c4 <dirlink>
80105c25:	85 c0                	test   %eax,%eax
80105c27:	78 21                	js     80105c4a <create+0x178>
80105c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c2c:	8b 40 04             	mov    0x4(%eax),%eax
80105c2f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c33:	c7 44 24 04 c0 89 10 	movl   $0x801089c0,0x4(%esp)
80105c3a:	80 
80105c3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c3e:	89 04 24             	mov    %eax,(%esp)
80105c41:	e8 7e c5 ff ff       	call   801021c4 <dirlink>
80105c46:	85 c0                	test   %eax,%eax
80105c48:	79 0c                	jns    80105c56 <create+0x184>
      panic("create dots");
80105c4a:	c7 04 24 f3 89 10 80 	movl   $0x801089f3,(%esp)
80105c51:	e8 0c a9 ff ff       	call   80100562 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105c56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c59:	8b 40 04             	mov    0x4(%eax),%eax
80105c5c:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c60:	8d 45 de             	lea    -0x22(%ebp),%eax
80105c63:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c6a:	89 04 24             	mov    %eax,(%esp)
80105c6d:	e8 52 c5 ff ff       	call   801021c4 <dirlink>
80105c72:	85 c0                	test   %eax,%eax
80105c74:	79 0c                	jns    80105c82 <create+0x1b0>
    panic("create: dirlink");
80105c76:	c7 04 24 ff 89 10 80 	movl   $0x801089ff,(%esp)
80105c7d:	e8 e0 a8 ff ff       	call   80100562 <panic>

  iunlockput(dp);
80105c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c85:	89 04 24             	mov    %eax,(%esp)
80105c88:	e8 be be ff ff       	call   80101b4b <iunlockput>

  return ip;
80105c8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105c90:	c9                   	leave  
80105c91:	c3                   	ret    

80105c92 <sys_open>:

int
sys_open(void)
{
80105c92:	55                   	push   %ebp
80105c93:	89 e5                	mov    %esp,%ebp
80105c95:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105c98:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105c9b:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ca6:	e8 e0 f6 ff ff       	call   8010538b <argstr>
80105cab:	85 c0                	test   %eax,%eax
80105cad:	78 17                	js     80105cc6 <sys_open+0x34>
80105caf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105cb2:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cb6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105cbd:	e8 43 f6 ff ff       	call   80105305 <argint>
80105cc2:	85 c0                	test   %eax,%eax
80105cc4:	79 0a                	jns    80105cd0 <sys_open+0x3e>
    return -1;
80105cc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ccb:	e9 5c 01 00 00       	jmp    80105e2c <sys_open+0x19a>

  begin_op();
80105cd0:	e8 9e d7 ff ff       	call   80103473 <begin_op>

  if(omode & O_CREATE){
80105cd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105cd8:	25 00 02 00 00       	and    $0x200,%eax
80105cdd:	85 c0                	test   %eax,%eax
80105cdf:	74 3b                	je     80105d1c <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80105ce1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ce4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105ceb:	00 
80105cec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105cf3:	00 
80105cf4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105cfb:	00 
80105cfc:	89 04 24             	mov    %eax,(%esp)
80105cff:	e8 ce fd ff ff       	call   80105ad2 <create>
80105d04:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105d07:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d0b:	75 6b                	jne    80105d78 <sys_open+0xe6>
      end_op();
80105d0d:	e8 e5 d7 ff ff       	call   801034f7 <end_op>
      return -1;
80105d12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d17:	e9 10 01 00 00       	jmp    80105e2c <sys_open+0x19a>
    }
  } else {
    if((ip = namei(path)) == 0){
80105d1c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d1f:	89 04 24             	mov    %eax,(%esp)
80105d22:	e8 5c c7 ff ff       	call   80102483 <namei>
80105d27:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d2a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d2e:	75 0f                	jne    80105d3f <sys_open+0xad>
      end_op();
80105d30:	e8 c2 d7 ff ff       	call   801034f7 <end_op>
      return -1;
80105d35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d3a:	e9 ed 00 00 00       	jmp    80105e2c <sys_open+0x19a>
    }
    ilock(ip);
80105d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d42:	89 04 24             	mov    %eax,(%esp)
80105d45:	e8 ff bb ff ff       	call   80101949 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d4d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d51:	66 83 f8 01          	cmp    $0x1,%ax
80105d55:	75 21                	jne    80105d78 <sys_open+0xe6>
80105d57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d5a:	85 c0                	test   %eax,%eax
80105d5c:	74 1a                	je     80105d78 <sys_open+0xe6>
      iunlockput(ip);
80105d5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d61:	89 04 24             	mov    %eax,(%esp)
80105d64:	e8 e2 bd ff ff       	call   80101b4b <iunlockput>
      end_op();
80105d69:	e8 89 d7 ff ff       	call   801034f7 <end_op>
      return -1;
80105d6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d73:	e9 b4 00 00 00       	jmp    80105e2c <sys_open+0x19a>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105d78:	e8 f4 b1 ff ff       	call   80100f71 <filealloc>
80105d7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d80:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d84:	74 14                	je     80105d9a <sys_open+0x108>
80105d86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d89:	89 04 24             	mov    %eax,(%esp)
80105d8c:	e8 2d f7 ff ff       	call   801054be <fdalloc>
80105d91:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105d94:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105d98:	79 28                	jns    80105dc2 <sys_open+0x130>
    if(f)
80105d9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d9e:	74 0b                	je     80105dab <sys_open+0x119>
      fileclose(f);
80105da0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105da3:	89 04 24             	mov    %eax,(%esp)
80105da6:	e8 6e b2 ff ff       	call   80101019 <fileclose>
    iunlockput(ip);
80105dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dae:	89 04 24             	mov    %eax,(%esp)
80105db1:	e8 95 bd ff ff       	call   80101b4b <iunlockput>
    end_op();
80105db6:	e8 3c d7 ff ff       	call   801034f7 <end_op>
    return -1;
80105dbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dc0:	eb 6a                	jmp    80105e2c <sys_open+0x19a>
  }
  iunlock(ip);
80105dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dc5:	89 04 24             	mov    %eax,(%esp)
80105dc8:	e8 89 bc ff ff       	call   80101a56 <iunlock>
  end_op();
80105dcd:	e8 25 d7 ff ff       	call   801034f7 <end_op>

  f->type = FD_INODE;
80105dd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dd5:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105ddb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dde:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105de1:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105de4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105de7:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105dee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105df1:	83 e0 01             	and    $0x1,%eax
80105df4:	85 c0                	test   %eax,%eax
80105df6:	0f 94 c0             	sete   %al
80105df9:	89 c2                	mov    %eax,%edx
80105dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dfe:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105e01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e04:	83 e0 01             	and    $0x1,%eax
80105e07:	85 c0                	test   %eax,%eax
80105e09:	75 0a                	jne    80105e15 <sys_open+0x183>
80105e0b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e0e:	83 e0 02             	and    $0x2,%eax
80105e11:	85 c0                	test   %eax,%eax
80105e13:	74 07                	je     80105e1c <sys_open+0x18a>
80105e15:	b8 01 00 00 00       	mov    $0x1,%eax
80105e1a:	eb 05                	jmp    80105e21 <sys_open+0x18f>
80105e1c:	b8 00 00 00 00       	mov    $0x0,%eax
80105e21:	89 c2                	mov    %eax,%edx
80105e23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e26:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105e29:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105e2c:	c9                   	leave  
80105e2d:	c3                   	ret    

80105e2e <sys_mkdir>:

int
sys_mkdir(void)
{
80105e2e:	55                   	push   %ebp
80105e2f:	89 e5                	mov    %esp,%ebp
80105e31:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105e34:	e8 3a d6 ff ff       	call   80103473 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105e39:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e3c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e40:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e47:	e8 3f f5 ff ff       	call   8010538b <argstr>
80105e4c:	85 c0                	test   %eax,%eax
80105e4e:	78 2c                	js     80105e7c <sys_mkdir+0x4e>
80105e50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e53:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105e5a:	00 
80105e5b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105e62:	00 
80105e63:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105e6a:	00 
80105e6b:	89 04 24             	mov    %eax,(%esp)
80105e6e:	e8 5f fc ff ff       	call   80105ad2 <create>
80105e73:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e76:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e7a:	75 0c                	jne    80105e88 <sys_mkdir+0x5a>
    end_op();
80105e7c:	e8 76 d6 ff ff       	call   801034f7 <end_op>
    return -1;
80105e81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e86:	eb 15                	jmp    80105e9d <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80105e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e8b:	89 04 24             	mov    %eax,(%esp)
80105e8e:	e8 b8 bc ff ff       	call   80101b4b <iunlockput>
  end_op();
80105e93:	e8 5f d6 ff ff       	call   801034f7 <end_op>
  return 0;
80105e98:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e9d:	c9                   	leave  
80105e9e:	c3                   	ret    

80105e9f <sys_mknod>:

int
sys_mknod(void)
{
80105e9f:	55                   	push   %ebp
80105ea0:	89 e5                	mov    %esp,%ebp
80105ea2:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105ea5:	e8 c9 d5 ff ff       	call   80103473 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105eaa:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ead:	89 44 24 04          	mov    %eax,0x4(%esp)
80105eb1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105eb8:	e8 ce f4 ff ff       	call   8010538b <argstr>
80105ebd:	85 c0                	test   %eax,%eax
80105ebf:	78 5e                	js     80105f1f <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80105ec1:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ec4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ec8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105ecf:	e8 31 f4 ff ff       	call   80105305 <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
80105ed4:	85 c0                	test   %eax,%eax
80105ed6:	78 47                	js     80105f1f <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105ed8:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105edb:	89 44 24 04          	mov    %eax,0x4(%esp)
80105edf:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105ee6:	e8 1a f4 ff ff       	call   80105305 <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80105eeb:	85 c0                	test   %eax,%eax
80105eed:	78 30                	js     80105f1f <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80105eef:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ef2:	0f bf c8             	movswl %ax,%ecx
80105ef5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105ef8:	0f bf d0             	movswl %ax,%edx
80105efb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105efe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80105f02:	89 54 24 08          	mov    %edx,0x8(%esp)
80105f06:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80105f0d:	00 
80105f0e:	89 04 24             	mov    %eax,(%esp)
80105f11:	e8 bc fb ff ff       	call   80105ad2 <create>
80105f16:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f19:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f1d:	75 0c                	jne    80105f2b <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80105f1f:	e8 d3 d5 ff ff       	call   801034f7 <end_op>
    return -1;
80105f24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f29:	eb 15                	jmp    80105f40 <sys_mknod+0xa1>
  }
  iunlockput(ip);
80105f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f2e:	89 04 24             	mov    %eax,(%esp)
80105f31:	e8 15 bc ff ff       	call   80101b4b <iunlockput>
  end_op();
80105f36:	e8 bc d5 ff ff       	call   801034f7 <end_op>
  return 0;
80105f3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f40:	c9                   	leave  
80105f41:	c3                   	ret    

80105f42 <sys_chdir>:

int
sys_chdir(void)
{
80105f42:	55                   	push   %ebp
80105f43:	89 e5                	mov    %esp,%ebp
80105f45:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105f48:	e8 05 e2 ff ff       	call   80104152 <myproc>
80105f4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105f50:	e8 1e d5 ff ff       	call   80103473 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105f55:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f58:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f5c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f63:	e8 23 f4 ff ff       	call   8010538b <argstr>
80105f68:	85 c0                	test   %eax,%eax
80105f6a:	78 14                	js     80105f80 <sys_chdir+0x3e>
80105f6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f6f:	89 04 24             	mov    %eax,(%esp)
80105f72:	e8 0c c5 ff ff       	call   80102483 <namei>
80105f77:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f7a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f7e:	75 0c                	jne    80105f8c <sys_chdir+0x4a>
    end_op();
80105f80:	e8 72 d5 ff ff       	call   801034f7 <end_op>
    return -1;
80105f85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f8a:	eb 5b                	jmp    80105fe7 <sys_chdir+0xa5>
  }
  ilock(ip);
80105f8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f8f:	89 04 24             	mov    %eax,(%esp)
80105f92:	e8 b2 b9 ff ff       	call   80101949 <ilock>
  if(ip->type != T_DIR){
80105f97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f9a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105f9e:	66 83 f8 01          	cmp    $0x1,%ax
80105fa2:	74 17                	je     80105fbb <sys_chdir+0x79>
    iunlockput(ip);
80105fa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fa7:	89 04 24             	mov    %eax,(%esp)
80105faa:	e8 9c bb ff ff       	call   80101b4b <iunlockput>
    end_op();
80105faf:	e8 43 d5 ff ff       	call   801034f7 <end_op>
    return -1;
80105fb4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fb9:	eb 2c                	jmp    80105fe7 <sys_chdir+0xa5>
  }
  iunlock(ip);
80105fbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fbe:	89 04 24             	mov    %eax,(%esp)
80105fc1:	e8 90 ba ff ff       	call   80101a56 <iunlock>
  iput(curproc->cwd);
80105fc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc9:	8b 40 6c             	mov    0x6c(%eax),%eax
80105fcc:	89 04 24             	mov    %eax,(%esp)
80105fcf:	e8 c6 ba ff ff       	call   80101a9a <iput>
  end_op();
80105fd4:	e8 1e d5 ff ff       	call   801034f7 <end_op>
  curproc->cwd = ip;
80105fd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fdc:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105fdf:	89 50 6c             	mov    %edx,0x6c(%eax)
  return 0;
80105fe2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fe7:	c9                   	leave  
80105fe8:	c3                   	ret    

80105fe9 <sys_exec>:

int
sys_exec(void)
{
80105fe9:	55                   	push   %ebp
80105fea:	89 e5                	mov    %esp,%ebp
80105fec:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105ff2:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ff5:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ff9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106000:	e8 86 f3 ff ff       	call   8010538b <argstr>
80106005:	85 c0                	test   %eax,%eax
80106007:	78 1a                	js     80106023 <sys_exec+0x3a>
80106009:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010600f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106013:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010601a:	e8 e6 f2 ff ff       	call   80105305 <argint>
8010601f:	85 c0                	test   %eax,%eax
80106021:	79 0a                	jns    8010602d <sys_exec+0x44>
    return -1;
80106023:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106028:	e9 c8 00 00 00       	jmp    801060f5 <sys_exec+0x10c>
  }
  memset(argv, 0, sizeof(argv));
8010602d:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106034:	00 
80106035:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010603c:	00 
8010603d:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106043:	89 04 24             	mov    %eax,(%esp)
80106046:	e8 8c ef ff ff       	call   80104fd7 <memset>
  for(i=0;; i++){
8010604b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106052:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106055:	83 f8 1f             	cmp    $0x1f,%eax
80106058:	76 0a                	jbe    80106064 <sys_exec+0x7b>
      return -1;
8010605a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010605f:	e9 91 00 00 00       	jmp    801060f5 <sys_exec+0x10c>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106064:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106067:	c1 e0 02             	shl    $0x2,%eax
8010606a:	89 c2                	mov    %eax,%edx
8010606c:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106072:	01 c2                	add    %eax,%edx
80106074:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010607a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010607e:	89 14 24             	mov    %edx,(%esp)
80106081:	e8 f7 f1 ff ff       	call   8010527d <fetchint>
80106086:	85 c0                	test   %eax,%eax
80106088:	79 07                	jns    80106091 <sys_exec+0xa8>
      return -1;
8010608a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010608f:	eb 64                	jmp    801060f5 <sys_exec+0x10c>
    if(uarg == 0){
80106091:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106097:	85 c0                	test   %eax,%eax
80106099:	75 26                	jne    801060c1 <sys_exec+0xd8>
      argv[i] = 0;
8010609b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010609e:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801060a5:	00 00 00 00 
      break;
801060a9:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801060aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ad:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801060b3:	89 54 24 04          	mov    %edx,0x4(%esp)
801060b7:	89 04 24             	mov    %eax,(%esp)
801060ba:	e8 5f aa ff ff       	call   80100b1e <exec>
801060bf:	eb 34                	jmp    801060f5 <sys_exec+0x10c>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801060c1:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801060c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060ca:	c1 e2 02             	shl    $0x2,%edx
801060cd:	01 c2                	add    %eax,%edx
801060cf:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801060d5:	89 54 24 04          	mov    %edx,0x4(%esp)
801060d9:	89 04 24             	mov    %eax,(%esp)
801060dc:	e8 ca f1 ff ff       	call   801052ab <fetchstr>
801060e1:	85 c0                	test   %eax,%eax
801060e3:	79 07                	jns    801060ec <sys_exec+0x103>
      return -1;
801060e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060ea:	eb 09                	jmp    801060f5 <sys_exec+0x10c>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801060ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801060f0:	e9 5d ff ff ff       	jmp    80106052 <sys_exec+0x69>
  return exec(path, argv);
}
801060f5:	c9                   	leave  
801060f6:	c3                   	ret    

801060f7 <sys_pipe>:

int
sys_pipe(void)
{
801060f7:	55                   	push   %ebp
801060f8:	89 e5                	mov    %esp,%ebp
801060fa:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801060fd:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106104:	00 
80106105:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106108:	89 44 24 04          	mov    %eax,0x4(%esp)
8010610c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106113:	e8 1a f2 ff ff       	call   80105332 <argptr>
80106118:	85 c0                	test   %eax,%eax
8010611a:	79 0a                	jns    80106126 <sys_pipe+0x2f>
    return -1;
8010611c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106121:	e9 9a 00 00 00       	jmp    801061c0 <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
80106126:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106129:	89 44 24 04          	mov    %eax,0x4(%esp)
8010612d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106130:	89 04 24             	mov    %eax,(%esp)
80106133:	e8 9e db ff ff       	call   80103cd6 <pipealloc>
80106138:	85 c0                	test   %eax,%eax
8010613a:	79 07                	jns    80106143 <sys_pipe+0x4c>
    return -1;
8010613c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106141:	eb 7d                	jmp    801061c0 <sys_pipe+0xc9>
  fd0 = -1;
80106143:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010614a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010614d:	89 04 24             	mov    %eax,(%esp)
80106150:	e8 69 f3 ff ff       	call   801054be <fdalloc>
80106155:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106158:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010615c:	78 14                	js     80106172 <sys_pipe+0x7b>
8010615e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106161:	89 04 24             	mov    %eax,(%esp)
80106164:	e8 55 f3 ff ff       	call   801054be <fdalloc>
80106169:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010616c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106170:	79 36                	jns    801061a8 <sys_pipe+0xb1>
    if(fd0 >= 0)
80106172:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106176:	78 13                	js     8010618b <sys_pipe+0x94>
      myproc()->ofile[fd0] = 0;
80106178:	e8 d5 df ff ff       	call   80104152 <myproc>
8010617d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106180:	83 c2 08             	add    $0x8,%edx
80106183:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
8010618a:	00 
    fileclose(rf);
8010618b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010618e:	89 04 24             	mov    %eax,(%esp)
80106191:	e8 83 ae ff ff       	call   80101019 <fileclose>
    fileclose(wf);
80106196:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106199:	89 04 24             	mov    %eax,(%esp)
8010619c:	e8 78 ae ff ff       	call   80101019 <fileclose>
    return -1;
801061a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061a6:	eb 18                	jmp    801061c0 <sys_pipe+0xc9>
  }
  fd[0] = fd0;
801061a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061ae:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801061b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061b3:	8d 50 04             	lea    0x4(%eax),%edx
801061b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061b9:	89 02                	mov    %eax,(%edx)
  return 0;
801061bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061c0:	c9                   	leave  
801061c1:	c3                   	ret    

801061c2 <sys_shm_open>:
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int sys_shm_open(void) {
801061c2:	55                   	push   %ebp
801061c3:	89 e5                	mov    %esp,%ebp
801061c5:	83 ec 28             	sub    $0x28,%esp
  int id;
  char **pointer;

  if(argint(0, &id) < 0)
801061c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801061cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801061cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801061d6:	e8 2a f1 ff ff       	call   80105305 <argint>
801061db:	85 c0                	test   %eax,%eax
801061dd:	79 07                	jns    801061e6 <sys_shm_open+0x24>
    return -1;
801061df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061e4:	eb 38                	jmp    8010621e <sys_shm_open+0x5c>

  if(argptr(1, (char **) (&pointer),4)<0)
801061e6:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801061ed:	00 
801061ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801061f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801061fc:	e8 31 f1 ff ff       	call   80105332 <argptr>
80106201:	85 c0                	test   %eax,%eax
80106203:	79 07                	jns    8010620c <sys_shm_open+0x4a>
    return -1;
80106205:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010620a:	eb 12                	jmp    8010621e <sys_shm_open+0x5c>
  return shm_open(id, pointer);
8010620c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010620f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106212:	89 54 24 04          	mov    %edx,0x4(%esp)
80106216:	89 04 24             	mov    %eax,(%esp)
80106219:	e8 f4 21 00 00       	call   80108412 <shm_open>
}
8010621e:	c9                   	leave  
8010621f:	c3                   	ret    

80106220 <sys_shm_close>:

int sys_shm_close(void) {
80106220:	55                   	push   %ebp
80106221:	89 e5                	mov    %esp,%ebp
80106223:	83 ec 28             	sub    $0x28,%esp
  int id;

  if(argint(0, &id) < 0)
80106226:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106229:	89 44 24 04          	mov    %eax,0x4(%esp)
8010622d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106234:	e8 cc f0 ff ff       	call   80105305 <argint>
80106239:	85 c0                	test   %eax,%eax
8010623b:	79 07                	jns    80106244 <sys_shm_close+0x24>
    return -1;
8010623d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106242:	eb 0b                	jmp    8010624f <sys_shm_close+0x2f>

  
  return shm_close(id);
80106244:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106247:	89 04 24             	mov    %eax,(%esp)
8010624a:	e8 be 22 00 00       	call   8010850d <shm_close>
}
8010624f:	c9                   	leave  
80106250:	c3                   	ret    

80106251 <sys_fork>:

int
sys_fork(void)
{
80106251:	55                   	push   %ebp
80106252:	89 e5                	mov    %esp,%ebp
80106254:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106257:	e8 f7 e1 ff ff       	call   80104453 <fork>
}
8010625c:	c9                   	leave  
8010625d:	c3                   	ret    

8010625e <sys_exit>:

int
sys_exit(void)
{
8010625e:	55                   	push   %ebp
8010625f:	89 e5                	mov    %esp,%ebp
80106261:	83 ec 08             	sub    $0x8,%esp
  exit();
80106264:	e8 61 e3 ff ff       	call   801045ca <exit>
  return 0;  // not reached
80106269:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010626e:	c9                   	leave  
8010626f:	c3                   	ret    

80106270 <sys_wait>:

int
sys_wait(void)
{
80106270:	55                   	push   %ebp
80106271:	89 e5                	mov    %esp,%ebp
80106273:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106276:	e8 59 e4 ff ff       	call   801046d4 <wait>
}
8010627b:	c9                   	leave  
8010627c:	c3                   	ret    

8010627d <sys_kill>:

int
sys_kill(void)
{
8010627d:	55                   	push   %ebp
8010627e:	89 e5                	mov    %esp,%ebp
80106280:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106283:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106286:	89 44 24 04          	mov    %eax,0x4(%esp)
8010628a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106291:	e8 6f f0 ff ff       	call   80105305 <argint>
80106296:	85 c0                	test   %eax,%eax
80106298:	79 07                	jns    801062a1 <sys_kill+0x24>
    return -1;
8010629a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010629f:	eb 0b                	jmp    801062ac <sys_kill+0x2f>
  return kill(pid);
801062a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a4:	89 04 24             	mov    %eax,(%esp)
801062a7:	e8 fd e7 ff ff       	call   80104aa9 <kill>
}
801062ac:	c9                   	leave  
801062ad:	c3                   	ret    

801062ae <sys_getpid>:

int
sys_getpid(void)
{
801062ae:	55                   	push   %ebp
801062af:	89 e5                	mov    %esp,%ebp
801062b1:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801062b4:	e8 99 de ff ff       	call   80104152 <myproc>
801062b9:	8b 40 14             	mov    0x14(%eax),%eax
}
801062bc:	c9                   	leave  
801062bd:	c3                   	ret    

801062be <sys_sbrk>:

int
sys_sbrk(void)
{
801062be:	55                   	push   %ebp
801062bf:	89 e5                	mov    %esp,%ebp
801062c1:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801062c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801062cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062d2:	e8 2e f0 ff ff       	call   80105305 <argint>
801062d7:	85 c0                	test   %eax,%eax
801062d9:	79 07                	jns    801062e2 <sys_sbrk+0x24>
    return -1;
801062db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062e0:	eb 24                	jmp    80106306 <sys_sbrk+0x48>
  addr = myproc()->sz;
801062e2:	e8 6b de ff ff       	call   80104152 <myproc>
801062e7:	8b 40 04             	mov    0x4(%eax),%eax
801062ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801062ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062f0:	89 04 24             	mov    %eax,(%esp)
801062f3:	e8 bb e0 ff ff       	call   801043b3 <growproc>
801062f8:	85 c0                	test   %eax,%eax
801062fa:	79 07                	jns    80106303 <sys_sbrk+0x45>
    return -1;
801062fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106301:	eb 03                	jmp    80106306 <sys_sbrk+0x48>
  return addr;
80106303:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106306:	c9                   	leave  
80106307:	c3                   	ret    

80106308 <sys_sleep>:

int
sys_sleep(void)
{
80106308:	55                   	push   %ebp
80106309:	89 e5                	mov    %esp,%ebp
8010630b:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
8010630e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106311:	89 44 24 04          	mov    %eax,0x4(%esp)
80106315:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010631c:	e8 e4 ef ff ff       	call   80105305 <argint>
80106321:	85 c0                	test   %eax,%eax
80106323:	79 07                	jns    8010632c <sys_sleep+0x24>
    return -1;
80106325:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010632a:	eb 6b                	jmp    80106397 <sys_sleep+0x8f>
  acquire(&tickslock);
8010632c:	c7 04 24 e0 5d 11 80 	movl   $0x80115de0,(%esp)
80106333:	e8 3d ea ff ff       	call   80104d75 <acquire>
  ticks0 = ticks;
80106338:	a1 20 66 11 80       	mov    0x80116620,%eax
8010633d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106340:	eb 33                	jmp    80106375 <sys_sleep+0x6d>
    if(myproc()->killed){
80106342:	e8 0b de ff ff       	call   80104152 <myproc>
80106347:	8b 40 28             	mov    0x28(%eax),%eax
8010634a:	85 c0                	test   %eax,%eax
8010634c:	74 13                	je     80106361 <sys_sleep+0x59>
      release(&tickslock);
8010634e:	c7 04 24 e0 5d 11 80 	movl   $0x80115de0,(%esp)
80106355:	e8 83 ea ff ff       	call   80104ddd <release>
      return -1;
8010635a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010635f:	eb 36                	jmp    80106397 <sys_sleep+0x8f>
    }
    sleep(&ticks, &tickslock);
80106361:	c7 44 24 04 e0 5d 11 	movl   $0x80115de0,0x4(%esp)
80106368:	80 
80106369:	c7 04 24 20 66 11 80 	movl   $0x80116620,(%esp)
80106370:	e8 35 e6 ff ff       	call   801049aa <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106375:	a1 20 66 11 80       	mov    0x80116620,%eax
8010637a:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010637d:	89 c2                	mov    %eax,%edx
8010637f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106382:	39 c2                	cmp    %eax,%edx
80106384:	72 bc                	jb     80106342 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106386:	c7 04 24 e0 5d 11 80 	movl   $0x80115de0,(%esp)
8010638d:	e8 4b ea ff ff       	call   80104ddd <release>
  return 0;
80106392:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106397:	c9                   	leave  
80106398:	c3                   	ret    

80106399 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106399:	55                   	push   %ebp
8010639a:	89 e5                	mov    %esp,%ebp
8010639c:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
8010639f:	c7 04 24 e0 5d 11 80 	movl   $0x80115de0,(%esp)
801063a6:	e8 ca e9 ff ff       	call   80104d75 <acquire>
  xticks = ticks;
801063ab:	a1 20 66 11 80       	mov    0x80116620,%eax
801063b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801063b3:	c7 04 24 e0 5d 11 80 	movl   $0x80115de0,(%esp)
801063ba:	e8 1e ea ff ff       	call   80104ddd <release>
  return xticks;
801063bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801063c2:	c9                   	leave  
801063c3:	c3                   	ret    

801063c4 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801063c4:	1e                   	push   %ds
  pushl %es
801063c5:	06                   	push   %es
  pushl %fs
801063c6:	0f a0                	push   %fs
  pushl %gs
801063c8:	0f a8                	push   %gs
  pushal
801063ca:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801063cb:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801063cf:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801063d1:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801063d3:	54                   	push   %esp
  call trap
801063d4:	e8 d8 01 00 00       	call   801065b1 <trap>
  addl $4, %esp
801063d9:	83 c4 04             	add    $0x4,%esp

801063dc <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801063dc:	61                   	popa   
  popl %gs
801063dd:	0f a9                	pop    %gs
  popl %fs
801063df:	0f a1                	pop    %fs
  popl %es
801063e1:	07                   	pop    %es
  popl %ds
801063e2:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801063e3:	83 c4 08             	add    $0x8,%esp
  iret
801063e6:	cf                   	iret   

801063e7 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801063e7:	55                   	push   %ebp
801063e8:	89 e5                	mov    %esp,%ebp
801063ea:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801063ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801063f0:	83 e8 01             	sub    $0x1,%eax
801063f3:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801063f7:	8b 45 08             	mov    0x8(%ebp),%eax
801063fa:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801063fe:	8b 45 08             	mov    0x8(%ebp),%eax
80106401:	c1 e8 10             	shr    $0x10,%eax
80106404:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106408:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010640b:	0f 01 18             	lidtl  (%eax)
}
8010640e:	c9                   	leave  
8010640f:	c3                   	ret    

80106410 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106410:	55                   	push   %ebp
80106411:	89 e5                	mov    %esp,%ebp
80106413:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106416:	0f 20 d0             	mov    %cr2,%eax
80106419:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010641c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010641f:	c9                   	leave  
80106420:	c3                   	ret    

80106421 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106421:	55                   	push   %ebp
80106422:	89 e5                	mov    %esp,%ebp
80106424:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106427:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010642e:	e9 c3 00 00 00       	jmp    801064f6 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106433:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106436:	8b 04 85 80 b0 10 80 	mov    -0x7fef4f80(,%eax,4),%eax
8010643d:	89 c2                	mov    %eax,%edx
8010643f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106442:	66 89 14 c5 20 5e 11 	mov    %dx,-0x7feea1e0(,%eax,8)
80106449:	80 
8010644a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010644d:	66 c7 04 c5 22 5e 11 	movw   $0x8,-0x7feea1de(,%eax,8)
80106454:	80 08 00 
80106457:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010645a:	0f b6 14 c5 24 5e 11 	movzbl -0x7feea1dc(,%eax,8),%edx
80106461:	80 
80106462:	83 e2 e0             	and    $0xffffffe0,%edx
80106465:	88 14 c5 24 5e 11 80 	mov    %dl,-0x7feea1dc(,%eax,8)
8010646c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010646f:	0f b6 14 c5 24 5e 11 	movzbl -0x7feea1dc(,%eax,8),%edx
80106476:	80 
80106477:	83 e2 1f             	and    $0x1f,%edx
8010647a:	88 14 c5 24 5e 11 80 	mov    %dl,-0x7feea1dc(,%eax,8)
80106481:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106484:	0f b6 14 c5 25 5e 11 	movzbl -0x7feea1db(,%eax,8),%edx
8010648b:	80 
8010648c:	83 e2 f0             	and    $0xfffffff0,%edx
8010648f:	83 ca 0e             	or     $0xe,%edx
80106492:	88 14 c5 25 5e 11 80 	mov    %dl,-0x7feea1db(,%eax,8)
80106499:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010649c:	0f b6 14 c5 25 5e 11 	movzbl -0x7feea1db(,%eax,8),%edx
801064a3:	80 
801064a4:	83 e2 ef             	and    $0xffffffef,%edx
801064a7:	88 14 c5 25 5e 11 80 	mov    %dl,-0x7feea1db(,%eax,8)
801064ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064b1:	0f b6 14 c5 25 5e 11 	movzbl -0x7feea1db(,%eax,8),%edx
801064b8:	80 
801064b9:	83 e2 9f             	and    $0xffffff9f,%edx
801064bc:	88 14 c5 25 5e 11 80 	mov    %dl,-0x7feea1db(,%eax,8)
801064c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064c6:	0f b6 14 c5 25 5e 11 	movzbl -0x7feea1db(,%eax,8),%edx
801064cd:	80 
801064ce:	83 ca 80             	or     $0xffffff80,%edx
801064d1:	88 14 c5 25 5e 11 80 	mov    %dl,-0x7feea1db(,%eax,8)
801064d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064db:	8b 04 85 80 b0 10 80 	mov    -0x7fef4f80(,%eax,4),%eax
801064e2:	c1 e8 10             	shr    $0x10,%eax
801064e5:	89 c2                	mov    %eax,%edx
801064e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064ea:	66 89 14 c5 26 5e 11 	mov    %dx,-0x7feea1da(,%eax,8)
801064f1:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801064f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801064f6:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801064fd:	0f 8e 30 ff ff ff    	jle    80106433 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106503:	a1 80 b1 10 80       	mov    0x8010b180,%eax
80106508:	66 a3 20 60 11 80    	mov    %ax,0x80116020
8010650e:	66 c7 05 22 60 11 80 	movw   $0x8,0x80116022
80106515:	08 00 
80106517:	0f b6 05 24 60 11 80 	movzbl 0x80116024,%eax
8010651e:	83 e0 e0             	and    $0xffffffe0,%eax
80106521:	a2 24 60 11 80       	mov    %al,0x80116024
80106526:	0f b6 05 24 60 11 80 	movzbl 0x80116024,%eax
8010652d:	83 e0 1f             	and    $0x1f,%eax
80106530:	a2 24 60 11 80       	mov    %al,0x80116024
80106535:	0f b6 05 25 60 11 80 	movzbl 0x80116025,%eax
8010653c:	83 c8 0f             	or     $0xf,%eax
8010653f:	a2 25 60 11 80       	mov    %al,0x80116025
80106544:	0f b6 05 25 60 11 80 	movzbl 0x80116025,%eax
8010654b:	83 e0 ef             	and    $0xffffffef,%eax
8010654e:	a2 25 60 11 80       	mov    %al,0x80116025
80106553:	0f b6 05 25 60 11 80 	movzbl 0x80116025,%eax
8010655a:	83 c8 60             	or     $0x60,%eax
8010655d:	a2 25 60 11 80       	mov    %al,0x80116025
80106562:	0f b6 05 25 60 11 80 	movzbl 0x80116025,%eax
80106569:	83 c8 80             	or     $0xffffff80,%eax
8010656c:	a2 25 60 11 80       	mov    %al,0x80116025
80106571:	a1 80 b1 10 80       	mov    0x8010b180,%eax
80106576:	c1 e8 10             	shr    $0x10,%eax
80106579:	66 a3 26 60 11 80    	mov    %ax,0x80116026

  initlock(&tickslock, "time");
8010657f:	c7 44 24 04 10 8a 10 	movl   $0x80108a10,0x4(%esp)
80106586:	80 
80106587:	c7 04 24 e0 5d 11 80 	movl   $0x80115de0,(%esp)
8010658e:	e8 c1 e7 ff ff       	call   80104d54 <initlock>
}
80106593:	c9                   	leave  
80106594:	c3                   	ret    

80106595 <idtinit>:

void
idtinit(void)
{
80106595:	55                   	push   %ebp
80106596:	89 e5                	mov    %esp,%ebp
80106598:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
8010659b:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
801065a2:	00 
801065a3:	c7 04 24 20 5e 11 80 	movl   $0x80115e20,(%esp)
801065aa:	e8 38 fe ff ff       	call   801063e7 <lidt>
}
801065af:	c9                   	leave  
801065b0:	c3                   	ret    

801065b1 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801065b1:	55                   	push   %ebp
801065b2:	89 e5                	mov    %esp,%ebp
801065b4:	57                   	push   %edi
801065b5:	56                   	push   %esi
801065b6:	53                   	push   %ebx
801065b7:	83 ec 4c             	sub    $0x4c,%esp
  if(tf->trapno == T_SYSCALL){
801065ba:	8b 45 08             	mov    0x8(%ebp),%eax
801065bd:	8b 40 30             	mov    0x30(%eax),%eax
801065c0:	83 f8 40             	cmp    $0x40,%eax
801065c3:	75 3c                	jne    80106601 <trap+0x50>
    if(myproc()->killed)
801065c5:	e8 88 db ff ff       	call   80104152 <myproc>
801065ca:	8b 40 28             	mov    0x28(%eax),%eax
801065cd:	85 c0                	test   %eax,%eax
801065cf:	74 05                	je     801065d6 <trap+0x25>
      exit();
801065d1:	e8 f4 df ff ff       	call   801045ca <exit>
    myproc()->tf = tf;
801065d6:	e8 77 db ff ff       	call   80104152 <myproc>
801065db:	8b 55 08             	mov    0x8(%ebp),%edx
801065de:	89 50 1c             	mov    %edx,0x1c(%eax)
    syscall();
801065e1:	e8 dc ed ff ff       	call   801053c2 <syscall>
    if(myproc()->killed)
801065e6:	e8 67 db ff ff       	call   80104152 <myproc>
801065eb:	8b 40 28             	mov    0x28(%eax),%eax
801065ee:	85 c0                	test   %eax,%eax
801065f0:	74 0a                	je     801065fc <trap+0x4b>
      exit();
801065f2:	e8 d3 df ff ff       	call   801045ca <exit>
    return;
801065f7:	e9 ae 02 00 00       	jmp    801068aa <trap+0x2f9>
801065fc:	e9 a9 02 00 00       	jmp    801068aa <trap+0x2f9>
  }

  switch(tf->trapno){
80106601:	8b 45 08             	mov    0x8(%ebp),%eax
80106604:	8b 40 30             	mov    0x30(%eax),%eax
80106607:	83 e8 0e             	sub    $0xe,%eax
8010660a:	83 f8 31             	cmp    $0x31,%eax
8010660d:	0f 87 46 01 00 00    	ja     80106759 <trap+0x1a8>
80106613:	8b 04 85 c4 8a 10 80 	mov    -0x7fef753c(,%eax,4),%eax
8010661a:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010661c:	e8 9a da ff ff       	call   801040bb <cpuid>
80106621:	85 c0                	test   %eax,%eax
80106623:	75 31                	jne    80106656 <trap+0xa5>
      acquire(&tickslock);
80106625:	c7 04 24 e0 5d 11 80 	movl   $0x80115de0,(%esp)
8010662c:	e8 44 e7 ff ff       	call   80104d75 <acquire>
      ticks++;
80106631:	a1 20 66 11 80       	mov    0x80116620,%eax
80106636:	83 c0 01             	add    $0x1,%eax
80106639:	a3 20 66 11 80       	mov    %eax,0x80116620
      wakeup(&ticks);
8010663e:	c7 04 24 20 66 11 80 	movl   $0x80116620,(%esp)
80106645:	e8 34 e4 ff ff       	call   80104a7e <wakeup>
      release(&tickslock);
8010664a:	c7 04 24 e0 5d 11 80 	movl   $0x80115de0,(%esp)
80106651:	e8 87 e7 ff ff       	call   80104ddd <release>
    }
    lapiceoi();
80106656:	e8 e2 c8 ff ff       	call   80102f3d <lapiceoi>
    break;
8010665b:	e9 cc 01 00 00       	jmp    8010682c <trap+0x27b>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106660:	e8 4f c1 ff ff       	call   801027b4 <ideintr>
    lapiceoi();
80106665:	e8 d3 c8 ff ff       	call   80102f3d <lapiceoi>
    break;
8010666a:	e9 bd 01 00 00       	jmp    8010682c <trap+0x27b>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010666f:	e8 de c6 ff ff       	call   80102d52 <kbdintr>
    lapiceoi();
80106674:	e8 c4 c8 ff ff       	call   80102f3d <lapiceoi>
    break;
80106679:	e9 ae 01 00 00       	jmp    8010682c <trap+0x27b>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010667e:	e8 10 04 00 00       	call   80106a93 <uartintr>
    lapiceoi();
80106683:	e8 b5 c8 ff ff       	call   80102f3d <lapiceoi>
    break;
80106688:	e9 9f 01 00 00       	jmp    8010682c <trap+0x27b>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010668d:	8b 45 08             	mov    0x8(%ebp),%eax
80106690:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106693:	8b 45 08             	mov    0x8(%ebp),%eax
80106696:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010669a:	0f b7 d8             	movzwl %ax,%ebx
8010669d:	e8 19 da ff ff       	call   801040bb <cpuid>
801066a2:	89 74 24 0c          	mov    %esi,0xc(%esp)
801066a6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801066aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801066ae:	c7 04 24 18 8a 10 80 	movl   $0x80108a18,(%esp)
801066b5:	e8 0e 9d ff ff       	call   801003c8 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
801066ba:	e8 7e c8 ff ff       	call   80102f3d <lapiceoi>
    break;
801066bf:	e9 68 01 00 00       	jmp    8010682c <trap+0x27b>
  //CS153 -- added case
  case T_PGFLT: ;
    uint address = rcr2();
801066c4:	e8 47 fd ff ff       	call   80106410 <rcr2>
801066c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    uint sp = myproc()->tf->esp; //myProcess trapframe; esp is the top of the stack
801066cc:	e8 81 da ff ff       	call   80104152 <myproc>
801066d1:	8b 40 1c             	mov    0x1c(%eax),%eax
801066d4:	8b 40 44             	mov    0x44(%eax),%eax
801066d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (address > PGROUNDDOWN(sp) - PGSIZE && address < PGROUNDDOWN(sp)) { //give an address and it'll round down to the start of the page
801066da:	8b 45 e0             	mov    -0x20(%ebp),%eax
801066dd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801066e2:	2d 00 10 00 00       	sub    $0x1000,%eax
801066e7:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
801066ea:	73 68                	jae    80106754 <trap+0x1a3>
801066ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
801066ef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801066f4:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
801066f7:	76 5b                	jbe    80106754 <trap+0x1a3>
      pte_t*pgdir = myproc()->pgdir;
801066f9:	e8 54 da ff ff       	call   80104152 <myproc>
801066fe:	8b 40 08             	mov    0x8(%eax),%eax
80106701:	89 45 dc             	mov    %eax,-0x24(%ebp)
      
      if (allocuvm(pgdir, PGROUNDDOWN(sp) - PGSIZE, PGROUNDDOWN(sp)) == 0) { //checks if the allocation is valid 
80106704:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106707:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010670c:	89 c2                	mov    %eax,%edx
8010670e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106711:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106716:	2d 00 10 00 00       	sub    $0x1000,%eax
8010671b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010671f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106723:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106726:	89 04 24             	mov    %eax,(%esp)
80106729:	e8 96 16 00 00       	call   80107dc4 <allocuvm>
8010672e:	85 c0                	test   %eax,%eax
80106730:	75 11                	jne    80106743 <trap+0x192>
        cprintf("Oh noes! \n");
80106732:	c7 04 24 3c 8a 10 80 	movl   $0x80108a3c,(%esp)
80106739:	e8 8a 9c ff ff       	call   801003c8 <cprintf>
        exit();
8010673e:	e8 87 de ff ff       	call   801045ca <exit>
      }
      myproc()->pages += 1;
80106743:	e8 0a da ff ff       	call   80104152 <myproc>
80106748:	8b 10                	mov    (%eax),%edx
8010674a:	83 c2 01             	add    $0x1,%edx
8010674d:	89 10                	mov    %edx,(%eax)
    }
    break;
8010674f:	e9 d8 00 00 00       	jmp    8010682c <trap+0x27b>
80106754:	e9 d3 00 00 00       	jmp    8010682c <trap+0x27b>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106759:	e8 f4 d9 ff ff       	call   80104152 <myproc>
8010675e:	85 c0                	test   %eax,%eax
80106760:	74 11                	je     80106773 <trap+0x1c2>
80106762:	8b 45 08             	mov    0x8(%ebp),%eax
80106765:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106769:	0f b7 c0             	movzwl %ax,%eax
8010676c:	83 e0 03             	and    $0x3,%eax
8010676f:	85 c0                	test   %eax,%eax
80106771:	75 40                	jne    801067b3 <trap+0x202>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106773:	e8 98 fc ff ff       	call   80106410 <rcr2>
80106778:	89 c3                	mov    %eax,%ebx
8010677a:	8b 45 08             	mov    0x8(%ebp),%eax
8010677d:	8b 70 38             	mov    0x38(%eax),%esi
80106780:	e8 36 d9 ff ff       	call   801040bb <cpuid>
80106785:	8b 55 08             	mov    0x8(%ebp),%edx
80106788:	8b 52 30             	mov    0x30(%edx),%edx
8010678b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
8010678f:	89 74 24 0c          	mov    %esi,0xc(%esp)
80106793:	89 44 24 08          	mov    %eax,0x8(%esp)
80106797:	89 54 24 04          	mov    %edx,0x4(%esp)
8010679b:	c7 04 24 48 8a 10 80 	movl   $0x80108a48,(%esp)
801067a2:	e8 21 9c ff ff       	call   801003c8 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801067a7:	c7 04 24 7a 8a 10 80 	movl   $0x80108a7a,(%esp)
801067ae:	e8 af 9d ff ff       	call   80100562 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801067b3:	e8 58 fc ff ff       	call   80106410 <rcr2>
801067b8:	89 c6                	mov    %eax,%esi
801067ba:	8b 45 08             	mov    0x8(%ebp),%eax
801067bd:	8b 40 38             	mov    0x38(%eax),%eax
801067c0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801067c3:	e8 f3 d8 ff ff       	call   801040bb <cpuid>
801067c8:	89 c3                	mov    %eax,%ebx
801067ca:	8b 45 08             	mov    0x8(%ebp),%eax
801067cd:	8b 78 34             	mov    0x34(%eax),%edi
801067d0:	89 7d d0             	mov    %edi,-0x30(%ebp)
801067d3:	8b 45 08             	mov    0x8(%ebp),%eax
801067d6:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801067d9:	e8 74 d9 ff ff       	call   80104152 <myproc>
801067de:	8d 50 70             	lea    0x70(%eax),%edx
801067e1:	89 55 cc             	mov    %edx,-0x34(%ebp)
801067e4:	e8 69 d9 ff ff       	call   80104152 <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801067e9:	8b 40 14             	mov    0x14(%eax),%eax
801067ec:	89 74 24 1c          	mov    %esi,0x1c(%esp)
801067f0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
801067f3:	89 4c 24 18          	mov    %ecx,0x18(%esp)
801067f7:	89 5c 24 14          	mov    %ebx,0x14(%esp)
801067fb:	8b 4d d0             	mov    -0x30(%ebp),%ecx
801067fe:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80106802:	89 7c 24 0c          	mov    %edi,0xc(%esp)
80106806:	8b 55 cc             	mov    -0x34(%ebp),%edx
80106809:	89 54 24 08          	mov    %edx,0x8(%esp)
8010680d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106811:	c7 04 24 80 8a 10 80 	movl   $0x80108a80,(%esp)
80106818:	e8 ab 9b ff ff       	call   801003c8 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
8010681d:	e8 30 d9 ff ff       	call   80104152 <myproc>
80106822:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
80106829:	eb 01                	jmp    8010682c <trap+0x27b>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
8010682b:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010682c:	e8 21 d9 ff ff       	call   80104152 <myproc>
80106831:	85 c0                	test   %eax,%eax
80106833:	74 23                	je     80106858 <trap+0x2a7>
80106835:	e8 18 d9 ff ff       	call   80104152 <myproc>
8010683a:	8b 40 28             	mov    0x28(%eax),%eax
8010683d:	85 c0                	test   %eax,%eax
8010683f:	74 17                	je     80106858 <trap+0x2a7>
80106841:	8b 45 08             	mov    0x8(%ebp),%eax
80106844:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106848:	0f b7 c0             	movzwl %ax,%eax
8010684b:	83 e0 03             	and    $0x3,%eax
8010684e:	83 f8 03             	cmp    $0x3,%eax
80106851:	75 05                	jne    80106858 <trap+0x2a7>
    exit();
80106853:	e8 72 dd ff ff       	call   801045ca <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106858:	e8 f5 d8 ff ff       	call   80104152 <myproc>
8010685d:	85 c0                	test   %eax,%eax
8010685f:	74 1d                	je     8010687e <trap+0x2cd>
80106861:	e8 ec d8 ff ff       	call   80104152 <myproc>
80106866:	8b 40 10             	mov    0x10(%eax),%eax
80106869:	83 f8 04             	cmp    $0x4,%eax
8010686c:	75 10                	jne    8010687e <trap+0x2cd>
     tf->trapno == T_IRQ0+IRQ_TIMER)
8010686e:	8b 45 08             	mov    0x8(%ebp),%eax
80106871:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106874:	83 f8 20             	cmp    $0x20,%eax
80106877:	75 05                	jne    8010687e <trap+0x2cd>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
80106879:	e8 bc e0 ff ff       	call   8010493a <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010687e:	e8 cf d8 ff ff       	call   80104152 <myproc>
80106883:	85 c0                	test   %eax,%eax
80106885:	74 23                	je     801068aa <trap+0x2f9>
80106887:	e8 c6 d8 ff ff       	call   80104152 <myproc>
8010688c:	8b 40 28             	mov    0x28(%eax),%eax
8010688f:	85 c0                	test   %eax,%eax
80106891:	74 17                	je     801068aa <trap+0x2f9>
80106893:	8b 45 08             	mov    0x8(%ebp),%eax
80106896:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010689a:	0f b7 c0             	movzwl %ax,%eax
8010689d:	83 e0 03             	and    $0x3,%eax
801068a0:	83 f8 03             	cmp    $0x3,%eax
801068a3:	75 05                	jne    801068aa <trap+0x2f9>
    exit();
801068a5:	e8 20 dd ff ff       	call   801045ca <exit>
}
801068aa:	83 c4 4c             	add    $0x4c,%esp
801068ad:	5b                   	pop    %ebx
801068ae:	5e                   	pop    %esi
801068af:	5f                   	pop    %edi
801068b0:	5d                   	pop    %ebp
801068b1:	c3                   	ret    

801068b2 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801068b2:	55                   	push   %ebp
801068b3:	89 e5                	mov    %esp,%ebp
801068b5:	83 ec 14             	sub    $0x14,%esp
801068b8:	8b 45 08             	mov    0x8(%ebp),%eax
801068bb:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801068bf:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801068c3:	89 c2                	mov    %eax,%edx
801068c5:	ec                   	in     (%dx),%al
801068c6:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801068c9:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801068cd:	c9                   	leave  
801068ce:	c3                   	ret    

801068cf <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801068cf:	55                   	push   %ebp
801068d0:	89 e5                	mov    %esp,%ebp
801068d2:	83 ec 08             	sub    $0x8,%esp
801068d5:	8b 55 08             	mov    0x8(%ebp),%edx
801068d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801068db:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801068df:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801068e2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801068e6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801068ea:	ee                   	out    %al,(%dx)
}
801068eb:	c9                   	leave  
801068ec:	c3                   	ret    

801068ed <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801068ed:	55                   	push   %ebp
801068ee:	89 e5                	mov    %esp,%ebp
801068f0:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801068f3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801068fa:	00 
801068fb:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106902:	e8 c8 ff ff ff       	call   801068cf <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106907:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
8010690e:	00 
8010690f:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106916:	e8 b4 ff ff ff       	call   801068cf <outb>
  outb(COM1+0, 115200/9600);
8010691b:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106922:	00 
80106923:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010692a:	e8 a0 ff ff ff       	call   801068cf <outb>
  outb(COM1+1, 0);
8010692f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106936:	00 
80106937:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
8010693e:	e8 8c ff ff ff       	call   801068cf <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106943:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010694a:	00 
8010694b:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106952:	e8 78 ff ff ff       	call   801068cf <outb>
  outb(COM1+4, 0);
80106957:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010695e:	00 
8010695f:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106966:	e8 64 ff ff ff       	call   801068cf <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010696b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106972:	00 
80106973:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
8010697a:	e8 50 ff ff ff       	call   801068cf <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010697f:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106986:	e8 27 ff ff ff       	call   801068b2 <inb>
8010698b:	3c ff                	cmp    $0xff,%al
8010698d:	75 02                	jne    80106991 <uartinit+0xa4>
    return;
8010698f:	eb 5e                	jmp    801069ef <uartinit+0x102>
  uart = 1;
80106991:	c7 05 24 b6 10 80 01 	movl   $0x1,0x8010b624
80106998:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010699b:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801069a2:	e8 0b ff ff ff       	call   801068b2 <inb>
  inb(COM1+0);
801069a7:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801069ae:	e8 ff fe ff ff       	call   801068b2 <inb>
  ioapicenable(IRQ_COM1, 0);
801069b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801069ba:	00 
801069bb:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801069c2:	e8 64 c0 ff ff       	call   80102a2b <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801069c7:	c7 45 f4 8c 8b 10 80 	movl   $0x80108b8c,-0xc(%ebp)
801069ce:	eb 15                	jmp    801069e5 <uartinit+0xf8>
    uartputc(*p);
801069d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069d3:	0f b6 00             	movzbl (%eax),%eax
801069d6:	0f be c0             	movsbl %al,%eax
801069d9:	89 04 24             	mov    %eax,(%esp)
801069dc:	e8 10 00 00 00       	call   801069f1 <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801069e1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801069e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069e8:	0f b6 00             	movzbl (%eax),%eax
801069eb:	84 c0                	test   %al,%al
801069ed:	75 e1                	jne    801069d0 <uartinit+0xe3>
    uartputc(*p);
}
801069ef:	c9                   	leave  
801069f0:	c3                   	ret    

801069f1 <uartputc>:

void
uartputc(int c)
{
801069f1:	55                   	push   %ebp
801069f2:	89 e5                	mov    %esp,%ebp
801069f4:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
801069f7:	a1 24 b6 10 80       	mov    0x8010b624,%eax
801069fc:	85 c0                	test   %eax,%eax
801069fe:	75 02                	jne    80106a02 <uartputc+0x11>
    return;
80106a00:	eb 4b                	jmp    80106a4d <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106a02:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106a09:	eb 10                	jmp    80106a1b <uartputc+0x2a>
    microdelay(10);
80106a0b:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106a12:	e8 4b c5 ff ff       	call   80102f62 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106a17:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a1b:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106a1f:	7f 16                	jg     80106a37 <uartputc+0x46>
80106a21:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106a28:	e8 85 fe ff ff       	call   801068b2 <inb>
80106a2d:	0f b6 c0             	movzbl %al,%eax
80106a30:	83 e0 20             	and    $0x20,%eax
80106a33:	85 c0                	test   %eax,%eax
80106a35:	74 d4                	je     80106a0b <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106a37:	8b 45 08             	mov    0x8(%ebp),%eax
80106a3a:	0f b6 c0             	movzbl %al,%eax
80106a3d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a41:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106a48:	e8 82 fe ff ff       	call   801068cf <outb>
}
80106a4d:	c9                   	leave  
80106a4e:	c3                   	ret    

80106a4f <uartgetc>:

static int
uartgetc(void)
{
80106a4f:	55                   	push   %ebp
80106a50:	89 e5                	mov    %esp,%ebp
80106a52:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106a55:	a1 24 b6 10 80       	mov    0x8010b624,%eax
80106a5a:	85 c0                	test   %eax,%eax
80106a5c:	75 07                	jne    80106a65 <uartgetc+0x16>
    return -1;
80106a5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a63:	eb 2c                	jmp    80106a91 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106a65:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106a6c:	e8 41 fe ff ff       	call   801068b2 <inb>
80106a71:	0f b6 c0             	movzbl %al,%eax
80106a74:	83 e0 01             	and    $0x1,%eax
80106a77:	85 c0                	test   %eax,%eax
80106a79:	75 07                	jne    80106a82 <uartgetc+0x33>
    return -1;
80106a7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a80:	eb 0f                	jmp    80106a91 <uartgetc+0x42>
  return inb(COM1+0);
80106a82:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106a89:	e8 24 fe ff ff       	call   801068b2 <inb>
80106a8e:	0f b6 c0             	movzbl %al,%eax
}
80106a91:	c9                   	leave  
80106a92:	c3                   	ret    

80106a93 <uartintr>:

void
uartintr(void)
{
80106a93:	55                   	push   %ebp
80106a94:	89 e5                	mov    %esp,%ebp
80106a96:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106a99:	c7 04 24 4f 6a 10 80 	movl   $0x80106a4f,(%esp)
80106aa0:	e8 44 9d ff ff       	call   801007e9 <consoleintr>
}
80106aa5:	c9                   	leave  
80106aa6:	c3                   	ret    

80106aa7 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106aa7:	6a 00                	push   $0x0
  pushl $0
80106aa9:	6a 00                	push   $0x0
  jmp alltraps
80106aab:	e9 14 f9 ff ff       	jmp    801063c4 <alltraps>

80106ab0 <vector1>:
.globl vector1
vector1:
  pushl $0
80106ab0:	6a 00                	push   $0x0
  pushl $1
80106ab2:	6a 01                	push   $0x1
  jmp alltraps
80106ab4:	e9 0b f9 ff ff       	jmp    801063c4 <alltraps>

80106ab9 <vector2>:
.globl vector2
vector2:
  pushl $0
80106ab9:	6a 00                	push   $0x0
  pushl $2
80106abb:	6a 02                	push   $0x2
  jmp alltraps
80106abd:	e9 02 f9 ff ff       	jmp    801063c4 <alltraps>

80106ac2 <vector3>:
.globl vector3
vector3:
  pushl $0
80106ac2:	6a 00                	push   $0x0
  pushl $3
80106ac4:	6a 03                	push   $0x3
  jmp alltraps
80106ac6:	e9 f9 f8 ff ff       	jmp    801063c4 <alltraps>

80106acb <vector4>:
.globl vector4
vector4:
  pushl $0
80106acb:	6a 00                	push   $0x0
  pushl $4
80106acd:	6a 04                	push   $0x4
  jmp alltraps
80106acf:	e9 f0 f8 ff ff       	jmp    801063c4 <alltraps>

80106ad4 <vector5>:
.globl vector5
vector5:
  pushl $0
80106ad4:	6a 00                	push   $0x0
  pushl $5
80106ad6:	6a 05                	push   $0x5
  jmp alltraps
80106ad8:	e9 e7 f8 ff ff       	jmp    801063c4 <alltraps>

80106add <vector6>:
.globl vector6
vector6:
  pushl $0
80106add:	6a 00                	push   $0x0
  pushl $6
80106adf:	6a 06                	push   $0x6
  jmp alltraps
80106ae1:	e9 de f8 ff ff       	jmp    801063c4 <alltraps>

80106ae6 <vector7>:
.globl vector7
vector7:
  pushl $0
80106ae6:	6a 00                	push   $0x0
  pushl $7
80106ae8:	6a 07                	push   $0x7
  jmp alltraps
80106aea:	e9 d5 f8 ff ff       	jmp    801063c4 <alltraps>

80106aef <vector8>:
.globl vector8
vector8:
  pushl $8
80106aef:	6a 08                	push   $0x8
  jmp alltraps
80106af1:	e9 ce f8 ff ff       	jmp    801063c4 <alltraps>

80106af6 <vector9>:
.globl vector9
vector9:
  pushl $0
80106af6:	6a 00                	push   $0x0
  pushl $9
80106af8:	6a 09                	push   $0x9
  jmp alltraps
80106afa:	e9 c5 f8 ff ff       	jmp    801063c4 <alltraps>

80106aff <vector10>:
.globl vector10
vector10:
  pushl $10
80106aff:	6a 0a                	push   $0xa
  jmp alltraps
80106b01:	e9 be f8 ff ff       	jmp    801063c4 <alltraps>

80106b06 <vector11>:
.globl vector11
vector11:
  pushl $11
80106b06:	6a 0b                	push   $0xb
  jmp alltraps
80106b08:	e9 b7 f8 ff ff       	jmp    801063c4 <alltraps>

80106b0d <vector12>:
.globl vector12
vector12:
  pushl $12
80106b0d:	6a 0c                	push   $0xc
  jmp alltraps
80106b0f:	e9 b0 f8 ff ff       	jmp    801063c4 <alltraps>

80106b14 <vector13>:
.globl vector13
vector13:
  pushl $13
80106b14:	6a 0d                	push   $0xd
  jmp alltraps
80106b16:	e9 a9 f8 ff ff       	jmp    801063c4 <alltraps>

80106b1b <vector14>:
.globl vector14
vector14:
  pushl $14
80106b1b:	6a 0e                	push   $0xe
  jmp alltraps
80106b1d:	e9 a2 f8 ff ff       	jmp    801063c4 <alltraps>

80106b22 <vector15>:
.globl vector15
vector15:
  pushl $0
80106b22:	6a 00                	push   $0x0
  pushl $15
80106b24:	6a 0f                	push   $0xf
  jmp alltraps
80106b26:	e9 99 f8 ff ff       	jmp    801063c4 <alltraps>

80106b2b <vector16>:
.globl vector16
vector16:
  pushl $0
80106b2b:	6a 00                	push   $0x0
  pushl $16
80106b2d:	6a 10                	push   $0x10
  jmp alltraps
80106b2f:	e9 90 f8 ff ff       	jmp    801063c4 <alltraps>

80106b34 <vector17>:
.globl vector17
vector17:
  pushl $17
80106b34:	6a 11                	push   $0x11
  jmp alltraps
80106b36:	e9 89 f8 ff ff       	jmp    801063c4 <alltraps>

80106b3b <vector18>:
.globl vector18
vector18:
  pushl $0
80106b3b:	6a 00                	push   $0x0
  pushl $18
80106b3d:	6a 12                	push   $0x12
  jmp alltraps
80106b3f:	e9 80 f8 ff ff       	jmp    801063c4 <alltraps>

80106b44 <vector19>:
.globl vector19
vector19:
  pushl $0
80106b44:	6a 00                	push   $0x0
  pushl $19
80106b46:	6a 13                	push   $0x13
  jmp alltraps
80106b48:	e9 77 f8 ff ff       	jmp    801063c4 <alltraps>

80106b4d <vector20>:
.globl vector20
vector20:
  pushl $0
80106b4d:	6a 00                	push   $0x0
  pushl $20
80106b4f:	6a 14                	push   $0x14
  jmp alltraps
80106b51:	e9 6e f8 ff ff       	jmp    801063c4 <alltraps>

80106b56 <vector21>:
.globl vector21
vector21:
  pushl $0
80106b56:	6a 00                	push   $0x0
  pushl $21
80106b58:	6a 15                	push   $0x15
  jmp alltraps
80106b5a:	e9 65 f8 ff ff       	jmp    801063c4 <alltraps>

80106b5f <vector22>:
.globl vector22
vector22:
  pushl $0
80106b5f:	6a 00                	push   $0x0
  pushl $22
80106b61:	6a 16                	push   $0x16
  jmp alltraps
80106b63:	e9 5c f8 ff ff       	jmp    801063c4 <alltraps>

80106b68 <vector23>:
.globl vector23
vector23:
  pushl $0
80106b68:	6a 00                	push   $0x0
  pushl $23
80106b6a:	6a 17                	push   $0x17
  jmp alltraps
80106b6c:	e9 53 f8 ff ff       	jmp    801063c4 <alltraps>

80106b71 <vector24>:
.globl vector24
vector24:
  pushl $0
80106b71:	6a 00                	push   $0x0
  pushl $24
80106b73:	6a 18                	push   $0x18
  jmp alltraps
80106b75:	e9 4a f8 ff ff       	jmp    801063c4 <alltraps>

80106b7a <vector25>:
.globl vector25
vector25:
  pushl $0
80106b7a:	6a 00                	push   $0x0
  pushl $25
80106b7c:	6a 19                	push   $0x19
  jmp alltraps
80106b7e:	e9 41 f8 ff ff       	jmp    801063c4 <alltraps>

80106b83 <vector26>:
.globl vector26
vector26:
  pushl $0
80106b83:	6a 00                	push   $0x0
  pushl $26
80106b85:	6a 1a                	push   $0x1a
  jmp alltraps
80106b87:	e9 38 f8 ff ff       	jmp    801063c4 <alltraps>

80106b8c <vector27>:
.globl vector27
vector27:
  pushl $0
80106b8c:	6a 00                	push   $0x0
  pushl $27
80106b8e:	6a 1b                	push   $0x1b
  jmp alltraps
80106b90:	e9 2f f8 ff ff       	jmp    801063c4 <alltraps>

80106b95 <vector28>:
.globl vector28
vector28:
  pushl $0
80106b95:	6a 00                	push   $0x0
  pushl $28
80106b97:	6a 1c                	push   $0x1c
  jmp alltraps
80106b99:	e9 26 f8 ff ff       	jmp    801063c4 <alltraps>

80106b9e <vector29>:
.globl vector29
vector29:
  pushl $0
80106b9e:	6a 00                	push   $0x0
  pushl $29
80106ba0:	6a 1d                	push   $0x1d
  jmp alltraps
80106ba2:	e9 1d f8 ff ff       	jmp    801063c4 <alltraps>

80106ba7 <vector30>:
.globl vector30
vector30:
  pushl $0
80106ba7:	6a 00                	push   $0x0
  pushl $30
80106ba9:	6a 1e                	push   $0x1e
  jmp alltraps
80106bab:	e9 14 f8 ff ff       	jmp    801063c4 <alltraps>

80106bb0 <vector31>:
.globl vector31
vector31:
  pushl $0
80106bb0:	6a 00                	push   $0x0
  pushl $31
80106bb2:	6a 1f                	push   $0x1f
  jmp alltraps
80106bb4:	e9 0b f8 ff ff       	jmp    801063c4 <alltraps>

80106bb9 <vector32>:
.globl vector32
vector32:
  pushl $0
80106bb9:	6a 00                	push   $0x0
  pushl $32
80106bbb:	6a 20                	push   $0x20
  jmp alltraps
80106bbd:	e9 02 f8 ff ff       	jmp    801063c4 <alltraps>

80106bc2 <vector33>:
.globl vector33
vector33:
  pushl $0
80106bc2:	6a 00                	push   $0x0
  pushl $33
80106bc4:	6a 21                	push   $0x21
  jmp alltraps
80106bc6:	e9 f9 f7 ff ff       	jmp    801063c4 <alltraps>

80106bcb <vector34>:
.globl vector34
vector34:
  pushl $0
80106bcb:	6a 00                	push   $0x0
  pushl $34
80106bcd:	6a 22                	push   $0x22
  jmp alltraps
80106bcf:	e9 f0 f7 ff ff       	jmp    801063c4 <alltraps>

80106bd4 <vector35>:
.globl vector35
vector35:
  pushl $0
80106bd4:	6a 00                	push   $0x0
  pushl $35
80106bd6:	6a 23                	push   $0x23
  jmp alltraps
80106bd8:	e9 e7 f7 ff ff       	jmp    801063c4 <alltraps>

80106bdd <vector36>:
.globl vector36
vector36:
  pushl $0
80106bdd:	6a 00                	push   $0x0
  pushl $36
80106bdf:	6a 24                	push   $0x24
  jmp alltraps
80106be1:	e9 de f7 ff ff       	jmp    801063c4 <alltraps>

80106be6 <vector37>:
.globl vector37
vector37:
  pushl $0
80106be6:	6a 00                	push   $0x0
  pushl $37
80106be8:	6a 25                	push   $0x25
  jmp alltraps
80106bea:	e9 d5 f7 ff ff       	jmp    801063c4 <alltraps>

80106bef <vector38>:
.globl vector38
vector38:
  pushl $0
80106bef:	6a 00                	push   $0x0
  pushl $38
80106bf1:	6a 26                	push   $0x26
  jmp alltraps
80106bf3:	e9 cc f7 ff ff       	jmp    801063c4 <alltraps>

80106bf8 <vector39>:
.globl vector39
vector39:
  pushl $0
80106bf8:	6a 00                	push   $0x0
  pushl $39
80106bfa:	6a 27                	push   $0x27
  jmp alltraps
80106bfc:	e9 c3 f7 ff ff       	jmp    801063c4 <alltraps>

80106c01 <vector40>:
.globl vector40
vector40:
  pushl $0
80106c01:	6a 00                	push   $0x0
  pushl $40
80106c03:	6a 28                	push   $0x28
  jmp alltraps
80106c05:	e9 ba f7 ff ff       	jmp    801063c4 <alltraps>

80106c0a <vector41>:
.globl vector41
vector41:
  pushl $0
80106c0a:	6a 00                	push   $0x0
  pushl $41
80106c0c:	6a 29                	push   $0x29
  jmp alltraps
80106c0e:	e9 b1 f7 ff ff       	jmp    801063c4 <alltraps>

80106c13 <vector42>:
.globl vector42
vector42:
  pushl $0
80106c13:	6a 00                	push   $0x0
  pushl $42
80106c15:	6a 2a                	push   $0x2a
  jmp alltraps
80106c17:	e9 a8 f7 ff ff       	jmp    801063c4 <alltraps>

80106c1c <vector43>:
.globl vector43
vector43:
  pushl $0
80106c1c:	6a 00                	push   $0x0
  pushl $43
80106c1e:	6a 2b                	push   $0x2b
  jmp alltraps
80106c20:	e9 9f f7 ff ff       	jmp    801063c4 <alltraps>

80106c25 <vector44>:
.globl vector44
vector44:
  pushl $0
80106c25:	6a 00                	push   $0x0
  pushl $44
80106c27:	6a 2c                	push   $0x2c
  jmp alltraps
80106c29:	e9 96 f7 ff ff       	jmp    801063c4 <alltraps>

80106c2e <vector45>:
.globl vector45
vector45:
  pushl $0
80106c2e:	6a 00                	push   $0x0
  pushl $45
80106c30:	6a 2d                	push   $0x2d
  jmp alltraps
80106c32:	e9 8d f7 ff ff       	jmp    801063c4 <alltraps>

80106c37 <vector46>:
.globl vector46
vector46:
  pushl $0
80106c37:	6a 00                	push   $0x0
  pushl $46
80106c39:	6a 2e                	push   $0x2e
  jmp alltraps
80106c3b:	e9 84 f7 ff ff       	jmp    801063c4 <alltraps>

80106c40 <vector47>:
.globl vector47
vector47:
  pushl $0
80106c40:	6a 00                	push   $0x0
  pushl $47
80106c42:	6a 2f                	push   $0x2f
  jmp alltraps
80106c44:	e9 7b f7 ff ff       	jmp    801063c4 <alltraps>

80106c49 <vector48>:
.globl vector48
vector48:
  pushl $0
80106c49:	6a 00                	push   $0x0
  pushl $48
80106c4b:	6a 30                	push   $0x30
  jmp alltraps
80106c4d:	e9 72 f7 ff ff       	jmp    801063c4 <alltraps>

80106c52 <vector49>:
.globl vector49
vector49:
  pushl $0
80106c52:	6a 00                	push   $0x0
  pushl $49
80106c54:	6a 31                	push   $0x31
  jmp alltraps
80106c56:	e9 69 f7 ff ff       	jmp    801063c4 <alltraps>

80106c5b <vector50>:
.globl vector50
vector50:
  pushl $0
80106c5b:	6a 00                	push   $0x0
  pushl $50
80106c5d:	6a 32                	push   $0x32
  jmp alltraps
80106c5f:	e9 60 f7 ff ff       	jmp    801063c4 <alltraps>

80106c64 <vector51>:
.globl vector51
vector51:
  pushl $0
80106c64:	6a 00                	push   $0x0
  pushl $51
80106c66:	6a 33                	push   $0x33
  jmp alltraps
80106c68:	e9 57 f7 ff ff       	jmp    801063c4 <alltraps>

80106c6d <vector52>:
.globl vector52
vector52:
  pushl $0
80106c6d:	6a 00                	push   $0x0
  pushl $52
80106c6f:	6a 34                	push   $0x34
  jmp alltraps
80106c71:	e9 4e f7 ff ff       	jmp    801063c4 <alltraps>

80106c76 <vector53>:
.globl vector53
vector53:
  pushl $0
80106c76:	6a 00                	push   $0x0
  pushl $53
80106c78:	6a 35                	push   $0x35
  jmp alltraps
80106c7a:	e9 45 f7 ff ff       	jmp    801063c4 <alltraps>

80106c7f <vector54>:
.globl vector54
vector54:
  pushl $0
80106c7f:	6a 00                	push   $0x0
  pushl $54
80106c81:	6a 36                	push   $0x36
  jmp alltraps
80106c83:	e9 3c f7 ff ff       	jmp    801063c4 <alltraps>

80106c88 <vector55>:
.globl vector55
vector55:
  pushl $0
80106c88:	6a 00                	push   $0x0
  pushl $55
80106c8a:	6a 37                	push   $0x37
  jmp alltraps
80106c8c:	e9 33 f7 ff ff       	jmp    801063c4 <alltraps>

80106c91 <vector56>:
.globl vector56
vector56:
  pushl $0
80106c91:	6a 00                	push   $0x0
  pushl $56
80106c93:	6a 38                	push   $0x38
  jmp alltraps
80106c95:	e9 2a f7 ff ff       	jmp    801063c4 <alltraps>

80106c9a <vector57>:
.globl vector57
vector57:
  pushl $0
80106c9a:	6a 00                	push   $0x0
  pushl $57
80106c9c:	6a 39                	push   $0x39
  jmp alltraps
80106c9e:	e9 21 f7 ff ff       	jmp    801063c4 <alltraps>

80106ca3 <vector58>:
.globl vector58
vector58:
  pushl $0
80106ca3:	6a 00                	push   $0x0
  pushl $58
80106ca5:	6a 3a                	push   $0x3a
  jmp alltraps
80106ca7:	e9 18 f7 ff ff       	jmp    801063c4 <alltraps>

80106cac <vector59>:
.globl vector59
vector59:
  pushl $0
80106cac:	6a 00                	push   $0x0
  pushl $59
80106cae:	6a 3b                	push   $0x3b
  jmp alltraps
80106cb0:	e9 0f f7 ff ff       	jmp    801063c4 <alltraps>

80106cb5 <vector60>:
.globl vector60
vector60:
  pushl $0
80106cb5:	6a 00                	push   $0x0
  pushl $60
80106cb7:	6a 3c                	push   $0x3c
  jmp alltraps
80106cb9:	e9 06 f7 ff ff       	jmp    801063c4 <alltraps>

80106cbe <vector61>:
.globl vector61
vector61:
  pushl $0
80106cbe:	6a 00                	push   $0x0
  pushl $61
80106cc0:	6a 3d                	push   $0x3d
  jmp alltraps
80106cc2:	e9 fd f6 ff ff       	jmp    801063c4 <alltraps>

80106cc7 <vector62>:
.globl vector62
vector62:
  pushl $0
80106cc7:	6a 00                	push   $0x0
  pushl $62
80106cc9:	6a 3e                	push   $0x3e
  jmp alltraps
80106ccb:	e9 f4 f6 ff ff       	jmp    801063c4 <alltraps>

80106cd0 <vector63>:
.globl vector63
vector63:
  pushl $0
80106cd0:	6a 00                	push   $0x0
  pushl $63
80106cd2:	6a 3f                	push   $0x3f
  jmp alltraps
80106cd4:	e9 eb f6 ff ff       	jmp    801063c4 <alltraps>

80106cd9 <vector64>:
.globl vector64
vector64:
  pushl $0
80106cd9:	6a 00                	push   $0x0
  pushl $64
80106cdb:	6a 40                	push   $0x40
  jmp alltraps
80106cdd:	e9 e2 f6 ff ff       	jmp    801063c4 <alltraps>

80106ce2 <vector65>:
.globl vector65
vector65:
  pushl $0
80106ce2:	6a 00                	push   $0x0
  pushl $65
80106ce4:	6a 41                	push   $0x41
  jmp alltraps
80106ce6:	e9 d9 f6 ff ff       	jmp    801063c4 <alltraps>

80106ceb <vector66>:
.globl vector66
vector66:
  pushl $0
80106ceb:	6a 00                	push   $0x0
  pushl $66
80106ced:	6a 42                	push   $0x42
  jmp alltraps
80106cef:	e9 d0 f6 ff ff       	jmp    801063c4 <alltraps>

80106cf4 <vector67>:
.globl vector67
vector67:
  pushl $0
80106cf4:	6a 00                	push   $0x0
  pushl $67
80106cf6:	6a 43                	push   $0x43
  jmp alltraps
80106cf8:	e9 c7 f6 ff ff       	jmp    801063c4 <alltraps>

80106cfd <vector68>:
.globl vector68
vector68:
  pushl $0
80106cfd:	6a 00                	push   $0x0
  pushl $68
80106cff:	6a 44                	push   $0x44
  jmp alltraps
80106d01:	e9 be f6 ff ff       	jmp    801063c4 <alltraps>

80106d06 <vector69>:
.globl vector69
vector69:
  pushl $0
80106d06:	6a 00                	push   $0x0
  pushl $69
80106d08:	6a 45                	push   $0x45
  jmp alltraps
80106d0a:	e9 b5 f6 ff ff       	jmp    801063c4 <alltraps>

80106d0f <vector70>:
.globl vector70
vector70:
  pushl $0
80106d0f:	6a 00                	push   $0x0
  pushl $70
80106d11:	6a 46                	push   $0x46
  jmp alltraps
80106d13:	e9 ac f6 ff ff       	jmp    801063c4 <alltraps>

80106d18 <vector71>:
.globl vector71
vector71:
  pushl $0
80106d18:	6a 00                	push   $0x0
  pushl $71
80106d1a:	6a 47                	push   $0x47
  jmp alltraps
80106d1c:	e9 a3 f6 ff ff       	jmp    801063c4 <alltraps>

80106d21 <vector72>:
.globl vector72
vector72:
  pushl $0
80106d21:	6a 00                	push   $0x0
  pushl $72
80106d23:	6a 48                	push   $0x48
  jmp alltraps
80106d25:	e9 9a f6 ff ff       	jmp    801063c4 <alltraps>

80106d2a <vector73>:
.globl vector73
vector73:
  pushl $0
80106d2a:	6a 00                	push   $0x0
  pushl $73
80106d2c:	6a 49                	push   $0x49
  jmp alltraps
80106d2e:	e9 91 f6 ff ff       	jmp    801063c4 <alltraps>

80106d33 <vector74>:
.globl vector74
vector74:
  pushl $0
80106d33:	6a 00                	push   $0x0
  pushl $74
80106d35:	6a 4a                	push   $0x4a
  jmp alltraps
80106d37:	e9 88 f6 ff ff       	jmp    801063c4 <alltraps>

80106d3c <vector75>:
.globl vector75
vector75:
  pushl $0
80106d3c:	6a 00                	push   $0x0
  pushl $75
80106d3e:	6a 4b                	push   $0x4b
  jmp alltraps
80106d40:	e9 7f f6 ff ff       	jmp    801063c4 <alltraps>

80106d45 <vector76>:
.globl vector76
vector76:
  pushl $0
80106d45:	6a 00                	push   $0x0
  pushl $76
80106d47:	6a 4c                	push   $0x4c
  jmp alltraps
80106d49:	e9 76 f6 ff ff       	jmp    801063c4 <alltraps>

80106d4e <vector77>:
.globl vector77
vector77:
  pushl $0
80106d4e:	6a 00                	push   $0x0
  pushl $77
80106d50:	6a 4d                	push   $0x4d
  jmp alltraps
80106d52:	e9 6d f6 ff ff       	jmp    801063c4 <alltraps>

80106d57 <vector78>:
.globl vector78
vector78:
  pushl $0
80106d57:	6a 00                	push   $0x0
  pushl $78
80106d59:	6a 4e                	push   $0x4e
  jmp alltraps
80106d5b:	e9 64 f6 ff ff       	jmp    801063c4 <alltraps>

80106d60 <vector79>:
.globl vector79
vector79:
  pushl $0
80106d60:	6a 00                	push   $0x0
  pushl $79
80106d62:	6a 4f                	push   $0x4f
  jmp alltraps
80106d64:	e9 5b f6 ff ff       	jmp    801063c4 <alltraps>

80106d69 <vector80>:
.globl vector80
vector80:
  pushl $0
80106d69:	6a 00                	push   $0x0
  pushl $80
80106d6b:	6a 50                	push   $0x50
  jmp alltraps
80106d6d:	e9 52 f6 ff ff       	jmp    801063c4 <alltraps>

80106d72 <vector81>:
.globl vector81
vector81:
  pushl $0
80106d72:	6a 00                	push   $0x0
  pushl $81
80106d74:	6a 51                	push   $0x51
  jmp alltraps
80106d76:	e9 49 f6 ff ff       	jmp    801063c4 <alltraps>

80106d7b <vector82>:
.globl vector82
vector82:
  pushl $0
80106d7b:	6a 00                	push   $0x0
  pushl $82
80106d7d:	6a 52                	push   $0x52
  jmp alltraps
80106d7f:	e9 40 f6 ff ff       	jmp    801063c4 <alltraps>

80106d84 <vector83>:
.globl vector83
vector83:
  pushl $0
80106d84:	6a 00                	push   $0x0
  pushl $83
80106d86:	6a 53                	push   $0x53
  jmp alltraps
80106d88:	e9 37 f6 ff ff       	jmp    801063c4 <alltraps>

80106d8d <vector84>:
.globl vector84
vector84:
  pushl $0
80106d8d:	6a 00                	push   $0x0
  pushl $84
80106d8f:	6a 54                	push   $0x54
  jmp alltraps
80106d91:	e9 2e f6 ff ff       	jmp    801063c4 <alltraps>

80106d96 <vector85>:
.globl vector85
vector85:
  pushl $0
80106d96:	6a 00                	push   $0x0
  pushl $85
80106d98:	6a 55                	push   $0x55
  jmp alltraps
80106d9a:	e9 25 f6 ff ff       	jmp    801063c4 <alltraps>

80106d9f <vector86>:
.globl vector86
vector86:
  pushl $0
80106d9f:	6a 00                	push   $0x0
  pushl $86
80106da1:	6a 56                	push   $0x56
  jmp alltraps
80106da3:	e9 1c f6 ff ff       	jmp    801063c4 <alltraps>

80106da8 <vector87>:
.globl vector87
vector87:
  pushl $0
80106da8:	6a 00                	push   $0x0
  pushl $87
80106daa:	6a 57                	push   $0x57
  jmp alltraps
80106dac:	e9 13 f6 ff ff       	jmp    801063c4 <alltraps>

80106db1 <vector88>:
.globl vector88
vector88:
  pushl $0
80106db1:	6a 00                	push   $0x0
  pushl $88
80106db3:	6a 58                	push   $0x58
  jmp alltraps
80106db5:	e9 0a f6 ff ff       	jmp    801063c4 <alltraps>

80106dba <vector89>:
.globl vector89
vector89:
  pushl $0
80106dba:	6a 00                	push   $0x0
  pushl $89
80106dbc:	6a 59                	push   $0x59
  jmp alltraps
80106dbe:	e9 01 f6 ff ff       	jmp    801063c4 <alltraps>

80106dc3 <vector90>:
.globl vector90
vector90:
  pushl $0
80106dc3:	6a 00                	push   $0x0
  pushl $90
80106dc5:	6a 5a                	push   $0x5a
  jmp alltraps
80106dc7:	e9 f8 f5 ff ff       	jmp    801063c4 <alltraps>

80106dcc <vector91>:
.globl vector91
vector91:
  pushl $0
80106dcc:	6a 00                	push   $0x0
  pushl $91
80106dce:	6a 5b                	push   $0x5b
  jmp alltraps
80106dd0:	e9 ef f5 ff ff       	jmp    801063c4 <alltraps>

80106dd5 <vector92>:
.globl vector92
vector92:
  pushl $0
80106dd5:	6a 00                	push   $0x0
  pushl $92
80106dd7:	6a 5c                	push   $0x5c
  jmp alltraps
80106dd9:	e9 e6 f5 ff ff       	jmp    801063c4 <alltraps>

80106dde <vector93>:
.globl vector93
vector93:
  pushl $0
80106dde:	6a 00                	push   $0x0
  pushl $93
80106de0:	6a 5d                	push   $0x5d
  jmp alltraps
80106de2:	e9 dd f5 ff ff       	jmp    801063c4 <alltraps>

80106de7 <vector94>:
.globl vector94
vector94:
  pushl $0
80106de7:	6a 00                	push   $0x0
  pushl $94
80106de9:	6a 5e                	push   $0x5e
  jmp alltraps
80106deb:	e9 d4 f5 ff ff       	jmp    801063c4 <alltraps>

80106df0 <vector95>:
.globl vector95
vector95:
  pushl $0
80106df0:	6a 00                	push   $0x0
  pushl $95
80106df2:	6a 5f                	push   $0x5f
  jmp alltraps
80106df4:	e9 cb f5 ff ff       	jmp    801063c4 <alltraps>

80106df9 <vector96>:
.globl vector96
vector96:
  pushl $0
80106df9:	6a 00                	push   $0x0
  pushl $96
80106dfb:	6a 60                	push   $0x60
  jmp alltraps
80106dfd:	e9 c2 f5 ff ff       	jmp    801063c4 <alltraps>

80106e02 <vector97>:
.globl vector97
vector97:
  pushl $0
80106e02:	6a 00                	push   $0x0
  pushl $97
80106e04:	6a 61                	push   $0x61
  jmp alltraps
80106e06:	e9 b9 f5 ff ff       	jmp    801063c4 <alltraps>

80106e0b <vector98>:
.globl vector98
vector98:
  pushl $0
80106e0b:	6a 00                	push   $0x0
  pushl $98
80106e0d:	6a 62                	push   $0x62
  jmp alltraps
80106e0f:	e9 b0 f5 ff ff       	jmp    801063c4 <alltraps>

80106e14 <vector99>:
.globl vector99
vector99:
  pushl $0
80106e14:	6a 00                	push   $0x0
  pushl $99
80106e16:	6a 63                	push   $0x63
  jmp alltraps
80106e18:	e9 a7 f5 ff ff       	jmp    801063c4 <alltraps>

80106e1d <vector100>:
.globl vector100
vector100:
  pushl $0
80106e1d:	6a 00                	push   $0x0
  pushl $100
80106e1f:	6a 64                	push   $0x64
  jmp alltraps
80106e21:	e9 9e f5 ff ff       	jmp    801063c4 <alltraps>

80106e26 <vector101>:
.globl vector101
vector101:
  pushl $0
80106e26:	6a 00                	push   $0x0
  pushl $101
80106e28:	6a 65                	push   $0x65
  jmp alltraps
80106e2a:	e9 95 f5 ff ff       	jmp    801063c4 <alltraps>

80106e2f <vector102>:
.globl vector102
vector102:
  pushl $0
80106e2f:	6a 00                	push   $0x0
  pushl $102
80106e31:	6a 66                	push   $0x66
  jmp alltraps
80106e33:	e9 8c f5 ff ff       	jmp    801063c4 <alltraps>

80106e38 <vector103>:
.globl vector103
vector103:
  pushl $0
80106e38:	6a 00                	push   $0x0
  pushl $103
80106e3a:	6a 67                	push   $0x67
  jmp alltraps
80106e3c:	e9 83 f5 ff ff       	jmp    801063c4 <alltraps>

80106e41 <vector104>:
.globl vector104
vector104:
  pushl $0
80106e41:	6a 00                	push   $0x0
  pushl $104
80106e43:	6a 68                	push   $0x68
  jmp alltraps
80106e45:	e9 7a f5 ff ff       	jmp    801063c4 <alltraps>

80106e4a <vector105>:
.globl vector105
vector105:
  pushl $0
80106e4a:	6a 00                	push   $0x0
  pushl $105
80106e4c:	6a 69                	push   $0x69
  jmp alltraps
80106e4e:	e9 71 f5 ff ff       	jmp    801063c4 <alltraps>

80106e53 <vector106>:
.globl vector106
vector106:
  pushl $0
80106e53:	6a 00                	push   $0x0
  pushl $106
80106e55:	6a 6a                	push   $0x6a
  jmp alltraps
80106e57:	e9 68 f5 ff ff       	jmp    801063c4 <alltraps>

80106e5c <vector107>:
.globl vector107
vector107:
  pushl $0
80106e5c:	6a 00                	push   $0x0
  pushl $107
80106e5e:	6a 6b                	push   $0x6b
  jmp alltraps
80106e60:	e9 5f f5 ff ff       	jmp    801063c4 <alltraps>

80106e65 <vector108>:
.globl vector108
vector108:
  pushl $0
80106e65:	6a 00                	push   $0x0
  pushl $108
80106e67:	6a 6c                	push   $0x6c
  jmp alltraps
80106e69:	e9 56 f5 ff ff       	jmp    801063c4 <alltraps>

80106e6e <vector109>:
.globl vector109
vector109:
  pushl $0
80106e6e:	6a 00                	push   $0x0
  pushl $109
80106e70:	6a 6d                	push   $0x6d
  jmp alltraps
80106e72:	e9 4d f5 ff ff       	jmp    801063c4 <alltraps>

80106e77 <vector110>:
.globl vector110
vector110:
  pushl $0
80106e77:	6a 00                	push   $0x0
  pushl $110
80106e79:	6a 6e                	push   $0x6e
  jmp alltraps
80106e7b:	e9 44 f5 ff ff       	jmp    801063c4 <alltraps>

80106e80 <vector111>:
.globl vector111
vector111:
  pushl $0
80106e80:	6a 00                	push   $0x0
  pushl $111
80106e82:	6a 6f                	push   $0x6f
  jmp alltraps
80106e84:	e9 3b f5 ff ff       	jmp    801063c4 <alltraps>

80106e89 <vector112>:
.globl vector112
vector112:
  pushl $0
80106e89:	6a 00                	push   $0x0
  pushl $112
80106e8b:	6a 70                	push   $0x70
  jmp alltraps
80106e8d:	e9 32 f5 ff ff       	jmp    801063c4 <alltraps>

80106e92 <vector113>:
.globl vector113
vector113:
  pushl $0
80106e92:	6a 00                	push   $0x0
  pushl $113
80106e94:	6a 71                	push   $0x71
  jmp alltraps
80106e96:	e9 29 f5 ff ff       	jmp    801063c4 <alltraps>

80106e9b <vector114>:
.globl vector114
vector114:
  pushl $0
80106e9b:	6a 00                	push   $0x0
  pushl $114
80106e9d:	6a 72                	push   $0x72
  jmp alltraps
80106e9f:	e9 20 f5 ff ff       	jmp    801063c4 <alltraps>

80106ea4 <vector115>:
.globl vector115
vector115:
  pushl $0
80106ea4:	6a 00                	push   $0x0
  pushl $115
80106ea6:	6a 73                	push   $0x73
  jmp alltraps
80106ea8:	e9 17 f5 ff ff       	jmp    801063c4 <alltraps>

80106ead <vector116>:
.globl vector116
vector116:
  pushl $0
80106ead:	6a 00                	push   $0x0
  pushl $116
80106eaf:	6a 74                	push   $0x74
  jmp alltraps
80106eb1:	e9 0e f5 ff ff       	jmp    801063c4 <alltraps>

80106eb6 <vector117>:
.globl vector117
vector117:
  pushl $0
80106eb6:	6a 00                	push   $0x0
  pushl $117
80106eb8:	6a 75                	push   $0x75
  jmp alltraps
80106eba:	e9 05 f5 ff ff       	jmp    801063c4 <alltraps>

80106ebf <vector118>:
.globl vector118
vector118:
  pushl $0
80106ebf:	6a 00                	push   $0x0
  pushl $118
80106ec1:	6a 76                	push   $0x76
  jmp alltraps
80106ec3:	e9 fc f4 ff ff       	jmp    801063c4 <alltraps>

80106ec8 <vector119>:
.globl vector119
vector119:
  pushl $0
80106ec8:	6a 00                	push   $0x0
  pushl $119
80106eca:	6a 77                	push   $0x77
  jmp alltraps
80106ecc:	e9 f3 f4 ff ff       	jmp    801063c4 <alltraps>

80106ed1 <vector120>:
.globl vector120
vector120:
  pushl $0
80106ed1:	6a 00                	push   $0x0
  pushl $120
80106ed3:	6a 78                	push   $0x78
  jmp alltraps
80106ed5:	e9 ea f4 ff ff       	jmp    801063c4 <alltraps>

80106eda <vector121>:
.globl vector121
vector121:
  pushl $0
80106eda:	6a 00                	push   $0x0
  pushl $121
80106edc:	6a 79                	push   $0x79
  jmp alltraps
80106ede:	e9 e1 f4 ff ff       	jmp    801063c4 <alltraps>

80106ee3 <vector122>:
.globl vector122
vector122:
  pushl $0
80106ee3:	6a 00                	push   $0x0
  pushl $122
80106ee5:	6a 7a                	push   $0x7a
  jmp alltraps
80106ee7:	e9 d8 f4 ff ff       	jmp    801063c4 <alltraps>

80106eec <vector123>:
.globl vector123
vector123:
  pushl $0
80106eec:	6a 00                	push   $0x0
  pushl $123
80106eee:	6a 7b                	push   $0x7b
  jmp alltraps
80106ef0:	e9 cf f4 ff ff       	jmp    801063c4 <alltraps>

80106ef5 <vector124>:
.globl vector124
vector124:
  pushl $0
80106ef5:	6a 00                	push   $0x0
  pushl $124
80106ef7:	6a 7c                	push   $0x7c
  jmp alltraps
80106ef9:	e9 c6 f4 ff ff       	jmp    801063c4 <alltraps>

80106efe <vector125>:
.globl vector125
vector125:
  pushl $0
80106efe:	6a 00                	push   $0x0
  pushl $125
80106f00:	6a 7d                	push   $0x7d
  jmp alltraps
80106f02:	e9 bd f4 ff ff       	jmp    801063c4 <alltraps>

80106f07 <vector126>:
.globl vector126
vector126:
  pushl $0
80106f07:	6a 00                	push   $0x0
  pushl $126
80106f09:	6a 7e                	push   $0x7e
  jmp alltraps
80106f0b:	e9 b4 f4 ff ff       	jmp    801063c4 <alltraps>

80106f10 <vector127>:
.globl vector127
vector127:
  pushl $0
80106f10:	6a 00                	push   $0x0
  pushl $127
80106f12:	6a 7f                	push   $0x7f
  jmp alltraps
80106f14:	e9 ab f4 ff ff       	jmp    801063c4 <alltraps>

80106f19 <vector128>:
.globl vector128
vector128:
  pushl $0
80106f19:	6a 00                	push   $0x0
  pushl $128
80106f1b:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106f20:	e9 9f f4 ff ff       	jmp    801063c4 <alltraps>

80106f25 <vector129>:
.globl vector129
vector129:
  pushl $0
80106f25:	6a 00                	push   $0x0
  pushl $129
80106f27:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106f2c:	e9 93 f4 ff ff       	jmp    801063c4 <alltraps>

80106f31 <vector130>:
.globl vector130
vector130:
  pushl $0
80106f31:	6a 00                	push   $0x0
  pushl $130
80106f33:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106f38:	e9 87 f4 ff ff       	jmp    801063c4 <alltraps>

80106f3d <vector131>:
.globl vector131
vector131:
  pushl $0
80106f3d:	6a 00                	push   $0x0
  pushl $131
80106f3f:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106f44:	e9 7b f4 ff ff       	jmp    801063c4 <alltraps>

80106f49 <vector132>:
.globl vector132
vector132:
  pushl $0
80106f49:	6a 00                	push   $0x0
  pushl $132
80106f4b:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106f50:	e9 6f f4 ff ff       	jmp    801063c4 <alltraps>

80106f55 <vector133>:
.globl vector133
vector133:
  pushl $0
80106f55:	6a 00                	push   $0x0
  pushl $133
80106f57:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106f5c:	e9 63 f4 ff ff       	jmp    801063c4 <alltraps>

80106f61 <vector134>:
.globl vector134
vector134:
  pushl $0
80106f61:	6a 00                	push   $0x0
  pushl $134
80106f63:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106f68:	e9 57 f4 ff ff       	jmp    801063c4 <alltraps>

80106f6d <vector135>:
.globl vector135
vector135:
  pushl $0
80106f6d:	6a 00                	push   $0x0
  pushl $135
80106f6f:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106f74:	e9 4b f4 ff ff       	jmp    801063c4 <alltraps>

80106f79 <vector136>:
.globl vector136
vector136:
  pushl $0
80106f79:	6a 00                	push   $0x0
  pushl $136
80106f7b:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106f80:	e9 3f f4 ff ff       	jmp    801063c4 <alltraps>

80106f85 <vector137>:
.globl vector137
vector137:
  pushl $0
80106f85:	6a 00                	push   $0x0
  pushl $137
80106f87:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106f8c:	e9 33 f4 ff ff       	jmp    801063c4 <alltraps>

80106f91 <vector138>:
.globl vector138
vector138:
  pushl $0
80106f91:	6a 00                	push   $0x0
  pushl $138
80106f93:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106f98:	e9 27 f4 ff ff       	jmp    801063c4 <alltraps>

80106f9d <vector139>:
.globl vector139
vector139:
  pushl $0
80106f9d:	6a 00                	push   $0x0
  pushl $139
80106f9f:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106fa4:	e9 1b f4 ff ff       	jmp    801063c4 <alltraps>

80106fa9 <vector140>:
.globl vector140
vector140:
  pushl $0
80106fa9:	6a 00                	push   $0x0
  pushl $140
80106fab:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106fb0:	e9 0f f4 ff ff       	jmp    801063c4 <alltraps>

80106fb5 <vector141>:
.globl vector141
vector141:
  pushl $0
80106fb5:	6a 00                	push   $0x0
  pushl $141
80106fb7:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106fbc:	e9 03 f4 ff ff       	jmp    801063c4 <alltraps>

80106fc1 <vector142>:
.globl vector142
vector142:
  pushl $0
80106fc1:	6a 00                	push   $0x0
  pushl $142
80106fc3:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106fc8:	e9 f7 f3 ff ff       	jmp    801063c4 <alltraps>

80106fcd <vector143>:
.globl vector143
vector143:
  pushl $0
80106fcd:	6a 00                	push   $0x0
  pushl $143
80106fcf:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106fd4:	e9 eb f3 ff ff       	jmp    801063c4 <alltraps>

80106fd9 <vector144>:
.globl vector144
vector144:
  pushl $0
80106fd9:	6a 00                	push   $0x0
  pushl $144
80106fdb:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106fe0:	e9 df f3 ff ff       	jmp    801063c4 <alltraps>

80106fe5 <vector145>:
.globl vector145
vector145:
  pushl $0
80106fe5:	6a 00                	push   $0x0
  pushl $145
80106fe7:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106fec:	e9 d3 f3 ff ff       	jmp    801063c4 <alltraps>

80106ff1 <vector146>:
.globl vector146
vector146:
  pushl $0
80106ff1:	6a 00                	push   $0x0
  pushl $146
80106ff3:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106ff8:	e9 c7 f3 ff ff       	jmp    801063c4 <alltraps>

80106ffd <vector147>:
.globl vector147
vector147:
  pushl $0
80106ffd:	6a 00                	push   $0x0
  pushl $147
80106fff:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107004:	e9 bb f3 ff ff       	jmp    801063c4 <alltraps>

80107009 <vector148>:
.globl vector148
vector148:
  pushl $0
80107009:	6a 00                	push   $0x0
  pushl $148
8010700b:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107010:	e9 af f3 ff ff       	jmp    801063c4 <alltraps>

80107015 <vector149>:
.globl vector149
vector149:
  pushl $0
80107015:	6a 00                	push   $0x0
  pushl $149
80107017:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010701c:	e9 a3 f3 ff ff       	jmp    801063c4 <alltraps>

80107021 <vector150>:
.globl vector150
vector150:
  pushl $0
80107021:	6a 00                	push   $0x0
  pushl $150
80107023:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107028:	e9 97 f3 ff ff       	jmp    801063c4 <alltraps>

8010702d <vector151>:
.globl vector151
vector151:
  pushl $0
8010702d:	6a 00                	push   $0x0
  pushl $151
8010702f:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107034:	e9 8b f3 ff ff       	jmp    801063c4 <alltraps>

80107039 <vector152>:
.globl vector152
vector152:
  pushl $0
80107039:	6a 00                	push   $0x0
  pushl $152
8010703b:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107040:	e9 7f f3 ff ff       	jmp    801063c4 <alltraps>

80107045 <vector153>:
.globl vector153
vector153:
  pushl $0
80107045:	6a 00                	push   $0x0
  pushl $153
80107047:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010704c:	e9 73 f3 ff ff       	jmp    801063c4 <alltraps>

80107051 <vector154>:
.globl vector154
vector154:
  pushl $0
80107051:	6a 00                	push   $0x0
  pushl $154
80107053:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107058:	e9 67 f3 ff ff       	jmp    801063c4 <alltraps>

8010705d <vector155>:
.globl vector155
vector155:
  pushl $0
8010705d:	6a 00                	push   $0x0
  pushl $155
8010705f:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107064:	e9 5b f3 ff ff       	jmp    801063c4 <alltraps>

80107069 <vector156>:
.globl vector156
vector156:
  pushl $0
80107069:	6a 00                	push   $0x0
  pushl $156
8010706b:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107070:	e9 4f f3 ff ff       	jmp    801063c4 <alltraps>

80107075 <vector157>:
.globl vector157
vector157:
  pushl $0
80107075:	6a 00                	push   $0x0
  pushl $157
80107077:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010707c:	e9 43 f3 ff ff       	jmp    801063c4 <alltraps>

80107081 <vector158>:
.globl vector158
vector158:
  pushl $0
80107081:	6a 00                	push   $0x0
  pushl $158
80107083:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107088:	e9 37 f3 ff ff       	jmp    801063c4 <alltraps>

8010708d <vector159>:
.globl vector159
vector159:
  pushl $0
8010708d:	6a 00                	push   $0x0
  pushl $159
8010708f:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107094:	e9 2b f3 ff ff       	jmp    801063c4 <alltraps>

80107099 <vector160>:
.globl vector160
vector160:
  pushl $0
80107099:	6a 00                	push   $0x0
  pushl $160
8010709b:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801070a0:	e9 1f f3 ff ff       	jmp    801063c4 <alltraps>

801070a5 <vector161>:
.globl vector161
vector161:
  pushl $0
801070a5:	6a 00                	push   $0x0
  pushl $161
801070a7:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801070ac:	e9 13 f3 ff ff       	jmp    801063c4 <alltraps>

801070b1 <vector162>:
.globl vector162
vector162:
  pushl $0
801070b1:	6a 00                	push   $0x0
  pushl $162
801070b3:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801070b8:	e9 07 f3 ff ff       	jmp    801063c4 <alltraps>

801070bd <vector163>:
.globl vector163
vector163:
  pushl $0
801070bd:	6a 00                	push   $0x0
  pushl $163
801070bf:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801070c4:	e9 fb f2 ff ff       	jmp    801063c4 <alltraps>

801070c9 <vector164>:
.globl vector164
vector164:
  pushl $0
801070c9:	6a 00                	push   $0x0
  pushl $164
801070cb:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801070d0:	e9 ef f2 ff ff       	jmp    801063c4 <alltraps>

801070d5 <vector165>:
.globl vector165
vector165:
  pushl $0
801070d5:	6a 00                	push   $0x0
  pushl $165
801070d7:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801070dc:	e9 e3 f2 ff ff       	jmp    801063c4 <alltraps>

801070e1 <vector166>:
.globl vector166
vector166:
  pushl $0
801070e1:	6a 00                	push   $0x0
  pushl $166
801070e3:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801070e8:	e9 d7 f2 ff ff       	jmp    801063c4 <alltraps>

801070ed <vector167>:
.globl vector167
vector167:
  pushl $0
801070ed:	6a 00                	push   $0x0
  pushl $167
801070ef:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801070f4:	e9 cb f2 ff ff       	jmp    801063c4 <alltraps>

801070f9 <vector168>:
.globl vector168
vector168:
  pushl $0
801070f9:	6a 00                	push   $0x0
  pushl $168
801070fb:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107100:	e9 bf f2 ff ff       	jmp    801063c4 <alltraps>

80107105 <vector169>:
.globl vector169
vector169:
  pushl $0
80107105:	6a 00                	push   $0x0
  pushl $169
80107107:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010710c:	e9 b3 f2 ff ff       	jmp    801063c4 <alltraps>

80107111 <vector170>:
.globl vector170
vector170:
  pushl $0
80107111:	6a 00                	push   $0x0
  pushl $170
80107113:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107118:	e9 a7 f2 ff ff       	jmp    801063c4 <alltraps>

8010711d <vector171>:
.globl vector171
vector171:
  pushl $0
8010711d:	6a 00                	push   $0x0
  pushl $171
8010711f:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107124:	e9 9b f2 ff ff       	jmp    801063c4 <alltraps>

80107129 <vector172>:
.globl vector172
vector172:
  pushl $0
80107129:	6a 00                	push   $0x0
  pushl $172
8010712b:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107130:	e9 8f f2 ff ff       	jmp    801063c4 <alltraps>

80107135 <vector173>:
.globl vector173
vector173:
  pushl $0
80107135:	6a 00                	push   $0x0
  pushl $173
80107137:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010713c:	e9 83 f2 ff ff       	jmp    801063c4 <alltraps>

80107141 <vector174>:
.globl vector174
vector174:
  pushl $0
80107141:	6a 00                	push   $0x0
  pushl $174
80107143:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107148:	e9 77 f2 ff ff       	jmp    801063c4 <alltraps>

8010714d <vector175>:
.globl vector175
vector175:
  pushl $0
8010714d:	6a 00                	push   $0x0
  pushl $175
8010714f:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107154:	e9 6b f2 ff ff       	jmp    801063c4 <alltraps>

80107159 <vector176>:
.globl vector176
vector176:
  pushl $0
80107159:	6a 00                	push   $0x0
  pushl $176
8010715b:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107160:	e9 5f f2 ff ff       	jmp    801063c4 <alltraps>

80107165 <vector177>:
.globl vector177
vector177:
  pushl $0
80107165:	6a 00                	push   $0x0
  pushl $177
80107167:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010716c:	e9 53 f2 ff ff       	jmp    801063c4 <alltraps>

80107171 <vector178>:
.globl vector178
vector178:
  pushl $0
80107171:	6a 00                	push   $0x0
  pushl $178
80107173:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107178:	e9 47 f2 ff ff       	jmp    801063c4 <alltraps>

8010717d <vector179>:
.globl vector179
vector179:
  pushl $0
8010717d:	6a 00                	push   $0x0
  pushl $179
8010717f:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107184:	e9 3b f2 ff ff       	jmp    801063c4 <alltraps>

80107189 <vector180>:
.globl vector180
vector180:
  pushl $0
80107189:	6a 00                	push   $0x0
  pushl $180
8010718b:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107190:	e9 2f f2 ff ff       	jmp    801063c4 <alltraps>

80107195 <vector181>:
.globl vector181
vector181:
  pushl $0
80107195:	6a 00                	push   $0x0
  pushl $181
80107197:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010719c:	e9 23 f2 ff ff       	jmp    801063c4 <alltraps>

801071a1 <vector182>:
.globl vector182
vector182:
  pushl $0
801071a1:	6a 00                	push   $0x0
  pushl $182
801071a3:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801071a8:	e9 17 f2 ff ff       	jmp    801063c4 <alltraps>

801071ad <vector183>:
.globl vector183
vector183:
  pushl $0
801071ad:	6a 00                	push   $0x0
  pushl $183
801071af:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801071b4:	e9 0b f2 ff ff       	jmp    801063c4 <alltraps>

801071b9 <vector184>:
.globl vector184
vector184:
  pushl $0
801071b9:	6a 00                	push   $0x0
  pushl $184
801071bb:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801071c0:	e9 ff f1 ff ff       	jmp    801063c4 <alltraps>

801071c5 <vector185>:
.globl vector185
vector185:
  pushl $0
801071c5:	6a 00                	push   $0x0
  pushl $185
801071c7:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801071cc:	e9 f3 f1 ff ff       	jmp    801063c4 <alltraps>

801071d1 <vector186>:
.globl vector186
vector186:
  pushl $0
801071d1:	6a 00                	push   $0x0
  pushl $186
801071d3:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801071d8:	e9 e7 f1 ff ff       	jmp    801063c4 <alltraps>

801071dd <vector187>:
.globl vector187
vector187:
  pushl $0
801071dd:	6a 00                	push   $0x0
  pushl $187
801071df:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801071e4:	e9 db f1 ff ff       	jmp    801063c4 <alltraps>

801071e9 <vector188>:
.globl vector188
vector188:
  pushl $0
801071e9:	6a 00                	push   $0x0
  pushl $188
801071eb:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801071f0:	e9 cf f1 ff ff       	jmp    801063c4 <alltraps>

801071f5 <vector189>:
.globl vector189
vector189:
  pushl $0
801071f5:	6a 00                	push   $0x0
  pushl $189
801071f7:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801071fc:	e9 c3 f1 ff ff       	jmp    801063c4 <alltraps>

80107201 <vector190>:
.globl vector190
vector190:
  pushl $0
80107201:	6a 00                	push   $0x0
  pushl $190
80107203:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107208:	e9 b7 f1 ff ff       	jmp    801063c4 <alltraps>

8010720d <vector191>:
.globl vector191
vector191:
  pushl $0
8010720d:	6a 00                	push   $0x0
  pushl $191
8010720f:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107214:	e9 ab f1 ff ff       	jmp    801063c4 <alltraps>

80107219 <vector192>:
.globl vector192
vector192:
  pushl $0
80107219:	6a 00                	push   $0x0
  pushl $192
8010721b:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107220:	e9 9f f1 ff ff       	jmp    801063c4 <alltraps>

80107225 <vector193>:
.globl vector193
vector193:
  pushl $0
80107225:	6a 00                	push   $0x0
  pushl $193
80107227:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010722c:	e9 93 f1 ff ff       	jmp    801063c4 <alltraps>

80107231 <vector194>:
.globl vector194
vector194:
  pushl $0
80107231:	6a 00                	push   $0x0
  pushl $194
80107233:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107238:	e9 87 f1 ff ff       	jmp    801063c4 <alltraps>

8010723d <vector195>:
.globl vector195
vector195:
  pushl $0
8010723d:	6a 00                	push   $0x0
  pushl $195
8010723f:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107244:	e9 7b f1 ff ff       	jmp    801063c4 <alltraps>

80107249 <vector196>:
.globl vector196
vector196:
  pushl $0
80107249:	6a 00                	push   $0x0
  pushl $196
8010724b:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107250:	e9 6f f1 ff ff       	jmp    801063c4 <alltraps>

80107255 <vector197>:
.globl vector197
vector197:
  pushl $0
80107255:	6a 00                	push   $0x0
  pushl $197
80107257:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010725c:	e9 63 f1 ff ff       	jmp    801063c4 <alltraps>

80107261 <vector198>:
.globl vector198
vector198:
  pushl $0
80107261:	6a 00                	push   $0x0
  pushl $198
80107263:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107268:	e9 57 f1 ff ff       	jmp    801063c4 <alltraps>

8010726d <vector199>:
.globl vector199
vector199:
  pushl $0
8010726d:	6a 00                	push   $0x0
  pushl $199
8010726f:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107274:	e9 4b f1 ff ff       	jmp    801063c4 <alltraps>

80107279 <vector200>:
.globl vector200
vector200:
  pushl $0
80107279:	6a 00                	push   $0x0
  pushl $200
8010727b:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107280:	e9 3f f1 ff ff       	jmp    801063c4 <alltraps>

80107285 <vector201>:
.globl vector201
vector201:
  pushl $0
80107285:	6a 00                	push   $0x0
  pushl $201
80107287:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010728c:	e9 33 f1 ff ff       	jmp    801063c4 <alltraps>

80107291 <vector202>:
.globl vector202
vector202:
  pushl $0
80107291:	6a 00                	push   $0x0
  pushl $202
80107293:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107298:	e9 27 f1 ff ff       	jmp    801063c4 <alltraps>

8010729d <vector203>:
.globl vector203
vector203:
  pushl $0
8010729d:	6a 00                	push   $0x0
  pushl $203
8010729f:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801072a4:	e9 1b f1 ff ff       	jmp    801063c4 <alltraps>

801072a9 <vector204>:
.globl vector204
vector204:
  pushl $0
801072a9:	6a 00                	push   $0x0
  pushl $204
801072ab:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801072b0:	e9 0f f1 ff ff       	jmp    801063c4 <alltraps>

801072b5 <vector205>:
.globl vector205
vector205:
  pushl $0
801072b5:	6a 00                	push   $0x0
  pushl $205
801072b7:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801072bc:	e9 03 f1 ff ff       	jmp    801063c4 <alltraps>

801072c1 <vector206>:
.globl vector206
vector206:
  pushl $0
801072c1:	6a 00                	push   $0x0
  pushl $206
801072c3:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801072c8:	e9 f7 f0 ff ff       	jmp    801063c4 <alltraps>

801072cd <vector207>:
.globl vector207
vector207:
  pushl $0
801072cd:	6a 00                	push   $0x0
  pushl $207
801072cf:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801072d4:	e9 eb f0 ff ff       	jmp    801063c4 <alltraps>

801072d9 <vector208>:
.globl vector208
vector208:
  pushl $0
801072d9:	6a 00                	push   $0x0
  pushl $208
801072db:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801072e0:	e9 df f0 ff ff       	jmp    801063c4 <alltraps>

801072e5 <vector209>:
.globl vector209
vector209:
  pushl $0
801072e5:	6a 00                	push   $0x0
  pushl $209
801072e7:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801072ec:	e9 d3 f0 ff ff       	jmp    801063c4 <alltraps>

801072f1 <vector210>:
.globl vector210
vector210:
  pushl $0
801072f1:	6a 00                	push   $0x0
  pushl $210
801072f3:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801072f8:	e9 c7 f0 ff ff       	jmp    801063c4 <alltraps>

801072fd <vector211>:
.globl vector211
vector211:
  pushl $0
801072fd:	6a 00                	push   $0x0
  pushl $211
801072ff:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107304:	e9 bb f0 ff ff       	jmp    801063c4 <alltraps>

80107309 <vector212>:
.globl vector212
vector212:
  pushl $0
80107309:	6a 00                	push   $0x0
  pushl $212
8010730b:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107310:	e9 af f0 ff ff       	jmp    801063c4 <alltraps>

80107315 <vector213>:
.globl vector213
vector213:
  pushl $0
80107315:	6a 00                	push   $0x0
  pushl $213
80107317:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010731c:	e9 a3 f0 ff ff       	jmp    801063c4 <alltraps>

80107321 <vector214>:
.globl vector214
vector214:
  pushl $0
80107321:	6a 00                	push   $0x0
  pushl $214
80107323:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107328:	e9 97 f0 ff ff       	jmp    801063c4 <alltraps>

8010732d <vector215>:
.globl vector215
vector215:
  pushl $0
8010732d:	6a 00                	push   $0x0
  pushl $215
8010732f:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107334:	e9 8b f0 ff ff       	jmp    801063c4 <alltraps>

80107339 <vector216>:
.globl vector216
vector216:
  pushl $0
80107339:	6a 00                	push   $0x0
  pushl $216
8010733b:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107340:	e9 7f f0 ff ff       	jmp    801063c4 <alltraps>

80107345 <vector217>:
.globl vector217
vector217:
  pushl $0
80107345:	6a 00                	push   $0x0
  pushl $217
80107347:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010734c:	e9 73 f0 ff ff       	jmp    801063c4 <alltraps>

80107351 <vector218>:
.globl vector218
vector218:
  pushl $0
80107351:	6a 00                	push   $0x0
  pushl $218
80107353:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107358:	e9 67 f0 ff ff       	jmp    801063c4 <alltraps>

8010735d <vector219>:
.globl vector219
vector219:
  pushl $0
8010735d:	6a 00                	push   $0x0
  pushl $219
8010735f:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107364:	e9 5b f0 ff ff       	jmp    801063c4 <alltraps>

80107369 <vector220>:
.globl vector220
vector220:
  pushl $0
80107369:	6a 00                	push   $0x0
  pushl $220
8010736b:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107370:	e9 4f f0 ff ff       	jmp    801063c4 <alltraps>

80107375 <vector221>:
.globl vector221
vector221:
  pushl $0
80107375:	6a 00                	push   $0x0
  pushl $221
80107377:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010737c:	e9 43 f0 ff ff       	jmp    801063c4 <alltraps>

80107381 <vector222>:
.globl vector222
vector222:
  pushl $0
80107381:	6a 00                	push   $0x0
  pushl $222
80107383:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107388:	e9 37 f0 ff ff       	jmp    801063c4 <alltraps>

8010738d <vector223>:
.globl vector223
vector223:
  pushl $0
8010738d:	6a 00                	push   $0x0
  pushl $223
8010738f:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107394:	e9 2b f0 ff ff       	jmp    801063c4 <alltraps>

80107399 <vector224>:
.globl vector224
vector224:
  pushl $0
80107399:	6a 00                	push   $0x0
  pushl $224
8010739b:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801073a0:	e9 1f f0 ff ff       	jmp    801063c4 <alltraps>

801073a5 <vector225>:
.globl vector225
vector225:
  pushl $0
801073a5:	6a 00                	push   $0x0
  pushl $225
801073a7:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801073ac:	e9 13 f0 ff ff       	jmp    801063c4 <alltraps>

801073b1 <vector226>:
.globl vector226
vector226:
  pushl $0
801073b1:	6a 00                	push   $0x0
  pushl $226
801073b3:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801073b8:	e9 07 f0 ff ff       	jmp    801063c4 <alltraps>

801073bd <vector227>:
.globl vector227
vector227:
  pushl $0
801073bd:	6a 00                	push   $0x0
  pushl $227
801073bf:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801073c4:	e9 fb ef ff ff       	jmp    801063c4 <alltraps>

801073c9 <vector228>:
.globl vector228
vector228:
  pushl $0
801073c9:	6a 00                	push   $0x0
  pushl $228
801073cb:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801073d0:	e9 ef ef ff ff       	jmp    801063c4 <alltraps>

801073d5 <vector229>:
.globl vector229
vector229:
  pushl $0
801073d5:	6a 00                	push   $0x0
  pushl $229
801073d7:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801073dc:	e9 e3 ef ff ff       	jmp    801063c4 <alltraps>

801073e1 <vector230>:
.globl vector230
vector230:
  pushl $0
801073e1:	6a 00                	push   $0x0
  pushl $230
801073e3:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801073e8:	e9 d7 ef ff ff       	jmp    801063c4 <alltraps>

801073ed <vector231>:
.globl vector231
vector231:
  pushl $0
801073ed:	6a 00                	push   $0x0
  pushl $231
801073ef:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801073f4:	e9 cb ef ff ff       	jmp    801063c4 <alltraps>

801073f9 <vector232>:
.globl vector232
vector232:
  pushl $0
801073f9:	6a 00                	push   $0x0
  pushl $232
801073fb:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107400:	e9 bf ef ff ff       	jmp    801063c4 <alltraps>

80107405 <vector233>:
.globl vector233
vector233:
  pushl $0
80107405:	6a 00                	push   $0x0
  pushl $233
80107407:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010740c:	e9 b3 ef ff ff       	jmp    801063c4 <alltraps>

80107411 <vector234>:
.globl vector234
vector234:
  pushl $0
80107411:	6a 00                	push   $0x0
  pushl $234
80107413:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107418:	e9 a7 ef ff ff       	jmp    801063c4 <alltraps>

8010741d <vector235>:
.globl vector235
vector235:
  pushl $0
8010741d:	6a 00                	push   $0x0
  pushl $235
8010741f:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107424:	e9 9b ef ff ff       	jmp    801063c4 <alltraps>

80107429 <vector236>:
.globl vector236
vector236:
  pushl $0
80107429:	6a 00                	push   $0x0
  pushl $236
8010742b:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107430:	e9 8f ef ff ff       	jmp    801063c4 <alltraps>

80107435 <vector237>:
.globl vector237
vector237:
  pushl $0
80107435:	6a 00                	push   $0x0
  pushl $237
80107437:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010743c:	e9 83 ef ff ff       	jmp    801063c4 <alltraps>

80107441 <vector238>:
.globl vector238
vector238:
  pushl $0
80107441:	6a 00                	push   $0x0
  pushl $238
80107443:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107448:	e9 77 ef ff ff       	jmp    801063c4 <alltraps>

8010744d <vector239>:
.globl vector239
vector239:
  pushl $0
8010744d:	6a 00                	push   $0x0
  pushl $239
8010744f:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107454:	e9 6b ef ff ff       	jmp    801063c4 <alltraps>

80107459 <vector240>:
.globl vector240
vector240:
  pushl $0
80107459:	6a 00                	push   $0x0
  pushl $240
8010745b:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107460:	e9 5f ef ff ff       	jmp    801063c4 <alltraps>

80107465 <vector241>:
.globl vector241
vector241:
  pushl $0
80107465:	6a 00                	push   $0x0
  pushl $241
80107467:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010746c:	e9 53 ef ff ff       	jmp    801063c4 <alltraps>

80107471 <vector242>:
.globl vector242
vector242:
  pushl $0
80107471:	6a 00                	push   $0x0
  pushl $242
80107473:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107478:	e9 47 ef ff ff       	jmp    801063c4 <alltraps>

8010747d <vector243>:
.globl vector243
vector243:
  pushl $0
8010747d:	6a 00                	push   $0x0
  pushl $243
8010747f:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107484:	e9 3b ef ff ff       	jmp    801063c4 <alltraps>

80107489 <vector244>:
.globl vector244
vector244:
  pushl $0
80107489:	6a 00                	push   $0x0
  pushl $244
8010748b:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107490:	e9 2f ef ff ff       	jmp    801063c4 <alltraps>

80107495 <vector245>:
.globl vector245
vector245:
  pushl $0
80107495:	6a 00                	push   $0x0
  pushl $245
80107497:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010749c:	e9 23 ef ff ff       	jmp    801063c4 <alltraps>

801074a1 <vector246>:
.globl vector246
vector246:
  pushl $0
801074a1:	6a 00                	push   $0x0
  pushl $246
801074a3:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801074a8:	e9 17 ef ff ff       	jmp    801063c4 <alltraps>

801074ad <vector247>:
.globl vector247
vector247:
  pushl $0
801074ad:	6a 00                	push   $0x0
  pushl $247
801074af:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801074b4:	e9 0b ef ff ff       	jmp    801063c4 <alltraps>

801074b9 <vector248>:
.globl vector248
vector248:
  pushl $0
801074b9:	6a 00                	push   $0x0
  pushl $248
801074bb:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801074c0:	e9 ff ee ff ff       	jmp    801063c4 <alltraps>

801074c5 <vector249>:
.globl vector249
vector249:
  pushl $0
801074c5:	6a 00                	push   $0x0
  pushl $249
801074c7:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801074cc:	e9 f3 ee ff ff       	jmp    801063c4 <alltraps>

801074d1 <vector250>:
.globl vector250
vector250:
  pushl $0
801074d1:	6a 00                	push   $0x0
  pushl $250
801074d3:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801074d8:	e9 e7 ee ff ff       	jmp    801063c4 <alltraps>

801074dd <vector251>:
.globl vector251
vector251:
  pushl $0
801074dd:	6a 00                	push   $0x0
  pushl $251
801074df:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801074e4:	e9 db ee ff ff       	jmp    801063c4 <alltraps>

801074e9 <vector252>:
.globl vector252
vector252:
  pushl $0
801074e9:	6a 00                	push   $0x0
  pushl $252
801074eb:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801074f0:	e9 cf ee ff ff       	jmp    801063c4 <alltraps>

801074f5 <vector253>:
.globl vector253
vector253:
  pushl $0
801074f5:	6a 00                	push   $0x0
  pushl $253
801074f7:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801074fc:	e9 c3 ee ff ff       	jmp    801063c4 <alltraps>

80107501 <vector254>:
.globl vector254
vector254:
  pushl $0
80107501:	6a 00                	push   $0x0
  pushl $254
80107503:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107508:	e9 b7 ee ff ff       	jmp    801063c4 <alltraps>

8010750d <vector255>:
.globl vector255
vector255:
  pushl $0
8010750d:	6a 00                	push   $0x0
  pushl $255
8010750f:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107514:	e9 ab ee ff ff       	jmp    801063c4 <alltraps>

80107519 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107519:	55                   	push   %ebp
8010751a:	89 e5                	mov    %esp,%ebp
8010751c:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010751f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107522:	83 e8 01             	sub    $0x1,%eax
80107525:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107529:	8b 45 08             	mov    0x8(%ebp),%eax
8010752c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107530:	8b 45 08             	mov    0x8(%ebp),%eax
80107533:	c1 e8 10             	shr    $0x10,%eax
80107536:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010753a:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010753d:	0f 01 10             	lgdtl  (%eax)
}
80107540:	c9                   	leave  
80107541:	c3                   	ret    

80107542 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107542:	55                   	push   %ebp
80107543:	89 e5                	mov    %esp,%ebp
80107545:	83 ec 04             	sub    $0x4,%esp
80107548:	8b 45 08             	mov    0x8(%ebp),%eax
8010754b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010754f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107553:	0f 00 d8             	ltr    %ax
}
80107556:	c9                   	leave  
80107557:	c3                   	ret    

80107558 <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
80107558:	55                   	push   %ebp
80107559:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010755b:	8b 45 08             	mov    0x8(%ebp),%eax
8010755e:	0f 22 d8             	mov    %eax,%cr3
}
80107561:	5d                   	pop    %ebp
80107562:	c3                   	ret    

80107563 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107563:	55                   	push   %ebp
80107564:	89 e5                	mov    %esp,%ebp
80107566:	83 ec 28             	sub    $0x28,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107569:	e8 4d cb ff ff       	call   801040bb <cpuid>
8010756e:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107574:	05 00 38 11 80       	add    $0x80113800,%eax
80107579:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010757c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010757f:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107585:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107588:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010758e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107591:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107595:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107598:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010759c:	83 e2 f0             	and    $0xfffffff0,%edx
8010759f:	83 ca 0a             	or     $0xa,%edx
801075a2:	88 50 7d             	mov    %dl,0x7d(%eax)
801075a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801075ac:	83 ca 10             	or     $0x10,%edx
801075af:	88 50 7d             	mov    %dl,0x7d(%eax)
801075b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b5:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801075b9:	83 e2 9f             	and    $0xffffff9f,%edx
801075bc:	88 50 7d             	mov    %dl,0x7d(%eax)
801075bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c2:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801075c6:	83 ca 80             	or     $0xffffff80,%edx
801075c9:	88 50 7d             	mov    %dl,0x7d(%eax)
801075cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075cf:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075d3:	83 ca 0f             	or     $0xf,%edx
801075d6:	88 50 7e             	mov    %dl,0x7e(%eax)
801075d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075dc:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075e0:	83 e2 ef             	and    $0xffffffef,%edx
801075e3:	88 50 7e             	mov    %dl,0x7e(%eax)
801075e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e9:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075ed:	83 e2 df             	and    $0xffffffdf,%edx
801075f0:	88 50 7e             	mov    %dl,0x7e(%eax)
801075f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f6:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075fa:	83 ca 40             	or     $0x40,%edx
801075fd:	88 50 7e             	mov    %dl,0x7e(%eax)
80107600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107603:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107607:	83 ca 80             	or     $0xffffff80,%edx
8010760a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010760d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107610:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107614:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107617:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010761e:	ff ff 
80107620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107623:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010762a:	00 00 
8010762c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010762f:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107636:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107639:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107640:	83 e2 f0             	and    $0xfffffff0,%edx
80107643:	83 ca 02             	or     $0x2,%edx
80107646:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010764c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010764f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107656:	83 ca 10             	or     $0x10,%edx
80107659:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010765f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107662:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107669:	83 e2 9f             	and    $0xffffff9f,%edx
8010766c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107675:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010767c:	83 ca 80             	or     $0xffffff80,%edx
8010767f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107685:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107688:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010768f:	83 ca 0f             	or     $0xf,%edx
80107692:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107698:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010769b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076a2:	83 e2 ef             	and    $0xffffffef,%edx
801076a5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ae:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076b5:	83 e2 df             	and    $0xffffffdf,%edx
801076b8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c1:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076c8:	83 ca 40             	or     $0x40,%edx
801076cb:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076d4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076db:	83 ca 80             	or     $0xffffff80,%edx
801076de:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e7:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801076ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f1:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801076f8:	ff ff 
801076fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076fd:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107704:	00 00 
80107706:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107709:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107710:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107713:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010771a:	83 e2 f0             	and    $0xfffffff0,%edx
8010771d:	83 ca 0a             	or     $0xa,%edx
80107720:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107726:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107729:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107730:	83 ca 10             	or     $0x10,%edx
80107733:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107739:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010773c:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107743:	83 ca 60             	or     $0x60,%edx
80107746:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010774c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010774f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107756:	83 ca 80             	or     $0xffffff80,%edx
80107759:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010775f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107762:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107769:	83 ca 0f             	or     $0xf,%edx
8010776c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107775:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010777c:	83 e2 ef             	and    $0xffffffef,%edx
8010777f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107785:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107788:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010778f:	83 e2 df             	and    $0xffffffdf,%edx
80107792:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107798:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010779b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801077a2:	83 ca 40             	or     $0x40,%edx
801077a5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801077ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ae:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801077b5:	83 ca 80             	or     $0xffffff80,%edx
801077b8:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801077be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c1:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801077c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077cb:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801077d2:	ff ff 
801077d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d7:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801077de:	00 00 
801077e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e3:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801077ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ed:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801077f4:	83 e2 f0             	and    $0xfffffff0,%edx
801077f7:	83 ca 02             	or     $0x2,%edx
801077fa:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107803:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010780a:	83 ca 10             	or     $0x10,%edx
8010780d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107813:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107816:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010781d:	83 ca 60             	or     $0x60,%edx
80107820:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107826:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107829:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107830:	83 ca 80             	or     $0xffffff80,%edx
80107833:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010783c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107843:	83 ca 0f             	or     $0xf,%edx
80107846:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010784c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010784f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107856:	83 e2 ef             	and    $0xffffffef,%edx
80107859:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010785f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107862:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107869:	83 e2 df             	and    $0xffffffdf,%edx
8010786c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107872:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107875:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010787c:	83 ca 40             	or     $0x40,%edx
8010787f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107885:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107888:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010788f:	83 ca 80             	or     $0xffffff80,%edx
80107892:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107898:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010789b:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801078a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a5:	83 c0 70             	add    $0x70,%eax
801078a8:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
801078af:	00 
801078b0:	89 04 24             	mov    %eax,(%esp)
801078b3:	e8 61 fc ff ff       	call   80107519 <lgdt>
}
801078b8:	c9                   	leave  
801078b9:	c3                   	ret    

801078ba <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801078ba:	55                   	push   %ebp
801078bb:	89 e5                	mov    %esp,%ebp
801078bd:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801078c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801078c3:	c1 e8 16             	shr    $0x16,%eax
801078c6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801078cd:	8b 45 08             	mov    0x8(%ebp),%eax
801078d0:	01 d0                	add    %edx,%eax
801078d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801078d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078d8:	8b 00                	mov    (%eax),%eax
801078da:	83 e0 01             	and    $0x1,%eax
801078dd:	85 c0                	test   %eax,%eax
801078df:	74 14                	je     801078f5 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801078e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078e4:	8b 00                	mov    (%eax),%eax
801078e6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078eb:	05 00 00 00 80       	add    $0x80000000,%eax
801078f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801078f3:	eb 48                	jmp    8010793d <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801078f5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801078f9:	74 0e                	je     80107909 <walkpgdir+0x4f>
801078fb:	e8 95 b2 ff ff       	call   80102b95 <kalloc>
80107900:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107903:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107907:	75 07                	jne    80107910 <walkpgdir+0x56>
      return 0;
80107909:	b8 00 00 00 00       	mov    $0x0,%eax
8010790e:	eb 44                	jmp    80107954 <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107910:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107917:	00 
80107918:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010791f:	00 
80107920:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107923:	89 04 24             	mov    %eax,(%esp)
80107926:	e8 ac d6 ff ff       	call   80104fd7 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010792b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010792e:	05 00 00 00 80       	add    $0x80000000,%eax
80107933:	83 c8 07             	or     $0x7,%eax
80107936:	89 c2                	mov    %eax,%edx
80107938:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010793b:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010793d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107940:	c1 e8 0c             	shr    $0xc,%eax
80107943:	25 ff 03 00 00       	and    $0x3ff,%eax
80107948:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010794f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107952:	01 d0                	add    %edx,%eax
}
80107954:	c9                   	leave  
80107955:	c3                   	ret    

80107956 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107956:	55                   	push   %ebp
80107957:	89 e5                	mov    %esp,%ebp
80107959:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010795c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010795f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107964:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107967:	8b 55 0c             	mov    0xc(%ebp),%edx
8010796a:	8b 45 10             	mov    0x10(%ebp),%eax
8010796d:	01 d0                	add    %edx,%eax
8010796f:	83 e8 01             	sub    $0x1,%eax
80107972:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107977:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010797a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107981:	00 
80107982:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107985:	89 44 24 04          	mov    %eax,0x4(%esp)
80107989:	8b 45 08             	mov    0x8(%ebp),%eax
8010798c:	89 04 24             	mov    %eax,(%esp)
8010798f:	e8 26 ff ff ff       	call   801078ba <walkpgdir>
80107994:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107997:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010799b:	75 07                	jne    801079a4 <mappages+0x4e>
      return -1;
8010799d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801079a2:	eb 48                	jmp    801079ec <mappages+0x96>
    if(*pte & PTE_P)
801079a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801079a7:	8b 00                	mov    (%eax),%eax
801079a9:	83 e0 01             	and    $0x1,%eax
801079ac:	85 c0                	test   %eax,%eax
801079ae:	74 0c                	je     801079bc <mappages+0x66>
      panic("remap");
801079b0:	c7 04 24 94 8b 10 80 	movl   $0x80108b94,(%esp)
801079b7:	e8 a6 8b ff ff       	call   80100562 <panic>
    *pte = pa | perm | PTE_P;
801079bc:	8b 45 18             	mov    0x18(%ebp),%eax
801079bf:	0b 45 14             	or     0x14(%ebp),%eax
801079c2:	83 c8 01             	or     $0x1,%eax
801079c5:	89 c2                	mov    %eax,%edx
801079c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801079ca:	89 10                	mov    %edx,(%eax)
    if(a == last)
801079cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079cf:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801079d2:	75 08                	jne    801079dc <mappages+0x86>
      break;
801079d4:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801079d5:	b8 00 00 00 00       	mov    $0x0,%eax
801079da:	eb 10                	jmp    801079ec <mappages+0x96>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
801079dc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801079e3:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801079ea:	eb 8e                	jmp    8010797a <mappages+0x24>
  return 0;
}
801079ec:	c9                   	leave  
801079ed:	c3                   	ret    

801079ee <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801079ee:	55                   	push   %ebp
801079ef:	89 e5                	mov    %esp,%ebp
801079f1:	53                   	push   %ebx
801079f2:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801079f5:	e8 9b b1 ff ff       	call   80102b95 <kalloc>
801079fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
801079fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107a01:	75 0a                	jne    80107a0d <setupkvm+0x1f>
    return 0;
80107a03:	b8 00 00 00 00       	mov    $0x0,%eax
80107a08:	e9 84 00 00 00       	jmp    80107a91 <setupkvm+0xa3>
  memset(pgdir, 0, PGSIZE);
80107a0d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107a14:	00 
80107a15:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107a1c:	00 
80107a1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a20:	89 04 24             	mov    %eax,(%esp)
80107a23:	e8 af d5 ff ff       	call   80104fd7 <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107a28:	c7 45 f4 80 b4 10 80 	movl   $0x8010b480,-0xc(%ebp)
80107a2f:	eb 54                	jmp    80107a85 <setupkvm+0x97>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a34:	8b 48 0c             	mov    0xc(%eax),%ecx
80107a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a3a:	8b 50 04             	mov    0x4(%eax),%edx
80107a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a40:	8b 58 08             	mov    0x8(%eax),%ebx
80107a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a46:	8b 40 04             	mov    0x4(%eax),%eax
80107a49:	29 c3                	sub    %eax,%ebx
80107a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4e:	8b 00                	mov    (%eax),%eax
80107a50:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107a54:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107a58:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107a5c:	89 44 24 04          	mov    %eax,0x4(%esp)
80107a60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a63:	89 04 24             	mov    %eax,(%esp)
80107a66:	e8 eb fe ff ff       	call   80107956 <mappages>
80107a6b:	85 c0                	test   %eax,%eax
80107a6d:	79 12                	jns    80107a81 <setupkvm+0x93>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
80107a6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a72:	89 04 24             	mov    %eax,(%esp)
80107a75:	e8 26 05 00 00       	call   80107fa0 <freevm>
      return 0;
80107a7a:	b8 00 00 00 00       	mov    $0x0,%eax
80107a7f:	eb 10                	jmp    80107a91 <setupkvm+0xa3>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107a81:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107a85:	81 7d f4 c0 b4 10 80 	cmpl   $0x8010b4c0,-0xc(%ebp)
80107a8c:	72 a3                	jb     80107a31 <setupkvm+0x43>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
80107a8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107a91:	83 c4 34             	add    $0x34,%esp
80107a94:	5b                   	pop    %ebx
80107a95:	5d                   	pop    %ebp
80107a96:	c3                   	ret    

80107a97 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107a97:	55                   	push   %ebp
80107a98:	89 e5                	mov    %esp,%ebp
80107a9a:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107a9d:	e8 4c ff ff ff       	call   801079ee <setupkvm>
80107aa2:	a3 24 66 11 80       	mov    %eax,0x80116624
  switchkvm();
80107aa7:	e8 02 00 00 00       	call   80107aae <switchkvm>
}
80107aac:	c9                   	leave  
80107aad:	c3                   	ret    

80107aae <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107aae:	55                   	push   %ebp
80107aaf:	89 e5                	mov    %esp,%ebp
80107ab1:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107ab4:	a1 24 66 11 80       	mov    0x80116624,%eax
80107ab9:	05 00 00 00 80       	add    $0x80000000,%eax
80107abe:	89 04 24             	mov    %eax,(%esp)
80107ac1:	e8 92 fa ff ff       	call   80107558 <lcr3>
}
80107ac6:	c9                   	leave  
80107ac7:	c3                   	ret    

80107ac8 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107ac8:	55                   	push   %ebp
80107ac9:	89 e5                	mov    %esp,%ebp
80107acb:	57                   	push   %edi
80107acc:	56                   	push   %esi
80107acd:	53                   	push   %ebx
80107ace:	83 ec 1c             	sub    $0x1c,%esp
  if(p == 0)
80107ad1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107ad5:	75 0c                	jne    80107ae3 <switchuvm+0x1b>
    panic("switchuvm: no process");
80107ad7:	c7 04 24 9a 8b 10 80 	movl   $0x80108b9a,(%esp)
80107ade:	e8 7f 8a ff ff       	call   80100562 <panic>
  if(p->kstack == 0)
80107ae3:	8b 45 08             	mov    0x8(%ebp),%eax
80107ae6:	8b 40 0c             	mov    0xc(%eax),%eax
80107ae9:	85 c0                	test   %eax,%eax
80107aeb:	75 0c                	jne    80107af9 <switchuvm+0x31>
    panic("switchuvm: no kstack");
80107aed:	c7 04 24 b0 8b 10 80 	movl   $0x80108bb0,(%esp)
80107af4:	e8 69 8a ff ff       	call   80100562 <panic>
  if(p->pgdir == 0)
80107af9:	8b 45 08             	mov    0x8(%ebp),%eax
80107afc:	8b 40 08             	mov    0x8(%eax),%eax
80107aff:	85 c0                	test   %eax,%eax
80107b01:	75 0c                	jne    80107b0f <switchuvm+0x47>
    panic("switchuvm: no pgdir");
80107b03:	c7 04 24 c5 8b 10 80 	movl   $0x80108bc5,(%esp)
80107b0a:	e8 53 8a ff ff       	call   80100562 <panic>

  pushcli();
80107b0f:	e8 be d3 ff ff       	call   80104ed2 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107b14:	e8 c3 c5 ff ff       	call   801040dc <mycpu>
80107b19:	89 c3                	mov    %eax,%ebx
80107b1b:	e8 bc c5 ff ff       	call   801040dc <mycpu>
80107b20:	83 c0 08             	add    $0x8,%eax
80107b23:	89 c7                	mov    %eax,%edi
80107b25:	e8 b2 c5 ff ff       	call   801040dc <mycpu>
80107b2a:	83 c0 08             	add    $0x8,%eax
80107b2d:	c1 e8 10             	shr    $0x10,%eax
80107b30:	89 c6                	mov    %eax,%esi
80107b32:	e8 a5 c5 ff ff       	call   801040dc <mycpu>
80107b37:	83 c0 08             	add    $0x8,%eax
80107b3a:	c1 e8 18             	shr    $0x18,%eax
80107b3d:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107b44:	67 00 
80107b46:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80107b4d:	89 f1                	mov    %esi,%ecx
80107b4f:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80107b55:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80107b5c:	83 e2 f0             	and    $0xfffffff0,%edx
80107b5f:	83 ca 09             	or     $0x9,%edx
80107b62:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107b68:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80107b6f:	83 ca 10             	or     $0x10,%edx
80107b72:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107b78:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80107b7f:	83 e2 9f             	and    $0xffffff9f,%edx
80107b82:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107b88:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80107b8f:	83 ca 80             	or     $0xffffff80,%edx
80107b92:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107b98:	0f b6 93 9e 00 00 00 	movzbl 0x9e(%ebx),%edx
80107b9f:	83 e2 f0             	and    $0xfffffff0,%edx
80107ba2:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107ba8:	0f b6 93 9e 00 00 00 	movzbl 0x9e(%ebx),%edx
80107baf:	83 e2 ef             	and    $0xffffffef,%edx
80107bb2:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107bb8:	0f b6 93 9e 00 00 00 	movzbl 0x9e(%ebx),%edx
80107bbf:	83 e2 df             	and    $0xffffffdf,%edx
80107bc2:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107bc8:	0f b6 93 9e 00 00 00 	movzbl 0x9e(%ebx),%edx
80107bcf:	83 ca 40             	or     $0x40,%edx
80107bd2:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107bd8:	0f b6 93 9e 00 00 00 	movzbl 0x9e(%ebx),%edx
80107bdf:	83 e2 7f             	and    $0x7f,%edx
80107be2:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107be8:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107bee:	e8 e9 c4 ff ff       	call   801040dc <mycpu>
80107bf3:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107bfa:	83 e2 ef             	and    $0xffffffef,%edx
80107bfd:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107c03:	e8 d4 c4 ff ff       	call   801040dc <mycpu>
80107c08:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107c0e:	e8 c9 c4 ff ff       	call   801040dc <mycpu>
80107c13:	8b 55 08             	mov    0x8(%ebp),%edx
80107c16:	8b 52 0c             	mov    0xc(%edx),%edx
80107c19:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107c1f:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107c22:	e8 b5 c4 ff ff       	call   801040dc <mycpu>
80107c27:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107c2d:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
80107c34:	e8 09 f9 ff ff       	call   80107542 <ltr>
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107c39:	8b 45 08             	mov    0x8(%ebp),%eax
80107c3c:	8b 40 08             	mov    0x8(%eax),%eax
80107c3f:	05 00 00 00 80       	add    $0x80000000,%eax
80107c44:	89 04 24             	mov    %eax,(%esp)
80107c47:	e8 0c f9 ff ff       	call   80107558 <lcr3>
  popcli();
80107c4c:	e8 cd d2 ff ff       	call   80104f1e <popcli>
}
80107c51:	83 c4 1c             	add    $0x1c,%esp
80107c54:	5b                   	pop    %ebx
80107c55:	5e                   	pop    %esi
80107c56:	5f                   	pop    %edi
80107c57:	5d                   	pop    %ebp
80107c58:	c3                   	ret    

80107c59 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107c59:	55                   	push   %ebp
80107c5a:	89 e5                	mov    %esp,%ebp
80107c5c:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
80107c5f:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107c66:	76 0c                	jbe    80107c74 <inituvm+0x1b>
    panic("inituvm: more than a page");
80107c68:	c7 04 24 d9 8b 10 80 	movl   $0x80108bd9,(%esp)
80107c6f:	e8 ee 88 ff ff       	call   80100562 <panic>
  mem = kalloc();
80107c74:	e8 1c af ff ff       	call   80102b95 <kalloc>
80107c79:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107c7c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107c83:	00 
80107c84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107c8b:	00 
80107c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8f:	89 04 24             	mov    %eax,(%esp)
80107c92:	e8 40 d3 ff ff       	call   80104fd7 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9a:	05 00 00 00 80       	add    $0x80000000,%eax
80107c9f:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107ca6:	00 
80107ca7:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107cab:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107cb2:	00 
80107cb3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107cba:	00 
80107cbb:	8b 45 08             	mov    0x8(%ebp),%eax
80107cbe:	89 04 24             	mov    %eax,(%esp)
80107cc1:	e8 90 fc ff ff       	call   80107956 <mappages>
  memmove(mem, init, sz);
80107cc6:	8b 45 10             	mov    0x10(%ebp),%eax
80107cc9:	89 44 24 08          	mov    %eax,0x8(%esp)
80107ccd:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cd0:	89 44 24 04          	mov    %eax,0x4(%esp)
80107cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd7:	89 04 24             	mov    %eax,(%esp)
80107cda:	e8 c7 d3 ff ff       	call   801050a6 <memmove>
}
80107cdf:	c9                   	leave  
80107ce0:	c3                   	ret    

80107ce1 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107ce1:	55                   	push   %ebp
80107ce2:	89 e5                	mov    %esp,%ebp
80107ce4:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107ce7:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cea:	25 ff 0f 00 00       	and    $0xfff,%eax
80107cef:	85 c0                	test   %eax,%eax
80107cf1:	74 0c                	je     80107cff <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
80107cf3:	c7 04 24 f4 8b 10 80 	movl   $0x80108bf4,(%esp)
80107cfa:	e8 63 88 ff ff       	call   80100562 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107cff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107d06:	e9 a6 00 00 00       	jmp    80107db1 <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0e:	8b 55 0c             	mov    0xc(%ebp),%edx
80107d11:	01 d0                	add    %edx,%eax
80107d13:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107d1a:	00 
80107d1b:	89 44 24 04          	mov    %eax,0x4(%esp)
80107d1f:	8b 45 08             	mov    0x8(%ebp),%eax
80107d22:	89 04 24             	mov    %eax,(%esp)
80107d25:	e8 90 fb ff ff       	call   801078ba <walkpgdir>
80107d2a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107d2d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d31:	75 0c                	jne    80107d3f <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80107d33:	c7 04 24 17 8c 10 80 	movl   $0x80108c17,(%esp)
80107d3a:	e8 23 88 ff ff       	call   80100562 <panic>
    pa = PTE_ADDR(*pte);
80107d3f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d42:	8b 00                	mov    (%eax),%eax
80107d44:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d49:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4f:	8b 55 18             	mov    0x18(%ebp),%edx
80107d52:	29 c2                	sub    %eax,%edx
80107d54:	89 d0                	mov    %edx,%eax
80107d56:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107d5b:	77 0f                	ja     80107d6c <loaduvm+0x8b>
      n = sz - i;
80107d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d60:	8b 55 18             	mov    0x18(%ebp),%edx
80107d63:	29 c2                	sub    %eax,%edx
80107d65:	89 d0                	mov    %edx,%eax
80107d67:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107d6a:	eb 07                	jmp    80107d73 <loaduvm+0x92>
    else
      n = PGSIZE;
80107d6c:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d76:	8b 55 14             	mov    0x14(%ebp),%edx
80107d79:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80107d7c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107d7f:	05 00 00 00 80       	add    $0x80000000,%eax
80107d84:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107d87:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107d8b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80107d8f:	89 44 24 04          	mov    %eax,0x4(%esp)
80107d93:	8b 45 10             	mov    0x10(%ebp),%eax
80107d96:	89 04 24             	mov    %eax,(%esp)
80107d99:	e8 48 a0 ff ff       	call   80101de6 <readi>
80107d9e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107da1:	74 07                	je     80107daa <loaduvm+0xc9>
      return -1;
80107da3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107da8:	eb 18                	jmp    80107dc2 <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80107daa:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107db1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db4:	3b 45 18             	cmp    0x18(%ebp),%eax
80107db7:	0f 82 4e ff ff ff    	jb     80107d0b <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80107dbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107dc2:	c9                   	leave  
80107dc3:	c3                   	ret    

80107dc4 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107dc4:	55                   	push   %ebp
80107dc5:	89 e5                	mov    %esp,%ebp
80107dc7:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107dca:	8b 45 10             	mov    0x10(%ebp),%eax
80107dcd:	85 c0                	test   %eax,%eax
80107dcf:	79 0a                	jns    80107ddb <allocuvm+0x17>
    return 0;
80107dd1:	b8 00 00 00 00       	mov    $0x0,%eax
80107dd6:	e9 fd 00 00 00       	jmp    80107ed8 <allocuvm+0x114>
  if(newsz < oldsz)
80107ddb:	8b 45 10             	mov    0x10(%ebp),%eax
80107dde:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107de1:	73 08                	jae    80107deb <allocuvm+0x27>
    return oldsz;
80107de3:	8b 45 0c             	mov    0xc(%ebp),%eax
80107de6:	e9 ed 00 00 00       	jmp    80107ed8 <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
80107deb:	8b 45 0c             	mov    0xc(%ebp),%eax
80107dee:	05 ff 0f 00 00       	add    $0xfff,%eax
80107df3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107df8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107dfb:	e9 c9 00 00 00       	jmp    80107ec9 <allocuvm+0x105>
    mem = kalloc();
80107e00:	e8 90 ad ff ff       	call   80102b95 <kalloc>
80107e05:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107e08:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e0c:	75 2f                	jne    80107e3d <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
80107e0e:	c7 04 24 35 8c 10 80 	movl   $0x80108c35,(%esp)
80107e15:	e8 ae 85 ff ff       	call   801003c8 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80107e1a:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e1d:	89 44 24 08          	mov    %eax,0x8(%esp)
80107e21:	8b 45 10             	mov    0x10(%ebp),%eax
80107e24:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e28:	8b 45 08             	mov    0x8(%ebp),%eax
80107e2b:	89 04 24             	mov    %eax,(%esp)
80107e2e:	e8 a7 00 00 00       	call   80107eda <deallocuvm>
      return 0;
80107e33:	b8 00 00 00 00       	mov    $0x0,%eax
80107e38:	e9 9b 00 00 00       	jmp    80107ed8 <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
80107e3d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107e44:	00 
80107e45:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107e4c:	00 
80107e4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e50:	89 04 24             	mov    %eax,(%esp)
80107e53:	e8 7f d1 ff ff       	call   80104fd7 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107e58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e5b:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e64:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107e6b:	00 
80107e6c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107e70:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107e77:	00 
80107e78:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e7c:	8b 45 08             	mov    0x8(%ebp),%eax
80107e7f:	89 04 24             	mov    %eax,(%esp)
80107e82:	e8 cf fa ff ff       	call   80107956 <mappages>
80107e87:	85 c0                	test   %eax,%eax
80107e89:	79 37                	jns    80107ec2 <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
80107e8b:	c7 04 24 4d 8c 10 80 	movl   $0x80108c4d,(%esp)
80107e92:	e8 31 85 ff ff       	call   801003c8 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80107e97:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e9a:	89 44 24 08          	mov    %eax,0x8(%esp)
80107e9e:	8b 45 10             	mov    0x10(%ebp),%eax
80107ea1:	89 44 24 04          	mov    %eax,0x4(%esp)
80107ea5:	8b 45 08             	mov    0x8(%ebp),%eax
80107ea8:	89 04 24             	mov    %eax,(%esp)
80107eab:	e8 2a 00 00 00       	call   80107eda <deallocuvm>
      kfree(mem);
80107eb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107eb3:	89 04 24             	mov    %eax,(%esp)
80107eb6:	e8 44 ac ff ff       	call   80102aff <kfree>
      return 0;
80107ebb:	b8 00 00 00 00       	mov    $0x0,%eax
80107ec0:	eb 16                	jmp    80107ed8 <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80107ec2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ecc:	3b 45 10             	cmp    0x10(%ebp),%eax
80107ecf:	0f 82 2b ff ff ff    	jb     80107e00 <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
80107ed5:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107ed8:	c9                   	leave  
80107ed9:	c3                   	ret    

80107eda <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107eda:	55                   	push   %ebp
80107edb:	89 e5                	mov    %esp,%ebp
80107edd:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107ee0:	8b 45 10             	mov    0x10(%ebp),%eax
80107ee3:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107ee6:	72 08                	jb     80107ef0 <deallocuvm+0x16>
    return oldsz;
80107ee8:	8b 45 0c             	mov    0xc(%ebp),%eax
80107eeb:	e9 ae 00 00 00       	jmp    80107f9e <deallocuvm+0xc4>

  a = PGROUNDUP(newsz);
80107ef0:	8b 45 10             	mov    0x10(%ebp),%eax
80107ef3:	05 ff 0f 00 00       	add    $0xfff,%eax
80107ef8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107efd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107f00:	e9 8a 00 00 00       	jmp    80107f8f <deallocuvm+0xb5>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f08:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107f0f:	00 
80107f10:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f14:	8b 45 08             	mov    0x8(%ebp),%eax
80107f17:	89 04 24             	mov    %eax,(%esp)
80107f1a:	e8 9b f9 ff ff       	call   801078ba <walkpgdir>
80107f1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107f22:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f26:	75 16                	jne    80107f3e <deallocuvm+0x64>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107f28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f2b:	c1 e8 16             	shr    $0x16,%eax
80107f2e:	83 c0 01             	add    $0x1,%eax
80107f31:	c1 e0 16             	shl    $0x16,%eax
80107f34:	2d 00 10 00 00       	sub    $0x1000,%eax
80107f39:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f3c:	eb 4a                	jmp    80107f88 <deallocuvm+0xae>
    else if((*pte & PTE_P) != 0){
80107f3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f41:	8b 00                	mov    (%eax),%eax
80107f43:	83 e0 01             	and    $0x1,%eax
80107f46:	85 c0                	test   %eax,%eax
80107f48:	74 3e                	je     80107f88 <deallocuvm+0xae>
      pa = PTE_ADDR(*pte);
80107f4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f4d:	8b 00                	mov    (%eax),%eax
80107f4f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f54:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107f57:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f5b:	75 0c                	jne    80107f69 <deallocuvm+0x8f>
        panic("kfree");
80107f5d:	c7 04 24 69 8c 10 80 	movl   $0x80108c69,(%esp)
80107f64:	e8 f9 85 ff ff       	call   80100562 <panic>
      char *v = P2V(pa);
80107f69:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f6c:	05 00 00 00 80       	add    $0x80000000,%eax
80107f71:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107f74:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107f77:	89 04 24             	mov    %eax,(%esp)
80107f7a:	e8 80 ab ff ff       	call   80102aff <kfree>
      *pte = 0;
80107f7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f82:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80107f88:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f92:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f95:	0f 82 6a ff ff ff    	jb     80107f05 <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80107f9b:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107f9e:	c9                   	leave  
80107f9f:	c3                   	ret    

80107fa0 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107fa0:	55                   	push   %ebp
80107fa1:	89 e5                	mov    %esp,%ebp
80107fa3:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80107fa6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107faa:	75 0c                	jne    80107fb8 <freevm+0x18>
    panic("freevm: no pgdir");
80107fac:	c7 04 24 6f 8c 10 80 	movl   $0x80108c6f,(%esp)
80107fb3:	e8 aa 85 ff ff       	call   80100562 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107fb8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107fbf:	00 
80107fc0:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80107fc7:	80 
80107fc8:	8b 45 08             	mov    0x8(%ebp),%eax
80107fcb:	89 04 24             	mov    %eax,(%esp)
80107fce:	e8 07 ff ff ff       	call   80107eda <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80107fd3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107fda:	eb 45                	jmp    80108021 <freevm+0x81>
    if(pgdir[i] & PTE_P){
80107fdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fdf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107fe6:	8b 45 08             	mov    0x8(%ebp),%eax
80107fe9:	01 d0                	add    %edx,%eax
80107feb:	8b 00                	mov    (%eax),%eax
80107fed:	83 e0 01             	and    $0x1,%eax
80107ff0:	85 c0                	test   %eax,%eax
80107ff2:	74 29                	je     8010801d <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ffe:	8b 45 08             	mov    0x8(%ebp),%eax
80108001:	01 d0                	add    %edx,%eax
80108003:	8b 00                	mov    (%eax),%eax
80108005:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010800a:	05 00 00 00 80       	add    $0x80000000,%eax
8010800f:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108012:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108015:	89 04 24             	mov    %eax,(%esp)
80108018:	e8 e2 aa ff ff       	call   80102aff <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010801d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108021:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108028:	76 b2                	jbe    80107fdc <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010802a:	8b 45 08             	mov    0x8(%ebp),%eax
8010802d:	89 04 24             	mov    %eax,(%esp)
80108030:	e8 ca aa ff ff       	call   80102aff <kfree>
}
80108035:	c9                   	leave  
80108036:	c3                   	ret    

80108037 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108037:	55                   	push   %ebp
80108038:	89 e5                	mov    %esp,%ebp
8010803a:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010803d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108044:	00 
80108045:	8b 45 0c             	mov    0xc(%ebp),%eax
80108048:	89 44 24 04          	mov    %eax,0x4(%esp)
8010804c:	8b 45 08             	mov    0x8(%ebp),%eax
8010804f:	89 04 24             	mov    %eax,(%esp)
80108052:	e8 63 f8 ff ff       	call   801078ba <walkpgdir>
80108057:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010805a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010805e:	75 0c                	jne    8010806c <clearpteu+0x35>
    panic("clearpteu");
80108060:	c7 04 24 80 8c 10 80 	movl   $0x80108c80,(%esp)
80108067:	e8 f6 84 ff ff       	call   80100562 <panic>
  *pte &= ~PTE_U;
8010806c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010806f:	8b 00                	mov    (%eax),%eax
80108071:	83 e0 fb             	and    $0xfffffffb,%eax
80108074:	89 c2                	mov    %eax,%edx
80108076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108079:	89 10                	mov    %edx,(%eax)
}
8010807b:	c9                   	leave  
8010807c:	c3                   	ret    

8010807d <copyuvm>:
// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
//CS153 -- added
copyuvm(pde_t *pgdir, uint sz, uint sp) //uint sp is STACKTOP
{
8010807d:	55                   	push   %ebp
8010807e:	89 e5                	mov    %esp,%ebp
80108080:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108083:	e8 66 f9 ff ff       	call   801079ee <setupkvm>
80108088:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010808b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010808f:	75 0a                	jne    8010809b <copyuvm+0x1e>
    return 0;
80108091:	b8 00 00 00 00       	mov    $0x0,%eax
80108096:	e9 e6 01 00 00       	jmp    80108281 <copyuvm+0x204>
  for(i = 0; i < sz; i += PGSIZE){
8010809b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801080a2:	e9 d1 00 00 00       	jmp    80108178 <copyuvm+0xfb>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801080a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801080b1:	00 
801080b2:	89 44 24 04          	mov    %eax,0x4(%esp)
801080b6:	8b 45 08             	mov    0x8(%ebp),%eax
801080b9:	89 04 24             	mov    %eax,(%esp)
801080bc:	e8 f9 f7 ff ff       	call   801078ba <walkpgdir>
801080c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
801080c4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801080c8:	75 0c                	jne    801080d6 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
801080ca:	c7 04 24 8a 8c 10 80 	movl   $0x80108c8a,(%esp)
801080d1:	e8 8c 84 ff ff       	call   80100562 <panic>
    if(!(*pte & PTE_P))
801080d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080d9:	8b 00                	mov    (%eax),%eax
801080db:	83 e0 01             	and    $0x1,%eax
801080de:	85 c0                	test   %eax,%eax
801080e0:	75 0c                	jne    801080ee <copyuvm+0x71>
      panic("copyuvm: page not present");
801080e2:	c7 04 24 a4 8c 10 80 	movl   $0x80108ca4,(%esp)
801080e9:	e8 74 84 ff ff       	call   80100562 <panic>
    pa = PTE_ADDR(*pte);
801080ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080f1:	8b 00                	mov    (%eax),%eax
801080f3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080f8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801080fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080fe:	8b 00                	mov    (%eax),%eax
80108100:	25 ff 0f 00 00       	and    $0xfff,%eax
80108105:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108108:	e8 88 aa ff ff       	call   80102b95 <kalloc>
8010810d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108110:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108114:	75 05                	jne    8010811b <copyuvm+0x9e>
      goto bad;
80108116:	e9 56 01 00 00       	jmp    80108271 <copyuvm+0x1f4>
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010811b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010811e:	05 00 00 00 80       	add    $0x80000000,%eax
80108123:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010812a:	00 
8010812b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010812f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108132:	89 04 24             	mov    %eax,(%esp)
80108135:	e8 6c cf ff ff       	call   801050a6 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
8010813a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010813d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108140:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108146:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108149:	89 54 24 10          	mov    %edx,0x10(%esp)
8010814d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80108151:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108158:	00 
80108159:	89 44 24 04          	mov    %eax,0x4(%esp)
8010815d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108160:	89 04 24             	mov    %eax,(%esp)
80108163:	e8 ee f7 ff ff       	call   80107956 <mappages>
80108168:	85 c0                	test   %eax,%eax
8010816a:	79 05                	jns    80108171 <copyuvm+0xf4>
      goto bad;
8010816c:	e9 00 01 00 00       	jmp    80108271 <copyuvm+0x1f4>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108171:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108178:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010817b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010817e:	0f 82 23 ff ff ff    	jb     801080a7 <copyuvm+0x2a>
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  //CS153 -- added 
  for(i = PGROUNDDOWN(sp); i < STACKTOP; i += PGSIZE){
80108184:	8b 45 10             	mov    0x10(%ebp),%eax
80108187:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010818c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010818f:	e9 cb 00 00 00       	jmp    8010825f <copyuvm+0x1e2>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108197:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010819e:	00 
8010819f:	89 44 24 04          	mov    %eax,0x4(%esp)
801081a3:	8b 45 08             	mov    0x8(%ebp),%eax
801081a6:	89 04 24             	mov    %eax,(%esp)
801081a9:	e8 0c f7 ff ff       	call   801078ba <walkpgdir>
801081ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
801081b1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801081b5:	75 0c                	jne    801081c3 <copyuvm+0x146>
      panic("copyuvm: pte should exist");
801081b7:	c7 04 24 8a 8c 10 80 	movl   $0x80108c8a,(%esp)
801081be:	e8 9f 83 ff ff       	call   80100562 <panic>
    if(!(*pte & PTE_P))
801081c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081c6:	8b 00                	mov    (%eax),%eax
801081c8:	83 e0 01             	and    $0x1,%eax
801081cb:	85 c0                	test   %eax,%eax
801081cd:	75 0c                	jne    801081db <copyuvm+0x15e>
      panic("copyuvm: page not present");
801081cf:	c7 04 24 a4 8c 10 80 	movl   $0x80108ca4,(%esp)
801081d6:	e8 87 83 ff ff       	call   80100562 <panic>
    pa = PTE_ADDR(*pte);
801081db:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081de:	8b 00                	mov    (%eax),%eax
801081e0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081e5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801081e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081eb:	8b 00                	mov    (%eax),%eax
801081ed:	25 ff 0f 00 00       	and    $0xfff,%eax
801081f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801081f5:	e8 9b a9 ff ff       	call   80102b95 <kalloc>
801081fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
801081fd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108201:	75 02                	jne    80108205 <copyuvm+0x188>
      goto bad;
80108203:	eb 6c                	jmp    80108271 <copyuvm+0x1f4>
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108205:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108208:	05 00 00 00 80       	add    $0x80000000,%eax
8010820d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108214:	00 
80108215:	89 44 24 04          	mov    %eax,0x4(%esp)
80108219:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010821c:	89 04 24             	mov    %eax,(%esp)
8010821f:	e8 82 ce ff ff       	call   801050a6 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108224:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108227:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010822a:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108230:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108233:	89 54 24 10          	mov    %edx,0x10(%esp)
80108237:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010823b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108242:	00 
80108243:	89 44 24 04          	mov    %eax,0x4(%esp)
80108247:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010824a:	89 04 24             	mov    %eax,(%esp)
8010824d:	e8 04 f7 ff ff       	call   80107956 <mappages>
80108252:	85 c0                	test   %eax,%eax
80108254:	79 02                	jns    80108258 <copyuvm+0x1db>
      goto bad;
80108256:	eb 19                	jmp    80108271 <copyuvm+0x1f4>
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  //CS153 -- added 
  for(i = PGROUNDDOWN(sp); i < STACKTOP; i += PGSIZE){
80108258:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010825f:	81 7d f4 fe ff ff 7f 	cmpl   $0x7ffffffe,-0xc(%ebp)
80108266:	0f 86 28 ff ff ff    	jbe    80108194 <copyuvm+0x117>
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }

  return d;
8010826c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010826f:	eb 10                	jmp    80108281 <copyuvm+0x204>

bad:
  freevm(d);
80108271:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108274:	89 04 24             	mov    %eax,(%esp)
80108277:	e8 24 fd ff ff       	call   80107fa0 <freevm>
  return 0;
8010827c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108281:	c9                   	leave  
80108282:	c3                   	ret    

80108283 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108283:	55                   	push   %ebp
80108284:	89 e5                	mov    %esp,%ebp
80108286:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108289:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108290:	00 
80108291:	8b 45 0c             	mov    0xc(%ebp),%eax
80108294:	89 44 24 04          	mov    %eax,0x4(%esp)
80108298:	8b 45 08             	mov    0x8(%ebp),%eax
8010829b:	89 04 24             	mov    %eax,(%esp)
8010829e:	e8 17 f6 ff ff       	call   801078ba <walkpgdir>
801082a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801082a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082a9:	8b 00                	mov    (%eax),%eax
801082ab:	83 e0 01             	and    $0x1,%eax
801082ae:	85 c0                	test   %eax,%eax
801082b0:	75 07                	jne    801082b9 <uva2ka+0x36>
    return 0;
801082b2:	b8 00 00 00 00       	mov    $0x0,%eax
801082b7:	eb 22                	jmp    801082db <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
801082b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082bc:	8b 00                	mov    (%eax),%eax
801082be:	83 e0 04             	and    $0x4,%eax
801082c1:	85 c0                	test   %eax,%eax
801082c3:	75 07                	jne    801082cc <uva2ka+0x49>
    return 0;
801082c5:	b8 00 00 00 00       	mov    $0x0,%eax
801082ca:	eb 0f                	jmp    801082db <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
801082cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082cf:	8b 00                	mov    (%eax),%eax
801082d1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082d6:	05 00 00 00 80       	add    $0x80000000,%eax
}
801082db:	c9                   	leave  
801082dc:	c3                   	ret    

801082dd <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801082dd:	55                   	push   %ebp
801082de:	89 e5                	mov    %esp,%ebp
801082e0:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801082e3:	8b 45 10             	mov    0x10(%ebp),%eax
801082e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801082e9:	e9 87 00 00 00       	jmp    80108375 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
801082ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801082f1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801082f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082fc:	89 44 24 04          	mov    %eax,0x4(%esp)
80108300:	8b 45 08             	mov    0x8(%ebp),%eax
80108303:	89 04 24             	mov    %eax,(%esp)
80108306:	e8 78 ff ff ff       	call   80108283 <uva2ka>
8010830b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010830e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108312:	75 07                	jne    8010831b <copyout+0x3e>
      return -1;
80108314:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108319:	eb 69                	jmp    80108384 <copyout+0xa7>
    n = PGSIZE - (va - va0);
8010831b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010831e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108321:	29 c2                	sub    %eax,%edx
80108323:	89 d0                	mov    %edx,%eax
80108325:	05 00 10 00 00       	add    $0x1000,%eax
8010832a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010832d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108330:	3b 45 14             	cmp    0x14(%ebp),%eax
80108333:	76 06                	jbe    8010833b <copyout+0x5e>
      n = len;
80108335:	8b 45 14             	mov    0x14(%ebp),%eax
80108338:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010833b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010833e:	8b 55 0c             	mov    0xc(%ebp),%edx
80108341:	29 c2                	sub    %eax,%edx
80108343:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108346:	01 c2                	add    %eax,%edx
80108348:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010834b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010834f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108352:	89 44 24 04          	mov    %eax,0x4(%esp)
80108356:	89 14 24             	mov    %edx,(%esp)
80108359:	e8 48 cd ff ff       	call   801050a6 <memmove>
    len -= n;
8010835e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108361:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108364:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108367:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010836a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010836d:	05 00 10 00 00       	add    $0x1000,%eax
80108372:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108375:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108379:	0f 85 6f ff ff ff    	jne    801082ee <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010837f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108384:	c9                   	leave  
80108385:	c3                   	ret    

80108386 <shminit>:
    char *frame; // a pointer to the physical frame; a pointer to the shared physical page
    int refcnt; // the number of processes sharing the page; if the shared memory region is closed, DO NOT REMOVE the page unless NO OTHER process is sharing it
  } shm_pages[64];
} shm_table;

void shminit() {
80108386:	55                   	push   %ebp
80108387:	89 e5                	mov    %esp,%ebp
80108389:	83 ec 28             	sub    $0x28,%esp
  int i;
  initlock(&(shm_table.lock), "SHM lock");
8010838c:	c7 44 24 04 be 8c 10 	movl   $0x80108cbe,0x4(%esp)
80108393:	80 
80108394:	c7 04 24 40 66 11 80 	movl   $0x80116640,(%esp)
8010839b:	e8 b4 c9 ff ff       	call   80104d54 <initlock>
  acquire(&(shm_table.lock));
801083a0:	c7 04 24 40 66 11 80 	movl   $0x80116640,(%esp)
801083a7:	e8 c9 c9 ff ff       	call   80104d75 <acquire>
  for (i = 0; i< 64; i++) { //64 pages in the shm_table
801083ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083b3:	eb 49                	jmp    801083fe <shminit+0x78>
    shm_table.shm_pages[i].id =0;
801083b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801083b8:	89 d0                	mov    %edx,%eax
801083ba:	01 c0                	add    %eax,%eax
801083bc:	01 d0                	add    %edx,%eax
801083be:	c1 e0 02             	shl    $0x2,%eax
801083c1:	05 74 66 11 80       	add    $0x80116674,%eax
801083c6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    shm_table.shm_pages[i].frame =0;
801083cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801083cf:	89 d0                	mov    %edx,%eax
801083d1:	01 c0                	add    %eax,%eax
801083d3:	01 d0                	add    %edx,%eax
801083d5:	c1 e0 02             	shl    $0x2,%eax
801083d8:	05 78 66 11 80       	add    $0x80116678,%eax
801083dd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    shm_table.shm_pages[i].refcnt =0;
801083e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801083e6:	89 d0                	mov    %edx,%eax
801083e8:	01 c0                	add    %eax,%eax
801083ea:	01 d0                	add    %edx,%eax
801083ec:	c1 e0 02             	shl    $0x2,%eax
801083ef:	05 7c 66 11 80       	add    $0x8011667c,%eax
801083f4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

void shminit() {
  int i;
  initlock(&(shm_table.lock), "SHM lock");
  acquire(&(shm_table.lock));
  for (i = 0; i< 64; i++) { //64 pages in the shm_table
801083fa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801083fe:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80108402:	7e b1                	jle    801083b5 <shminit+0x2f>
    shm_table.shm_pages[i].id =0;
    shm_table.shm_pages[i].frame =0;
    shm_table.shm_pages[i].refcnt =0;
  }
  release(&(shm_table.lock));
80108404:	c7 04 24 40 66 11 80 	movl   $0x80116640,(%esp)
8010840b:	e8 cd c9 ff ff       	call   80104ddd <release>
}
80108410:	c9                   	leave  
80108411:	c3                   	ret    

80108412 <shm_open>:

int shm_open(int id, char **pointer) {
80108412:	55                   	push   %ebp
80108413:	89 e5                	mov    %esp,%ebp
80108415:	83 ec 28             	sub    $0x28,%esp
//CS153 added
//NOTE: Use the embedded spin lock to avoid race conditions.
    // MORE SPECIFICALLY: Use the same acquire and release calls that are in shm_init
    int i;
    acquire(&(shm_table.lock));
80108418:	c7 04 24 40 66 11 80 	movl   $0x80116640,(%esp)
8010841f:	e8 51 c9 ff ff       	call   80104d75 <acquire>
    for (i = 0; i < 64; ++i) {
80108424:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010842b:	eb 52                	jmp    8010847f <shm_open+0x6d>
      if (id == shm_table.shm_pages[i].id) {
8010842d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80108430:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108433:	89 d0                	mov    %edx,%eax
80108435:	01 c0                	add    %eax,%eax
80108437:	01 d0                	add    %edx,%eax
80108439:	c1 e0 02             	shl    $0x2,%eax
8010843c:	05 74 66 11 80       	add    $0x80116674,%eax
80108441:	8b 00                	mov    (%eax),%eax
80108443:	39 c1                	cmp    %eax,%ecx
80108445:	75 34                	jne    8010847b <shm_open+0x69>
        cprintf("%d", shm_table.shm_pages[i]);
80108447:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010844a:	89 d0                	mov    %edx,%eax
8010844c:	01 c0                	add    %eax,%eax
8010844e:	01 d0                	add    %edx,%eax
80108450:	c1 e0 02             	shl    $0x2,%eax
80108453:	05 70 66 11 80       	add    $0x80116670,%eax
80108458:	8b 50 04             	mov    0x4(%eax),%edx
8010845b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010845f:	8b 50 08             	mov    0x8(%eax),%edx
80108462:	89 54 24 08          	mov    %edx,0x8(%esp)
80108466:	8b 40 0c             	mov    0xc(%eax),%eax
80108469:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010846d:	c7 04 24 c7 8c 10 80 	movl   $0x80108cc7,(%esp)
80108474:	e8 4f 7f ff ff       	call   801003c8 <cprintf>
        break;
80108479:	eb 0a                	jmp    80108485 <shm_open+0x73>
//CS153 added
//NOTE: Use the embedded spin lock to avoid race conditions.
    // MORE SPECIFICALLY: Use the same acquire and release calls that are in shm_init
    int i;
    acquire(&(shm_table.lock));
    for (i = 0; i < 64; ++i) {
8010847b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010847f:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80108483:	7e a8                	jle    8010842d <shm_open+0x1b>
      if (id == shm_table.shm_pages[i].id) {
        cprintf("%d", shm_table.shm_pages[i]);
        break;
      }
    }
    release(&(shm_table.lock));
80108485:	c7 04 24 40 66 11 80 	movl   $0x80116640,(%esp)
8010848c:	e8 4c c9 ff ff       	call   80104ddd <release>
//CASE ONE: ANOTHER PROCESS CALLED SHM_OPEN BEFORE "US"
// 1. Find the physical address of the page in the table.
    // uint phys_addr = V2P(shm_table.shm_pages[i].id);
// 2. Map it into an available page in the virtual address space (aka, add it to the page table). (HINT: use mappages)
    uint va = PGROUNDUP(myproc()->sz);
80108491:	e8 bc bc ff ff       	call   80104152 <myproc>
80108496:	8b 40 04             	mov    0x4(%eax),%eax
80108499:	05 ff 0f 00 00       	add    $0xfff,%eax
8010849e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    //TODO: No process in this file's code that can be consulted?
// 3. Increment refcnt and return the pointer to the virtual address with something like:
    //TODO: VERIFY
    *pointer = (char * ) va;
801084a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801084a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801084ac:	89 10                	mov    %edx,(%eax)
    //TODO: sz = shm_table...
    
//CASE TWO: THE SHARED MEMORY SEGMENT DNE (NOT FOUND IN TABLE), AKA, "WE" ARE THE FIRST SHM_OPEN
// 1. Find an empty entry in the shm_table.
// 2. Initialize its id to the id passed in as a parameter.
    acquire(&(shm_table.lock));
801084ae:	c7 04 24 40 66 11 80 	movl   $0x80116640,(%esp)
801084b5:	e8 bb c8 ff ff       	call   80104d75 <acquire>
    for (i = 0; i < 64; ++i) {
801084ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084c1:	eb 31                	jmp    801084f4 <shm_open+0xe2>
        if (shm_table.shm_pages[i].id == 0) {
801084c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084c6:	89 d0                	mov    %edx,%eax
801084c8:	01 c0                	add    %eax,%eax
801084ca:	01 d0                	add    %edx,%eax
801084cc:	c1 e0 02             	shl    $0x2,%eax
801084cf:	05 74 66 11 80       	add    $0x80116674,%eax
801084d4:	8b 00                	mov    (%eax),%eax
801084d6:	85 c0                	test   %eax,%eax
801084d8:	75 16                	jne    801084f0 <shm_open+0xde>
            shm_table.shm_pages[i].id = id;
801084da:	8b 4d 08             	mov    0x8(%ebp),%ecx
801084dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084e0:	89 d0                	mov    %edx,%eax
801084e2:	01 c0                	add    %eax,%eax
801084e4:	01 d0                	add    %edx,%eax
801084e6:	c1 e0 02             	shl    $0x2,%eax
801084e9:	05 74 66 11 80       	add    $0x80116674,%eax
801084ee:	89 08                	mov    %ecx,(%eax)
    
//CASE TWO: THE SHARED MEMORY SEGMENT DNE (NOT FOUND IN TABLE), AKA, "WE" ARE THE FIRST SHM_OPEN
// 1. Find an empty entry in the shm_table.
// 2. Initialize its id to the id passed in as a parameter.
    acquire(&(shm_table.lock));
    for (i = 0; i < 64; ++i) {
801084f0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801084f4:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801084f8:	7e c9                	jle    801084c3 <shm_open+0xb1>
        if (shm_table.shm_pages[i].id == 0) {
            shm_table.shm_pages[i].id = id;
        }
    }
    release(&(shm_table.lock));
801084fa:	c7 04 24 40 66 11 80 	movl   $0x80116640,(%esp)
80108501:	e8 d7 c8 ff ff       	call   80104ddd <release>
    // 6. Map the page to an available virtual address space page ("e.g. sz").

    // 7. Return a pointer through char ** pointer.


    return 0; //added to remove compiler warning -- you should decide what to return
80108506:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010850b:	c9                   	leave  
8010850c:	c3                   	ret    

8010850d <shm_close>:


int shm_close(int id) {
8010850d:	55                   	push   %ebp
8010850e:	89 e5                	mov    %esp,%ebp
    //you write this too!




    return 0; //added to remove compiler warning -- you should decide what to return
80108510:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108515:	5d                   	pop    %ebp
80108516:	c3                   	ret    
