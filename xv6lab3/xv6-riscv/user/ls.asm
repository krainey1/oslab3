
user/_ls:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "kernel/fs.h"
#include "kernel/fcntl.h"

char*
fmtname(char *path)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	1800                	addi	s0,sp,48
   a:	84aa                	mv	s1,a0
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   c:	2b8000ef          	jal	2c4 <strlen>
  10:	02051793          	slli	a5,a0,0x20
  14:	9381                	srli	a5,a5,0x20
  16:	97a6                	add	a5,a5,s1
  18:	02f00693          	li	a3,47
  1c:	0097e963          	bltu	a5,s1,2e <fmtname+0x2e>
  20:	0007c703          	lbu	a4,0(a5)
  24:	00d70563          	beq	a4,a3,2e <fmtname+0x2e>
  28:	17fd                	addi	a5,a5,-1
  2a:	fe97fbe3          	bgeu	a5,s1,20 <fmtname+0x20>
    ;
  p++;
  2e:	00178493          	addi	s1,a5,1

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  32:	8526                	mv	a0,s1
  34:	290000ef          	jal	2c4 <strlen>
  38:	2501                	sext.w	a0,a0
  3a:	47b5                	li	a5,13
  3c:	00a7f863          	bgeu	a5,a0,4c <fmtname+0x4c>
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  buf[sizeof(buf)-1] = '\0';
  return buf;
}
  40:	8526                	mv	a0,s1
  42:	70a2                	ld	ra,40(sp)
  44:	7402                	ld	s0,32(sp)
  46:	64e2                	ld	s1,24(sp)
  48:	6145                	addi	sp,sp,48
  4a:	8082                	ret
  4c:	e84a                	sd	s2,16(sp)
  4e:	e44e                	sd	s3,8(sp)
  memmove(buf, p, strlen(p));
  50:	8526                	mv	a0,s1
  52:	272000ef          	jal	2c4 <strlen>
  56:	00002997          	auipc	s3,0x2
  5a:	fba98993          	addi	s3,s3,-70 # 2010 <buf.0>
  5e:	0005061b          	sext.w	a2,a0
  62:	85a6                	mv	a1,s1
  64:	854e                	mv	a0,s3
  66:	3c0000ef          	jal	426 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  6a:	8526                	mv	a0,s1
  6c:	258000ef          	jal	2c4 <strlen>
  70:	0005091b          	sext.w	s2,a0
  74:	8526                	mv	a0,s1
  76:	24e000ef          	jal	2c4 <strlen>
  7a:	1902                	slli	s2,s2,0x20
  7c:	02095913          	srli	s2,s2,0x20
  80:	4639                	li	a2,14
  82:	9e09                	subw	a2,a2,a0
  84:	02000593          	li	a1,32
  88:	01298533          	add	a0,s3,s2
  8c:	262000ef          	jal	2ee <memset>
  buf[sizeof(buf)-1] = '\0';
  90:	00098723          	sb	zero,14(s3)
  return buf;
  94:	84ce                	mv	s1,s3
  96:	6942                	ld	s2,16(sp)
  98:	69a2                	ld	s3,8(sp)
  9a:	b75d                	j	40 <fmtname+0x40>

000000000000009c <ls>:

void
ls(char *path)
{
  9c:	d9010113          	addi	sp,sp,-624
  a0:	26113423          	sd	ra,616(sp)
  a4:	26813023          	sd	s0,608(sp)
  a8:	25213823          	sd	s2,592(sp)
  ac:	1c80                	addi	s0,sp,624
  ae:	892a                	mv	s2,a0
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, O_RDONLY)) < 0){
  b0:	4581                	li	a1,0
  b2:	48e000ef          	jal	540 <open>
  b6:	06054363          	bltz	a0,11c <ls+0x80>
  ba:	24913c23          	sd	s1,600(sp)
  be:	84aa                	mv	s1,a0
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
  c0:	d9840593          	addi	a1,s0,-616
  c4:	494000ef          	jal	558 <fstat>
  c8:	06054363          	bltz	a0,12e <ls+0x92>
    fprintf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
  cc:	da041783          	lh	a5,-608(s0)
  d0:	4705                	li	a4,1
  d2:	06e78c63          	beq	a5,a4,14a <ls+0xae>
  d6:	37f9                	addiw	a5,a5,-2
  d8:	17c2                	slli	a5,a5,0x30
  da:	93c1                	srli	a5,a5,0x30
  dc:	02f76263          	bltu	a4,a5,100 <ls+0x64>
  case T_DEVICE:
  case T_FILE:
    printf("%s %d %d %d\n", fmtname(path), st.type, st.ino, (int) st.size);
  e0:	854a                	mv	a0,s2
  e2:	f1fff0ef          	jal	0 <fmtname>
  e6:	85aa                	mv	a1,a0
  e8:	da842703          	lw	a4,-600(s0)
  ec:	d9c42683          	lw	a3,-612(s0)
  f0:	da041603          	lh	a2,-608(s0)
  f4:	00001517          	auipc	a0,0x1
  f8:	a3c50513          	addi	a0,a0,-1476 # b30 <malloc+0x134>
  fc:	04d000ef          	jal	948 <printf>
      }
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
    }
    break;
  }
  close(fd);
 100:	8526                	mv	a0,s1
 102:	426000ef          	jal	528 <close>
 106:	25813483          	ld	s1,600(sp)
}
 10a:	26813083          	ld	ra,616(sp)
 10e:	26013403          	ld	s0,608(sp)
 112:	25013903          	ld	s2,592(sp)
 116:	27010113          	addi	sp,sp,624
 11a:	8082                	ret
    fprintf(2, "ls: cannot open %s\n", path);
 11c:	864a                	mv	a2,s2
 11e:	00001597          	auipc	a1,0x1
 122:	9e258593          	addi	a1,a1,-1566 # b00 <malloc+0x104>
 126:	4509                	li	a0,2
 128:	7f6000ef          	jal	91e <fprintf>
    return;
 12c:	bff9                	j	10a <ls+0x6e>
    fprintf(2, "ls: cannot stat %s\n", path);
 12e:	864a                	mv	a2,s2
 130:	00001597          	auipc	a1,0x1
 134:	9e858593          	addi	a1,a1,-1560 # b18 <malloc+0x11c>
 138:	4509                	li	a0,2
 13a:	7e4000ef          	jal	91e <fprintf>
    close(fd);
 13e:	8526                	mv	a0,s1
 140:	3e8000ef          	jal	528 <close>
    return;
 144:	25813483          	ld	s1,600(sp)
 148:	b7c9                	j	10a <ls+0x6e>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 14a:	854a                	mv	a0,s2
 14c:	178000ef          	jal	2c4 <strlen>
 150:	2541                	addiw	a0,a0,16
 152:	20000793          	li	a5,512
 156:	00a7f963          	bgeu	a5,a0,168 <ls+0xcc>
      printf("ls: path too long\n");
 15a:	00001517          	auipc	a0,0x1
 15e:	9e650513          	addi	a0,a0,-1562 # b40 <malloc+0x144>
 162:	7e6000ef          	jal	948 <printf>
      break;
 166:	bf69                	j	100 <ls+0x64>
 168:	25313423          	sd	s3,584(sp)
 16c:	25413023          	sd	s4,576(sp)
 170:	23513c23          	sd	s5,568(sp)
    strcpy(buf, path);
 174:	85ca                	mv	a1,s2
 176:	dc040513          	addi	a0,s0,-576
 17a:	102000ef          	jal	27c <strcpy>
    p = buf+strlen(buf);
 17e:	dc040513          	addi	a0,s0,-576
 182:	142000ef          	jal	2c4 <strlen>
 186:	1502                	slli	a0,a0,0x20
 188:	9101                	srli	a0,a0,0x20
 18a:	dc040793          	addi	a5,s0,-576
 18e:	00a78933          	add	s2,a5,a0
    *p++ = '/';
 192:	00190993          	addi	s3,s2,1
 196:	02f00793          	li	a5,47
 19a:	00f90023          	sb	a5,0(s2)
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
 19e:	00001a17          	auipc	s4,0x1
 1a2:	992a0a13          	addi	s4,s4,-1646 # b30 <malloc+0x134>
        printf("ls: cannot stat %s\n", buf);
 1a6:	00001a97          	auipc	s5,0x1
 1aa:	972a8a93          	addi	s5,s5,-1678 # b18 <malloc+0x11c>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1ae:	a031                	j	1ba <ls+0x11e>
        printf("ls: cannot stat %s\n", buf);
 1b0:	dc040593          	addi	a1,s0,-576
 1b4:	8556                	mv	a0,s5
 1b6:	792000ef          	jal	948 <printf>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1ba:	4641                	li	a2,16
 1bc:	db040593          	addi	a1,s0,-592
 1c0:	8526                	mv	a0,s1
 1c2:	356000ef          	jal	518 <read>
 1c6:	47c1                	li	a5,16
 1c8:	04f51463          	bne	a0,a5,210 <ls+0x174>
      if(de.inum == 0)
 1cc:	db045783          	lhu	a5,-592(s0)
 1d0:	d7ed                	beqz	a5,1ba <ls+0x11e>
      memmove(p, de.name, DIRSIZ);
 1d2:	4639                	li	a2,14
 1d4:	db240593          	addi	a1,s0,-590
 1d8:	854e                	mv	a0,s3
 1da:	24c000ef          	jal	426 <memmove>
      p[DIRSIZ] = 0;
 1de:	000907a3          	sb	zero,15(s2)
      if(stat(buf, &st) < 0){
 1e2:	d9840593          	addi	a1,s0,-616
 1e6:	dc040513          	addi	a0,s0,-576
 1ea:	1ba000ef          	jal	3a4 <stat>
 1ee:	fc0541e3          	bltz	a0,1b0 <ls+0x114>
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
 1f2:	dc040513          	addi	a0,s0,-576
 1f6:	e0bff0ef          	jal	0 <fmtname>
 1fa:	85aa                	mv	a1,a0
 1fc:	da842703          	lw	a4,-600(s0)
 200:	d9c42683          	lw	a3,-612(s0)
 204:	da041603          	lh	a2,-608(s0)
 208:	8552                	mv	a0,s4
 20a:	73e000ef          	jal	948 <printf>
 20e:	b775                	j	1ba <ls+0x11e>
 210:	24813983          	ld	s3,584(sp)
 214:	24013a03          	ld	s4,576(sp)
 218:	23813a83          	ld	s5,568(sp)
 21c:	b5d5                	j	100 <ls+0x64>

000000000000021e <main>:

int
main(int argc, char *argv[])
{
 21e:	1101                	addi	sp,sp,-32
 220:	ec06                	sd	ra,24(sp)
 222:	e822                	sd	s0,16(sp)
 224:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
 226:	4785                	li	a5,1
 228:	02a7d763          	bge	a5,a0,256 <main+0x38>
 22c:	e426                	sd	s1,8(sp)
 22e:	e04a                	sd	s2,0(sp)
 230:	00858493          	addi	s1,a1,8
 234:	ffe5091b          	addiw	s2,a0,-2
 238:	02091793          	slli	a5,s2,0x20
 23c:	01d7d913          	srli	s2,a5,0x1d
 240:	05c1                	addi	a1,a1,16
 242:	992e                	add	s2,s2,a1
    ls(".");
    exit(0);
  }
  for(i=1; i<argc; i++)
    ls(argv[i]);
 244:	6088                	ld	a0,0(s1)
 246:	e57ff0ef          	jal	9c <ls>
  for(i=1; i<argc; i++)
 24a:	04a1                	addi	s1,s1,8
 24c:	ff249ce3          	bne	s1,s2,244 <main+0x26>
  exit(0);
 250:	4501                	li	a0,0
 252:	2ae000ef          	jal	500 <exit>
 256:	e426                	sd	s1,8(sp)
 258:	e04a                	sd	s2,0(sp)
    ls(".");
 25a:	00001517          	auipc	a0,0x1
 25e:	8fe50513          	addi	a0,a0,-1794 # b58 <malloc+0x15c>
 262:	e3bff0ef          	jal	9c <ls>
    exit(0);
 266:	4501                	li	a0,0
 268:	298000ef          	jal	500 <exit>

000000000000026c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 26c:	1141                	addi	sp,sp,-16
 26e:	e406                	sd	ra,8(sp)
 270:	e022                	sd	s0,0(sp)
 272:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 274:	fabff0ef          	jal	21e <main>
  exit(r);
 278:	288000ef          	jal	500 <exit>

000000000000027c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 27c:	1141                	addi	sp,sp,-16
 27e:	e422                	sd	s0,8(sp)
 280:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 282:	87aa                	mv	a5,a0
 284:	0585                	addi	a1,a1,1
 286:	0785                	addi	a5,a5,1
 288:	fff5c703          	lbu	a4,-1(a1)
 28c:	fee78fa3          	sb	a4,-1(a5)
 290:	fb75                	bnez	a4,284 <strcpy+0x8>
    ;
  return os;
}
 292:	6422                	ld	s0,8(sp)
 294:	0141                	addi	sp,sp,16
 296:	8082                	ret

0000000000000298 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 298:	1141                	addi	sp,sp,-16
 29a:	e422                	sd	s0,8(sp)
 29c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 29e:	00054783          	lbu	a5,0(a0)
 2a2:	cb91                	beqz	a5,2b6 <strcmp+0x1e>
 2a4:	0005c703          	lbu	a4,0(a1)
 2a8:	00f71763          	bne	a4,a5,2b6 <strcmp+0x1e>
    p++, q++;
 2ac:	0505                	addi	a0,a0,1
 2ae:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2b0:	00054783          	lbu	a5,0(a0)
 2b4:	fbe5                	bnez	a5,2a4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2b6:	0005c503          	lbu	a0,0(a1)
}
 2ba:	40a7853b          	subw	a0,a5,a0
 2be:	6422                	ld	s0,8(sp)
 2c0:	0141                	addi	sp,sp,16
 2c2:	8082                	ret

00000000000002c4 <strlen>:

uint
strlen(const char *s)
{
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e422                	sd	s0,8(sp)
 2c8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2ca:	00054783          	lbu	a5,0(a0)
 2ce:	cf91                	beqz	a5,2ea <strlen+0x26>
 2d0:	0505                	addi	a0,a0,1
 2d2:	87aa                	mv	a5,a0
 2d4:	86be                	mv	a3,a5
 2d6:	0785                	addi	a5,a5,1
 2d8:	fff7c703          	lbu	a4,-1(a5)
 2dc:	ff65                	bnez	a4,2d4 <strlen+0x10>
 2de:	40a6853b          	subw	a0,a3,a0
 2e2:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 2e4:	6422                	ld	s0,8(sp)
 2e6:	0141                	addi	sp,sp,16
 2e8:	8082                	ret
  for(n = 0; s[n]; n++)
 2ea:	4501                	li	a0,0
 2ec:	bfe5                	j	2e4 <strlen+0x20>

00000000000002ee <memset>:

void*
memset(void *dst, int c, uint n)
{
 2ee:	1141                	addi	sp,sp,-16
 2f0:	e422                	sd	s0,8(sp)
 2f2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2f4:	ca19                	beqz	a2,30a <memset+0x1c>
 2f6:	87aa                	mv	a5,a0
 2f8:	1602                	slli	a2,a2,0x20
 2fa:	9201                	srli	a2,a2,0x20
 2fc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 300:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 304:	0785                	addi	a5,a5,1
 306:	fee79de3          	bne	a5,a4,300 <memset+0x12>
  }
  return dst;
}
 30a:	6422                	ld	s0,8(sp)
 30c:	0141                	addi	sp,sp,16
 30e:	8082                	ret

0000000000000310 <strchr>:

char*
strchr(const char *s, char c)
{
 310:	1141                	addi	sp,sp,-16
 312:	e422                	sd	s0,8(sp)
 314:	0800                	addi	s0,sp,16
  for(; *s; s++)
 316:	00054783          	lbu	a5,0(a0)
 31a:	cb99                	beqz	a5,330 <strchr+0x20>
    if(*s == c)
 31c:	00f58763          	beq	a1,a5,32a <strchr+0x1a>
  for(; *s; s++)
 320:	0505                	addi	a0,a0,1
 322:	00054783          	lbu	a5,0(a0)
 326:	fbfd                	bnez	a5,31c <strchr+0xc>
      return (char*)s;
  return 0;
 328:	4501                	li	a0,0
}
 32a:	6422                	ld	s0,8(sp)
 32c:	0141                	addi	sp,sp,16
 32e:	8082                	ret
  return 0;
 330:	4501                	li	a0,0
 332:	bfe5                	j	32a <strchr+0x1a>

0000000000000334 <gets>:

char*
gets(char *buf, int max)
{
 334:	711d                	addi	sp,sp,-96
 336:	ec86                	sd	ra,88(sp)
 338:	e8a2                	sd	s0,80(sp)
 33a:	e4a6                	sd	s1,72(sp)
 33c:	e0ca                	sd	s2,64(sp)
 33e:	fc4e                	sd	s3,56(sp)
 340:	f852                	sd	s4,48(sp)
 342:	f456                	sd	s5,40(sp)
 344:	f05a                	sd	s6,32(sp)
 346:	ec5e                	sd	s7,24(sp)
 348:	1080                	addi	s0,sp,96
 34a:	8baa                	mv	s7,a0
 34c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 34e:	892a                	mv	s2,a0
 350:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 352:	4aa9                	li	s5,10
 354:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 356:	89a6                	mv	s3,s1
 358:	2485                	addiw	s1,s1,1
 35a:	0344d663          	bge	s1,s4,386 <gets+0x52>
    cc = read(0, &c, 1);
 35e:	4605                	li	a2,1
 360:	faf40593          	addi	a1,s0,-81
 364:	4501                	li	a0,0
 366:	1b2000ef          	jal	518 <read>
    if(cc < 1)
 36a:	00a05e63          	blez	a0,386 <gets+0x52>
    buf[i++] = c;
 36e:	faf44783          	lbu	a5,-81(s0)
 372:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 376:	01578763          	beq	a5,s5,384 <gets+0x50>
 37a:	0905                	addi	s2,s2,1
 37c:	fd679de3          	bne	a5,s6,356 <gets+0x22>
    buf[i++] = c;
 380:	89a6                	mv	s3,s1
 382:	a011                	j	386 <gets+0x52>
 384:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 386:	99de                	add	s3,s3,s7
 388:	00098023          	sb	zero,0(s3)
  return buf;
}
 38c:	855e                	mv	a0,s7
 38e:	60e6                	ld	ra,88(sp)
 390:	6446                	ld	s0,80(sp)
 392:	64a6                	ld	s1,72(sp)
 394:	6906                	ld	s2,64(sp)
 396:	79e2                	ld	s3,56(sp)
 398:	7a42                	ld	s4,48(sp)
 39a:	7aa2                	ld	s5,40(sp)
 39c:	7b02                	ld	s6,32(sp)
 39e:	6be2                	ld	s7,24(sp)
 3a0:	6125                	addi	sp,sp,96
 3a2:	8082                	ret

00000000000003a4 <stat>:

int
stat(const char *n, struct stat *st)
{
 3a4:	1101                	addi	sp,sp,-32
 3a6:	ec06                	sd	ra,24(sp)
 3a8:	e822                	sd	s0,16(sp)
 3aa:	e04a                	sd	s2,0(sp)
 3ac:	1000                	addi	s0,sp,32
 3ae:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3b0:	4581                	li	a1,0
 3b2:	18e000ef          	jal	540 <open>
  if(fd < 0)
 3b6:	02054263          	bltz	a0,3da <stat+0x36>
 3ba:	e426                	sd	s1,8(sp)
 3bc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3be:	85ca                	mv	a1,s2
 3c0:	198000ef          	jal	558 <fstat>
 3c4:	892a                	mv	s2,a0
  close(fd);
 3c6:	8526                	mv	a0,s1
 3c8:	160000ef          	jal	528 <close>
  return r;
 3cc:	64a2                	ld	s1,8(sp)
}
 3ce:	854a                	mv	a0,s2
 3d0:	60e2                	ld	ra,24(sp)
 3d2:	6442                	ld	s0,16(sp)
 3d4:	6902                	ld	s2,0(sp)
 3d6:	6105                	addi	sp,sp,32
 3d8:	8082                	ret
    return -1;
 3da:	597d                	li	s2,-1
 3dc:	bfcd                	j	3ce <stat+0x2a>

00000000000003de <atoi>:

int
atoi(const char *s)
{
 3de:	1141                	addi	sp,sp,-16
 3e0:	e422                	sd	s0,8(sp)
 3e2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3e4:	00054683          	lbu	a3,0(a0)
 3e8:	fd06879b          	addiw	a5,a3,-48
 3ec:	0ff7f793          	zext.b	a5,a5
 3f0:	4625                	li	a2,9
 3f2:	02f66863          	bltu	a2,a5,422 <atoi+0x44>
 3f6:	872a                	mv	a4,a0
  n = 0;
 3f8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3fa:	0705                	addi	a4,a4,1
 3fc:	0025179b          	slliw	a5,a0,0x2
 400:	9fa9                	addw	a5,a5,a0
 402:	0017979b          	slliw	a5,a5,0x1
 406:	9fb5                	addw	a5,a5,a3
 408:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 40c:	00074683          	lbu	a3,0(a4)
 410:	fd06879b          	addiw	a5,a3,-48
 414:	0ff7f793          	zext.b	a5,a5
 418:	fef671e3          	bgeu	a2,a5,3fa <atoi+0x1c>
  return n;
}
 41c:	6422                	ld	s0,8(sp)
 41e:	0141                	addi	sp,sp,16
 420:	8082                	ret
  n = 0;
 422:	4501                	li	a0,0
 424:	bfe5                	j	41c <atoi+0x3e>

0000000000000426 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 426:	1141                	addi	sp,sp,-16
 428:	e422                	sd	s0,8(sp)
 42a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 42c:	02b57463          	bgeu	a0,a1,454 <memmove+0x2e>
    while(n-- > 0)
 430:	00c05f63          	blez	a2,44e <memmove+0x28>
 434:	1602                	slli	a2,a2,0x20
 436:	9201                	srli	a2,a2,0x20
 438:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 43c:	872a                	mv	a4,a0
      *dst++ = *src++;
 43e:	0585                	addi	a1,a1,1
 440:	0705                	addi	a4,a4,1
 442:	fff5c683          	lbu	a3,-1(a1)
 446:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 44a:	fef71ae3          	bne	a4,a5,43e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 44e:	6422                	ld	s0,8(sp)
 450:	0141                	addi	sp,sp,16
 452:	8082                	ret
    dst += n;
 454:	00c50733          	add	a4,a0,a2
    src += n;
 458:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 45a:	fec05ae3          	blez	a2,44e <memmove+0x28>
 45e:	fff6079b          	addiw	a5,a2,-1
 462:	1782                	slli	a5,a5,0x20
 464:	9381                	srli	a5,a5,0x20
 466:	fff7c793          	not	a5,a5
 46a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 46c:	15fd                	addi	a1,a1,-1
 46e:	177d                	addi	a4,a4,-1
 470:	0005c683          	lbu	a3,0(a1)
 474:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 478:	fee79ae3          	bne	a5,a4,46c <memmove+0x46>
 47c:	bfc9                	j	44e <memmove+0x28>

000000000000047e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 47e:	1141                	addi	sp,sp,-16
 480:	e422                	sd	s0,8(sp)
 482:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 484:	ca05                	beqz	a2,4b4 <memcmp+0x36>
 486:	fff6069b          	addiw	a3,a2,-1
 48a:	1682                	slli	a3,a3,0x20
 48c:	9281                	srli	a3,a3,0x20
 48e:	0685                	addi	a3,a3,1
 490:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 492:	00054783          	lbu	a5,0(a0)
 496:	0005c703          	lbu	a4,0(a1)
 49a:	00e79863          	bne	a5,a4,4aa <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 49e:	0505                	addi	a0,a0,1
    p2++;
 4a0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4a2:	fed518e3          	bne	a0,a3,492 <memcmp+0x14>
  }
  return 0;
 4a6:	4501                	li	a0,0
 4a8:	a019                	j	4ae <memcmp+0x30>
      return *p1 - *p2;
 4aa:	40e7853b          	subw	a0,a5,a4
}
 4ae:	6422                	ld	s0,8(sp)
 4b0:	0141                	addi	sp,sp,16
 4b2:	8082                	ret
  return 0;
 4b4:	4501                	li	a0,0
 4b6:	bfe5                	j	4ae <memcmp+0x30>

00000000000004b8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4b8:	1141                	addi	sp,sp,-16
 4ba:	e406                	sd	ra,8(sp)
 4bc:	e022                	sd	s0,0(sp)
 4be:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4c0:	f67ff0ef          	jal	426 <memmove>
}
 4c4:	60a2                	ld	ra,8(sp)
 4c6:	6402                	ld	s0,0(sp)
 4c8:	0141                	addi	sp,sp,16
 4ca:	8082                	ret

00000000000004cc <sbrk>:

char *
sbrk(int n) {
 4cc:	1141                	addi	sp,sp,-16
 4ce:	e406                	sd	ra,8(sp)
 4d0:	e022                	sd	s0,0(sp)
 4d2:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4d4:	4585                	li	a1,1
 4d6:	0b2000ef          	jal	588 <sys_sbrk>
}
 4da:	60a2                	ld	ra,8(sp)
 4dc:	6402                	ld	s0,0(sp)
 4de:	0141                	addi	sp,sp,16
 4e0:	8082                	ret

00000000000004e2 <sbrklazy>:

char *
sbrklazy(int n) {
 4e2:	1141                	addi	sp,sp,-16
 4e4:	e406                	sd	ra,8(sp)
 4e6:	e022                	sd	s0,0(sp)
 4e8:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4ea:	4589                	li	a1,2
 4ec:	09c000ef          	jal	588 <sys_sbrk>
}
 4f0:	60a2                	ld	ra,8(sp)
 4f2:	6402                	ld	s0,0(sp)
 4f4:	0141                	addi	sp,sp,16
 4f6:	8082                	ret

00000000000004f8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4f8:	4885                	li	a7,1
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <exit>:
.global exit
exit:
 li a7, SYS_exit
 500:	4889                	li	a7,2
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <wait>:
.global wait
wait:
 li a7, SYS_wait
 508:	488d                	li	a7,3
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 510:	4891                	li	a7,4
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <read>:
.global read
read:
 li a7, SYS_read
 518:	4895                	li	a7,5
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <write>:
.global write
write:
 li a7, SYS_write
 520:	48c1                	li	a7,16
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <close>:
.global close
close:
 li a7, SYS_close
 528:	48d5                	li	a7,21
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <kill>:
.global kill
kill:
 li a7, SYS_kill
 530:	4899                	li	a7,6
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <exec>:
.global exec
exec:
 li a7, SYS_exec
 538:	489d                	li	a7,7
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <open>:
.global open
open:
 li a7, SYS_open
 540:	48bd                	li	a7,15
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 548:	48c5                	li	a7,17
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 550:	48c9                	li	a7,18
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 558:	48a1                	li	a7,8
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <link>:
.global link
link:
 li a7, SYS_link
 560:	48cd                	li	a7,19
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 568:	48d1                	li	a7,20
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 570:	48a5                	li	a7,9
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <dup>:
.global dup
dup:
 li a7, SYS_dup
 578:	48a9                	li	a7,10
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 580:	48ad                	li	a7,11
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 588:	48b1                	li	a7,12
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <pause>:
.global pause
pause:
 li a7, SYS_pause
 590:	48b5                	li	a7,13
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 598:	48b9                	li	a7,14
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <trace>:
.global trace
trace:
 li a7, SYS_trace
 5a0:	48d9                	li	a7,22
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
 5a8:	48dd                	li	a7,23
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <get_priority>:
.global get_priority
get_priority:
 li a7, SYS_get_priority
 5b0:	48e1                	li	a7,24
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <cps>:
.global cps
cps:
 li a7, SYS_cps
 5b8:	48e5                	li	a7,25
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5c0:	1101                	addi	sp,sp,-32
 5c2:	ec06                	sd	ra,24(sp)
 5c4:	e822                	sd	s0,16(sp)
 5c6:	1000                	addi	s0,sp,32
 5c8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5cc:	4605                	li	a2,1
 5ce:	fef40593          	addi	a1,s0,-17
 5d2:	f4fff0ef          	jal	520 <write>
}
 5d6:	60e2                	ld	ra,24(sp)
 5d8:	6442                	ld	s0,16(sp)
 5da:	6105                	addi	sp,sp,32
 5dc:	8082                	ret

00000000000005de <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 5de:	715d                	addi	sp,sp,-80
 5e0:	e486                	sd	ra,72(sp)
 5e2:	e0a2                	sd	s0,64(sp)
 5e4:	f84a                	sd	s2,48(sp)
 5e6:	0880                	addi	s0,sp,80
 5e8:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 5ea:	c299                	beqz	a3,5f0 <printint+0x12>
 5ec:	0805c363          	bltz	a1,672 <printint+0x94>
  neg = 0;
 5f0:	4881                	li	a7,0
 5f2:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 5f6:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 5f8:	00000517          	auipc	a0,0x0
 5fc:	57050513          	addi	a0,a0,1392 # b68 <digits>
 600:	883e                	mv	a6,a5
 602:	2785                	addiw	a5,a5,1
 604:	02c5f733          	remu	a4,a1,a2
 608:	972a                	add	a4,a4,a0
 60a:	00074703          	lbu	a4,0(a4)
 60e:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 612:	872e                	mv	a4,a1
 614:	02c5d5b3          	divu	a1,a1,a2
 618:	0685                	addi	a3,a3,1
 61a:	fec773e3          	bgeu	a4,a2,600 <printint+0x22>
  if(neg)
 61e:	00088b63          	beqz	a7,634 <printint+0x56>
    buf[i++] = '-';
 622:	fd078793          	addi	a5,a5,-48
 626:	97a2                	add	a5,a5,s0
 628:	02d00713          	li	a4,45
 62c:	fee78423          	sb	a4,-24(a5)
 630:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 634:	02f05a63          	blez	a5,668 <printint+0x8a>
 638:	fc26                	sd	s1,56(sp)
 63a:	f44e                	sd	s3,40(sp)
 63c:	fb840713          	addi	a4,s0,-72
 640:	00f704b3          	add	s1,a4,a5
 644:	fff70993          	addi	s3,a4,-1
 648:	99be                	add	s3,s3,a5
 64a:	37fd                	addiw	a5,a5,-1
 64c:	1782                	slli	a5,a5,0x20
 64e:	9381                	srli	a5,a5,0x20
 650:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 654:	fff4c583          	lbu	a1,-1(s1)
 658:	854a                	mv	a0,s2
 65a:	f67ff0ef          	jal	5c0 <putc>
  while(--i >= 0)
 65e:	14fd                	addi	s1,s1,-1
 660:	ff349ae3          	bne	s1,s3,654 <printint+0x76>
 664:	74e2                	ld	s1,56(sp)
 666:	79a2                	ld	s3,40(sp)
}
 668:	60a6                	ld	ra,72(sp)
 66a:	6406                	ld	s0,64(sp)
 66c:	7942                	ld	s2,48(sp)
 66e:	6161                	addi	sp,sp,80
 670:	8082                	ret
    x = -xx;
 672:	40b005b3          	neg	a1,a1
    neg = 1;
 676:	4885                	li	a7,1
    x = -xx;
 678:	bfad                	j	5f2 <printint+0x14>

000000000000067a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 67a:	711d                	addi	sp,sp,-96
 67c:	ec86                	sd	ra,88(sp)
 67e:	e8a2                	sd	s0,80(sp)
 680:	e0ca                	sd	s2,64(sp)
 682:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 684:	0005c903          	lbu	s2,0(a1)
 688:	28090663          	beqz	s2,914 <vprintf+0x29a>
 68c:	e4a6                	sd	s1,72(sp)
 68e:	fc4e                	sd	s3,56(sp)
 690:	f852                	sd	s4,48(sp)
 692:	f456                	sd	s5,40(sp)
 694:	f05a                	sd	s6,32(sp)
 696:	ec5e                	sd	s7,24(sp)
 698:	e862                	sd	s8,16(sp)
 69a:	e466                	sd	s9,8(sp)
 69c:	8b2a                	mv	s6,a0
 69e:	8a2e                	mv	s4,a1
 6a0:	8bb2                	mv	s7,a2
  state = 0;
 6a2:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 6a4:	4481                	li	s1,0
 6a6:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 6a8:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 6ac:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 6b0:	06c00c93          	li	s9,108
 6b4:	a005                	j	6d4 <vprintf+0x5a>
        putc(fd, c0);
 6b6:	85ca                	mv	a1,s2
 6b8:	855a                	mv	a0,s6
 6ba:	f07ff0ef          	jal	5c0 <putc>
 6be:	a019                	j	6c4 <vprintf+0x4a>
    } else if(state == '%'){
 6c0:	03598263          	beq	s3,s5,6e4 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 6c4:	2485                	addiw	s1,s1,1
 6c6:	8726                	mv	a4,s1
 6c8:	009a07b3          	add	a5,s4,s1
 6cc:	0007c903          	lbu	s2,0(a5)
 6d0:	22090a63          	beqz	s2,904 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 6d4:	0009079b          	sext.w	a5,s2
    if(state == 0){
 6d8:	fe0994e3          	bnez	s3,6c0 <vprintf+0x46>
      if(c0 == '%'){
 6dc:	fd579de3          	bne	a5,s5,6b6 <vprintf+0x3c>
        state = '%';
 6e0:	89be                	mv	s3,a5
 6e2:	b7cd                	j	6c4 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 6e4:	00ea06b3          	add	a3,s4,a4
 6e8:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 6ec:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 6ee:	c681                	beqz	a3,6f6 <vprintf+0x7c>
 6f0:	9752                	add	a4,a4,s4
 6f2:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 6f6:	05878363          	beq	a5,s8,73c <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 6fa:	05978d63          	beq	a5,s9,754 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 6fe:	07500713          	li	a4,117
 702:	0ee78763          	beq	a5,a4,7f0 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 706:	07800713          	li	a4,120
 70a:	12e78963          	beq	a5,a4,83c <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 70e:	07000713          	li	a4,112
 712:	14e78e63          	beq	a5,a4,86e <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 716:	06300713          	li	a4,99
 71a:	18e78e63          	beq	a5,a4,8b6 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 71e:	07300713          	li	a4,115
 722:	1ae78463          	beq	a5,a4,8ca <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 726:	02500713          	li	a4,37
 72a:	04e79563          	bne	a5,a4,774 <vprintf+0xfa>
        putc(fd, '%');
 72e:	02500593          	li	a1,37
 732:	855a                	mv	a0,s6
 734:	e8dff0ef          	jal	5c0 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 738:	4981                	li	s3,0
 73a:	b769                	j	6c4 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 73c:	008b8913          	addi	s2,s7,8
 740:	4685                	li	a3,1
 742:	4629                	li	a2,10
 744:	000ba583          	lw	a1,0(s7)
 748:	855a                	mv	a0,s6
 74a:	e95ff0ef          	jal	5de <printint>
 74e:	8bca                	mv	s7,s2
      state = 0;
 750:	4981                	li	s3,0
 752:	bf8d                	j	6c4 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 754:	06400793          	li	a5,100
 758:	02f68963          	beq	a3,a5,78a <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 75c:	06c00793          	li	a5,108
 760:	04f68263          	beq	a3,a5,7a4 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 764:	07500793          	li	a5,117
 768:	0af68063          	beq	a3,a5,808 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 76c:	07800793          	li	a5,120
 770:	0ef68263          	beq	a3,a5,854 <vprintf+0x1da>
        putc(fd, '%');
 774:	02500593          	li	a1,37
 778:	855a                	mv	a0,s6
 77a:	e47ff0ef          	jal	5c0 <putc>
        putc(fd, c0);
 77e:	85ca                	mv	a1,s2
 780:	855a                	mv	a0,s6
 782:	e3fff0ef          	jal	5c0 <putc>
      state = 0;
 786:	4981                	li	s3,0
 788:	bf35                	j	6c4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 78a:	008b8913          	addi	s2,s7,8
 78e:	4685                	li	a3,1
 790:	4629                	li	a2,10
 792:	000bb583          	ld	a1,0(s7)
 796:	855a                	mv	a0,s6
 798:	e47ff0ef          	jal	5de <printint>
        i += 1;
 79c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 79e:	8bca                	mv	s7,s2
      state = 0;
 7a0:	4981                	li	s3,0
        i += 1;
 7a2:	b70d                	j	6c4 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7a4:	06400793          	li	a5,100
 7a8:	02f60763          	beq	a2,a5,7d6 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7ac:	07500793          	li	a5,117
 7b0:	06f60963          	beq	a2,a5,822 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7b4:	07800793          	li	a5,120
 7b8:	faf61ee3          	bne	a2,a5,774 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7bc:	008b8913          	addi	s2,s7,8
 7c0:	4681                	li	a3,0
 7c2:	4641                	li	a2,16
 7c4:	000bb583          	ld	a1,0(s7)
 7c8:	855a                	mv	a0,s6
 7ca:	e15ff0ef          	jal	5de <printint>
        i += 2;
 7ce:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 7d0:	8bca                	mv	s7,s2
      state = 0;
 7d2:	4981                	li	s3,0
        i += 2;
 7d4:	bdc5                	j	6c4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7d6:	008b8913          	addi	s2,s7,8
 7da:	4685                	li	a3,1
 7dc:	4629                	li	a2,10
 7de:	000bb583          	ld	a1,0(s7)
 7e2:	855a                	mv	a0,s6
 7e4:	dfbff0ef          	jal	5de <printint>
        i += 2;
 7e8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 7ea:	8bca                	mv	s7,s2
      state = 0;
 7ec:	4981                	li	s3,0
        i += 2;
 7ee:	bdd9                	j	6c4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 7f0:	008b8913          	addi	s2,s7,8
 7f4:	4681                	li	a3,0
 7f6:	4629                	li	a2,10
 7f8:	000be583          	lwu	a1,0(s7)
 7fc:	855a                	mv	a0,s6
 7fe:	de1ff0ef          	jal	5de <printint>
 802:	8bca                	mv	s7,s2
      state = 0;
 804:	4981                	li	s3,0
 806:	bd7d                	j	6c4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 808:	008b8913          	addi	s2,s7,8
 80c:	4681                	li	a3,0
 80e:	4629                	li	a2,10
 810:	000bb583          	ld	a1,0(s7)
 814:	855a                	mv	a0,s6
 816:	dc9ff0ef          	jal	5de <printint>
        i += 1;
 81a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 81c:	8bca                	mv	s7,s2
      state = 0;
 81e:	4981                	li	s3,0
        i += 1;
 820:	b555                	j	6c4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 822:	008b8913          	addi	s2,s7,8
 826:	4681                	li	a3,0
 828:	4629                	li	a2,10
 82a:	000bb583          	ld	a1,0(s7)
 82e:	855a                	mv	a0,s6
 830:	dafff0ef          	jal	5de <printint>
        i += 2;
 834:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 836:	8bca                	mv	s7,s2
      state = 0;
 838:	4981                	li	s3,0
        i += 2;
 83a:	b569                	j	6c4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 83c:	008b8913          	addi	s2,s7,8
 840:	4681                	li	a3,0
 842:	4641                	li	a2,16
 844:	000be583          	lwu	a1,0(s7)
 848:	855a                	mv	a0,s6
 84a:	d95ff0ef          	jal	5de <printint>
 84e:	8bca                	mv	s7,s2
      state = 0;
 850:	4981                	li	s3,0
 852:	bd8d                	j	6c4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 854:	008b8913          	addi	s2,s7,8
 858:	4681                	li	a3,0
 85a:	4641                	li	a2,16
 85c:	000bb583          	ld	a1,0(s7)
 860:	855a                	mv	a0,s6
 862:	d7dff0ef          	jal	5de <printint>
        i += 1;
 866:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 868:	8bca                	mv	s7,s2
      state = 0;
 86a:	4981                	li	s3,0
        i += 1;
 86c:	bda1                	j	6c4 <vprintf+0x4a>
 86e:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 870:	008b8d13          	addi	s10,s7,8
 874:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 878:	03000593          	li	a1,48
 87c:	855a                	mv	a0,s6
 87e:	d43ff0ef          	jal	5c0 <putc>
  putc(fd, 'x');
 882:	07800593          	li	a1,120
 886:	855a                	mv	a0,s6
 888:	d39ff0ef          	jal	5c0 <putc>
 88c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 88e:	00000b97          	auipc	s7,0x0
 892:	2dab8b93          	addi	s7,s7,730 # b68 <digits>
 896:	03c9d793          	srli	a5,s3,0x3c
 89a:	97de                	add	a5,a5,s7
 89c:	0007c583          	lbu	a1,0(a5)
 8a0:	855a                	mv	a0,s6
 8a2:	d1fff0ef          	jal	5c0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8a6:	0992                	slli	s3,s3,0x4
 8a8:	397d                	addiw	s2,s2,-1
 8aa:	fe0916e3          	bnez	s2,896 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 8ae:	8bea                	mv	s7,s10
      state = 0;
 8b0:	4981                	li	s3,0
 8b2:	6d02                	ld	s10,0(sp)
 8b4:	bd01                	j	6c4 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 8b6:	008b8913          	addi	s2,s7,8
 8ba:	000bc583          	lbu	a1,0(s7)
 8be:	855a                	mv	a0,s6
 8c0:	d01ff0ef          	jal	5c0 <putc>
 8c4:	8bca                	mv	s7,s2
      state = 0;
 8c6:	4981                	li	s3,0
 8c8:	bbf5                	j	6c4 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 8ca:	008b8993          	addi	s3,s7,8
 8ce:	000bb903          	ld	s2,0(s7)
 8d2:	00090f63          	beqz	s2,8f0 <vprintf+0x276>
        for(; *s; s++)
 8d6:	00094583          	lbu	a1,0(s2)
 8da:	c195                	beqz	a1,8fe <vprintf+0x284>
          putc(fd, *s);
 8dc:	855a                	mv	a0,s6
 8de:	ce3ff0ef          	jal	5c0 <putc>
        for(; *s; s++)
 8e2:	0905                	addi	s2,s2,1
 8e4:	00094583          	lbu	a1,0(s2)
 8e8:	f9f5                	bnez	a1,8dc <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 8ea:	8bce                	mv	s7,s3
      state = 0;
 8ec:	4981                	li	s3,0
 8ee:	bbd9                	j	6c4 <vprintf+0x4a>
          s = "(null)";
 8f0:	00000917          	auipc	s2,0x0
 8f4:	27090913          	addi	s2,s2,624 # b60 <malloc+0x164>
        for(; *s; s++)
 8f8:	02800593          	li	a1,40
 8fc:	b7c5                	j	8dc <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 8fe:	8bce                	mv	s7,s3
      state = 0;
 900:	4981                	li	s3,0
 902:	b3c9                	j	6c4 <vprintf+0x4a>
 904:	64a6                	ld	s1,72(sp)
 906:	79e2                	ld	s3,56(sp)
 908:	7a42                	ld	s4,48(sp)
 90a:	7aa2                	ld	s5,40(sp)
 90c:	7b02                	ld	s6,32(sp)
 90e:	6be2                	ld	s7,24(sp)
 910:	6c42                	ld	s8,16(sp)
 912:	6ca2                	ld	s9,8(sp)
    }
  }
}
 914:	60e6                	ld	ra,88(sp)
 916:	6446                	ld	s0,80(sp)
 918:	6906                	ld	s2,64(sp)
 91a:	6125                	addi	sp,sp,96
 91c:	8082                	ret

000000000000091e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 91e:	715d                	addi	sp,sp,-80
 920:	ec06                	sd	ra,24(sp)
 922:	e822                	sd	s0,16(sp)
 924:	1000                	addi	s0,sp,32
 926:	e010                	sd	a2,0(s0)
 928:	e414                	sd	a3,8(s0)
 92a:	e818                	sd	a4,16(s0)
 92c:	ec1c                	sd	a5,24(s0)
 92e:	03043023          	sd	a6,32(s0)
 932:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 936:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 93a:	8622                	mv	a2,s0
 93c:	d3fff0ef          	jal	67a <vprintf>
}
 940:	60e2                	ld	ra,24(sp)
 942:	6442                	ld	s0,16(sp)
 944:	6161                	addi	sp,sp,80
 946:	8082                	ret

0000000000000948 <printf>:

void
printf(const char *fmt, ...)
{
 948:	711d                	addi	sp,sp,-96
 94a:	ec06                	sd	ra,24(sp)
 94c:	e822                	sd	s0,16(sp)
 94e:	1000                	addi	s0,sp,32
 950:	e40c                	sd	a1,8(s0)
 952:	e810                	sd	a2,16(s0)
 954:	ec14                	sd	a3,24(s0)
 956:	f018                	sd	a4,32(s0)
 958:	f41c                	sd	a5,40(s0)
 95a:	03043823          	sd	a6,48(s0)
 95e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 962:	00840613          	addi	a2,s0,8
 966:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 96a:	85aa                	mv	a1,a0
 96c:	4505                	li	a0,1
 96e:	d0dff0ef          	jal	67a <vprintf>
}
 972:	60e2                	ld	ra,24(sp)
 974:	6442                	ld	s0,16(sp)
 976:	6125                	addi	sp,sp,96
 978:	8082                	ret

000000000000097a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 97a:	1141                	addi	sp,sp,-16
 97c:	e422                	sd	s0,8(sp)
 97e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 980:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 984:	00001797          	auipc	a5,0x1
 988:	67c7b783          	ld	a5,1660(a5) # 2000 <freep>
 98c:	a02d                	j	9b6 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 98e:	4618                	lw	a4,8(a2)
 990:	9f2d                	addw	a4,a4,a1
 992:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 996:	6398                	ld	a4,0(a5)
 998:	6310                	ld	a2,0(a4)
 99a:	a83d                	j	9d8 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 99c:	ff852703          	lw	a4,-8(a0)
 9a0:	9f31                	addw	a4,a4,a2
 9a2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 9a4:	ff053683          	ld	a3,-16(a0)
 9a8:	a091                	j	9ec <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9aa:	6398                	ld	a4,0(a5)
 9ac:	00e7e463          	bltu	a5,a4,9b4 <free+0x3a>
 9b0:	00e6ea63          	bltu	a3,a4,9c4 <free+0x4a>
{
 9b4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9b6:	fed7fae3          	bgeu	a5,a3,9aa <free+0x30>
 9ba:	6398                	ld	a4,0(a5)
 9bc:	00e6e463          	bltu	a3,a4,9c4 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9c0:	fee7eae3          	bltu	a5,a4,9b4 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 9c4:	ff852583          	lw	a1,-8(a0)
 9c8:	6390                	ld	a2,0(a5)
 9ca:	02059813          	slli	a6,a1,0x20
 9ce:	01c85713          	srli	a4,a6,0x1c
 9d2:	9736                	add	a4,a4,a3
 9d4:	fae60de3          	beq	a2,a4,98e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 9d8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9dc:	4790                	lw	a2,8(a5)
 9de:	02061593          	slli	a1,a2,0x20
 9e2:	01c5d713          	srli	a4,a1,0x1c
 9e6:	973e                	add	a4,a4,a5
 9e8:	fae68ae3          	beq	a3,a4,99c <free+0x22>
    p->s.ptr = bp->s.ptr;
 9ec:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 9ee:	00001717          	auipc	a4,0x1
 9f2:	60f73923          	sd	a5,1554(a4) # 2000 <freep>
}
 9f6:	6422                	ld	s0,8(sp)
 9f8:	0141                	addi	sp,sp,16
 9fa:	8082                	ret

00000000000009fc <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9fc:	7139                	addi	sp,sp,-64
 9fe:	fc06                	sd	ra,56(sp)
 a00:	f822                	sd	s0,48(sp)
 a02:	f426                	sd	s1,40(sp)
 a04:	ec4e                	sd	s3,24(sp)
 a06:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a08:	02051493          	slli	s1,a0,0x20
 a0c:	9081                	srli	s1,s1,0x20
 a0e:	04bd                	addi	s1,s1,15
 a10:	8091                	srli	s1,s1,0x4
 a12:	0014899b          	addiw	s3,s1,1
 a16:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a18:	00001517          	auipc	a0,0x1
 a1c:	5e853503          	ld	a0,1512(a0) # 2000 <freep>
 a20:	c915                	beqz	a0,a54 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a22:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a24:	4798                	lw	a4,8(a5)
 a26:	08977a63          	bgeu	a4,s1,aba <malloc+0xbe>
 a2a:	f04a                	sd	s2,32(sp)
 a2c:	e852                	sd	s4,16(sp)
 a2e:	e456                	sd	s5,8(sp)
 a30:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 a32:	8a4e                	mv	s4,s3
 a34:	0009871b          	sext.w	a4,s3
 a38:	6685                	lui	a3,0x1
 a3a:	00d77363          	bgeu	a4,a3,a40 <malloc+0x44>
 a3e:	6a05                	lui	s4,0x1
 a40:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a44:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a48:	00001917          	auipc	s2,0x1
 a4c:	5b890913          	addi	s2,s2,1464 # 2000 <freep>
  if(p == SBRK_ERROR)
 a50:	5afd                	li	s5,-1
 a52:	a081                	j	a92 <malloc+0x96>
 a54:	f04a                	sd	s2,32(sp)
 a56:	e852                	sd	s4,16(sp)
 a58:	e456                	sd	s5,8(sp)
 a5a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a5c:	00001797          	auipc	a5,0x1
 a60:	5c478793          	addi	a5,a5,1476 # 2020 <base>
 a64:	00001717          	auipc	a4,0x1
 a68:	58f73e23          	sd	a5,1436(a4) # 2000 <freep>
 a6c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a6e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a72:	b7c1                	j	a32 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 a74:	6398                	ld	a4,0(a5)
 a76:	e118                	sd	a4,0(a0)
 a78:	a8a9                	j	ad2 <malloc+0xd6>
  hp->s.size = nu;
 a7a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a7e:	0541                	addi	a0,a0,16
 a80:	efbff0ef          	jal	97a <free>
  return freep;
 a84:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a88:	c12d                	beqz	a0,aea <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a8a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a8c:	4798                	lw	a4,8(a5)
 a8e:	02977263          	bgeu	a4,s1,ab2 <malloc+0xb6>
    if(p == freep)
 a92:	00093703          	ld	a4,0(s2)
 a96:	853e                	mv	a0,a5
 a98:	fef719e3          	bne	a4,a5,a8a <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 a9c:	8552                	mv	a0,s4
 a9e:	a2fff0ef          	jal	4cc <sbrk>
  if(p == SBRK_ERROR)
 aa2:	fd551ce3          	bne	a0,s5,a7a <malloc+0x7e>
        return 0;
 aa6:	4501                	li	a0,0
 aa8:	7902                	ld	s2,32(sp)
 aaa:	6a42                	ld	s4,16(sp)
 aac:	6aa2                	ld	s5,8(sp)
 aae:	6b02                	ld	s6,0(sp)
 ab0:	a03d                	j	ade <malloc+0xe2>
 ab2:	7902                	ld	s2,32(sp)
 ab4:	6a42                	ld	s4,16(sp)
 ab6:	6aa2                	ld	s5,8(sp)
 ab8:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 aba:	fae48de3          	beq	s1,a4,a74 <malloc+0x78>
        p->s.size -= nunits;
 abe:	4137073b          	subw	a4,a4,s3
 ac2:	c798                	sw	a4,8(a5)
        p += p->s.size;
 ac4:	02071693          	slli	a3,a4,0x20
 ac8:	01c6d713          	srli	a4,a3,0x1c
 acc:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 ace:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 ad2:	00001717          	auipc	a4,0x1
 ad6:	52a73723          	sd	a0,1326(a4) # 2000 <freep>
      return (void*)(p + 1);
 ada:	01078513          	addi	a0,a5,16
  }
}
 ade:	70e2                	ld	ra,56(sp)
 ae0:	7442                	ld	s0,48(sp)
 ae2:	74a2                	ld	s1,40(sp)
 ae4:	69e2                	ld	s3,24(sp)
 ae6:	6121                	addi	sp,sp,64
 ae8:	8082                	ret
 aea:	7902                	ld	s2,32(sp)
 aec:	6a42                	ld	s4,16(sp)
 aee:	6aa2                	ld	s5,8(sp)
 af0:	6b02                	ld	s6,0(sp)
 af2:	b7f5                	j	ade <malloc+0xe2>
