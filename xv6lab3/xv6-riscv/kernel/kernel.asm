
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	48813103          	ld	sp,1160(sp) # 8000a488 <_GLOBAL_OFFSET_TABLE_+0x8>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdae27>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	dbc78793          	addi	a5,a5,-580 # 80000e3c <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a2:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	7119                	addi	sp,sp,-128
    800000d2:	fc86                	sd	ra,120(sp)
    800000d4:	f8a2                	sd	s0,112(sp)
    800000d6:	f4a6                	sd	s1,104(sp)
    800000d8:	0100                	addi	s0,sp,128
  char buf[32];
  int i = 0;

  while(i < n){
    800000da:	06c05a63          	blez	a2,8000014e <consolewrite+0x7e>
    800000de:	f0ca                	sd	s2,96(sp)
    800000e0:	ecce                	sd	s3,88(sp)
    800000e2:	e8d2                	sd	s4,80(sp)
    800000e4:	e4d6                	sd	s5,72(sp)
    800000e6:	e0da                	sd	s6,64(sp)
    800000e8:	fc5e                	sd	s7,56(sp)
    800000ea:	f862                	sd	s8,48(sp)
    800000ec:	f466                	sd	s9,40(sp)
    800000ee:	8aaa                	mv	s5,a0
    800000f0:	8b2e                	mv	s6,a1
    800000f2:	8a32                	mv	s4,a2
  int i = 0;
    800000f4:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000f6:	02000c13          	li	s8,32
    800000fa:	02000c93          	li	s9,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    800000fe:	5bfd                	li	s7,-1
    80000100:	a035                	j	8000012c <consolewrite+0x5c>
    if(nn > n - i)
    80000102:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000106:	86ce                	mv	a3,s3
    80000108:	01648633          	add	a2,s1,s6
    8000010c:	85d6                	mv	a1,s5
    8000010e:	f8040513          	addi	a0,s0,-128
    80000112:	168020ef          	jal	8000227a <either_copyin>
    80000116:	03750e63          	beq	a0,s7,80000152 <consolewrite+0x82>
      break;
    uartwrite(buf, nn);
    8000011a:	85ce                	mv	a1,s3
    8000011c:	f8040513          	addi	a0,s0,-128
    80000120:	778000ef          	jal	80000898 <uartwrite>
    i += nn;
    80000124:	009904bb          	addw	s1,s2,s1
  while(i < n){
    80000128:	0144da63          	bge	s1,s4,8000013c <consolewrite+0x6c>
    if(nn > n - i)
    8000012c:	409a093b          	subw	s2,s4,s1
    80000130:	0009079b          	sext.w	a5,s2
    80000134:	fcfc57e3          	bge	s8,a5,80000102 <consolewrite+0x32>
    80000138:	8966                	mv	s2,s9
    8000013a:	b7e1                	j	80000102 <consolewrite+0x32>
    8000013c:	7906                	ld	s2,96(sp)
    8000013e:	69e6                	ld	s3,88(sp)
    80000140:	6a46                	ld	s4,80(sp)
    80000142:	6aa6                	ld	s5,72(sp)
    80000144:	6b06                	ld	s6,64(sp)
    80000146:	7be2                	ld	s7,56(sp)
    80000148:	7c42                	ld	s8,48(sp)
    8000014a:	7ca2                	ld	s9,40(sp)
    8000014c:	a819                	j	80000162 <consolewrite+0x92>
  int i = 0;
    8000014e:	4481                	li	s1,0
    80000150:	a809                	j	80000162 <consolewrite+0x92>
    80000152:	7906                	ld	s2,96(sp)
    80000154:	69e6                	ld	s3,88(sp)
    80000156:	6a46                	ld	s4,80(sp)
    80000158:	6aa6                	ld	s5,72(sp)
    8000015a:	6b06                	ld	s6,64(sp)
    8000015c:	7be2                	ld	s7,56(sp)
    8000015e:	7c42                	ld	s8,48(sp)
    80000160:	7ca2                	ld	s9,40(sp)
  }

  return i;
}
    80000162:	8526                	mv	a0,s1
    80000164:	70e6                	ld	ra,120(sp)
    80000166:	7446                	ld	s0,112(sp)
    80000168:	74a6                	ld	s1,104(sp)
    8000016a:	6109                	addi	sp,sp,128
    8000016c:	8082                	ret

000000008000016e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	711d                	addi	sp,sp,-96
    80000170:	ec86                	sd	ra,88(sp)
    80000172:	e8a2                	sd	s0,80(sp)
    80000174:	e4a6                	sd	s1,72(sp)
    80000176:	e0ca                	sd	s2,64(sp)
    80000178:	fc4e                	sd	s3,56(sp)
    8000017a:	f852                	sd	s4,48(sp)
    8000017c:	f456                	sd	s5,40(sp)
    8000017e:	f05a                	sd	s6,32(sp)
    80000180:	1080                	addi	s0,sp,96
    80000182:	8aaa                	mv	s5,a0
    80000184:	8a2e                	mv	s4,a1
    80000186:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018c:	00012517          	auipc	a0,0x12
    80000190:	34450513          	addi	a0,a0,836 # 800124d0 <cons>
    80000194:	23b000ef          	jal	80000bce <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000198:	00012497          	auipc	s1,0x12
    8000019c:	33848493          	addi	s1,s1,824 # 800124d0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a0:	00012917          	auipc	s2,0x12
    800001a4:	3c890913          	addi	s2,s2,968 # 80012568 <cons+0x98>
  while(n > 0){
    800001a8:	0b305d63          	blez	s3,80000262 <consoleread+0xf4>
    while(cons.r == cons.w){
    800001ac:	0984a783          	lw	a5,152(s1)
    800001b0:	09c4a703          	lw	a4,156(s1)
    800001b4:	0af71263          	bne	a4,a5,80000258 <consoleread+0xea>
      if(killed(myproc())){
    800001b8:	716010ef          	jal	800018ce <myproc>
    800001bc:	751010ef          	jal	8000210c <killed>
    800001c0:	e12d                	bnez	a0,80000222 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    800001c2:	85a6                	mv	a1,s1
    800001c4:	854a                	mv	a0,s2
    800001c6:	50f010ef          	jal	80001ed4 <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef703e3          	beq	a4,a5,800001b8 <consoleread+0x4a>
    800001d6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001d8:	00012717          	auipc	a4,0x12
    800001dc:	2f870713          	addi	a4,a4,760 # 800124d0 <cons>
    800001e0:	0017869b          	addiw	a3,a5,1
    800001e4:	08d72c23          	sw	a3,152(a4)
    800001e8:	07f7f693          	andi	a3,a5,127
    800001ec:	9736                	add	a4,a4,a3
    800001ee:	01874703          	lbu	a4,24(a4)
    800001f2:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001f6:	4691                	li	a3,4
    800001f8:	04db8663          	beq	s7,a3,80000244 <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001fc:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000200:	4685                	li	a3,1
    80000202:	faf40613          	addi	a2,s0,-81
    80000206:	85d2                	mv	a1,s4
    80000208:	8556                	mv	a0,s5
    8000020a:	026020ef          	jal	80002230 <either_copyout>
    8000020e:	57fd                	li	a5,-1
    80000210:	04f50863          	beq	a0,a5,80000260 <consoleread+0xf2>
      break;

    dst++;
    80000214:	0a05                	addi	s4,s4,1
    --n;
    80000216:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80000218:	47a9                	li	a5,10
    8000021a:	04fb8d63          	beq	s7,a5,80000274 <consoleread+0x106>
    8000021e:	6be2                	ld	s7,24(sp)
    80000220:	b761                	j	800001a8 <consoleread+0x3a>
        release(&cons.lock);
    80000222:	00012517          	auipc	a0,0x12
    80000226:	2ae50513          	addi	a0,a0,686 # 800124d0 <cons>
    8000022a:	23d000ef          	jal	80000c66 <release>
        return -1;
    8000022e:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000230:	60e6                	ld	ra,88(sp)
    80000232:	6446                	ld	s0,80(sp)
    80000234:	64a6                	ld	s1,72(sp)
    80000236:	6906                	ld	s2,64(sp)
    80000238:	79e2                	ld	s3,56(sp)
    8000023a:	7a42                	ld	s4,48(sp)
    8000023c:	7aa2                	ld	s5,40(sp)
    8000023e:	7b02                	ld	s6,32(sp)
    80000240:	6125                	addi	sp,sp,96
    80000242:	8082                	ret
      if(n < target){
    80000244:	0009871b          	sext.w	a4,s3
    80000248:	01677a63          	bgeu	a4,s6,8000025c <consoleread+0xee>
        cons.r--;
    8000024c:	00012717          	auipc	a4,0x12
    80000250:	30f72e23          	sw	a5,796(a4) # 80012568 <cons+0x98>
    80000254:	6be2                	ld	s7,24(sp)
    80000256:	a031                	j	80000262 <consoleread+0xf4>
    80000258:	ec5e                	sd	s7,24(sp)
    8000025a:	bfbd                	j	800001d8 <consoleread+0x6a>
    8000025c:	6be2                	ld	s7,24(sp)
    8000025e:	a011                	j	80000262 <consoleread+0xf4>
    80000260:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000262:	00012517          	auipc	a0,0x12
    80000266:	26e50513          	addi	a0,a0,622 # 800124d0 <cons>
    8000026a:	1fd000ef          	jal	80000c66 <release>
  return target - n;
    8000026e:	413b053b          	subw	a0,s6,s3
    80000272:	bf7d                	j	80000230 <consoleread+0xc2>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	b7f5                	j	80000262 <consoleread+0xf4>

0000000080000278 <consputc>:
{
    80000278:	1141                	addi	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50863          	beq	a0,a5,80000294 <consputc+0x1c>
    uartputc_sync(c);
    80000288:	6a4000ef          	jal	8000092c <uartputc_sync>
}
    8000028c:	60a2                	ld	ra,8(sp)
    8000028e:	6402                	ld	s0,0(sp)
    80000290:	0141                	addi	sp,sp,16
    80000292:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000294:	4521                	li	a0,8
    80000296:	696000ef          	jal	8000092c <uartputc_sync>
    8000029a:	02000513          	li	a0,32
    8000029e:	68e000ef          	jal	8000092c <uartputc_sync>
    800002a2:	4521                	li	a0,8
    800002a4:	688000ef          	jal	8000092c <uartputc_sync>
    800002a8:	b7d5                	j	8000028c <consputc+0x14>

00000000800002aa <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002aa:	1101                	addi	sp,sp,-32
    800002ac:	ec06                	sd	ra,24(sp)
    800002ae:	e822                	sd	s0,16(sp)
    800002b0:	e426                	sd	s1,8(sp)
    800002b2:	1000                	addi	s0,sp,32
    800002b4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b6:	00012517          	auipc	a0,0x12
    800002ba:	21a50513          	addi	a0,a0,538 # 800124d0 <cons>
    800002be:	111000ef          	jal	80000bce <acquire>

  switch(c){
    800002c2:	47d5                	li	a5,21
    800002c4:	08f48f63          	beq	s1,a5,80000362 <consoleintr+0xb8>
    800002c8:	0297c563          	blt	a5,s1,800002f2 <consoleintr+0x48>
    800002cc:	47a1                	li	a5,8
    800002ce:	0ef48463          	beq	s1,a5,800003b6 <consoleintr+0x10c>
    800002d2:	47c1                	li	a5,16
    800002d4:	10f49563          	bne	s1,a5,800003de <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002d8:	7ed010ef          	jal	800022c4 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002dc:	00012517          	auipc	a0,0x12
    800002e0:	1f450513          	addi	a0,a0,500 # 800124d0 <cons>
    800002e4:	183000ef          	jal	80000c66 <release>
}
    800002e8:	60e2                	ld	ra,24(sp)
    800002ea:	6442                	ld	s0,16(sp)
    800002ec:	64a2                	ld	s1,8(sp)
    800002ee:	6105                	addi	sp,sp,32
    800002f0:	8082                	ret
  switch(c){
    800002f2:	07f00793          	li	a5,127
    800002f6:	0cf48063          	beq	s1,a5,800003b6 <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002fa:	00012717          	auipc	a4,0x12
    800002fe:	1d670713          	addi	a4,a4,470 # 800124d0 <cons>
    80000302:	0a072783          	lw	a5,160(a4)
    80000306:	09872703          	lw	a4,152(a4)
    8000030a:	9f99                	subw	a5,a5,a4
    8000030c:	07f00713          	li	a4,127
    80000310:	fcf766e3          	bltu	a4,a5,800002dc <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000314:	47b5                	li	a5,13
    80000316:	0cf48763          	beq	s1,a5,800003e4 <consoleintr+0x13a>
      consputc(c);
    8000031a:	8526                	mv	a0,s1
    8000031c:	f5dff0ef          	jal	80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000320:	00012797          	auipc	a5,0x12
    80000324:	1b078793          	addi	a5,a5,432 # 800124d0 <cons>
    80000328:	0a07a683          	lw	a3,160(a5)
    8000032c:	0016871b          	addiw	a4,a3,1
    80000330:	0007061b          	sext.w	a2,a4
    80000334:	0ae7a023          	sw	a4,160(a5)
    80000338:	07f6f693          	andi	a3,a3,127
    8000033c:	97b6                	add	a5,a5,a3
    8000033e:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000342:	47a9                	li	a5,10
    80000344:	0cf48563          	beq	s1,a5,8000040e <consoleintr+0x164>
    80000348:	4791                	li	a5,4
    8000034a:	0cf48263          	beq	s1,a5,8000040e <consoleintr+0x164>
    8000034e:	00012797          	auipc	a5,0x12
    80000352:	21a7a783          	lw	a5,538(a5) # 80012568 <cons+0x98>
    80000356:	9f1d                	subw	a4,a4,a5
    80000358:	08000793          	li	a5,128
    8000035c:	f8f710e3          	bne	a4,a5,800002dc <consoleintr+0x32>
    80000360:	a07d                	j	8000040e <consoleintr+0x164>
    80000362:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000364:	00012717          	auipc	a4,0x12
    80000368:	16c70713          	addi	a4,a4,364 # 800124d0 <cons>
    8000036c:	0a072783          	lw	a5,160(a4)
    80000370:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000374:	00012497          	auipc	s1,0x12
    80000378:	15c48493          	addi	s1,s1,348 # 800124d0 <cons>
    while(cons.e != cons.w &&
    8000037c:	4929                	li	s2,10
    8000037e:	02f70863          	beq	a4,a5,800003ae <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000382:	37fd                	addiw	a5,a5,-1
    80000384:	07f7f713          	andi	a4,a5,127
    80000388:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000038a:	01874703          	lbu	a4,24(a4)
    8000038e:	03270263          	beq	a4,s2,800003b2 <consoleintr+0x108>
      cons.e--;
    80000392:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000396:	10000513          	li	a0,256
    8000039a:	edfff0ef          	jal	80000278 <consputc>
    while(cons.e != cons.w &&
    8000039e:	0a04a783          	lw	a5,160(s1)
    800003a2:	09c4a703          	lw	a4,156(s1)
    800003a6:	fcf71ee3          	bne	a4,a5,80000382 <consoleintr+0xd8>
    800003aa:	6902                	ld	s2,0(sp)
    800003ac:	bf05                	j	800002dc <consoleintr+0x32>
    800003ae:	6902                	ld	s2,0(sp)
    800003b0:	b735                	j	800002dc <consoleintr+0x32>
    800003b2:	6902                	ld	s2,0(sp)
    800003b4:	b725                	j	800002dc <consoleintr+0x32>
    if(cons.e != cons.w){
    800003b6:	00012717          	auipc	a4,0x12
    800003ba:	11a70713          	addi	a4,a4,282 # 800124d0 <cons>
    800003be:	0a072783          	lw	a5,160(a4)
    800003c2:	09c72703          	lw	a4,156(a4)
    800003c6:	f0f70be3          	beq	a4,a5,800002dc <consoleintr+0x32>
      cons.e--;
    800003ca:	37fd                	addiw	a5,a5,-1
    800003cc:	00012717          	auipc	a4,0x12
    800003d0:	1af72223          	sw	a5,420(a4) # 80012570 <cons+0xa0>
      consputc(BACKSPACE);
    800003d4:	10000513          	li	a0,256
    800003d8:	ea1ff0ef          	jal	80000278 <consputc>
    800003dc:	b701                	j	800002dc <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003de:	ee048fe3          	beqz	s1,800002dc <consoleintr+0x32>
    800003e2:	bf21                	j	800002fa <consoleintr+0x50>
      consputc(c);
    800003e4:	4529                	li	a0,10
    800003e6:	e93ff0ef          	jal	80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003ea:	00012797          	auipc	a5,0x12
    800003ee:	0e678793          	addi	a5,a5,230 # 800124d0 <cons>
    800003f2:	0a07a703          	lw	a4,160(a5)
    800003f6:	0017069b          	addiw	a3,a4,1
    800003fa:	0006861b          	sext.w	a2,a3
    800003fe:	0ad7a023          	sw	a3,160(a5)
    80000402:	07f77713          	andi	a4,a4,127
    80000406:	97ba                	add	a5,a5,a4
    80000408:	4729                	li	a4,10
    8000040a:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040e:	00012797          	auipc	a5,0x12
    80000412:	14c7af23          	sw	a2,350(a5) # 8001256c <cons+0x9c>
        wakeup(&cons.r);
    80000416:	00012517          	auipc	a0,0x12
    8000041a:	15250513          	addi	a0,a0,338 # 80012568 <cons+0x98>
    8000041e:	303010ef          	jal	80001f20 <wakeup>
    80000422:	bd6d                	j	800002dc <consoleintr+0x32>

0000000080000424 <consoleinit>:

void
consoleinit(void)
{
    80000424:	1141                	addi	sp,sp,-16
    80000426:	e406                	sd	ra,8(sp)
    80000428:	e022                	sd	s0,0(sp)
    8000042a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000042c:	00007597          	auipc	a1,0x7
    80000430:	bd458593          	addi	a1,a1,-1068 # 80007000 <etext>
    80000434:	00012517          	auipc	a0,0x12
    80000438:	09c50513          	addi	a0,a0,156 # 800124d0 <cons>
    8000043c:	712000ef          	jal	80000b4e <initlock>

  uartinit();
    80000440:	400000ef          	jal	80000840 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000444:	00022797          	auipc	a5,0x22
    80000448:	3fc78793          	addi	a5,a5,1020 # 80022840 <devsw>
    8000044c:	00000717          	auipc	a4,0x0
    80000450:	d2270713          	addi	a4,a4,-734 # 8000016e <consoleread>
    80000454:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000456:	00000717          	auipc	a4,0x0
    8000045a:	c7a70713          	addi	a4,a4,-902 # 800000d0 <consolewrite>
    8000045e:	ef98                	sd	a4,24(a5)
}
    80000460:	60a2                	ld	ra,8(sp)
    80000462:	6402                	ld	s0,0(sp)
    80000464:	0141                	addi	sp,sp,16
    80000466:	8082                	ret

0000000080000468 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000468:	7139                	addi	sp,sp,-64
    8000046a:	fc06                	sd	ra,56(sp)
    8000046c:	f822                	sd	s0,48(sp)
    8000046e:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000470:	c219                	beqz	a2,80000476 <printint+0xe>
    80000472:	08054063          	bltz	a0,800004f2 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80000476:	4881                	li	a7,0
    80000478:	fc840693          	addi	a3,s0,-56

  i = 0;
    8000047c:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000047e:	00007617          	auipc	a2,0x7
    80000482:	3e260613          	addi	a2,a2,994 # 80007860 <digits>
    80000486:	883e                	mv	a6,a5
    80000488:	2785                	addiw	a5,a5,1
    8000048a:	02b57733          	remu	a4,a0,a1
    8000048e:	9732                	add	a4,a4,a2
    80000490:	00074703          	lbu	a4,0(a4)
    80000494:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000498:	872a                	mv	a4,a0
    8000049a:	02b55533          	divu	a0,a0,a1
    8000049e:	0685                	addi	a3,a3,1
    800004a0:	feb773e3          	bgeu	a4,a1,80000486 <printint+0x1e>

  if(sign)
    800004a4:	00088a63          	beqz	a7,800004b8 <printint+0x50>
    buf[i++] = '-';
    800004a8:	1781                	addi	a5,a5,-32
    800004aa:	97a2                	add	a5,a5,s0
    800004ac:	02d00713          	li	a4,45
    800004b0:	fee78423          	sb	a4,-24(a5)
    800004b4:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    800004b8:	02f05963          	blez	a5,800004ea <printint+0x82>
    800004bc:	f426                	sd	s1,40(sp)
    800004be:	f04a                	sd	s2,32(sp)
    800004c0:	fc840713          	addi	a4,s0,-56
    800004c4:	00f704b3          	add	s1,a4,a5
    800004c8:	fff70913          	addi	s2,a4,-1
    800004cc:	993e                	add	s2,s2,a5
    800004ce:	37fd                	addiw	a5,a5,-1
    800004d0:	1782                	slli	a5,a5,0x20
    800004d2:	9381                	srli	a5,a5,0x20
    800004d4:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004d8:	fff4c503          	lbu	a0,-1(s1)
    800004dc:	d9dff0ef          	jal	80000278 <consputc>
  while(--i >= 0)
    800004e0:	14fd                	addi	s1,s1,-1
    800004e2:	ff249be3          	bne	s1,s2,800004d8 <printint+0x70>
    800004e6:	74a2                	ld	s1,40(sp)
    800004e8:	7902                	ld	s2,32(sp)
}
    800004ea:	70e2                	ld	ra,56(sp)
    800004ec:	7442                	ld	s0,48(sp)
    800004ee:	6121                	addi	sp,sp,64
    800004f0:	8082                	ret
    x = -xx;
    800004f2:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004f6:	4885                	li	a7,1
    x = -xx;
    800004f8:	b741                	j	80000478 <printint+0x10>

00000000800004fa <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004fa:	7131                	addi	sp,sp,-192
    800004fc:	fc86                	sd	ra,120(sp)
    800004fe:	f8a2                	sd	s0,112(sp)
    80000500:	e8d2                	sd	s4,80(sp)
    80000502:	0100                	addi	s0,sp,128
    80000504:	8a2a                	mv	s4,a0
    80000506:	e40c                	sd	a1,8(s0)
    80000508:	e810                	sd	a2,16(s0)
    8000050a:	ec14                	sd	a3,24(s0)
    8000050c:	f018                	sd	a4,32(s0)
    8000050e:	f41c                	sd	a5,40(s0)
    80000510:	03043823          	sd	a6,48(s0)
    80000514:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    80000518:	0000a797          	auipc	a5,0xa
    8000051c:	f8c7a783          	lw	a5,-116(a5) # 8000a4a4 <panicking>
    80000520:	c3a1                	beqz	a5,80000560 <printf+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	000a4503          	lbu	a0,0(s4)
    8000052e:	28050763          	beqz	a0,800007bc <printf+0x2c2>
    80000532:	f4a6                	sd	s1,104(sp)
    80000534:	f0ca                	sd	s2,96(sp)
    80000536:	ecce                	sd	s3,88(sp)
    80000538:	e4d6                	sd	s5,72(sp)
    8000053a:	e0da                	sd	s6,64(sp)
    8000053c:	f862                	sd	s8,48(sp)
    8000053e:	f466                	sd	s9,40(sp)
    80000540:	f06a                	sd	s10,32(sp)
    80000542:	ec6e                	sd	s11,24(sp)
    80000544:	4981                	li	s3,0
    if(cx != '%'){
    80000546:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    8000054a:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000054e:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80000552:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000556:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    8000055a:	07000d93          	li	s11,112
    8000055e:	a01d                	j	80000584 <printf+0x8a>
    acquire(&pr.lock);
    80000560:	00012517          	auipc	a0,0x12
    80000564:	01850513          	addi	a0,a0,24 # 80012578 <pr>
    80000568:	666000ef          	jal	80000bce <acquire>
    8000056c:	bf5d                	j	80000522 <printf+0x28>
      consputc(cx);
    8000056e:	d0bff0ef          	jal	80000278 <consputc>
      continue;
    80000572:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000574:	0014899b          	addiw	s3,s1,1
    80000578:	013a07b3          	add	a5,s4,s3
    8000057c:	0007c503          	lbu	a0,0(a5)
    80000580:	20050b63          	beqz	a0,80000796 <printf+0x29c>
    if(cx != '%'){
    80000584:	ff5515e3          	bne	a0,s5,8000056e <printf+0x74>
    i++;
    80000588:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    8000058c:	009a07b3          	add	a5,s4,s1
    80000590:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000594:	20090b63          	beqz	s2,800007aa <printf+0x2b0>
    80000598:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    8000059c:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    8000059e:	c789                	beqz	a5,800005a8 <printf+0xae>
    800005a0:	009a0733          	add	a4,s4,s1
    800005a4:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    800005a8:	03690963          	beq	s2,s6,800005da <printf+0xe0>
    } else if(c0 == 'l' && c1 == 'd'){
    800005ac:	05890363          	beq	s2,s8,800005f2 <printf+0xf8>
    } else if(c0 == 'u'){
    800005b0:	0d990663          	beq	s2,s9,8000067c <printf+0x182>
    } else if(c0 == 'x'){
    800005b4:	11a90d63          	beq	s2,s10,800006ce <printf+0x1d4>
    } else if(c0 == 'p'){
    800005b8:	15b90663          	beq	s2,s11,80000704 <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    800005bc:	06300793          	li	a5,99
    800005c0:	18f90563          	beq	s2,a5,8000074a <printf+0x250>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    800005c4:	07300793          	li	a5,115
    800005c8:	18f90b63          	beq	s2,a5,8000075e <printf+0x264>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800005cc:	03591b63          	bne	s2,s5,80000602 <printf+0x108>
      consputc('%');
    800005d0:	02500513          	li	a0,37
    800005d4:	ca5ff0ef          	jal	80000278 <consputc>
    800005d8:	bf71                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, int), 10, 1);
    800005da:	f8843783          	ld	a5,-120(s0)
    800005de:	00878713          	addi	a4,a5,8
    800005e2:	f8e43423          	sd	a4,-120(s0)
    800005e6:	4605                	li	a2,1
    800005e8:	45a9                	li	a1,10
    800005ea:	4388                	lw	a0,0(a5)
    800005ec:	e7dff0ef          	jal	80000468 <printint>
    800005f0:	b751                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'd'){
    800005f2:	01678f63          	beq	a5,s6,80000610 <printf+0x116>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005f6:	03878b63          	beq	a5,s8,8000062c <printf+0x132>
    } else if(c0 == 'l' && c1 == 'u'){
    800005fa:	09978e63          	beq	a5,s9,80000696 <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'x'){
    800005fe:	0fa78563          	beq	a5,s10,800006e8 <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80000602:	8556                	mv	a0,s5
    80000604:	c75ff0ef          	jal	80000278 <consputc>
      consputc(c0);
    80000608:	854a                	mv	a0,s2
    8000060a:	c6fff0ef          	jal	80000278 <consputc>
    8000060e:	b79d                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000610:	f8843783          	ld	a5,-120(s0)
    80000614:	00878713          	addi	a4,a5,8
    80000618:	f8e43423          	sd	a4,-120(s0)
    8000061c:	4605                	li	a2,1
    8000061e:	45a9                	li	a1,10
    80000620:	6388                	ld	a0,0(a5)
    80000622:	e47ff0ef          	jal	80000468 <printint>
      i += 1;
    80000626:	0029849b          	addiw	s1,s3,2
    8000062a:	b7a9                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000062c:	06400793          	li	a5,100
    80000630:	02f68863          	beq	a3,a5,80000660 <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000634:	07500793          	li	a5,117
    80000638:	06f68d63          	beq	a3,a5,800006b2 <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000063c:	07800793          	li	a5,120
    80000640:	fcf691e3          	bne	a3,a5,80000602 <printf+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4601                	li	a2,0
    80000652:	45c1                	li	a1,16
    80000654:	6388                	ld	a0,0(a5)
    80000656:	e13ff0ef          	jal	80000468 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bf19                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4605                	li	a2,1
    8000066e:	45a9                	li	a1,10
    80000670:	6388                	ld	a0,0(a5)
    80000672:	df7ff0ef          	jal	80000468 <printint>
      i += 2;
    80000676:	0039849b          	addiw	s1,s3,3
    8000067a:	bded                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4601                	li	a2,0
    8000068a:	45a9                	li	a1,10
    8000068c:	0007e503          	lwu	a0,0(a5)
    80000690:	dd9ff0ef          	jal	80000468 <printint>
    80000694:	b5c5                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	4601                	li	a2,0
    800006a4:	45a9                	li	a1,10
    800006a6:	6388                	ld	a0,0(a5)
    800006a8:	dc1ff0ef          	jal	80000468 <printint>
      i += 1;
    800006ac:	0029849b          	addiw	s1,s3,2
    800006b0:	b5d1                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4601                	li	a2,0
    800006c0:	45a9                	li	a1,10
    800006c2:	6388                	ld	a0,0(a5)
    800006c4:	da5ff0ef          	jal	80000468 <printint>
      i += 2;
    800006c8:	0039849b          	addiw	s1,s3,3
    800006cc:	b565                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	addi	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	4601                	li	a2,0
    800006dc:	45c1                	li	a1,16
    800006de:	0007e503          	lwu	a0,0(a5)
    800006e2:	d87ff0ef          	jal	80000468 <printint>
    800006e6:	b579                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    800006e8:	f8843783          	ld	a5,-120(s0)
    800006ec:	00878713          	addi	a4,a5,8
    800006f0:	f8e43423          	sd	a4,-120(s0)
    800006f4:	4601                	li	a2,0
    800006f6:	45c1                	li	a1,16
    800006f8:	6388                	ld	a0,0(a5)
    800006fa:	d6fff0ef          	jal	80000468 <printint>
      i += 1;
    800006fe:	0029849b          	addiw	s1,s3,2
    80000702:	bd8d                	j	80000574 <printf+0x7a>
    80000704:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    80000706:	f8843783          	ld	a5,-120(s0)
    8000070a:	00878713          	addi	a4,a5,8
    8000070e:	f8e43423          	sd	a4,-120(s0)
    80000712:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000716:	03000513          	li	a0,48
    8000071a:	b5fff0ef          	jal	80000278 <consputc>
  consputc('x');
    8000071e:	07800513          	li	a0,120
    80000722:	b57ff0ef          	jal	80000278 <consputc>
    80000726:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000728:	00007b97          	auipc	s7,0x7
    8000072c:	138b8b93          	addi	s7,s7,312 # 80007860 <digits>
    80000730:	03c9d793          	srli	a5,s3,0x3c
    80000734:	97de                	add	a5,a5,s7
    80000736:	0007c503          	lbu	a0,0(a5)
    8000073a:	b3fff0ef          	jal	80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000073e:	0992                	slli	s3,s3,0x4
    80000740:	397d                	addiw	s2,s2,-1
    80000742:	fe0917e3          	bnez	s2,80000730 <printf+0x236>
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	b535                	j	80000574 <printf+0x7a>
      consputc(va_arg(ap, uint));
    8000074a:	f8843783          	ld	a5,-120(s0)
    8000074e:	00878713          	addi	a4,a5,8
    80000752:	f8e43423          	sd	a4,-120(s0)
    80000756:	4388                	lw	a0,0(a5)
    80000758:	b21ff0ef          	jal	80000278 <consputc>
    8000075c:	bd21                	j	80000574 <printf+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    8000075e:	f8843783          	ld	a5,-120(s0)
    80000762:	00878713          	addi	a4,a5,8
    80000766:	f8e43423          	sd	a4,-120(s0)
    8000076a:	0007b903          	ld	s2,0(a5)
    8000076e:	00090d63          	beqz	s2,80000788 <printf+0x28e>
      for(; *s; s++)
    80000772:	00094503          	lbu	a0,0(s2)
    80000776:	de050fe3          	beqz	a0,80000574 <printf+0x7a>
        consputc(*s);
    8000077a:	affff0ef          	jal	80000278 <consputc>
      for(; *s; s++)
    8000077e:	0905                	addi	s2,s2,1
    80000780:	00094503          	lbu	a0,0(s2)
    80000784:	f97d                	bnez	a0,8000077a <printf+0x280>
    80000786:	b3fd                	j	80000574 <printf+0x7a>
        s = "(null)";
    80000788:	00007917          	auipc	s2,0x7
    8000078c:	88090913          	addi	s2,s2,-1920 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000790:	02800513          	li	a0,40
    80000794:	b7dd                	j	8000077a <printf+0x280>
    80000796:	74a6                	ld	s1,104(sp)
    80000798:	7906                	ld	s2,96(sp)
    8000079a:	69e6                	ld	s3,88(sp)
    8000079c:	6aa6                	ld	s5,72(sp)
    8000079e:	6b06                	ld	s6,64(sp)
    800007a0:	7c42                	ld	s8,48(sp)
    800007a2:	7ca2                	ld	s9,40(sp)
    800007a4:	7d02                	ld	s10,32(sp)
    800007a6:	6de2                	ld	s11,24(sp)
    800007a8:	a811                	j	800007bc <printf+0x2c2>
    800007aa:	74a6                	ld	s1,104(sp)
    800007ac:	7906                	ld	s2,96(sp)
    800007ae:	69e6                	ld	s3,88(sp)
    800007b0:	6aa6                	ld	s5,72(sp)
    800007b2:	6b06                	ld	s6,64(sp)
    800007b4:	7c42                	ld	s8,48(sp)
    800007b6:	7ca2                	ld	s9,40(sp)
    800007b8:	7d02                	ld	s10,32(sp)
    800007ba:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    800007bc:	0000a797          	auipc	a5,0xa
    800007c0:	ce87a783          	lw	a5,-792(a5) # 8000a4a4 <panicking>
    800007c4:	c799                	beqz	a5,800007d2 <printf+0x2d8>
    release(&pr.lock);

  return 0;
}
    800007c6:	4501                	li	a0,0
    800007c8:	70e6                	ld	ra,120(sp)
    800007ca:	7446                	ld	s0,112(sp)
    800007cc:	6a46                	ld	s4,80(sp)
    800007ce:	6129                	addi	sp,sp,192
    800007d0:	8082                	ret
    release(&pr.lock);
    800007d2:	00012517          	auipc	a0,0x12
    800007d6:	da650513          	addi	a0,a0,-602 # 80012578 <pr>
    800007da:	48c000ef          	jal	80000c66 <release>
  return 0;
    800007de:	b7e5                	j	800007c6 <printf+0x2cc>

00000000800007e0 <panic>:

void
panic(char *s)
{
    800007e0:	1101                	addi	sp,sp,-32
    800007e2:	ec06                	sd	ra,24(sp)
    800007e4:	e822                	sd	s0,16(sp)
    800007e6:	e426                	sd	s1,8(sp)
    800007e8:	e04a                	sd	s2,0(sp)
    800007ea:	1000                	addi	s0,sp,32
    800007ec:	84aa                	mv	s1,a0
  panicking = 1;
    800007ee:	4905                	li	s2,1
    800007f0:	0000a797          	auipc	a5,0xa
    800007f4:	cb27aa23          	sw	s2,-844(a5) # 8000a4a4 <panicking>
  printf("panic: ");
    800007f8:	00007517          	auipc	a0,0x7
    800007fc:	82050513          	addi	a0,a0,-2016 # 80007018 <etext+0x18>
    80000800:	cfbff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000804:	85a6                	mv	a1,s1
    80000806:	00007517          	auipc	a0,0x7
    8000080a:	81a50513          	addi	a0,a0,-2022 # 80007020 <etext+0x20>
    8000080e:	cedff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000812:	0000a797          	auipc	a5,0xa
    80000816:	c927a723          	sw	s2,-882(a5) # 8000a4a0 <panicked>
  for(;;)
    8000081a:	a001                	j	8000081a <panic+0x3a>

000000008000081c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000081c:	1141                	addi	sp,sp,-16
    8000081e:	e406                	sd	ra,8(sp)
    80000820:	e022                	sd	s0,0(sp)
    80000822:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000824:	00007597          	auipc	a1,0x7
    80000828:	80458593          	addi	a1,a1,-2044 # 80007028 <etext+0x28>
    8000082c:	00012517          	auipc	a0,0x12
    80000830:	d4c50513          	addi	a0,a0,-692 # 80012578 <pr>
    80000834:	31a000ef          	jal	80000b4e <initlock>
}
    80000838:	60a2                	ld	ra,8(sp)
    8000083a:	6402                	ld	s0,0(sp)
    8000083c:	0141                	addi	sp,sp,16
    8000083e:	8082                	ret

0000000080000840 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80000840:	1141                	addi	sp,sp,-16
    80000842:	e406                	sd	ra,8(sp)
    80000844:	e022                	sd	s0,0(sp)
    80000846:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000848:	100007b7          	lui	a5,0x10000
    8000084c:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000850:	10000737          	lui	a4,0x10000
    80000854:	f8000693          	li	a3,-128
    80000858:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000085c:	468d                	li	a3,3
    8000085e:	10000637          	lui	a2,0x10000
    80000862:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000866:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000086a:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	461d                	li	a2,7
    80000874:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000878:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    8000087c:	00006597          	auipc	a1,0x6
    80000880:	7b458593          	addi	a1,a1,1972 # 80007030 <etext+0x30>
    80000884:	00012517          	auipc	a0,0x12
    80000888:	d0c50513          	addi	a0,a0,-756 # 80012590 <tx_lock>
    8000088c:	2c2000ef          	jal	80000b4e <initlock>
}
    80000890:	60a2                	ld	ra,8(sp)
    80000892:	6402                	ld	s0,0(sp)
    80000894:	0141                	addi	sp,sp,16
    80000896:	8082                	ret

0000000080000898 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    80000898:	715d                	addi	sp,sp,-80
    8000089a:	e486                	sd	ra,72(sp)
    8000089c:	e0a2                	sd	s0,64(sp)
    8000089e:	fc26                	sd	s1,56(sp)
    800008a0:	ec56                	sd	s5,24(sp)
    800008a2:	0880                	addi	s0,sp,80
    800008a4:	8aaa                	mv	s5,a0
    800008a6:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008a8:	00012517          	auipc	a0,0x12
    800008ac:	ce850513          	addi	a0,a0,-792 # 80012590 <tx_lock>
    800008b0:	31e000ef          	jal	80000bce <acquire>

  int i = 0;
  while(i < n){ 
    800008b4:	06905063          	blez	s1,80000914 <uartwrite+0x7c>
    800008b8:	f84a                	sd	s2,48(sp)
    800008ba:	f44e                	sd	s3,40(sp)
    800008bc:	f052                	sd	s4,32(sp)
    800008be:	e85a                	sd	s6,16(sp)
    800008c0:	e45e                	sd	s7,8(sp)
    800008c2:	8a56                	mv	s4,s5
    800008c4:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    800008c6:	0000a497          	auipc	s1,0xa
    800008ca:	be648493          	addi	s1,s1,-1050 # 8000a4ac <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    800008ce:	00012997          	auipc	s3,0x12
    800008d2:	cc298993          	addi	s3,s3,-830 # 80012590 <tx_lock>
    800008d6:	0000a917          	auipc	s2,0xa
    800008da:	bd290913          	addi	s2,s2,-1070 # 8000a4a8 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    800008de:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    800008e2:	4b05                	li	s6,1
    800008e4:	a005                	j	80000904 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    800008e6:	85ce                	mv	a1,s3
    800008e8:	854a                	mv	a0,s2
    800008ea:	5ea010ef          	jal	80001ed4 <sleep>
    while(tx_busy != 0){
    800008ee:	409c                	lw	a5,0(s1)
    800008f0:	fbfd                	bnez	a5,800008e6 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    800008f2:	000a4783          	lbu	a5,0(s4)
    800008f6:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    800008fa:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    800008fe:	0a05                	addi	s4,s4,1
    80000900:	015a0563          	beq	s4,s5,8000090a <uartwrite+0x72>
    while(tx_busy != 0){
    80000904:	409c                	lw	a5,0(s1)
    80000906:	f3e5                	bnez	a5,800008e6 <uartwrite+0x4e>
    80000908:	b7ed                	j	800008f2 <uartwrite+0x5a>
    8000090a:	7942                	ld	s2,48(sp)
    8000090c:	79a2                	ld	s3,40(sp)
    8000090e:	7a02                	ld	s4,32(sp)
    80000910:	6b42                	ld	s6,16(sp)
    80000912:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000914:	00012517          	auipc	a0,0x12
    80000918:	c7c50513          	addi	a0,a0,-900 # 80012590 <tx_lock>
    8000091c:	34a000ef          	jal	80000c66 <release>
}
    80000920:	60a6                	ld	ra,72(sp)
    80000922:	6406                	ld	s0,64(sp)
    80000924:	74e2                	ld	s1,56(sp)
    80000926:	6ae2                	ld	s5,24(sp)
    80000928:	6161                	addi	sp,sp,80
    8000092a:	8082                	ret

000000008000092c <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000092c:	1101                	addi	sp,sp,-32
    8000092e:	ec06                	sd	ra,24(sp)
    80000930:	e822                	sd	s0,16(sp)
    80000932:	e426                	sd	s1,8(sp)
    80000934:	1000                	addi	s0,sp,32
    80000936:	84aa                	mv	s1,a0
  if(panicking == 0)
    80000938:	0000a797          	auipc	a5,0xa
    8000093c:	b6c7a783          	lw	a5,-1172(a5) # 8000a4a4 <panicking>
    80000940:	cf95                	beqz	a5,8000097c <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000942:	0000a797          	auipc	a5,0xa
    80000946:	b5e7a783          	lw	a5,-1186(a5) # 8000a4a0 <panicked>
    8000094a:	ef85                	bnez	a5,80000982 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000094c:	10000737          	lui	a4,0x10000
    80000950:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000952:	00074783          	lbu	a5,0(a4)
    80000956:	0207f793          	andi	a5,a5,32
    8000095a:	dfe5                	beqz	a5,80000952 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000095c:	0ff4f513          	zext.b	a0,s1
    80000960:	100007b7          	lui	a5,0x10000
    80000964:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80000968:	0000a797          	auipc	a5,0xa
    8000096c:	b3c7a783          	lw	a5,-1220(a5) # 8000a4a4 <panicking>
    80000970:	cb91                	beqz	a5,80000984 <uartputc_sync+0x58>
    pop_off();
}
    80000972:	60e2                	ld	ra,24(sp)
    80000974:	6442                	ld	s0,16(sp)
    80000976:	64a2                	ld	s1,8(sp)
    80000978:	6105                	addi	sp,sp,32
    8000097a:	8082                	ret
    push_off();
    8000097c:	212000ef          	jal	80000b8e <push_off>
    80000980:	b7c9                	j	80000942 <uartputc_sync+0x16>
    for(;;)
    80000982:	a001                	j	80000982 <uartputc_sync+0x56>
    pop_off();
    80000984:	28e000ef          	jal	80000c12 <pop_off>
}
    80000988:	b7ed                	j	80000972 <uartputc_sync+0x46>

000000008000098a <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000098a:	1141                	addi	sp,sp,-16
    8000098c:	e422                	sd	s0,8(sp)
    8000098e:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    80000990:	100007b7          	lui	a5,0x10000
    80000994:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    80000996:	0007c783          	lbu	a5,0(a5)
    8000099a:	8b85                	andi	a5,a5,1
    8000099c:	cb81                	beqz	a5,800009ac <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    8000099e:	100007b7          	lui	a5,0x10000
    800009a2:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009a6:	6422                	ld	s0,8(sp)
    800009a8:	0141                	addi	sp,sp,16
    800009aa:	8082                	ret
    return -1;
    800009ac:	557d                	li	a0,-1
    800009ae:	bfe5                	j	800009a6 <uartgetc+0x1c>

00000000800009b0 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009b0:	1101                	addi	sp,sp,-32
    800009b2:	ec06                	sd	ra,24(sp)
    800009b4:	e822                	sd	s0,16(sp)
    800009b6:	e426                	sd	s1,8(sp)
    800009b8:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009ba:	100007b7          	lui	a5,0x10000
    800009be:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    800009c0:	0007c783          	lbu	a5,0(a5)

  acquire(&tx_lock);
    800009c4:	00012517          	auipc	a0,0x12
    800009c8:	bcc50513          	addi	a0,a0,-1076 # 80012590 <tx_lock>
    800009cc:	202000ef          	jal	80000bce <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    800009d0:	100007b7          	lui	a5,0x10000
    800009d4:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009d6:	0007c783          	lbu	a5,0(a5)
    800009da:	0207f793          	andi	a5,a5,32
    800009de:	eb89                	bnez	a5,800009f0 <uartintr+0x40>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    800009e0:	00012517          	auipc	a0,0x12
    800009e4:	bb050513          	addi	a0,a0,-1104 # 80012590 <tx_lock>
    800009e8:	27e000ef          	jal	80000c66 <release>

  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009ec:	54fd                	li	s1,-1
    800009ee:	a831                	j	80000a0a <uartintr+0x5a>
    tx_busy = 0;
    800009f0:	0000a797          	auipc	a5,0xa
    800009f4:	aa07ae23          	sw	zero,-1348(a5) # 8000a4ac <tx_busy>
    wakeup(&tx_chan);
    800009f8:	0000a517          	auipc	a0,0xa
    800009fc:	ab050513          	addi	a0,a0,-1360 # 8000a4a8 <tx_chan>
    80000a00:	520010ef          	jal	80001f20 <wakeup>
    80000a04:	bff1                	j	800009e0 <uartintr+0x30>
      break;
    consoleintr(c);
    80000a06:	8a5ff0ef          	jal	800002aa <consoleintr>
    int c = uartgetc();
    80000a0a:	f81ff0ef          	jal	8000098a <uartgetc>
    if(c == -1)
    80000a0e:	fe951ce3          	bne	a0,s1,80000a06 <uartintr+0x56>
  }
}
    80000a12:	60e2                	ld	ra,24(sp)
    80000a14:	6442                	ld	s0,16(sp)
    80000a16:	64a2                	ld	s1,8(sp)
    80000a18:	6105                	addi	sp,sp,32
    80000a1a:	8082                	ret

0000000080000a1c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a1c:	1101                	addi	sp,sp,-32
    80000a1e:	ec06                	sd	ra,24(sp)
    80000a20:	e822                	sd	s0,16(sp)
    80000a22:	e426                	sd	s1,8(sp)
    80000a24:	e04a                	sd	s2,0(sp)
    80000a26:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a28:	03451793          	slli	a5,a0,0x34
    80000a2c:	e7a9                	bnez	a5,80000a76 <kfree+0x5a>
    80000a2e:	84aa                	mv	s1,a0
    80000a30:	00023797          	auipc	a5,0x23
    80000a34:	fa878793          	addi	a5,a5,-88 # 800239d8 <end>
    80000a38:	02f56f63          	bltu	a0,a5,80000a76 <kfree+0x5a>
    80000a3c:	47c5                	li	a5,17
    80000a3e:	07ee                	slli	a5,a5,0x1b
    80000a40:	02f57b63          	bgeu	a0,a5,80000a76 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a44:	6605                	lui	a2,0x1
    80000a46:	4585                	li	a1,1
    80000a48:	25a000ef          	jal	80000ca2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a4c:	00012917          	auipc	s2,0x12
    80000a50:	b5c90913          	addi	s2,s2,-1188 # 800125a8 <kmem>
    80000a54:	854a                	mv	a0,s2
    80000a56:	178000ef          	jal	80000bce <acquire>
  r->next = kmem.freelist;
    80000a5a:	01893783          	ld	a5,24(s2)
    80000a5e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a60:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a64:	854a                	mv	a0,s2
    80000a66:	200000ef          	jal	80000c66 <release>
}
    80000a6a:	60e2                	ld	ra,24(sp)
    80000a6c:	6442                	ld	s0,16(sp)
    80000a6e:	64a2                	ld	s1,8(sp)
    80000a70:	6902                	ld	s2,0(sp)
    80000a72:	6105                	addi	sp,sp,32
    80000a74:	8082                	ret
    panic("kfree");
    80000a76:	00006517          	auipc	a0,0x6
    80000a7a:	5c250513          	addi	a0,a0,1474 # 80007038 <etext+0x38>
    80000a7e:	d63ff0ef          	jal	800007e0 <panic>

0000000080000a82 <freerange>:
{
    80000a82:	7179                	addi	sp,sp,-48
    80000a84:	f406                	sd	ra,40(sp)
    80000a86:	f022                	sd	s0,32(sp)
    80000a88:	ec26                	sd	s1,24(sp)
    80000a8a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a8c:	6785                	lui	a5,0x1
    80000a8e:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a92:	00e504b3          	add	s1,a0,a4
    80000a96:	777d                	lui	a4,0xfffff
    80000a98:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a9a:	94be                	add	s1,s1,a5
    80000a9c:	0295e263          	bltu	a1,s1,80000ac0 <freerange+0x3e>
    80000aa0:	e84a                	sd	s2,16(sp)
    80000aa2:	e44e                	sd	s3,8(sp)
    80000aa4:	e052                	sd	s4,0(sp)
    80000aa6:	892e                	mv	s2,a1
    kfree(p);
    80000aa8:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aaa:	6985                	lui	s3,0x1
    kfree(p);
    80000aac:	01448533          	add	a0,s1,s4
    80000ab0:	f6dff0ef          	jal	80000a1c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ab4:	94ce                	add	s1,s1,s3
    80000ab6:	fe997be3          	bgeu	s2,s1,80000aac <freerange+0x2a>
    80000aba:	6942                	ld	s2,16(sp)
    80000abc:	69a2                	ld	s3,8(sp)
    80000abe:	6a02                	ld	s4,0(sp)
}
    80000ac0:	70a2                	ld	ra,40(sp)
    80000ac2:	7402                	ld	s0,32(sp)
    80000ac4:	64e2                	ld	s1,24(sp)
    80000ac6:	6145                	addi	sp,sp,48
    80000ac8:	8082                	ret

0000000080000aca <kinit>:
{
    80000aca:	1141                	addi	sp,sp,-16
    80000acc:	e406                	sd	ra,8(sp)
    80000ace:	e022                	sd	s0,0(sp)
    80000ad0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ad2:	00006597          	auipc	a1,0x6
    80000ad6:	56e58593          	addi	a1,a1,1390 # 80007040 <etext+0x40>
    80000ada:	00012517          	auipc	a0,0x12
    80000ade:	ace50513          	addi	a0,a0,-1330 # 800125a8 <kmem>
    80000ae2:	06c000ef          	jal	80000b4e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ae6:	45c5                	li	a1,17
    80000ae8:	05ee                	slli	a1,a1,0x1b
    80000aea:	00023517          	auipc	a0,0x23
    80000aee:	eee50513          	addi	a0,a0,-274 # 800239d8 <end>
    80000af2:	f91ff0ef          	jal	80000a82 <freerange>
}
    80000af6:	60a2                	ld	ra,8(sp)
    80000af8:	6402                	ld	s0,0(sp)
    80000afa:	0141                	addi	sp,sp,16
    80000afc:	8082                	ret

0000000080000afe <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000afe:	1101                	addi	sp,sp,-32
    80000b00:	ec06                	sd	ra,24(sp)
    80000b02:	e822                	sd	s0,16(sp)
    80000b04:	e426                	sd	s1,8(sp)
    80000b06:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b08:	00012497          	auipc	s1,0x12
    80000b0c:	aa048493          	addi	s1,s1,-1376 # 800125a8 <kmem>
    80000b10:	8526                	mv	a0,s1
    80000b12:	0bc000ef          	jal	80000bce <acquire>
  r = kmem.freelist;
    80000b16:	6c84                	ld	s1,24(s1)
  if(r)
    80000b18:	c485                	beqz	s1,80000b40 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b1a:	609c                	ld	a5,0(s1)
    80000b1c:	00012517          	auipc	a0,0x12
    80000b20:	a8c50513          	addi	a0,a0,-1396 # 800125a8 <kmem>
    80000b24:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b26:	140000ef          	jal	80000c66 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b2a:	6605                	lui	a2,0x1
    80000b2c:	4595                	li	a1,5
    80000b2e:	8526                	mv	a0,s1
    80000b30:	172000ef          	jal	80000ca2 <memset>
  return (void*)r;
}
    80000b34:	8526                	mv	a0,s1
    80000b36:	60e2                	ld	ra,24(sp)
    80000b38:	6442                	ld	s0,16(sp)
    80000b3a:	64a2                	ld	s1,8(sp)
    80000b3c:	6105                	addi	sp,sp,32
    80000b3e:	8082                	ret
  release(&kmem.lock);
    80000b40:	00012517          	auipc	a0,0x12
    80000b44:	a6850513          	addi	a0,a0,-1432 # 800125a8 <kmem>
    80000b48:	11e000ef          	jal	80000c66 <release>
  if(r)
    80000b4c:	b7e5                	j	80000b34 <kalloc+0x36>

0000000080000b4e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b4e:	1141                	addi	sp,sp,-16
    80000b50:	e422                	sd	s0,8(sp)
    80000b52:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b54:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b56:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b5a:	00053823          	sd	zero,16(a0)
}
    80000b5e:	6422                	ld	s0,8(sp)
    80000b60:	0141                	addi	sp,sp,16
    80000b62:	8082                	ret

0000000080000b64 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b64:	411c                	lw	a5,0(a0)
    80000b66:	e399                	bnez	a5,80000b6c <holding+0x8>
    80000b68:	4501                	li	a0,0
  return r;
}
    80000b6a:	8082                	ret
{
    80000b6c:	1101                	addi	sp,sp,-32
    80000b6e:	ec06                	sd	ra,24(sp)
    80000b70:	e822                	sd	s0,16(sp)
    80000b72:	e426                	sd	s1,8(sp)
    80000b74:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b76:	6904                	ld	s1,16(a0)
    80000b78:	53b000ef          	jal	800018b2 <mycpu>
    80000b7c:	40a48533          	sub	a0,s1,a0
    80000b80:	00153513          	seqz	a0,a0
}
    80000b84:	60e2                	ld	ra,24(sp)
    80000b86:	6442                	ld	s0,16(sp)
    80000b88:	64a2                	ld	s1,8(sp)
    80000b8a:	6105                	addi	sp,sp,32
    80000b8c:	8082                	ret

0000000080000b8e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8e:	1101                	addi	sp,sp,-32
    80000b90:	ec06                	sd	ra,24(sp)
    80000b92:	e822                	sd	s0,16(sp)
    80000b94:	e426                	sd	s1,8(sp)
    80000b96:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b98:	100024f3          	csrr	s1,sstatus
    80000b9c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000ba0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000ba2:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000ba6:	50d000ef          	jal	800018b2 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cb99                	beqz	a5,80000bc2 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	505000ef          	jal	800018b2 <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addiw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	addi	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	4f1000ef          	jal	800018b2 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bc6:	8085                	srli	s1,s1,0x1
    80000bc8:	8885                	andi	s1,s1,1
    80000bca:	dd64                	sw	s1,124(a0)
    80000bcc:	b7cd                	j	80000bae <push_off+0x20>

0000000080000bce <acquire>:
{
    80000bce:	1101                	addi	sp,sp,-32
    80000bd0:	ec06                	sd	ra,24(sp)
    80000bd2:	e822                	sd	s0,16(sp)
    80000bd4:	e426                	sd	s1,8(sp)
    80000bd6:	1000                	addi	s0,sp,32
    80000bd8:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bda:	fb5ff0ef          	jal	80000b8e <push_off>
  if(holding(lk))
    80000bde:	8526                	mv	a0,s1
    80000be0:	f85ff0ef          	jal	80000b64 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be4:	4705                	li	a4,1
  if(holding(lk))
    80000be6:	e105                	bnez	a0,80000c06 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be8:	87ba                	mv	a5,a4
    80000bea:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bee:	2781                	sext.w	a5,a5
    80000bf0:	ffe5                	bnez	a5,80000be8 <acquire+0x1a>
  __sync_synchronize();
    80000bf2:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000bf6:	4bd000ef          	jal	800018b2 <mycpu>
    80000bfa:	e888                	sd	a0,16(s1)
}
    80000bfc:	60e2                	ld	ra,24(sp)
    80000bfe:	6442                	ld	s0,16(sp)
    80000c00:	64a2                	ld	s1,8(sp)
    80000c02:	6105                	addi	sp,sp,32
    80000c04:	8082                	ret
    panic("acquire");
    80000c06:	00006517          	auipc	a0,0x6
    80000c0a:	44250513          	addi	a0,a0,1090 # 80007048 <etext+0x48>
    80000c0e:	bd3ff0ef          	jal	800007e0 <panic>

0000000080000c12 <pop_off>:

void
pop_off(void)
{
    80000c12:	1141                	addi	sp,sp,-16
    80000c14:	e406                	sd	ra,8(sp)
    80000c16:	e022                	sd	s0,0(sp)
    80000c18:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c1a:	499000ef          	jal	800018b2 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c1e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c22:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c24:	e78d                	bnez	a5,80000c4e <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c26:	5d3c                	lw	a5,120(a0)
    80000c28:	02f05963          	blez	a5,80000c5a <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c2c:	37fd                	addiw	a5,a5,-1
    80000c2e:	0007871b          	sext.w	a4,a5
    80000c32:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c34:	eb09                	bnez	a4,80000c46 <pop_off+0x34>
    80000c36:	5d7c                	lw	a5,124(a0)
    80000c38:	c799                	beqz	a5,80000c46 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c3e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c42:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c46:	60a2                	ld	ra,8(sp)
    80000c48:	6402                	ld	s0,0(sp)
    80000c4a:	0141                	addi	sp,sp,16
    80000c4c:	8082                	ret
    panic("pop_off - interruptible");
    80000c4e:	00006517          	auipc	a0,0x6
    80000c52:	40250513          	addi	a0,a0,1026 # 80007050 <etext+0x50>
    80000c56:	b8bff0ef          	jal	800007e0 <panic>
    panic("pop_off");
    80000c5a:	00006517          	auipc	a0,0x6
    80000c5e:	40e50513          	addi	a0,a0,1038 # 80007068 <etext+0x68>
    80000c62:	b7fff0ef          	jal	800007e0 <panic>

0000000080000c66 <release>:
{
    80000c66:	1101                	addi	sp,sp,-32
    80000c68:	ec06                	sd	ra,24(sp)
    80000c6a:	e822                	sd	s0,16(sp)
    80000c6c:	e426                	sd	s1,8(sp)
    80000c6e:	1000                	addi	s0,sp,32
    80000c70:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c72:	ef3ff0ef          	jal	80000b64 <holding>
    80000c76:	c105                	beqz	a0,80000c96 <release+0x30>
  lk->cpu = 0;
    80000c78:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c7c:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000c80:	0310000f          	fence	rw,w
    80000c84:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000c88:	f8bff0ef          	jal	80000c12 <pop_off>
}
    80000c8c:	60e2                	ld	ra,24(sp)
    80000c8e:	6442                	ld	s0,16(sp)
    80000c90:	64a2                	ld	s1,8(sp)
    80000c92:	6105                	addi	sp,sp,32
    80000c94:	8082                	ret
    panic("release");
    80000c96:	00006517          	auipc	a0,0x6
    80000c9a:	3da50513          	addi	a0,a0,986 # 80007070 <etext+0x70>
    80000c9e:	b43ff0ef          	jal	800007e0 <panic>

0000000080000ca2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ca2:	1141                	addi	sp,sp,-16
    80000ca4:	e422                	sd	s0,8(sp)
    80000ca6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000ca8:	ca19                	beqz	a2,80000cbe <memset+0x1c>
    80000caa:	87aa                	mv	a5,a0
    80000cac:	1602                	slli	a2,a2,0x20
    80000cae:	9201                	srli	a2,a2,0x20
    80000cb0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cb4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cb8:	0785                	addi	a5,a5,1
    80000cba:	fee79de3          	bne	a5,a4,80000cb4 <memset+0x12>
  }
  return dst;
}
    80000cbe:	6422                	ld	s0,8(sp)
    80000cc0:	0141                	addi	sp,sp,16
    80000cc2:	8082                	ret

0000000080000cc4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cc4:	1141                	addi	sp,sp,-16
    80000cc6:	e422                	sd	s0,8(sp)
    80000cc8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cca:	ca05                	beqz	a2,80000cfa <memcmp+0x36>
    80000ccc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cd0:	1682                	slli	a3,a3,0x20
    80000cd2:	9281                	srli	a3,a3,0x20
    80000cd4:	0685                	addi	a3,a3,1
    80000cd6:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cd8:	00054783          	lbu	a5,0(a0)
    80000cdc:	0005c703          	lbu	a4,0(a1)
    80000ce0:	00e79863          	bne	a5,a4,80000cf0 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000ce4:	0505                	addi	a0,a0,1
    80000ce6:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000ce8:	fed518e3          	bne	a0,a3,80000cd8 <memcmp+0x14>
  }

  return 0;
    80000cec:	4501                	li	a0,0
    80000cee:	a019                	j	80000cf4 <memcmp+0x30>
      return *s1 - *s2;
    80000cf0:	40e7853b          	subw	a0,a5,a4
}
    80000cf4:	6422                	ld	s0,8(sp)
    80000cf6:	0141                	addi	sp,sp,16
    80000cf8:	8082                	ret
  return 0;
    80000cfa:	4501                	li	a0,0
    80000cfc:	bfe5                	j	80000cf4 <memcmp+0x30>

0000000080000cfe <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000cfe:	1141                	addi	sp,sp,-16
    80000d00:	e422                	sd	s0,8(sp)
    80000d02:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d04:	c205                	beqz	a2,80000d24 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d06:	02a5e263          	bltu	a1,a0,80000d2a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d0a:	1602                	slli	a2,a2,0x20
    80000d0c:	9201                	srli	a2,a2,0x20
    80000d0e:	00c587b3          	add	a5,a1,a2
{
    80000d12:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d14:	0585                	addi	a1,a1,1
    80000d16:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdb629>
    80000d18:	fff5c683          	lbu	a3,-1(a1)
    80000d1c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d20:	feb79ae3          	bne	a5,a1,80000d14 <memmove+0x16>

  return dst;
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  if(s < d && s + n > d){
    80000d2a:	02061693          	slli	a3,a2,0x20
    80000d2e:	9281                	srli	a3,a3,0x20
    80000d30:	00d58733          	add	a4,a1,a3
    80000d34:	fce57be3          	bgeu	a0,a4,80000d0a <memmove+0xc>
    d += n;
    80000d38:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d3a:	fff6079b          	addiw	a5,a2,-1
    80000d3e:	1782                	slli	a5,a5,0x20
    80000d40:	9381                	srli	a5,a5,0x20
    80000d42:	fff7c793          	not	a5,a5
    80000d46:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d48:	177d                	addi	a4,a4,-1
    80000d4a:	16fd                	addi	a3,a3,-1
    80000d4c:	00074603          	lbu	a2,0(a4)
    80000d50:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d54:	fef71ae3          	bne	a4,a5,80000d48 <memmove+0x4a>
    80000d58:	b7f1                	j	80000d24 <memmove+0x26>

0000000080000d5a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d5a:	1141                	addi	sp,sp,-16
    80000d5c:	e406                	sd	ra,8(sp)
    80000d5e:	e022                	sd	s0,0(sp)
    80000d60:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d62:	f9dff0ef          	jal	80000cfe <memmove>
}
    80000d66:	60a2                	ld	ra,8(sp)
    80000d68:	6402                	ld	s0,0(sp)
    80000d6a:	0141                	addi	sp,sp,16
    80000d6c:	8082                	ret

0000000080000d6e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d6e:	1141                	addi	sp,sp,-16
    80000d70:	e422                	sd	s0,8(sp)
    80000d72:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d74:	ce11                	beqz	a2,80000d90 <strncmp+0x22>
    80000d76:	00054783          	lbu	a5,0(a0)
    80000d7a:	cf89                	beqz	a5,80000d94 <strncmp+0x26>
    80000d7c:	0005c703          	lbu	a4,0(a1)
    80000d80:	00f71a63          	bne	a4,a5,80000d94 <strncmp+0x26>
    n--, p++, q++;
    80000d84:	367d                	addiw	a2,a2,-1
    80000d86:	0505                	addi	a0,a0,1
    80000d88:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000d8a:	f675                	bnez	a2,80000d76 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000d8c:	4501                	li	a0,0
    80000d8e:	a801                	j	80000d9e <strncmp+0x30>
    80000d90:	4501                	li	a0,0
    80000d92:	a031                	j	80000d9e <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000d94:	00054503          	lbu	a0,0(a0)
    80000d98:	0005c783          	lbu	a5,0(a1)
    80000d9c:	9d1d                	subw	a0,a0,a5
}
    80000d9e:	6422                	ld	s0,8(sp)
    80000da0:	0141                	addi	sp,sp,16
    80000da2:	8082                	ret

0000000080000da4 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000da4:	1141                	addi	sp,sp,-16
    80000da6:	e422                	sd	s0,8(sp)
    80000da8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000daa:	87aa                	mv	a5,a0
    80000dac:	86b2                	mv	a3,a2
    80000dae:	367d                	addiw	a2,a2,-1
    80000db0:	02d05563          	blez	a3,80000dda <strncpy+0x36>
    80000db4:	0785                	addi	a5,a5,1
    80000db6:	0005c703          	lbu	a4,0(a1)
    80000dba:	fee78fa3          	sb	a4,-1(a5)
    80000dbe:	0585                	addi	a1,a1,1
    80000dc0:	f775                	bnez	a4,80000dac <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dc2:	873e                	mv	a4,a5
    80000dc4:	9fb5                	addw	a5,a5,a3
    80000dc6:	37fd                	addiw	a5,a5,-1
    80000dc8:	00c05963          	blez	a2,80000dda <strncpy+0x36>
    *s++ = 0;
    80000dcc:	0705                	addi	a4,a4,1
    80000dce:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000dd2:	40e786bb          	subw	a3,a5,a4
    80000dd6:	fed04be3          	bgtz	a3,80000dcc <strncpy+0x28>
  return os;
}
    80000dda:	6422                	ld	s0,8(sp)
    80000ddc:	0141                	addi	sp,sp,16
    80000dde:	8082                	ret

0000000080000de0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000de0:	1141                	addi	sp,sp,-16
    80000de2:	e422                	sd	s0,8(sp)
    80000de4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000de6:	02c05363          	blez	a2,80000e0c <safestrcpy+0x2c>
    80000dea:	fff6069b          	addiw	a3,a2,-1
    80000dee:	1682                	slli	a3,a3,0x20
    80000df0:	9281                	srli	a3,a3,0x20
    80000df2:	96ae                	add	a3,a3,a1
    80000df4:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000df6:	00d58963          	beq	a1,a3,80000e08 <safestrcpy+0x28>
    80000dfa:	0585                	addi	a1,a1,1
    80000dfc:	0785                	addi	a5,a5,1
    80000dfe:	fff5c703          	lbu	a4,-1(a1)
    80000e02:	fee78fa3          	sb	a4,-1(a5)
    80000e06:	fb65                	bnez	a4,80000df6 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e08:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e0c:	6422                	ld	s0,8(sp)
    80000e0e:	0141                	addi	sp,sp,16
    80000e10:	8082                	ret

0000000080000e12 <strlen>:

int
strlen(const char *s)
{
    80000e12:	1141                	addi	sp,sp,-16
    80000e14:	e422                	sd	s0,8(sp)
    80000e16:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e18:	00054783          	lbu	a5,0(a0)
    80000e1c:	cf91                	beqz	a5,80000e38 <strlen+0x26>
    80000e1e:	0505                	addi	a0,a0,1
    80000e20:	87aa                	mv	a5,a0
    80000e22:	86be                	mv	a3,a5
    80000e24:	0785                	addi	a5,a5,1
    80000e26:	fff7c703          	lbu	a4,-1(a5)
    80000e2a:	ff65                	bnez	a4,80000e22 <strlen+0x10>
    80000e2c:	40a6853b          	subw	a0,a3,a0
    80000e30:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e38:	4501                	li	a0,0
    80000e3a:	bfe5                	j	80000e32 <strlen+0x20>

0000000080000e3c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e3c:	1141                	addi	sp,sp,-16
    80000e3e:	e406                	sd	ra,8(sp)
    80000e40:	e022                	sd	s0,0(sp)
    80000e42:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e44:	25f000ef          	jal	800018a2 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e48:	00009717          	auipc	a4,0x9
    80000e4c:	66870713          	addi	a4,a4,1640 # 8000a4b0 <started>
  if(cpuid() == 0){
    80000e50:	c51d                	beqz	a0,80000e7e <main+0x42>
    while(started == 0)
    80000e52:	431c                	lw	a5,0(a4)
    80000e54:	2781                	sext.w	a5,a5
    80000e56:	dff5                	beqz	a5,80000e52 <main+0x16>
      ;
    __sync_synchronize();
    80000e58:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000e5c:	247000ef          	jal	800018a2 <cpuid>
    80000e60:	85aa                	mv	a1,a0
    80000e62:	00006517          	auipc	a0,0x6
    80000e66:	22e50513          	addi	a0,a0,558 # 80007090 <etext+0x90>
    80000e6a:	e90ff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000e6e:	080000ef          	jal	80000eee <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e72:	634010ef          	jal	800024a6 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e76:	702040ef          	jal	80005578 <plicinithart>
  }

  scheduler();        
    80000e7a:	6c3000ef          	jal	80001d3c <scheduler>
    consoleinit();
    80000e7e:	da6ff0ef          	jal	80000424 <consoleinit>
    printfinit();
    80000e82:	99bff0ef          	jal	8000081c <printfinit>
    printf("\n");
    80000e86:	00006517          	auipc	a0,0x6
    80000e8a:	40250513          	addi	a0,a0,1026 # 80007288 <etext+0x288>
    80000e8e:	e6cff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000e92:	00006517          	auipc	a0,0x6
    80000e96:	1e650513          	addi	a0,a0,486 # 80007078 <etext+0x78>
    80000e9a:	e60ff0ef          	jal	800004fa <printf>
    printf("\n");
    80000e9e:	00006517          	auipc	a0,0x6
    80000ea2:	3ea50513          	addi	a0,a0,1002 # 80007288 <etext+0x288>
    80000ea6:	e54ff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80000eaa:	c21ff0ef          	jal	80000aca <kinit>
    kvminit();       // create kernel page table
    80000eae:	2ca000ef          	jal	80001178 <kvminit>
    kvminithart();   // turn on paging
    80000eb2:	03c000ef          	jal	80000eee <kvminithart>
    procinit();      // process table
    80000eb6:	137000ef          	jal	800017ec <procinit>
    trapinit();      // trap vectors
    80000eba:	5c8010ef          	jal	80002482 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ebe:	5e8010ef          	jal	800024a6 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ec2:	69c040ef          	jal	8000555e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ec6:	6b2040ef          	jal	80005578 <plicinithart>
    binit();         // buffer cache
    80000eca:	581010ef          	jal	80002c4a <binit>
    iinit();         // inode table
    80000ece:	306020ef          	jal	800031d4 <iinit>
    fileinit();      // file table
    80000ed2:	1f8030ef          	jal	800040ca <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ed6:	792040ef          	jal	80005668 <virtio_disk_init>
    userinit();      // first user process
    80000eda:	4bb000ef          	jal	80001b94 <userinit>
    __sync_synchronize();
    80000ede:	0330000f          	fence	rw,rw
    started = 1;
    80000ee2:	4785                	li	a5,1
    80000ee4:	00009717          	auipc	a4,0x9
    80000ee8:	5cf72623          	sw	a5,1484(a4) # 8000a4b0 <started>
    80000eec:	b779                	j	80000e7a <main+0x3e>

0000000080000eee <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000eee:	1141                	addi	sp,sp,-16
    80000ef0:	e422                	sd	s0,8(sp)
    80000ef2:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000ef4:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000ef8:	00009797          	auipc	a5,0x9
    80000efc:	5c07b783          	ld	a5,1472(a5) # 8000a4b8 <kernel_pagetable>
    80000f00:	83b1                	srli	a5,a5,0xc
    80000f02:	577d                	li	a4,-1
    80000f04:	177e                	slli	a4,a4,0x3f
    80000f06:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f08:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f0c:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f10:	6422                	ld	s0,8(sp)
    80000f12:	0141                	addi	sp,sp,16
    80000f14:	8082                	ret

0000000080000f16 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f16:	7139                	addi	sp,sp,-64
    80000f18:	fc06                	sd	ra,56(sp)
    80000f1a:	f822                	sd	s0,48(sp)
    80000f1c:	f426                	sd	s1,40(sp)
    80000f1e:	f04a                	sd	s2,32(sp)
    80000f20:	ec4e                	sd	s3,24(sp)
    80000f22:	e852                	sd	s4,16(sp)
    80000f24:	e456                	sd	s5,8(sp)
    80000f26:	e05a                	sd	s6,0(sp)
    80000f28:	0080                	addi	s0,sp,64
    80000f2a:	84aa                	mv	s1,a0
    80000f2c:	89ae                	mv	s3,a1
    80000f2e:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f30:	57fd                	li	a5,-1
    80000f32:	83e9                	srli	a5,a5,0x1a
    80000f34:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f36:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f38:	02b7fc63          	bgeu	a5,a1,80000f70 <walk+0x5a>
    panic("walk");
    80000f3c:	00006517          	auipc	a0,0x6
    80000f40:	16c50513          	addi	a0,a0,364 # 800070a8 <etext+0xa8>
    80000f44:	89dff0ef          	jal	800007e0 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f48:	060a8263          	beqz	s5,80000fac <walk+0x96>
    80000f4c:	bb3ff0ef          	jal	80000afe <kalloc>
    80000f50:	84aa                	mv	s1,a0
    80000f52:	c139                	beqz	a0,80000f98 <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f54:	6605                	lui	a2,0x1
    80000f56:	4581                	li	a1,0
    80000f58:	d4bff0ef          	jal	80000ca2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f5c:	00c4d793          	srli	a5,s1,0xc
    80000f60:	07aa                	slli	a5,a5,0xa
    80000f62:	0017e793          	ori	a5,a5,1
    80000f66:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f6a:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdb61f>
    80000f6c:	036a0063          	beq	s4,s6,80000f8c <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f70:	0149d933          	srl	s2,s3,s4
    80000f74:	1ff97913          	andi	s2,s2,511
    80000f78:	090e                	slli	s2,s2,0x3
    80000f7a:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000f7c:	00093483          	ld	s1,0(s2)
    80000f80:	0014f793          	andi	a5,s1,1
    80000f84:	d3f1                	beqz	a5,80000f48 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f86:	80a9                	srli	s1,s1,0xa
    80000f88:	04b2                	slli	s1,s1,0xc
    80000f8a:	b7c5                	j	80000f6a <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000f8c:	00c9d513          	srli	a0,s3,0xc
    80000f90:	1ff57513          	andi	a0,a0,511
    80000f94:	050e                	slli	a0,a0,0x3
    80000f96:	9526                	add	a0,a0,s1
}
    80000f98:	70e2                	ld	ra,56(sp)
    80000f9a:	7442                	ld	s0,48(sp)
    80000f9c:	74a2                	ld	s1,40(sp)
    80000f9e:	7902                	ld	s2,32(sp)
    80000fa0:	69e2                	ld	s3,24(sp)
    80000fa2:	6a42                	ld	s4,16(sp)
    80000fa4:	6aa2                	ld	s5,8(sp)
    80000fa6:	6b02                	ld	s6,0(sp)
    80000fa8:	6121                	addi	sp,sp,64
    80000faa:	8082                	ret
        return 0;
    80000fac:	4501                	li	a0,0
    80000fae:	b7ed                	j	80000f98 <walk+0x82>

0000000080000fb0 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fb0:	57fd                	li	a5,-1
    80000fb2:	83e9                	srli	a5,a5,0x1a
    80000fb4:	00b7f463          	bgeu	a5,a1,80000fbc <walkaddr+0xc>
    return 0;
    80000fb8:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fba:	8082                	ret
{
    80000fbc:	1141                	addi	sp,sp,-16
    80000fbe:	e406                	sd	ra,8(sp)
    80000fc0:	e022                	sd	s0,0(sp)
    80000fc2:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fc4:	4601                	li	a2,0
    80000fc6:	f51ff0ef          	jal	80000f16 <walk>
  if(pte == 0)
    80000fca:	c105                	beqz	a0,80000fea <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000fcc:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000fce:	0117f693          	andi	a3,a5,17
    80000fd2:	4745                	li	a4,17
    return 0;
    80000fd4:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000fd6:	00e68663          	beq	a3,a4,80000fe2 <walkaddr+0x32>
}
    80000fda:	60a2                	ld	ra,8(sp)
    80000fdc:	6402                	ld	s0,0(sp)
    80000fde:	0141                	addi	sp,sp,16
    80000fe0:	8082                	ret
  pa = PTE2PA(*pte);
    80000fe2:	83a9                	srli	a5,a5,0xa
    80000fe4:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000fe8:	bfcd                	j	80000fda <walkaddr+0x2a>
    return 0;
    80000fea:	4501                	li	a0,0
    80000fec:	b7fd                	j	80000fda <walkaddr+0x2a>

0000000080000fee <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000fee:	715d                	addi	sp,sp,-80
    80000ff0:	e486                	sd	ra,72(sp)
    80000ff2:	e0a2                	sd	s0,64(sp)
    80000ff4:	fc26                	sd	s1,56(sp)
    80000ff6:	f84a                	sd	s2,48(sp)
    80000ff8:	f44e                	sd	s3,40(sp)
    80000ffa:	f052                	sd	s4,32(sp)
    80000ffc:	ec56                	sd	s5,24(sp)
    80000ffe:	e85a                	sd	s6,16(sp)
    80001000:	e45e                	sd	s7,8(sp)
    80001002:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001004:	03459793          	slli	a5,a1,0x34
    80001008:	e7a9                	bnez	a5,80001052 <mappages+0x64>
    8000100a:	8aaa                	mv	s5,a0
    8000100c:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    8000100e:	03461793          	slli	a5,a2,0x34
    80001012:	e7b1                	bnez	a5,8000105e <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    80001014:	ca39                	beqz	a2,8000106a <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001016:	77fd                	lui	a5,0xfffff
    80001018:	963e                	add	a2,a2,a5
    8000101a:	00b609b3          	add	s3,a2,a1
  a = va;
    8000101e:	892e                	mv	s2,a1
    80001020:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001024:	6b85                	lui	s7,0x1
    80001026:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    8000102a:	4605                	li	a2,1
    8000102c:	85ca                	mv	a1,s2
    8000102e:	8556                	mv	a0,s5
    80001030:	ee7ff0ef          	jal	80000f16 <walk>
    80001034:	c539                	beqz	a0,80001082 <mappages+0x94>
    if(*pte & PTE_V)
    80001036:	611c                	ld	a5,0(a0)
    80001038:	8b85                	andi	a5,a5,1
    8000103a:	ef95                	bnez	a5,80001076 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000103c:	80b1                	srli	s1,s1,0xc
    8000103e:	04aa                	slli	s1,s1,0xa
    80001040:	0164e4b3          	or	s1,s1,s6
    80001044:	0014e493          	ori	s1,s1,1
    80001048:	e104                	sd	s1,0(a0)
    if(a == last)
    8000104a:	05390863          	beq	s2,s3,8000109a <mappages+0xac>
    a += PGSIZE;
    8000104e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001050:	bfd9                	j	80001026 <mappages+0x38>
    panic("mappages: va not aligned");
    80001052:	00006517          	auipc	a0,0x6
    80001056:	05e50513          	addi	a0,a0,94 # 800070b0 <etext+0xb0>
    8000105a:	f86ff0ef          	jal	800007e0 <panic>
    panic("mappages: size not aligned");
    8000105e:	00006517          	auipc	a0,0x6
    80001062:	07250513          	addi	a0,a0,114 # 800070d0 <etext+0xd0>
    80001066:	f7aff0ef          	jal	800007e0 <panic>
    panic("mappages: size");
    8000106a:	00006517          	auipc	a0,0x6
    8000106e:	08650513          	addi	a0,a0,134 # 800070f0 <etext+0xf0>
    80001072:	f6eff0ef          	jal	800007e0 <panic>
      panic("mappages: remap");
    80001076:	00006517          	auipc	a0,0x6
    8000107a:	08a50513          	addi	a0,a0,138 # 80007100 <etext+0x100>
    8000107e:	f62ff0ef          	jal	800007e0 <panic>
      return -1;
    80001082:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001084:	60a6                	ld	ra,72(sp)
    80001086:	6406                	ld	s0,64(sp)
    80001088:	74e2                	ld	s1,56(sp)
    8000108a:	7942                	ld	s2,48(sp)
    8000108c:	79a2                	ld	s3,40(sp)
    8000108e:	7a02                	ld	s4,32(sp)
    80001090:	6ae2                	ld	s5,24(sp)
    80001092:	6b42                	ld	s6,16(sp)
    80001094:	6ba2                	ld	s7,8(sp)
    80001096:	6161                	addi	sp,sp,80
    80001098:	8082                	ret
  return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7e5                	j	80001084 <mappages+0x96>

000000008000109e <kvmmap>:
{
    8000109e:	1141                	addi	sp,sp,-16
    800010a0:	e406                	sd	ra,8(sp)
    800010a2:	e022                	sd	s0,0(sp)
    800010a4:	0800                	addi	s0,sp,16
    800010a6:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010a8:	86b2                	mv	a3,a2
    800010aa:	863e                	mv	a2,a5
    800010ac:	f43ff0ef          	jal	80000fee <mappages>
    800010b0:	e509                	bnez	a0,800010ba <kvmmap+0x1c>
}
    800010b2:	60a2                	ld	ra,8(sp)
    800010b4:	6402                	ld	s0,0(sp)
    800010b6:	0141                	addi	sp,sp,16
    800010b8:	8082                	ret
    panic("kvmmap");
    800010ba:	00006517          	auipc	a0,0x6
    800010be:	05650513          	addi	a0,a0,86 # 80007110 <etext+0x110>
    800010c2:	f1eff0ef          	jal	800007e0 <panic>

00000000800010c6 <kvmmake>:
{
    800010c6:	1101                	addi	sp,sp,-32
    800010c8:	ec06                	sd	ra,24(sp)
    800010ca:	e822                	sd	s0,16(sp)
    800010cc:	e426                	sd	s1,8(sp)
    800010ce:	e04a                	sd	s2,0(sp)
    800010d0:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010d2:	a2dff0ef          	jal	80000afe <kalloc>
    800010d6:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010d8:	6605                	lui	a2,0x1
    800010da:	4581                	li	a1,0
    800010dc:	bc7ff0ef          	jal	80000ca2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800010e0:	4719                	li	a4,6
    800010e2:	6685                	lui	a3,0x1
    800010e4:	10000637          	lui	a2,0x10000
    800010e8:	100005b7          	lui	a1,0x10000
    800010ec:	8526                	mv	a0,s1
    800010ee:	fb1ff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800010f2:	4719                	li	a4,6
    800010f4:	6685                	lui	a3,0x1
    800010f6:	10001637          	lui	a2,0x10001
    800010fa:	100015b7          	lui	a1,0x10001
    800010fe:	8526                	mv	a0,s1
    80001100:	f9fff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001104:	4719                	li	a4,6
    80001106:	040006b7          	lui	a3,0x4000
    8000110a:	0c000637          	lui	a2,0xc000
    8000110e:	0c0005b7          	lui	a1,0xc000
    80001112:	8526                	mv	a0,s1
    80001114:	f8bff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001118:	00006917          	auipc	s2,0x6
    8000111c:	ee890913          	addi	s2,s2,-280 # 80007000 <etext>
    80001120:	4729                	li	a4,10
    80001122:	80006697          	auipc	a3,0x80006
    80001126:	ede68693          	addi	a3,a3,-290 # 7000 <_entry-0x7fff9000>
    8000112a:	4605                	li	a2,1
    8000112c:	067e                	slli	a2,a2,0x1f
    8000112e:	85b2                	mv	a1,a2
    80001130:	8526                	mv	a0,s1
    80001132:	f6dff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001136:	46c5                	li	a3,17
    80001138:	06ee                	slli	a3,a3,0x1b
    8000113a:	4719                	li	a4,6
    8000113c:	412686b3          	sub	a3,a3,s2
    80001140:	864a                	mv	a2,s2
    80001142:	85ca                	mv	a1,s2
    80001144:	8526                	mv	a0,s1
    80001146:	f59ff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000114a:	4729                	li	a4,10
    8000114c:	6685                	lui	a3,0x1
    8000114e:	00005617          	auipc	a2,0x5
    80001152:	eb260613          	addi	a2,a2,-334 # 80006000 <_trampoline>
    80001156:	040005b7          	lui	a1,0x4000
    8000115a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000115c:	05b2                	slli	a1,a1,0xc
    8000115e:	8526                	mv	a0,s1
    80001160:	f3fff0ef          	jal	8000109e <kvmmap>
  proc_mapstacks(kpgtbl);
    80001164:	8526                	mv	a0,s1
    80001166:	5ee000ef          	jal	80001754 <proc_mapstacks>
}
    8000116a:	8526                	mv	a0,s1
    8000116c:	60e2                	ld	ra,24(sp)
    8000116e:	6442                	ld	s0,16(sp)
    80001170:	64a2                	ld	s1,8(sp)
    80001172:	6902                	ld	s2,0(sp)
    80001174:	6105                	addi	sp,sp,32
    80001176:	8082                	ret

0000000080001178 <kvminit>:
{
    80001178:	1141                	addi	sp,sp,-16
    8000117a:	e406                	sd	ra,8(sp)
    8000117c:	e022                	sd	s0,0(sp)
    8000117e:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001180:	f47ff0ef          	jal	800010c6 <kvmmake>
    80001184:	00009797          	auipc	a5,0x9
    80001188:	32a7ba23          	sd	a0,820(a5) # 8000a4b8 <kernel_pagetable>
}
    8000118c:	60a2                	ld	ra,8(sp)
    8000118e:	6402                	ld	s0,0(sp)
    80001190:	0141                	addi	sp,sp,16
    80001192:	8082                	ret

0000000080001194 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001194:	1101                	addi	sp,sp,-32
    80001196:	ec06                	sd	ra,24(sp)
    80001198:	e822                	sd	s0,16(sp)
    8000119a:	e426                	sd	s1,8(sp)
    8000119c:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000119e:	961ff0ef          	jal	80000afe <kalloc>
    800011a2:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800011a4:	c509                	beqz	a0,800011ae <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800011a6:	6605                	lui	a2,0x1
    800011a8:	4581                	li	a1,0
    800011aa:	af9ff0ef          	jal	80000ca2 <memset>
  return pagetable;
}
    800011ae:	8526                	mv	a0,s1
    800011b0:	60e2                	ld	ra,24(sp)
    800011b2:	6442                	ld	s0,16(sp)
    800011b4:	64a2                	ld	s1,8(sp)
    800011b6:	6105                	addi	sp,sp,32
    800011b8:	8082                	ret

00000000800011ba <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011ba:	7139                	addi	sp,sp,-64
    800011bc:	fc06                	sd	ra,56(sp)
    800011be:	f822                	sd	s0,48(sp)
    800011c0:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011c2:	03459793          	slli	a5,a1,0x34
    800011c6:	e38d                	bnez	a5,800011e8 <uvmunmap+0x2e>
    800011c8:	f04a                	sd	s2,32(sp)
    800011ca:	ec4e                	sd	s3,24(sp)
    800011cc:	e852                	sd	s4,16(sp)
    800011ce:	e456                	sd	s5,8(sp)
    800011d0:	e05a                	sd	s6,0(sp)
    800011d2:	8a2a                	mv	s4,a0
    800011d4:	892e                	mv	s2,a1
    800011d6:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011d8:	0632                	slli	a2,a2,0xc
    800011da:	00b609b3          	add	s3,a2,a1
    800011de:	6b05                	lui	s6,0x1
    800011e0:	0535f963          	bgeu	a1,s3,80001232 <uvmunmap+0x78>
    800011e4:	f426                	sd	s1,40(sp)
    800011e6:	a015                	j	8000120a <uvmunmap+0x50>
    800011e8:	f426                	sd	s1,40(sp)
    800011ea:	f04a                	sd	s2,32(sp)
    800011ec:	ec4e                	sd	s3,24(sp)
    800011ee:	e852                	sd	s4,16(sp)
    800011f0:	e456                	sd	s5,8(sp)
    800011f2:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    800011f4:	00006517          	auipc	a0,0x6
    800011f8:	f2450513          	addi	a0,a0,-220 # 80007118 <etext+0x118>
    800011fc:	de4ff0ef          	jal	800007e0 <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001200:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001204:	995a                	add	s2,s2,s6
    80001206:	03397563          	bgeu	s2,s3,80001230 <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    8000120a:	4601                	li	a2,0
    8000120c:	85ca                	mv	a1,s2
    8000120e:	8552                	mv	a0,s4
    80001210:	d07ff0ef          	jal	80000f16 <walk>
    80001214:	84aa                	mv	s1,a0
    80001216:	d57d                	beqz	a0,80001204 <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    80001218:	611c                	ld	a5,0(a0)
    8000121a:	0017f713          	andi	a4,a5,1
    8000121e:	d37d                	beqz	a4,80001204 <uvmunmap+0x4a>
    if(do_free){
    80001220:	fe0a80e3          	beqz	s5,80001200 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    80001224:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    80001226:	00c79513          	slli	a0,a5,0xc
    8000122a:	ff2ff0ef          	jal	80000a1c <kfree>
    8000122e:	bfc9                	j	80001200 <uvmunmap+0x46>
    80001230:	74a2                	ld	s1,40(sp)
    80001232:	7902                	ld	s2,32(sp)
    80001234:	69e2                	ld	s3,24(sp)
    80001236:	6a42                	ld	s4,16(sp)
    80001238:	6aa2                	ld	s5,8(sp)
    8000123a:	6b02                	ld	s6,0(sp)
  }
}
    8000123c:	70e2                	ld	ra,56(sp)
    8000123e:	7442                	ld	s0,48(sp)
    80001240:	6121                	addi	sp,sp,64
    80001242:	8082                	ret

0000000080001244 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001244:	1101                	addi	sp,sp,-32
    80001246:	ec06                	sd	ra,24(sp)
    80001248:	e822                	sd	s0,16(sp)
    8000124a:	e426                	sd	s1,8(sp)
    8000124c:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000124e:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001250:	00b67d63          	bgeu	a2,a1,8000126a <uvmdealloc+0x26>
    80001254:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001256:	6785                	lui	a5,0x1
    80001258:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000125a:	00f60733          	add	a4,a2,a5
    8000125e:	76fd                	lui	a3,0xfffff
    80001260:	8f75                	and	a4,a4,a3
    80001262:	97ae                	add	a5,a5,a1
    80001264:	8ff5                	and	a5,a5,a3
    80001266:	00f76863          	bltu	a4,a5,80001276 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000126a:	8526                	mv	a0,s1
    8000126c:	60e2                	ld	ra,24(sp)
    8000126e:	6442                	ld	s0,16(sp)
    80001270:	64a2                	ld	s1,8(sp)
    80001272:	6105                	addi	sp,sp,32
    80001274:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001276:	8f99                	sub	a5,a5,a4
    80001278:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000127a:	4685                	li	a3,1
    8000127c:	0007861b          	sext.w	a2,a5
    80001280:	85ba                	mv	a1,a4
    80001282:	f39ff0ef          	jal	800011ba <uvmunmap>
    80001286:	b7d5                	j	8000126a <uvmdealloc+0x26>

0000000080001288 <uvmalloc>:
  if(newsz < oldsz)
    80001288:	08b66f63          	bltu	a2,a1,80001326 <uvmalloc+0x9e>
{
    8000128c:	7139                	addi	sp,sp,-64
    8000128e:	fc06                	sd	ra,56(sp)
    80001290:	f822                	sd	s0,48(sp)
    80001292:	ec4e                	sd	s3,24(sp)
    80001294:	e852                	sd	s4,16(sp)
    80001296:	e456                	sd	s5,8(sp)
    80001298:	0080                	addi	s0,sp,64
    8000129a:	8aaa                	mv	s5,a0
    8000129c:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000129e:	6785                	lui	a5,0x1
    800012a0:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012a2:	95be                	add	a1,a1,a5
    800012a4:	77fd                	lui	a5,0xfffff
    800012a6:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800012aa:	08c9f063          	bgeu	s3,a2,8000132a <uvmalloc+0xa2>
    800012ae:	f426                	sd	s1,40(sp)
    800012b0:	f04a                	sd	s2,32(sp)
    800012b2:	e05a                	sd	s6,0(sp)
    800012b4:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800012b6:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800012ba:	845ff0ef          	jal	80000afe <kalloc>
    800012be:	84aa                	mv	s1,a0
    if(mem == 0){
    800012c0:	c515                	beqz	a0,800012ec <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800012c2:	6605                	lui	a2,0x1
    800012c4:	4581                	li	a1,0
    800012c6:	9ddff0ef          	jal	80000ca2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800012ca:	875a                	mv	a4,s6
    800012cc:	86a6                	mv	a3,s1
    800012ce:	6605                	lui	a2,0x1
    800012d0:	85ca                	mv	a1,s2
    800012d2:	8556                	mv	a0,s5
    800012d4:	d1bff0ef          	jal	80000fee <mappages>
    800012d8:	e915                	bnez	a0,8000130c <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800012da:	6785                	lui	a5,0x1
    800012dc:	993e                	add	s2,s2,a5
    800012de:	fd496ee3          	bltu	s2,s4,800012ba <uvmalloc+0x32>
  return newsz;
    800012e2:	8552                	mv	a0,s4
    800012e4:	74a2                	ld	s1,40(sp)
    800012e6:	7902                	ld	s2,32(sp)
    800012e8:	6b02                	ld	s6,0(sp)
    800012ea:	a811                	j	800012fe <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800012ec:	864e                	mv	a2,s3
    800012ee:	85ca                	mv	a1,s2
    800012f0:	8556                	mv	a0,s5
    800012f2:	f53ff0ef          	jal	80001244 <uvmdealloc>
      return 0;
    800012f6:	4501                	li	a0,0
    800012f8:	74a2                	ld	s1,40(sp)
    800012fa:	7902                	ld	s2,32(sp)
    800012fc:	6b02                	ld	s6,0(sp)
}
    800012fe:	70e2                	ld	ra,56(sp)
    80001300:	7442                	ld	s0,48(sp)
    80001302:	69e2                	ld	s3,24(sp)
    80001304:	6a42                	ld	s4,16(sp)
    80001306:	6aa2                	ld	s5,8(sp)
    80001308:	6121                	addi	sp,sp,64
    8000130a:	8082                	ret
      kfree(mem);
    8000130c:	8526                	mv	a0,s1
    8000130e:	f0eff0ef          	jal	80000a1c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001312:	864e                	mv	a2,s3
    80001314:	85ca                	mv	a1,s2
    80001316:	8556                	mv	a0,s5
    80001318:	f2dff0ef          	jal	80001244 <uvmdealloc>
      return 0;
    8000131c:	4501                	li	a0,0
    8000131e:	74a2                	ld	s1,40(sp)
    80001320:	7902                	ld	s2,32(sp)
    80001322:	6b02                	ld	s6,0(sp)
    80001324:	bfe9                	j	800012fe <uvmalloc+0x76>
    return oldsz;
    80001326:	852e                	mv	a0,a1
}
    80001328:	8082                	ret
  return newsz;
    8000132a:	8532                	mv	a0,a2
    8000132c:	bfc9                	j	800012fe <uvmalloc+0x76>

000000008000132e <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000132e:	7179                	addi	sp,sp,-48
    80001330:	f406                	sd	ra,40(sp)
    80001332:	f022                	sd	s0,32(sp)
    80001334:	ec26                	sd	s1,24(sp)
    80001336:	e84a                	sd	s2,16(sp)
    80001338:	e44e                	sd	s3,8(sp)
    8000133a:	e052                	sd	s4,0(sp)
    8000133c:	1800                	addi	s0,sp,48
    8000133e:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001340:	84aa                	mv	s1,a0
    80001342:	6905                	lui	s2,0x1
    80001344:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001346:	4985                	li	s3,1
    80001348:	a819                	j	8000135e <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000134a:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000134c:	00c79513          	slli	a0,a5,0xc
    80001350:	fdfff0ef          	jal	8000132e <freewalk>
      pagetable[i] = 0;
    80001354:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001358:	04a1                	addi	s1,s1,8
    8000135a:	01248f63          	beq	s1,s2,80001378 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    8000135e:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001360:	00f7f713          	andi	a4,a5,15
    80001364:	ff3703e3          	beq	a4,s3,8000134a <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001368:	8b85                	andi	a5,a5,1
    8000136a:	d7fd                	beqz	a5,80001358 <freewalk+0x2a>
      panic("freewalk: leaf");
    8000136c:	00006517          	auipc	a0,0x6
    80001370:	dc450513          	addi	a0,a0,-572 # 80007130 <etext+0x130>
    80001374:	c6cff0ef          	jal	800007e0 <panic>
    }
  }
  kfree((void*)pagetable);
    80001378:	8552                	mv	a0,s4
    8000137a:	ea2ff0ef          	jal	80000a1c <kfree>
}
    8000137e:	70a2                	ld	ra,40(sp)
    80001380:	7402                	ld	s0,32(sp)
    80001382:	64e2                	ld	s1,24(sp)
    80001384:	6942                	ld	s2,16(sp)
    80001386:	69a2                	ld	s3,8(sp)
    80001388:	6a02                	ld	s4,0(sp)
    8000138a:	6145                	addi	sp,sp,48
    8000138c:	8082                	ret

000000008000138e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000138e:	1101                	addi	sp,sp,-32
    80001390:	ec06                	sd	ra,24(sp)
    80001392:	e822                	sd	s0,16(sp)
    80001394:	e426                	sd	s1,8(sp)
    80001396:	1000                	addi	s0,sp,32
    80001398:	84aa                	mv	s1,a0
  if(sz > 0)
    8000139a:	e989                	bnez	a1,800013ac <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000139c:	8526                	mv	a0,s1
    8000139e:	f91ff0ef          	jal	8000132e <freewalk>
}
    800013a2:	60e2                	ld	ra,24(sp)
    800013a4:	6442                	ld	s0,16(sp)
    800013a6:	64a2                	ld	s1,8(sp)
    800013a8:	6105                	addi	sp,sp,32
    800013aa:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800013ac:	6785                	lui	a5,0x1
    800013ae:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013b0:	95be                	add	a1,a1,a5
    800013b2:	4685                	li	a3,1
    800013b4:	00c5d613          	srli	a2,a1,0xc
    800013b8:	4581                	li	a1,0
    800013ba:	e01ff0ef          	jal	800011ba <uvmunmap>
    800013be:	bff9                	j	8000139c <uvmfree+0xe>

00000000800013c0 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800013c0:	ce49                	beqz	a2,8000145a <uvmcopy+0x9a>
{
    800013c2:	715d                	addi	sp,sp,-80
    800013c4:	e486                	sd	ra,72(sp)
    800013c6:	e0a2                	sd	s0,64(sp)
    800013c8:	fc26                	sd	s1,56(sp)
    800013ca:	f84a                	sd	s2,48(sp)
    800013cc:	f44e                	sd	s3,40(sp)
    800013ce:	f052                	sd	s4,32(sp)
    800013d0:	ec56                	sd	s5,24(sp)
    800013d2:	e85a                	sd	s6,16(sp)
    800013d4:	e45e                	sd	s7,8(sp)
    800013d6:	0880                	addi	s0,sp,80
    800013d8:	8aaa                	mv	s5,a0
    800013da:	8b2e                	mv	s6,a1
    800013dc:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800013de:	4481                	li	s1,0
    800013e0:	a029                	j	800013ea <uvmcopy+0x2a>
    800013e2:	6785                	lui	a5,0x1
    800013e4:	94be                	add	s1,s1,a5
    800013e6:	0544fe63          	bgeu	s1,s4,80001442 <uvmcopy+0x82>
    if((pte = walk(old, i, 0)) == 0)
    800013ea:	4601                	li	a2,0
    800013ec:	85a6                	mv	a1,s1
    800013ee:	8556                	mv	a0,s5
    800013f0:	b27ff0ef          	jal	80000f16 <walk>
    800013f4:	d57d                	beqz	a0,800013e2 <uvmcopy+0x22>
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
    800013f6:	6118                	ld	a4,0(a0)
    800013f8:	00177793          	andi	a5,a4,1
    800013fc:	d3fd                	beqz	a5,800013e2 <uvmcopy+0x22>
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    800013fe:	00a75593          	srli	a1,a4,0xa
    80001402:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001406:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    8000140a:	ef4ff0ef          	jal	80000afe <kalloc>
    8000140e:	89aa                	mv	s3,a0
    80001410:	c105                	beqz	a0,80001430 <uvmcopy+0x70>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001412:	6605                	lui	a2,0x1
    80001414:	85de                	mv	a1,s7
    80001416:	8e9ff0ef          	jal	80000cfe <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000141a:	874a                	mv	a4,s2
    8000141c:	86ce                	mv	a3,s3
    8000141e:	6605                	lui	a2,0x1
    80001420:	85a6                	mv	a1,s1
    80001422:	855a                	mv	a0,s6
    80001424:	bcbff0ef          	jal	80000fee <mappages>
    80001428:	dd4d                	beqz	a0,800013e2 <uvmcopy+0x22>
      kfree(mem);
    8000142a:	854e                	mv	a0,s3
    8000142c:	df0ff0ef          	jal	80000a1c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001430:	4685                	li	a3,1
    80001432:	00c4d613          	srli	a2,s1,0xc
    80001436:	4581                	li	a1,0
    80001438:	855a                	mv	a0,s6
    8000143a:	d81ff0ef          	jal	800011ba <uvmunmap>
  return -1;
    8000143e:	557d                	li	a0,-1
    80001440:	a011                	j	80001444 <uvmcopy+0x84>
  return 0;
    80001442:	4501                	li	a0,0
}
    80001444:	60a6                	ld	ra,72(sp)
    80001446:	6406                	ld	s0,64(sp)
    80001448:	74e2                	ld	s1,56(sp)
    8000144a:	7942                	ld	s2,48(sp)
    8000144c:	79a2                	ld	s3,40(sp)
    8000144e:	7a02                	ld	s4,32(sp)
    80001450:	6ae2                	ld	s5,24(sp)
    80001452:	6b42                	ld	s6,16(sp)
    80001454:	6ba2                	ld	s7,8(sp)
    80001456:	6161                	addi	sp,sp,80
    80001458:	8082                	ret
  return 0;
    8000145a:	4501                	li	a0,0
}
    8000145c:	8082                	ret

000000008000145e <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000145e:	1141                	addi	sp,sp,-16
    80001460:	e406                	sd	ra,8(sp)
    80001462:	e022                	sd	s0,0(sp)
    80001464:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001466:	4601                	li	a2,0
    80001468:	aafff0ef          	jal	80000f16 <walk>
  if(pte == 0)
    8000146c:	c901                	beqz	a0,8000147c <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000146e:	611c                	ld	a5,0(a0)
    80001470:	9bbd                	andi	a5,a5,-17
    80001472:	e11c                	sd	a5,0(a0)
}
    80001474:	60a2                	ld	ra,8(sp)
    80001476:	6402                	ld	s0,0(sp)
    80001478:	0141                	addi	sp,sp,16
    8000147a:	8082                	ret
    panic("uvmclear");
    8000147c:	00006517          	auipc	a0,0x6
    80001480:	cc450513          	addi	a0,a0,-828 # 80007140 <etext+0x140>
    80001484:	b5cff0ef          	jal	800007e0 <panic>

0000000080001488 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001488:	c6dd                	beqz	a3,80001536 <copyinstr+0xae>
{
    8000148a:	715d                	addi	sp,sp,-80
    8000148c:	e486                	sd	ra,72(sp)
    8000148e:	e0a2                	sd	s0,64(sp)
    80001490:	fc26                	sd	s1,56(sp)
    80001492:	f84a                	sd	s2,48(sp)
    80001494:	f44e                	sd	s3,40(sp)
    80001496:	f052                	sd	s4,32(sp)
    80001498:	ec56                	sd	s5,24(sp)
    8000149a:	e85a                	sd	s6,16(sp)
    8000149c:	e45e                	sd	s7,8(sp)
    8000149e:	0880                	addi	s0,sp,80
    800014a0:	8a2a                	mv	s4,a0
    800014a2:	8b2e                	mv	s6,a1
    800014a4:	8bb2                	mv	s7,a2
    800014a6:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800014a8:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800014aa:	6985                	lui	s3,0x1
    800014ac:	a825                	j	800014e4 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800014ae:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800014b2:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800014b4:	37fd                	addiw	a5,a5,-1
    800014b6:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800014ba:	60a6                	ld	ra,72(sp)
    800014bc:	6406                	ld	s0,64(sp)
    800014be:	74e2                	ld	s1,56(sp)
    800014c0:	7942                	ld	s2,48(sp)
    800014c2:	79a2                	ld	s3,40(sp)
    800014c4:	7a02                	ld	s4,32(sp)
    800014c6:	6ae2                	ld	s5,24(sp)
    800014c8:	6b42                	ld	s6,16(sp)
    800014ca:	6ba2                	ld	s7,8(sp)
    800014cc:	6161                	addi	sp,sp,80
    800014ce:	8082                	ret
    800014d0:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800014d4:	9742                	add	a4,a4,a6
      --max;
    800014d6:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    800014da:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    800014de:	04e58463          	beq	a1,a4,80001526 <copyinstr+0x9e>
{
    800014e2:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    800014e4:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800014e8:	85a6                	mv	a1,s1
    800014ea:	8552                	mv	a0,s4
    800014ec:	ac5ff0ef          	jal	80000fb0 <walkaddr>
    if(pa0 == 0)
    800014f0:	cd0d                	beqz	a0,8000152a <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800014f2:	417486b3          	sub	a3,s1,s7
    800014f6:	96ce                	add	a3,a3,s3
    if(n > max)
    800014f8:	00d97363          	bgeu	s2,a3,800014fe <copyinstr+0x76>
    800014fc:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    800014fe:	955e                	add	a0,a0,s7
    80001500:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001502:	c695                	beqz	a3,8000152e <copyinstr+0xa6>
    80001504:	87da                	mv	a5,s6
    80001506:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001508:	41650633          	sub	a2,a0,s6
    while(n > 0){
    8000150c:	96da                	add	a3,a3,s6
    8000150e:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001510:	00f60733          	add	a4,a2,a5
    80001514:	00074703          	lbu	a4,0(a4)
    80001518:	db59                	beqz	a4,800014ae <copyinstr+0x26>
        *dst = *p;
    8000151a:	00e78023          	sb	a4,0(a5)
      dst++;
    8000151e:	0785                	addi	a5,a5,1
    while(n > 0){
    80001520:	fed797e3          	bne	a5,a3,8000150e <copyinstr+0x86>
    80001524:	b775                	j	800014d0 <copyinstr+0x48>
    80001526:	4781                	li	a5,0
    80001528:	b771                	j	800014b4 <copyinstr+0x2c>
      return -1;
    8000152a:	557d                	li	a0,-1
    8000152c:	b779                	j	800014ba <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    8000152e:	6b85                	lui	s7,0x1
    80001530:	9ba6                	add	s7,s7,s1
    80001532:	87da                	mv	a5,s6
    80001534:	b77d                	j	800014e2 <copyinstr+0x5a>
  int got_null = 0;
    80001536:	4781                	li	a5,0
  if(got_null){
    80001538:	37fd                	addiw	a5,a5,-1
    8000153a:	0007851b          	sext.w	a0,a5
}
    8000153e:	8082                	ret

0000000080001540 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    80001540:	1141                	addi	sp,sp,-16
    80001542:	e406                	sd	ra,8(sp)
    80001544:	e022                	sd	s0,0(sp)
    80001546:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80001548:	4601                	li	a2,0
    8000154a:	9cdff0ef          	jal	80000f16 <walk>
  if (pte == 0) {
    8000154e:	c519                	beqz	a0,8000155c <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    80001550:	6108                	ld	a0,0(a0)
    80001552:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80001554:	60a2                	ld	ra,8(sp)
    80001556:	6402                	ld	s0,0(sp)
    80001558:	0141                	addi	sp,sp,16
    8000155a:	8082                	ret
    return 0;
    8000155c:	4501                	li	a0,0
    8000155e:	bfdd                	j	80001554 <ismapped+0x14>

0000000080001560 <vmfault>:
{
    80001560:	7179                	addi	sp,sp,-48
    80001562:	f406                	sd	ra,40(sp)
    80001564:	f022                	sd	s0,32(sp)
    80001566:	ec26                	sd	s1,24(sp)
    80001568:	e44e                	sd	s3,8(sp)
    8000156a:	1800                	addi	s0,sp,48
    8000156c:	89aa                	mv	s3,a0
    8000156e:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    80001570:	35e000ef          	jal	800018ce <myproc>
  if (va >= p->sz)
    80001574:	653c                	ld	a5,72(a0)
    80001576:	00f4ea63          	bltu	s1,a5,8000158a <vmfault+0x2a>
    return 0;
    8000157a:	4981                	li	s3,0
}
    8000157c:	854e                	mv	a0,s3
    8000157e:	70a2                	ld	ra,40(sp)
    80001580:	7402                	ld	s0,32(sp)
    80001582:	64e2                	ld	s1,24(sp)
    80001584:	69a2                	ld	s3,8(sp)
    80001586:	6145                	addi	sp,sp,48
    80001588:	8082                	ret
    8000158a:	e84a                	sd	s2,16(sp)
    8000158c:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    8000158e:	77fd                	lui	a5,0xfffff
    80001590:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    80001592:	85a6                	mv	a1,s1
    80001594:	854e                	mv	a0,s3
    80001596:	fabff0ef          	jal	80001540 <ismapped>
    return 0;
    8000159a:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    8000159c:	c119                	beqz	a0,800015a2 <vmfault+0x42>
    8000159e:	6942                	ld	s2,16(sp)
    800015a0:	bff1                	j	8000157c <vmfault+0x1c>
    800015a2:	e052                	sd	s4,0(sp)
  mem = (uint64) kalloc();
    800015a4:	d5aff0ef          	jal	80000afe <kalloc>
    800015a8:	8a2a                	mv	s4,a0
  if(mem == 0)
    800015aa:	c90d                	beqz	a0,800015dc <vmfault+0x7c>
  mem = (uint64) kalloc();
    800015ac:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    800015ae:	6605                	lui	a2,0x1
    800015b0:	4581                	li	a1,0
    800015b2:	ef0ff0ef          	jal	80000ca2 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    800015b6:	4759                	li	a4,22
    800015b8:	86d2                	mv	a3,s4
    800015ba:	6605                	lui	a2,0x1
    800015bc:	85a6                	mv	a1,s1
    800015be:	05093503          	ld	a0,80(s2)
    800015c2:	a2dff0ef          	jal	80000fee <mappages>
    800015c6:	e501                	bnez	a0,800015ce <vmfault+0x6e>
    800015c8:	6942                	ld	s2,16(sp)
    800015ca:	6a02                	ld	s4,0(sp)
    800015cc:	bf45                	j	8000157c <vmfault+0x1c>
    kfree((void *)mem);
    800015ce:	8552                	mv	a0,s4
    800015d0:	c4cff0ef          	jal	80000a1c <kfree>
    return 0;
    800015d4:	4981                	li	s3,0
    800015d6:	6942                	ld	s2,16(sp)
    800015d8:	6a02                	ld	s4,0(sp)
    800015da:	b74d                	j	8000157c <vmfault+0x1c>
    800015dc:	6942                	ld	s2,16(sp)
    800015de:	6a02                	ld	s4,0(sp)
    800015e0:	bf71                	j	8000157c <vmfault+0x1c>

00000000800015e2 <copyout>:
  while(len > 0){
    800015e2:	c2cd                	beqz	a3,80001684 <copyout+0xa2>
{
    800015e4:	711d                	addi	sp,sp,-96
    800015e6:	ec86                	sd	ra,88(sp)
    800015e8:	e8a2                	sd	s0,80(sp)
    800015ea:	e4a6                	sd	s1,72(sp)
    800015ec:	f852                	sd	s4,48(sp)
    800015ee:	f05a                	sd	s6,32(sp)
    800015f0:	ec5e                	sd	s7,24(sp)
    800015f2:	e862                	sd	s8,16(sp)
    800015f4:	1080                	addi	s0,sp,96
    800015f6:	8c2a                	mv	s8,a0
    800015f8:	8b2e                	mv	s6,a1
    800015fa:	8bb2                	mv	s7,a2
    800015fc:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    800015fe:	74fd                	lui	s1,0xfffff
    80001600:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001602:	57fd                	li	a5,-1
    80001604:	83e9                	srli	a5,a5,0x1a
    80001606:	0897e163          	bltu	a5,s1,80001688 <copyout+0xa6>
    8000160a:	e0ca                	sd	s2,64(sp)
    8000160c:	fc4e                	sd	s3,56(sp)
    8000160e:	f456                	sd	s5,40(sp)
    80001610:	e466                	sd	s9,8(sp)
    80001612:	e06a                	sd	s10,0(sp)
    80001614:	6d05                	lui	s10,0x1
    80001616:	8cbe                	mv	s9,a5
    80001618:	a015                	j	8000163c <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000161a:	409b0533          	sub	a0,s6,s1
    8000161e:	0009861b          	sext.w	a2,s3
    80001622:	85de                	mv	a1,s7
    80001624:	954a                	add	a0,a0,s2
    80001626:	ed8ff0ef          	jal	80000cfe <memmove>
    len -= n;
    8000162a:	413a0a33          	sub	s4,s4,s3
    src += n;
    8000162e:	9bce                	add	s7,s7,s3
  while(len > 0){
    80001630:	040a0363          	beqz	s4,80001676 <copyout+0x94>
    if(va0 >= MAXVA)
    80001634:	055cec63          	bltu	s9,s5,8000168c <copyout+0xaa>
    80001638:	84d6                	mv	s1,s5
    8000163a:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    8000163c:	85a6                	mv	a1,s1
    8000163e:	8562                	mv	a0,s8
    80001640:	971ff0ef          	jal	80000fb0 <walkaddr>
    80001644:	892a                	mv	s2,a0
    if(pa0 == 0) {
    80001646:	e901                	bnez	a0,80001656 <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001648:	4601                	li	a2,0
    8000164a:	85a6                	mv	a1,s1
    8000164c:	8562                	mv	a0,s8
    8000164e:	f13ff0ef          	jal	80001560 <vmfault>
    80001652:	892a                	mv	s2,a0
    80001654:	c139                	beqz	a0,8000169a <copyout+0xb8>
    pte = walk(pagetable, va0, 0);
    80001656:	4601                	li	a2,0
    80001658:	85a6                	mv	a1,s1
    8000165a:	8562                	mv	a0,s8
    8000165c:	8bbff0ef          	jal	80000f16 <walk>
    if((*pte & PTE_W) == 0)
    80001660:	611c                	ld	a5,0(a0)
    80001662:	8b91                	andi	a5,a5,4
    80001664:	c3b1                	beqz	a5,800016a8 <copyout+0xc6>
    n = PGSIZE - (dstva - va0);
    80001666:	01a48ab3          	add	s5,s1,s10
    8000166a:	416a89b3          	sub	s3,s5,s6
    if(n > len)
    8000166e:	fb3a76e3          	bgeu	s4,s3,8000161a <copyout+0x38>
    80001672:	89d2                	mv	s3,s4
    80001674:	b75d                	j	8000161a <copyout+0x38>
  return 0;
    80001676:	4501                	li	a0,0
    80001678:	6906                	ld	s2,64(sp)
    8000167a:	79e2                	ld	s3,56(sp)
    8000167c:	7aa2                	ld	s5,40(sp)
    8000167e:	6ca2                	ld	s9,8(sp)
    80001680:	6d02                	ld	s10,0(sp)
    80001682:	a80d                	j	800016b4 <copyout+0xd2>
    80001684:	4501                	li	a0,0
}
    80001686:	8082                	ret
      return -1;
    80001688:	557d                	li	a0,-1
    8000168a:	a02d                	j	800016b4 <copyout+0xd2>
    8000168c:	557d                	li	a0,-1
    8000168e:	6906                	ld	s2,64(sp)
    80001690:	79e2                	ld	s3,56(sp)
    80001692:	7aa2                	ld	s5,40(sp)
    80001694:	6ca2                	ld	s9,8(sp)
    80001696:	6d02                	ld	s10,0(sp)
    80001698:	a831                	j	800016b4 <copyout+0xd2>
        return -1;
    8000169a:	557d                	li	a0,-1
    8000169c:	6906                	ld	s2,64(sp)
    8000169e:	79e2                	ld	s3,56(sp)
    800016a0:	7aa2                	ld	s5,40(sp)
    800016a2:	6ca2                	ld	s9,8(sp)
    800016a4:	6d02                	ld	s10,0(sp)
    800016a6:	a039                	j	800016b4 <copyout+0xd2>
      return -1;
    800016a8:	557d                	li	a0,-1
    800016aa:	6906                	ld	s2,64(sp)
    800016ac:	79e2                	ld	s3,56(sp)
    800016ae:	7aa2                	ld	s5,40(sp)
    800016b0:	6ca2                	ld	s9,8(sp)
    800016b2:	6d02                	ld	s10,0(sp)
}
    800016b4:	60e6                	ld	ra,88(sp)
    800016b6:	6446                	ld	s0,80(sp)
    800016b8:	64a6                	ld	s1,72(sp)
    800016ba:	7a42                	ld	s4,48(sp)
    800016bc:	7b02                	ld	s6,32(sp)
    800016be:	6be2                	ld	s7,24(sp)
    800016c0:	6c42                	ld	s8,16(sp)
    800016c2:	6125                	addi	sp,sp,96
    800016c4:	8082                	ret

00000000800016c6 <copyin>:
  while(len > 0){
    800016c6:	c6c9                	beqz	a3,80001750 <copyin+0x8a>
{
    800016c8:	715d                	addi	sp,sp,-80
    800016ca:	e486                	sd	ra,72(sp)
    800016cc:	e0a2                	sd	s0,64(sp)
    800016ce:	fc26                	sd	s1,56(sp)
    800016d0:	f84a                	sd	s2,48(sp)
    800016d2:	f44e                	sd	s3,40(sp)
    800016d4:	f052                	sd	s4,32(sp)
    800016d6:	ec56                	sd	s5,24(sp)
    800016d8:	e85a                	sd	s6,16(sp)
    800016da:	e45e                	sd	s7,8(sp)
    800016dc:	e062                	sd	s8,0(sp)
    800016de:	0880                	addi	s0,sp,80
    800016e0:	8baa                	mv	s7,a0
    800016e2:	8aae                	mv	s5,a1
    800016e4:	8932                	mv	s2,a2
    800016e6:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    800016e8:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    800016ea:	6b05                	lui	s6,0x1
    800016ec:	a035                	j	80001718 <copyin+0x52>
    800016ee:	412984b3          	sub	s1,s3,s2
    800016f2:	94da                	add	s1,s1,s6
    if(n > len)
    800016f4:	009a7363          	bgeu	s4,s1,800016fa <copyin+0x34>
    800016f8:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800016fa:	413905b3          	sub	a1,s2,s3
    800016fe:	0004861b          	sext.w	a2,s1
    80001702:	95aa                	add	a1,a1,a0
    80001704:	8556                	mv	a0,s5
    80001706:	df8ff0ef          	jal	80000cfe <memmove>
    len -= n;
    8000170a:	409a0a33          	sub	s4,s4,s1
    dst += n;
    8000170e:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001710:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001714:	020a0163          	beqz	s4,80001736 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001718:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    8000171c:	85ce                	mv	a1,s3
    8000171e:	855e                	mv	a0,s7
    80001720:	891ff0ef          	jal	80000fb0 <walkaddr>
    if(pa0 == 0) {
    80001724:	f569                	bnez	a0,800016ee <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001726:	4601                	li	a2,0
    80001728:	85ce                	mv	a1,s3
    8000172a:	855e                	mv	a0,s7
    8000172c:	e35ff0ef          	jal	80001560 <vmfault>
    80001730:	fd5d                	bnez	a0,800016ee <copyin+0x28>
        return -1;
    80001732:	557d                	li	a0,-1
    80001734:	a011                	j	80001738 <copyin+0x72>
  return 0;
    80001736:	4501                	li	a0,0
}
    80001738:	60a6                	ld	ra,72(sp)
    8000173a:	6406                	ld	s0,64(sp)
    8000173c:	74e2                	ld	s1,56(sp)
    8000173e:	7942                	ld	s2,48(sp)
    80001740:	79a2                	ld	s3,40(sp)
    80001742:	7a02                	ld	s4,32(sp)
    80001744:	6ae2                	ld	s5,24(sp)
    80001746:	6b42                	ld	s6,16(sp)
    80001748:	6ba2                	ld	s7,8(sp)
    8000174a:	6c02                	ld	s8,0(sp)
    8000174c:	6161                	addi	sp,sp,80
    8000174e:	8082                	ret
  return 0;
    80001750:	4501                	li	a0,0
}
    80001752:	8082                	ret

0000000080001754 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001754:	7139                	addi	sp,sp,-64
    80001756:	fc06                	sd	ra,56(sp)
    80001758:	f822                	sd	s0,48(sp)
    8000175a:	f426                	sd	s1,40(sp)
    8000175c:	f04a                	sd	s2,32(sp)
    8000175e:	ec4e                	sd	s3,24(sp)
    80001760:	e852                	sd	s4,16(sp)
    80001762:	e456                	sd	s5,8(sp)
    80001764:	e05a                	sd	s6,0(sp)
    80001766:	0080                	addi	s0,sp,64
    80001768:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000176a:	00011497          	auipc	s1,0x11
    8000176e:	28e48493          	addi	s1,s1,654 # 800129f8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001772:	8b26                	mv	s6,s1
    80001774:	ff4df937          	lui	s2,0xff4df
    80001778:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bafe5>
    8000177c:	0936                	slli	s2,s2,0xd
    8000177e:	6f590913          	addi	s2,s2,1781
    80001782:	0936                	slli	s2,s2,0xd
    80001784:	bd390913          	addi	s2,s2,-1069
    80001788:	0932                	slli	s2,s2,0xc
    8000178a:	7a790913          	addi	s2,s2,1959
    8000178e:	040009b7          	lui	s3,0x4000
    80001792:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001794:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001796:	00017a97          	auipc	s5,0x17
    8000179a:	e62a8a93          	addi	s5,s5,-414 # 800185f8 <tickslock>
    char *pa = kalloc();
    8000179e:	b60ff0ef          	jal	80000afe <kalloc>
    800017a2:	862a                	mv	a2,a0
    if(pa == 0)
    800017a4:	cd15                	beqz	a0,800017e0 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800017a6:	416485b3          	sub	a1,s1,s6
    800017aa:	8591                	srai	a1,a1,0x4
    800017ac:	032585b3          	mul	a1,a1,s2
    800017b0:	2585                	addiw	a1,a1,1
    800017b2:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017b6:	4719                	li	a4,6
    800017b8:	6685                	lui	a3,0x1
    800017ba:	40b985b3          	sub	a1,s3,a1
    800017be:	8552                	mv	a0,s4
    800017c0:	8dfff0ef          	jal	8000109e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017c4:	17048493          	addi	s1,s1,368
    800017c8:	fd549be3          	bne	s1,s5,8000179e <proc_mapstacks+0x4a>
  }
}
    800017cc:	70e2                	ld	ra,56(sp)
    800017ce:	7442                	ld	s0,48(sp)
    800017d0:	74a2                	ld	s1,40(sp)
    800017d2:	7902                	ld	s2,32(sp)
    800017d4:	69e2                	ld	s3,24(sp)
    800017d6:	6a42                	ld	s4,16(sp)
    800017d8:	6aa2                	ld	s5,8(sp)
    800017da:	6b02                	ld	s6,0(sp)
    800017dc:	6121                	addi	sp,sp,64
    800017de:	8082                	ret
      panic("kalloc");
    800017e0:	00006517          	auipc	a0,0x6
    800017e4:	97050513          	addi	a0,a0,-1680 # 80007150 <etext+0x150>
    800017e8:	ff9fe0ef          	jal	800007e0 <panic>

00000000800017ec <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017ec:	7139                	addi	sp,sp,-64
    800017ee:	fc06                	sd	ra,56(sp)
    800017f0:	f822                	sd	s0,48(sp)
    800017f2:	f426                	sd	s1,40(sp)
    800017f4:	f04a                	sd	s2,32(sp)
    800017f6:	ec4e                	sd	s3,24(sp)
    800017f8:	e852                	sd	s4,16(sp)
    800017fa:	e456                	sd	s5,8(sp)
    800017fc:	e05a                	sd	s6,0(sp)
    800017fe:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001800:	00006597          	auipc	a1,0x6
    80001804:	95858593          	addi	a1,a1,-1704 # 80007158 <etext+0x158>
    80001808:	00011517          	auipc	a0,0x11
    8000180c:	dc050513          	addi	a0,a0,-576 # 800125c8 <pid_lock>
    80001810:	b3eff0ef          	jal	80000b4e <initlock>
  initlock(&wait_lock, "wait_lock");
    80001814:	00006597          	auipc	a1,0x6
    80001818:	94c58593          	addi	a1,a1,-1716 # 80007160 <etext+0x160>
    8000181c:	00011517          	auipc	a0,0x11
    80001820:	dc450513          	addi	a0,a0,-572 # 800125e0 <wait_lock>
    80001824:	b2aff0ef          	jal	80000b4e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001828:	00011497          	auipc	s1,0x11
    8000182c:	1d048493          	addi	s1,s1,464 # 800129f8 <proc>
      initlock(&p->lock, "proc");
    80001830:	00006b17          	auipc	s6,0x6
    80001834:	940b0b13          	addi	s6,s6,-1728 # 80007170 <etext+0x170>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001838:	8aa6                	mv	s5,s1
    8000183a:	ff4df937          	lui	s2,0xff4df
    8000183e:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bafe5>
    80001842:	0936                	slli	s2,s2,0xd
    80001844:	6f590913          	addi	s2,s2,1781
    80001848:	0936                	slli	s2,s2,0xd
    8000184a:	bd390913          	addi	s2,s2,-1069
    8000184e:	0932                	slli	s2,s2,0xc
    80001850:	7a790913          	addi	s2,s2,1959
    80001854:	040009b7          	lui	s3,0x4000
    80001858:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000185a:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000185c:	00017a17          	auipc	s4,0x17
    80001860:	d9ca0a13          	addi	s4,s4,-612 # 800185f8 <tickslock>
      initlock(&p->lock, "proc");
    80001864:	85da                	mv	a1,s6
    80001866:	8526                	mv	a0,s1
    80001868:	ae6ff0ef          	jal	80000b4e <initlock>
      p->state = UNUSED;
    8000186c:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001870:	415487b3          	sub	a5,s1,s5
    80001874:	8791                	srai	a5,a5,0x4
    80001876:	032787b3          	mul	a5,a5,s2
    8000187a:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffdb629>
    8000187c:	00d7979b          	slliw	a5,a5,0xd
    80001880:	40f987b3          	sub	a5,s3,a5
    80001884:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001886:	17048493          	addi	s1,s1,368
    8000188a:	fd449de3          	bne	s1,s4,80001864 <procinit+0x78>
  }
}
    8000188e:	70e2                	ld	ra,56(sp)
    80001890:	7442                	ld	s0,48(sp)
    80001892:	74a2                	ld	s1,40(sp)
    80001894:	7902                	ld	s2,32(sp)
    80001896:	69e2                	ld	s3,24(sp)
    80001898:	6a42                	ld	s4,16(sp)
    8000189a:	6aa2                	ld	s5,8(sp)
    8000189c:	6b02                	ld	s6,0(sp)
    8000189e:	6121                	addi	sp,sp,64
    800018a0:	8082                	ret

00000000800018a2 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018a2:	1141                	addi	sp,sp,-16
    800018a4:	e422                	sd	s0,8(sp)
    800018a6:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018a8:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018aa:	2501                	sext.w	a0,a0
    800018ac:	6422                	ld	s0,8(sp)
    800018ae:	0141                	addi	sp,sp,16
    800018b0:	8082                	ret

00000000800018b2 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018b2:	1141                	addi	sp,sp,-16
    800018b4:	e422                	sd	s0,8(sp)
    800018b6:	0800                	addi	s0,sp,16
    800018b8:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018ba:	2781                	sext.w	a5,a5
    800018bc:	079e                	slli	a5,a5,0x7
  return c;
}
    800018be:	00011517          	auipc	a0,0x11
    800018c2:	d3a50513          	addi	a0,a0,-710 # 800125f8 <cpus>
    800018c6:	953e                	add	a0,a0,a5
    800018c8:	6422                	ld	s0,8(sp)
    800018ca:	0141                	addi	sp,sp,16
    800018cc:	8082                	ret

00000000800018ce <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800018ce:	1101                	addi	sp,sp,-32
    800018d0:	ec06                	sd	ra,24(sp)
    800018d2:	e822                	sd	s0,16(sp)
    800018d4:	e426                	sd	s1,8(sp)
    800018d6:	1000                	addi	s0,sp,32
  push_off();
    800018d8:	ab6ff0ef          	jal	80000b8e <push_off>
    800018dc:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018de:	2781                	sext.w	a5,a5
    800018e0:	079e                	slli	a5,a5,0x7
    800018e2:	00011717          	auipc	a4,0x11
    800018e6:	ce670713          	addi	a4,a4,-794 # 800125c8 <pid_lock>
    800018ea:	97ba                	add	a5,a5,a4
    800018ec:	7b84                	ld	s1,48(a5)
  pop_off();
    800018ee:	b24ff0ef          	jal	80000c12 <pop_off>
  return p;
}
    800018f2:	8526                	mv	a0,s1
    800018f4:	60e2                	ld	ra,24(sp)
    800018f6:	6442                	ld	s0,16(sp)
    800018f8:	64a2                	ld	s1,8(sp)
    800018fa:	6105                	addi	sp,sp,32
    800018fc:	8082                	ret

00000000800018fe <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800018fe:	7179                	addi	sp,sp,-48
    80001900:	f406                	sd	ra,40(sp)
    80001902:	f022                	sd	s0,32(sp)
    80001904:	ec26                	sd	s1,24(sp)
    80001906:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001908:	fc7ff0ef          	jal	800018ce <myproc>
    8000190c:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    8000190e:	b58ff0ef          	jal	80000c66 <release>

  if (first) {
    80001912:	00009797          	auipc	a5,0x9
    80001916:	b5e7a783          	lw	a5,-1186(a5) # 8000a470 <first.1>
    8000191a:	cf8d                	beqz	a5,80001954 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    8000191c:	4505                	li	a0,1
    8000191e:	573010ef          	jal	80003690 <fsinit>

    first = 0;
    80001922:	00009797          	auipc	a5,0x9
    80001926:	b407a723          	sw	zero,-1202(a5) # 8000a470 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    8000192a:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    8000192e:	00006517          	auipc	a0,0x6
    80001932:	84a50513          	addi	a0,a0,-1974 # 80007178 <etext+0x178>
    80001936:	fca43823          	sd	a0,-48(s0)
    8000193a:	fc043c23          	sd	zero,-40(s0)
    8000193e:	fd040593          	addi	a1,s0,-48
    80001942:	64f020ef          	jal	80004790 <kexec>
    80001946:	6cbc                	ld	a5,88(s1)
    80001948:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    8000194a:	6cbc                	ld	a5,88(s1)
    8000194c:	7bb8                	ld	a4,112(a5)
    8000194e:	57fd                	li	a5,-1
    80001950:	02f70d63          	beq	a4,a5,8000198a <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001954:	36b000ef          	jal	800024be <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001958:	68a8                	ld	a0,80(s1)
    8000195a:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000195c:	04000737          	lui	a4,0x4000
    80001960:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001962:	0732                	slli	a4,a4,0xc
    80001964:	00004797          	auipc	a5,0x4
    80001968:	73878793          	addi	a5,a5,1848 # 8000609c <userret>
    8000196c:	00004697          	auipc	a3,0x4
    80001970:	69468693          	addi	a3,a3,1684 # 80006000 <_trampoline>
    80001974:	8f95                	sub	a5,a5,a3
    80001976:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001978:	577d                	li	a4,-1
    8000197a:	177e                	slli	a4,a4,0x3f
    8000197c:	8d59                	or	a0,a0,a4
    8000197e:	9782                	jalr	a5
}
    80001980:	70a2                	ld	ra,40(sp)
    80001982:	7402                	ld	s0,32(sp)
    80001984:	64e2                	ld	s1,24(sp)
    80001986:	6145                	addi	sp,sp,48
    80001988:	8082                	ret
      panic("exec");
    8000198a:	00005517          	auipc	a0,0x5
    8000198e:	7f650513          	addi	a0,a0,2038 # 80007180 <etext+0x180>
    80001992:	e4ffe0ef          	jal	800007e0 <panic>

0000000080001996 <allocpid>:
{
    80001996:	1101                	addi	sp,sp,-32
    80001998:	ec06                	sd	ra,24(sp)
    8000199a:	e822                	sd	s0,16(sp)
    8000199c:	e426                	sd	s1,8(sp)
    8000199e:	e04a                	sd	s2,0(sp)
    800019a0:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800019a2:	00011917          	auipc	s2,0x11
    800019a6:	c2690913          	addi	s2,s2,-986 # 800125c8 <pid_lock>
    800019aa:	854a                	mv	a0,s2
    800019ac:	a22ff0ef          	jal	80000bce <acquire>
  pid = nextpid;
    800019b0:	00009797          	auipc	a5,0x9
    800019b4:	ac478793          	addi	a5,a5,-1340 # 8000a474 <nextpid>
    800019b8:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800019ba:	0014871b          	addiw	a4,s1,1
    800019be:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800019c0:	854a                	mv	a0,s2
    800019c2:	aa4ff0ef          	jal	80000c66 <release>
}
    800019c6:	8526                	mv	a0,s1
    800019c8:	60e2                	ld	ra,24(sp)
    800019ca:	6442                	ld	s0,16(sp)
    800019cc:	64a2                	ld	s1,8(sp)
    800019ce:	6902                	ld	s2,0(sp)
    800019d0:	6105                	addi	sp,sp,32
    800019d2:	8082                	ret

00000000800019d4 <proc_pagetable>:
{
    800019d4:	1101                	addi	sp,sp,-32
    800019d6:	ec06                	sd	ra,24(sp)
    800019d8:	e822                	sd	s0,16(sp)
    800019da:	e426                	sd	s1,8(sp)
    800019dc:	e04a                	sd	s2,0(sp)
    800019de:	1000                	addi	s0,sp,32
    800019e0:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800019e2:	fb2ff0ef          	jal	80001194 <uvmcreate>
    800019e6:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800019e8:	cd05                	beqz	a0,80001a20 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    800019ea:	4729                	li	a4,10
    800019ec:	00004697          	auipc	a3,0x4
    800019f0:	61468693          	addi	a3,a3,1556 # 80006000 <_trampoline>
    800019f4:	6605                	lui	a2,0x1
    800019f6:	040005b7          	lui	a1,0x4000
    800019fa:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019fc:	05b2                	slli	a1,a1,0xc
    800019fe:	df0ff0ef          	jal	80000fee <mappages>
    80001a02:	02054663          	bltz	a0,80001a2e <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a06:	4719                	li	a4,6
    80001a08:	05893683          	ld	a3,88(s2)
    80001a0c:	6605                	lui	a2,0x1
    80001a0e:	020005b7          	lui	a1,0x2000
    80001a12:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a14:	05b6                	slli	a1,a1,0xd
    80001a16:	8526                	mv	a0,s1
    80001a18:	dd6ff0ef          	jal	80000fee <mappages>
    80001a1c:	00054f63          	bltz	a0,80001a3a <proc_pagetable+0x66>
}
    80001a20:	8526                	mv	a0,s1
    80001a22:	60e2                	ld	ra,24(sp)
    80001a24:	6442                	ld	s0,16(sp)
    80001a26:	64a2                	ld	s1,8(sp)
    80001a28:	6902                	ld	s2,0(sp)
    80001a2a:	6105                	addi	sp,sp,32
    80001a2c:	8082                	ret
    uvmfree(pagetable, 0);
    80001a2e:	4581                	li	a1,0
    80001a30:	8526                	mv	a0,s1
    80001a32:	95dff0ef          	jal	8000138e <uvmfree>
    return 0;
    80001a36:	4481                	li	s1,0
    80001a38:	b7e5                	j	80001a20 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a3a:	4681                	li	a3,0
    80001a3c:	4605                	li	a2,1
    80001a3e:	040005b7          	lui	a1,0x4000
    80001a42:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a44:	05b2                	slli	a1,a1,0xc
    80001a46:	8526                	mv	a0,s1
    80001a48:	f72ff0ef          	jal	800011ba <uvmunmap>
    uvmfree(pagetable, 0);
    80001a4c:	4581                	li	a1,0
    80001a4e:	8526                	mv	a0,s1
    80001a50:	93fff0ef          	jal	8000138e <uvmfree>
    return 0;
    80001a54:	4481                	li	s1,0
    80001a56:	b7e9                	j	80001a20 <proc_pagetable+0x4c>

0000000080001a58 <proc_freepagetable>:
{
    80001a58:	1101                	addi	sp,sp,-32
    80001a5a:	ec06                	sd	ra,24(sp)
    80001a5c:	e822                	sd	s0,16(sp)
    80001a5e:	e426                	sd	s1,8(sp)
    80001a60:	e04a                	sd	s2,0(sp)
    80001a62:	1000                	addi	s0,sp,32
    80001a64:	84aa                	mv	s1,a0
    80001a66:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a68:	4681                	li	a3,0
    80001a6a:	4605                	li	a2,1
    80001a6c:	040005b7          	lui	a1,0x4000
    80001a70:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a72:	05b2                	slli	a1,a1,0xc
    80001a74:	f46ff0ef          	jal	800011ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a78:	4681                	li	a3,0
    80001a7a:	4605                	li	a2,1
    80001a7c:	020005b7          	lui	a1,0x2000
    80001a80:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a82:	05b6                	slli	a1,a1,0xd
    80001a84:	8526                	mv	a0,s1
    80001a86:	f34ff0ef          	jal	800011ba <uvmunmap>
  uvmfree(pagetable, sz);
    80001a8a:	85ca                	mv	a1,s2
    80001a8c:	8526                	mv	a0,s1
    80001a8e:	901ff0ef          	jal	8000138e <uvmfree>
}
    80001a92:	60e2                	ld	ra,24(sp)
    80001a94:	6442                	ld	s0,16(sp)
    80001a96:	64a2                	ld	s1,8(sp)
    80001a98:	6902                	ld	s2,0(sp)
    80001a9a:	6105                	addi	sp,sp,32
    80001a9c:	8082                	ret

0000000080001a9e <freeproc>:
{
    80001a9e:	1101                	addi	sp,sp,-32
    80001aa0:	ec06                	sd	ra,24(sp)
    80001aa2:	e822                	sd	s0,16(sp)
    80001aa4:	e426                	sd	s1,8(sp)
    80001aa6:	1000                	addi	s0,sp,32
    80001aa8:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001aaa:	6d28                	ld	a0,88(a0)
    80001aac:	c119                	beqz	a0,80001ab2 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001aae:	f6ffe0ef          	jal	80000a1c <kfree>
  p->trapframe = 0;
    80001ab2:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001ab6:	68a8                	ld	a0,80(s1)
    80001ab8:	c501                	beqz	a0,80001ac0 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001aba:	64ac                	ld	a1,72(s1)
    80001abc:	f9dff0ef          	jal	80001a58 <proc_freepagetable>
  p->pagetable = 0;
    80001ac0:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001ac4:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001ac8:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001acc:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001ad0:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001ad4:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ad8:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001adc:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ae0:	0004ac23          	sw	zero,24(s1)
}
    80001ae4:	60e2                	ld	ra,24(sp)
    80001ae6:	6442                	ld	s0,16(sp)
    80001ae8:	64a2                	ld	s1,8(sp)
    80001aea:	6105                	addi	sp,sp,32
    80001aec:	8082                	ret

0000000080001aee <allocproc>:
{
    80001aee:	1101                	addi	sp,sp,-32
    80001af0:	ec06                	sd	ra,24(sp)
    80001af2:	e822                	sd	s0,16(sp)
    80001af4:	e426                	sd	s1,8(sp)
    80001af6:	e04a                	sd	s2,0(sp)
    80001af8:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001afa:	00011497          	auipc	s1,0x11
    80001afe:	efe48493          	addi	s1,s1,-258 # 800129f8 <proc>
    80001b02:	00017917          	auipc	s2,0x17
    80001b06:	af690913          	addi	s2,s2,-1290 # 800185f8 <tickslock>
    acquire(&p->lock);
    80001b0a:	8526                	mv	a0,s1
    80001b0c:	8c2ff0ef          	jal	80000bce <acquire>
    if(p->state == UNUSED) {
    80001b10:	4c9c                	lw	a5,24(s1)
    80001b12:	cb91                	beqz	a5,80001b26 <allocproc+0x38>
      release(&p->lock);
    80001b14:	8526                	mv	a0,s1
    80001b16:	950ff0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b1a:	17048493          	addi	s1,s1,368
    80001b1e:	ff2496e3          	bne	s1,s2,80001b0a <allocproc+0x1c>
  return 0;
    80001b22:	4481                	li	s1,0
    80001b24:	a089                	j	80001b66 <allocproc+0x78>
  p->pid = allocpid();
    80001b26:	e71ff0ef          	jal	80001996 <allocpid>
    80001b2a:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b2c:	4785                	li	a5,1
    80001b2e:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001b30:	fcffe0ef          	jal	80000afe <kalloc>
    80001b34:	892a                	mv	s2,a0
    80001b36:	eca8                	sd	a0,88(s1)
    80001b38:	cd15                	beqz	a0,80001b74 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001b3a:	8526                	mv	a0,s1
    80001b3c:	e99ff0ef          	jal	800019d4 <proc_pagetable>
    80001b40:	892a                	mv	s2,a0
    80001b42:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001b44:	c121                	beqz	a0,80001b84 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001b46:	07000613          	li	a2,112
    80001b4a:	4581                	li	a1,0
    80001b4c:	06048513          	addi	a0,s1,96
    80001b50:	952ff0ef          	jal	80000ca2 <memset>
  p->context.ra = (uint64)forkret;
    80001b54:	00000797          	auipc	a5,0x0
    80001b58:	daa78793          	addi	a5,a5,-598 # 800018fe <forkret>
    80001b5c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b5e:	60bc                	ld	a5,64(s1)
    80001b60:	6705                	lui	a4,0x1
    80001b62:	97ba                	add	a5,a5,a4
    80001b64:	f4bc                	sd	a5,104(s1)
}
    80001b66:	8526                	mv	a0,s1
    80001b68:	60e2                	ld	ra,24(sp)
    80001b6a:	6442                	ld	s0,16(sp)
    80001b6c:	64a2                	ld	s1,8(sp)
    80001b6e:	6902                	ld	s2,0(sp)
    80001b70:	6105                	addi	sp,sp,32
    80001b72:	8082                	ret
    freeproc(p);
    80001b74:	8526                	mv	a0,s1
    80001b76:	f29ff0ef          	jal	80001a9e <freeproc>
    release(&p->lock);
    80001b7a:	8526                	mv	a0,s1
    80001b7c:	8eaff0ef          	jal	80000c66 <release>
    return 0;
    80001b80:	84ca                	mv	s1,s2
    80001b82:	b7d5                	j	80001b66 <allocproc+0x78>
    freeproc(p);
    80001b84:	8526                	mv	a0,s1
    80001b86:	f19ff0ef          	jal	80001a9e <freeproc>
    release(&p->lock);
    80001b8a:	8526                	mv	a0,s1
    80001b8c:	8daff0ef          	jal	80000c66 <release>
    return 0;
    80001b90:	84ca                	mv	s1,s2
    80001b92:	bfd1                	j	80001b66 <allocproc+0x78>

0000000080001b94 <userinit>:
{
    80001b94:	1101                	addi	sp,sp,-32
    80001b96:	ec06                	sd	ra,24(sp)
    80001b98:	e822                	sd	s0,16(sp)
    80001b9a:	e426                	sd	s1,8(sp)
    80001b9c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b9e:	f51ff0ef          	jal	80001aee <allocproc>
    80001ba2:	84aa                	mv	s1,a0
  initproc = p;
    80001ba4:	00009797          	auipc	a5,0x9
    80001ba8:	90a7be23          	sd	a0,-1764(a5) # 8000a4c0 <initproc>
  p->cwd = namei("/");
    80001bac:	00005517          	auipc	a0,0x5
    80001bb0:	5dc50513          	addi	a0,a0,1500 # 80007188 <etext+0x188>
    80001bb4:	7ff010ef          	jal	80003bb2 <namei>
    80001bb8:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bbc:	478d                	li	a5,3
    80001bbe:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bc0:	8526                	mv	a0,s1
    80001bc2:	8a4ff0ef          	jal	80000c66 <release>
}
    80001bc6:	60e2                	ld	ra,24(sp)
    80001bc8:	6442                	ld	s0,16(sp)
    80001bca:	64a2                	ld	s1,8(sp)
    80001bcc:	6105                	addi	sp,sp,32
    80001bce:	8082                	ret

0000000080001bd0 <growproc>:
{
    80001bd0:	1101                	addi	sp,sp,-32
    80001bd2:	ec06                	sd	ra,24(sp)
    80001bd4:	e822                	sd	s0,16(sp)
    80001bd6:	e426                	sd	s1,8(sp)
    80001bd8:	e04a                	sd	s2,0(sp)
    80001bda:	1000                	addi	s0,sp,32
    80001bdc:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001bde:	cf1ff0ef          	jal	800018ce <myproc>
    80001be2:	84aa                	mv	s1,a0
  sz = p->sz;
    80001be4:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001be6:	01204c63          	bgtz	s2,80001bfe <growproc+0x2e>
  } else if(n < 0){
    80001bea:	02094463          	bltz	s2,80001c12 <growproc+0x42>
  p->sz = sz;
    80001bee:	e4ac                	sd	a1,72(s1)
  return 0;
    80001bf0:	4501                	li	a0,0
}
    80001bf2:	60e2                	ld	ra,24(sp)
    80001bf4:	6442                	ld	s0,16(sp)
    80001bf6:	64a2                	ld	s1,8(sp)
    80001bf8:	6902                	ld	s2,0(sp)
    80001bfa:	6105                	addi	sp,sp,32
    80001bfc:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001bfe:	4691                	li	a3,4
    80001c00:	00b90633          	add	a2,s2,a1
    80001c04:	6928                	ld	a0,80(a0)
    80001c06:	e82ff0ef          	jal	80001288 <uvmalloc>
    80001c0a:	85aa                	mv	a1,a0
    80001c0c:	f16d                	bnez	a0,80001bee <growproc+0x1e>
      return -1;
    80001c0e:	557d                	li	a0,-1
    80001c10:	b7cd                	j	80001bf2 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c12:	00b90633          	add	a2,s2,a1
    80001c16:	6928                	ld	a0,80(a0)
    80001c18:	e2cff0ef          	jal	80001244 <uvmdealloc>
    80001c1c:	85aa                	mv	a1,a0
    80001c1e:	bfc1                	j	80001bee <growproc+0x1e>

0000000080001c20 <kfork>:
{
    80001c20:	7139                	addi	sp,sp,-64
    80001c22:	fc06                	sd	ra,56(sp)
    80001c24:	f822                	sd	s0,48(sp)
    80001c26:	f04a                	sd	s2,32(sp)
    80001c28:	e456                	sd	s5,8(sp)
    80001c2a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c2c:	ca3ff0ef          	jal	800018ce <myproc>
    80001c30:	8aaa                	mv	s5,a0
  p->nice = 20;
    80001c32:	47d1                	li	a5,20
    80001c34:	16f52623          	sw	a5,364(a0)
  if((np = allocproc()) == 0){
    80001c38:	eb7ff0ef          	jal	80001aee <allocproc>
    80001c3c:	0e050e63          	beqz	a0,80001d38 <kfork+0x118>
    80001c40:	ec4e                	sd	s3,24(sp)
    80001c42:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c44:	048ab603          	ld	a2,72(s5)
    80001c48:	692c                	ld	a1,80(a0)
    80001c4a:	050ab503          	ld	a0,80(s5)
    80001c4e:	f72ff0ef          	jal	800013c0 <uvmcopy>
    80001c52:	04054e63          	bltz	a0,80001cae <kfork+0x8e>
    80001c56:	f426                	sd	s1,40(sp)
    80001c58:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001c5a:	048ab783          	ld	a5,72(s5)
    80001c5e:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001c62:	058ab683          	ld	a3,88(s5)
    80001c66:	87b6                	mv	a5,a3
    80001c68:	0589b703          	ld	a4,88(s3)
    80001c6c:	12068693          	addi	a3,a3,288
    80001c70:	0007b803          	ld	a6,0(a5)
    80001c74:	6788                	ld	a0,8(a5)
    80001c76:	6b8c                	ld	a1,16(a5)
    80001c78:	6f90                	ld	a2,24(a5)
    80001c7a:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001c7e:	e708                	sd	a0,8(a4)
    80001c80:	eb0c                	sd	a1,16(a4)
    80001c82:	ef10                	sd	a2,24(a4)
    80001c84:	02078793          	addi	a5,a5,32
    80001c88:	02070713          	addi	a4,a4,32
    80001c8c:	fed792e3          	bne	a5,a3,80001c70 <kfork+0x50>
  np->tracemask = p->tracemask;
    80001c90:	168aa783          	lw	a5,360(s5)
    80001c94:	16f9a423          	sw	a5,360(s3)
  np->trapframe->a0 = 0;
    80001c98:	0589b783          	ld	a5,88(s3)
    80001c9c:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001ca0:	0d0a8493          	addi	s1,s5,208
    80001ca4:	0d098913          	addi	s2,s3,208
    80001ca8:	150a8a13          	addi	s4,s5,336
    80001cac:	a831                	j	80001cc8 <kfork+0xa8>
    freeproc(np);
    80001cae:	854e                	mv	a0,s3
    80001cb0:	defff0ef          	jal	80001a9e <freeproc>
    release(&np->lock);
    80001cb4:	854e                	mv	a0,s3
    80001cb6:	fb1fe0ef          	jal	80000c66 <release>
    return -1;
    80001cba:	597d                	li	s2,-1
    80001cbc:	69e2                	ld	s3,24(sp)
    80001cbe:	a0b5                	j	80001d2a <kfork+0x10a>
  for(i = 0; i < NOFILE; i++)
    80001cc0:	04a1                	addi	s1,s1,8
    80001cc2:	0921                	addi	s2,s2,8
    80001cc4:	01448963          	beq	s1,s4,80001cd6 <kfork+0xb6>
    if(p->ofile[i])
    80001cc8:	6088                	ld	a0,0(s1)
    80001cca:	d97d                	beqz	a0,80001cc0 <kfork+0xa0>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ccc:	480020ef          	jal	8000414c <filedup>
    80001cd0:	00a93023          	sd	a0,0(s2)
    80001cd4:	b7f5                	j	80001cc0 <kfork+0xa0>
  np->cwd = idup(p->cwd);
    80001cd6:	150ab503          	ld	a0,336(s5)
    80001cda:	68c010ef          	jal	80003366 <idup>
    80001cde:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ce2:	4641                	li	a2,16
    80001ce4:	158a8593          	addi	a1,s5,344
    80001ce8:	15898513          	addi	a0,s3,344
    80001cec:	8f4ff0ef          	jal	80000de0 <safestrcpy>
  pid = np->pid;
    80001cf0:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001cf4:	854e                	mv	a0,s3
    80001cf6:	f71fe0ef          	jal	80000c66 <release>
  acquire(&wait_lock);
    80001cfa:	00011497          	auipc	s1,0x11
    80001cfe:	8e648493          	addi	s1,s1,-1818 # 800125e0 <wait_lock>
    80001d02:	8526                	mv	a0,s1
    80001d04:	ecbfe0ef          	jal	80000bce <acquire>
  np->parent = p;
    80001d08:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001d0c:	8526                	mv	a0,s1
    80001d0e:	f59fe0ef          	jal	80000c66 <release>
  acquire(&np->lock);
    80001d12:	854e                	mv	a0,s3
    80001d14:	ebbfe0ef          	jal	80000bce <acquire>
  np->state = RUNNABLE;
    80001d18:	478d                	li	a5,3
    80001d1a:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001d1e:	854e                	mv	a0,s3
    80001d20:	f47fe0ef          	jal	80000c66 <release>
  return pid;
    80001d24:	74a2                	ld	s1,40(sp)
    80001d26:	69e2                	ld	s3,24(sp)
    80001d28:	6a42                	ld	s4,16(sp)
}
    80001d2a:	854a                	mv	a0,s2
    80001d2c:	70e2                	ld	ra,56(sp)
    80001d2e:	7442                	ld	s0,48(sp)
    80001d30:	7902                	ld	s2,32(sp)
    80001d32:	6aa2                	ld	s5,8(sp)
    80001d34:	6121                	addi	sp,sp,64
    80001d36:	8082                	ret
    return -1;
    80001d38:	597d                	li	s2,-1
    80001d3a:	bfc5                	j	80001d2a <kfork+0x10a>

0000000080001d3c <scheduler>:
{
    80001d3c:	715d                	addi	sp,sp,-80
    80001d3e:	e486                	sd	ra,72(sp)
    80001d40:	e0a2                	sd	s0,64(sp)
    80001d42:	fc26                	sd	s1,56(sp)
    80001d44:	f84a                	sd	s2,48(sp)
    80001d46:	f44e                	sd	s3,40(sp)
    80001d48:	f052                	sd	s4,32(sp)
    80001d4a:	ec56                	sd	s5,24(sp)
    80001d4c:	e85a                	sd	s6,16(sp)
    80001d4e:	e45e                	sd	s7,8(sp)
    80001d50:	e062                	sd	s8,0(sp)
    80001d52:	0880                	addi	s0,sp,80
    80001d54:	8792                	mv	a5,tp
  int id = r_tp();
    80001d56:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d58:	00779b13          	slli	s6,a5,0x7
    80001d5c:	00011717          	auipc	a4,0x11
    80001d60:	86c70713          	addi	a4,a4,-1940 # 800125c8 <pid_lock>
    80001d64:	975a                	add	a4,a4,s6
    80001d66:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d6a:	00011717          	auipc	a4,0x11
    80001d6e:	89670713          	addi	a4,a4,-1898 # 80012600 <cpus+0x8>
    80001d72:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d74:	4c11                	li	s8,4
        c->proc = p;
    80001d76:	079e                	slli	a5,a5,0x7
    80001d78:	00011a17          	auipc	s4,0x11
    80001d7c:	850a0a13          	addi	s4,s4,-1968 # 800125c8 <pid_lock>
    80001d80:	9a3e                	add	s4,s4,a5
        found = 1;
    80001d82:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d84:	00017997          	auipc	s3,0x17
    80001d88:	87498993          	addi	s3,s3,-1932 # 800185f8 <tickslock>
    80001d8c:	a83d                	j	80001dca <scheduler+0x8e>
      release(&p->lock);
    80001d8e:	8526                	mv	a0,s1
    80001d90:	ed7fe0ef          	jal	80000c66 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d94:	17048493          	addi	s1,s1,368
    80001d98:	03348563          	beq	s1,s3,80001dc2 <scheduler+0x86>
      acquire(&p->lock);
    80001d9c:	8526                	mv	a0,s1
    80001d9e:	e31fe0ef          	jal	80000bce <acquire>
      if(p->state == RUNNABLE) {
    80001da2:	4c9c                	lw	a5,24(s1)
    80001da4:	ff2795e3          	bne	a5,s2,80001d8e <scheduler+0x52>
        p->state = RUNNING;
    80001da8:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001dac:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001db0:	06048593          	addi	a1,s1,96
    80001db4:	855a                	mv	a0,s6
    80001db6:	662000ef          	jal	80002418 <swtch>
        c->proc = 0;
    80001dba:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001dbe:	8ade                	mv	s5,s7
    80001dc0:	b7f9                	j	80001d8e <scheduler+0x52>
    if(found == 0) {
    80001dc2:	000a9463          	bnez	s5,80001dca <scheduler+0x8e>
      asm volatile("wfi");
    80001dc6:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dca:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001dce:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dd2:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dd6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001dda:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ddc:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001de0:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001de2:	00011497          	auipc	s1,0x11
    80001de6:	c1648493          	addi	s1,s1,-1002 # 800129f8 <proc>
      if(p->state == RUNNABLE) {
    80001dea:	490d                	li	s2,3
    80001dec:	bf45                	j	80001d9c <scheduler+0x60>

0000000080001dee <sched>:
{
    80001dee:	7179                	addi	sp,sp,-48
    80001df0:	f406                	sd	ra,40(sp)
    80001df2:	f022                	sd	s0,32(sp)
    80001df4:	ec26                	sd	s1,24(sp)
    80001df6:	e84a                	sd	s2,16(sp)
    80001df8:	e44e                	sd	s3,8(sp)
    80001dfa:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001dfc:	ad3ff0ef          	jal	800018ce <myproc>
    80001e00:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e02:	d63fe0ef          	jal	80000b64 <holding>
    80001e06:	c92d                	beqz	a0,80001e78 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e08:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e0a:	2781                	sext.w	a5,a5
    80001e0c:	079e                	slli	a5,a5,0x7
    80001e0e:	00010717          	auipc	a4,0x10
    80001e12:	7ba70713          	addi	a4,a4,1978 # 800125c8 <pid_lock>
    80001e16:	97ba                	add	a5,a5,a4
    80001e18:	0a87a703          	lw	a4,168(a5)
    80001e1c:	4785                	li	a5,1
    80001e1e:	06f71363          	bne	a4,a5,80001e84 <sched+0x96>
  if(p->state == RUNNING)
    80001e22:	4c98                	lw	a4,24(s1)
    80001e24:	4791                	li	a5,4
    80001e26:	06f70563          	beq	a4,a5,80001e90 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e2a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e2e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e30:	e7b5                	bnez	a5,80001e9c <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e32:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e34:	00010917          	auipc	s2,0x10
    80001e38:	79490913          	addi	s2,s2,1940 # 800125c8 <pid_lock>
    80001e3c:	2781                	sext.w	a5,a5
    80001e3e:	079e                	slli	a5,a5,0x7
    80001e40:	97ca                	add	a5,a5,s2
    80001e42:	0ac7a983          	lw	s3,172(a5)
    80001e46:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e48:	2781                	sext.w	a5,a5
    80001e4a:	079e                	slli	a5,a5,0x7
    80001e4c:	00010597          	auipc	a1,0x10
    80001e50:	7b458593          	addi	a1,a1,1972 # 80012600 <cpus+0x8>
    80001e54:	95be                	add	a1,a1,a5
    80001e56:	06048513          	addi	a0,s1,96
    80001e5a:	5be000ef          	jal	80002418 <swtch>
    80001e5e:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e60:	2781                	sext.w	a5,a5
    80001e62:	079e                	slli	a5,a5,0x7
    80001e64:	993e                	add	s2,s2,a5
    80001e66:	0b392623          	sw	s3,172(s2)
}
    80001e6a:	70a2                	ld	ra,40(sp)
    80001e6c:	7402                	ld	s0,32(sp)
    80001e6e:	64e2                	ld	s1,24(sp)
    80001e70:	6942                	ld	s2,16(sp)
    80001e72:	69a2                	ld	s3,8(sp)
    80001e74:	6145                	addi	sp,sp,48
    80001e76:	8082                	ret
    panic("sched p->lock");
    80001e78:	00005517          	auipc	a0,0x5
    80001e7c:	31850513          	addi	a0,a0,792 # 80007190 <etext+0x190>
    80001e80:	961fe0ef          	jal	800007e0 <panic>
    panic("sched locks");
    80001e84:	00005517          	auipc	a0,0x5
    80001e88:	31c50513          	addi	a0,a0,796 # 800071a0 <etext+0x1a0>
    80001e8c:	955fe0ef          	jal	800007e0 <panic>
    panic("sched RUNNING");
    80001e90:	00005517          	auipc	a0,0x5
    80001e94:	32050513          	addi	a0,a0,800 # 800071b0 <etext+0x1b0>
    80001e98:	949fe0ef          	jal	800007e0 <panic>
    panic("sched interruptible");
    80001e9c:	00005517          	auipc	a0,0x5
    80001ea0:	32450513          	addi	a0,a0,804 # 800071c0 <etext+0x1c0>
    80001ea4:	93dfe0ef          	jal	800007e0 <panic>

0000000080001ea8 <yield>:
{
    80001ea8:	1101                	addi	sp,sp,-32
    80001eaa:	ec06                	sd	ra,24(sp)
    80001eac:	e822                	sd	s0,16(sp)
    80001eae:	e426                	sd	s1,8(sp)
    80001eb0:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001eb2:	a1dff0ef          	jal	800018ce <myproc>
    80001eb6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001eb8:	d17fe0ef          	jal	80000bce <acquire>
  p->state = RUNNABLE;
    80001ebc:	478d                	li	a5,3
    80001ebe:	cc9c                	sw	a5,24(s1)
  sched();
    80001ec0:	f2fff0ef          	jal	80001dee <sched>
  release(&p->lock);
    80001ec4:	8526                	mv	a0,s1
    80001ec6:	da1fe0ef          	jal	80000c66 <release>
}
    80001eca:	60e2                	ld	ra,24(sp)
    80001ecc:	6442                	ld	s0,16(sp)
    80001ece:	64a2                	ld	s1,8(sp)
    80001ed0:	6105                	addi	sp,sp,32
    80001ed2:	8082                	ret

0000000080001ed4 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001ed4:	7179                	addi	sp,sp,-48
    80001ed6:	f406                	sd	ra,40(sp)
    80001ed8:	f022                	sd	s0,32(sp)
    80001eda:	ec26                	sd	s1,24(sp)
    80001edc:	e84a                	sd	s2,16(sp)
    80001ede:	e44e                	sd	s3,8(sp)
    80001ee0:	1800                	addi	s0,sp,48
    80001ee2:	89aa                	mv	s3,a0
    80001ee4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001ee6:	9e9ff0ef          	jal	800018ce <myproc>
    80001eea:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001eec:	ce3fe0ef          	jal	80000bce <acquire>
  release(lk);
    80001ef0:	854a                	mv	a0,s2
    80001ef2:	d75fe0ef          	jal	80000c66 <release>

  // Go to sleep.
  p->chan = chan;
    80001ef6:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001efa:	4789                	li	a5,2
    80001efc:	cc9c                	sw	a5,24(s1)

  sched();
    80001efe:	ef1ff0ef          	jal	80001dee <sched>

  // Tidy up.
  p->chan = 0;
    80001f02:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f06:	8526                	mv	a0,s1
    80001f08:	d5ffe0ef          	jal	80000c66 <release>
  acquire(lk);
    80001f0c:	854a                	mv	a0,s2
    80001f0e:	cc1fe0ef          	jal	80000bce <acquire>
}
    80001f12:	70a2                	ld	ra,40(sp)
    80001f14:	7402                	ld	s0,32(sp)
    80001f16:	64e2                	ld	s1,24(sp)
    80001f18:	6942                	ld	s2,16(sp)
    80001f1a:	69a2                	ld	s3,8(sp)
    80001f1c:	6145                	addi	sp,sp,48
    80001f1e:	8082                	ret

0000000080001f20 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001f20:	7139                	addi	sp,sp,-64
    80001f22:	fc06                	sd	ra,56(sp)
    80001f24:	f822                	sd	s0,48(sp)
    80001f26:	f426                	sd	s1,40(sp)
    80001f28:	f04a                	sd	s2,32(sp)
    80001f2a:	ec4e                	sd	s3,24(sp)
    80001f2c:	e852                	sd	s4,16(sp)
    80001f2e:	e456                	sd	s5,8(sp)
    80001f30:	0080                	addi	s0,sp,64
    80001f32:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f34:	00011497          	auipc	s1,0x11
    80001f38:	ac448493          	addi	s1,s1,-1340 # 800129f8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f3c:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f3e:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f40:	00016917          	auipc	s2,0x16
    80001f44:	6b890913          	addi	s2,s2,1720 # 800185f8 <tickslock>
    80001f48:	a801                	j	80001f58 <wakeup+0x38>
      }
      release(&p->lock);
    80001f4a:	8526                	mv	a0,s1
    80001f4c:	d1bfe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f50:	17048493          	addi	s1,s1,368
    80001f54:	03248263          	beq	s1,s2,80001f78 <wakeup+0x58>
    if(p != myproc()){
    80001f58:	977ff0ef          	jal	800018ce <myproc>
    80001f5c:	fea48ae3          	beq	s1,a0,80001f50 <wakeup+0x30>
      acquire(&p->lock);
    80001f60:	8526                	mv	a0,s1
    80001f62:	c6dfe0ef          	jal	80000bce <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f66:	4c9c                	lw	a5,24(s1)
    80001f68:	ff3791e3          	bne	a5,s3,80001f4a <wakeup+0x2a>
    80001f6c:	709c                	ld	a5,32(s1)
    80001f6e:	fd479ee3          	bne	a5,s4,80001f4a <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f72:	0154ac23          	sw	s5,24(s1)
    80001f76:	bfd1                	j	80001f4a <wakeup+0x2a>
    }
  }
}
    80001f78:	70e2                	ld	ra,56(sp)
    80001f7a:	7442                	ld	s0,48(sp)
    80001f7c:	74a2                	ld	s1,40(sp)
    80001f7e:	7902                	ld	s2,32(sp)
    80001f80:	69e2                	ld	s3,24(sp)
    80001f82:	6a42                	ld	s4,16(sp)
    80001f84:	6aa2                	ld	s5,8(sp)
    80001f86:	6121                	addi	sp,sp,64
    80001f88:	8082                	ret

0000000080001f8a <reparent>:
{
    80001f8a:	7179                	addi	sp,sp,-48
    80001f8c:	f406                	sd	ra,40(sp)
    80001f8e:	f022                	sd	s0,32(sp)
    80001f90:	ec26                	sd	s1,24(sp)
    80001f92:	e84a                	sd	s2,16(sp)
    80001f94:	e44e                	sd	s3,8(sp)
    80001f96:	e052                	sd	s4,0(sp)
    80001f98:	1800                	addi	s0,sp,48
    80001f9a:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f9c:	00011497          	auipc	s1,0x11
    80001fa0:	a5c48493          	addi	s1,s1,-1444 # 800129f8 <proc>
      pp->parent = initproc;
    80001fa4:	00008a17          	auipc	s4,0x8
    80001fa8:	51ca0a13          	addi	s4,s4,1308 # 8000a4c0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fac:	00016997          	auipc	s3,0x16
    80001fb0:	64c98993          	addi	s3,s3,1612 # 800185f8 <tickslock>
    80001fb4:	a029                	j	80001fbe <reparent+0x34>
    80001fb6:	17048493          	addi	s1,s1,368
    80001fba:	01348b63          	beq	s1,s3,80001fd0 <reparent+0x46>
    if(pp->parent == p){
    80001fbe:	7c9c                	ld	a5,56(s1)
    80001fc0:	ff279be3          	bne	a5,s2,80001fb6 <reparent+0x2c>
      pp->parent = initproc;
    80001fc4:	000a3503          	ld	a0,0(s4)
    80001fc8:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001fca:	f57ff0ef          	jal	80001f20 <wakeup>
    80001fce:	b7e5                	j	80001fb6 <reparent+0x2c>
}
    80001fd0:	70a2                	ld	ra,40(sp)
    80001fd2:	7402                	ld	s0,32(sp)
    80001fd4:	64e2                	ld	s1,24(sp)
    80001fd6:	6942                	ld	s2,16(sp)
    80001fd8:	69a2                	ld	s3,8(sp)
    80001fda:	6a02                	ld	s4,0(sp)
    80001fdc:	6145                	addi	sp,sp,48
    80001fde:	8082                	ret

0000000080001fe0 <kexit>:
{
    80001fe0:	7179                	addi	sp,sp,-48
    80001fe2:	f406                	sd	ra,40(sp)
    80001fe4:	f022                	sd	s0,32(sp)
    80001fe6:	ec26                	sd	s1,24(sp)
    80001fe8:	e84a                	sd	s2,16(sp)
    80001fea:	e44e                	sd	s3,8(sp)
    80001fec:	e052                	sd	s4,0(sp)
    80001fee:	1800                	addi	s0,sp,48
    80001ff0:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001ff2:	8ddff0ef          	jal	800018ce <myproc>
    80001ff6:	89aa                	mv	s3,a0
  if(p == initproc)
    80001ff8:	00008797          	auipc	a5,0x8
    80001ffc:	4c87b783          	ld	a5,1224(a5) # 8000a4c0 <initproc>
    80002000:	0d050493          	addi	s1,a0,208
    80002004:	15050913          	addi	s2,a0,336
    80002008:	00a79f63          	bne	a5,a0,80002026 <kexit+0x46>
    panic("init exiting");
    8000200c:	00005517          	auipc	a0,0x5
    80002010:	1cc50513          	addi	a0,a0,460 # 800071d8 <etext+0x1d8>
    80002014:	fccfe0ef          	jal	800007e0 <panic>
      fileclose(f);
    80002018:	17a020ef          	jal	80004192 <fileclose>
      p->ofile[fd] = 0;
    8000201c:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002020:	04a1                	addi	s1,s1,8
    80002022:	01248563          	beq	s1,s2,8000202c <kexit+0x4c>
    if(p->ofile[fd]){
    80002026:	6088                	ld	a0,0(s1)
    80002028:	f965                	bnez	a0,80002018 <kexit+0x38>
    8000202a:	bfdd                	j	80002020 <kexit+0x40>
  begin_op();
    8000202c:	55b010ef          	jal	80003d86 <begin_op>
  iput(p->cwd);
    80002030:	1509b503          	ld	a0,336(s3)
    80002034:	4ea010ef          	jal	8000351e <iput>
  end_op();
    80002038:	5b9010ef          	jal	80003df0 <end_op>
  p->cwd = 0;
    8000203c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002040:	00010497          	auipc	s1,0x10
    80002044:	5a048493          	addi	s1,s1,1440 # 800125e0 <wait_lock>
    80002048:	8526                	mv	a0,s1
    8000204a:	b85fe0ef          	jal	80000bce <acquire>
  reparent(p);
    8000204e:	854e                	mv	a0,s3
    80002050:	f3bff0ef          	jal	80001f8a <reparent>
  wakeup(p->parent);
    80002054:	0389b503          	ld	a0,56(s3)
    80002058:	ec9ff0ef          	jal	80001f20 <wakeup>
  acquire(&p->lock);
    8000205c:	854e                	mv	a0,s3
    8000205e:	b71fe0ef          	jal	80000bce <acquire>
  p->xstate = status;
    80002062:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002066:	4795                	li	a5,5
    80002068:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000206c:	8526                	mv	a0,s1
    8000206e:	bf9fe0ef          	jal	80000c66 <release>
  sched();
    80002072:	d7dff0ef          	jal	80001dee <sched>
  panic("zombie exit");
    80002076:	00005517          	auipc	a0,0x5
    8000207a:	17250513          	addi	a0,a0,370 # 800071e8 <etext+0x1e8>
    8000207e:	f62fe0ef          	jal	800007e0 <panic>

0000000080002082 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002082:	7179                	addi	sp,sp,-48
    80002084:	f406                	sd	ra,40(sp)
    80002086:	f022                	sd	s0,32(sp)
    80002088:	ec26                	sd	s1,24(sp)
    8000208a:	e84a                	sd	s2,16(sp)
    8000208c:	e44e                	sd	s3,8(sp)
    8000208e:	1800                	addi	s0,sp,48
    80002090:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002092:	00011497          	auipc	s1,0x11
    80002096:	96648493          	addi	s1,s1,-1690 # 800129f8 <proc>
    8000209a:	00016997          	auipc	s3,0x16
    8000209e:	55e98993          	addi	s3,s3,1374 # 800185f8 <tickslock>
    acquire(&p->lock);
    800020a2:	8526                	mv	a0,s1
    800020a4:	b2bfe0ef          	jal	80000bce <acquire>
    if(p->pid == pid){
    800020a8:	589c                	lw	a5,48(s1)
    800020aa:	01278b63          	beq	a5,s2,800020c0 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800020ae:	8526                	mv	a0,s1
    800020b0:	bb7fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800020b4:	17048493          	addi	s1,s1,368
    800020b8:	ff3495e3          	bne	s1,s3,800020a2 <kkill+0x20>
  }
  return -1;
    800020bc:	557d                	li	a0,-1
    800020be:	a819                	j	800020d4 <kkill+0x52>
      p->killed = 1;
    800020c0:	4785                	li	a5,1
    800020c2:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800020c4:	4c98                	lw	a4,24(s1)
    800020c6:	4789                	li	a5,2
    800020c8:	00f70d63          	beq	a4,a5,800020e2 <kkill+0x60>
      release(&p->lock);
    800020cc:	8526                	mv	a0,s1
    800020ce:	b99fe0ef          	jal	80000c66 <release>
      return 0;
    800020d2:	4501                	li	a0,0
}
    800020d4:	70a2                	ld	ra,40(sp)
    800020d6:	7402                	ld	s0,32(sp)
    800020d8:	64e2                	ld	s1,24(sp)
    800020da:	6942                	ld	s2,16(sp)
    800020dc:	69a2                	ld	s3,8(sp)
    800020de:	6145                	addi	sp,sp,48
    800020e0:	8082                	ret
        p->state = RUNNABLE;
    800020e2:	478d                	li	a5,3
    800020e4:	cc9c                	sw	a5,24(s1)
    800020e6:	b7dd                	j	800020cc <kkill+0x4a>

00000000800020e8 <setkilled>:

void
setkilled(struct proc *p)
{
    800020e8:	1101                	addi	sp,sp,-32
    800020ea:	ec06                	sd	ra,24(sp)
    800020ec:	e822                	sd	s0,16(sp)
    800020ee:	e426                	sd	s1,8(sp)
    800020f0:	1000                	addi	s0,sp,32
    800020f2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020f4:	adbfe0ef          	jal	80000bce <acquire>
  p->killed = 1;
    800020f8:	4785                	li	a5,1
    800020fa:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800020fc:	8526                	mv	a0,s1
    800020fe:	b69fe0ef          	jal	80000c66 <release>
}
    80002102:	60e2                	ld	ra,24(sp)
    80002104:	6442                	ld	s0,16(sp)
    80002106:	64a2                	ld	s1,8(sp)
    80002108:	6105                	addi	sp,sp,32
    8000210a:	8082                	ret

000000008000210c <killed>:

int
killed(struct proc *p)
{
    8000210c:	1101                	addi	sp,sp,-32
    8000210e:	ec06                	sd	ra,24(sp)
    80002110:	e822                	sd	s0,16(sp)
    80002112:	e426                	sd	s1,8(sp)
    80002114:	e04a                	sd	s2,0(sp)
    80002116:	1000                	addi	s0,sp,32
    80002118:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000211a:	ab5fe0ef          	jal	80000bce <acquire>
  k = p->killed;
    8000211e:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002122:	8526                	mv	a0,s1
    80002124:	b43fe0ef          	jal	80000c66 <release>
  return k;
}
    80002128:	854a                	mv	a0,s2
    8000212a:	60e2                	ld	ra,24(sp)
    8000212c:	6442                	ld	s0,16(sp)
    8000212e:	64a2                	ld	s1,8(sp)
    80002130:	6902                	ld	s2,0(sp)
    80002132:	6105                	addi	sp,sp,32
    80002134:	8082                	ret

0000000080002136 <kwait>:
{
    80002136:	715d                	addi	sp,sp,-80
    80002138:	e486                	sd	ra,72(sp)
    8000213a:	e0a2                	sd	s0,64(sp)
    8000213c:	fc26                	sd	s1,56(sp)
    8000213e:	f84a                	sd	s2,48(sp)
    80002140:	f44e                	sd	s3,40(sp)
    80002142:	f052                	sd	s4,32(sp)
    80002144:	ec56                	sd	s5,24(sp)
    80002146:	e85a                	sd	s6,16(sp)
    80002148:	e45e                	sd	s7,8(sp)
    8000214a:	e062                	sd	s8,0(sp)
    8000214c:	0880                	addi	s0,sp,80
    8000214e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002150:	f7eff0ef          	jal	800018ce <myproc>
    80002154:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002156:	00010517          	auipc	a0,0x10
    8000215a:	48a50513          	addi	a0,a0,1162 # 800125e0 <wait_lock>
    8000215e:	a71fe0ef          	jal	80000bce <acquire>
    havekids = 0;
    80002162:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002164:	4a15                	li	s4,5
        havekids = 1;
    80002166:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002168:	00016997          	auipc	s3,0x16
    8000216c:	49098993          	addi	s3,s3,1168 # 800185f8 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002170:	00010c17          	auipc	s8,0x10
    80002174:	470c0c13          	addi	s8,s8,1136 # 800125e0 <wait_lock>
    80002178:	a871                	j	80002214 <kwait+0xde>
          pid = pp->pid;
    8000217a:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000217e:	000b0c63          	beqz	s6,80002196 <kwait+0x60>
    80002182:	4691                	li	a3,4
    80002184:	02c48613          	addi	a2,s1,44
    80002188:	85da                	mv	a1,s6
    8000218a:	05093503          	ld	a0,80(s2)
    8000218e:	c54ff0ef          	jal	800015e2 <copyout>
    80002192:	02054b63          	bltz	a0,800021c8 <kwait+0x92>
          freeproc(pp);
    80002196:	8526                	mv	a0,s1
    80002198:	907ff0ef          	jal	80001a9e <freeproc>
          release(&pp->lock);
    8000219c:	8526                	mv	a0,s1
    8000219e:	ac9fe0ef          	jal	80000c66 <release>
          release(&wait_lock);
    800021a2:	00010517          	auipc	a0,0x10
    800021a6:	43e50513          	addi	a0,a0,1086 # 800125e0 <wait_lock>
    800021aa:	abdfe0ef          	jal	80000c66 <release>
}
    800021ae:	854e                	mv	a0,s3
    800021b0:	60a6                	ld	ra,72(sp)
    800021b2:	6406                	ld	s0,64(sp)
    800021b4:	74e2                	ld	s1,56(sp)
    800021b6:	7942                	ld	s2,48(sp)
    800021b8:	79a2                	ld	s3,40(sp)
    800021ba:	7a02                	ld	s4,32(sp)
    800021bc:	6ae2                	ld	s5,24(sp)
    800021be:	6b42                	ld	s6,16(sp)
    800021c0:	6ba2                	ld	s7,8(sp)
    800021c2:	6c02                	ld	s8,0(sp)
    800021c4:	6161                	addi	sp,sp,80
    800021c6:	8082                	ret
            release(&pp->lock);
    800021c8:	8526                	mv	a0,s1
    800021ca:	a9dfe0ef          	jal	80000c66 <release>
            release(&wait_lock);
    800021ce:	00010517          	auipc	a0,0x10
    800021d2:	41250513          	addi	a0,a0,1042 # 800125e0 <wait_lock>
    800021d6:	a91fe0ef          	jal	80000c66 <release>
            return -1;
    800021da:	59fd                	li	s3,-1
    800021dc:	bfc9                	j	800021ae <kwait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021de:	17048493          	addi	s1,s1,368
    800021e2:	03348063          	beq	s1,s3,80002202 <kwait+0xcc>
      if(pp->parent == p){
    800021e6:	7c9c                	ld	a5,56(s1)
    800021e8:	ff279be3          	bne	a5,s2,800021de <kwait+0xa8>
        acquire(&pp->lock);
    800021ec:	8526                	mv	a0,s1
    800021ee:	9e1fe0ef          	jal	80000bce <acquire>
        if(pp->state == ZOMBIE){
    800021f2:	4c9c                	lw	a5,24(s1)
    800021f4:	f94783e3          	beq	a5,s4,8000217a <kwait+0x44>
        release(&pp->lock);
    800021f8:	8526                	mv	a0,s1
    800021fa:	a6dfe0ef          	jal	80000c66 <release>
        havekids = 1;
    800021fe:	8756                	mv	a4,s5
    80002200:	bff9                	j	800021de <kwait+0xa8>
    if(!havekids || killed(p)){
    80002202:	cf19                	beqz	a4,80002220 <kwait+0xea>
    80002204:	854a                	mv	a0,s2
    80002206:	f07ff0ef          	jal	8000210c <killed>
    8000220a:	e919                	bnez	a0,80002220 <kwait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000220c:	85e2                	mv	a1,s8
    8000220e:	854a                	mv	a0,s2
    80002210:	cc5ff0ef          	jal	80001ed4 <sleep>
    havekids = 0;
    80002214:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002216:	00010497          	auipc	s1,0x10
    8000221a:	7e248493          	addi	s1,s1,2018 # 800129f8 <proc>
    8000221e:	b7e1                	j	800021e6 <kwait+0xb0>
      release(&wait_lock);
    80002220:	00010517          	auipc	a0,0x10
    80002224:	3c050513          	addi	a0,a0,960 # 800125e0 <wait_lock>
    80002228:	a3ffe0ef          	jal	80000c66 <release>
      return -1;
    8000222c:	59fd                	li	s3,-1
    8000222e:	b741                	j	800021ae <kwait+0x78>

0000000080002230 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002230:	7179                	addi	sp,sp,-48
    80002232:	f406                	sd	ra,40(sp)
    80002234:	f022                	sd	s0,32(sp)
    80002236:	ec26                	sd	s1,24(sp)
    80002238:	e84a                	sd	s2,16(sp)
    8000223a:	e44e                	sd	s3,8(sp)
    8000223c:	e052                	sd	s4,0(sp)
    8000223e:	1800                	addi	s0,sp,48
    80002240:	84aa                	mv	s1,a0
    80002242:	892e                	mv	s2,a1
    80002244:	89b2                	mv	s3,a2
    80002246:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002248:	e86ff0ef          	jal	800018ce <myproc>
  if(user_dst){
    8000224c:	cc99                	beqz	s1,8000226a <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000224e:	86d2                	mv	a3,s4
    80002250:	864e                	mv	a2,s3
    80002252:	85ca                	mv	a1,s2
    80002254:	6928                	ld	a0,80(a0)
    80002256:	b8cff0ef          	jal	800015e2 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000225a:	70a2                	ld	ra,40(sp)
    8000225c:	7402                	ld	s0,32(sp)
    8000225e:	64e2                	ld	s1,24(sp)
    80002260:	6942                	ld	s2,16(sp)
    80002262:	69a2                	ld	s3,8(sp)
    80002264:	6a02                	ld	s4,0(sp)
    80002266:	6145                	addi	sp,sp,48
    80002268:	8082                	ret
    memmove((char *)dst, src, len);
    8000226a:	000a061b          	sext.w	a2,s4
    8000226e:	85ce                	mv	a1,s3
    80002270:	854a                	mv	a0,s2
    80002272:	a8dfe0ef          	jal	80000cfe <memmove>
    return 0;
    80002276:	8526                	mv	a0,s1
    80002278:	b7cd                	j	8000225a <either_copyout+0x2a>

000000008000227a <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000227a:	7179                	addi	sp,sp,-48
    8000227c:	f406                	sd	ra,40(sp)
    8000227e:	f022                	sd	s0,32(sp)
    80002280:	ec26                	sd	s1,24(sp)
    80002282:	e84a                	sd	s2,16(sp)
    80002284:	e44e                	sd	s3,8(sp)
    80002286:	e052                	sd	s4,0(sp)
    80002288:	1800                	addi	s0,sp,48
    8000228a:	892a                	mv	s2,a0
    8000228c:	84ae                	mv	s1,a1
    8000228e:	89b2                	mv	s3,a2
    80002290:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002292:	e3cff0ef          	jal	800018ce <myproc>
  if(user_src){
    80002296:	cc99                	beqz	s1,800022b4 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002298:	86d2                	mv	a3,s4
    8000229a:	864e                	mv	a2,s3
    8000229c:	85ca                	mv	a1,s2
    8000229e:	6928                	ld	a0,80(a0)
    800022a0:	c26ff0ef          	jal	800016c6 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800022a4:	70a2                	ld	ra,40(sp)
    800022a6:	7402                	ld	s0,32(sp)
    800022a8:	64e2                	ld	s1,24(sp)
    800022aa:	6942                	ld	s2,16(sp)
    800022ac:	69a2                	ld	s3,8(sp)
    800022ae:	6a02                	ld	s4,0(sp)
    800022b0:	6145                	addi	sp,sp,48
    800022b2:	8082                	ret
    memmove(dst, (char*)src, len);
    800022b4:	000a061b          	sext.w	a2,s4
    800022b8:	85ce                	mv	a1,s3
    800022ba:	854a                	mv	a0,s2
    800022bc:	a43fe0ef          	jal	80000cfe <memmove>
    return 0;
    800022c0:	8526                	mv	a0,s1
    800022c2:	b7cd                	j	800022a4 <either_copyin+0x2a>

00000000800022c4 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022c4:	715d                	addi	sp,sp,-80
    800022c6:	e486                	sd	ra,72(sp)
    800022c8:	e0a2                	sd	s0,64(sp)
    800022ca:	fc26                	sd	s1,56(sp)
    800022cc:	f84a                	sd	s2,48(sp)
    800022ce:	f44e                	sd	s3,40(sp)
    800022d0:	f052                	sd	s4,32(sp)
    800022d2:	ec56                	sd	s5,24(sp)
    800022d4:	e85a                	sd	s6,16(sp)
    800022d6:	e45e                	sd	s7,8(sp)
    800022d8:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022da:	00005517          	auipc	a0,0x5
    800022de:	fae50513          	addi	a0,a0,-82 # 80007288 <etext+0x288>
    800022e2:	a18fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022e6:	00011497          	auipc	s1,0x11
    800022ea:	86a48493          	addi	s1,s1,-1942 # 80012b50 <proc+0x158>
    800022ee:	00016917          	auipc	s2,0x16
    800022f2:	46290913          	addi	s2,s2,1122 # 80018750 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022f6:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800022f8:	00005997          	auipc	s3,0x5
    800022fc:	f0098993          	addi	s3,s3,-256 # 800071f8 <etext+0x1f8>
    printf("%d %s %s", p->pid, state, p->name);
    80002300:	00005a97          	auipc	s5,0x5
    80002304:	f00a8a93          	addi	s5,s5,-256 # 80007200 <etext+0x200>
    printf("\n");
    80002308:	00005a17          	auipc	s4,0x5
    8000230c:	f80a0a13          	addi	s4,s4,-128 # 80007288 <etext+0x288>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002310:	00005b97          	auipc	s7,0x5
    80002314:	568b8b93          	addi	s7,s7,1384 # 80007878 <states.0>
    80002318:	a829                	j	80002332 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000231a:	ed86a583          	lw	a1,-296(a3)
    8000231e:	8556                	mv	a0,s5
    80002320:	9dafe0ef          	jal	800004fa <printf>
    printf("\n");
    80002324:	8552                	mv	a0,s4
    80002326:	9d4fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000232a:	17048493          	addi	s1,s1,368
    8000232e:	03248263          	beq	s1,s2,80002352 <procdump+0x8e>
    if(p->state == UNUSED)
    80002332:	86a6                	mv	a3,s1
    80002334:	ec04a783          	lw	a5,-320(s1)
    80002338:	dbed                	beqz	a5,8000232a <procdump+0x66>
      state = "???";
    8000233a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000233c:	fcfb6fe3          	bltu	s6,a5,8000231a <procdump+0x56>
    80002340:	02079713          	slli	a4,a5,0x20
    80002344:	01d75793          	srli	a5,a4,0x1d
    80002348:	97de                	add	a5,a5,s7
    8000234a:	6390                	ld	a2,0(a5)
    8000234c:	f679                	bnez	a2,8000231a <procdump+0x56>
      state = "???";
    8000234e:	864e                	mv	a2,s3
    80002350:	b7e9                	j	8000231a <procdump+0x56>
  }
}
    80002352:	60a6                	ld	ra,72(sp)
    80002354:	6406                	ld	s0,64(sp)
    80002356:	74e2                	ld	s1,56(sp)
    80002358:	7942                	ld	s2,48(sp)
    8000235a:	79a2                	ld	s3,40(sp)
    8000235c:	7a02                	ld	s4,32(sp)
    8000235e:	6ae2                	ld	s5,24(sp)
    80002360:	6b42                	ld	s6,16(sp)
    80002362:	6ba2                	ld	s7,8(sp)
    80002364:	6161                	addi	sp,sp,80
    80002366:	8082                	ret

0000000080002368 <cps>:

int 
cps(void)
{
    80002368:	715d                	addi	sp,sp,-80
    8000236a:	e486                	sd	ra,72(sp)
    8000236c:	e0a2                	sd	s0,64(sp)
    8000236e:	fc26                	sd	s1,56(sp)
    80002370:	f84a                	sd	s2,48(sp)
    80002372:	f44e                	sd	s3,40(sp)
    80002374:	f052                	sd	s4,32(sp)
    80002376:	ec56                	sd	s5,24(sp)
    80002378:	e85a                	sd	s6,16(sp)
    8000237a:	e45e                	sd	s7,8(sp)
    8000237c:	e062                	sd	s8,0(sp)
    8000237e:	0880                	addi	s0,sp,80
	struct proc *p;
	
	// Loop over process table looking for process with pid

	printf("name \t pid \t state \t priority \n");
    80002380:	00005517          	auipc	a0,0x5
    80002384:	e9050513          	addi	a0,a0,-368 # 80007210 <etext+0x210>
    80002388:	972fe0ef          	jal	800004fa <printf>
	for(p = proc; p < &proc[NPROC]; p++){
    8000238c:	00010497          	auipc	s1,0x10
    80002390:	7c448493          	addi	s1,s1,1988 # 80012b50 <proc+0x158>
    80002394:	00016997          	auipc	s3,0x16
    80002398:	3bc98993          	addi	s3,s3,956 # 80018750 <bcache+0x140>
		if(p->state == SLEEPING)
    8000239c:	4909                	li	s2,2
			printf("%s \t %d \t SLEEEPING \t %d \n", p->name, p->pid, p->nice);
		else if(p->state == RUNNING)
    8000239e:	4a11                	li	s4,4
			printf("%s \t %d \t RUNNING \t %d \n", p->name, p->pid, p->nice);
		else if(p->state == RUNNABLE)
    800023a0:	4a8d                	li	s5,3
			printf("%s \t %d \t RUNNABLE \t %d \n", p->name, p->pid, p->nice);	
    800023a2:	00005c17          	auipc	s8,0x5
    800023a6:	ecec0c13          	addi	s8,s8,-306 # 80007270 <etext+0x270>
			printf("%s \t %d \t RUNNING \t %d \n", p->name, p->pid, p->nice);
    800023aa:	00005b97          	auipc	s7,0x5
    800023ae:	ea6b8b93          	addi	s7,s7,-346 # 80007250 <etext+0x250>
			printf("%s \t %d \t SLEEEPING \t %d \n", p->name, p->pid, p->nice);
    800023b2:	00005b17          	auipc	s6,0x5
    800023b6:	e7eb0b13          	addi	s6,s6,-386 # 80007230 <etext+0x230>
    800023ba:	a819                	j	800023d0 <cps+0x68>
    800023bc:	48d4                	lw	a3,20(s1)
    800023be:	ed84a603          	lw	a2,-296(s1)
    800023c2:	855a                	mv	a0,s6
    800023c4:	936fe0ef          	jal	800004fa <printf>
	for(p = proc; p < &proc[NPROC]; p++){
    800023c8:	17048493          	addi	s1,s1,368
    800023cc:	03348963          	beq	s1,s3,800023fe <cps+0x96>
		if(p->state == SLEEPING)
    800023d0:	85a6                	mv	a1,s1
    800023d2:	ec04a783          	lw	a5,-320(s1)
    800023d6:	ff2783e3          	beq	a5,s2,800023bc <cps+0x54>
		else if(p->state == RUNNING)
    800023da:	01478b63          	beq	a5,s4,800023f0 <cps+0x88>
		else if(p->state == RUNNABLE)
    800023de:	ff5795e3          	bne	a5,s5,800023c8 <cps+0x60>
			printf("%s \t %d \t RUNNABLE \t %d \n", p->name, p->pid, p->nice);	
    800023e2:	48d4                	lw	a3,20(s1)
    800023e4:	ed84a603          	lw	a2,-296(s1)
    800023e8:	8562                	mv	a0,s8
    800023ea:	910fe0ef          	jal	800004fa <printf>
    800023ee:	bfe9                	j	800023c8 <cps+0x60>
			printf("%s \t %d \t RUNNING \t %d \n", p->name, p->pid, p->nice);
    800023f0:	48d4                	lw	a3,20(s1)
    800023f2:	ed84a603          	lw	a2,-296(s1)
    800023f6:	855e                	mv	a0,s7
    800023f8:	902fe0ef          	jal	800004fa <printf>
    800023fc:	b7f1                	j	800023c8 <cps+0x60>
	}
	
	return 22;
    800023fe:	4559                	li	a0,22
    80002400:	60a6                	ld	ra,72(sp)
    80002402:	6406                	ld	s0,64(sp)
    80002404:	74e2                	ld	s1,56(sp)
    80002406:	7942                	ld	s2,48(sp)
    80002408:	79a2                	ld	s3,40(sp)
    8000240a:	7a02                	ld	s4,32(sp)
    8000240c:	6ae2                	ld	s5,24(sp)
    8000240e:	6b42                	ld	s6,16(sp)
    80002410:	6ba2                	ld	s7,8(sp)
    80002412:	6c02                	ld	s8,0(sp)
    80002414:	6161                	addi	sp,sp,80
    80002416:	8082                	ret

0000000080002418 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002418:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    8000241c:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002420:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002422:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002424:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002428:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    8000242c:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002430:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002434:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002438:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    8000243c:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002440:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002444:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002448:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    8000244c:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002450:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002454:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002456:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002458:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    8000245c:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002460:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002464:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002468:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    8000246c:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002470:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002474:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002478:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    8000247c:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002480:	8082                	ret

0000000080002482 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002482:	1141                	addi	sp,sp,-16
    80002484:	e406                	sd	ra,8(sp)
    80002486:	e022                	sd	s0,0(sp)
    80002488:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000248a:	00005597          	auipc	a1,0x5
    8000248e:	e3658593          	addi	a1,a1,-458 # 800072c0 <etext+0x2c0>
    80002492:	00016517          	auipc	a0,0x16
    80002496:	16650513          	addi	a0,a0,358 # 800185f8 <tickslock>
    8000249a:	eb4fe0ef          	jal	80000b4e <initlock>
}
    8000249e:	60a2                	ld	ra,8(sp)
    800024a0:	6402                	ld	s0,0(sp)
    800024a2:	0141                	addi	sp,sp,16
    800024a4:	8082                	ret

00000000800024a6 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800024a6:	1141                	addi	sp,sp,-16
    800024a8:	e422                	sd	s0,8(sp)
    800024aa:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800024ac:	00003797          	auipc	a5,0x3
    800024b0:	05478793          	addi	a5,a5,84 # 80005500 <kernelvec>
    800024b4:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800024b8:	6422                	ld	s0,8(sp)
    800024ba:	0141                	addi	sp,sp,16
    800024bc:	8082                	ret

00000000800024be <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800024be:	1141                	addi	sp,sp,-16
    800024c0:	e406                	sd	ra,8(sp)
    800024c2:	e022                	sd	s0,0(sp)
    800024c4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800024c6:	c08ff0ef          	jal	800018ce <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024ca:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800024ce:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024d0:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800024d4:	04000737          	lui	a4,0x4000
    800024d8:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800024da:	0732                	slli	a4,a4,0xc
    800024dc:	00004797          	auipc	a5,0x4
    800024e0:	b2478793          	addi	a5,a5,-1244 # 80006000 <_trampoline>
    800024e4:	00004697          	auipc	a3,0x4
    800024e8:	b1c68693          	addi	a3,a3,-1252 # 80006000 <_trampoline>
    800024ec:	8f95                	sub	a5,a5,a3
    800024ee:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800024f0:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800024f4:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800024f6:	18002773          	csrr	a4,satp
    800024fa:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800024fc:	6d38                	ld	a4,88(a0)
    800024fe:	613c                	ld	a5,64(a0)
    80002500:	6685                	lui	a3,0x1
    80002502:	97b6                	add	a5,a5,a3
    80002504:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002506:	6d3c                	ld	a5,88(a0)
    80002508:	00000717          	auipc	a4,0x0
    8000250c:	0f870713          	addi	a4,a4,248 # 80002600 <usertrap>
    80002510:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002512:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002514:	8712                	mv	a4,tp
    80002516:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002518:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000251c:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002520:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002524:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002528:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000252a:	6f9c                	ld	a5,24(a5)
    8000252c:	14179073          	csrw	sepc,a5
}
    80002530:	60a2                	ld	ra,8(sp)
    80002532:	6402                	ld	s0,0(sp)
    80002534:	0141                	addi	sp,sp,16
    80002536:	8082                	ret

0000000080002538 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002538:	1101                	addi	sp,sp,-32
    8000253a:	ec06                	sd	ra,24(sp)
    8000253c:	e822                	sd	s0,16(sp)
    8000253e:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002540:	b62ff0ef          	jal	800018a2 <cpuid>
    80002544:	cd11                	beqz	a0,80002560 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002546:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000254a:	000f4737          	lui	a4,0xf4
    8000254e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002552:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002554:	14d79073          	csrw	stimecmp,a5
}
    80002558:	60e2                	ld	ra,24(sp)
    8000255a:	6442                	ld	s0,16(sp)
    8000255c:	6105                	addi	sp,sp,32
    8000255e:	8082                	ret
    80002560:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80002562:	00016497          	auipc	s1,0x16
    80002566:	09648493          	addi	s1,s1,150 # 800185f8 <tickslock>
    8000256a:	8526                	mv	a0,s1
    8000256c:	e62fe0ef          	jal	80000bce <acquire>
    ticks++;
    80002570:	00008517          	auipc	a0,0x8
    80002574:	f5850513          	addi	a0,a0,-168 # 8000a4c8 <ticks>
    80002578:	411c                	lw	a5,0(a0)
    8000257a:	2785                	addiw	a5,a5,1
    8000257c:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    8000257e:	9a3ff0ef          	jal	80001f20 <wakeup>
    release(&tickslock);
    80002582:	8526                	mv	a0,s1
    80002584:	ee2fe0ef          	jal	80000c66 <release>
    80002588:	64a2                	ld	s1,8(sp)
    8000258a:	bf75                	j	80002546 <clockintr+0xe>

000000008000258c <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000258c:	1101                	addi	sp,sp,-32
    8000258e:	ec06                	sd	ra,24(sp)
    80002590:	e822                	sd	s0,16(sp)
    80002592:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002594:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002598:	57fd                	li	a5,-1
    8000259a:	17fe                	slli	a5,a5,0x3f
    8000259c:	07a5                	addi	a5,a5,9
    8000259e:	00f70c63          	beq	a4,a5,800025b6 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800025a2:	57fd                	li	a5,-1
    800025a4:	17fe                	slli	a5,a5,0x3f
    800025a6:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800025a8:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800025aa:	04f70763          	beq	a4,a5,800025f8 <devintr+0x6c>
  }
}
    800025ae:	60e2                	ld	ra,24(sp)
    800025b0:	6442                	ld	s0,16(sp)
    800025b2:	6105                	addi	sp,sp,32
    800025b4:	8082                	ret
    800025b6:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800025b8:	7f5020ef          	jal	800055ac <plic_claim>
    800025bc:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800025be:	47a9                	li	a5,10
    800025c0:	00f50963          	beq	a0,a5,800025d2 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    800025c4:	4785                	li	a5,1
    800025c6:	00f50963          	beq	a0,a5,800025d8 <devintr+0x4c>
    return 1;
    800025ca:	4505                	li	a0,1
    } else if(irq){
    800025cc:	e889                	bnez	s1,800025de <devintr+0x52>
    800025ce:	64a2                	ld	s1,8(sp)
    800025d0:	bff9                	j	800025ae <devintr+0x22>
      uartintr();
    800025d2:	bdefe0ef          	jal	800009b0 <uartintr>
    if(irq)
    800025d6:	a819                	j	800025ec <devintr+0x60>
      virtio_disk_intr();
    800025d8:	49a030ef          	jal	80005a72 <virtio_disk_intr>
    if(irq)
    800025dc:	a801                	j	800025ec <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    800025de:	85a6                	mv	a1,s1
    800025e0:	00005517          	auipc	a0,0x5
    800025e4:	ce850513          	addi	a0,a0,-792 # 800072c8 <etext+0x2c8>
    800025e8:	f13fd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    800025ec:	8526                	mv	a0,s1
    800025ee:	7df020ef          	jal	800055cc <plic_complete>
    return 1;
    800025f2:	4505                	li	a0,1
    800025f4:	64a2                	ld	s1,8(sp)
    800025f6:	bf65                	j	800025ae <devintr+0x22>
    clockintr();
    800025f8:	f41ff0ef          	jal	80002538 <clockintr>
    return 2;
    800025fc:	4509                	li	a0,2
    800025fe:	bf45                	j	800025ae <devintr+0x22>

0000000080002600 <usertrap>:
{
    80002600:	1101                	addi	sp,sp,-32
    80002602:	ec06                	sd	ra,24(sp)
    80002604:	e822                	sd	s0,16(sp)
    80002606:	e426                	sd	s1,8(sp)
    80002608:	e04a                	sd	s2,0(sp)
    8000260a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000260c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002610:	1007f793          	andi	a5,a5,256
    80002614:	eba5                	bnez	a5,80002684 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002616:	00003797          	auipc	a5,0x3
    8000261a:	eea78793          	addi	a5,a5,-278 # 80005500 <kernelvec>
    8000261e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002622:	aacff0ef          	jal	800018ce <myproc>
    80002626:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002628:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000262a:	14102773          	csrr	a4,sepc
    8000262e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002630:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002634:	47a1                	li	a5,8
    80002636:	04f70d63          	beq	a4,a5,80002690 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    8000263a:	f53ff0ef          	jal	8000258c <devintr>
    8000263e:	892a                	mv	s2,a0
    80002640:	e945                	bnez	a0,800026f0 <usertrap+0xf0>
    80002642:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002646:	47bd                	li	a5,15
    80002648:	08f70863          	beq	a4,a5,800026d8 <usertrap+0xd8>
    8000264c:	14202773          	csrr	a4,scause
    80002650:	47b5                	li	a5,13
    80002652:	08f70363          	beq	a4,a5,800026d8 <usertrap+0xd8>
    80002656:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000265a:	5890                	lw	a2,48(s1)
    8000265c:	00005517          	auipc	a0,0x5
    80002660:	cac50513          	addi	a0,a0,-852 # 80007308 <etext+0x308>
    80002664:	e97fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002668:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000266c:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002670:	00005517          	auipc	a0,0x5
    80002674:	cc850513          	addi	a0,a0,-824 # 80007338 <etext+0x338>
    80002678:	e83fd0ef          	jal	800004fa <printf>
    setkilled(p);
    8000267c:	8526                	mv	a0,s1
    8000267e:	a6bff0ef          	jal	800020e8 <setkilled>
    80002682:	a035                	j	800026ae <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002684:	00005517          	auipc	a0,0x5
    80002688:	c6450513          	addi	a0,a0,-924 # 800072e8 <etext+0x2e8>
    8000268c:	954fe0ef          	jal	800007e0 <panic>
    if(killed(p))
    80002690:	a7dff0ef          	jal	8000210c <killed>
    80002694:	ed15                	bnez	a0,800026d0 <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002696:	6cb8                	ld	a4,88(s1)
    80002698:	6f1c                	ld	a5,24(a4)
    8000269a:	0791                	addi	a5,a5,4
    8000269c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000269e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800026a2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026a6:	10079073          	csrw	sstatus,a5
    syscall();
    800026aa:	246000ef          	jal	800028f0 <syscall>
  if(killed(p))
    800026ae:	8526                	mv	a0,s1
    800026b0:	a5dff0ef          	jal	8000210c <killed>
    800026b4:	e139                	bnez	a0,800026fa <usertrap+0xfa>
  prepare_return();
    800026b6:	e09ff0ef          	jal	800024be <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800026ba:	68a8                	ld	a0,80(s1)
    800026bc:	8131                	srli	a0,a0,0xc
    800026be:	57fd                	li	a5,-1
    800026c0:	17fe                	slli	a5,a5,0x3f
    800026c2:	8d5d                	or	a0,a0,a5
}
    800026c4:	60e2                	ld	ra,24(sp)
    800026c6:	6442                	ld	s0,16(sp)
    800026c8:	64a2                	ld	s1,8(sp)
    800026ca:	6902                	ld	s2,0(sp)
    800026cc:	6105                	addi	sp,sp,32
    800026ce:	8082                	ret
      kexit(-1);
    800026d0:	557d                	li	a0,-1
    800026d2:	90fff0ef          	jal	80001fe0 <kexit>
    800026d6:	b7c1                	j	80002696 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026d8:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026dc:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    800026e0:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    800026e2:	00163613          	seqz	a2,a2
    800026e6:	68a8                	ld	a0,80(s1)
    800026e8:	e79fe0ef          	jal	80001560 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800026ec:	f169                	bnez	a0,800026ae <usertrap+0xae>
    800026ee:	b7a5                	j	80002656 <usertrap+0x56>
  if(killed(p))
    800026f0:	8526                	mv	a0,s1
    800026f2:	a1bff0ef          	jal	8000210c <killed>
    800026f6:	c511                	beqz	a0,80002702 <usertrap+0x102>
    800026f8:	a011                	j	800026fc <usertrap+0xfc>
    800026fa:	4901                	li	s2,0
    kexit(-1);
    800026fc:	557d                	li	a0,-1
    800026fe:	8e3ff0ef          	jal	80001fe0 <kexit>
  if(which_dev == 2)
    80002702:	4789                	li	a5,2
    80002704:	faf919e3          	bne	s2,a5,800026b6 <usertrap+0xb6>
    yield();
    80002708:	fa0ff0ef          	jal	80001ea8 <yield>
    8000270c:	b76d                	j	800026b6 <usertrap+0xb6>

000000008000270e <kerneltrap>:
{
    8000270e:	7179                	addi	sp,sp,-48
    80002710:	f406                	sd	ra,40(sp)
    80002712:	f022                	sd	s0,32(sp)
    80002714:	ec26                	sd	s1,24(sp)
    80002716:	e84a                	sd	s2,16(sp)
    80002718:	e44e                	sd	s3,8(sp)
    8000271a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000271c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002720:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002724:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002728:	1004f793          	andi	a5,s1,256
    8000272c:	c795                	beqz	a5,80002758 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000272e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002732:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002734:	eb85                	bnez	a5,80002764 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002736:	e57ff0ef          	jal	8000258c <devintr>
    8000273a:	c91d                	beqz	a0,80002770 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    8000273c:	4789                	li	a5,2
    8000273e:	04f50a63          	beq	a0,a5,80002792 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002742:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002746:	10049073          	csrw	sstatus,s1
}
    8000274a:	70a2                	ld	ra,40(sp)
    8000274c:	7402                	ld	s0,32(sp)
    8000274e:	64e2                	ld	s1,24(sp)
    80002750:	6942                	ld	s2,16(sp)
    80002752:	69a2                	ld	s3,8(sp)
    80002754:	6145                	addi	sp,sp,48
    80002756:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002758:	00005517          	auipc	a0,0x5
    8000275c:	c0850513          	addi	a0,a0,-1016 # 80007360 <etext+0x360>
    80002760:	880fe0ef          	jal	800007e0 <panic>
    panic("kerneltrap: interrupts enabled");
    80002764:	00005517          	auipc	a0,0x5
    80002768:	c2450513          	addi	a0,a0,-988 # 80007388 <etext+0x388>
    8000276c:	874fe0ef          	jal	800007e0 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002770:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002774:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002778:	85ce                	mv	a1,s3
    8000277a:	00005517          	auipc	a0,0x5
    8000277e:	c2e50513          	addi	a0,a0,-978 # 800073a8 <etext+0x3a8>
    80002782:	d79fd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    80002786:	00005517          	auipc	a0,0x5
    8000278a:	c4a50513          	addi	a0,a0,-950 # 800073d0 <etext+0x3d0>
    8000278e:	852fe0ef          	jal	800007e0 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002792:	93cff0ef          	jal	800018ce <myproc>
    80002796:	d555                	beqz	a0,80002742 <kerneltrap+0x34>
    yield();
    80002798:	f10ff0ef          	jal	80001ea8 <yield>
    8000279c:	b75d                	j	80002742 <kerneltrap+0x34>

000000008000279e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000279e:	1101                	addi	sp,sp,-32
    800027a0:	ec06                	sd	ra,24(sp)
    800027a2:	e822                	sd	s0,16(sp)
    800027a4:	e426                	sd	s1,8(sp)
    800027a6:	1000                	addi	s0,sp,32
    800027a8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800027aa:	924ff0ef          	jal	800018ce <myproc>
  switch (n) {
    800027ae:	4795                	li	a5,5
    800027b0:	0497e163          	bltu	a5,s1,800027f2 <argraw+0x54>
    800027b4:	048a                	slli	s1,s1,0x2
    800027b6:	00005717          	auipc	a4,0x5
    800027ba:	0f270713          	addi	a4,a4,242 # 800078a8 <states.0+0x30>
    800027be:	94ba                	add	s1,s1,a4
    800027c0:	409c                	lw	a5,0(s1)
    800027c2:	97ba                	add	a5,a5,a4
    800027c4:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800027c6:	6d3c                	ld	a5,88(a0)
    800027c8:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800027ca:	60e2                	ld	ra,24(sp)
    800027cc:	6442                	ld	s0,16(sp)
    800027ce:	64a2                	ld	s1,8(sp)
    800027d0:	6105                	addi	sp,sp,32
    800027d2:	8082                	ret
    return p->trapframe->a1;
    800027d4:	6d3c                	ld	a5,88(a0)
    800027d6:	7fa8                	ld	a0,120(a5)
    800027d8:	bfcd                	j	800027ca <argraw+0x2c>
    return p->trapframe->a2;
    800027da:	6d3c                	ld	a5,88(a0)
    800027dc:	63c8                	ld	a0,128(a5)
    800027de:	b7f5                	j	800027ca <argraw+0x2c>
    return p->trapframe->a3;
    800027e0:	6d3c                	ld	a5,88(a0)
    800027e2:	67c8                	ld	a0,136(a5)
    800027e4:	b7dd                	j	800027ca <argraw+0x2c>
    return p->trapframe->a4;
    800027e6:	6d3c                	ld	a5,88(a0)
    800027e8:	6bc8                	ld	a0,144(a5)
    800027ea:	b7c5                	j	800027ca <argraw+0x2c>
    return p->trapframe->a5;
    800027ec:	6d3c                	ld	a5,88(a0)
    800027ee:	6fc8                	ld	a0,152(a5)
    800027f0:	bfe9                	j	800027ca <argraw+0x2c>
  panic("argraw");
    800027f2:	00005517          	auipc	a0,0x5
    800027f6:	bee50513          	addi	a0,a0,-1042 # 800073e0 <etext+0x3e0>
    800027fa:	fe7fd0ef          	jal	800007e0 <panic>

00000000800027fe <fetchaddr>:
{
    800027fe:	1101                	addi	sp,sp,-32
    80002800:	ec06                	sd	ra,24(sp)
    80002802:	e822                	sd	s0,16(sp)
    80002804:	e426                	sd	s1,8(sp)
    80002806:	e04a                	sd	s2,0(sp)
    80002808:	1000                	addi	s0,sp,32
    8000280a:	84aa                	mv	s1,a0
    8000280c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000280e:	8c0ff0ef          	jal	800018ce <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002812:	653c                	ld	a5,72(a0)
    80002814:	02f4f663          	bgeu	s1,a5,80002840 <fetchaddr+0x42>
    80002818:	00848713          	addi	a4,s1,8
    8000281c:	02e7e463          	bltu	a5,a4,80002844 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002820:	46a1                	li	a3,8
    80002822:	8626                	mv	a2,s1
    80002824:	85ca                	mv	a1,s2
    80002826:	6928                	ld	a0,80(a0)
    80002828:	e9ffe0ef          	jal	800016c6 <copyin>
    8000282c:	00a03533          	snez	a0,a0
    80002830:	40a00533          	neg	a0,a0
}
    80002834:	60e2                	ld	ra,24(sp)
    80002836:	6442                	ld	s0,16(sp)
    80002838:	64a2                	ld	s1,8(sp)
    8000283a:	6902                	ld	s2,0(sp)
    8000283c:	6105                	addi	sp,sp,32
    8000283e:	8082                	ret
    return -1;
    80002840:	557d                	li	a0,-1
    80002842:	bfcd                	j	80002834 <fetchaddr+0x36>
    80002844:	557d                	li	a0,-1
    80002846:	b7fd                	j	80002834 <fetchaddr+0x36>

0000000080002848 <fetchstr>:
{
    80002848:	7179                	addi	sp,sp,-48
    8000284a:	f406                	sd	ra,40(sp)
    8000284c:	f022                	sd	s0,32(sp)
    8000284e:	ec26                	sd	s1,24(sp)
    80002850:	e84a                	sd	s2,16(sp)
    80002852:	e44e                	sd	s3,8(sp)
    80002854:	1800                	addi	s0,sp,48
    80002856:	892a                	mv	s2,a0
    80002858:	84ae                	mv	s1,a1
    8000285a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000285c:	872ff0ef          	jal	800018ce <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002860:	86ce                	mv	a3,s3
    80002862:	864a                	mv	a2,s2
    80002864:	85a6                	mv	a1,s1
    80002866:	6928                	ld	a0,80(a0)
    80002868:	c21fe0ef          	jal	80001488 <copyinstr>
    8000286c:	00054c63          	bltz	a0,80002884 <fetchstr+0x3c>
  return strlen(buf);
    80002870:	8526                	mv	a0,s1
    80002872:	da0fe0ef          	jal	80000e12 <strlen>
}
    80002876:	70a2                	ld	ra,40(sp)
    80002878:	7402                	ld	s0,32(sp)
    8000287a:	64e2                	ld	s1,24(sp)
    8000287c:	6942                	ld	s2,16(sp)
    8000287e:	69a2                	ld	s3,8(sp)
    80002880:	6145                	addi	sp,sp,48
    80002882:	8082                	ret
    return -1;
    80002884:	557d                	li	a0,-1
    80002886:	bfc5                	j	80002876 <fetchstr+0x2e>

0000000080002888 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002888:	1101                	addi	sp,sp,-32
    8000288a:	ec06                	sd	ra,24(sp)
    8000288c:	e822                	sd	s0,16(sp)
    8000288e:	e426                	sd	s1,8(sp)
    80002890:	1000                	addi	s0,sp,32
    80002892:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002894:	f0bff0ef          	jal	8000279e <argraw>
    80002898:	c088                	sw	a0,0(s1)
}
    8000289a:	60e2                	ld	ra,24(sp)
    8000289c:	6442                	ld	s0,16(sp)
    8000289e:	64a2                	ld	s1,8(sp)
    800028a0:	6105                	addi	sp,sp,32
    800028a2:	8082                	ret

00000000800028a4 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800028a4:	1101                	addi	sp,sp,-32
    800028a6:	ec06                	sd	ra,24(sp)
    800028a8:	e822                	sd	s0,16(sp)
    800028aa:	e426                	sd	s1,8(sp)
    800028ac:	1000                	addi	s0,sp,32
    800028ae:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028b0:	eefff0ef          	jal	8000279e <argraw>
    800028b4:	e088                	sd	a0,0(s1)
}
    800028b6:	60e2                	ld	ra,24(sp)
    800028b8:	6442                	ld	s0,16(sp)
    800028ba:	64a2                	ld	s1,8(sp)
    800028bc:	6105                	addi	sp,sp,32
    800028be:	8082                	ret

00000000800028c0 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800028c0:	7179                	addi	sp,sp,-48
    800028c2:	f406                	sd	ra,40(sp)
    800028c4:	f022                	sd	s0,32(sp)
    800028c6:	ec26                	sd	s1,24(sp)
    800028c8:	e84a                	sd	s2,16(sp)
    800028ca:	1800                	addi	s0,sp,48
    800028cc:	84ae                	mv	s1,a1
    800028ce:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800028d0:	fd840593          	addi	a1,s0,-40
    800028d4:	fd1ff0ef          	jal	800028a4 <argaddr>
  return fetchstr(addr, buf, max);
    800028d8:	864a                	mv	a2,s2
    800028da:	85a6                	mv	a1,s1
    800028dc:	fd843503          	ld	a0,-40(s0)
    800028e0:	f69ff0ef          	jal	80002848 <fetchstr>
}
    800028e4:	70a2                	ld	ra,40(sp)
    800028e6:	7402                	ld	s0,32(sp)
    800028e8:	64e2                	ld	s1,24(sp)
    800028ea:	6942                	ld	s2,16(sp)
    800028ec:	6145                	addi	sp,sp,48
    800028ee:	8082                	ret

00000000800028f0 <syscall>:
  [SYS_cps]                "cps",
};

void
syscall(void)
{
    800028f0:	1101                	addi	sp,sp,-32
    800028f2:	ec06                	sd	ra,24(sp)
    800028f4:	e822                	sd	s0,16(sp)
    800028f6:	e426                	sd	s1,8(sp)
    800028f8:	e04a                	sd	s2,0(sp)
    800028fa:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800028fc:	fd3fe0ef          	jal	800018ce <myproc>
    80002900:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002902:	6d3c                	ld	a5,88(a0)
    80002904:	77dc                	ld	a5,168(a5)
    80002906:	0007891b          	sext.w	s2,a5

  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000290a:	37fd                	addiw	a5,a5,-1
    8000290c:	4761                	li	a4,24
    8000290e:	04f76663          	bltu	a4,a5,8000295a <syscall+0x6a>
    80002912:	00391713          	slli	a4,s2,0x3
    80002916:	00005797          	auipc	a5,0x5
    8000291a:	faa78793          	addi	a5,a5,-86 # 800078c0 <syscalls>
    8000291e:	97ba                	add	a5,a5,a4
    80002920:	639c                	ld	a5,0(a5)
    80002922:	cf85                	beqz	a5,8000295a <syscall+0x6a>
    int retval = syscalls[num]();
    80002924:	9782                	jalr	a5
    80002926:	0005069b          	sext.w	a3,a0
    p->trapframe->a0 = retval;
    8000292a:	6cbc                	ld	a5,88(s1)
    8000292c:	fbb4                	sd	a3,112(a5)

    if ((p->tracemask & (1 << num)) && syscall_names[num])
    8000292e:	1684a783          	lw	a5,360(s1)
    80002932:	4127d7bb          	sraw	a5,a5,s2
    80002936:	8b85                	andi	a5,a5,1
    80002938:	cf95                	beqz	a5,80002974 <syscall+0x84>
    8000293a:	090e                	slli	s2,s2,0x3
    8000293c:	00005797          	auipc	a5,0x5
    80002940:	f8478793          	addi	a5,a5,-124 # 800078c0 <syscalls>
    80002944:	97ca                	add	a5,a5,s2
    80002946:	6bf0                	ld	a2,208(a5)
    80002948:	c615                	beqz	a2,80002974 <syscall+0x84>
      printf("%d: syscall %s -> %d\n", p->pid, syscall_names[num], retval);
    8000294a:	588c                	lw	a1,48(s1)
    8000294c:	00005517          	auipc	a0,0x5
    80002950:	a9c50513          	addi	a0,a0,-1380 # 800073e8 <etext+0x3e8>
    80002954:	ba7fd0ef          	jal	800004fa <printf>
    80002958:	a831                	j	80002974 <syscall+0x84>

  } else {
    printf("%d %s: unknown sys call %d\n",
    8000295a:	86ca                	mv	a3,s2
    8000295c:	15848613          	addi	a2,s1,344
    80002960:	588c                	lw	a1,48(s1)
    80002962:	00005517          	auipc	a0,0x5
    80002966:	a9e50513          	addi	a0,a0,-1378 # 80007400 <etext+0x400>
    8000296a:	b91fd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000296e:	6cbc                	ld	a5,88(s1)
    80002970:	577d                	li	a4,-1
    80002972:	fbb8                	sd	a4,112(a5)
  }
}
    80002974:	60e2                	ld	ra,24(sp)
    80002976:	6442                	ld	s0,16(sp)
    80002978:	64a2                	ld	s1,8(sp)
    8000297a:	6902                	ld	s2,0(sp)
    8000297c:	6105                	addi	sp,sp,32
    8000297e:	8082                	ret

0000000080002980 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002980:	1101                	addi	sp,sp,-32
    80002982:	ec06                	sd	ra,24(sp)
    80002984:	e822                	sd	s0,16(sp)
    80002986:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002988:	fec40593          	addi	a1,s0,-20
    8000298c:	4501                	li	a0,0
    8000298e:	efbff0ef          	jal	80002888 <argint>
  kexit(n);
    80002992:	fec42503          	lw	a0,-20(s0)
    80002996:	e4aff0ef          	jal	80001fe0 <kexit>
  return 0;  // not reached
}
    8000299a:	4501                	li	a0,0
    8000299c:	60e2                	ld	ra,24(sp)
    8000299e:	6442                	ld	s0,16(sp)
    800029a0:	6105                	addi	sp,sp,32
    800029a2:	8082                	ret

00000000800029a4 <sys_getpid>:

uint64
sys_getpid(void)
{
    800029a4:	1141                	addi	sp,sp,-16
    800029a6:	e406                	sd	ra,8(sp)
    800029a8:	e022                	sd	s0,0(sp)
    800029aa:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800029ac:	f23fe0ef          	jal	800018ce <myproc>
}
    800029b0:	5908                	lw	a0,48(a0)
    800029b2:	60a2                	ld	ra,8(sp)
    800029b4:	6402                	ld	s0,0(sp)
    800029b6:	0141                	addi	sp,sp,16
    800029b8:	8082                	ret

00000000800029ba <sys_fork>:

uint64
sys_fork(void)
{
    800029ba:	1141                	addi	sp,sp,-16
    800029bc:	e406                	sd	ra,8(sp)
    800029be:	e022                	sd	s0,0(sp)
    800029c0:	0800                	addi	s0,sp,16
  return kfork();
    800029c2:	a5eff0ef          	jal	80001c20 <kfork>
}
    800029c6:	60a2                	ld	ra,8(sp)
    800029c8:	6402                	ld	s0,0(sp)
    800029ca:	0141                	addi	sp,sp,16
    800029cc:	8082                	ret

00000000800029ce <sys_wait>:

uint64
sys_wait(void)
{
    800029ce:	1101                	addi	sp,sp,-32
    800029d0:	ec06                	sd	ra,24(sp)
    800029d2:	e822                	sd	s0,16(sp)
    800029d4:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800029d6:	fe840593          	addi	a1,s0,-24
    800029da:	4501                	li	a0,0
    800029dc:	ec9ff0ef          	jal	800028a4 <argaddr>
  return kwait(p);
    800029e0:	fe843503          	ld	a0,-24(s0)
    800029e4:	f52ff0ef          	jal	80002136 <kwait>
}
    800029e8:	60e2                	ld	ra,24(sp)
    800029ea:	6442                	ld	s0,16(sp)
    800029ec:	6105                	addi	sp,sp,32
    800029ee:	8082                	ret

00000000800029f0 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800029f0:	7179                	addi	sp,sp,-48
    800029f2:	f406                	sd	ra,40(sp)
    800029f4:	f022                	sd	s0,32(sp)
    800029f6:	ec26                	sd	s1,24(sp)
    800029f8:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    800029fa:	fd840593          	addi	a1,s0,-40
    800029fe:	4501                	li	a0,0
    80002a00:	e89ff0ef          	jal	80002888 <argint>
  argint(1, &t);
    80002a04:	fdc40593          	addi	a1,s0,-36
    80002a08:	4505                	li	a0,1
    80002a0a:	e7fff0ef          	jal	80002888 <argint>
  addr = myproc()->sz;
    80002a0e:	ec1fe0ef          	jal	800018ce <myproc>
    80002a12:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002a14:	fdc42703          	lw	a4,-36(s0)
    80002a18:	4785                	li	a5,1
    80002a1a:	02f70163          	beq	a4,a5,80002a3c <sys_sbrk+0x4c>
    80002a1e:	fd842783          	lw	a5,-40(s0)
    80002a22:	0007cd63          	bltz	a5,80002a3c <sys_sbrk+0x4c>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002a26:	97a6                	add	a5,a5,s1
    80002a28:	0297e863          	bltu	a5,s1,80002a58 <sys_sbrk+0x68>
      return -1;
    myproc()->sz += n;
    80002a2c:	ea3fe0ef          	jal	800018ce <myproc>
    80002a30:	fd842703          	lw	a4,-40(s0)
    80002a34:	653c                	ld	a5,72(a0)
    80002a36:	97ba                	add	a5,a5,a4
    80002a38:	e53c                	sd	a5,72(a0)
    80002a3a:	a039                	j	80002a48 <sys_sbrk+0x58>
    if(growproc(n) < 0) {
    80002a3c:	fd842503          	lw	a0,-40(s0)
    80002a40:	990ff0ef          	jal	80001bd0 <growproc>
    80002a44:	00054863          	bltz	a0,80002a54 <sys_sbrk+0x64>
  }
  return addr;
}
    80002a48:	8526                	mv	a0,s1
    80002a4a:	70a2                	ld	ra,40(sp)
    80002a4c:	7402                	ld	s0,32(sp)
    80002a4e:	64e2                	ld	s1,24(sp)
    80002a50:	6145                	addi	sp,sp,48
    80002a52:	8082                	ret
      return -1;
    80002a54:	54fd                	li	s1,-1
    80002a56:	bfcd                	j	80002a48 <sys_sbrk+0x58>
      return -1;
    80002a58:	54fd                	li	s1,-1
    80002a5a:	b7fd                	j	80002a48 <sys_sbrk+0x58>

0000000080002a5c <sys_pause>:

uint64
sys_pause(void)
{
    80002a5c:	7139                	addi	sp,sp,-64
    80002a5e:	fc06                	sd	ra,56(sp)
    80002a60:	f822                	sd	s0,48(sp)
    80002a62:	f04a                	sd	s2,32(sp)
    80002a64:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002a66:	fcc40593          	addi	a1,s0,-52
    80002a6a:	4501                	li	a0,0
    80002a6c:	e1dff0ef          	jal	80002888 <argint>
  if(n < 0)
    80002a70:	fcc42783          	lw	a5,-52(s0)
    80002a74:	0607c763          	bltz	a5,80002ae2 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002a78:	00016517          	auipc	a0,0x16
    80002a7c:	b8050513          	addi	a0,a0,-1152 # 800185f8 <tickslock>
    80002a80:	94efe0ef          	jal	80000bce <acquire>
  ticks0 = ticks;
    80002a84:	00008917          	auipc	s2,0x8
    80002a88:	a4492903          	lw	s2,-1468(s2) # 8000a4c8 <ticks>
  while(ticks - ticks0 < n){
    80002a8c:	fcc42783          	lw	a5,-52(s0)
    80002a90:	cf8d                	beqz	a5,80002aca <sys_pause+0x6e>
    80002a92:	f426                	sd	s1,40(sp)
    80002a94:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002a96:	00016997          	auipc	s3,0x16
    80002a9a:	b6298993          	addi	s3,s3,-1182 # 800185f8 <tickslock>
    80002a9e:	00008497          	auipc	s1,0x8
    80002aa2:	a2a48493          	addi	s1,s1,-1494 # 8000a4c8 <ticks>
    if(killed(myproc())){
    80002aa6:	e29fe0ef          	jal	800018ce <myproc>
    80002aaa:	e62ff0ef          	jal	8000210c <killed>
    80002aae:	ed0d                	bnez	a0,80002ae8 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002ab0:	85ce                	mv	a1,s3
    80002ab2:	8526                	mv	a0,s1
    80002ab4:	c20ff0ef          	jal	80001ed4 <sleep>
  while(ticks - ticks0 < n){
    80002ab8:	409c                	lw	a5,0(s1)
    80002aba:	412787bb          	subw	a5,a5,s2
    80002abe:	fcc42703          	lw	a4,-52(s0)
    80002ac2:	fee7e2e3          	bltu	a5,a4,80002aa6 <sys_pause+0x4a>
    80002ac6:	74a2                	ld	s1,40(sp)
    80002ac8:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002aca:	00016517          	auipc	a0,0x16
    80002ace:	b2e50513          	addi	a0,a0,-1234 # 800185f8 <tickslock>
    80002ad2:	994fe0ef          	jal	80000c66 <release>
  return 0;
    80002ad6:	4501                	li	a0,0
}
    80002ad8:	70e2                	ld	ra,56(sp)
    80002ada:	7442                	ld	s0,48(sp)
    80002adc:	7902                	ld	s2,32(sp)
    80002ade:	6121                	addi	sp,sp,64
    80002ae0:	8082                	ret
    n = 0;
    80002ae2:	fc042623          	sw	zero,-52(s0)
    80002ae6:	bf49                	j	80002a78 <sys_pause+0x1c>
      release(&tickslock);
    80002ae8:	00016517          	auipc	a0,0x16
    80002aec:	b1050513          	addi	a0,a0,-1264 # 800185f8 <tickslock>
    80002af0:	976fe0ef          	jal	80000c66 <release>
      return -1;
    80002af4:	557d                	li	a0,-1
    80002af6:	74a2                	ld	s1,40(sp)
    80002af8:	69e2                	ld	s3,24(sp)
    80002afa:	bff9                	j	80002ad8 <sys_pause+0x7c>

0000000080002afc <sys_kill>:

uint64
sys_kill(void)
{
    80002afc:	1101                	addi	sp,sp,-32
    80002afe:	ec06                	sd	ra,24(sp)
    80002b00:	e822                	sd	s0,16(sp)
    80002b02:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002b04:	fec40593          	addi	a1,s0,-20
    80002b08:	4501                	li	a0,0
    80002b0a:	d7fff0ef          	jal	80002888 <argint>
  return kkill(pid);
    80002b0e:	fec42503          	lw	a0,-20(s0)
    80002b12:	d70ff0ef          	jal	80002082 <kkill>
}
    80002b16:	60e2                	ld	ra,24(sp)
    80002b18:	6442                	ld	s0,16(sp)
    80002b1a:	6105                	addi	sp,sp,32
    80002b1c:	8082                	ret

0000000080002b1e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002b1e:	1101                	addi	sp,sp,-32
    80002b20:	ec06                	sd	ra,24(sp)
    80002b22:	e822                	sd	s0,16(sp)
    80002b24:	e426                	sd	s1,8(sp)
    80002b26:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002b28:	00016517          	auipc	a0,0x16
    80002b2c:	ad050513          	addi	a0,a0,-1328 # 800185f8 <tickslock>
    80002b30:	89efe0ef          	jal	80000bce <acquire>
  xticks = ticks;
    80002b34:	00008497          	auipc	s1,0x8
    80002b38:	9944a483          	lw	s1,-1644(s1) # 8000a4c8 <ticks>
  release(&tickslock);
    80002b3c:	00016517          	auipc	a0,0x16
    80002b40:	abc50513          	addi	a0,a0,-1348 # 800185f8 <tickslock>
    80002b44:	922fe0ef          	jal	80000c66 <release>
  return xticks;
}
    80002b48:	02049513          	slli	a0,s1,0x20
    80002b4c:	9101                	srli	a0,a0,0x20
    80002b4e:	60e2                	ld	ra,24(sp)
    80002b50:	6442                	ld	s0,16(sp)
    80002b52:	64a2                	ld	s1,8(sp)
    80002b54:	6105                	addi	sp,sp,32
    80002b56:	8082                	ret

0000000080002b58 <sys_trace>:


//trace
uint64
sys_trace(void)
{
    80002b58:	1101                	addi	sp,sp,-32
    80002b5a:	ec06                	sd	ra,24(sp)
    80002b5c:	e822                	sd	s0,16(sp)
    80002b5e:	1000                	addi	s0,sp,32
  int mask;

  argint(0, &mask);
    80002b60:	fec40593          	addi	a1,s0,-20
    80002b64:	4501                	li	a0,0
    80002b66:	d23ff0ef          	jal	80002888 <argint>

  struct proc *p = myproc();
    80002b6a:	d65fe0ef          	jal	800018ce <myproc>
  // set the trace mask in the proc structure
  p->tracemask = mask;
    80002b6e:	fec42783          	lw	a5,-20(s0)
    80002b72:	16f52423          	sw	a5,360(a0)

  return 0;
}
    80002b76:	4501                	li	a0,0
    80002b78:	60e2                	ld	ra,24(sp)
    80002b7a:	6442                	ld	s0,16(sp)
    80002b7c:	6105                	addi	sp,sp,32
    80002b7e:	8082                	ret

0000000080002b80 <sys_set_priority>:

//set priority
uint64
sys_set_priority(void)
{
    80002b80:	1101                	addi	sp,sp,-32
    80002b82:	ec06                	sd	ra,24(sp)
    80002b84:	e822                	sd	s0,16(sp)
    80002b86:	1000                	addi	s0,sp,32
  int pid, priority;
  argint(0, &pid);
    80002b88:	fec40593          	addi	a1,s0,-20
    80002b8c:	4501                	li	a0,0
    80002b8e:	cfbff0ef          	jal	80002888 <argint>
  argint(1, &priority);
    80002b92:	fe840593          	addi	a1,s0,-24
    80002b96:	4505                	li	a0,1
    80002b98:	cf1ff0ef          	jal	80002888 <argint>

  if (priority < 0) priority = 0;
    80002b9c:	fe842783          	lw	a5,-24(s0)
    80002ba0:	0207cd63          	bltz	a5,80002bda <sys_set_priority+0x5a>
  if (priority > 39) priority = 39;
    80002ba4:	02700713          	li	a4,39
    80002ba8:	00f75663          	bge	a4,a5,80002bb4 <sys_set_priority+0x34>
    80002bac:	02700793          	li	a5,39
    80002bb0:	fef42423          	sw	a5,-24(s0)

  extern struct proc proc[NPROC];
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++){
    if (p->pid == pid){
    80002bb4:	fec42683          	lw	a3,-20(s0)
  for (p = proc; p < &proc[NPROC]; p++){
    80002bb8:	00010797          	auipc	a5,0x10
    80002bbc:	e4078793          	addi	a5,a5,-448 # 800129f8 <proc>
    80002bc0:	00016617          	auipc	a2,0x16
    80002bc4:	a3860613          	addi	a2,a2,-1480 # 800185f8 <tickslock>
    if (p->pid == pid){
    80002bc8:	5b98                	lw	a4,48(a5)
    80002bca:	00d70b63          	beq	a4,a3,80002be0 <sys_set_priority+0x60>
  for (p = proc; p < &proc[NPROC]; p++){
    80002bce:	17078793          	addi	a5,a5,368
    80002bd2:	fec79be3          	bne	a5,a2,80002bc8 <sys_set_priority+0x48>
      p->nice = priority;
      return 0;
    }
  }
  return -1; //no pid 
    80002bd6:	557d                	li	a0,-1
    80002bd8:	a809                	j	80002bea <sys_set_priority+0x6a>
  if (priority < 0) priority = 0;
    80002bda:	fe042423          	sw	zero,-24(s0)
  if (priority > 39) priority = 39;
    80002bde:	bfd9                	j	80002bb4 <sys_set_priority+0x34>
      p->nice = priority;
    80002be0:	fe842703          	lw	a4,-24(s0)
    80002be4:	16e7a623          	sw	a4,364(a5)
      return 0;
    80002be8:	4501                	li	a0,0
}
    80002bea:	60e2                	ld	ra,24(sp)
    80002bec:	6442                	ld	s0,16(sp)
    80002bee:	6105                	addi	sp,sp,32
    80002bf0:	8082                	ret

0000000080002bf2 <sys_get_priority>:

uint64
sys_get_priority(void)
{
    80002bf2:	1101                	addi	sp,sp,-32
    80002bf4:	ec06                	sd	ra,24(sp)
    80002bf6:	e822                	sd	s0,16(sp)
    80002bf8:	1000                	addi	s0,sp,32
  int pid;
  argint(0, &pid);
    80002bfa:	fec40593          	addi	a1,s0,-20
    80002bfe:	4501                	li	a0,0
    80002c00:	c89ff0ef          	jal	80002888 <argint>

  extern struct proc proc[NPROC];
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++){
    if (p->pid == pid){
    80002c04:	fec42683          	lw	a3,-20(s0)
  for (p = proc; p < &proc[NPROC]; p++){
    80002c08:	00010797          	auipc	a5,0x10
    80002c0c:	df078793          	addi	a5,a5,-528 # 800129f8 <proc>
    80002c10:	00016617          	auipc	a2,0x16
    80002c14:	9e860613          	addi	a2,a2,-1560 # 800185f8 <tickslock>
    if (p->pid == pid){
    80002c18:	5b98                	lw	a4,48(a5)
    80002c1a:	00d70863          	beq	a4,a3,80002c2a <sys_get_priority+0x38>
  for (p = proc; p < &proc[NPROC]; p++){
    80002c1e:	17078793          	addi	a5,a5,368
    80002c22:	fec79be3          	bne	a5,a2,80002c18 <sys_get_priority+0x26>
      return p->nice;
    }
  }
  return -1; //no pid
    80002c26:	557d                	li	a0,-1
    80002c28:	a019                	j	80002c2e <sys_get_priority+0x3c>
      return p->nice;
    80002c2a:	16c7a503          	lw	a0,364(a5)
}
    80002c2e:	60e2                	ld	ra,24(sp)
    80002c30:	6442                	ld	s0,16(sp)
    80002c32:	6105                	addi	sp,sp,32
    80002c34:	8082                	ret

0000000080002c36 <sys_cps>:

uint64
sys_cps(void)
{
    80002c36:	1141                	addi	sp,sp,-16
    80002c38:	e406                	sd	ra,8(sp)
    80002c3a:	e022                	sd	s0,0(sp)
    80002c3c:	0800                	addi	s0,sp,16
  return cps();
    80002c3e:	f2aff0ef          	jal	80002368 <cps>
}
    80002c42:	60a2                	ld	ra,8(sp)
    80002c44:	6402                	ld	s0,0(sp)
    80002c46:	0141                	addi	sp,sp,16
    80002c48:	8082                	ret

0000000080002c4a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002c4a:	7179                	addi	sp,sp,-48
    80002c4c:	f406                	sd	ra,40(sp)
    80002c4e:	f022                	sd	s0,32(sp)
    80002c50:	ec26                	sd	s1,24(sp)
    80002c52:	e84a                	sd	s2,16(sp)
    80002c54:	e44e                	sd	s3,8(sp)
    80002c56:	e052                	sd	s4,0(sp)
    80002c58:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002c5a:	00005597          	auipc	a1,0x5
    80002c5e:	88e58593          	addi	a1,a1,-1906 # 800074e8 <etext+0x4e8>
    80002c62:	00016517          	auipc	a0,0x16
    80002c66:	9ae50513          	addi	a0,a0,-1618 # 80018610 <bcache>
    80002c6a:	ee5fd0ef          	jal	80000b4e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002c6e:	0001e797          	auipc	a5,0x1e
    80002c72:	9a278793          	addi	a5,a5,-1630 # 80020610 <bcache+0x8000>
    80002c76:	0001e717          	auipc	a4,0x1e
    80002c7a:	c0270713          	addi	a4,a4,-1022 # 80020878 <bcache+0x8268>
    80002c7e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002c82:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002c86:	00016497          	auipc	s1,0x16
    80002c8a:	9a248493          	addi	s1,s1,-1630 # 80018628 <bcache+0x18>
    b->next = bcache.head.next;
    80002c8e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002c90:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002c92:	00005a17          	auipc	s4,0x5
    80002c96:	85ea0a13          	addi	s4,s4,-1954 # 800074f0 <etext+0x4f0>
    b->next = bcache.head.next;
    80002c9a:	2b893783          	ld	a5,696(s2)
    80002c9e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002ca0:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002ca4:	85d2                	mv	a1,s4
    80002ca6:	01048513          	addi	a0,s1,16
    80002caa:	322010ef          	jal	80003fcc <initsleeplock>
    bcache.head.next->prev = b;
    80002cae:	2b893783          	ld	a5,696(s2)
    80002cb2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002cb4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002cb8:	45848493          	addi	s1,s1,1112
    80002cbc:	fd349fe3          	bne	s1,s3,80002c9a <binit+0x50>
  }
}
    80002cc0:	70a2                	ld	ra,40(sp)
    80002cc2:	7402                	ld	s0,32(sp)
    80002cc4:	64e2                	ld	s1,24(sp)
    80002cc6:	6942                	ld	s2,16(sp)
    80002cc8:	69a2                	ld	s3,8(sp)
    80002cca:	6a02                	ld	s4,0(sp)
    80002ccc:	6145                	addi	sp,sp,48
    80002cce:	8082                	ret

0000000080002cd0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002cd0:	7179                	addi	sp,sp,-48
    80002cd2:	f406                	sd	ra,40(sp)
    80002cd4:	f022                	sd	s0,32(sp)
    80002cd6:	ec26                	sd	s1,24(sp)
    80002cd8:	e84a                	sd	s2,16(sp)
    80002cda:	e44e                	sd	s3,8(sp)
    80002cdc:	1800                	addi	s0,sp,48
    80002cde:	892a                	mv	s2,a0
    80002ce0:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002ce2:	00016517          	auipc	a0,0x16
    80002ce6:	92e50513          	addi	a0,a0,-1746 # 80018610 <bcache>
    80002cea:	ee5fd0ef          	jal	80000bce <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002cee:	0001e497          	auipc	s1,0x1e
    80002cf2:	bda4b483          	ld	s1,-1062(s1) # 800208c8 <bcache+0x82b8>
    80002cf6:	0001e797          	auipc	a5,0x1e
    80002cfa:	b8278793          	addi	a5,a5,-1150 # 80020878 <bcache+0x8268>
    80002cfe:	02f48b63          	beq	s1,a5,80002d34 <bread+0x64>
    80002d02:	873e                	mv	a4,a5
    80002d04:	a021                	j	80002d0c <bread+0x3c>
    80002d06:	68a4                	ld	s1,80(s1)
    80002d08:	02e48663          	beq	s1,a4,80002d34 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002d0c:	449c                	lw	a5,8(s1)
    80002d0e:	ff279ce3          	bne	a5,s2,80002d06 <bread+0x36>
    80002d12:	44dc                	lw	a5,12(s1)
    80002d14:	ff3799e3          	bne	a5,s3,80002d06 <bread+0x36>
      b->refcnt++;
    80002d18:	40bc                	lw	a5,64(s1)
    80002d1a:	2785                	addiw	a5,a5,1
    80002d1c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d1e:	00016517          	auipc	a0,0x16
    80002d22:	8f250513          	addi	a0,a0,-1806 # 80018610 <bcache>
    80002d26:	f41fd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002d2a:	01048513          	addi	a0,s1,16
    80002d2e:	2d4010ef          	jal	80004002 <acquiresleep>
      return b;
    80002d32:	a889                	j	80002d84 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002d34:	0001e497          	auipc	s1,0x1e
    80002d38:	b8c4b483          	ld	s1,-1140(s1) # 800208c0 <bcache+0x82b0>
    80002d3c:	0001e797          	auipc	a5,0x1e
    80002d40:	b3c78793          	addi	a5,a5,-1220 # 80020878 <bcache+0x8268>
    80002d44:	00f48863          	beq	s1,a5,80002d54 <bread+0x84>
    80002d48:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002d4a:	40bc                	lw	a5,64(s1)
    80002d4c:	cb91                	beqz	a5,80002d60 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002d4e:	64a4                	ld	s1,72(s1)
    80002d50:	fee49de3          	bne	s1,a4,80002d4a <bread+0x7a>
  panic("bget: no buffers");
    80002d54:	00004517          	auipc	a0,0x4
    80002d58:	7a450513          	addi	a0,a0,1956 # 800074f8 <etext+0x4f8>
    80002d5c:	a85fd0ef          	jal	800007e0 <panic>
      b->dev = dev;
    80002d60:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002d64:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002d68:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002d6c:	4785                	li	a5,1
    80002d6e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d70:	00016517          	auipc	a0,0x16
    80002d74:	8a050513          	addi	a0,a0,-1888 # 80018610 <bcache>
    80002d78:	eeffd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002d7c:	01048513          	addi	a0,s1,16
    80002d80:	282010ef          	jal	80004002 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002d84:	409c                	lw	a5,0(s1)
    80002d86:	cb89                	beqz	a5,80002d98 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002d88:	8526                	mv	a0,s1
    80002d8a:	70a2                	ld	ra,40(sp)
    80002d8c:	7402                	ld	s0,32(sp)
    80002d8e:	64e2                	ld	s1,24(sp)
    80002d90:	6942                	ld	s2,16(sp)
    80002d92:	69a2                	ld	s3,8(sp)
    80002d94:	6145                	addi	sp,sp,48
    80002d96:	8082                	ret
    virtio_disk_rw(b, 0);
    80002d98:	4581                	li	a1,0
    80002d9a:	8526                	mv	a0,s1
    80002d9c:	2c5020ef          	jal	80005860 <virtio_disk_rw>
    b->valid = 1;
    80002da0:	4785                	li	a5,1
    80002da2:	c09c                	sw	a5,0(s1)
  return b;
    80002da4:	b7d5                	j	80002d88 <bread+0xb8>

0000000080002da6 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002da6:	1101                	addi	sp,sp,-32
    80002da8:	ec06                	sd	ra,24(sp)
    80002daa:	e822                	sd	s0,16(sp)
    80002dac:	e426                	sd	s1,8(sp)
    80002dae:	1000                	addi	s0,sp,32
    80002db0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002db2:	0541                	addi	a0,a0,16
    80002db4:	2cc010ef          	jal	80004080 <holdingsleep>
    80002db8:	c911                	beqz	a0,80002dcc <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002dba:	4585                	li	a1,1
    80002dbc:	8526                	mv	a0,s1
    80002dbe:	2a3020ef          	jal	80005860 <virtio_disk_rw>
}
    80002dc2:	60e2                	ld	ra,24(sp)
    80002dc4:	6442                	ld	s0,16(sp)
    80002dc6:	64a2                	ld	s1,8(sp)
    80002dc8:	6105                	addi	sp,sp,32
    80002dca:	8082                	ret
    panic("bwrite");
    80002dcc:	00004517          	auipc	a0,0x4
    80002dd0:	74450513          	addi	a0,a0,1860 # 80007510 <etext+0x510>
    80002dd4:	a0dfd0ef          	jal	800007e0 <panic>

0000000080002dd8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002dd8:	1101                	addi	sp,sp,-32
    80002dda:	ec06                	sd	ra,24(sp)
    80002ddc:	e822                	sd	s0,16(sp)
    80002dde:	e426                	sd	s1,8(sp)
    80002de0:	e04a                	sd	s2,0(sp)
    80002de2:	1000                	addi	s0,sp,32
    80002de4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002de6:	01050913          	addi	s2,a0,16
    80002dea:	854a                	mv	a0,s2
    80002dec:	294010ef          	jal	80004080 <holdingsleep>
    80002df0:	c135                	beqz	a0,80002e54 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002df2:	854a                	mv	a0,s2
    80002df4:	254010ef          	jal	80004048 <releasesleep>

  acquire(&bcache.lock);
    80002df8:	00016517          	auipc	a0,0x16
    80002dfc:	81850513          	addi	a0,a0,-2024 # 80018610 <bcache>
    80002e00:	dcffd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002e04:	40bc                	lw	a5,64(s1)
    80002e06:	37fd                	addiw	a5,a5,-1
    80002e08:	0007871b          	sext.w	a4,a5
    80002e0c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002e0e:	e71d                	bnez	a4,80002e3c <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002e10:	68b8                	ld	a4,80(s1)
    80002e12:	64bc                	ld	a5,72(s1)
    80002e14:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002e16:	68b8                	ld	a4,80(s1)
    80002e18:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002e1a:	0001d797          	auipc	a5,0x1d
    80002e1e:	7f678793          	addi	a5,a5,2038 # 80020610 <bcache+0x8000>
    80002e22:	2b87b703          	ld	a4,696(a5)
    80002e26:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002e28:	0001e717          	auipc	a4,0x1e
    80002e2c:	a5070713          	addi	a4,a4,-1456 # 80020878 <bcache+0x8268>
    80002e30:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002e32:	2b87b703          	ld	a4,696(a5)
    80002e36:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002e38:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002e3c:	00015517          	auipc	a0,0x15
    80002e40:	7d450513          	addi	a0,a0,2004 # 80018610 <bcache>
    80002e44:	e23fd0ef          	jal	80000c66 <release>
}
    80002e48:	60e2                	ld	ra,24(sp)
    80002e4a:	6442                	ld	s0,16(sp)
    80002e4c:	64a2                	ld	s1,8(sp)
    80002e4e:	6902                	ld	s2,0(sp)
    80002e50:	6105                	addi	sp,sp,32
    80002e52:	8082                	ret
    panic("brelse");
    80002e54:	00004517          	auipc	a0,0x4
    80002e58:	6c450513          	addi	a0,a0,1732 # 80007518 <etext+0x518>
    80002e5c:	985fd0ef          	jal	800007e0 <panic>

0000000080002e60 <bpin>:

void
bpin(struct buf *b) {
    80002e60:	1101                	addi	sp,sp,-32
    80002e62:	ec06                	sd	ra,24(sp)
    80002e64:	e822                	sd	s0,16(sp)
    80002e66:	e426                	sd	s1,8(sp)
    80002e68:	1000                	addi	s0,sp,32
    80002e6a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e6c:	00015517          	auipc	a0,0x15
    80002e70:	7a450513          	addi	a0,a0,1956 # 80018610 <bcache>
    80002e74:	d5bfd0ef          	jal	80000bce <acquire>
  b->refcnt++;
    80002e78:	40bc                	lw	a5,64(s1)
    80002e7a:	2785                	addiw	a5,a5,1
    80002e7c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e7e:	00015517          	auipc	a0,0x15
    80002e82:	79250513          	addi	a0,a0,1938 # 80018610 <bcache>
    80002e86:	de1fd0ef          	jal	80000c66 <release>
}
    80002e8a:	60e2                	ld	ra,24(sp)
    80002e8c:	6442                	ld	s0,16(sp)
    80002e8e:	64a2                	ld	s1,8(sp)
    80002e90:	6105                	addi	sp,sp,32
    80002e92:	8082                	ret

0000000080002e94 <bunpin>:

void
bunpin(struct buf *b) {
    80002e94:	1101                	addi	sp,sp,-32
    80002e96:	ec06                	sd	ra,24(sp)
    80002e98:	e822                	sd	s0,16(sp)
    80002e9a:	e426                	sd	s1,8(sp)
    80002e9c:	1000                	addi	s0,sp,32
    80002e9e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002ea0:	00015517          	auipc	a0,0x15
    80002ea4:	77050513          	addi	a0,a0,1904 # 80018610 <bcache>
    80002ea8:	d27fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002eac:	40bc                	lw	a5,64(s1)
    80002eae:	37fd                	addiw	a5,a5,-1
    80002eb0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002eb2:	00015517          	auipc	a0,0x15
    80002eb6:	75e50513          	addi	a0,a0,1886 # 80018610 <bcache>
    80002eba:	dadfd0ef          	jal	80000c66 <release>
}
    80002ebe:	60e2                	ld	ra,24(sp)
    80002ec0:	6442                	ld	s0,16(sp)
    80002ec2:	64a2                	ld	s1,8(sp)
    80002ec4:	6105                	addi	sp,sp,32
    80002ec6:	8082                	ret

0000000080002ec8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002ec8:	1101                	addi	sp,sp,-32
    80002eca:	ec06                	sd	ra,24(sp)
    80002ecc:	e822                	sd	s0,16(sp)
    80002ece:	e426                	sd	s1,8(sp)
    80002ed0:	e04a                	sd	s2,0(sp)
    80002ed2:	1000                	addi	s0,sp,32
    80002ed4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002ed6:	00d5d59b          	srliw	a1,a1,0xd
    80002eda:	0001e797          	auipc	a5,0x1e
    80002ede:	e127a783          	lw	a5,-494(a5) # 80020cec <sb+0x1c>
    80002ee2:	9dbd                	addw	a1,a1,a5
    80002ee4:	dedff0ef          	jal	80002cd0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002ee8:	0074f713          	andi	a4,s1,7
    80002eec:	4785                	li	a5,1
    80002eee:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002ef2:	14ce                	slli	s1,s1,0x33
    80002ef4:	90d9                	srli	s1,s1,0x36
    80002ef6:	00950733          	add	a4,a0,s1
    80002efa:	05874703          	lbu	a4,88(a4)
    80002efe:	00e7f6b3          	and	a3,a5,a4
    80002f02:	c29d                	beqz	a3,80002f28 <bfree+0x60>
    80002f04:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002f06:	94aa                	add	s1,s1,a0
    80002f08:	fff7c793          	not	a5,a5
    80002f0c:	8f7d                	and	a4,a4,a5
    80002f0e:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002f12:	7f9000ef          	jal	80003f0a <log_write>
  brelse(bp);
    80002f16:	854a                	mv	a0,s2
    80002f18:	ec1ff0ef          	jal	80002dd8 <brelse>
}
    80002f1c:	60e2                	ld	ra,24(sp)
    80002f1e:	6442                	ld	s0,16(sp)
    80002f20:	64a2                	ld	s1,8(sp)
    80002f22:	6902                	ld	s2,0(sp)
    80002f24:	6105                	addi	sp,sp,32
    80002f26:	8082                	ret
    panic("freeing free block");
    80002f28:	00004517          	auipc	a0,0x4
    80002f2c:	5f850513          	addi	a0,a0,1528 # 80007520 <etext+0x520>
    80002f30:	8b1fd0ef          	jal	800007e0 <panic>

0000000080002f34 <balloc>:
{
    80002f34:	711d                	addi	sp,sp,-96
    80002f36:	ec86                	sd	ra,88(sp)
    80002f38:	e8a2                	sd	s0,80(sp)
    80002f3a:	e4a6                	sd	s1,72(sp)
    80002f3c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002f3e:	0001e797          	auipc	a5,0x1e
    80002f42:	d967a783          	lw	a5,-618(a5) # 80020cd4 <sb+0x4>
    80002f46:	0e078f63          	beqz	a5,80003044 <balloc+0x110>
    80002f4a:	e0ca                	sd	s2,64(sp)
    80002f4c:	fc4e                	sd	s3,56(sp)
    80002f4e:	f852                	sd	s4,48(sp)
    80002f50:	f456                	sd	s5,40(sp)
    80002f52:	f05a                	sd	s6,32(sp)
    80002f54:	ec5e                	sd	s7,24(sp)
    80002f56:	e862                	sd	s8,16(sp)
    80002f58:	e466                	sd	s9,8(sp)
    80002f5a:	8baa                	mv	s7,a0
    80002f5c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002f5e:	0001eb17          	auipc	s6,0x1e
    80002f62:	d72b0b13          	addi	s6,s6,-654 # 80020cd0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f66:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002f68:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f6a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002f6c:	6c89                	lui	s9,0x2
    80002f6e:	a0b5                	j	80002fda <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002f70:	97ca                	add	a5,a5,s2
    80002f72:	8e55                	or	a2,a2,a3
    80002f74:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002f78:	854a                	mv	a0,s2
    80002f7a:	791000ef          	jal	80003f0a <log_write>
        brelse(bp);
    80002f7e:	854a                	mv	a0,s2
    80002f80:	e59ff0ef          	jal	80002dd8 <brelse>
  bp = bread(dev, bno);
    80002f84:	85a6                	mv	a1,s1
    80002f86:	855e                	mv	a0,s7
    80002f88:	d49ff0ef          	jal	80002cd0 <bread>
    80002f8c:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002f8e:	40000613          	li	a2,1024
    80002f92:	4581                	li	a1,0
    80002f94:	05850513          	addi	a0,a0,88
    80002f98:	d0bfd0ef          	jal	80000ca2 <memset>
  log_write(bp);
    80002f9c:	854a                	mv	a0,s2
    80002f9e:	76d000ef          	jal	80003f0a <log_write>
  brelse(bp);
    80002fa2:	854a                	mv	a0,s2
    80002fa4:	e35ff0ef          	jal	80002dd8 <brelse>
}
    80002fa8:	6906                	ld	s2,64(sp)
    80002faa:	79e2                	ld	s3,56(sp)
    80002fac:	7a42                	ld	s4,48(sp)
    80002fae:	7aa2                	ld	s5,40(sp)
    80002fb0:	7b02                	ld	s6,32(sp)
    80002fb2:	6be2                	ld	s7,24(sp)
    80002fb4:	6c42                	ld	s8,16(sp)
    80002fb6:	6ca2                	ld	s9,8(sp)
}
    80002fb8:	8526                	mv	a0,s1
    80002fba:	60e6                	ld	ra,88(sp)
    80002fbc:	6446                	ld	s0,80(sp)
    80002fbe:	64a6                	ld	s1,72(sp)
    80002fc0:	6125                	addi	sp,sp,96
    80002fc2:	8082                	ret
    brelse(bp);
    80002fc4:	854a                	mv	a0,s2
    80002fc6:	e13ff0ef          	jal	80002dd8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002fca:	015c87bb          	addw	a5,s9,s5
    80002fce:	00078a9b          	sext.w	s5,a5
    80002fd2:	004b2703          	lw	a4,4(s6)
    80002fd6:	04eaff63          	bgeu	s5,a4,80003034 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002fda:	41fad79b          	sraiw	a5,s5,0x1f
    80002fde:	0137d79b          	srliw	a5,a5,0x13
    80002fe2:	015787bb          	addw	a5,a5,s5
    80002fe6:	40d7d79b          	sraiw	a5,a5,0xd
    80002fea:	01cb2583          	lw	a1,28(s6)
    80002fee:	9dbd                	addw	a1,a1,a5
    80002ff0:	855e                	mv	a0,s7
    80002ff2:	cdfff0ef          	jal	80002cd0 <bread>
    80002ff6:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002ff8:	004b2503          	lw	a0,4(s6)
    80002ffc:	000a849b          	sext.w	s1,s5
    80003000:	8762                	mv	a4,s8
    80003002:	fca4f1e3          	bgeu	s1,a0,80002fc4 <balloc+0x90>
      m = 1 << (bi % 8);
    80003006:	00777693          	andi	a3,a4,7
    8000300a:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000300e:	41f7579b          	sraiw	a5,a4,0x1f
    80003012:	01d7d79b          	srliw	a5,a5,0x1d
    80003016:	9fb9                	addw	a5,a5,a4
    80003018:	4037d79b          	sraiw	a5,a5,0x3
    8000301c:	00f90633          	add	a2,s2,a5
    80003020:	05864603          	lbu	a2,88(a2)
    80003024:	00c6f5b3          	and	a1,a3,a2
    80003028:	d5a1                	beqz	a1,80002f70 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000302a:	2705                	addiw	a4,a4,1
    8000302c:	2485                	addiw	s1,s1,1
    8000302e:	fd471ae3          	bne	a4,s4,80003002 <balloc+0xce>
    80003032:	bf49                	j	80002fc4 <balloc+0x90>
    80003034:	6906                	ld	s2,64(sp)
    80003036:	79e2                	ld	s3,56(sp)
    80003038:	7a42                	ld	s4,48(sp)
    8000303a:	7aa2                	ld	s5,40(sp)
    8000303c:	7b02                	ld	s6,32(sp)
    8000303e:	6be2                	ld	s7,24(sp)
    80003040:	6c42                	ld	s8,16(sp)
    80003042:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80003044:	00004517          	auipc	a0,0x4
    80003048:	4f450513          	addi	a0,a0,1268 # 80007538 <etext+0x538>
    8000304c:	caefd0ef          	jal	800004fa <printf>
  return 0;
    80003050:	4481                	li	s1,0
    80003052:	b79d                	j	80002fb8 <balloc+0x84>

0000000080003054 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003054:	7179                	addi	sp,sp,-48
    80003056:	f406                	sd	ra,40(sp)
    80003058:	f022                	sd	s0,32(sp)
    8000305a:	ec26                	sd	s1,24(sp)
    8000305c:	e84a                	sd	s2,16(sp)
    8000305e:	e44e                	sd	s3,8(sp)
    80003060:	1800                	addi	s0,sp,48
    80003062:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003064:	47ad                	li	a5,11
    80003066:	02b7e663          	bltu	a5,a1,80003092 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    8000306a:	02059793          	slli	a5,a1,0x20
    8000306e:	01e7d593          	srli	a1,a5,0x1e
    80003072:	00b504b3          	add	s1,a0,a1
    80003076:	0504a903          	lw	s2,80(s1)
    8000307a:	06091a63          	bnez	s2,800030ee <bmap+0x9a>
      addr = balloc(ip->dev);
    8000307e:	4108                	lw	a0,0(a0)
    80003080:	eb5ff0ef          	jal	80002f34 <balloc>
    80003084:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003088:	06090363          	beqz	s2,800030ee <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    8000308c:	0524a823          	sw	s2,80(s1)
    80003090:	a8b9                	j	800030ee <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003092:	ff45849b          	addiw	s1,a1,-12
    80003096:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000309a:	0ff00793          	li	a5,255
    8000309e:	06e7ee63          	bltu	a5,a4,8000311a <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800030a2:	08052903          	lw	s2,128(a0)
    800030a6:	00091d63          	bnez	s2,800030c0 <bmap+0x6c>
      addr = balloc(ip->dev);
    800030aa:	4108                	lw	a0,0(a0)
    800030ac:	e89ff0ef          	jal	80002f34 <balloc>
    800030b0:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800030b4:	02090d63          	beqz	s2,800030ee <bmap+0x9a>
    800030b8:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800030ba:	0929a023          	sw	s2,128(s3)
    800030be:	a011                	j	800030c2 <bmap+0x6e>
    800030c0:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800030c2:	85ca                	mv	a1,s2
    800030c4:	0009a503          	lw	a0,0(s3)
    800030c8:	c09ff0ef          	jal	80002cd0 <bread>
    800030cc:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800030ce:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800030d2:	02049713          	slli	a4,s1,0x20
    800030d6:	01e75593          	srli	a1,a4,0x1e
    800030da:	00b784b3          	add	s1,a5,a1
    800030de:	0004a903          	lw	s2,0(s1)
    800030e2:	00090e63          	beqz	s2,800030fe <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800030e6:	8552                	mv	a0,s4
    800030e8:	cf1ff0ef          	jal	80002dd8 <brelse>
    return addr;
    800030ec:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800030ee:	854a                	mv	a0,s2
    800030f0:	70a2                	ld	ra,40(sp)
    800030f2:	7402                	ld	s0,32(sp)
    800030f4:	64e2                	ld	s1,24(sp)
    800030f6:	6942                	ld	s2,16(sp)
    800030f8:	69a2                	ld	s3,8(sp)
    800030fa:	6145                	addi	sp,sp,48
    800030fc:	8082                	ret
      addr = balloc(ip->dev);
    800030fe:	0009a503          	lw	a0,0(s3)
    80003102:	e33ff0ef          	jal	80002f34 <balloc>
    80003106:	0005091b          	sext.w	s2,a0
      if(addr){
    8000310a:	fc090ee3          	beqz	s2,800030e6 <bmap+0x92>
        a[bn] = addr;
    8000310e:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003112:	8552                	mv	a0,s4
    80003114:	5f7000ef          	jal	80003f0a <log_write>
    80003118:	b7f9                	j	800030e6 <bmap+0x92>
    8000311a:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000311c:	00004517          	auipc	a0,0x4
    80003120:	43450513          	addi	a0,a0,1076 # 80007550 <etext+0x550>
    80003124:	ebcfd0ef          	jal	800007e0 <panic>

0000000080003128 <iget>:
{
    80003128:	7179                	addi	sp,sp,-48
    8000312a:	f406                	sd	ra,40(sp)
    8000312c:	f022                	sd	s0,32(sp)
    8000312e:	ec26                	sd	s1,24(sp)
    80003130:	e84a                	sd	s2,16(sp)
    80003132:	e44e                	sd	s3,8(sp)
    80003134:	e052                	sd	s4,0(sp)
    80003136:	1800                	addi	s0,sp,48
    80003138:	89aa                	mv	s3,a0
    8000313a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000313c:	0001e517          	auipc	a0,0x1e
    80003140:	bb450513          	addi	a0,a0,-1100 # 80020cf0 <itable>
    80003144:	a8bfd0ef          	jal	80000bce <acquire>
  empty = 0;
    80003148:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000314a:	0001e497          	auipc	s1,0x1e
    8000314e:	bbe48493          	addi	s1,s1,-1090 # 80020d08 <itable+0x18>
    80003152:	0001f697          	auipc	a3,0x1f
    80003156:	64668693          	addi	a3,a3,1606 # 80022798 <log>
    8000315a:	a039                	j	80003168 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000315c:	02090963          	beqz	s2,8000318e <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003160:	08848493          	addi	s1,s1,136
    80003164:	02d48863          	beq	s1,a3,80003194 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003168:	449c                	lw	a5,8(s1)
    8000316a:	fef059e3          	blez	a5,8000315c <iget+0x34>
    8000316e:	4098                	lw	a4,0(s1)
    80003170:	ff3716e3          	bne	a4,s3,8000315c <iget+0x34>
    80003174:	40d8                	lw	a4,4(s1)
    80003176:	ff4713e3          	bne	a4,s4,8000315c <iget+0x34>
      ip->ref++;
    8000317a:	2785                	addiw	a5,a5,1
    8000317c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000317e:	0001e517          	auipc	a0,0x1e
    80003182:	b7250513          	addi	a0,a0,-1166 # 80020cf0 <itable>
    80003186:	ae1fd0ef          	jal	80000c66 <release>
      return ip;
    8000318a:	8926                	mv	s2,s1
    8000318c:	a02d                	j	800031b6 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000318e:	fbe9                	bnez	a5,80003160 <iget+0x38>
      empty = ip;
    80003190:	8926                	mv	s2,s1
    80003192:	b7f9                	j	80003160 <iget+0x38>
  if(empty == 0)
    80003194:	02090a63          	beqz	s2,800031c8 <iget+0xa0>
  ip->dev = dev;
    80003198:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000319c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800031a0:	4785                	li	a5,1
    800031a2:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800031a6:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800031aa:	0001e517          	auipc	a0,0x1e
    800031ae:	b4650513          	addi	a0,a0,-1210 # 80020cf0 <itable>
    800031b2:	ab5fd0ef          	jal	80000c66 <release>
}
    800031b6:	854a                	mv	a0,s2
    800031b8:	70a2                	ld	ra,40(sp)
    800031ba:	7402                	ld	s0,32(sp)
    800031bc:	64e2                	ld	s1,24(sp)
    800031be:	6942                	ld	s2,16(sp)
    800031c0:	69a2                	ld	s3,8(sp)
    800031c2:	6a02                	ld	s4,0(sp)
    800031c4:	6145                	addi	sp,sp,48
    800031c6:	8082                	ret
    panic("iget: no inodes");
    800031c8:	00004517          	auipc	a0,0x4
    800031cc:	3a050513          	addi	a0,a0,928 # 80007568 <etext+0x568>
    800031d0:	e10fd0ef          	jal	800007e0 <panic>

00000000800031d4 <iinit>:
{
    800031d4:	7179                	addi	sp,sp,-48
    800031d6:	f406                	sd	ra,40(sp)
    800031d8:	f022                	sd	s0,32(sp)
    800031da:	ec26                	sd	s1,24(sp)
    800031dc:	e84a                	sd	s2,16(sp)
    800031de:	e44e                	sd	s3,8(sp)
    800031e0:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800031e2:	00004597          	auipc	a1,0x4
    800031e6:	39658593          	addi	a1,a1,918 # 80007578 <etext+0x578>
    800031ea:	0001e517          	auipc	a0,0x1e
    800031ee:	b0650513          	addi	a0,a0,-1274 # 80020cf0 <itable>
    800031f2:	95dfd0ef          	jal	80000b4e <initlock>
  for(i = 0; i < NINODE; i++) {
    800031f6:	0001e497          	auipc	s1,0x1e
    800031fa:	b2248493          	addi	s1,s1,-1246 # 80020d18 <itable+0x28>
    800031fe:	0001f997          	auipc	s3,0x1f
    80003202:	5aa98993          	addi	s3,s3,1450 # 800227a8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003206:	00004917          	auipc	s2,0x4
    8000320a:	37a90913          	addi	s2,s2,890 # 80007580 <etext+0x580>
    8000320e:	85ca                	mv	a1,s2
    80003210:	8526                	mv	a0,s1
    80003212:	5bb000ef          	jal	80003fcc <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003216:	08848493          	addi	s1,s1,136
    8000321a:	ff349ae3          	bne	s1,s3,8000320e <iinit+0x3a>
}
    8000321e:	70a2                	ld	ra,40(sp)
    80003220:	7402                	ld	s0,32(sp)
    80003222:	64e2                	ld	s1,24(sp)
    80003224:	6942                	ld	s2,16(sp)
    80003226:	69a2                	ld	s3,8(sp)
    80003228:	6145                	addi	sp,sp,48
    8000322a:	8082                	ret

000000008000322c <ialloc>:
{
    8000322c:	7139                	addi	sp,sp,-64
    8000322e:	fc06                	sd	ra,56(sp)
    80003230:	f822                	sd	s0,48(sp)
    80003232:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003234:	0001e717          	auipc	a4,0x1e
    80003238:	aa872703          	lw	a4,-1368(a4) # 80020cdc <sb+0xc>
    8000323c:	4785                	li	a5,1
    8000323e:	06e7f063          	bgeu	a5,a4,8000329e <ialloc+0x72>
    80003242:	f426                	sd	s1,40(sp)
    80003244:	f04a                	sd	s2,32(sp)
    80003246:	ec4e                	sd	s3,24(sp)
    80003248:	e852                	sd	s4,16(sp)
    8000324a:	e456                	sd	s5,8(sp)
    8000324c:	e05a                	sd	s6,0(sp)
    8000324e:	8aaa                	mv	s5,a0
    80003250:	8b2e                	mv	s6,a1
    80003252:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003254:	0001ea17          	auipc	s4,0x1e
    80003258:	a7ca0a13          	addi	s4,s4,-1412 # 80020cd0 <sb>
    8000325c:	00495593          	srli	a1,s2,0x4
    80003260:	018a2783          	lw	a5,24(s4)
    80003264:	9dbd                	addw	a1,a1,a5
    80003266:	8556                	mv	a0,s5
    80003268:	a69ff0ef          	jal	80002cd0 <bread>
    8000326c:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000326e:	05850993          	addi	s3,a0,88
    80003272:	00f97793          	andi	a5,s2,15
    80003276:	079a                	slli	a5,a5,0x6
    80003278:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000327a:	00099783          	lh	a5,0(s3)
    8000327e:	cb9d                	beqz	a5,800032b4 <ialloc+0x88>
    brelse(bp);
    80003280:	b59ff0ef          	jal	80002dd8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003284:	0905                	addi	s2,s2,1
    80003286:	00ca2703          	lw	a4,12(s4)
    8000328a:	0009079b          	sext.w	a5,s2
    8000328e:	fce7e7e3          	bltu	a5,a4,8000325c <ialloc+0x30>
    80003292:	74a2                	ld	s1,40(sp)
    80003294:	7902                	ld	s2,32(sp)
    80003296:	69e2                	ld	s3,24(sp)
    80003298:	6a42                	ld	s4,16(sp)
    8000329a:	6aa2                	ld	s5,8(sp)
    8000329c:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000329e:	00004517          	auipc	a0,0x4
    800032a2:	2ea50513          	addi	a0,a0,746 # 80007588 <etext+0x588>
    800032a6:	a54fd0ef          	jal	800004fa <printf>
  return 0;
    800032aa:	4501                	li	a0,0
}
    800032ac:	70e2                	ld	ra,56(sp)
    800032ae:	7442                	ld	s0,48(sp)
    800032b0:	6121                	addi	sp,sp,64
    800032b2:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800032b4:	04000613          	li	a2,64
    800032b8:	4581                	li	a1,0
    800032ba:	854e                	mv	a0,s3
    800032bc:	9e7fd0ef          	jal	80000ca2 <memset>
      dip->type = type;
    800032c0:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800032c4:	8526                	mv	a0,s1
    800032c6:	445000ef          	jal	80003f0a <log_write>
      brelse(bp);
    800032ca:	8526                	mv	a0,s1
    800032cc:	b0dff0ef          	jal	80002dd8 <brelse>
      return iget(dev, inum);
    800032d0:	0009059b          	sext.w	a1,s2
    800032d4:	8556                	mv	a0,s5
    800032d6:	e53ff0ef          	jal	80003128 <iget>
    800032da:	74a2                	ld	s1,40(sp)
    800032dc:	7902                	ld	s2,32(sp)
    800032de:	69e2                	ld	s3,24(sp)
    800032e0:	6a42                	ld	s4,16(sp)
    800032e2:	6aa2                	ld	s5,8(sp)
    800032e4:	6b02                	ld	s6,0(sp)
    800032e6:	b7d9                	j	800032ac <ialloc+0x80>

00000000800032e8 <iupdate>:
{
    800032e8:	1101                	addi	sp,sp,-32
    800032ea:	ec06                	sd	ra,24(sp)
    800032ec:	e822                	sd	s0,16(sp)
    800032ee:	e426                	sd	s1,8(sp)
    800032f0:	e04a                	sd	s2,0(sp)
    800032f2:	1000                	addi	s0,sp,32
    800032f4:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800032f6:	415c                	lw	a5,4(a0)
    800032f8:	0047d79b          	srliw	a5,a5,0x4
    800032fc:	0001e597          	auipc	a1,0x1e
    80003300:	9ec5a583          	lw	a1,-1556(a1) # 80020ce8 <sb+0x18>
    80003304:	9dbd                	addw	a1,a1,a5
    80003306:	4108                	lw	a0,0(a0)
    80003308:	9c9ff0ef          	jal	80002cd0 <bread>
    8000330c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000330e:	05850793          	addi	a5,a0,88
    80003312:	40d8                	lw	a4,4(s1)
    80003314:	8b3d                	andi	a4,a4,15
    80003316:	071a                	slli	a4,a4,0x6
    80003318:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000331a:	04449703          	lh	a4,68(s1)
    8000331e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003322:	04649703          	lh	a4,70(s1)
    80003326:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000332a:	04849703          	lh	a4,72(s1)
    8000332e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003332:	04a49703          	lh	a4,74(s1)
    80003336:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000333a:	44f8                	lw	a4,76(s1)
    8000333c:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000333e:	03400613          	li	a2,52
    80003342:	05048593          	addi	a1,s1,80
    80003346:	00c78513          	addi	a0,a5,12
    8000334a:	9b5fd0ef          	jal	80000cfe <memmove>
  log_write(bp);
    8000334e:	854a                	mv	a0,s2
    80003350:	3bb000ef          	jal	80003f0a <log_write>
  brelse(bp);
    80003354:	854a                	mv	a0,s2
    80003356:	a83ff0ef          	jal	80002dd8 <brelse>
}
    8000335a:	60e2                	ld	ra,24(sp)
    8000335c:	6442                	ld	s0,16(sp)
    8000335e:	64a2                	ld	s1,8(sp)
    80003360:	6902                	ld	s2,0(sp)
    80003362:	6105                	addi	sp,sp,32
    80003364:	8082                	ret

0000000080003366 <idup>:
{
    80003366:	1101                	addi	sp,sp,-32
    80003368:	ec06                	sd	ra,24(sp)
    8000336a:	e822                	sd	s0,16(sp)
    8000336c:	e426                	sd	s1,8(sp)
    8000336e:	1000                	addi	s0,sp,32
    80003370:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003372:	0001e517          	auipc	a0,0x1e
    80003376:	97e50513          	addi	a0,a0,-1666 # 80020cf0 <itable>
    8000337a:	855fd0ef          	jal	80000bce <acquire>
  ip->ref++;
    8000337e:	449c                	lw	a5,8(s1)
    80003380:	2785                	addiw	a5,a5,1
    80003382:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003384:	0001e517          	auipc	a0,0x1e
    80003388:	96c50513          	addi	a0,a0,-1684 # 80020cf0 <itable>
    8000338c:	8dbfd0ef          	jal	80000c66 <release>
}
    80003390:	8526                	mv	a0,s1
    80003392:	60e2                	ld	ra,24(sp)
    80003394:	6442                	ld	s0,16(sp)
    80003396:	64a2                	ld	s1,8(sp)
    80003398:	6105                	addi	sp,sp,32
    8000339a:	8082                	ret

000000008000339c <ilock>:
{
    8000339c:	1101                	addi	sp,sp,-32
    8000339e:	ec06                	sd	ra,24(sp)
    800033a0:	e822                	sd	s0,16(sp)
    800033a2:	e426                	sd	s1,8(sp)
    800033a4:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800033a6:	cd19                	beqz	a0,800033c4 <ilock+0x28>
    800033a8:	84aa                	mv	s1,a0
    800033aa:	451c                	lw	a5,8(a0)
    800033ac:	00f05c63          	blez	a5,800033c4 <ilock+0x28>
  acquiresleep(&ip->lock);
    800033b0:	0541                	addi	a0,a0,16
    800033b2:	451000ef          	jal	80004002 <acquiresleep>
  if(ip->valid == 0){
    800033b6:	40bc                	lw	a5,64(s1)
    800033b8:	cf89                	beqz	a5,800033d2 <ilock+0x36>
}
    800033ba:	60e2                	ld	ra,24(sp)
    800033bc:	6442                	ld	s0,16(sp)
    800033be:	64a2                	ld	s1,8(sp)
    800033c0:	6105                	addi	sp,sp,32
    800033c2:	8082                	ret
    800033c4:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800033c6:	00004517          	auipc	a0,0x4
    800033ca:	1da50513          	addi	a0,a0,474 # 800075a0 <etext+0x5a0>
    800033ce:	c12fd0ef          	jal	800007e0 <panic>
    800033d2:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800033d4:	40dc                	lw	a5,4(s1)
    800033d6:	0047d79b          	srliw	a5,a5,0x4
    800033da:	0001e597          	auipc	a1,0x1e
    800033de:	90e5a583          	lw	a1,-1778(a1) # 80020ce8 <sb+0x18>
    800033e2:	9dbd                	addw	a1,a1,a5
    800033e4:	4088                	lw	a0,0(s1)
    800033e6:	8ebff0ef          	jal	80002cd0 <bread>
    800033ea:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800033ec:	05850593          	addi	a1,a0,88
    800033f0:	40dc                	lw	a5,4(s1)
    800033f2:	8bbd                	andi	a5,a5,15
    800033f4:	079a                	slli	a5,a5,0x6
    800033f6:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800033f8:	00059783          	lh	a5,0(a1)
    800033fc:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003400:	00259783          	lh	a5,2(a1)
    80003404:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003408:	00459783          	lh	a5,4(a1)
    8000340c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003410:	00659783          	lh	a5,6(a1)
    80003414:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003418:	459c                	lw	a5,8(a1)
    8000341a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000341c:	03400613          	li	a2,52
    80003420:	05b1                	addi	a1,a1,12
    80003422:	05048513          	addi	a0,s1,80
    80003426:	8d9fd0ef          	jal	80000cfe <memmove>
    brelse(bp);
    8000342a:	854a                	mv	a0,s2
    8000342c:	9adff0ef          	jal	80002dd8 <brelse>
    ip->valid = 1;
    80003430:	4785                	li	a5,1
    80003432:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003434:	04449783          	lh	a5,68(s1)
    80003438:	c399                	beqz	a5,8000343e <ilock+0xa2>
    8000343a:	6902                	ld	s2,0(sp)
    8000343c:	bfbd                	j	800033ba <ilock+0x1e>
      panic("ilock: no type");
    8000343e:	00004517          	auipc	a0,0x4
    80003442:	16a50513          	addi	a0,a0,362 # 800075a8 <etext+0x5a8>
    80003446:	b9afd0ef          	jal	800007e0 <panic>

000000008000344a <iunlock>:
{
    8000344a:	1101                	addi	sp,sp,-32
    8000344c:	ec06                	sd	ra,24(sp)
    8000344e:	e822                	sd	s0,16(sp)
    80003450:	e426                	sd	s1,8(sp)
    80003452:	e04a                	sd	s2,0(sp)
    80003454:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003456:	c505                	beqz	a0,8000347e <iunlock+0x34>
    80003458:	84aa                	mv	s1,a0
    8000345a:	01050913          	addi	s2,a0,16
    8000345e:	854a                	mv	a0,s2
    80003460:	421000ef          	jal	80004080 <holdingsleep>
    80003464:	cd09                	beqz	a0,8000347e <iunlock+0x34>
    80003466:	449c                	lw	a5,8(s1)
    80003468:	00f05b63          	blez	a5,8000347e <iunlock+0x34>
  releasesleep(&ip->lock);
    8000346c:	854a                	mv	a0,s2
    8000346e:	3db000ef          	jal	80004048 <releasesleep>
}
    80003472:	60e2                	ld	ra,24(sp)
    80003474:	6442                	ld	s0,16(sp)
    80003476:	64a2                	ld	s1,8(sp)
    80003478:	6902                	ld	s2,0(sp)
    8000347a:	6105                	addi	sp,sp,32
    8000347c:	8082                	ret
    panic("iunlock");
    8000347e:	00004517          	auipc	a0,0x4
    80003482:	13a50513          	addi	a0,a0,314 # 800075b8 <etext+0x5b8>
    80003486:	b5afd0ef          	jal	800007e0 <panic>

000000008000348a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000348a:	7179                	addi	sp,sp,-48
    8000348c:	f406                	sd	ra,40(sp)
    8000348e:	f022                	sd	s0,32(sp)
    80003490:	ec26                	sd	s1,24(sp)
    80003492:	e84a                	sd	s2,16(sp)
    80003494:	e44e                	sd	s3,8(sp)
    80003496:	1800                	addi	s0,sp,48
    80003498:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000349a:	05050493          	addi	s1,a0,80
    8000349e:	08050913          	addi	s2,a0,128
    800034a2:	a021                	j	800034aa <itrunc+0x20>
    800034a4:	0491                	addi	s1,s1,4
    800034a6:	01248b63          	beq	s1,s2,800034bc <itrunc+0x32>
    if(ip->addrs[i]){
    800034aa:	408c                	lw	a1,0(s1)
    800034ac:	dde5                	beqz	a1,800034a4 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800034ae:	0009a503          	lw	a0,0(s3)
    800034b2:	a17ff0ef          	jal	80002ec8 <bfree>
      ip->addrs[i] = 0;
    800034b6:	0004a023          	sw	zero,0(s1)
    800034ba:	b7ed                	j	800034a4 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800034bc:	0809a583          	lw	a1,128(s3)
    800034c0:	ed89                	bnez	a1,800034da <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800034c2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800034c6:	854e                	mv	a0,s3
    800034c8:	e21ff0ef          	jal	800032e8 <iupdate>
}
    800034cc:	70a2                	ld	ra,40(sp)
    800034ce:	7402                	ld	s0,32(sp)
    800034d0:	64e2                	ld	s1,24(sp)
    800034d2:	6942                	ld	s2,16(sp)
    800034d4:	69a2                	ld	s3,8(sp)
    800034d6:	6145                	addi	sp,sp,48
    800034d8:	8082                	ret
    800034da:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800034dc:	0009a503          	lw	a0,0(s3)
    800034e0:	ff0ff0ef          	jal	80002cd0 <bread>
    800034e4:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800034e6:	05850493          	addi	s1,a0,88
    800034ea:	45850913          	addi	s2,a0,1112
    800034ee:	a021                	j	800034f6 <itrunc+0x6c>
    800034f0:	0491                	addi	s1,s1,4
    800034f2:	01248963          	beq	s1,s2,80003504 <itrunc+0x7a>
      if(a[j])
    800034f6:	408c                	lw	a1,0(s1)
    800034f8:	dde5                	beqz	a1,800034f0 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800034fa:	0009a503          	lw	a0,0(s3)
    800034fe:	9cbff0ef          	jal	80002ec8 <bfree>
    80003502:	b7fd                	j	800034f0 <itrunc+0x66>
    brelse(bp);
    80003504:	8552                	mv	a0,s4
    80003506:	8d3ff0ef          	jal	80002dd8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000350a:	0809a583          	lw	a1,128(s3)
    8000350e:	0009a503          	lw	a0,0(s3)
    80003512:	9b7ff0ef          	jal	80002ec8 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003516:	0809a023          	sw	zero,128(s3)
    8000351a:	6a02                	ld	s4,0(sp)
    8000351c:	b75d                	j	800034c2 <itrunc+0x38>

000000008000351e <iput>:
{
    8000351e:	1101                	addi	sp,sp,-32
    80003520:	ec06                	sd	ra,24(sp)
    80003522:	e822                	sd	s0,16(sp)
    80003524:	e426                	sd	s1,8(sp)
    80003526:	1000                	addi	s0,sp,32
    80003528:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000352a:	0001d517          	auipc	a0,0x1d
    8000352e:	7c650513          	addi	a0,a0,1990 # 80020cf0 <itable>
    80003532:	e9cfd0ef          	jal	80000bce <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003536:	4498                	lw	a4,8(s1)
    80003538:	4785                	li	a5,1
    8000353a:	02f70063          	beq	a4,a5,8000355a <iput+0x3c>
  ip->ref--;
    8000353e:	449c                	lw	a5,8(s1)
    80003540:	37fd                	addiw	a5,a5,-1
    80003542:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003544:	0001d517          	auipc	a0,0x1d
    80003548:	7ac50513          	addi	a0,a0,1964 # 80020cf0 <itable>
    8000354c:	f1afd0ef          	jal	80000c66 <release>
}
    80003550:	60e2                	ld	ra,24(sp)
    80003552:	6442                	ld	s0,16(sp)
    80003554:	64a2                	ld	s1,8(sp)
    80003556:	6105                	addi	sp,sp,32
    80003558:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000355a:	40bc                	lw	a5,64(s1)
    8000355c:	d3ed                	beqz	a5,8000353e <iput+0x20>
    8000355e:	04a49783          	lh	a5,74(s1)
    80003562:	fff1                	bnez	a5,8000353e <iput+0x20>
    80003564:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003566:	01048913          	addi	s2,s1,16
    8000356a:	854a                	mv	a0,s2
    8000356c:	297000ef          	jal	80004002 <acquiresleep>
    release(&itable.lock);
    80003570:	0001d517          	auipc	a0,0x1d
    80003574:	78050513          	addi	a0,a0,1920 # 80020cf0 <itable>
    80003578:	eeefd0ef          	jal	80000c66 <release>
    itrunc(ip);
    8000357c:	8526                	mv	a0,s1
    8000357e:	f0dff0ef          	jal	8000348a <itrunc>
    ip->type = 0;
    80003582:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003586:	8526                	mv	a0,s1
    80003588:	d61ff0ef          	jal	800032e8 <iupdate>
    ip->valid = 0;
    8000358c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003590:	854a                	mv	a0,s2
    80003592:	2b7000ef          	jal	80004048 <releasesleep>
    acquire(&itable.lock);
    80003596:	0001d517          	auipc	a0,0x1d
    8000359a:	75a50513          	addi	a0,a0,1882 # 80020cf0 <itable>
    8000359e:	e30fd0ef          	jal	80000bce <acquire>
    800035a2:	6902                	ld	s2,0(sp)
    800035a4:	bf69                	j	8000353e <iput+0x20>

00000000800035a6 <iunlockput>:
{
    800035a6:	1101                	addi	sp,sp,-32
    800035a8:	ec06                	sd	ra,24(sp)
    800035aa:	e822                	sd	s0,16(sp)
    800035ac:	e426                	sd	s1,8(sp)
    800035ae:	1000                	addi	s0,sp,32
    800035b0:	84aa                	mv	s1,a0
  iunlock(ip);
    800035b2:	e99ff0ef          	jal	8000344a <iunlock>
  iput(ip);
    800035b6:	8526                	mv	a0,s1
    800035b8:	f67ff0ef          	jal	8000351e <iput>
}
    800035bc:	60e2                	ld	ra,24(sp)
    800035be:	6442                	ld	s0,16(sp)
    800035c0:	64a2                	ld	s1,8(sp)
    800035c2:	6105                	addi	sp,sp,32
    800035c4:	8082                	ret

00000000800035c6 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800035c6:	0001d717          	auipc	a4,0x1d
    800035ca:	71672703          	lw	a4,1814(a4) # 80020cdc <sb+0xc>
    800035ce:	4785                	li	a5,1
    800035d0:	0ae7ff63          	bgeu	a5,a4,8000368e <ireclaim+0xc8>
{
    800035d4:	7139                	addi	sp,sp,-64
    800035d6:	fc06                	sd	ra,56(sp)
    800035d8:	f822                	sd	s0,48(sp)
    800035da:	f426                	sd	s1,40(sp)
    800035dc:	f04a                	sd	s2,32(sp)
    800035de:	ec4e                	sd	s3,24(sp)
    800035e0:	e852                	sd	s4,16(sp)
    800035e2:	e456                	sd	s5,8(sp)
    800035e4:	e05a                	sd	s6,0(sp)
    800035e6:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800035e8:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800035ea:	00050a1b          	sext.w	s4,a0
    800035ee:	0001da97          	auipc	s5,0x1d
    800035f2:	6e2a8a93          	addi	s5,s5,1762 # 80020cd0 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    800035f6:	00004b17          	auipc	s6,0x4
    800035fa:	fcab0b13          	addi	s6,s6,-54 # 800075c0 <etext+0x5c0>
    800035fe:	a099                	j	80003644 <ireclaim+0x7e>
    80003600:	85ce                	mv	a1,s3
    80003602:	855a                	mv	a0,s6
    80003604:	ef7fc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    80003608:	85ce                	mv	a1,s3
    8000360a:	8552                	mv	a0,s4
    8000360c:	b1dff0ef          	jal	80003128 <iget>
    80003610:	89aa                	mv	s3,a0
    brelse(bp);
    80003612:	854a                	mv	a0,s2
    80003614:	fc4ff0ef          	jal	80002dd8 <brelse>
    if (ip) {
    80003618:	00098f63          	beqz	s3,80003636 <ireclaim+0x70>
      begin_op();
    8000361c:	76a000ef          	jal	80003d86 <begin_op>
      ilock(ip);
    80003620:	854e                	mv	a0,s3
    80003622:	d7bff0ef          	jal	8000339c <ilock>
      iunlock(ip);
    80003626:	854e                	mv	a0,s3
    80003628:	e23ff0ef          	jal	8000344a <iunlock>
      iput(ip);
    8000362c:	854e                	mv	a0,s3
    8000362e:	ef1ff0ef          	jal	8000351e <iput>
      end_op();
    80003632:	7be000ef          	jal	80003df0 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003636:	0485                	addi	s1,s1,1
    80003638:	00caa703          	lw	a4,12(s5)
    8000363c:	0004879b          	sext.w	a5,s1
    80003640:	02e7fd63          	bgeu	a5,a4,8000367a <ireclaim+0xb4>
    80003644:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003648:	0044d593          	srli	a1,s1,0x4
    8000364c:	018aa783          	lw	a5,24(s5)
    80003650:	9dbd                	addw	a1,a1,a5
    80003652:	8552                	mv	a0,s4
    80003654:	e7cff0ef          	jal	80002cd0 <bread>
    80003658:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000365a:	05850793          	addi	a5,a0,88
    8000365e:	00f9f713          	andi	a4,s3,15
    80003662:	071a                	slli	a4,a4,0x6
    80003664:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003666:	00079703          	lh	a4,0(a5)
    8000366a:	c701                	beqz	a4,80003672 <ireclaim+0xac>
    8000366c:	00679783          	lh	a5,6(a5)
    80003670:	dbc1                	beqz	a5,80003600 <ireclaim+0x3a>
    brelse(bp);
    80003672:	854a                	mv	a0,s2
    80003674:	f64ff0ef          	jal	80002dd8 <brelse>
    if (ip) {
    80003678:	bf7d                	j	80003636 <ireclaim+0x70>
}
    8000367a:	70e2                	ld	ra,56(sp)
    8000367c:	7442                	ld	s0,48(sp)
    8000367e:	74a2                	ld	s1,40(sp)
    80003680:	7902                	ld	s2,32(sp)
    80003682:	69e2                	ld	s3,24(sp)
    80003684:	6a42                	ld	s4,16(sp)
    80003686:	6aa2                	ld	s5,8(sp)
    80003688:	6b02                	ld	s6,0(sp)
    8000368a:	6121                	addi	sp,sp,64
    8000368c:	8082                	ret
    8000368e:	8082                	ret

0000000080003690 <fsinit>:
fsinit(int dev) {
    80003690:	7179                	addi	sp,sp,-48
    80003692:	f406                	sd	ra,40(sp)
    80003694:	f022                	sd	s0,32(sp)
    80003696:	ec26                	sd	s1,24(sp)
    80003698:	e84a                	sd	s2,16(sp)
    8000369a:	e44e                	sd	s3,8(sp)
    8000369c:	1800                	addi	s0,sp,48
    8000369e:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800036a0:	4585                	li	a1,1
    800036a2:	e2eff0ef          	jal	80002cd0 <bread>
    800036a6:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036a8:	0001d997          	auipc	s3,0x1d
    800036ac:	62898993          	addi	s3,s3,1576 # 80020cd0 <sb>
    800036b0:	02000613          	li	a2,32
    800036b4:	05850593          	addi	a1,a0,88
    800036b8:	854e                	mv	a0,s3
    800036ba:	e44fd0ef          	jal	80000cfe <memmove>
  brelse(bp);
    800036be:	854a                	mv	a0,s2
    800036c0:	f18ff0ef          	jal	80002dd8 <brelse>
  if(sb.magic != FSMAGIC)
    800036c4:	0009a703          	lw	a4,0(s3)
    800036c8:	102037b7          	lui	a5,0x10203
    800036cc:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800036d0:	02f71363          	bne	a4,a5,800036f6 <fsinit+0x66>
  initlog(dev, &sb);
    800036d4:	0001d597          	auipc	a1,0x1d
    800036d8:	5fc58593          	addi	a1,a1,1532 # 80020cd0 <sb>
    800036dc:	8526                	mv	a0,s1
    800036de:	62a000ef          	jal	80003d08 <initlog>
  ireclaim(dev);
    800036e2:	8526                	mv	a0,s1
    800036e4:	ee3ff0ef          	jal	800035c6 <ireclaim>
}
    800036e8:	70a2                	ld	ra,40(sp)
    800036ea:	7402                	ld	s0,32(sp)
    800036ec:	64e2                	ld	s1,24(sp)
    800036ee:	6942                	ld	s2,16(sp)
    800036f0:	69a2                	ld	s3,8(sp)
    800036f2:	6145                	addi	sp,sp,48
    800036f4:	8082                	ret
    panic("invalid file system");
    800036f6:	00004517          	auipc	a0,0x4
    800036fa:	eea50513          	addi	a0,a0,-278 # 800075e0 <etext+0x5e0>
    800036fe:	8e2fd0ef          	jal	800007e0 <panic>

0000000080003702 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003702:	1141                	addi	sp,sp,-16
    80003704:	e422                	sd	s0,8(sp)
    80003706:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003708:	411c                	lw	a5,0(a0)
    8000370a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000370c:	415c                	lw	a5,4(a0)
    8000370e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003710:	04451783          	lh	a5,68(a0)
    80003714:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003718:	04a51783          	lh	a5,74(a0)
    8000371c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003720:	04c56783          	lwu	a5,76(a0)
    80003724:	e99c                	sd	a5,16(a1)
}
    80003726:	6422                	ld	s0,8(sp)
    80003728:	0141                	addi	sp,sp,16
    8000372a:	8082                	ret

000000008000372c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000372c:	457c                	lw	a5,76(a0)
    8000372e:	0ed7eb63          	bltu	a5,a3,80003824 <readi+0xf8>
{
    80003732:	7159                	addi	sp,sp,-112
    80003734:	f486                	sd	ra,104(sp)
    80003736:	f0a2                	sd	s0,96(sp)
    80003738:	eca6                	sd	s1,88(sp)
    8000373a:	e0d2                	sd	s4,64(sp)
    8000373c:	fc56                	sd	s5,56(sp)
    8000373e:	f85a                	sd	s6,48(sp)
    80003740:	f45e                	sd	s7,40(sp)
    80003742:	1880                	addi	s0,sp,112
    80003744:	8b2a                	mv	s6,a0
    80003746:	8bae                	mv	s7,a1
    80003748:	8a32                	mv	s4,a2
    8000374a:	84b6                	mv	s1,a3
    8000374c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000374e:	9f35                	addw	a4,a4,a3
    return 0;
    80003750:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003752:	0cd76063          	bltu	a4,a3,80003812 <readi+0xe6>
    80003756:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003758:	00e7f463          	bgeu	a5,a4,80003760 <readi+0x34>
    n = ip->size - off;
    8000375c:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003760:	080a8f63          	beqz	s5,800037fe <readi+0xd2>
    80003764:	e8ca                	sd	s2,80(sp)
    80003766:	f062                	sd	s8,32(sp)
    80003768:	ec66                	sd	s9,24(sp)
    8000376a:	e86a                	sd	s10,16(sp)
    8000376c:	e46e                	sd	s11,8(sp)
    8000376e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003770:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003774:	5c7d                	li	s8,-1
    80003776:	a80d                	j	800037a8 <readi+0x7c>
    80003778:	020d1d93          	slli	s11,s10,0x20
    8000377c:	020ddd93          	srli	s11,s11,0x20
    80003780:	05890613          	addi	a2,s2,88
    80003784:	86ee                	mv	a3,s11
    80003786:	963a                	add	a2,a2,a4
    80003788:	85d2                	mv	a1,s4
    8000378a:	855e                	mv	a0,s7
    8000378c:	aa5fe0ef          	jal	80002230 <either_copyout>
    80003790:	05850763          	beq	a0,s8,800037de <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003794:	854a                	mv	a0,s2
    80003796:	e42ff0ef          	jal	80002dd8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000379a:	013d09bb          	addw	s3,s10,s3
    8000379e:	009d04bb          	addw	s1,s10,s1
    800037a2:	9a6e                	add	s4,s4,s11
    800037a4:	0559f763          	bgeu	s3,s5,800037f2 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    800037a8:	00a4d59b          	srliw	a1,s1,0xa
    800037ac:	855a                	mv	a0,s6
    800037ae:	8a7ff0ef          	jal	80003054 <bmap>
    800037b2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800037b6:	c5b1                	beqz	a1,80003802 <readi+0xd6>
    bp = bread(ip->dev, addr);
    800037b8:	000b2503          	lw	a0,0(s6)
    800037bc:	d14ff0ef          	jal	80002cd0 <bread>
    800037c0:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800037c2:	3ff4f713          	andi	a4,s1,1023
    800037c6:	40ec87bb          	subw	a5,s9,a4
    800037ca:	413a86bb          	subw	a3,s5,s3
    800037ce:	8d3e                	mv	s10,a5
    800037d0:	2781                	sext.w	a5,a5
    800037d2:	0006861b          	sext.w	a2,a3
    800037d6:	faf671e3          	bgeu	a2,a5,80003778 <readi+0x4c>
    800037da:	8d36                	mv	s10,a3
    800037dc:	bf71                	j	80003778 <readi+0x4c>
      brelse(bp);
    800037de:	854a                	mv	a0,s2
    800037e0:	df8ff0ef          	jal	80002dd8 <brelse>
      tot = -1;
    800037e4:	59fd                	li	s3,-1
      break;
    800037e6:	6946                	ld	s2,80(sp)
    800037e8:	7c02                	ld	s8,32(sp)
    800037ea:	6ce2                	ld	s9,24(sp)
    800037ec:	6d42                	ld	s10,16(sp)
    800037ee:	6da2                	ld	s11,8(sp)
    800037f0:	a831                	j	8000380c <readi+0xe0>
    800037f2:	6946                	ld	s2,80(sp)
    800037f4:	7c02                	ld	s8,32(sp)
    800037f6:	6ce2                	ld	s9,24(sp)
    800037f8:	6d42                	ld	s10,16(sp)
    800037fa:	6da2                	ld	s11,8(sp)
    800037fc:	a801                	j	8000380c <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800037fe:	89d6                	mv	s3,s5
    80003800:	a031                	j	8000380c <readi+0xe0>
    80003802:	6946                	ld	s2,80(sp)
    80003804:	7c02                	ld	s8,32(sp)
    80003806:	6ce2                	ld	s9,24(sp)
    80003808:	6d42                	ld	s10,16(sp)
    8000380a:	6da2                	ld	s11,8(sp)
  }
  return tot;
    8000380c:	0009851b          	sext.w	a0,s3
    80003810:	69a6                	ld	s3,72(sp)
}
    80003812:	70a6                	ld	ra,104(sp)
    80003814:	7406                	ld	s0,96(sp)
    80003816:	64e6                	ld	s1,88(sp)
    80003818:	6a06                	ld	s4,64(sp)
    8000381a:	7ae2                	ld	s5,56(sp)
    8000381c:	7b42                	ld	s6,48(sp)
    8000381e:	7ba2                	ld	s7,40(sp)
    80003820:	6165                	addi	sp,sp,112
    80003822:	8082                	ret
    return 0;
    80003824:	4501                	li	a0,0
}
    80003826:	8082                	ret

0000000080003828 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003828:	457c                	lw	a5,76(a0)
    8000382a:	10d7e063          	bltu	a5,a3,8000392a <writei+0x102>
{
    8000382e:	7159                	addi	sp,sp,-112
    80003830:	f486                	sd	ra,104(sp)
    80003832:	f0a2                	sd	s0,96(sp)
    80003834:	e8ca                	sd	s2,80(sp)
    80003836:	e0d2                	sd	s4,64(sp)
    80003838:	fc56                	sd	s5,56(sp)
    8000383a:	f85a                	sd	s6,48(sp)
    8000383c:	f45e                	sd	s7,40(sp)
    8000383e:	1880                	addi	s0,sp,112
    80003840:	8aaa                	mv	s5,a0
    80003842:	8bae                	mv	s7,a1
    80003844:	8a32                	mv	s4,a2
    80003846:	8936                	mv	s2,a3
    80003848:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000384a:	00e687bb          	addw	a5,a3,a4
    8000384e:	0ed7e063          	bltu	a5,a3,8000392e <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003852:	00043737          	lui	a4,0x43
    80003856:	0cf76e63          	bltu	a4,a5,80003932 <writei+0x10a>
    8000385a:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000385c:	0a0b0f63          	beqz	s6,8000391a <writei+0xf2>
    80003860:	eca6                	sd	s1,88(sp)
    80003862:	f062                	sd	s8,32(sp)
    80003864:	ec66                	sd	s9,24(sp)
    80003866:	e86a                	sd	s10,16(sp)
    80003868:	e46e                	sd	s11,8(sp)
    8000386a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000386c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003870:	5c7d                	li	s8,-1
    80003872:	a825                	j	800038aa <writei+0x82>
    80003874:	020d1d93          	slli	s11,s10,0x20
    80003878:	020ddd93          	srli	s11,s11,0x20
    8000387c:	05848513          	addi	a0,s1,88
    80003880:	86ee                	mv	a3,s11
    80003882:	8652                	mv	a2,s4
    80003884:	85de                	mv	a1,s7
    80003886:	953a                	add	a0,a0,a4
    80003888:	9f3fe0ef          	jal	8000227a <either_copyin>
    8000388c:	05850a63          	beq	a0,s8,800038e0 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003890:	8526                	mv	a0,s1
    80003892:	678000ef          	jal	80003f0a <log_write>
    brelse(bp);
    80003896:	8526                	mv	a0,s1
    80003898:	d40ff0ef          	jal	80002dd8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000389c:	013d09bb          	addw	s3,s10,s3
    800038a0:	012d093b          	addw	s2,s10,s2
    800038a4:	9a6e                	add	s4,s4,s11
    800038a6:	0569f063          	bgeu	s3,s6,800038e6 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800038aa:	00a9559b          	srliw	a1,s2,0xa
    800038ae:	8556                	mv	a0,s5
    800038b0:	fa4ff0ef          	jal	80003054 <bmap>
    800038b4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800038b8:	c59d                	beqz	a1,800038e6 <writei+0xbe>
    bp = bread(ip->dev, addr);
    800038ba:	000aa503          	lw	a0,0(s5)
    800038be:	c12ff0ef          	jal	80002cd0 <bread>
    800038c2:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800038c4:	3ff97713          	andi	a4,s2,1023
    800038c8:	40ec87bb          	subw	a5,s9,a4
    800038cc:	413b06bb          	subw	a3,s6,s3
    800038d0:	8d3e                	mv	s10,a5
    800038d2:	2781                	sext.w	a5,a5
    800038d4:	0006861b          	sext.w	a2,a3
    800038d8:	f8f67ee3          	bgeu	a2,a5,80003874 <writei+0x4c>
    800038dc:	8d36                	mv	s10,a3
    800038de:	bf59                	j	80003874 <writei+0x4c>
      brelse(bp);
    800038e0:	8526                	mv	a0,s1
    800038e2:	cf6ff0ef          	jal	80002dd8 <brelse>
  }

  if(off > ip->size)
    800038e6:	04caa783          	lw	a5,76(s5)
    800038ea:	0327fa63          	bgeu	a5,s2,8000391e <writei+0xf6>
    ip->size = off;
    800038ee:	052aa623          	sw	s2,76(s5)
    800038f2:	64e6                	ld	s1,88(sp)
    800038f4:	7c02                	ld	s8,32(sp)
    800038f6:	6ce2                	ld	s9,24(sp)
    800038f8:	6d42                	ld	s10,16(sp)
    800038fa:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800038fc:	8556                	mv	a0,s5
    800038fe:	9ebff0ef          	jal	800032e8 <iupdate>

  return tot;
    80003902:	0009851b          	sext.w	a0,s3
    80003906:	69a6                	ld	s3,72(sp)
}
    80003908:	70a6                	ld	ra,104(sp)
    8000390a:	7406                	ld	s0,96(sp)
    8000390c:	6946                	ld	s2,80(sp)
    8000390e:	6a06                	ld	s4,64(sp)
    80003910:	7ae2                	ld	s5,56(sp)
    80003912:	7b42                	ld	s6,48(sp)
    80003914:	7ba2                	ld	s7,40(sp)
    80003916:	6165                	addi	sp,sp,112
    80003918:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000391a:	89da                	mv	s3,s6
    8000391c:	b7c5                	j	800038fc <writei+0xd4>
    8000391e:	64e6                	ld	s1,88(sp)
    80003920:	7c02                	ld	s8,32(sp)
    80003922:	6ce2                	ld	s9,24(sp)
    80003924:	6d42                	ld	s10,16(sp)
    80003926:	6da2                	ld	s11,8(sp)
    80003928:	bfd1                	j	800038fc <writei+0xd4>
    return -1;
    8000392a:	557d                	li	a0,-1
}
    8000392c:	8082                	ret
    return -1;
    8000392e:	557d                	li	a0,-1
    80003930:	bfe1                	j	80003908 <writei+0xe0>
    return -1;
    80003932:	557d                	li	a0,-1
    80003934:	bfd1                	j	80003908 <writei+0xe0>

0000000080003936 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003936:	1141                	addi	sp,sp,-16
    80003938:	e406                	sd	ra,8(sp)
    8000393a:	e022                	sd	s0,0(sp)
    8000393c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000393e:	4639                	li	a2,14
    80003940:	c2efd0ef          	jal	80000d6e <strncmp>
}
    80003944:	60a2                	ld	ra,8(sp)
    80003946:	6402                	ld	s0,0(sp)
    80003948:	0141                	addi	sp,sp,16
    8000394a:	8082                	ret

000000008000394c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000394c:	7139                	addi	sp,sp,-64
    8000394e:	fc06                	sd	ra,56(sp)
    80003950:	f822                	sd	s0,48(sp)
    80003952:	f426                	sd	s1,40(sp)
    80003954:	f04a                	sd	s2,32(sp)
    80003956:	ec4e                	sd	s3,24(sp)
    80003958:	e852                	sd	s4,16(sp)
    8000395a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000395c:	04451703          	lh	a4,68(a0)
    80003960:	4785                	li	a5,1
    80003962:	00f71a63          	bne	a4,a5,80003976 <dirlookup+0x2a>
    80003966:	892a                	mv	s2,a0
    80003968:	89ae                	mv	s3,a1
    8000396a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000396c:	457c                	lw	a5,76(a0)
    8000396e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003970:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003972:	e39d                	bnez	a5,80003998 <dirlookup+0x4c>
    80003974:	a095                	j	800039d8 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003976:	00004517          	auipc	a0,0x4
    8000397a:	c8250513          	addi	a0,a0,-894 # 800075f8 <etext+0x5f8>
    8000397e:	e63fc0ef          	jal	800007e0 <panic>
      panic("dirlookup read");
    80003982:	00004517          	auipc	a0,0x4
    80003986:	c8e50513          	addi	a0,a0,-882 # 80007610 <etext+0x610>
    8000398a:	e57fc0ef          	jal	800007e0 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000398e:	24c1                	addiw	s1,s1,16
    80003990:	04c92783          	lw	a5,76(s2)
    80003994:	04f4f163          	bgeu	s1,a5,800039d6 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003998:	4741                	li	a4,16
    8000399a:	86a6                	mv	a3,s1
    8000399c:	fc040613          	addi	a2,s0,-64
    800039a0:	4581                	li	a1,0
    800039a2:	854a                	mv	a0,s2
    800039a4:	d89ff0ef          	jal	8000372c <readi>
    800039a8:	47c1                	li	a5,16
    800039aa:	fcf51ce3          	bne	a0,a5,80003982 <dirlookup+0x36>
    if(de.inum == 0)
    800039ae:	fc045783          	lhu	a5,-64(s0)
    800039b2:	dff1                	beqz	a5,8000398e <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    800039b4:	fc240593          	addi	a1,s0,-62
    800039b8:	854e                	mv	a0,s3
    800039ba:	f7dff0ef          	jal	80003936 <namecmp>
    800039be:	f961                	bnez	a0,8000398e <dirlookup+0x42>
      if(poff)
    800039c0:	000a0463          	beqz	s4,800039c8 <dirlookup+0x7c>
        *poff = off;
    800039c4:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800039c8:	fc045583          	lhu	a1,-64(s0)
    800039cc:	00092503          	lw	a0,0(s2)
    800039d0:	f58ff0ef          	jal	80003128 <iget>
    800039d4:	a011                	j	800039d8 <dirlookup+0x8c>
  return 0;
    800039d6:	4501                	li	a0,0
}
    800039d8:	70e2                	ld	ra,56(sp)
    800039da:	7442                	ld	s0,48(sp)
    800039dc:	74a2                	ld	s1,40(sp)
    800039de:	7902                	ld	s2,32(sp)
    800039e0:	69e2                	ld	s3,24(sp)
    800039e2:	6a42                	ld	s4,16(sp)
    800039e4:	6121                	addi	sp,sp,64
    800039e6:	8082                	ret

00000000800039e8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800039e8:	711d                	addi	sp,sp,-96
    800039ea:	ec86                	sd	ra,88(sp)
    800039ec:	e8a2                	sd	s0,80(sp)
    800039ee:	e4a6                	sd	s1,72(sp)
    800039f0:	e0ca                	sd	s2,64(sp)
    800039f2:	fc4e                	sd	s3,56(sp)
    800039f4:	f852                	sd	s4,48(sp)
    800039f6:	f456                	sd	s5,40(sp)
    800039f8:	f05a                	sd	s6,32(sp)
    800039fa:	ec5e                	sd	s7,24(sp)
    800039fc:	e862                	sd	s8,16(sp)
    800039fe:	e466                	sd	s9,8(sp)
    80003a00:	1080                	addi	s0,sp,96
    80003a02:	84aa                	mv	s1,a0
    80003a04:	8b2e                	mv	s6,a1
    80003a06:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003a08:	00054703          	lbu	a4,0(a0)
    80003a0c:	02f00793          	li	a5,47
    80003a10:	00f70e63          	beq	a4,a5,80003a2c <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003a14:	ebbfd0ef          	jal	800018ce <myproc>
    80003a18:	15053503          	ld	a0,336(a0)
    80003a1c:	94bff0ef          	jal	80003366 <idup>
    80003a20:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003a22:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003a26:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003a28:	4b85                	li	s7,1
    80003a2a:	a871                	j	80003ac6 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003a2c:	4585                	li	a1,1
    80003a2e:	4505                	li	a0,1
    80003a30:	ef8ff0ef          	jal	80003128 <iget>
    80003a34:	8a2a                	mv	s4,a0
    80003a36:	b7f5                	j	80003a22 <namex+0x3a>
      iunlockput(ip);
    80003a38:	8552                	mv	a0,s4
    80003a3a:	b6dff0ef          	jal	800035a6 <iunlockput>
      return 0;
    80003a3e:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003a40:	8552                	mv	a0,s4
    80003a42:	60e6                	ld	ra,88(sp)
    80003a44:	6446                	ld	s0,80(sp)
    80003a46:	64a6                	ld	s1,72(sp)
    80003a48:	6906                	ld	s2,64(sp)
    80003a4a:	79e2                	ld	s3,56(sp)
    80003a4c:	7a42                	ld	s4,48(sp)
    80003a4e:	7aa2                	ld	s5,40(sp)
    80003a50:	7b02                	ld	s6,32(sp)
    80003a52:	6be2                	ld	s7,24(sp)
    80003a54:	6c42                	ld	s8,16(sp)
    80003a56:	6ca2                	ld	s9,8(sp)
    80003a58:	6125                	addi	sp,sp,96
    80003a5a:	8082                	ret
      iunlock(ip);
    80003a5c:	8552                	mv	a0,s4
    80003a5e:	9edff0ef          	jal	8000344a <iunlock>
      return ip;
    80003a62:	bff9                	j	80003a40 <namex+0x58>
      iunlockput(ip);
    80003a64:	8552                	mv	a0,s4
    80003a66:	b41ff0ef          	jal	800035a6 <iunlockput>
      return 0;
    80003a6a:	8a4e                	mv	s4,s3
    80003a6c:	bfd1                	j	80003a40 <namex+0x58>
  len = path - s;
    80003a6e:	40998633          	sub	a2,s3,s1
    80003a72:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003a76:	099c5063          	bge	s8,s9,80003af6 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003a7a:	4639                	li	a2,14
    80003a7c:	85a6                	mv	a1,s1
    80003a7e:	8556                	mv	a0,s5
    80003a80:	a7efd0ef          	jal	80000cfe <memmove>
    80003a84:	84ce                	mv	s1,s3
  while(*path == '/')
    80003a86:	0004c783          	lbu	a5,0(s1)
    80003a8a:	01279763          	bne	a5,s2,80003a98 <namex+0xb0>
    path++;
    80003a8e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003a90:	0004c783          	lbu	a5,0(s1)
    80003a94:	ff278de3          	beq	a5,s2,80003a8e <namex+0xa6>
    ilock(ip);
    80003a98:	8552                	mv	a0,s4
    80003a9a:	903ff0ef          	jal	8000339c <ilock>
    if(ip->type != T_DIR){
    80003a9e:	044a1783          	lh	a5,68(s4)
    80003aa2:	f9779be3          	bne	a5,s7,80003a38 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003aa6:	000b0563          	beqz	s6,80003ab0 <namex+0xc8>
    80003aaa:	0004c783          	lbu	a5,0(s1)
    80003aae:	d7dd                	beqz	a5,80003a5c <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003ab0:	4601                	li	a2,0
    80003ab2:	85d6                	mv	a1,s5
    80003ab4:	8552                	mv	a0,s4
    80003ab6:	e97ff0ef          	jal	8000394c <dirlookup>
    80003aba:	89aa                	mv	s3,a0
    80003abc:	d545                	beqz	a0,80003a64 <namex+0x7c>
    iunlockput(ip);
    80003abe:	8552                	mv	a0,s4
    80003ac0:	ae7ff0ef          	jal	800035a6 <iunlockput>
    ip = next;
    80003ac4:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003ac6:	0004c783          	lbu	a5,0(s1)
    80003aca:	01279763          	bne	a5,s2,80003ad8 <namex+0xf0>
    path++;
    80003ace:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ad0:	0004c783          	lbu	a5,0(s1)
    80003ad4:	ff278de3          	beq	a5,s2,80003ace <namex+0xe6>
  if(*path == 0)
    80003ad8:	cb8d                	beqz	a5,80003b0a <namex+0x122>
  while(*path != '/' && *path != 0)
    80003ada:	0004c783          	lbu	a5,0(s1)
    80003ade:	89a6                	mv	s3,s1
  len = path - s;
    80003ae0:	4c81                	li	s9,0
    80003ae2:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003ae4:	01278963          	beq	a5,s2,80003af6 <namex+0x10e>
    80003ae8:	d3d9                	beqz	a5,80003a6e <namex+0x86>
    path++;
    80003aea:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003aec:	0009c783          	lbu	a5,0(s3)
    80003af0:	ff279ce3          	bne	a5,s2,80003ae8 <namex+0x100>
    80003af4:	bfad                	j	80003a6e <namex+0x86>
    memmove(name, s, len);
    80003af6:	2601                	sext.w	a2,a2
    80003af8:	85a6                	mv	a1,s1
    80003afa:	8556                	mv	a0,s5
    80003afc:	a02fd0ef          	jal	80000cfe <memmove>
    name[len] = 0;
    80003b00:	9cd6                	add	s9,s9,s5
    80003b02:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003b06:	84ce                	mv	s1,s3
    80003b08:	bfbd                	j	80003a86 <namex+0x9e>
  if(nameiparent){
    80003b0a:	f20b0be3          	beqz	s6,80003a40 <namex+0x58>
    iput(ip);
    80003b0e:	8552                	mv	a0,s4
    80003b10:	a0fff0ef          	jal	8000351e <iput>
    return 0;
    80003b14:	4a01                	li	s4,0
    80003b16:	b72d                	j	80003a40 <namex+0x58>

0000000080003b18 <dirlink>:
{
    80003b18:	7139                	addi	sp,sp,-64
    80003b1a:	fc06                	sd	ra,56(sp)
    80003b1c:	f822                	sd	s0,48(sp)
    80003b1e:	f04a                	sd	s2,32(sp)
    80003b20:	ec4e                	sd	s3,24(sp)
    80003b22:	e852                	sd	s4,16(sp)
    80003b24:	0080                	addi	s0,sp,64
    80003b26:	892a                	mv	s2,a0
    80003b28:	8a2e                	mv	s4,a1
    80003b2a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003b2c:	4601                	li	a2,0
    80003b2e:	e1fff0ef          	jal	8000394c <dirlookup>
    80003b32:	e535                	bnez	a0,80003b9e <dirlink+0x86>
    80003b34:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b36:	04c92483          	lw	s1,76(s2)
    80003b3a:	c48d                	beqz	s1,80003b64 <dirlink+0x4c>
    80003b3c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b3e:	4741                	li	a4,16
    80003b40:	86a6                	mv	a3,s1
    80003b42:	fc040613          	addi	a2,s0,-64
    80003b46:	4581                	li	a1,0
    80003b48:	854a                	mv	a0,s2
    80003b4a:	be3ff0ef          	jal	8000372c <readi>
    80003b4e:	47c1                	li	a5,16
    80003b50:	04f51b63          	bne	a0,a5,80003ba6 <dirlink+0x8e>
    if(de.inum == 0)
    80003b54:	fc045783          	lhu	a5,-64(s0)
    80003b58:	c791                	beqz	a5,80003b64 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b5a:	24c1                	addiw	s1,s1,16
    80003b5c:	04c92783          	lw	a5,76(s2)
    80003b60:	fcf4efe3          	bltu	s1,a5,80003b3e <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003b64:	4639                	li	a2,14
    80003b66:	85d2                	mv	a1,s4
    80003b68:	fc240513          	addi	a0,s0,-62
    80003b6c:	a38fd0ef          	jal	80000da4 <strncpy>
  de.inum = inum;
    80003b70:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b74:	4741                	li	a4,16
    80003b76:	86a6                	mv	a3,s1
    80003b78:	fc040613          	addi	a2,s0,-64
    80003b7c:	4581                	li	a1,0
    80003b7e:	854a                	mv	a0,s2
    80003b80:	ca9ff0ef          	jal	80003828 <writei>
    80003b84:	1541                	addi	a0,a0,-16
    80003b86:	00a03533          	snez	a0,a0
    80003b8a:	40a00533          	neg	a0,a0
    80003b8e:	74a2                	ld	s1,40(sp)
}
    80003b90:	70e2                	ld	ra,56(sp)
    80003b92:	7442                	ld	s0,48(sp)
    80003b94:	7902                	ld	s2,32(sp)
    80003b96:	69e2                	ld	s3,24(sp)
    80003b98:	6a42                	ld	s4,16(sp)
    80003b9a:	6121                	addi	sp,sp,64
    80003b9c:	8082                	ret
    iput(ip);
    80003b9e:	981ff0ef          	jal	8000351e <iput>
    return -1;
    80003ba2:	557d                	li	a0,-1
    80003ba4:	b7f5                	j	80003b90 <dirlink+0x78>
      panic("dirlink read");
    80003ba6:	00004517          	auipc	a0,0x4
    80003baa:	a7a50513          	addi	a0,a0,-1414 # 80007620 <etext+0x620>
    80003bae:	c33fc0ef          	jal	800007e0 <panic>

0000000080003bb2 <namei>:

struct inode*
namei(char *path)
{
    80003bb2:	1101                	addi	sp,sp,-32
    80003bb4:	ec06                	sd	ra,24(sp)
    80003bb6:	e822                	sd	s0,16(sp)
    80003bb8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003bba:	fe040613          	addi	a2,s0,-32
    80003bbe:	4581                	li	a1,0
    80003bc0:	e29ff0ef          	jal	800039e8 <namex>
}
    80003bc4:	60e2                	ld	ra,24(sp)
    80003bc6:	6442                	ld	s0,16(sp)
    80003bc8:	6105                	addi	sp,sp,32
    80003bca:	8082                	ret

0000000080003bcc <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003bcc:	1141                	addi	sp,sp,-16
    80003bce:	e406                	sd	ra,8(sp)
    80003bd0:	e022                	sd	s0,0(sp)
    80003bd2:	0800                	addi	s0,sp,16
    80003bd4:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003bd6:	4585                	li	a1,1
    80003bd8:	e11ff0ef          	jal	800039e8 <namex>
}
    80003bdc:	60a2                	ld	ra,8(sp)
    80003bde:	6402                	ld	s0,0(sp)
    80003be0:	0141                	addi	sp,sp,16
    80003be2:	8082                	ret

0000000080003be4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003be4:	1101                	addi	sp,sp,-32
    80003be6:	ec06                	sd	ra,24(sp)
    80003be8:	e822                	sd	s0,16(sp)
    80003bea:	e426                	sd	s1,8(sp)
    80003bec:	e04a                	sd	s2,0(sp)
    80003bee:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003bf0:	0001f917          	auipc	s2,0x1f
    80003bf4:	ba890913          	addi	s2,s2,-1112 # 80022798 <log>
    80003bf8:	01892583          	lw	a1,24(s2)
    80003bfc:	02492503          	lw	a0,36(s2)
    80003c00:	8d0ff0ef          	jal	80002cd0 <bread>
    80003c04:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003c06:	02892603          	lw	a2,40(s2)
    80003c0a:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003c0c:	00c05f63          	blez	a2,80003c2a <write_head+0x46>
    80003c10:	0001f717          	auipc	a4,0x1f
    80003c14:	bb470713          	addi	a4,a4,-1100 # 800227c4 <log+0x2c>
    80003c18:	87aa                	mv	a5,a0
    80003c1a:	060a                	slli	a2,a2,0x2
    80003c1c:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003c1e:	4314                	lw	a3,0(a4)
    80003c20:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003c22:	0711                	addi	a4,a4,4
    80003c24:	0791                	addi	a5,a5,4
    80003c26:	fec79ce3          	bne	a5,a2,80003c1e <write_head+0x3a>
  }
  bwrite(buf);
    80003c2a:	8526                	mv	a0,s1
    80003c2c:	97aff0ef          	jal	80002da6 <bwrite>
  brelse(buf);
    80003c30:	8526                	mv	a0,s1
    80003c32:	9a6ff0ef          	jal	80002dd8 <brelse>
}
    80003c36:	60e2                	ld	ra,24(sp)
    80003c38:	6442                	ld	s0,16(sp)
    80003c3a:	64a2                	ld	s1,8(sp)
    80003c3c:	6902                	ld	s2,0(sp)
    80003c3e:	6105                	addi	sp,sp,32
    80003c40:	8082                	ret

0000000080003c42 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c42:	0001f797          	auipc	a5,0x1f
    80003c46:	b7e7a783          	lw	a5,-1154(a5) # 800227c0 <log+0x28>
    80003c4a:	0af05e63          	blez	a5,80003d06 <install_trans+0xc4>
{
    80003c4e:	715d                	addi	sp,sp,-80
    80003c50:	e486                	sd	ra,72(sp)
    80003c52:	e0a2                	sd	s0,64(sp)
    80003c54:	fc26                	sd	s1,56(sp)
    80003c56:	f84a                	sd	s2,48(sp)
    80003c58:	f44e                	sd	s3,40(sp)
    80003c5a:	f052                	sd	s4,32(sp)
    80003c5c:	ec56                	sd	s5,24(sp)
    80003c5e:	e85a                	sd	s6,16(sp)
    80003c60:	e45e                	sd	s7,8(sp)
    80003c62:	0880                	addi	s0,sp,80
    80003c64:	8b2a                	mv	s6,a0
    80003c66:	0001fa97          	auipc	s5,0x1f
    80003c6a:	b5ea8a93          	addi	s5,s5,-1186 # 800227c4 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c6e:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003c70:	00004b97          	auipc	s7,0x4
    80003c74:	9c0b8b93          	addi	s7,s7,-1600 # 80007630 <etext+0x630>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003c78:	0001fa17          	auipc	s4,0x1f
    80003c7c:	b20a0a13          	addi	s4,s4,-1248 # 80022798 <log>
    80003c80:	a025                	j	80003ca8 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003c82:	000aa603          	lw	a2,0(s5)
    80003c86:	85ce                	mv	a1,s3
    80003c88:	855e                	mv	a0,s7
    80003c8a:	871fc0ef          	jal	800004fa <printf>
    80003c8e:	a839                	j	80003cac <install_trans+0x6a>
    brelse(lbuf);
    80003c90:	854a                	mv	a0,s2
    80003c92:	946ff0ef          	jal	80002dd8 <brelse>
    brelse(dbuf);
    80003c96:	8526                	mv	a0,s1
    80003c98:	940ff0ef          	jal	80002dd8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c9c:	2985                	addiw	s3,s3,1
    80003c9e:	0a91                	addi	s5,s5,4
    80003ca0:	028a2783          	lw	a5,40(s4)
    80003ca4:	04f9d663          	bge	s3,a5,80003cf0 <install_trans+0xae>
    if(recovering) {
    80003ca8:	fc0b1de3          	bnez	s6,80003c82 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003cac:	018a2583          	lw	a1,24(s4)
    80003cb0:	013585bb          	addw	a1,a1,s3
    80003cb4:	2585                	addiw	a1,a1,1
    80003cb6:	024a2503          	lw	a0,36(s4)
    80003cba:	816ff0ef          	jal	80002cd0 <bread>
    80003cbe:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003cc0:	000aa583          	lw	a1,0(s5)
    80003cc4:	024a2503          	lw	a0,36(s4)
    80003cc8:	808ff0ef          	jal	80002cd0 <bread>
    80003ccc:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003cce:	40000613          	li	a2,1024
    80003cd2:	05890593          	addi	a1,s2,88
    80003cd6:	05850513          	addi	a0,a0,88
    80003cda:	824fd0ef          	jal	80000cfe <memmove>
    bwrite(dbuf);  // write dst to disk
    80003cde:	8526                	mv	a0,s1
    80003ce0:	8c6ff0ef          	jal	80002da6 <bwrite>
    if(recovering == 0)
    80003ce4:	fa0b16e3          	bnez	s6,80003c90 <install_trans+0x4e>
      bunpin(dbuf);
    80003ce8:	8526                	mv	a0,s1
    80003cea:	9aaff0ef          	jal	80002e94 <bunpin>
    80003cee:	b74d                	j	80003c90 <install_trans+0x4e>
}
    80003cf0:	60a6                	ld	ra,72(sp)
    80003cf2:	6406                	ld	s0,64(sp)
    80003cf4:	74e2                	ld	s1,56(sp)
    80003cf6:	7942                	ld	s2,48(sp)
    80003cf8:	79a2                	ld	s3,40(sp)
    80003cfa:	7a02                	ld	s4,32(sp)
    80003cfc:	6ae2                	ld	s5,24(sp)
    80003cfe:	6b42                	ld	s6,16(sp)
    80003d00:	6ba2                	ld	s7,8(sp)
    80003d02:	6161                	addi	sp,sp,80
    80003d04:	8082                	ret
    80003d06:	8082                	ret

0000000080003d08 <initlog>:
{
    80003d08:	7179                	addi	sp,sp,-48
    80003d0a:	f406                	sd	ra,40(sp)
    80003d0c:	f022                	sd	s0,32(sp)
    80003d0e:	ec26                	sd	s1,24(sp)
    80003d10:	e84a                	sd	s2,16(sp)
    80003d12:	e44e                	sd	s3,8(sp)
    80003d14:	1800                	addi	s0,sp,48
    80003d16:	892a                	mv	s2,a0
    80003d18:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003d1a:	0001f497          	auipc	s1,0x1f
    80003d1e:	a7e48493          	addi	s1,s1,-1410 # 80022798 <log>
    80003d22:	00004597          	auipc	a1,0x4
    80003d26:	92e58593          	addi	a1,a1,-1746 # 80007650 <etext+0x650>
    80003d2a:	8526                	mv	a0,s1
    80003d2c:	e23fc0ef          	jal	80000b4e <initlock>
  log.start = sb->logstart;
    80003d30:	0149a583          	lw	a1,20(s3)
    80003d34:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003d36:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003d3a:	854a                	mv	a0,s2
    80003d3c:	f95fe0ef          	jal	80002cd0 <bread>
  log.lh.n = lh->n;
    80003d40:	4d30                	lw	a2,88(a0)
    80003d42:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003d44:	00c05f63          	blez	a2,80003d62 <initlog+0x5a>
    80003d48:	87aa                	mv	a5,a0
    80003d4a:	0001f717          	auipc	a4,0x1f
    80003d4e:	a7a70713          	addi	a4,a4,-1414 # 800227c4 <log+0x2c>
    80003d52:	060a                	slli	a2,a2,0x2
    80003d54:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003d56:	4ff4                	lw	a3,92(a5)
    80003d58:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003d5a:	0791                	addi	a5,a5,4
    80003d5c:	0711                	addi	a4,a4,4
    80003d5e:	fec79ce3          	bne	a5,a2,80003d56 <initlog+0x4e>
  brelse(buf);
    80003d62:	876ff0ef          	jal	80002dd8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003d66:	4505                	li	a0,1
    80003d68:	edbff0ef          	jal	80003c42 <install_trans>
  log.lh.n = 0;
    80003d6c:	0001f797          	auipc	a5,0x1f
    80003d70:	a407aa23          	sw	zero,-1452(a5) # 800227c0 <log+0x28>
  write_head(); // clear the log
    80003d74:	e71ff0ef          	jal	80003be4 <write_head>
}
    80003d78:	70a2                	ld	ra,40(sp)
    80003d7a:	7402                	ld	s0,32(sp)
    80003d7c:	64e2                	ld	s1,24(sp)
    80003d7e:	6942                	ld	s2,16(sp)
    80003d80:	69a2                	ld	s3,8(sp)
    80003d82:	6145                	addi	sp,sp,48
    80003d84:	8082                	ret

0000000080003d86 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003d86:	1101                	addi	sp,sp,-32
    80003d88:	ec06                	sd	ra,24(sp)
    80003d8a:	e822                	sd	s0,16(sp)
    80003d8c:	e426                	sd	s1,8(sp)
    80003d8e:	e04a                	sd	s2,0(sp)
    80003d90:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003d92:	0001f517          	auipc	a0,0x1f
    80003d96:	a0650513          	addi	a0,a0,-1530 # 80022798 <log>
    80003d9a:	e35fc0ef          	jal	80000bce <acquire>
  while(1){
    if(log.committing){
    80003d9e:	0001f497          	auipc	s1,0x1f
    80003da2:	9fa48493          	addi	s1,s1,-1542 # 80022798 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003da6:	4979                	li	s2,30
    80003da8:	a029                	j	80003db2 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003daa:	85a6                	mv	a1,s1
    80003dac:	8526                	mv	a0,s1
    80003dae:	926fe0ef          	jal	80001ed4 <sleep>
    if(log.committing){
    80003db2:	509c                	lw	a5,32(s1)
    80003db4:	fbfd                	bnez	a5,80003daa <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003db6:	4cd8                	lw	a4,28(s1)
    80003db8:	2705                	addiw	a4,a4,1
    80003dba:	0027179b          	slliw	a5,a4,0x2
    80003dbe:	9fb9                	addw	a5,a5,a4
    80003dc0:	0017979b          	slliw	a5,a5,0x1
    80003dc4:	5494                	lw	a3,40(s1)
    80003dc6:	9fb5                	addw	a5,a5,a3
    80003dc8:	00f95763          	bge	s2,a5,80003dd6 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003dcc:	85a6                	mv	a1,s1
    80003dce:	8526                	mv	a0,s1
    80003dd0:	904fe0ef          	jal	80001ed4 <sleep>
    80003dd4:	bff9                	j	80003db2 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003dd6:	0001f517          	auipc	a0,0x1f
    80003dda:	9c250513          	addi	a0,a0,-1598 # 80022798 <log>
    80003dde:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80003de0:	e87fc0ef          	jal	80000c66 <release>
      break;
    }
  }
}
    80003de4:	60e2                	ld	ra,24(sp)
    80003de6:	6442                	ld	s0,16(sp)
    80003de8:	64a2                	ld	s1,8(sp)
    80003dea:	6902                	ld	s2,0(sp)
    80003dec:	6105                	addi	sp,sp,32
    80003dee:	8082                	ret

0000000080003df0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003df0:	7139                	addi	sp,sp,-64
    80003df2:	fc06                	sd	ra,56(sp)
    80003df4:	f822                	sd	s0,48(sp)
    80003df6:	f426                	sd	s1,40(sp)
    80003df8:	f04a                	sd	s2,32(sp)
    80003dfa:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003dfc:	0001f497          	auipc	s1,0x1f
    80003e00:	99c48493          	addi	s1,s1,-1636 # 80022798 <log>
    80003e04:	8526                	mv	a0,s1
    80003e06:	dc9fc0ef          	jal	80000bce <acquire>
  log.outstanding -= 1;
    80003e0a:	4cdc                	lw	a5,28(s1)
    80003e0c:	37fd                	addiw	a5,a5,-1
    80003e0e:	0007891b          	sext.w	s2,a5
    80003e12:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003e14:	509c                	lw	a5,32(s1)
    80003e16:	ef9d                	bnez	a5,80003e54 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003e18:	04091763          	bnez	s2,80003e66 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003e1c:	0001f497          	auipc	s1,0x1f
    80003e20:	97c48493          	addi	s1,s1,-1668 # 80022798 <log>
    80003e24:	4785                	li	a5,1
    80003e26:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003e28:	8526                	mv	a0,s1
    80003e2a:	e3dfc0ef          	jal	80000c66 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003e2e:	549c                	lw	a5,40(s1)
    80003e30:	04f04b63          	bgtz	a5,80003e86 <end_op+0x96>
    acquire(&log.lock);
    80003e34:	0001f497          	auipc	s1,0x1f
    80003e38:	96448493          	addi	s1,s1,-1692 # 80022798 <log>
    80003e3c:	8526                	mv	a0,s1
    80003e3e:	d91fc0ef          	jal	80000bce <acquire>
    log.committing = 0;
    80003e42:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003e46:	8526                	mv	a0,s1
    80003e48:	8d8fe0ef          	jal	80001f20 <wakeup>
    release(&log.lock);
    80003e4c:	8526                	mv	a0,s1
    80003e4e:	e19fc0ef          	jal	80000c66 <release>
}
    80003e52:	a025                	j	80003e7a <end_op+0x8a>
    80003e54:	ec4e                	sd	s3,24(sp)
    80003e56:	e852                	sd	s4,16(sp)
    80003e58:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003e5a:	00003517          	auipc	a0,0x3
    80003e5e:	7fe50513          	addi	a0,a0,2046 # 80007658 <etext+0x658>
    80003e62:	97ffc0ef          	jal	800007e0 <panic>
    wakeup(&log);
    80003e66:	0001f497          	auipc	s1,0x1f
    80003e6a:	93248493          	addi	s1,s1,-1742 # 80022798 <log>
    80003e6e:	8526                	mv	a0,s1
    80003e70:	8b0fe0ef          	jal	80001f20 <wakeup>
  release(&log.lock);
    80003e74:	8526                	mv	a0,s1
    80003e76:	df1fc0ef          	jal	80000c66 <release>
}
    80003e7a:	70e2                	ld	ra,56(sp)
    80003e7c:	7442                	ld	s0,48(sp)
    80003e7e:	74a2                	ld	s1,40(sp)
    80003e80:	7902                	ld	s2,32(sp)
    80003e82:	6121                	addi	sp,sp,64
    80003e84:	8082                	ret
    80003e86:	ec4e                	sd	s3,24(sp)
    80003e88:	e852                	sd	s4,16(sp)
    80003e8a:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e8c:	0001fa97          	auipc	s5,0x1f
    80003e90:	938a8a93          	addi	s5,s5,-1736 # 800227c4 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003e94:	0001fa17          	auipc	s4,0x1f
    80003e98:	904a0a13          	addi	s4,s4,-1788 # 80022798 <log>
    80003e9c:	018a2583          	lw	a1,24(s4)
    80003ea0:	012585bb          	addw	a1,a1,s2
    80003ea4:	2585                	addiw	a1,a1,1
    80003ea6:	024a2503          	lw	a0,36(s4)
    80003eaa:	e27fe0ef          	jal	80002cd0 <bread>
    80003eae:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003eb0:	000aa583          	lw	a1,0(s5)
    80003eb4:	024a2503          	lw	a0,36(s4)
    80003eb8:	e19fe0ef          	jal	80002cd0 <bread>
    80003ebc:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003ebe:	40000613          	li	a2,1024
    80003ec2:	05850593          	addi	a1,a0,88
    80003ec6:	05848513          	addi	a0,s1,88
    80003eca:	e35fc0ef          	jal	80000cfe <memmove>
    bwrite(to);  // write the log
    80003ece:	8526                	mv	a0,s1
    80003ed0:	ed7fe0ef          	jal	80002da6 <bwrite>
    brelse(from);
    80003ed4:	854e                	mv	a0,s3
    80003ed6:	f03fe0ef          	jal	80002dd8 <brelse>
    brelse(to);
    80003eda:	8526                	mv	a0,s1
    80003edc:	efdfe0ef          	jal	80002dd8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ee0:	2905                	addiw	s2,s2,1
    80003ee2:	0a91                	addi	s5,s5,4
    80003ee4:	028a2783          	lw	a5,40(s4)
    80003ee8:	faf94ae3          	blt	s2,a5,80003e9c <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003eec:	cf9ff0ef          	jal	80003be4 <write_head>
    install_trans(0); // Now install writes to home locations
    80003ef0:	4501                	li	a0,0
    80003ef2:	d51ff0ef          	jal	80003c42 <install_trans>
    log.lh.n = 0;
    80003ef6:	0001f797          	auipc	a5,0x1f
    80003efa:	8c07a523          	sw	zero,-1846(a5) # 800227c0 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003efe:	ce7ff0ef          	jal	80003be4 <write_head>
    80003f02:	69e2                	ld	s3,24(sp)
    80003f04:	6a42                	ld	s4,16(sp)
    80003f06:	6aa2                	ld	s5,8(sp)
    80003f08:	b735                	j	80003e34 <end_op+0x44>

0000000080003f0a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003f0a:	1101                	addi	sp,sp,-32
    80003f0c:	ec06                	sd	ra,24(sp)
    80003f0e:	e822                	sd	s0,16(sp)
    80003f10:	e426                	sd	s1,8(sp)
    80003f12:	e04a                	sd	s2,0(sp)
    80003f14:	1000                	addi	s0,sp,32
    80003f16:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003f18:	0001f917          	auipc	s2,0x1f
    80003f1c:	88090913          	addi	s2,s2,-1920 # 80022798 <log>
    80003f20:	854a                	mv	a0,s2
    80003f22:	cadfc0ef          	jal	80000bce <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003f26:	02892603          	lw	a2,40(s2)
    80003f2a:	47f5                	li	a5,29
    80003f2c:	04c7cc63          	blt	a5,a2,80003f84 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003f30:	0001f797          	auipc	a5,0x1f
    80003f34:	8847a783          	lw	a5,-1916(a5) # 800227b4 <log+0x1c>
    80003f38:	04f05c63          	blez	a5,80003f90 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003f3c:	4781                	li	a5,0
    80003f3e:	04c05f63          	blez	a2,80003f9c <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003f42:	44cc                	lw	a1,12(s1)
    80003f44:	0001f717          	auipc	a4,0x1f
    80003f48:	88070713          	addi	a4,a4,-1920 # 800227c4 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003f4c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003f4e:	4314                	lw	a3,0(a4)
    80003f50:	04b68663          	beq	a3,a1,80003f9c <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003f54:	2785                	addiw	a5,a5,1
    80003f56:	0711                	addi	a4,a4,4
    80003f58:	fef61be3          	bne	a2,a5,80003f4e <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003f5c:	0621                	addi	a2,a2,8
    80003f5e:	060a                	slli	a2,a2,0x2
    80003f60:	0001f797          	auipc	a5,0x1f
    80003f64:	83878793          	addi	a5,a5,-1992 # 80022798 <log>
    80003f68:	97b2                	add	a5,a5,a2
    80003f6a:	44d8                	lw	a4,12(s1)
    80003f6c:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003f6e:	8526                	mv	a0,s1
    80003f70:	ef1fe0ef          	jal	80002e60 <bpin>
    log.lh.n++;
    80003f74:	0001f717          	auipc	a4,0x1f
    80003f78:	82470713          	addi	a4,a4,-2012 # 80022798 <log>
    80003f7c:	571c                	lw	a5,40(a4)
    80003f7e:	2785                	addiw	a5,a5,1
    80003f80:	d71c                	sw	a5,40(a4)
    80003f82:	a80d                	j	80003fb4 <log_write+0xaa>
    panic("too big a transaction");
    80003f84:	00003517          	auipc	a0,0x3
    80003f88:	6e450513          	addi	a0,a0,1764 # 80007668 <etext+0x668>
    80003f8c:	855fc0ef          	jal	800007e0 <panic>
    panic("log_write outside of trans");
    80003f90:	00003517          	auipc	a0,0x3
    80003f94:	6f050513          	addi	a0,a0,1776 # 80007680 <etext+0x680>
    80003f98:	849fc0ef          	jal	800007e0 <panic>
  log.lh.block[i] = b->blockno;
    80003f9c:	00878693          	addi	a3,a5,8
    80003fa0:	068a                	slli	a3,a3,0x2
    80003fa2:	0001e717          	auipc	a4,0x1e
    80003fa6:	7f670713          	addi	a4,a4,2038 # 80022798 <log>
    80003faa:	9736                	add	a4,a4,a3
    80003fac:	44d4                	lw	a3,12(s1)
    80003fae:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003fb0:	faf60fe3          	beq	a2,a5,80003f6e <log_write+0x64>
  }
  release(&log.lock);
    80003fb4:	0001e517          	auipc	a0,0x1e
    80003fb8:	7e450513          	addi	a0,a0,2020 # 80022798 <log>
    80003fbc:	cabfc0ef          	jal	80000c66 <release>
}
    80003fc0:	60e2                	ld	ra,24(sp)
    80003fc2:	6442                	ld	s0,16(sp)
    80003fc4:	64a2                	ld	s1,8(sp)
    80003fc6:	6902                	ld	s2,0(sp)
    80003fc8:	6105                	addi	sp,sp,32
    80003fca:	8082                	ret

0000000080003fcc <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003fcc:	1101                	addi	sp,sp,-32
    80003fce:	ec06                	sd	ra,24(sp)
    80003fd0:	e822                	sd	s0,16(sp)
    80003fd2:	e426                	sd	s1,8(sp)
    80003fd4:	e04a                	sd	s2,0(sp)
    80003fd6:	1000                	addi	s0,sp,32
    80003fd8:	84aa                	mv	s1,a0
    80003fda:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003fdc:	00003597          	auipc	a1,0x3
    80003fe0:	6c458593          	addi	a1,a1,1732 # 800076a0 <etext+0x6a0>
    80003fe4:	0521                	addi	a0,a0,8
    80003fe6:	b69fc0ef          	jal	80000b4e <initlock>
  lk->name = name;
    80003fea:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003fee:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003ff2:	0204a423          	sw	zero,40(s1)
}
    80003ff6:	60e2                	ld	ra,24(sp)
    80003ff8:	6442                	ld	s0,16(sp)
    80003ffa:	64a2                	ld	s1,8(sp)
    80003ffc:	6902                	ld	s2,0(sp)
    80003ffe:	6105                	addi	sp,sp,32
    80004000:	8082                	ret

0000000080004002 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004002:	1101                	addi	sp,sp,-32
    80004004:	ec06                	sd	ra,24(sp)
    80004006:	e822                	sd	s0,16(sp)
    80004008:	e426                	sd	s1,8(sp)
    8000400a:	e04a                	sd	s2,0(sp)
    8000400c:	1000                	addi	s0,sp,32
    8000400e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004010:	00850913          	addi	s2,a0,8
    80004014:	854a                	mv	a0,s2
    80004016:	bb9fc0ef          	jal	80000bce <acquire>
  while (lk->locked) {
    8000401a:	409c                	lw	a5,0(s1)
    8000401c:	c799                	beqz	a5,8000402a <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    8000401e:	85ca                	mv	a1,s2
    80004020:	8526                	mv	a0,s1
    80004022:	eb3fd0ef          	jal	80001ed4 <sleep>
  while (lk->locked) {
    80004026:	409c                	lw	a5,0(s1)
    80004028:	fbfd                	bnez	a5,8000401e <acquiresleep+0x1c>
  }
  lk->locked = 1;
    8000402a:	4785                	li	a5,1
    8000402c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000402e:	8a1fd0ef          	jal	800018ce <myproc>
    80004032:	591c                	lw	a5,48(a0)
    80004034:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004036:	854a                	mv	a0,s2
    80004038:	c2ffc0ef          	jal	80000c66 <release>
}
    8000403c:	60e2                	ld	ra,24(sp)
    8000403e:	6442                	ld	s0,16(sp)
    80004040:	64a2                	ld	s1,8(sp)
    80004042:	6902                	ld	s2,0(sp)
    80004044:	6105                	addi	sp,sp,32
    80004046:	8082                	ret

0000000080004048 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004048:	1101                	addi	sp,sp,-32
    8000404a:	ec06                	sd	ra,24(sp)
    8000404c:	e822                	sd	s0,16(sp)
    8000404e:	e426                	sd	s1,8(sp)
    80004050:	e04a                	sd	s2,0(sp)
    80004052:	1000                	addi	s0,sp,32
    80004054:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004056:	00850913          	addi	s2,a0,8
    8000405a:	854a                	mv	a0,s2
    8000405c:	b73fc0ef          	jal	80000bce <acquire>
  lk->locked = 0;
    80004060:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004064:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004068:	8526                	mv	a0,s1
    8000406a:	eb7fd0ef          	jal	80001f20 <wakeup>
  release(&lk->lk);
    8000406e:	854a                	mv	a0,s2
    80004070:	bf7fc0ef          	jal	80000c66 <release>
}
    80004074:	60e2                	ld	ra,24(sp)
    80004076:	6442                	ld	s0,16(sp)
    80004078:	64a2                	ld	s1,8(sp)
    8000407a:	6902                	ld	s2,0(sp)
    8000407c:	6105                	addi	sp,sp,32
    8000407e:	8082                	ret

0000000080004080 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004080:	7179                	addi	sp,sp,-48
    80004082:	f406                	sd	ra,40(sp)
    80004084:	f022                	sd	s0,32(sp)
    80004086:	ec26                	sd	s1,24(sp)
    80004088:	e84a                	sd	s2,16(sp)
    8000408a:	1800                	addi	s0,sp,48
    8000408c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000408e:	00850913          	addi	s2,a0,8
    80004092:	854a                	mv	a0,s2
    80004094:	b3bfc0ef          	jal	80000bce <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004098:	409c                	lw	a5,0(s1)
    8000409a:	ef81                	bnez	a5,800040b2 <holdingsleep+0x32>
    8000409c:	4481                	li	s1,0
  release(&lk->lk);
    8000409e:	854a                	mv	a0,s2
    800040a0:	bc7fc0ef          	jal	80000c66 <release>
  return r;
}
    800040a4:	8526                	mv	a0,s1
    800040a6:	70a2                	ld	ra,40(sp)
    800040a8:	7402                	ld	s0,32(sp)
    800040aa:	64e2                	ld	s1,24(sp)
    800040ac:	6942                	ld	s2,16(sp)
    800040ae:	6145                	addi	sp,sp,48
    800040b0:	8082                	ret
    800040b2:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800040b4:	0284a983          	lw	s3,40(s1)
    800040b8:	817fd0ef          	jal	800018ce <myproc>
    800040bc:	5904                	lw	s1,48(a0)
    800040be:	413484b3          	sub	s1,s1,s3
    800040c2:	0014b493          	seqz	s1,s1
    800040c6:	69a2                	ld	s3,8(sp)
    800040c8:	bfd9                	j	8000409e <holdingsleep+0x1e>

00000000800040ca <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800040ca:	1141                	addi	sp,sp,-16
    800040cc:	e406                	sd	ra,8(sp)
    800040ce:	e022                	sd	s0,0(sp)
    800040d0:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800040d2:	00003597          	auipc	a1,0x3
    800040d6:	5de58593          	addi	a1,a1,1502 # 800076b0 <etext+0x6b0>
    800040da:	0001f517          	auipc	a0,0x1f
    800040de:	80650513          	addi	a0,a0,-2042 # 800228e0 <ftable>
    800040e2:	a6dfc0ef          	jal	80000b4e <initlock>
}
    800040e6:	60a2                	ld	ra,8(sp)
    800040e8:	6402                	ld	s0,0(sp)
    800040ea:	0141                	addi	sp,sp,16
    800040ec:	8082                	ret

00000000800040ee <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800040ee:	1101                	addi	sp,sp,-32
    800040f0:	ec06                	sd	ra,24(sp)
    800040f2:	e822                	sd	s0,16(sp)
    800040f4:	e426                	sd	s1,8(sp)
    800040f6:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800040f8:	0001e517          	auipc	a0,0x1e
    800040fc:	7e850513          	addi	a0,a0,2024 # 800228e0 <ftable>
    80004100:	acffc0ef          	jal	80000bce <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004104:	0001e497          	auipc	s1,0x1e
    80004108:	7f448493          	addi	s1,s1,2036 # 800228f8 <ftable+0x18>
    8000410c:	0001f717          	auipc	a4,0x1f
    80004110:	78c70713          	addi	a4,a4,1932 # 80023898 <disk>
    if(f->ref == 0){
    80004114:	40dc                	lw	a5,4(s1)
    80004116:	cf89                	beqz	a5,80004130 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004118:	02848493          	addi	s1,s1,40
    8000411c:	fee49ce3          	bne	s1,a4,80004114 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004120:	0001e517          	auipc	a0,0x1e
    80004124:	7c050513          	addi	a0,a0,1984 # 800228e0 <ftable>
    80004128:	b3ffc0ef          	jal	80000c66 <release>
  return 0;
    8000412c:	4481                	li	s1,0
    8000412e:	a809                	j	80004140 <filealloc+0x52>
      f->ref = 1;
    80004130:	4785                	li	a5,1
    80004132:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004134:	0001e517          	auipc	a0,0x1e
    80004138:	7ac50513          	addi	a0,a0,1964 # 800228e0 <ftable>
    8000413c:	b2bfc0ef          	jal	80000c66 <release>
}
    80004140:	8526                	mv	a0,s1
    80004142:	60e2                	ld	ra,24(sp)
    80004144:	6442                	ld	s0,16(sp)
    80004146:	64a2                	ld	s1,8(sp)
    80004148:	6105                	addi	sp,sp,32
    8000414a:	8082                	ret

000000008000414c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000414c:	1101                	addi	sp,sp,-32
    8000414e:	ec06                	sd	ra,24(sp)
    80004150:	e822                	sd	s0,16(sp)
    80004152:	e426                	sd	s1,8(sp)
    80004154:	1000                	addi	s0,sp,32
    80004156:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004158:	0001e517          	auipc	a0,0x1e
    8000415c:	78850513          	addi	a0,a0,1928 # 800228e0 <ftable>
    80004160:	a6ffc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    80004164:	40dc                	lw	a5,4(s1)
    80004166:	02f05063          	blez	a5,80004186 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000416a:	2785                	addiw	a5,a5,1
    8000416c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000416e:	0001e517          	auipc	a0,0x1e
    80004172:	77250513          	addi	a0,a0,1906 # 800228e0 <ftable>
    80004176:	af1fc0ef          	jal	80000c66 <release>
  return f;
}
    8000417a:	8526                	mv	a0,s1
    8000417c:	60e2                	ld	ra,24(sp)
    8000417e:	6442                	ld	s0,16(sp)
    80004180:	64a2                	ld	s1,8(sp)
    80004182:	6105                	addi	sp,sp,32
    80004184:	8082                	ret
    panic("filedup");
    80004186:	00003517          	auipc	a0,0x3
    8000418a:	53250513          	addi	a0,a0,1330 # 800076b8 <etext+0x6b8>
    8000418e:	e52fc0ef          	jal	800007e0 <panic>

0000000080004192 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004192:	7139                	addi	sp,sp,-64
    80004194:	fc06                	sd	ra,56(sp)
    80004196:	f822                	sd	s0,48(sp)
    80004198:	f426                	sd	s1,40(sp)
    8000419a:	0080                	addi	s0,sp,64
    8000419c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000419e:	0001e517          	auipc	a0,0x1e
    800041a2:	74250513          	addi	a0,a0,1858 # 800228e0 <ftable>
    800041a6:	a29fc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    800041aa:	40dc                	lw	a5,4(s1)
    800041ac:	04f05a63          	blez	a5,80004200 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800041b0:	37fd                	addiw	a5,a5,-1
    800041b2:	0007871b          	sext.w	a4,a5
    800041b6:	c0dc                	sw	a5,4(s1)
    800041b8:	04e04e63          	bgtz	a4,80004214 <fileclose+0x82>
    800041bc:	f04a                	sd	s2,32(sp)
    800041be:	ec4e                	sd	s3,24(sp)
    800041c0:	e852                	sd	s4,16(sp)
    800041c2:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800041c4:	0004a903          	lw	s2,0(s1)
    800041c8:	0094ca83          	lbu	s5,9(s1)
    800041cc:	0104ba03          	ld	s4,16(s1)
    800041d0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800041d4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800041d8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800041dc:	0001e517          	auipc	a0,0x1e
    800041e0:	70450513          	addi	a0,a0,1796 # 800228e0 <ftable>
    800041e4:	a83fc0ef          	jal	80000c66 <release>

  if(ff.type == FD_PIPE){
    800041e8:	4785                	li	a5,1
    800041ea:	04f90063          	beq	s2,a5,8000422a <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800041ee:	3979                	addiw	s2,s2,-2
    800041f0:	4785                	li	a5,1
    800041f2:	0527f563          	bgeu	a5,s2,8000423c <fileclose+0xaa>
    800041f6:	7902                	ld	s2,32(sp)
    800041f8:	69e2                	ld	s3,24(sp)
    800041fa:	6a42                	ld	s4,16(sp)
    800041fc:	6aa2                	ld	s5,8(sp)
    800041fe:	a00d                	j	80004220 <fileclose+0x8e>
    80004200:	f04a                	sd	s2,32(sp)
    80004202:	ec4e                	sd	s3,24(sp)
    80004204:	e852                	sd	s4,16(sp)
    80004206:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004208:	00003517          	auipc	a0,0x3
    8000420c:	4b850513          	addi	a0,a0,1208 # 800076c0 <etext+0x6c0>
    80004210:	dd0fc0ef          	jal	800007e0 <panic>
    release(&ftable.lock);
    80004214:	0001e517          	auipc	a0,0x1e
    80004218:	6cc50513          	addi	a0,a0,1740 # 800228e0 <ftable>
    8000421c:	a4bfc0ef          	jal	80000c66 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004220:	70e2                	ld	ra,56(sp)
    80004222:	7442                	ld	s0,48(sp)
    80004224:	74a2                	ld	s1,40(sp)
    80004226:	6121                	addi	sp,sp,64
    80004228:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000422a:	85d6                	mv	a1,s5
    8000422c:	8552                	mv	a0,s4
    8000422e:	336000ef          	jal	80004564 <pipeclose>
    80004232:	7902                	ld	s2,32(sp)
    80004234:	69e2                	ld	s3,24(sp)
    80004236:	6a42                	ld	s4,16(sp)
    80004238:	6aa2                	ld	s5,8(sp)
    8000423a:	b7dd                	j	80004220 <fileclose+0x8e>
    begin_op();
    8000423c:	b4bff0ef          	jal	80003d86 <begin_op>
    iput(ff.ip);
    80004240:	854e                	mv	a0,s3
    80004242:	adcff0ef          	jal	8000351e <iput>
    end_op();
    80004246:	babff0ef          	jal	80003df0 <end_op>
    8000424a:	7902                	ld	s2,32(sp)
    8000424c:	69e2                	ld	s3,24(sp)
    8000424e:	6a42                	ld	s4,16(sp)
    80004250:	6aa2                	ld	s5,8(sp)
    80004252:	b7f9                	j	80004220 <fileclose+0x8e>

0000000080004254 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004254:	715d                	addi	sp,sp,-80
    80004256:	e486                	sd	ra,72(sp)
    80004258:	e0a2                	sd	s0,64(sp)
    8000425a:	fc26                	sd	s1,56(sp)
    8000425c:	f44e                	sd	s3,40(sp)
    8000425e:	0880                	addi	s0,sp,80
    80004260:	84aa                	mv	s1,a0
    80004262:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004264:	e6afd0ef          	jal	800018ce <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004268:	409c                	lw	a5,0(s1)
    8000426a:	37f9                	addiw	a5,a5,-2
    8000426c:	4705                	li	a4,1
    8000426e:	04f76063          	bltu	a4,a5,800042ae <filestat+0x5a>
    80004272:	f84a                	sd	s2,48(sp)
    80004274:	892a                	mv	s2,a0
    ilock(f->ip);
    80004276:	6c88                	ld	a0,24(s1)
    80004278:	924ff0ef          	jal	8000339c <ilock>
    stati(f->ip, &st);
    8000427c:	fb840593          	addi	a1,s0,-72
    80004280:	6c88                	ld	a0,24(s1)
    80004282:	c80ff0ef          	jal	80003702 <stati>
    iunlock(f->ip);
    80004286:	6c88                	ld	a0,24(s1)
    80004288:	9c2ff0ef          	jal	8000344a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000428c:	46e1                	li	a3,24
    8000428e:	fb840613          	addi	a2,s0,-72
    80004292:	85ce                	mv	a1,s3
    80004294:	05093503          	ld	a0,80(s2)
    80004298:	b4afd0ef          	jal	800015e2 <copyout>
    8000429c:	41f5551b          	sraiw	a0,a0,0x1f
    800042a0:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800042a2:	60a6                	ld	ra,72(sp)
    800042a4:	6406                	ld	s0,64(sp)
    800042a6:	74e2                	ld	s1,56(sp)
    800042a8:	79a2                	ld	s3,40(sp)
    800042aa:	6161                	addi	sp,sp,80
    800042ac:	8082                	ret
  return -1;
    800042ae:	557d                	li	a0,-1
    800042b0:	bfcd                	j	800042a2 <filestat+0x4e>

00000000800042b2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800042b2:	7179                	addi	sp,sp,-48
    800042b4:	f406                	sd	ra,40(sp)
    800042b6:	f022                	sd	s0,32(sp)
    800042b8:	e84a                	sd	s2,16(sp)
    800042ba:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800042bc:	00854783          	lbu	a5,8(a0)
    800042c0:	cfd1                	beqz	a5,8000435c <fileread+0xaa>
    800042c2:	ec26                	sd	s1,24(sp)
    800042c4:	e44e                	sd	s3,8(sp)
    800042c6:	84aa                	mv	s1,a0
    800042c8:	89ae                	mv	s3,a1
    800042ca:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800042cc:	411c                	lw	a5,0(a0)
    800042ce:	4705                	li	a4,1
    800042d0:	04e78363          	beq	a5,a4,80004316 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800042d4:	470d                	li	a4,3
    800042d6:	04e78763          	beq	a5,a4,80004324 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800042da:	4709                	li	a4,2
    800042dc:	06e79a63          	bne	a5,a4,80004350 <fileread+0x9e>
    ilock(f->ip);
    800042e0:	6d08                	ld	a0,24(a0)
    800042e2:	8baff0ef          	jal	8000339c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800042e6:	874a                	mv	a4,s2
    800042e8:	5094                	lw	a3,32(s1)
    800042ea:	864e                	mv	a2,s3
    800042ec:	4585                	li	a1,1
    800042ee:	6c88                	ld	a0,24(s1)
    800042f0:	c3cff0ef          	jal	8000372c <readi>
    800042f4:	892a                	mv	s2,a0
    800042f6:	00a05563          	blez	a0,80004300 <fileread+0x4e>
      f->off += r;
    800042fa:	509c                	lw	a5,32(s1)
    800042fc:	9fa9                	addw	a5,a5,a0
    800042fe:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004300:	6c88                	ld	a0,24(s1)
    80004302:	948ff0ef          	jal	8000344a <iunlock>
    80004306:	64e2                	ld	s1,24(sp)
    80004308:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000430a:	854a                	mv	a0,s2
    8000430c:	70a2                	ld	ra,40(sp)
    8000430e:	7402                	ld	s0,32(sp)
    80004310:	6942                	ld	s2,16(sp)
    80004312:	6145                	addi	sp,sp,48
    80004314:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004316:	6908                	ld	a0,16(a0)
    80004318:	388000ef          	jal	800046a0 <piperead>
    8000431c:	892a                	mv	s2,a0
    8000431e:	64e2                	ld	s1,24(sp)
    80004320:	69a2                	ld	s3,8(sp)
    80004322:	b7e5                	j	8000430a <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004324:	02451783          	lh	a5,36(a0)
    80004328:	03079693          	slli	a3,a5,0x30
    8000432c:	92c1                	srli	a3,a3,0x30
    8000432e:	4725                	li	a4,9
    80004330:	02d76863          	bltu	a4,a3,80004360 <fileread+0xae>
    80004334:	0792                	slli	a5,a5,0x4
    80004336:	0001e717          	auipc	a4,0x1e
    8000433a:	50a70713          	addi	a4,a4,1290 # 80022840 <devsw>
    8000433e:	97ba                	add	a5,a5,a4
    80004340:	639c                	ld	a5,0(a5)
    80004342:	c39d                	beqz	a5,80004368 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004344:	4505                	li	a0,1
    80004346:	9782                	jalr	a5
    80004348:	892a                	mv	s2,a0
    8000434a:	64e2                	ld	s1,24(sp)
    8000434c:	69a2                	ld	s3,8(sp)
    8000434e:	bf75                	j	8000430a <fileread+0x58>
    panic("fileread");
    80004350:	00003517          	auipc	a0,0x3
    80004354:	38050513          	addi	a0,a0,896 # 800076d0 <etext+0x6d0>
    80004358:	c88fc0ef          	jal	800007e0 <panic>
    return -1;
    8000435c:	597d                	li	s2,-1
    8000435e:	b775                	j	8000430a <fileread+0x58>
      return -1;
    80004360:	597d                	li	s2,-1
    80004362:	64e2                	ld	s1,24(sp)
    80004364:	69a2                	ld	s3,8(sp)
    80004366:	b755                	j	8000430a <fileread+0x58>
    80004368:	597d                	li	s2,-1
    8000436a:	64e2                	ld	s1,24(sp)
    8000436c:	69a2                	ld	s3,8(sp)
    8000436e:	bf71                	j	8000430a <fileread+0x58>

0000000080004370 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004370:	00954783          	lbu	a5,9(a0)
    80004374:	10078b63          	beqz	a5,8000448a <filewrite+0x11a>
{
    80004378:	715d                	addi	sp,sp,-80
    8000437a:	e486                	sd	ra,72(sp)
    8000437c:	e0a2                	sd	s0,64(sp)
    8000437e:	f84a                	sd	s2,48(sp)
    80004380:	f052                	sd	s4,32(sp)
    80004382:	e85a                	sd	s6,16(sp)
    80004384:	0880                	addi	s0,sp,80
    80004386:	892a                	mv	s2,a0
    80004388:	8b2e                	mv	s6,a1
    8000438a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000438c:	411c                	lw	a5,0(a0)
    8000438e:	4705                	li	a4,1
    80004390:	02e78763          	beq	a5,a4,800043be <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004394:	470d                	li	a4,3
    80004396:	02e78863          	beq	a5,a4,800043c6 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000439a:	4709                	li	a4,2
    8000439c:	0ce79c63          	bne	a5,a4,80004474 <filewrite+0x104>
    800043a0:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800043a2:	0ac05863          	blez	a2,80004452 <filewrite+0xe2>
    800043a6:	fc26                	sd	s1,56(sp)
    800043a8:	ec56                	sd	s5,24(sp)
    800043aa:	e45e                	sd	s7,8(sp)
    800043ac:	e062                	sd	s8,0(sp)
    int i = 0;
    800043ae:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800043b0:	6b85                	lui	s7,0x1
    800043b2:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800043b6:	6c05                	lui	s8,0x1
    800043b8:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800043bc:	a8b5                	j	80004438 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800043be:	6908                	ld	a0,16(a0)
    800043c0:	1fc000ef          	jal	800045bc <pipewrite>
    800043c4:	a04d                	j	80004466 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800043c6:	02451783          	lh	a5,36(a0)
    800043ca:	03079693          	slli	a3,a5,0x30
    800043ce:	92c1                	srli	a3,a3,0x30
    800043d0:	4725                	li	a4,9
    800043d2:	0ad76e63          	bltu	a4,a3,8000448e <filewrite+0x11e>
    800043d6:	0792                	slli	a5,a5,0x4
    800043d8:	0001e717          	auipc	a4,0x1e
    800043dc:	46870713          	addi	a4,a4,1128 # 80022840 <devsw>
    800043e0:	97ba                	add	a5,a5,a4
    800043e2:	679c                	ld	a5,8(a5)
    800043e4:	c7dd                	beqz	a5,80004492 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800043e6:	4505                	li	a0,1
    800043e8:	9782                	jalr	a5
    800043ea:	a8b5                	j	80004466 <filewrite+0xf6>
      if(n1 > max)
    800043ec:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800043f0:	997ff0ef          	jal	80003d86 <begin_op>
      ilock(f->ip);
    800043f4:	01893503          	ld	a0,24(s2)
    800043f8:	fa5fe0ef          	jal	8000339c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800043fc:	8756                	mv	a4,s5
    800043fe:	02092683          	lw	a3,32(s2)
    80004402:	01698633          	add	a2,s3,s6
    80004406:	4585                	li	a1,1
    80004408:	01893503          	ld	a0,24(s2)
    8000440c:	c1cff0ef          	jal	80003828 <writei>
    80004410:	84aa                	mv	s1,a0
    80004412:	00a05763          	blez	a0,80004420 <filewrite+0xb0>
        f->off += r;
    80004416:	02092783          	lw	a5,32(s2)
    8000441a:	9fa9                	addw	a5,a5,a0
    8000441c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004420:	01893503          	ld	a0,24(s2)
    80004424:	826ff0ef          	jal	8000344a <iunlock>
      end_op();
    80004428:	9c9ff0ef          	jal	80003df0 <end_op>

      if(r != n1){
    8000442c:	029a9563          	bne	s5,s1,80004456 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80004430:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004434:	0149da63          	bge	s3,s4,80004448 <filewrite+0xd8>
      int n1 = n - i;
    80004438:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    8000443c:	0004879b          	sext.w	a5,s1
    80004440:	fafbd6e3          	bge	s7,a5,800043ec <filewrite+0x7c>
    80004444:	84e2                	mv	s1,s8
    80004446:	b75d                	j	800043ec <filewrite+0x7c>
    80004448:	74e2                	ld	s1,56(sp)
    8000444a:	6ae2                	ld	s5,24(sp)
    8000444c:	6ba2                	ld	s7,8(sp)
    8000444e:	6c02                	ld	s8,0(sp)
    80004450:	a039                	j	8000445e <filewrite+0xee>
    int i = 0;
    80004452:	4981                	li	s3,0
    80004454:	a029                	j	8000445e <filewrite+0xee>
    80004456:	74e2                	ld	s1,56(sp)
    80004458:	6ae2                	ld	s5,24(sp)
    8000445a:	6ba2                	ld	s7,8(sp)
    8000445c:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    8000445e:	033a1c63          	bne	s4,s3,80004496 <filewrite+0x126>
    80004462:	8552                	mv	a0,s4
    80004464:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004466:	60a6                	ld	ra,72(sp)
    80004468:	6406                	ld	s0,64(sp)
    8000446a:	7942                	ld	s2,48(sp)
    8000446c:	7a02                	ld	s4,32(sp)
    8000446e:	6b42                	ld	s6,16(sp)
    80004470:	6161                	addi	sp,sp,80
    80004472:	8082                	ret
    80004474:	fc26                	sd	s1,56(sp)
    80004476:	f44e                	sd	s3,40(sp)
    80004478:	ec56                	sd	s5,24(sp)
    8000447a:	e45e                	sd	s7,8(sp)
    8000447c:	e062                	sd	s8,0(sp)
    panic("filewrite");
    8000447e:	00003517          	auipc	a0,0x3
    80004482:	26250513          	addi	a0,a0,610 # 800076e0 <etext+0x6e0>
    80004486:	b5afc0ef          	jal	800007e0 <panic>
    return -1;
    8000448a:	557d                	li	a0,-1
}
    8000448c:	8082                	ret
      return -1;
    8000448e:	557d                	li	a0,-1
    80004490:	bfd9                	j	80004466 <filewrite+0xf6>
    80004492:	557d                	li	a0,-1
    80004494:	bfc9                	j	80004466 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80004496:	557d                	li	a0,-1
    80004498:	79a2                	ld	s3,40(sp)
    8000449a:	b7f1                	j	80004466 <filewrite+0xf6>

000000008000449c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000449c:	7179                	addi	sp,sp,-48
    8000449e:	f406                	sd	ra,40(sp)
    800044a0:	f022                	sd	s0,32(sp)
    800044a2:	ec26                	sd	s1,24(sp)
    800044a4:	e052                	sd	s4,0(sp)
    800044a6:	1800                	addi	s0,sp,48
    800044a8:	84aa                	mv	s1,a0
    800044aa:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800044ac:	0005b023          	sd	zero,0(a1)
    800044b0:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800044b4:	c3bff0ef          	jal	800040ee <filealloc>
    800044b8:	e088                	sd	a0,0(s1)
    800044ba:	c549                	beqz	a0,80004544 <pipealloc+0xa8>
    800044bc:	c33ff0ef          	jal	800040ee <filealloc>
    800044c0:	00aa3023          	sd	a0,0(s4)
    800044c4:	cd25                	beqz	a0,8000453c <pipealloc+0xa0>
    800044c6:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800044c8:	e36fc0ef          	jal	80000afe <kalloc>
    800044cc:	892a                	mv	s2,a0
    800044ce:	c12d                	beqz	a0,80004530 <pipealloc+0x94>
    800044d0:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800044d2:	4985                	li	s3,1
    800044d4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800044d8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800044dc:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800044e0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800044e4:	00003597          	auipc	a1,0x3
    800044e8:	f5458593          	addi	a1,a1,-172 # 80007438 <etext+0x438>
    800044ec:	e62fc0ef          	jal	80000b4e <initlock>
  (*f0)->type = FD_PIPE;
    800044f0:	609c                	ld	a5,0(s1)
    800044f2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800044f6:	609c                	ld	a5,0(s1)
    800044f8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800044fc:	609c                	ld	a5,0(s1)
    800044fe:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004502:	609c                	ld	a5,0(s1)
    80004504:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004508:	000a3783          	ld	a5,0(s4)
    8000450c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004510:	000a3783          	ld	a5,0(s4)
    80004514:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004518:	000a3783          	ld	a5,0(s4)
    8000451c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004520:	000a3783          	ld	a5,0(s4)
    80004524:	0127b823          	sd	s2,16(a5)
  return 0;
    80004528:	4501                	li	a0,0
    8000452a:	6942                	ld	s2,16(sp)
    8000452c:	69a2                	ld	s3,8(sp)
    8000452e:	a01d                	j	80004554 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004530:	6088                	ld	a0,0(s1)
    80004532:	c119                	beqz	a0,80004538 <pipealloc+0x9c>
    80004534:	6942                	ld	s2,16(sp)
    80004536:	a029                	j	80004540 <pipealloc+0xa4>
    80004538:	6942                	ld	s2,16(sp)
    8000453a:	a029                	j	80004544 <pipealloc+0xa8>
    8000453c:	6088                	ld	a0,0(s1)
    8000453e:	c10d                	beqz	a0,80004560 <pipealloc+0xc4>
    fileclose(*f0);
    80004540:	c53ff0ef          	jal	80004192 <fileclose>
  if(*f1)
    80004544:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004548:	557d                	li	a0,-1
  if(*f1)
    8000454a:	c789                	beqz	a5,80004554 <pipealloc+0xb8>
    fileclose(*f1);
    8000454c:	853e                	mv	a0,a5
    8000454e:	c45ff0ef          	jal	80004192 <fileclose>
  return -1;
    80004552:	557d                	li	a0,-1
}
    80004554:	70a2                	ld	ra,40(sp)
    80004556:	7402                	ld	s0,32(sp)
    80004558:	64e2                	ld	s1,24(sp)
    8000455a:	6a02                	ld	s4,0(sp)
    8000455c:	6145                	addi	sp,sp,48
    8000455e:	8082                	ret
  return -1;
    80004560:	557d                	li	a0,-1
    80004562:	bfcd                	j	80004554 <pipealloc+0xb8>

0000000080004564 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004564:	1101                	addi	sp,sp,-32
    80004566:	ec06                	sd	ra,24(sp)
    80004568:	e822                	sd	s0,16(sp)
    8000456a:	e426                	sd	s1,8(sp)
    8000456c:	e04a                	sd	s2,0(sp)
    8000456e:	1000                	addi	s0,sp,32
    80004570:	84aa                	mv	s1,a0
    80004572:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004574:	e5afc0ef          	jal	80000bce <acquire>
  if(writable){
    80004578:	02090763          	beqz	s2,800045a6 <pipeclose+0x42>
    pi->writeopen = 0;
    8000457c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004580:	21848513          	addi	a0,s1,536
    80004584:	99dfd0ef          	jal	80001f20 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004588:	2204b783          	ld	a5,544(s1)
    8000458c:	e785                	bnez	a5,800045b4 <pipeclose+0x50>
    release(&pi->lock);
    8000458e:	8526                	mv	a0,s1
    80004590:	ed6fc0ef          	jal	80000c66 <release>
    kfree((char*)pi);
    80004594:	8526                	mv	a0,s1
    80004596:	c86fc0ef          	jal	80000a1c <kfree>
  } else
    release(&pi->lock);
}
    8000459a:	60e2                	ld	ra,24(sp)
    8000459c:	6442                	ld	s0,16(sp)
    8000459e:	64a2                	ld	s1,8(sp)
    800045a0:	6902                	ld	s2,0(sp)
    800045a2:	6105                	addi	sp,sp,32
    800045a4:	8082                	ret
    pi->readopen = 0;
    800045a6:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800045aa:	21c48513          	addi	a0,s1,540
    800045ae:	973fd0ef          	jal	80001f20 <wakeup>
    800045b2:	bfd9                	j	80004588 <pipeclose+0x24>
    release(&pi->lock);
    800045b4:	8526                	mv	a0,s1
    800045b6:	eb0fc0ef          	jal	80000c66 <release>
}
    800045ba:	b7c5                	j	8000459a <pipeclose+0x36>

00000000800045bc <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800045bc:	711d                	addi	sp,sp,-96
    800045be:	ec86                	sd	ra,88(sp)
    800045c0:	e8a2                	sd	s0,80(sp)
    800045c2:	e4a6                	sd	s1,72(sp)
    800045c4:	e0ca                	sd	s2,64(sp)
    800045c6:	fc4e                	sd	s3,56(sp)
    800045c8:	f852                	sd	s4,48(sp)
    800045ca:	f456                	sd	s5,40(sp)
    800045cc:	1080                	addi	s0,sp,96
    800045ce:	84aa                	mv	s1,a0
    800045d0:	8aae                	mv	s5,a1
    800045d2:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800045d4:	afafd0ef          	jal	800018ce <myproc>
    800045d8:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800045da:	8526                	mv	a0,s1
    800045dc:	df2fc0ef          	jal	80000bce <acquire>
  while(i < n){
    800045e0:	0b405a63          	blez	s4,80004694 <pipewrite+0xd8>
    800045e4:	f05a                	sd	s6,32(sp)
    800045e6:	ec5e                	sd	s7,24(sp)
    800045e8:	e862                	sd	s8,16(sp)
  int i = 0;
    800045ea:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800045ec:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800045ee:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800045f2:	21c48b93          	addi	s7,s1,540
    800045f6:	a81d                	j	8000462c <pipewrite+0x70>
      release(&pi->lock);
    800045f8:	8526                	mv	a0,s1
    800045fa:	e6cfc0ef          	jal	80000c66 <release>
      return -1;
    800045fe:	597d                	li	s2,-1
    80004600:	7b02                	ld	s6,32(sp)
    80004602:	6be2                	ld	s7,24(sp)
    80004604:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004606:	854a                	mv	a0,s2
    80004608:	60e6                	ld	ra,88(sp)
    8000460a:	6446                	ld	s0,80(sp)
    8000460c:	64a6                	ld	s1,72(sp)
    8000460e:	6906                	ld	s2,64(sp)
    80004610:	79e2                	ld	s3,56(sp)
    80004612:	7a42                	ld	s4,48(sp)
    80004614:	7aa2                	ld	s5,40(sp)
    80004616:	6125                	addi	sp,sp,96
    80004618:	8082                	ret
      wakeup(&pi->nread);
    8000461a:	8562                	mv	a0,s8
    8000461c:	905fd0ef          	jal	80001f20 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004620:	85a6                	mv	a1,s1
    80004622:	855e                	mv	a0,s7
    80004624:	8b1fd0ef          	jal	80001ed4 <sleep>
  while(i < n){
    80004628:	05495b63          	bge	s2,s4,8000467e <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    8000462c:	2204a783          	lw	a5,544(s1)
    80004630:	d7e1                	beqz	a5,800045f8 <pipewrite+0x3c>
    80004632:	854e                	mv	a0,s3
    80004634:	ad9fd0ef          	jal	8000210c <killed>
    80004638:	f161                	bnez	a0,800045f8 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000463a:	2184a783          	lw	a5,536(s1)
    8000463e:	21c4a703          	lw	a4,540(s1)
    80004642:	2007879b          	addiw	a5,a5,512
    80004646:	fcf70ae3          	beq	a4,a5,8000461a <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000464a:	4685                	li	a3,1
    8000464c:	01590633          	add	a2,s2,s5
    80004650:	faf40593          	addi	a1,s0,-81
    80004654:	0509b503          	ld	a0,80(s3)
    80004658:	86efd0ef          	jal	800016c6 <copyin>
    8000465c:	03650e63          	beq	a0,s6,80004698 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004660:	21c4a783          	lw	a5,540(s1)
    80004664:	0017871b          	addiw	a4,a5,1
    80004668:	20e4ae23          	sw	a4,540(s1)
    8000466c:	1ff7f793          	andi	a5,a5,511
    80004670:	97a6                	add	a5,a5,s1
    80004672:	faf44703          	lbu	a4,-81(s0)
    80004676:	00e78c23          	sb	a4,24(a5)
      i++;
    8000467a:	2905                	addiw	s2,s2,1
    8000467c:	b775                	j	80004628 <pipewrite+0x6c>
    8000467e:	7b02                	ld	s6,32(sp)
    80004680:	6be2                	ld	s7,24(sp)
    80004682:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004684:	21848513          	addi	a0,s1,536
    80004688:	899fd0ef          	jal	80001f20 <wakeup>
  release(&pi->lock);
    8000468c:	8526                	mv	a0,s1
    8000468e:	dd8fc0ef          	jal	80000c66 <release>
  return i;
    80004692:	bf95                	j	80004606 <pipewrite+0x4a>
  int i = 0;
    80004694:	4901                	li	s2,0
    80004696:	b7fd                	j	80004684 <pipewrite+0xc8>
    80004698:	7b02                	ld	s6,32(sp)
    8000469a:	6be2                	ld	s7,24(sp)
    8000469c:	6c42                	ld	s8,16(sp)
    8000469e:	b7dd                	j	80004684 <pipewrite+0xc8>

00000000800046a0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800046a0:	715d                	addi	sp,sp,-80
    800046a2:	e486                	sd	ra,72(sp)
    800046a4:	e0a2                	sd	s0,64(sp)
    800046a6:	fc26                	sd	s1,56(sp)
    800046a8:	f84a                	sd	s2,48(sp)
    800046aa:	f44e                	sd	s3,40(sp)
    800046ac:	f052                	sd	s4,32(sp)
    800046ae:	ec56                	sd	s5,24(sp)
    800046b0:	0880                	addi	s0,sp,80
    800046b2:	84aa                	mv	s1,a0
    800046b4:	892e                	mv	s2,a1
    800046b6:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800046b8:	a16fd0ef          	jal	800018ce <myproc>
    800046bc:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800046be:	8526                	mv	a0,s1
    800046c0:	d0efc0ef          	jal	80000bce <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800046c4:	2184a703          	lw	a4,536(s1)
    800046c8:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800046cc:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800046d0:	02f71563          	bne	a4,a5,800046fa <piperead+0x5a>
    800046d4:	2244a783          	lw	a5,548(s1)
    800046d8:	cb85                	beqz	a5,80004708 <piperead+0x68>
    if(killed(pr)){
    800046da:	8552                	mv	a0,s4
    800046dc:	a31fd0ef          	jal	8000210c <killed>
    800046e0:	ed19                	bnez	a0,800046fe <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800046e2:	85a6                	mv	a1,s1
    800046e4:	854e                	mv	a0,s3
    800046e6:	feefd0ef          	jal	80001ed4 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800046ea:	2184a703          	lw	a4,536(s1)
    800046ee:	21c4a783          	lw	a5,540(s1)
    800046f2:	fef701e3          	beq	a4,a5,800046d4 <piperead+0x34>
    800046f6:	e85a                	sd	s6,16(sp)
    800046f8:	a809                	j	8000470a <piperead+0x6a>
    800046fa:	e85a                	sd	s6,16(sp)
    800046fc:	a039                	j	8000470a <piperead+0x6a>
      release(&pi->lock);
    800046fe:	8526                	mv	a0,s1
    80004700:	d66fc0ef          	jal	80000c66 <release>
      return -1;
    80004704:	59fd                	li	s3,-1
    80004706:	a8b1                	j	80004762 <piperead+0xc2>
    80004708:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000470a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000470c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000470e:	05505263          	blez	s5,80004752 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004712:	2184a783          	lw	a5,536(s1)
    80004716:	21c4a703          	lw	a4,540(s1)
    8000471a:	02f70c63          	beq	a4,a5,80004752 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000471e:	0017871b          	addiw	a4,a5,1
    80004722:	20e4ac23          	sw	a4,536(s1)
    80004726:	1ff7f793          	andi	a5,a5,511
    8000472a:	97a6                	add	a5,a5,s1
    8000472c:	0187c783          	lbu	a5,24(a5)
    80004730:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004734:	4685                	li	a3,1
    80004736:	fbf40613          	addi	a2,s0,-65
    8000473a:	85ca                	mv	a1,s2
    8000473c:	050a3503          	ld	a0,80(s4)
    80004740:	ea3fc0ef          	jal	800015e2 <copyout>
    80004744:	01650763          	beq	a0,s6,80004752 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004748:	2985                	addiw	s3,s3,1
    8000474a:	0905                	addi	s2,s2,1
    8000474c:	fd3a93e3          	bne	s5,s3,80004712 <piperead+0x72>
    80004750:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004752:	21c48513          	addi	a0,s1,540
    80004756:	fcafd0ef          	jal	80001f20 <wakeup>
  release(&pi->lock);
    8000475a:	8526                	mv	a0,s1
    8000475c:	d0afc0ef          	jal	80000c66 <release>
    80004760:	6b42                	ld	s6,16(sp)
  return i;
}
    80004762:	854e                	mv	a0,s3
    80004764:	60a6                	ld	ra,72(sp)
    80004766:	6406                	ld	s0,64(sp)
    80004768:	74e2                	ld	s1,56(sp)
    8000476a:	7942                	ld	s2,48(sp)
    8000476c:	79a2                	ld	s3,40(sp)
    8000476e:	7a02                	ld	s4,32(sp)
    80004770:	6ae2                	ld	s5,24(sp)
    80004772:	6161                	addi	sp,sp,80
    80004774:	8082                	ret

0000000080004776 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004776:	1141                	addi	sp,sp,-16
    80004778:	e422                	sd	s0,8(sp)
    8000477a:	0800                	addi	s0,sp,16
    8000477c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000477e:	8905                	andi	a0,a0,1
    80004780:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004782:	8b89                	andi	a5,a5,2
    80004784:	c399                	beqz	a5,8000478a <flags2perm+0x14>
      perm |= PTE_W;
    80004786:	00456513          	ori	a0,a0,4
    return perm;
}
    8000478a:	6422                	ld	s0,8(sp)
    8000478c:	0141                	addi	sp,sp,16
    8000478e:	8082                	ret

0000000080004790 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004790:	df010113          	addi	sp,sp,-528
    80004794:	20113423          	sd	ra,520(sp)
    80004798:	20813023          	sd	s0,512(sp)
    8000479c:	ffa6                	sd	s1,504(sp)
    8000479e:	fbca                	sd	s2,496(sp)
    800047a0:	0c00                	addi	s0,sp,528
    800047a2:	892a                	mv	s2,a0
    800047a4:	dea43c23          	sd	a0,-520(s0)
    800047a8:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800047ac:	922fd0ef          	jal	800018ce <myproc>
    800047b0:	84aa                	mv	s1,a0

  begin_op();
    800047b2:	dd4ff0ef          	jal	80003d86 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    800047b6:	854a                	mv	a0,s2
    800047b8:	bfaff0ef          	jal	80003bb2 <namei>
    800047bc:	c931                	beqz	a0,80004810 <kexec+0x80>
    800047be:	f3d2                	sd	s4,480(sp)
    800047c0:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800047c2:	bdbfe0ef          	jal	8000339c <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800047c6:	04000713          	li	a4,64
    800047ca:	4681                	li	a3,0
    800047cc:	e5040613          	addi	a2,s0,-432
    800047d0:	4581                	li	a1,0
    800047d2:	8552                	mv	a0,s4
    800047d4:	f59fe0ef          	jal	8000372c <readi>
    800047d8:	04000793          	li	a5,64
    800047dc:	00f51a63          	bne	a0,a5,800047f0 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    800047e0:	e5042703          	lw	a4,-432(s0)
    800047e4:	464c47b7          	lui	a5,0x464c4
    800047e8:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800047ec:	02f70663          	beq	a4,a5,80004818 <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800047f0:	8552                	mv	a0,s4
    800047f2:	db5fe0ef          	jal	800035a6 <iunlockput>
    end_op();
    800047f6:	dfaff0ef          	jal	80003df0 <end_op>
  }
  return -1;
    800047fa:	557d                	li	a0,-1
    800047fc:	7a1e                	ld	s4,480(sp)
}
    800047fe:	20813083          	ld	ra,520(sp)
    80004802:	20013403          	ld	s0,512(sp)
    80004806:	74fe                	ld	s1,504(sp)
    80004808:	795e                	ld	s2,496(sp)
    8000480a:	21010113          	addi	sp,sp,528
    8000480e:	8082                	ret
    end_op();
    80004810:	de0ff0ef          	jal	80003df0 <end_op>
    return -1;
    80004814:	557d                	li	a0,-1
    80004816:	b7e5                	j	800047fe <kexec+0x6e>
    80004818:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    8000481a:	8526                	mv	a0,s1
    8000481c:	9b8fd0ef          	jal	800019d4 <proc_pagetable>
    80004820:	8b2a                	mv	s6,a0
    80004822:	2c050b63          	beqz	a0,80004af8 <kexec+0x368>
    80004826:	f7ce                	sd	s3,488(sp)
    80004828:	efd6                	sd	s5,472(sp)
    8000482a:	e7de                	sd	s7,456(sp)
    8000482c:	e3e2                	sd	s8,448(sp)
    8000482e:	ff66                	sd	s9,440(sp)
    80004830:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004832:	e7042d03          	lw	s10,-400(s0)
    80004836:	e8845783          	lhu	a5,-376(s0)
    8000483a:	12078963          	beqz	a5,8000496c <kexec+0x1dc>
    8000483e:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004840:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004842:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004844:	6c85                	lui	s9,0x1
    80004846:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000484a:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000484e:	6a85                	lui	s5,0x1
    80004850:	a085                	j	800048b0 <kexec+0x120>
      panic("loadseg: address should exist");
    80004852:	00003517          	auipc	a0,0x3
    80004856:	e9e50513          	addi	a0,a0,-354 # 800076f0 <etext+0x6f0>
    8000485a:	f87fb0ef          	jal	800007e0 <panic>
    if(sz - i < PGSIZE)
    8000485e:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004860:	8726                	mv	a4,s1
    80004862:	012c06bb          	addw	a3,s8,s2
    80004866:	4581                	li	a1,0
    80004868:	8552                	mv	a0,s4
    8000486a:	ec3fe0ef          	jal	8000372c <readi>
    8000486e:	2501                	sext.w	a0,a0
    80004870:	24a49a63          	bne	s1,a0,80004ac4 <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80004874:	012a893b          	addw	s2,s5,s2
    80004878:	03397363          	bgeu	s2,s3,8000489e <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    8000487c:	02091593          	slli	a1,s2,0x20
    80004880:	9181                	srli	a1,a1,0x20
    80004882:	95de                	add	a1,a1,s7
    80004884:	855a                	mv	a0,s6
    80004886:	f2afc0ef          	jal	80000fb0 <walkaddr>
    8000488a:	862a                	mv	a2,a0
    if(pa == 0)
    8000488c:	d179                	beqz	a0,80004852 <kexec+0xc2>
    if(sz - i < PGSIZE)
    8000488e:	412984bb          	subw	s1,s3,s2
    80004892:	0004879b          	sext.w	a5,s1
    80004896:	fcfcf4e3          	bgeu	s9,a5,8000485e <kexec+0xce>
    8000489a:	84d6                	mv	s1,s5
    8000489c:	b7c9                	j	8000485e <kexec+0xce>
    sz = sz1;
    8000489e:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800048a2:	2d85                	addiw	s11,s11,1
    800048a4:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    800048a8:	e8845783          	lhu	a5,-376(s0)
    800048ac:	08fdd063          	bge	s11,a5,8000492c <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800048b0:	2d01                	sext.w	s10,s10
    800048b2:	03800713          	li	a4,56
    800048b6:	86ea                	mv	a3,s10
    800048b8:	e1840613          	addi	a2,s0,-488
    800048bc:	4581                	li	a1,0
    800048be:	8552                	mv	a0,s4
    800048c0:	e6dfe0ef          	jal	8000372c <readi>
    800048c4:	03800793          	li	a5,56
    800048c8:	1cf51663          	bne	a0,a5,80004a94 <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    800048cc:	e1842783          	lw	a5,-488(s0)
    800048d0:	4705                	li	a4,1
    800048d2:	fce798e3          	bne	a5,a4,800048a2 <kexec+0x112>
    if(ph.memsz < ph.filesz)
    800048d6:	e4043483          	ld	s1,-448(s0)
    800048da:	e3843783          	ld	a5,-456(s0)
    800048de:	1af4ef63          	bltu	s1,a5,80004a9c <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800048e2:	e2843783          	ld	a5,-472(s0)
    800048e6:	94be                	add	s1,s1,a5
    800048e8:	1af4ee63          	bltu	s1,a5,80004aa4 <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    800048ec:	df043703          	ld	a4,-528(s0)
    800048f0:	8ff9                	and	a5,a5,a4
    800048f2:	1a079d63          	bnez	a5,80004aac <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800048f6:	e1c42503          	lw	a0,-484(s0)
    800048fa:	e7dff0ef          	jal	80004776 <flags2perm>
    800048fe:	86aa                	mv	a3,a0
    80004900:	8626                	mv	a2,s1
    80004902:	85ca                	mv	a1,s2
    80004904:	855a                	mv	a0,s6
    80004906:	983fc0ef          	jal	80001288 <uvmalloc>
    8000490a:	e0a43423          	sd	a0,-504(s0)
    8000490e:	1a050363          	beqz	a0,80004ab4 <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004912:	e2843b83          	ld	s7,-472(s0)
    80004916:	e2042c03          	lw	s8,-480(s0)
    8000491a:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000491e:	00098463          	beqz	s3,80004926 <kexec+0x196>
    80004922:	4901                	li	s2,0
    80004924:	bfa1                	j	8000487c <kexec+0xec>
    sz = sz1;
    80004926:	e0843903          	ld	s2,-504(s0)
    8000492a:	bfa5                	j	800048a2 <kexec+0x112>
    8000492c:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    8000492e:	8552                	mv	a0,s4
    80004930:	c77fe0ef          	jal	800035a6 <iunlockput>
  end_op();
    80004934:	cbcff0ef          	jal	80003df0 <end_op>
  p = myproc();
    80004938:	f97fc0ef          	jal	800018ce <myproc>
    8000493c:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000493e:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004942:	6985                	lui	s3,0x1
    80004944:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004946:	99ca                	add	s3,s3,s2
    80004948:	77fd                	lui	a5,0xfffff
    8000494a:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    8000494e:	4691                	li	a3,4
    80004950:	6609                	lui	a2,0x2
    80004952:	964e                	add	a2,a2,s3
    80004954:	85ce                	mv	a1,s3
    80004956:	855a                	mv	a0,s6
    80004958:	931fc0ef          	jal	80001288 <uvmalloc>
    8000495c:	892a                	mv	s2,a0
    8000495e:	e0a43423          	sd	a0,-504(s0)
    80004962:	e519                	bnez	a0,80004970 <kexec+0x1e0>
  if(pagetable)
    80004964:	e1343423          	sd	s3,-504(s0)
    80004968:	4a01                	li	s4,0
    8000496a:	aab1                	j	80004ac6 <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000496c:	4901                	li	s2,0
    8000496e:	b7c1                	j	8000492e <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004970:	75f9                	lui	a1,0xffffe
    80004972:	95aa                	add	a1,a1,a0
    80004974:	855a                	mv	a0,s6
    80004976:	ae9fc0ef          	jal	8000145e <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    8000497a:	7bfd                	lui	s7,0xfffff
    8000497c:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    8000497e:	e0043783          	ld	a5,-512(s0)
    80004982:	6388                	ld	a0,0(a5)
    80004984:	cd39                	beqz	a0,800049e2 <kexec+0x252>
    80004986:	e9040993          	addi	s3,s0,-368
    8000498a:	f9040c13          	addi	s8,s0,-112
    8000498e:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004990:	c82fc0ef          	jal	80000e12 <strlen>
    80004994:	0015079b          	addiw	a5,a0,1
    80004998:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000499c:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800049a0:	11796e63          	bltu	s2,s7,80004abc <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800049a4:	e0043d03          	ld	s10,-512(s0)
    800049a8:	000d3a03          	ld	s4,0(s10)
    800049ac:	8552                	mv	a0,s4
    800049ae:	c64fc0ef          	jal	80000e12 <strlen>
    800049b2:	0015069b          	addiw	a3,a0,1
    800049b6:	8652                	mv	a2,s4
    800049b8:	85ca                	mv	a1,s2
    800049ba:	855a                	mv	a0,s6
    800049bc:	c27fc0ef          	jal	800015e2 <copyout>
    800049c0:	10054063          	bltz	a0,80004ac0 <kexec+0x330>
    ustack[argc] = sp;
    800049c4:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800049c8:	0485                	addi	s1,s1,1
    800049ca:	008d0793          	addi	a5,s10,8
    800049ce:	e0f43023          	sd	a5,-512(s0)
    800049d2:	008d3503          	ld	a0,8(s10)
    800049d6:	c909                	beqz	a0,800049e8 <kexec+0x258>
    if(argc >= MAXARG)
    800049d8:	09a1                	addi	s3,s3,8
    800049da:	fb899be3          	bne	s3,s8,80004990 <kexec+0x200>
  ip = 0;
    800049de:	4a01                	li	s4,0
    800049e0:	a0dd                	j	80004ac6 <kexec+0x336>
  sp = sz;
    800049e2:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    800049e6:	4481                	li	s1,0
  ustack[argc] = 0;
    800049e8:	00349793          	slli	a5,s1,0x3
    800049ec:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdb5b8>
    800049f0:	97a2                	add	a5,a5,s0
    800049f2:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800049f6:	00148693          	addi	a3,s1,1
    800049fa:	068e                	slli	a3,a3,0x3
    800049fc:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004a00:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004a04:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004a08:	f5796ee3          	bltu	s2,s7,80004964 <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004a0c:	e9040613          	addi	a2,s0,-368
    80004a10:	85ca                	mv	a1,s2
    80004a12:	855a                	mv	a0,s6
    80004a14:	bcffc0ef          	jal	800015e2 <copyout>
    80004a18:	0e054263          	bltz	a0,80004afc <kexec+0x36c>
  p->trapframe->a1 = sp;
    80004a1c:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004a20:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004a24:	df843783          	ld	a5,-520(s0)
    80004a28:	0007c703          	lbu	a4,0(a5)
    80004a2c:	cf11                	beqz	a4,80004a48 <kexec+0x2b8>
    80004a2e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004a30:	02f00693          	li	a3,47
    80004a34:	a039                	j	80004a42 <kexec+0x2b2>
      last = s+1;
    80004a36:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004a3a:	0785                	addi	a5,a5,1
    80004a3c:	fff7c703          	lbu	a4,-1(a5)
    80004a40:	c701                	beqz	a4,80004a48 <kexec+0x2b8>
    if(*s == '/')
    80004a42:	fed71ce3          	bne	a4,a3,80004a3a <kexec+0x2aa>
    80004a46:	bfc5                	j	80004a36 <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004a48:	4641                	li	a2,16
    80004a4a:	df843583          	ld	a1,-520(s0)
    80004a4e:	158a8513          	addi	a0,s5,344
    80004a52:	b8efc0ef          	jal	80000de0 <safestrcpy>
  oldpagetable = p->pagetable;
    80004a56:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004a5a:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004a5e:	e0843783          	ld	a5,-504(s0)
    80004a62:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004a66:	058ab783          	ld	a5,88(s5)
    80004a6a:	e6843703          	ld	a4,-408(s0)
    80004a6e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004a70:	058ab783          	ld	a5,88(s5)
    80004a74:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004a78:	85e6                	mv	a1,s9
    80004a7a:	fdffc0ef          	jal	80001a58 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004a7e:	0004851b          	sext.w	a0,s1
    80004a82:	79be                	ld	s3,488(sp)
    80004a84:	7a1e                	ld	s4,480(sp)
    80004a86:	6afe                	ld	s5,472(sp)
    80004a88:	6b5e                	ld	s6,464(sp)
    80004a8a:	6bbe                	ld	s7,456(sp)
    80004a8c:	6c1e                	ld	s8,448(sp)
    80004a8e:	7cfa                	ld	s9,440(sp)
    80004a90:	7d5a                	ld	s10,432(sp)
    80004a92:	b3b5                	j	800047fe <kexec+0x6e>
    80004a94:	e1243423          	sd	s2,-504(s0)
    80004a98:	7dba                	ld	s11,424(sp)
    80004a9a:	a035                	j	80004ac6 <kexec+0x336>
    80004a9c:	e1243423          	sd	s2,-504(s0)
    80004aa0:	7dba                	ld	s11,424(sp)
    80004aa2:	a015                	j	80004ac6 <kexec+0x336>
    80004aa4:	e1243423          	sd	s2,-504(s0)
    80004aa8:	7dba                	ld	s11,424(sp)
    80004aaa:	a831                	j	80004ac6 <kexec+0x336>
    80004aac:	e1243423          	sd	s2,-504(s0)
    80004ab0:	7dba                	ld	s11,424(sp)
    80004ab2:	a811                	j	80004ac6 <kexec+0x336>
    80004ab4:	e1243423          	sd	s2,-504(s0)
    80004ab8:	7dba                	ld	s11,424(sp)
    80004aba:	a031                	j	80004ac6 <kexec+0x336>
  ip = 0;
    80004abc:	4a01                	li	s4,0
    80004abe:	a021                	j	80004ac6 <kexec+0x336>
    80004ac0:	4a01                	li	s4,0
  if(pagetable)
    80004ac2:	a011                	j	80004ac6 <kexec+0x336>
    80004ac4:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004ac6:	e0843583          	ld	a1,-504(s0)
    80004aca:	855a                	mv	a0,s6
    80004acc:	f8dfc0ef          	jal	80001a58 <proc_freepagetable>
  return -1;
    80004ad0:	557d                	li	a0,-1
  if(ip){
    80004ad2:	000a1b63          	bnez	s4,80004ae8 <kexec+0x358>
    80004ad6:	79be                	ld	s3,488(sp)
    80004ad8:	7a1e                	ld	s4,480(sp)
    80004ada:	6afe                	ld	s5,472(sp)
    80004adc:	6b5e                	ld	s6,464(sp)
    80004ade:	6bbe                	ld	s7,456(sp)
    80004ae0:	6c1e                	ld	s8,448(sp)
    80004ae2:	7cfa                	ld	s9,440(sp)
    80004ae4:	7d5a                	ld	s10,432(sp)
    80004ae6:	bb21                	j	800047fe <kexec+0x6e>
    80004ae8:	79be                	ld	s3,488(sp)
    80004aea:	6afe                	ld	s5,472(sp)
    80004aec:	6b5e                	ld	s6,464(sp)
    80004aee:	6bbe                	ld	s7,456(sp)
    80004af0:	6c1e                	ld	s8,448(sp)
    80004af2:	7cfa                	ld	s9,440(sp)
    80004af4:	7d5a                	ld	s10,432(sp)
    80004af6:	b9ed                	j	800047f0 <kexec+0x60>
    80004af8:	6b5e                	ld	s6,464(sp)
    80004afa:	b9dd                	j	800047f0 <kexec+0x60>
  sz = sz1;
    80004afc:	e0843983          	ld	s3,-504(s0)
    80004b00:	b595                	j	80004964 <kexec+0x1d4>

0000000080004b02 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004b02:	7179                	addi	sp,sp,-48
    80004b04:	f406                	sd	ra,40(sp)
    80004b06:	f022                	sd	s0,32(sp)
    80004b08:	ec26                	sd	s1,24(sp)
    80004b0a:	e84a                	sd	s2,16(sp)
    80004b0c:	1800                	addi	s0,sp,48
    80004b0e:	892e                	mv	s2,a1
    80004b10:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004b12:	fdc40593          	addi	a1,s0,-36
    80004b16:	d73fd0ef          	jal	80002888 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004b1a:	fdc42703          	lw	a4,-36(s0)
    80004b1e:	47bd                	li	a5,15
    80004b20:	02e7e963          	bltu	a5,a4,80004b52 <argfd+0x50>
    80004b24:	dabfc0ef          	jal	800018ce <myproc>
    80004b28:	fdc42703          	lw	a4,-36(s0)
    80004b2c:	01a70793          	addi	a5,a4,26
    80004b30:	078e                	slli	a5,a5,0x3
    80004b32:	953e                	add	a0,a0,a5
    80004b34:	611c                	ld	a5,0(a0)
    80004b36:	c385                	beqz	a5,80004b56 <argfd+0x54>
    return -1;
  if(pfd)
    80004b38:	00090463          	beqz	s2,80004b40 <argfd+0x3e>
    *pfd = fd;
    80004b3c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004b40:	4501                	li	a0,0
  if(pf)
    80004b42:	c091                	beqz	s1,80004b46 <argfd+0x44>
    *pf = f;
    80004b44:	e09c                	sd	a5,0(s1)
}
    80004b46:	70a2                	ld	ra,40(sp)
    80004b48:	7402                	ld	s0,32(sp)
    80004b4a:	64e2                	ld	s1,24(sp)
    80004b4c:	6942                	ld	s2,16(sp)
    80004b4e:	6145                	addi	sp,sp,48
    80004b50:	8082                	ret
    return -1;
    80004b52:	557d                	li	a0,-1
    80004b54:	bfcd                	j	80004b46 <argfd+0x44>
    80004b56:	557d                	li	a0,-1
    80004b58:	b7fd                	j	80004b46 <argfd+0x44>

0000000080004b5a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004b5a:	1101                	addi	sp,sp,-32
    80004b5c:	ec06                	sd	ra,24(sp)
    80004b5e:	e822                	sd	s0,16(sp)
    80004b60:	e426                	sd	s1,8(sp)
    80004b62:	1000                	addi	s0,sp,32
    80004b64:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004b66:	d69fc0ef          	jal	800018ce <myproc>
    80004b6a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004b6c:	0d050793          	addi	a5,a0,208
    80004b70:	4501                	li	a0,0
    80004b72:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004b74:	6398                	ld	a4,0(a5)
    80004b76:	cb19                	beqz	a4,80004b8c <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004b78:	2505                	addiw	a0,a0,1
    80004b7a:	07a1                	addi	a5,a5,8
    80004b7c:	fed51ce3          	bne	a0,a3,80004b74 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004b80:	557d                	li	a0,-1
}
    80004b82:	60e2                	ld	ra,24(sp)
    80004b84:	6442                	ld	s0,16(sp)
    80004b86:	64a2                	ld	s1,8(sp)
    80004b88:	6105                	addi	sp,sp,32
    80004b8a:	8082                	ret
      p->ofile[fd] = f;
    80004b8c:	01a50793          	addi	a5,a0,26
    80004b90:	078e                	slli	a5,a5,0x3
    80004b92:	963e                	add	a2,a2,a5
    80004b94:	e204                	sd	s1,0(a2)
      return fd;
    80004b96:	b7f5                	j	80004b82 <fdalloc+0x28>

0000000080004b98 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004b98:	715d                	addi	sp,sp,-80
    80004b9a:	e486                	sd	ra,72(sp)
    80004b9c:	e0a2                	sd	s0,64(sp)
    80004b9e:	fc26                	sd	s1,56(sp)
    80004ba0:	f84a                	sd	s2,48(sp)
    80004ba2:	f44e                	sd	s3,40(sp)
    80004ba4:	ec56                	sd	s5,24(sp)
    80004ba6:	e85a                	sd	s6,16(sp)
    80004ba8:	0880                	addi	s0,sp,80
    80004baa:	8b2e                	mv	s6,a1
    80004bac:	89b2                	mv	s3,a2
    80004bae:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004bb0:	fb040593          	addi	a1,s0,-80
    80004bb4:	818ff0ef          	jal	80003bcc <nameiparent>
    80004bb8:	84aa                	mv	s1,a0
    80004bba:	10050a63          	beqz	a0,80004cce <create+0x136>
    return 0;

  ilock(dp);
    80004bbe:	fdefe0ef          	jal	8000339c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004bc2:	4601                	li	a2,0
    80004bc4:	fb040593          	addi	a1,s0,-80
    80004bc8:	8526                	mv	a0,s1
    80004bca:	d83fe0ef          	jal	8000394c <dirlookup>
    80004bce:	8aaa                	mv	s5,a0
    80004bd0:	c129                	beqz	a0,80004c12 <create+0x7a>
    iunlockput(dp);
    80004bd2:	8526                	mv	a0,s1
    80004bd4:	9d3fe0ef          	jal	800035a6 <iunlockput>
    ilock(ip);
    80004bd8:	8556                	mv	a0,s5
    80004bda:	fc2fe0ef          	jal	8000339c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004bde:	4789                	li	a5,2
    80004be0:	02fb1463          	bne	s6,a5,80004c08 <create+0x70>
    80004be4:	044ad783          	lhu	a5,68(s5)
    80004be8:	37f9                	addiw	a5,a5,-2
    80004bea:	17c2                	slli	a5,a5,0x30
    80004bec:	93c1                	srli	a5,a5,0x30
    80004bee:	4705                	li	a4,1
    80004bf0:	00f76c63          	bltu	a4,a5,80004c08 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004bf4:	8556                	mv	a0,s5
    80004bf6:	60a6                	ld	ra,72(sp)
    80004bf8:	6406                	ld	s0,64(sp)
    80004bfa:	74e2                	ld	s1,56(sp)
    80004bfc:	7942                	ld	s2,48(sp)
    80004bfe:	79a2                	ld	s3,40(sp)
    80004c00:	6ae2                	ld	s5,24(sp)
    80004c02:	6b42                	ld	s6,16(sp)
    80004c04:	6161                	addi	sp,sp,80
    80004c06:	8082                	ret
    iunlockput(ip);
    80004c08:	8556                	mv	a0,s5
    80004c0a:	99dfe0ef          	jal	800035a6 <iunlockput>
    return 0;
    80004c0e:	4a81                	li	s5,0
    80004c10:	b7d5                	j	80004bf4 <create+0x5c>
    80004c12:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004c14:	85da                	mv	a1,s6
    80004c16:	4088                	lw	a0,0(s1)
    80004c18:	e14fe0ef          	jal	8000322c <ialloc>
    80004c1c:	8a2a                	mv	s4,a0
    80004c1e:	cd15                	beqz	a0,80004c5a <create+0xc2>
  ilock(ip);
    80004c20:	f7cfe0ef          	jal	8000339c <ilock>
  ip->major = major;
    80004c24:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004c28:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004c2c:	4905                	li	s2,1
    80004c2e:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004c32:	8552                	mv	a0,s4
    80004c34:	eb4fe0ef          	jal	800032e8 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004c38:	032b0763          	beq	s6,s2,80004c66 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004c3c:	004a2603          	lw	a2,4(s4)
    80004c40:	fb040593          	addi	a1,s0,-80
    80004c44:	8526                	mv	a0,s1
    80004c46:	ed3fe0ef          	jal	80003b18 <dirlink>
    80004c4a:	06054563          	bltz	a0,80004cb4 <create+0x11c>
  iunlockput(dp);
    80004c4e:	8526                	mv	a0,s1
    80004c50:	957fe0ef          	jal	800035a6 <iunlockput>
  return ip;
    80004c54:	8ad2                	mv	s5,s4
    80004c56:	7a02                	ld	s4,32(sp)
    80004c58:	bf71                	j	80004bf4 <create+0x5c>
    iunlockput(dp);
    80004c5a:	8526                	mv	a0,s1
    80004c5c:	94bfe0ef          	jal	800035a6 <iunlockput>
    return 0;
    80004c60:	8ad2                	mv	s5,s4
    80004c62:	7a02                	ld	s4,32(sp)
    80004c64:	bf41                	j	80004bf4 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004c66:	004a2603          	lw	a2,4(s4)
    80004c6a:	00003597          	auipc	a1,0x3
    80004c6e:	aa658593          	addi	a1,a1,-1370 # 80007710 <etext+0x710>
    80004c72:	8552                	mv	a0,s4
    80004c74:	ea5fe0ef          	jal	80003b18 <dirlink>
    80004c78:	02054e63          	bltz	a0,80004cb4 <create+0x11c>
    80004c7c:	40d0                	lw	a2,4(s1)
    80004c7e:	00003597          	auipc	a1,0x3
    80004c82:	a9a58593          	addi	a1,a1,-1382 # 80007718 <etext+0x718>
    80004c86:	8552                	mv	a0,s4
    80004c88:	e91fe0ef          	jal	80003b18 <dirlink>
    80004c8c:	02054463          	bltz	a0,80004cb4 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004c90:	004a2603          	lw	a2,4(s4)
    80004c94:	fb040593          	addi	a1,s0,-80
    80004c98:	8526                	mv	a0,s1
    80004c9a:	e7ffe0ef          	jal	80003b18 <dirlink>
    80004c9e:	00054b63          	bltz	a0,80004cb4 <create+0x11c>
    dp->nlink++;  // for ".."
    80004ca2:	04a4d783          	lhu	a5,74(s1)
    80004ca6:	2785                	addiw	a5,a5,1
    80004ca8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004cac:	8526                	mv	a0,s1
    80004cae:	e3afe0ef          	jal	800032e8 <iupdate>
    80004cb2:	bf71                	j	80004c4e <create+0xb6>
  ip->nlink = 0;
    80004cb4:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004cb8:	8552                	mv	a0,s4
    80004cba:	e2efe0ef          	jal	800032e8 <iupdate>
  iunlockput(ip);
    80004cbe:	8552                	mv	a0,s4
    80004cc0:	8e7fe0ef          	jal	800035a6 <iunlockput>
  iunlockput(dp);
    80004cc4:	8526                	mv	a0,s1
    80004cc6:	8e1fe0ef          	jal	800035a6 <iunlockput>
  return 0;
    80004cca:	7a02                	ld	s4,32(sp)
    80004ccc:	b725                	j	80004bf4 <create+0x5c>
    return 0;
    80004cce:	8aaa                	mv	s5,a0
    80004cd0:	b715                	j	80004bf4 <create+0x5c>

0000000080004cd2 <sys_dup>:
{
    80004cd2:	7179                	addi	sp,sp,-48
    80004cd4:	f406                	sd	ra,40(sp)
    80004cd6:	f022                	sd	s0,32(sp)
    80004cd8:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004cda:	fd840613          	addi	a2,s0,-40
    80004cde:	4581                	li	a1,0
    80004ce0:	4501                	li	a0,0
    80004ce2:	e21ff0ef          	jal	80004b02 <argfd>
    return -1;
    80004ce6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004ce8:	02054363          	bltz	a0,80004d0e <sys_dup+0x3c>
    80004cec:	ec26                	sd	s1,24(sp)
    80004cee:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004cf0:	fd843903          	ld	s2,-40(s0)
    80004cf4:	854a                	mv	a0,s2
    80004cf6:	e65ff0ef          	jal	80004b5a <fdalloc>
    80004cfa:	84aa                	mv	s1,a0
    return -1;
    80004cfc:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004cfe:	00054d63          	bltz	a0,80004d18 <sys_dup+0x46>
  filedup(f);
    80004d02:	854a                	mv	a0,s2
    80004d04:	c48ff0ef          	jal	8000414c <filedup>
  return fd;
    80004d08:	87a6                	mv	a5,s1
    80004d0a:	64e2                	ld	s1,24(sp)
    80004d0c:	6942                	ld	s2,16(sp)
}
    80004d0e:	853e                	mv	a0,a5
    80004d10:	70a2                	ld	ra,40(sp)
    80004d12:	7402                	ld	s0,32(sp)
    80004d14:	6145                	addi	sp,sp,48
    80004d16:	8082                	ret
    80004d18:	64e2                	ld	s1,24(sp)
    80004d1a:	6942                	ld	s2,16(sp)
    80004d1c:	bfcd                	j	80004d0e <sys_dup+0x3c>

0000000080004d1e <sys_read>:
{
    80004d1e:	7179                	addi	sp,sp,-48
    80004d20:	f406                	sd	ra,40(sp)
    80004d22:	f022                	sd	s0,32(sp)
    80004d24:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004d26:	fd840593          	addi	a1,s0,-40
    80004d2a:	4505                	li	a0,1
    80004d2c:	b79fd0ef          	jal	800028a4 <argaddr>
  argint(2, &n);
    80004d30:	fe440593          	addi	a1,s0,-28
    80004d34:	4509                	li	a0,2
    80004d36:	b53fd0ef          	jal	80002888 <argint>
  if(argfd(0, 0, &f) < 0)
    80004d3a:	fe840613          	addi	a2,s0,-24
    80004d3e:	4581                	li	a1,0
    80004d40:	4501                	li	a0,0
    80004d42:	dc1ff0ef          	jal	80004b02 <argfd>
    80004d46:	87aa                	mv	a5,a0
    return -1;
    80004d48:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004d4a:	0007ca63          	bltz	a5,80004d5e <sys_read+0x40>
  return fileread(f, p, n);
    80004d4e:	fe442603          	lw	a2,-28(s0)
    80004d52:	fd843583          	ld	a1,-40(s0)
    80004d56:	fe843503          	ld	a0,-24(s0)
    80004d5a:	d58ff0ef          	jal	800042b2 <fileread>
}
    80004d5e:	70a2                	ld	ra,40(sp)
    80004d60:	7402                	ld	s0,32(sp)
    80004d62:	6145                	addi	sp,sp,48
    80004d64:	8082                	ret

0000000080004d66 <sys_write>:
{
    80004d66:	7179                	addi	sp,sp,-48
    80004d68:	f406                	sd	ra,40(sp)
    80004d6a:	f022                	sd	s0,32(sp)
    80004d6c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004d6e:	fd840593          	addi	a1,s0,-40
    80004d72:	4505                	li	a0,1
    80004d74:	b31fd0ef          	jal	800028a4 <argaddr>
  argint(2, &n);
    80004d78:	fe440593          	addi	a1,s0,-28
    80004d7c:	4509                	li	a0,2
    80004d7e:	b0bfd0ef          	jal	80002888 <argint>
  if(argfd(0, 0, &f) < 0)
    80004d82:	fe840613          	addi	a2,s0,-24
    80004d86:	4581                	li	a1,0
    80004d88:	4501                	li	a0,0
    80004d8a:	d79ff0ef          	jal	80004b02 <argfd>
    80004d8e:	87aa                	mv	a5,a0
    return -1;
    80004d90:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004d92:	0007ca63          	bltz	a5,80004da6 <sys_write+0x40>
  return filewrite(f, p, n);
    80004d96:	fe442603          	lw	a2,-28(s0)
    80004d9a:	fd843583          	ld	a1,-40(s0)
    80004d9e:	fe843503          	ld	a0,-24(s0)
    80004da2:	dceff0ef          	jal	80004370 <filewrite>
}
    80004da6:	70a2                	ld	ra,40(sp)
    80004da8:	7402                	ld	s0,32(sp)
    80004daa:	6145                	addi	sp,sp,48
    80004dac:	8082                	ret

0000000080004dae <sys_close>:
{
    80004dae:	1101                	addi	sp,sp,-32
    80004db0:	ec06                	sd	ra,24(sp)
    80004db2:	e822                	sd	s0,16(sp)
    80004db4:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004db6:	fe040613          	addi	a2,s0,-32
    80004dba:	fec40593          	addi	a1,s0,-20
    80004dbe:	4501                	li	a0,0
    80004dc0:	d43ff0ef          	jal	80004b02 <argfd>
    return -1;
    80004dc4:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004dc6:	02054063          	bltz	a0,80004de6 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004dca:	b05fc0ef          	jal	800018ce <myproc>
    80004dce:	fec42783          	lw	a5,-20(s0)
    80004dd2:	07e9                	addi	a5,a5,26
    80004dd4:	078e                	slli	a5,a5,0x3
    80004dd6:	953e                	add	a0,a0,a5
    80004dd8:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004ddc:	fe043503          	ld	a0,-32(s0)
    80004de0:	bb2ff0ef          	jal	80004192 <fileclose>
  return 0;
    80004de4:	4781                	li	a5,0
}
    80004de6:	853e                	mv	a0,a5
    80004de8:	60e2                	ld	ra,24(sp)
    80004dea:	6442                	ld	s0,16(sp)
    80004dec:	6105                	addi	sp,sp,32
    80004dee:	8082                	ret

0000000080004df0 <sys_fstat>:
{
    80004df0:	1101                	addi	sp,sp,-32
    80004df2:	ec06                	sd	ra,24(sp)
    80004df4:	e822                	sd	s0,16(sp)
    80004df6:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004df8:	fe040593          	addi	a1,s0,-32
    80004dfc:	4505                	li	a0,1
    80004dfe:	aa7fd0ef          	jal	800028a4 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004e02:	fe840613          	addi	a2,s0,-24
    80004e06:	4581                	li	a1,0
    80004e08:	4501                	li	a0,0
    80004e0a:	cf9ff0ef          	jal	80004b02 <argfd>
    80004e0e:	87aa                	mv	a5,a0
    return -1;
    80004e10:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004e12:	0007c863          	bltz	a5,80004e22 <sys_fstat+0x32>
  return filestat(f, st);
    80004e16:	fe043583          	ld	a1,-32(s0)
    80004e1a:	fe843503          	ld	a0,-24(s0)
    80004e1e:	c36ff0ef          	jal	80004254 <filestat>
}
    80004e22:	60e2                	ld	ra,24(sp)
    80004e24:	6442                	ld	s0,16(sp)
    80004e26:	6105                	addi	sp,sp,32
    80004e28:	8082                	ret

0000000080004e2a <sys_link>:
{
    80004e2a:	7169                	addi	sp,sp,-304
    80004e2c:	f606                	sd	ra,296(sp)
    80004e2e:	f222                	sd	s0,288(sp)
    80004e30:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004e32:	08000613          	li	a2,128
    80004e36:	ed040593          	addi	a1,s0,-304
    80004e3a:	4501                	li	a0,0
    80004e3c:	a85fd0ef          	jal	800028c0 <argstr>
    return -1;
    80004e40:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004e42:	0c054e63          	bltz	a0,80004f1e <sys_link+0xf4>
    80004e46:	08000613          	li	a2,128
    80004e4a:	f5040593          	addi	a1,s0,-176
    80004e4e:	4505                	li	a0,1
    80004e50:	a71fd0ef          	jal	800028c0 <argstr>
    return -1;
    80004e54:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004e56:	0c054463          	bltz	a0,80004f1e <sys_link+0xf4>
    80004e5a:	ee26                	sd	s1,280(sp)
  begin_op();
    80004e5c:	f2bfe0ef          	jal	80003d86 <begin_op>
  if((ip = namei(old)) == 0){
    80004e60:	ed040513          	addi	a0,s0,-304
    80004e64:	d4ffe0ef          	jal	80003bb2 <namei>
    80004e68:	84aa                	mv	s1,a0
    80004e6a:	c53d                	beqz	a0,80004ed8 <sys_link+0xae>
  ilock(ip);
    80004e6c:	d30fe0ef          	jal	8000339c <ilock>
  if(ip->type == T_DIR){
    80004e70:	04449703          	lh	a4,68(s1)
    80004e74:	4785                	li	a5,1
    80004e76:	06f70663          	beq	a4,a5,80004ee2 <sys_link+0xb8>
    80004e7a:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004e7c:	04a4d783          	lhu	a5,74(s1)
    80004e80:	2785                	addiw	a5,a5,1
    80004e82:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004e86:	8526                	mv	a0,s1
    80004e88:	c60fe0ef          	jal	800032e8 <iupdate>
  iunlock(ip);
    80004e8c:	8526                	mv	a0,s1
    80004e8e:	dbcfe0ef          	jal	8000344a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004e92:	fd040593          	addi	a1,s0,-48
    80004e96:	f5040513          	addi	a0,s0,-176
    80004e9a:	d33fe0ef          	jal	80003bcc <nameiparent>
    80004e9e:	892a                	mv	s2,a0
    80004ea0:	cd21                	beqz	a0,80004ef8 <sys_link+0xce>
  ilock(dp);
    80004ea2:	cfafe0ef          	jal	8000339c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004ea6:	00092703          	lw	a4,0(s2)
    80004eaa:	409c                	lw	a5,0(s1)
    80004eac:	04f71363          	bne	a4,a5,80004ef2 <sys_link+0xc8>
    80004eb0:	40d0                	lw	a2,4(s1)
    80004eb2:	fd040593          	addi	a1,s0,-48
    80004eb6:	854a                	mv	a0,s2
    80004eb8:	c61fe0ef          	jal	80003b18 <dirlink>
    80004ebc:	02054b63          	bltz	a0,80004ef2 <sys_link+0xc8>
  iunlockput(dp);
    80004ec0:	854a                	mv	a0,s2
    80004ec2:	ee4fe0ef          	jal	800035a6 <iunlockput>
  iput(ip);
    80004ec6:	8526                	mv	a0,s1
    80004ec8:	e56fe0ef          	jal	8000351e <iput>
  end_op();
    80004ecc:	f25fe0ef          	jal	80003df0 <end_op>
  return 0;
    80004ed0:	4781                	li	a5,0
    80004ed2:	64f2                	ld	s1,280(sp)
    80004ed4:	6952                	ld	s2,272(sp)
    80004ed6:	a0a1                	j	80004f1e <sys_link+0xf4>
    end_op();
    80004ed8:	f19fe0ef          	jal	80003df0 <end_op>
    return -1;
    80004edc:	57fd                	li	a5,-1
    80004ede:	64f2                	ld	s1,280(sp)
    80004ee0:	a83d                	j	80004f1e <sys_link+0xf4>
    iunlockput(ip);
    80004ee2:	8526                	mv	a0,s1
    80004ee4:	ec2fe0ef          	jal	800035a6 <iunlockput>
    end_op();
    80004ee8:	f09fe0ef          	jal	80003df0 <end_op>
    return -1;
    80004eec:	57fd                	li	a5,-1
    80004eee:	64f2                	ld	s1,280(sp)
    80004ef0:	a03d                	j	80004f1e <sys_link+0xf4>
    iunlockput(dp);
    80004ef2:	854a                	mv	a0,s2
    80004ef4:	eb2fe0ef          	jal	800035a6 <iunlockput>
  ilock(ip);
    80004ef8:	8526                	mv	a0,s1
    80004efa:	ca2fe0ef          	jal	8000339c <ilock>
  ip->nlink--;
    80004efe:	04a4d783          	lhu	a5,74(s1)
    80004f02:	37fd                	addiw	a5,a5,-1
    80004f04:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004f08:	8526                	mv	a0,s1
    80004f0a:	bdefe0ef          	jal	800032e8 <iupdate>
  iunlockput(ip);
    80004f0e:	8526                	mv	a0,s1
    80004f10:	e96fe0ef          	jal	800035a6 <iunlockput>
  end_op();
    80004f14:	eddfe0ef          	jal	80003df0 <end_op>
  return -1;
    80004f18:	57fd                	li	a5,-1
    80004f1a:	64f2                	ld	s1,280(sp)
    80004f1c:	6952                	ld	s2,272(sp)
}
    80004f1e:	853e                	mv	a0,a5
    80004f20:	70b2                	ld	ra,296(sp)
    80004f22:	7412                	ld	s0,288(sp)
    80004f24:	6155                	addi	sp,sp,304
    80004f26:	8082                	ret

0000000080004f28 <sys_unlink>:
{
    80004f28:	7151                	addi	sp,sp,-240
    80004f2a:	f586                	sd	ra,232(sp)
    80004f2c:	f1a2                	sd	s0,224(sp)
    80004f2e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004f30:	08000613          	li	a2,128
    80004f34:	f3040593          	addi	a1,s0,-208
    80004f38:	4501                	li	a0,0
    80004f3a:	987fd0ef          	jal	800028c0 <argstr>
    80004f3e:	16054063          	bltz	a0,8000509e <sys_unlink+0x176>
    80004f42:	eda6                	sd	s1,216(sp)
  begin_op();
    80004f44:	e43fe0ef          	jal	80003d86 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004f48:	fb040593          	addi	a1,s0,-80
    80004f4c:	f3040513          	addi	a0,s0,-208
    80004f50:	c7dfe0ef          	jal	80003bcc <nameiparent>
    80004f54:	84aa                	mv	s1,a0
    80004f56:	c945                	beqz	a0,80005006 <sys_unlink+0xde>
  ilock(dp);
    80004f58:	c44fe0ef          	jal	8000339c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004f5c:	00002597          	auipc	a1,0x2
    80004f60:	7b458593          	addi	a1,a1,1972 # 80007710 <etext+0x710>
    80004f64:	fb040513          	addi	a0,s0,-80
    80004f68:	9cffe0ef          	jal	80003936 <namecmp>
    80004f6c:	10050e63          	beqz	a0,80005088 <sys_unlink+0x160>
    80004f70:	00002597          	auipc	a1,0x2
    80004f74:	7a858593          	addi	a1,a1,1960 # 80007718 <etext+0x718>
    80004f78:	fb040513          	addi	a0,s0,-80
    80004f7c:	9bbfe0ef          	jal	80003936 <namecmp>
    80004f80:	10050463          	beqz	a0,80005088 <sys_unlink+0x160>
    80004f84:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004f86:	f2c40613          	addi	a2,s0,-212
    80004f8a:	fb040593          	addi	a1,s0,-80
    80004f8e:	8526                	mv	a0,s1
    80004f90:	9bdfe0ef          	jal	8000394c <dirlookup>
    80004f94:	892a                	mv	s2,a0
    80004f96:	0e050863          	beqz	a0,80005086 <sys_unlink+0x15e>
  ilock(ip);
    80004f9a:	c02fe0ef          	jal	8000339c <ilock>
  if(ip->nlink < 1)
    80004f9e:	04a91783          	lh	a5,74(s2)
    80004fa2:	06f05763          	blez	a5,80005010 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004fa6:	04491703          	lh	a4,68(s2)
    80004faa:	4785                	li	a5,1
    80004fac:	06f70963          	beq	a4,a5,8000501e <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004fb0:	4641                	li	a2,16
    80004fb2:	4581                	li	a1,0
    80004fb4:	fc040513          	addi	a0,s0,-64
    80004fb8:	cebfb0ef          	jal	80000ca2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004fbc:	4741                	li	a4,16
    80004fbe:	f2c42683          	lw	a3,-212(s0)
    80004fc2:	fc040613          	addi	a2,s0,-64
    80004fc6:	4581                	li	a1,0
    80004fc8:	8526                	mv	a0,s1
    80004fca:	85ffe0ef          	jal	80003828 <writei>
    80004fce:	47c1                	li	a5,16
    80004fd0:	08f51b63          	bne	a0,a5,80005066 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80004fd4:	04491703          	lh	a4,68(s2)
    80004fd8:	4785                	li	a5,1
    80004fda:	08f70d63          	beq	a4,a5,80005074 <sys_unlink+0x14c>
  iunlockput(dp);
    80004fde:	8526                	mv	a0,s1
    80004fe0:	dc6fe0ef          	jal	800035a6 <iunlockput>
  ip->nlink--;
    80004fe4:	04a95783          	lhu	a5,74(s2)
    80004fe8:	37fd                	addiw	a5,a5,-1
    80004fea:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004fee:	854a                	mv	a0,s2
    80004ff0:	af8fe0ef          	jal	800032e8 <iupdate>
  iunlockput(ip);
    80004ff4:	854a                	mv	a0,s2
    80004ff6:	db0fe0ef          	jal	800035a6 <iunlockput>
  end_op();
    80004ffa:	df7fe0ef          	jal	80003df0 <end_op>
  return 0;
    80004ffe:	4501                	li	a0,0
    80005000:	64ee                	ld	s1,216(sp)
    80005002:	694e                	ld	s2,208(sp)
    80005004:	a849                	j	80005096 <sys_unlink+0x16e>
    end_op();
    80005006:	debfe0ef          	jal	80003df0 <end_op>
    return -1;
    8000500a:	557d                	li	a0,-1
    8000500c:	64ee                	ld	s1,216(sp)
    8000500e:	a061                	j	80005096 <sys_unlink+0x16e>
    80005010:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005012:	00002517          	auipc	a0,0x2
    80005016:	70e50513          	addi	a0,a0,1806 # 80007720 <etext+0x720>
    8000501a:	fc6fb0ef          	jal	800007e0 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000501e:	04c92703          	lw	a4,76(s2)
    80005022:	02000793          	li	a5,32
    80005026:	f8e7f5e3          	bgeu	a5,a4,80004fb0 <sys_unlink+0x88>
    8000502a:	e5ce                	sd	s3,200(sp)
    8000502c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005030:	4741                	li	a4,16
    80005032:	86ce                	mv	a3,s3
    80005034:	f1840613          	addi	a2,s0,-232
    80005038:	4581                	li	a1,0
    8000503a:	854a                	mv	a0,s2
    8000503c:	ef0fe0ef          	jal	8000372c <readi>
    80005040:	47c1                	li	a5,16
    80005042:	00f51c63          	bne	a0,a5,8000505a <sys_unlink+0x132>
    if(de.inum != 0)
    80005046:	f1845783          	lhu	a5,-232(s0)
    8000504a:	efa1                	bnez	a5,800050a2 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000504c:	29c1                	addiw	s3,s3,16
    8000504e:	04c92783          	lw	a5,76(s2)
    80005052:	fcf9efe3          	bltu	s3,a5,80005030 <sys_unlink+0x108>
    80005056:	69ae                	ld	s3,200(sp)
    80005058:	bfa1                	j	80004fb0 <sys_unlink+0x88>
      panic("isdirempty: readi");
    8000505a:	00002517          	auipc	a0,0x2
    8000505e:	6de50513          	addi	a0,a0,1758 # 80007738 <etext+0x738>
    80005062:	f7efb0ef          	jal	800007e0 <panic>
    80005066:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005068:	00002517          	auipc	a0,0x2
    8000506c:	6e850513          	addi	a0,a0,1768 # 80007750 <etext+0x750>
    80005070:	f70fb0ef          	jal	800007e0 <panic>
    dp->nlink--;
    80005074:	04a4d783          	lhu	a5,74(s1)
    80005078:	37fd                	addiw	a5,a5,-1
    8000507a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000507e:	8526                	mv	a0,s1
    80005080:	a68fe0ef          	jal	800032e8 <iupdate>
    80005084:	bfa9                	j	80004fde <sys_unlink+0xb6>
    80005086:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005088:	8526                	mv	a0,s1
    8000508a:	d1cfe0ef          	jal	800035a6 <iunlockput>
  end_op();
    8000508e:	d63fe0ef          	jal	80003df0 <end_op>
  return -1;
    80005092:	557d                	li	a0,-1
    80005094:	64ee                	ld	s1,216(sp)
}
    80005096:	70ae                	ld	ra,232(sp)
    80005098:	740e                	ld	s0,224(sp)
    8000509a:	616d                	addi	sp,sp,240
    8000509c:	8082                	ret
    return -1;
    8000509e:	557d                	li	a0,-1
    800050a0:	bfdd                	j	80005096 <sys_unlink+0x16e>
    iunlockput(ip);
    800050a2:	854a                	mv	a0,s2
    800050a4:	d02fe0ef          	jal	800035a6 <iunlockput>
    goto bad;
    800050a8:	694e                	ld	s2,208(sp)
    800050aa:	69ae                	ld	s3,200(sp)
    800050ac:	bff1                	j	80005088 <sys_unlink+0x160>

00000000800050ae <sys_open>:

uint64
sys_open(void)
{
    800050ae:	7131                	addi	sp,sp,-192
    800050b0:	fd06                	sd	ra,184(sp)
    800050b2:	f922                	sd	s0,176(sp)
    800050b4:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800050b6:	f4c40593          	addi	a1,s0,-180
    800050ba:	4505                	li	a0,1
    800050bc:	fccfd0ef          	jal	80002888 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800050c0:	08000613          	li	a2,128
    800050c4:	f5040593          	addi	a1,s0,-176
    800050c8:	4501                	li	a0,0
    800050ca:	ff6fd0ef          	jal	800028c0 <argstr>
    800050ce:	87aa                	mv	a5,a0
    return -1;
    800050d0:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800050d2:	0a07c263          	bltz	a5,80005176 <sys_open+0xc8>
    800050d6:	f526                	sd	s1,168(sp)

  begin_op();
    800050d8:	caffe0ef          	jal	80003d86 <begin_op>

  if(omode & O_CREATE){
    800050dc:	f4c42783          	lw	a5,-180(s0)
    800050e0:	2007f793          	andi	a5,a5,512
    800050e4:	c3d5                	beqz	a5,80005188 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800050e6:	4681                	li	a3,0
    800050e8:	4601                	li	a2,0
    800050ea:	4589                	li	a1,2
    800050ec:	f5040513          	addi	a0,s0,-176
    800050f0:	aa9ff0ef          	jal	80004b98 <create>
    800050f4:	84aa                	mv	s1,a0
    if(ip == 0){
    800050f6:	c541                	beqz	a0,8000517e <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800050f8:	04449703          	lh	a4,68(s1)
    800050fc:	478d                	li	a5,3
    800050fe:	00f71763          	bne	a4,a5,8000510c <sys_open+0x5e>
    80005102:	0464d703          	lhu	a4,70(s1)
    80005106:	47a5                	li	a5,9
    80005108:	0ae7ed63          	bltu	a5,a4,800051c2 <sys_open+0x114>
    8000510c:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000510e:	fe1fe0ef          	jal	800040ee <filealloc>
    80005112:	892a                	mv	s2,a0
    80005114:	c179                	beqz	a0,800051da <sys_open+0x12c>
    80005116:	ed4e                	sd	s3,152(sp)
    80005118:	a43ff0ef          	jal	80004b5a <fdalloc>
    8000511c:	89aa                	mv	s3,a0
    8000511e:	0a054a63          	bltz	a0,800051d2 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005122:	04449703          	lh	a4,68(s1)
    80005126:	478d                	li	a5,3
    80005128:	0cf70263          	beq	a4,a5,800051ec <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000512c:	4789                	li	a5,2
    8000512e:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005132:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005136:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000513a:	f4c42783          	lw	a5,-180(s0)
    8000513e:	0017c713          	xori	a4,a5,1
    80005142:	8b05                	andi	a4,a4,1
    80005144:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005148:	0037f713          	andi	a4,a5,3
    8000514c:	00e03733          	snez	a4,a4
    80005150:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005154:	4007f793          	andi	a5,a5,1024
    80005158:	c791                	beqz	a5,80005164 <sys_open+0xb6>
    8000515a:	04449703          	lh	a4,68(s1)
    8000515e:	4789                	li	a5,2
    80005160:	08f70d63          	beq	a4,a5,800051fa <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80005164:	8526                	mv	a0,s1
    80005166:	ae4fe0ef          	jal	8000344a <iunlock>
  end_op();
    8000516a:	c87fe0ef          	jal	80003df0 <end_op>

  return fd;
    8000516e:	854e                	mv	a0,s3
    80005170:	74aa                	ld	s1,168(sp)
    80005172:	790a                	ld	s2,160(sp)
    80005174:	69ea                	ld	s3,152(sp)
}
    80005176:	70ea                	ld	ra,184(sp)
    80005178:	744a                	ld	s0,176(sp)
    8000517a:	6129                	addi	sp,sp,192
    8000517c:	8082                	ret
      end_op();
    8000517e:	c73fe0ef          	jal	80003df0 <end_op>
      return -1;
    80005182:	557d                	li	a0,-1
    80005184:	74aa                	ld	s1,168(sp)
    80005186:	bfc5                	j	80005176 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80005188:	f5040513          	addi	a0,s0,-176
    8000518c:	a27fe0ef          	jal	80003bb2 <namei>
    80005190:	84aa                	mv	s1,a0
    80005192:	c11d                	beqz	a0,800051b8 <sys_open+0x10a>
    ilock(ip);
    80005194:	a08fe0ef          	jal	8000339c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005198:	04449703          	lh	a4,68(s1)
    8000519c:	4785                	li	a5,1
    8000519e:	f4f71de3          	bne	a4,a5,800050f8 <sys_open+0x4a>
    800051a2:	f4c42783          	lw	a5,-180(s0)
    800051a6:	d3bd                	beqz	a5,8000510c <sys_open+0x5e>
      iunlockput(ip);
    800051a8:	8526                	mv	a0,s1
    800051aa:	bfcfe0ef          	jal	800035a6 <iunlockput>
      end_op();
    800051ae:	c43fe0ef          	jal	80003df0 <end_op>
      return -1;
    800051b2:	557d                	li	a0,-1
    800051b4:	74aa                	ld	s1,168(sp)
    800051b6:	b7c1                	j	80005176 <sys_open+0xc8>
      end_op();
    800051b8:	c39fe0ef          	jal	80003df0 <end_op>
      return -1;
    800051bc:	557d                	li	a0,-1
    800051be:	74aa                	ld	s1,168(sp)
    800051c0:	bf5d                	j	80005176 <sys_open+0xc8>
    iunlockput(ip);
    800051c2:	8526                	mv	a0,s1
    800051c4:	be2fe0ef          	jal	800035a6 <iunlockput>
    end_op();
    800051c8:	c29fe0ef          	jal	80003df0 <end_op>
    return -1;
    800051cc:	557d                	li	a0,-1
    800051ce:	74aa                	ld	s1,168(sp)
    800051d0:	b75d                	j	80005176 <sys_open+0xc8>
      fileclose(f);
    800051d2:	854a                	mv	a0,s2
    800051d4:	fbffe0ef          	jal	80004192 <fileclose>
    800051d8:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800051da:	8526                	mv	a0,s1
    800051dc:	bcafe0ef          	jal	800035a6 <iunlockput>
    end_op();
    800051e0:	c11fe0ef          	jal	80003df0 <end_op>
    return -1;
    800051e4:	557d                	li	a0,-1
    800051e6:	74aa                	ld	s1,168(sp)
    800051e8:	790a                	ld	s2,160(sp)
    800051ea:	b771                	j	80005176 <sys_open+0xc8>
    f->type = FD_DEVICE;
    800051ec:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800051f0:	04649783          	lh	a5,70(s1)
    800051f4:	02f91223          	sh	a5,36(s2)
    800051f8:	bf3d                	j	80005136 <sys_open+0x88>
    itrunc(ip);
    800051fa:	8526                	mv	a0,s1
    800051fc:	a8efe0ef          	jal	8000348a <itrunc>
    80005200:	b795                	j	80005164 <sys_open+0xb6>

0000000080005202 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005202:	7175                	addi	sp,sp,-144
    80005204:	e506                	sd	ra,136(sp)
    80005206:	e122                	sd	s0,128(sp)
    80005208:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000520a:	b7dfe0ef          	jal	80003d86 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000520e:	08000613          	li	a2,128
    80005212:	f7040593          	addi	a1,s0,-144
    80005216:	4501                	li	a0,0
    80005218:	ea8fd0ef          	jal	800028c0 <argstr>
    8000521c:	02054363          	bltz	a0,80005242 <sys_mkdir+0x40>
    80005220:	4681                	li	a3,0
    80005222:	4601                	li	a2,0
    80005224:	4585                	li	a1,1
    80005226:	f7040513          	addi	a0,s0,-144
    8000522a:	96fff0ef          	jal	80004b98 <create>
    8000522e:	c911                	beqz	a0,80005242 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005230:	b76fe0ef          	jal	800035a6 <iunlockput>
  end_op();
    80005234:	bbdfe0ef          	jal	80003df0 <end_op>
  return 0;
    80005238:	4501                	li	a0,0
}
    8000523a:	60aa                	ld	ra,136(sp)
    8000523c:	640a                	ld	s0,128(sp)
    8000523e:	6149                	addi	sp,sp,144
    80005240:	8082                	ret
    end_op();
    80005242:	baffe0ef          	jal	80003df0 <end_op>
    return -1;
    80005246:	557d                	li	a0,-1
    80005248:	bfcd                	j	8000523a <sys_mkdir+0x38>

000000008000524a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000524a:	7135                	addi	sp,sp,-160
    8000524c:	ed06                	sd	ra,152(sp)
    8000524e:	e922                	sd	s0,144(sp)
    80005250:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005252:	b35fe0ef          	jal	80003d86 <begin_op>
  argint(1, &major);
    80005256:	f6c40593          	addi	a1,s0,-148
    8000525a:	4505                	li	a0,1
    8000525c:	e2cfd0ef          	jal	80002888 <argint>
  argint(2, &minor);
    80005260:	f6840593          	addi	a1,s0,-152
    80005264:	4509                	li	a0,2
    80005266:	e22fd0ef          	jal	80002888 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000526a:	08000613          	li	a2,128
    8000526e:	f7040593          	addi	a1,s0,-144
    80005272:	4501                	li	a0,0
    80005274:	e4cfd0ef          	jal	800028c0 <argstr>
    80005278:	02054563          	bltz	a0,800052a2 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000527c:	f6841683          	lh	a3,-152(s0)
    80005280:	f6c41603          	lh	a2,-148(s0)
    80005284:	458d                	li	a1,3
    80005286:	f7040513          	addi	a0,s0,-144
    8000528a:	90fff0ef          	jal	80004b98 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000528e:	c911                	beqz	a0,800052a2 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005290:	b16fe0ef          	jal	800035a6 <iunlockput>
  end_op();
    80005294:	b5dfe0ef          	jal	80003df0 <end_op>
  return 0;
    80005298:	4501                	li	a0,0
}
    8000529a:	60ea                	ld	ra,152(sp)
    8000529c:	644a                	ld	s0,144(sp)
    8000529e:	610d                	addi	sp,sp,160
    800052a0:	8082                	ret
    end_op();
    800052a2:	b4ffe0ef          	jal	80003df0 <end_op>
    return -1;
    800052a6:	557d                	li	a0,-1
    800052a8:	bfcd                	j	8000529a <sys_mknod+0x50>

00000000800052aa <sys_chdir>:

uint64
sys_chdir(void)
{
    800052aa:	7135                	addi	sp,sp,-160
    800052ac:	ed06                	sd	ra,152(sp)
    800052ae:	e922                	sd	s0,144(sp)
    800052b0:	e14a                	sd	s2,128(sp)
    800052b2:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800052b4:	e1afc0ef          	jal	800018ce <myproc>
    800052b8:	892a                	mv	s2,a0
  
  begin_op();
    800052ba:	acdfe0ef          	jal	80003d86 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800052be:	08000613          	li	a2,128
    800052c2:	f6040593          	addi	a1,s0,-160
    800052c6:	4501                	li	a0,0
    800052c8:	df8fd0ef          	jal	800028c0 <argstr>
    800052cc:	04054363          	bltz	a0,80005312 <sys_chdir+0x68>
    800052d0:	e526                	sd	s1,136(sp)
    800052d2:	f6040513          	addi	a0,s0,-160
    800052d6:	8ddfe0ef          	jal	80003bb2 <namei>
    800052da:	84aa                	mv	s1,a0
    800052dc:	c915                	beqz	a0,80005310 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800052de:	8befe0ef          	jal	8000339c <ilock>
  if(ip->type != T_DIR){
    800052e2:	04449703          	lh	a4,68(s1)
    800052e6:	4785                	li	a5,1
    800052e8:	02f71963          	bne	a4,a5,8000531a <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800052ec:	8526                	mv	a0,s1
    800052ee:	95cfe0ef          	jal	8000344a <iunlock>
  iput(p->cwd);
    800052f2:	15093503          	ld	a0,336(s2)
    800052f6:	a28fe0ef          	jal	8000351e <iput>
  end_op();
    800052fa:	af7fe0ef          	jal	80003df0 <end_op>
  p->cwd = ip;
    800052fe:	14993823          	sd	s1,336(s2)
  return 0;
    80005302:	4501                	li	a0,0
    80005304:	64aa                	ld	s1,136(sp)
}
    80005306:	60ea                	ld	ra,152(sp)
    80005308:	644a                	ld	s0,144(sp)
    8000530a:	690a                	ld	s2,128(sp)
    8000530c:	610d                	addi	sp,sp,160
    8000530e:	8082                	ret
    80005310:	64aa                	ld	s1,136(sp)
    end_op();
    80005312:	adffe0ef          	jal	80003df0 <end_op>
    return -1;
    80005316:	557d                	li	a0,-1
    80005318:	b7fd                	j	80005306 <sys_chdir+0x5c>
    iunlockput(ip);
    8000531a:	8526                	mv	a0,s1
    8000531c:	a8afe0ef          	jal	800035a6 <iunlockput>
    end_op();
    80005320:	ad1fe0ef          	jal	80003df0 <end_op>
    return -1;
    80005324:	557d                	li	a0,-1
    80005326:	64aa                	ld	s1,136(sp)
    80005328:	bff9                	j	80005306 <sys_chdir+0x5c>

000000008000532a <sys_exec>:

uint64
sys_exec(void)
{
    8000532a:	7121                	addi	sp,sp,-448
    8000532c:	ff06                	sd	ra,440(sp)
    8000532e:	fb22                	sd	s0,432(sp)
    80005330:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005332:	e4840593          	addi	a1,s0,-440
    80005336:	4505                	li	a0,1
    80005338:	d6cfd0ef          	jal	800028a4 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000533c:	08000613          	li	a2,128
    80005340:	f5040593          	addi	a1,s0,-176
    80005344:	4501                	li	a0,0
    80005346:	d7afd0ef          	jal	800028c0 <argstr>
    8000534a:	87aa                	mv	a5,a0
    return -1;
    8000534c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000534e:	0c07c463          	bltz	a5,80005416 <sys_exec+0xec>
    80005352:	f726                	sd	s1,424(sp)
    80005354:	f34a                	sd	s2,416(sp)
    80005356:	ef4e                	sd	s3,408(sp)
    80005358:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000535a:	10000613          	li	a2,256
    8000535e:	4581                	li	a1,0
    80005360:	e5040513          	addi	a0,s0,-432
    80005364:	93ffb0ef          	jal	80000ca2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005368:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    8000536c:	89a6                	mv	s3,s1
    8000536e:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005370:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005374:	00391513          	slli	a0,s2,0x3
    80005378:	e4040593          	addi	a1,s0,-448
    8000537c:	e4843783          	ld	a5,-440(s0)
    80005380:	953e                	add	a0,a0,a5
    80005382:	c7cfd0ef          	jal	800027fe <fetchaddr>
    80005386:	02054663          	bltz	a0,800053b2 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    8000538a:	e4043783          	ld	a5,-448(s0)
    8000538e:	c3a9                	beqz	a5,800053d0 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005390:	f6efb0ef          	jal	80000afe <kalloc>
    80005394:	85aa                	mv	a1,a0
    80005396:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000539a:	cd01                	beqz	a0,800053b2 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000539c:	6605                	lui	a2,0x1
    8000539e:	e4043503          	ld	a0,-448(s0)
    800053a2:	ca6fd0ef          	jal	80002848 <fetchstr>
    800053a6:	00054663          	bltz	a0,800053b2 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800053aa:	0905                	addi	s2,s2,1
    800053ac:	09a1                	addi	s3,s3,8
    800053ae:	fd4913e3          	bne	s2,s4,80005374 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800053b2:	f5040913          	addi	s2,s0,-176
    800053b6:	6088                	ld	a0,0(s1)
    800053b8:	c931                	beqz	a0,8000540c <sys_exec+0xe2>
    kfree(argv[i]);
    800053ba:	e62fb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800053be:	04a1                	addi	s1,s1,8
    800053c0:	ff249be3          	bne	s1,s2,800053b6 <sys_exec+0x8c>
  return -1;
    800053c4:	557d                	li	a0,-1
    800053c6:	74ba                	ld	s1,424(sp)
    800053c8:	791a                	ld	s2,416(sp)
    800053ca:	69fa                	ld	s3,408(sp)
    800053cc:	6a5a                	ld	s4,400(sp)
    800053ce:	a0a1                	j	80005416 <sys_exec+0xec>
      argv[i] = 0;
    800053d0:	0009079b          	sext.w	a5,s2
    800053d4:	078e                	slli	a5,a5,0x3
    800053d6:	fd078793          	addi	a5,a5,-48
    800053da:	97a2                	add	a5,a5,s0
    800053dc:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    800053e0:	e5040593          	addi	a1,s0,-432
    800053e4:	f5040513          	addi	a0,s0,-176
    800053e8:	ba8ff0ef          	jal	80004790 <kexec>
    800053ec:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800053ee:	f5040993          	addi	s3,s0,-176
    800053f2:	6088                	ld	a0,0(s1)
    800053f4:	c511                	beqz	a0,80005400 <sys_exec+0xd6>
    kfree(argv[i]);
    800053f6:	e26fb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800053fa:	04a1                	addi	s1,s1,8
    800053fc:	ff349be3          	bne	s1,s3,800053f2 <sys_exec+0xc8>
  return ret;
    80005400:	854a                	mv	a0,s2
    80005402:	74ba                	ld	s1,424(sp)
    80005404:	791a                	ld	s2,416(sp)
    80005406:	69fa                	ld	s3,408(sp)
    80005408:	6a5a                	ld	s4,400(sp)
    8000540a:	a031                	j	80005416 <sys_exec+0xec>
  return -1;
    8000540c:	557d                	li	a0,-1
    8000540e:	74ba                	ld	s1,424(sp)
    80005410:	791a                	ld	s2,416(sp)
    80005412:	69fa                	ld	s3,408(sp)
    80005414:	6a5a                	ld	s4,400(sp)
}
    80005416:	70fa                	ld	ra,440(sp)
    80005418:	745a                	ld	s0,432(sp)
    8000541a:	6139                	addi	sp,sp,448
    8000541c:	8082                	ret

000000008000541e <sys_pipe>:

uint64
sys_pipe(void)
{
    8000541e:	7139                	addi	sp,sp,-64
    80005420:	fc06                	sd	ra,56(sp)
    80005422:	f822                	sd	s0,48(sp)
    80005424:	f426                	sd	s1,40(sp)
    80005426:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005428:	ca6fc0ef          	jal	800018ce <myproc>
    8000542c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000542e:	fd840593          	addi	a1,s0,-40
    80005432:	4501                	li	a0,0
    80005434:	c70fd0ef          	jal	800028a4 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005438:	fc840593          	addi	a1,s0,-56
    8000543c:	fd040513          	addi	a0,s0,-48
    80005440:	85cff0ef          	jal	8000449c <pipealloc>
    return -1;
    80005444:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005446:	0a054463          	bltz	a0,800054ee <sys_pipe+0xd0>
  fd0 = -1;
    8000544a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000544e:	fd043503          	ld	a0,-48(s0)
    80005452:	f08ff0ef          	jal	80004b5a <fdalloc>
    80005456:	fca42223          	sw	a0,-60(s0)
    8000545a:	08054163          	bltz	a0,800054dc <sys_pipe+0xbe>
    8000545e:	fc843503          	ld	a0,-56(s0)
    80005462:	ef8ff0ef          	jal	80004b5a <fdalloc>
    80005466:	fca42023          	sw	a0,-64(s0)
    8000546a:	06054063          	bltz	a0,800054ca <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000546e:	4691                	li	a3,4
    80005470:	fc440613          	addi	a2,s0,-60
    80005474:	fd843583          	ld	a1,-40(s0)
    80005478:	68a8                	ld	a0,80(s1)
    8000547a:	968fc0ef          	jal	800015e2 <copyout>
    8000547e:	00054e63          	bltz	a0,8000549a <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005482:	4691                	li	a3,4
    80005484:	fc040613          	addi	a2,s0,-64
    80005488:	fd843583          	ld	a1,-40(s0)
    8000548c:	0591                	addi	a1,a1,4
    8000548e:	68a8                	ld	a0,80(s1)
    80005490:	952fc0ef          	jal	800015e2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005494:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005496:	04055c63          	bgez	a0,800054ee <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    8000549a:	fc442783          	lw	a5,-60(s0)
    8000549e:	07e9                	addi	a5,a5,26
    800054a0:	078e                	slli	a5,a5,0x3
    800054a2:	97a6                	add	a5,a5,s1
    800054a4:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800054a8:	fc042783          	lw	a5,-64(s0)
    800054ac:	07e9                	addi	a5,a5,26
    800054ae:	078e                	slli	a5,a5,0x3
    800054b0:	94be                	add	s1,s1,a5
    800054b2:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800054b6:	fd043503          	ld	a0,-48(s0)
    800054ba:	cd9fe0ef          	jal	80004192 <fileclose>
    fileclose(wf);
    800054be:	fc843503          	ld	a0,-56(s0)
    800054c2:	cd1fe0ef          	jal	80004192 <fileclose>
    return -1;
    800054c6:	57fd                	li	a5,-1
    800054c8:	a01d                	j	800054ee <sys_pipe+0xd0>
    if(fd0 >= 0)
    800054ca:	fc442783          	lw	a5,-60(s0)
    800054ce:	0007c763          	bltz	a5,800054dc <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800054d2:	07e9                	addi	a5,a5,26
    800054d4:	078e                	slli	a5,a5,0x3
    800054d6:	97a6                	add	a5,a5,s1
    800054d8:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800054dc:	fd043503          	ld	a0,-48(s0)
    800054e0:	cb3fe0ef          	jal	80004192 <fileclose>
    fileclose(wf);
    800054e4:	fc843503          	ld	a0,-56(s0)
    800054e8:	cabfe0ef          	jal	80004192 <fileclose>
    return -1;
    800054ec:	57fd                	li	a5,-1
}
    800054ee:	853e                	mv	a0,a5
    800054f0:	70e2                	ld	ra,56(sp)
    800054f2:	7442                	ld	s0,48(sp)
    800054f4:	74a2                	ld	s1,40(sp)
    800054f6:	6121                	addi	sp,sp,64
    800054f8:	8082                	ret
    800054fa:	0000                	unimp
    800054fc:	0000                	unimp
	...

0000000080005500 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005500:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005502:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005504:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005506:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005508:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000550a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000550c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000550e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005510:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005512:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005514:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005516:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005518:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000551a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000551c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000551e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005520:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005522:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005524:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005526:	9e8fd0ef          	jal	8000270e <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000552a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000552c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000552e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005530:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005532:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005534:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005536:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005538:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000553a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000553c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000553e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005540:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005542:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005544:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005546:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005548:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000554a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000554c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000554e:	10200073          	sret
	...

000000008000555e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000555e:	1141                	addi	sp,sp,-16
    80005560:	e422                	sd	s0,8(sp)
    80005562:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005564:	0c0007b7          	lui	a5,0xc000
    80005568:	4705                	li	a4,1
    8000556a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000556c:	0c0007b7          	lui	a5,0xc000
    80005570:	c3d8                	sw	a4,4(a5)
}
    80005572:	6422                	ld	s0,8(sp)
    80005574:	0141                	addi	sp,sp,16
    80005576:	8082                	ret

0000000080005578 <plicinithart>:

void
plicinithart(void)
{
    80005578:	1141                	addi	sp,sp,-16
    8000557a:	e406                	sd	ra,8(sp)
    8000557c:	e022                	sd	s0,0(sp)
    8000557e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005580:	b22fc0ef          	jal	800018a2 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005584:	0085171b          	slliw	a4,a0,0x8
    80005588:	0c0027b7          	lui	a5,0xc002
    8000558c:	97ba                	add	a5,a5,a4
    8000558e:	40200713          	li	a4,1026
    80005592:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005596:	00d5151b          	slliw	a0,a0,0xd
    8000559a:	0c2017b7          	lui	a5,0xc201
    8000559e:	97aa                	add	a5,a5,a0
    800055a0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800055a4:	60a2                	ld	ra,8(sp)
    800055a6:	6402                	ld	s0,0(sp)
    800055a8:	0141                	addi	sp,sp,16
    800055aa:	8082                	ret

00000000800055ac <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800055ac:	1141                	addi	sp,sp,-16
    800055ae:	e406                	sd	ra,8(sp)
    800055b0:	e022                	sd	s0,0(sp)
    800055b2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800055b4:	aeefc0ef          	jal	800018a2 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800055b8:	00d5151b          	slliw	a0,a0,0xd
    800055bc:	0c2017b7          	lui	a5,0xc201
    800055c0:	97aa                	add	a5,a5,a0
  return irq;
}
    800055c2:	43c8                	lw	a0,4(a5)
    800055c4:	60a2                	ld	ra,8(sp)
    800055c6:	6402                	ld	s0,0(sp)
    800055c8:	0141                	addi	sp,sp,16
    800055ca:	8082                	ret

00000000800055cc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800055cc:	1101                	addi	sp,sp,-32
    800055ce:	ec06                	sd	ra,24(sp)
    800055d0:	e822                	sd	s0,16(sp)
    800055d2:	e426                	sd	s1,8(sp)
    800055d4:	1000                	addi	s0,sp,32
    800055d6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800055d8:	acafc0ef          	jal	800018a2 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800055dc:	00d5151b          	slliw	a0,a0,0xd
    800055e0:	0c2017b7          	lui	a5,0xc201
    800055e4:	97aa                	add	a5,a5,a0
    800055e6:	c3c4                	sw	s1,4(a5)
}
    800055e8:	60e2                	ld	ra,24(sp)
    800055ea:	6442                	ld	s0,16(sp)
    800055ec:	64a2                	ld	s1,8(sp)
    800055ee:	6105                	addi	sp,sp,32
    800055f0:	8082                	ret

00000000800055f2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800055f2:	1141                	addi	sp,sp,-16
    800055f4:	e406                	sd	ra,8(sp)
    800055f6:	e022                	sd	s0,0(sp)
    800055f8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800055fa:	479d                	li	a5,7
    800055fc:	04a7ca63          	blt	a5,a0,80005650 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005600:	0001e797          	auipc	a5,0x1e
    80005604:	29878793          	addi	a5,a5,664 # 80023898 <disk>
    80005608:	97aa                	add	a5,a5,a0
    8000560a:	0187c783          	lbu	a5,24(a5)
    8000560e:	e7b9                	bnez	a5,8000565c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005610:	00451693          	slli	a3,a0,0x4
    80005614:	0001e797          	auipc	a5,0x1e
    80005618:	28478793          	addi	a5,a5,644 # 80023898 <disk>
    8000561c:	6398                	ld	a4,0(a5)
    8000561e:	9736                	add	a4,a4,a3
    80005620:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005624:	6398                	ld	a4,0(a5)
    80005626:	9736                	add	a4,a4,a3
    80005628:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000562c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005630:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005634:	97aa                	add	a5,a5,a0
    80005636:	4705                	li	a4,1
    80005638:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000563c:	0001e517          	auipc	a0,0x1e
    80005640:	27450513          	addi	a0,a0,628 # 800238b0 <disk+0x18>
    80005644:	8ddfc0ef          	jal	80001f20 <wakeup>
}
    80005648:	60a2                	ld	ra,8(sp)
    8000564a:	6402                	ld	s0,0(sp)
    8000564c:	0141                	addi	sp,sp,16
    8000564e:	8082                	ret
    panic("free_desc 1");
    80005650:	00002517          	auipc	a0,0x2
    80005654:	11050513          	addi	a0,a0,272 # 80007760 <etext+0x760>
    80005658:	988fb0ef          	jal	800007e0 <panic>
    panic("free_desc 2");
    8000565c:	00002517          	auipc	a0,0x2
    80005660:	11450513          	addi	a0,a0,276 # 80007770 <etext+0x770>
    80005664:	97cfb0ef          	jal	800007e0 <panic>

0000000080005668 <virtio_disk_init>:
{
    80005668:	1101                	addi	sp,sp,-32
    8000566a:	ec06                	sd	ra,24(sp)
    8000566c:	e822                	sd	s0,16(sp)
    8000566e:	e426                	sd	s1,8(sp)
    80005670:	e04a                	sd	s2,0(sp)
    80005672:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005674:	00002597          	auipc	a1,0x2
    80005678:	10c58593          	addi	a1,a1,268 # 80007780 <etext+0x780>
    8000567c:	0001e517          	auipc	a0,0x1e
    80005680:	34450513          	addi	a0,a0,836 # 800239c0 <disk+0x128>
    80005684:	ccafb0ef          	jal	80000b4e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005688:	100017b7          	lui	a5,0x10001
    8000568c:	4398                	lw	a4,0(a5)
    8000568e:	2701                	sext.w	a4,a4
    80005690:	747277b7          	lui	a5,0x74727
    80005694:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005698:	18f71063          	bne	a4,a5,80005818 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000569c:	100017b7          	lui	a5,0x10001
    800056a0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800056a2:	439c                	lw	a5,0(a5)
    800056a4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800056a6:	4709                	li	a4,2
    800056a8:	16e79863          	bne	a5,a4,80005818 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800056ac:	100017b7          	lui	a5,0x10001
    800056b0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800056b2:	439c                	lw	a5,0(a5)
    800056b4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800056b6:	16e79163          	bne	a5,a4,80005818 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800056ba:	100017b7          	lui	a5,0x10001
    800056be:	47d8                	lw	a4,12(a5)
    800056c0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800056c2:	554d47b7          	lui	a5,0x554d4
    800056c6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800056ca:	14f71763          	bne	a4,a5,80005818 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    800056ce:	100017b7          	lui	a5,0x10001
    800056d2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800056d6:	4705                	li	a4,1
    800056d8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800056da:	470d                	li	a4,3
    800056dc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800056de:	10001737          	lui	a4,0x10001
    800056e2:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800056e4:	c7ffe737          	lui	a4,0xc7ffe
    800056e8:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdad87>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800056ec:	8ef9                	and	a3,a3,a4
    800056ee:	10001737          	lui	a4,0x10001
    800056f2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800056f4:	472d                	li	a4,11
    800056f6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800056f8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800056fc:	439c                	lw	a5,0(a5)
    800056fe:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005702:	8ba1                	andi	a5,a5,8
    80005704:	12078063          	beqz	a5,80005824 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005708:	100017b7          	lui	a5,0x10001
    8000570c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005710:	100017b7          	lui	a5,0x10001
    80005714:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005718:	439c                	lw	a5,0(a5)
    8000571a:	2781                	sext.w	a5,a5
    8000571c:	10079a63          	bnez	a5,80005830 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005720:	100017b7          	lui	a5,0x10001
    80005724:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005728:	439c                	lw	a5,0(a5)
    8000572a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000572c:	10078863          	beqz	a5,8000583c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005730:	471d                	li	a4,7
    80005732:	10f77b63          	bgeu	a4,a5,80005848 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005736:	bc8fb0ef          	jal	80000afe <kalloc>
    8000573a:	0001e497          	auipc	s1,0x1e
    8000573e:	15e48493          	addi	s1,s1,350 # 80023898 <disk>
    80005742:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005744:	bbafb0ef          	jal	80000afe <kalloc>
    80005748:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000574a:	bb4fb0ef          	jal	80000afe <kalloc>
    8000574e:	87aa                	mv	a5,a0
    80005750:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005752:	6088                	ld	a0,0(s1)
    80005754:	10050063          	beqz	a0,80005854 <virtio_disk_init+0x1ec>
    80005758:	0001e717          	auipc	a4,0x1e
    8000575c:	14873703          	ld	a4,328(a4) # 800238a0 <disk+0x8>
    80005760:	0e070a63          	beqz	a4,80005854 <virtio_disk_init+0x1ec>
    80005764:	0e078863          	beqz	a5,80005854 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005768:	6605                	lui	a2,0x1
    8000576a:	4581                	li	a1,0
    8000576c:	d36fb0ef          	jal	80000ca2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005770:	0001e497          	auipc	s1,0x1e
    80005774:	12848493          	addi	s1,s1,296 # 80023898 <disk>
    80005778:	6605                	lui	a2,0x1
    8000577a:	4581                	li	a1,0
    8000577c:	6488                	ld	a0,8(s1)
    8000577e:	d24fb0ef          	jal	80000ca2 <memset>
  memset(disk.used, 0, PGSIZE);
    80005782:	6605                	lui	a2,0x1
    80005784:	4581                	li	a1,0
    80005786:	6888                	ld	a0,16(s1)
    80005788:	d1afb0ef          	jal	80000ca2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000578c:	100017b7          	lui	a5,0x10001
    80005790:	4721                	li	a4,8
    80005792:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005794:	4098                	lw	a4,0(s1)
    80005796:	100017b7          	lui	a5,0x10001
    8000579a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000579e:	40d8                	lw	a4,4(s1)
    800057a0:	100017b7          	lui	a5,0x10001
    800057a4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800057a8:	649c                	ld	a5,8(s1)
    800057aa:	0007869b          	sext.w	a3,a5
    800057ae:	10001737          	lui	a4,0x10001
    800057b2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800057b6:	9781                	srai	a5,a5,0x20
    800057b8:	10001737          	lui	a4,0x10001
    800057bc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800057c0:	689c                	ld	a5,16(s1)
    800057c2:	0007869b          	sext.w	a3,a5
    800057c6:	10001737          	lui	a4,0x10001
    800057ca:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800057ce:	9781                	srai	a5,a5,0x20
    800057d0:	10001737          	lui	a4,0x10001
    800057d4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800057d8:	10001737          	lui	a4,0x10001
    800057dc:	4785                	li	a5,1
    800057de:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800057e0:	00f48c23          	sb	a5,24(s1)
    800057e4:	00f48ca3          	sb	a5,25(s1)
    800057e8:	00f48d23          	sb	a5,26(s1)
    800057ec:	00f48da3          	sb	a5,27(s1)
    800057f0:	00f48e23          	sb	a5,28(s1)
    800057f4:	00f48ea3          	sb	a5,29(s1)
    800057f8:	00f48f23          	sb	a5,30(s1)
    800057fc:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005800:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005804:	100017b7          	lui	a5,0x10001
    80005808:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000580c:	60e2                	ld	ra,24(sp)
    8000580e:	6442                	ld	s0,16(sp)
    80005810:	64a2                	ld	s1,8(sp)
    80005812:	6902                	ld	s2,0(sp)
    80005814:	6105                	addi	sp,sp,32
    80005816:	8082                	ret
    panic("could not find virtio disk");
    80005818:	00002517          	auipc	a0,0x2
    8000581c:	f7850513          	addi	a0,a0,-136 # 80007790 <etext+0x790>
    80005820:	fc1fa0ef          	jal	800007e0 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005824:	00002517          	auipc	a0,0x2
    80005828:	f8c50513          	addi	a0,a0,-116 # 800077b0 <etext+0x7b0>
    8000582c:	fb5fa0ef          	jal	800007e0 <panic>
    panic("virtio disk should not be ready");
    80005830:	00002517          	auipc	a0,0x2
    80005834:	fa050513          	addi	a0,a0,-96 # 800077d0 <etext+0x7d0>
    80005838:	fa9fa0ef          	jal	800007e0 <panic>
    panic("virtio disk has no queue 0");
    8000583c:	00002517          	auipc	a0,0x2
    80005840:	fb450513          	addi	a0,a0,-76 # 800077f0 <etext+0x7f0>
    80005844:	f9dfa0ef          	jal	800007e0 <panic>
    panic("virtio disk max queue too short");
    80005848:	00002517          	auipc	a0,0x2
    8000584c:	fc850513          	addi	a0,a0,-56 # 80007810 <etext+0x810>
    80005850:	f91fa0ef          	jal	800007e0 <panic>
    panic("virtio disk kalloc");
    80005854:	00002517          	auipc	a0,0x2
    80005858:	fdc50513          	addi	a0,a0,-36 # 80007830 <etext+0x830>
    8000585c:	f85fa0ef          	jal	800007e0 <panic>

0000000080005860 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005860:	7159                	addi	sp,sp,-112
    80005862:	f486                	sd	ra,104(sp)
    80005864:	f0a2                	sd	s0,96(sp)
    80005866:	eca6                	sd	s1,88(sp)
    80005868:	e8ca                	sd	s2,80(sp)
    8000586a:	e4ce                	sd	s3,72(sp)
    8000586c:	e0d2                	sd	s4,64(sp)
    8000586e:	fc56                	sd	s5,56(sp)
    80005870:	f85a                	sd	s6,48(sp)
    80005872:	f45e                	sd	s7,40(sp)
    80005874:	f062                	sd	s8,32(sp)
    80005876:	ec66                	sd	s9,24(sp)
    80005878:	1880                	addi	s0,sp,112
    8000587a:	8a2a                	mv	s4,a0
    8000587c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000587e:	00c52c83          	lw	s9,12(a0)
    80005882:	001c9c9b          	slliw	s9,s9,0x1
    80005886:	1c82                	slli	s9,s9,0x20
    80005888:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000588c:	0001e517          	auipc	a0,0x1e
    80005890:	13450513          	addi	a0,a0,308 # 800239c0 <disk+0x128>
    80005894:	b3afb0ef          	jal	80000bce <acquire>
  for(int i = 0; i < 3; i++){
    80005898:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000589a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000589c:	0001eb17          	auipc	s6,0x1e
    800058a0:	ffcb0b13          	addi	s6,s6,-4 # 80023898 <disk>
  for(int i = 0; i < 3; i++){
    800058a4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800058a6:	0001ec17          	auipc	s8,0x1e
    800058aa:	11ac0c13          	addi	s8,s8,282 # 800239c0 <disk+0x128>
    800058ae:	a8b9                	j	8000590c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    800058b0:	00fb0733          	add	a4,s6,a5
    800058b4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800058b8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800058ba:	0207c563          	bltz	a5,800058e4 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    800058be:	2905                	addiw	s2,s2,1
    800058c0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800058c2:	05590963          	beq	s2,s5,80005914 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    800058c6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800058c8:	0001e717          	auipc	a4,0x1e
    800058cc:	fd070713          	addi	a4,a4,-48 # 80023898 <disk>
    800058d0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800058d2:	01874683          	lbu	a3,24(a4)
    800058d6:	fee9                	bnez	a3,800058b0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    800058d8:	2785                	addiw	a5,a5,1
    800058da:	0705                	addi	a4,a4,1
    800058dc:	fe979be3          	bne	a5,s1,800058d2 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    800058e0:	57fd                	li	a5,-1
    800058e2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800058e4:	01205d63          	blez	s2,800058fe <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800058e8:	f9042503          	lw	a0,-112(s0)
    800058ec:	d07ff0ef          	jal	800055f2 <free_desc>
      for(int j = 0; j < i; j++)
    800058f0:	4785                	li	a5,1
    800058f2:	0127d663          	bge	a5,s2,800058fe <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800058f6:	f9442503          	lw	a0,-108(s0)
    800058fa:	cf9ff0ef          	jal	800055f2 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800058fe:	85e2                	mv	a1,s8
    80005900:	0001e517          	auipc	a0,0x1e
    80005904:	fb050513          	addi	a0,a0,-80 # 800238b0 <disk+0x18>
    80005908:	dccfc0ef          	jal	80001ed4 <sleep>
  for(int i = 0; i < 3; i++){
    8000590c:	f9040613          	addi	a2,s0,-112
    80005910:	894e                	mv	s2,s3
    80005912:	bf55                	j	800058c6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005914:	f9042503          	lw	a0,-112(s0)
    80005918:	00451693          	slli	a3,a0,0x4

  if(write)
    8000591c:	0001e797          	auipc	a5,0x1e
    80005920:	f7c78793          	addi	a5,a5,-132 # 80023898 <disk>
    80005924:	00a50713          	addi	a4,a0,10
    80005928:	0712                	slli	a4,a4,0x4
    8000592a:	973e                	add	a4,a4,a5
    8000592c:	01703633          	snez	a2,s7
    80005930:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005932:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005936:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000593a:	6398                	ld	a4,0(a5)
    8000593c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000593e:	0a868613          	addi	a2,a3,168
    80005942:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005944:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005946:	6390                	ld	a2,0(a5)
    80005948:	00d605b3          	add	a1,a2,a3
    8000594c:	4741                	li	a4,16
    8000594e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005950:	4805                	li	a6,1
    80005952:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005956:	f9442703          	lw	a4,-108(s0)
    8000595a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000595e:	0712                	slli	a4,a4,0x4
    80005960:	963a                	add	a2,a2,a4
    80005962:	058a0593          	addi	a1,s4,88
    80005966:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005968:	0007b883          	ld	a7,0(a5)
    8000596c:	9746                	add	a4,a4,a7
    8000596e:	40000613          	li	a2,1024
    80005972:	c710                	sw	a2,8(a4)
  if(write)
    80005974:	001bb613          	seqz	a2,s7
    80005978:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000597c:	00166613          	ori	a2,a2,1
    80005980:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005984:	f9842583          	lw	a1,-104(s0)
    80005988:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000598c:	00250613          	addi	a2,a0,2
    80005990:	0612                	slli	a2,a2,0x4
    80005992:	963e                	add	a2,a2,a5
    80005994:	577d                	li	a4,-1
    80005996:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000599a:	0592                	slli	a1,a1,0x4
    8000599c:	98ae                	add	a7,a7,a1
    8000599e:	03068713          	addi	a4,a3,48
    800059a2:	973e                	add	a4,a4,a5
    800059a4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800059a8:	6398                	ld	a4,0(a5)
    800059aa:	972e                	add	a4,a4,a1
    800059ac:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800059b0:	4689                	li	a3,2
    800059b2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800059b6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800059ba:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    800059be:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800059c2:	6794                	ld	a3,8(a5)
    800059c4:	0026d703          	lhu	a4,2(a3)
    800059c8:	8b1d                	andi	a4,a4,7
    800059ca:	0706                	slli	a4,a4,0x1
    800059cc:	96ba                	add	a3,a3,a4
    800059ce:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800059d2:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800059d6:	6798                	ld	a4,8(a5)
    800059d8:	00275783          	lhu	a5,2(a4)
    800059dc:	2785                	addiw	a5,a5,1
    800059de:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800059e2:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800059e6:	100017b7          	lui	a5,0x10001
    800059ea:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800059ee:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    800059f2:	0001e917          	auipc	s2,0x1e
    800059f6:	fce90913          	addi	s2,s2,-50 # 800239c0 <disk+0x128>
  while(b->disk == 1) {
    800059fa:	4485                	li	s1,1
    800059fc:	01079a63          	bne	a5,a6,80005a10 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005a00:	85ca                	mv	a1,s2
    80005a02:	8552                	mv	a0,s4
    80005a04:	cd0fc0ef          	jal	80001ed4 <sleep>
  while(b->disk == 1) {
    80005a08:	004a2783          	lw	a5,4(s4)
    80005a0c:	fe978ae3          	beq	a5,s1,80005a00 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005a10:	f9042903          	lw	s2,-112(s0)
    80005a14:	00290713          	addi	a4,s2,2
    80005a18:	0712                	slli	a4,a4,0x4
    80005a1a:	0001e797          	auipc	a5,0x1e
    80005a1e:	e7e78793          	addi	a5,a5,-386 # 80023898 <disk>
    80005a22:	97ba                	add	a5,a5,a4
    80005a24:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005a28:	0001e997          	auipc	s3,0x1e
    80005a2c:	e7098993          	addi	s3,s3,-400 # 80023898 <disk>
    80005a30:	00491713          	slli	a4,s2,0x4
    80005a34:	0009b783          	ld	a5,0(s3)
    80005a38:	97ba                	add	a5,a5,a4
    80005a3a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005a3e:	854a                	mv	a0,s2
    80005a40:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005a44:	bafff0ef          	jal	800055f2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005a48:	8885                	andi	s1,s1,1
    80005a4a:	f0fd                	bnez	s1,80005a30 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005a4c:	0001e517          	auipc	a0,0x1e
    80005a50:	f7450513          	addi	a0,a0,-140 # 800239c0 <disk+0x128>
    80005a54:	a12fb0ef          	jal	80000c66 <release>
}
    80005a58:	70a6                	ld	ra,104(sp)
    80005a5a:	7406                	ld	s0,96(sp)
    80005a5c:	64e6                	ld	s1,88(sp)
    80005a5e:	6946                	ld	s2,80(sp)
    80005a60:	69a6                	ld	s3,72(sp)
    80005a62:	6a06                	ld	s4,64(sp)
    80005a64:	7ae2                	ld	s5,56(sp)
    80005a66:	7b42                	ld	s6,48(sp)
    80005a68:	7ba2                	ld	s7,40(sp)
    80005a6a:	7c02                	ld	s8,32(sp)
    80005a6c:	6ce2                	ld	s9,24(sp)
    80005a6e:	6165                	addi	sp,sp,112
    80005a70:	8082                	ret

0000000080005a72 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005a72:	1101                	addi	sp,sp,-32
    80005a74:	ec06                	sd	ra,24(sp)
    80005a76:	e822                	sd	s0,16(sp)
    80005a78:	e426                	sd	s1,8(sp)
    80005a7a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005a7c:	0001e497          	auipc	s1,0x1e
    80005a80:	e1c48493          	addi	s1,s1,-484 # 80023898 <disk>
    80005a84:	0001e517          	auipc	a0,0x1e
    80005a88:	f3c50513          	addi	a0,a0,-196 # 800239c0 <disk+0x128>
    80005a8c:	942fb0ef          	jal	80000bce <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005a90:	100017b7          	lui	a5,0x10001
    80005a94:	53b8                	lw	a4,96(a5)
    80005a96:	8b0d                	andi	a4,a4,3
    80005a98:	100017b7          	lui	a5,0x10001
    80005a9c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80005a9e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005aa2:	689c                	ld	a5,16(s1)
    80005aa4:	0204d703          	lhu	a4,32(s1)
    80005aa8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005aac:	04f70663          	beq	a4,a5,80005af8 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005ab0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005ab4:	6898                	ld	a4,16(s1)
    80005ab6:	0204d783          	lhu	a5,32(s1)
    80005aba:	8b9d                	andi	a5,a5,7
    80005abc:	078e                	slli	a5,a5,0x3
    80005abe:	97ba                	add	a5,a5,a4
    80005ac0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005ac2:	00278713          	addi	a4,a5,2
    80005ac6:	0712                	slli	a4,a4,0x4
    80005ac8:	9726                	add	a4,a4,s1
    80005aca:	01074703          	lbu	a4,16(a4)
    80005ace:	e321                	bnez	a4,80005b0e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005ad0:	0789                	addi	a5,a5,2
    80005ad2:	0792                	slli	a5,a5,0x4
    80005ad4:	97a6                	add	a5,a5,s1
    80005ad6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005ad8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005adc:	c44fc0ef          	jal	80001f20 <wakeup>

    disk.used_idx += 1;
    80005ae0:	0204d783          	lhu	a5,32(s1)
    80005ae4:	2785                	addiw	a5,a5,1
    80005ae6:	17c2                	slli	a5,a5,0x30
    80005ae8:	93c1                	srli	a5,a5,0x30
    80005aea:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005aee:	6898                	ld	a4,16(s1)
    80005af0:	00275703          	lhu	a4,2(a4)
    80005af4:	faf71ee3          	bne	a4,a5,80005ab0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005af8:	0001e517          	auipc	a0,0x1e
    80005afc:	ec850513          	addi	a0,a0,-312 # 800239c0 <disk+0x128>
    80005b00:	966fb0ef          	jal	80000c66 <release>
}
    80005b04:	60e2                	ld	ra,24(sp)
    80005b06:	6442                	ld	s0,16(sp)
    80005b08:	64a2                	ld	s1,8(sp)
    80005b0a:	6105                	addi	sp,sp,32
    80005b0c:	8082                	ret
      panic("virtio_disk_intr status");
    80005b0e:	00002517          	auipc	a0,0x2
    80005b12:	d3a50513          	addi	a0,a0,-710 # 80007848 <etext+0x848>
    80005b16:	ccbfa0ef          	jal	800007e0 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
