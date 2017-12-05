
_testHelloWorld:     file format elf32-i386


Disassembly of section .text:

00001000 <main>:
int
main() {
    1000:	55                   	push   %ebp
    return 0;
}
    1001:	31 c0                	xor    %eax,%eax
int
main() {
    1003:	89 e5                	mov    %esp,%ebp
    return 0;
}
    1005:	5d                   	pop    %ebp
    1006:	c3                   	ret    
    1007:	66 90                	xchg   %ax,%ax
    1009:	66 90                	xchg   %ax,%ax
    100b:	66 90                	xchg   %ax,%ax
    100d:	66 90                	xchg   %ax,%ax
    100f:	90                   	nop

00001010 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    1010:	55                   	push   %ebp
    1011:	89 e5                	mov    %esp,%ebp
    1013:	8b 45 08             	mov    0x8(%ebp),%eax
    1016:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    1019:	53                   	push   %ebx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    101a:	89 c2                	mov    %eax,%edx
    101c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    1020:	83 c1 01             	add    $0x1,%ecx
    1023:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
    1027:	83 c2 01             	add    $0x1,%edx
    102a:	84 db                	test   %bl,%bl
    102c:	88 5a ff             	mov    %bl,-0x1(%edx)
    102f:	75 ef                	jne    1020 <strcpy+0x10>
    ;
  return os;
}
    1031:	5b                   	pop    %ebx
    1032:	5d                   	pop    %ebp
    1033:	c3                   	ret    
    1034:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    103a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00001040 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    1040:	55                   	push   %ebp
    1041:	89 e5                	mov    %esp,%ebp
    1043:	8b 55 08             	mov    0x8(%ebp),%edx
    1046:	53                   	push   %ebx
    1047:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  while(*p && *p == *q)
    104a:	0f b6 02             	movzbl (%edx),%eax
    104d:	84 c0                	test   %al,%al
    104f:	74 2d                	je     107e <strcmp+0x3e>
    1051:	0f b6 19             	movzbl (%ecx),%ebx
    1054:	38 d8                	cmp    %bl,%al
    1056:	74 0e                	je     1066 <strcmp+0x26>
    1058:	eb 2b                	jmp    1085 <strcmp+0x45>
    105a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    1060:	38 c8                	cmp    %cl,%al
    1062:	75 15                	jne    1079 <strcmp+0x39>
    p++, q++;
    1064:	89 d9                	mov    %ebx,%ecx
    1066:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    1069:	0f b6 02             	movzbl (%edx),%eax
    p++, q++;
    106c:	8d 59 01             	lea    0x1(%ecx),%ebx
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    106f:	0f b6 49 01          	movzbl 0x1(%ecx),%ecx
    1073:	84 c0                	test   %al,%al
    1075:	75 e9                	jne    1060 <strcmp+0x20>
    1077:	31 c0                	xor    %eax,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
    1079:	29 c8                	sub    %ecx,%eax
}
    107b:	5b                   	pop    %ebx
    107c:	5d                   	pop    %ebp
    107d:	c3                   	ret    
    107e:	0f b6 09             	movzbl (%ecx),%ecx
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    1081:	31 c0                	xor    %eax,%eax
    1083:	eb f4                	jmp    1079 <strcmp+0x39>
    1085:	0f b6 cb             	movzbl %bl,%ecx
    1088:	eb ef                	jmp    1079 <strcmp+0x39>
    108a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00001090 <strlen>:
  return (uchar)*p - (uchar)*q;
}

uint
strlen(char *s)
{
    1090:	55                   	push   %ebp
    1091:	89 e5                	mov    %esp,%ebp
    1093:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
    1096:	80 39 00             	cmpb   $0x0,(%ecx)
    1099:	74 12                	je     10ad <strlen+0x1d>
    109b:	31 d2                	xor    %edx,%edx
    109d:	8d 76 00             	lea    0x0(%esi),%esi
    10a0:	83 c2 01             	add    $0x1,%edx
    10a3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
    10a7:	89 d0                	mov    %edx,%eax
    10a9:	75 f5                	jne    10a0 <strlen+0x10>
    ;
  return n;
}
    10ab:	5d                   	pop    %ebp
    10ac:	c3                   	ret    
uint
strlen(char *s)
{
  int n;

  for(n = 0; s[n]; n++)
    10ad:	31 c0                	xor    %eax,%eax
    ;
  return n;
}
    10af:	5d                   	pop    %ebp
    10b0:	c3                   	ret    
    10b1:	eb 0d                	jmp    10c0 <memset>
    10b3:	90                   	nop
    10b4:	90                   	nop
    10b5:	90                   	nop
    10b6:	90                   	nop
    10b7:	90                   	nop
    10b8:	90                   	nop
    10b9:	90                   	nop
    10ba:	90                   	nop
    10bb:	90                   	nop
    10bc:	90                   	nop
    10bd:	90                   	nop
    10be:	90                   	nop
    10bf:	90                   	nop

000010c0 <memset>:

void*
memset(void *dst, int c, uint n)
{
    10c0:	55                   	push   %ebp
    10c1:	89 e5                	mov    %esp,%ebp
    10c3:	8b 55 08             	mov    0x8(%ebp),%edx
    10c6:	57                   	push   %edi
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
    10c7:	8b 4d 10             	mov    0x10(%ebp),%ecx
    10ca:	8b 45 0c             	mov    0xc(%ebp),%eax
    10cd:	89 d7                	mov    %edx,%edi
    10cf:	fc                   	cld    
    10d0:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
    10d2:	89 d0                	mov    %edx,%eax
    10d4:	5f                   	pop    %edi
    10d5:	5d                   	pop    %ebp
    10d6:	c3                   	ret    
    10d7:	89 f6                	mov    %esi,%esi
    10d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000010e0 <strchr>:

char*
strchr(const char *s, char c)
{
    10e0:	55                   	push   %ebp
    10e1:	89 e5                	mov    %esp,%ebp
    10e3:	8b 45 08             	mov    0x8(%ebp),%eax
    10e6:	53                   	push   %ebx
    10e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  for(; *s; s++)
    10ea:	0f b6 18             	movzbl (%eax),%ebx
    10ed:	84 db                	test   %bl,%bl
    10ef:	74 1d                	je     110e <strchr+0x2e>
    if(*s == c)
    10f1:	38 d3                	cmp    %dl,%bl
    10f3:	89 d1                	mov    %edx,%ecx
    10f5:	75 0d                	jne    1104 <strchr+0x24>
    10f7:	eb 17                	jmp    1110 <strchr+0x30>
    10f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    1100:	38 ca                	cmp    %cl,%dl
    1102:	74 0c                	je     1110 <strchr+0x30>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    1104:	83 c0 01             	add    $0x1,%eax
    1107:	0f b6 10             	movzbl (%eax),%edx
    110a:	84 d2                	test   %dl,%dl
    110c:	75 f2                	jne    1100 <strchr+0x20>
    if(*s == c)
      return (char*)s;
  return 0;
    110e:	31 c0                	xor    %eax,%eax
}
    1110:	5b                   	pop    %ebx
    1111:	5d                   	pop    %ebp
    1112:	c3                   	ret    
    1113:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    1119:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00001120 <gets>:

char*
gets(char *buf, int max)
{
    1120:	55                   	push   %ebp
    1121:	89 e5                	mov    %esp,%ebp
    1123:	57                   	push   %edi
    1124:	56                   	push   %esi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1125:	31 f6                	xor    %esi,%esi
  return 0;
}

char*
gets(char *buf, int max)
{
    1127:	53                   	push   %ebx
    1128:	83 ec 2c             	sub    $0x2c,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    cc = read(0, &c, 1);
    112b:	8d 7d e7             	lea    -0x19(%ebp),%edi
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    112e:	eb 31                	jmp    1161 <gets+0x41>
    cc = read(0, &c, 1);
    1130:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    1137:	00 
    1138:	89 7c 24 04          	mov    %edi,0x4(%esp)
    113c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    1143:	e8 02 01 00 00       	call   124a <read>
    if(cc < 1)
    1148:	85 c0                	test   %eax,%eax
    114a:	7e 1d                	jle    1169 <gets+0x49>
      break;
    buf[i++] = c;
    114c:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1150:	89 de                	mov    %ebx,%esi
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    1152:	8b 55 08             	mov    0x8(%ebp),%edx
    if(c == '\n' || c == '\r')
    1155:	3c 0d                	cmp    $0xd,%al

  for(i=0; i+1 < max; ){
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    1157:	88 44 1a ff          	mov    %al,-0x1(%edx,%ebx,1)
    if(c == '\n' || c == '\r')
    115b:	74 0c                	je     1169 <gets+0x49>
    115d:	3c 0a                	cmp    $0xa,%al
    115f:	74 08                	je     1169 <gets+0x49>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1161:	8d 5e 01             	lea    0x1(%esi),%ebx
    1164:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
    1167:	7c c7                	jl     1130 <gets+0x10>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    1169:	8b 45 08             	mov    0x8(%ebp),%eax
    116c:	c6 04 30 00          	movb   $0x0,(%eax,%esi,1)
  return buf;
}
    1170:	83 c4 2c             	add    $0x2c,%esp
    1173:	5b                   	pop    %ebx
    1174:	5e                   	pop    %esi
    1175:	5f                   	pop    %edi
    1176:	5d                   	pop    %ebp
    1177:	c3                   	ret    
    1178:	90                   	nop
    1179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

00001180 <stat>:

int
stat(char *n, struct stat *st)
{
    1180:	55                   	push   %ebp
    1181:	89 e5                	mov    %esp,%ebp
    1183:	56                   	push   %esi
    1184:	53                   	push   %ebx
    1185:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    1188:	8b 45 08             	mov    0x8(%ebp),%eax
    118b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1192:	00 
    1193:	89 04 24             	mov    %eax,(%esp)
    1196:	e8 d7 00 00 00       	call   1272 <open>
  if(fd < 0)
    119b:	85 c0                	test   %eax,%eax
stat(char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    119d:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
    119f:	78 27                	js     11c8 <stat+0x48>
    return -1;
  r = fstat(fd, st);
    11a1:	8b 45 0c             	mov    0xc(%ebp),%eax
    11a4:	89 1c 24             	mov    %ebx,(%esp)
    11a7:	89 44 24 04          	mov    %eax,0x4(%esp)
    11ab:	e8 da 00 00 00       	call   128a <fstat>
  close(fd);
    11b0:	89 1c 24             	mov    %ebx,(%esp)
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
  r = fstat(fd, st);
    11b3:	89 c6                	mov    %eax,%esi
  close(fd);
    11b5:	e8 a0 00 00 00       	call   125a <close>
  return r;
    11ba:	89 f0                	mov    %esi,%eax
}
    11bc:	83 c4 10             	add    $0x10,%esp
    11bf:	5b                   	pop    %ebx
    11c0:	5e                   	pop    %esi
    11c1:	5d                   	pop    %ebp
    11c2:	c3                   	ret    
    11c3:	90                   	nop
    11c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
    11c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    11cd:	eb ed                	jmp    11bc <stat+0x3c>
    11cf:	90                   	nop

000011d0 <atoi>:
  return r;
}

int
atoi(const char *s)
{
    11d0:	55                   	push   %ebp
    11d1:	89 e5                	mov    %esp,%ebp
    11d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
    11d6:	53                   	push   %ebx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    11d7:	0f be 11             	movsbl (%ecx),%edx
    11da:	8d 42 d0             	lea    -0x30(%edx),%eax
    11dd:	3c 09                	cmp    $0x9,%al
int
atoi(const char *s)
{
  int n;

  n = 0;
    11df:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
    11e4:	77 17                	ja     11fd <atoi+0x2d>
    11e6:	66 90                	xchg   %ax,%ax
    n = n*10 + *s++ - '0';
    11e8:	83 c1 01             	add    $0x1,%ecx
    11eb:	8d 04 80             	lea    (%eax,%eax,4),%eax
    11ee:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    11f2:	0f be 11             	movsbl (%ecx),%edx
    11f5:	8d 5a d0             	lea    -0x30(%edx),%ebx
    11f8:	80 fb 09             	cmp    $0x9,%bl
    11fb:	76 eb                	jbe    11e8 <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
    11fd:	5b                   	pop    %ebx
    11fe:	5d                   	pop    %ebp
    11ff:	c3                   	ret    

00001200 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    1200:	55                   	push   %ebp
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    1201:	31 d2                	xor    %edx,%edx
  return n;
}

void*
memmove(void *vdst, void *vsrc, int n)
{
    1203:	89 e5                	mov    %esp,%ebp
    1205:	56                   	push   %esi
    1206:	8b 45 08             	mov    0x8(%ebp),%eax
    1209:	53                   	push   %ebx
    120a:	8b 5d 10             	mov    0x10(%ebp),%ebx
    120d:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    1210:	85 db                	test   %ebx,%ebx
    1212:	7e 12                	jle    1226 <memmove+0x26>
    1214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    *dst++ = *src++;
    1218:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
    121c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
    121f:	83 c2 01             	add    $0x1,%edx
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    1222:	39 da                	cmp    %ebx,%edx
    1224:	75 f2                	jne    1218 <memmove+0x18>
    *dst++ = *src++;
  return vdst;
}
    1226:	5b                   	pop    %ebx
    1227:	5e                   	pop    %esi
    1228:	5d                   	pop    %ebp
    1229:	c3                   	ret    

0000122a <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    122a:	b8 01 00 00 00       	mov    $0x1,%eax
    122f:	cd 40                	int    $0x40
    1231:	c3                   	ret    

00001232 <exit>:
SYSCALL(exit)
    1232:	b8 02 00 00 00       	mov    $0x2,%eax
    1237:	cd 40                	int    $0x40
    1239:	c3                   	ret    

0000123a <wait>:
SYSCALL(wait)
    123a:	b8 03 00 00 00       	mov    $0x3,%eax
    123f:	cd 40                	int    $0x40
    1241:	c3                   	ret    

00001242 <pipe>:
SYSCALL(pipe)
    1242:	b8 04 00 00 00       	mov    $0x4,%eax
    1247:	cd 40                	int    $0x40
    1249:	c3                   	ret    

0000124a <read>:
SYSCALL(read)
    124a:	b8 05 00 00 00       	mov    $0x5,%eax
    124f:	cd 40                	int    $0x40
    1251:	c3                   	ret    

00001252 <write>:
SYSCALL(write)
    1252:	b8 10 00 00 00       	mov    $0x10,%eax
    1257:	cd 40                	int    $0x40
    1259:	c3                   	ret    

0000125a <close>:
SYSCALL(close)
    125a:	b8 15 00 00 00       	mov    $0x15,%eax
    125f:	cd 40                	int    $0x40
    1261:	c3                   	ret    

00001262 <kill>:
SYSCALL(kill)
    1262:	b8 06 00 00 00       	mov    $0x6,%eax
    1267:	cd 40                	int    $0x40
    1269:	c3                   	ret    

0000126a <exec>:
SYSCALL(exec)
    126a:	b8 07 00 00 00       	mov    $0x7,%eax
    126f:	cd 40                	int    $0x40
    1271:	c3                   	ret    

00001272 <open>:
SYSCALL(open)
    1272:	b8 0f 00 00 00       	mov    $0xf,%eax
    1277:	cd 40                	int    $0x40
    1279:	c3                   	ret    

0000127a <mknod>:
SYSCALL(mknod)
    127a:	b8 11 00 00 00       	mov    $0x11,%eax
    127f:	cd 40                	int    $0x40
    1281:	c3                   	ret    

00001282 <unlink>:
SYSCALL(unlink)
    1282:	b8 12 00 00 00       	mov    $0x12,%eax
    1287:	cd 40                	int    $0x40
    1289:	c3                   	ret    

0000128a <fstat>:
SYSCALL(fstat)
    128a:	b8 08 00 00 00       	mov    $0x8,%eax
    128f:	cd 40                	int    $0x40
    1291:	c3                   	ret    

00001292 <link>:
SYSCALL(link)
    1292:	b8 13 00 00 00       	mov    $0x13,%eax
    1297:	cd 40                	int    $0x40
    1299:	c3                   	ret    

0000129a <mkdir>:
SYSCALL(mkdir)
    129a:	b8 14 00 00 00       	mov    $0x14,%eax
    129f:	cd 40                	int    $0x40
    12a1:	c3                   	ret    

000012a2 <chdir>:
SYSCALL(chdir)
    12a2:	b8 09 00 00 00       	mov    $0x9,%eax
    12a7:	cd 40                	int    $0x40
    12a9:	c3                   	ret    

000012aa <dup>:
SYSCALL(dup)
    12aa:	b8 0a 00 00 00       	mov    $0xa,%eax
    12af:	cd 40                	int    $0x40
    12b1:	c3                   	ret    

000012b2 <getpid>:
SYSCALL(getpid)
    12b2:	b8 0b 00 00 00       	mov    $0xb,%eax
    12b7:	cd 40                	int    $0x40
    12b9:	c3                   	ret    

000012ba <sbrk>:
SYSCALL(sbrk)
    12ba:	b8 0c 00 00 00       	mov    $0xc,%eax
    12bf:	cd 40                	int    $0x40
    12c1:	c3                   	ret    

000012c2 <sleep>:
SYSCALL(sleep)
    12c2:	b8 0d 00 00 00       	mov    $0xd,%eax
    12c7:	cd 40                	int    $0x40
    12c9:	c3                   	ret    

000012ca <uptime>:
SYSCALL(uptime)
    12ca:	b8 0e 00 00 00       	mov    $0xe,%eax
    12cf:	cd 40                	int    $0x40
    12d1:	c3                   	ret    

000012d2 <shm_open>:
SYSCALL(shm_open)
    12d2:	b8 16 00 00 00       	mov    $0x16,%eax
    12d7:	cd 40                	int    $0x40
    12d9:	c3                   	ret    

000012da <shm_close>:
SYSCALL(shm_close)	
    12da:	b8 17 00 00 00       	mov    $0x17,%eax
    12df:	cd 40                	int    $0x40
    12e1:	c3                   	ret    
    12e2:	66 90                	xchg   %ax,%ax
    12e4:	66 90                	xchg   %ax,%ax
    12e6:	66 90                	xchg   %ax,%ax
    12e8:	66 90                	xchg   %ax,%ax
    12ea:	66 90                	xchg   %ax,%ax
    12ec:	66 90                	xchg   %ax,%ax
    12ee:	66 90                	xchg   %ax,%ax

000012f0 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
    12f0:	55                   	push   %ebp
    12f1:	89 e5                	mov    %esp,%ebp
    12f3:	57                   	push   %edi
    12f4:	56                   	push   %esi
    12f5:	89 c6                	mov    %eax,%esi
    12f7:	53                   	push   %ebx
    12f8:	83 ec 4c             	sub    $0x4c,%esp
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    12fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
    12fe:	85 db                	test   %ebx,%ebx
    1300:	74 09                	je     130b <printint+0x1b>
    1302:	89 d0                	mov    %edx,%eax
    1304:	c1 e8 1f             	shr    $0x1f,%eax
    1307:	84 c0                	test   %al,%al
    1309:	75 75                	jne    1380 <printint+0x90>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    130b:	89 d0                	mov    %edx,%eax
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    130d:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
    1314:	89 75 c0             	mov    %esi,-0x40(%ebp)
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
    1317:	31 ff                	xor    %edi,%edi
    1319:	89 ce                	mov    %ecx,%esi
    131b:	8d 5d d7             	lea    -0x29(%ebp),%ebx
    131e:	eb 02                	jmp    1322 <printint+0x32>
  do{
    buf[i++] = digits[x % base];
    1320:	89 cf                	mov    %ecx,%edi
    1322:	31 d2                	xor    %edx,%edx
    1324:	f7 f6                	div    %esi
    1326:	8d 4f 01             	lea    0x1(%edi),%ecx
    1329:	0f b6 92 38 17 00 00 	movzbl 0x1738(%edx),%edx
  }while((x /= base) != 0);
    1330:	85 c0                	test   %eax,%eax
    x = xx;
  }

  i = 0;
  do{
    buf[i++] = digits[x % base];
    1332:	88 14 0b             	mov    %dl,(%ebx,%ecx,1)
  }while((x /= base) != 0);
    1335:	75 e9                	jne    1320 <printint+0x30>
  if(neg)
    1337:	8b 55 c4             	mov    -0x3c(%ebp),%edx
    x = xx;
  }

  i = 0;
  do{
    buf[i++] = digits[x % base];
    133a:	89 c8                	mov    %ecx,%eax
    133c:	8b 75 c0             	mov    -0x40(%ebp),%esi
  }while((x /= base) != 0);
  if(neg)
    133f:	85 d2                	test   %edx,%edx
    1341:	74 08                	je     134b <printint+0x5b>
    buf[i++] = '-';
    1343:	8d 4f 02             	lea    0x2(%edi),%ecx
    1346:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)

  while(--i >= 0)
    134b:	8d 79 ff             	lea    -0x1(%ecx),%edi
    134e:	66 90                	xchg   %ax,%ax
    1350:	0f b6 44 3d d8       	movzbl -0x28(%ebp,%edi,1),%eax
    1355:	83 ef 01             	sub    $0x1,%edi
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
    1358:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    135f:	00 
    1360:	89 5c 24 04          	mov    %ebx,0x4(%esp)
    1364:	89 34 24             	mov    %esi,(%esp)
    1367:	88 45 d7             	mov    %al,-0x29(%ebp)
    136a:	e8 e3 fe ff ff       	call   1252 <write>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    136f:	83 ff ff             	cmp    $0xffffffff,%edi
    1372:	75 dc                	jne    1350 <printint+0x60>
    putc(fd, buf[i]);
}
    1374:	83 c4 4c             	add    $0x4c,%esp
    1377:	5b                   	pop    %ebx
    1378:	5e                   	pop    %esi
    1379:	5f                   	pop    %edi
    137a:	5d                   	pop    %ebp
    137b:	c3                   	ret    
    137c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
    1380:	89 d0                	mov    %edx,%eax
    1382:	f7 d8                	neg    %eax
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    1384:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
    138b:	eb 87                	jmp    1314 <printint+0x24>
    138d:	8d 76 00             	lea    0x0(%esi),%esi

00001390 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1390:	55                   	push   %ebp
    1391:	89 e5                	mov    %esp,%ebp
    1393:	57                   	push   %edi
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    1394:	31 ff                	xor    %edi,%edi
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1396:	56                   	push   %esi
    1397:	53                   	push   %ebx
    1398:	83 ec 3c             	sub    $0x3c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    139b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
    139e:	8d 45 10             	lea    0x10(%ebp),%eax
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    13a1:	8b 75 08             	mov    0x8(%ebp),%esi
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
    13a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  for(i = 0; fmt[i]; i++){
    13a7:	0f b6 13             	movzbl (%ebx),%edx
    13aa:	83 c3 01             	add    $0x1,%ebx
    13ad:	84 d2                	test   %dl,%dl
    13af:	75 39                	jne    13ea <printf+0x5a>
    13b1:	e9 c2 00 00 00       	jmp    1478 <printf+0xe8>
    13b6:	66 90                	xchg   %ax,%ax
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
    13b8:	83 fa 25             	cmp    $0x25,%edx
    13bb:	0f 84 bf 00 00 00    	je     1480 <printf+0xf0>
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
    13c1:	8d 45 e2             	lea    -0x1e(%ebp),%eax
    13c4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    13cb:	00 
    13cc:	89 44 24 04          	mov    %eax,0x4(%esp)
    13d0:	89 34 24             	mov    %esi,(%esp)
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
    13d3:	88 55 e2             	mov    %dl,-0x1e(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
    13d6:	e8 77 fe ff ff       	call   1252 <write>
    13db:	83 c3 01             	add    $0x1,%ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    13de:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
    13e2:	84 d2                	test   %dl,%dl
    13e4:	0f 84 8e 00 00 00    	je     1478 <printf+0xe8>
    c = fmt[i] & 0xff;
    if(state == 0){
    13ea:	85 ff                	test   %edi,%edi
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    13ec:	0f be c2             	movsbl %dl,%eax
    if(state == 0){
    13ef:	74 c7                	je     13b8 <printf+0x28>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    13f1:	83 ff 25             	cmp    $0x25,%edi
    13f4:	75 e5                	jne    13db <printf+0x4b>
      if(c == 'd'){
    13f6:	83 fa 64             	cmp    $0x64,%edx
    13f9:	0f 84 31 01 00 00    	je     1530 <printf+0x1a0>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
    13ff:	25 f7 00 00 00       	and    $0xf7,%eax
    1404:	83 f8 70             	cmp    $0x70,%eax
    1407:	0f 84 83 00 00 00    	je     1490 <printf+0x100>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
    140d:	83 fa 73             	cmp    $0x73,%edx
    1410:	0f 84 a2 00 00 00    	je     14b8 <printf+0x128>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1416:	83 fa 63             	cmp    $0x63,%edx
    1419:	0f 84 35 01 00 00    	je     1554 <printf+0x1c4>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
    141f:	83 fa 25             	cmp    $0x25,%edx
    1422:	0f 84 e0 00 00 00    	je     1508 <printf+0x178>
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
    1428:	8d 45 e6             	lea    -0x1a(%ebp),%eax
    142b:	83 c3 01             	add    $0x1,%ebx
    142e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    1435:	00 
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    1436:	31 ff                	xor    %edi,%edi
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
    1438:	89 44 24 04          	mov    %eax,0x4(%esp)
    143c:	89 34 24             	mov    %esi,(%esp)
    143f:	89 55 d0             	mov    %edx,-0x30(%ebp)
    1442:	c6 45 e6 25          	movb   $0x25,-0x1a(%ebp)
    1446:	e8 07 fe ff ff       	call   1252 <write>
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
    144b:	8b 55 d0             	mov    -0x30(%ebp),%edx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
    144e:	8d 45 e7             	lea    -0x19(%ebp),%eax
    1451:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    1458:	00 
    1459:	89 44 24 04          	mov    %eax,0x4(%esp)
    145d:	89 34 24             	mov    %esi,(%esp)
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
    1460:	88 55 e7             	mov    %dl,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
    1463:	e8 ea fd ff ff       	call   1252 <write>
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    1468:	0f b6 53 ff          	movzbl -0x1(%ebx),%edx
    146c:	84 d2                	test   %dl,%dl
    146e:	0f 85 76 ff ff ff    	jne    13ea <printf+0x5a>
    1474:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    1478:	83 c4 3c             	add    $0x3c,%esp
    147b:	5b                   	pop    %ebx
    147c:	5e                   	pop    %esi
    147d:	5f                   	pop    %edi
    147e:	5d                   	pop    %ebp
    147f:	c3                   	ret    
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
    1480:	bf 25 00 00 00       	mov    $0x25,%edi
    1485:	e9 51 ff ff ff       	jmp    13db <printf+0x4b>
    148a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
    1490:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    1493:	b9 10 00 00 00       	mov    $0x10,%ecx
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    1498:	31 ff                	xor    %edi,%edi
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
    149a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    14a1:	8b 10                	mov    (%eax),%edx
    14a3:	89 f0                	mov    %esi,%eax
    14a5:	e8 46 fe ff ff       	call   12f0 <printint>
        ap++;
    14aa:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
    14ae:	e9 28 ff ff ff       	jmp    13db <printf+0x4b>
    14b3:	90                   	nop
    14b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      } else if(c == 's'){
        s = (char*)*ap;
    14b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
        ap++;
    14bb:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
    14bf:	8b 38                	mov    (%eax),%edi
        ap++;
        if(s == 0)
          s = "(null)";
    14c1:	b8 31 17 00 00       	mov    $0x1731,%eax
    14c6:	85 ff                	test   %edi,%edi
    14c8:	0f 44 f8             	cmove  %eax,%edi
        while(*s != 0){
    14cb:	0f b6 07             	movzbl (%edi),%eax
    14ce:	84 c0                	test   %al,%al
    14d0:	74 2a                	je     14fc <printf+0x16c>
    14d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    14d8:	88 45 e3             	mov    %al,-0x1d(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
    14db:	8d 45 e3             	lea    -0x1d(%ebp),%eax
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
    14de:	83 c7 01             	add    $0x1,%edi
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
    14e1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    14e8:	00 
    14e9:	89 44 24 04          	mov    %eax,0x4(%esp)
    14ed:	89 34 24             	mov    %esi,(%esp)
    14f0:	e8 5d fd ff ff       	call   1252 <write>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    14f5:	0f b6 07             	movzbl (%edi),%eax
    14f8:	84 c0                	test   %al,%al
    14fa:	75 dc                	jne    14d8 <printf+0x148>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    14fc:	31 ff                	xor    %edi,%edi
    14fe:	e9 d8 fe ff ff       	jmp    13db <printf+0x4b>
    1503:	90                   	nop
    1504:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
    1508:	8d 45 e5             	lea    -0x1b(%ebp),%eax
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    150b:	31 ff                	xor    %edi,%edi
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
    150d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    1514:	00 
    1515:	89 44 24 04          	mov    %eax,0x4(%esp)
    1519:	89 34 24             	mov    %esi,(%esp)
    151c:	c6 45 e5 25          	movb   $0x25,-0x1b(%ebp)
    1520:	e8 2d fd ff ff       	call   1252 <write>
    1525:	e9 b1 fe ff ff       	jmp    13db <printf+0x4b>
    152a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
    1530:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    1533:	b9 0a 00 00 00       	mov    $0xa,%ecx
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    1538:	66 31 ff             	xor    %di,%di
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
    153b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1542:	8b 10                	mov    (%eax),%edx
    1544:	89 f0                	mov    %esi,%eax
    1546:	e8 a5 fd ff ff       	call   12f0 <printint>
        ap++;
    154b:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
    154f:	e9 87 fe ff ff       	jmp    13db <printf+0x4b>
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
    1554:	8b 45 d4             	mov    -0x2c(%ebp),%eax
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    1557:	31 ff                	xor    %edi,%edi
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
    1559:	8b 00                	mov    (%eax),%eax
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
    155b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    1562:	00 
    1563:	89 34 24             	mov    %esi,(%esp)
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
    1566:	88 45 e4             	mov    %al,-0x1c(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
    1569:	8d 45 e4             	lea    -0x1c(%ebp),%eax
    156c:	89 44 24 04          	mov    %eax,0x4(%esp)
    1570:	e8 dd fc ff ff       	call   1252 <write>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
    1575:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
    1579:	e9 5d fe ff ff       	jmp    13db <printf+0x4b>
    157e:	66 90                	xchg   %ax,%ax

00001580 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1580:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1581:	a1 f4 19 00 00       	mov    0x19f4,%eax
static Header base;
static Header *freep;

void
free(void *ap)
{
    1586:	89 e5                	mov    %esp,%ebp
    1588:	57                   	push   %edi
    1589:	56                   	push   %esi
    158a:	53                   	push   %ebx
    158b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    158e:	8b 08                	mov    (%eax),%ecx
void
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1590:	8d 53 f8             	lea    -0x8(%ebx),%edx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1593:	39 d0                	cmp    %edx,%eax
    1595:	72 11                	jb     15a8 <free+0x28>
    1597:	90                   	nop
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1598:	39 c8                	cmp    %ecx,%eax
    159a:	72 04                	jb     15a0 <free+0x20>
    159c:	39 ca                	cmp    %ecx,%edx
    159e:	72 10                	jb     15b0 <free+0x30>
    15a0:	89 c8                	mov    %ecx,%eax
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15a2:	39 d0                	cmp    %edx,%eax
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    15a4:	8b 08                	mov    (%eax),%ecx
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15a6:	73 f0                	jae    1598 <free+0x18>
    15a8:	39 ca                	cmp    %ecx,%edx
    15aa:	72 04                	jb     15b0 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    15ac:	39 c8                	cmp    %ecx,%eax
    15ae:	72 f0                	jb     15a0 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
    15b0:	8b 73 fc             	mov    -0x4(%ebx),%esi
    15b3:	8d 3c f2             	lea    (%edx,%esi,8),%edi
    15b6:	39 cf                	cmp    %ecx,%edi
    15b8:	74 1e                	je     15d8 <free+0x58>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
    15ba:	89 4b f8             	mov    %ecx,-0x8(%ebx)
  if(p + p->s.size == bp){
    15bd:	8b 48 04             	mov    0x4(%eax),%ecx
    15c0:	8d 34 c8             	lea    (%eax,%ecx,8),%esi
    15c3:	39 f2                	cmp    %esi,%edx
    15c5:	74 28                	je     15ef <free+0x6f>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
    15c7:	89 10                	mov    %edx,(%eax)
  freep = p;
    15c9:	a3 f4 19 00 00       	mov    %eax,0x19f4
}
    15ce:	5b                   	pop    %ebx
    15cf:	5e                   	pop    %esi
    15d0:	5f                   	pop    %edi
    15d1:	5d                   	pop    %ebp
    15d2:	c3                   	ret    
    15d3:	90                   	nop
    15d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    15d8:	03 71 04             	add    0x4(%ecx),%esi
    15db:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
    15de:	8b 08                	mov    (%eax),%ecx
    15e0:	8b 09                	mov    (%ecx),%ecx
    15e2:	89 4b f8             	mov    %ecx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    15e5:	8b 48 04             	mov    0x4(%eax),%ecx
    15e8:	8d 34 c8             	lea    (%eax,%ecx,8),%esi
    15eb:	39 f2                	cmp    %esi,%edx
    15ed:	75 d8                	jne    15c7 <free+0x47>
    p->s.size += bp->s.size;
    15ef:	03 4b fc             	add    -0x4(%ebx),%ecx
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
  freep = p;
    15f2:	a3 f4 19 00 00       	mov    %eax,0x19f4
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    15f7:	89 48 04             	mov    %ecx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    15fa:	8b 53 f8             	mov    -0x8(%ebx),%edx
    15fd:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
}
    15ff:	5b                   	pop    %ebx
    1600:	5e                   	pop    %esi
    1601:	5f                   	pop    %edi
    1602:	5d                   	pop    %ebp
    1603:	c3                   	ret    
    1604:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    160a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00001610 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1610:	55                   	push   %ebp
    1611:	89 e5                	mov    %esp,%ebp
    1613:	57                   	push   %edi
    1614:	56                   	push   %esi
    1615:	53                   	push   %ebx
    1616:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1619:	8b 45 08             	mov    0x8(%ebp),%eax
  if((prevp = freep) == 0){
    161c:	8b 1d f4 19 00 00    	mov    0x19f4,%ebx
malloc(uint nbytes)
{
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1622:	8d 48 07             	lea    0x7(%eax),%ecx
    1625:	c1 e9 03             	shr    $0x3,%ecx
  if((prevp = freep) == 0){
    1628:	85 db                	test   %ebx,%ebx
malloc(uint nbytes)
{
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    162a:	8d 71 01             	lea    0x1(%ecx),%esi
  if((prevp = freep) == 0){
    162d:	0f 84 9b 00 00 00    	je     16ce <malloc+0xbe>
    1633:	8b 13                	mov    (%ebx),%edx
    1635:	8b 7a 04             	mov    0x4(%edx),%edi
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
    1638:	39 fe                	cmp    %edi,%esi
    163a:	76 64                	jbe    16a0 <malloc+0x90>
    163c:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
    1643:	bb 00 80 00 00       	mov    $0x8000,%ebx
    1648:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    164b:	eb 0e                	jmp    165b <malloc+0x4b>
    164d:	8d 76 00             	lea    0x0(%esi),%esi
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1650:	8b 02                	mov    (%edx),%eax
    if(p->s.size >= nunits){
    1652:	8b 78 04             	mov    0x4(%eax),%edi
    1655:	39 fe                	cmp    %edi,%esi
    1657:	76 4f                	jbe    16a8 <malloc+0x98>
    1659:	89 c2                	mov    %eax,%edx
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    165b:	3b 15 f4 19 00 00    	cmp    0x19f4,%edx
    1661:	75 ed                	jne    1650 <malloc+0x40>
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
    1663:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1666:	81 fe 00 10 00 00    	cmp    $0x1000,%esi
    166c:	bf 00 10 00 00       	mov    $0x1000,%edi
    1671:	0f 43 fe             	cmovae %esi,%edi
    1674:	0f 42 c3             	cmovb  %ebx,%eax
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
    1677:	89 04 24             	mov    %eax,(%esp)
    167a:	e8 3b fc ff ff       	call   12ba <sbrk>
  if(p == (char*)-1)
    167f:	83 f8 ff             	cmp    $0xffffffff,%eax
    1682:	74 18                	je     169c <malloc+0x8c>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
    1684:	89 78 04             	mov    %edi,0x4(%eax)
  free((void*)(hp + 1));
    1687:	83 c0 08             	add    $0x8,%eax
    168a:	89 04 24             	mov    %eax,(%esp)
    168d:	e8 ee fe ff ff       	call   1580 <free>
  return freep;
    1692:	8b 15 f4 19 00 00    	mov    0x19f4,%edx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
    1698:	85 d2                	test   %edx,%edx
    169a:	75 b4                	jne    1650 <malloc+0x40>
        return 0;
    169c:	31 c0                	xor    %eax,%eax
    169e:	eb 20                	jmp    16c0 <malloc+0xb0>
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
    16a0:	89 d0                	mov    %edx,%eax
    16a2:	89 da                	mov    %ebx,%edx
    16a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      if(p->s.size == nunits)
    16a8:	39 fe                	cmp    %edi,%esi
    16aa:	74 1c                	je     16c8 <malloc+0xb8>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
    16ac:	29 f7                	sub    %esi,%edi
    16ae:	89 78 04             	mov    %edi,0x4(%eax)
        p += p->s.size;
    16b1:	8d 04 f8             	lea    (%eax,%edi,8),%eax
        p->s.size = nunits;
    16b4:	89 70 04             	mov    %esi,0x4(%eax)
      }
      freep = prevp;
    16b7:	89 15 f4 19 00 00    	mov    %edx,0x19f4
      return (void*)(p + 1);
    16bd:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    16c0:	83 c4 1c             	add    $0x1c,%esp
    16c3:	5b                   	pop    %ebx
    16c4:	5e                   	pop    %esi
    16c5:	5f                   	pop    %edi
    16c6:	5d                   	pop    %ebp
    16c7:	c3                   	ret    
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
    16c8:	8b 08                	mov    (%eax),%ecx
    16ca:	89 0a                	mov    %ecx,(%edx)
    16cc:	eb e9                	jmp    16b7 <malloc+0xa7>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    16ce:	c7 05 f4 19 00 00 f8 	movl   $0x19f8,0x19f4
    16d5:	19 00 00 
    base.s.size = 0;
    16d8:	ba f8 19 00 00       	mov    $0x19f8,%edx
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    16dd:	c7 05 f8 19 00 00 f8 	movl   $0x19f8,0x19f8
    16e4:	19 00 00 
    base.s.size = 0;
    16e7:	c7 05 fc 19 00 00 00 	movl   $0x0,0x19fc
    16ee:	00 00 00 
    16f1:	e9 46 ff ff ff       	jmp    163c <malloc+0x2c>
    16f6:	66 90                	xchg   %ax,%ax
    16f8:	66 90                	xchg   %ax,%ax
    16fa:	66 90                	xchg   %ax,%ax
    16fc:	66 90                	xchg   %ax,%ax
    16fe:	66 90                	xchg   %ax,%ax

00001700 <uacquire>:
#include "uspinlock.h"
#include "x86.h"

void
uacquire(struct uspinlock *lk)
{
    1700:	55                   	push   %ebp
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
    1701:	b9 01 00 00 00       	mov    $0x1,%ecx
    1706:	89 e5                	mov    %esp,%ebp
    1708:	8b 55 08             	mov    0x8(%ebp),%edx
    170b:	90                   	nop
    170c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    1710:	89 c8                	mov    %ecx,%eax
    1712:	f0 87 02             	lock xchg %eax,(%edx)
  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
    1715:	85 c0                	test   %eax,%eax
    1717:	75 f7                	jne    1710 <uacquire+0x10>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
    1719:	0f ae f0             	mfence 
}
    171c:	5d                   	pop    %ebp
    171d:	c3                   	ret    
    171e:	66 90                	xchg   %ax,%ax

00001720 <urelease>:

void urelease (struct uspinlock *lk) {
    1720:	55                   	push   %ebp
    1721:	89 e5                	mov    %esp,%ebp
    1723:	8b 45 08             	mov    0x8(%ebp),%eax
  __sync_synchronize();
    1726:	0f ae f0             	mfence 

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
    1729:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
    172f:	5d                   	pop    %ebp
    1730:	c3                   	ret    
