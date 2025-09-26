
user/_grind:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <do_rand>:
#include "kernel/riscv.h"

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
       6:	611c                	ld	a5,0(a0)
       8:	80000737          	lui	a4,0x80000
       c:	ffe74713          	xori	a4,a4,-2
      10:	02e7f7b3          	remu	a5,a5,a4
      14:	0785                	addi	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
      16:	66fd                	lui	a3,0x1f
      18:	31d68693          	addi	a3,a3,797 # 1f31d <base+0x1cf15>
      1c:	02d7e733          	rem	a4,a5,a3
    x = 16807 * lo - 2836 * hi;
      20:	6611                	lui	a2,0x4
      22:	1a760613          	addi	a2,a2,423 # 41a7 <base+0x1d9f>
      26:	02c70733          	mul	a4,a4,a2
    hi = x / 127773;
      2a:	02d7c7b3          	div	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
      2e:	76fd                	lui	a3,0xfffff
      30:	4ec68693          	addi	a3,a3,1260 # fffffffffffff4ec <base+0xffffffffffffd0e4>
      34:	02d787b3          	mul	a5,a5,a3
      38:	97ba                	add	a5,a5,a4
    if (x < 0)
      3a:	0007c963          	bltz	a5,4c <do_rand+0x4c>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
      3e:	17fd                	addi	a5,a5,-1
    *ctx = x;
      40:	e11c                	sd	a5,0(a0)
    return (x);
}
      42:	0007851b          	sext.w	a0,a5
      46:	6422                	ld	s0,8(sp)
      48:	0141                	addi	sp,sp,16
      4a:	8082                	ret
        x += 0x7fffffff;
      4c:	80000737          	lui	a4,0x80000
      50:	fff74713          	not	a4,a4
      54:	97ba                	add	a5,a5,a4
      56:	b7e5                	j	3e <do_rand+0x3e>

0000000000000058 <rand>:

unsigned long rand_next = 1;

int
rand(void)
{
      58:	1141                	addi	sp,sp,-16
      5a:	e406                	sd	ra,8(sp)
      5c:	e022                	sd	s0,0(sp)
      5e:	0800                	addi	s0,sp,16
    return (do_rand(&rand_next));
      60:	00002517          	auipc	a0,0x2
      64:	fa050513          	addi	a0,a0,-96 # 2000 <rand_next>
      68:	f99ff0ef          	jal	0 <do_rand>
}
      6c:	60a2                	ld	ra,8(sp)
      6e:	6402                	ld	s0,0(sp)
      70:	0141                	addi	sp,sp,16
      72:	8082                	ret

0000000000000074 <go>:

void
go(int which_child)
{
      74:	7159                	addi	sp,sp,-112
      76:	f486                	sd	ra,104(sp)
      78:	f0a2                	sd	s0,96(sp)
      7a:	eca6                	sd	s1,88(sp)
      7c:	fc56                	sd	s5,56(sp)
      7e:	1880                	addi	s0,sp,112
      80:	84aa                	mv	s1,a0
  int fd = -1;
  static char buf[999];
  char *break0 = sbrk(0);
      82:	4501                	li	a0,0
      84:	2bb000ef          	jal	b3e <sbrk>
      88:	8aaa                	mv	s5,a0
  uint64 iters = 0;

  mkdir("grindir");
      8a:	00001517          	auipc	a0,0x1
      8e:	0e650513          	addi	a0,a0,230 # 1170 <malloc+0x102>
      92:	349000ef          	jal	bda <mkdir>
  if(chdir("grindir") != 0){
      96:	00001517          	auipc	a0,0x1
      9a:	0da50513          	addi	a0,a0,218 # 1170 <malloc+0x102>
      9e:	345000ef          	jal	be2 <chdir>
      a2:	cd11                	beqz	a0,be <go+0x4a>
      a4:	e8ca                	sd	s2,80(sp)
      a6:	e4ce                	sd	s3,72(sp)
      a8:	e0d2                	sd	s4,64(sp)
      aa:	f85a                	sd	s6,48(sp)
    printf("grind: chdir grindir failed\n");
      ac:	00001517          	auipc	a0,0x1
      b0:	0cc50513          	addi	a0,a0,204 # 1178 <malloc+0x10a>
      b4:	707000ef          	jal	fba <printf>
    exit(1);
      b8:	4505                	li	a0,1
      ba:	2b9000ef          	jal	b72 <exit>
      be:	e8ca                	sd	s2,80(sp)
      c0:	e4ce                	sd	s3,72(sp)
      c2:	e0d2                	sd	s4,64(sp)
      c4:	f85a                	sd	s6,48(sp)
  }
  chdir("/");
      c6:	00001517          	auipc	a0,0x1
      ca:	0da50513          	addi	a0,a0,218 # 11a0 <malloc+0x132>
      ce:	315000ef          	jal	be2 <chdir>
      d2:	00001997          	auipc	s3,0x1
      d6:	0de98993          	addi	s3,s3,222 # 11b0 <malloc+0x142>
      da:	c489                	beqz	s1,e4 <go+0x70>
      dc:	00001997          	auipc	s3,0x1
      e0:	0cc98993          	addi	s3,s3,204 # 11a8 <malloc+0x13a>
  uint64 iters = 0;
      e4:	4481                	li	s1,0
  int fd = -1;
      e6:	5a7d                	li	s4,-1
      e8:	00001917          	auipc	s2,0x1
      ec:	39890913          	addi	s2,s2,920 # 1480 <malloc+0x412>
      f0:	a819                	j	106 <go+0x92>
    iters++;
    if((iters % 500) == 0)
      write(1, which_child?"B":"A", 1);
    int what = rand() % 23;
    if(what == 1){
      close(open("grindir/../a", O_CREATE|O_RDWR));
      f2:	20200593          	li	a1,514
      f6:	00001517          	auipc	a0,0x1
      fa:	0c250513          	addi	a0,a0,194 # 11b8 <malloc+0x14a>
      fe:	2b5000ef          	jal	bb2 <open>
     102:	299000ef          	jal	b9a <close>
    iters++;
     106:	0485                	addi	s1,s1,1
    if((iters % 500) == 0)
     108:	1f400793          	li	a5,500
     10c:	02f4f7b3          	remu	a5,s1,a5
     110:	e791                	bnez	a5,11c <go+0xa8>
      write(1, which_child?"B":"A", 1);
     112:	4605                	li	a2,1
     114:	85ce                	mv	a1,s3
     116:	4505                	li	a0,1
     118:	27b000ef          	jal	b92 <write>
    int what = rand() % 23;
     11c:	f3dff0ef          	jal	58 <rand>
     120:	47dd                	li	a5,23
     122:	02f5653b          	remw	a0,a0,a5
     126:	0005071b          	sext.w	a4,a0
     12a:	47d9                	li	a5,22
     12c:	fce7ede3          	bltu	a5,a4,106 <go+0x92>
     130:	02051793          	slli	a5,a0,0x20
     134:	01e7d513          	srli	a0,a5,0x1e
     138:	954a                	add	a0,a0,s2
     13a:	411c                	lw	a5,0(a0)
     13c:	97ca                	add	a5,a5,s2
     13e:	8782                	jr	a5
    } else if(what == 2){
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     140:	20200593          	li	a1,514
     144:	00001517          	auipc	a0,0x1
     148:	08450513          	addi	a0,a0,132 # 11c8 <malloc+0x15a>
     14c:	267000ef          	jal	bb2 <open>
     150:	24b000ef          	jal	b9a <close>
     154:	bf4d                	j	106 <go+0x92>
    } else if(what == 3){
      unlink("grindir/../a");
     156:	00001517          	auipc	a0,0x1
     15a:	06250513          	addi	a0,a0,98 # 11b8 <malloc+0x14a>
     15e:	265000ef          	jal	bc2 <unlink>
     162:	b755                	j	106 <go+0x92>
    } else if(what == 4){
      if(chdir("grindir") != 0){
     164:	00001517          	auipc	a0,0x1
     168:	00c50513          	addi	a0,a0,12 # 1170 <malloc+0x102>
     16c:	277000ef          	jal	be2 <chdir>
     170:	ed11                	bnez	a0,18c <go+0x118>
        printf("grind: chdir grindir failed\n");
        exit(1);
      }
      unlink("../b");
     172:	00001517          	auipc	a0,0x1
     176:	06e50513          	addi	a0,a0,110 # 11e0 <malloc+0x172>
     17a:	249000ef          	jal	bc2 <unlink>
      chdir("/");
     17e:	00001517          	auipc	a0,0x1
     182:	02250513          	addi	a0,a0,34 # 11a0 <malloc+0x132>
     186:	25d000ef          	jal	be2 <chdir>
     18a:	bfb5                	j	106 <go+0x92>
        printf("grind: chdir grindir failed\n");
     18c:	00001517          	auipc	a0,0x1
     190:	fec50513          	addi	a0,a0,-20 # 1178 <malloc+0x10a>
     194:	627000ef          	jal	fba <printf>
        exit(1);
     198:	4505                	li	a0,1
     19a:	1d9000ef          	jal	b72 <exit>
    } else if(what == 5){
      close(fd);
     19e:	8552                	mv	a0,s4
     1a0:	1fb000ef          	jal	b9a <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     1a4:	20200593          	li	a1,514
     1a8:	00001517          	auipc	a0,0x1
     1ac:	04050513          	addi	a0,a0,64 # 11e8 <malloc+0x17a>
     1b0:	203000ef          	jal	bb2 <open>
     1b4:	8a2a                	mv	s4,a0
     1b6:	bf81                	j	106 <go+0x92>
    } else if(what == 6){
      close(fd);
     1b8:	8552                	mv	a0,s4
     1ba:	1e1000ef          	jal	b9a <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     1be:	20200593          	li	a1,514
     1c2:	00001517          	auipc	a0,0x1
     1c6:	03650513          	addi	a0,a0,54 # 11f8 <malloc+0x18a>
     1ca:	1e9000ef          	jal	bb2 <open>
     1ce:	8a2a                	mv	s4,a0
     1d0:	bf1d                	j	106 <go+0x92>
    } else if(what == 7){
      write(fd, buf, sizeof(buf));
     1d2:	3e700613          	li	a2,999
     1d6:	00002597          	auipc	a1,0x2
     1da:	e4a58593          	addi	a1,a1,-438 # 2020 <buf.0>
     1de:	8552                	mv	a0,s4
     1e0:	1b3000ef          	jal	b92 <write>
     1e4:	b70d                	j	106 <go+0x92>
    } else if(what == 8){
      read(fd, buf, sizeof(buf));
     1e6:	3e700613          	li	a2,999
     1ea:	00002597          	auipc	a1,0x2
     1ee:	e3658593          	addi	a1,a1,-458 # 2020 <buf.0>
     1f2:	8552                	mv	a0,s4
     1f4:	197000ef          	jal	b8a <read>
     1f8:	b739                	j	106 <go+0x92>
    } else if(what == 9){
      mkdir("grindir/../a");
     1fa:	00001517          	auipc	a0,0x1
     1fe:	fbe50513          	addi	a0,a0,-66 # 11b8 <malloc+0x14a>
     202:	1d9000ef          	jal	bda <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     206:	20200593          	li	a1,514
     20a:	00001517          	auipc	a0,0x1
     20e:	00650513          	addi	a0,a0,6 # 1210 <malloc+0x1a2>
     212:	1a1000ef          	jal	bb2 <open>
     216:	185000ef          	jal	b9a <close>
      unlink("a/a");
     21a:	00001517          	auipc	a0,0x1
     21e:	00650513          	addi	a0,a0,6 # 1220 <malloc+0x1b2>
     222:	1a1000ef          	jal	bc2 <unlink>
     226:	b5c5                	j	106 <go+0x92>
    } else if(what == 10){
      mkdir("/../b");
     228:	00001517          	auipc	a0,0x1
     22c:	00050513          	mv	a0,a0
     230:	1ab000ef          	jal	bda <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     234:	20200593          	li	a1,514
     238:	00001517          	auipc	a0,0x1
     23c:	ff850513          	addi	a0,a0,-8 # 1230 <malloc+0x1c2>
     240:	173000ef          	jal	bb2 <open>
     244:	157000ef          	jal	b9a <close>
      unlink("b/b");
     248:	00001517          	auipc	a0,0x1
     24c:	ff850513          	addi	a0,a0,-8 # 1240 <malloc+0x1d2>
     250:	173000ef          	jal	bc2 <unlink>
     254:	bd4d                	j	106 <go+0x92>
    } else if(what == 11){
      unlink("b");
     256:	00001517          	auipc	a0,0x1
     25a:	ff250513          	addi	a0,a0,-14 # 1248 <malloc+0x1da>
     25e:	165000ef          	jal	bc2 <unlink>
      link("../grindir/./../a", "../b");
     262:	00001597          	auipc	a1,0x1
     266:	f7e58593          	addi	a1,a1,-130 # 11e0 <malloc+0x172>
     26a:	00001517          	auipc	a0,0x1
     26e:	fe650513          	addi	a0,a0,-26 # 1250 <malloc+0x1e2>
     272:	161000ef          	jal	bd2 <link>
     276:	bd41                	j	106 <go+0x92>
    } else if(what == 12){
      unlink("../grindir/../a");
     278:	00001517          	auipc	a0,0x1
     27c:	ff050513          	addi	a0,a0,-16 # 1268 <malloc+0x1fa>
     280:	143000ef          	jal	bc2 <unlink>
      link(".././b", "/grindir/../a");
     284:	00001597          	auipc	a1,0x1
     288:	f6458593          	addi	a1,a1,-156 # 11e8 <malloc+0x17a>
     28c:	00001517          	auipc	a0,0x1
     290:	fec50513          	addi	a0,a0,-20 # 1278 <malloc+0x20a>
     294:	13f000ef          	jal	bd2 <link>
     298:	b5bd                	j	106 <go+0x92>
    } else if(what == 13){
      int pid = fork();
     29a:	0d1000ef          	jal	b6a <fork>
      if(pid == 0){
     29e:	c519                	beqz	a0,2ac <go+0x238>
        exit(0);
      } else if(pid < 0){
     2a0:	00054863          	bltz	a0,2b0 <go+0x23c>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     2a4:	4501                	li	a0,0
     2a6:	0d5000ef          	jal	b7a <wait>
     2aa:	bdb1                	j	106 <go+0x92>
        exit(0);
     2ac:	0c7000ef          	jal	b72 <exit>
        printf("grind: fork failed\n");
     2b0:	00001517          	auipc	a0,0x1
     2b4:	fd050513          	addi	a0,a0,-48 # 1280 <malloc+0x212>
     2b8:	503000ef          	jal	fba <printf>
        exit(1);
     2bc:	4505                	li	a0,1
     2be:	0b5000ef          	jal	b72 <exit>
    } else if(what == 14){
      int pid = fork();
     2c2:	0a9000ef          	jal	b6a <fork>
      if(pid == 0){
     2c6:	c519                	beqz	a0,2d4 <go+0x260>
        fork();
        fork();
        exit(0);
      } else if(pid < 0){
     2c8:	00054d63          	bltz	a0,2e2 <go+0x26e>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     2cc:	4501                	li	a0,0
     2ce:	0ad000ef          	jal	b7a <wait>
     2d2:	bd15                	j	106 <go+0x92>
        fork();
     2d4:	097000ef          	jal	b6a <fork>
        fork();
     2d8:	093000ef          	jal	b6a <fork>
        exit(0);
     2dc:	4501                	li	a0,0
     2de:	095000ef          	jal	b72 <exit>
        printf("grind: fork failed\n");
     2e2:	00001517          	auipc	a0,0x1
     2e6:	f9e50513          	addi	a0,a0,-98 # 1280 <malloc+0x212>
     2ea:	4d1000ef          	jal	fba <printf>
        exit(1);
     2ee:	4505                	li	a0,1
     2f0:	083000ef          	jal	b72 <exit>
    } else if(what == 15){
      sbrk(6011);
     2f4:	6505                	lui	a0,0x1
     2f6:	77b50513          	addi	a0,a0,1915 # 177b <digits+0x29b>
     2fa:	045000ef          	jal	b3e <sbrk>
     2fe:	b521                	j	106 <go+0x92>
    } else if(what == 16){
      if(sbrk(0) > break0)
     300:	4501                	li	a0,0
     302:	03d000ef          	jal	b3e <sbrk>
     306:	e0aaf0e3          	bgeu	s5,a0,106 <go+0x92>
        sbrk(-(sbrk(0) - break0));
     30a:	4501                	li	a0,0
     30c:	033000ef          	jal	b3e <sbrk>
     310:	40aa853b          	subw	a0,s5,a0
     314:	02b000ef          	jal	b3e <sbrk>
     318:	b3fd                	j	106 <go+0x92>
    } else if(what == 17){
      int pid = fork();
     31a:	051000ef          	jal	b6a <fork>
     31e:	8b2a                	mv	s6,a0
      if(pid == 0){
     320:	c10d                	beqz	a0,342 <go+0x2ce>
        close(open("a", O_CREATE|O_RDWR));
        exit(0);
      } else if(pid < 0){
     322:	02054d63          	bltz	a0,35c <go+0x2e8>
        printf("grind: fork failed\n");
        exit(1);
      }
      if(chdir("../grindir/..") != 0){
     326:	00001517          	auipc	a0,0x1
     32a:	f7a50513          	addi	a0,a0,-134 # 12a0 <malloc+0x232>
     32e:	0b5000ef          	jal	be2 <chdir>
     332:	ed15                	bnez	a0,36e <go+0x2fa>
        printf("grind: chdir failed\n");
        exit(1);
      }
      kill(pid);
     334:	855a                	mv	a0,s6
     336:	06d000ef          	jal	ba2 <kill>
      wait(0);
     33a:	4501                	li	a0,0
     33c:	03f000ef          	jal	b7a <wait>
     340:	b3d9                	j	106 <go+0x92>
        close(open("a", O_CREATE|O_RDWR));
     342:	20200593          	li	a1,514
     346:	00001517          	auipc	a0,0x1
     34a:	f5250513          	addi	a0,a0,-174 # 1298 <malloc+0x22a>
     34e:	065000ef          	jal	bb2 <open>
     352:	049000ef          	jal	b9a <close>
        exit(0);
     356:	4501                	li	a0,0
     358:	01b000ef          	jal	b72 <exit>
        printf("grind: fork failed\n");
     35c:	00001517          	auipc	a0,0x1
     360:	f2450513          	addi	a0,a0,-220 # 1280 <malloc+0x212>
     364:	457000ef          	jal	fba <printf>
        exit(1);
     368:	4505                	li	a0,1
     36a:	009000ef          	jal	b72 <exit>
        printf("grind: chdir failed\n");
     36e:	00001517          	auipc	a0,0x1
     372:	f4250513          	addi	a0,a0,-190 # 12b0 <malloc+0x242>
     376:	445000ef          	jal	fba <printf>
        exit(1);
     37a:	4505                	li	a0,1
     37c:	7f6000ef          	jal	b72 <exit>
    } else if(what == 18){
      int pid = fork();
     380:	7ea000ef          	jal	b6a <fork>
      if(pid == 0){
     384:	c519                	beqz	a0,392 <go+0x31e>
        kill(getpid());
        exit(0);
      } else if(pid < 0){
     386:	00054d63          	bltz	a0,3a0 <go+0x32c>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     38a:	4501                	li	a0,0
     38c:	7ee000ef          	jal	b7a <wait>
     390:	bb9d                	j	106 <go+0x92>
        kill(getpid());
     392:	061000ef          	jal	bf2 <getpid>
     396:	00d000ef          	jal	ba2 <kill>
        exit(0);
     39a:	4501                	li	a0,0
     39c:	7d6000ef          	jal	b72 <exit>
        printf("grind: fork failed\n");
     3a0:	00001517          	auipc	a0,0x1
     3a4:	ee050513          	addi	a0,a0,-288 # 1280 <malloc+0x212>
     3a8:	413000ef          	jal	fba <printf>
        exit(1);
     3ac:	4505                	li	a0,1
     3ae:	7c4000ef          	jal	b72 <exit>
    } else if(what == 19){
      int fds[2];
      if(pipe(fds) < 0){
     3b2:	fa840513          	addi	a0,s0,-88
     3b6:	7cc000ef          	jal	b82 <pipe>
     3ba:	02054363          	bltz	a0,3e0 <go+0x36c>
        printf("grind: pipe failed\n");
        exit(1);
      }
      int pid = fork();
     3be:	7ac000ef          	jal	b6a <fork>
      if(pid == 0){
     3c2:	c905                	beqz	a0,3f2 <go+0x37e>
          printf("grind: pipe write failed\n");
        char c;
        if(read(fds[0], &c, 1) != 1)
          printf("grind: pipe read failed\n");
        exit(0);
      } else if(pid < 0){
     3c4:	08054263          	bltz	a0,448 <go+0x3d4>
        printf("grind: fork failed\n");
        exit(1);
      }
      close(fds[0]);
     3c8:	fa842503          	lw	a0,-88(s0)
     3cc:	7ce000ef          	jal	b9a <close>
      close(fds[1]);
     3d0:	fac42503          	lw	a0,-84(s0)
     3d4:	7c6000ef          	jal	b9a <close>
      wait(0);
     3d8:	4501                	li	a0,0
     3da:	7a0000ef          	jal	b7a <wait>
     3de:	b325                	j	106 <go+0x92>
        printf("grind: pipe failed\n");
     3e0:	00001517          	auipc	a0,0x1
     3e4:	ee850513          	addi	a0,a0,-280 # 12c8 <malloc+0x25a>
     3e8:	3d3000ef          	jal	fba <printf>
        exit(1);
     3ec:	4505                	li	a0,1
     3ee:	784000ef          	jal	b72 <exit>
        fork();
     3f2:	778000ef          	jal	b6a <fork>
        fork();
     3f6:	774000ef          	jal	b6a <fork>
        if(write(fds[1], "x", 1) != 1)
     3fa:	4605                	li	a2,1
     3fc:	00001597          	auipc	a1,0x1
     400:	ee458593          	addi	a1,a1,-284 # 12e0 <malloc+0x272>
     404:	fac42503          	lw	a0,-84(s0)
     408:	78a000ef          	jal	b92 <write>
     40c:	4785                	li	a5,1
     40e:	00f51f63          	bne	a0,a5,42c <go+0x3b8>
        if(read(fds[0], &c, 1) != 1)
     412:	4605                	li	a2,1
     414:	fa040593          	addi	a1,s0,-96
     418:	fa842503          	lw	a0,-88(s0)
     41c:	76e000ef          	jal	b8a <read>
     420:	4785                	li	a5,1
     422:	00f51c63          	bne	a0,a5,43a <go+0x3c6>
        exit(0);
     426:	4501                	li	a0,0
     428:	74a000ef          	jal	b72 <exit>
          printf("grind: pipe write failed\n");
     42c:	00001517          	auipc	a0,0x1
     430:	ebc50513          	addi	a0,a0,-324 # 12e8 <malloc+0x27a>
     434:	387000ef          	jal	fba <printf>
     438:	bfe9                	j	412 <go+0x39e>
          printf("grind: pipe read failed\n");
     43a:	00001517          	auipc	a0,0x1
     43e:	ece50513          	addi	a0,a0,-306 # 1308 <malloc+0x29a>
     442:	379000ef          	jal	fba <printf>
     446:	b7c5                	j	426 <go+0x3b2>
        printf("grind: fork failed\n");
     448:	00001517          	auipc	a0,0x1
     44c:	e3850513          	addi	a0,a0,-456 # 1280 <malloc+0x212>
     450:	36b000ef          	jal	fba <printf>
        exit(1);
     454:	4505                	li	a0,1
     456:	71c000ef          	jal	b72 <exit>
    } else if(what == 20){
      int pid = fork();
     45a:	710000ef          	jal	b6a <fork>
      if(pid == 0){
     45e:	c519                	beqz	a0,46c <go+0x3f8>
        chdir("a");
        unlink("../a");
        fd = open("x", O_CREATE|O_RDWR);
        unlink("x");
        exit(0);
      } else if(pid < 0){
     460:	04054f63          	bltz	a0,4be <go+0x44a>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     464:	4501                	li	a0,0
     466:	714000ef          	jal	b7a <wait>
     46a:	b971                	j	106 <go+0x92>
        unlink("a");
     46c:	00001517          	auipc	a0,0x1
     470:	e2c50513          	addi	a0,a0,-468 # 1298 <malloc+0x22a>
     474:	74e000ef          	jal	bc2 <unlink>
        mkdir("a");
     478:	00001517          	auipc	a0,0x1
     47c:	e2050513          	addi	a0,a0,-480 # 1298 <malloc+0x22a>
     480:	75a000ef          	jal	bda <mkdir>
        chdir("a");
     484:	00001517          	auipc	a0,0x1
     488:	e1450513          	addi	a0,a0,-492 # 1298 <malloc+0x22a>
     48c:	756000ef          	jal	be2 <chdir>
        unlink("../a");
     490:	00001517          	auipc	a0,0x1
     494:	e9850513          	addi	a0,a0,-360 # 1328 <malloc+0x2ba>
     498:	72a000ef          	jal	bc2 <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     49c:	20200593          	li	a1,514
     4a0:	00001517          	auipc	a0,0x1
     4a4:	e4050513          	addi	a0,a0,-448 # 12e0 <malloc+0x272>
     4a8:	70a000ef          	jal	bb2 <open>
        unlink("x");
     4ac:	00001517          	auipc	a0,0x1
     4b0:	e3450513          	addi	a0,a0,-460 # 12e0 <malloc+0x272>
     4b4:	70e000ef          	jal	bc2 <unlink>
        exit(0);
     4b8:	4501                	li	a0,0
     4ba:	6b8000ef          	jal	b72 <exit>
        printf("grind: fork failed\n");
     4be:	00001517          	auipc	a0,0x1
     4c2:	dc250513          	addi	a0,a0,-574 # 1280 <malloc+0x212>
     4c6:	2f5000ef          	jal	fba <printf>
        exit(1);
     4ca:	4505                	li	a0,1
     4cc:	6a6000ef          	jal	b72 <exit>
    } else if(what == 21){
      unlink("c");
     4d0:	00001517          	auipc	a0,0x1
     4d4:	e6050513          	addi	a0,a0,-416 # 1330 <malloc+0x2c2>
     4d8:	6ea000ef          	jal	bc2 <unlink>
      // should always succeed. check that there are free i-nodes,
      // file descriptors, blocks.
      int fd1 = open("c", O_CREATE|O_RDWR);
     4dc:	20200593          	li	a1,514
     4e0:	00001517          	auipc	a0,0x1
     4e4:	e5050513          	addi	a0,a0,-432 # 1330 <malloc+0x2c2>
     4e8:	6ca000ef          	jal	bb2 <open>
     4ec:	8b2a                	mv	s6,a0
      if(fd1 < 0){
     4ee:	04054763          	bltz	a0,53c <go+0x4c8>
        printf("grind: create c failed\n");
        exit(1);
      }
      if(write(fd1, "x", 1) != 1){
     4f2:	4605                	li	a2,1
     4f4:	00001597          	auipc	a1,0x1
     4f8:	dec58593          	addi	a1,a1,-532 # 12e0 <malloc+0x272>
     4fc:	696000ef          	jal	b92 <write>
     500:	4785                	li	a5,1
     502:	04f51663          	bne	a0,a5,54e <go+0x4da>
        printf("grind: write c failed\n");
        exit(1);
      }
      struct stat st;
      if(fstat(fd1, &st) != 0){
     506:	fa840593          	addi	a1,s0,-88
     50a:	855a                	mv	a0,s6
     50c:	6be000ef          	jal	bca <fstat>
     510:	e921                	bnez	a0,560 <go+0x4ec>
        printf("grind: fstat failed\n");
        exit(1);
      }
      if(st.size != 1){
     512:	fb843583          	ld	a1,-72(s0)
     516:	4785                	li	a5,1
     518:	04f59d63          	bne	a1,a5,572 <go+0x4fe>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
        exit(1);
      }
      if(st.ino > 200){
     51c:	fac42583          	lw	a1,-84(s0)
     520:	0c800793          	li	a5,200
     524:	06b7e163          	bltu	a5,a1,586 <go+0x512>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
        exit(1);
      }
      close(fd1);
     528:	855a                	mv	a0,s6
     52a:	670000ef          	jal	b9a <close>
      unlink("c");
     52e:	00001517          	auipc	a0,0x1
     532:	e0250513          	addi	a0,a0,-510 # 1330 <malloc+0x2c2>
     536:	68c000ef          	jal	bc2 <unlink>
     53a:	b6f1                	j	106 <go+0x92>
        printf("grind: create c failed\n");
     53c:	00001517          	auipc	a0,0x1
     540:	dfc50513          	addi	a0,a0,-516 # 1338 <malloc+0x2ca>
     544:	277000ef          	jal	fba <printf>
        exit(1);
     548:	4505                	li	a0,1
     54a:	628000ef          	jal	b72 <exit>
        printf("grind: write c failed\n");
     54e:	00001517          	auipc	a0,0x1
     552:	e0250513          	addi	a0,a0,-510 # 1350 <malloc+0x2e2>
     556:	265000ef          	jal	fba <printf>
        exit(1);
     55a:	4505                	li	a0,1
     55c:	616000ef          	jal	b72 <exit>
        printf("grind: fstat failed\n");
     560:	00001517          	auipc	a0,0x1
     564:	e0850513          	addi	a0,a0,-504 # 1368 <malloc+0x2fa>
     568:	253000ef          	jal	fba <printf>
        exit(1);
     56c:	4505                	li	a0,1
     56e:	604000ef          	jal	b72 <exit>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     572:	2581                	sext.w	a1,a1
     574:	00001517          	auipc	a0,0x1
     578:	e0c50513          	addi	a0,a0,-500 # 1380 <malloc+0x312>
     57c:	23f000ef          	jal	fba <printf>
        exit(1);
     580:	4505                	li	a0,1
     582:	5f0000ef          	jal	b72 <exit>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     586:	00001517          	auipc	a0,0x1
     58a:	e2250513          	addi	a0,a0,-478 # 13a8 <malloc+0x33a>
     58e:	22d000ef          	jal	fba <printf>
        exit(1);
     592:	4505                	li	a0,1
     594:	5de000ef          	jal	b72 <exit>
    } else if(what == 22){
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
     598:	f9840513          	addi	a0,s0,-104
     59c:	5e6000ef          	jal	b82 <pipe>
     5a0:	0c054263          	bltz	a0,664 <go+0x5f0>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      if(pipe(bb) < 0){
     5a4:	fa040513          	addi	a0,s0,-96
     5a8:	5da000ef          	jal	b82 <pipe>
     5ac:	0c054663          	bltz	a0,678 <go+0x604>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      int pid1 = fork();
     5b0:	5ba000ef          	jal	b6a <fork>
      if(pid1 == 0){
     5b4:	0c050c63          	beqz	a0,68c <go+0x618>
        close(aa[1]);
        char *args[3] = { "echo", "hi", 0 };
        exec("grindir/../echo", args);
        fprintf(2, "grind: echo: not found\n");
        exit(2);
      } else if(pid1 < 0){
     5b8:	14054e63          	bltz	a0,714 <go+0x6a0>
        fprintf(2, "grind: fork failed\n");
        exit(3);
      }
      int pid2 = fork();
     5bc:	5ae000ef          	jal	b6a <fork>
      if(pid2 == 0){
     5c0:	16050463          	beqz	a0,728 <go+0x6b4>
        close(bb[1]);
        char *args[2] = { "cat", 0 };
        exec("/cat", args);
        fprintf(2, "grind: cat: not found\n");
        exit(6);
      } else if(pid2 < 0){
     5c4:	20054263          	bltz	a0,7c8 <go+0x754>
        fprintf(2, "grind: fork failed\n");
        exit(7);
      }
      close(aa[0]);
     5c8:	f9842503          	lw	a0,-104(s0)
     5cc:	5ce000ef          	jal	b9a <close>
      close(aa[1]);
     5d0:	f9c42503          	lw	a0,-100(s0)
     5d4:	5c6000ef          	jal	b9a <close>
      close(bb[1]);
     5d8:	fa442503          	lw	a0,-92(s0)
     5dc:	5be000ef          	jal	b9a <close>
      char buf[4] = { 0, 0, 0, 0 };
     5e0:	f8042823          	sw	zero,-112(s0)
      read(bb[0], buf+0, 1);
     5e4:	4605                	li	a2,1
     5e6:	f9040593          	addi	a1,s0,-112
     5ea:	fa042503          	lw	a0,-96(s0)
     5ee:	59c000ef          	jal	b8a <read>
      read(bb[0], buf+1, 1);
     5f2:	4605                	li	a2,1
     5f4:	f9140593          	addi	a1,s0,-111
     5f8:	fa042503          	lw	a0,-96(s0)
     5fc:	58e000ef          	jal	b8a <read>
      read(bb[0], buf+2, 1);
     600:	4605                	li	a2,1
     602:	f9240593          	addi	a1,s0,-110
     606:	fa042503          	lw	a0,-96(s0)
     60a:	580000ef          	jal	b8a <read>
      close(bb[0]);
     60e:	fa042503          	lw	a0,-96(s0)
     612:	588000ef          	jal	b9a <close>
      int st1, st2;
      wait(&st1);
     616:	f9440513          	addi	a0,s0,-108
     61a:	560000ef          	jal	b7a <wait>
      wait(&st2);
     61e:	fa840513          	addi	a0,s0,-88
     622:	558000ef          	jal	b7a <wait>
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi\n") != 0){
     626:	f9442783          	lw	a5,-108(s0)
     62a:	fa842703          	lw	a4,-88(s0)
     62e:	8fd9                	or	a5,a5,a4
     630:	eb99                	bnez	a5,646 <go+0x5d2>
     632:	00001597          	auipc	a1,0x1
     636:	e1658593          	addi	a1,a1,-490 # 1448 <malloc+0x3da>
     63a:	f9040513          	addi	a0,s0,-112
     63e:	2cc000ef          	jal	90a <strcmp>
     642:	ac0502e3          	beqz	a0,106 <go+0x92>
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     646:	f9040693          	addi	a3,s0,-112
     64a:	fa842603          	lw	a2,-88(s0)
     64e:	f9442583          	lw	a1,-108(s0)
     652:	00001517          	auipc	a0,0x1
     656:	dfe50513          	addi	a0,a0,-514 # 1450 <malloc+0x3e2>
     65a:	161000ef          	jal	fba <printf>
        exit(1);
     65e:	4505                	li	a0,1
     660:	512000ef          	jal	b72 <exit>
        fprintf(2, "grind: pipe failed\n");
     664:	00001597          	auipc	a1,0x1
     668:	c6458593          	addi	a1,a1,-924 # 12c8 <malloc+0x25a>
     66c:	4509                	li	a0,2
     66e:	123000ef          	jal	f90 <fprintf>
        exit(1);
     672:	4505                	li	a0,1
     674:	4fe000ef          	jal	b72 <exit>
        fprintf(2, "grind: pipe failed\n");
     678:	00001597          	auipc	a1,0x1
     67c:	c5058593          	addi	a1,a1,-944 # 12c8 <malloc+0x25a>
     680:	4509                	li	a0,2
     682:	10f000ef          	jal	f90 <fprintf>
        exit(1);
     686:	4505                	li	a0,1
     688:	4ea000ef          	jal	b72 <exit>
        close(bb[0]);
     68c:	fa042503          	lw	a0,-96(s0)
     690:	50a000ef          	jal	b9a <close>
        close(bb[1]);
     694:	fa442503          	lw	a0,-92(s0)
     698:	502000ef          	jal	b9a <close>
        close(aa[0]);
     69c:	f9842503          	lw	a0,-104(s0)
     6a0:	4fa000ef          	jal	b9a <close>
        close(1);
     6a4:	4505                	li	a0,1
     6a6:	4f4000ef          	jal	b9a <close>
        if(dup(aa[1]) != 1){
     6aa:	f9c42503          	lw	a0,-100(s0)
     6ae:	53c000ef          	jal	bea <dup>
     6b2:	4785                	li	a5,1
     6b4:	00f50c63          	beq	a0,a5,6cc <go+0x658>
          fprintf(2, "grind: dup failed\n");
     6b8:	00001597          	auipc	a1,0x1
     6bc:	d1858593          	addi	a1,a1,-744 # 13d0 <malloc+0x362>
     6c0:	4509                	li	a0,2
     6c2:	0cf000ef          	jal	f90 <fprintf>
          exit(1);
     6c6:	4505                	li	a0,1
     6c8:	4aa000ef          	jal	b72 <exit>
        close(aa[1]);
     6cc:	f9c42503          	lw	a0,-100(s0)
     6d0:	4ca000ef          	jal	b9a <close>
        char *args[3] = { "echo", "hi", 0 };
     6d4:	00001797          	auipc	a5,0x1
     6d8:	d1478793          	addi	a5,a5,-748 # 13e8 <malloc+0x37a>
     6dc:	faf43423          	sd	a5,-88(s0)
     6e0:	00001797          	auipc	a5,0x1
     6e4:	d1078793          	addi	a5,a5,-752 # 13f0 <malloc+0x382>
     6e8:	faf43823          	sd	a5,-80(s0)
     6ec:	fa043c23          	sd	zero,-72(s0)
        exec("grindir/../echo", args);
     6f0:	fa840593          	addi	a1,s0,-88
     6f4:	00001517          	auipc	a0,0x1
     6f8:	d0450513          	addi	a0,a0,-764 # 13f8 <malloc+0x38a>
     6fc:	4ae000ef          	jal	baa <exec>
        fprintf(2, "grind: echo: not found\n");
     700:	00001597          	auipc	a1,0x1
     704:	d0858593          	addi	a1,a1,-760 # 1408 <malloc+0x39a>
     708:	4509                	li	a0,2
     70a:	087000ef          	jal	f90 <fprintf>
        exit(2);
     70e:	4509                	li	a0,2
     710:	462000ef          	jal	b72 <exit>
        fprintf(2, "grind: fork failed\n");
     714:	00001597          	auipc	a1,0x1
     718:	b6c58593          	addi	a1,a1,-1172 # 1280 <malloc+0x212>
     71c:	4509                	li	a0,2
     71e:	073000ef          	jal	f90 <fprintf>
        exit(3);
     722:	450d                	li	a0,3
     724:	44e000ef          	jal	b72 <exit>
        close(aa[1]);
     728:	f9c42503          	lw	a0,-100(s0)
     72c:	46e000ef          	jal	b9a <close>
        close(bb[0]);
     730:	fa042503          	lw	a0,-96(s0)
     734:	466000ef          	jal	b9a <close>
        close(0);
     738:	4501                	li	a0,0
     73a:	460000ef          	jal	b9a <close>
        if(dup(aa[0]) != 0){
     73e:	f9842503          	lw	a0,-104(s0)
     742:	4a8000ef          	jal	bea <dup>
     746:	c919                	beqz	a0,75c <go+0x6e8>
          fprintf(2, "grind: dup failed\n");
     748:	00001597          	auipc	a1,0x1
     74c:	c8858593          	addi	a1,a1,-888 # 13d0 <malloc+0x362>
     750:	4509                	li	a0,2
     752:	03f000ef          	jal	f90 <fprintf>
          exit(4);
     756:	4511                	li	a0,4
     758:	41a000ef          	jal	b72 <exit>
        close(aa[0]);
     75c:	f9842503          	lw	a0,-104(s0)
     760:	43a000ef          	jal	b9a <close>
        close(1);
     764:	4505                	li	a0,1
     766:	434000ef          	jal	b9a <close>
        if(dup(bb[1]) != 1){
     76a:	fa442503          	lw	a0,-92(s0)
     76e:	47c000ef          	jal	bea <dup>
     772:	4785                	li	a5,1
     774:	00f50c63          	beq	a0,a5,78c <go+0x718>
          fprintf(2, "grind: dup failed\n");
     778:	00001597          	auipc	a1,0x1
     77c:	c5858593          	addi	a1,a1,-936 # 13d0 <malloc+0x362>
     780:	4509                	li	a0,2
     782:	00f000ef          	jal	f90 <fprintf>
          exit(5);
     786:	4515                	li	a0,5
     788:	3ea000ef          	jal	b72 <exit>
        close(bb[1]);
     78c:	fa442503          	lw	a0,-92(s0)
     790:	40a000ef          	jal	b9a <close>
        char *args[2] = { "cat", 0 };
     794:	00001797          	auipc	a5,0x1
     798:	c8c78793          	addi	a5,a5,-884 # 1420 <malloc+0x3b2>
     79c:	faf43423          	sd	a5,-88(s0)
     7a0:	fa043823          	sd	zero,-80(s0)
        exec("/cat", args);
     7a4:	fa840593          	addi	a1,s0,-88
     7a8:	00001517          	auipc	a0,0x1
     7ac:	c8050513          	addi	a0,a0,-896 # 1428 <malloc+0x3ba>
     7b0:	3fa000ef          	jal	baa <exec>
        fprintf(2, "grind: cat: not found\n");
     7b4:	00001597          	auipc	a1,0x1
     7b8:	c7c58593          	addi	a1,a1,-900 # 1430 <malloc+0x3c2>
     7bc:	4509                	li	a0,2
     7be:	7d2000ef          	jal	f90 <fprintf>
        exit(6);
     7c2:	4519                	li	a0,6
     7c4:	3ae000ef          	jal	b72 <exit>
        fprintf(2, "grind: fork failed\n");
     7c8:	00001597          	auipc	a1,0x1
     7cc:	ab858593          	addi	a1,a1,-1352 # 1280 <malloc+0x212>
     7d0:	4509                	li	a0,2
     7d2:	7be000ef          	jal	f90 <fprintf>
        exit(7);
     7d6:	451d                	li	a0,7
     7d8:	39a000ef          	jal	b72 <exit>

00000000000007dc <iter>:
  }
}

void
iter()
{
     7dc:	7179                	addi	sp,sp,-48
     7de:	f406                	sd	ra,40(sp)
     7e0:	f022                	sd	s0,32(sp)
     7e2:	1800                	addi	s0,sp,48
  unlink("a");
     7e4:	00001517          	auipc	a0,0x1
     7e8:	ab450513          	addi	a0,a0,-1356 # 1298 <malloc+0x22a>
     7ec:	3d6000ef          	jal	bc2 <unlink>
  unlink("b");
     7f0:	00001517          	auipc	a0,0x1
     7f4:	a5850513          	addi	a0,a0,-1448 # 1248 <malloc+0x1da>
     7f8:	3ca000ef          	jal	bc2 <unlink>
  
  int pid1 = fork();
     7fc:	36e000ef          	jal	b6a <fork>
  if(pid1 < 0){
     800:	02054163          	bltz	a0,822 <iter+0x46>
     804:	ec26                	sd	s1,24(sp)
     806:	84aa                	mv	s1,a0
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid1 == 0){
     808:	e905                	bnez	a0,838 <iter+0x5c>
     80a:	e84a                	sd	s2,16(sp)
    rand_next ^= 31;
     80c:	00001717          	auipc	a4,0x1
     810:	7f470713          	addi	a4,a4,2036 # 2000 <rand_next>
     814:	631c                	ld	a5,0(a4)
     816:	01f7c793          	xori	a5,a5,31
     81a:	e31c                	sd	a5,0(a4)
    go(0);
     81c:	4501                	li	a0,0
     81e:	857ff0ef          	jal	74 <go>
     822:	ec26                	sd	s1,24(sp)
     824:	e84a                	sd	s2,16(sp)
    printf("grind: fork failed\n");
     826:	00001517          	auipc	a0,0x1
     82a:	a5a50513          	addi	a0,a0,-1446 # 1280 <malloc+0x212>
     82e:	78c000ef          	jal	fba <printf>
    exit(1);
     832:	4505                	li	a0,1
     834:	33e000ef          	jal	b72 <exit>
     838:	e84a                	sd	s2,16(sp)
    exit(0);
  }

  int pid2 = fork();
     83a:	330000ef          	jal	b6a <fork>
     83e:	892a                	mv	s2,a0
  if(pid2 < 0){
     840:	02054063          	bltz	a0,860 <iter+0x84>
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid2 == 0){
     844:	e51d                	bnez	a0,872 <iter+0x96>
    rand_next ^= 7177;
     846:	00001697          	auipc	a3,0x1
     84a:	7ba68693          	addi	a3,a3,1978 # 2000 <rand_next>
     84e:	629c                	ld	a5,0(a3)
     850:	6709                	lui	a4,0x2
     852:	c0970713          	addi	a4,a4,-1015 # 1c09 <digits+0x729>
     856:	8fb9                	xor	a5,a5,a4
     858:	e29c                	sd	a5,0(a3)
    go(1);
     85a:	4505                	li	a0,1
     85c:	819ff0ef          	jal	74 <go>
    printf("grind: fork failed\n");
     860:	00001517          	auipc	a0,0x1
     864:	a2050513          	addi	a0,a0,-1504 # 1280 <malloc+0x212>
     868:	752000ef          	jal	fba <printf>
    exit(1);
     86c:	4505                	li	a0,1
     86e:	304000ef          	jal	b72 <exit>
    exit(0);
  }

  int st1 = -1;
     872:	57fd                	li	a5,-1
     874:	fcf42e23          	sw	a5,-36(s0)
  wait(&st1);
     878:	fdc40513          	addi	a0,s0,-36
     87c:	2fe000ef          	jal	b7a <wait>
  if(st1 != 0){
     880:	fdc42783          	lw	a5,-36(s0)
     884:	eb99                	bnez	a5,89a <iter+0xbe>
    kill(pid1);
    kill(pid2);
  }
  int st2 = -1;
     886:	57fd                	li	a5,-1
     888:	fcf42c23          	sw	a5,-40(s0)
  wait(&st2);
     88c:	fd840513          	addi	a0,s0,-40
     890:	2ea000ef          	jal	b7a <wait>

  exit(0);
     894:	4501                	li	a0,0
     896:	2dc000ef          	jal	b72 <exit>
    kill(pid1);
     89a:	8526                	mv	a0,s1
     89c:	306000ef          	jal	ba2 <kill>
    kill(pid2);
     8a0:	854a                	mv	a0,s2
     8a2:	300000ef          	jal	ba2 <kill>
     8a6:	b7c5                	j	886 <iter+0xaa>

00000000000008a8 <main>:
}

int
main()
{
     8a8:	1101                	addi	sp,sp,-32
     8aa:	ec06                	sd	ra,24(sp)
     8ac:	e822                	sd	s0,16(sp)
     8ae:	e426                	sd	s1,8(sp)
     8b0:	1000                	addi	s0,sp,32
    }
    if(pid > 0){
      wait(0);
    }
    pause(20);
    rand_next += 1;
     8b2:	00001497          	auipc	s1,0x1
     8b6:	74e48493          	addi	s1,s1,1870 # 2000 <rand_next>
     8ba:	a809                	j	8cc <main+0x24>
      iter();
     8bc:	f21ff0ef          	jal	7dc <iter>
    pause(20);
     8c0:	4551                	li	a0,20
     8c2:	340000ef          	jal	c02 <pause>
    rand_next += 1;
     8c6:	609c                	ld	a5,0(s1)
     8c8:	0785                	addi	a5,a5,1
     8ca:	e09c                	sd	a5,0(s1)
    int pid = fork();
     8cc:	29e000ef          	jal	b6a <fork>
    if(pid == 0){
     8d0:	d575                	beqz	a0,8bc <main+0x14>
    if(pid > 0){
     8d2:	fea057e3          	blez	a0,8c0 <main+0x18>
      wait(0);
     8d6:	4501                	li	a0,0
     8d8:	2a2000ef          	jal	b7a <wait>
     8dc:	b7d5                	j	8c0 <main+0x18>

00000000000008de <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
     8de:	1141                	addi	sp,sp,-16
     8e0:	e406                	sd	ra,8(sp)
     8e2:	e022                	sd	s0,0(sp)
     8e4:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
     8e6:	fc3ff0ef          	jal	8a8 <main>
  exit(r);
     8ea:	288000ef          	jal	b72 <exit>

00000000000008ee <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     8ee:	1141                	addi	sp,sp,-16
     8f0:	e422                	sd	s0,8(sp)
     8f2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     8f4:	87aa                	mv	a5,a0
     8f6:	0585                	addi	a1,a1,1
     8f8:	0785                	addi	a5,a5,1
     8fa:	fff5c703          	lbu	a4,-1(a1)
     8fe:	fee78fa3          	sb	a4,-1(a5)
     902:	fb75                	bnez	a4,8f6 <strcpy+0x8>
    ;
  return os;
}
     904:	6422                	ld	s0,8(sp)
     906:	0141                	addi	sp,sp,16
     908:	8082                	ret

000000000000090a <strcmp>:

int
strcmp(const char *p, const char *q)
{
     90a:	1141                	addi	sp,sp,-16
     90c:	e422                	sd	s0,8(sp)
     90e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     910:	00054783          	lbu	a5,0(a0)
     914:	cb91                	beqz	a5,928 <strcmp+0x1e>
     916:	0005c703          	lbu	a4,0(a1)
     91a:	00f71763          	bne	a4,a5,928 <strcmp+0x1e>
    p++, q++;
     91e:	0505                	addi	a0,a0,1
     920:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     922:	00054783          	lbu	a5,0(a0)
     926:	fbe5                	bnez	a5,916 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     928:	0005c503          	lbu	a0,0(a1)
}
     92c:	40a7853b          	subw	a0,a5,a0
     930:	6422                	ld	s0,8(sp)
     932:	0141                	addi	sp,sp,16
     934:	8082                	ret

0000000000000936 <strlen>:

uint
strlen(const char *s)
{
     936:	1141                	addi	sp,sp,-16
     938:	e422                	sd	s0,8(sp)
     93a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     93c:	00054783          	lbu	a5,0(a0)
     940:	cf91                	beqz	a5,95c <strlen+0x26>
     942:	0505                	addi	a0,a0,1
     944:	87aa                	mv	a5,a0
     946:	86be                	mv	a3,a5
     948:	0785                	addi	a5,a5,1
     94a:	fff7c703          	lbu	a4,-1(a5)
     94e:	ff65                	bnez	a4,946 <strlen+0x10>
     950:	40a6853b          	subw	a0,a3,a0
     954:	2505                	addiw	a0,a0,1
    ;
  return n;
}
     956:	6422                	ld	s0,8(sp)
     958:	0141                	addi	sp,sp,16
     95a:	8082                	ret
  for(n = 0; s[n]; n++)
     95c:	4501                	li	a0,0
     95e:	bfe5                	j	956 <strlen+0x20>

0000000000000960 <memset>:

void*
memset(void *dst, int c, uint n)
{
     960:	1141                	addi	sp,sp,-16
     962:	e422                	sd	s0,8(sp)
     964:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     966:	ca19                	beqz	a2,97c <memset+0x1c>
     968:	87aa                	mv	a5,a0
     96a:	1602                	slli	a2,a2,0x20
     96c:	9201                	srli	a2,a2,0x20
     96e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     972:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     976:	0785                	addi	a5,a5,1
     978:	fee79de3          	bne	a5,a4,972 <memset+0x12>
  }
  return dst;
}
     97c:	6422                	ld	s0,8(sp)
     97e:	0141                	addi	sp,sp,16
     980:	8082                	ret

0000000000000982 <strchr>:

char*
strchr(const char *s, char c)
{
     982:	1141                	addi	sp,sp,-16
     984:	e422                	sd	s0,8(sp)
     986:	0800                	addi	s0,sp,16
  for(; *s; s++)
     988:	00054783          	lbu	a5,0(a0)
     98c:	cb99                	beqz	a5,9a2 <strchr+0x20>
    if(*s == c)
     98e:	00f58763          	beq	a1,a5,99c <strchr+0x1a>
  for(; *s; s++)
     992:	0505                	addi	a0,a0,1
     994:	00054783          	lbu	a5,0(a0)
     998:	fbfd                	bnez	a5,98e <strchr+0xc>
      return (char*)s;
  return 0;
     99a:	4501                	li	a0,0
}
     99c:	6422                	ld	s0,8(sp)
     99e:	0141                	addi	sp,sp,16
     9a0:	8082                	ret
  return 0;
     9a2:	4501                	li	a0,0
     9a4:	bfe5                	j	99c <strchr+0x1a>

00000000000009a6 <gets>:

char*
gets(char *buf, int max)
{
     9a6:	711d                	addi	sp,sp,-96
     9a8:	ec86                	sd	ra,88(sp)
     9aa:	e8a2                	sd	s0,80(sp)
     9ac:	e4a6                	sd	s1,72(sp)
     9ae:	e0ca                	sd	s2,64(sp)
     9b0:	fc4e                	sd	s3,56(sp)
     9b2:	f852                	sd	s4,48(sp)
     9b4:	f456                	sd	s5,40(sp)
     9b6:	f05a                	sd	s6,32(sp)
     9b8:	ec5e                	sd	s7,24(sp)
     9ba:	1080                	addi	s0,sp,96
     9bc:	8baa                	mv	s7,a0
     9be:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     9c0:	892a                	mv	s2,a0
     9c2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     9c4:	4aa9                	li	s5,10
     9c6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     9c8:	89a6                	mv	s3,s1
     9ca:	2485                	addiw	s1,s1,1
     9cc:	0344d663          	bge	s1,s4,9f8 <gets+0x52>
    cc = read(0, &c, 1);
     9d0:	4605                	li	a2,1
     9d2:	faf40593          	addi	a1,s0,-81
     9d6:	4501                	li	a0,0
     9d8:	1b2000ef          	jal	b8a <read>
    if(cc < 1)
     9dc:	00a05e63          	blez	a0,9f8 <gets+0x52>
    buf[i++] = c;
     9e0:	faf44783          	lbu	a5,-81(s0)
     9e4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     9e8:	01578763          	beq	a5,s5,9f6 <gets+0x50>
     9ec:	0905                	addi	s2,s2,1
     9ee:	fd679de3          	bne	a5,s6,9c8 <gets+0x22>
    buf[i++] = c;
     9f2:	89a6                	mv	s3,s1
     9f4:	a011                	j	9f8 <gets+0x52>
     9f6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     9f8:	99de                	add	s3,s3,s7
     9fa:	00098023          	sb	zero,0(s3)
  return buf;
}
     9fe:	855e                	mv	a0,s7
     a00:	60e6                	ld	ra,88(sp)
     a02:	6446                	ld	s0,80(sp)
     a04:	64a6                	ld	s1,72(sp)
     a06:	6906                	ld	s2,64(sp)
     a08:	79e2                	ld	s3,56(sp)
     a0a:	7a42                	ld	s4,48(sp)
     a0c:	7aa2                	ld	s5,40(sp)
     a0e:	7b02                	ld	s6,32(sp)
     a10:	6be2                	ld	s7,24(sp)
     a12:	6125                	addi	sp,sp,96
     a14:	8082                	ret

0000000000000a16 <stat>:

int
stat(const char *n, struct stat *st)
{
     a16:	1101                	addi	sp,sp,-32
     a18:	ec06                	sd	ra,24(sp)
     a1a:	e822                	sd	s0,16(sp)
     a1c:	e04a                	sd	s2,0(sp)
     a1e:	1000                	addi	s0,sp,32
     a20:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     a22:	4581                	li	a1,0
     a24:	18e000ef          	jal	bb2 <open>
  if(fd < 0)
     a28:	02054263          	bltz	a0,a4c <stat+0x36>
     a2c:	e426                	sd	s1,8(sp)
     a2e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     a30:	85ca                	mv	a1,s2
     a32:	198000ef          	jal	bca <fstat>
     a36:	892a                	mv	s2,a0
  close(fd);
     a38:	8526                	mv	a0,s1
     a3a:	160000ef          	jal	b9a <close>
  return r;
     a3e:	64a2                	ld	s1,8(sp)
}
     a40:	854a                	mv	a0,s2
     a42:	60e2                	ld	ra,24(sp)
     a44:	6442                	ld	s0,16(sp)
     a46:	6902                	ld	s2,0(sp)
     a48:	6105                	addi	sp,sp,32
     a4a:	8082                	ret
    return -1;
     a4c:	597d                	li	s2,-1
     a4e:	bfcd                	j	a40 <stat+0x2a>

0000000000000a50 <atoi>:

int
atoi(const char *s)
{
     a50:	1141                	addi	sp,sp,-16
     a52:	e422                	sd	s0,8(sp)
     a54:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     a56:	00054683          	lbu	a3,0(a0)
     a5a:	fd06879b          	addiw	a5,a3,-48
     a5e:	0ff7f793          	zext.b	a5,a5
     a62:	4625                	li	a2,9
     a64:	02f66863          	bltu	a2,a5,a94 <atoi+0x44>
     a68:	872a                	mv	a4,a0
  n = 0;
     a6a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     a6c:	0705                	addi	a4,a4,1
     a6e:	0025179b          	slliw	a5,a0,0x2
     a72:	9fa9                	addw	a5,a5,a0
     a74:	0017979b          	slliw	a5,a5,0x1
     a78:	9fb5                	addw	a5,a5,a3
     a7a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     a7e:	00074683          	lbu	a3,0(a4)
     a82:	fd06879b          	addiw	a5,a3,-48
     a86:	0ff7f793          	zext.b	a5,a5
     a8a:	fef671e3          	bgeu	a2,a5,a6c <atoi+0x1c>
  return n;
}
     a8e:	6422                	ld	s0,8(sp)
     a90:	0141                	addi	sp,sp,16
     a92:	8082                	ret
  n = 0;
     a94:	4501                	li	a0,0
     a96:	bfe5                	j	a8e <atoi+0x3e>

0000000000000a98 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     a98:	1141                	addi	sp,sp,-16
     a9a:	e422                	sd	s0,8(sp)
     a9c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     a9e:	02b57463          	bgeu	a0,a1,ac6 <memmove+0x2e>
    while(n-- > 0)
     aa2:	00c05f63          	blez	a2,ac0 <memmove+0x28>
     aa6:	1602                	slli	a2,a2,0x20
     aa8:	9201                	srli	a2,a2,0x20
     aaa:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     aae:	872a                	mv	a4,a0
      *dst++ = *src++;
     ab0:	0585                	addi	a1,a1,1
     ab2:	0705                	addi	a4,a4,1
     ab4:	fff5c683          	lbu	a3,-1(a1)
     ab8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     abc:	fef71ae3          	bne	a4,a5,ab0 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     ac0:	6422                	ld	s0,8(sp)
     ac2:	0141                	addi	sp,sp,16
     ac4:	8082                	ret
    dst += n;
     ac6:	00c50733          	add	a4,a0,a2
    src += n;
     aca:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     acc:	fec05ae3          	blez	a2,ac0 <memmove+0x28>
     ad0:	fff6079b          	addiw	a5,a2,-1
     ad4:	1782                	slli	a5,a5,0x20
     ad6:	9381                	srli	a5,a5,0x20
     ad8:	fff7c793          	not	a5,a5
     adc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     ade:	15fd                	addi	a1,a1,-1
     ae0:	177d                	addi	a4,a4,-1
     ae2:	0005c683          	lbu	a3,0(a1)
     ae6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     aea:	fee79ae3          	bne	a5,a4,ade <memmove+0x46>
     aee:	bfc9                	j	ac0 <memmove+0x28>

0000000000000af0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     af0:	1141                	addi	sp,sp,-16
     af2:	e422                	sd	s0,8(sp)
     af4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     af6:	ca05                	beqz	a2,b26 <memcmp+0x36>
     af8:	fff6069b          	addiw	a3,a2,-1
     afc:	1682                	slli	a3,a3,0x20
     afe:	9281                	srli	a3,a3,0x20
     b00:	0685                	addi	a3,a3,1
     b02:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     b04:	00054783          	lbu	a5,0(a0)
     b08:	0005c703          	lbu	a4,0(a1)
     b0c:	00e79863          	bne	a5,a4,b1c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     b10:	0505                	addi	a0,a0,1
    p2++;
     b12:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     b14:	fed518e3          	bne	a0,a3,b04 <memcmp+0x14>
  }
  return 0;
     b18:	4501                	li	a0,0
     b1a:	a019                	j	b20 <memcmp+0x30>
      return *p1 - *p2;
     b1c:	40e7853b          	subw	a0,a5,a4
}
     b20:	6422                	ld	s0,8(sp)
     b22:	0141                	addi	sp,sp,16
     b24:	8082                	ret
  return 0;
     b26:	4501                	li	a0,0
     b28:	bfe5                	j	b20 <memcmp+0x30>

0000000000000b2a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     b2a:	1141                	addi	sp,sp,-16
     b2c:	e406                	sd	ra,8(sp)
     b2e:	e022                	sd	s0,0(sp)
     b30:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     b32:	f67ff0ef          	jal	a98 <memmove>
}
     b36:	60a2                	ld	ra,8(sp)
     b38:	6402                	ld	s0,0(sp)
     b3a:	0141                	addi	sp,sp,16
     b3c:	8082                	ret

0000000000000b3e <sbrk>:

char *
sbrk(int n) {
     b3e:	1141                	addi	sp,sp,-16
     b40:	e406                	sd	ra,8(sp)
     b42:	e022                	sd	s0,0(sp)
     b44:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
     b46:	4585                	li	a1,1
     b48:	0b2000ef          	jal	bfa <sys_sbrk>
}
     b4c:	60a2                	ld	ra,8(sp)
     b4e:	6402                	ld	s0,0(sp)
     b50:	0141                	addi	sp,sp,16
     b52:	8082                	ret

0000000000000b54 <sbrklazy>:

char *
sbrklazy(int n) {
     b54:	1141                	addi	sp,sp,-16
     b56:	e406                	sd	ra,8(sp)
     b58:	e022                	sd	s0,0(sp)
     b5a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
     b5c:	4589                	li	a1,2
     b5e:	09c000ef          	jal	bfa <sys_sbrk>
}
     b62:	60a2                	ld	ra,8(sp)
     b64:	6402                	ld	s0,0(sp)
     b66:	0141                	addi	sp,sp,16
     b68:	8082                	ret

0000000000000b6a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     b6a:	4885                	li	a7,1
 ecall
     b6c:	00000073          	ecall
 ret
     b70:	8082                	ret

0000000000000b72 <exit>:
.global exit
exit:
 li a7, SYS_exit
     b72:	4889                	li	a7,2
 ecall
     b74:	00000073          	ecall
 ret
     b78:	8082                	ret

0000000000000b7a <wait>:
.global wait
wait:
 li a7, SYS_wait
     b7a:	488d                	li	a7,3
 ecall
     b7c:	00000073          	ecall
 ret
     b80:	8082                	ret

0000000000000b82 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     b82:	4891                	li	a7,4
 ecall
     b84:	00000073          	ecall
 ret
     b88:	8082                	ret

0000000000000b8a <read>:
.global read
read:
 li a7, SYS_read
     b8a:	4895                	li	a7,5
 ecall
     b8c:	00000073          	ecall
 ret
     b90:	8082                	ret

0000000000000b92 <write>:
.global write
write:
 li a7, SYS_write
     b92:	48c1                	li	a7,16
 ecall
     b94:	00000073          	ecall
 ret
     b98:	8082                	ret

0000000000000b9a <close>:
.global close
close:
 li a7, SYS_close
     b9a:	48d5                	li	a7,21
 ecall
     b9c:	00000073          	ecall
 ret
     ba0:	8082                	ret

0000000000000ba2 <kill>:
.global kill
kill:
 li a7, SYS_kill
     ba2:	4899                	li	a7,6
 ecall
     ba4:	00000073          	ecall
 ret
     ba8:	8082                	ret

0000000000000baa <exec>:
.global exec
exec:
 li a7, SYS_exec
     baa:	489d                	li	a7,7
 ecall
     bac:	00000073          	ecall
 ret
     bb0:	8082                	ret

0000000000000bb2 <open>:
.global open
open:
 li a7, SYS_open
     bb2:	48bd                	li	a7,15
 ecall
     bb4:	00000073          	ecall
 ret
     bb8:	8082                	ret

0000000000000bba <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     bba:	48c5                	li	a7,17
 ecall
     bbc:	00000073          	ecall
 ret
     bc0:	8082                	ret

0000000000000bc2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     bc2:	48c9                	li	a7,18
 ecall
     bc4:	00000073          	ecall
 ret
     bc8:	8082                	ret

0000000000000bca <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     bca:	48a1                	li	a7,8
 ecall
     bcc:	00000073          	ecall
 ret
     bd0:	8082                	ret

0000000000000bd2 <link>:
.global link
link:
 li a7, SYS_link
     bd2:	48cd                	li	a7,19
 ecall
     bd4:	00000073          	ecall
 ret
     bd8:	8082                	ret

0000000000000bda <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     bda:	48d1                	li	a7,20
 ecall
     bdc:	00000073          	ecall
 ret
     be0:	8082                	ret

0000000000000be2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     be2:	48a5                	li	a7,9
 ecall
     be4:	00000073          	ecall
 ret
     be8:	8082                	ret

0000000000000bea <dup>:
.global dup
dup:
 li a7, SYS_dup
     bea:	48a9                	li	a7,10
 ecall
     bec:	00000073          	ecall
 ret
     bf0:	8082                	ret

0000000000000bf2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     bf2:	48ad                	li	a7,11
 ecall
     bf4:	00000073          	ecall
 ret
     bf8:	8082                	ret

0000000000000bfa <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
     bfa:	48b1                	li	a7,12
 ecall
     bfc:	00000073          	ecall
 ret
     c00:	8082                	ret

0000000000000c02 <pause>:
.global pause
pause:
 li a7, SYS_pause
     c02:	48b5                	li	a7,13
 ecall
     c04:	00000073          	ecall
 ret
     c08:	8082                	ret

0000000000000c0a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     c0a:	48b9                	li	a7,14
 ecall
     c0c:	00000073          	ecall
 ret
     c10:	8082                	ret

0000000000000c12 <trace>:
.global trace
trace:
 li a7, SYS_trace
     c12:	48d9                	li	a7,22
 ecall
     c14:	00000073          	ecall
 ret
     c18:	8082                	ret

0000000000000c1a <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
     c1a:	48dd                	li	a7,23
 ecall
     c1c:	00000073          	ecall
 ret
     c20:	8082                	ret

0000000000000c22 <get_priority>:
.global get_priority
get_priority:
 li a7, SYS_get_priority
     c22:	48e1                	li	a7,24
 ecall
     c24:	00000073          	ecall
 ret
     c28:	8082                	ret

0000000000000c2a <cps>:
.global cps
cps:
 li a7, SYS_cps
     c2a:	48e5                	li	a7,25
 ecall
     c2c:	00000073          	ecall
 ret
     c30:	8082                	ret

0000000000000c32 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     c32:	1101                	addi	sp,sp,-32
     c34:	ec06                	sd	ra,24(sp)
     c36:	e822                	sd	s0,16(sp)
     c38:	1000                	addi	s0,sp,32
     c3a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     c3e:	4605                	li	a2,1
     c40:	fef40593          	addi	a1,s0,-17
     c44:	f4fff0ef          	jal	b92 <write>
}
     c48:	60e2                	ld	ra,24(sp)
     c4a:	6442                	ld	s0,16(sp)
     c4c:	6105                	addi	sp,sp,32
     c4e:	8082                	ret

0000000000000c50 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
     c50:	715d                	addi	sp,sp,-80
     c52:	e486                	sd	ra,72(sp)
     c54:	e0a2                	sd	s0,64(sp)
     c56:	f84a                	sd	s2,48(sp)
     c58:	0880                	addi	s0,sp,80
     c5a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
     c5c:	c299                	beqz	a3,c62 <printint+0x12>
     c5e:	0805c363          	bltz	a1,ce4 <printint+0x94>
  neg = 0;
     c62:	4881                	li	a7,0
     c64:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
     c68:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
     c6a:	00001517          	auipc	a0,0x1
     c6e:	87650513          	addi	a0,a0,-1930 # 14e0 <digits>
     c72:	883e                	mv	a6,a5
     c74:	2785                	addiw	a5,a5,1
     c76:	02c5f733          	remu	a4,a1,a2
     c7a:	972a                	add	a4,a4,a0
     c7c:	00074703          	lbu	a4,0(a4)
     c80:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
     c84:	872e                	mv	a4,a1
     c86:	02c5d5b3          	divu	a1,a1,a2
     c8a:	0685                	addi	a3,a3,1
     c8c:	fec773e3          	bgeu	a4,a2,c72 <printint+0x22>
  if(neg)
     c90:	00088b63          	beqz	a7,ca6 <printint+0x56>
    buf[i++] = '-';
     c94:	fd078793          	addi	a5,a5,-48
     c98:	97a2                	add	a5,a5,s0
     c9a:	02d00713          	li	a4,45
     c9e:	fee78423          	sb	a4,-24(a5)
     ca2:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
     ca6:	02f05a63          	blez	a5,cda <printint+0x8a>
     caa:	fc26                	sd	s1,56(sp)
     cac:	f44e                	sd	s3,40(sp)
     cae:	fb840713          	addi	a4,s0,-72
     cb2:	00f704b3          	add	s1,a4,a5
     cb6:	fff70993          	addi	s3,a4,-1
     cba:	99be                	add	s3,s3,a5
     cbc:	37fd                	addiw	a5,a5,-1
     cbe:	1782                	slli	a5,a5,0x20
     cc0:	9381                	srli	a5,a5,0x20
     cc2:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
     cc6:	fff4c583          	lbu	a1,-1(s1)
     cca:	854a                	mv	a0,s2
     ccc:	f67ff0ef          	jal	c32 <putc>
  while(--i >= 0)
     cd0:	14fd                	addi	s1,s1,-1
     cd2:	ff349ae3          	bne	s1,s3,cc6 <printint+0x76>
     cd6:	74e2                	ld	s1,56(sp)
     cd8:	79a2                	ld	s3,40(sp)
}
     cda:	60a6                	ld	ra,72(sp)
     cdc:	6406                	ld	s0,64(sp)
     cde:	7942                	ld	s2,48(sp)
     ce0:	6161                	addi	sp,sp,80
     ce2:	8082                	ret
    x = -xx;
     ce4:	40b005b3          	neg	a1,a1
    neg = 1;
     ce8:	4885                	li	a7,1
    x = -xx;
     cea:	bfad                	j	c64 <printint+0x14>

0000000000000cec <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     cec:	711d                	addi	sp,sp,-96
     cee:	ec86                	sd	ra,88(sp)
     cf0:	e8a2                	sd	s0,80(sp)
     cf2:	e0ca                	sd	s2,64(sp)
     cf4:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     cf6:	0005c903          	lbu	s2,0(a1)
     cfa:	28090663          	beqz	s2,f86 <vprintf+0x29a>
     cfe:	e4a6                	sd	s1,72(sp)
     d00:	fc4e                	sd	s3,56(sp)
     d02:	f852                	sd	s4,48(sp)
     d04:	f456                	sd	s5,40(sp)
     d06:	f05a                	sd	s6,32(sp)
     d08:	ec5e                	sd	s7,24(sp)
     d0a:	e862                	sd	s8,16(sp)
     d0c:	e466                	sd	s9,8(sp)
     d0e:	8b2a                	mv	s6,a0
     d10:	8a2e                	mv	s4,a1
     d12:	8bb2                	mv	s7,a2
  state = 0;
     d14:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
     d16:	4481                	li	s1,0
     d18:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
     d1a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
     d1e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
     d22:	06c00c93          	li	s9,108
     d26:	a005                	j	d46 <vprintf+0x5a>
        putc(fd, c0);
     d28:	85ca                	mv	a1,s2
     d2a:	855a                	mv	a0,s6
     d2c:	f07ff0ef          	jal	c32 <putc>
     d30:	a019                	j	d36 <vprintf+0x4a>
    } else if(state == '%'){
     d32:	03598263          	beq	s3,s5,d56 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
     d36:	2485                	addiw	s1,s1,1
     d38:	8726                	mv	a4,s1
     d3a:	009a07b3          	add	a5,s4,s1
     d3e:	0007c903          	lbu	s2,0(a5)
     d42:	22090a63          	beqz	s2,f76 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
     d46:	0009079b          	sext.w	a5,s2
    if(state == 0){
     d4a:	fe0994e3          	bnez	s3,d32 <vprintf+0x46>
      if(c0 == '%'){
     d4e:	fd579de3          	bne	a5,s5,d28 <vprintf+0x3c>
        state = '%';
     d52:	89be                	mv	s3,a5
     d54:	b7cd                	j	d36 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
     d56:	00ea06b3          	add	a3,s4,a4
     d5a:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
     d5e:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
     d60:	c681                	beqz	a3,d68 <vprintf+0x7c>
     d62:	9752                	add	a4,a4,s4
     d64:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
     d68:	05878363          	beq	a5,s8,dae <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
     d6c:	05978d63          	beq	a5,s9,dc6 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
     d70:	07500713          	li	a4,117
     d74:	0ee78763          	beq	a5,a4,e62 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
     d78:	07800713          	li	a4,120
     d7c:	12e78963          	beq	a5,a4,eae <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
     d80:	07000713          	li	a4,112
     d84:	14e78e63          	beq	a5,a4,ee0 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
     d88:	06300713          	li	a4,99
     d8c:	18e78e63          	beq	a5,a4,f28 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
     d90:	07300713          	li	a4,115
     d94:	1ae78463          	beq	a5,a4,f3c <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
     d98:	02500713          	li	a4,37
     d9c:	04e79563          	bne	a5,a4,de6 <vprintf+0xfa>
        putc(fd, '%');
     da0:	02500593          	li	a1,37
     da4:	855a                	mv	a0,s6
     da6:	e8dff0ef          	jal	c32 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
     daa:	4981                	li	s3,0
     dac:	b769                	j	d36 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
     dae:	008b8913          	addi	s2,s7,8
     db2:	4685                	li	a3,1
     db4:	4629                	li	a2,10
     db6:	000ba583          	lw	a1,0(s7)
     dba:	855a                	mv	a0,s6
     dbc:	e95ff0ef          	jal	c50 <printint>
     dc0:	8bca                	mv	s7,s2
      state = 0;
     dc2:	4981                	li	s3,0
     dc4:	bf8d                	j	d36 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
     dc6:	06400793          	li	a5,100
     dca:	02f68963          	beq	a3,a5,dfc <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     dce:	06c00793          	li	a5,108
     dd2:	04f68263          	beq	a3,a5,e16 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
     dd6:	07500793          	li	a5,117
     dda:	0af68063          	beq	a3,a5,e7a <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
     dde:	07800793          	li	a5,120
     de2:	0ef68263          	beq	a3,a5,ec6 <vprintf+0x1da>
        putc(fd, '%');
     de6:	02500593          	li	a1,37
     dea:	855a                	mv	a0,s6
     dec:	e47ff0ef          	jal	c32 <putc>
        putc(fd, c0);
     df0:	85ca                	mv	a1,s2
     df2:	855a                	mv	a0,s6
     df4:	e3fff0ef          	jal	c32 <putc>
      state = 0;
     df8:	4981                	li	s3,0
     dfa:	bf35                	j	d36 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     dfc:	008b8913          	addi	s2,s7,8
     e00:	4685                	li	a3,1
     e02:	4629                	li	a2,10
     e04:	000bb583          	ld	a1,0(s7)
     e08:	855a                	mv	a0,s6
     e0a:	e47ff0ef          	jal	c50 <printint>
        i += 1;
     e0e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
     e10:	8bca                	mv	s7,s2
      state = 0;
     e12:	4981                	li	s3,0
        i += 1;
     e14:	b70d                	j	d36 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     e16:	06400793          	li	a5,100
     e1a:	02f60763          	beq	a2,a5,e48 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
     e1e:	07500793          	li	a5,117
     e22:	06f60963          	beq	a2,a5,e94 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
     e26:	07800793          	li	a5,120
     e2a:	faf61ee3          	bne	a2,a5,de6 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
     e2e:	008b8913          	addi	s2,s7,8
     e32:	4681                	li	a3,0
     e34:	4641                	li	a2,16
     e36:	000bb583          	ld	a1,0(s7)
     e3a:	855a                	mv	a0,s6
     e3c:	e15ff0ef          	jal	c50 <printint>
        i += 2;
     e40:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
     e42:	8bca                	mv	s7,s2
      state = 0;
     e44:	4981                	li	s3,0
        i += 2;
     e46:	bdc5                	j	d36 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     e48:	008b8913          	addi	s2,s7,8
     e4c:	4685                	li	a3,1
     e4e:	4629                	li	a2,10
     e50:	000bb583          	ld	a1,0(s7)
     e54:	855a                	mv	a0,s6
     e56:	dfbff0ef          	jal	c50 <printint>
        i += 2;
     e5a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
     e5c:	8bca                	mv	s7,s2
      state = 0;
     e5e:	4981                	li	s3,0
        i += 2;
     e60:	bdd9                	j	d36 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
     e62:	008b8913          	addi	s2,s7,8
     e66:	4681                	li	a3,0
     e68:	4629                	li	a2,10
     e6a:	000be583          	lwu	a1,0(s7)
     e6e:	855a                	mv	a0,s6
     e70:	de1ff0ef          	jal	c50 <printint>
     e74:	8bca                	mv	s7,s2
      state = 0;
     e76:	4981                	li	s3,0
     e78:	bd7d                	j	d36 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     e7a:	008b8913          	addi	s2,s7,8
     e7e:	4681                	li	a3,0
     e80:	4629                	li	a2,10
     e82:	000bb583          	ld	a1,0(s7)
     e86:	855a                	mv	a0,s6
     e88:	dc9ff0ef          	jal	c50 <printint>
        i += 1;
     e8c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
     e8e:	8bca                	mv	s7,s2
      state = 0;
     e90:	4981                	li	s3,0
        i += 1;
     e92:	b555                	j	d36 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     e94:	008b8913          	addi	s2,s7,8
     e98:	4681                	li	a3,0
     e9a:	4629                	li	a2,10
     e9c:	000bb583          	ld	a1,0(s7)
     ea0:	855a                	mv	a0,s6
     ea2:	dafff0ef          	jal	c50 <printint>
        i += 2;
     ea6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
     ea8:	8bca                	mv	s7,s2
      state = 0;
     eaa:	4981                	li	s3,0
        i += 2;
     eac:	b569                	j	d36 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
     eae:	008b8913          	addi	s2,s7,8
     eb2:	4681                	li	a3,0
     eb4:	4641                	li	a2,16
     eb6:	000be583          	lwu	a1,0(s7)
     eba:	855a                	mv	a0,s6
     ebc:	d95ff0ef          	jal	c50 <printint>
     ec0:	8bca                	mv	s7,s2
      state = 0;
     ec2:	4981                	li	s3,0
     ec4:	bd8d                	j	d36 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
     ec6:	008b8913          	addi	s2,s7,8
     eca:	4681                	li	a3,0
     ecc:	4641                	li	a2,16
     ece:	000bb583          	ld	a1,0(s7)
     ed2:	855a                	mv	a0,s6
     ed4:	d7dff0ef          	jal	c50 <printint>
        i += 1;
     ed8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
     eda:	8bca                	mv	s7,s2
      state = 0;
     edc:	4981                	li	s3,0
        i += 1;
     ede:	bda1                	j	d36 <vprintf+0x4a>
     ee0:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
     ee2:	008b8d13          	addi	s10,s7,8
     ee6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
     eea:	03000593          	li	a1,48
     eee:	855a                	mv	a0,s6
     ef0:	d43ff0ef          	jal	c32 <putc>
  putc(fd, 'x');
     ef4:	07800593          	li	a1,120
     ef8:	855a                	mv	a0,s6
     efa:	d39ff0ef          	jal	c32 <putc>
     efe:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     f00:	00000b97          	auipc	s7,0x0
     f04:	5e0b8b93          	addi	s7,s7,1504 # 14e0 <digits>
     f08:	03c9d793          	srli	a5,s3,0x3c
     f0c:	97de                	add	a5,a5,s7
     f0e:	0007c583          	lbu	a1,0(a5)
     f12:	855a                	mv	a0,s6
     f14:	d1fff0ef          	jal	c32 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     f18:	0992                	slli	s3,s3,0x4
     f1a:	397d                	addiw	s2,s2,-1
     f1c:	fe0916e3          	bnez	s2,f08 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
     f20:	8bea                	mv	s7,s10
      state = 0;
     f22:	4981                	li	s3,0
     f24:	6d02                	ld	s10,0(sp)
     f26:	bd01                	j	d36 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
     f28:	008b8913          	addi	s2,s7,8
     f2c:	000bc583          	lbu	a1,0(s7)
     f30:	855a                	mv	a0,s6
     f32:	d01ff0ef          	jal	c32 <putc>
     f36:	8bca                	mv	s7,s2
      state = 0;
     f38:	4981                	li	s3,0
     f3a:	bbf5                	j	d36 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
     f3c:	008b8993          	addi	s3,s7,8
     f40:	000bb903          	ld	s2,0(s7)
     f44:	00090f63          	beqz	s2,f62 <vprintf+0x276>
        for(; *s; s++)
     f48:	00094583          	lbu	a1,0(s2)
     f4c:	c195                	beqz	a1,f70 <vprintf+0x284>
          putc(fd, *s);
     f4e:	855a                	mv	a0,s6
     f50:	ce3ff0ef          	jal	c32 <putc>
        for(; *s; s++)
     f54:	0905                	addi	s2,s2,1
     f56:	00094583          	lbu	a1,0(s2)
     f5a:	f9f5                	bnez	a1,f4e <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
     f5c:	8bce                	mv	s7,s3
      state = 0;
     f5e:	4981                	li	s3,0
     f60:	bbd9                	j	d36 <vprintf+0x4a>
          s = "(null)";
     f62:	00000917          	auipc	s2,0x0
     f66:	51690913          	addi	s2,s2,1302 # 1478 <malloc+0x40a>
        for(; *s; s++)
     f6a:	02800593          	li	a1,40
     f6e:	b7c5                	j	f4e <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
     f70:	8bce                	mv	s7,s3
      state = 0;
     f72:	4981                	li	s3,0
     f74:	b3c9                	j	d36 <vprintf+0x4a>
     f76:	64a6                	ld	s1,72(sp)
     f78:	79e2                	ld	s3,56(sp)
     f7a:	7a42                	ld	s4,48(sp)
     f7c:	7aa2                	ld	s5,40(sp)
     f7e:	7b02                	ld	s6,32(sp)
     f80:	6be2                	ld	s7,24(sp)
     f82:	6c42                	ld	s8,16(sp)
     f84:	6ca2                	ld	s9,8(sp)
    }
  }
}
     f86:	60e6                	ld	ra,88(sp)
     f88:	6446                	ld	s0,80(sp)
     f8a:	6906                	ld	s2,64(sp)
     f8c:	6125                	addi	sp,sp,96
     f8e:	8082                	ret

0000000000000f90 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
     f90:	715d                	addi	sp,sp,-80
     f92:	ec06                	sd	ra,24(sp)
     f94:	e822                	sd	s0,16(sp)
     f96:	1000                	addi	s0,sp,32
     f98:	e010                	sd	a2,0(s0)
     f9a:	e414                	sd	a3,8(s0)
     f9c:	e818                	sd	a4,16(s0)
     f9e:	ec1c                	sd	a5,24(s0)
     fa0:	03043023          	sd	a6,32(s0)
     fa4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
     fa8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
     fac:	8622                	mv	a2,s0
     fae:	d3fff0ef          	jal	cec <vprintf>
}
     fb2:	60e2                	ld	ra,24(sp)
     fb4:	6442                	ld	s0,16(sp)
     fb6:	6161                	addi	sp,sp,80
     fb8:	8082                	ret

0000000000000fba <printf>:

void
printf(const char *fmt, ...)
{
     fba:	711d                	addi	sp,sp,-96
     fbc:	ec06                	sd	ra,24(sp)
     fbe:	e822                	sd	s0,16(sp)
     fc0:	1000                	addi	s0,sp,32
     fc2:	e40c                	sd	a1,8(s0)
     fc4:	e810                	sd	a2,16(s0)
     fc6:	ec14                	sd	a3,24(s0)
     fc8:	f018                	sd	a4,32(s0)
     fca:	f41c                	sd	a5,40(s0)
     fcc:	03043823          	sd	a6,48(s0)
     fd0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
     fd4:	00840613          	addi	a2,s0,8
     fd8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
     fdc:	85aa                	mv	a1,a0
     fde:	4505                	li	a0,1
     fe0:	d0dff0ef          	jal	cec <vprintf>
}
     fe4:	60e2                	ld	ra,24(sp)
     fe6:	6442                	ld	s0,16(sp)
     fe8:	6125                	addi	sp,sp,96
     fea:	8082                	ret

0000000000000fec <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
     fec:	1141                	addi	sp,sp,-16
     fee:	e422                	sd	s0,8(sp)
     ff0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
     ff2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     ff6:	00001797          	auipc	a5,0x1
     ffa:	01a7b783          	ld	a5,26(a5) # 2010 <freep>
     ffe:	a02d                	j	1028 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1000:	4618                	lw	a4,8(a2)
    1002:	9f2d                	addw	a4,a4,a1
    1004:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    1008:	6398                	ld	a4,0(a5)
    100a:	6310                	ld	a2,0(a4)
    100c:	a83d                	j	104a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    100e:	ff852703          	lw	a4,-8(a0)
    1012:	9f31                	addw	a4,a4,a2
    1014:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    1016:	ff053683          	ld	a3,-16(a0)
    101a:	a091                	j	105e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    101c:	6398                	ld	a4,0(a5)
    101e:	00e7e463          	bltu	a5,a4,1026 <free+0x3a>
    1022:	00e6ea63          	bltu	a3,a4,1036 <free+0x4a>
{
    1026:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1028:	fed7fae3          	bgeu	a5,a3,101c <free+0x30>
    102c:	6398                	ld	a4,0(a5)
    102e:	00e6e463          	bltu	a3,a4,1036 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1032:	fee7eae3          	bltu	a5,a4,1026 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    1036:	ff852583          	lw	a1,-8(a0)
    103a:	6390                	ld	a2,0(a5)
    103c:	02059813          	slli	a6,a1,0x20
    1040:	01c85713          	srli	a4,a6,0x1c
    1044:	9736                	add	a4,a4,a3
    1046:	fae60de3          	beq	a2,a4,1000 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    104a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    104e:	4790                	lw	a2,8(a5)
    1050:	02061593          	slli	a1,a2,0x20
    1054:	01c5d713          	srli	a4,a1,0x1c
    1058:	973e                	add	a4,a4,a5
    105a:	fae68ae3          	beq	a3,a4,100e <free+0x22>
    p->s.ptr = bp->s.ptr;
    105e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    1060:	00001717          	auipc	a4,0x1
    1064:	faf73823          	sd	a5,-80(a4) # 2010 <freep>
}
    1068:	6422                	ld	s0,8(sp)
    106a:	0141                	addi	sp,sp,16
    106c:	8082                	ret

000000000000106e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    106e:	7139                	addi	sp,sp,-64
    1070:	fc06                	sd	ra,56(sp)
    1072:	f822                	sd	s0,48(sp)
    1074:	f426                	sd	s1,40(sp)
    1076:	ec4e                	sd	s3,24(sp)
    1078:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    107a:	02051493          	slli	s1,a0,0x20
    107e:	9081                	srli	s1,s1,0x20
    1080:	04bd                	addi	s1,s1,15
    1082:	8091                	srli	s1,s1,0x4
    1084:	0014899b          	addiw	s3,s1,1
    1088:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    108a:	00001517          	auipc	a0,0x1
    108e:	f8653503          	ld	a0,-122(a0) # 2010 <freep>
    1092:	c915                	beqz	a0,10c6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1094:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1096:	4798                	lw	a4,8(a5)
    1098:	08977a63          	bgeu	a4,s1,112c <malloc+0xbe>
    109c:	f04a                	sd	s2,32(sp)
    109e:	e852                	sd	s4,16(sp)
    10a0:	e456                	sd	s5,8(sp)
    10a2:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    10a4:	8a4e                	mv	s4,s3
    10a6:	0009871b          	sext.w	a4,s3
    10aa:	6685                	lui	a3,0x1
    10ac:	00d77363          	bgeu	a4,a3,10b2 <malloc+0x44>
    10b0:	6a05                	lui	s4,0x1
    10b2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    10b6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    10ba:	00001917          	auipc	s2,0x1
    10be:	f5690913          	addi	s2,s2,-170 # 2010 <freep>
  if(p == SBRK_ERROR)
    10c2:	5afd                	li	s5,-1
    10c4:	a081                	j	1104 <malloc+0x96>
    10c6:	f04a                	sd	s2,32(sp)
    10c8:	e852                	sd	s4,16(sp)
    10ca:	e456                	sd	s5,8(sp)
    10cc:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    10ce:	00001797          	auipc	a5,0x1
    10d2:	33a78793          	addi	a5,a5,826 # 2408 <base>
    10d6:	00001717          	auipc	a4,0x1
    10da:	f2f73d23          	sd	a5,-198(a4) # 2010 <freep>
    10de:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    10e0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    10e4:	b7c1                	j	10a4 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
    10e6:	6398                	ld	a4,0(a5)
    10e8:	e118                	sd	a4,0(a0)
    10ea:	a8a9                	j	1144 <malloc+0xd6>
  hp->s.size = nu;
    10ec:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    10f0:	0541                	addi	a0,a0,16
    10f2:	efbff0ef          	jal	fec <free>
  return freep;
    10f6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    10fa:	c12d                	beqz	a0,115c <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    10fc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    10fe:	4798                	lw	a4,8(a5)
    1100:	02977263          	bgeu	a4,s1,1124 <malloc+0xb6>
    if(p == freep)
    1104:	00093703          	ld	a4,0(s2)
    1108:	853e                	mv	a0,a5
    110a:	fef719e3          	bne	a4,a5,10fc <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
    110e:	8552                	mv	a0,s4
    1110:	a2fff0ef          	jal	b3e <sbrk>
  if(p == SBRK_ERROR)
    1114:	fd551ce3          	bne	a0,s5,10ec <malloc+0x7e>
        return 0;
    1118:	4501                	li	a0,0
    111a:	7902                	ld	s2,32(sp)
    111c:	6a42                	ld	s4,16(sp)
    111e:	6aa2                	ld	s5,8(sp)
    1120:	6b02                	ld	s6,0(sp)
    1122:	a03d                	j	1150 <malloc+0xe2>
    1124:	7902                	ld	s2,32(sp)
    1126:	6a42                	ld	s4,16(sp)
    1128:	6aa2                	ld	s5,8(sp)
    112a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    112c:	fae48de3          	beq	s1,a4,10e6 <malloc+0x78>
        p->s.size -= nunits;
    1130:	4137073b          	subw	a4,a4,s3
    1134:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1136:	02071693          	slli	a3,a4,0x20
    113a:	01c6d713          	srli	a4,a3,0x1c
    113e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1140:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1144:	00001717          	auipc	a4,0x1
    1148:	eca73623          	sd	a0,-308(a4) # 2010 <freep>
      return (void*)(p + 1);
    114c:	01078513          	addi	a0,a5,16
  }
}
    1150:	70e2                	ld	ra,56(sp)
    1152:	7442                	ld	s0,48(sp)
    1154:	74a2                	ld	s1,40(sp)
    1156:	69e2                	ld	s3,24(sp)
    1158:	6121                	addi	sp,sp,64
    115a:	8082                	ret
    115c:	7902                	ld	s2,32(sp)
    115e:	6a42                	ld	s4,16(sp)
    1160:	6aa2                	ld	s5,8(sp)
    1162:	6b02                	ld	s6,0(sp)
    1164:	b7f5                	j	1150 <malloc+0xe2>
