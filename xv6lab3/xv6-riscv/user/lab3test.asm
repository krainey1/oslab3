
user/_lab3test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
   0:	715d                	addi	sp,sp,-80
   2:	e486                	sd	ra,72(sp)
   4:	e0a2                	sd	s0,64(sp)
   6:	fc26                	sd	s1,56(sp)
   8:	f84a                	sd	s2,48(sp)
   a:	f44e                	sd	s3,40(sp)
   c:	f052                	sd	s4,32(sp)
   e:	ec56                	sd	s5,24(sp)
  10:	0880                	addi	s0,sp,80
	int k, n, id;
	volatile long x = 0, z;
  12:	fa043c23          	sd	zero,-72(s0)
	
	if(argc < 2)
  16:	4785                	li	a5,1
		n = 1;		// default value
  18:	4985                	li	s3,1
	if(argc < 2)
  1a:	00a7cc63          	blt	a5,a0,32 <main+0x32>
{
  1e:	4901                	li	s2,0
		id = fork();
		if(id < 0){
			printf("%d failed in fork!\n", getpid());
		}
		else if(id > 0){ // parent
			printf("Parent %d creating child %d\n", getpid(), id);
  20:	00001a17          	auipc	s4,0x1
  24:	968a0a13          	addi	s4,s4,-1688 # 988 <malloc+0x11a>
			printf("%d failed in fork!\n", getpid());
  28:	00001a97          	auipc	s5,0x1
  2c:	948a8a93          	addi	s5,s5,-1720 # 970 <malloc+0x102>
  30:	a035                	j	5c <main+0x5c>
		n = atoi(argv[1]);  // from command line
  32:	6588                	ld	a0,8(a1)
  34:	21c000ef          	jal	250 <atoi>
  38:	89aa                	mv	s3,a0
	if(n < 0 || n > 20)
  3a:	0005071b          	sext.w	a4,a0
  3e:	47d1                	li	a5,20
  40:	08e7ed63          	bltu	a5,a4,da <main+0xda>
	for(k = 0; k < n; k++){
  44:	fca04de3          	bgtz	a0,1e <main+0x1e>
  48:	a071                	j	d4 <main+0xd4>
			printf("%d failed in fork!\n", getpid());
  4a:	3a8000ef          	jal	3f2 <getpid>
  4e:	85aa                	mv	a1,a0
  50:	8556                	mv	a0,s5
  52:	768000ef          	jal	7ba <printf>
	for(k = 0; k < n; k++){
  56:	2905                	addiw	s2,s2,1
  58:	07390e63          	beq	s2,s3,d4 <main+0xd4>
		id = fork();
  5c:	30e000ef          	jal	36a <fork>
  60:	84aa                	mv	s1,a0
		if(id < 0){
  62:	fe0544e3          	bltz	a0,4a <main+0x4a>
		else if(id > 0){ // parent
  66:	00a05a63          	blez	a0,7a <main+0x7a>
			printf("Parent %d creating child %d\n", getpid(), id);
  6a:	388000ef          	jal	3f2 <getpid>
  6e:	85aa                	mv	a1,a0
  70:	8626                	mv	a2,s1
  72:	8552                	mv	a0,s4
  74:	746000ef          	jal	7ba <printf>
  78:	bff9                	j	56 <main+0x56>
		} else{ // child
			printf("Child %d created\n", getpid());
  7a:	378000ef          	jal	3f2 <getpid>
  7e:	85aa                	mv	a1,a0
  80:	00001517          	auipc	a0,0x1
  84:	92850513          	addi	a0,a0,-1752 # 9a8 <malloc+0x13a>
  88:	732000ef          	jal	7ba <printf>
			for(z = 0; z < 8000000000; z += 1)
  8c:	fa043823          	sd	zero,-80(s0)
  90:	fb043703          	ld	a4,-80(s0)
  94:	001dd7b7          	lui	a5,0x1dd
  98:	d6578793          	addi	a5,a5,-667 # 1dcd65 <base+0x1dbd55>
  9c:	07b2                	slli	a5,a5,0xc
  9e:	17fd                	addi	a5,a5,-1
  a0:	02e7c163          	blt	a5,a4,c2 <main+0xc2>
  a4:	873e                	mv	a4,a5
				x = x + 1;
  a6:	fb843783          	ld	a5,-72(s0)
  aa:	0785                	addi	a5,a5,1
  ac:	faf43c23          	sd	a5,-72(s0)
			for(z = 0; z < 8000000000; z += 1)
  b0:	fb043783          	ld	a5,-80(s0)
  b4:	0785                	addi	a5,a5,1
  b6:	faf43823          	sd	a5,-80(s0)
  ba:	fb043783          	ld	a5,-80(s0)
  be:	fef754e3          	bge	a4,a5,a6 <main+0xa6>
			printf("Child %d terminated\n", getpid());
  c2:	330000ef          	jal	3f2 <getpid>
  c6:	85aa                	mv	a1,a0
  c8:	00001517          	auipc	a0,0x1
  cc:	8f850513          	addi	a0,a0,-1800 # 9c0 <malloc+0x152>
  d0:	6ea000ef          	jal	7ba <printf>
			break;
		}
	}
	exit(0);
  d4:	4501                	li	a0,0
  d6:	29c000ef          	jal	372 <exit>
		n = 2;
  da:	4989                	li	s3,2
	for(k = 0; k < n; k++){
  dc:	b789                	j	1e <main+0x1e>

00000000000000de <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  de:	1141                	addi	sp,sp,-16
  e0:	e406                	sd	ra,8(sp)
  e2:	e022                	sd	s0,0(sp)
  e4:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  e6:	f1bff0ef          	jal	0 <main>
  exit(r);
  ea:	288000ef          	jal	372 <exit>

00000000000000ee <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  ee:	1141                	addi	sp,sp,-16
  f0:	e422                	sd	s0,8(sp)
  f2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  f4:	87aa                	mv	a5,a0
  f6:	0585                	addi	a1,a1,1
  f8:	0785                	addi	a5,a5,1
  fa:	fff5c703          	lbu	a4,-1(a1)
  fe:	fee78fa3          	sb	a4,-1(a5)
 102:	fb75                	bnez	a4,f6 <strcpy+0x8>
    ;
  return os;
}
 104:	6422                	ld	s0,8(sp)
 106:	0141                	addi	sp,sp,16
 108:	8082                	ret

000000000000010a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 10a:	1141                	addi	sp,sp,-16
 10c:	e422                	sd	s0,8(sp)
 10e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 110:	00054783          	lbu	a5,0(a0)
 114:	cb91                	beqz	a5,128 <strcmp+0x1e>
 116:	0005c703          	lbu	a4,0(a1)
 11a:	00f71763          	bne	a4,a5,128 <strcmp+0x1e>
    p++, q++;
 11e:	0505                	addi	a0,a0,1
 120:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 122:	00054783          	lbu	a5,0(a0)
 126:	fbe5                	bnez	a5,116 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 128:	0005c503          	lbu	a0,0(a1)
}
 12c:	40a7853b          	subw	a0,a5,a0
 130:	6422                	ld	s0,8(sp)
 132:	0141                	addi	sp,sp,16
 134:	8082                	ret

0000000000000136 <strlen>:

uint
strlen(const char *s)
{
 136:	1141                	addi	sp,sp,-16
 138:	e422                	sd	s0,8(sp)
 13a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 13c:	00054783          	lbu	a5,0(a0)
 140:	cf91                	beqz	a5,15c <strlen+0x26>
 142:	0505                	addi	a0,a0,1
 144:	87aa                	mv	a5,a0
 146:	86be                	mv	a3,a5
 148:	0785                	addi	a5,a5,1
 14a:	fff7c703          	lbu	a4,-1(a5)
 14e:	ff65                	bnez	a4,146 <strlen+0x10>
 150:	40a6853b          	subw	a0,a3,a0
 154:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 156:	6422                	ld	s0,8(sp)
 158:	0141                	addi	sp,sp,16
 15a:	8082                	ret
  for(n = 0; s[n]; n++)
 15c:	4501                	li	a0,0
 15e:	bfe5                	j	156 <strlen+0x20>

0000000000000160 <memset>:

void*
memset(void *dst, int c, uint n)
{
 160:	1141                	addi	sp,sp,-16
 162:	e422                	sd	s0,8(sp)
 164:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 166:	ca19                	beqz	a2,17c <memset+0x1c>
 168:	87aa                	mv	a5,a0
 16a:	1602                	slli	a2,a2,0x20
 16c:	9201                	srli	a2,a2,0x20
 16e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 172:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 176:	0785                	addi	a5,a5,1
 178:	fee79de3          	bne	a5,a4,172 <memset+0x12>
  }
  return dst;
}
 17c:	6422                	ld	s0,8(sp)
 17e:	0141                	addi	sp,sp,16
 180:	8082                	ret

0000000000000182 <strchr>:

char*
strchr(const char *s, char c)
{
 182:	1141                	addi	sp,sp,-16
 184:	e422                	sd	s0,8(sp)
 186:	0800                	addi	s0,sp,16
  for(; *s; s++)
 188:	00054783          	lbu	a5,0(a0)
 18c:	cb99                	beqz	a5,1a2 <strchr+0x20>
    if(*s == c)
 18e:	00f58763          	beq	a1,a5,19c <strchr+0x1a>
  for(; *s; s++)
 192:	0505                	addi	a0,a0,1
 194:	00054783          	lbu	a5,0(a0)
 198:	fbfd                	bnez	a5,18e <strchr+0xc>
      return (char*)s;
  return 0;
 19a:	4501                	li	a0,0
}
 19c:	6422                	ld	s0,8(sp)
 19e:	0141                	addi	sp,sp,16
 1a0:	8082                	ret
  return 0;
 1a2:	4501                	li	a0,0
 1a4:	bfe5                	j	19c <strchr+0x1a>

00000000000001a6 <gets>:

char*
gets(char *buf, int max)
{
 1a6:	711d                	addi	sp,sp,-96
 1a8:	ec86                	sd	ra,88(sp)
 1aa:	e8a2                	sd	s0,80(sp)
 1ac:	e4a6                	sd	s1,72(sp)
 1ae:	e0ca                	sd	s2,64(sp)
 1b0:	fc4e                	sd	s3,56(sp)
 1b2:	f852                	sd	s4,48(sp)
 1b4:	f456                	sd	s5,40(sp)
 1b6:	f05a                	sd	s6,32(sp)
 1b8:	ec5e                	sd	s7,24(sp)
 1ba:	1080                	addi	s0,sp,96
 1bc:	8baa                	mv	s7,a0
 1be:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1c0:	892a                	mv	s2,a0
 1c2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1c4:	4aa9                	li	s5,10
 1c6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1c8:	89a6                	mv	s3,s1
 1ca:	2485                	addiw	s1,s1,1
 1cc:	0344d663          	bge	s1,s4,1f8 <gets+0x52>
    cc = read(0, &c, 1);
 1d0:	4605                	li	a2,1
 1d2:	faf40593          	addi	a1,s0,-81
 1d6:	4501                	li	a0,0
 1d8:	1b2000ef          	jal	38a <read>
    if(cc < 1)
 1dc:	00a05e63          	blez	a0,1f8 <gets+0x52>
    buf[i++] = c;
 1e0:	faf44783          	lbu	a5,-81(s0)
 1e4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1e8:	01578763          	beq	a5,s5,1f6 <gets+0x50>
 1ec:	0905                	addi	s2,s2,1
 1ee:	fd679de3          	bne	a5,s6,1c8 <gets+0x22>
    buf[i++] = c;
 1f2:	89a6                	mv	s3,s1
 1f4:	a011                	j	1f8 <gets+0x52>
 1f6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1f8:	99de                	add	s3,s3,s7
 1fa:	00098023          	sb	zero,0(s3)
  return buf;
}
 1fe:	855e                	mv	a0,s7
 200:	60e6                	ld	ra,88(sp)
 202:	6446                	ld	s0,80(sp)
 204:	64a6                	ld	s1,72(sp)
 206:	6906                	ld	s2,64(sp)
 208:	79e2                	ld	s3,56(sp)
 20a:	7a42                	ld	s4,48(sp)
 20c:	7aa2                	ld	s5,40(sp)
 20e:	7b02                	ld	s6,32(sp)
 210:	6be2                	ld	s7,24(sp)
 212:	6125                	addi	sp,sp,96
 214:	8082                	ret

0000000000000216 <stat>:

int
stat(const char *n, struct stat *st)
{
 216:	1101                	addi	sp,sp,-32
 218:	ec06                	sd	ra,24(sp)
 21a:	e822                	sd	s0,16(sp)
 21c:	e04a                	sd	s2,0(sp)
 21e:	1000                	addi	s0,sp,32
 220:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 222:	4581                	li	a1,0
 224:	18e000ef          	jal	3b2 <open>
  if(fd < 0)
 228:	02054263          	bltz	a0,24c <stat+0x36>
 22c:	e426                	sd	s1,8(sp)
 22e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 230:	85ca                	mv	a1,s2
 232:	198000ef          	jal	3ca <fstat>
 236:	892a                	mv	s2,a0
  close(fd);
 238:	8526                	mv	a0,s1
 23a:	160000ef          	jal	39a <close>
  return r;
 23e:	64a2                	ld	s1,8(sp)
}
 240:	854a                	mv	a0,s2
 242:	60e2                	ld	ra,24(sp)
 244:	6442                	ld	s0,16(sp)
 246:	6902                	ld	s2,0(sp)
 248:	6105                	addi	sp,sp,32
 24a:	8082                	ret
    return -1;
 24c:	597d                	li	s2,-1
 24e:	bfcd                	j	240 <stat+0x2a>

0000000000000250 <atoi>:

int
atoi(const char *s)
{
 250:	1141                	addi	sp,sp,-16
 252:	e422                	sd	s0,8(sp)
 254:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 256:	00054683          	lbu	a3,0(a0)
 25a:	fd06879b          	addiw	a5,a3,-48
 25e:	0ff7f793          	zext.b	a5,a5
 262:	4625                	li	a2,9
 264:	02f66863          	bltu	a2,a5,294 <atoi+0x44>
 268:	872a                	mv	a4,a0
  n = 0;
 26a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 26c:	0705                	addi	a4,a4,1
 26e:	0025179b          	slliw	a5,a0,0x2
 272:	9fa9                	addw	a5,a5,a0
 274:	0017979b          	slliw	a5,a5,0x1
 278:	9fb5                	addw	a5,a5,a3
 27a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 27e:	00074683          	lbu	a3,0(a4)
 282:	fd06879b          	addiw	a5,a3,-48
 286:	0ff7f793          	zext.b	a5,a5
 28a:	fef671e3          	bgeu	a2,a5,26c <atoi+0x1c>
  return n;
}
 28e:	6422                	ld	s0,8(sp)
 290:	0141                	addi	sp,sp,16
 292:	8082                	ret
  n = 0;
 294:	4501                	li	a0,0
 296:	bfe5                	j	28e <atoi+0x3e>

0000000000000298 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 298:	1141                	addi	sp,sp,-16
 29a:	e422                	sd	s0,8(sp)
 29c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 29e:	02b57463          	bgeu	a0,a1,2c6 <memmove+0x2e>
    while(n-- > 0)
 2a2:	00c05f63          	blez	a2,2c0 <memmove+0x28>
 2a6:	1602                	slli	a2,a2,0x20
 2a8:	9201                	srli	a2,a2,0x20
 2aa:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2ae:	872a                	mv	a4,a0
      *dst++ = *src++;
 2b0:	0585                	addi	a1,a1,1
 2b2:	0705                	addi	a4,a4,1
 2b4:	fff5c683          	lbu	a3,-1(a1)
 2b8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2bc:	fef71ae3          	bne	a4,a5,2b0 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2c0:	6422                	ld	s0,8(sp)
 2c2:	0141                	addi	sp,sp,16
 2c4:	8082                	ret
    dst += n;
 2c6:	00c50733          	add	a4,a0,a2
    src += n;
 2ca:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2cc:	fec05ae3          	blez	a2,2c0 <memmove+0x28>
 2d0:	fff6079b          	addiw	a5,a2,-1
 2d4:	1782                	slli	a5,a5,0x20
 2d6:	9381                	srli	a5,a5,0x20
 2d8:	fff7c793          	not	a5,a5
 2dc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2de:	15fd                	addi	a1,a1,-1
 2e0:	177d                	addi	a4,a4,-1
 2e2:	0005c683          	lbu	a3,0(a1)
 2e6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2ea:	fee79ae3          	bne	a5,a4,2de <memmove+0x46>
 2ee:	bfc9                	j	2c0 <memmove+0x28>

00000000000002f0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2f0:	1141                	addi	sp,sp,-16
 2f2:	e422                	sd	s0,8(sp)
 2f4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2f6:	ca05                	beqz	a2,326 <memcmp+0x36>
 2f8:	fff6069b          	addiw	a3,a2,-1
 2fc:	1682                	slli	a3,a3,0x20
 2fe:	9281                	srli	a3,a3,0x20
 300:	0685                	addi	a3,a3,1
 302:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 304:	00054783          	lbu	a5,0(a0)
 308:	0005c703          	lbu	a4,0(a1)
 30c:	00e79863          	bne	a5,a4,31c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 310:	0505                	addi	a0,a0,1
    p2++;
 312:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 314:	fed518e3          	bne	a0,a3,304 <memcmp+0x14>
  }
  return 0;
 318:	4501                	li	a0,0
 31a:	a019                	j	320 <memcmp+0x30>
      return *p1 - *p2;
 31c:	40e7853b          	subw	a0,a5,a4
}
 320:	6422                	ld	s0,8(sp)
 322:	0141                	addi	sp,sp,16
 324:	8082                	ret
  return 0;
 326:	4501                	li	a0,0
 328:	bfe5                	j	320 <memcmp+0x30>

000000000000032a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 32a:	1141                	addi	sp,sp,-16
 32c:	e406                	sd	ra,8(sp)
 32e:	e022                	sd	s0,0(sp)
 330:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 332:	f67ff0ef          	jal	298 <memmove>
}
 336:	60a2                	ld	ra,8(sp)
 338:	6402                	ld	s0,0(sp)
 33a:	0141                	addi	sp,sp,16
 33c:	8082                	ret

000000000000033e <sbrk>:

char *
sbrk(int n) {
 33e:	1141                	addi	sp,sp,-16
 340:	e406                	sd	ra,8(sp)
 342:	e022                	sd	s0,0(sp)
 344:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 346:	4585                	li	a1,1
 348:	0b2000ef          	jal	3fa <sys_sbrk>
}
 34c:	60a2                	ld	ra,8(sp)
 34e:	6402                	ld	s0,0(sp)
 350:	0141                	addi	sp,sp,16
 352:	8082                	ret

0000000000000354 <sbrklazy>:

char *
sbrklazy(int n) {
 354:	1141                	addi	sp,sp,-16
 356:	e406                	sd	ra,8(sp)
 358:	e022                	sd	s0,0(sp)
 35a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 35c:	4589                	li	a1,2
 35e:	09c000ef          	jal	3fa <sys_sbrk>
}
 362:	60a2                	ld	ra,8(sp)
 364:	6402                	ld	s0,0(sp)
 366:	0141                	addi	sp,sp,16
 368:	8082                	ret

000000000000036a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 36a:	4885                	li	a7,1
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <exit>:
.global exit
exit:
 li a7, SYS_exit
 372:	4889                	li	a7,2
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <wait>:
.global wait
wait:
 li a7, SYS_wait
 37a:	488d                	li	a7,3
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 382:	4891                	li	a7,4
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <read>:
.global read
read:
 li a7, SYS_read
 38a:	4895                	li	a7,5
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <write>:
.global write
write:
 li a7, SYS_write
 392:	48c1                	li	a7,16
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <close>:
.global close
close:
 li a7, SYS_close
 39a:	48d5                	li	a7,21
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3a2:	4899                	li	a7,6
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <exec>:
.global exec
exec:
 li a7, SYS_exec
 3aa:	489d                	li	a7,7
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <open>:
.global open
open:
 li a7, SYS_open
 3b2:	48bd                	li	a7,15
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3ba:	48c5                	li	a7,17
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3c2:	48c9                	li	a7,18
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3ca:	48a1                	li	a7,8
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <link>:
.global link
link:
 li a7, SYS_link
 3d2:	48cd                	li	a7,19
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3da:	48d1                	li	a7,20
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3e2:	48a5                	li	a7,9
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <dup>:
.global dup
dup:
 li a7, SYS_dup
 3ea:	48a9                	li	a7,10
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3f2:	48ad                	li	a7,11
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3fa:	48b1                	li	a7,12
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <pause>:
.global pause
pause:
 li a7, SYS_pause
 402:	48b5                	li	a7,13
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 40a:	48b9                	li	a7,14
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <trace>:
.global trace
trace:
 li a7, SYS_trace
 412:	48d9                	li	a7,22
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
 41a:	48dd                	li	a7,23
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <get_priority>:
.global get_priority
get_priority:
 li a7, SYS_get_priority
 422:	48e1                	li	a7,24
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <cps>:
.global cps
cps:
 li a7, SYS_cps
 42a:	48e5                	li	a7,25
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 432:	1101                	addi	sp,sp,-32
 434:	ec06                	sd	ra,24(sp)
 436:	e822                	sd	s0,16(sp)
 438:	1000                	addi	s0,sp,32
 43a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 43e:	4605                	li	a2,1
 440:	fef40593          	addi	a1,s0,-17
 444:	f4fff0ef          	jal	392 <write>
}
 448:	60e2                	ld	ra,24(sp)
 44a:	6442                	ld	s0,16(sp)
 44c:	6105                	addi	sp,sp,32
 44e:	8082                	ret

0000000000000450 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 450:	715d                	addi	sp,sp,-80
 452:	e486                	sd	ra,72(sp)
 454:	e0a2                	sd	s0,64(sp)
 456:	f84a                	sd	s2,48(sp)
 458:	0880                	addi	s0,sp,80
 45a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 45c:	c299                	beqz	a3,462 <printint+0x12>
 45e:	0805c363          	bltz	a1,4e4 <printint+0x94>
  neg = 0;
 462:	4881                	li	a7,0
 464:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 468:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 46a:	00000517          	auipc	a0,0x0
 46e:	57650513          	addi	a0,a0,1398 # 9e0 <digits>
 472:	883e                	mv	a6,a5
 474:	2785                	addiw	a5,a5,1
 476:	02c5f733          	remu	a4,a1,a2
 47a:	972a                	add	a4,a4,a0
 47c:	00074703          	lbu	a4,0(a4)
 480:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 484:	872e                	mv	a4,a1
 486:	02c5d5b3          	divu	a1,a1,a2
 48a:	0685                	addi	a3,a3,1
 48c:	fec773e3          	bgeu	a4,a2,472 <printint+0x22>
  if(neg)
 490:	00088b63          	beqz	a7,4a6 <printint+0x56>
    buf[i++] = '-';
 494:	fd078793          	addi	a5,a5,-48
 498:	97a2                	add	a5,a5,s0
 49a:	02d00713          	li	a4,45
 49e:	fee78423          	sb	a4,-24(a5)
 4a2:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4a6:	02f05a63          	blez	a5,4da <printint+0x8a>
 4aa:	fc26                	sd	s1,56(sp)
 4ac:	f44e                	sd	s3,40(sp)
 4ae:	fb840713          	addi	a4,s0,-72
 4b2:	00f704b3          	add	s1,a4,a5
 4b6:	fff70993          	addi	s3,a4,-1
 4ba:	99be                	add	s3,s3,a5
 4bc:	37fd                	addiw	a5,a5,-1
 4be:	1782                	slli	a5,a5,0x20
 4c0:	9381                	srli	a5,a5,0x20
 4c2:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4c6:	fff4c583          	lbu	a1,-1(s1)
 4ca:	854a                	mv	a0,s2
 4cc:	f67ff0ef          	jal	432 <putc>
  while(--i >= 0)
 4d0:	14fd                	addi	s1,s1,-1
 4d2:	ff349ae3          	bne	s1,s3,4c6 <printint+0x76>
 4d6:	74e2                	ld	s1,56(sp)
 4d8:	79a2                	ld	s3,40(sp)
}
 4da:	60a6                	ld	ra,72(sp)
 4dc:	6406                	ld	s0,64(sp)
 4de:	7942                	ld	s2,48(sp)
 4e0:	6161                	addi	sp,sp,80
 4e2:	8082                	ret
    x = -xx;
 4e4:	40b005b3          	neg	a1,a1
    neg = 1;
 4e8:	4885                	li	a7,1
    x = -xx;
 4ea:	bfad                	j	464 <printint+0x14>

00000000000004ec <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4ec:	711d                	addi	sp,sp,-96
 4ee:	ec86                	sd	ra,88(sp)
 4f0:	e8a2                	sd	s0,80(sp)
 4f2:	e0ca                	sd	s2,64(sp)
 4f4:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4f6:	0005c903          	lbu	s2,0(a1)
 4fa:	28090663          	beqz	s2,786 <vprintf+0x29a>
 4fe:	e4a6                	sd	s1,72(sp)
 500:	fc4e                	sd	s3,56(sp)
 502:	f852                	sd	s4,48(sp)
 504:	f456                	sd	s5,40(sp)
 506:	f05a                	sd	s6,32(sp)
 508:	ec5e                	sd	s7,24(sp)
 50a:	e862                	sd	s8,16(sp)
 50c:	e466                	sd	s9,8(sp)
 50e:	8b2a                	mv	s6,a0
 510:	8a2e                	mv	s4,a1
 512:	8bb2                	mv	s7,a2
  state = 0;
 514:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 516:	4481                	li	s1,0
 518:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 51a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 51e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 522:	06c00c93          	li	s9,108
 526:	a005                	j	546 <vprintf+0x5a>
        putc(fd, c0);
 528:	85ca                	mv	a1,s2
 52a:	855a                	mv	a0,s6
 52c:	f07ff0ef          	jal	432 <putc>
 530:	a019                	j	536 <vprintf+0x4a>
    } else if(state == '%'){
 532:	03598263          	beq	s3,s5,556 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 536:	2485                	addiw	s1,s1,1
 538:	8726                	mv	a4,s1
 53a:	009a07b3          	add	a5,s4,s1
 53e:	0007c903          	lbu	s2,0(a5)
 542:	22090a63          	beqz	s2,776 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 546:	0009079b          	sext.w	a5,s2
    if(state == 0){
 54a:	fe0994e3          	bnez	s3,532 <vprintf+0x46>
      if(c0 == '%'){
 54e:	fd579de3          	bne	a5,s5,528 <vprintf+0x3c>
        state = '%';
 552:	89be                	mv	s3,a5
 554:	b7cd                	j	536 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 556:	00ea06b3          	add	a3,s4,a4
 55a:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 55e:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 560:	c681                	beqz	a3,568 <vprintf+0x7c>
 562:	9752                	add	a4,a4,s4
 564:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 568:	05878363          	beq	a5,s8,5ae <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 56c:	05978d63          	beq	a5,s9,5c6 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 570:	07500713          	li	a4,117
 574:	0ee78763          	beq	a5,a4,662 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 578:	07800713          	li	a4,120
 57c:	12e78963          	beq	a5,a4,6ae <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 580:	07000713          	li	a4,112
 584:	14e78e63          	beq	a5,a4,6e0 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 588:	06300713          	li	a4,99
 58c:	18e78e63          	beq	a5,a4,728 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 590:	07300713          	li	a4,115
 594:	1ae78463          	beq	a5,a4,73c <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 598:	02500713          	li	a4,37
 59c:	04e79563          	bne	a5,a4,5e6 <vprintf+0xfa>
        putc(fd, '%');
 5a0:	02500593          	li	a1,37
 5a4:	855a                	mv	a0,s6
 5a6:	e8dff0ef          	jal	432 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5aa:	4981                	li	s3,0
 5ac:	b769                	j	536 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5ae:	008b8913          	addi	s2,s7,8
 5b2:	4685                	li	a3,1
 5b4:	4629                	li	a2,10
 5b6:	000ba583          	lw	a1,0(s7)
 5ba:	855a                	mv	a0,s6
 5bc:	e95ff0ef          	jal	450 <printint>
 5c0:	8bca                	mv	s7,s2
      state = 0;
 5c2:	4981                	li	s3,0
 5c4:	bf8d                	j	536 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5c6:	06400793          	li	a5,100
 5ca:	02f68963          	beq	a3,a5,5fc <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5ce:	06c00793          	li	a5,108
 5d2:	04f68263          	beq	a3,a5,616 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 5d6:	07500793          	li	a5,117
 5da:	0af68063          	beq	a3,a5,67a <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 5de:	07800793          	li	a5,120
 5e2:	0ef68263          	beq	a3,a5,6c6 <vprintf+0x1da>
        putc(fd, '%');
 5e6:	02500593          	li	a1,37
 5ea:	855a                	mv	a0,s6
 5ec:	e47ff0ef          	jal	432 <putc>
        putc(fd, c0);
 5f0:	85ca                	mv	a1,s2
 5f2:	855a                	mv	a0,s6
 5f4:	e3fff0ef          	jal	432 <putc>
      state = 0;
 5f8:	4981                	li	s3,0
 5fa:	bf35                	j	536 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5fc:	008b8913          	addi	s2,s7,8
 600:	4685                	li	a3,1
 602:	4629                	li	a2,10
 604:	000bb583          	ld	a1,0(s7)
 608:	855a                	mv	a0,s6
 60a:	e47ff0ef          	jal	450 <printint>
        i += 1;
 60e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 610:	8bca                	mv	s7,s2
      state = 0;
 612:	4981                	li	s3,0
        i += 1;
 614:	b70d                	j	536 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 616:	06400793          	li	a5,100
 61a:	02f60763          	beq	a2,a5,648 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 61e:	07500793          	li	a5,117
 622:	06f60963          	beq	a2,a5,694 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 626:	07800793          	li	a5,120
 62a:	faf61ee3          	bne	a2,a5,5e6 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 62e:	008b8913          	addi	s2,s7,8
 632:	4681                	li	a3,0
 634:	4641                	li	a2,16
 636:	000bb583          	ld	a1,0(s7)
 63a:	855a                	mv	a0,s6
 63c:	e15ff0ef          	jal	450 <printint>
        i += 2;
 640:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 642:	8bca                	mv	s7,s2
      state = 0;
 644:	4981                	li	s3,0
        i += 2;
 646:	bdc5                	j	536 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 648:	008b8913          	addi	s2,s7,8
 64c:	4685                	li	a3,1
 64e:	4629                	li	a2,10
 650:	000bb583          	ld	a1,0(s7)
 654:	855a                	mv	a0,s6
 656:	dfbff0ef          	jal	450 <printint>
        i += 2;
 65a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 65c:	8bca                	mv	s7,s2
      state = 0;
 65e:	4981                	li	s3,0
        i += 2;
 660:	bdd9                	j	536 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 662:	008b8913          	addi	s2,s7,8
 666:	4681                	li	a3,0
 668:	4629                	li	a2,10
 66a:	000be583          	lwu	a1,0(s7)
 66e:	855a                	mv	a0,s6
 670:	de1ff0ef          	jal	450 <printint>
 674:	8bca                	mv	s7,s2
      state = 0;
 676:	4981                	li	s3,0
 678:	bd7d                	j	536 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 67a:	008b8913          	addi	s2,s7,8
 67e:	4681                	li	a3,0
 680:	4629                	li	a2,10
 682:	000bb583          	ld	a1,0(s7)
 686:	855a                	mv	a0,s6
 688:	dc9ff0ef          	jal	450 <printint>
        i += 1;
 68c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 68e:	8bca                	mv	s7,s2
      state = 0;
 690:	4981                	li	s3,0
        i += 1;
 692:	b555                	j	536 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 694:	008b8913          	addi	s2,s7,8
 698:	4681                	li	a3,0
 69a:	4629                	li	a2,10
 69c:	000bb583          	ld	a1,0(s7)
 6a0:	855a                	mv	a0,s6
 6a2:	dafff0ef          	jal	450 <printint>
        i += 2;
 6a6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a8:	8bca                	mv	s7,s2
      state = 0;
 6aa:	4981                	li	s3,0
        i += 2;
 6ac:	b569                	j	536 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6ae:	008b8913          	addi	s2,s7,8
 6b2:	4681                	li	a3,0
 6b4:	4641                	li	a2,16
 6b6:	000be583          	lwu	a1,0(s7)
 6ba:	855a                	mv	a0,s6
 6bc:	d95ff0ef          	jal	450 <printint>
 6c0:	8bca                	mv	s7,s2
      state = 0;
 6c2:	4981                	li	s3,0
 6c4:	bd8d                	j	536 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c6:	008b8913          	addi	s2,s7,8
 6ca:	4681                	li	a3,0
 6cc:	4641                	li	a2,16
 6ce:	000bb583          	ld	a1,0(s7)
 6d2:	855a                	mv	a0,s6
 6d4:	d7dff0ef          	jal	450 <printint>
        i += 1;
 6d8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6da:	8bca                	mv	s7,s2
      state = 0;
 6dc:	4981                	li	s3,0
        i += 1;
 6de:	bda1                	j	536 <vprintf+0x4a>
 6e0:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6e2:	008b8d13          	addi	s10,s7,8
 6e6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6ea:	03000593          	li	a1,48
 6ee:	855a                	mv	a0,s6
 6f0:	d43ff0ef          	jal	432 <putc>
  putc(fd, 'x');
 6f4:	07800593          	li	a1,120
 6f8:	855a                	mv	a0,s6
 6fa:	d39ff0ef          	jal	432 <putc>
 6fe:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 700:	00000b97          	auipc	s7,0x0
 704:	2e0b8b93          	addi	s7,s7,736 # 9e0 <digits>
 708:	03c9d793          	srli	a5,s3,0x3c
 70c:	97de                	add	a5,a5,s7
 70e:	0007c583          	lbu	a1,0(a5)
 712:	855a                	mv	a0,s6
 714:	d1fff0ef          	jal	432 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 718:	0992                	slli	s3,s3,0x4
 71a:	397d                	addiw	s2,s2,-1
 71c:	fe0916e3          	bnez	s2,708 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 720:	8bea                	mv	s7,s10
      state = 0;
 722:	4981                	li	s3,0
 724:	6d02                	ld	s10,0(sp)
 726:	bd01                	j	536 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 728:	008b8913          	addi	s2,s7,8
 72c:	000bc583          	lbu	a1,0(s7)
 730:	855a                	mv	a0,s6
 732:	d01ff0ef          	jal	432 <putc>
 736:	8bca                	mv	s7,s2
      state = 0;
 738:	4981                	li	s3,0
 73a:	bbf5                	j	536 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 73c:	008b8993          	addi	s3,s7,8
 740:	000bb903          	ld	s2,0(s7)
 744:	00090f63          	beqz	s2,762 <vprintf+0x276>
        for(; *s; s++)
 748:	00094583          	lbu	a1,0(s2)
 74c:	c195                	beqz	a1,770 <vprintf+0x284>
          putc(fd, *s);
 74e:	855a                	mv	a0,s6
 750:	ce3ff0ef          	jal	432 <putc>
        for(; *s; s++)
 754:	0905                	addi	s2,s2,1
 756:	00094583          	lbu	a1,0(s2)
 75a:	f9f5                	bnez	a1,74e <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 75c:	8bce                	mv	s7,s3
      state = 0;
 75e:	4981                	li	s3,0
 760:	bbd9                	j	536 <vprintf+0x4a>
          s = "(null)";
 762:	00000917          	auipc	s2,0x0
 766:	27690913          	addi	s2,s2,630 # 9d8 <malloc+0x16a>
        for(; *s; s++)
 76a:	02800593          	li	a1,40
 76e:	b7c5                	j	74e <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 770:	8bce                	mv	s7,s3
      state = 0;
 772:	4981                	li	s3,0
 774:	b3c9                	j	536 <vprintf+0x4a>
 776:	64a6                	ld	s1,72(sp)
 778:	79e2                	ld	s3,56(sp)
 77a:	7a42                	ld	s4,48(sp)
 77c:	7aa2                	ld	s5,40(sp)
 77e:	7b02                	ld	s6,32(sp)
 780:	6be2                	ld	s7,24(sp)
 782:	6c42                	ld	s8,16(sp)
 784:	6ca2                	ld	s9,8(sp)
    }
  }
}
 786:	60e6                	ld	ra,88(sp)
 788:	6446                	ld	s0,80(sp)
 78a:	6906                	ld	s2,64(sp)
 78c:	6125                	addi	sp,sp,96
 78e:	8082                	ret

0000000000000790 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 790:	715d                	addi	sp,sp,-80
 792:	ec06                	sd	ra,24(sp)
 794:	e822                	sd	s0,16(sp)
 796:	1000                	addi	s0,sp,32
 798:	e010                	sd	a2,0(s0)
 79a:	e414                	sd	a3,8(s0)
 79c:	e818                	sd	a4,16(s0)
 79e:	ec1c                	sd	a5,24(s0)
 7a0:	03043023          	sd	a6,32(s0)
 7a4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7a8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7ac:	8622                	mv	a2,s0
 7ae:	d3fff0ef          	jal	4ec <vprintf>
}
 7b2:	60e2                	ld	ra,24(sp)
 7b4:	6442                	ld	s0,16(sp)
 7b6:	6161                	addi	sp,sp,80
 7b8:	8082                	ret

00000000000007ba <printf>:

void
printf(const char *fmt, ...)
{
 7ba:	711d                	addi	sp,sp,-96
 7bc:	ec06                	sd	ra,24(sp)
 7be:	e822                	sd	s0,16(sp)
 7c0:	1000                	addi	s0,sp,32
 7c2:	e40c                	sd	a1,8(s0)
 7c4:	e810                	sd	a2,16(s0)
 7c6:	ec14                	sd	a3,24(s0)
 7c8:	f018                	sd	a4,32(s0)
 7ca:	f41c                	sd	a5,40(s0)
 7cc:	03043823          	sd	a6,48(s0)
 7d0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7d4:	00840613          	addi	a2,s0,8
 7d8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7dc:	85aa                	mv	a1,a0
 7de:	4505                	li	a0,1
 7e0:	d0dff0ef          	jal	4ec <vprintf>
}
 7e4:	60e2                	ld	ra,24(sp)
 7e6:	6442                	ld	s0,16(sp)
 7e8:	6125                	addi	sp,sp,96
 7ea:	8082                	ret

00000000000007ec <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ec:	1141                	addi	sp,sp,-16
 7ee:	e422                	sd	s0,8(sp)
 7f0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7f2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f6:	00001797          	auipc	a5,0x1
 7fa:	80a7b783          	ld	a5,-2038(a5) # 1000 <freep>
 7fe:	a02d                	j	828 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 800:	4618                	lw	a4,8(a2)
 802:	9f2d                	addw	a4,a4,a1
 804:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 808:	6398                	ld	a4,0(a5)
 80a:	6310                	ld	a2,0(a4)
 80c:	a83d                	j	84a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 80e:	ff852703          	lw	a4,-8(a0)
 812:	9f31                	addw	a4,a4,a2
 814:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 816:	ff053683          	ld	a3,-16(a0)
 81a:	a091                	j	85e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 81c:	6398                	ld	a4,0(a5)
 81e:	00e7e463          	bltu	a5,a4,826 <free+0x3a>
 822:	00e6ea63          	bltu	a3,a4,836 <free+0x4a>
{
 826:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 828:	fed7fae3          	bgeu	a5,a3,81c <free+0x30>
 82c:	6398                	ld	a4,0(a5)
 82e:	00e6e463          	bltu	a3,a4,836 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 832:	fee7eae3          	bltu	a5,a4,826 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 836:	ff852583          	lw	a1,-8(a0)
 83a:	6390                	ld	a2,0(a5)
 83c:	02059813          	slli	a6,a1,0x20
 840:	01c85713          	srli	a4,a6,0x1c
 844:	9736                	add	a4,a4,a3
 846:	fae60de3          	beq	a2,a4,800 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 84a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 84e:	4790                	lw	a2,8(a5)
 850:	02061593          	slli	a1,a2,0x20
 854:	01c5d713          	srli	a4,a1,0x1c
 858:	973e                	add	a4,a4,a5
 85a:	fae68ae3          	beq	a3,a4,80e <free+0x22>
    p->s.ptr = bp->s.ptr;
 85e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 860:	00000717          	auipc	a4,0x0
 864:	7af73023          	sd	a5,1952(a4) # 1000 <freep>
}
 868:	6422                	ld	s0,8(sp)
 86a:	0141                	addi	sp,sp,16
 86c:	8082                	ret

000000000000086e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 86e:	7139                	addi	sp,sp,-64
 870:	fc06                	sd	ra,56(sp)
 872:	f822                	sd	s0,48(sp)
 874:	f426                	sd	s1,40(sp)
 876:	ec4e                	sd	s3,24(sp)
 878:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 87a:	02051493          	slli	s1,a0,0x20
 87e:	9081                	srli	s1,s1,0x20
 880:	04bd                	addi	s1,s1,15
 882:	8091                	srli	s1,s1,0x4
 884:	0014899b          	addiw	s3,s1,1
 888:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 88a:	00000517          	auipc	a0,0x0
 88e:	77653503          	ld	a0,1910(a0) # 1000 <freep>
 892:	c915                	beqz	a0,8c6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 894:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 896:	4798                	lw	a4,8(a5)
 898:	08977a63          	bgeu	a4,s1,92c <malloc+0xbe>
 89c:	f04a                	sd	s2,32(sp)
 89e:	e852                	sd	s4,16(sp)
 8a0:	e456                	sd	s5,8(sp)
 8a2:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8a4:	8a4e                	mv	s4,s3
 8a6:	0009871b          	sext.w	a4,s3
 8aa:	6685                	lui	a3,0x1
 8ac:	00d77363          	bgeu	a4,a3,8b2 <malloc+0x44>
 8b0:	6a05                	lui	s4,0x1
 8b2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8b6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8ba:	00000917          	auipc	s2,0x0
 8be:	74690913          	addi	s2,s2,1862 # 1000 <freep>
  if(p == SBRK_ERROR)
 8c2:	5afd                	li	s5,-1
 8c4:	a081                	j	904 <malloc+0x96>
 8c6:	f04a                	sd	s2,32(sp)
 8c8:	e852                	sd	s4,16(sp)
 8ca:	e456                	sd	s5,8(sp)
 8cc:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8ce:	00000797          	auipc	a5,0x0
 8d2:	74278793          	addi	a5,a5,1858 # 1010 <base>
 8d6:	00000717          	auipc	a4,0x0
 8da:	72f73523          	sd	a5,1834(a4) # 1000 <freep>
 8de:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8e0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8e4:	b7c1                	j	8a4 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 8e6:	6398                	ld	a4,0(a5)
 8e8:	e118                	sd	a4,0(a0)
 8ea:	a8a9                	j	944 <malloc+0xd6>
  hp->s.size = nu;
 8ec:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8f0:	0541                	addi	a0,a0,16
 8f2:	efbff0ef          	jal	7ec <free>
  return freep;
 8f6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8fa:	c12d                	beqz	a0,95c <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8fc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8fe:	4798                	lw	a4,8(a5)
 900:	02977263          	bgeu	a4,s1,924 <malloc+0xb6>
    if(p == freep)
 904:	00093703          	ld	a4,0(s2)
 908:	853e                	mv	a0,a5
 90a:	fef719e3          	bne	a4,a5,8fc <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 90e:	8552                	mv	a0,s4
 910:	a2fff0ef          	jal	33e <sbrk>
  if(p == SBRK_ERROR)
 914:	fd551ce3          	bne	a0,s5,8ec <malloc+0x7e>
        return 0;
 918:	4501                	li	a0,0
 91a:	7902                	ld	s2,32(sp)
 91c:	6a42                	ld	s4,16(sp)
 91e:	6aa2                	ld	s5,8(sp)
 920:	6b02                	ld	s6,0(sp)
 922:	a03d                	j	950 <malloc+0xe2>
 924:	7902                	ld	s2,32(sp)
 926:	6a42                	ld	s4,16(sp)
 928:	6aa2                	ld	s5,8(sp)
 92a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 92c:	fae48de3          	beq	s1,a4,8e6 <malloc+0x78>
        p->s.size -= nunits;
 930:	4137073b          	subw	a4,a4,s3
 934:	c798                	sw	a4,8(a5)
        p += p->s.size;
 936:	02071693          	slli	a3,a4,0x20
 93a:	01c6d713          	srli	a4,a3,0x1c
 93e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 940:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 944:	00000717          	auipc	a4,0x0
 948:	6aa73e23          	sd	a0,1724(a4) # 1000 <freep>
      return (void*)(p + 1);
 94c:	01078513          	addi	a0,a5,16
  }
}
 950:	70e2                	ld	ra,56(sp)
 952:	7442                	ld	s0,48(sp)
 954:	74a2                	ld	s1,40(sp)
 956:	69e2                	ld	s3,24(sp)
 958:	6121                	addi	sp,sp,64
 95a:	8082                	ret
 95c:	7902                	ld	s2,32(sp)
 95e:	6a42                	ld	s4,16(sp)
 960:	6aa2                	ld	s5,8(sp)
 962:	6b02                	ld	s6,0(sp)
 964:	b7f5                	j	950 <malloc+0xe2>
