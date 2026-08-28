
libCALCULATION.so:	file format elf64-littleaarch64

Disassembly of section .text:

00000000000a8be4 <air1_opcal5_algorithm>:
   a8be4:      	stp	d15, d14, [sp, #-0xa0]!
   a8be8:      	stp	d13, d12, [sp, #0x10]
   a8bec:      	stp	d11, d10, [sp, #0x20]
   a8bf0:      	stp	d9, d8, [sp, #0x30]
   a8bf4:      	stp	x29, x30, [sp, #0x40]
   a8bf8:      	add	x29, sp, #0x40
   a8bfc:      	stp	x28, x27, [sp, #0x50]
   a8c00:      	stp	x26, x25, [sp, #0x60]
   a8c04:      	stp	x24, x23, [sp, #0x70]
   a8c08:      	stp	x22, x21, [sp, #0x80]
   a8c0c:      	stp	x20, x19, [sp, #0x90]
   a8c10:      	sub	sp, sp, #0x1, lsl #12   // =0x1000
   a8c14:      	sub	sp, sp, #0x270
   a8c18:      	mrs	x23, TPIDR_EL0
   a8c1c:      	mov	x25, x0
   a8c20:      	adrp	x0, 0xe8000 <quick_sel_arr+0x1810>
   a8c24:      	mov	x28, x2
   a8c28:      	mov	x26, x1
   a8c2c:      	ldr	x8, [x23, #0x28]
   a8c30:      	add	x0, x0, #0x2f8
   a8c34:      	mov	w1, wzr
   a8c38:      	mov	w2, #0x311              // =785
   a8c3c:      	mov	x19, x5
   a8c40:      	mov	x27, x4
   a8c44:      	mov	x22, x3
   a8c48:      	stur	x8, [x29, #-0x58]
   a8c4c:      	bl	0xbefc0 <memset@plt>
   a8c50:      	adrp	x20, 0xe8000 <quick_sel_arr+0x1810>
   a8c54:      	adrp	x21, 0xe8000 <quick_sel_arr+0x1810>
   a8c58:      	movi	v0.2d, #0000000000000000
   a8c5c:      	add	x20, x20, #0x6ac
   a8c60:      	add	x21, x21, #0x610
   a8c64:      	mov	x0, x20
   a8c68:      	mov	w1, wzr
   a8c6c:      	mov	w2, #0x61e              // =1566
   a8c70:      	stp	q0, q0, [x21]
   a8c74:      	stp	q0, q0, [x21, #0x20]
   a8c78:      	stp	q0, q0, [x21, #0x40]
   a8c7c:      	stp	q0, q0, [x21, #0x60]
   a8c80:      	str	q0, [x21, #0x80]
   a8c84:      	stur	q0, [x21, #0x8b]
   a8c88:      	bl	0xbefc0 <memset@plt>
   a8c8c:      	ldrb	w8, [x26, #0x4a]
   a8c90:      	adrp	x24, 0xe8000 <quick_sel_arr+0x1810>
   a8c94:      	cbz	w8, 0xa8ca0 <air1_opcal5_algorithm+0xbc>
   a8c98:      	mov	w0, #0x10               // =16
   a8c9c:      	b	0xa8d58 <air1_opcal5_algorithm+0x174>
   a8ca0:      	mov	w8, #0x90b8             // =37048
   a8ca4:      	mov	w9, #0x348a             // =13450
   a8ca8:      	add	x0, x22, x8
   a8cac:      	mov	w8, #0x1b48             // =6984
   a8cb0:      	add	x2, x22, x8
   a8cb4:      	mov	w8, #0x3290             // =12944
   a8cb8:      	add	x3, x22, x8
   a8cbc:      	mov	w8, #0x1cc8             // =7368
   a8cc0:      	add	x8, x22, x8
   a8cc4:      	add	x1, x22, x9
   a8cc8:      	ldrh	w10, [x22, #0x12]
   a8ccc:      	add	x6, x22, #0x154
   a8cd0:      	ldrh	w9, [x26]
   a8cd4:      	add	x7, x25, #0x1b2
   a8cd8:      	str	x8, [sp, #0x3e0]
   a8cdc:      	mov	w8, #0x439c             // =17308
   a8ce0:      	add	x4, x22, x8
   a8ce4:      	mov	w8, #0x32a9             // =12969
   a8ce8:      	add	x8, x22, x8
   a8cec:      	mov	w11, #0x6               // =6
   a8cf0:      	mov	w12, #0x6009            // =24585
   a8cf4:      	mov	w13, #0x600a            // =24586
   a8cf8:      	mov	x14, #0x404e000000000000 // =4633641066610819072
   a8cfc:      	str	x8, [sp, #0x3e8]
   a8d00:      	mov	w8, #0x1b2e             // =6958
   a8d04:      	add	x5, x22, x8
   a8d08:      	add	x8, x22, #0x918
   a8d0c:      	str	x8, [sp, #0x3d8]
   a8d10:      	mov	w8, #0x93bc             // =37820
   a8d14:      	add	x8, x22, x8
   a8d18:      	ldrh	w15, [x26, x11]
   a8d1c:      	add	w15, w15, w12
   a8d20:      	cmp	w13, w15, uxth
   a8d24:      	b.hi	0xa8d54 <air1_opcal5_algorithm+0x170>
   a8d28:      	ldur	d0, [x26, #0x42]
   a8d2c:      	fmov	d1, x14
   a8d30:      	fcmp	d0, d1
   a8d34:      	b.gt	0xa8d54 <air1_opcal5_algorithm+0x170>
   a8d38:      	add	x11, x11, #0x2
   a8d3c:      	cmp	x11, #0x42
   a8d40:      	b.ne	0xa8d18 <air1_opcal5_algorithm+0x134>
   a8d44:      	mov	w11, #-0x10f9           // =-4345
   a8d48:      	add	w12, w9, w11
   a8d4c:      	cmp	w12, w11
   a8d50:      	b.hi	0xa8db4 <air1_opcal5_algorithm+0x1d0>
   a8d54:      	mov	w0, #0x8                // =8
   a8d58:      	mov	x1, x26
   a8d5c:      	mov	x2, x22
   a8d60:      	mov	x3, x27
   a8d64:      	mov	x4, x19
   a8d68:      	bl	0xb0968 <set_exceptional_output>
   a8d6c:      	ldrb	w0, [x24, #0x608]
   a8d70:      	ldr	x8, [x23, #0x28]
   a8d74:      	ldur	x9, [x29, #-0x58]
   a8d78:      	cmp	x8, x9
   a8d7c:      	b.ne	0xb0964 <air1_opcal5_algorithm+0x7d80>
   a8d80:      	add	sp, sp, #0x1, lsl #12   // =0x1000
   a8d84:      	add	sp, sp, #0x270
   a8d88:      	ldp	x20, x19, [sp, #0x90]
   a8d8c:      	ldp	x22, x21, [sp, #0x80]
   a8d90:      	ldp	x24, x23, [sp, #0x70]
   a8d94:      	ldp	x26, x25, [sp, #0x60]
   a8d98:      	ldp	x28, x27, [sp, #0x50]
   a8d9c:      	ldp	x29, x30, [sp, #0x40]
   a8da0:      	ldp	d9, d8, [sp, #0x30]
   a8da4:      	ldp	d11, d10, [sp, #0x20]
   a8da8:      	ldp	d13, d12, [sp, #0x10]
   a8dac:      	ldp	d15, d14, [sp], #0xa0
   a8db0:      	ret
   a8db4:      	cbz	w10, 0xa8dc8 <air1_opcal5_algorithm+0x1e4>
   a8db8:      	cmp	w9, w10
   a8dbc:      	b.hi	0xa8dc8 <air1_opcal5_algorithm+0x1e4>
   a8dc0:      	mov	w0, #0x20               // =32
   a8dc4:      	b	0xa8d58 <air1_opcal5_algorithm+0x174>
   a8dc8:      	ldrh	w10, [x22, #0x8]
   a8dcc:      	strh	w9, [x22, #0x12]
   a8dd0:      	ldr	s0, [x7, #0x4]
   a8dd4:      	add	w9, w10, #0x1
   a8dd8:      	strh	w9, [x22, #0x8]
   a8ddc:      	cbnz	w10, 0xa8e34 <air1_opcal5_algorithm+0x250>
   a8de0:      	fcvt	d1, s0
   a8de4:      	movi	d2, #0000000000000000
   a8de8:      	fcmp	s0, s0
   a8dec:      	mov	x9, #0x3333333333333333 // =3689348814741910323
   a8df0:      	movk	x9, #0x3fb3, lsl #48
   a8df4:      	fcsel	d0, d2, d1, vs
   a8df8:      	fmov	d1, x9
   a8dfc:      	fcmp	d0, d1
   a8e00:      	b.pl	0xa8e10 <air1_opcal5_algorithm+0x22c>
   a8e04:      	mov	w9, #0x2                // =2
   a8e08:      	strb	w9, [x22, #0x2]
   a8e0c:      	b	0xa8e34 <air1_opcal5_algorithm+0x250>
   a8e10:      	mov	x9, #0x3333333333333333 // =3689348814741910323
   a8e14:      	movk	x9, #0x3fb3, lsl #48
   a8e18:      	fmov	d1, x9
   a8e1c:      	fcmp	d0, d1
   a8e20:      	b.le	0xa8e30 <air1_opcal5_algorithm+0x24c>
   a8e24:      	mov	w9, #0x1                // =1
   a8e28:      	strb	w9, [x22, #0x2]
   a8e2c:      	b	0xa8e34 <air1_opcal5_algorithm+0x250>
   a8e30:      	strb	wzr, [x22, #0x2]
   a8e34:      	adrp	x10, 0x9000 <loess_weight_arr+0x7920>
   a8e38:      	adrp	x17, 0xe9000 <g_algo+0x330>
   a8e3c:      	add	x17, x17, #0x6a0
   a8e40:      	mov	w12, #0x100             // =256
   a8e44:      	adrp	x13, 0x9000 <loess_weight_arr+0x7920>
   a8e48:      	mov	x11, #0x4044000000000000 // =4630826316843712512
   a8e4c:      	ldr	q0, [x10, #0xa20]
   a8e50:      	adrp	x10, 0x9000 <loess_weight_arr+0x7920>
   a8e54:      	strh	w12, [x17, #0x18]
   a8e58:      	mov	w12, #0x1e              // =30
   a8e5c:      	str	x11, [x17, #0x10]
   a8e60:      	mov	w11, #0x708             // =1800
   a8e64:      	str	q0, [x17]
   a8e68:      	ldr	q0, [x10, #0xa30]
   a8e6c:      	strb	w12, [x17, #0x20]
   a8e70:      	adrp	x12, 0x9000 <loess_weight_arr+0x7920>
   a8e74:      	movk	w11, #0x12c, lsl #16
   a8e78:      	adrp	x14, 0x9000 <loess_weight_arr+0x7920>
   a8e7c:      	stur	q0, [x17, #0x28]
   a8e80:      	ldr	q0, [x13, #0x7c0]
   a8e84:      	mov	x13, #0x80000000000     // =8796093022208
   a8e88:      	mov	w15, #0x18              // =24
   a8e8c:      	str	w11, [x17, #0x1c]
   a8e90:      	mov	w11, #0x1               // =1
   a8e94:      	stur	q0, [x17, #0x48]
   a8e98:      	ldr	q0, [x12, #0x700]
   a8e9c:      	mov	w12, #0x360             // =864
   a8ea0:      	movk	x13, #0x4091, lsl #48
   a8ea4:      	movk	w12, #0x7e0, lsl #16
   a8ea8:      	strb	w11, [x17, #0x40]
   a8eac:      	strb	w11, [x17, #0x80]
   a8eb0:      	adrp	x16, 0x9000 <loess_weight_arr+0x7920>
   a8eb4:      	strb	w11, [x17, #0x92]
   a8eb8:      	mov	x11, #0x4069000000000000 // =4641240890982006784
   a8ebc:      	stur	w12, [x17, #0x82]
   a8ec0:      	mov	w12, #0x900             // =2304
   a8ec4:      	str	q0, [sp, #0x230]
   a8ec8:      	ldr	q1, [x16, #0xa50]
   a8ecc:      	str	q0, [x17, #0x70]
   a8ed0:      	ldr	q0, [x14, #0xce0]
   a8ed4:      	strh	w12, [x17, #0x86]
   a8ed8:      	adrp	x12, 0x9000 <loess_weight_arr+0x7920>
   a8edc:      	str	x11, [x17, #0xc8]
   a8ee0:      	mov	x11, #-0x3333333333333334 // =-3689348814741910324
   a8ee4:      	movk	x11, #0xcccd
   a8ee8:      	str	x13, [x17, #0x88]
   a8eec:      	ldr	q2, [x12, #0x760]
   a8ef0:      	mov	x12, #0x9bdd            // =39901
   a8ef4:      	movk	x12, #0xea4a, lsl #16
   a8ef8:      	strh	w15, [x17, #0x90]
   a8efc:      	movk	x12, #0x18da, lsl #32
   a8f00:      	stur	q0, [x17, #0x98]
   a8f04:      	movk	x12, #0x3f67, lsl #48
   a8f08:      	adrp	x13, 0x9000 <loess_weight_arr+0x7920>
   a8f0c:      	adrp	x15, 0x9000 <loess_weight_arr+0x7920>
   a8f10:      	movk	x11, #0x402c, lsl #48
   a8f14:      	stur	q1, [x17, #0xa8]
   a8f18:      	mov	w14, #0xa               // =10
   a8f1c:      	dup	v0.2d, x12
   a8f20:      	adrp	x12, 0x9000 <loess_weight_arr+0x7920>
   a8f24:      	stur	q2, [x17, #0xb8]
   a8f28:      	ldr	q1, [x13, #0xb50]
   a8f2c:      	ldr	q2, [x15, #0x950]
   a8f30:      	stur	q0, [x17, #0xd8]
   a8f34:      	stp	xzr, x11, [x17, #0x118]
   a8f38:      	adrp	x11, 0x9000 <loess_weight_arr+0x7920>
   a8f3c:      	ldr	q0, [x12, #0x6c0]
   a8f40:      	adrp	x12, 0x9000 <loess_weight_arr+0x7920>
   a8f44:      	stur	q1, [x17, #0xe8]
   a8f48:      	adrp	x13, 0x9000 <loess_weight_arr+0x7920>
   a8f4c:      	stur	q2, [x17, #0xf8]
   a8f50:      	ldr	q1, [x11, #0x870]
   a8f54:      	ldr	q2, [x12, #0x640]
   a8f58:      	adrp	x11, 0x9000 <loess_weight_arr+0x7920>
   a8f5c:      	adrp	x12, 0x9000 <loess_weight_arr+0x7920>
   a8f60:      	ldr	q3, [x13, #0xc90]
   a8f64:      	adrp	x13, 0x9000 <loess_weight_arr+0x7920>
   a8f68:      	stp	q0, q1, [x17, #0x140]
   a8f6c:      	ldr	q0, [x11, #0x790]
   a8f70:      	mov	x11, #0x3ff0000000000000 // =4607182418800017408
   a8f74:      	ldr	q1, [x12, #0x9e0]
   a8f78:      	adrp	x12, 0x9000 <loess_weight_arr+0x7920>
   a8f7c:      	stp	q2, q3, [x17, #0x160]
   a8f80:      	ldr	q2, [x13, #0xcc0]
   a8f84:      	add	x13, x17, #0x1c8
   a8f88:      	stp	x11, xzr, [x17, #0x1b0]
   a8f8c:      	stp	q0, q1, [x17, #0x180]
   a8f90:      	ldr	q0, [x12, #0xbc0]
   a8f94:      	adrp	x12, 0x9000 <loess_weight_arr+0x7920>
   a8f98:      	str	q2, [x17, #0x1a0]
   a8f9c:      	fmov	v17.2d, #1.00000000
   a8fa0:      	str	xzr, [x13, #0x10]
   a8fa4:      	str	q0, [x13]
   a8fa8:      	mov	x10, #-0x6666666666666667 // =-7378697629483820647
   a8fac:      	ldr	q0, [x12, #0xab0]
   a8fb0:      	adrp	x12, 0x9000 <loess_weight_arr+0x7920>
   a8fb4:      	str	xzr, [x13, #0x30]
   a8fb8:      	movk	x10, #0x999a
   a8fbc:      	str	q17, [x13, #0x20]
   a8fc0:      	mov	w9, #0x2                // =2
   a8fc4:      	str	x11, [x13, #0x40]
   a8fc8:      	adrp	x11, 0x9000 <loess_weight_arr+0x7920>
   a8fcc:      	mov	w13, #0x60a             // =1546
   a8fd0:      	ldr	q2, [x12, #0xbf0]
   a8fd4:      	mov	x12, #0x9fbe            // =40894
   a8fd8:      	strh	w14, [x17, #0xd0]
   a8fdc:      	movk	x12, #0x2f1a, lsl #16
   a8fe0:      	add	x14, x17, #0x218
   a8fe4:      	movk	x12, #0x24dd, lsl #32
   a8fe8:      	ldr	q1, [x11, #0x960]
   a8fec:      	adrp	x11, 0x9000 <loess_weight_arr+0x7920>
   a8ff0:      	strh	w13, [x17, #0x210]
   a8ff4:      	adrp	x13, 0x9000 <loess_weight_arr+0x7920>
   a8ff8:      	movk	x12, #0x3ff2, lsl #48
   a8ffc:      	stp	q0, q1, [x14]
   a9000:      	movk	x10, #0x3fc9, lsl #48
   a9004:      	ldr	q0, [x11, #0x650]
   a9008:      	add	x11, x17, #0x258
   a900c:      	ldr	q1, [x13, #0xd60]
   a9010:      	str	x12, [x17, #0x268]
   a9014:      	adrp	x12, 0x1000 <strcasecmp+0x1000>
   a9018:      	strb	w9, [x17, #0x1a]
   a901c:      	str	x10, [x17, #0x38]
   a9020:      	mov	w13, #0x1b0             // =432
   a9024:      	str	q1, [x11]
   a9028:      	mov	w15, #0xe10             // =3600
   a902c:      	ldr	d1, [x12, #0x520]
   a9030:      	mov	x12, #0x4049000000000000 // =4632233691727265792
   a9034:      	strb	wzr, [x17, #0x58]
   a9038:      	mov	x16, #-0x3fbc000000000000 // =-4592545720011063296
   a903c:      	stp	xzr, xzr, [x17, #0x60]
   a9040:      	fmov	d3, #1.00000000
   a9044:      	fmov	d4, x12
   a9048:      	adrp	x12, 0x1000 <strcasecmp+0x1000>
   a904c:      	stp	xzr, xzr, [x17, #0x108]
   a9050:      	stp	xzr, xzr, [x17, #0x130]
   a9054:      	str	xzr, [x17, #0x128]
   a9058:      	str	xzr, [x17, #0x1c0]
   a905c:      	str	xzr, [x17, #0x1e0]
   a9060:      	str	xzr, [x17, #0x200]
   a9064:      	stp	q2, q0, [x14, #0x20]
   a9068:      	ldr	d0, [x12, #0x540]
   a906c:      	ldrb	w11, [x22, #0x2]
   a9070:      	mov	w12, #0x32              // =50
   a9074:      	mov	w14, #0xb40             // =2880
   a9078:      	fmov	d2, x16
   a907c:      	mov	x16, #0xc00000000000    // =211106232532992
   a9080:      	str	x10, [x17, #0x2b8]
   a9084:      	cmp	w11, #0x1
   a9088:      	mov	w11, #0x360             // =864
   a908c:      	csel	w13, w13, w11, eq
   a9090:      	strb	w12, [x17, #0x270]
   a9094:      	adrp	x12, 0x9000 <loess_weight_arr+0x7920>
   a9098:      	csel	w14, w15, w14, eq
   a909c:      	mov	x15, #0xc00000000000    // =211106232532992
   a90a0:      	fcsel	d1, d3, d1, eq
   a90a4:      	strh	w13, [x17, #0x272]
   a90a8:      	adrp	x13, 0x9000 <loess_weight_arr+0x7920>
   a90ac:      	ldr	q7, [x12, #0xbd0]
   a90b0:      	add	x12, x17, #0x278
   a90b4:      	movk	x15, #0x4072, lsl #48
   a90b8:      	movk	x16, #0x4062, lsl #48
   a90bc:      	ldr	q16, [x13, #0xb90]
   a90c0:      	add	x13, x17, #0x288
   a90c4:      	str	q7, [x12]
   a90c8:      	mov	x12, #-0x3fb7000000000000 // =-4591138345127510016
   a90cc:      	strh	w14, [x17, #0x274]
   a90d0:      	mov	x14, #-0x3fac000000000000 // =-4588042120383692800
   a90d4:      	fmov	d5, x15
   a90d8:      	fmov	d6, x16
   a90dc:      	str	q16, [x13]
   a90e0:      	fmov	d16, x12
   a90e4:      	str	d1, [x17, #0x298]
   a90e8:      	fmov	d1, x14
   a90ec:      	mov	x10, #0x800000000000    // =140737488355328
   a90f0:      	mov	w15, #0x2d0             // =720
   a90f4:      	movk	x10, #0x4061, lsl #48
   a90f8:      	mov	w16, #0x3a8             // =936
   a90fc:      	fcsel	d2, d4, d2, eq
   a9100:      	fcsel	d4, d6, d5, eq
   a9104:      	mov	x12, #0x3333333333333333 // =3689348814741910323
   a9108:      	fcsel	d1, d1, d16, eq
   a910c:      	csel	w15, w16, w15, eq
   a9110:      	adrp	x16, 0x1000 <strcasecmp+0x1000>
   a9114:      	movk	x12, #0x3ff3, lsl #48
   a9118:      	str	x10, [x17, #0x2d8]
   a911c:      	adrp	x10, 0x9000 <loess_weight_arr+0x7920>
   a9120:      	fmov	d6, #1.50000000
   a9124:      	ldr	d5, [x16, #0x558]
   a9128:      	fmov	d7, #0.25000000
   a912c:      	str	d4, [x17, #0x2b0]
   a9130:      	fmov	d4, x12
   a9134:      	str	d1, [x17, #0x2e0]
   a9138:      	ldr	q1, [x10, #0x8b0]
   a913c:      	mov	w10, #0x54              // =84
   a9140:      	mov	w16, #0x5a0             // =1440
   a9144:      	fcsel	d6, d0, d6, eq
   a9148:      	str	d2, [x17, #0x2a8]
   a914c:      	fcsel	d2, d5, d7, eq
   a9150:      	fcsel	d3, d4, d3, eq
   a9154:      	mov	w13, #0xff              // =255
   a9158:      	strh	w10, [x17, #0x308]
   a915c:      	adrp	x10, 0xe9000 <g_algo+0x330>
   a9160:      	csel	w16, w11, w16, eq
   a9164:      	add	x12, x17, #0x2f2
   a9168:      	movk	w13, #0x201, lsl #16
   a916c:      	strh	w11, [x17, #0x2f0]
   a9170:      	mov	w11, #0x60              // =96
   a9174:      	add	x14, x17, #0x2f8
   a9178:      	add	x10, x10, #0x9b0
   a917c:      	strb	w9, [x17, #0x2a0]
   a9180:      	strh	w15, [x17, #0x2c0]
   a9184:      	strh	w16, [x17, #0x2c2]
   a9188:      	str	d6, [x17, #0x2c8]
   a918c:      	str	d2, [x17, #0x2d0]
   a9190:      	str	d3, [x17, #0x2e8]
   a9194:      	str	w13, [x12]
   a9198:      	strh	w11, [x17, #0x2f6]
   a919c:      	str	q1, [x14]
   a91a0:      	str	x25, [sp, #0x3b0]
   a91a4:      	b.ne	0xa91c4 <air1_opcal5_algorithm+0x5e0>
   a91a8:      	adrp	x11, 0x9000 <loess_weight_arr+0x7920>
   a91ac:      	mov	x12, #-0x6666666666666667 // =-7378697629483820647
   a91b0:      	movk	x12, #0x999a
   a91b4:      	strh	w9, [x10, #0x10]
   a91b8:      	movk	x12, #0x3f89, lsl #48
   a91bc:      	ldr	q1, [x11, #0x9a0]
   a91c0:      	b	0xa91dc <air1_opcal5_algorithm+0x5f8>
   a91c4:      	adrp	x11, 0x9000 <loess_weight_arr+0x7920>
   a91c8:      	mov	x12, #-0x6666666666666667 // =-7378697629483820647
   a91cc:      	movk	x12, #0x999a
   a91d0:      	strh	w9, [x10, #0x10]
   a91d4:      	movk	x12, #0x3f89, lsl #48
   a91d8:      	ldr	q1, [x11, #0x7f0]
   a91dc:      	str	x12, [x10]
   a91e0:      	mov	w11, #0x2               // =2
   a91e4:      	adrp	x12, 0x9000 <loess_weight_arr+0x7920>
   a91e8:      	adrp	x9, 0xe9000 <g_algo+0x330>
   a91ec:      	adrp	x10, 0x9000 <loess_weight_arr+0x7920>
   a91f0:      	movk	w11, #0x201, lsl #16
   a91f4:      	add	x9, x9, #0x9c8
   a91f8:      	ldr	q3, [x12, #0x7a0]
   a91fc:      	mov	x12, #0x800000000000    // =140737488355328
   a9200:      	ldr	q2, [x10, #0xb60]
   a9204:      	movk	x12, #0x4066, lsl #48
   a9208:      	str	w11, [x9, #0x20]
   a920c:      	mov	w11, #0x1b0             // =432
   a9210:      	mov	w13, #0x120             // =288
   a9214:      	adrp	x14, 0x9000 <loess_weight_arr+0x7920>
   a9218:      	stp	q1, q2, [x9]
   a921c:      	movk	w13, #0x90, lsl #16
   a9220:      	strh	w11, [x9, #0x40]
   a9224:      	adrp	x11, 0x9000 <loess_weight_arr+0x7920>
   a9228:      	str	x12, [x9, #0x48]
   a922c:      	adrp	x12, 0x9000 <loess_weight_arr+0x7920>
   a9230:      	ldr	q1, [sp, #0x230]
   a9234:      	str	w13, [x9, #0x50]
   a9238:      	adrp	x13, 0x9000 <loess_weight_arr+0x7920>
   a923c:      	stur	q3, [x9, #0x28]
   a9240:      	ldr	q2, [x12, #0xaa0]
   a9244:      	adrp	x15, 0x9000 <loess_weight_arr+0x7920>
   a9248:      	stur	q1, [x9, #0x68]
   a924c:      	ldr	q1, [x11, #0xba0]
   a9250:      	adrp	x11, 0x9000 <loess_weight_arr+0x7920>
   a9254:      	ldr	q3, [x14, #0x800]
   a9258:      	stur	q2, [x9, #0x88]
   a925c:      	ldr	q2, [x13, #0xaf0]
   a9260:      	stur	q1, [x9, #0x78]
   a9264:      	mov	x14, #0x4054000000000000 // =4635329916471083008
   a9268:      	ldr	q1, [x11, #0xae0]
   a926c:      	adrp	x11, 0x1000 <strcasecmp+0x1000>
   a9270:      	str	q3, [x9, #0xc0]
   a9274:      	ldr	q3, [x15, #0x8c0]
   a9278:      	mov	w15, #0x120             // =288
   a927c:      	str	x14, [x9, #0xd0]
   a9280:      	stp	q1, q2, [x9, #0xa0]
   a9284:      	ldr	d1, [x11, #0x6b8]
   a9288:      	adrp	x11, 0x9000 <loess_weight_arr+0x7920>
   a928c:      	add	x14, x9, #0x13a
   a9290:      	movk	w15, #0xa0a, lsl #16
   a9294:      	add	x16, x9, #0x128
   a9298:      	str	d1, [x9, #0xd8]
   a929c:      	adrp	x13, 0x9000 <loess_weight_arr+0x7920>
   a92a0:      	ldr	q1, [x11, #0x840]
   a92a4:      	adrp	x11, 0x9000 <loess_weight_arr+0x7920>
   a92a8:      	str	w15, [x14]
   a92ac:      	mov	w15, #0x3               // =3
   a92b0:      	adrp	x14, 0x9000 <loess_weight_arr+0x7920>
   a92b4:      	movk	w15, #0xb, lsl #16
   a92b8:      	str	q1, [x9, #0x110]
   a92bc:      	ldr	q1, [x11, #0xd50]
   a92c0:      	stur	q3, [x9, #0xf8]
   a92c4:      	ldr	q2, [x13, #0xac0]
   a92c8:      	str	w15, [x9, #0xe0]
   a92cc:      	mov	x15, #0x4024000000000000 // =4621819117588971520
   a92d0:      	str	q1, [x16]
   a92d4:      	adrp	x16, 0x9000 <loess_weight_arr+0x7920>
   a92d8:      	ldr	q1, [x14, #0xe10]
   a92dc:      	add	x14, x9, #0x158
   a92e0:      	str	x15, [x9, #0x168]
   a92e4:      	mov	x15, #0x4000000000000000 // =4611686018427387904
   a92e8:      	ldr	q3, [x16, #0x730]
   a92ec:      	adrp	x17, 0x1000 <strcasecmp+0x1000>
   a92f0:      	str	q1, [x9, #0x140]
   a92f4:      	mov	w16, #0xa02             // =2562
   a92f8:      	str	x15, [x9, #0x178]
   a92fc:      	adrp	x15, 0x9000 <loess_weight_arr+0x7920>
   a9300:      	str	q3, [x14]
   a9304:      	adrp	x14, 0x9000 <loess_weight_arr+0x7920>
   a9308:      	stur	q2, [x9, #0xe8]
   a930c:      	ldr	d2, [x17, #0x670]
   a9310:      	strh	w16, [x9, #0x170]
   a9314:      	adrp	x16, 0x1000 <strcasecmp+0x1000>
   a9318:      	ldr	q1, [x14, #0xcf0]
   a931c:      	add	x14, x9, #0x188
   a9320:      	str	d2, [x9, #0x150]
   a9324:      	mov	w12, #0x120             // =288
   a9328:      	ldr	d2, [x16, #0x6c8]
   a932c:      	adrp	x16, 0x9000 <loess_weight_arr+0x7920>
   a9330:      	str	q1, [x14]
   a9334:      	ldr	q1, [x15, #0x9c0]
   a9338:      	add	x15, x9, #0x198
   a933c:      	adrp	x14, 0x9000 <loess_weight_arr+0x7920>
   a9340:      	ldr	q3, [x16, #0x830]
   a9344:      	add	x16, x9, #0x1a8
   a9348:      	strh	w12, [x9, #0x98]
   a934c:      	mov	x13, #0x3fe0000000000000 // =4602678819172646912
   a9350:      	str	q1, [x15]
   a9354:      	adrp	x15, 0x9000 <loess_weight_arr+0x7920>
   a9358:      	ldr	q4, [x14, #0x610]
   a935c:      	add	x14, x9, #0x1b8
   a9360:      	str	q3, [x16]
   a9364:      	adrp	x16, 0x9000 <loess_weight_arr+0x7920>
   a9368:      	ldr	q1, [x15, #0xcb0]
   a936c:      	add	x15, x9, #0x1c8
   a9370:      	str	q4, [x14]
   a9374:      	adrp	x14, 0x9000 <loess_weight_arr+0x7920>
   a9378:      	ldr	q3, [x16, #0x770]
   a937c:      	add	x16, x9, #0x1d8
   a9380:      	str	q1, [x15]
   a9384:      	mov	w15, #0x5               // =5
   a9388:      	ldr	q4, [x14, #0xde0]
   a938c:      	add	x14, x9, #0x1e8
   a9390:      	movk	w15, #0xc, lsl #16
   a9394:      	str	q3, [x16]
   a9398:      	mov	w16, #0x30              // =48
   a939c:      	strh	w12, [x9, #0x220]
   a93a0:      	str	q4, [x14]
   a93a4:      	adrp	x14, 0x9000 <loess_weight_arr+0x7920>
   a93a8:      	str	w15, [x9, #0x1f8]
   a93ac:      	mov	x15, #0x4044000000000000 // =4630826316843712512
   a93b0:      	adrp	x12, 0x9000 <loess_weight_arr+0x7920>
   a93b4:      	strh	w16, [x9, #0x1fc]
   a93b8:      	ldr	q1, [x14, #0xc30]
   a93bc:      	add	x14, x9, #0x208
   a93c0:      	str	x15, [x9, #0x200]
   a93c4:      	adrp	x15, 0x9000 <loess_weight_arr+0x7920>
   a93c8:      	adrp	x16, 0x1000 <strcasecmp+0x1000>
   a93cc:      	str	d2, [x9, #0x180]
   a93d0:      	str	q1, [x14]
   a93d4:      	add	x14, x9, #0x238
   a93d8:      	ldr	q1, [x15, #0x8d0]
   a93dc:      	adrp	x15, 0x9000 <loess_weight_arr+0x7920>
   a93e0:      	ldr	q2, [x12, #0x970]
   a93e4:      	add	x12, x9, #0x228
   a93e8:      	ldr	d3, [x16, #0x5d0]
   a93ec:      	str	x13, [x9, #0x108]
   a93f0:      	str	q1, [x14]
   a93f4:      	adrp	x14, 0x9000 <loess_weight_arr+0x7920>
   a93f8:      	str	q2, [x12]
   a93fc:      	mov	w12, #0x2               // =2
   a9400:      	str	d3, [x9, #0x218]
   a9404:      	mov	w13, #0x6               // =6
   a9408:      	ldr	q3, [x14, #0x980]
   a940c:      	add	x14, x9, #0x258
   a9410:      	strb	w12, [x9, #0x270]
   a9414:      	mov	x12, #-0x6666666666666667 // =-7378697629483820647
   a9418:      	movk	x12, #0x999a
   a941c:      	ldr	q1, [x15, #0x5e0]
   a9420:      	add	x15, x9, #0x248
   a9424:      	str	q3, [x14]
   a9428:      	movk	x12, #0x3ff1, lsl #48
   a942c:      	adrp	x14, 0x9000 <loess_weight_arr+0x7920>
   a9430:      	strh	w13, [x9, #0x120]
   a9434:      	mov	x10, #0x403e000000000000 // =4629137466983448576
   a9438:      	strh	w13, [x9, #0x280]
   a943c:      	mov	w13, #0x5               // =5
   a9440:      	str	q1, [x15]
   a9444:      	ldr	q1, [x14, #0xa70]
   a9448:      	str	x12, [x9, #0x288]
   a944c:      	add	x12, x9, #0x298
   a9450:      	movk	w13, #0x240, lsl #16
   a9454:      	adrp	x14, 0x9000 <loess_weight_arr+0x7920>
   a9458:      	mov	x15, #-0x4010000000000000 // =-4616189618054758400
   a945c:      	str	q2, [x9, #0x2b0]
   a9460:      	str	q1, [x12]
   a9464:      	mov	w12, #0x3               // =3
   a9468:      	str	w13, [x9, #0x2a8]
   a946c:      	ldr	q1, [x14, #0x5c0]
   a9470:      	adrp	x13, 0x9000 <loess_weight_arr+0x7920>
   a9474:      	movk	w12, #0xc, lsl #16
   a9478:      	add	x14, x9, #0x3f8
   a947c:      	str	x15, [x9, #0x268]
   a9480:      	stp	q1, q1, [x9, #0x3c0]
   a9484:      	mov	w15, #0x180             // =384
   a9488:      	ldr	q1, [x13, #0xcd0]
   a948c:      	adrp	x13, 0x9000 <loess_weight_arr+0x7920>
   a9490:      	str	w12, [x9, #0x3f0]
   a9494:      	adrp	x12, 0x9000 <loess_weight_arr+0x7920>
   a9498:      	strh	w15, [x9, #0x2ac]
   a949c:      	add	x15, x9, #0x408
   a94a0:      	str	q1, [x14]
   a94a4:      	ldr	q1, [x13, #0xa00]
   a94a8:      	mov	x13, #0x4014000000000000 // =4617315517961601024
   a94ac:      	ldr	q2, [x12, #0xdf0]
   a94b0:      	adrp	x12, 0x9000 <loess_weight_arr+0x7920>
   a94b4:      	add	x14, x9, #0x418
   a94b8:      	fmov	v4.2d, #-20.00000000
   a94bc:      	str	q1, [x9, #0x550]
   a94c0:      	str	x13, [x9, #0x428]
   a94c4:      	mov	x13, #0x800000000000    // =140737488355328
   a94c8:      	movk	x13, #0xc051, lsl #48
   a94cc:      	str	q2, [x15]
   a94d0:      	add	x15, x9, #0x448
   a94d4:      	ldr	q2, [x12, #0x910]
   a94d8:      	mov	x12, #-0x3fb7000000000000 // =-4591138345127510016
   a94dc:      	str	q1, [x14]
   a94e0:      	dup	v3.2d, x13
   a94e4:      	mov	w13, #0xc               // =12
   a94e8:      	str	q2, [x15]
   a94ec:      	add	x14, x9, #0x498
   a94f0:      	str	x12, [x9, #0x458]
   a94f4:      	adrp	x15, 0x9000 <loess_weight_arr+0x7920>
   a94f8:      	dup	v2.2d, x12
   a94fc:      	add	x12, x9, #0x4a8
   a9500:      	movk	w13, #0x18, lsl #16
   a9504:      	str	q4, [x9, #0x510]
   a9508:      	str	q2, [x14]
   a950c:      	ldr	q2, [x15, #0xb20]
   a9510:      	str	q3, [x12]
   a9514:      	adrp	x12, 0x9000 <loess_weight_arr+0x7920>
   a9518:      	str	w13, [x9, #0x4b8]
   a951c:      	mov	x13, #0x4049000000000000 // =4632233691727265792
   a9520:      	str	q2, [x9, #0x4c0]
   a9524:      	add	x14, x9, #0x4d8
   a9528:      	ldr	q2, [x12, #0x920]
   a952c:      	add	x12, x9, #0x4e8
   a9530:      	dup	v3.2d, x13
   a9534:      	mov	x13, #0x3ff0000000000000 // =4607182418800017408
   a9538:      	str	q4, [x9, #0x520]
   a953c:      	mov	w15, #0x5               // =5
   a9540:      	str	q3, [x12]
   a9544:      	adrp	x12, 0x9000 <loess_weight_arr+0x7920>
   a9548:      	str	x13, [x9, #0x4f8]
   a954c:      	adrp	x13, 0x9000 <loess_weight_arr+0x7920>
   a9550:      	str	q2, [x14]
   a9554:      	add	x14, x9, #0x2c2
   a9558:      	ldr	q2, [x12, #0xd70]
   a955c:      	adrp	x12, 0x9000 <loess_weight_arr+0x7920>
   a9560:      	ldr	q3, [x13, #0x740]
   a9564:      	mov	x13, #0x800000000000    // =140737488355328
   a9568:      	fmov	v4.2d, #-25.00000000
   a956c:      	movk	x13, #0xc041, lsl #48
   a9570:      	ldr	q5, [x12, #0xd00]
   a9574:      	adrp	x12, 0x9000 <loess_weight_arr+0x7920>
   a9578:      	movk	w15, #0x1e, lsl #16
   a957c:      	str	q3, [x9, #0x540]
   a9580:      	str	q2, [x9, #0x530]
   a9584:      	mov	w11, #0xc               // =12
   a9588:      	str	q4, [x9, #0x570]
   a958c:      	dup	v4.2d, x13
   a9590:      	mov	w13, #0x3               // =3
   a9594:      	str	w15, [x14]
   a9598:      	str	q4, [x9, #0x580]
   a959c:      	ldr	q4, [x12, #0x9f0]
   a95a0:      	add	x12, x9, #0x2c8
   a95a4:      	add	x14, x9, #0x2e8
   a95a8:      	strb	w13, [x9, #0x2c0]
   a95ac:      	add	x13, x9, #0x2d8
   a95b0:      	add	x15, x9, #0x348
   a95b4:      	str	x10, [x9, #0x38]
   a95b8:      	str	q4, [x12]
   a95bc:      	add	x12, x9, #0x2f8
   a95c0:      	str	q4, [x13]
   a95c4:      	add	x13, x9, #0x308
   a95c8:      	str	q2, [x14]
   a95cc:      	add	x14, x9, #0x318
   a95d0:      	str	q3, [x12]
   a95d4:      	adrp	x12, 0x9000 <loess_weight_arr+0x7920>
   a95d8:      	str	q1, [x13]
   a95dc:      	add	x13, x9, #0x328
   a95e0:      	fmov	v1.2d, #-30.00000000
   a95e4:      	str	q5, [x14]
   a95e8:      	fmov	v3.2d, #2.00000000
   a95ec:      	add	x14, x9, #0x338
   a95f0:      	ldr	q2, [x12, #0x8f0]
   a95f4:      	add	x12, x9, #0x358
   a95f8:      	mov	w10, #0x1               // =1
   a95fc:      	strb	w11, [x9, #0x138]
   a9600:      	str	q1, [x14]
   a9604:      	adrp	x14, 0x9000 <loess_weight_arr+0x7920>
   a9608:      	str	q3, [x12]
   a960c:      	adrp	x12, 0x9000 <loess_weight_arr+0x7920>
   a9610:      	str	q1, [x13]
   a9614:      	adrp	x13, 0x9000 <loess_weight_arr+0x7920>
   a9618:      	str	q2, [x15]
   a961c:      	ldr	q2, [x14, #0xb70]
   a9620:      	add	x14, x9, #0x388
   a9624:      	ldr	q3, [x12, #0x820]
   a9628:      	mov	x12, #0x800000000000    // =140737488355328
   a962c:      	add	x15, x9, #0x368
   a9630:      	movk	x12, #0x4051, lsl #48
   a9634:      	ldr	q1, [x13, #0xb10]
   a9638:      	add	x13, x9, #0x378
   a963c:      	str	q3, [x14]
   a9640:      	adrp	x14, 0x9000 <loess_weight_arr+0x7920>
   a9644:      	strb	w10, [x9, #0x54]
   a9648:      	str	x12, [x9, #0x398]
   a964c:      	adrp	x12, 0x9000 <loess_weight_arr+0x7920>
   a9650:      	strh	w10, [x9, #0x290]
   a9654:      	str	q1, [x15]
   a9658:      	ldr	q1, [x14, #0x5f0]
   a965c:      	str	q2, [x13]
   a9660:      	mov	x13, #0x17              // =23
   a9664:      	strb	w10, [x9, #0x598]
   a9668:      	adrp	x10, 0x9000 <loess_weight_arr+0x7920>
   a966c:      	movk	x13, #0x3c, lsl #16
   a9670:      	ldr	q2, [x12, #0x850]
   a9674:      	movk	x13, #0x258, lsl #32
   a9678:      	mov	w12, #0x3               // =3
   a967c:      	strh	w11, [x9, #0x3f4]
   a9680:      	movk	x13, #0x204, lsl #48
   a9684:      	strh	w11, [x9, #0x59a]
   a9688:      	mov	x11, #-0x3ffc000000000000 // =-4610560118520545280
   a968c:      	str	q1, [x9, #0x5a0]
   a9690:      	movk	w12, #0x24, lsl #16
   a9694:      	ldr	q1, [x10, #0xda0]
   a9698:      	mov	x10, #0x4008000000000000 // =4613937818241073152
   a969c:      	stp	xzr, xzr, [x9, #0x58]
   a96a0:      	str	xzr, [x9, #0x278]
   a96a4:      	str	q5, [x9, #0x560]
   a96a8:      	str	x13, [x9, #0x590]
   a96ac:      	str	q2, [x9, #0x5b0]
   a96b0:      	str	x11, [x9, #0x5c0]
   a96b4:      	str	w12, [x9, #0x5c8]
   a96b8:      	str	q1, [x9, #0x5d0]
   a96bc:      	str	x10, [x9, #0x5e0]
   a96c0:      	ldrh	w25, [x22, #0x8]
   a96c4:      	cmp	w25, #0x1
   a96c8:      	b.hi	0xa9704 <air1_opcal5_algorithm+0xb20>
   a96cc:      	adrp	x9, 0xe9000 <g_algo+0x330>
   a96d0:      	ldur	w10, [x26, #0x2]
   a96d4:      	ldrh	w11, [x26]
   a96d8:      	ldr	w12, [x7, #0x8]
   a96dc:      	ldrh	w9, [x9, #0x6be]
   a96e0:      	nop
   a96e4:      	msub	x9, x9, x11, x10
   a96e8:      	mov	w11, #0xbb00            // =47872
   a96ec:      	movk	w11, #0x17, lsl #16
   a96f0:      	sub	x10, x9, x12
   a96f4:      	cmp	x10, x11
   a96f8:      	ccmp	x9, #0x0, #0x4, gt
   a96fc:      	csel	w9, w9, w12, gt
   a9700:      	str	w9, [x22, #0x4]
   a9704:      	ldr	s1, [x7, #0x4]
   a9708:      	adrp	x9, 0x1000 <strcasecmp+0x1000>
   a970c:      	fcvt	d1, s1
   a9710:      	ldr	d2, [x9, #0x5b8]
   a9714:      	fcmp	d1, d2
   a9718:      	b.mi	0xa9894 <air1_opcal5_algorithm+0xcb0>
   a971c:      	adrp	x9, 0x1000 <strcasecmp+0x1000>
   a9720:      	ldr	d2, [x9, #0x690]
   a9724:      	fcmp	d1, d2
   a9728:      	b.gt	0xa9894 <air1_opcal5_algorithm+0xcb0>
   a972c:      	ldr	s1, [x7]
   a9730:      	mov	x9, #0x6666666666666666 // =7378697629483820646
   a9734:      	movk	x9, #0x3ff6, lsl #48
   a9738:      	fcvt	d1, s1
   a973c:      	fmov	d2, x9
   a9740:      	fcmp	d1, d2
   a9744:      	b.mi	0xa9894 <air1_opcal5_algorithm+0xcb0>
   a9748:      	fcmp	d1, d0
   a974c:      	b.gt	0xa9894 <air1_opcal5_algorithm+0xcb0>
   a9750:      	ldr	x9, [sp, #0x3b0]
   a9754:      	fmov	s1, #2.50000000
   a9758:      	ldur	s0, [x9, #0x5]
   a975c:      	fcmp	s0, s1
   a9760:      	b.mi	0xa9894 <air1_opcal5_algorithm+0xcb0>
   a9764:      	mov	x9, #0x3333333333333333 // =3689348814741910323
   a9768:      	fcvt	d0, s0
   a976c:      	movk	x9, #0x4020, lsl #48
   a9770:      	fmov	d1, x9
   a9774:      	fcmp	d0, d1
   a9778:      	b.gt	0xa9894 <air1_opcal5_algorithm+0xcb0>
   a977c:      	adrp	x13, 0xe9000 <g_algo+0x330>
   a9780:      	mov	w9, wzr
   a9784:      	cmp	w25, #0x2
   a9788:      	strb	wzr, [x13, #0xfb0]
   a978c:      	b.lo	0xa9b28 <air1_opcal5_algorithm+0xf44>
   a9790:      	ldrh	w9, [x26]
   a9794:      	ldrh	w10, [x8, #0x4]
   a9798:      	sub	w9, w9, w10
   a979c:      	cmp	w9, #0x1
   a97a0:      	b.ne	0xa9ac8 <air1_opcal5_algorithm+0xee4>
   a97a4:      	ldur	w9, [x26, #0x2]
   a97a8:      	ldr	w10, [x8]
   a97ac:      	sub	x9, x9, x10
   a97b0:      	mov	x10, #0x404e000000000000 // =4633641066610819072
   a97b4:      	scvtf	d0, x9
   a97b8:      	fmov	d1, x10
   a97bc:      	fdiv	d0, d0, d1
   a97c0:      	fmov	d1, #23.00000000
   a97c4:      	fcmp	d0, d1
   a97c8:      	b.lt	0xa97fc <air1_opcal5_algorithm+0xc18>
   a97cc:      	ldrb	w9, [x8, #0x14]
   a97d0:      	ldr	w10, [x8, #0x8]
   a97d4:      	ldrh	w12, [x8, #0xc]
   a97d8:      	strh	w25, [x8, #0xc]
   a97dc:      	add	w11, w9, #0x1
   a97e0:      	and	w11, w11, #0xff
   a97e4:      	stur	w10, [x8, #0x6]
   a97e8:      	cmp	w11, #0x4
   a97ec:      	mov	w11, #0x4               // =4
   a97f0:      	csinc	w9, w11, w9, hs
   a97f4:      	strh	w12, [x8, #0xa]
   a97f8:      	strb	w9, [x8, #0x14]
   a97fc:      	mov	x9, #0x404e000000000000 // =4633641066610819072
   a9800:      	fmov	d1, x9
   a9804:      	fcmp	d0, d1
   a9808:      	b.lt	0xa9834 <air1_opcal5_algorithm+0xc50>
   a980c:      	ldrb	w9, [x8, #0x15]
   a9810:      	ldrh	w11, [x8, #0x10]
   a9814:      	strh	w25, [x8, #0x10]
   a9818:      	add	w10, w9, #0x1
   a981c:      	and	w10, w10, #0xff
   a9820:      	strh	w11, [x8, #0xe]
   a9824:      	cmp	w10, #0x2
   a9828:      	mov	w10, #0x2               // =2
   a982c:      	csinc	w9, w10, w9, hs
   a9830:      	strb	w9, [x8, #0x15]
   a9834:      	mov	x9, #0xc00000000000     // =211106232532992
   a9838:      	movk	x9, #0x4082, lsl #48
   a983c:      	fmov	d1, x9
   a9840:      	fcmp	d0, d1
   a9844:      	b.lt	0xa985c <air1_opcal5_algorithm+0xc78>
   a9848:      	ldrb	w9, [x8, #0x16]
   a984c:      	strh	w25, [x8, #0x12]
   a9850:      	cmp	w9, #0xff
   a9854:      	cset	w9, ne
   a9858:      	strb	w9, [x8, #0x16]
   a985c:      	adrp	x9, 0xe9000 <g_algo+0x330>
   a9860:      	ldrb	w11, [x8, #0x14]
   a9864:      	adrp	x10, 0xe9000 <g_algo+0x330>
   a9868:      	ldrb	w9, [x9, #0xf5e]
   a986c:      	cmp	w11, w9
   a9870:      	b.ne	0xa988c <air1_opcal5_algorithm+0xca8>
   a9874:      	ldrsh	w9, [x8, #0xc]
   a9878:      	ldrsh	w11, [x8, #0x6]
   a987c:      	ldrsh	w12, [x10, #0xaa0]
   a9880:      	sub	w9, w9, w11
   a9884:      	cmp	w9, w12
   a9888:      	b.le	0xa9ad0 <air1_opcal5_algorithm+0xeec>
   a988c:      	mov	w9, wzr
   a9890:      	b	0xa9ad8 <air1_opcal5_algorithm+0xef4>
   a9894:      	mov	w8, #0x1                // =1
   a9898:      	strb	wzr, [x21, #0x54]
   a989c:      	strb	wzr, [x21, #0x9a]
   a98a0:      	add	x10, x26, #0x42
   a98a4:      	add	x11, x21, #0x8
   a98a8:      	strb	w8, [x24, #0x608]
   a98ac:      	cmp	x10, x11
   a98b0:      	ldur	w8, [x26, #0x2]
   a98b4:      	str	w8, [x21, #0x4]
   a98b8:      	ldrh	w8, [x22, #0x58]
   a98bc:      	ldrh	w9, [x26]
   a98c0:      	add	w8, w8, w9
   a98c4:      	strh	w9, [x21]
   a98c8:      	strh	w8, [x21, #0x2]
   a98cc:      	b.ls	0xa98ec <air1_opcal5_algorithm+0xd08>
   a98d0:      	adrp	x10, 0xe8000 <quick_sel_arr+0x1810>
   a98d4:      	add	x9, x26, #0x6
   a98d8:      	add	x10, x10, #0x654
   a98dc:      	cmp	x9, x10
   a98e0:      	b.hs	0xa98ec <air1_opcal5_algorithm+0xd08>
   a98e4:      	mov	x9, xzr
   a98e8:      	b	0xa9910 <air1_opcal5_algorithm+0xd2c>
   a98ec:      	adrp	x10, 0xe8000 <quick_sel_arr+0x1810>
   a98f0:      	ldur	q0, [x26, #0x6]
   a98f4:      	add	x10, x10, #0x618
   a98f8:      	mov	w9, #0x18               // =24
   a98fc:      	str	q0, [x10]
   a9900:      	ldur	q0, [x26, #0x16]
   a9904:      	str	q0, [x10, #0x10]
   a9908:      	ldur	q0, [x26, #0x26]
   a990c:      	str	q0, [x10, #0x20]
   a9910:      	lsl	x9, x9, #1
   a9914:      	add	x10, x26, #0x6
   a9918:      	ldrh	w11, [x10, x9]
   a991c:      	add	x12, x21, x9
   a9920:      	add	x9, x9, #0x2
   a9924:      	cmp	x9, #0x3c
   a9928:      	strh	w11, [x12, #0x8]
   a992c:      	b.ne	0xa9918 <air1_opcal5_algorithm+0xd34>
   a9930:      	ldur	w9, [x22, #0x5d]
   a9934:      	strh	w8, [x22, #0x5a]
   a9938:      	ldrb	w10, [x22, #0x61]
   a993c:      	mov	w11, #0x40              // =64
   a9940:      	add	x12, x21, #0x9b
   a9944:      	str	w9, [x22, #0x5c]
   a9948:      	strb	w10, [x22, #0x60]
   a994c:      	ldur	q0, [x21, #0x34]
   a9950:      	ldrb	w8, [x21, #0x9a]
   a9954:      	ldrh	w10, [x21, #0x2]
   a9958:      	stur	q0, [x20, #0x3e]
   a995c:      	ldur	q0, [x21, #0x18]
   a9960:      	strb	w8, [x22, #0x61]
   a9964:      	ldr	w8, [x21, #0x4]
   a9968:      	strh	w10, [x20, #0x2]
   a996c:      	ldrb	w10, [x21, #0x9a]
   a9970:      	ldur	q1, [x21, #0x28]
   a9974:      	stur	q0, [x20, #0x22]
   a9978:      	ldrh	w9, [x21]
   a997c:      	str	w8, [x20, #0x4]
   a9980:      	ldur	q0, [x21, #0x8]
   a9984:      	mov	x8, x27
   a9988:      	strb	w10, [x20, #0x8]
   a998c:      	add	x10, x27, #0x1
   a9990:      	cmp	x10, x12
   a9994:      	stur	q1, [x20, #0x32]
   a9998:      	strh	w9, [x20]
   a999c:      	stur	q0, [x20, #0x12]
   a99a0:      	sturh	w11, [x21, #0x97]
   a99a4:      	strb	w9, [x8], #0x9b
   a99a8:      	b.hs	0xa99cc <air1_opcal5_algorithm+0xde8>
   a99ac:      	adrp	x9, 0xe8000 <quick_sel_arr+0x1810>
   a99b0:      	add	x9, x9, #0x611
   a99b4:      	cmp	x8, x9
   a99b8:      	b.ls	0xa99cc <air1_opcal5_algorithm+0xde8>
   a99bc:      	add	x8, x21, #0x1
   a99c0:      	mov	w9, #0x1                // =1
   a99c4:      	mov	x10, x27
   a99c8:      	b	0xa9a28 <air1_opcal5_algorithm+0xe44>
   a99cc:      	adrp	x8, 0xe8000 <quick_sel_arr+0x1810>
   a99d0:      	add	x10, x27, #0x98
   a99d4:      	add	x8, x8, #0x611
   a99d8:      	mov	w9, #0x99               // =153
   a99dc:      	ldp	q0, q1, [x8]
   a99e0:      	stur	q0, [x27, #0x1]
   a99e4:      	stur	q1, [x27, #0x11]
   a99e8:      	ldp	q0, q1, [x8, #0x20]
   a99ec:      	stur	q0, [x27, #0x21]
   a99f0:      	stur	q1, [x27, #0x31]
   a99f4:      	ldp	q0, q1, [x8, #0x40]
   a99f8:      	stur	q0, [x27, #0x41]
   a99fc:      	stur	q1, [x27, #0x51]
   a9a00:      	ldp	q0, q1, [x8, #0x60]
   a9a04:      	stur	q0, [x27, #0x61]
   a9a08:      	stur	q1, [x27, #0x71]
   a9a0c:      	ldr	d0, [x8, #0x80]
   a9a10:      	stur	d0, [x27, #0x81]
   a9a14:      	ldr	d0, [x8, #0x88]
   a9a18:      	stur	d0, [x27, #0x89]
   a9a1c:      	ldr	d0, [x8, #0x90]
   a9a20:      	add	x8, x8, #0x98
   a9a24:      	stur	d0, [x27, #0x91]
   a9a28:      	sub	w9, w9, #0x9b
   a9a2c:      	add	x10, x10, #0x1
   a9a30:      	ldrb	w11, [x8], #0x1
   a9a34:      	adds	w9, w9, #0x1
   a9a38:      	strb	w11, [x10], #0x1
   a9a3c:      	b.lo	0xa9a30 <air1_opcal5_algorithm+0xe4c>
   a9a40:      	add	x8, x20, #0x61e
   a9a44:      	cmp	x19, x8
   a9a48:      	b.hs	0xa9a60 <air1_opcal5_algorithm+0xe7c>
   a9a4c:      	add	x8, x19, #0x61e
   a9a50:      	cmp	x8, x20
   a9a54:      	b.ls	0xa9a60 <air1_opcal5_algorithm+0xe7c>
   a9a58:      	mov	w8, wzr
   a9a5c:      	b	0xa9ab0 <air1_opcal5_algorithm+0xecc>
   a9a60:      	mov	x8, xzr
   a9a64:      	add	x9, x20, x8
   a9a68:      	add	x10, x19, x8
   a9a6c:      	add	x8, x8, #0x20
   a9a70:      	cmp	x8, #0x600
   a9a74:      	ldp	q0, q1, [x9]
   a9a78:      	stp	q0, q1, [x10]
   a9a7c:      	b.ne	0xa9a64 <air1_opcal5_algorithm+0xe80>
   a9a80:      	adrp	x8, 0xe8000 <quick_sel_arr+0x1810>
   a9a84:      	add	x9, x19, #0x618
   a9a88:      	add	x8, x8, #0xcac
   a9a8c:      	add	x20, x8, #0x18
   a9a90:      	ldr	d0, [x8]
   a9a94:      	str	d0, [x19, #0x600]
   a9a98:      	ldr	d0, [x8, #0x8]
   a9a9c:      	str	d0, [x19, #0x608]
   a9aa0:      	ldr	d0, [x8, #0x10]
   a9aa4:      	mov	w8, #0x618              // =1560
   a9aa8:      	str	d0, [x19, #0x610]
   a9aac:      	mov	x19, x9
   a9ab0:      	sub	w8, w8, #0x61e
   a9ab4:      	ldrb	w9, [x20], #0x1
   a9ab8:      	adds	w8, w8, #0x1
   a9abc:      	strb	w9, [x19], #0x1
   a9ac0:      	b.lo	0xa9ab4 <air1_opcal5_algorithm+0xed0>
   a9ac4:      	b	0xa8d6c <air1_opcal5_algorithm+0x188>
   a9ac8:      	mov	w9, wzr
   a9acc:      	b	0xa9b28 <air1_opcal5_algorithm+0xf44>
   a9ad0:      	mov	w9, #0x1                // =1
   a9ad4:      	strb	w9, [x13, #0xfb0]
   a9ad8:      	adrp	x11, 0xe9000 <g_algo+0x330>
   a9adc:      	ldrb	w12, [x8, #0x15]
   a9ae0:      	ldrb	w11, [x11, #0xf5f]
   a9ae4:      	cmp	w12, w11
   a9ae8:      	b.ne	0xa9b0c <air1_opcal5_algorithm+0xf28>
   a9aec:      	ldrsh	w11, [x8, #0x10]
   a9af0:      	ldrsh	w12, [x8, #0xe]
   a9af4:      	ldrsh	w10, [x10, #0xaa0]
   a9af8:      	sub	w11, w11, w12
   a9afc:      	cmp	w11, w10
   a9b00:      	b.gt	0xa9b0c <air1_opcal5_algorithm+0xf28>
   a9b04:      	mov	w9, #0x1                // =1
   a9b08:      	strb	w9, [x13, #0xfb0]
   a9b0c:      	adrp	x10, 0xe9000 <g_algo+0x330>
   a9b10:      	ldrb	w11, [x8, #0x16]
   a9b14:      	ldrb	w10, [x10, #0xf60]
   a9b18:      	cmp	w11, w10
   a9b1c:      	b.ne	0xa9b28 <air1_opcal5_algorithm+0xf44>
   a9b20:      	mov	w9, #0x1                // =1
   a9b24:      	strb	w9, [x13, #0xfb0]
   a9b28:      	ldrb	w10, [x8, #0x17]
   a9b2c:      	str	x19, [sp, #0x3a0]
   a9b30:      	cmp	w10, #0x1
   a9b34:      	b.ne	0xa9b40 <air1_opcal5_algorithm+0xf5c>
   a9b38:      	mov	w9, #0x1                // =1
   a9b3c:      	strb	w9, [x13, #0xfb0]
   a9b40:      	ldur	w24, [x26, #0x2]
   a9b44:      	add	x19, sp, #0x430
   a9b48:      	ldrh	w10, [x22, #0x1cc]
   a9b4c:      	str	w24, [x8]
   a9b50:      	ldrh	w12, [x26]
   a9b54:      	strb	w9, [x8, #0x17]
   a9b58:      	strh	w12, [x8, #0x4]
   a9b5c:      	cbnz	w10, 0xa9b80 <air1_opcal5_algorithm+0xf9c>
   a9b60:      	adrp	x9, 0xe9000 <g_algo+0x330>
   a9b64:      	ldr	w8, [x22, #0x4]
   a9b68:      	ldrh	w9, [x9, #0x6bc]
   a9b6c:      	add	w8, w8, w9
   a9b70:      	sub	w8, w8, #0x78
   a9b74:      	cmp	w8, w24
   a9b78:      	b.hi	0xa9b80 <air1_opcal5_algorithm+0xf9c>
   a9b7c:      	strh	w12, [x22, #0x1cc]
   a9b80:      	strh	w12, [x22]
   a9b84:      	mov	x9, xzr
   a9b88:      	ldrh	w10, [x26, #0x6]
   a9b8c:      	mov	w8, wzr
   a9b90:      	ldrh	w11, [x26, #0xa]
   a9b94:      	str	x28, [sp, #0x240]
   a9b98:      	movi	v0.2d, #0000000000000000
   a9b9c:      	fmov	s1, w10
   a9ba0:      	ldrh	w10, [x26, #0x8]
   a9ba4:      	fmov	s2, w11
   a9ba8:      	ldrh	w11, [x26, #0xe]
   a9bac:      	mov	v1.s[1], w10
   a9bb0:      	ldrh	w10, [x26, #0xc]
   a9bb4:      	fmov	s3, w11
   a9bb8:      	ldrh	w11, [x26, #0x12]
   a9bbc:      	str	q0, [x19, #0xc30]
   a9bc0:      	mov	v2.s[1], w10
   a9bc4:      	ldrh	w10, [x26, #0x10]
   a9bc8:      	fmov	s4, w11
   a9bcc:      	ldrh	w11, [x26, #0x1a]
   a9bd0:      	ushll	v1.2d, v1.2s, #0x0
   a9bd4:      	str	q0, [x19, #0xc20]
   a9bd8:      	mov	v3.s[1], w10
   a9bdc:      	ldrh	w10, [x26, #0x14]
   a9be0:      	fmov	s6, w11
   a9be4:      	ldrh	w11, [x26, #0x1e]
   a9be8:      	ushll	v2.2d, v2.2s, #0x0
   a9bec:      	str	q0, [x19, #0xc10]
   a9bf0:      	mov	v4.s[1], w10
   a9bf4:      	ldrh	w10, [x26, #0x16]
   a9bf8:      	ucvtf	v1.2d, v1.2d
   a9bfc:      	str	q0, [x19, #0xc00]
   a9c00:      	str	q0, [x19, #0xbf0]
   a9c04:      	ushll	v3.2d, v3.2s, #0x0
   a9c08:      	fmov	s5, w10
   a9c0c:      	ldrh	w10, [x26, #0x18]
   a9c10:      	str	q0, [x19, #0xbe0]
   a9c14:      	ucvtf	v2.2d, v2.2d
   a9c18:      	str	q0, [x19, #0xbd0]
   a9c1c:      	ushll	v4.2d, v4.2s, #0x0
   a9c20:      	mov	v5.s[1], w10
   a9c24:      	ldrh	w10, [x26, #0x1c]
   a9c28:      	str	q0, [x19, #0xbc0]
   a9c2c:      	ucvtf	v3.2d, v3.2d
   a9c30:      	str	q0, [x19, #0xbb0]
   a9c34:      	str	q0, [x19, #0xba0]
   a9c38:      	ucvtf	v4.2d, v4.2d
   a9c3c:      	str	q0, [x19, #0xb90]
   a9c40:      	ushll	v5.2d, v5.2s, #0x0
   a9c44:      	str	q0, [x19, #0xb80]
   a9c48:      	str	q0, [x19, #0xb70]
   a9c4c:      	str	q0, [x19, #0xb60]
   a9c50:      	str	q0, [x19, #0xb50]
   a9c54:      	ucvtf	v5.2d, v5.2d
   a9c58:      	str	q0, [x19, #0x960]
   a9c5c:      	str	q0, [x19, #0x950]
   a9c60:      	str	q0, [x19, #0x940]
   a9c64:      	str	q0, [x19, #0x930]
   a9c68:      	str	q0, [x19, #0x920]
   a9c6c:      	str	q0, [x19, #0x910]
   a9c70:      	str	q0, [x19, #0x900]
   a9c74:      	str	q0, [x19, #0x8f0]
   a9c78:      	str	q0, [x19, #0x8e0]
   a9c7c:      	str	q0, [x19, #0x8d0]
   a9c80:      	str	q0, [x19, #0x8c0]
   a9c84:      	str	q0, [x19, #0x8b0]
   a9c88:      	str	q0, [x19, #0x8a0]
   a9c8c:      	str	q0, [x19, #0x890]
   a9c90:      	str	q0, [x19, #0x880]
   a9c94:      	str	q0, [x19, #0x690]
   a9c98:      	str	q0, [x19, #0x680]
   a9c9c:      	str	q0, [x19, #0x670]
   a9ca0:      	str	q0, [x19, #0x660]
   a9ca4:      	str	q0, [x19, #0x650]
   a9ca8:      	str	q0, [x19, #0x640]
   a9cac:      	str	q0, [x19, #0x630]
   a9cb0:      	str	q0, [x19, #0x620]
   a9cb4:      	str	q0, [x19, #0x610]
   a9cb8:      	str	q0, [x19, #0x600]
   a9cbc:      	str	q0, [x19, #0x5f0]
   a9cc0:      	str	q0, [x19, #0x5e0]
   a9cc4:      	str	q0, [x19, #0x5d0]
   a9cc8:      	str	q0, [x19, #0x5c0]
   a9ccc:      	mov	v6.s[1], w10
   a9cd0:      	str	q0, [x19, #0x5b0]
   a9cd4:      	fmov	s0, w11
   a9cd8:      	ldrh	w10, [x26, #0x20]
   a9cdc:      	ldrh	w11, [x26, #0x22]
   a9ce0:      	str	q1, [x19, #0xb50]
   a9ce4:      	str	q1, [x19, #0x880]
   a9ce8:      	mov	v0.s[1], w10
   a9cec:      	str	q1, [x19, #0x5b0]
   a9cf0:      	fmov	s1, w11
   a9cf4:      	ldrh	w10, [x26, #0x24]
   a9cf8:      	ldrh	w11, [x26, #0x26]
   a9cfc:      	str	q2, [x19, #0xb60]
   a9d00:      	str	q2, [x19, #0x890]
   a9d04:      	ushll	v6.2d, v6.2s, #0x0
   a9d08:      	mov	v1.s[1], w10
   a9d0c:      	str	q2, [x19, #0x5c0]
   a9d10:      	fmov	s2, w11
   a9d14:      	ldrh	w10, [x26, #0x28]
   a9d18:      	ldrh	w11, [x26, #0x2a]
   a9d1c:      	str	q3, [x19, #0xb70]
   a9d20:      	str	q3, [x19, #0x8a0]
   a9d24:      	ushll	v0.2d, v0.2s, #0x0
   a9d28:      	mov	v2.s[1], w10
   a9d2c:      	str	q3, [x19, #0x5d0]
   a9d30:      	fmov	s3, w11
   a9d34:      	ldrh	w10, [x26, #0x2c]
   a9d38:      	str	q4, [x19, #0xb80]
   a9d3c:      	ushll	v1.2d, v1.2s, #0x0
   a9d40:      	str	q4, [x19, #0x8b0]
   a9d44:      	ucvtf	v0.2d, v0.2d
   a9d48:      	str	q4, [x19, #0x5e0]
   a9d4c:      	ucvtf	v4.2d, v6.2d
   a9d50:      	mov	v3.s[1], w10
   a9d54:      	ldrh	w10, [x26, #0x2e]
   a9d58:      	ldrh	w11, [x26, #0x32]
   a9d5c:      	ushll	v2.2d, v2.2s, #0x0
   a9d60:      	ucvtf	v1.2d, v1.2d
   a9d64:      	str	q0, [x19, #0xbb0]
   a9d68:      	str	q4, [x19, #0xba0]
   a9d6c:      	str	q4, [x19, #0x8d0]
   a9d70:      	ushll	v3.2d, v3.2s, #0x0
   a9d74:      	str	q4, [x19, #0x600]
   a9d78:      	fmov	s4, w10
   a9d7c:      	ldrh	w10, [x26, #0x30]
   a9d80:      	str	q0, [x19, #0x8e0]
   a9d84:      	str	q0, [x19, #0x610]
   a9d88:      	fmov	s0, w11
   a9d8c:      	ldrh	w11, [x26, #0x34]
   a9d90:      	ucvtf	v2.2d, v2.2d
   a9d94:      	mov	v4.s[1], w10
   a9d98:      	ldrh	w10, [x26, #0x36]
   a9d9c:      	str	q1, [x19, #0xbc0]
   a9da0:      	ucvtf	v3.2d, v3.2d
   a9da4:      	str	q1, [x19, #0x8f0]
   a9da8:      	str	q1, [x19, #0x620]
   a9dac:      	fmov	s1, w10
   a9db0:      	ldrh	w10, [x26, #0x38]
   a9db4:      	str	q2, [x19, #0xbd0]
   a9db8:      	mov	v0.s[1], w11
   a9dbc:      	ldrh	w11, [x26, #0x3a]
   a9dc0:      	str	q2, [x19, #0x900]
   a9dc4:      	str	q2, [x19, #0x630]
   a9dc8:      	ushll	v2.2d, v4.2s, #0x0
   a9dcc:      	mov	v1.s[1], w10
   a9dd0:      	fmov	s4, w11
   a9dd4:      	ldrh	w10, [x26, #0x3c]
   a9dd8:      	ushll	v0.2d, v0.2s, #0x0
   a9ddc:      	ldrh	w11, [x26, #0x3e]
   a9de0:      	str	q5, [x19, #0xb90]
   a9de4:      	str	q5, [x19, #0x8c0]
   a9de8:      	ucvtf	v2.2d, v2.2d
   a9dec:      	mov	v4.s[1], w10
   a9df0:      	str	q5, [x19, #0x5f0]
   a9df4:      	fmov	s5, w11
   a9df8:      	ldrh	w10, [x26, #0x40]
   a9dfc:      	str	q3, [x19, #0xbe0]
   a9e00:      	ushll	v1.2d, v1.2s, #0x0
   a9e04:      	str	q3, [x19, #0x910]
   a9e08:      	ucvtf	v0.2d, v0.2d
   a9e0c:      	str	q3, [x19, #0x640]
   a9e10:      	ushll	v3.2d, v4.2s, #0x0
   a9e14:      	mov	v5.s[1], w10
   a9e18:      	str	q2, [x19, #0xbf0]
   a9e1c:      	str	q2, [x19, #0x920]
   a9e20:      	ucvtf	v1.2d, v1.2d
   a9e24:      	str	q2, [x19, #0x650]
   a9e28:      	add	x10, sp, #0xf80
   a9e2c:      	str	q0, [x19, #0xc00]
   a9e30:      	mov	x11, #-0x8000000000000000 // =-9223372036854775808
   a9e34:      	str	q0, [x19, #0x930]
   a9e38:      	ushll	v2.2d, v5.2s, #0x0
   a9e3c:      	str	q0, [x19, #0x660]
   a9e40:      	ucvtf	v0.2d, v3.2d
   a9e44:      	str	q1, [x19, #0xc10]
   a9e48:      	str	q1, [x19, #0x940]
   a9e4c:      	str	q1, [x19, #0x670]
   a9e50:      	ucvtf	v1.2d, v2.2d
   a9e54:      	str	q0, [x19, #0xc20]
   a9e58:      	str	q0, [x19, #0x950]
   a9e5c:      	str	q0, [x19, #0x680]
   a9e60:      	movi	d0, #0000000000000000
   a9e64:      	str	q1, [x19, #0xc30]
   a9e68:      	str	q1, [x19, #0x960]
   a9e6c:      	str	q1, [x19, #0x690]
   a9e70:      	ldr	d1, [x10, x9]
   a9e74:      	fmov	d2, x11
   a9e78:      	add	x9, x9, #0x8
   a9e7c:      	fcmp	d1, d1
   a9e80:      	fcsel	d1, d1, d2, vc
   a9e84:      	cinc	w8, w8, vc
   a9e88:      	cmp	x9, #0xf0
   a9e8c:      	fadd	d0, d0, d1
   a9e90:      	b.ne	0xa9e70 <air1_opcal5_algorithm+0x128c>
   a9e94:      	and	w8, w8, #0xffff
   a9e98:      	movi	d2, #0000000000000000
   a9e9c:      	ldr	d3, [x19, #0xb58]
   a9ea0:      	mov	w28, wzr
   a9ea4:      	add	x9, sp, #0xf80
   a9ea8:      	ucvtf	d1, w8
   a9eac:      	mov	w8, #0x1                // =1
   a9eb0:      	fdiv	d0, d0, d1
   a9eb4:      	ldr	d1, [x19, #0xb50]
   a9eb8:      	fsub	d1, d1, d0
   a9ebc:      	fmadd	d1, d1, d1, d2
   a9ec0:      	fsub	d2, d3, d0
   a9ec4:      	ldr	d3, [x19, #0xb60]
   a9ec8:      	fmadd	d1, d2, d2, d1
   a9ecc:      	fsub	d2, d3, d0
   a9ed0:      	ldr	d3, [x19, #0xb68]
   a9ed4:      	fmadd	d1, d2, d2, d1
   a9ed8:      	fsub	d2, d3, d0
   a9edc:      	ldr	d3, [x19, #0xb70]
   a9ee0:      	fmadd	d1, d2, d2, d1
   a9ee4:      	fsub	d2, d3, d0
   a9ee8:      	ldr	d3, [x19, #0xb78]
   a9eec:      	fmadd	d1, d2, d2, d1
   a9ef0:      	fsub	d2, d3, d0
   a9ef4:      	ldr	d3, [x19, #0xb80]
   a9ef8:      	fmadd	d1, d2, d2, d1
   a9efc:      	fsub	d2, d3, d0
   a9f00:      	ldr	d3, [x19, #0xb88]
   a9f04:      	fmadd	d1, d2, d2, d1
   a9f08:      	fsub	d2, d3, d0
   a9f0c:      	ldr	d3, [x19, #0xb90]
   a9f10:      	fmadd	d1, d2, d2, d1
   a9f14:      	fsub	d2, d3, d0
   a9f18:      	ldr	d3, [x19, #0xb98]
   a9f1c:      	fmadd	d1, d2, d2, d1
   a9f20:      	fsub	d2, d3, d0
   a9f24:      	ldr	d3, [x19, #0xba0]
   a9f28:      	fmadd	d1, d2, d2, d1
   a9f2c:      	fsub	d2, d3, d0
   a9f30:      	ldr	d3, [x19, #0xba8]
   a9f34:      	fmadd	d1, d2, d2, d1
   a9f38:      	fsub	d2, d3, d0
   a9f3c:      	ldr	d3, [x19, #0xbb0]
   a9f40:      	fmadd	d1, d2, d2, d1
   a9f44:      	fsub	d2, d3, d0
   a9f48:      	ldr	d3, [x19, #0xbb8]
   a9f4c:      	fmadd	d1, d2, d2, d1
   a9f50:      	fsub	d2, d3, d0
   a9f54:      	ldr	d3, [x19, #0xbc0]
   a9f58:      	fmadd	d1, d2, d2, d1
   a9f5c:      	fsub	d2, d3, d0
   a9f60:      	ldr	d3, [x19, #0xbc8]
   a9f64:      	fmadd	d1, d2, d2, d1
   a9f68:      	fsub	d2, d3, d0
   a9f6c:      	ldr	d3, [x19, #0xbd0]
   a9f70:      	fmadd	d1, d2, d2, d1
   a9f74:      	fsub	d2, d3, d0
   a9f78:      	ldr	d3, [x19, #0xbd8]
   a9f7c:      	fmadd	d1, d2, d2, d1
   a9f80:      	fsub	d2, d3, d0
   a9f84:      	ldr	d3, [x19, #0xbe0]
   a9f88:      	fmadd	d1, d2, d2, d1
   a9f8c:      	fsub	d2, d3, d0
   a9f90:      	ldr	d3, [x19, #0xbe8]
   a9f94:      	fmadd	d1, d2, d2, d1
   a9f98:      	fsub	d2, d3, d0
   a9f9c:      	ldr	d3, [x19, #0xbf0]
   a9fa0:      	fmadd	d1, d2, d2, d1
   a9fa4:      	fsub	d2, d3, d0
   a9fa8:      	ldr	d3, [x19, #0xbf8]
   a9fac:      	fmadd	d1, d2, d2, d1
   a9fb0:      	fsub	d2, d3, d0
   a9fb4:      	ldr	d3, [x19, #0xc00]
   a9fb8:      	fmadd	d1, d2, d2, d1
   a9fbc:      	fsub	d2, d3, d0
   a9fc0:      	ldr	d3, [x19, #0xc08]
   a9fc4:      	fmadd	d1, d2, d2, d1
   a9fc8:      	fsub	d2, d3, d0
   a9fcc:      	ldr	d3, [x19, #0xc10]
   a9fd0:      	fmadd	d1, d2, d2, d1
   a9fd4:      	fsub	d2, d3, d0
   a9fd8:      	ldr	d3, [x19, #0xc18]
   a9fdc:      	fmadd	d1, d2, d2, d1
   a9fe0:      	fsub	d2, d3, d0
   a9fe4:      	ldr	d3, [x19, #0xc20]
   a9fe8:      	fmadd	d1, d2, d2, d1
   a9fec:      	fsub	d2, d3, d0
   a9ff0:      	ldr	d3, [x19, #0xc28]
   a9ff4:      	fmadd	d1, d2, d2, d1
   a9ff8:      	fsub	d2, d3, d0
   a9ffc:      	ldr	d3, [x19, #0xc30]
   aa000:      	fmadd	d1, d2, d2, d1
   aa004:      	fsub	d2, d3, d0
   aa008:      	ldr	d3, [x19, #0xc38]
   aa00c:      	fmadd	d1, d2, d2, d1
   aa010:      	fsub	d0, d3, d0
   aa014:      	fmadd	d9, d0, d0, d1
   aa018:      	and	x10, x28, #0xff
   aa01c:      	ldr	d0, [x9, x8, lsl #3]
   aa020:      	ldr	d1, [x9, x10, lsl #3]
   aa024:      	fcmp	d0, d1
   aa028:      	csel	w28, w8, w28, gt
   aa02c:      	add	x8, x8, #0x1
   aa030:      	cmp	x8, #0x1e
   aa034:      	b.ne	0xaa018 <air1_opcal5_algorithm+0x1434>
   aa038:      	mov	w9, wzr
   aa03c:      	mov	w8, #0x1                // =1
   aa040:      	add	x10, sp, #0xf80
   aa044:      	str	w12, [sp, #0x3c0]
   aa048:      	str	q17, [sp, #0x3f0]
   aa04c:      	and	x11, x9, #0xff
   aa050:      	ldr	d0, [x10, x8, lsl #3]
   aa054:      	ldr	d1, [x10, x11, lsl #3]
   aa058:      	fcmp	d0, d1
   aa05c:      	csel	w9, w8, w9, mi
   aa060:      	add	x8, x8, #0x1
   aa064:      	cmp	x8, #0x1e
   aa068:      	b.ne	0xaa04c <air1_opcal5_algorithm+0x1468>
   aa06c:      	mov	w8, w28
   aa070:      	movi	d10, #0000000000000000
   aa074:      	and	x21, x8, #0xff
   aa078:      	add	x8, sp, #0xf80
   aa07c:      	movi	d0, #0000000000000000
   aa080:      	str	x27, [sp, #0x390]
   aa084:      	str	x0, [sp, #0x228]
   aa088:      	ldr	d8, [x8, x21, lsl #3]
   aa08c:      	and	w8, w28, #0xff
   aa090:      	cmp	w8, #0x1
   aa094:      	str	x1, [sp, #0x220]
   aa098:      	str	x2, [sp, #0x398]
   aa09c:      	str	x3, [sp, #0x3d0]
   aa0a0:      	str	x4, [sp, #0x218]
   aa0a4:      	str	x5, [sp, #0x3c8]
   aa0a8:      	str	x6, [sp, #0x98]
   aa0ac:      	str	x7, [sp, #0x210]
   aa0b0:      	b.hi	0xaa520 <air1_opcal5_algorithm+0x193c>
   aa0b4:      	and	w10, w9, #0xff
   aa0b8:      	cmp	w10, #0x1d
   aa0bc:      	b.hi	0xaa150 <air1_opcal5_algorithm+0x156c>
   aa0c0:      	b.eq	0xaa148 <air1_opcal5_algorithm+0x1564>
   aa0c4:      	and	x13, x9, #0xff
   aa0c8:      	cmp	x13, #0x1c
   aa0cc:      	mov	w9, #0x1c               // =28
   aa0d0:      	csel	x9, x13, x9, hi
   aa0d4:      	sub	x10, x9, x13
   aa0d8:      	add	x11, x10, #0x1
   aa0dc:      	mov	x10, x13
   aa0e0:      	cmp	x11, #0x4
   aa0e4:      	b.lo	0xaa120 <air1_opcal5_algorithm+0x153c>
   aa0e8:      	and	x12, x11, #0xfffffffffffffffc
   aa0ec:      	add	x14, sp, #0x9e0
   aa0f0:      	add	x10, x12, x13
   aa0f4:      	add	x13, x14, x13, lsl #3
   aa0f8:      	add	x13, x13, #0x10
   aa0fc:      	mov	x14, x12
   aa100:      	ldur	q0, [x13, #-0x8]
   aa104:      	subs	x14, x14, #0x4
   aa108:      	ldur	q1, [x13, #0x8]
   aa10c:      	stp	q0, q1, [x13, #-0x10]
   aa110:      	add	x13, x13, #0x20
   aa114:      	b.ne	0xaa100 <air1_opcal5_algorithm+0x151c>
   aa118:      	cmp	x11, x12
   aa11c:      	b.eq	0xaa148 <air1_opcal5_algorithm+0x1564>
   aa120:      	add	x11, sp, #0x9e0
   aa124:      	sub	x9, x9, x10
   aa128:      	add	x10, x11, x10, lsl #3
   aa12c:      	add	x9, x9, #0x1
   aa130:      	add	x10, x10, #0x8
   aa134:      	ldr	d0, [x10]
   aa138:      	subs	x9, x9, #0x1
   aa13c:      	stur	d0, [x10, #-0x8]
   aa140:      	add	x10, x10, #0x8
   aa144:      	b.ne	0xaa134 <air1_opcal5_algorithm+0x1550>
   aa148:      	mov	w9, #0x1d               // =29
   aa14c:      	b	0xaa154 <air1_opcal5_algorithm+0x1570>
   aa150:      	mov	w9, #0x1e               // =30
   aa154:      	mov	w9, w9
   aa158:      	movi	d0, #0000000000000000
   aa15c:      	mov	w10, wzr
   aa160:      	add	x11, sp, #0x9e0
   aa164:      	mov	x12, #-0x8000000000000000 // =-9223372036854775808
   aa168:      	mov	x13, x9
   aa16c:      	ldr	d1, [x11], #0x8
   aa170:      	fmov	d2, x12
   aa174:      	fcmp	d1, d1
   aa178:      	fcsel	d1, d1, d2, vc
   aa17c:      	cinc	w10, w10, vc
   aa180:      	subs	x13, x13, #0x1
   aa184:      	fadd	d0, d0, d1
   aa188:      	b.ne	0xaa16c <air1_opcal5_algorithm+0x1588>
   aa18c:      	and	w10, w10, #0xffff
   aa190:      	mov	x11, x9
   aa194:      	ucvtf	d1, w10
   aa198:      	add	x10, sp, #0x9e0
   aa19c:      	fdiv	d1, d0, d1
   aa1a0:      	movi	d0, #0000000000000000
   aa1a4:      	ldr	d2, [x10], #0x8
   aa1a8:      	subs	x11, x11, #0x1
   aa1ac:      	fsub	d2, d2, d1
   aa1b0:      	fmadd	d0, d2, d2, d0
   aa1b4:      	b.ne	0xaa1a4 <air1_opcal5_algorithm+0x15c0>
   aa1b8:      	sub	w9, w9, #0x1
   aa1bc:      	tst	w28, #0xff
   aa1c0:      	scvtf	d1, w9
   aa1c4:      	fdiv	d0, d0, d1
   aa1c8:      	fsqrt	d10, d0
   aa1cc:      	b.eq	0xaa28c <air1_opcal5_algorithm+0x16a8>
   aa1d0:      	mov	w9, w28
   aa1d4:      	add	w10, w8, #0x1
   aa1d8:      	and	x9, x9, #0xff
   aa1dc:      	add	x11, sp, #0xcb0
   aa1e0:      	sub	x9, x9, #0x1
   aa1e4:      	ldr	d0, [x11, w10, uxtw #3]
   aa1e8:      	ldr	d1, [x11, x9, lsl #3]
   aa1ec:      	fcmp	d0, d1
   aa1f0:      	b.le	0xaa2c0 <air1_opcal5_algorithm+0x16dc>
   aa1f4:      	and	w9, w28, #0xff
   aa1f8:      	cmp	w9, #0x1d
   aa1fc:      	b.hi	0xaa2ec <air1_opcal5_algorithm+0x1708>
   aa200:      	b.eq	0xaa284 <air1_opcal5_algorithm+0x16a0>
   aa204:      	cmp	x21, #0x1c
   aa208:      	mov	w9, #0x1c               // =28
   aa20c:      	csel	x9, x21, x9, hi
   aa210:      	sub	x10, x9, x21
   aa214:      	add	x11, x10, #0x1
   aa218:      	mov	x10, x21
   aa21c:      	cmp	x11, #0x4
   aa220:      	b.lo	0xaa25c <air1_opcal5_algorithm+0x1678>
   aa224:      	add	x13, sp, #0xcb0
   aa228:      	and	x12, x11, #0xfffffffffffffffc
   aa22c:      	add	x13, x13, x21, lsl #3
   aa230:      	add	x10, x12, x21
   aa234:      	add	x13, x13, #0x10
   aa238:      	mov	x14, x12
   aa23c:      	ldur	q0, [x13, #-0x8]
   aa240:      	subs	x14, x14, #0x4
   aa244:      	ldur	q1, [x13, #0x8]
   aa248:      	stp	q0, q1, [x13, #-0x10]
   aa24c:      	add	x13, x13, #0x20
   aa250:      	b.ne	0xaa23c <air1_opcal5_algorithm+0x1658>
   aa254:      	cmp	x11, x12
   aa258:      	b.eq	0xaa284 <air1_opcal5_algorithm+0x16a0>
   aa25c:      	add	x11, sp, #0xcb0
   aa260:      	sub	x9, x9, x10
   aa264:      	add	x10, x11, x10, lsl #3
   aa268:      	add	x9, x9, #0x1
   aa26c:      	add	x10, x10, #0x8
   aa270:      	ldr	d0, [x10]
   aa274:      	subs	x9, x9, #0x1
   aa278:      	stur	d0, [x10, #-0x8]
   aa27c:      	add	x10, x10, #0x8
   aa280:      	b.ne	0xaa270 <air1_opcal5_algorithm+0x168c>
   aa284:      	mov	w10, #0x1d              // =29
   aa288:      	b	0xaa2f0 <air1_opcal5_algorithm+0x170c>
   aa28c:      	add	x8, sp, #0xcb0
   aa290:      	add	x0, sp, #0xcb0
   aa294:      	orr	x27, x8, #0x8
   aa298:      	mov	w2, #0xe8               // =232
   aa29c:      	mov	x1, x27
   aa2a0:      	bl	0xbf050 <memmove@plt>
   aa2a4:      	add	x0, sp, #0xcb0
   aa2a8:      	mov	x1, x27
   aa2ac:      	mov	w2, #0xe0               // =224
   aa2b0:      	bl	0xbf050 <memmove@plt>
   aa2b4:      	mov	w8, #0x1c               // =28
   aa2b8:      	mov	w9, #0x1c               // =28
   aa2bc:      	b	0xaa4b4 <air1_opcal5_algorithm+0x18d0>
   aa2c0:      	cmp	w9, #0x1d
   aa2c4:      	b.hi	0xaa384 <air1_opcal5_algorithm+0x17a0>
   aa2c8:      	and	w12, w9, #0xffff
   aa2cc:      	cmp	w12, #0x1c
   aa2d0:      	b.hi	0xaa38c <air1_opcal5_algorithm+0x17a8>
   aa2d4:      	mov	w8, #0x1d               // =29
   aa2d8:      	sub	x10, x8, x12
   aa2dc:      	cmp	x10, #0x4
   aa2e0:      	b.hs	0xaa394 <air1_opcal5_algorithm+0x17b0>
   aa2e4:      	mov	x8, x12
   aa2e8:      	b	0xaa3cc <air1_opcal5_algorithm+0x17e8>
   aa2ec:      	mov	w10, #0x1e              // =30
   aa2f0:      	cmp	w10, w28, uxtb
   aa2f4:      	b.ls	0xaa48c <air1_opcal5_algorithm+0x18a8>
   aa2f8:      	sub	w9, w10, #0x1
   aa2fc:      	cmp	w9, w8
   aa300:      	b.ls	0xaa37c <air1_opcal5_algorithm+0x1798>
   aa304:      	mov	w8, w10
   aa308:      	add	x10, x21, #0x1
   aa30c:      	sub	x8, x8, #0x1
   aa310:      	cmp	x8, x10
   aa314:      	csinc	x10, x8, x21, hi
   aa318:      	sub	x11, x10, x21
   aa31c:      	mov	x10, x21
   aa320:      	cmp	x11, #0x2
   aa324:      	b.lo	0xaa35c <air1_opcal5_algorithm+0x1778>
   aa328:      	add	x13, sp, #0xcb0
   aa32c:      	and	x12, x11, #0xfffffffffffffffe
   aa330:      	add	x13, x13, x21, lsl #3
   aa334:      	add	x10, x12, x21
   aa338:      	add	x13, x13, #0x8
   aa33c:      	mov	x14, x12
   aa340:      	ldr	q0, [x13]
   aa344:      	subs	x14, x14, #0x2
   aa348:      	stur	q0, [x13, #-0x8]
   aa34c:      	add	x13, x13, #0x10
   aa350:      	b.ne	0xaa340 <air1_opcal5_algorithm+0x175c>
   aa354:      	cmp	x11, x12
   aa358:      	b.eq	0xaa37c <air1_opcal5_algorithm+0x1798>
   aa35c:      	add	x11, sp, #0xcb0
   aa360:      	add	x12, x11, x10, lsl #3
   aa364:      	add	x13, x10, #0x1
   aa368:      	mov	x10, x13
   aa36c:      	cmp	x13, x8
   aa370:      	ldr	d0, [x12, #0x8]
   aa374:      	str	d0, [x12]
   aa378:      	b.lo	0xaa360 <air1_opcal5_algorithm+0x177c>
   aa37c:      	mov	w10, w9
   aa380:      	b	0xaa48c <air1_opcal5_algorithm+0x18a8>
   aa384:      	mov	w10, #0x1e              // =30
   aa388:      	b	0xaa3f4 <air1_opcal5_algorithm+0x1810>
   aa38c:      	mov	w10, #0x1d              // =29
   aa390:      	b	0xaa3f4 <air1_opcal5_algorithm+0x1810>
   aa394:      	and	x11, x10, #0xfffffffffffffffc
   aa398:      	add	x13, sp, #0xcb0
   aa39c:      	add	x8, x11, x12
   aa3a0:      	add	x12, x13, x12, lsl #3
   aa3a4:      	add	x12, x12, #0x10
   aa3a8:      	mov	x13, x11
   aa3ac:      	ldur	q0, [x12, #-0x8]
   aa3b0:      	subs	x13, x13, #0x4
   aa3b4:      	ldur	q1, [x12, #0x8]
   aa3b8:      	stp	q0, q1, [x12, #-0x10]
   aa3bc:      	add	x12, x12, #0x20
   aa3c0:      	b.ne	0xaa3ac <air1_opcal5_algorithm+0x17c8>
   aa3c4:      	cmp	x10, x11
   aa3c8:      	b.eq	0xaa3ec <air1_opcal5_algorithm+0x1808>
   aa3cc:      	add	x10, sp, #0xcb0
   aa3d0:      	add	x11, x10, x8, lsl #3
   aa3d4:      	add	x12, x8, #0x1
   aa3d8:      	mov	x8, x12
   aa3dc:      	cmp	x12, #0x1d
   aa3e0:      	ldr	d0, [x11, #0x8]
   aa3e4:      	str	d0, [x11]
   aa3e8:      	b.ne	0xaa3d0 <air1_opcal5_algorithm+0x17ec>
   aa3ec:      	mov	w10, #0x1d              // =29
   aa3f0:      	add	x19, sp, #0x430
   aa3f4:      	cmp	w10, w9
   aa3f8:      	b.ls	0xaa48c <air1_opcal5_algorithm+0x18a8>
   aa3fc:      	and	w13, w9, #0xffff
   aa400:      	sub	w8, w10, #0x1
   aa404:      	cmp	w8, w13
   aa408:      	b.ls	0xaa488 <air1_opcal5_algorithm+0x18a4>
   aa40c:      	mov	w9, w10
   aa410:      	add	x10, x13, #0x1
   aa414:      	sub	x9, x9, #0x1
   aa418:      	cmp	x9, x10
   aa41c:      	csinc	x10, x9, x13, hi
   aa420:      	sub	x11, x10, x13
   aa424:      	cmp	x11, #0x2
   aa428:      	b.hs	0xaa434 <air1_opcal5_algorithm+0x1850>
   aa42c:      	mov	x10, x13
   aa430:      	b	0xaa468 <air1_opcal5_algorithm+0x1884>
   aa434:      	and	x12, x11, #0xfffffffffffffffe
   aa438:      	add	x14, sp, #0xcb0
   aa43c:      	add	x10, x12, x13
   aa440:      	add	x13, x14, x13, lsl #3
   aa444:      	add	x13, x13, #0x8
   aa448:      	mov	x14, x12
   aa44c:      	ldr	q0, [x13]
   aa450:      	subs	x14, x14, #0x2
   aa454:      	stur	q0, [x13, #-0x8]
   aa458:      	add	x13, x13, #0x10
   aa45c:      	b.ne	0xaa44c <air1_opcal5_algorithm+0x1868>
   aa460:      	cmp	x11, x12
   aa464:      	b.eq	0xaa488 <air1_opcal5_algorithm+0x18a4>
   aa468:      	add	x11, sp, #0xcb0
   aa46c:      	add	x12, x11, x10, lsl #3
   aa470:      	add	x13, x10, #0x1
   aa474:      	mov	x10, x13
   aa478:      	cmp	x13, x9
   aa47c:      	ldr	d0, [x12, #0x8]
   aa480:      	str	d0, [x12]
   aa484:      	b.lo	0xaa46c <air1_opcal5_algorithm+0x1888>
   aa488:      	mov	w10, w8
   aa48c:      	cbz	w10, 0xaa4a4 <air1_opcal5_algorithm+0x18c0>
   aa490:      	and	w8, w10, #0xff
   aa494:      	cmp	w8, #0x1
   aa498:      	b.ne	0xaa4b0 <air1_opcal5_algorithm+0x18cc>
   aa49c:      	movi	d0, #0000000000000000
   aa4a0:      	b	0xaa520 <air1_opcal5_algorithm+0x193c>
   aa4a4:      	mov	x8, #0x7ff8000000000000 // =9221120237041090560
   aa4a8:      	fmov	d0, x8
   aa4ac:      	b	0xaa520 <air1_opcal5_algorithm+0x193c>
   aa4b0:      	and	x9, x10, #0xff
   aa4b4:      	movi	d0, #0000000000000000
   aa4b8:      	mov	w10, wzr
   aa4bc:      	add	x11, sp, #0xcb0
   aa4c0:      	mov	x12, #-0x8000000000000000 // =-9223372036854775808
   aa4c4:      	mov	x13, x9
   aa4c8:      	ldr	d1, [x11], #0x8
   aa4cc:      	fmov	d2, x12
   aa4d0:      	fcmp	d1, d1
   aa4d4:      	fcsel	d1, d1, d2, vc
   aa4d8:      	cinc	w10, w10, vc
   aa4dc:      	subs	x13, x13, #0x1
   aa4e0:      	fadd	d0, d0, d1
   aa4e4:      	b.ne	0xaa4c8 <air1_opcal5_algorithm+0x18e4>
   aa4e8:      	and	w10, w10, #0xffff
   aa4ec:      	ucvtf	d1, w10
   aa4f0:      	add	x10, sp, #0xcb0
   aa4f4:      	fdiv	d1, d0, d1
   aa4f8:      	movi	d0, #0000000000000000
   aa4fc:      	ldr	d2, [x10], #0x8
   aa500:      	subs	x9, x9, #0x1
   aa504:      	fsub	d2, d2, d1
   aa508:      	fmadd	d0, d2, d2, d0
   aa50c:      	b.ne	0xaa4fc <air1_opcal5_algorithm+0x1918>
   aa510:      	sub	w8, w8, #0x1
   aa514:      	scvtf	d1, w8
   aa518:      	fdiv	d0, d0, d1
   aa51c:      	fsqrt	d0, d0
   aa520:      	ldrh	w8, [x22, #0x1cc]
   aa524:      	cmp	w25, w8
   aa528:      	b.ls	0xaa780 <air1_opcal5_algorithm+0x1b9c>
   aa52c:      	cbz	w8, 0xaa780 <air1_opcal5_algorithm+0x1b9c>
   aa530:      	and	w8, w28, #0xff
   aa534:      	cmp	w8, #0x1
   aa538:      	b.hi	0xaa780 <air1_opcal5_algorithm+0x1b9c>
   aa53c:      	fmov	d1, #29.00000000
   aa540:      	ldr	q2, [x19, #0xc00]
   aa544:      	ldr	q3, [x19, #0xc10]
   aa548:      	mov	w8, #0x1d               // =29
   aa54c:      	ldr	q4, [x19, #0xc20]
   aa550:      	sub	x8, x8, x21
   aa554:      	fdiv	d1, d9, d1
   aa558:      	str	q2, [x19, #0x930]
   aa55c:      	ldr	q2, [x19, #0xc30]
   aa560:      	str	q3, [x19, #0x940]
   aa564:      	ldr	q3, [x19, #0xbc0]
   aa568:      	str	q4, [x19, #0x950]
   aa56c:      	ldr	q4, [x19, #0xbd0]
   aa570:      	cmp	x8, #0x2
   aa574:      	str	q2, [x19, #0x960]
   aa578:      	ldr	q2, [x19, #0xbe0]
   aa57c:      	str	q3, [x19, #0x8f0]
   aa580:      	ldr	q3, [x19, #0xbf0]
   aa584:      	str	q4, [x19, #0x900]
   aa588:      	ldr	q4, [x19, #0xb80]
   aa58c:      	str	q2, [x19, #0x910]
   aa590:      	ldr	q2, [x19, #0xb90]
   aa594:      	str	q3, [x19, #0x920]
   aa598:      	ldr	q3, [x19, #0xba0]
   aa59c:      	str	q4, [x19, #0x8b0]
   aa5a0:      	ldr	q4, [x19, #0xbb0]
   aa5a4:      	str	q2, [x19, #0x8c0]
   aa5a8:      	ldr	q2, [x19, #0xb50]
   aa5ac:      	str	q3, [x19, #0x8d0]
   aa5b0:      	ldr	q3, [x19, #0xb60]
   aa5b4:      	str	q4, [x19, #0x8e0]
   aa5b8:      	ldr	q4, [x19, #0xb70]
   aa5bc:      	str	q2, [x19, #0x880]
   aa5c0:      	str	q3, [x19, #0x890]
   aa5c4:      	str	q4, [x19, #0x8a0]
   aa5c8:      	b.lo	0xaa604 <air1_opcal5_algorithm+0x1a20>
   aa5cc:      	add	x11, sp, #0xcb0
   aa5d0:      	and	x9, x8, #0xfffffffffffffffe
   aa5d4:      	add	x11, x11, x21, lsl #3
   aa5d8:      	add	x10, x9, x21
   aa5dc:      	add	x11, x11, #0x8
   aa5e0:      	mov	x12, x9
   aa5e4:      	ldr	q2, [x11]
   aa5e8:      	subs	x12, x12, #0x2
   aa5ec:      	stur	q2, [x11, #-0x8]
   aa5f0:      	add	x11, x11, #0x10
   aa5f4:      	b.ne	0xaa5e4 <air1_opcal5_algorithm+0x1a00>
   aa5f8:      	mov	x21, x10
   aa5fc:      	cmp	x8, x9
   aa600:      	b.eq	0xaa624 <air1_opcal5_algorithm+0x1a40>
   aa604:      	add	x8, sp, #0xcb0
   aa608:      	add	x9, x8, x21, lsl #3
   aa60c:      	add	x10, x21, #0x1
   aa610:      	mov	x21, x10
   aa614:      	cmp	x10, #0x1d
   aa618:      	ldr	d2, [x9, #0x8]
   aa61c:      	str	d2, [x9]
   aa620:      	b.ne	0xaa608 <air1_opcal5_algorithm+0x1a24>
   aa624:      	fsqrt	d1, d1
   aa628:      	movi	d2, #0000000000000000
   aa62c:      	mov	x8, xzr
   aa630:      	mov	w10, wzr
   aa634:      	add	x9, sp, #0xcb0
   aa638:      	mov	x11, #-0x8000000000000000 // =-9223372036854775808
   aa63c:      	ldr	d3, [x9, x8]
   aa640:      	fmov	d4, x11
   aa644:      	add	x8, x8, #0x8
   aa648:      	fcmp	d3, d3
   aa64c:      	fcsel	d3, d3, d4, vc
   aa650:      	cinc	w10, w10, vc
   aa654:      	cmp	x8, #0xe8
   aa658:      	fadd	d2, d2, d3
   aa65c:      	b.ne	0xaa63c <air1_opcal5_algorithm+0x1a58>
   aa660:      	and	w10, w10, #0xffff
   aa664:      	mov	x9, xzr
   aa668:      	mov	w8, wzr
   aa66c:      	mov	x11, #-0x8000000000000000 // =-9223372036854775808
   aa670:      	ucvtf	d3, w10
   aa674:      	add	x10, sp, #0xcb0
   aa678:      	fdiv	d2, d2, d3
   aa67c:      	movi	d3, #0000000000000000
   aa680:      	fsub	d2, d8, d2
   aa684:      	ldr	d4, [x10, x9]
   aa688:      	fmov	d5, x11
   aa68c:      	add	x9, x9, #0x8
   aa690:      	fcmp	d4, d4
   aa694:      	fcsel	d4, d4, d5, vc
   aa698:      	cinc	w8, w8, vc
   aa69c:      	cmp	x9, #0xe8
   aa6a0:      	fadd	d3, d3, d4
   aa6a4:      	b.ne	0xaa684 <air1_opcal5_algorithm+0x1aa0>
   aa6a8:      	and	w8, w8, #0xffff
   aa6ac:      	fcmp	d2, #0.0
   aa6b0:      	ucvtf	d4, w8
   aa6b4:      	adrp	x8, 0xe9000 <g_algo+0x330>
   aa6b8:      	fdiv	d3, d3, d4
   aa6bc:      	fneg	d4, d2
   aa6c0:      	fcsel	d2, d4, d2, mi
   aa6c4:      	fdiv	d2, d2, d3
   aa6c8:      	ldr	d3, [x8, #0x6d8]
   aa6cc:      	fcmp	d2, d3
   aa6d0:      	b.le	0xaa780 <air1_opcal5_algorithm+0x1b9c>
   aa6d4:      	fsub	d2, d1, d0
   aa6d8:      	adrp	x8, 0xe9000 <g_algo+0x330>
   aa6dc:      	fneg	d3, d2
   aa6e0:      	fcmp	d2, #0.0
   aa6e4:      	fcsel	d2, d3, d2, mi
   aa6e8:      	fdiv	d0, d2, d0
   aa6ec:      	ldr	d2, [x8, #0x6c8]
   aa6f0:      	fcmp	d0, d2
   aa6f4:      	b.le	0xaa780 <air1_opcal5_algorithm+0x1b9c>
   aa6f8:      	fsub	d0, d1, d10
   aa6fc:      	adrp	x8, 0xe9000 <g_algo+0x330>
   aa700:      	fneg	d1, d0
   aa704:      	fcmp	d0, #0.0
   aa708:      	fcsel	d0, d1, d0, mi
   aa70c:      	ldr	d1, [x8, #0x6d0]
   aa710:      	fdiv	d0, d0, d10
   aa714:      	fcmp	d0, d1
   aa718:      	b.pl	0xaa780 <air1_opcal5_algorithm+0x1b9c>
   aa71c:      	adrp	x11, 0xe8000 <quick_sel_arr+0x1810>
   aa720:      	mov	w8, #0x1                // =1
   aa724:      	mov	w9, #0x2                // =2
   aa728:      	adrp	x10, 0xe8000 <quick_sel_arr+0x1810>
   aa72c:      	add	x11, x11, #0x610
   aa730:      	ldr	w12, [sp, #0x3c0]
   aa734:      	strb	w8, [x10, #0x608]
   aa738:      	add	x10, x11, #0x8
   aa73c:      	strb	w9, [x11, #0x9a]
   aa740:      	ldrh	w8, [x22, #0x58]
   aa744:      	strb	wzr, [x11, #0x54]
   aa748:      	str	w24, [x11, #0x4]
   aa74c:      	strh	w12, [x11]
   aa750:      	add	w9, w8, w12
   aa754:      	add	x8, x26, #0x42
   aa758:      	cmp	x8, x10
   aa75c:      	strh	w9, [x11, #0x2]
   aa760:      	b.ls	0xb06dc <air1_opcal5_algorithm+0x7af8>
   aa764:      	adrp	x10, 0xe8000 <quick_sel_arr+0x1810>
   aa768:      	add	x8, x26, #0x6
   aa76c:      	add	x10, x10, #0x654
   aa770:      	cmp	x8, x10
   aa774:      	b.hs	0xb06dc <air1_opcal5_algorithm+0x7af8>
   aa778:      	mov	x8, xzr
   aa77c:      	b	0xb0700 <air1_opcal5_algorithm+0x7b1c>
   aa780:      	movi	v0.2d, #0000000000000000
   aa784:      	add	x0, sp, #0xf80
   aa788:      	mov	w1, wzr
   aa78c:      	mov	w2, #0x2d0              // =720
   aa790:      	str	xzr, [x19, #0x2d0]
   aa794:      	ldr	w25, [x22, #0xc]
   aa798:      	str	xzr, [x19, #0x250]
   aa79c:      	ldur	d9, [x26, #0x42]
   aa7a0:      	stp	q0, q0, [x19, #0x2b0]
   aa7a4:      	ldr	d8, [x22, #0x50]
   aa7a8:      	stp	q0, q0, [x19, #0x290]
   aa7ac:      	stp	q0, q0, [x19, #0x270]
   aa7b0:      	str	q0, [x19, #0x260]
   aa7b4:      	stp	q0, q0, [x19, #0x230]
   aa7b8:      	stp	q0, q0, [x19, #0x210]
   aa7bc:      	stp	q0, q0, [x19, #0x1f0]
   aa7c0:      	str	q0, [x19, #0x1e0]
   aa7c4:      	str	q0, [x19, #0x690]
   aa7c8:      	str	q0, [x19, #0x680]
   aa7cc:      	str	q0, [x19, #0x670]
   aa7d0:      	str	q0, [x19, #0x660]
   aa7d4:      	str	q0, [x19, #0x650]
   aa7d8:      	str	q0, [x19, #0x640]
   aa7dc:      	str	q0, [x19, #0x630]
   aa7e0:      	str	q0, [x19, #0x620]
   aa7e4:      	str	q0, [x19, #0x610]
   aa7e8:      	str	q0, [x19, #0x600]
   aa7ec:      	str	q0, [x19, #0x5f0]
   aa7f0:      	str	q0, [x19, #0x5e0]
   aa7f4:      	str	q0, [x19, #0x5d0]
   aa7f8:      	str	q0, [x19, #0x5c0]
   aa7fc:      	str	q0, [x19, #0x5b0]
   aa800:      	stp	q0, q0, [x19, #0x3b0]
   aa804:      	stp	q0, q0, [x19, #0x390]
   aa808:      	stp	q0, q0, [x19, #0x370]
   aa80c:      	stp	q0, q0, [x19, #0x350]
   aa810:      	stp	q0, q0, [x19, #0x330]
   aa814:      	stp	q0, q0, [x19, #0x310]
   aa818:      	stp	q0, q0, [x19, #0x2f0]
   aa81c:      	str	q0, [x19, #0x2e0]
   aa820:      	stp	q0, q0, [x19, #0x1c0]
   aa824:      	stp	q0, q0, [x19, #0x1a0]
   aa828:      	stp	q0, q0, [x19, #0x180]
   aa82c:      	stp	q0, q0, [x19, #0x160]
   aa830:      	stp	q0, q0, [x19, #0x140]
   aa834:      	stp	q0, q0, [x19, #0x120]
   aa838:      	stp	q0, q0, [x19, #0x100]
   aa83c:      	stp	q0, q0, [x19, #0xe0]
   aa840:      	stp	q0, q0, [x19, #0xc0]
   aa844:      	stp	q0, q0, [x19, #0xa0]
   aa848:      	stp	q0, q0, [x19, #0x80]
   aa84c:      	stp	q0, q0, [x19, #0x60]
   aa850:      	ldrh	w19, [x22, #0x10]
   aa854:      	str	q0, [sp, #0x480]
   aa858:      	str	q0, [sp, #0x470]
   aa85c:      	str	q0, [sp, #0x460]
   aa860:      	str	q0, [sp, #0x450]
   aa864:      	str	q0, [sp, #0x440]
   aa868:      	str	q0, [sp, #0x430]
   aa86c:      	bl	0xbefc0 <memset@plt>
   aa870:      	add	x0, sp, #0xcb0
   aa874:      	mov	w1, wzr
   aa878:      	mov	w2, #0x2d0              // =720
   aa87c:      	bl	0xbefc0 <memset@plt>
   aa880:      	adrp	x8, 0xe9000 <g_algo+0x330>
   aa884:      	ldr	w21, [sp, #0x3c0]
   aa888:      	movi	v0.2d, #0000000000000000
   aa88c:      	str	xzr, [sp, #0x408]
   aa890:      	ldrb	w8, [x8, #0x6e0]
   aa894:      	str	q0, [sp, #0x420]
   aa898:      	cmp	w8, #0x1
   aa89c:      	str	q0, [sp, #0x410]
   aa8a0:      	b.ne	0xab008 <air1_opcal5_algorithm+0x2424>
   aa8a4:      	cbz	w19, 0xab008 <air1_opcal5_algorithm+0x2424>
   aa8a8:      	sub	w8, w21, w19
   aa8ac:      	cmp	w8, #0x1
   aa8b0:      	b.ne	0xab008 <air1_opcal5_algorithm+0x2424>
   aa8b4:      	sub	x27, x24, x25
   aa8b8:      	cmp	x27, #0x1e0
   aa8bc:      	b.lt	0xab008 <air1_opcal5_algorithm+0x2424>
   aa8c0:      	cmp	x27, #0x563
   aa8c4:      	b.gt	0xab008 <air1_opcal5_algorithm+0x2424>
   aa8c8:      	fsub	d0, d9, d8
   aa8cc:      	mov	w12, #-0x122            // =-290
   aa8d0:      	adrp	x11, 0x1000 <strcasecmp+0x1000>
   aa8d4:      	dup	v1.2s, w25
   aa8d8:      	movi	v3.2s, #0xa
   aa8dc:      	movi	v5.2s, #0x2
   aa8e0:      	dup	v4.2s, w12
   aa8e4:      	mov	x8, xzr
   aa8e8:      	str	d0, [sp, #0x3b8]
   aa8ec:      	dup	v0.2s, w24
   aa8f0:      	mov	x9, xzr
   aa8f4:      	add	x10, x26, #0x6
   aa8f8:      	ldr	d2, [x11, #0x560]
   aa8fc:      	add	x11, x22, #0x14
   aa900:      	add	x12, sp, #0x690
   aa904:      	add	x13, sp, #0x610
   aa908:      	add	x14, sp, #0x9e0
   aa90c:      	add	x15, sp, #0x710
   aa910:      	lsl	x16, x9, #2
   aa914:      	fmov	d16, d4
   aa918:      	add	x17, x10, x16
   aa91c:      	add	x16, x11, x16
   aa920:      	ldrh	w0, [x17]
   aa924:      	mla	v16.2s, v2.2s, v3.2s
   aa928:      	ldrh	w1, [x16]
   aa92c:      	add	v2.2s, v2.2s, v5.2s
   aa930:      	ldrh	w17, [x17, #0x2]
   aa934:      	fmov	s6, w0
   aa938:      	ldrh	w16, [x16, #0x2]
   aa93c:      	fmov	s7, w1
   aa940:      	mov	v6.s[1], w17
   aa944:      	mov	v7.s[1], w16
   aa948:      	lsl	x16, x9, #3
   aa94c:      	add	x9, x9, #0x1
   aa950:      	ushll	v6.2d, v6.2s, #0x0
   aa954:      	ushll	v7.2d, v7.2s, #0x0
   aa958:      	ucvtf	v6.2d, v6.2d
   aa95c:      	ucvtf	v7.2d, v7.2d
   aa960:      	str	q6, [x14, x8]
   aa964:      	add	v6.2s, v16.2s, v0.2s
   aa968:      	str	q7, [x15, x8]
   aa96c:      	add	v7.2s, v16.2s, v1.2s
   aa970:      	add	x8, x8, #0x10
   aa974:      	cmp	x8, #0xf0
   aa978:      	str	d6, [x12, x16]
   aa97c:      	str	d7, [x13, x16]
   aa980:      	b.ne	0xaa910 <air1_opcal5_algorithm+0x1d2c>
   aa984:      	add	x0, sp, #0x9e0
   aa988:      	add	x1, sp, #0x520
   aa98c:      	bl	0xb91e4 <eliminate_peak>
   aa990:      	add	x0, sp, #0x710
   aa994:      	add	x1, sp, #0x430
   aa998:      	bl	0xb91e4 <eliminate_peak>
   aa99c:      	add	x19, sp, #0x430
   aa9a0:      	movi	d0, #0000000000000000
   aa9a4:      	mov	x8, #-0x8000000000000000 // =-9223372036854775808
   aa9a8:      	ldr	d16, [sp, #0x480]
   aa9ac:      	mov	x12, #0x404e000000000000 // =4633641066610819072
   aa9b0:      	ldr	w15, [sp, #0x670]
   aa9b4:      	ldp	d4, d1, [x19, #0xe8]
   aa9b8:      	mov	w14, #0xcd              // =205
   aa9bc:      	mov	x3, #-0x3fb7000000000000 // =-4591138345127510016
   aa9c0:      	ldp	d7, d6, [x19, #0x98]
   aa9c4:      	adrp	x24, 0xe8000 <quick_sel_arr+0x1810>
   aa9c8:      	ldp	d18, d19, [x19, #0x58]
   aa9cc:      	fadd	d2, d1, d0
   aa9d0:      	fcmp	d1, d1
   aa9d4:      	ldr	w17, [sp, #0x6a0]
   aa9d8:      	fmov	d21, x3
   aa9dc:      	fadd	d3, d6, d0
   aa9e0:      	ldr	w7, [sp, #0x620]
   aa9e4:      	fcsel	d31, d2, d0, vc
   aa9e8:      	fcmp	d6, d6
   aa9ec:      	ldp	d2, d5, [x19, #0xf8]
   aa9f0:      	fcsel	d15, d3, d0, vc
   aa9f4:      	fmov	d3, x8
   aa9f8:      	fcmp	d2, d2
   aa9fc:      	cset	w8, vc
   aaa00:      	fcsel	d24, d2, d3, vc
   aaa04:      	fcmp	d1, d1
   aaa08:      	fadd	d1, d16, d0
   aaa0c:      	ldp	d2, d17, [x19, #0xa8]
   aaa10:      	cinc	w8, w8, vc
   aaa14:      	fcmp	d16, d16
   aaa18:      	fcsel	d1, d1, d0, vc
   aaa1c:      	fcmp	d2, d2
   aaa20:      	cset	w9, vc
   aaa24:      	str	d1, [sp, #0x2c0]
   aaa28:      	fcsel	d1, d2, d3, vc
   aaa2c:      	fcmp	d6, d6
   aaa30:      	ldr	d2, [sp, #0x438]
   aaa34:      	str	d1, [sp, #0x2b8]
   aaa38:      	ldr	d1, [sp, #0x430]
   aaa3c:      	cinc	w9, w9, vc
   aaa40:      	fadd	d6, d1, d0
   aaa44:      	fcmp	d1, d1
   aaa48:      	fcsel	d0, d6, d0, vc
   aaa4c:      	fcmp	d18, d18
   aaa50:      	cset	w10, vc
   aaa54:      	fcsel	d6, d18, d3, vc
   aaa58:      	fcmp	d16, d16
   aaa5c:      	str	d0, [sp, #0x248]
   aaa60:      	cinc	w10, w10, vc
   aaa64:      	fcmp	d2, d2
   aaa68:      	fcsel	d0, d2, d3, vc
   aaa6c:      	cset	w11, vc
   aaa70:      	fcmp	d1, d1
   aaa74:      	ldr	d1, [sp, #0x448]
   aaa78:      	ldr	d2, [sp, #0x458]
   aaa7c:      	str	d0, [sp, #0x1e0]
   aaa80:      	ldr	d0, [sp, #0x440]
   aaa84:      	cinc	w11, w11, vc
   aaa88:      	fcmp	d0, d0
   aaa8c:      	fcsel	d0, d0, d3, vc
   aaa90:      	cinc	w11, w11, vc
   aaa94:      	fcmp	d1, d1
   aaa98:      	str	d0, [sp, #0x1e8]
   aaa9c:      	ldr	d0, [sp, #0x450]
   aaaa0:      	fcsel	d1, d1, d3, vc
   aaaa4:      	cinc	w11, w11, vc
   aaaa8:      	fcmp	d0, d0
   aaaac:      	stp	d1, d6, [sp, #0x1f0]
   aaab0:      	ldr	d1, [sp, #0x468]
   aaab4:      	fcsel	d0, d0, d3, vc
   aaab8:      	cinc	w11, w11, vc
   aaabc:      	fcmp	d2, d2
   aaac0:      	str	d0, [sp, #0x250]
   aaac4:      	ldr	d0, [sp, #0x460]
   aaac8:      	fcsel	d2, d2, d3, vc
   aaacc:      	cinc	w11, w11, vc
   aaad0:      	fcmp	d0, d0
   aaad4:      	str	d2, [sp, #0x258]
   aaad8:      	ldr	d2, [sp, #0x478]
   aaadc:      	fcsel	d0, d0, d3, vc
   aaae0:      	cinc	w11, w11, vc
   aaae4:      	fcmp	d1, d1
   aaae8:      	str	d0, [sp, #0x260]
   aaaec:      	ldr	d0, [sp, #0x470]
   aaaf0:      	fcsel	d1, d1, d3, vc
   aaaf4:      	cinc	w11, w11, vc
   aaaf8:      	fcmp	d0, d0
   aaafc:      	str	d1, [sp, #0x270]
   aab00:      	fcsel	d9, d0, d3, vc
   aab04:      	cinc	w11, w11, vc
   aab08:      	fcmp	d2, d2
   aab0c:      	ldp	d0, d1, [x19, #0x68]
   aab10:      	fcsel	d10, d2, d3, vc
   aab14:      	cinc	w13, w11, vc
   aab18:      	fcmp	d19, d19
   aab1c:      	fcsel	d2, d19, d3, vc
   aab20:      	cinc	w10, w10, vc
   aab24:      	fcmp	d0, d0
   aab28:      	ldp	d18, d19, [x19, #0x128]
   aab2c:      	fcsel	d0, d0, d3, vc
   aab30:      	cinc	w10, w10, vc
   aab34:      	fcmp	d1, d1
   aab38:      	str	d2, [sp, #0x1c0]
   aab3c:      	str	d0, [sp, #0x200]
   aab40:      	fcsel	d1, d1, d3, vc
   aab44:      	ldp	d0, d6, [x19, #0x78]
   aab48:      	cinc	w10, w10, vc
   aab4c:      	str	d1, [sp, #0x268]
   aab50:      	fcmp	d0, d0
   aab54:      	fcsel	d2, d0, d3, vc
   aab58:      	cinc	w10, w10, vc
   aab5c:      	ldp	d0, d1, [x19, #0x88]
   aab60:      	fcmp	d6, d6
   aab64:      	fcsel	d11, d6, d3, vc
   aab68:      	cinc	w10, w10, vc
   aab6c:      	fcmp	d0, d0
   aab70:      	fcsel	d12, d0, d3, vc
   aab74:      	cinc	w10, w10, vc
   aab78:      	fcmp	d1, d1
   aab7c:      	fcsel	d14, d1, d3, vc
   aab80:      	cinc	w10, w10, vc
   aab84:      	fcmp	d7, d7
   aab88:      	ldp	d0, d1, [x19, #0xb8]
   aab8c:      	fcsel	d13, d7, d3, vc
   aab90:      	cinc	w11, w10, vc
   aab94:      	fcmp	d17, d17
   aab98:      	fcsel	d25, d17, d3, vc
   aab9c:      	cinc	w9, w9, vc
   aaba0:      	fcmp	d0, d0
   aaba4:      	ldp	d16, d17, [x19, #0x118]
   aaba8:      	fcsel	d0, d0, d3, vc
   aabac:      	cinc	w9, w9, vc
   aabb0:      	fcmp	d1, d1
   aabb4:      	str	d0, [sp, #0x3a8]
   aabb8:      	fcsel	d1, d1, d3, vc
   aabbc:      	ldp	d0, d6, [x19, #0xc8]
   aabc0:      	cinc	w9, w9, vc
   aabc4:      	str	d1, [sp, #0x388]
   aabc8:      	fcmp	d0, d0
   aabcc:      	fcsel	d0, d0, d3, vc
   aabd0:      	cinc	w9, w9, vc
   aabd4:      	fcmp	d6, d6
   aabd8:      	fcsel	d1, d6, d3, vc
   aabdc:      	str	d0, [sp, #0x340]
   aabe0:      	cinc	w9, w9, vc
   aabe4:      	fmov	d6, x12
   aabe8:      	str	d1, [sp, #0x300]
   aabec:      	ldp	d0, d1, [x19, #0xd8]
   aabf0:      	fcmp	d0, d0
   aabf4:      	fcsel	d7, d0, d3, vc
   aabf8:      	cinc	w9, w9, vc
   aabfc:      	fcmp	d1, d1
   aac00:      	ucvtf	d0, w27
   aac04:      	fcsel	d1, d1, d3, vc
   aac08:      	cinc	w9, w9, vc
   aac0c:      	fcmp	d4, d4
   aac10:      	fdiv	d0, d0, d6
   aac14:      	str	d1, [sp, #0x1c8]
   aac18:      	fcsel	d1, d4, d3, vc
   aac1c:      	cinc	w12, w9, vc
   aac20:      	fcmp	d5, d5
   aac24:      	ldr	w9, [sp, #0x610]
   aac28:      	stp	d1, d7, [sp, #0x1d0]
   aac2c:      	fcsel	d4, d5, d3, vc
   aac30:      	ldp	d6, d7, [x19, #0x108]
   aac34:      	cinc	w8, w8, vc
   aac38:      	sub	x2, x15, x9
   aac3c:      	sub	x17, x17, x9
   aac40:      	fcmp	d6, d6
   aac44:      	fcsel	d1, d6, d3, vc
   aac48:      	cinc	w8, w8, vc
   aac4c:      	fcmp	d7, d7
   aac50:      	fcsel	d6, d7, d3, vc
   aac54:      	cinc	w8, w8, vc
   aac58:      	fcmp	d16, d16
   aac5c:      	stp	d1, d4, [sp, #0x1b0]
   aac60:      	fcsel	d7, d16, d3, vc
   aac64:      	fmov	d16, #-7.00000000
   aac68:      	cinc	w8, w8, vc
   aac6c:      	fcmp	d17, d17
   aac70:      	fadd	d0, d0, d16
   aac74:      	fcsel	d16, d17, d3, vc
   aac78:      	cinc	w8, w8, vc
   aac7c:      	fcmp	d18, d18
   aac80:      	fcvtzs	w16, d0
   aac84:      	ldr	d0, [x19, #0x138]
   aac88:      	fcsel	d17, d18, d3, vc
   aac8c:      	cinc	w8, w8, vc
   aac90:      	fcmp	d19, d19
   aac94:      	and	w0, w16, #0xff
   aac98:      	cinc	w1, w8, vc
   aac9c:      	mul	w8, w0, w14
   aaca0:      	fcsel	d18, d19, d3, vc
   aaca4:      	fcmp	d0, d0
   aaca8:      	mov	x0, #0x4049000000000000 // =4632233691727265792
   aacac:      	lsr	w8, w8, #10
   aacb0:      	ldr	w14, [sp, #0x648]
   aacb4:      	fcsel	d19, d0, d3, vc
   aacb8:      	add	w15, w8, w8, lsl #2
   aacbc:      	scvtf	d0, x2
   aacc0:      	scvtf	d3, x17
   aacc4:      	sub	w4, w16, w15
   aacc8:      	cinc	w15, w1, vc
   aaccc:      	fmov	d20, x0
   aacd0:      	tst	w4, #0xff
   aacd4:      	b.eq	0xaacf0 <air1_opcal5_algorithm+0x210c>
   aacd8:      	ucvtf	d22, w16
   aacdc:      	fmov	d23, #5.00000000
   aace0:      	fdiv	d22, d22, d23
   aace4:      	fmov	d23, #1.00000000
   aace8:      	fadd	d22, d22, d23
   aacec:      	fcvtzs	w8, d22
   aacf0:      	fadd	d20, d0, d20
   aacf4:      	fadd	d21, d3, d21
   aacf8:      	cmp	w8, #0x1
   aacfc:      	b.eq	0xab084 <air1_opcal5_algorithm+0x24a0>
   aad00:      	fmov	d5, d25
   aad04:      	fmov	d4, d2
   aad08:      	fmov	d2, d24
   aad0c:      	str	w15, [sp, #0x1a0]
   aad10:      	mov	x15, x14
   aad14:      	str	x7, [sp, #0x1a8]
   aad18:      	mov	w14, w12
   aad1c:      	mov	w12, w11
   aad20:      	mov	x11, x23
   aad24:      	adrp	x30, 0x9000 <loess_weight_arr+0x7920>
   aad28:      	adrp	x28, 0x9000 <loess_weight_arr+0x7920>
   aad2c:      	adrp	x24, 0x9000 <loess_weight_arr+0x7920>
   aad30:      	adrp	x23, 0x9000 <loess_weight_arr+0x7920>
   aad34:      	adrp	x21, 0x9000 <loess_weight_arr+0x7920>
   aad38:      	adrp	x19, 0x9000 <loess_weight_arr+0x7920>
   aad3c:      	adrp	x7, 0x9000 <loess_weight_arr+0x7920>
   aad40:      	adrp	x6, 0x9000 <loess_weight_arr+0x7920>
   aad44:      	adrp	x4, 0x9000 <loess_weight_arr+0x7920>
   aad48:      	adrp	x3, 0x9000 <loess_weight_arr+0x7920>
   aad4c:      	adrp	x2, 0x9000 <loess_weight_arr+0x7920>
   aad50:      	adrp	x1, 0x9000 <loess_weight_arr+0x7920>
   aad54:      	adrp	x0, 0x9000 <loess_weight_arr+0x7920>
   aad58:      	adrp	x17, 0x9000 <loess_weight_arr+0x7920>
   aad5c:      	adrp	x16, 0x9000 <loess_weight_arr+0x7920>
   aad60:      	cmp	w8, #0x2
   aad64:      	b.ne	0xab224 <air1_opcal5_algorithm+0x2640>
   aad68:      	mov	x5, #0x200000000000     // =35184372088832
   aad6c:      	add	x10, sp, #0x430
   aad70:      	movk	x5, #0xc072, lsl #48
   aad74:      	fmov	d26, #-10.00000000
   aad78:      	ldr	q24, [x28, #0xd10]
   aad7c:      	fmov	d1, d9
   aad80:      	ldr	q25, [x24, #0xd20]
   aad84:      	fmov	d9, d15
   aad88:      	fmov	d22, x5
   aad8c:      	mov	x5, #0xc00000000000     // =211106232532992
   aad90:      	movk	x5, #0xc072, lsl #48
   aad94:      	ldr	q27, [x23, #0xd30]
   aad98:      	ldr	q28, [x21, #0x5d0]
   aad9c:      	fmov	d15, d14
   aada0:      	fadd	d21, d21, d22
   aada4:      	ldr	q22, [x30, #0x940]
   aada8:      	ldr	q29, [x7, #0xb30]
   aadac:      	fmov	d14, d13
   aadb0:      	ldr	q30, [x6, #0xc60]
   aadb4:      	fmov	d13, d12
   aadb8:      	fmov	d12, d11
   aadbc:      	fmov	d11, d10
   aadc0:      	dup	v21.2d, v21.d[0]
   aadc4:      	fmov	d10, d31
   aadc8:      	ldr	q31, [x4, #0x750]
   aadcc:      	fadd	v22.2d, v21.2d, v22.2d
   aadd0:      	fadd	v24.2d, v21.2d, v24.2d
   aadd4:      	fadd	v25.2d, v21.2d, v25.2d
   aadd8:      	fadd	v27.2d, v21.2d, v27.2d
   aaddc:      	str	q22, [x10, #0xc40]
   aade0:      	fmov	d22, x5
   aade4:      	ldr	d23, [x10, #0xc40]
   aade8:      	fadd	d22, d23, d22
   aadec:      	fadd	d26, d23, d26
   aadf0:      	fmov	d23, #30.00000000
   aadf4:      	fcmp	d20, d22
   aadf8:      	fcsel	d22, d20, d22, gt
   aadfc:      	ldr	q20, [x19, #0xd80]
   aae00:      	add	x19, sp, #0x430
   aae04:      	fadd	v20.2d, v21.2d, v20.2d
   aae08:      	fsub	d26, d26, d22
   aae0c:      	str	q24, [x19, #0xc50]
   aae10:      	str	q25, [x19, #0xc60]
   aae14:      	ldr	q25, [x3, #0xb80]
   aae18:      	str	q27, [x19, #0xc70]
   aae1c:      	fadd	v27.2d, v21.2d, v28.2d
   aae20:      	str	q20, [x19, #0xc90]
   aae24:      	fdiv	d24, d26, d23
   aae28:      	ldr	q26, [x2, #0x780]
   aae2c:      	fadd	v28.2d, v21.2d, v29.2d
   aae30:      	ldr	q20, [x0, #0x570]
   aae34:      	fadd	v25.2d, v21.2d, v25.2d
   aae38:      	str	q27, [x19, #0xc80]
   aae3c:      	ldr	q27, [x1, #0x8a0]
   aae40:      	fadd	v26.2d, v21.2d, v26.2d
   aae44:      	str	q28, [x19, #0xca0]
   aae48:      	ldr	q28, [x17, #0xc70]
   aae4c:      	fadd	v27.2d, v21.2d, v27.2d
   aae50:      	str	q25, [x19, #0xcd0]
   aae54:      	fmov	d25, #3.00000000
   aae58:      	fadd	v29.2d, v21.2d, v30.2d
   aae5c:      	str	q26, [x19, #0xce0]
   aae60:      	fadd	v20.2d, v21.2d, v20.2d
   aae64:      	fadd	v28.2d, v21.2d, v28.2d
   aae68:      	str	q27, [x19, #0xcf0]
   aae6c:      	fmov	d26, #4.00000000
   aae70:      	fmov	d27, #5.00000000
   aae74:      	str	q29, [x19, #0xcb0]
   aae78:      	ldr	q29, [x16, #0x680]
   aae7c:      	str	q20, [x19, #0xd00]
   aae80:      	fmov	d20, #6.00000000
   aae84:      	str	q28, [x19, #0xd10]
   aae88:      	fmov	d28, #7.00000000
   aae8c:      	fadd	v30.2d, v21.2d, v31.2d
   aae90:      	fmov	d31, d10
   aae94:      	fadd	v21.2d, v21.2d, v29.2d
   aae98:      	fmov	d29, #2.00000000
   aae9c:      	fmov	d10, d11
   aaea0:      	fmov	d11, d12
   aaea4:      	str	q30, [x19, #0xcc0]
   aaea8:      	fmov	d30, #24.00000000
   aaeac:      	str	q21, [x19, #0xd20]
   aaeb0:      	fmov	d21, #8.00000000
   aaeb4:      	fmadd	d25, d24, d25, d22
   aaeb8:      	fmadd	d26, d24, d26, d22
   aaebc:      	fmadd	d27, d24, d27, d22
   aaec0:      	fmadd	d20, d24, d20, d22
   aaec4:      	fmadd	d28, d24, d28, d22
   aaec8:      	fmadd	d21, d24, d21, d22
   aaecc:      	fmov	d12, d13
   aaed0:      	fmov	d13, d14
   aaed4:      	str	d25, [x19, #0xb60]
   aaed8:      	fmov	d25, #9.00000000
   aaedc:      	str	d26, [x19, #0xb68]
   aaee0:      	fmov	d26, #10.00000000
   aaee4:      	str	d27, [x19, #0xb70]
   aaee8:      	fmov	d27, #11.00000000
   aaeec:      	fmadd	d25, d24, d25, d22
   aaef0:      	str	d20, [x19, #0xb78]
   aaef4:      	fmadd	d26, d24, d26, d22
   aaef8:      	fmov	d20, #12.00000000
   aaefc:      	str	d28, [x19, #0xb80]
   aaf00:      	fmov	d28, #13.00000000
   aaf04:      	fmadd	d27, d24, d27, d22
   aaf08:      	str	d21, [x19, #0xb88]
   aaf0c:      	str	d25, [x19, #0xb90]
   aaf10:      	fmov	d25, #15.00000000
   aaf14:      	fmadd	d20, d24, d20, d22
   aaf18:      	str	d26, [x19, #0xb98]
   aaf1c:      	fmov	d26, #16.00000000
   aaf20:      	fmadd	d28, d24, d28, d22
   aaf24:      	fmadd	d25, d24, d25, d22
   aaf28:      	str	d27, [x19, #0xba0]
   aaf2c:      	fmov	d27, #17.00000000
   aaf30:      	fmov	d21, #14.00000000
   aaf34:      	fmadd	d26, d24, d26, d22
   aaf38:      	str	d20, [x19, #0xba8]
   aaf3c:      	fmov	d20, #18.00000000
   aaf40:      	str	d28, [x19, #0xbb0]
   aaf44:      	fmov	d28, #19.00000000
   aaf48:      	fmadd	d27, d24, d27, d22
   aaf4c:      	str	d25, [x19, #0xbc0]
   aaf50:      	fmov	d25, #21.00000000
   aaf54:      	fmadd	d21, d24, d21, d22
   aaf58:      	fmadd	d20, d24, d20, d22
   aaf5c:      	str	d26, [x19, #0xbc8]
   aaf60:      	fmov	d26, #22.00000000
   aaf64:      	fmadd	d28, d24, d28, d22
   aaf68:      	fmadd	d25, d24, d25, d22
   aaf6c:      	str	d27, [x19, #0xbd0]
   aaf70:      	fmov	d27, #23.00000000
   aaf74:      	fmadd	d26, d24, d26, d22
   aaf78:      	str	d21, [x19, #0xbb8]
   aaf7c:      	fmov	d21, #20.00000000
   aaf80:      	str	d20, [x19, #0xbd8]
   aaf84:      	str	d28, [x19, #0xbe0]
   aaf88:      	fmov	d28, #25.00000000
   aaf8c:      	str	d25, [x19, #0xbf0]
   aaf90:      	fmadd	d25, d24, d27, d22
   aaf94:      	fmov	d27, #26.00000000
   aaf98:      	fmadd	d20, d24, d29, d22
   aaf9c:      	fmadd	d29, d24, d30, d22
   aafa0:      	fmadd	d21, d24, d21, d22
   aafa4:      	str	d26, [x19, #0xbf8]
   aafa8:      	fmadd	d26, d24, d28, d22
   aafac:      	fmadd	d27, d24, d27, d22
   aafb0:      	fmov	d28, #27.00000000
   aafb4:      	str	d25, [x19, #0xc00]
   aafb8:      	fmov	d25, #28.00000000
   aafbc:      	str	d29, [x19, #0xc08]
   aafc0:      	fmov	d29, #29.00000000
   aafc4:      	str	d21, [x19, #0xbe8]
   aafc8:      	fadd	d21, d22, d24
   aafcc:      	str	d26, [x19, #0xc10]
   aafd0:      	fmadd	d26, d24, d28, d22
   aafd4:      	str	d27, [x19, #0xc18]
   aafd8:      	fmadd	d25, d24, d25, d22
   aafdc:      	fmadd	d27, d24, d29, d22
   aafe0:      	fmov	d14, d15
   aafe4:      	fmov	d15, d9
   aafe8:      	fmov	d9, d1
   aafec:      	str	d21, [x19, #0xb50]
   aaff0:      	fmadd	d22, d24, d23, d22
   aaff4:      	str	d20, [x19, #0xb58]
   aaff8:      	str	d26, [x19, #0xc20]
   aaffc:      	str	d25, [x19, #0xc28]
   ab000:      	str	d27, [x19, #0xc30]
   ab004:      	b	0xab4b8 <air1_opcal5_algorithm+0x28d4>
   ab008:      	adrp	x27, 0xe8000 <quick_sel_arr+0x1810>
   ab00c:      	mov	w9, #0x1                // =1
   ab010:      	add	x27, x27, #0x2f8
   ab014:      	mov	x8, xzr
   ab018:      	mov	w10, #-0x122            // =-290
   ab01c:      	ldr	x3, [sp, #0x3a0]
   ab020:      	ldr	x4, [sp, #0x398]
   ab024:      	strb	w9, [x27, #0x310]
   ab028:      	ldr	x5, [sp, #0x3d0]
   ab02c:      	ldrh	w9, [x22, #0x58]
   ab030:      	str	w24, [x27, #0x10]
   ab034:      	adrp	x24, 0xe8000 <quick_sel_arr+0x1810>
   ab038:      	ldr	x6, [sp, #0x3c8]
   ab03c:      	strh	w21, [x27, #0x8]
   ab040:      	add	w11, w9, w21
   ab044:      	add	x9, x26, #0x6
   ab048:      	str	d9, [x27, #0x2f0]
   ab04c:      	strh	w11, [x27]
   ab050:      	adrp	x11, 0xe8000 <quick_sel_arr+0x1810>
   ab054:      	add	x11, x11, #0x408
   ab058:      	ldrh	w12, [x9], #0x2
   ab05c:      	add	x13, x11, x8, lsl #1
   ab060:      	sturh	w12, [x13, #-0xf0]
   ab064:      	ldur	w12, [x26, #0x2]
   ab068:      	add	w12, w10, w12
   ab06c:      	add	w10, w10, #0xa
   ab070:      	str	w12, [x11, x8, lsl #2]
   ab074:      	add	x8, x8, #0x4
   ab078:      	cmp	x8, #0x78
   ab07c:      	b.ne	0xab058 <air1_opcal5_algorithm+0x2474>
   ab080:      	b	0xabb30 <air1_opcal5_algorithm+0x2f4c>
   ab084:      	mov	x10, #0xc00000000000    // =211106232532992
   ab088:      	fmov	d23, #30.00000000
   ab08c:      	movk	x10, #0xc072, lsl #48
   ab090:      	fmov	d4, d2
   ab094:      	fmov	d2, d24
   ab098:      	fmov	d5, d25
   ab09c:      	fmov	d25, #5.00000000
   ab0a0:      	fmov	d27, #6.00000000
   ab0a4:      	fmov	d22, x10
   ab0a8:      	fmov	d28, #7.00000000
   ab0ac:      	fmov	d29, #8.00000000
   ab0b0:      	fmov	d30, #28.00000000
   ab0b4:      	ldr	x3, [sp, #0x3a0]
   ab0b8:      	fadd	d22, d21, d22
   ab0bc:      	ldr	x4, [sp, #0x398]
   ab0c0:      	ldr	x5, [sp, #0x3d0]
   ab0c4:      	ldr	x6, [sp, #0x3c8]
   ab0c8:      	fcmp	d20, d22
   ab0cc:      	fcsel	d22, d20, d22, gt
   ab0d0:      	fsub	d20, d21, d22
   ab0d4:      	fmov	d21, #4.00000000
   ab0d8:      	fdiv	d24, d20, d23
   ab0dc:      	fmov	d20, #3.00000000
   ab0e0:      	fmadd	d26, d24, d20, d22
   ab0e4:      	fmadd	d25, d24, d25, d22
   ab0e8:      	fmadd	d21, d24, d21, d22
   ab0ec:      	fmadd	d27, d24, d27, d22
   ab0f0:      	fmadd	d28, d24, d28, d22
   ab0f4:      	fmadd	d29, d24, d29, d22
   ab0f8:      	fmov	d20, #2.00000000
   ab0fc:      	str	d26, [x19, #0xb60]
   ab100:      	fmov	d26, #9.00000000
   ab104:      	str	d25, [x19, #0xb70]
   ab108:      	fmov	d25, #11.00000000
   ab10c:      	str	d21, [x19, #0xb68]
   ab110:      	fmov	d21, #10.00000000
   ab114:      	str	d27, [x19, #0xb78]
   ab118:      	fmov	d27, #12.00000000
   ab11c:      	fmadd	d26, d24, d26, d22
   ab120:      	fmadd	d25, d24, d25, d22
   ab124:      	fmadd	d21, d24, d21, d22
   ab128:      	str	d28, [x19, #0xb80]
   ab12c:      	fmadd	d27, d24, d27, d22
   ab130:      	fmov	d28, #13.00000000
   ab134:      	str	d29, [x19, #0xb88]
   ab138:      	fmov	d29, #14.00000000
   ab13c:      	str	d26, [x19, #0xb90]
   ab140:      	fmov	d26, #15.00000000
   ab144:      	str	d25, [x19, #0xba0]
   ab148:      	fmov	d25, #17.00000000
   ab14c:      	str	d21, [x19, #0xb98]
   ab150:      	fmov	d21, #16.00000000
   ab154:      	fmadd	d28, d24, d28, d22
   ab158:      	fmadd	d29, d24, d29, d22
   ab15c:      	str	d27, [x19, #0xba8]
   ab160:      	fmov	d27, #18.00000000
   ab164:      	fmadd	d26, d24, d26, d22
   ab168:      	fmadd	d25, d24, d25, d22
   ab16c:      	fmadd	d21, d24, d21, d22
   ab170:      	fmadd	d20, d24, d20, d22
   ab174:      	fmadd	d27, d24, d27, d22
   ab178:      	str	d28, [x19, #0xbb0]
   ab17c:      	fmov	d28, #19.00000000
   ab180:      	str	d29, [x19, #0xbb8]
   ab184:      	fmov	d29, #20.00000000
   ab188:      	str	d26, [x19, #0xbc0]
   ab18c:      	fmov	d26, #21.00000000
   ab190:      	str	d25, [x19, #0xbd0]
   ab194:      	fmov	d25, #23.00000000
   ab198:      	str	d21, [x19, #0xbc8]
   ab19c:      	fmov	d21, #22.00000000
   ab1a0:      	fmadd	d28, d24, d28, d22
   ab1a4:      	fmadd	d29, d24, d29, d22
   ab1a8:      	str	d27, [x19, #0xbd8]
   ab1ac:      	fmov	d27, #24.00000000
   ab1b0:      	fmadd	d26, d24, d26, d22
   ab1b4:      	fmadd	d25, d24, d25, d22
   ab1b8:      	fmadd	d21, d24, d21, d22
   ab1bc:      	str	d28, [x19, #0xbe0]
   ab1c0:      	fmov	d28, #25.00000000
   ab1c4:      	fmadd	d27, d24, d27, d22
   ab1c8:      	str	d29, [x19, #0xbe8]
   ab1cc:      	fmov	d29, #26.00000000
   ab1d0:      	str	d26, [x19, #0xbf0]
   ab1d4:      	fmov	d26, #27.00000000
   ab1d8:      	str	d25, [x19, #0xc00]
   ab1dc:      	fmov	d25, #29.00000000
   ab1e0:      	str	d21, [x19, #0xbf8]
   ab1e4:      	fmadd	d28, d24, d28, d22
   ab1e8:      	fmadd	d29, d24, d29, d22
   ab1ec:      	fadd	d21, d22, d24
   ab1f0:      	str	d27, [x19, #0xc08]
   ab1f4:      	fmadd	d26, d24, d26, d22
   ab1f8:      	fmadd	d27, d24, d30, d22
   ab1fc:      	fmadd	d25, d24, d25, d22
   ab200:      	fmadd	d22, d24, d23, d22
   ab204:      	str	d28, [x19, #0xc10]
   ab208:      	str	d29, [x19, #0xc18]
   ab20c:      	str	d21, [x19, #0xb50]
   ab210:      	str	d20, [x19, #0xb58]
   ab214:      	str	d26, [x19, #0xc20]
   ab218:      	str	d27, [x19, #0xc28]
   ab21c:      	str	d25, [x19, #0xc30]
   ab220:      	b	0xab4e8 <air1_opcal5_algorithm+0x2904>
   ab224:      	mov	x10, #0x200000000000    // =35184372088832
   ab228:      	ldr	q23, [x28, #0xd10]
   ab22c:      	movk	x10, #0xc072, lsl #48
   ab230:      	ldr	q24, [x24, #0xd20]
   ab234:      	ldr	q25, [x23, #0xd30]
   ab238:      	mov	x5, xzr
   ab23c:      	fmov	d22, x10
   ab240:      	add	x10, sp, #0x430
   ab244:      	fadd	d21, d21, d22
   ab248:      	ldr	q22, [x30, #0x940]
   ab24c:      	dup	v21.2d, v21.d[0]
   ab250:      	fadd	v22.2d, v21.2d, v22.2d
   ab254:      	fadd	v23.2d, v21.2d, v23.2d
   ab258:      	fadd	v24.2d, v21.2d, v24.2d
   ab25c:      	fadd	v25.2d, v21.2d, v25.2d
   ab260:      	str	q22, [x10, #0xd30]
   ab264:      	ldr	q22, [x21, #0x5d0]
   ab268:      	str	q23, [x10, #0xd40]
   ab26c:      	ldr	q23, [x19, #0xd80]
   ab270:      	add	x19, sp, #0x430
   ab274:      	add	x10, sp, #0xf80
   ab278:      	fadd	v22.2d, v21.2d, v22.2d
   ab27c:      	fadd	v23.2d, v21.2d, v23.2d
   ab280:      	str	q24, [x19, #0xd50]
   ab284:      	ldr	q24, [x7, #0xb30]
   ab288:      	str	q25, [x19, #0xd60]
   ab28c:      	ldr	q25, [x6, #0xc60]
   ab290:      	str	q22, [x19, #0xd70]
   ab294:      	ldr	q22, [x4, #0x750]
   ab298:      	fadd	v24.2d, v21.2d, v24.2d
   ab29c:      	str	q23, [x19, #0xd80]
   ab2a0:      	fadd	v25.2d, v21.2d, v25.2d
   ab2a4:      	ldr	q23, [x3, #0xb80]
   ab2a8:      	fadd	v22.2d, v21.2d, v22.2d
   ab2ac:      	str	q24, [x19, #0xd90]
   ab2b0:      	ldr	q24, [x2, #0x780]
   ab2b4:      	str	q25, [x19, #0xda0]
   ab2b8:      	ldr	q25, [x1, #0x8a0]
   ab2bc:      	fadd	v23.2d, v21.2d, v23.2d
   ab2c0:      	str	q22, [x19, #0xdb0]
   ab2c4:      	fadd	v24.2d, v21.2d, v24.2d
   ab2c8:      	fadd	v22.2d, v21.2d, v25.2d
   ab2cc:      	ldr	q25, [x0, #0x570]
   ab2d0:      	str	q23, [x19, #0xdc0]
   ab2d4:      	ldr	q23, [x17, #0xc70]
   ab2d8:      	str	q24, [x19, #0xdd0]
   ab2dc:      	mov	x17, #0xc00000000000    // =211106232532992
   ab2e0:      	fadd	v24.2d, v21.2d, v25.2d
   ab2e4:      	ldr	q25, [x16, #0x680]
   ab2e8:      	str	q22, [x19, #0xde0]
   ab2ec:      	add	x16, x10, #0xf0
   ab2f0:      	fadd	v22.2d, v21.2d, v23.2d
   ab2f4:      	movk	x17, #0xc072, lsl #48
   ab2f8:      	fadd	v21.2d, v21.2d, v25.2d
   ab2fc:      	str	q24, [x19, #0xdf0]
   ab300:      	str	q22, [x19, #0xe00]
   ab304:      	str	q21, [x19, #0xe10]
   ab308:      	ldr	d21, [x19, #0xd30]
   ab30c:      	fmov	d22, x17
   ab310:      	fadd	d21, d21, d22
   ab314:      	scvtf	d22, w5
   ab318:      	add	x5, x5, #0xa
   ab31c:      	cmp	x5, #0x12c
   ab320:      	fadd	d21, d21, d22
   ab324:      	str	d21, [x16], #0x8
   ab328:      	b.ne	0xab308 <air1_opcal5_algorithm+0x2724>
   ab32c:      	mov	x10, #0xc00000000000    // =211106232532992
   ab330:      	ldr	d21, [x19, #0xc40]
   ab334:      	movk	x10, #0xc072, lsl #48
   ab338:      	fmov	d23, #-10.00000000
   ab33c:      	fmov	d25, #5.00000000
   ab340:      	fmov	d27, #6.00000000
   ab344:      	fmov	d28, #7.00000000
   ab348:      	fmov	d29, #8.00000000
   ab34c:      	fmov	d22, x10
   ab350:      	fmov	d30, #28.00000000
   ab354:      	fadd	d22, d21, d22
   ab358:      	fadd	d21, d21, d23
   ab35c:      	fmov	d23, #30.00000000
   ab360:      	fcmp	d20, d22
   ab364:      	fcsel	d22, d20, d22, gt
   ab368:      	fsub	d20, d21, d22
   ab36c:      	fmov	d21, #4.00000000
   ab370:      	fdiv	d24, d20, d23
   ab374:      	fmov	d20, #3.00000000
   ab378:      	fmadd	d26, d24, d20, d22
   ab37c:      	fmadd	d25, d24, d25, d22
   ab380:      	fmadd	d21, d24, d21, d22
   ab384:      	fmadd	d27, d24, d27, d22
   ab388:      	fmadd	d28, d24, d28, d22
   ab38c:      	fmadd	d29, d24, d29, d22
   ab390:      	fmov	d20, #2.00000000
   ab394:      	str	d26, [x19, #0xb60]
   ab398:      	fmov	d26, #9.00000000
   ab39c:      	str	d25, [x19, #0xb70]
   ab3a0:      	fmov	d25, #11.00000000
   ab3a4:      	str	d21, [x19, #0xb68]
   ab3a8:      	fmov	d21, #10.00000000
   ab3ac:      	str	d27, [x19, #0xb78]
   ab3b0:      	fmov	d27, #12.00000000
   ab3b4:      	fmadd	d26, d24, d26, d22
   ab3b8:      	fmadd	d25, d24, d25, d22
   ab3bc:      	fmadd	d21, d24, d21, d22
   ab3c0:      	str	d28, [x19, #0xb80]
   ab3c4:      	fmadd	d27, d24, d27, d22
   ab3c8:      	fmov	d28, #13.00000000
   ab3cc:      	str	d29, [x19, #0xb88]
   ab3d0:      	fmov	d29, #14.00000000
   ab3d4:      	str	d26, [x19, #0xb90]
   ab3d8:      	fmov	d26, #15.00000000
   ab3dc:      	str	d25, [x19, #0xba0]
   ab3e0:      	fmov	d25, #17.00000000
   ab3e4:      	str	d21, [x19, #0xb98]
   ab3e8:      	fmov	d21, #16.00000000
   ab3ec:      	fmadd	d28, d24, d28, d22
   ab3f0:      	fmadd	d29, d24, d29, d22
   ab3f4:      	str	d27, [x19, #0xba8]
   ab3f8:      	fmov	d27, #18.00000000
   ab3fc:      	fmadd	d26, d24, d26, d22
   ab400:      	fmadd	d25, d24, d25, d22
   ab404:      	fmadd	d21, d24, d21, d22
   ab408:      	fmadd	d20, d24, d20, d22
   ab40c:      	fmadd	d27, d24, d27, d22
   ab410:      	str	d28, [x19, #0xbb0]
   ab414:      	fmov	d28, #19.00000000
   ab418:      	str	d29, [x19, #0xbb8]
   ab41c:      	fmov	d29, #20.00000000
   ab420:      	str	d26, [x19, #0xbc0]
   ab424:      	fmov	d26, #21.00000000
   ab428:      	str	d25, [x19, #0xbd0]
   ab42c:      	fmov	d25, #23.00000000
   ab430:      	str	d21, [x19, #0xbc8]
   ab434:      	fmov	d21, #22.00000000
   ab438:      	fmadd	d28, d24, d28, d22
   ab43c:      	fmadd	d29, d24, d29, d22
   ab440:      	str	d27, [x19, #0xbd8]
   ab444:      	fmov	d27, #24.00000000
   ab448:      	fmadd	d26, d24, d26, d22
   ab44c:      	fmadd	d25, d24, d25, d22
   ab450:      	fmadd	d21, d24, d21, d22
   ab454:      	str	d28, [x19, #0xbe0]
   ab458:      	fmov	d28, #25.00000000
   ab45c:      	fmadd	d27, d24, d27, d22
   ab460:      	str	d29, [x19, #0xbe8]
   ab464:      	fmov	d29, #26.00000000
   ab468:      	str	d26, [x19, #0xbf0]
   ab46c:      	fmov	d26, #27.00000000
   ab470:      	str	d25, [x19, #0xc00]
   ab474:      	fmov	d25, #29.00000000
   ab478:      	str	d21, [x19, #0xbf8]
   ab47c:      	fmadd	d28, d24, d28, d22
   ab480:      	fmadd	d29, d24, d29, d22
   ab484:      	fadd	d21, d22, d24
   ab488:      	str	d27, [x19, #0xc08]
   ab48c:      	fmadd	d26, d24, d26, d22
   ab490:      	fmadd	d27, d24, d30, d22
   ab494:      	fmadd	d25, d24, d25, d22
   ab498:      	fmadd	d22, d24, d23, d22
   ab49c:      	str	d28, [x19, #0xc10]
   ab4a0:      	str	d29, [x19, #0xc18]
   ab4a4:      	str	d21, [x19, #0xb50]
   ab4a8:      	str	d20, [x19, #0xb58]
   ab4ac:      	str	d26, [x19, #0xc20]
   ab4b0:      	str	d27, [x19, #0xc28]
   ab4b4:      	str	d25, [x19, #0xc30]
   ab4b8:      	mov	x23, x11
   ab4bc:      	ldr	x3, [sp, #0x3a0]
   ab4c0:      	ldr	x4, [sp, #0x398]
   ab4c4:      	mov	w11, w12
   ab4c8:      	ldr	x5, [sp, #0x3d0]
   ab4cc:      	mov	w12, w14
   ab4d0:      	ldr	x6, [sp, #0x3c8]
   ab4d4:      	mov	x14, x15
   ab4d8:      	ldr	w21, [sp, #0x3c0]
   ab4dc:      	adrp	x24, 0xe8000 <quick_sel_arr+0x1810>
   ab4e0:      	ldr	x7, [sp, #0x1a8]
   ab4e4:      	ldr	w15, [sp, #0x1a0]
   ab4e8:      	str	d22, [x19, #0xc38]
   ab4ec:      	cbz	w8, 0xab710 <air1_opcal5_algorithm+0x2b2c>
   ab4f0:      	ldr	d1, [sp, #0x248]
   ab4f4:      	fadd	d25, d31, d2
   ab4f8:      	ldr	d22, [sp, #0x1e0]
   ab4fc:      	and	w10, w13, #0xffff
   ab500:      	ldr	d23, [sp, #0x1f8]
   ab504:      	fadd	d22, d1, d22
   ab508:      	ldr	d1, [sp, #0x2c0]
   ab50c:      	fadd	d23, d1, d23
   ab510:      	ldr	d1, [sp, #0x2b8]
   ab514:      	fadd	d24, d15, d1
   ab518:      	ldr	d1, [sp, #0x1e8]
   ab51c:      	fadd	d22, d22, d1
   ab520:      	ldr	d1, [sp, #0x1c0]
   ab524:      	fadd	d2, d23, d1
   ab528:      	ldr	d1, [sp, #0x1f0]
   ab52c:      	ucvtf	d23, w10
   ab530:      	and	w10, w11, #0xffff
   ab534:      	mov	w11, #0x1e              // =30
   ab538:      	fadd	d22, d22, d1
   ab53c:      	ldr	d1, [sp, #0x250]
   ab540:      	fadd	d22, d22, d1
   ab544:      	ldr	d1, [sp, #0x258]
   ab548:      	fadd	d22, d22, d1
   ab54c:      	ldr	d1, [sp, #0x260]
   ab550:      	fadd	d22, d22, d1
   ab554:      	ldr	d1, [sp, #0x270]
   ab558:      	fadd	d22, d22, d1
   ab55c:      	ldr	d1, [sp, #0x200]
   ab560:      	fadd	d2, d2, d1
   ab564:      	ldr	d1, [sp, #0x268]
   ab568:      	fadd	d22, d22, d9
   ab56c:      	fadd	d2, d2, d1
   ab570:      	ldr	d1, [sp, #0x3a8]
   ab574:      	fadd	d22, d22, d10
   ab578:      	fadd	d2, d2, d4
   ab57c:      	fdiv	d22, d22, d23
   ab580:      	fadd	d23, d24, d5
   ab584:      	ucvtf	d24, w10
   ab588:      	and	w10, w12, #0xffff
   ab58c:      	fadd	d2, d2, d11
   ab590:      	fadd	d23, d23, d1
   ab594:      	ldr	d1, [sp, #0x388]
   ab598:      	ucvtf	d5, w10
   ab59c:      	and	w10, w15, #0xffff
   ab5a0:      	fadd	d2, d2, d12
   ab5a4:      	fadd	d23, d23, d1
   ab5a8:      	ldr	d1, [sp, #0x340]
   ab5ac:      	fadd	d2, d2, d14
   ab5b0:      	fadd	d23, d23, d1
   ab5b4:      	ldr	d1, [sp, #0x300]
   ab5b8:      	fadd	d2, d2, d13
   ab5bc:      	fadd	d23, d23, d1
   ab5c0:      	ldr	d1, [sp, #0x1b8]
   ab5c4:      	fadd	d4, d25, d1
   ab5c8:      	ldr	d1, [sp, #0x1d8]
   ab5cc:      	fdiv	d2, d2, d24
   ab5d0:      	fsub	d24, d3, d0
   ab5d4:      	fadd	d23, d23, d1
   ab5d8:      	ldr	d1, [sp, #0x1b0]
   ab5dc:      	fadd	d4, d4, d1
   ab5e0:      	ldr	d1, [sp, #0x1c8]
   ab5e4:      	fadd	d1, d23, d1
   ab5e8:      	fadd	d4, d4, d6
   ab5ec:      	ldr	d6, [sp, #0x1d0]
   ab5f0:      	fadd	d1, d1, d6
   ab5f4:      	fadd	d4, d4, d7
   ab5f8:      	fmov	d7, #3.00000000
   ab5fc:      	fadd	d4, d4, d16
   ab600:      	fdiv	d1, d1, d5
   ab604:      	ucvtf	d5, w10
   ab608:      	sub	x10, x14, x9
   ab60c:      	fadd	d4, d4, d17
   ab610:      	fadd	d4, d4, d18
   ab614:      	fadd	d4, d4, d19
   ab618:      	fmov	d19, #2.00000000
   ab61c:      	fdiv	d4, d4, d5
   ab620:      	scvtf	d5, x10
   ab624:      	sub	x10, x7, x9
   ab628:      	fsub	d6, d1, d2
   ab62c:      	fsub	d2, d2, d22
   ab630:      	scvtf	d17, x10
   ab634:      	fsub	d16, d0, d5
   ab638:      	movi	d22, #0000000000000000
   ab63c:      	fnmsub	d3, d3, d19, d5
   ab640:      	mov	x10, #-0x2              // =-2
   ab644:      	fmul	d6, d6, d7
   ab648:      	fmul	d2, d2, d7
   ab64c:      	fsub	d18, d5, d17
   ab650:      	fnmsub	d17, d0, d19, d17
   ab654:      	fneg	d5, d24
   ab658:      	umaddl	x13, w8, w11, x10
   ab65c:      	mov	w10, w8
   ab660:      	cmp	x13, #0x4
   ab664:      	fmsub	d17, d18, d22, d17
   ab668:      	fdiv	d6, d6, d16
   ab66c:      	fsub	d4, d4, d1
   ab670:      	fmul	d25, d4, d7
   ab674:      	fdiv	d2, d2, d18
   ab678:      	fdiv	d25, d25, d24
   ab67c:      	fsub	d2, d6, d2
   ab680:      	fmsub	d2, d18, d22, d2
   ab684:      	fdiv	d23, d16, d17
   ab688:      	fsub	d6, d25, d6
   ab68c:      	fdiv	d2, d2, d17
   ab690:      	fmsub	d3, d16, d23, d3
   ab694:      	fdiv	d4, d4, d24
   ab698:      	fmsub	d2, d16, d2, d6
   ab69c:      	fmul	d6, d24, d7
   ab6a0:      	fdiv	d2, d2, d3
   ab6a4:      	fdiv	d3, d5, d3
   ab6a8:      	fmadd	d2, d3, d22, d2
   ab6ac:      	fmadd	d3, d2, d19, d22
   ab6b0:      	fmul	d3, d24, d3
   ab6b4:      	fdiv	d5, d3, d7
   ab6b8:      	fsub	d3, d22, d2
   ab6bc:      	fdiv	d3, d3, d6
   ab6c0:      	fsub	d6, d20, d0
   ab6c4:      	fsub	d4, d4, d5
   ab6c8:      	fsub	d5, d21, d0
   ab6cc:      	fmul	d19, d2, d6
   ab6d0:      	fmadd	d7, d4, d5, d1
   ab6d4:      	fmul	d16, d2, d5
   ab6d8:      	fmadd	d18, d4, d6, d1
   ab6dc:      	fmadd	d7, d16, d5, d7
   ab6e0:      	fmul	d17, d3, d5
   ab6e4:      	fmul	d20, d3, d6
   ab6e8:      	fmul	d16, d5, d17
   ab6ec:      	fmadd	d17, d19, d6, d18
   ab6f0:      	fmul	d18, d6, d20
   ab6f4:      	fmadd	d5, d16, d5, d7
   ab6f8:      	fmadd	d6, d18, d6, d17
   ab6fc:      	str	d5, [x19, #0x880]
   ab700:      	str	d6, [x19, #0x888]
   ab704:      	b.hs	0xab718 <air1_opcal5_algorithm+0x2b34>
   ab708:      	mov	w12, #0x2               // =2
   ab70c:      	b	0xab7a8 <air1_opcal5_algorithm+0x2bc4>
   ab710:      	mov	x10, xzr
   ab714:      	b	0xab7f0 <air1_opcal5_algorithm+0x2c0c>
   ab718:      	and	x14, x13, #0xfffffffffffffffc
   ab71c:      	add	x15, sp, #0xf80
   ab720:      	add	x16, sp, #0xcb0
   ab724:      	orr	x12, x13, #0x2
   ab728:      	add	x15, x15, #0x20
   ab72c:      	add	x16, x16, #0x20
   ab730:      	mov	x17, x14
   ab734:      	dup	v5.2d, v0.d[0]
   ab738:      	dup	v6.2d, v4.d[0]
   ab73c:      	dup	v7.2d, v1.d[0]
   ab740:      	dup	v16.2d, v2.d[0]
   ab744:      	dup	v17.2d, v3.d[0]
   ab748:      	ldp	q18, q19, [x15, #-0x10]
   ab74c:      	mov	v20.16b, v7.16b
   ab750:      	add	x15, x15, #0x20
   ab754:      	mov	v21.16b, v7.16b
   ab758:      	subs	x17, x17, #0x4
   ab75c:      	fsub	v18.2d, v18.2d, v5.2d
   ab760:      	fsub	v19.2d, v19.2d, v5.2d
   ab764:      	fmla	v20.2d, v18.2d, v6.2d
   ab768:      	fmul	v22.2d, v16.2d, v18.2d
   ab76c:      	fmla	v21.2d, v19.2d, v6.2d
   ab770:      	fmul	v23.2d, v19.2d, v2.d[0]
   ab774:      	fmul	v24.2d, v17.2d, v18.2d
   ab778:      	fmul	v25.2d, v19.2d, v3.d[0]
   ab77c:      	fmla	v20.2d, v18.2d, v22.2d
   ab780:      	fmla	v21.2d, v19.2d, v23.2d
   ab784:      	fmul	v22.2d, v18.2d, v24.2d
   ab788:      	fmul	v23.2d, v19.2d, v25.2d
   ab78c:      	fmla	v20.2d, v18.2d, v22.2d
   ab790:      	fmla	v21.2d, v19.2d, v23.2d
   ab794:      	stp	q20, q21, [x16, #-0x10]
   ab798:      	add	x16, x16, #0x20
   ab79c:      	b.ne	0xab748 <air1_opcal5_algorithm+0x2b64>
   ab7a0:      	cmp	x13, x14
   ab7a4:      	b.eq	0xab7f0 <air1_opcal5_algorithm+0x2c0c>
   ab7a8:      	umull	x11, w8, w11
   ab7ac:      	lsl	x13, x12, #3
   ab7b0:      	add	x14, sp, #0xcb0
   ab7b4:      	add	x15, sp, #0xf80
   ab7b8:      	sub	x11, x12, x11
   ab7bc:      	add	x12, x14, x13
   ab7c0:      	add	x13, x15, x13
   ab7c4:      	ldr	d5, [x13], #0x8
   ab7c8:      	adds	x11, x11, #0x1
   ab7cc:      	fsub	d5, d5, d0
   ab7d0:      	fmadd	d6, d4, d5, d1
   ab7d4:      	fmul	d7, d2, d5
   ab7d8:      	fmul	d16, d3, d5
   ab7dc:      	fmadd	d6, d7, d5, d6
   ab7e0:      	fmul	d7, d5, d16
   ab7e4:      	fmadd	d5, d7, d5, d6
   ab7e8:      	str	d5, [x12], #0x8
   ab7ec:      	b.lo	0xab7c4 <air1_opcal5_algorithm+0x2be0>
   ab7f0:      	ldrh	w11, [x22, #0x58]
   ab7f4:      	add	x12, x10, #0x1
   ab7f8:      	cmp	x10, #0xf
   ab7fc:      	add	w11, w11, w21
   ab800:      	b.hs	0xab80c <air1_opcal5_algorithm+0x2c28>
   ab804:      	mov	x13, xzr
   ab808:      	b	0xab858 <air1_opcal5_algorithm+0x2c74>
   ab80c:      	adrp	x14, 0x9000 <loess_weight_arr+0x7920>
   ab810:      	add	w16, w11, #0x8
   ab814:      	and	x13, x12, #0x1f0
   ab818:      	add	x15, sp, #0x408
   ab81c:      	movi	v0.8h, #0x10
   ab820:      	dup	v2.8h, w11
   ab824:      	ldr	q1, [x14, #0x580]
   ab828:      	add	x14, x15, #0x10
   ab82c:      	mov	x15, x13
   ab830:      	dup	v3.8h, w16
   ab834:      	add	v4.8h, v2.8h, v1.8h
   ab838:      	subs	x15, x15, #0x10
   ab83c:      	add	v5.8h, v3.8h, v1.8h
   ab840:      	add	v1.8h, v1.8h, v0.8h
   ab844:      	stp	q4, q5, [x14, #-0x10]
   ab848:      	add	x14, x14, #0x20
   ab84c:      	b.ne	0xab834 <air1_opcal5_algorithm+0x2c50>
   ab850:      	cmp	x12, x13
   ab854:      	b.eq	0xab870 <air1_opcal5_algorithm+0x2c8c>
   ab858:      	add	x14, sp, #0x408
   ab85c:      	add	w15, w11, w13
   ab860:      	strh	w15, [x14, x13, lsl #1]
   ab864:      	add	x13, x13, #0x1
   ab868:      	cmp	x12, x13
   ab86c:      	b.ne	0xab85c <air1_opcal5_algorithm+0x2c78>
   ab870:      	add	w11, w8, #0x1
   ab874:      	cbz	w8, 0xab924 <air1_opcal5_algorithm+0x2d40>
   ab878:      	scvtf	d0, x27
   ab87c:      	ldr	d1, [sp, #0x3b8]
   ab880:      	adrp	x14, 0x1000 <strcasecmp+0x1000>
   ab884:      	add	x12, sp, #0xf80
   ab888:      	add	x12, x12, #0xe8
   ab88c:      	add	x13, sp, #0x410
   ab890:      	fmov	d2, #0.50000000
   ab894:      	fmov	d3, #-0.50000000
   ab898:      	fdiv	d0, d1, d0
   ab89c:      	ldr	d1, [x14, #0x578]
   ab8a0:      	mov	x14, #0x4059000000000000 // =4636737291354636288
   ab8a4:      	mov	x15, x10
   ab8a8:      	ldr	d4, [x12]
   ab8ac:      	fcmp	d4, d4
   ab8b0:      	b.vs	0xab90c <air1_opcal5_algorithm+0x2d28>
   ab8b4:      	fcmp	d4, #0.0
   ab8b8:      	fcsel	d5, d3, d2, lt
   ab8bc:      	fadd	d4, d4, d5
   ab8c0:      	fcvtzs	d4, d4
   ab8c4:      	scvtf	d4, d4
   ab8c8:      	fcvtzs	x16, d4
   ab8cc:      	add	w16, w9, w16
   ab8d0:      	sub	x16, x16, x25
   ab8d4:      	scvtf	d4, x16
   ab8d8:      	fmadd	d4, d0, d4, d8
   ab8dc:      	fcmp	d4, d4
   ab8e0:      	b.vs	0xab918 <air1_opcal5_algorithm+0x2d34>
   ab8e4:      	fmov	d5, x14
   ab8e8:      	fmadd	d4, d4, d5, d1
   ab8ec:      	fcvtzs	w16, d4
   ab8f0:      	scvtf	d4, w16
   ab8f4:      	fdiv	d4, d4, d5
   ab8f8:      	subs	x15, x15, #0x1
   ab8fc:      	add	x12, x12, #0xf0
   ab900:      	str	d4, [x13], #0x8
   ab904:      	b.ne	0xab8a8 <air1_opcal5_algorithm+0x2cc4>
   ab908:      	b	0xab924 <air1_opcal5_algorithm+0x2d40>
   ab90c:      	mov	x16, #0x7ff8000000000000 // =9221120237041090560
   ab910:      	fmov	d4, x16
   ab914:      	b	0xab8c8 <air1_opcal5_algorithm+0x2ce4>
   ab918:      	mov	x16, #0x7ff8000000000000 // =9221120237041090560
   ab91c:      	fmov	d4, x16
   ab920:      	b	0xab8f8 <air1_opcal5_algorithm+0x2d14>
   ab924:      	cmp	x10, #0x3
   ab928:      	strb	w11, [x24, #0x608]
   ab92c:      	b.hs	0xab940 <air1_opcal5_algorithm+0x2d5c>
   ab930:      	adrp	x27, 0xe8000 <quick_sel_arr+0x1810>
   ab934:      	mov	x11, xzr
   ab938:      	add	x27, x27, #0x2f8
   ab93c:      	b	0xab9a8 <air1_opcal5_algorithm+0x2dc4>
   ab940:      	adrp	x27, 0xe8000 <quick_sel_arr+0x1810>
   ab944:      	add	x11, x26, #0x2
   ab948:      	add	x27, x27, #0x2f8
   ab94c:      	cmp	x11, x27
   ab950:      	b.ls	0xab96c <air1_opcal5_algorithm+0x2d88>
   ab954:      	add	x11, x27, x10, lsl #1
   ab958:      	add	x11, x11, #0xa
   ab95c:      	cmp	x11, x26
   ab960:      	b.ls	0xab96c <air1_opcal5_algorithm+0x2d88>
   ab964:      	mov	x11, xzr
   ab968:      	b	0xab9a8 <air1_opcal5_algorithm+0x2dc4>
   ab96c:      	add	x12, x10, #0x1
   ab970:      	ld1r	{ v0.4h }, [x26]
   ab974:      	and	x11, x12, #0x1fc
   ab978:      	adrp	x15, 0xe8000 <quick_sel_arr+0x1810>
   ab97c:      	add	x13, sp, #0x408
   ab980:      	mov	x14, x11
   ab984:      	add	x15, x15, #0x300
   ab988:      	ldr	d1, [x13], #0x8
   ab98c:      	str	d0, [x15]
   ab990:      	subs	x14, x14, #0x4
   ab994:      	stur	d1, [x15, #-0x8]
   ab998:      	add	x15, x15, #0x8
   ab99c:      	b.ne	0xab988 <air1_opcal5_algorithm+0x2da4>
   ab9a0:      	cmp	x12, x11
   ab9a4:      	b.eq	0xab9dc <air1_opcal5_algorithm+0x2df8>
   ab9a8:      	sub	x12, x10, x11
   ab9ac:      	lsl	x13, x11, #1
   ab9b0:      	add	x11, x12, #0x1
   ab9b4:      	add	x12, x13, x27
   ab9b8:      	add	x14, sp, #0x408
   ab9bc:      	add	x12, x12, #0x8
   ab9c0:      	add	x13, x14, x13
   ab9c4:      	ldrh	w14, [x13], #0x2
   ab9c8:      	subs	x11, x11, #0x1
   ab9cc:      	sturh	w14, [x12, #-0x8]
   ab9d0:      	ldrh	w14, [x26]
   ab9d4:      	strh	w14, [x12], #0x2
   ab9d8:      	b.ne	0xab9c4 <air1_opcal5_algorithm+0x2de0>
   ab9dc:      	cbz	w8, 0xaba74 <air1_opcal5_algorithm+0x2e90>
   ab9e0:      	adrp	x12, 0xe8000 <quick_sel_arr+0x1810>
   ab9e4:      	dup	v0.2s, w9
   ab9e8:      	add	x12, x12, #0x318
   ab9ec:      	mov	x11, xzr
   ab9f0:      	fmov	v1.2d, #0.50000000
   ab9f4:      	add	x13, x12, #0x100
   ab9f8:      	add	x14, sp, #0xf80
   ab9fc:      	add	x15, sp, #0xcb0
   aba00:      	mov	x16, xzr
   aba04:      	mov	x17, x13
   aba08:      	ldr	q2, [x14, x16]
   aba0c:      	add	x2, x12, x16
   aba10:      	ldr	q3, [x15, x16]
   aba14:      	add	x16, x16, #0x10
   aba18:      	cmp	x16, #0xf0
   aba1c:      	fadd	v2.2d, v2.2d, v1.2d
   aba20:      	fadd	v3.2d, v3.2d, v1.2d
   aba24:      	fcvtzu	v2.2d, v2.2d
   aba28:      	fcvtzs	v3.2d, v3.2d
   aba2c:      	xtn	v2.2s, v2.2d
   aba30:      	xtn	v3.2s, v3.2d
   aba34:      	add	v2.2s, v0.2s, v2.2s
   aba38:      	mov	w0, v3.s[1]
   aba3c:      	fmov	w1, s3
   aba40:      	stur	s2, [x17, #-0x10]
   aba44:      	st1	{ v2.s }[1], [x17]
   aba48:      	add	x17, x17, #0x20
   aba4c:      	strh	w1, [x2]
   aba50:      	strh	w0, [x2, #0x8]
   aba54:      	b.ne	0xaba08 <air1_opcal5_algorithm+0x2e24>
   aba58:      	add	x11, x11, #0x1
   aba5c:      	add	x13, x13, #0x4
   aba60:      	add	x14, x14, #0xf0
   aba64:      	add	x15, x15, #0xf0
   aba68:      	add	x12, x12, #0x2
   aba6c:      	cmp	x11, x10
   aba70:      	b.ne	0xaba00 <air1_opcal5_algorithm+0x2e1c>
   aba74:      	add	x12, x27, x10, lsl #2
   aba78:      	add	x13, x27, x10, lsl #1
   aba7c:      	mov	x11, xzr
   aba80:      	add	x12, x12, #0x110
   aba84:      	add	x13, x13, #0x20
   aba88:      	add	x14, x26, #0x6
   aba8c:      	mov	w15, #-0x122            // =-290
   aba90:      	ldrh	w16, [x14], #0x2
   aba94:      	strh	w16, [x13, x11, lsl #1]
   aba98:      	ldur	w16, [x26, #0x2]
   aba9c:      	add	w16, w15, w16
   abaa0:      	add	w15, w15, #0xa
   abaa4:      	str	w16, [x12, x11, lsl #2]
   abaa8:      	add	x11, x11, #0x4
   abaac:      	cmp	x11, #0x78
   abab0:      	b.ne	0xaba90 <air1_opcal5_algorithm+0x2eac>
   abab4:      	cbz	w8, 0xabb0c <air1_opcal5_algorithm+0x2f28>
   abab8:      	add	x11, sp, #0xf80
   ababc:      	adrp	x14, 0xe8000 <quick_sel_arr+0x1810>
   abac0:      	mov	x12, xzr
   abac4:      	add	x11, x11, #0xe8
   abac8:      	fmov	d0, #0.50000000
   abacc:      	add	x13, sp, #0x410
   abad0:      	add	x14, x14, #0x5e8
   abad4:      	ldr	d1, [x11], #0xf0
   abad8:      	lsl	x16, x12, #3
   abadc:      	add	x17, x14, x12, lsl #2
   abae0:      	add	x0, x12, #0x1
   abae4:      	sub	x17, x17, #0x2e0
   abae8:      	fadd	d1, d1, d0
   abaec:      	mov	x12, x0
   abaf0:      	cmp	x10, x0
   abaf4:      	fcvtzu	w15, d1
   abaf8:      	ldr	d1, [x13, x16]
   abafc:      	add	w15, w9, w15
   abb00:      	str	d1, [x14, x16]
   abb04:      	str	w15, [x17]
   abb08:      	b.ne	0xabad4 <air1_opcal5_algorithm+0x2ef0>
   abb0c:      	ldur	w9, [x26, #0x2]
   abb10:      	add	x11, x27, x10, lsl #2
   abb14:      	str	w9, [x11, #0x10]
   abb18:      	add	x9, x27, x10, lsl #3
   abb1c:      	ldur	d0, [x26, #0x42]
   abb20:      	str	d0, [x9, #0x2f0]
   abb24:      	ldrh	w9, [x22, #0x58]
   abb28:      	add	w8, w9, w8
   abb2c:      	strh	w8, [x22, #0x58]
   abb30:      	add	x8, x22, #0x14
   abb34:      	add	x9, x26, #0x42
   abb38:      	cmp	x8, x9
   abb3c:      	b.hs	0xabb58 <air1_opcal5_algorithm+0x2f74>
   abb40:      	add	x8, x22, #0x50
   abb44:      	add	x9, x26, #0x6
   abb48:      	cmp	x9, x8
   abb4c:      	b.hs	0xabb58 <air1_opcal5_algorithm+0x2f74>
   abb50:      	mov	x8, xzr
   abb54:      	b	0xabb74 <air1_opcal5_algorithm+0x2f90>
   abb58:      	ldur	q0, [x26, #0x6]
   abb5c:      	mov	w8, #0x18               // =24
   abb60:      	stur	q0, [x22, #0x14]
   abb64:      	ldur	q0, [x26, #0x16]
   abb68:      	stur	q0, [x22, #0x24]
   abb6c:      	ldur	q0, [x26, #0x26]
   abb70:      	stur	q0, [x22, #0x34]
   abb74:      	lsl	x8, x8, #1
   abb78:      	add	x9, x26, #0x6
   abb7c:      	ldrh	w10, [x9, x8]
   abb80:      	add	x11, x22, x8
   abb84:      	add	x8, x8, #0x2
   abb88:      	cmp	x8, #0x3c
   abb8c:      	strh	w10, [x11, #0x14]
   abb90:      	b.ne	0xabb7c <air1_opcal5_algorithm+0x2f98>
   abb94:      	ldrh	w8, [x26]
   abb98:      	strh	w8, [x22, #0x10]
   abb9c:      	ldur	w8, [x26, #0x2]
   abba0:      	str	w8, [x22, #0xc]
   abba4:      	ldur	d0, [x26, #0x42]
   abba8:      	str	d0, [x22, #0x50]
   abbac:      	ldrb	w8, [x24, #0x608]
   abbb0:      	cbz	w8, 0xa8d6c <air1_opcal5_algorithm+0x188>
   abbb4:      	mov	w8, #0x1d30             // =7472
   abbb8:      	add	x9, x22, #0x252
   abbbc:      	add	x8, x22, x8
   abbc0:      	add	x11, x22, #0x910
   abbc4:      	adrp	x13, 0xe8000 <quick_sel_arr+0x1810>
   abbc8:      	add	x10, x22, #0x820
   abbcc:      	add	x13, x13, #0xe90
   abbd0:      	add	x26, sp, #0xf80
   abbd4:      	stp	x8, x9, [sp, #0x1f8]
   abbd8:      	mov	w8, #0x1da0             // =7584
   abbdc:      	add	x8, x22, x8
   abbe0:      	mov	w9, #0x1c58             // =7256
   abbe4:      	add	x9, x22, x9
   abbe8:      	str	x10, [sp, #0x1c8]
   abbec:      	add	x25, sp, #0x9e0
   abbf0:      	adrp	x21, 0xe8000 <quick_sel_arr+0x1810>
   abbf4:      	str	x8, [sp, #0x1f0]
   abbf8:      	mov	w8, #0x1df0             // =7664
   abbfc:      	add	x8, x22, x8
   abc00:      	str	x9, [sp, #0x188]
   abc04:      	fmov	v4.2d, #10.00000000
   abc08:      	mov	x12, xzr
   abc0c:      	add	x21, x21, #0xcd0
   abc10:      	add	x28, sp, #0x710
   abc14:      	str	x8, [sp, #0x1e8]
   abc18:      	mov	w8, #0x1da8             // =7592
   abc1c:      	add	x8, x22, x8
   abc20:      	mov	x14, x3
   abc24:      	str	x23, [sp, #0x208]
   abc28:      	str	q4, [sp, #0x160]
   abc2c:      	str	x8, [sp, #0x1e0]
   abc30:      	mov	w8, #0x1df8             // =7672
   abc34:      	add	x8, x22, x8
   abc38:      	str	x8, [sp, #0x1d8]
   abc3c:      	mov	w8, #0x1c10             // =7184
   abc40:      	add	x8, x22, x8
   abc44:      	str	x8, [sp, #0x1d0]
   abc48:      	mov	w8, #0x1b68             // =7016
   abc4c:      	add	x8, x22, x8
   abc50:      	str	x8, [sp, #0x68]
   abc54:      	mov	w8, #0x3b40             // =15168
   abc58:      	add	x8, x22, x8
   abc5c:      	str	x8, [sp, #0x1c0]
   abc60:      	mov	w8, #0x3b68             // =15208
   abc64:      	add	x8, x22, x8
   abc68:      	str	x8, [sp, #0x1b8]
   abc6c:      	mov	w8, #0x40e0             // =16608
   abc70:      	add	x8, x22, x8
   abc74:      	str	x8, [sp, #0x1b0]
   abc78:      	mov	w8, #0x40f4             // =16628
   abc7c:      	add	x8, x22, x8
   abc80:      	str	x8, [sp, #0x1a8]
   abc84:      	mov	w8, #0x1c40             // =7232
   abc88:      	add	x8, x22, x8
   abc8c:      	stp	x11, x8, [sp, #0x28]
   abc90:      	mov	w8, #0x32d0             // =13008
   abc94:      	add	x8, x22, x8
   abc98:      	str	x8, [sp, #0x1a0]
   abc9c:      	mov	w8, #0x43b0             // =17328
   abca0:      	add	x8, x22, x8
   abca4:      	str	x8, [sp, #0x198]
   abca8:      	mov	w8, #0x43d8             // =17368
   abcac:      	add	x8, x22, x8
   abcb0:      	str	x8, [sp, #0x190]
   abcb4:      	add	x8, x13, #0xf0
   abcb8:      	cmp	x10, x8
   abcbc:      	mov	w10, #0x1e78            // =7800
   abcc0:      	cset	w8, lo
   abcc4:      	cmp	x11, x13
   abcc8:      	cset	w9, hi
   abccc:      	add	x11, x22, #0x6d8
   abcd0:      	and	w8, w8, w9
   abcd4:      	mov	w9, #0x3288             // =12936
   abcd8:      	add	x9, x22, x9
   abcdc:      	str	w8, [sp, #0x184]
   abce0:      	mov	w8, #0x1c9c             // =7324
   abce4:      	add	x8, x22, x8
   abce8:      	str	x9, [sp, #0x58]
   abcec:      	add	x9, x22, x10
   abcf0:      	add	x10, x22, #0x700
   abcf4:      	str	x8, [sp, #0x20]
   abcf8:      	mov	w8, #0x1c94             // =7316
   abcfc:      	add	x8, x22, x8
   abd00:      	str	x8, [sp, #0xb0]
   abd04:      	mov	w8, #0x1c48             // =7240
   abd08:      	add	x8, x22, x8
   abd0c:      	str	x8, [sp, #0x60]
   abd10:      	mov	w8, #0x1cb9             // =7353
   abd14:      	add	x8, x22, x8
   abd18:      	str	x8, [sp, #0x88]
   abd1c:      	adrp	x8, 0x1000 <strcasecmp+0x1000>
   abd20:      	ldr	d11, [x8, #0x600]
   abd24:      	mov	x8, #0x7ff8000000000000 // =9221120237041090560
   abd28:      	dup	v0.2d, x8
   abd2c:      	add	x8, x22, #0x254
   abd30:      	str	d11, [sp, #0x178]
   abd34:      	str	q0, [sp, #0x40]
   abd38:      	stp	x8, x9, [sp, #0x150]
   abd3c:      	add	x9, x22, #0x64
   abd40:      	add	x8, x22, #0xdc
   abd44:      	stp	x8, x9, [sp, #0x140]
   abd48:      	add	x9, x22, #0x1d0
   abd4c:      	add	x8, x22, #0x1d4
   abd50:      	stp	x8, x9, [sp, #0x130]
   abd54:      	add	x8, x5, #0xb0
   abd58:      	add	x9, x4, #0x220
   abd5c:      	str	x8, [sp, #0x3a8]
   abd60:      	add	x8, x6, #0xea
   abd64:      	stp	x8, x9, [sp, #0x120]
   abd68:      	add	x8, x22, #0x728
   abd6c:      	add	x9, sp, #0xcb0
   abd70:      	str	x8, [sp, #0x250]
   abd74:      	add	x8, x26, #0x28
   abd78:      	stp	x8, x11, [sp, #0x78]
   abd7c:      	add	x8, x9, #0x28
   abd80:      	stp	x8, x10, [sp, #0xc0]
   abd84:      	add	x8, x9, #0xf0
   abd88:      	add	x10, x26, #0x1e0
   abd8c:      	str	x8, [sp, #0x70]
   abd90:      	add	x8, x22, #0x730
   abd94:      	str	x8, [sp, #0x248]
   abd98:      	add	x8, x9, #0x1e0
   abd9c:      	add	x9, x22, #0x928
   abda0:      	stp	x8, x10, [sp, #0x10]
   abda4:      	add	x8, x26, #0x18
   abda8:      	add	x10, x22, #0x1cc
   abdac:      	str	x8, [sp, #0x38]
   abdb0:      	add	x8, x22, #0x930
   abdb4:      	stp	x8, x9, [sp, #0x110]
   abdb8:      	add	x8, x5, #0x8
   abdbc:      	add	x9, x5, #0x48
   abdc0:      	str	x8, [sp, #0x8]
   abdc4:      	add	x8, x22, #0x5c
   abdc8:      	stp	x8, x9, [sp, #0x100]
   abdcc:      	add	x9, x22, #0x5d
   abdd0:      	orr	x8, x25, #0x1
   abdd4:      	stp	x8, x9, [sp, #0xf0]
   abdd8:      	mov	w8, #0x1cb8             // =7352
   abddc:      	add	x8, x22, x8
   abde0:      	str	x8, [sp, #0xb8]
   abde4:      	add	x8, x22, #0x154
   abde8:      	str	x8, [sp, #0x258]
   abdec:      	ldr	x8, [sp, #0x240]
   abdf0:      	add	x9, x8, #0x1f4
   abdf4:      	add	x8, x8, #0x2bd
   abdf8:      	stp	x9, x10, [sp, #0xa0]
   abdfc:      	adrp	x9, 0xe8000 <quick_sel_arr+0x1810>
   abe00:      	add	x9, x9, #0x408
   abe04:      	str	x8, [sp, #0x90]
   abe08:      	mov	x8, #0xfe0000000000     // =279275953455104
   abe0c:      	movk	x8, #0x40af, lsl #48
   abe10:      	str	x9, [sp, #0x3c0]
   abe14:      	mov	x9, #0x400000000000     // =70368744177664
   abe18:      	movk	x9, #0x408f, lsl #48
   abe1c:      	dup	v5.2d, x8
   abe20:      	dup	v6.2d, x9
   abe24:      	stp	q6, q5, [sp, #0xd0]
   abe28:      	add	x0, x21, #0x8
   abe2c:      	mov	w1, wzr
   abe30:      	mov	w2, #0x9c0              // =2496
   abe34:      	str	x14, [sp, #0x388]
   abe38:      	mov	x23, x12
   abe3c:      	bl	0xbefc0 <memset@plt>
   abe40:      	adrp	x8, 0xe8000 <quick_sel_arr+0x1810>
   abe44:      	mov	x0, x20
   abe48:      	movi	v0.2d, #0000000000000000
   abe4c:      	add	x8, x8, #0x610
   abe50:      	mov	w1, wzr
   abe54:      	mov	w2, #0x61e              // =1566
   abe58:      	stp	q0, q0, [x8]
   abe5c:      	stp	q0, q0, [x8, #0x20]
   abe60:      	stp	q0, q0, [x8, #0x40]
   abe64:      	stp	q0, q0, [x8, #0x60]
   abe68:      	str	q0, [x8, #0x80]
   abe6c:      	stur	q0, [x8, #0x8b]
   abe70:      	bl	0xbefc0 <memset@plt>
   abe74:      	add	x8, x27, x23, lsl #1
   abe78:      	add	x10, x27, x23, lsl #3
   abe7c:      	add	x9, x8, #0x20
   abe80:      	mov	x14, x8
   abe84:      	add	x19, x27, x23, lsl #2
   abe88:      	str	x23, [sp, #0x3b8]
   abe8c:      	mov	x13, x19
   abe90:      	ldr	d4, [x10, #0x2f0]
   abe94:      	ld4	{ v0.4h, v1.4h, v2.4h, v3.4h }, [x9]
   abe98:      	mov	w2, #0x47e              // =1150
   abe9c:      	str	d4, [x21, #0x48]
   abea0:      	ldrh	w10, [x14, #0x8]!
   abea4:      	ldrh	w11, [x8]
   abea8:      	str	x14, [sp, #0x2b8]
   abeac:      	ldr	w12, [x13, #0x10]!
   abeb0:      	add	x23, x13, #0x100
   abeb4:      	strh	w10, [x21, #0x2]
   abeb8:      	mov	x10, x23
   abebc:      	strh	w11, [x21]
   abec0:      	str	w12, [x21, #0x4]
   abec4:      	add	x11, sp, #0x300
   abec8:      	str	d0, [x21, #0x8]
   abecc:      	add	x24, x13, #0x2d4
   abed0:      	ld4	{ v20.4s, v21.4s, v22.4s, v23.4s }, [x10], #64
   abed4:      	str	q20, [x21, #0x50]
   abed8:      	ldrh	w9, [x9, #0xe8]
   abedc:      	ldrh	w27, [x22, #0x250]
   abee0:      	ldr	x0, [sp, #0x200]
   abee4:      	ld4	{ v0.4s, v1.4s, v2.4s, v3.4s }, [x10]
   abee8:      	add	x10, sp, #0x340
   abeec:      	strh	w9, [x21, #0x42]
   abef0:      	add	w9, w27, #0x1
   abef4:      	ldr	x1, [sp, #0x150]
   abef8:      	st1	{ v0.2d, v1.2d, v2.2d, v3.2d }, [x10]
   abefc:      	add	x10, x13, #0x180
   abf00:      	ld4	{ v0.4s, v1.4s, v2.4s, v3.4s }, [x10]
   abf04:      	add	x10, sp, #0x300
   abf08:      	st1	{ v0.2d, v1.2d, v2.2d, v3.2d }, [x10]
   abf0c:      	add	x10, x13, #0x1c0
   abf10:      	ld4	{ v0.4s, v1.4s, v2.4s, v3.4s }, [x10]
   abf14:      	add	x10, sp, #0x2c0
   abf18:      	st1	{ v0.2d, v1.2d, v2.2d, v3.2d }, [x10]
   abf1c:      	add	x10, x13, #0x200
   abf20:      	ld4	{ v0.4s, v1.4s, v2.4s, v3.4s }, [x10]
   abf24:      	add	x10, sp, #0x270
   abf28:      	st1	{ v0.2d, v1.2d, v2.2d, v3.2d }, [x10]
   abf2c:      	add	x10, x13, #0x240
   abf30:      	ld4	{ v28.4s, v29.4s, v30.4s, v31.4s }, [x10]
   abf34:      	add	x10, x13, #0x280
   abf38:      	ld4	{ v8.4s, v9.4s, v10.4s, v11.4s }, [x10]
   abf3c:      	add	x10, x8, #0x40
   abf40:      	ld4	{ v12.4h, v13.4h, v14.4h, v15.4h }, [x10]
   abf44:      	add	x10, x8, #0x60
   abf48:      	stp	q28, q8, [x21, #0xa0]
   abf4c:      	ld4	{ v0.4h, v1.4h, v2.4h, v3.4h }, [x10]
   abf50:      	add	x10, x8, #0x80
   abf54:      	ld4	{ v16.4h, v17.4h, v18.4h, v19.4h }, [x10]
   abf58:      	add	x10, x8, #0xa0
   abf5c:      	stp	d12, d0, [x21, #0x10]
   abf60:      	ld4	{ v4.4h, v5.4h, v6.4h, v7.4h }, [x10]
   abf64:      	add	x10, x8, #0xc0
   abf68:      	ld4	{ v20.4h, v21.4h, v22.4h, v23.4h }, [x10]
   abf6c:      	add	x10, sp, #0x340
   abf70:      	stp	d16, d4, [x21, #0x20]
   abf74:      	ld1	{ v24.2d, v25.2d, v26.2d, v27.2d }, [x10]
   abf78:      	add	x10, x8, #0xe0
   abf7c:      	ld1	{ v0.2d, v1.2d, v2.2d, v3.2d }, [x11]
   abf80:      	ldrh	w8, [x8, #0x100]
   abf84:      	stp	q24, q0, [x21, #0x60]
   abf88:      	ld4	{ v0.4h, v1.4h, v2.4h, v3.4h }, [x10]
   abf8c:      	add	x10, sp, #0x2c0
   abf90:      	strh	w8, [x21, #0x40]
   abf94:      	ld1	{ v24.2d, v25.2d, v26.2d, v27.2d }, [x10]
   abf98:      	add	x10, sp, #0x270
   abf9c:      	str	x13, [sp, #0x2c0]
   abfa0:      	stp	d20, d0, [x21, #0x30]
   abfa4:      	ld1	{ v4.2d, v5.2d, v6.2d, v7.2d }, [x10]
   abfa8:      	str	w9, [sp, #0x270]
   abfac:      	ldr	w10, [x13, #0x2c0]
   abfb0:      	ldr	w8, [x13, #0x2d0]
   abfb4:      	strh	w9, [x22, #0x250]
   abfb8:      	stp	q24, q4, [x21, #0x80]
   abfbc:      	stp	w10, w8, [x21, #0xc0]
   abfc0:      	bl	0xbf050 <memmove@plt>
   abfc4:      	ldp	x1, x0, [sp, #0x140]
   abfc8:      	mov	w2, #0xf0               // =240
   abfcc:      	ldrh	w8, [x21]
   abfd0:      	strh	w8, [x22, #0x6d0]
   abfd4:      	bl	0xbf050 <memmove@plt>
   abfd8:      	ldr	x8, [sp, #0x258]
   abfdc:      	cmp	x8, x24
   abfe0:      	b.hs	0xabff8 <air1_opcal5_algorithm+0x3414>
   abfe4:      	ldr	x8, [sp, #0xa8]
   abfe8:      	cmp	x23, x8
   abfec:      	b.hs	0xabff8 <air1_opcal5_algorithm+0x3414>
   abff0:      	mov	x9, xzr
   abff4:      	b	0xac054 <air1_opcal5_algorithm+0x3470>
   abff8:      	add	x8, x19, #0x110
   abffc:      	mov	x9, x8
   ac000:      	ld4	{ v0.4s, v1.4s, v2.4s, v3.4s }, [x9], #64
   ac004:      	ldr	x10, [sp, #0x98]
   ac008:      	str	q0, [x10]
   ac00c:      	ld4	{ v0.4s, v1.4s, v2.4s, v3.4s }, [x9]
   ac010:      	add	x9, x8, #0x80
   ac014:      	str	q0, [x10, #0x10]
   ac018:      	ld4	{ v0.4s, v1.4s, v2.4s, v3.4s }, [x9]
   ac01c:      	add	x9, x8, #0xc0
   ac020:      	str	q0, [x10, #0x20]
   ac024:      	ld4	{ v0.4s, v1.4s, v2.4s, v3.4s }, [x9]
   ac028:      	add	x9, x8, #0x100
   ac02c:      	str	q0, [x10, #0x30]
   ac030:      	ld4	{ v0.4s, v1.4s, v2.4s, v3.4s }, [x9]
   ac034:      	add	x9, x8, #0x140
   ac038:      	add	x8, x8, #0x180
   ac03c:      	str	q0, [x10, #0x40]
   ac040:      	ld4	{ v0.4s, v1.4s, v2.4s, v3.4s }, [x9]
   ac044:      	mov	w9, #0x1c               // =28
   ac048:      	str	q0, [x10, #0x50]
   ac04c:      	ld4	{ v0.4s, v1.4s, v2.4s, v3.4s }, [x8]
   ac050:      	str	q0, [x10, #0x60]
   ac054:      	ldr	x8, [sp, #0x390]
   ac058:      	mov	w11, #0x9b              // =155
   ac05c:      	ldr	x10, [sp, #0x3b8]
   ac060:      	adrp	x24, 0xe9000 <g_algo+0x330>
   ac064:      	ldr	x12, [sp, #0x3a0]
   ac068:      	movi	d9, #0000000000000000
   ac06c:      	movi	v13.2s, #0x1
   ac070:      	movi	d15, #0x0000ff000000ff
   ac074:      	madd	x11, x10, x11, x8
   ac078:      	mov	w8, #0x61e              // =1566
   ac07c:      	add	x19, sp, #0x430
   ac080:      	add	x24, x24, #0x6a0
   ac084:      	madd	x8, x10, x8, x12
   ac088:      	add	x10, x11, #0x9b
   ac08c:      	ldr	d11, [sp, #0x178]
   ac090:      	fmov	d12, #1.00000000
   ac094:      	fmov	d14, #0.50000000
   ac098:      	fmov	d8, #1.50000000
   ac09c:      	str	x10, [sp, #0x260]
   ac0a0:      	ldr	x10, [sp, #0x3c0]
   ac0a4:      	str	x8, [sp, #0x340]
   ac0a8:      	add	x8, x8, #0x61e
   ac0ac:      	fmov	d10, #6.00000000
   ac0b0:      	add	x21, sp, #0xcb0
   ac0b4:      	adrp	x23, 0x1000 <strcasecmp+0x1000>
   ac0b8:      	str	x11, [sp, #0x300]
   ac0bc:      	str	x8, [sp, #0x268]
   ac0c0:      	add	x8, x9, #0x55
   ac0c4:      	add	x9, x10, x9, lsl #4
   ac0c8:      	ldr	w10, [x9], #0x10
   ac0cc:      	str	w10, [x22, x8, lsl #2]
   ac0d0:      	add	x8, x8, #0x1
   ac0d4:      	cmp	x8, #0x73
   ac0d8:      	b.ne	0xac0c8 <air1_opcal5_algorithm+0x34e4>
   ac0dc:      	ldp	x1, x0, [sp, #0x130]
   ac0e0:      	mov	w2, #0x7c               // =124
   ac0e4:      	bl	0xbf050 <memmove@plt>
   ac0e8:      	adrp	x8, 0xe8000 <quick_sel_arr+0x1810>
   ac0ec:      	adrp	x14, 0xe8000 <quick_sel_arr+0x1810>
   ac0f0:      	ldp	q6, q5, [sp, #0xd0]
   ac0f4:      	add	x14, x14, #0xcd0
   ac0f8:      	mov	x17, #-0x8000000000000000 // =-9223372036854775808
   ac0fc:      	adrp	x0, 0x1000 <strcasecmp+0x1000>
   ac100:      	adrp	x1, 0x1000 <strcasecmp+0x1000>
   ac104:      	mov	x2, #-0x7fffffffffffffff // =-9223372036854775807
   ac108:      	ldr	w8, [x8, #0xcd4]
   ac10c:      	ldr	x11, [sp, #0x398]
   ac110:      	ldr	x12, [sp, #0x3c8]
   ac114:      	ldr	x13, [sp, #0x210]
   ac118:      	str	w8, [x22, #0x24c]
   ac11c:      	ldr	q1, [sp, #0x3f0]
   ac120:      	ldr	q4, [sp, #0x160]
   ac124:      	ldr	x16, [sp, #0xf0]
   ac128:      	cbnz	w27, 0xac22c <air1_opcal5_algorithm+0x3648>
   ac12c:      	mov	w9, #0x1                // =1
   ac130:      	mov	w10, #0xff              // =255
   ac134:      	movi	v2.2d, #0000000000000000
   ac138:      	ldr	q0, [sp, #0x230]
   ac13c:      	mov	x15, #0x3ff0000000000000 // =4607182418800017408
   ac140:      	str	q1, [x22, #0x1d30]
   ac144:      	strb	w9, [x12, #0x9f]
   ac148:      	ldr	x9, [sp, #0x3e8]
   ac14c:      	str	q1, [x22, #0x1d40]
   ac150:      	str	q2, [x22, #0x1d70]
   ac154:      	strb	w10, [x9]
   ac158:      	mov	x9, #-0x1450            // =-5200
   ac15c:      	str	q2, [x22, #0x1d80]
   ac160:      	str	q1, [x22, #0x1d50]
   ac164:      	str	q0, [x22, #0x1d60]
   ac168:      	str	q2, [x22, #0x1d90]
   ac16c:      	str	q1, [x22, #0x1da0]
   ac170:      	str	q2, [x22, #0x1df0]
   ac174:      	str	q1, [x22, #0x1db0]
   ac178:      	str	q2, [x22, #0x1e00]
   ac17c:      	str	q1, [x22, #0x1dc0]
   ac180:      	str	q2, [x22, #0x1e10]
   ac184:      	str	q1, [x22, #0x1dd0]
   ac188:      	str	q2, [x22, #0x1e20]
   ac18c:      	str	q1, [x22, #0x1de0]
   ac190:      	str	q2, [x22, #0x1e30]
   ac194:      	add	x10, x22, x9
   ac198:      	adds	x9, x9, #0x68
   ac19c:      	str	x15, [x10, #0x32b8]
   ac1a0:      	str	x15, [x10, #0x32e0]
   ac1a4:      	b.ne	0xac194 <air1_opcal5_algorithm+0x35b0>
   ac1a8:      	adrp	x9, 0xe9000 <g_algo+0x330>
   ac1ac:      	mov	w10, #0x6               // =6
   ac1b0:      	add	x9, x9, #0x9d8
   ac1b4:      	str	wzr, [x22, #0x1b28]
   ac1b8:      	strh	wzr, [x22, #0x1b2c]
   ac1bc:      	strh	wzr, [x22, #0x1b60]
   ac1c0:      	ldp	d0, d1, [x9]
   ac1c4:      	strb	w10, [x12]
   ac1c8:      	ldr	x9, [sp, #0x3a8]
   ac1cc:      	stp	xzr, xzr, [x11]
   ac1d0:      	ldr	x10, [sp, #0x68]
   ac1d4:      	str	d0, [x22, #0x32c0]
   ac1d8:      	strh	wzr, [x9, #0x4]
   ac1dc:      	fsub	d0, d12, d1
   ac1e0:      	str	wzr, [x9]
   ac1e4:      	mov	w9, #0x1                // =1
   ac1e8:      	str	d1, [x22, #0x32b0]
   ac1ec:      	ldr	q1, [sp, #0x40]
   ac1f0:      	strb	w9, [x12, #0xc3]
   ac1f4:      	mov	x9, #0x7ff8000000000000 // =9221120237041090560
   ac1f8:      	str	d0, [x22, #0x32b8]
   ac1fc:      	movi	v0.2d, #0000000000000000
   ac200:      	stur	q1, [x12, #0xca]
   ac204:      	str	x9, [x22, #0x1c28]
   ac208:      	str	x9, [x22, #0x1b40]
   ac20c:      	mov	w9, #0x64               // =100
   ac210:      	stur	q1, [x12, #0xda]
   ac214:      	stur	q1, [x12, #0xea]
   ac218:      	strb	w9, [x12, #0x34]
   ac21c:      	sub	w9, w8, #0x122
   ac220:      	str	q1, [x22, #0x1b30]
   ac224:      	stp	q0, q0, [x10]
   ac228:      	str	w9, [x22, #0x3348]
   ac22c:      	adrp	x11, 0xe9000 <g_algo+0x330>
   ac230:      	ldr	w10, [x22, #0x4]
   ac234:      	mov	x9, xzr
   ac238:      	ldrh	w11, [x11, #0x6bc]
   ac23c:      	add	w10, w10, w11
   ac240:      	sub	w10, w10, #0x78
   ac244:      	cmp	w10, w8
   ac248:      	adrp	x8, 0xe8000 <quick_sel_arr+0x1810>
   ac24c:      	cset	w10, ls
   ac250:      	add	x8, x8, #0xd98
   ac254:      	strb	w10, [x8], #0x8
   ac258:      	ldp	s1, s0, [x13]
   ac25c:      	fcvt	d0, s0
   ac260:      	fneg	d2, d0
   ac264:      	fcvt	d0, s1
   ac268:      	dup	v0.2d, v0.d[0]
   ac26c:      	dup	v1.2d, v2.d[0]
   ac270:      	add	x10, x14, x9
   ac274:      	add	x9, x9, #0x4
   ac278:      	mov	v3.16b, v1.16b
   ac27c:      	cmp	x9, #0x3c
   ac280:      	ldrh	w11, [x10, #0x8]
   ac284:      	ldrh	w10, [x10, #0xa]
   ac288:      	fmov	s2, w11
   ac28c:      	mov	v2.s[1], w10
   ac290:      	ushll	v2.2d, v2.2s, #0x0
   ac294:      	ucvtf	v2.2d, v2.2d
   ac298:      	fdiv	v2.2d, v2.2d, v4.2d
   ac29c:      	fdiv	v2.2d, v2.2d, v5.2d
   ac2a0:      	fmla	v3.2d, v0.2d, v2.2d
   ac2a4:      	fdiv	v2.2d, v3.2d, v4.2d
   ac2a8:      	fmul	v2.2d, v2.2d, v6.2d
   ac2ac:      	str	q2, [x8], #0x10
   ac2b0:      	b.ne	0xac270 <air1_opcal5_algorithm+0x368c>
   ac2b4:      	ldr	w27, [sp, #0x270]
   ac2b8:      	adrp	x3, 0x1000 <strcasecmp+0x1000>
   ac2bc:      	and	w8, w27, #0xffff
   ac2c0:      	cmp	w8, #0x1
   ac2c4:      	b.ls	0xac8f0 <air1_opcal5_algorithm+0x3d0c>
   ac2c8:      	ldr	x10, [sp, #0x80]
   ac2cc:      	mov	x15, x14
   ac2d0:      	ldr	x11, [sp, #0xc8]
   ac2d4:      	mov	x8, xzr
   ac2d8:      	ldp	q4, q5, [x14, #0xd0]
   ac2dc:      	mov	w9, wzr
   ac2e0:      	ldp	q0, q1, [x10]
   ac2e4:      	str	q0, [x19, #0xb50]
   ac2e8:      	ldp	q2, q3, [x11]
   ac2ec:      	str	q1, [x19, #0xb60]
   ac2f0:      	str	q2, [x19, #0x880]
   ac2f4:      	ldp	q16, q7, [x14, #0x120]
   ac2f8:      	str	q3, [x19, #0x890]
   ac2fc:      	ldp	q0, q2, [x14, #0x1a0]
   ac300:      	ldp	q22, q21, [x14, #0x140]
   ac304:      	ldr	x12, [sp, #0x78]
   ac308:      	ldp	q6, q18, [x14, #0xf0]
   ac30c:      	stp	q4, q5, [x12]
   ac310:      	stp	q7, q22, [x12, #0x60]
   ac314:      	stp	q0, q2, [x12, #0xd0]
   ac318:      	ldp	q4, q17, [x14, #0x100]
   ac31c:      	stp	q6, q18, [x12, #0x20]
   ac320:      	ldp	q2, q7, [x14, #0x180]
   ac324:      	stp	q17, q16, [x12, #0x40]
   ac328:      	ldp	q20, q19, [x14, #0x160]
   ac32c:      	stp	q21, q20, [x12, #0x80]
   ac330:      	ldr	q1, [x14, #0x180]
   ac334:      	str	q19, [x12, #0xa0]
   ac338:      	ldr	x10, [x10, #0x20]
   ac33c:      	ldr	x11, [x11, #0x20]
   ac340:      	ldr	x13, [sp, #0x250]
   ac344:      	stp	q1, q7, [x12, #0xb0]
   ac348:      	ldp	q23, q16, [x14, #0xd0]
   ac34c:      	str	x10, [x19, #0xb70]
   ac350:      	str	x11, [x19, #0x8a0]
   ac354:      	ldp	q6, q18, [x14, #0x140]
   ac358:      	ldp	q5, q20, [x14, #0x110]
   ac35c:      	ldp	q0, q7, [x14, #0x160]
   ac360:      	ldrh	w10, [x13, #0x4]
   ac364:      	ldrh	w11, [x15]
   ac368:      	ldr	q3, [x14, #0x1a0]
   ac36c:      	ldr	q17, [x14, #0xf0]
   ac370:      	strh	w10, [sp, #0x9e4]
   ac374:      	ldr	q21, [x14, #0x130]
   ac378:      	sub	w10, w11, #0x1
   ac37c:      	ldr	q22, [x14, #0x190]
   ac380:      	ldr	q1, [x14, #0x1b0]
   ac384:      	ldr	x14, [sp, #0xc0]
   ac388:      	ldr	w12, [x13]
   ac38c:      	ldr	x11, [sp, #0x258]
   ac390:      	stp	q22, q3, [x14, #0xc0]
   ac394:      	str	q1, [x14, #0xe0]
   ac398:      	stp	q18, q0, [x14, #0x80]
   ac39c:      	stp	q7, q2, [x14, #0xa0]
   ac3a0:      	stp	q5, q20, [x14, #0x40]
   ac3a4:      	stp	q21, q6, [x14, #0x60]
   ac3a8:      	stp	q23, q16, [x14]
   ac3ac:      	str	w12, [sp, #0x9e0]
   ac3b0:      	stp	q17, q4, [x14, #0x20]
   ac3b4:      	b	0xac3dc <air1_opcal5_algorithm+0x37f8>
   ac3b8:      	ldrb	w12, [x16, #0x4]
   ac3bc:      	ldr	w13, [x16]
   ac3c0:      	strb	w12, [sp, #0x9e4]
   ac3c4:      	str	w13, [sp, #0x9e0]
   ac3c8:      	strb	wzr, [sp, #0x9e5]
   ac3cc:      	add	x8, x8, #0x8
   ac3d0:      	add	x11, x11, #0x4
   ac3d4:      	cmp	x8, #0xf0
   ac3d8:      	b.eq	0xac968 <air1_opcal5_algorithm+0x3d84>
   ac3dc:      	ldr	w12, [x11]
   ac3e0:      	ldur	w13, [x11, #-0x14]
   ac3e4:      	sub	x12, x12, x13
   ac3e8:      	cmp	x12, #0x3a
   ac3ec:      	csinc	w9, w9, wzr, ge
   ac3f0:      	and	w12, w9, #0xff
   ac3f4:      	cmp	w12, #0x1
   ac3f8:      	b.ne	0xac3b8 <air1_opcal5_algorithm+0x37d4>
   ac3fc:      	ldr	s0, [sp, #0x9e0]
   ac400:      	ldrsb	w12, [sp, #0x9e4]
   ac404:      	ldrsb	w13, [sp, #0x9e5]
   ac408:      	sshll	v0.8h, v0.8b, #0x0
   ac40c:      	ldr	w15, [x16]
   ac410:      	cmp	w12, #0x0
   ac414:      	cneg	w12, w12, mi
   ac418:      	cmp	w13, #0x0
   ac41c:      	cneg	w13, w13, mi
   ac420:      	abs	v0.4h, v0.4h
   ac424:      	addv	h0, v0.4h
   ac428:      	fmov	w14, s0
   ac42c:      	add	w12, w14, w12
   ac430:      	add	w12, w12, w13
   ac434:      	add	x13, x26, x8
   ac438:      	and	w12, w12, #0xff
   ac43c:      	cmp	w12, #0x3
   ac440:      	ldrb	w12, [x16, #0x4]
   ac444:      	csel	x14, x21, x26, hi
   ac448:      	ldr	d3, [x13, #0x28]
   ac44c:      	add	x14, x14, x8
   ac450:      	ldrh	w13, [x22, #0x6ce]
   ac454:      	str	w15, [sp, #0x9e0]
   ac458:      	strb	w12, [sp, #0x9e4]
   ac45c:      	ldp	d2, d6, [x14]
   ac460:      	cmp	w10, w13
   ac464:      	ldp	d5, d4, [x14, #0x10]
   ac468:      	ldr	d1, [x14, #0x20]
   ac46c:      	b.ne	0xac3c8 <air1_opcal5_algorithm+0x37e4>
   ac470:      	fcmp	d2, d6
   ac474:      	fcsel	d0, d6, d2, gt
   ac478:      	fcsel	d7, d2, d6, gt
   ac47c:      	fcmp	d0, d5
   ac480:      	fcsel	d16, d5, d0, gt
   ac484:      	fcsel	d0, d0, d5, gt
   ac488:      	fcmp	d16, d4
   ac48c:      	fcsel	d17, d4, d16, gt
   ac490:      	fcsel	d16, d16, d4, gt
   ac494:      	fcmp	d17, d1
   ac498:      	fcsel	d18, d1, d17, gt
   ac49c:      	fcsel	d17, d17, d1, gt
   ac4a0:      	fcmp	d18, d3
   ac4a4:      	fcsel	d18, d18, d3, gt
   ac4a8:      	fcmp	d7, d0
   ac4ac:      	fcsel	d19, d0, d7, gt
   ac4b0:      	fcsel	d0, d7, d0, gt
   ac4b4:      	fcmp	d19, d16
   ac4b8:      	fcsel	d7, d16, d19, gt
   ac4bc:      	fcsel	d16, d19, d16, gt
   ac4c0:      	fcmp	d7, d17
   ac4c4:      	fcsel	d19, d17, d7, gt
   ac4c8:      	fcsel	d7, d7, d17, gt
   ac4cc:      	fcmp	d19, d18
   ac4d0:      	fcsel	d17, d19, d18, gt
   ac4d4:      	fcmp	d0, d16
   ac4d8:      	fcsel	d18, d16, d0, gt
   ac4dc:      	fcsel	d0, d0, d16, gt
   ac4e0:      	fcmp	d18, d7
   ac4e4:      	fcsel	d16, d7, d18, gt
   ac4e8:      	fcsel	d7, d18, d7, gt
   ac4ec:      	fcmp	d16, d17
   ac4f0:      	fcsel	d18, d17, d16, gt
   ac4f4:      	fcsel	d16, d16, d17, gt
   ac4f8:      	fcmp	d0, d7
   ac4fc:      	fcsel	d0, d7, d0, gt
   ac500:      	fcmp	d0, d16
   ac504:      	fcsel	d7, d16, d0, gt
   ac508:      	fcmp	d6, d6
   ac50c:      	fmov	d0, x17
   ac510:      	fadd	d16, d2, d9
   ac514:      	cset	w12, vc
   ac518:      	fcsel	d17, d6, d0, vc
   ac51c:      	fcmp	d2, d2
   ac520:      	fadd	d7, d18, d7
   ac524:      	fcsel	d16, d16, d9, vc
   ac528:      	cinc	w12, w12, vc
   ac52c:      	fcmp	d5, d5
   ac530:      	fmul	d7, d7, d14
   ac534:      	fcsel	d19, d5, d0, vc
   ac538:      	fadd	d16, d16, d17
   ac53c:      	cinc	w12, w12, vc
   ac540:      	fcmp	d4, d4
   ac544:      	fcsel	d17, d4, d0, vc
   ac548:      	fadd	d16, d16, d19
   ac54c:      	cinc	w12, w12, vc
   ac550:      	fcmp	d1, d1
   ac554:      	fcsel	d19, d1, d0, vc
   ac558:      	fadd	d16, d16, d17
   ac55c:      	cinc	w12, w12, vc
   ac560:      	fcmp	d3, d3
   ac564:      	fcsel	d17, d3, d0, vc
   ac568:      	fadd	d16, d16, d19
   ac56c:      	cinc	w12, w12, vc
   ac570:      	ucvtf	d19, w12
   ac574:      	fadd	d16, d16, d17
   ac578:      	fsub	d17, d6, d7
   ac57c:      	fdiv	d16, d16, d19
   ac580:      	fsub	d19, d5, d7
   ac584:      	fneg	d18, d17
   ac588:      	fcmp	d17, #0.0
   ac58c:      	fneg	d21, d19
   ac590:      	fcsel	d17, d18, d17, mi
   ac594:      	fsub	d6, d6, d16
   ac598:      	fsub	d18, d5, d16
   ac59c:      	fsub	d23, d1, d16
   ac5a0:      	fneg	d20, d6
   ac5a4:      	fcmp	d6, #0.0
   ac5a8:      	fcsel	d5, d20, d6, mi
   ac5ac:      	fcmp	d19, #0.0
   ac5b0:      	fsub	d6, d4, d7
   ac5b4:      	fneg	d20, d18
   ac5b8:      	fcsel	d19, d21, d19, mi
   ac5bc:      	fcmp	d18, #0.0
   ac5c0:      	fsub	d21, d4, d16
   ac5c4:      	fneg	d22, d6
   ac5c8:      	fcsel	d4, d20, d18, mi
   ac5cc:      	fcmp	d6, #0.0
   ac5d0:      	fsub	d18, d1, d7
   ac5d4:      	fsub	d1, d3, d7
   ac5d8:      	fneg	d20, d21
   ac5dc:      	fsub	d7, d2, d7
   ac5e0:      	fcsel	d22, d22, d6, mi
   ac5e4:      	fcmp	d21, #0.0
   ac5e8:      	fsub	d2, d2, d16
   ac5ec:      	fneg	d24, d18
   ac5f0:      	fcsel	d6, d20, d21, mi
   ac5f4:      	fcmp	d18, #0.0
   ac5f8:      	fneg	d20, d23
   ac5fc:      	fsub	d21, d3, d16
   ac600:      	fcsel	d18, d24, d18, mi
   ac604:      	fcmp	d23, #0.0
   ac608:      	fneg	d24, d1
   ac60c:      	fcsel	d3, d20, d23, mi
   ac610:      	fcmp	d1, #0.0
   ac614:      	fneg	d20, d21
   ac618:      	fcsel	d23, d24, d1, mi
   ac61c:      	fcmp	d21, #0.0
   ac620:      	fneg	d24, d7
   ac624:      	fcsel	d16, d20, d21, mi
   ac628:      	fcmp	d7, #0.0
   ac62c:      	fneg	d20, d2
   ac630:      	fcsel	d7, d24, d7, mi
   ac634:      	fcmp	d2, #0.0
   ac638:      	fcsel	d20, d20, d2, mi
   ac63c:      	fcmp	d7, d17
   ac640:      	fcsel	d2, d17, d7, gt
   ac644:      	fcsel	d7, d7, d17, gt
   ac648:      	fcmp	d2, d19
   ac64c:      	fcsel	d17, d19, d2, gt
   ac650:      	fcsel	d2, d2, d19, gt
   ac654:      	fcmp	d17, d22
   ac658:      	fcsel	d19, d22, d17, gt
   ac65c:      	fcsel	d17, d17, d22, gt
   ac660:      	fcmp	d19, d18
   ac664:      	fcsel	d21, d18, d19, gt
   ac668:      	fcsel	d18, d19, d18, gt
   ac66c:      	fcmp	d21, d23
   ac670:      	fcsel	d19, d21, d23, gt
   ac674:      	fcmp	d7, d2
   ac678:      	fcsel	d21, d2, d7, gt
   ac67c:      	fcsel	d2, d7, d2, gt
   ac680:      	fcmp	d21, d17
   ac684:      	fcsel	d7, d17, d21, gt
   ac688:      	fcsel	d17, d21, d17, gt
   ac68c:      	fcmp	d7, d18
   ac690:      	fcsel	d21, d18, d7, gt
   ac694:      	fcsel	d7, d7, d18, gt
   ac698:      	fcmp	d21, d19
   ac69c:      	fcsel	d18, d21, d19, gt
   ac6a0:      	fcmp	d2, d17
   ac6a4:      	fcsel	d19, d17, d2, gt
   ac6a8:      	fcsel	d2, d2, d17, gt
   ac6ac:      	fcmp	d19, d7
   ac6b0:      	fcsel	d17, d7, d19, gt
   ac6b4:      	fcsel	d7, d19, d7, gt
   ac6b8:      	fcmp	d17, d18
   ac6bc:      	fcsel	d19, d18, d17, gt
   ac6c0:      	fcsel	d17, d17, d18, gt
   ac6c4:      	fcmp	d2, d7
   ac6c8:      	fcsel	d2, d7, d2, gt
   ac6cc:      	fcmp	d2, d17
   ac6d0:      	fcsel	d7, d17, d2, gt
   ac6d4:      	fcmp	d5, d5
   ac6d8:      	fadd	d17, d20, d9
   ac6dc:      	cset	w12, vc
   ac6e0:      	fcsel	d2, d5, d0, vc
   ac6e4:      	fcmp	d20, d20
   ac6e8:      	fadd	d7, d19, d7
   ac6ec:      	fcsel	d5, d17, d9, vc
   ac6f0:      	cinc	w12, w12, vc
   ac6f4:      	fcmp	d4, d4
   ac6f8:      	fmul	d7, d7, d14
   ac6fc:      	fcsel	d4, d4, d0, vc
   ac700:      	cinc	w12, w12, vc
   ac704:      	fcmp	d6, d6
   ac708:      	fcsel	d6, d6, d0, vc
   ac70c:      	cinc	w12, w12, vc
   ac710:      	fcmp	d3, d3
   ac714:      	fcsel	d3, d3, d0, vc
   ac718:      	cinc	w12, w12, vc
   ac71c:      	fcmp	d16, d16
   ac720:      	fcsel	d0, d16, d0, vc
   ac724:      	cinc	w12, w12, vc
   ac728:      	fcmp	d7, d11
   ac72c:      	b.pl	0xac77c <air1_opcal5_algorithm+0x3b98>
   ac730:      	fadd	d2, d5, d2
   ac734:      	fadd	d2, d2, d4
   ac738:      	fadd	d2, d2, d6
   ac73c:      	fadd	d2, d2, d3
   ac740:      	fadd	d0, d2, d0
   ac744:      	ucvtf	d2, w12
   ac748:      	fdiv	d2, d0, d2
   ac74c:      	movi	d0, #0000000000000000
   ac750:      	fcmp	d2, d2
   ac754:      	b.vs	0xac7d0 <air1_opcal5_algorithm+0x3bec>
   ac758:      	ldr	d3, [x1, #0x678]
   ac75c:      	fmul	d3, d2, d3
   ac760:      	fcmp	d3, #0.0
   ac764:      	b.ge	0xac790 <air1_opcal5_algorithm+0x3bac>
   ac768:      	ldr	d4, [x23, #0x518]
   ac76c:      	fcmp	d3, d4
   ac770:      	fmov	d4, #-0.50000000
   ac774:      	b.pl	0xac7a0 <air1_opcal5_algorithm+0x3bbc>
   ac778:      	b	0xac7b4 <air1_opcal5_algorithm+0x3bd0>
   ac77c:      	adrp	x12, 0x1000 <strcasecmp+0x1000>
   ac780:      	ldr	d0, [x12, #0x5f0]
   ac784:      	fmul	d2, d7, d0
   ac788:      	fdiv	d0, d1, d2
   ac78c:      	b	0xac7d8 <air1_opcal5_algorithm+0x3bf4>
   ac790:      	ldr	d4, [x3, #0x620]
   ac794:      	fcmp	d3, d4
   ac798:      	fmov	d4, #0.50000000
   ac79c:      	b.gt	0xac7b4 <air1_opcal5_algorithm+0x3bd0>
   ac7a0:      	fadd	d3, d3, d4
   ac7a4:      	fcvtzs	x12, d3
   ac7a8:      	add	x13, x12, x2
   ac7ac:      	cmp	x13, #0x1
   ac7b0:      	b.hi	0xac8ac <air1_opcal5_algorithm+0x3cc8>
   ac7b4:      	adrp	x12, 0x1000 <strcasecmp+0x1000>
   ac7b8:      	ldr	d3, [x12, #0x628]
   ac7bc:      	fcmp	d2, d3
   ac7c0:      	b.le	0xac7d0 <air1_opcal5_algorithm+0x3bec>
   ac7c4:      	ldr	d0, [x0, #0x5d8]
   ac7c8:      	fmul	d0, d2, d0
   ac7cc:      	fdiv	d0, d1, d0
   ac7d0:      	ldr	d1, [x0, #0x5d8]
   ac7d4:      	fmul	d2, d2, d1
   ac7d8:      	fcmp	d0, d0
   ac7dc:      	b.vs	0xac3c8 <air1_opcal5_algorithm+0x37e4>
   ac7e0:      	ldr	d1, [x1, #0x678]
   ac7e4:      	fmul	d1, d0, d1
   ac7e8:      	fcmp	d1, #0.0
   ac7ec:      	b.ge	0xac804 <air1_opcal5_algorithm+0x3c20>
   ac7f0:      	ldr	d3, [x23, #0x518]
   ac7f4:      	fcmp	d1, d3
   ac7f8:      	fmov	d3, #-0.50000000
   ac7fc:      	b.pl	0xac814 <air1_opcal5_algorithm+0x3c30>
   ac800:      	b	0xac828 <air1_opcal5_algorithm+0x3c44>
   ac804:      	ldr	d3, [x3, #0x620]
   ac808:      	fcmp	d1, d3
   ac80c:      	fmov	d3, #0.50000000
   ac810:      	b.gt	0xac828 <air1_opcal5_algorithm+0x3c44>
   ac814:      	fadd	d3, d1, d3
   ac818:      	fcvtzs	x12, d3
   ac81c:      	add	x13, x12, x2
   ac820:      	cmp	x13, #0x1
   ac824:      	b.hi	0xac848 <air1_opcal5_algorithm+0x3c64>
   ac828:      	fcmp	d0, d8
   ac82c:      	b.le	0xac85c <air1_opcal5_algorithm+0x3c78>
   ac830:      	add	x12, x21, x8
   ac834:      	ldr	d0, [x12, #0x20]
   ac838:      	fadd	d0, d2, d0
   ac83c:      	str	d0, [x12, #0x28]
   ac840:      	mov	w12, #0x1               // =1
   ac844:      	b	0xac8e8 <air1_opcal5_algorithm+0x3d04>
   ac848:      	mov	x13, #0xd601            // =54785
   ac84c:      	movk	x13, #0x7e11, lsl #16
   ac850:      	movk	x13, #0x3, lsl #32
   ac854:      	cmp	x12, x13
   ac858:      	b.ge	0xac830 <air1_opcal5_algorithm+0x3c4c>
   ac85c:      	fcmp	d1, #0.0
   ac860:      	b.ge	0xac878 <air1_opcal5_algorithm+0x3c94>
   ac864:      	ldr	d3, [x23, #0x518]
   ac868:      	fcmp	d1, d3
   ac86c:      	fmov	d3, #-0.50000000
   ac870:      	b.pl	0xac888 <air1_opcal5_algorithm+0x3ca4>
   ac874:      	b	0xac89c <air1_opcal5_algorithm+0x3cb8>
   ac878:      	ldr	d3, [x3, #0x620]
   ac87c:      	fcmp	d1, d3
   ac880:      	fmov	d3, #0.50000000
   ac884:      	b.gt	0xac89c <air1_opcal5_algorithm+0x3cb8>
   ac888:      	fadd	d1, d1, d3
   ac88c:      	fcvtzs	x12, d1
   ac890:      	add	x13, x12, x2
   ac894:      	cmp	x13, #0x1
   ac898:      	b.hi	0xac8c0 <air1_opcal5_algorithm+0x3cdc>
   ac89c:      	fmov	d1, #-1.50000000
   ac8a0:      	fcmp	d0, d1
   ac8a4:      	b.pl	0xac3c8 <air1_opcal5_algorithm+0x37e4>
   ac8a8:      	b	0xac8d4 <air1_opcal5_algorithm+0x3cf0>
   ac8ac:      	mov	w13, #0x9681            // =38529
   ac8b0:      	movk	w13, #0x98, lsl #16
   ac8b4:      	cmp	x12, x13
   ac8b8:      	b.ge	0xac7c4 <air1_opcal5_algorithm+0x3be0>
   ac8bc:      	b	0xac7d0 <air1_opcal5_algorithm+0x3bec>
   ac8c0:      	mov	x13, #-0xd601           // =-54785
   ac8c4:      	movk	x13, #0x81ee, lsl #16
   ac8c8:      	movk	x13, #0xfffc, lsl #32
   ac8cc:      	cmp	x12, x13
   ac8d0:      	b.gt	0xac3c8 <air1_opcal5_algorithm+0x37e4>
   ac8d4:      	add	x12, x21, x8
   ac8d8:      	ldr	d0, [x12, #0x20]
   ac8dc:      	fsub	d0, d0, d2
   ac8e0:      	str	d0, [x12, #0x28]
   ac8e4:      	mov	w12, #0xff              // =255
   ac8e8:      	strb	w12, [sp, #0x9e5]
   ac8ec:      	b	0xac3cc <air1_opcal5_algorithm+0x37e8>
   ac8f0:      	adrp	x9, 0xe8000 <quick_sel_arr+0x1810>
   ac8f4:      	ldr	x8, [sp, #0x250]
   ac8f8:      	add	x9, x9, #0xda0
   ac8fc:      	ldp	q0, q1, [x9]
   ac900:      	ldp	q2, q3, [x9, #0x20]
   ac904:      	stp	q0, q1, [x9, #0xf0]
   ac908:      	ldp	q0, q1, [x9, #0x40]
   ac90c:      	stp	q2, q3, [x9, #0x110]
   ac910:      	ldp	q2, q3, [x9, #0x60]
   ac914:      	stp	q0, q1, [x9, #0x130]
   ac918:      	ldp	q0, q1, [x9, #0x80]
   ac91c:      	stp	q2, q3, [x9, #0x150]
   ac920:      	ldp	q2, q3, [x9, #0xa0]
   ac924:      	stp	q0, q1, [x9, #0x170]
   ac928:      	ldp	q0, q1, [x9, #0xc0]
   ac92c:      	stp	q2, q3, [x9, #0x190]
   ac930:      	ldr	q2, [x9, #0xe0]
   ac934:      	stp	q0, q1, [x9, #0x1b0]
   ac938:      	str	q2, [x9, #0x1d0]
   ac93c:      	strh	wzr, [x8, #0x4]
   ac940:      	str	wzr, [x8]
   ac944:      	ldr	d0, [x9, #0xc8]
   ac948:      	str	d0, [x22, #0x700]
   ac94c:      	ldp	d1, d2, [x9, #0xd0]
   ac950:      	ldp	d3, d4, [x9, #0xe0]
   ac954:      	str	d1, [x22, #0x708]
   ac958:      	str	d2, [x22, #0x710]
   ac95c:      	str	d3, [x22, #0x718]
   ac960:      	str	d4, [x22, #0x720]
   ac964:      	b	0xaca10 <air1_opcal5_algorithm+0x3e2c>
   ac968:      	ldr	x9, [sp, #0xc0]
   ac96c:      	adrp	x12, 0xe8000 <quick_sel_arr+0x1810>
   ac970:      	add	x12, x12, #0xe68
   ac974:      	ldr	x11, [sp, #0x70]
   ac978:      	add	x8, x12, #0x108
   ac97c:      	ldr	x10, [sp, #0x250]
   ac980:      	ldp	q0, q1, [x9, #0xb0]
   ac984:      	stur	q0, [x12, #0xd8]
   ac988:      	ldp	q2, q0, [x9, #0xd0]
   ac98c:      	stur	q1, [x12, #0xe8]
   ac990:      	stur	q2, [x12, #0xf8]
   ac994:      	ldp	q1, q2, [x9, #0x70]
   ac998:      	str	q0, [x8]
   ac99c:      	stur	q1, [x12, #0x98]
   ac9a0:      	ldp	q0, q3, [x9, #0x90]
   ac9a4:      	stur	q2, [x12, #0xa8]
   ac9a8:      	stur	q0, [x12, #0xb8]
   ac9ac:      	ldp	q1, q0, [x9, #0x30]
   ac9b0:      	stur	q3, [x12, #0xc8]
   ac9b4:      	stur	q1, [x12, #0x58]
   ac9b8:      	ldp	q1, q3, [x9, #0x10]
   ac9bc:      	stur	q0, [x12, #0x68]
   ac9c0:      	stur	q1, [x12, #0x38]
   ac9c4:      	ldp	q2, q4, [x9, #0x50]
   ac9c8:      	stur	q3, [x12, #0x48]
   ac9cc:      	stur	q2, [x12, #0x78]
   ac9d0:      	ldr	q0, [x9]
   ac9d4:      	stur	q4, [x12, #0x88]
   ac9d8:      	ldrh	w8, [sp, #0x9e4]
   ac9dc:      	ldr	w9, [sp, #0x9e0]
   ac9e0:      	stur	q0, [x12, #0x28]
   ac9e4:      	ldrh	w27, [x22, #0x250]
   ac9e8:      	ldp	q0, q1, [x11]
   ac9ec:      	strh	w8, [x10, #0x4]
   ac9f0:      	str	w9, [x10]
   ac9f4:      	ldr	x8, [x11, #0x20]
   ac9f8:      	ldr	x9, [sp, #0xc8]
   ac9fc:      	stp	q0, q1, [x9]
   aca00:      	str	x8, [x9, #0x20]
   aca04:      	ldp	d0, d1, [x12]
   aca08:      	ldp	d2, d3, [x12, #0x10]
   aca0c:      	ldr	d4, [x12, #0x20]
   aca10:      	add	x0, sp, #0xcb0
   aca14:      	mov	w1, wzr
   aca18:      	mov	w2, #0x2d0              // =720
   aca1c:      	str	d0, [x22, #0x6d8]
   aca20:      	str	d1, [x22, #0x6e0]
   aca24:      	str	d2, [x22, #0x6e8]
   aca28:      	str	d3, [x22, #0x6f0]
   aca2c:      	str	d4, [x22, #0x6f8]
   aca30:      	bl	0xbefc0 <memset@plt>
   aca34:      	add	x0, sp, #0x9e0
   aca38:      	mov	w1, wzr
   aca3c:      	mov	w2, #0x2d0              // =720
   aca40:      	bl	0xbefc0 <memset@plt>
   aca44:      	add	x0, sp, #0x710
   aca48:      	mov	w1, wzr
   aca4c:      	mov	w2, #0x2d0              // =720
   aca50:      	bl	0xbefc0 <memset@plt>
   aca54:      	and	w8, w27, #0xffff
   aca58:      	cmp	w8, #0x3
   aca5c:      	b.lo	0xacd90 <air1_opcal5_algorithm+0x41ac>
   aca60:      	ldr	w8, [x22, #0x1c8]
   aca64:      	ldr	w9, [x22, #0x64]
   aca68:      	sub	x8, x8, x9
   aca6c:      	cmp	x8, #0x382
   aca70:      	b.ge	0xacd90 <air1_opcal5_algorithm+0x41ac>
   aca74:      	add	x0, sp, #0xf80
   aca78:      	ldr	x1, [sp, #0x248]
   aca7c:      	mov	w2, #0x1e0              // =480
   aca80:      	bl	0xbf060 <memcpy@plt>
   aca84:      	adrp	x9, 0xe8000 <quick_sel_arr+0x1810>
   aca88:      	ldr	x10, [sp, #0x18]
   aca8c:      	add	x9, x9, #0xe90
   aca90:      	mov	w27, wzr
   aca94:      	add	x8, sp, #0x430
   aca98:      	mov	w19, wzr
   aca9c:      	ldp	q0, q1, [x9, #0xc0]
   acaa0:      	ldr	q2, [x9, #0xe0]
   acaa4:      	stp	q0, q1, [x10, #0xc0]
   acaa8:      	ldp	q3, q0, [x9, #0x80]
   acaac:      	str	q2, [x10, #0xe0]
   acab0:      	ldp	q2, q1, [x9, #0xa0]
   acab4:      	stp	q3, q0, [x10, #0x80]
   acab8:      	ldp	q0, q3, [x9, #0x40]
   acabc:      	stp	q2, q1, [x10, #0xa0]
   acac0:      	ldp	q2, q1, [x9, #0x60]
   acac4:      	stp	q0, q3, [x10, #0x40]
   acac8:      	ldp	q0, q3, [x9]
   acacc:      	stp	q2, q1, [x10, #0x60]
   acad0:      	ldp	q2, q1, [x9, #0x20]
   acad4:      	stp	q0, q3, [x10]
   acad8:      	ldr	q0, [sp, #0x3f0]
   acadc:      	stp	q2, q1, [x10, #0x20]
   acae0:      	str	q0, [x8, #0x5b0]
   acae4:      	str	q0, [x8, #0x5c0]
   acae8:      	str	q0, [x8, #0x5d0]
   acaec:      	str	q0, [x8, #0x5e0]
   acaf0:      	str	q0, [x8, #0x5f0]
   acaf4:      	str	q0, [x8, #0x600]
   acaf8:      	str	q0, [x8, #0x610]
   acafc:      	str	q0, [x8, #0x620]
   acb00:      	str	q0, [x8, #0x630]
   acb04:      	str	q0, [x8, #0x640]
   acb08:      	str	q0, [x8, #0x650]
   acb0c:      	str	q0, [x8, #0x660]
   acb10:      	str	q0, [x8, #0x670]
   acb14:      	str	q0, [x8, #0x680]
   acb18:      	str	q0, [x8, #0x690]
   acb1c:      	str	q0, [x8, #0x6a0]
   acb20:      	str	q0, [x8, #0x6b0]
   acb24:      	str	q0, [x8, #0x6c0]
   acb28:      	str	q0, [x8, #0x6d0]
   acb2c:      	str	q0, [x8, #0x6e0]
   acb30:      	str	q0, [x8, #0x6f0]
   acb34:      	str	q0, [x8, #0x700]
   acb38:      	str	q0, [x8, #0x710]
   acb3c:      	str	q0, [x8, #0x720]
   acb40:      	str	q0, [x8, #0x730]
   acb44:      	str	q0, [x8, #0x740]
   acb48:      	str	q0, [x8, #0x750]
   acb4c:      	str	q0, [x8, #0x760]
   acb50:      	str	q0, [x8, #0x770]
   acb54:      	str	q0, [x8, #0x780]
   acb58:      	str	q0, [x8, #0x790]
   acb5c:      	str	q0, [x8, #0x7a0]
   acb60:      	str	q0, [x8, #0x7b0]
   acb64:      	str	q0, [x8, #0x7c0]
   acb68:      	str	q0, [x8, #0x7d0]
   acb6c:      	str	q0, [x8, #0x7e0]
   acb70:      	str	q0, [x8, #0x7f0]
   acb74:      	str	q0, [x8, #0x800]
   acb78:      	str	q0, [x8, #0x810]
   acb7c:      	str	q0, [x8, #0x820]
   acb80:      	str	q0, [x8, #0x830]
   acb84:      	str	q0, [x8, #0x840]
   acb88:      	str	q0, [x8, #0x850]
   acb8c:      	str	q0, [x8, #0x860]
   acb90:      	str	q0, [x8, #0x870]
   acb94:      	adrp	x9, 0xc3000 <cos@plt+0x3f60>
   acb98:      	mov	w8, #0x7ff0             // =32752
   acb9c:      	mov	x10, xzr
   acba0:      	ldr	x9, [x9, #0x368]
   acba4:      	add	x8, x9, x8
   acba8:      	movi	d0, #0000000000000000
   acbac:      	movi	d4, #0000000000000000
   acbb0:      	movi	d3, #0000000000000000
   acbb4:      	movi	d2, #0000000000000000
   acbb8:      	movi	d1, #0000000000000000
   acbbc:      	mov	x11, xzr
   acbc0:      	mov	x12, x8
   acbc4:      	mov	x13, x9
   acbc8:      	lsl	x14, x11, #3
   acbcc:      	cmp	x10, #0x2d
   acbd0:      	csel	x15, x13, x12, lo
   acbd4:      	add	x11, x11, #0x1
   acbd8:      	add	x13, x13, #0x168
   acbdc:      	sub	x12, x12, #0x168
   acbe0:      	ldr	d5, [x25, x14]
   acbe4:      	cmp	x11, #0x5a
   acbe8:      	ldr	d6, [x15]
   acbec:      	ldr	d7, [x26, x14]
   acbf0:      	fmul	d5, d5, d6
   acbf4:      	scvtf	d6, w11
   acbf8:      	fmul	d16, d5, d7
   acbfc:      	fmul	d17, d5, d6
   acc00:      	fmadd	d1, d5, d7, d1
   acc04:      	fadd	d3, d3, d5
   acc08:      	fmadd	d4, d5, d6, d4
   acc0c:      	fmadd	d2, d16, d6, d2
   acc10:      	fmadd	d0, d17, d6, d0
   acc14:      	b.ne	0xacbc8 <air1_opcal5_algorithm+0x3fe4>
   acc18:      	fneg	d5, d4
   acc1c:      	add	x11, x10, #0x1
   acc20:      	lsl	x12, x10, #3
   acc24:      	add	x9, x9, #0x8
   acc28:      	sub	x8, x8, #0x8
   acc2c:      	mov	x10, x11
   acc30:      	fmul	d4, d4, d5
   acc34:      	fmadd	d4, d0, d3, d4
   acc38:      	fdiv	d5, d5, d4
   acc3c:      	fdiv	d3, d3, d4
   acc40:      	fdiv	d0, d0, d4
   acc44:      	fmul	d4, d2, d5
   acc48:      	fmul	d2, d2, d3
   acc4c:      	fmadd	d0, d0, d1, d4
   acc50:      	fmadd	d1, d5, d1, d2
   acc54:      	scvtf	d2, w11
   acc58:      	fmadd	d0, d1, d2, d0
   acc5c:      	ldr	d1, [x26, x12]
   acc60:      	str	d0, [x21, x12]
   acc64:      	fsub	d1, d1, d0
   acc68:      	fneg	d2, d1
   acc6c:      	fcmp	d1, #0.0
   acc70:      	fcsel	d1, d2, d1, mi
   acc74:      	cmp	x11, #0x5a
   acc78:      	str	d1, [x28, x12]
   acc7c:      	b.ne	0xacba8 <air1_opcal5_algorithm+0x3fc4>
   acc80:      	add	x0, sp, #0x710
   acc84:      	mov	w1, #0x5a               // =90
   acc88:      	mov	w2, #0x2d               // =45
   acc8c:      	bl	0xb96a8 <quick_select>
   acc90:      	add	x0, sp, #0x710
   acc94:      	mov	w1, #0x5a               // =90
   acc98:      	mov	w2, #0x2e               // =46
   acc9c:      	fmov	d8, d0
   acca0:      	bl	0xb96a8 <quick_select>
   acca4:      	fadd	d0, d8, d0
   acca8:      	mov	x8, xzr
   accac:      	ldr	q5, [sp, #0x3f0]
   accb0:      	fmul	d0, d0, d14
   accb4:      	fmul	d1, d0, d10
   accb8:      	dup	v0.2s, w19
   accbc:      	dup	v1.2d, v1.d[0]
   accc0:      	ldr	q2, [x28, x8]
   accc4:      	mov	v3.16b, v5.16b
   accc8:      	fdiv	v2.2d, v2.2d, v1.2d
   acccc:      	fmin	v2.2d, v2.2d, v5.2d
   accd0:      	fmls	v3.2d, v2.2d, v2.2d
   accd4:      	fmul	v2.2d, v3.2d, v3.2d
   accd8:      	str	q2, [x25, x8]
   accdc:      	add	x8, x8, #0x10
   acce0:      	fcmge	v3.2d, v2.2d, #0.0
   acce4:      	cmp	x8, #0x2d0
   acce8:      	fcmlt	v4.2d, v2.2d, #0.0
   accec:      	orr	v3.16b, v4.16b, v3.16b
   accf0:      	mvn	v3.16b, v3.16b
   accf4:      	xtn	v3.2s, v3.2d
   accf8:      	bit	v0.8b, v13.8b, v3.8b
   accfc:      	b.ne	0xaccc0 <air1_opcal5_algorithm+0x40dc>
   acd00:      	dup	v1.2s, w19
   acd04:      	and	v0.8b, v0.8b, v15.8b
   acd08:      	add	w27, w27, #0x1
   acd0c:      	and	v1.8b, v1.8b, v15.8b
   acd10:      	cmeq	v0.2s, v0.2s, v1.2s
   acd14:      	mvn	v0.8b, v0.8b
   acd18:      	mov	w8, v0.s[1]
   acd1c:      	fmov	w9, s0
   acd20:      	bfi	w9, w8, #1, #31
   acd24:      	tst	w9, #0x3
   acd28:      	csinc	w19, w19, wzr, eq
   acd2c:      	and	w8, w19, #0xff
   acd30:      	cmp	w8, #0x1
   acd34:      	ccmp	w27, #0x3, #0x4, ne
   acd38:      	b.ne	0xacb94 <air1_opcal5_algorithm+0x3fb0>
   acd3c:      	ldr	x8, [sp, #0x10]
   acd40:      	adrp	x9, 0xe8000 <quick_sel_arr+0x1810>
   acd44:      	add	x9, x9, #0xf80
   acd48:      	add	x19, sp, #0x430
   acd4c:      	ldp	q0, q1, [x8, #0xc0]
   acd50:      	ldr	q2, [x8, #0xe0]
   acd54:      	stp	q0, q1, [x9, #0xc0]
   acd58:      	ldp	q3, q0, [x8, #0x80]
   acd5c:      	str	q2, [x9, #0xe0]
   acd60:      	ldp	q2, q1, [x8, #0xa0]
   acd64:      	stp	q3, q0, [x9, #0x80]
   acd68:      	ldp	q0, q3, [x8, #0x40]
   acd6c:      	stp	q2, q1, [x9, #0xa0]
   acd70:      	ldp	q2, q1, [x8, #0x60]
   acd74:      	stp	q0, q3, [x9, #0x40]
   acd78:      	ldp	q0, q3, [x8]
   acd7c:      	stp	q2, q1, [x9, #0x60]
   acd80:      	ldp	q2, q1, [x8, #0x20]
   acd84:      	stp	q0, q3, [x9]
   acd88:      	stp	q2, q1, [x9, #0x20]
   acd8c:      	b	0xacdd8 <air1_opcal5_algorithm+0x41f4>
   acd90:      	adrp	x8, 0xe8000 <quick_sel_arr+0x1810>
   acd94:      	add	x8, x8, #0xe90
   acd98:      	ldp	q0, q1, [x8]
   acd9c:      	ldp	q2, q3, [x8, #0x20]
   acda0:      	stp	q0, q1, [x8, #0xf0]
   acda4:      	ldp	q0, q1, [x8, #0x40]
   acda8:      	stp	q2, q3, [x8, #0x110]
   acdac:      	ldp	q2, q3, [x8, #0x60]
   acdb0:      	stp	q0, q1, [x8, #0x130]
   acdb4:      	ldp	q0, q1, [x8, #0x80]
   acdb8:      	stp	q2, q3, [x8, #0x150]
   acdbc:      	ldp	q2, q3, [x8, #0xa0]
   acdc0:      	stp	q0, q1, [x8, #0x170]
   acdc4:      	ldp	q0, q1, [x8, #0xc0]
   acdc8:      	stp	q2, q3, [x8, #0x190]
   acdcc:      	ldr	q2, [x8, #0xe0]
   acdd0:      	stp	q0, q1, [x8, #0x1b0]
   acdd4:      	str	q2, [x8, #0x1d0]
   acdd8:      	ldr	x10, [sp, #0x1c8]
   acddc:      	adrp	x11, 0xe8000 <quick_sel_arr+0x1810>
   acde0:      	ldr	x8, [sp, #0x248]
   acde4:      	fmov	d23, #-0.25000000
   acde8:      	fmov	d24, #1.75000000
   acdec:      	fmov	d15, #2.00000000
   acdf0:      	ldp	q0, q1, [x10, #0xc0]
   acdf4:      	add	x11, x11, #0xcd0
   acdf8:      	ldr	q2, [x10, #0xe0]
   acdfc:      	stp	q0, q1, [x8, #0xc0]
   ace00:      	ldp	q3, q0, [x10, #0x80]
   ace04:      	str	q2, [x8, #0xe0]
   ace08:      	ldp	q2, q1, [x10, #0xa0]
   ace0c:      	stp	q3, q0, [x8, #0x80]
   ace10:      	ldp	q0, q3, [x10, #0x40]
   ace14:      	stp	q2, q1, [x8, #0xa0]
   ace18:      	ldp	q2, q1, [x10, #0x60]
   ace1c:      	stp	q0, q3, [x8, #0x40]
   ace20:      	ldp	q0, q3, [x10]
   ace24:      	stp	q2, q1, [x8, #0x60]
   ace28:      	ldp	q2, q1, [x10, #0x20]
   ace2c:      	stp	q0, q3, [x8]
   ace30:      	stp	q2, q1, [x8, #0x20]
   ace34:      	ldr	w8, [sp, #0x184]
   ace38:      	cbz	w8, 0xace60 <air1_opcal5_algorithm+0x427c>
   ace3c:      	mov	x8, xzr
   ace40:      	adrp	x21, 0xe9000 <g_algo+0x330>
   ace44:      	add	x9, x11, x8
   ace48:      	ldr	d0, [x9, #0x1c0]
   ace4c:      	str	d0, [x10, x8]
   ace50:      	add	x8, x8, #0x8
   ace54:      	cmp	x8, #0xf0
   ace58:      	b.ne	0xace44 <air1_opcal5_algorithm+0x4260>
   ace5c:      	b	0xacec8 <air1_opcal5_algorithm+0x42e4>
   ace60:      	adrp	x8, 0xe8000 <quick_sel_arr+0x1810>
   ace64:      	adrp	x21, 0xe9000 <g_algo+0x330>
   ace68:      	add	x8, x8, #0xe90
   ace6c:      	ldp	q0, q1, [x8]
   ace70:      	str	q0, [x22, #0x820]
   ace74:      	ldp	q2, q0, [x8, #0x20]
   ace78:      	str	q1, [x22, #0x830]
   ace7c:      	str	q2, [x22, #0x840]
   ace80:      	ldp	q1, q2, [x8, #0x40]
   ace84:      	str	q0, [x22, #0x850]
   ace88:      	str	q1, [x22, #0x860]
   ace8c:      	ldp	q0, q1, [x8, #0x60]
   ace90:      	str	q2, [x22, #0x870]
   ace94:      	str	q0, [x22, #0x880]
   ace98:      	ldp	q2, q0, [x8, #0x80]
   ace9c:      	str	q1, [x22, #0x890]
   acea0:      	str	q2, [x22, #0x8a0]
   acea4:      	ldp	q1, q2, [x8, #0xa0]
   acea8:      	str	q0, [x22, #0x8b0]
   aceac:      	str	q1, [x22, #0x8c0]
   aceb0:      	ldp	q0, q1, [x8, #0xc0]
   aceb4:      	str	q2, [x22, #0x8d0]
   aceb8:      	str	q0, [x22, #0x8e0]
   acebc:      	ldr	q2, [x8, #0xe0]
   acec0:      	str	q1, [x22, #0x8f0]
   acec4:      	str	q2, [x22, #0x900]
   acec8:      	mov	x8, xzr
   acecc:      	add	x9, x11, x8
   aced0:      	add	x8, x8, #0x30
   aced4:      	ldr	d3, [x9, #0x2b8]
   aced8:      	ldr	d0, [x9, #0x2b0]
   acedc:      	ldr	d2, [x9, #0x2c0]
   acee0:      	ldr	d6, [x9, #0x2c8]
   acee4:      	fcmp	d0, d3
   acee8:      	ldr	d16, [x9, #0x2d0]
   aceec:      	ldr	d18, [x9, #0x2d8]
   acef0:      	fcsel	d1, d3, d0, gt
   acef4:      	fcsel	d4, d0, d3, gt
   acef8:      	fcmp	d1, d2
   acefc:      	fcsel	d5, d1, d2, gt
   acf00:      	fcsel	d1, d2, d1, gt
   acf04:      	fcmp	d4, d5
   acf08:      	fcsel	d0, d5, d4, gt
   acf0c:      	fcsel	d4, d4, d5, gt
   acf10:      	fcmp	d1, d6
   acf14:      	fcsel	d5, d1, d6, gt
   acf18:      	fcsel	d7, d6, d1, gt
   acf1c:      	str	d0, [x9, #0x3a0]
   acf20:      	fcmp	d0, d5
   acf24:      	fcsel	d1, d5, d0, gt
   acf28:      	fcsel	d5, d0, d5, gt
   acf2c:      	fcmp	d7, d16
   acf30:      	fcsel	d17, d16, d7, gt
   acf34:      	fcsel	d7, d7, d16, gt
   acf38:      	fcmp	d17, d18
   acf3c:      	fcsel	d17, d17, d18, gt
   acf40:      	fcmp	d1, d7
   acf44:      	fcsel	d19, d7, d1, gt
   acf48:      	fcsel	d7, d1, d7, gt
   acf4c:      	fcmp	d19, d17
   acf50:      	fcsel	d17, d19, d17, gt
   acf54:      	fcmp	d4, d5
   acf58:      	fcsel	d19, d5, d4, gt
   acf5c:      	fcsel	d4, d4, d5, gt
   acf60:      	fcmp	d19, d7
   acf64:      	fadd	d1, d1, d19
   acf68:      	fcsel	d5, d7, d19, gt
   acf6c:      	fcsel	d7, d19, d7, gt
   acf70:      	fmul	d1, d1, d14
   acf74:      	fcmp	d5, d17
   acf78:      	str	d5, [x9, #0x3b0]
   acf7c:      	str	d1, [x9, #0x3a8]
   acf80:      	fcsel	d20, d17, d5, gt
   acf84:      	fcsel	d17, d5, d17, gt
   acf88:      	fcmp	d4, d7
   acf8c:      	fcsel	d4, d7, d4, gt
   acf90:      	fcmp	d4, d17
   acf94:      	fcsel	d4, d17, d4, gt
   acf98:      	fcmp	d3, d2
   acf9c:      	fcsel	d7, d2, d3, gt
   acfa0:      	fcsel	d3, d3, d2, gt
   acfa4:      	fadd	d4, d20, d4
   acfa8:      	fcmp	d7, d6
   acfac:      	fmul	d4, d4, d14
   acfb0:      	fcsel	d17, d6, d7, gt
   acfb4:      	fcsel	d7, d7, d6, gt
   acfb8:      	str	d4, [x9, #0x3b8]
   acfbc:      	fcmp	d17, d16
   acfc0:      	fcsel	d21, d16, d17, gt
   acfc4:      	fcsel	d17, d17, d16, gt
   acfc8:      	fcmp	d21, d18
   acfcc:      	fcsel	d21, d21, d18, gt
   acfd0:      	fcmp	d3, d7
   acfd4:      	fcsel	d22, d7, d3, gt
   acfd8:      	fcsel	d3, d3, d7, gt
   acfdc:      	fcmp	d22, d17
   acfe0:      	fcsel	d7, d17, d22, gt
   acfe4:      	fcsel	d17, d22, d17, gt
   acfe8:      	fcmp	d7, d21
   acfec:      	fcsel	d7, d7, d21, gt
   acff0:      	fcmp	d3, d17
   acff4:      	fcsel	d3, d17, d3, gt
   acff8:      	fcmp	d3, d7
   acffc:      	fcsel	d3, d7, d3, gt
   ad000:      	fcmp	d2, d6
   ad004:      	fcsel	d7, d6, d2, gt
   ad008:      	fcsel	d2, d2, d6, gt
   ad00c:      	str	d3, [x9, #0x3c0]
   ad010:      	fcmp	d7, d16
   ad014:      	fcsel	d6, d16, d7, gt
   ad018:      	fcsel	d7, d7, d16, gt
   ad01c:      	fcmp	d6, d18
   ad020:      	fcsel	d6, d6, d18, gt
   ad024:      	fcmp	d2, d7
   ad028:      	fcsel	d16, d7, d2, gt
   ad02c:      	fcsel	d2, d2, d7, gt
   ad030:      	fcmp	d16, d6
   ad034:      	fcsel	d7, d16, d6, gt
   ad038:      	fcsel	d6, d6, d16, gt
   ad03c:      	fcmp	d2, d7
   ad040:      	fcsel	d2, d7, d2, gt
   ad044:      	cmp	x8, #0xf0
   ad048:      	fadd	d2, d6, d2
   ad04c:      	fmul	d0, d2, d14
   ad050:      	str	d0, [x9, #0x3c8]
   ad054:      	b.ne	0xacecc <air1_opcal5_algorithm+0x42e8>
   ad058:      	ldrh	w27, [x22, #0x250]
   ad05c:      	cmp	w27, #0x2
   ad060:      	b.lo	0xad1bc <air1_opcal5_algorithm+0x45d8>
   ad064:      	ldr	w8, [x22, #0x1c8]
   ad068:      	ldr	w9, [x22, #0x148]
   ad06c:      	sub	x8, x8, x9
   ad070:      	cmp	x8, #0x148
   ad074:      	b.ge	0xad1bc <air1_opcal5_algorithm+0x45d8>
   ad078:      	adrp	x9, 0xe9000 <g_algo+0x330>
   ad07c:      	ldr	x10, [sp, #0x38]
   ad080:      	add	x9, x9, #0x70
   ad084:      	mov	x8, xzr
   ad088:      	fmov	d16, #7.00000000
   ad08c:      	ldp	q1, q0, [x9, #0x40]
   ad090:      	ldp	q3, q2, [x9, #0x80]
   ad094:      	stp	q1, q0, [x10, #0x40]
   ad098:      	ldp	q0, q1, [x9, #0x60]
   ad09c:      	stp	q3, q2, [x10, #0x80]
   ad0a0:      	ldp	q3, q2, [x9, #0xd0]
   ad0a4:      	stp	q0, q1, [x10, #0x60]
   ad0a8:      	stp	q3, q2, [x10, #0xd0]
   ad0ac:      	ldr	q1, [x9, #0xa0]
   ad0b0:      	ldp	q2, q0, [x9, #0xb0]
   ad0b4:      	str	q1, [x10, #0xa0]
   ad0b8:      	stp	q2, q0, [x10, #0xb0]
   ad0bc:      	ldp	q3, q0, [x9, #0x20]
   ad0c0:      	ldp	q1, q2, [x9]
   ad0c4:      	stp	q3, q0, [x10, #0x20]
   ad0c8:      	ldr	x9, [sp, #0x28]
   ad0cc:      	stp	q1, q2, [x10]
   ad0d0:      	ldr	d3, [x19, #0xb68]
   ad0d4:      	ldr	d2, [x19, #0xb78]
   ad0d8:      	ldr	q0, [x9]
   ad0dc:      	ldr	x9, [x9, #0x10]
   ad0e0:      	str	q0, [x19, #0xb50]
   ad0e4:      	ldr	d0, [x19, #0xb70]
   ad0e8:      	ldr	d4, [x19, #0xb50]
   ad0ec:      	str	x9, [x19, #0xb60]
   ad0f0:      	ldr	d1, [x19, #0xb58]
   ad0f4:      	fmadd	d4, d4, d23, d9
   ad0f8:      	add	x9, x26, x8
   ad0fc:      	fmov	d5, d1
   ad100:      	fmov	d6, d0
   ad104:      	fadd	d4, d1, d4
   ad108:      	ldr	d1, [x9, #0x10]
   ad10c:      	fmadd	d4, d1, d24, d4
   ad110:      	fmadd	d3, d3, d15, d4
   ad114:      	fmov	d4, d5
   ad118:      	fmadd	d3, d0, d24, d3
   ad11c:      	fmov	d0, d2
   ad120:      	fadd	d3, d2, d3
   ad124:      	ldr	d2, [x9, #0x30]
   ad128:      	add	x9, x11, x8
   ad12c:      	add	x8, x8, #0x8
   ad130:      	cmp	x8, #0xd8
   ad134:      	fmadd	d3, d2, d23, d3
   ad138:      	fdiv	d7, d3, d16
   ad13c:      	fmov	d3, d6
   ad140:      	str	d7, [x9, #0x490]
   ad144:      	b.ne	0xad0f4 <air1_opcal5_algorithm+0x4510>
   ad148:      	ldr	d0, [x19, #0xc28]
   ad14c:      	fmov	d6, #7.25000000
   ad150:      	ldr	d1, [x19, #0xc30]
   ad154:      	adrp	x8, 0xe9000 <g_algo+0x330>
   ad158:      	ldr	d2, [x19, #0xc38]
   ad15c:      	add	x8, x8, #0x238
   ad160:      	ldr	d3, [x19, #0xc40]
   ad164:      	fmadd	d0, d0, d23, d1
   ad168:      	ldr	d4, [x19, #0xc48]
   ad16c:      	fmadd	d1, d1, d23, d2
   ad170:      	ldr	d5, [x19, #0xc50]
   ad174:      	fmadd	d0, d2, d24, d0
   ad178:      	fmadd	d2, d2, d23, d3
   ad17c:      	fmadd	d1, d3, d24, d1
   ad180:      	fmadd	d0, d3, d15, d0
   ad184:      	fmadd	d2, d4, d24, d2
   ad188:      	fmadd	d1, d4, d15, d1
   ad18c:      	fmov	d3, #4.50000000
   ad190:      	fmadd	d0, d4, d24, d0
   ad194:      	fmadd	d2, d5, d15, d2
   ad198:      	fmadd	d1, d5, d24, d1
   ad19c:      	fadd	d0, d5, d0
   ad1a0:      	fdiv	d2, d2, d3
   ad1a4:      	fdiv	d0, d0, d6
   ad1a8:      	fmov	d6, #6.25000000
   ad1ac:      	str	d2, [x8, #0x10]
   ad1b0:      	fdiv	d1, d1, d6
   ad1b4:      	stp	d0, d1, [x8]
   ad1b8:      	b	0xad204 <air1_opcal5_algorithm+0x4620>
   ad1bc:      	adrp	x8, 0xe9000 <g_algo+0x330>
   ad1c0:      	add	x8, x8, #0x70
   ad1c4:      	ldp	q0, q1, [x8]
   ad1c8:      	ldp	q2, q3, [x8, #0x20]
   ad1cc:      	stp	q0, q1, [x8, #0xf0]
   ad1d0:      	ldp	q0, q1, [x8, #0x40]
   ad1d4:      	stp	q2, q3, [x8, #0x110]
   ad1d8:      	ldp	q2, q3, [x8, #0x60]
   ad1dc:      	stp	q0, q1, [x8, #0x130]
   ad1e0:      	ldp	q0, q1, [x8, #0x80]
   ad1e4:      	stp	q2, q3, [x8, #0x150]
   ad1e8:      	ldp	q2, q3, [x8, #0xa0]
   ad1ec:      	stp	q0, q1, [x8, #0x170]
   ad1f0:      	ldp	q0, q1, [x8, #0xc0]
   ad1f4:      	stp	q2, q3, [x8, #0x190]
   ad1f8:      	ldr	q2, [x8, #0xe0]
   ad1fc:      	stp	q0, q1, [x8, #0x1b0]
   ad200:      	str	q2, [x8, #0x1d0]
   ad204:      	adrp	x23, 0xe9000 <g_algo+0x330>
   ad208:      	ldr	x8, [sp, #0x3d8]
   ad20c:      	add	x23, x23, #0x148
   ad210:      	mov	w2, #0x578              // =1400
   ad214:      	ldp	x1, x0, [sp, #0x1b8]
   ad218:      	ldr	d0, [x23]
   ad21c:      	str	d0, [x22, #0x910]
   ad220:      	ldur	q0, [x23, #0x8]
   ad224:      	str	q0, [x8]
   ad228:      	bl	0xbf050 <memmove@plt>
   ad22c:      	ldr	d0, [x23, #0x40]
   ad230:      	adrp	x11, 0xe8000 <quick_sel_arr+0x1810>
   ad234:      	mov	x8, xzr
   ad238:      	ldr	d1, [x23, #0x70]
   ad23c:      	ldr	d2, [x23, #0xa0]
   ad240:      	add	x9, x23, #0x108
   ad244:      	ldr	d3, [x23, #0xd0]
   ad248:      	str	d0, [x22, #0x40b8]
   ad24c:      	ldr	d0, [x23, #0x100]
   ad250:      	fmov	d16, #0.25000000
   ad254:      	add	x11, x11, #0xcd0
   ad258:      	mov	w23, #0x2               // =2
   ad25c:      	str	d1, [x22, #0x40c0]
   ad260:      	str	d2, [x22, #0x40c8]
   ad264:      	str	d3, [x22, #0x40d0]
   ad268:      	str	d0, [x22, #0x40d8]
   ad26c:      	b	0xad2d0 <air1_opcal5_algorithm+0x46ec>
   ad270:      	fmov	d6, d2
   ad274:      	fadd	d5, d5, d9
   ad278:      	fcmp	d1, d7
   ad27c:      	add	x8, x8, #0x30
   ad280:      	fadd	d4, d4, d5
   ad284:      	fcsel	d5, d7, d1, pl
   ad288:      	fcmp	d1, d6
   ad28c:      	fadd	d3, d3, d4
   ad290:      	fcsel	d4, d7, d5, gt
   ad294:      	fadd	d2, d2, d3
   ad298:      	fcsel	d3, d1, d6, gt
   ad29c:      	fcmp	d0, d4
   ad2a0:      	fadd	d1, d1, d2
   ad2a4:      	fcsel	d2, d4, d0, pl
   ad2a8:      	fcmp	d0, d3
   ad2ac:      	fcsel	d2, d4, d2, gt
   ad2b0:      	fadd	d1, d0, d1
   ad2b4:      	fcsel	d0, d0, d3, gt
   ad2b8:      	cmp	x8, #0xf0
   ad2bc:      	fsub	d1, d1, d2
   ad2c0:      	fsub	d0, d1, d0
   ad2c4:      	fmul	d0, d0, d16
   ad2c8:      	str	d0, [x9], #0x8
   ad2cc:      	b.eq	0xad344 <air1_opcal5_algorithm+0x4760>
   ad2d0:      	add	x10, x11, x8
   ad2d4:      	ldr	d5, [x10, #0x490]
   ad2d8:      	ldr	d4, [x10, #0x498]
   ad2dc:      	ldr	d3, [x10, #0x4a0]
   ad2e0:      	fmov	d7, d5
   ad2e4:      	ldr	d2, [x10, #0x4a8]
   ad2e8:      	fmov	d6, d4
   ad2ec:      	ldr	d1, [x10, #0x4b0]
   ad2f0:      	ldr	d0, [x10, #0x4b8]
   ad2f4:      	fcmp	d4, d5
   ad2f8:      	b.gt	0xad310 <air1_opcal5_algorithm+0x472c>
   ad2fc:      	fmov	d6, d5
   ad300:      	fmov	d7, d5
   ad304:      	b.pl	0xad310 <air1_opcal5_algorithm+0x472c>
   ad308:      	fmov	d6, d5
   ad30c:      	fmov	d7, d4
   ad310:      	fcmp	d3, d6
   ad314:      	b.le	0xad320 <air1_opcal5_algorithm+0x473c>
   ad318:      	fmov	d6, d3
   ad31c:      	b	0xad32c <air1_opcal5_algorithm+0x4748>
   ad320:      	fcmp	d3, d7
   ad324:      	b.pl	0xad32c <air1_opcal5_algorithm+0x4748>
   ad328:      	fmov	d7, d3
   ad32c:      	fcmp	d2, d6
   ad330:      	b.gt	0xad270 <air1_opcal5_algorithm+0x468c>
   ad334:      	fcmp	d2, d7
   ad338:      	b.pl	0xad274 <air1_opcal5_algorithm+0x4690>
   ad33c:      	fmov	d7, d2
   ad340:      	b	0xad274 <air1_opcal5_algorithm+0x4690>
   ad344:      	ldp	x1, x0, [sp, #0x1a8]
   ad348:      	mov	w2, #0x2bc              // =700
   ad34c:      	bl	0xbf050 <memmove@plt>
   ad350:      	ldp	x1, x0, [sp, #0x190]
   ad354:      	mov	w2, #0x578              // =1400
   ad358:      	bl	0xbf050 <memmove@plt>
   ad35c:      	adrp	x11, 0xe8000 <quick_sel_arr+0x1810>
   ad360:      	ldr	x10, [sp, #0x218]
   ad364:      	add	x11, x11, #0xd34
   ad368:      	ldr	w8, [x11]
   ad36c:      	str	w8, [x10]
   ad370:      	add	x8, x11, #0x51c
   ad374:      	ldr	w9, [x11, #0x18]
   ad378:      	ldr	d0, [x8]
   ad37c:      	add	x8, x11, #0x524
   ad380:      	str	w9, [x10, #0x4]
   ad384:      	ldr	w9, [x11, #0x30]
   ad388:      	ldr	d1, [x8]
   ad38c:      	add	x8, x11, #0x52c
   ad390:      	fmov	d6, d0
   ad394:      	str	d0, [x22, #0x4928]
   ad398:      	str	w9, [x10, #0x8]
   ad39c:      	ldr	w9, [x11, #0x48]
   ad3a0:      	fmov	d5, d1
   ad3a4:      	ldr	d2, [x8]
   ad3a8:      	add	x8, x11, #0x534
   ad3ac:      	fcmp	d1, d0
   ad3b0:      	str	d1, [x22, #0x4930]
   ad3b4:      	str	w9, [x10, #0xc]
   ad3b8:      	ldr	w9, [x11, #0x60]
   ad3bc:      	str	d2, [x22, #0x4938]
   ad3c0:      	ldr	d3, [x8]
   ad3c4:      	add	x8, x11, #0x53c
   ad3c8:      	str	w9, [x10, #0x10]
   ad3cc:      	ldr	d4, [x8]
   ad3d0:      	str	d3, [x22, #0x4940]
   ad3d4:      	str	d4, [x22, #0x4948]
   ad3d8:      	b.gt	0xad3f0 <air1_opcal5_algorithm+0x480c>
   ad3dc:      	fmov	d5, d0
   ad3e0:      	fmov	d6, d0
   ad3e4:      	b.pl	0xad3f0 <air1_opcal5_algorithm+0x480c>
   ad3e8:      	fmov	d5, d0
   ad3ec:      	fmov	d6, d1
   ad3f0:      	fcmp	d2, d5
   ad3f4:      	b.le	0xad400 <air1_opcal5_algorithm+0x481c>
   ad3f8:      	fmov	d5, d2
   ad3fc:      	b	0xad40c <air1_opcal5_algorithm+0x4828>
   ad400:      	fcmp	d2, d6
   ad404:      	b.pl	0xad40c <air1_opcal5_algorithm+0x4828>
   ad408:      	fmov	d6, d2
   ad40c:      	fcmp	d3, d5
   ad410:      	b.le	0xad41c <air1_opcal5_algorithm+0x4838>
   ad414:      	fmov	d5, d3
   ad418:      	b	0xad428 <air1_opcal5_algorithm+0x4844>
   ad41c:      	fcmp	d3, d6
   ad420:      	b.pl	0xad428 <air1_opcal5_algorithm+0x4844>
   ad424:      	fmov	d6, d3
   ad428:      	fcmp	d4, d5
   ad42c:      	b.le	0xad438 <air1_opcal5_algorithm+0x4854>
   ad430:      	fmov	d5, d4
   ad434:      	b	0xad444 <air1_opcal5_algorithm+0x4860>
   ad438:      	fcmp	d4, d6
   ad43c:      	b.pl	0xad444 <air1_opcal5_algorithm+0x4860>
   ad440:      	fmov	d6, d4
   ad444:      	fadd	d0, d0, d9
   ad448:      	adrp	x8, 0xe9000 <g_algo+0x330>
   ad44c:      	ldp	x1, x0, [sp, #0x110]
   ad450:      	mov	w2, #0x11f8             // =4600
   ad454:      	fadd	d0, d0, d1
   ad458:      	fmov	d1, #3.00000000
   ad45c:      	fadd	d0, d0, d2
   ad460:      	fadd	d0, d0, d3
   ad464:      	fadd	d0, d0, d4
   ad468:      	fsub	d0, d0, d6
   ad46c:      	fsub	d0, d0, d5
   ad470:      	fdiv	d8, d0, d1
   ad474:      	str	d8, [x8, #0x278]
   ad478:      	bl	0xbf050 <memmove@plt>
   ad47c:      	ldrb	w8, [x22, #0x2]
   ad480:      	str	d8, [x22, #0x1b20]
   ad484:      	cmp	w8, #0x1
   ad488:      	b.eq	0xad4b4 <air1_opcal5_algorithm+0x48d0>
   ad48c:      	adrp	x14, 0xe8000 <quick_sel_arr+0x1810>
   ad490:      	ldr	x3, [sp, #0x3d0]
   ad494:      	ldr	x4, [sp, #0x3c8]
   ad498:      	add	x14, x14, #0xcd0
   ad49c:      	adrp	x30, 0xe8000 <quick_sel_arr+0x1810>
   ad4a0:      	cmp	w8, #0x2
   ad4a4:      	b.ne	0xad4e4 <air1_opcal5_algorithm+0x4900>
   ad4a8:      	adrp	x8, 0xe9000 <g_algo+0x330>
   ad4ac:      	add	x8, x8, #0x6f0
   ad4b0:      	b	0xad4d0 <air1_opcal5_algorithm+0x48ec>
   ad4b4:      	ldr	x3, [sp, #0x3d0]
   ad4b8:      	adrp	x8, 0xe9000 <g_algo+0x330>
   ad4bc:      	ldr	x4, [sp, #0x3c8]
   ad4c0:      	adrp	x14, 0xe8000 <quick_sel_arr+0x1810>
   ad4c4:      	add	x8, x8, #0x6e8
   ad4c8:      	add	x14, x14, #0xcd0
   ad4cc:      	adrp	x30, 0xe8000 <quick_sel_arr+0x1810>
   ad4d0:      	ldr	d0, [x8]
   ad4d4:      	adrp	x8, 0xe9000 <g_algo+0x330>
   ad4d8:      	fsub	d0, d8, d0
   ad4dc:      	str	d0, [x8, #0x280]
   ad4e0:      	b	0xad4ec <air1_opcal5_algorithm+0x4908>
   ad4e4:      	adrp	x8, 0xe9000 <g_algo+0x330>
   ad4e8:      	ldr	d0, [x8, #0x280]
   ad4ec:      	adrp	x8, 0xe9000 <g_algo+0x330>
   ad4f0:      	ldrb	w8, [x8, #0x6f8]
   ad4f4:      	cmp	w8, #0x1
   ad4f8:      	b.ne	0xad528 <air1_opcal5_algorithm+0x4944>
   ad4fc:      	adrp	x8, 0xe9000 <g_algo+0x330>
   ad500:      	add	x8, x8, #0x700
   ad504:      	ldp	d1, d2, [x8]
   ad508:      	fmul	d1, d0, d1
   ad50c:      	fmul	d2, d0, d2
   ad510:      	fmul	d1, d0, d1
   ad514:      	fmul	d2, d0, d2
   ad518:      	fmadd	d1, d1, d0, d2
   ad51c:      	ldp	d2, d3, [x8, #0x10]
   ad520:      	fmadd	d0, d2, d0, d1
   ad524:      	fadd	d0, d3, d0
   ad528:      	adrp	x8, 0xe9000 <g_algo+0x330>
   ad52c:      	cmp	w27, #0x1
   ad530:      	str	d0, [x8, #0x288]
   ad534:      	adrp	x8, 0xe8000 <quick_sel_arr+0x1810>
   ad538:      	b.ls	0xad604 <air1_opcal5_algorithm+0x4a20>
   ad53c:      	adrp	x9, 0xe9000 <g_algo+0x330>
   ad540:      	ldrh	w8, [x8, #0xcd0]
   ad544:      	add	x9, x9, #0x722
   ad548:      	ldrh	w10, [x9]
   ad54c:      	ldrh	w9, [x9, #0x2]
   ad550:      	cmp	w8, w10
   ad554:      	b.ls	0xad60c <air1_opcal5_algorithm+0x4a28>
   ad558:      	cmp	w8, w9
   ad55c:      	b.hi	0xad60c <air1_opcal5_algorithm+0x4a28>
   ad560:      	mov	x9, #0x4044000000000000 // =4630826316843712512
   ad564:      	ldr	d1, [x22, #0x1b58]
   ad568:      	fmov	d2, x9
   ad56c:      	fcmp	d1, d2
   ad570:      	b.lt	0xad710 <air1_opcal5_algorithm+0x4b2c>
   ad574:      	mov	x9, #0xc00000000000     // =211106232532992
   ad578:      	movk	x9, #0x4082, lsl #48
   ad57c:      	fmov	d2, x9
   ad580:      	fcmp	d1, d2
   ad584:      	b.hi	0xad710 <air1_opcal5_algorithm+0x4b2c>
   ad588:      	mov	x10, #0x800000000000    // =140737488355328
   ad58c:      	ldrh	w9, [x22, #0x1b2c]
   ad590:      	movk	x10, #0x4066, lsl #48
   ad594:      	add	w9, w9, #0x1
   ad598:      	fmov	d2, x10
   ad59c:      	strh	w9, [x22, #0x1b2c]
   ad5a0:      	fcmp	d1, d2
   ad5a4:      	b.le	0xad5b4 <air1_opcal5_algorithm+0x49d0>
   ad5a8:      	ldrh	w10, [x22, #0x1b28]
   ad5ac:      	add	w10, w10, #0x1
   ad5b0:      	strh	w10, [x22, #0x1b28]
   ad5b4:      	mov	x10, #0x800000000000    // =140737488355328
   ad5b8:      	movk	x10, #0x4051, lsl #48
   ad5bc:      	fmov	d2, x10
   ad5c0:      	fcmp	d1, d2
   ad5c4:      	b.pl	0xad5d4 <air1_opcal5_algorithm+0x49f0>
   ad5c8:      	ldrh	w10, [x22, #0x1b2a]
   ad5cc:      	add	w10, w10, #0x1
   ad5d0:      	strh	w10, [x22, #0x1b2a]
   ad5d4:      	ldr	d2, [x22, #0x1b48]
   ad5d8:      	and	w9, w9, #0xffff
   ad5dc:      	fsub	d3, d1, d2
   ad5e0:      	ucvtf	d4, w9
   ad5e4:      	fdiv	d4, d3, d4
   ad5e8:      	fadd	d2, d2, d4
   ad5ec:      	ldr	d4, [x22, #0x1b50]
   ad5f0:      	fsub	d1, d1, d2
   ad5f4:      	str	d2, [x22, #0x1b48]
   ad5f8:      	fmadd	d1, d3, d1, d4
   ad5fc:      	str	d1, [x22, #0x1b50]
   ad600:      	b	0xad710 <air1_opcal5_algorithm+0x4b2c>
   ad604:      	ldrh	w8, [x8, #0xcd0]
   ad608:      	b	0xad710 <air1_opcal5_algorithm+0x4b2c>
   ad60c:      	cmp	w8, w9
   ad610:      	b.ls	0xad710 <air1_opcal5_algorithm+0x4b2c>
   ad614:      	ldrh	w9, [x22, #0x1b2c]
   ad618:      	cmp	w9, #0x121
   ad61c:      	b.lo	0xad710 <air1_opcal5_algorithm+0x4b2c>
   ad620:      	ucvtf	d1, w9
   ad624:      	fmov	d2, #-1.00000000
   ad628:      	ldr	d3, [x22, #0x1b50]
   ad62c:      	mov	x9, #0x4059000000000000 // =4636737291354636288
   ad630:      	ldr	d4, [x22, #0x1b48]
   ad634:      	fadd	d2, d1, d2
   ad638:      	fmov	d5, x9
   ad63c:      	mov	x9, #0x4042000000000000 // =4630263366890291200
   ad640:      	fdiv	d2, d3, d2
   ad644:      	ldr	h3, [x22, #0x1b28]
   ad648:      	fmov	d6, x9
   ad64c:      	ucvtf	d3, d3
   ad650:      	fdiv	d3, d3, d1
   ad654:      	fsqrt	d2, d2
   ad658:      	fdiv	d2, d2, d4
   ad65c:      	ldr	h4, [x22, #0x1b2a]
   ad660:      	ucvtf	d4, d4
   ad664:      	fdiv	d4, d4, d1
   ad668:      	fmul	d1, d2, d5
   ad66c:      	fmul	d2, d3, d5
   ad670:      	fcmp	d1, d6
   ad674:      	str	d2, [x22, #0x1b30]
   ad678:      	str	d1, [x22, #0x1b40]
   ad67c:      	fmul	d3, d4, d5
   ad680:      	str	d3, [x22, #0x1b38]
   ad684:      	b.gt	0xad6ac <air1_opcal5_algorithm+0x4ac8>
   ad688:      	fmov	d4, #5.00000000
   ad68c:      	fcmp	d3, d4
   ad690:      	b.gt	0xad6ac <air1_opcal5_algorithm+0x4ac8>
   ad694:      	mov	x9, #0x404e000000000000 // =4633641066610819072
   ad698:      	fmov	d3, x9
   ad69c:      	fcmp	d2, d3
   ad6a0:      	b.le	0xad6b4 <air1_opcal5_algorithm+0x4ad0>
   ad6a4:      	mov	w9, #0x5                // =5
   ad6a8:      	b	0xad70c <air1_opcal5_algorithm+0x4b28>
   ad6ac:      	mov	w9, #0x6                // =6
   ad6b0:      	b	0xad70c <air1_opcal5_algorithm+0x4b28>
   ad6b4:      	fmov	d3, #30.00000000
   ad6b8:      	fcmp	d2, d3
   ad6bc:      	b.le	0xad6c8 <air1_opcal5_algorithm+0x4ae4>
   ad6c0:      	mov	w9, #0x4                // =4
   ad6c4:      	b	0xad70c <air1_opcal5_algorithm+0x4b28>
   ad6c8:      	fmov	d3, #5.00000000
   ad6cc:      	fcmp	d2, d3
   ad6d0:      	b.pl	0xad6e8 <air1_opcal5_algorithm+0x4b04>
   ad6d4:      	fmov	d3, #20.00000000
   ad6d8:      	fcmp	d1, d3
   ad6dc:      	b.hi	0xad6e8 <air1_opcal5_algorithm+0x4b04>
   ad6e0:      	mov	w9, #0x1                // =1
   ad6e4:      	b	0xad70c <air1_opcal5_algorithm+0x4b28>
   ad6e8:      	fmov	d3, #15.00000000
   ad6ec:      	fcmp	d2, d3
   ad6f0:      	b.pl	0xad708 <air1_opcal5_algorithm+0x4b24>
   ad6f4:      	fmov	d2, #30.00000000
   ad6f8:      	fcmp	d1, d2
   ad6fc:      	b.hi	0xad708 <air1_opcal5_algorithm+0x4b24>
   ad700:      	strb	w23, [x4]
   ad704:      	b	0xad710 <air1_opcal5_algorithm+0x4b2c>
   ad708:      	mov	w9, #0x3                // =3
   ad70c:      	strb	w9, [x4]
   ad710:      	adrp	x9, 0xe9000 <g_algo+0x330>
   ad714:      	ucvtf	d1, w8
   ad718:      	add	x9, x9, #0x720
   ad71c:      	ldrb	w9, [x9]
   ad720:      	cmp	w9, #0x1
   ad724:      	b.ne	0xad798 <air1_opcal5_algorithm+0x4bb4>
   ad728:      	adrp	x9, 0xe9000 <g_algo+0x330>
   ad72c:      	cmp	w8, #0x5
   ad730:      	ldrh	w9, [x9, #0x730]
   ad734:      	b.lo	0xad770 <air1_opcal5_algorithm+0x4b8c>
   ad738:      	cmp	w8, w9
   ad73c:      	b.hi	0xad770 <air1_opcal5_algorithm+0x4b8c>
   ad740:      	fcmp	d0, d14
   ad744:      	b.lt	0xad770 <air1_opcal5_algorithm+0x4b8c>
   ad748:      	mov	x10, #0x4049000000000000 // =4632233691727265792
   ad74c:      	fmov	d2, x10
   ad750:      	fcmp	d0, d2
   ad754:      	b.hi	0xad770 <air1_opcal5_algorithm+0x4b8c>
   ad758:      	ldr	d2, [x22, #0x1b90]
   ad75c:      	ldrh	w10, [x22, #0x1b98]
   ad760:      	fadd	d2, d0, d2
   ad764:      	add	w10, w10, #0x1
   ad768:      	str	d2, [x22, #0x1b90]
   ad76c:      	strh	w10, [x22, #0x1b98]
   ad770:      	adrp	x10, 0xe9000 <g_algo+0x330>
   ad774:      	cmp	w8, w9
   ad778:      	add	x10, x10, #0x720
   ad77c:      	ldr	d2, [x10, #0x8]
   ad780:      	ldrb	w10, [x4, #0x9a]
   ad784:      	b.hs	0xad7a0 <air1_opcal5_algorithm+0x4bbc>
   ad788:      	cbz	w10, 0xad7ac <air1_opcal5_algorithm+0x4bc8>
   ad78c:      	ldr	d4, [x22, #0x1bb8]
   ad790:      	ldr	d3, [x22, #0x1bb0]
   ad794:      	b	0xad7e0 <air1_opcal5_algorithm+0x4bfc>
   ad798:      	fmov	d8, #10.00000000
   ad79c:      	b	0xad988 <air1_opcal5_algorithm+0x4da4>
   ad7a0:      	cbz	w10, 0xad7b4 <air1_opcal5_algorithm+0x4bd0>
   ad7a4:      	ldr	d3, [x22, #0x1bb8]
   ad7a8:      	b	0xad7d4 <air1_opcal5_algorithm+0x4bf0>
   ad7ac:      	movi	d2, #0000000000000000
   ad7b0:      	b	0xad814 <air1_opcal5_algorithm+0x4c30>
   ad7b4:      	fmov	d3, d0
   ad7b8:      	ldrh	w9, [x22, #0x1b98]
   ad7bc:      	mov	w10, #0x1               // =1
   ad7c0:      	strb	w10, [x4, #0x9a]
   ad7c4:      	cbz	w9, 0xad7d4 <air1_opcal5_algorithm+0x4bf0>
   ad7c8:      	ucvtf	d3, w9
   ad7cc:      	ldr	d4, [x22, #0x1b90]
   ad7d0:      	fdiv	d3, d4, d3
   ad7d4:      	fmov	d4, d0
   ad7d8:      	str	d3, [x22, #0x1bb0]
   ad7dc:      	str	d0, [x22, #0x1bb8]
   ad7e0:      	mov	x9, #0x848000000000     // =145685290680320
   ad7e4:      	fmov	d7, #-1.00000000
   ad7e8:      	movk	x9, #0x412e, lsl #48
   ad7ec:      	fmov	d5, x9
   ad7f0:      	fdiv	d2, d2, d5
   ad7f4:      	fadd	d5, d2, d7
   ad7f8:      	fsub	d6, d12, d2
   ad7fc:      	fmadd	d2, d2, d15, d7
   ad800:      	fmul	d3, d5, d3
   ad804:      	fmadd	d3, d6, d4, d3
   ad808:      	ldr	d4, [x22, #0x1bc0]
   ad80c:      	fmsub	d2, d2, d4, d3
   ad810:      	str	d2, [x22, #0x1bc0]
   ad814:      	adrp	x9, 0xe9000 <g_algo+0x330>
   ad818:      	ldrh	w10, [x22, #0x1bca]
   ad81c:      	fmov	d8, #10.00000000
   ad820:      	ldrh	w9, [x9, #0x722]
   ad824:      	cmp	w8, w9
   ad828:      	b.ls	0xad838 <air1_opcal5_algorithm+0x4c54>
   ad82c:      	cbnz	w10, 0xad838 <air1_opcal5_algorithm+0x4c54>
   ad830:      	mov	w10, w27
   ad834:      	strh	w27, [x22, #0x1bca]
   ad838:      	adrp	x9, 0xe9000 <g_algo+0x330>
   ad83c:      	ldrh	w9, [x9, #0x724]
   ad840:      	cbz	w10, 0xad87c <air1_opcal5_algorithm+0x4c98>
   ad844:      	cmp	w8, w9
   ad848:      	b.hi	0xad87c <air1_opcal5_algorithm+0x4c98>
   ad84c:      	fcmp	d0, d14
   ad850:      	b.lt	0xad87c <air1_opcal5_algorithm+0x4c98>
   ad854:      	mov	x11, #0x4049000000000000 // =4632233691727265792
   ad858:      	fmov	d3, x11
   ad85c:      	fcmp	d0, d3
   ad860:      	b.hi	0xad87c <air1_opcal5_algorithm+0x4c98>
   ad864:      	ldr	d3, [x22, #0x1ba0]
   ad868:      	ldrh	w11, [x22, #0x1ba8]
   ad86c:      	fadd	d3, d0, d3
   ad870:      	add	w11, w11, #0x1
   ad874:      	str	d3, [x22, #0x1ba0]
   ad878:      	strh	w11, [x22, #0x1ba8]
   ad87c:      	cmp	w8, w9
   ad880:      	b.ls	0xad8b0 <air1_opcal5_algorithm+0x4ccc>
   ad884:      	ldrb	w11, [x4, #0x9e]
   ad888:      	cbnz	w11, 0xad8b0 <air1_opcal5_algorithm+0x4ccc>
   ad88c:      	cmp	w27, #0x120
   ad890:      	b.lo	0xad8a4 <air1_opcal5_algorithm+0x4cc0>
   ad894:      	cmp	w10, w27
   ad898:      	b.eq	0xad8a4 <air1_opcal5_algorithm+0x4cc0>
   ad89c:      	ldrh	w10, [x22, #0x1ba8]
   ad8a0:      	cbnz	w10, 0xad8a8 <air1_opcal5_algorithm+0x4cc4>
   ad8a4:      	strb	wzr, [x4, #0x9f]
   ad8a8:      	mov	w10, #0x1               // =1
   ad8ac:      	strb	w10, [x4, #0x9e]
   ad8b0:      	ldrb	w10, [x4]
   ad8b4:      	sub	w10, w10, #0x1
   ad8b8:      	cmp	w10, #0x5
   ad8bc:      	b.hi	0xad8f0 <air1_opcal5_algorithm+0x4d0c>
   ad8c0:      	ldr	h3, [x22, #0x1ba8]
   ad8c4:      	adrp	x13, 0x31000 <air1_opcal4_loess_weight_arr+0x76e8>
   ad8c8:      	add	x13, x13, #0x7e0
   ad8cc:      	ldr	d4, [x22, #0x1ba0]
   ad8d0:      	ucvtf	d3, d3
   ad8d4:      	adr	x11, 0xad8e8 <air1_opcal5_algorithm+0x4d04>
   ad8d8:      	ldrb	w12, [x13, x10]
   ad8dc:      	add	x11, x11, x12, lsl #2
   ad8e0:      	fdiv	d3, d4, d3
   ad8e4:      	br	x11
   ad8e8:      	fadd	d2, d2, d3
   ad8ec:      	b	0xad938 <air1_opcal5_algorithm+0x4d54>
   ad8f0:      	movi	d2, #0000000000000000
   ad8f4:      	b	0xad938 <air1_opcal5_algorithm+0x4d54>
   ad8f8:      	mov	x10, #0x6666666666666666 // =7378697629483820646
   ad8fc:      	movk	x10, #0x3fee, lsl #48
   ad900:      	b	0xad90c <air1_opcal5_algorithm+0x4d28>
   ad904:      	mov	x10, #0x3333333333333333 // =3689348814741910323
   ad908:      	movk	x10, #0x3feb, lsl #48
   ad90c:      	fmov	d4, x10
   ad910:      	fmadd	d2, d3, d4, d2
   ad914:      	b	0xad938 <air1_opcal5_algorithm+0x4d54>
   ad918:      	adrp	x10, 0x1000 <strcasecmp+0x1000>
   ad91c:      	ldr	d4, [x10, #0x6c0]
   ad920:      	fmadd	d2, d3, d4, d2
   ad924:      	b	0xad938 <air1_opcal5_algorithm+0x4d54>
   ad928:      	fmov	d4, #0.75000000
   ad92c:      	fmadd	d2, d3, d4, d2
   ad930:      	b	0xad938 <air1_opcal5_algorithm+0x4d54>
   ad934:      	fmov	d2, d0
   ad938:      	fmov	d3, d0
   ad93c:      	ldrb	w10, [x4, #0x9f]
   ad940:      	cbz	w10, 0xad980 <air1_opcal5_algorithm+0x4d9c>
   ad944:      	adrp	x10, 0xe9000 <g_algo+0x330>
   ad948:      	ldrh	w10, [x10, #0x726]
   ad94c:      	cmp	w8, w10
   ad950:      	fcsel	d3, d2, d0, hi
   ad954:      	b.hi	0xad980 <air1_opcal5_algorithm+0x4d9c>
   ad958:      	cmp	w8, w9
   ad95c:      	b.ls	0xad980 <air1_opcal5_algorithm+0x4d9c>
   ad960:      	ucvtf	d3, w9
   ad964:      	ucvtf	d4, w10
   ad968:      	fsub	d5, d1, d3
   ad96c:      	fsub	d3, d4, d3
   ad970:      	fdiv	d3, d5, d3
   ad974:      	fsub	d4, d12, d3
   ad978:      	fmul	d2, d2, d3
   ad97c:      	fmadd	d3, d4, d0, d2
   ad980:      	fcmp	d3, d0
   ad984:      	fcsel	d0, d0, d3, mi
   ad988:      	adrp	x9, 0xe9000 <g_algo+0x330>
   ad98c:      	adrp	x10, 0xe9000 <g_algo+0x330>
   ad990:      	add	x10, x10, #0x290
   ad994:      	ldrb	w9, [x9, #0x732]
   ad998:      	str	d0, [x10]
   ad99c:      	str	d0, [x10, #0x8]
   ad9a0:      	cmp	w9, #0x1
   ad9a4:      	b.ne	0xada00 <air1_opcal5_algorithm+0x4e1c>
   ad9a8:      	adrp	x9, 0xe9000 <g_algo+0x330>
   ad9ac:      	cmp	w8, #0x724
   ad9b0:      	add	x9, x9, #0x738
   ad9b4:      	ldp	d2, d3, [x9, #0x8]
   ad9b8:      	ldr	d5, [x9, #0x18]
   ad9bc:      	ldr	d4, [x9]
   ad9c0:      	fmul	d2, d2, d1
   ad9c4:      	fmul	d3, d3, d1
   ad9c8:      	fmul	d2, d2, d1
   ad9cc:      	fmul	d3, d3, d1
   ad9d0:      	fmadd	d2, d2, d1, d3
   ad9d4:      	ldr	d3, [x9, #0x20]
   ad9d8:      	adrp	x9, 0xe9000 <g_algo+0x330>
   ad9dc:      	fmadd	d2, d5, d1, d2
   ad9e0:      	fadd	d2, d3, d2
   ad9e4:      	fsub	d3, d12, d4
   ad9e8:      	fmul	d4, d4, d2
   ad9ec:      	fccmp	d2, d12, #0x0, ls
   ad9f0:      	fadd	d3, d3, d4
   ad9f4:      	fcsel	d2, d12, d3, gt
   ad9f8:      	fdiv	d0, d0, d2
   ad9fc:      	str	d0, [x9, #0x298]
   ada00:      	adrp	x9, 0xe8000 <quick_sel_arr+0x1810>
   ada04:      	ldr	d3, [x22, #0x50]
   ada08:      	add	x9, x9, #0xcd4
   ada0c:      	ldrb	w10, [x4, #0xc2]
   ada10:      	ldur	d2, [x9, #0x44]
   ada14:      	ldrb	w12, [x9, #0xc4]
   ada18:      	ldr	w11, [x9]
   ada1c:      	ldr	w9, [x22, #0x248]
   ada20:      	str	d2, [x22, #0x50]
   ada24:      	cbnz	w12, 0xada64 <air1_opcal5_algorithm+0x4e80>
   ada28:      	cmp	w27, #0x2
   ada2c:      	b.lo	0xada64 <air1_opcal5_algorithm+0x4e80>
   ada30:      	cmp	w10, #0x2
   ada34:      	b.hi	0xada64 <air1_opcal5_algorithm+0x4e80>
   ada38:      	fcmp	d2, d3
   ada3c:      	b.ne	0xada5c <air1_opcal5_algorithm+0x4e78>
   ada40:      	mov	x13, #0x4049000000000000 // =4632233691727265792
   ada44:      	fmov	d3, x13
   ada48:      	fcmp	d2, d3
   ada4c:      	fmov	d3, #5.00000000
   ada50:      	fccmp	d2, d3, #0x8, le
   ada54:      	csinc	w10, wzr, w10, pl
   ada58:      	b	0xada60 <air1_opcal5_algorithm+0x4e7c>
   ada5c:      	mov	w10, wzr
   ada60:      	strb	w10, [x4, #0xc2]
   ada64:      	and	w13, w10, #0xff
   ada68:      	adrp	x15, 0xe9000 <g_algo+0x330>
   ada6c:      	cmp	w13, #0x3
   ada70:      	cset	w13, ne
   ada74:      	fcmp	d2, #0.0
   ada78:      	strb	w13, [x15, #0x2b0]
   ada7c:      	b.ne	0xada8c <air1_opcal5_algorithm+0x4ea8>
   ada80:      	mov	x12, #0x7ff8000000000000 // =9221120237041090560
   ada84:      	fmov	d2, x12
   ada88:      	b	0xadae4 <air1_opcal5_algorithm+0x4f00>
   ada8c:      	fcmp	d2, d8
   ada90:      	b.pl	0xadab0 <air1_opcal5_algorithm+0x4ecc>
   ada94:      	fmov	d3, #5.00000000
   ada98:      	fcmp	d2, d3
   ada9c:      	ccmp	w12, #0x0, #0x0, mi
   adaa0:      	mov	x12, #0x7ff8000000000000 // =9221120237041090560
   adaa4:      	fmov	d2, x12
   adaa8:      	fcsel	d2, d2, d8, eq
   adaac:      	b	0xadae4 <air1_opcal5_algorithm+0x4f00>
   adab0:      	mov	x15, #0x800000000000    // =140737488355328
   adab4:      	movk	x15, #0x4046, lsl #48
   adab8:      	fmov	d3, x15
   adabc:      	fcmp	d2, d3
   adac0:      	b.le	0xadae4 <air1_opcal5_algorithm+0x4f00>
   adac4:      	mov	x13, #0x4049000000000000 // =4632233691727265792
   adac8:      	fmov	d3, x13
   adacc:      	fcmp	d2, d3
   adad0:      	fmov	d2, x15
   adad4:      	ccmp	w12, #0x0, #0x0, gt
   adad8:      	mov	x12, #0x7ff8000000000000 // =9221120237041090560
   adadc:      	fmov	d3, x12
   adae0:      	fcsel	d2, d3, d2, eq
   adae4:      	cmp	w27, #0x1
   adae8:      	b.eq	0xadb1c <air1_opcal5_algorithm+0x4f38>
   adaec:      	mvn	x12, x9
   adaf0:      	add	x11, x12, x11
   adaf4:      	cmp	x11, #0x1de
   adaf8:      	b.hi	0xadb1c <air1_opcal5_algorithm+0x4f38>
   adafc:      	ldr	d3, [x22, #0x1be0]
   adb00:      	ldr	d4, [x22, #0x1bd8]
   adb04:      	ldr	d5, [x22, #0x1bd0]
   adb08:      	str	d2, [x22, #0x1bd0]
   adb0c:      	str	d3, [x22, #0x1be8]
   adb10:      	str	d4, [x22, #0x1be0]
   adb14:      	str	d5, [x22, #0x1bd8]
   adb18:      	b	0xadb3c <air1_opcal5_algorithm+0x4f58>
   adb1c:      	mov	x11, #0x7ff8000000000000 // =9221120237041090560
   adb20:      	str	d2, [x22, #0x1bd0]
   adb24:      	fmov	d3, x11
   adb28:      	dup	v6.2d, x11
   adb2c:      	str	x11, [x22, #0x1be8]
   adb30:      	stur	q6, [x4, #0xaa]
   adb34:      	fmov	d4, d3
   adb38:      	fmov	d5, d3
   adb3c:      	mov	x11, #-0x8000000000000000 // =-9223372036854775808
   adb40:      	fcmp	d3, d3
   adb44:      	fadd	d7, d2, d9
   adb48:      	and	w10, w10, #0xff
   adb4c:      	fmov	d6, x11
   adb50:      	cset	w11, vc
   adb54:      	fcsel	d3, d3, d6, vc
   adb58:      	fcmp	d2, d2
   adb5c:      	fcsel	d2, d7, d9, vc
   adb60:      	cinc	w11, w11, vc
   adb64:      	fcmp	d4, d4
   adb68:      	fcsel	d4, d4, d6, vc
   adb6c:      	cinc	w11, w11, vc
   adb70:      	fcmp	d5, d5
   adb74:      	fcsel	d5, d5, d6, vc
   adb78:      	cinc	w11, w11, vc
   adb7c:      	cmp	w10, #0x3
   adb80:      	adrp	x10, 0xe9000 <g_algo+0x330>
   adb84:      	fadd	d2, d2, d5
   adb88:      	fadd	d2, d4, d2
   adb8c:      	fadd	d2, d3, d2
   adb90:      	ucvtf	d3, w11
   adb94:      	fdiv	d4, d2, d3
   adb98:      	fmov	d3, #1.00000000
   adb9c:      	str	d4, [x10, #0x2a0]
   adba0:      	b.eq	0xadbe0 <air1_opcal5_algorithm+0x4ffc>
   adba4:      	adrp	x10, 0xe9000 <g_algo+0x330>
   adba8:      	fcmp	d2, #0.0
   adbac:      	add	x10, x10, #0x8f0
   adbb0:      	ldp	d3, d5, [x10]
   adbb4:      	fmadd	d3, d3, d4, d5
   adbb8:      	fcsel	d2, d12, d3, eq
   adbbc:      	ldr	d3, [x10, #0x10]
   adbc0:      	adrp	x10, 0xe9000 <g_algo+0x330>
   adbc4:      	fcmp	d2, d3
   adbc8:      	str	d2, [x10, #0x2a8]
   adbcc:      	b.mi	0xadbe0 <air1_opcal5_algorithm+0x4ffc>
   adbd0:      	adrp	x10, 0xe9000 <g_algo+0x330>
   adbd4:      	ldr	d3, [x10, #0x908]
   adbd8:      	fcmp	d2, d3
   adbdc:      	b.le	0xadbec <air1_opcal5_algorithm+0x5008>
   adbe0:      	fmov	d2, d3
   adbe4:      	adrp	x10, 0xe9000 <g_algo+0x330>
   adbe8:      	str	d3, [x10, #0x2a8]
   adbec:      	ldr	x10, [sp, #0x3b0]
   adbf0:      	ldur	s3, [x10, #0x5]
   adbf4:      	mov	x10, #0x4059000000000000 // =4636737291354636288
   adbf8:      	fcvt	d3, s3
   adbfc:      	fmov	d4, x10
   adc00:      	ldrh	w10, [x24, #0x368]
   adc04:      	fdiv	d3, d3, d4
   adc08:      	ldr	d4, [x24]
   adc0c:      	cmp	w8, w10
   adc10:      	adrp	x10, 0xe9000 <g_algo+0x330>
   adc14:      	fmul	d3, d4, d3
   adc18:      	fmul	d2, d2, d3
   adc1c:      	fdiv	d0, d0, d2
   adc20:      	str	d0, [x10, #0x2b8]
   adc24:      	b.hi	0xadc8c <air1_opcal5_algorithm+0x50a8>
   adc28:      	ldr	d2, [x24, #0x370]
   adc2c:      	fcmp	d2, d0
   adc30:      	b.lt	0xadc8c <air1_opcal5_algorithm+0x50a8>
   adc34:      	adrp	x10, 0xe9000 <g_algo+0x330>
   adc38:      	fmul	d3, d0, d0
   adc3c:      	add	x10, x10, #0x9f0
   adc40:      	ldr	x24, [sp, #0x188]
   adc44:      	ldp	d4, d2, [x10]
   adc48:      	fmul	d2, d0, d2
   adc4c:      	fmadd	d2, d4, d3, d2
   adc50:      	ldr	d3, [x10, #0x10]
   adc54:      	ldrh	w10, [x10, #0x28]
   adc58:      	fadd	d2, d3, d2
   adc5c:      	cmp	w8, w10
   adc60:      	b.ls	0xadc94 <air1_opcal5_algorithm+0x50b0>
   adc64:      	adrp	x8, 0xe9000 <g_algo+0x330>
   adc68:      	ucvtf	d3, w10
   adc6c:      	ldr	h4, [x8, #0xa1a]
   adc70:      	fsub	d1, d1, d3
   adc74:      	ucvtf	d3, d4
   adc78:      	fdiv	d1, d1, d3
   adc7c:      	fsub	d3, d12, d1
   adc80:      	fmul	d0, d0, d1
   adc84:      	fmadd	d0, d3, d2, d0
   adc88:      	b	0xadc98 <air1_opcal5_algorithm+0x50b4>
   adc8c:      	ldr	x24, [sp, #0x188]
   adc90:      	b	0xadc98 <air1_opcal5_algorithm+0x50b4>
   adc94:      	fmov	d0, d2
   adc98:      	ldr	x10, [sp, #0x1d0]
   adc9c:      	str	d0, [x14, #0x5f0]
   adca0:      	ldr	x11, [sp, #0x120]
   adca4:      	cmp	w27, #0x1
   adca8:      	ldr	x8, [x10, #0x10]
   adcac:      	ldr	q1, [x10]
   adcb0:      	str	x8, [x11, #0x10]
   adcb4:      	mov	x8, #0x7ff8000000000000 // =9221120237041090560
   adcb8:      	str	q1, [x11]
   adcbc:      	str	x8, [x10]
   adcc0:      	b.eq	0xadd04 <air1_opcal5_algorithm+0x5120>
   adcc4:      	ldrh	w10, [x14]
   adcc8:      	cmp	w10, #0x9
   adccc:      	b.ls	0xadd04 <air1_opcal5_algorithm+0x5120>
   adcd0:      	ldr	w8, [x30, #0xcd4]
   adcd4:      	ldrh	w12, [x22, #0x6ce]
   adcd8:      	ldrh	w11, [x22, #0x1ce]
   adcdc:      	sub	x8, x8, x9
   adce0:      	ldr	x27, [sp, #0xb8]
   adce4:      	cmp	w11, w12
   adce8:      	b.ls	0xadd18 <air1_opcal5_algorithm+0x5134>
   adcec:      	cmp	w11, w10
   adcf0:      	cset	w9, lo
   adcf4:      	cmp	x8, #0x438
   adcf8:      	cset	w10, gt
   adcfc:      	and	w9, w9, w10
   add00:      	b	0xadd1c <air1_opcal5_algorithm+0x5138>
   add04:      	mov	w8, #0x1                // =1
   add08:      	adrp	x9, 0xe9000 <g_algo+0x330>
   add0c:      	ldr	x27, [sp, #0xb8]
   add10:      	strb	w8, [x9, #0x2d0]
   add14:      	b	0xade2c <air1_opcal5_algorithm+0x5248>
   add18:      	mov	w9, wzr
   add1c:      	tbnz	w9, #0x0, 0xade20 <air1_opcal5_algorithm+0x523c>
   add20:      	cmp	x8, #0x5dd
   add24:      	b.ge	0xade20 <air1_opcal5_algorithm+0x523c>
   add28:      	scvtf	d1, x8
   add2c:      	mov	x8, #0x404e000000000000 // =4633641066610819072
   add30:      	ldr	d3, [x22, #0x1c18]
   add34:      	ldr	d4, [x22, #0x1c20]
   add38:      	fmov	d2, x8
   add3c:      	fdiv	d1, d1, d2
   add40:      	ldr	d2, [x22, #0x1c38]
   add44:      	fsub	d2, d0, d2
   add48:      	fdiv	d1, d2, d1
   add4c:      	ldr	d2, [x22, #0x1c28]
   add50:      	fcmp	d1, d1
   add54:      	str	d1, [x22, #0x1c10]
   add58:      	cset	w8, vs
   add5c:      	fcmp	d3, d3
   add60:      	cinc	w8, w8, vs
   add64:      	fcmp	d4, d4
   add68:      	cinc	w8, w8, vs
   add6c:      	fcmp	d2, d2
   add70:      	csetm	w9, vs
   add74:      	cmp	w8, w9
   add78:      	b.ne	0xae34c <air1_opcal5_algorithm+0x5768>
   add7c:      	mov	x8, #-0x8000000000000000 // =-9223372036854775808
   add80:      	fcmp	d4, d4
   add84:      	fadd	d5, d3, d9
   add88:      	fmov	d6, x8
   add8c:      	cset	w8, vc
   add90:      	fcsel	d4, d4, d6, vc
   add94:      	fcmp	d3, d3
   add98:      	fcsel	d3, d5, d9, vc
   add9c:      	cinc	w8, w8, vc
   adda0:      	fcmp	d2, d2
   adda4:      	ldr	d5, [x22, #0x1c30]
   adda8:      	fcsel	d2, d2, d6, vc
   addac:      	cinc	w8, w8, vc
   addb0:      	fcmp	d5, #0.0
   addb4:      	b.ne	0xae32c <air1_opcal5_algorithm+0x5748>
   addb8:      	fadd	d3, d3, d4
   addbc:      	fadd	d2, d3, d2
   addc0:      	ucvtf	d3, w8
   addc4:      	fdiv	d2, d2, d3
   addc8:      	fmov	d3, #5.00000000
   addcc:      	fcmp	d1, d3
   addd0:      	b.le	0xadddc <air1_opcal5_algorithm+0x51f8>
   addd4:      	fcmp	d2, d12
   addd8:      	b.mi	0xaddf4 <air1_opcal5_algorithm+0x5210>
   adddc:      	fmov	d3, #-5.00000000
   adde0:      	fcmp	d1, d3
   adde4:      	b.pl	0xae34c <air1_opcal5_algorithm+0x5768>
   adde8:      	fmov	d1, #-1.00000000
   addec:      	fcmp	d2, d1
   addf0:      	b.le	0xae34c <air1_opcal5_algorithm+0x5768>
   addf4:      	mov	x9, #0x3ff0000000000000 // =4607182418800017408
   addf8:      	adrp	x10, 0xe9000 <g_algo+0x330>
   addfc:      	mov	w8, wzr
   ade00:      	movi	d1, #0000000000000000
   ade04:      	fmov	d2, d0
   ade08:      	fmov	d3, d0
   ade0c:      	str	x9, [x22, #0x1c30]
   ade10:      	mov	w9, #0x3                // =3
   ade14:      	strb	w9, [x4, #0xc3]
   ade18:      	strb	w9, [x10, #0x2d0]
   ade1c:      	b	0xade40 <air1_opcal5_algorithm+0x525c>
   ade20:      	adrp	x8, 0xe9000 <g_algo+0x330>
   ade24:      	str	xzr, [x22, #0x1c30]
   ade28:      	strb	w23, [x8, #0x2d0]
   ade2c:      	mov	w8, wzr
   ade30:      	movi	d1, #0000000000000000
   ade34:      	fmov	d2, d0
   ade38:      	fmov	d3, d0
   ade3c:      	strb	wzr, [x4, #0xc3]
   ade40:      	adrp	x9, 0xe9000 <g_algo+0x330>
   ade44:      	add	x9, x9, #0x7f0
   ade48:      	ldp	d5, d4, [x9, #0x90]
   ade4c:      	ldp	d7, d6, [x9, #0x78]
   ade50:      	ldr	d16, [x9, #0x88]
   ade54:      	fmul	d4, d2, d4
   ade58:      	fmul	d6, d2, d6
   ade5c:      	fmadd	d4, d5, d3, d4
   ade60:      	ldp	d5, d17, [x9, #0xa0]
   ade64:      	fmadd	d6, d7, d3, d6
   ade68:      	ldr	d7, [x9, #0x60]
   ade6c:      	fmadd	d4, d5, d1, d4
   ade70:      	ldp	d5, d18, [x9, #0x68]
   ade74:      	fmadd	d6, d16, d1, d6
   ade78:      	fmul	d5, d4, d5
   ade7c:      	fmadd	d5, d7, d6, d5
   ade80:      	ldp	d16, d7, [x9, #0xb0]
   ade84:      	fmadd	d5, d18, d4, d5
   ade88:      	fmul	d2, d2, d16
   ade8c:      	fmadd	d2, d17, d3, d2
   ade90:      	fsub	d3, d0, d5
   ade94:      	fmadd	d1, d7, d1, d2
   ade98:      	ldr	d7, [x9, #0x10]
   ade9c:      	ldp	d5, d2, [x9]
   adea0:      	add	w9, w8, #0x1
   adea4:      	fmadd	d5, d5, d3, d6
   adea8:      	strh	w9, [x22, #0x1bf2]
   adeac:      	fmadd	d2, d2, d3, d4
   adeb0:      	fmadd	d3, d7, d3, d1
   adeb4:      	fmov	d1, d0
   adeb8:      	str	d5, [x22, #0x1bf8]
   adebc:      	str	d2, [x22, #0x1c00]
   adec0:      	str	d3, [x22, #0x1c08]
   adec4:      	cbz	w8, 0xadef8 <air1_opcal5_algorithm+0x5314>
   adec8:      	and	w8, w9, #0xffff
   adecc:      	cmp	w8, #0x19
   aded0:      	b.hi	0xadef4 <air1_opcal5_algorithm+0x5310>
   aded4:      	sub	w8, w8, #0x1
   aded8:      	fmov	d3, #24.00000000
   adedc:      	scvtf	d1, w8
   adee0:      	fdiv	d1, d1, d3
   adee4:      	fsub	d3, d12, d1
   adee8:      	fmul	d1, d1, d2
   adeec:      	fmadd	d1, d3, d0, d1
   adef0:      	b	0xadef8 <air1_opcal5_algorithm+0x5314>
   adef4:      	fmov	d1, d2
   adef8:      	adrp	x8, 0xe9000 <g_algo+0x330>
   adefc:      	str	d0, [x22, #0x1c38]
   adf00:      	movi	v0.2d, #0000000000000000
   adf04:      	str	d1, [x8, #0x2c8]
   adf08:      	adrp	x8, 0xe9000 <g_algo+0x330>
   adf0c:      	str	q0, [x19, #0xb90]
   adf10:      	ldrb	w8, [x8, #0x8b0]
   adf14:      	str	q0, [x19, #0xb80]
   adf18:      	str	q0, [x19, #0xb70]
   adf1c:      	str	q0, [x19, #0xb60]
   adf20:      	sub	w9, w8, #0x1
   adf24:      	cmp	w8, #0x2
   adf28:      	str	q0, [x19, #0xb50]
   adf2c:      	b.lo	0xadfbc <air1_opcal5_algorithm+0x53d8>
   adf30:      	cmp	w9, #0x4
   adf34:      	b.hs	0xadf40 <air1_opcal5_algorithm+0x535c>
   adf38:      	mov	x10, xzr
   adf3c:      	b	0xadf80 <air1_opcal5_algorithm+0x539c>
   adf40:      	and	x10, x9, #0xfffffffc
   adf44:      	ldr	x11, [sp, #0x20]
   adf48:      	mov	x12, x24
   adf4c:      	mov	x13, x10
   adf50:      	ldp	q0, q1, [x12, #-0x10]
   adf54:      	subs	x13, x13, #0x4
   adf58:      	stur	q0, [x12, #-0x18]
   adf5c:      	stur	q1, [x12, #-0x8]
   adf60:      	add	x12, x12, #0x20
   adf64:      	ldp	d0, d1, [x11, #-0x8]
   adf68:      	stur	d0, [x11, #-0xc]
   adf6c:      	stur	d1, [x11, #-0x4]
   adf70:      	add	x11, x11, #0x10
   adf74:      	b.ne	0xadf50 <air1_opcal5_algorithm+0x536c>
   adf78:      	cmp	x10, x9
   adf7c:      	b.eq	0xadfb4 <air1_opcal5_algorithm+0x53d0>
   adf80:      	ldr	x11, [sp, #0xb0]
   adf84:      	ldr	x12, [sp, #0x60]
   adf88:      	add	x11, x11, x10, lsl #2
   adf8c:      	add	x12, x12, x10, lsl #3
   adf90:      	sub	x10, x9, x10
   adf94:      	ldr	d0, [x12]
   adf98:      	subs	x10, x10, #0x1
   adf9c:      	stur	d0, [x12, #-0x8]
   adfa0:      	add	x12, x12, #0x8
   adfa4:      	ldr	w13, [x11]
   adfa8:      	stur	w13, [x11, #-0x4]
   adfac:      	add	x11, x11, #0x4
   adfb0:      	b.ne	0xadf94 <air1_opcal5_algorithm+0x53b0>
   adfb4:      	adrp	x10, 0xe9000 <g_algo+0x330>
   adfb8:      	ldr	d1, [x10, #0x2c8]
   adfbc:      	add	x9, x22, w9, sxtw #3
   adfc0:      	add	x8, x22, x8, lsl #2
   adfc4:      	str	d1, [x9, #0x1c40]
   adfc8:      	ldr	w9, [x30, #0xcd4]
   adfcc:      	str	w9, [x8, #0x1c8c]
   adfd0:      	ldrb	w8, [x21, #0x8b1]
   adfd4:      	cmp	x8, #0x2
   adfd8:      	b.lo	0xae008 <air1_opcal5_algorithm+0x5424>
   adfdc:      	mov	x8, xzr
   adfe0:      	ldr	x9, [sp, #0x88]
   adfe4:      	ldrb	w10, [x9]
   adfe8:      	add	x8, x8, #0x1
   adfec:      	sturb	w10, [x9, #-0x1]
   adff0:      	add	x9, x9, #0x1
   adff4:      	ldrb	w10, [x21, #0x8b1]
   adff8:      	sub	x10, x10, #0x1
   adffc:      	cmp	x8, x10
   ae000:      	b.lt	0xadfe4 <air1_opcal5_algorithm+0x5400>
   ae004:      	b	0xae00c <air1_opcal5_algorithm+0x5428>
   ae008:      	sub	x10, x8, #0x1
   ae00c:      	mov	w9, #0x1cb8             // =7352
   ae010:      	add	x8, x22, x10
   ae014:      	strb	wzr, [x8, x9]
   ae018:      	adrp	x9, 0xe9000 <g_algo+0x330>
   ae01c:      	ldrh	w8, [x22, #0x250]
   ae020:      	ldrb	w19, [x9, #0x8b0]
   ae024:      	cmp	w8, w19
   ae028:      	b.hs	0xae078 <air1_opcal5_algorithm+0x5494>
   ae02c:      	ldrb	w8, [x21, #0x8b1]
   ae030:      	add	x19, sp, #0x430
   ae034:      	cbz	x8, 0xae530 <air1_opcal5_algorithm+0x594c>
   ae038:      	mov	x9, xzr
   ae03c:      	lsl	x10, x9, #1
   ae040:      	lsl	x12, x9, #3
   ae044:      	add	x11, x22, x10
   ae048:      	add	x10, x14, x10
   ae04c:      	ldrh	w11, [x11, #0x6c4]
   ae050:      	strh	w11, [x10, #0x602]
   ae054:      	add	x10, x14, x12
   ae058:      	ldr	d0, [x24, x12]
   ae05c:      	add	x11, x14, x9
   ae060:      	add	x9, x9, #0x1
   ae064:      	cmp	x8, x9
   ae068:      	str	d0, [x10, #0x610]
   ae06c:      	strb	wzr, [x11, #0x640]
   ae070:      	b.ne	0xae03c <air1_opcal5_algorithm+0x5458>
   ae074:      	b	0xae530 <air1_opcal5_algorithm+0x594c>
   ae078:      	movi	v0.2d, #0000000000000000
   ae07c:      	add	x8, sp, #0x430
   ae080:      	str	q0, [x8, #0x8c0]
   ae084:      	str	q0, [x8, #0x8b0]
   ae088:      	str	q0, [x8, #0x8a0]
   ae08c:      	str	q0, [x8, #0x890]
   ae090:      	str	q0, [x8, #0x880]
   ae094:      	cbz	w19, 0xae0d0 <air1_opcal5_algorithm+0x54ec>
   ae098:      	lsl	x2, x19, #3
   ae09c:      	add	x0, sp, #0xcb0
   ae0a0:      	ldr	x1, [sp, #0x30]
   ae0a4:      	bl	0xbf060 <memcpy@plt>
   ae0a8:      	cmp	w19, #0x1
   ae0ac:      	b.ne	0xae0dc <air1_opcal5_algorithm+0x54f8>
   ae0b0:      	ldr	x3, [sp, #0x3d0]
   ae0b4:      	adrp	x14, 0xe8000 <quick_sel_arr+0x1810>
   ae0b8:      	ldr	x4, [sp, #0x3c8]
   ae0bc:      	movi	d0, #0000000000000000
   ae0c0:      	mov	w19, #0x1               // =1
   ae0c4:      	add	x14, x14, #0xcd0
   ae0c8:      	adrp	x30, 0xe8000 <quick_sel_arr+0x1810>
   ae0cc:      	b	0xae160 <air1_opcal5_algorithm+0x557c>
   ae0d0:      	mov	x8, #0x7ff8000000000000 // =9221120237041090560
   ae0d4:      	fmov	d0, x8
   ae0d8:      	b	0xae160 <air1_opcal5_algorithm+0x557c>
   ae0dc:      	movi	d0, #0000000000000000
   ae0e0:      	mov	w8, wzr
   ae0e4:      	add	x9, sp, #0xcb0
   ae0e8:      	mov	x10, x19
   ae0ec:      	mov	x11, #-0x8000000000000000 // =-9223372036854775808
   ae0f0:      	ldr	d1, [x9], #0x8
   ae0f4:      	fmov	d2, x11
   ae0f8:      	fcmp	d1, d1
   ae0fc:      	fcsel	d1, d1, d2, vc
   ae100:      	cinc	w8, w8, vc
   ae104:      	subs	x10, x10, #0x1
   ae108:      	fadd	d0, d0, d1
   ae10c:      	b.ne	0xae0f0 <air1_opcal5_algorithm+0x550c>
   ae110:      	and	w8, w8, #0xffff
   ae114:      	adrp	x14, 0xe8000 <quick_sel_arr+0x1810>
   ae118:      	mov	x9, x19
   ae11c:      	ldr	x3, [sp, #0x3d0]
   ae120:      	ldr	x4, [sp, #0x3c8]
   ae124:      	add	x14, x14, #0xcd0
   ae128:      	ucvtf	d1, w8
   ae12c:      	add	x8, sp, #0xcb0
   ae130:      	adrp	x30, 0xe8000 <quick_sel_arr+0x1810>
   ae134:      	fdiv	d1, d0, d1
   ae138:      	movi	d0, #0000000000000000
   ae13c:      	ldr	d2, [x8], #0x8
   ae140:      	subs	x9, x9, #0x1
   ae144:      	fsub	d2, d2, d1
   ae148:      	fmadd	d0, d2, d2, d0
   ae14c:      	b.ne	0xae13c <air1_opcal5_algorithm+0x5558>
   ae150:      	sub	w8, w19, #0x1
   ae154:      	scvtf	d1, w8
   ae158:      	fdiv	d0, d0, d1
   ae15c:      	fsqrt	d0, d0
   ae160:      	cmp	w19, #0x1
   ae164:      	ldr	x9, [sp, #0xb0]
   ae168:      	csinc	w8, w19, wzr, gt
   ae16c:      	add	x19, sp, #0x430
   ae170:      	sub	w8, w8, #0x1
   ae174:      	cbz	x8, 0xae194 <air1_opcal5_algorithm+0x55b0>
   ae178:      	ldp	w11, w10, [x9, #-0x4]
   ae17c:      	add	x9, x9, #0x4
   ae180:      	sub	x8, x8, #0x1
   ae184:      	sub	x10, x10, x11
   ae188:      	cmp	x10, #0x258
   ae18c:      	b.lt	0xae174 <air1_opcal5_algorithm+0x5590>
   ae190:      	b	0xae1e8 <air1_opcal5_algorithm+0x5604>
   ae194:      	adrp	x8, 0x1000 <strcasecmp+0x1000>
   ae198:      	ldr	d1, [x8, #0x680]
   ae19c:      	fcmp	d0, d1
   ae1a0:      	b.mi	0xae1e8 <air1_opcal5_algorithm+0x5604>
   ae1a4:      	adrp	x24, 0xe9000 <g_algo+0x330>
   ae1a8:      	add	x0, sp, #0xcb0
   ae1ac:      	add	x24, x24, #0x8b1
   ae1b0:      	add	x2, sp, #0xf80
   ae1b4:      	add	x1, x24, #0x7
   ae1b8:      	bl	0xb98d0 <smooth_sg>
   ae1bc:      	adrp	x14, 0xe8000 <quick_sel_arr+0x1810>
   ae1c0:      	adrp	x30, 0xe8000 <quick_sel_arr+0x1810>
   ae1c4:      	add	x14, x14, #0xcd0
   ae1c8:      	ldr	x4, [sp, #0x3c8]
   ae1cc:      	ldr	x3, [sp, #0x3d0]
   ae1d0:      	ldrb	w8, [x24]
   ae1d4:      	cbz	w8, 0xae530 <air1_opcal5_algorithm+0x594c>
   ae1d8:      	cmp	w8, #0x1
   ae1dc:      	b.ne	0xae3b8 <air1_opcal5_algorithm+0x57d4>
   ae1e0:      	mov	x9, xzr
   ae1e4:      	b	0xae4a8 <air1_opcal5_algorithm+0x58c4>
   ae1e8:      	ldrb	w8, [x21, #0x8b1]
   ae1ec:      	cbz	w8, 0xae530 <air1_opcal5_algorithm+0x594c>
   ae1f0:      	cmp	w8, #0x1
   ae1f4:      	b.ne	0xae238 <air1_opcal5_algorithm+0x5654>
   ae1f8:      	mov	x9, xzr
   ae1fc:      	lsl	x12, x9, #3
   ae200:      	add	x10, x14, x9
   ae204:      	add	x11, x14, x12
   ae208:      	sub	x8, x8, x9
   ae20c:      	add	x10, x10, #0x640
   ae210:      	add	x9, x27, x9
   ae214:      	add	x11, x11, #0x610
   ae218:      	add	x12, x24, x12
   ae21c:      	ldr	d0, [x12], #0x8
   ae220:      	subs	x8, x8, #0x1
   ae224:      	str	d0, [x11], #0x8
   ae228:      	ldrb	w13, [x9], #0x1
   ae22c:      	strb	w13, [x10], #0x1
   ae230:      	b.ne	0xae21c <air1_opcal5_algorithm+0x5638>
   ae234:      	b	0xae4e8 <air1_opcal5_algorithm+0x5904>
   ae238:      	adrp	x14, 0xe9000 <g_algo+0x330>
   ae23c:      	lsl	x10, x8, #3
   ae240:      	add	x14, x14, #0x2e0
   ae244:      	add	x16, x24, x10
   ae248:      	add	x15, x14, #0x30
   ae24c:      	add	x13, x14, x10
   ae250:      	add	x17, x15, x8
   ae254:      	add	x10, x22, x8
   ae258:      	cmp	x17, x14
   ae25c:      	mov	w11, #0x1cb8            // =7352
   ae260:      	cset	w1, hi
   ae264:      	cmp	x13, x15
   ae268:      	cset	w2, hi
   ae26c:      	cmp	x16, x14
   ae270:      	add	x0, x10, x11
   ae274:      	cset	w10, hi
   ae278:      	cmp	x24, x13
   ae27c:      	mov	x9, xzr
   ae280:      	cset	w12, lo
   ae284:      	cmp	x0, x14
   ae288:      	cset	w11, hi
   ae28c:      	cmp	x27, x13
   ae290:      	cset	w14, lo
   ae294:      	cmp	x16, x15
   ae298:      	cset	w13, hi
   ae29c:      	cmp	x17, x24
   ae2a0:      	cset	w16, hi
   ae2a4:      	cmp	x0, x15
   ae2a8:      	cset	w15, hi
   ae2ac:      	cmp	x27, x17
   ae2b0:      	and	w0, w1, w2
   ae2b4:      	cset	w17, lo
   ae2b8:      	tbnz	w0, #0x0, 0xae494 <air1_opcal5_algorithm+0x58b0>
   ae2bc:      	and	w10, w10, w12
   ae2c0:      	tbnz	w10, #0x0, 0xae494 <air1_opcal5_algorithm+0x58b0>
   ae2c4:      	and	w10, w11, w14
   ae2c8:      	tbnz	w10, #0x0, 0xae494 <air1_opcal5_algorithm+0x58b0>
   ae2cc:      	adrp	x14, 0xe8000 <quick_sel_arr+0x1810>
   ae2d0:      	and	w10, w13, w16
   ae2d4:      	add	x14, x14, #0xcd0
   ae2d8:      	tbnz	w10, #0x0, 0xae1fc <air1_opcal5_algorithm+0x5618>
   ae2dc:      	and	w10, w15, w17
   ae2e0:      	tbnz	w10, #0x0, 0xae1fc <air1_opcal5_algorithm+0x5618>
   ae2e4:      	adrp	x15, 0xe9000 <g_algo+0x330>
   ae2e8:      	mov	x10, xzr
   ae2ec:      	mov	x11, xzr
   ae2f0:      	and	x9, x8, #0xfe
   ae2f4:      	add	x15, x15, #0x2e0
   ae2f8:      	ldr	q0, [x24, x10]
   ae2fc:      	add	x12, x24, x11
   ae300:      	add	x13, x15, x11
   ae304:      	add	x11, x11, #0x2
   ae308:      	cmp	x9, x11
   ae30c:      	str	q0, [x15, x10]
   ae310:      	add	x10, x10, #0x10
   ae314:      	ldrh	w12, [x12, #0x60]
   ae318:      	strh	w12, [x13, #0x30]
   ae31c:      	b.ne	0xae2f8 <air1_opcal5_algorithm+0x5714>
   ae320:      	cmp	x9, x8
   ae324:      	b.ne	0xae1fc <air1_opcal5_algorithm+0x5618>
   ae328:      	b	0xae4e8 <air1_opcal5_algorithm+0x5904>
   ae32c:      	fneg	d2, d1
   ae330:      	fcmp	d1, #0.0
   ae334:      	fmov	d3, #3.00000000
   ae338:      	fcsel	d1, d2, d1, mi
   ae33c:      	fadd	d2, d5, d12
   ae340:      	fcmp	d1, d3
   ae344:      	fcsel	d1, d12, d2, gt
   ae348:      	str	d1, [x22, #0x1c30]
   ae34c:      	ldrb	w8, [x4, #0xc3]
   ae350:      	adrp	x9, 0xe9000 <g_algo+0x330>
   ae354:      	strb	w8, [x9, #0x2d0]
   ae358:      	cbz	w8, 0xae394 <air1_opcal5_algorithm+0x57b0>
   ae35c:      	cmp	w8, #0x2
   ae360:      	b.ls	0xade2c <air1_opcal5_algorithm+0x5248>
   ae364:      	movi	d1, #0000000000000000
   ae368:      	cmp	w8, #0x3
   ae36c:      	b.ne	0xae3a8 <air1_opcal5_algorithm+0x57c4>
   ae370:      	ldr	d2, [x22, #0x1c30]
   ae374:      	fcmp	d2, d10
   ae378:      	b.ne	0xae3a8 <air1_opcal5_algorithm+0x57c4>
   ae37c:      	fmov	d2, d0
   ae380:      	fmov	d3, d0
   ae384:      	mov	w8, wzr
   ae388:      	strb	wzr, [x4, #0xc3]
   ae38c:      	str	xzr, [x22, #0x1c30]
   ae390:      	b	0xade40 <air1_opcal5_algorithm+0x525c>
   ae394:      	ldrh	w8, [x22, #0x1bf2]
   ae398:      	ldr	d3, [x22, #0x1bf8]
   ae39c:      	ldr	d2, [x22, #0x1c00]
   ae3a0:      	ldr	d1, [x22, #0x1c08]
   ae3a4:      	b	0xade40 <air1_opcal5_algorithm+0x525c>
   ae3a8:      	mov	w8, wzr
   ae3ac:      	fmov	d2, d0
   ae3b0:      	fmov	d3, d0
   ae3b4:      	b	0xade40 <air1_opcal5_algorithm+0x525c>
   ae3b8:      	adrp	x0, 0xe9000 <g_algo+0x330>
   ae3bc:      	add	x10, x22, x8
   ae3c0:      	add	x0, x0, #0x2e0
   ae3c4:      	mov	w12, #0x1cb8            // =7352
   ae3c8:      	add	x13, x0, #0x30
   ae3cc:      	add	x11, x0, x8, lsl #3
   ae3d0:      	add	x14, x13, x8
   ae3d4:      	add	x15, x10, x12
   ae3d8:      	cmp	x14, x0
   ae3dc:      	mov	x9, xzr
   ae3e0:      	cset	w16, hi
   ae3e4:      	cmp	x11, x13
   ae3e8:      	cset	w17, hi
   ae3ec:      	cmp	x15, x0
   ae3f0:      	cset	w10, hi
   ae3f4:      	cmp	x27, x11
   ae3f8:      	cset	w12, lo
   ae3fc:      	cmp	x15, x13
   ae400:      	cset	w11, hi
   ae404:      	cmp	x27, x14
   ae408:      	and	w15, w16, w17
   ae40c:      	cset	w13, lo
   ae410:      	tbnz	w15, #0x0, 0xae4a0 <air1_opcal5_algorithm+0x58bc>
   ae414:      	adrp	x14, 0xe8000 <quick_sel_arr+0x1810>
   ae418:      	and	w10, w10, w12
   ae41c:      	add	x14, x14, #0xcd0
   ae420:      	tbnz	w10, #0x0, 0xae4a8 <air1_opcal5_algorithm+0x58c4>
   ae424:      	and	w10, w11, w13
   ae428:      	tbnz	w10, #0x0, 0xae4a8 <air1_opcal5_algorithm+0x58c4>
   ae42c:      	adrp	x13, 0xe9000 <g_algo+0x330>
   ae430:      	and	x9, x8, #0xfe
   ae434:      	add	x13, x13, #0x2e0
   ae438:      	mov	x11, x27
   ae43c:      	add	x10, x13, #0x30
   ae440:      	mov	x12, x9
   ae444:      	ldr	x14, [sp, #0x38]
   ae448:      	ldr	q0, [x14], #0x10
   ae44c:      	add	x15, x11, #0x1
   ae450:      	subs	x12, x12, #0x2
   ae454:      	str	q0, [x13], #0x10
   ae458:      	ld1	{ v0.b }[0], [x11]
   ae45c:      	add	x11, x11, #0x2
   ae460:      	ld1	{ v0.b }[4], [x15]
   ae464:      	add	v0.2s, v0.2s, v13.2s
   ae468:      	mov	w15, v0.s[1]
   ae46c:      	fmov	w16, s0
   ae470:      	strb	w16, [x10]
   ae474:      	strb	w15, [x10, #0x1]
   ae478:      	add	x10, x10, #0x2
   ae47c:      	b.ne	0xae448 <air1_opcal5_algorithm+0x5864>
   ae480:      	adrp	x14, 0xe8000 <quick_sel_arr+0x1810>
   ae484:      	cmp	x9, x8
   ae488:      	add	x14, x14, #0xcd0
   ae48c:      	b.ne	0xae4a8 <air1_opcal5_algorithm+0x58c4>
   ae490:      	b	0xae4e8 <air1_opcal5_algorithm+0x5904>
   ae494:      	adrp	x14, 0xe8000 <quick_sel_arr+0x1810>
   ae498:      	add	x14, x14, #0xcd0
   ae49c:      	b	0xae1fc <air1_opcal5_algorithm+0x5618>
   ae4a0:      	adrp	x14, 0xe8000 <quick_sel_arr+0x1810>
   ae4a4:      	add	x14, x14, #0xcd0
   ae4a8:      	ldr	x13, [sp, #0x38]
   ae4ac:      	lsl	x12, x9, #3
   ae4b0:      	add	x10, x14, x9
   ae4b4:      	add	x11, x14, x12
   ae4b8:      	sub	x8, x8, x9
   ae4bc:      	add	x10, x10, #0x640
   ae4c0:      	add	x9, x27, x9
   ae4c4:      	add	x11, x11, #0x610
   ae4c8:      	add	x12, x13, x12
   ae4cc:      	ldr	d0, [x12], #0x8
   ae4d0:      	subs	x8, x8, #0x1
   ae4d4:      	str	d0, [x11], #0x8
   ae4d8:      	ldrb	w13, [x9], #0x1
   ae4dc:      	add	w13, w13, #0x1
   ae4e0:      	strb	w13, [x10], #0x1
   ae4e4:      	b.ne	0xae4cc <air1_opcal5_algorithm+0x58e8>
   ae4e8:      	mov	x8, xzr
   ae4ec:      	lsl	x9, x8, #1
   ae4f0:      	lsl	x10, x8, #3
   ae4f4:      	add	x11, x22, x9
   ae4f8:      	add	x12, x14, x10
   ae4fc:      	add	x9, x14, x9
   ae500:      	add	x10, x27, x10
   ae504:      	ldrh	w11, [x11, #0x6c4]
   ae508:      	ldr	d0, [x12, #0x610]
   ae50c:      	add	x12, x14, x8
   ae510:      	strh	w11, [x9, #0x602]
   ae514:      	stur	d0, [x10, #-0x60]
   ae518:      	ldrb	w9, [x12, #0x640]
   ae51c:      	strb	w9, [x27, x8]
   ae520:      	add	x8, x8, #0x1
   ae524:      	ldrb	w9, [x21, #0x8b1]
   ae528:      	cmp	x8, x9
   ae52c:      	b.lo	0xae4ec <air1_opcal5_algorithm+0x5908>
   ae530:      	ldr	x8, [sp, #0x240]
   ae534:      	ldrb	w12, [x8, #0x2bc]
   ae538:      	adrp	x8, 0xe9000 <g_algo+0x330>
   ae53c:      	ldr	d0, [x8, #0x2c8]
   ae540:      	cbz	x12, 0xae62c <air1_opcal5_algorithm+0x5a48>
   ae544:      	movi	d1, #0000000000000000
   ae548:      	mov	x7, #0xc00000000000     // =211106232532992
   ae54c:      	adrp	x24, 0xe9000 <g_algo+0x330>
   ae550:      	mov	x13, xzr
   ae554:      	mov	w9, wzr
   ae558:      	mov	w8, wzr
   ae55c:      	mov	w10, wzr
   ae560:      	mov	w14, wzr
   ae564:      	mov	w15, wzr
   ae568:      	mov	w11, wzr
   ae56c:      	ldr	x5, [sp, #0x158]
   ae570:      	movk	x7, #0x4082, lsl #48
   ae574:      	ldr	x6, [sp, #0xa0]
   ae578:      	mov	w21, #0x68              // =104
   ae57c:      	add	x24, x24, #0x918
   ae580:      	b	0xae590 <air1_opcal5_algorithm+0x59ac>
   ae584:      	add	x13, x13, #0x1
   ae588:      	cmp	x12, x13
   ae58c:      	b.eq	0xae60c <air1_opcal5_algorithm+0x5a28>
   ae590:      	add	x16, x6, x13
   ae594:      	ldrb	w17, [x16, #0xc9]
   ae598:      	cbnz	w17, 0xae584 <air1_opcal5_algorithm+0x59a0>
   ae59c:      	ldr	w17, [x6, x13, lsl #2]
   ae5a0:      	ldr	w0, [x30, #0xcd4]
   ae5a4:      	cmp	w17, w0
   ae5a8:      	b.hi	0xae584 <air1_opcal5_algorithm+0x59a0>
   ae5ac:      	add	x1, x6, x13, lsl #3
   ae5b0:      	fmov	d3, x7
   ae5b4:      	sub	x1, x1, #0x190
   ae5b8:      	sub	x0, x0, x17
   ae5bc:      	add	w11, w11, #0x1
   ae5c0:      	ldr	d2, [x1]
   ae5c4:      	ldp	x2, x1, [x24]
   ae5c8:      	fcmp	d2, d3
   ae5cc:      	fccmp	d2, d8, #0x8, ls
   ae5d0:      	csinc	w15, w15, wzr, lt
   ae5d4:      	cmp	x0, x1
   ae5d8:      	ccmp	x0, x2, #0x4, lt
   ae5dc:      	and	w0, w15, #0xff
   ae5e0:      	csinc	w14, w14, wzr, le
   ae5e4:      	cmp	w0, #0x0
   ae5e8:      	and	w0, w14, #0xff
   ae5ec:      	ccmp	w0, #0x0, #0x4, ne
   ae5f0:      	b.eq	0xae584 <air1_opcal5_algorithm+0x59a0>
   ae5f4:      	fmov	d1, d2
   ae5f8:      	mov	w9, #0x1                // =1
   ae5fc:      	mov	w10, w13
   ae600:      	mov	w8, w17
   ae604:      	strb	w23, [x16, #0xc9]
   ae608:      	b	0xae584 <air1_opcal5_algorithm+0x59a0>
   ae60c:      	tst	w11, #0xff
   ae610:      	b.eq	0xae8a0 <air1_opcal5_algorithm+0x5cbc>
   ae614:      	and	x12, x11, #0xff
   ae618:      	and	w13, w11, #0xff
   ae61c:      	cmp	w13, #0x8
   ae620:      	b.hs	0xae648 <air1_opcal5_algorithm+0x5a64>
   ae624:      	mov	x13, xzr
   ae628:      	b	0xaeee4 <air1_opcal5_algorithm+0x6300>
   ae62c:      	movi	d1, #0000000000000000
   ae630:      	mov	w9, wzr
   ae634:      	mov	w8, wzr
   ae638:      	mov	w10, wzr
   ae63c:      	ldr	x5, [sp, #0x158]
   ae640:      	mov	w21, #0x68              // =104
   ae644:      	b	0xae8a8 <air1_opcal5_algorithm+0x5cc4>
   ae648:      	cmp	w13, #0x10
   ae64c:      	b.hs	0xae734 <air1_opcal5_algorithm+0x5b50>
   ae650:      	mov	x13, xzr
   ae654:      	ldr	x16, [sp, #0x90]
   ae658:      	mov	x15, x13
   ae65c:      	mov	w13, w11
   ae660:      	and	x11, x13, #0xff
   ae664:      	and	x13, x13, #0xf8
   ae668:      	sub	x14, x15, x13
   ae66c:      	add	x15, x16, x15
   ae670:      	b	0xae680 <air1_opcal5_algorithm+0x5a9c>
   ae674:      	adds	x14, x14, #0x8
   ae678:      	add	x15, x15, #0x8
   ae67c:      	b.eq	0xae728 <air1_opcal5_algorithm+0x5b44>
   ae680:      	ldr	d2, [x15]
   ae684:      	cmeq	v2.8b, v2.8b, #0
   ae688:      	umov	w16, v2.b[0]
   ae68c:      	tbz	w16, #0x0, 0xae6dc <air1_opcal5_algorithm+0x5af8>
   ae690:      	strb	w23, [x15]
   ae694:      	umov	w16, v2.b[1]
   ae698:      	tbnz	w16, #0x0, 0xae6e4 <air1_opcal5_algorithm+0x5b00>
   ae69c:      	umov	w16, v2.b[2]
   ae6a0:      	tbz	w16, #0x0, 0xae6f0 <air1_opcal5_algorithm+0x5b0c>
   ae6a4:      	strb	w23, [x15, #0x2]
   ae6a8:      	umov	w16, v2.b[3]
   ae6ac:      	tbnz	w16, #0x0, 0xae6f8 <air1_opcal5_algorithm+0x5b14>
   ae6b0:      	umov	w16, v2.b[4]
   ae6b4:      	tbz	w16, #0x0, 0xae704 <air1_opcal5_algorithm+0x5b20>
   ae6b8:      	strb	w23, [x15, #0x4]
   ae6bc:      	umov	w16, v2.b[5]
   ae6c0:      	tbnz	w16, #0x0, 0xae70c <air1_opcal5_algorithm+0x5b28>
   ae6c4:      	umov	w16, v2.b[6]
   ae6c8:      	tbz	w16, #0x0, 0xae718 <air1_opcal5_algorithm+0x5b34>
   ae6cc:      	strb	w23, [x15, #0x6]
   ae6d0:      	umov	w16, v2.b[7]
   ae6d4:      	tbz	w16, #0x0, 0xae674 <air1_opcal5_algorithm+0x5a90>
   ae6d8:      	b	0xae720 <air1_opcal5_algorithm+0x5b3c>
   ae6dc:      	umov	w16, v2.b[1]
   ae6e0:      	tbz	w16, #0x0, 0xae69c <air1_opcal5_algorithm+0x5ab8>
   ae6e4:      	strb	w23, [x15, #0x1]
   ae6e8:      	umov	w16, v2.b[2]
   ae6ec:      	tbnz	w16, #0x0, 0xae6a4 <air1_opcal5_algorithm+0x5ac0>
   ae6f0:      	umov	w16, v2.b[3]
   ae6f4:      	tbz	w16, #0x0, 0xae6b0 <air1_opcal5_algorithm+0x5acc>
   ae6f8:      	strb	w23, [x15, #0x3]
   ae6fc:      	umov	w16, v2.b[4]
   ae700:      	tbnz	w16, #0x0, 0xae6b8 <air1_opcal5_algorithm+0x5ad4>
   ae704:      	umov	w16, v2.b[5]
   ae708:      	tbz	w16, #0x0, 0xae6c4 <air1_opcal5_algorithm+0x5ae0>
   ae70c:      	strb	w23, [x15, #0x5]
   ae710:      	umov	w16, v2.b[6]
   ae714:      	tbnz	w16, #0x0, 0xae6cc <air1_opcal5_algorithm+0x5ae8>
   ae718:      	umov	w16, v2.b[7]
   ae71c:      	tbz	w16, #0x0, 0xae674 <air1_opcal5_algorithm+0x5a90>
   ae720:      	strb	w23, [x15, #0x7]
   ae724:      	b	0xae674 <air1_opcal5_algorithm+0x5a90>
   ae728:      	cmp	x13, x11
   ae72c:      	b.eq	0xae8a0 <air1_opcal5_algorithm+0x5cbc>
   ae730:      	b	0xaeee4 <air1_opcal5_algorithm+0x6300>
   ae734:      	and	x13, x12, #0xf0
   ae738:      	ldr	x14, [sp, #0x90]
   ae73c:      	mov	x15, x13
   ae740:      	b	0xae750 <air1_opcal5_algorithm+0x5b6c>
   ae744:      	subs	x15, x15, #0x10
   ae748:      	add	x14, x14, #0x10
   ae74c:      	b.eq	0xae898 <air1_opcal5_algorithm+0x5cb4>
   ae750:      	ldr	q2, [x14]
   ae754:      	cmeq	v2.16b, v2.16b, #0
   ae758:      	umov	w16, v2.b[0]
   ae75c:      	tbz	w16, #0x0, 0xae7fc <air1_opcal5_algorithm+0x5c18>
   ae760:      	strb	w23, [x14]
   ae764:      	umov	w16, v2.b[1]
   ae768:      	tbnz	w16, #0x0, 0xae804 <air1_opcal5_algorithm+0x5c20>
   ae76c:      	umov	w16, v2.b[2]
   ae770:      	tbz	w16, #0x0, 0xae810 <air1_opcal5_algorithm+0x5c2c>
   ae774:      	strb	w23, [x14, #0x2]
   ae778:      	umov	w16, v2.b[3]
   ae77c:      	tbnz	w16, #0x0, 0xae818 <air1_opcal5_algorithm+0x5c34>
   ae780:      	umov	w16, v2.b[4]
   ae784:      	tbz	w16, #0x0, 0xae824 <air1_opcal5_algorithm+0x5c40>
   ae788:      	strb	w23, [x14, #0x4]
   ae78c:      	umov	w16, v2.b[5]
   ae790:      	tbnz	w16, #0x0, 0xae82c <air1_opcal5_algorithm+0x5c48>
   ae794:      	umov	w16, v2.b[6]
   ae798:      	tbz	w16, #0x0, 0xae838 <air1_opcal5_algorithm+0x5c54>
   ae79c:      	strb	w23, [x14, #0x6]
   ae7a0:      	umov	w16, v2.b[7]
   ae7a4:      	tbnz	w16, #0x0, 0xae840 <air1_opcal5_algorithm+0x5c5c>
   ae7a8:      	umov	w16, v2.b[8]
   ae7ac:      	tbz	w16, #0x0, 0xae84c <air1_opcal5_algorithm+0x5c68>
   ae7b0:      	strb	w23, [x14, #0x8]
   ae7b4:      	umov	w16, v2.b[9]
   ae7b8:      	tbnz	w16, #0x0, 0xae854 <air1_opcal5_algorithm+0x5c70>
   ae7bc:      	umov	w16, v2.b[10]
   ae7c0:      	tbz	w16, #0x0, 0xae860 <air1_opcal5_algorithm+0x5c7c>
   ae7c4:      	strb	w23, [x14, #0xa]
   ae7c8:      	umov	w16, v2.b[11]
   ae7cc:      	tbnz	w16, #0x0, 0xae868 <air1_opcal5_algorithm+0x5c84>
   ae7d0:      	umov	w16, v2.b[12]
   ae7d4:      	tbz	w16, #0x0, 0xae874 <air1_opcal5_algorithm+0x5c90>
   ae7d8:      	strb	w23, [x14, #0xc]
   ae7dc:      	umov	w16, v2.b[13]
   ae7e0:      	tbnz	w16, #0x0, 0xae87c <air1_opcal5_algorithm+0x5c98>
   ae7e4:      	umov	w16, v2.b[14]
   ae7e8:      	tbz	w16, #0x0, 0xae888 <air1_opcal5_algorithm+0x5ca4>
   ae7ec:      	strb	w23, [x14, #0xe]
   ae7f0:      	umov	w16, v2.b[15]
   ae7f4:      	tbz	w16, #0x0, 0xae744 <air1_opcal5_algorithm+0x5b60>
   ae7f8:      	b	0xae890 <air1_opcal5_algorithm+0x5cac>
   ae7fc:      	umov	w16, v2.b[1]
   ae800:      	tbz	w16, #0x0, 0xae76c <air1_opcal5_algorithm+0x5b88>
   ae804:      	strb	w23, [x14, #0x1]
   ae808:      	umov	w16, v2.b[2]
   ae80c:      	tbnz	w16, #0x0, 0xae774 <air1_opcal5_algorithm+0x5b90>
   ae810:      	umov	w16, v2.b[3]
   ae814:      	tbz	w16, #0x0, 0xae780 <air1_opcal5_algorithm+0x5b9c>
   ae818:      	strb	w23, [x14, #0x3]
   ae81c:      	umov	w16, v2.b[4]
   ae820:      	tbnz	w16, #0x0, 0xae788 <air1_opcal5_algorithm+0x5ba4>
   ae824:      	umov	w16, v2.b[5]
   ae828:      	tbz	w16, #0x0, 0xae794 <air1_opcal5_algorithm+0x5bb0>
   ae82c:      	strb	w23, [x14, #0x5]
   ae830:      	umov	w16, v2.b[6]
   ae834:      	tbnz	w16, #0x0, 0xae79c <air1_opcal5_algorithm+0x5bb8>
   ae838:      	umov	w16, v2.b[7]
   ae83c:      	tbz	w16, #0x0, 0xae7a8 <air1_opcal5_algorithm+0x5bc4>
   ae840:      	strb	w23, [x14, #0x7]
   ae844:      	umov	w16, v2.b[8]
   ae848:      	tbnz	w16, #0x0, 0xae7b0 <air1_opcal5_algorithm+0x5bcc>
   ae84c:      	umov	w16, v2.b[9]
   ae850:      	tbz	w16, #0x0, 0xae7bc <air1_opcal5_algorithm+0x5bd8>
   ae854:      	strb	w23, [x14, #0x9]
   ae858:      	umov	w16, v2.b[10]
   ae85c:      	tbnz	w16, #0x0, 0xae7c4 <air1_opcal5_algorithm+0x5be0>
   ae860:      	umov	w16, v2.b[11]
   ae864:      	tbz	w16, #0x0, 0xae7d0 <air1_opcal5_algorithm+0x5bec>
   ae868:      	strb	w23, [x14, #0xb]
   ae86c:      	umov	w16, v2.b[12]
   ae870:      	tbnz	w16, #0x0, 0xae7d8 <air1_opcal5_algorithm+0x5bf4>
   ae874:      	umov	w16, v2.b[13]
   ae878:      	tbz	w16, #0x0, 0xae7e4 <air1_opcal5_algorithm+0x5c00>
   ae87c:      	strb	w23, [x14, #0xd]
   ae880:      	umov	w16, v2.b[14]
   ae884:      	tbnz	w16, #0x0, 0xae7ec <air1_opcal5_algorithm+0x5c08>
   ae888:      	umov	w16, v2.b[15]
   ae88c:      	tbz	w16, #0x0, 0xae744 <air1_opcal5_algorithm+0x5b60>
   ae890:      	strb	w23, [x14, #0xf]
   ae894:      	b	0xae744 <air1_opcal5_algorithm+0x5b60>
   ae898:      	cmp	x13, x12
   ae89c:      	b.ne	0xaeee0 <air1_opcal5_algorithm+0x62fc>
   ae8a0:      	adrp	x14, 0xe8000 <quick_sel_arr+0x1810>
   ae8a4:      	add	x14, x14, #0xcd0
   ae8a8:      	ldrh	w11, [x22, #0x250]
   ae8ac:      	cmp	w11, #0x2
   ae8b0:      	b.lo	0xae918 <air1_opcal5_algorithm+0x5d34>
   ae8b4:      	ldrh	w11, [x22, #0x6d0]
   ae8b8:      	ldrh	w12, [x22, #0x6ce]
   ae8bc:      	sub	w11, w11, w12
   ae8c0:      	sxth	w11, w11
   ae8c4:      	cmp	w11, #0x4
   ae8c8:      	b.gt	0xae918 <air1_opcal5_algorithm+0x5d34>
   ae8cc:      	fcmp	d0, d8
   ae8d0:      	b.ls	0xae918 <air1_opcal5_algorithm+0x5d34>
   ae8d4:      	mov	x11, #0x400000000000    // =70368744177664
   ae8d8:      	movk	x11, #0x408f, lsl #48
   ae8dc:      	fmov	d2, x11
   ae8e0:      	fcmp	d0, d2
   ae8e4:      	b.ge	0xae918 <air1_opcal5_algorithm+0x5d34>
   ae8e8:      	adrp	x11, 0xe8000 <quick_sel_arr+0x1810>
   ae8ec:      	ldrb	w11, [x11, #0xd98]
   ae8f0:      	cbz	w11, 0xae918 <air1_opcal5_algorithm+0x5d34>
   ae8f4:      	cbz	w9, 0xae918 <air1_opcal5_algorithm+0x5d34>
   ae8f8:      	ldr	x9, [sp, #0x240]
   ae8fc:      	add	x9, x9, w10, uxtb
   ae900:      	mov	w10, #0x1               // =1
   ae904:      	strb	w10, [x9, #0x2bd]
   ae908:      	adrp	x9, 0xe9000 <g_algo+0x330>
   ae90c:      	add	x9, x9, #0x318
   ae910:      	str	d1, [x9]
   ae914:      	str	w8, [x9, #0x8]
   ae918:      	adrp	x8, 0xe9000 <g_algo+0x330>
   ae91c:      	add	x8, x8, #0x2c8
   ae920:      	ldur	q0, [x8, #0x18]
   ae924:      	ldr	d1, [x8, #0x50]
   ae928:      	ldur	q2, [x8, #0x28]
   ae92c:      	ldur	q3, [x8, #0x38]
   ae930:      	str	q0, [x22, #0x1cc0]
   ae934:      	fcmp	d1, #0.0
   ae938:      	ldr	d0, [x8]
   ae93c:      	str	q2, [x22, #0x1cd0]
   ae940:      	str	q3, [x22, #0x1ce0]
   ae944:      	str	d0, [x22, #0x1cf0]
   ae948:      	b.ne	0xae96c <air1_opcal5_algorithm+0x5d88>
   ae94c:      	ldrsb	w8, [x3, #0x18]
   ae950:      	and	w9, w8, #0xff
   ae954:      	cmp	w8, #0x1
   ae958:      	b.lt	0xaeb18 <air1_opcal5_algorithm+0x5f34>
   ae95c:      	adrp	x8, 0xe8000 <quick_sel_arr+0x1810>
   ae960:      	ldrh	w27, [x22, #0x250]
   ae964:      	ldrh	w8, [x8, #0xcd0]
   ae968:      	b	0xaeb50 <air1_opcal5_algorithm+0x5f6c>
   ae96c:      	ldr	w8, [x14, #0x4]
   ae970:      	ldr	w9, [x14, #0x650]
   ae974:      	sub	x8, x8, x9
   ae978:      	scvtf	d0, x8
   ae97c:      	mov	x8, #0x404e000000000000 // =4633641066610819072
   ae980:      	fmov	d2, x8
   ae984:      	fdiv	d0, d0, d2
   ae988:      	fcmp	d0, d0
   ae98c:      	b.vs	0xb06a0 <air1_opcal5_algorithm+0x7abc>
   ae990:      	fcmp	d0, #0.0
   ae994:      	fmov	d2, #-0.50000000
   ae998:      	fcsel	d2, d2, d14, lt
   ae99c:      	fadd	d0, d0, d2
   ae9a0:      	fcvtzs	d0, d0
   ae9a4:      	scvtf	d0, d0
   ae9a8:      	fmov	d2, #5.00000000
   ae9ac:      	fdiv	d0, d0, d2
   ae9b0:      	fmul	d0, d0, d8
   ae9b4:      	fcmp	d0, d0
   ae9b8:      	b.vs	0xb06ac <air1_opcal5_algorithm+0x7ac8>
   ae9bc:      	fcmp	d0, #0.0
   ae9c0:      	fmov	d2, #-0.50000000
   ae9c4:      	fcsel	d2, d2, d14, lt
   ae9c8:      	fadd	d0, d0, d2
   ae9cc:      	fcvtzs	d0, d0
   ae9d0:      	scvtf	d2, d0
   ae9d4:      	adrp	x8, 0xe9000 <g_algo+0x330>
   ae9d8:      	fmov	d3, #5.00000000
   ae9dc:      	ldr	d0, [x8, #0x930]
   ae9e0:      	fdiv	d0, d0, d3
   ae9e4:      	fmul	d0, d0, d8
   ae9e8:      	fcmp	d0, d0
   ae9ec:      	b.vs	0xb06b8 <air1_opcal5_algorithm+0x7ad4>
   ae9f0:      	fcmp	d0, #0.0
   ae9f4:      	fmov	d3, #-0.50000000
   ae9f8:      	fcsel	d3, d3, d14, lt
   ae9fc:      	fadd	d0, d0, d3
   aea00:      	fcvtzs	d0, d0
   aea04:      	scvtf	d0, d0
   aea08:      	fdiv	d2, d2, d8
   aea0c:      	ldrh	w8, [x14]
   aea10:      	ldr	x12, [sp, #0x58]
   aea14:      	mov	x10, #-0x31             // =-49
   aea18:      	ucvtf	d3, w8
   aea1c:      	mov	x11, x12
   aea20:      	fsub	d2, d3, d2
   aea24:      	ldurb	w13, [x12, #-0xc8]
   aea28:      	adds	x10, x10, #0x1
   aea2c:      	ldur	q3, [x12, #-0xc0]
   aea30:      	ldur	q4, [x12, #-0xa8]
   aea34:      	sturb	w13, [x12, #-0x60]
   aea38:      	ldurh	w13, [x12, #-0xb0]
   aea3c:      	stur	q3, [x12, #-0x58]
   aea40:      	ldur	d3, [x12, #-0x98]
   aea44:      	ldur	w14, [x12, #-0xc4]
   aea48:      	stur	q4, [x12, #-0x40]
   aea4c:      	sturh	w13, [x12, #-0x48]
   aea50:      	ldurb	w13, [x12, #-0x90]
   aea54:      	stur	d3, [x12, #-0x30]
   aea58:      	ldur	q3, [x12, #-0x88]
   aea5c:      	ldur	q4, [x12, #-0x78]
   aea60:      	stur	w14, [x12, #-0x5c]
   aea64:      	sturb	w13, [x12, #-0x28]
   aea68:      	ldrb	w13, [x11, #-0x68]!
   aea6c:      	stp	q3, q4, [x12, #-0x20]
   aea70:      	strb	w13, [x12]
   aea74:      	mov	x12, x11
   aea78:      	b.lo	0xaea24 <air1_opcal5_algorithm+0x5e40>
   aea7c:      	fdiv	d3, d0, d8
   aea80:      	mov	w12, #0x1               // =1
   aea84:      	adrp	x11, 0xe9000 <g_algo+0x330>
   aea88:      	strb	wzr, [x4, #0x372]
   aea8c:      	add	x11, x11, #0x912
   aea90:      	ldr	d0, [x22, #0x1d60]
   aea94:      	strb	w12, [x4, #0x34a]
   aea98:      	ldrh	w27, [x22, #0x250]
   aea9c:      	str	d2, [x22, #0x1e48]
   aeaa0:      	ldrh	w10, [x11, #0x2]
   aeaa4:      	str	d1, [x22, #0x1e60]
   aeaa8:      	ldrh	w11, [x11]
   aeaac:      	str	d0, [x22, #0x1e68]
   aeab0:      	str	d1, [x22, #0x1e80]
   aeab4:      	ldr	d1, [x22, #0x1d98]
   aeab8:      	cmp	w8, w10
   aeabc:      	str	d0, [x22, #0x1e90]
   aeac0:      	cinc	w10, w12, hs
   aeac4:      	cmp	w8, w11
   aeac8:      	ldr	d0, [x22, #0x1cf0]
   aeacc:      	csel	w10, wzr, w10, lo
   aead0:      	str	w9, [x22, #0x1e44]
   aead4:      	strh	w27, [x22, #0x1e58]
   aead8:      	str	d1, [x22, #0x1e70]
   aeadc:      	str	d0, [x22, #0x1e88]
   aeae0:      	str	d1, [x22, #0x1e98]
   aeae4:      	strb	w10, [x4, #0x312]
   aeae8:      	fadd	d2, d2, d3
   aeaec:      	ldr	d3, [x22, #0x1eb0]
   aeaf0:      	fcmp	d3, #0.0
   aeaf4:      	str	d2, [x22, #0x1e50]
   aeaf8:      	b.eq	0xaeb20 <air1_opcal5_algorithm+0x5f3c>
   aeafc:      	ldr	w10, [x22, #0x1eac]
   aeb00:      	sub	x9, x9, x10
   aeb04:      	scvtf	d1, x9
   aeb08:      	mov	x9, #0x404e000000000000 // =4633641066610819072
   aeb0c:      	fmov	d2, x9
   aeb10:      	fdiv	d1, d1, d2
   aeb14:      	b	0xaeb2c <air1_opcal5_algorithm+0x5f48>
   aeb18:      	strb	w9, [x3]
   aeb1c:      	b	0xaebc4 <air1_opcal5_algorithm+0x5fe0>
   aeb20:      	mov	x9, #0xc00000000000     // =211106232532992
   aeb24:      	movk	x9, #0x4058, lsl #48
   aeb28:      	fmov	d1, x9
   aeb2c:      	adrp	x9, 0xe9000 <g_algo+0x330>
   aeb30:      	ldr	d2, [x9, #0x928]
   aeb34:      	fcmp	d1, d2
   aeb38:      	b.hi	0xaeb48 <air1_opcal5_algorithm+0x5f64>
   aeb3c:      	ldr	x9, [sp, #0x3e0]
   aeb40:      	mov	w10, #0xfe              // =254
   aeb44:      	strb	w10, [x9, #0x218]
   aeb48:      	mov	w9, #0x1                // =1
   aeb4c:      	strb	w9, [x3, #0x18]
   aeb50:      	mov	x10, xzr
   aeb54:      	mov	w11, #0x1               // =1
   aeb58:      	b	0xaeb68 <air1_opcal5_algorithm+0x5f84>
   aeb5c:      	mov	w11, wzr
   aeb60:      	cmp	x10, #0x32
   aeb64:      	b.eq	0xaebb0 <air1_opcal5_algorithm+0x5fcc>
   aeb68:      	add	x13, x10, #0x1
   aeb6c:      	madd	x12, x10, x21, x5
   aeb70:      	mov	x10, x13
   aeb74:      	ldrb	w13, [x12]
   aeb78:      	cmp	w13, #0x1
   aeb7c:      	b.eq	0xaeb5c <air1_opcal5_algorithm+0x5f78>
   aeb80:      	cmp	w13, #0xfa
   aeb84:      	b.eq	0xaeb5c <air1_opcal5_algorithm+0x5f78>
   aeb88:      	add	x10, x10, #0x1
   aeb8c:      	add	x12, x12, #0x68
   aeb90:      	cmp	x10, #0x33
   aeb94:      	b.ne	0xaeb74 <air1_opcal5_algorithm+0x5f90>
   aeb98:      	tbz	w11, #0x0, 0xaebb0 <air1_opcal5_algorithm+0x5fcc>
   aeb9c:      	ldr	d13, [x22, #0x1e90]
   aeba0:      	strb	wzr, [x3, #0x18]
   aeba4:      	ldr	d8, [x22, #0x1e98]
   aeba8:      	strb	wzr, [x3]
   aebac:      	b	0xaf0a4 <air1_opcal5_algorithm+0x64c0>
   aebb0:      	ucvtf	d1, w8
   aebb4:      	ldr	d2, [x22, #0x1e50]
   aebb8:      	fsub	d1, d1, d2
   aebbc:      	fcmp	d1, #0.0
   aebc0:      	b.pl	0xaebd4 <air1_opcal5_algorithm+0x5ff0>
   aebc4:      	tbnz	w9, #0x7, 0xaec60 <air1_opcal5_algorithm+0x607c>
   aebc8:      	ldr	d13, [x22, #0x1e90]
   aebcc:      	ldr	d8, [x22, #0x1e98]
   aebd0:      	b	0xaf088 <air1_opcal5_algorithm+0x64a4>
   aebd4:      	cmp	w9, #0x2
   aebd8:      	b.eq	0xaee7c <air1_opcal5_algorithm+0x6298>
   aebdc:      	cmp	w9, #0x1
   aebe0:      	b.ne	0xaefdc <air1_opcal5_algorithm+0x63f8>
   aebe4:      	fcmp	d1, d1
   aebe8:      	b.vs	0xb06c4 <air1_opcal5_algorithm+0x7ae0>
   aebec:      	fcvtzs	w8, d1
   aebf0:      	fcmp	d1, #0.0
   aebf4:      	scvtf	d2, w8
   aebf8:      	cset	w9, gt
   aebfc:      	fcmp	d1, d2
   aec00:      	cset	w10, ne
   aec04:      	and	w9, w9, w10
   aec08:      	add	w8, w9, w8
   aec0c:      	scvtf	d2, w8
   aec10:      	fsub	d1, d2, d1
   aec14:      	mov	w9, #0xff               // =255
   aec18:      	strb	w9, [x3, #0x18]
   aec1c:      	fsub	d2, d12, d1
   aec20:      	fmul	d0, d0, d1
   aec24:      	ldr	d1, [x22, #0x1ce8]
   aec28:      	fmadd	d0, d2, d1, d0
   aec2c:      	adrp	x8, 0xe9000 <g_algo+0x330>
   aec30:      	strb	w9, [x3]
   aec34:      	ldr	d1, [x22, #0x1e68]
   aec38:      	ldr	d2, [x22, #0x1e70]
   aec3c:      	ldr	d3, [x8, #0x938]
   aec40:      	fmadd	d1, d1, d0, d2
   aec44:      	fsub	d2, d12, d3
   aec48:      	fmul	d1, d1, d2
   aec4c:      	fmadd	d0, d3, d0, d1
   aec50:      	ldr	d1, [x22, #0x1e60]
   aec54:      	str	d1, [x22, #0x1e80]
   aec58:      	str	d0, [x22, #0x1e88]
   aec5c:      	b	0xaec64 <air1_opcal5_algorithm+0x6080>
   aec60:      	mov	w23, #0x2               // =2
   aec64:      	cmp	w9, #0xff
   aec68:      	str	xzr, [x19, #0xb58]
   aec6c:      	str	xzr, [x19, #0xb50]
   aec70:      	str	xzr, [x19, #0x888]
   aec74:      	str	xzr, [x19, #0x880]
   aec78:      	b.ne	0xaedb8 <air1_opcal5_algorithm+0x61d4>
   aec7c:      	add	x1, sp, #0xcb0
   aec80:      	mov	x0, x22
   aec84:      	bl	0xb9c58 <regress_cal>
   aec88:      	adrp	x8, 0xe9000 <g_algo+0x330>
   aec8c:      	ldr	d10, [x19, #0x880]
   aec90:      	add	x8, x8, #0x968
   aec94:      	ldr	d0, [x8, #0x18]
   aec98:      	fcmp	d0, d10
   aec9c:      	b.hi	0xaecf8 <air1_opcal5_algorithm+0x6114>
   aeca0:      	ldr	d1, [x8, #0x10]
   aeca4:      	fcmp	d1, d10
   aeca8:      	b.lt	0xaecf8 <air1_opcal5_algorithm+0x6114>
   aecac:      	ldr	d9, [x19, #0x888]
   aecb0:      	ldr	d2, [x8, #0x8]
   aecb4:      	fcmp	d2, d9
   aecb8:      	b.hi	0xaecf8 <air1_opcal5_algorithm+0x6114>
   aecbc:      	ldr	d3, [x8]
   aecc0:      	fcmp	d3, d9
   aecc4:      	b.lt	0xaecf8 <air1_opcal5_algorithm+0x6114>
   aecc8:      	fsub	d2, d3, d2
   aeccc:      	fsub	d1, d0, d1
   aecd0:      	fdiv	d1, d2, d1
   aecd4:      	ldr	d2, [x8, #0x20]
   aecd8:      	fmsub	d0, d1, d0, d3
   aecdc:      	fsub	d3, d0, d2
   aece0:      	fadd	d0, d2, d0
   aece4:      	fmadd	d2, d1, d10, d3
   aece8:      	fmadd	d0, d1, d10, d0
   aecec:      	fcmp	d2, d9
   aecf0:      	fccmp	d0, d9, #0x8, ls
   aecf4:      	b.ge	0xaed00 <air1_opcal5_algorithm+0x611c>
   aecf8:      	ldr	d9, [x22, #0x1e68]
   aecfc:      	ldr	d10, [x22, #0x1e70]
   aed00:      	ldr	x8, [sp, #0x3d0]
   aed04:      	add	x1, sp, #0xf80
   aed08:      	mov	x0, x22
   aed0c:      	strb	w23, [x8, #0x18]
   aed10:      	bl	0xb9c58 <regress_cal>
   aed14:      	adrp	x8, 0xe9000 <g_algo+0x330>
   aed18:      	ldr	d8, [x19, #0xb50]
   aed1c:      	add	x8, x8, #0x968
   aed20:      	ldr	d0, [x8, #0x18]
   aed24:      	fcmp	d0, d8
   aed28:      	b.hi	0xaeeb0 <air1_opcal5_algorithm+0x62cc>
   aed2c:      	ldr	d1, [x8, #0x10]
   aed30:      	fcmp	d1, d8
   aed34:      	b.lt	0xaeeb0 <air1_opcal5_algorithm+0x62cc>
   aed38:      	ldr	d13, [x19, #0xb58]
   aed3c:      	ldr	d2, [x8, #0x8]
   aed40:      	fcmp	d2, d13
   aed44:      	b.hi	0xaeeb0 <air1_opcal5_algorithm+0x62cc>
   aed48:      	ldr	d3, [x8]
   aed4c:      	fcmp	d3, d13
   aed50:      	b.lt	0xaeeb0 <air1_opcal5_algorithm+0x62cc>
   aed54:      	fsub	d2, d3, d2
   aed58:      	fsub	d1, d0, d1
   aed5c:      	fdiv	d1, d2, d1
   aed60:      	ldr	d2, [x8, #0x20]
   aed64:      	fmsub	d0, d1, d0, d3
   aed68:      	fsub	d3, d0, d2
   aed6c:      	fadd	d0, d2, d0
   aed70:      	fmadd	d2, d1, d8, d3
   aed74:      	fmadd	d0, d1, d8, d0
   aed78:      	fcmp	d2, d13
   aed7c:      	fccmp	d0, d13, #0x8, ls
   aed80:      	b.lt	0xaeeb0 <air1_opcal5_algorithm+0x62cc>
   aed84:      	ldr	x10, [sp, #0x3c8]
   aed88:      	fsub	d0, d9, d13
   aed8c:      	fsub	d1, d10, d8
   aed90:      	ldr	x12, [sp, #0x3d0]
   aed94:      	ldrb	w8, [x10, #0x34a]
   aed98:      	str	d0, [x22, #0x3298]
   aed9c:      	str	d1, [x22, #0x32a0]
   aeda0:      	cmp	w8, #0x1
   aeda4:      	b.ne	0xaf000 <air1_opcal5_algorithm+0x641c>
   aeda8:      	ldrb	w8, [x10, #0x312]
   aedac:      	cbz	w8, 0xaf014 <air1_opcal5_algorithm+0x6430>
   aedb0:      	mov	w8, #0x1                // =1
   aedb4:      	b	0xaee6c <air1_opcal5_algorithm+0x6288>
   aedb8:      	add	x1, sp, #0xf80
   aedbc:      	mov	x0, x22
   aedc0:      	bl	0xb9c58 <regress_cal>
   aedc4:      	ldr	x12, [sp, #0x3d0]
   aedc8:      	adrp	x8, 0xe9000 <g_algo+0x330>
   aedcc:      	add	x8, x8, #0x968
   aedd0:      	ldr	d8, [x19, #0xb50]
   aedd4:      	ldr	d13, [x19, #0xb58]
   aedd8:      	strb	wzr, [x12, #0x18]
   aeddc:      	ldp	d0, d1, [x8]
   aede0:      	ldp	d2, d3, [x8, #0x10]
   aede4:      	fsub	d4, d0, d1
   aede8:      	fsub	d5, d3, d2
   aedec:      	fcmp	d3, d8
   aedf0:      	fdiv	d4, d4, d5
   aedf4:      	fmsub	d5, d4, d3, d0
   aedf8:      	ldr	d3, [x8, #0x20]
   aedfc:      	cset	w8, ls
   aee00:      	fcmp	d2, d8
   aee04:      	fsub	d2, d5, d3
   aee08:      	cset	w9, ge
   aee0c:      	fcmp	d1, d13
   aee10:      	fadd	d1, d3, d5
   aee14:      	and	w8, w8, w9
   aee18:      	fmadd	d2, d4, d8, d2
   aee1c:      	cset	w10, ls
   aee20:      	fcmp	d0, d13
   aee24:      	fmadd	d0, d4, d8, d1
   aee28:      	and	w8, w8, w10
   aee2c:      	ldr	x10, [sp, #0x3c8]
   aee30:      	cset	w11, ge
   aee34:      	fcmp	d2, d13
   aee38:      	and	w8, w8, w11
   aee3c:      	cset	w9, ls
   aee40:      	fcmp	d0, d13
   aee44:      	and	w8, w8, w9
   aee48:      	cset	w9, ge
   aee4c:      	and	w8, w8, w9
   aee50:      	tbnz	w8, #0x0, 0xaee64 <air1_opcal5_algorithm+0x6280>
   aee54:      	ldr	d13, [x22, #0x1e68]
   aee58:      	mov	w9, #0xfc               // =252
   aee5c:      	ldr	d8, [x22, #0x1e70]
   aee60:      	strb	w9, [x10, #0x34a]
   aee64:      	ldrb	w9, [x10, #0x312]
   aee68:      	cbz	w9, 0xaef18 <air1_opcal5_algorithm+0x6334>
   aee6c:      	ldr	x9, [sp, #0x3e8]
   aee70:      	mov	w11, #0xff              // =255
   aee74:      	strb	w11, [x9]
   aee78:      	b	0xaf020 <air1_opcal5_algorithm+0x643c>
   aee7c:      	ldrh	w8, [x22, #0x1e58]
   aee80:      	sub	w8, w27, w8
   aee84:      	cmp	w8, #0x5
   aee88:      	b.gt	0xaef7c <air1_opcal5_algorithm+0x6398>
   aee8c:      	fmov	v0.2d, #1.50000000
   aee90:      	ldur	q1, [x3, #0x8]
   aee94:      	ldr	d13, [x22, #0x1e90]
   aee98:      	strb	w23, [x3]
   aee9c:      	ldr	d8, [x22, #0x1e98]
   aeea0:      	fdiv	v0.2d, v1.2d, v0.2d
   aeea4:      	mov	d1, v0.d[1]
   aeea8:      	stur	q0, [x3, #0x8]
   aeeac:      	b	0xaf09c <air1_opcal5_algorithm+0x64b8>
   aeeb0:      	ldr	d13, [x22, #0x1e68]
   aeeb4:      	mov	w9, #0xfd               // =253
   aeeb8:      	ldr	d8, [x22, #0x1e70]
   aeebc:      	mov	w8, wzr
   aeec0:      	ldr	x10, [sp, #0x3c8]
   aeec4:      	fsub	d0, d9, d13
   aeec8:      	ldr	x12, [sp, #0x3d0]
   aeecc:      	fsub	d1, d10, d8
   aeed0:      	strb	w9, [x10, #0x34a]
   aeed4:      	str	d0, [x22, #0x3298]
   aeed8:      	str	d1, [x22, #0x32a0]
   aeedc:      	b	0xaf020 <air1_opcal5_algorithm+0x643c>
   aeee0:      	tbnz	w12, #0x3, 0xae654 <air1_opcal5_algorithm+0x5a70>
   aeee4:      	sub	x11, x12, x13
   aeee8:      	ldr	x12, [sp, #0x90]
   aeeec:      	adrp	x14, 0xe8000 <quick_sel_arr+0x1810>
   aeef0:      	add	x14, x14, #0xcd0
   aeef4:      	add	x12, x12, x13
   aeef8:      	b	0xaef08 <air1_opcal5_algorithm+0x6324>
   aeefc:      	subs	x11, x11, #0x1
   aef00:      	add	x12, x12, #0x1
   aef04:      	b.eq	0xae8a8 <air1_opcal5_algorithm+0x5cc4>
   aef08:      	ldrb	w13, [x12]
   aef0c:      	cbnz	w13, 0xaeefc <air1_opcal5_algorithm+0x6318>
   aef10:      	strb	w23, [x12]
   aef14:      	b	0xaeefc <air1_opcal5_algorithm+0x6318>
   aef18:      	ldrb	w9, [x10, #0x34a]
   aef1c:      	cmp	w9, #0x1
   aef20:      	b.ne	0xaf008 <air1_opcal5_algorithm+0x6424>
   aef24:      	mov	x9, #0x4059000000000000 // =4636737291354636288
   aef28:      	ldr	d0, [x22, #0x1e88]
   aef2c:      	ldr	d1, [x22, #0x1e80]
   aef30:      	fmov	d2, x9
   aef34:      	fsub	d0, d0, d1
   aef38:      	fcmp	d1, d2
   aef3c:      	b.mi	0xaef4c <air1_opcal5_algorithm+0x6368>
   aef40:      	fdiv	d0, d0, d1
   aef44:      	fmov	d1, x9
   aef48:      	fmul	d0, d0, d1
   aef4c:      	fmov	d1, #-20.00000000
   aef50:      	fcmp	d0, d1
   aef54:      	b.mi	0xaef68 <air1_opcal5_algorithm+0x6384>
   aef58:      	mov	x9, #0x4044000000000000 // =4630826316843712512
   aef5c:      	fmov	d1, x9
   aef60:      	fcmp	d0, d1
   aef64:      	b.ls	0xb01a0 <air1_opcal5_algorithm+0x75bc>
   aef68:      	ldr	x9, [sp, #0x3e8]
   aef6c:      	strb	w23, [x9]
   aef70:      	mov	w9, #0xfa               // =250
   aef74:      	strb	w9, [x10, #0x34a]
   aef78:      	b	0xaf020 <air1_opcal5_algorithm+0x643c>
   aef7c:      	and	w8, w8, #0xffff
   aef80:      	cmp	w8, #0x6
   aef84:      	b.ne	0xaefdc <air1_opcal5_algorithm+0x63f8>
   aef88:      	fcmp	d1, d1
   aef8c:      	b.vs	0xb06d0 <air1_opcal5_algorithm+0x7aec>
   aef90:      	fcvtzs	w8, d1
   aef94:      	fcmp	d1, #0.0
   aef98:      	scvtf	d0, w8
   aef9c:      	cset	w9, gt
   aefa0:      	fcmp	d1, d0
   aefa4:      	cset	w10, ne
   aefa8:      	and	w9, w9, w10
   aefac:      	add	w8, w9, w8
   aefb0:      	scvtf	d0, w8
   aefb4:      	fsub	d0, d0, d1
   aefb8:      	ldr	d1, [x22, #0x1cc8]
   aefbc:      	mov	w9, #0xfe               // =254
   aefc0:      	ldr	x8, [sp, #0x8]
   aefc4:      	fsub	d2, d12, d0
   aefc8:      	fmul	d0, d0, d1
   aefcc:      	ldr	d1, [x22, #0x1cc0]
   aefd0:      	strb	w9, [x3, #0x18]
   aefd4:      	stp	xzr, xzr, [x8]
   aefd8:      	b	0xaec28 <air1_opcal5_algorithm+0x6044>
   aefdc:      	mov	w8, #0xfd               // =253
   aefe0:      	ldr	d13, [x22, #0x1e90]
   aefe4:      	ldr	d8, [x22, #0x1e98]
   aefe8:      	strb	wzr, [x3, #0x18]
   aefec:      	strb	wzr, [x3]
   aeff0:      	strb	w8, [x4, #0x34a]
   aeff4:      	ldr	x8, [sp, #0x8]
   aeff8:      	stp	xzr, xzr, [x8]
   aeffc:      	b	0xaf0a4 <air1_opcal5_algorithm+0x64c0>
   af000:      	mov	w8, #0x1                // =1
   af004:      	b	0xaf020 <air1_opcal5_algorithm+0x643c>
   af008:      	ldr	x9, [sp, #0x3e8]
   af00c:      	strb	w23, [x9]
   af010:      	b	0xaf020 <air1_opcal5_algorithm+0x643c>
   af014:      	ldr	x9, [sp, #0x3e8]
   af018:      	mov	w8, #0x1                // =1
   af01c:      	strb	wzr, [x9]
   af020:      	fmov	d0, #2.50000000
   af024:      	fcmp	d13, d0
   af028:      	b.gt	0xaf05c <air1_opcal5_algorithm+0x6478>
   af02c:      	adrp	x9, 0x1000 <strcasecmp+0x1000>
   af030:      	ldr	d0, [x9, #0x640]
   af034:      	fcmp	d13, d0
   af038:      	b.mi	0xaf05c <air1_opcal5_algorithm+0x6478>
   af03c:      	mov	x9, #0x4069000000000000 // =4641240890982006784
   af040:      	fmov	d0, x9
   af044:      	fcmp	d8, d0
   af048:      	b.gt	0xaf05c <air1_opcal5_algorithm+0x6478>
   af04c:      	mov	x9, #-0x3fa7000000000000 // =-4586634745500139520
   af050:      	fmov	d0, x9
   af054:      	fcmp	d8, d0
   af058:      	b.pl	0xaf078 <air1_opcal5_algorithm+0x6494>
   af05c:      	ldr	x9, [sp, #0x8]
   af060:      	movi	d8, #0000000000000000
   af064:      	mov	w8, wzr
   af068:      	fmov	d13, #1.00000000
   af06c:      	stp	xzr, xzr, [x9]
   af070:      	mov	w9, #0xfb               // =251
   af074:      	strb	w9, [x10, #0x34a]
   af078:      	ldrb	w9, [x12, #0x18]
   af07c:      	str	d13, [x22, #0x1e90]
   af080:      	str	d8, [x22, #0x1e98]
   af084:      	strb	w8, [x10, #0x372]
   af088:      	ldrh	w27, [x22, #0x250]
   af08c:      	cmp	w9, #0x2
   af090:      	b.ne	0xaf0a4 <air1_opcal5_algorithm+0x64c0>
   af094:      	ldr	d0, [x22, #0x3298]
   af098:      	ldr	d1, [x22, #0x32a0]
   af09c:      	fadd	d13, d0, d13
   af0a0:      	fadd	d8, d1, d8
   af0a4:      	ldr	x24, [sp, #0x1f0]
   af0a8:      	mov	w2, #0x48               // =72
   af0ac:      	ldr	x1, [sp, #0x1e0]
   af0b0:      	mov	x0, x24
   af0b4:      	bl	0xbf050 <memmove@plt>
   af0b8:      	ldp	q0, q1, [x24, #0x10]
   af0bc:      	str	d13, [x22, #0x1de8]
   af0c0:      	add	x1, sp, #0xf80
   af0c4:      	add	x2, sp, #0x9e0
   af0c8:      	mov	w0, w27
   af0cc:      	str	xzr, [x19, #0x5e0]
   af0d0:      	str	q0, [x19, #0xb60]
   af0d4:      	ldp	q2, q0, [x24, #0x30]
   af0d8:      	str	q1, [x19, #0xb70]
   af0dc:      	str	q2, [x19, #0xb80]
   af0e0:      	str	q0, [x19, #0xb90]
   af0e4:      	ldr	q3, [x24]
   af0e8:      	movi	v0.2d, #0000000000000000
   af0ec:      	str	q3, [x19, #0xb50]
   af0f0:      	str	q0, [x19, #0x5d0]
   af0f4:      	str	q0, [x19, #0x5c0]
   af0f8:      	str	q0, [x19, #0x5b0]
   af0fc:      	bl	0xbb0e8 <apply_simple_smooth>
   af100:      	ldr	q0, [x19, #0x5b0]
   af104:      	mov	w2, #0x48               // =72
   af108:      	ldr	q1, [x19, #0x5c0]
   af10c:      	ldr	x9, [sp, #0x1f8]
   af110:      	ldr	q3, [x19, #0x5b0]
   af114:      	ldr	x24, [sp, #0x3e0]
   af118:      	stp	q0, q1, [x9]
   af11c:      	ldr	q0, [x19, #0x5c0]
   af120:      	ldr	x23, [sp, #0x1e8]
   af124:      	ldr	q2, [x19, #0x5d0]
   af128:      	ldr	q1, [x19, #0x5d0]
   af12c:      	stp	q3, q0, [x24, #0xf0]
   af130:      	ldr	x8, [x19, #0x5e0]
   af134:      	mov	x0, x23
   af138:      	ldr	d0, [x19, #0x5e0]
   af13c:      	str	q2, [x9, #0x20]
   af140:      	ldr	x1, [sp, #0x1d8]
   af144:      	str	q1, [x24, #0x110]
   af148:      	str	x8, [x9, #0x30]
   af14c:      	str	d0, [x22, #0x1de8]
   af150:      	bl	0xbf050 <memmove@plt>
   af154:      	ldp	q0, q1, [x23, #0x10]
   af158:      	str	d8, [x22, #0x1e38]
   af15c:      	add	x1, sp, #0xcb0
   af160:      	add	x2, sp, #0x710
   af164:      	mov	w0, w27
   af168:      	str	xzr, [x19, #0x310]
   af16c:      	str	q0, [x19, #0x890]
   af170:      	ldp	q2, q0, [x23, #0x30]
   af174:      	str	q1, [x19, #0x8a0]
   af178:      	str	q2, [x19, #0x8b0]
   af17c:      	str	q0, [x19, #0x8c0]
   af180:      	ldr	q3, [x23]
   af184:      	movi	v0.2d, #0000000000000000
   af188:      	str	q3, [x19, #0x880]
   af18c:      	stp	q0, q0, [x19, #0x2f0]
   af190:      	str	q0, [x19, #0x2e0]
   af194:      	bl	0xbb0e8 <apply_simple_smooth>
   af198:      	ldp	q0, q2, [x19, #0x2e0]
   af19c:      	ldp	q5, q1, [x19, #0x2f0]
   af1a0:      	ldr	x8, [x19, #0x310]
   af1a4:      	ldr	x9, [sp, #0x128]
   af1a8:      	ldr	q4, [x19, #0x2e0]
   af1ac:      	ldr	q6, [x19, #0x300]
   af1b0:      	stp	q0, q2, [x9]
   af1b4:      	ldr	d7, [x19, #0x310]
   af1b8:      	str	q1, [x9, #0x20]
   af1bc:      	ldr	d18, [x22, #0x1d30]
   af1c0:      	str	x8, [x9, #0x30]
   af1c4:      	ldr	d3, [x22, #0x1cc0]
   af1c8:      	ldr	d17, [x22, #0x1d68]
   af1cc:      	stp	q4, q5, [x24, #0x140]
   af1d0:      	ldp	q19, q20, [x24, #0x70]
   af1d4:      	str	q6, [x24, #0x160]
   af1d8:      	adrp	x9, 0xe9000 <g_algo+0x330>
   af1dc:      	fmadd	d17, d18, d3, d17
   af1e0:      	str	d7, [x22, #0x1e38]
   af1e4:      	ldp	q16, q2, [x24]
   af1e8:      	str	d17, [x22, #0x1cf8]
   af1ec:      	ldr	q1, [x22, #0x1d70]
   af1f0:      	ldr	q0, [x22, #0x1d80]
   af1f4:      	ldr	d21, [x22, #0x1d90]
   af1f8:      	ldr	d5, [x22, #0x1d58]
   af1fc:      	fmla	v1.2d, v16.2d, v19.2d
   af200:      	ldr	d4, [x22, #0x1ce8]
   af204:      	fmla	v0.2d, v2.2d, v20.2d
   af208:      	ldr	d18, [x22, #0x1d98]
   af20c:      	ldr	d7, [x22, #0x1d60]
   af210:      	ldr	d6, [x22, #0x1cf0]
   af214:      	fmadd	d5, d5, d4, d21
   af218:      	ldr	x8, [sp, #0x3e8]
   af21c:      	str	q1, [x22, #0x1d00]
   af220:      	ldrb	w9, [x9, #0x993]
   af224:      	str	q0, [x22, #0x1d10]
   af228:      	fmadd	d7, d7, d6, d18
   af22c:      	ldrb	w8, [x8]
   af230:      	str	d5, [x22, #0x1d20]
   af234:      	cmp	w8, w9
   af238:      	str	d7, [x22, #0x1d28]
   af23c:      	b.ne	0xaf290 <air1_opcal5_algorithm+0x66ac>
   af240:      	adrp	x10, 0xe9000 <g_algo+0x330>
   af244:      	ldr	x9, [sp, #0x3a8]
   af248:      	add	x10, x10, #0x994
   af24c:      	ldr	x19, [sp, #0x390]
   af250:      	ldr	x12, [sp, #0x3d0]
   af254:      	adrp	x27, 0xe8000 <quick_sel_arr+0x1810>
   af258:      	ldr	x23, [sp, #0x208]
   af25c:      	add	x27, x27, #0x2f8
   af260:      	ldur	d18, [x10, #0x44]
   af264:      	strb	wzr, [x9]
   af268:      	ldrb	w9, [x10]
   af26c:      	adrp	x24, 0xe9000 <g_algo+0x330>
   af270:      	ldrb	w10, [x10, #0x1]
   af274:      	mov	x13, #-0x8000000000000000 // =-9223372036854775808
   af278:      	str	d18, [x22, #0x32b0]
   af27c:      	cmp	w8, w9
   af280:      	b.eq	0xaf2e8 <air1_opcal5_algorithm+0x6704>
   af284:      	cmp	w8, w10
   af288:      	b.ne	0xaf300 <air1_opcal5_algorithm+0x671c>
   af28c:      	b	0xaf2e8 <air1_opcal5_algorithm+0x6704>
   af290:      	adrp	x11, 0xe9000 <g_algo+0x330>
   af294:      	adrp	x27, 0xe8000 <quick_sel_arr+0x1810>
   af298:      	add	x11, x11, #0x994
   af29c:      	ldr	x19, [sp, #0x390]
   af2a0:      	add	x27, x27, #0x2f8
   af2a4:      	ldr	x12, [sp, #0x3d0]
   af2a8:      	adrp	x24, 0xe9000 <g_algo+0x330>
   af2ac:      	ldr	x23, [sp, #0x208]
   af2b0:      	ldrb	w9, [x11], #0x3c
   af2b4:      	mov	x13, #-0x8000000000000000 // =-9223372036854775808
   af2b8:      	cmp	w8, w9
   af2bc:      	b.eq	0xaf2d4 <air1_opcal5_algorithm+0x66f0>
   af2c0:      	adrp	x11, 0xe9000 <g_algo+0x330>
   af2c4:      	add	x11, x11, #0x995
   af2c8:      	ldrb	w10, [x11], #0x33
   af2cc:      	cmp	w8, w10
   af2d0:      	b.ne	0xaf380 <air1_opcal5_algorithm+0x679c>
   af2d4:      	ldr	d18, [x11]
   af2d8:      	mov	w9, #0x1                // =1
   af2dc:      	ldr	x8, [sp, #0x3a8]
   af2e0:      	str	d18, [x22, #0x32c0]
   af2e4:      	strb	w9, [x8]
   af2e8:      	ldrb	w8, [x12, #0xb5]
   af2ec:      	cbnz	w8, 0xaf300 <air1_opcal5_algorithm+0x671c>
   af2f0:      	ldr	d18, [x22, #0x32b0]
   af2f4:      	mov	w8, #0x1                // =1
   af2f8:      	str	d18, [x22, #0x32c8]
   af2fc:      	strb	w8, [x12, #0xb5]
   af300:      	ldr	d18, [x22, #0x32b0]
   af304:      	ldr	x8, [sp, #0x3a8]
   af308:      	fsub	d20, d12, d18
   af30c:      	ldrb	w8, [x8]
   af310:      	cmp	w8, #0x1
   af314:      	str	d20, [x22, #0x32b8]
   af318:      	b.ne	0xaf360 <air1_opcal5_algorithm+0x677c>
   af31c:      	ldr	d19, [x22, #0x32c0]
   af320:      	fcmp	d18, d19
   af324:      	b.eq	0xaf360 <air1_opcal5_algorithm+0x677c>
   af328:      	mov	w8, #0x1                // =1
   af32c:      	strb	w8, [x12, #0xb1]
   af330:      	b.vs	0xaf42c <air1_opcal5_algorithm+0x6848>
   af334:      	mov	x9, #0x4059000000000000 // =4636737291354636288
   af338:      	fmov	d20, x9
   af33c:      	fmul	d20, d18, d20
   af340:      	fcmp	d20, #0.0
   af344:      	b.ge	0xaf368 <air1_opcal5_algorithm+0x6784>
   af348:      	adrp	x8, 0x1000 <strcasecmp+0x1000>
   af34c:      	ldr	d21, [x8, #0x518]
   af350:      	fcmp	d20, d21
   af354:      	b.pl	0xaf3a8 <air1_opcal5_algorithm+0x67c4>
   af358:      	mov	x8, #-0x8000000000000000 // =-9223372036854775808
   af35c:      	b	0xaf3bc <air1_opcal5_algorithm+0x67d8>
   af360:      	strb	wzr, [x12, #0xb1]
   af364:      	b	0xaf460 <air1_opcal5_algorithm+0x687c>
   af368:      	adrp	x8, 0x1000 <strcasecmp+0x1000>
   af36c:      	ldr	d21, [x8, #0x620]
   af370:      	fcmp	d20, d21
   af374:      	b.le	0xaf3b4 <air1_opcal5_algorithm+0x67d0>
   af378:      	mov	x8, #0x7fffffffffffffff // =9223372036854775807
   af37c:      	b	0xaf3bc <air1_opcal5_algorithm+0x67d8>
   af380:      	adrp	x11, 0xe9000 <g_algo+0x330>
   af384:      	ldrb	w11, [x11, #0x992]
   af388:      	cmp	w8, w11
   af38c:      	b.ne	0xaf27c <air1_opcal5_algorithm+0x6698>
   af390:      	adrp	x11, 0xe9000 <g_algo+0x330>
   af394:      	ldr	d18, [x11, #0x9e0]
   af398:      	ldr	x11, [sp, #0x3a8]
   af39c:      	str	d18, [x22, #0x32b0]
   af3a0:      	strb	wzr, [x11]
   af3a4:      	b	0xaf27c <air1_opcal5_algorithm+0x6698>
   af3a8:      	fmov	d21, #-0.50000000
   af3ac:      	fadd	d20, d20, d21
   af3b0:      	b	0xaf3b8 <air1_opcal5_algorithm+0x67d4>
   af3b4:      	fadd	d20, d20, d14
   af3b8:      	fcvtzs	x8, d20
   af3bc:      	fmov	d20, x9
   af3c0:      	fmul	d20, d19, d20
   af3c4:      	fcmp	d20, #0.0
   af3c8:      	b.ge	0xaf3e4 <air1_opcal5_algorithm+0x6800>
   af3cc:      	adrp	x9, 0x1000 <strcasecmp+0x1000>
   af3d0:      	ldr	d21, [x9, #0x518]
   af3d4:      	fcmp	d20, d21
   af3d8:      	fmov	d21, #-0.50000000
   af3dc:      	b.pl	0xaf3f8 <air1_opcal5_algorithm+0x6814>
   af3e0:      	b	0xaf42c <air1_opcal5_algorithm+0x6848>
   af3e4:      	adrp	x9, 0x1000 <strcasecmp+0x1000>
   af3e8:      	ldr	d21, [x9, #0x620]
   af3ec:      	fcmp	d20, d21
   af3f0:      	fmov	d21, #0.50000000
   af3f4:      	b.gt	0xaf42c <air1_opcal5_algorithm+0x6848>
   af3f8:      	mov	x9, #0x7fffffffffffffff // =9223372036854775807
   af3fc:      	add	x9, x8, x9
   af400:      	cmn	x9, #0x3
   af404:      	b.hi	0xaf42c <air1_opcal5_algorithm+0x6848>
   af408:      	fadd	d20, d20, d21
   af40c:      	mov	x10, #0x7fffffffffffffff // =9223372036854775807
   af410:      	fcvtzs	x9, d20
   af414:      	cmp	x9, x10
   af418:      	b.eq	0xaf42c <air1_opcal5_algorithm+0x6848>
   af41c:      	cmp	x9, x13
   af420:      	b.eq	0xaf42c <air1_opcal5_algorithm+0x6848>
   af424:      	cmp	x8, x9
   af428:      	b.eq	0xaf450 <air1_opcal5_algorithm+0x686c>
   af42c:      	adrp	x8, 0xe9000 <g_algo+0x330>
   af430:      	ldr	d20, [x22, #0x32c8]
   af434:      	ldr	h21, [x8, #0x996]
   af438:      	fsub	d20, d20, d19
   af43c:      	ucvtf	d21, d21
   af440:      	fdiv	d20, d20, d21
   af444:      	fsub	d18, d18, d20
   af448:      	fcmp	d18, d19
   af44c:      	b.pl	0xaf454 <air1_opcal5_algorithm+0x6870>
   af450:      	fmov	d18, d19
   af454:      	fsub	d20, d12, d18
   af458:      	str	d18, [x22, #0x32b0]
   af45c:      	str	d20, [x22, #0x32b8]
   af460:      	ldr	d19, [x22, #0x3308]
   af464:      	adrp	x9, 0xe9000 <g_algo+0x330>
   af468:      	add	x9, x9, #0x3d0
   af46c:      	fmul	d6, d6, d20
   af470:      	ldr	x8, [sp, #0x108]
   af474:      	str	d18, [x22, #0x3300]
   af478:      	fmul	d3, d3, d19
   af47c:      	ldr	d19, [x22, #0x32d0]
   af480:      	mov	w10, #0x3318            // =13080
   af484:      	str	d20, [x22, #0x3338]
   af488:      	fmadd	d3, d19, d17, d3
   af48c:      	ldr	q17, [x22, #0x3310]
   af490:      	ldr	d19, [x22, #0x3330]
   af494:      	str	d20, [x22, #0x3330]
   af498:      	fmul	v16.2d, v16.2d, v17.2d
   af49c:      	str	d3, [x9]
   af4a0:      	ldur	q3, [x12, #0x48]
   af4a4:      	fmla	v16.2d, v1.2d, v3.2d
   af4a8:      	ldr	q1, [x22, #0x3320]
   af4ac:      	fmul	d3, d4, d19
   af4b0:      	ldr	d4, [x22, #0x32f8]
   af4b4:      	str	q1, [x22, x10]
   af4b8:      	fmul	v2.2d, v2.2d, v1.2d
   af4bc:      	str	d19, [x22, #0x3328]
   af4c0:      	stur	q16, [x9, #0x8]
   af4c4:      	ldur	q16, [x12, #0x58]
   af4c8:      	fmadd	d3, d4, d5, d3
   af4cc:      	fmadd	d4, d18, d7, d6
   af4d0:      	fmla	v2.2d, v0.2d, v16.2d
   af4d4:      	stp	d3, d4, [x9, #0x28]
   af4d8:      	stur	q2, [x9, #0x18]
   af4dc:      	ldp	q0, q2, [x8]
   af4e0:      	ldr	q3, [x8, #0x20]
   af4e4:      	ldr	x8, [sp, #0x1a0]
   af4e8:      	stp	q0, q2, [x8]
   af4ec:      	str	q3, [x8, #0x20]
   af4f0:      	mov	w8, #0x3308             // =13064
   af4f4:      	ldr	d0, [x9, #0x30]
   af4f8:      	str	q17, [x22, x8]
   af4fc:      	adrp	x8, 0xe9000 <g_algo+0x330>
   af500:      	ldrb	w8, [x8, #0xa1c]
   af504:      	cbz	w8, 0xaf510 <air1_opcal5_algorithm+0x692c>
   af508:      	ldrb	w9, [x12, #0x18]
   af50c:      	cbz	w9, 0xb0138 <air1_opcal5_algorithm+0x7554>
   af510:      	fmov	d1, d0
   af514:      	adrp	x21, 0xe9000 <g_algo+0x330>
   af518:      	mov	x0, x22
   af51c:      	add	x21, x21, #0x3d0
   af520:      	ldr	x1, [sp, #0x3b0]
   af524:      	ldp	q0, q2, [x21]
   af528:      	str	d1, [x21, #0x70]
   af52c:      	str	d1, [x21, #0x38]
   af530:      	ldr	q3, [x21, #0x20]
   af534:      	stp	q0, q2, [x21, #0x40]
   af538:      	str	q3, [x21, #0x60]
   af53c:      	bl	0xb0c4c <check_error>
   af540:      	mov	x8, #0x4059000000000000 // =4636737291354636288
   af544:      	str	x8, [x21, #0x88]
   af548:      	ldrh	w9, [x22, #0x250]
   af54c:      	cmp	w9, #0xc
   af550:      	b.hs	0xaf588 <air1_opcal5_algorithm+0x69a4>
   af554:      	ldr	x16, [sp, #0x228]
   af558:      	adrp	x15, 0xe9000 <g_algo+0x330>
   af55c:      	ldr	x17, [sp, #0x220]
   af560:      	adrp	x4, 0xe8000 <quick_sel_arr+0x1810>
   af564:      	ldr	x0, [sp, #0x398]
   af568:      	fmov	d0, x8
   af56c:      	ldr	x1, [sp, #0x3d0]
   af570:      	add	x15, x15, #0x480
   af574:      	ldr	x2, [sp, #0x3c8]
   af578:      	add	x4, x4, #0x6a7
   af57c:      	ldr	x3, [sp, #0x3b8]
   af580:      	ldr	x5, [sp, #0x3a0]
   af584:      	b	0xaf650 <air1_opcal5_algorithm+0x6a6c>
   af588:      	ldr	w8, [x22, #0x238]
   af58c:      	adrp	x15, 0xe9000 <g_algo+0x330>
   af590:      	ldr	w11, [x22, #0x234]
   af594:      	adrp	x4, 0xe8000 <quick_sel_arr+0x1810>
   af598:      	ldr	x16, [sp, #0x228]
   af59c:      	add	x15, x15, #0x480
   af5a0:      	ldr	x17, [sp, #0x220]
   af5a4:      	add	x4, x4, #0x6a7
   af5a8:      	ldr	x0, [sp, #0x398]
   af5ac:      	sub	x9, x8, x11
   af5b0:      	ldr	x1, [sp, #0x3d0]
   af5b4:      	cmp	x9, #0xb5
   af5b8:      	ldr	x2, [sp, #0x3c8]
   af5bc:      	ldr	x3, [sp, #0x3b8]
   af5c0:      	ldr	x5, [sp, #0x3a0]
   af5c4:      	b.lt	0xaf648 <air1_opcal5_algorithm+0x6a64>
   af5c8:      	ldr	w9, [x22, #0x23c]
   af5cc:      	sub	x8, x9, x8
   af5d0:      	cmp	x8, #0xb5
   af5d4:      	b.lt	0xaf648 <air1_opcal5_algorithm+0x6a64>
   af5d8:      	ldr	w8, [x22, #0x240]
   af5dc:      	sub	x9, x8, x9
   af5e0:      	cmp	x9, #0xb5
   af5e4:      	b.lt	0xaf648 <air1_opcal5_algorithm+0x6a64>
   af5e8:      	ldr	w10, [x22, #0x244]
   af5ec:      	sub	x8, x10, x8
   af5f0:      	cmp	x8, #0xb5
   af5f4:      	b.lt	0xaf648 <air1_opcal5_algorithm+0x6a64>
   af5f8:      	ldr	w9, [x22, #0x248]
   af5fc:      	sub	x8, x9, x10
   af600:      	cmp	x8, #0xb5
   af604:      	b.lt	0xaf648 <air1_opcal5_algorithm+0x6a64>
   af608:      	ldr	w10, [x22, #0x24c]
   af60c:      	sub	x10, x10, x9
   af610:      	cmp	x10, #0xb5
   af614:      	b.lt	0xaf648 <air1_opcal5_algorithm+0x6a64>
   af618:      	adrp	x10, 0xe8000 <quick_sel_arr+0x1810>
   af61c:      	ldr	w10, [x10, #0xcd4]
   af620:      	sub	x11, x10, x11
   af624:      	sub	x12, x11, #0x835
   af628:      	cmn	x12, #0x385
   af62c:      	b.lo	0xaf648 <air1_opcal5_algorithm+0x6a64>
   af630:      	ldrb	w12, [x1, #0xbc]
   af634:      	cmp	w12, #0x1
   af638:      	b.eq	0xaf648 <air1_opcal5_algorithm+0x6a64>
   af63c:      	ldrb	w12, [x1, #0xbd]
   af640:      	cmp	w12, #0x1
   af644:      	b.ne	0xb01ac <air1_opcal5_algorithm+0x75c8>
   af648:      	mov	x8, #0x4059000000000000 // =4636737291354636288
   af64c:      	fmov	d0, x8
   af650:      	add	x9, x27, x3, lsl #1
   af654:      	ldr	x11, [sp, #0x2c0]
   af658:      	add	x10, x9, #0x60
   af65c:      	add	x8, x9, #0x20
   af660:      	adrp	x14, 0xe8000 <quick_sel_arr+0x1810>
   af664:      	add	x14, x14, #0x610
   af668:      	ldr	w11, [x11]
   af66c:      	ld4	{ v16.8h, v17.8h, v18.8h, v19.8h }, [x10]
   af670:      	add	x10, x9, #0xa0
   af674:      	str	w11, [x14, #0x4]
   af678:      	ld4	{ v20.8h, v21.8h, v22.8h, v23.8h }, [x10]
   af67c:      	stur	q16, [x14, #0x18]
   af680:      	ldr	x10, [sp, #0x2b8]
   af684:      	ld4	{ v1.8h, v2.8h, v3.8h, v4.8h }, [x8]
   af688:      	stur	q20, [x14, #0x28]
   af68c:      	ldrh	w10, [x10]
   af690:      	ldrh	w12, [x9, #0xe0]
   af694:      	ldrh	w11, [x9, #0xf0]
   af698:      	strh	w10, [x14]
   af69c:      	ldrh	w10, [x9, #0xe8]
   af6a0:      	strh	w12, [x14, #0x38]
   af6a4:      	ldrh	w12, [x9, #0xf8]
   af6a8:      	strh	w11, [x14, #0x3c]
   af6ac:      	ldrh	w11, [x8, #0xe8]
   af6b0:      	strh	w10, [x14, #0x3a]
   af6b4:      	ldrb	w10, [x27, #0x310]
   af6b8:      	add	x8, x3, #0x1
   af6bc:      	strh	w12, [x14, #0x3e]
   af6c0:      	ldrb	w12, [x15]
   af6c4:      	strh	w11, [x14, #0x42]
   af6c8:      	cmp	x8, x10
   af6cc:      	ldrh	w13, [x9, #0x100]
   af6d0:      	ldrh	w9, [x9]
   af6d4:      	cset	w11, ne
   af6d8:      	cmp	w12, #0x1
   af6dc:      	stur	q1, [x14, #0x8]
   af6e0:      	strh	w13, [x14, #0x40]
   af6e4:      	strh	w9, [x14, #0x2]
   af6e8:      	strb	w11, [x14, #0x9a]
   af6ec:      	b.eq	0xaf708 <air1_opcal5_algorithm+0x6b24>
   af6f0:      	ldrb	w11, [x15, #0x5]
   af6f4:      	cmp	w11, #0x1
   af6f8:      	b.eq	0xaf708 <air1_opcal5_algorithm+0x6b24>
   af6fc:      	ldrb	w11, [x15, #0x8a]
   af700:      	cmp	w11, #0x1
   af704:      	b.ne	0xaf71c <air1_opcal5_algorithm+0x6b38>
   af708:      	cmp	x8, x10
   af70c:      	mov	w10, #0x4               // =4
   af710:      	cinc	w10, w10, ne
   af714:      	adrp	x11, 0xe8000 <quick_sel_arr+0x1810>
   af718:      	strb	w10, [x11, #0x6aa]
   af71c:      	adrp	x12, 0xe9000 <g_algo+0x330>
   af720:      	adrp	x13, 0xe8000 <quick_sel_arr+0x1810>
   af724:      	add	x12, x12, #0x440
   af728:      	add	x13, x13, #0x654
   af72c:      	ldrb	w11, [x12, #0x20]
   af730:      	ldr	d1, [x12]
   af734:      	ldrb	w12, [x12, #0x21]
   af738:      	cmp	w11, #0x0
   af73c:      	cset	w10, ne
   af740:      	stp	d1, d0, [x13]
   af744:      	sturh	w10, [x13, #0x53]
   af748:      	cbz	w12, 0xaf75c <air1_opcal5_algorithm+0x6b78>
   af74c:      	cmp	w11, #0x0
   af750:      	mov	w10, #0x2               // =2
   af754:      	cinc	w10, w10, ne
   af758:      	strh	w10, [x4]
   af75c:      	adrp	x11, 0xe9000 <g_algo+0x330>
   af760:      	ldrb	w11, [x11, #0x462]
   af764:      	cbz	w11, 0xaf770 <air1_opcal5_algorithm+0x6b8c>
   af768:      	orr	w10, w10, #0x4
   af76c:      	strh	w10, [x4]
   af770:      	adrp	x11, 0xe9000 <g_algo+0x330>
   af774:      	ldrb	w11, [x11, #0x463]
   af778:      	cbz	w11, 0xaf784 <air1_opcal5_algorithm+0x6ba0>
   af77c:      	add	w10, w10, #0x8
   af780:      	strh	w10, [x4]
   af784:      	adrp	x11, 0xe9000 <g_algo+0x330>
   af788:      	ldrb	w11, [x11, #0x464]
   af78c:      	cbz	w11, 0xaf798 <air1_opcal5_algorithm+0x6bb4>
   af790:      	add	w10, w10, #0x10
   af794:      	strh	w10, [x4]
   af798:      	ldrb	w11, [x24, #0xfb0]
   af79c:      	cmp	w11, #0x1
   af7a0:      	b.ne	0xaf7ac <air1_opcal5_algorithm+0x6bc8>
   af7a4:      	add	w10, w10, #0x20
   af7a8:      	strh	w10, [x4]
   af7ac:      	adrp	x10, 0xe8000 <quick_sel_arr+0x1810>
   af7b0:      	adrp	x11, 0xe9000 <g_algo+0x330>
   af7b4:      	add	x10, x10, #0xd98
   af7b8:      	ldr	d2, [x11, #0xfa8]
   af7bc:      	adrp	x11, 0xe8000 <quick_sel_arr+0x1810>
   af7c0:      	ldr	d1, [x10, #0x6d0]
   af7c4:      	ldrb	w10, [x10]
   af7c8:      	fcmp	d2, d1
   af7cc:      	strb	w10, [x11, #0x664]
   af7d0:      	b.pl	0xaf7dc <air1_opcal5_algorithm+0x6bf8>
   af7d4:      	mov	w10, wzr
   af7d8:      	b	0xaf824 <air1_opcal5_algorithm+0x6c40>
   af7dc:      	fneg	d1, d0
   af7e0:      	fcmp	d0, #0.0
   af7e4:      	adrp	x10, 0xe9000 <g_algo+0x330>
   af7e8:      	fcsel	d1, d1, d0, mi
   af7ec:      	ldr	d2, [x10, #0xfa0]
   af7f0:      	mov	x10, #0xc00000000000    // =211106232532992
   af7f4:      	movk	x10, #0x4058, lsl #48
   af7f8:      	fcmp	d1, d2
   af7fc:      	fmov	d1, x10
   af800:      	adrp	x10, 0xe9000 <g_algo+0x330>
   af804:      	cset	w11, lt
   af808:      	ldrb	w10, [x10, #0x465]
   af80c:      	fcmp	d0, d1
   af810:      	cset	w12, pl
   af814:      	cmp	w10, #0x0
   af818:      	orr	w10, w12, w11
   af81c:      	cset	w11, eq
   af820:      	and	w10, w11, w10
   af824:      	adrp	x14, 0xe9000 <g_algo+0x330>
   af828:      	adrp	x13, 0xe8000 <quick_sel_arr+0x1810>
   af82c:      	add	x14, x14, #0x2d2
   af830:      	add	x13, x13, #0x666
   af834:      	add	x11, x14, #0x13e
   af838:      	add	x12, x14, #0x14e
   af83c:      	strb	w10, [x13, #0x43]
   af840:      	ldr	w10, [x14, #0x8]
   af844:      	ldr	q0, [x11]
   af848:      	add	x11, x14, #0x15e
   af84c:      	ldr	q1, [x12]
   af850:      	str	wzr, [x13]
   af854:      	ldr	x12, [x14]
   af858:      	stur	w10, [x13, #0xd]
   af85c:      	stur	q0, [x13, #0x11]
   af860:      	ldr	q0, [x11]
   af864:      	stur	q1, [x13, #0x21]
   af868:      	tst	w12, #0xffff
   af86c:      	stur	x12, [x13, #0x5]
   af870:      	stur	q0, [x13, #0x31]
   af874:      	strb	wzr, [x13, #0x4]
   af878:      	b.eq	0xaf888 <air1_opcal5_algorithm+0x6ca4>
   af87c:      	mov	w10, #0x1               // =1
   af880:      	adrp	x11, 0xe8000 <quick_sel_arr+0x1810>
   af884:      	strb	w10, [x11, #0x665]
   af888:      	ldr	x11, [sp, #0xf8]
   af88c:      	strh	w9, [x22, #0x5a]
   af890:      	ldr	x9, [sp, #0x100]
   af894:      	adrp	x13, 0xe8000 <quick_sel_arr+0x1810>
   af898:      	add	x13, x13, #0x610
   af89c:      	ldr	x12, [sp, #0x300]
   af8a0:      	ldr	w10, [x11]
   af8a4:      	ldrb	w11, [x11, #0x4]
   af8a8:      	str	w10, [x9]
   af8ac:      	strb	w11, [x9, #0x4]
   af8b0:      	mov	w9, #0x9b               // =155
   af8b4:      	ldrb	w10, [x13, #0x9a]
   af8b8:      	add	x11, x13, #0x9b
   af8bc:      	madd	x9, x3, x9, x19
   af8c0:      	cmp	x12, x11
   af8c4:      	strb	w10, [x22, #0x61]
   af8c8:      	b.hs	0xaf8e8 <air1_opcal5_algorithm+0x6d04>
   af8cc:      	ldr	x10, [sp, #0x260]
   af8d0:      	cmp	x10, x13
   af8d4:      	b.ls	0xaf8e8 <air1_opcal5_algorithm+0x6d04>
   af8d8:      	mov	w12, wzr
   af8dc:      	mov	x11, x13
   af8e0:      	mov	x10, x9
   af8e4:      	b	0xaf93c <air1_opcal5_algorithm+0x6d58>
   af8e8:      	mov	w10, #0x9b              // =155
   af8ec:      	add	x11, x13, #0x98
   af8f0:      	ldp	q0, q1, [x13]
   af8f4:      	nop
   af8f8:      	madd	x10, x3, x10, x19
   af8fc:      	mov	w12, #0x98              // =152
   af900:      	str	q0, [x9]
   af904:      	str	q1, [x10, #0x10]
   af908:      	ldp	q0, q1, [x13, #0x20]
   af90c:      	stp	q0, q1, [x10, #0x20]
   af910:      	ldp	q0, q1, [x13, #0x40]
   af914:      	stp	q0, q1, [x10, #0x40]
   af918:      	add	x10, x9, #0x98
   af91c:      	ldp	q0, q1, [x13, #0x60]
   af920:      	stp	q0, q1, [x9, #0x60]
   af924:      	ldr	d0, [x13, #0x80]
   af928:      	str	d0, [x9, #0x80]
   af92c:      	ldr	d0, [x13, #0x88]
   af930:      	str	d0, [x9, #0x88]
   af934:      	ldr	d0, [x13, #0x90]
   af938:      	str	d0, [x9, #0x90]
   af93c:      	sub	w9, w12, #0x9b
   af940:      	ldrb	w12, [x11], #0x1
   af944:      	adds	w9, w9, #0x1
   af948:      	strb	w12, [x10], #0x1
   af94c:      	b.lo	0xaf940 <air1_opcal5_algorithm+0x6d5c>
   af950:      	adrp	x15, 0xe8000 <quick_sel_arr+0x1810>
   af954:      	adrp	x4, 0xe8000 <quick_sel_arr+0x1810>
   af958:      	add	x15, x15, #0x610
   af95c:      	add	x4, x4, #0xd18
   af960:      	add	x13, x4, #0x5c8
   af964:      	ldr	x14, [sp, #0x3e0]
   af968:      	ldp	w9, w10, [x15]
   af96c:      	ldrb	w11, [x15, #0x9a]
   af970:      	ldr	d0, [x4]
   af974:      	ldur	q1, [x15, #0x8]
   af978:      	stp	w9, w10, [x20]
   af97c:      	ldur	q2, [x15, #0x18]
   af980:      	add	x9, x4, #0x138
   af984:      	strb	w11, [x20, #0x8]
   af988:      	stur	d0, [x20, #0xa]
   af98c:      	ldur	q0, [x15, #0x28]
   af990:      	stur	q1, [x20, #0x12]
   af994:      	ldur	q1, [x15, #0x34]
   af998:      	stur	q2, [x20, #0x22]
   af99c:      	add	x10, x4, #0x148
   af9a0:      	ldr	q2, [x9]
   af9a4:      	add	x9, x4, #0x158
   af9a8:      	add	x11, x4, #0x168
   af9ac:      	stur	q0, [x20, #0x32]
   af9b0:      	stur	q1, [x20, #0x3e]
   af9b4:      	ldr	q0, [x10]
   af9b8:      	stur	q2, [x20, #0xfe]
   af9bc:      	add	x10, x20, #0x4e
   af9c0:      	ldr	q1, [x9]
   af9c4:      	add	x9, x4, #0x108
   af9c8:      	ldr	q2, [x11]
   af9cc:      	add	x11, x4, #0x118
   af9d0:      	ldrb	w12, [x15, #0x54]
   af9d4:      	stp	q0, q1, [x10, #0xc0]
   af9d8:      	ldr	q0, [x9]
   af9dc:      	ldr	q1, [x11]
   af9e0:      	str	q2, [x10, #0xe0]
   af9e4:      	strb	w12, [x20, #0x9]
   af9e8:      	add	x12, x4, #0x128
   af9ec:      	stur	q0, [x20, #0xce]
   af9f0:      	ldur	q0, [x4, #0xb8]
   af9f4:      	stur	q1, [x20, #0xde]
   af9f8:      	ldur	q1, [x4, #0xc8]
   af9fc:      	ldr	q2, [x12]
   afa00:      	add	x9, x4, #0x548
   afa04:      	stur	q0, [x20, #0x7e]
   afa08:      	ldur	q0, [x4, #0xe8]
   afa0c:      	stur	q1, [x20, #0x8e]
   afa10:      	ldur	q1, [x4, #0x88]
   afa14:      	ldur	q3, [x4, #0xf8]
   afa18:      	stur	q2, [x20, #0xee]
   afa1c:      	ldur	q2, [x4, #0xd8]
   afa20:      	stur	q0, [x20, #0xae]
   afa24:      	stur	q1, [x20, #0x4e]
   afa28:      	ldur	q0, [x4, #0x98]
   afa2c:      	ldur	q1, [x4, #0xa8]
   afa30:      	add	x10, x4, #0x538
   afa34:      	stur	q3, [x20, #0xbe]
   afa38:      	add	x11, x20, #0x13e
   afa3c:      	stur	q2, [x20, #0x9e]
   afa40:      	ldr	x12, [x4, #0x558]
   afa44:      	stur	q0, [x20, #0x5e]
   afa48:      	ldr	q0, [x9]
   afa4c:      	stur	q1, [x20, #0x6e]
   afa50:      	ldr	q1, [x10]
   afa54:      	ldr	q2, [x4, #0x560]
   afa58:      	add	x9, x20, #0x166
   afa5c:      	ldr	d3, [x4, #0x570]
   afa60:      	add	x10, x20, #0x176
   afa64:      	str	x12, [x11, #0x20]
   afa68:      	ldur	w12, [x15, #0x63]
   afa6c:      	stp	q1, q0, [x11]
   afa70:      	add	x11, x20, #0x19e
   afa74:      	str	q2, [x9]
   afa78:      	add	x9, x20, #0x17e
   afa7c:      	str	d3, [x10]
   afa80:      	ldr	d2, [x22, #0x1b40]
   afa84:      	ldr	q0, [x0]
   afa88:      	add	x10, x20, #0x18e
   afa8c:      	ldr	q1, [x22, #0x1b30]
   afa90:      	str	d2, [x11]
   afa94:      	add	x11, x4, #0x588
   afa98:      	str	q0, [x9]
   afa9c:      	add	x9, x4, #0x578
   afaa0:      	str	q1, [x10]
   afaa4:      	ldr	q1, [x4, #0x5a0]
   afaa8:      	ldrb	w10, [x2]
   afaac:      	str	w12, [x20, #0x1f0]
   afab0:      	ldr	q0, [x9]
   afab4:      	add	x9, x20, #0x1a7
   afab8:      	ldr	d2, [x4, #0x5b0]
   afabc:      	add	x12, x20, #0x23d
   afac0:      	strb	w10, [x20, #0x1a6]
   afac4:      	add	x10, x20, #0x1cf
   afac8:      	str	q0, [x9]
   afacc:      	ldr	q0, [x11]
   afad0:      	add	x9, x20, #0x1bf
   afad4:      	add	x11, x20, #0x1df
   afad8:      	str	q1, [x10]
   afadc:      	ldur	x10, [x15, #0x5b]
   afae0:      	ldur	d3, [x15, #0x44]
   afae4:      	str	q0, [x9]
   afae8:      	ldrb	w9, [x4, #0x5b8]
   afaec:      	str	d2, [x11]
   afaf0:      	add	x11, x4, #0x5d8
   afaf4:      	str	x10, [x20, #0x1e8]
   afaf8:      	ldr	q2, [x13]
   afafc:      	strb	w9, [x20, #0x1e7]
   afb00:      	add	x9, x4, #0x5e8
   afb04:      	ldr	q1, [x11]
   afb08:      	add	x13, x20, #0x245
   afb0c:      	ldrh	w10, [x4, #0x5fc]
   afb10:      	ldr	q0, [x9]
   afb14:      	add	x9, x20, #0x1f4
   afb18:      	ldr	w11, [x4, #0x5f8]
   afb1c:      	strh	w10, [x20, #0x228]
   afb20:      	ldr	w10, [x4, #0x608]
   afb24:      	stp	q1, q0, [x9, #0x10]
   afb28:      	ldr	d0, [x4, #0x600]
   afb2c:      	str	q2, [x9]
   afb30:      	ldr	d1, [x22, #0x1e60]
   afb34:      	str	w11, [x20, #0x224]
   afb38:      	add	x11, x20, #0x239
   afb3c:      	ldrb	w9, [x1, #0x18]
   afb40:      	ldr	q2, [x22, #0x1d20]
   afb44:      	strb	w9, [x20, #0x22a]
   afb48:      	ldr	x9, [sp, #0x3e8]
   afb4c:      	ldrb	w9, [x9]
   afb50:      	str	w10, [x20, #0x22c]
   afb54:      	str	d0, [x20, #0x230]
   afb58:      	ldr	d0, [x22, #0x1e48]
   afb5c:      	strb	w9, [x20, #0x22b]
   afb60:      	ldrb	w10, [x2, #0x312]
   afb64:      	str	d0, [x12]
   afb68:      	str	d1, [x13]
   afb6c:      	ldr	d0, [x22, #0x1e80]
   afb70:      	ldr	d1, [x22, #0x1e50]
   afb74:      	add	x12, x20, #0x256
   afb78:      	strb	w10, [x20, #0x238]
   afb7c:      	ldr	w10, [x22, #0x1e44]
   afb80:      	add	x13, x20, #0x339
   afb84:      	str	w10, [x11]
   afb88:      	add	x11, x20, #0x24e
   afb8c:      	ldrb	w10, [x2, #0x34a]
   afb90:      	str	d1, [x12]
   afb94:      	ldr	q1, [x22, #0x1e90]
   afb98:      	add	x12, x20, #0x2f9
   afb9c:      	str	d0, [x11]
   afba0:      	ldr	d0, [x22, #0x1e88]
   afba4:      	strb	w10, [x20, #0x24d]
   afba8:      	ldrh	w10, [x22, #0x1e58]
   afbac:      	add	x11, x20, #0x278
   afbb0:      	str	d0, [x20, #0x260]
   afbb4:      	strh	w10, [x20, #0x25e]
   afbb8:      	add	x10, x20, #0x268
   afbbc:      	ldr	q0, [x0, #0x320]
   afbc0:      	str	q1, [x11]
   afbc4:      	add	x11, x20, #0x2c1
   afbc8:      	ldr	q1, [x22, #0x1cc0]
   afbcc:      	str	q0, [x10]
   afbd0:      	ldrb	w10, [x2, #0x372]
   afbd4:      	strb	w10, [x20, #0x288]
   afbd8:      	add	x10, x20, #0x289
   afbdc:      	ldr	d0, [x22, #0x1d30]
   afbe0:      	str	d0, [x10]
   afbe4:      	ldr	q0, [x0, #0x220]
   afbe8:      	str	q1, [x12]
   afbec:      	ldr	q1, [x22, #0x1d00]
   afbf0:      	str	q0, [x11]
   afbf4:      	ldr	q0, [x14, #0x70]
   afbf8:      	str	q1, [x13]
   afbfc:      	ldr	q1, [x22, #0x1cd0]
   afc00:      	add	x13, x20, #0x349
   afc04:      	stur	q0, [x10, #0x8]
   afc08:      	ldr	q0, [x0, #0x230]
   afc0c:      	str	q1, [x12, #0x10]
   afc10:      	ldr	q1, [x22, #0x1d10]
   afc14:      	str	q0, [x11, #0x10]
   afc18:      	ldr	q0, [x14, #0x80]
   afc1c:      	str	q1, [x13]
   afc20:      	ldr	q1, [x22, #0x1ce0]
   afc24:      	add	x13, x4, #0x6c8
   afc28:      	add	x14, x20, #0x382
   afc2c:      	stur	q0, [x10, #0x18]
   afc30:      	ldr	q0, [x0, #0x240]
   afc34:      	str	q1, [x12, #0x20]
   afc38:      	ldr	d1, [x22, #0x1d98]
   afc3c:      	str	q0, [x11, #0x20]
   afc40:      	ldr	q0, [x0, #0x210]
   afc44:      	str	d1, [x11, #0x30]
   afc48:      	ldr	d1, [x22, #0x32c0]
   afc4c:      	add	x11, x4, #0x6d8
   afc50:      	strb	w9, [x20, #0x381]
   afc54:      	add	x9, x20, #0x3b2
   afc58:      	stur	q0, [x10, #0x28]
   afc5c:      	ldr	q0, [x22, #0x1cf0]
   afc60:      	add	x10, x20, #0x359
   afc64:      	str	q0, [x12, #0x30]
   afc68:      	ldr	q0, [x22, #0x32b0]
   afc6c:      	str	q2, [x10]
   afc70:      	add	x10, x20, #0x369
   afc74:      	add	x12, x20, #0x379
   afc78:      	str	q0, [x10]
   afc7c:      	ldr	q0, [x11]
   afc80:      	str	d1, [x12]
   afc84:      	ldr	q1, [x13]
   afc88:      	add	x10, x4, #0x6b8
   afc8c:      	ldurh	w11, [x15, #0x97]
   afc90:      	add	x12, x20, #0x4b9
   afc94:      	stp	q1, q0, [x14, #0x10]
   afc98:      	ldr	d0, [x4, #0x6e8]
   afc9c:      	ldr	q2, [x10]
   afca0:      	add	x10, x20, #0x3ba
   afca4:      	strh	w11, [x20, #0x3c2]
   afca8:      	ldrb	w11, [x4, #0x74a]
   afcac:      	str	d0, [x9]
   afcb0:      	ldrb	w9, [x4, #0x748]
   afcb4:      	str	d3, [x10]
   afcb8:      	ldrb	w10, [x4, #0x749]
   afcbc:      	strb	w11, [x20, #0x3c6]
   afcc0:      	ldur	d0, [x15, #0x4c]
   afcc4:      	strb	w9, [x20, #0x3c4]
   afcc8:      	ldrb	w9, [x4, #0x74b]
   afccc:      	strb	w10, [x20, #0x3c5]
   afcd0:      	ldrb	w10, [x4, #0x74c]
   afcd4:      	ldr	d1, [x4, #0x750]
   afcd8:      	add	x11, x20, #0x3d4
   afcdc:      	strb	w9, [x20, #0x3c7]
   afce0:      	ldrb	w9, [x24, #0xfb0]
   afce4:      	strb	w10, [x20, #0x3c8]
   afce8:      	add	x10, x20, #0x3cb
   afcec:      	str	q2, [x14]
   afcf0:      	ldr	d2, [x22, #0x3480]
   afcf4:      	strb	w9, [x20, #0x3c9]
   afcf8:      	ldrb	w9, [x15, #0x99]
   afcfc:      	str	d0, [x10]
   afd00:      	add	x10, x20, #0x3ec
   afd04:      	str	d1, [x11]
   afd08:      	ldr	d1, [x22, #0x3468]
   afd0c:      	strb	w9, [x20, #0x3d3]
   afd10:      	add	x9, x20, #0x3dc
   afd14:      	ldr	q0, [x0, #0x1910]
   afd18:      	add	x14, x20, #0x4be
   afd1c:      	ldrb	w11, [x4, #0x758]
   afd20:      	str	d1, [x10]
   afd24:      	ldr	q1, [x22, #0x3470]
   afd28:      	add	x10, x20, #0x3fd
   afd2c:      	str	q0, [x9]
   afd30:      	ldr	d0, [x4, #0x760]
   afd34:      	strb	w11, [x20, #0x3f4]
   afd38:      	add	x9, x20, #0x3f5
   afd3c:      	add	x11, x20, #0x40d
   afd40:      	str	q1, [x10]
   afd44:      	ldrb	w10, [x4, #0x768]
   afd48:      	str	d0, [x9]
   afd4c:      	ldr	d0, [x4, #0x780]
   afd50:      	str	d2, [x11]
   afd54:      	add	x11, x20, #0x41c
   afd58:      	ldrb	w9, [x17]
   afd5c:      	strb	w9, [x20, #0x415]
   afd60:      	ldrb	w9, [x17, #0x1]
   afd64:      	strb	w9, [x20, #0x416]
   afd68:      	ldrb	w9, [x17, #0x2]
   afd6c:      	strb	w9, [x20, #0x417]
   afd70:      	ldrh	w9, [x0, #0x1940]
   afd74:      	strb	w10, [x20, #0x41a]
   afd78:      	str	d0, [x11]
   afd7c:      	add	x10, x4, #0x798
   afd80:      	ldr	q0, [x4, #0x770]
   afd84:      	add	x11, x20, #0x424
   afd88:      	strh	w9, [x20, #0x418]
   afd8c:      	ldrb	w9, [x4, #0x769]
   afd90:      	ldr	q2, [x10]
   afd94:      	add	x10, x20, #0x444
   afd98:      	str	q0, [x11]
   afd9c:      	add	x11, x4, #0x7a8
   afda0:      	strb	w9, [x20, #0x41b]
   afda4:      	add	x9, x4, #0x788
   afda8:      	str	q2, [x10]
   afdac:      	add	x10, x20, #0x454
   afdb0:      	ldr	q0, [x11]
   afdb4:      	add	x11, x20, #0x474
   afdb8:      	ldr	q1, [x9]
   afdbc:      	add	x9, x20, #0x434
   afdc0:      	ldr	d2, [x4, #0x7c8]
   afdc4:      	str	q0, [x10]
   afdc8:      	ldrb	w10, [x4, #0x7e8]
   afdcc:      	str	q1, [x9]
   afdd0:      	add	x9, x4, #0x7b8
   afdd4:      	str	d2, [x11]
   afdd8:      	ldrb	w11, [x4, #0x7ea]
   afddc:      	strb	w10, [x20, #0x47c]
   afde0:      	ldrb	w10, [x4, #0x76a]
   afde4:      	ldr	q1, [x9]
   afde8:      	add	x9, x20, #0x464
   afdec:      	strb	w11, [x20, #0x47e]
   afdf0:      	ldrb	w11, [x4, #0x76c]
   afdf4:      	strb	w10, [x20, #0x47f]
   afdf8:      	ldr	d0, [x4, #0x7d0]
   afdfc:      	str	q1, [x9]
   afe00:      	ldrb	w9, [x4, #0x7e9]
   afe04:      	strb	w11, [x20, #0x481]
   afe08:      	add	x10, x20, #0x483
   afe0c:      	ldr	d1, [x22, #0x5038]
   afe10:      	add	x11, x20, #0x48b
   afe14:      	strb	w9, [x20, #0x47d]
   afe18:      	ldrb	w9, [x4, #0x76b]
   afe1c:      	str	d0, [x10]
   afe20:      	ldr	d0, [x4, #0x7e0]
   afe24:      	str	d1, [x11]
   afe28:      	add	x11, x20, #0x497
   afe2c:      	strb	w9, [x20, #0x480]
   afe30:      	ldrb	w9, [x4, #0x76d]
   afe34:      	ldrb	w10, [x4, #0x7d9]
   afe38:      	str	d0, [x11]
   afe3c:      	ldr	q0, [x4, #0x800]
   afe40:      	strb	w9, [x20, #0x482]
   afe44:      	ldrb	w9, [x4, #0x7d8]
   afe48:      	strb	w10, [x20, #0x494]
   afe4c:      	ldrb	w10, [x4, #0x7db]
   afe50:      	ext	v0.16b, v0.16b, v0.16b, #0x8
   afe54:      	ldr	d1, [x4, #0x7f8]
   afe58:      	strb	w9, [x20, #0x493]
   afe5c:      	ldrb	w9, [x4, #0x7da]
   afe60:      	strb	w10, [x20, #0x496]
   afe64:      	add	x10, x20, #0x4a1
   afe68:      	ldrb	w11, [x4, #0x814]
   afe6c:      	strb	w9, [x20, #0x495]
   afe70:      	ldrb	w9, [x4, #0x7eb]
   afe74:      	str	d1, [x10]
   afe78:      	add	x10, x4, #0x7ed
   afe7c:      	strb	w11, [x12, #0x4]
   afe80:      	ldrb	w11, [x4, #0x815]
   afe84:      	strb	w9, [x20, #0x49f]
   afe88:      	ldrb	w9, [x4, #0x7ec]
   afe8c:      	ldrb	w13, [x10, #0x4]
   afe90:      	ldr	w10, [x10]
   afe94:      	strb	w11, [x20, #0x4c4]
   afe98:      	strb	w9, [x20, #0x4a0]
   afe9c:      	add	x9, x20, #0x4a9
   afea0:      	add	x11, x20, #0x60e
   afea4:      	ldr	q1, [x22, #0x9270]
   afea8:      	str	w10, [x14]
   afeac:      	ldrb	w10, [x4, #0x93f]
   afeb0:      	str	q0, [x9]
   afeb4:      	ldr	w9, [x4, #0x810]
   afeb8:      	ldr	q0, [x4, #0x940]
   afebc:      	strb	w13, [x14, #0x4]
   afec0:      	strb	w10, [x20, #0x60d]
   afec4:      	add	x10, x20, #0x4ce
   afec8:      	str	w9, [x12]
   afecc:      	ldrb	w9, [x4, #0x7f2]
   afed0:      	str	q0, [x11]
   afed4:      	add	x11, x20, #0x4f6
   afed8:      	ext	v1.16b, v1.16b, v1.16b, #0x8
   afedc:      	add	x12, x20, #0x606
   afee0:      	strb	w9, [x20, #0x4c3]
   afee4:      	ldrb	w9, [x4, #0x816]
   afee8:      	ldr	w13, [x4, #0x938]
   afeec:      	strb	w9, [x20, #0x4c5]
   afef0:      	add	x9, x20, #0x4c6
   afef4:      	ldr	d0, [x16]
   afef8:      	str	q1, [x10]
   afefc:      	add	x10, x20, #0x4e6
   aff00:      	ldr	d1, [x4, #0x860]
   aff04:      	str	d0, [x9]
   aff08:      	add	x9, x20, #0x4de
   aff0c:      	ldr	d0, [x16, #0x2b8]
   aff10:      	str	d1, [x11]
   aff14:      	add	x11, x4, #0x838
   aff18:      	str	d0, [x9]
   aff1c:      	add	x9, x4, #0x818
   aff20:      	ldr	q0, [x4, #0x850]
   aff24:      	ldr	q1, [x11]
   aff28:      	add	x11, x20, #0x52e
   aff2c:      	ldr	q2, [x9]
   aff30:      	add	x9, x20, #0x4fe
   aff34:      	str	q0, [x10]
   aff38:      	add	x10, x4, #0x828
   aff3c:      	str	q2, [x9]
   aff40:      	add	x9, x20, #0x50e
   aff44:      	ldr	q0, [x10]
   aff48:      	add	x10, x20, #0x51e
   aff4c:      	ldr	d2, [x4, #0x848]
   aff50:      	str	q0, [x9]
   aff54:      	ldr	d0, [x4, #0x868]
   aff58:      	str	q1, [x10]
   aff5c:      	add	x9, x20, #0x536
   aff60:      	ldr	q1, [x4, #0x890]
   aff64:      	add	x10, x20, #0x53e
   aff68:      	str	d2, [x11]
   aff6c:      	ldr	q2, [x4, #0x8a0]
   aff70:      	add	x11, x20, #0x54e
   aff74:      	str	d0, [x9]
   aff78:      	str	q1, [x10]
   aff7c:      	ldr	d0, [x4, #0x880]
   aff80:      	add	x9, x20, #0x55e
   aff84:      	ldr	q1, [x4, #0x870]
   aff88:      	add	x10, x20, #0x566
   aff8c:      	str	q2, [x11]
   aff90:      	ldr	d2, [x4, #0x888]
   aff94:      	add	x11, x20, #0x576
   aff98:      	str	d0, [x9]
   aff9c:      	ldr	d0, [x4, #0x908]
   affa0:      	str	q1, [x10]
   affa4:      	add	x9, x20, #0x57e
   affa8:      	ldr	d1, [x4, #0x930]
   affac:      	add	x10, x20, #0x586
   affb0:      	str	d2, [x11]
   affb4:      	ldr	d2, [x4, #0x920]
   affb8:      	add	x11, x20, #0x58e
   affbc:      	str	d0, [x9]
   affc0:      	str	d1, [x10]
   affc4:      	ldr	q0, [x4, #0x910]
   affc8:      	add	x9, x20, #0x596
   affcc:      	ldr	d1, [x4, #0x928]
   affd0:      	add	x10, x20, #0x5a6
   affd4:      	str	d2, [x11]
   affd8:      	ldr	d2, [x4, #0x8b0]
   affdc:      	add	x11, x20, #0x5ae
   affe0:      	str	q0, [x9]
   affe4:      	add	x9, x4, #0x8d8
   affe8:      	str	d1, [x10]
   affec:      	add	x10, x4, #0x8b8
   afff0:      	str	d2, [x11]
   afff4:      	ldr	d1, [x4, #0x8c8]
   afff8:      	ldr	q0, [x9]
   afffc:      	add	x9, x20, #0x5b6
   b0000:      	ldr	q2, [x10]
   b0004:      	add	x10, x20, #0x5ce
   b0008:      	add	x11, x20, #0x5c6
   b000c:      	str	q0, [x9]
   b0010:      	ldr	d0, [x4, #0x8d0]
   b0014:      	str	q2, [x10]
   b0018:      	add	x10, x20, #0x5de
   b001c:      	add	x9, x4, #0x8e8
   b0020:      	str	d1, [x11]
   b0024:      	ldr	d1, [x4, #0x8f8]
   b0028:      	add	x11, x20, #0x5e6
   b002c:      	str	d0, [x10]
   b0030:      	add	x10, x4, #0x938
   b0034:      	ldr	q2, [x9]
   b0038:      	add	x9, x20, #0x5ee
   b003c:      	str	d1, [x11]
   b0040:      	ldr	d0, [x4, #0x900]
   b0044:      	ldur	w10, [x10, #0x3]
   b0048:      	add	x11, x20, #0x5fe
   b004c:      	str	q2, [x9]
   b0050:      	mov	w9, #0x61e              // =1566
   b0054:      	madd	x9, x3, x9, x5
   b0058:      	stur	w10, [x12, #0x3]
   b005c:      	ldr	x10, [sp, #0x340]
   b0060:      	str	d0, [x11]
   b0064:      	add	x11, x20, #0x61e
   b0068:      	str	w13, [x12]
   b006c:      	cmp	x10, x11
   b0070:      	b.hs	0xb0098 <air1_opcal5_algorithm+0x74b4>
   b0074:      	ldr	x10, [sp, #0x268]
   b0078:      	cmp	x10, x20
   b007c:      	b.ls	0xb0098 <air1_opcal5_algorithm+0x74b4>
   b0080:      	ldr	x14, [sp, #0x388]
   b0084:      	adrp	x21, 0xe8000 <quick_sel_arr+0x1810>
   b0088:      	mov	w11, wzr
   b008c:      	mov	x10, x20
   b0090:      	add	x21, x21, #0xcd0
   b0094:      	b	0xb00fc <air1_opcal5_algorithm+0x7518>
   b0098:      	adrp	x21, 0xe8000 <quick_sel_arr+0x1810>
   b009c:      	mov	x10, xzr
   b00a0:      	add	x21, x21, #0xcd0
   b00a4:      	ldr	x14, [sp, #0x388]
   b00a8:      	add	x11, x20, x10
   b00ac:      	add	x12, x14, x10
   b00b0:      	add	x10, x10, #0x20
   b00b4:      	cmp	x10, #0x600
   b00b8:      	ldp	q0, q1, [x11]
   b00bc:      	stp	q0, q1, [x12]
   b00c0:      	b.ne	0xb00a8 <air1_opcal5_algorithm+0x74c4>
   b00c4:      	adrp	x11, 0xe8000 <quick_sel_arr+0x1810>
   b00c8:      	mov	w10, #0x61e             // =1566
   b00cc:      	add	x11, x11, #0xcac
   b00d0:      	add	x12, x9, #0x618
   b00d4:      	madd	x10, x3, x10, x5
   b00d8:      	ldr	d0, [x11]
   b00dc:      	str	d0, [x9, #0x600]
   b00e0:      	ldr	d0, [x11, #0x8]
   b00e4:      	str	d0, [x10, #0x608]
   b00e8:      	add	x10, x11, #0x18
   b00ec:      	ldr	d0, [x11, #0x10]
   b00f0:      	mov	w11, #0x618             // =1560
   b00f4:      	str	d0, [x9, #0x610]
   b00f8:      	mov	x9, x12
   b00fc:      	sub	w11, w11, #0x61e
   b0100:      	adrp	x24, 0xe8000 <quick_sel_arr+0x1810>
   b0104:      	ldrb	w12, [x10], #0x1
   b0108:      	adds	w11, w11, #0x1
   b010c:      	strb	w12, [x9], #0x1
   b0110:      	b.lo	0xb0104 <air1_opcal5_algorithm+0x7520>
   b0114:      	ldr	x10, [sp, #0x3c0]
   b0118:      	add	x14, x14, #0x61e
   b011c:      	ldrb	w9, [x24, #0x608]
   b0120:      	mov	x12, x8
   b0124:      	add	x10, x10, #0x4
   b0128:      	cmp	x8, x9
   b012c:      	str	x10, [sp, #0x3c0]
   b0130:      	b.lo	0xabe28 <air1_opcal5_algorithm+0x3244>
   b0134:      	b	0xa8d6c <air1_opcal5_algorithm+0x188>
   b0138:      	cmp	w8, #0x2
   b013c:      	b.eq	0xb017c <air1_opcal5_algorithm+0x7598>
   b0140:      	movi	d1, #0000000000000000
   b0144:      	cmp	w8, #0x1
   b0148:      	b.ne	0xaf514 <air1_opcal5_algorithm+0x6930>
   b014c:      	adrp	x8, 0xe9000 <g_algo+0x330>
   b0150:      	add	x8, x8, #0xa20
   b0154:      	ldp	d1, d2, [x8]
   b0158:      	fmul	d1, d0, d1
   b015c:      	fmul	d2, d0, d2
   b0160:      	fmul	d1, d0, d1
   b0164:      	fmul	d2, d0, d2
   b0168:      	fmadd	d1, d1, d0, d2
   b016c:      	ldp	d2, d3, [x8, #0x10]
   b0170:      	fmadd	d0, d2, d0, d1
   b0174:      	fadd	d1, d3, d0
   b0178:      	b	0xaf514 <air1_opcal5_algorithm+0x6930>
   b017c:      	adrp	x8, 0xe9000 <g_algo+0x330>
   b0180:      	add	x8, x8, #0xa40
   b0184:      	ldp	d1, d2, [x8]
   b0188:      	fmul	d1, d0, d1
   b018c:      	fcmp	d1, d2
   b0190:      	fcsel	d1, d2, d1, gt
   b0194:      	ldr	d2, [x8, #0x10]
   b0198:      	fnmsub	d1, d0, d2, d1
   b019c:      	b	0xaf514 <air1_opcal5_algorithm+0x6930>
   b01a0:      	ldr	x9, [sp, #0x3e8]
   b01a4:      	mov	w11, #0x1               // =1
   b01a8:      	b	0xaee74 <air1_opcal5_algorithm+0x6290>
   b01ac:      	ldrb	w12, [x1, #0xbe]
   b01b0:      	cmp	w12, #0x1
   b01b4:      	b.ne	0xb01e4 <air1_opcal5_algorithm+0x7600>
   b01b8:      	mov	x8, #0x4059000000000000 // =4636737291354636288
   b01bc:      	adrp	x27, 0xe8000 <quick_sel_arr+0x1810>
   b01c0:      	ldr	x23, [sp, #0x208]
   b01c4:      	add	x27, x27, #0x2f8
   b01c8:      	ldr	x5, [sp, #0x3a0]
   b01cc:      	fmov	d0, x8
   b01d0:      	ldr	x19, [sp, #0x390]
   b01d4:      	ldr	x16, [sp, #0x228]
   b01d8:      	ldr	x17, [sp, #0x220]
   b01dc:      	ldr	x0, [sp, #0x398]
   b01e0:      	b	0xb024c <air1_opcal5_algorithm+0x7668>
   b01e4:      	ldrb	w12, [x1, #0xbf]
   b01e8:      	cmp	w12, #0x1
   b01ec:      	b.eq	0xb0220 <air1_opcal5_algorithm+0x763c>
   b01f0:      	ldr	x12, [sp, #0x3d0]
   b01f4:      	ldrb	w12, [x12, #0xc0]
   b01f8:      	cmp	w12, #0x1
   b01fc:      	b.eq	0xb0220 <air1_opcal5_algorithm+0x763c>
   b0200:      	ldr	x12, [sp, #0x3d0]
   b0204:      	ldrb	w12, [x12, #0xc1]
   b0208:      	cmp	w12, #0x1
   b020c:      	b.eq	0xb0220 <air1_opcal5_algorithm+0x763c>
   b0210:      	ldr	x12, [sp, #0x3d0]
   b0214:      	ldrb	w12, [x12, #0xc2]
   b0218:      	cmp	w12, #0x1
   b021c:      	b.ne	0xb026c <air1_opcal5_algorithm+0x7688>
   b0220:      	mov	x8, #0x4059000000000000 // =4636737291354636288
   b0224:      	fmov	d0, x8
   b0228:      	ldr	x23, [sp, #0x208]
   b022c:      	adrp	x27, 0xe8000 <quick_sel_arr+0x1810>
   b0230:      	ldr	x5, [sp, #0x3a0]
   b0234:      	add	x27, x27, #0x2f8
   b0238:      	ldr	x19, [sp, #0x390]
   b023c:      	ldr	x16, [sp, #0x228]
   b0240:      	ldr	x17, [sp, #0x220]
   b0244:      	ldr	x0, [sp, #0x398]
   b0248:      	ldr	x1, [sp, #0x3d0]
   b024c:      	ldr	x2, [sp, #0x3c8]
   b0250:      	adrp	x15, 0xe9000 <g_algo+0x330>
   b0254:      	ldr	x3, [sp, #0x3b8]
   b0258:      	adrp	x4, 0xe8000 <quick_sel_arr+0x1810>
   b025c:      	adrp	x24, 0xe9000 <g_algo+0x330>
   b0260:      	add	x15, x15, #0x480
   b0264:      	add	x4, x4, #0x6a7
   b0268:      	b	0xaf650 <air1_opcal5_algorithm+0x6a6c>
   b026c:      	adrp	x12, 0xe9000 <g_algo+0x330>
   b0270:      	add	x12, x12, #0x6a8
   b0274:      	ldr	d3, [x12, #0x8]
   b0278:      	adrp	x12, 0xe9000 <g_algo+0x330>
   b027c:      	ldr	d1, [x12, #0x410]
   b0280:      	mov	x12, #0x4059000000000000 // =4636737291354636288
   b0284:      	fcmp	d1, d3
   b0288:      	fmov	d0, x12
   b028c:      	b.mi	0xb0228 <air1_opcal5_algorithm+0x7644>
   b0290:      	adrp	x12, 0xe9000 <g_algo+0x330>
   b0294:      	adrp	x27, 0xe8000 <quick_sel_arr+0x1810>
   b0298:      	add	x12, x12, #0x6a8
   b029c:      	adrp	x15, 0xe9000 <g_algo+0x330>
   b02a0:      	adrp	x4, 0xe8000 <quick_sel_arr+0x1810>
   b02a4:      	ldr	x23, [sp, #0x208]
   b02a8:      	ldr	x5, [sp, #0x3a0]
   b02ac:      	add	x27, x27, #0x2f8
   b02b0:      	ldr	d4, [x12]
   b02b4:      	adrp	x24, 0xe9000 <g_algo+0x330>
   b02b8:      	ldr	x19, [sp, #0x390]
   b02bc:      	add	x15, x15, #0x480
   b02c0:      	ldr	x16, [sp, #0x228]
   b02c4:      	add	x4, x4, #0x6a7
   b02c8:      	fcmp	d1, d4
   b02cc:      	ldr	x17, [sp, #0x220]
   b02d0:      	ldr	x0, [sp, #0x398]
   b02d4:      	ldr	x1, [sp, #0x3d0]
   b02d8:      	ldr	x2, [sp, #0x3c8]
   b02dc:      	ldr	x3, [sp, #0x3b8]
   b02e0:      	b.gt	0xaf650 <air1_opcal5_algorithm+0x6a6c>
   b02e4:      	adrp	x12, 0xe9000 <g_algo+0x330>
   b02e8:      	ldr	d2, [x12, #0x418]
   b02ec:      	mov	x12, #0x4059000000000000 // =4636737291354636288
   b02f0:      	fcmp	d2, d3
   b02f4:      	fmov	d0, x12
   b02f8:      	b.mi	0xb0228 <air1_opcal5_algorithm+0x7644>
   b02fc:      	adrp	x27, 0xe8000 <quick_sel_arr+0x1810>
   b0300:      	adrp	x15, 0xe9000 <g_algo+0x330>
   b0304:      	adrp	x4, 0xe8000 <quick_sel_arr+0x1810>
   b0308:      	fcmp	d2, d4
   b030c:      	ldr	x23, [sp, #0x208]
   b0310:      	add	x27, x27, #0x2f8
   b0314:      	ldr	x5, [sp, #0x3a0]
   b0318:      	adrp	x24, 0xe9000 <g_algo+0x330>
   b031c:      	ldr	x19, [sp, #0x390]
   b0320:      	add	x15, x15, #0x480
   b0324:      	ldr	x16, [sp, #0x228]
   b0328:      	add	x4, x4, #0x6a7
   b032c:      	ldr	x17, [sp, #0x220]
   b0330:      	ldr	x0, [sp, #0x398]
   b0334:      	ldr	x1, [sp, #0x3d0]
   b0338:      	ldr	x2, [sp, #0x3c8]
   b033c:      	ldr	x3, [sp, #0x3b8]
   b0340:      	b.gt	0xaf650 <air1_opcal5_algorithm+0x6a6c>
   b0344:      	adrp	x12, 0xe9000 <g_algo+0x330>
   b0348:      	ldr	d2, [x12, #0x420]
   b034c:      	mov	x12, #0x4059000000000000 // =4636737291354636288
   b0350:      	fcmp	d2, d3
   b0354:      	fmov	d0, x12
   b0358:      	b.mi	0xb0228 <air1_opcal5_algorithm+0x7644>
   b035c:      	adrp	x27, 0xe8000 <quick_sel_arr+0x1810>
   b0360:      	adrp	x15, 0xe9000 <g_algo+0x330>
   b0364:      	adrp	x4, 0xe8000 <quick_sel_arr+0x1810>
   b0368:      	fcmp	d2, d4
   b036c:      	ldr	x23, [sp, #0x208]
   b0370:      	add	x27, x27, #0x2f8
   b0374:      	ldr	x5, [sp, #0x3a0]
   b0378:      	adrp	x24, 0xe9000 <g_algo+0x330>
   b037c:      	ldr	x19, [sp, #0x390]
   b0380:      	add	x15, x15, #0x480
   b0384:      	ldr	x16, [sp, #0x228]
   b0388:      	add	x4, x4, #0x6a7
   b038c:      	ldr	x17, [sp, #0x220]
   b0390:      	ldr	x0, [sp, #0x398]
   b0394:      	ldr	x1, [sp, #0x3d0]
   b0398:      	ldr	x2, [sp, #0x3c8]
   b039c:      	ldr	x3, [sp, #0x3b8]
   b03a0:      	b.gt	0xaf650 <air1_opcal5_algorithm+0x6a6c>
   b03a4:      	adrp	x12, 0xe9000 <g_algo+0x330>
   b03a8:      	ldr	d2, [x12, #0x428]
   b03ac:      	mov	x12, #0x4059000000000000 // =4636737291354636288
   b03b0:      	fcmp	d2, d3
   b03b4:      	fmov	d0, x12
   b03b8:      	b.mi	0xb0228 <air1_opcal5_algorithm+0x7644>
   b03bc:      	adrp	x27, 0xe8000 <quick_sel_arr+0x1810>
   b03c0:      	adrp	x15, 0xe9000 <g_algo+0x330>
   b03c4:      	adrp	x4, 0xe8000 <quick_sel_arr+0x1810>
   b03c8:      	fcmp	d2, d4
   b03cc:      	ldr	x23, [sp, #0x208]
   b03d0:      	add	x27, x27, #0x2f8
   b03d4:      	ldr	x5, [sp, #0x3a0]
   b03d8:      	adrp	x24, 0xe9000 <g_algo+0x330>
   b03dc:      	ldr	x19, [sp, #0x390]
   b03e0:      	add	x15, x15, #0x480
   b03e4:      	ldr	x16, [sp, #0x228]
   b03e8:      	add	x4, x4, #0x6a7
   b03ec:      	ldr	x17, [sp, #0x220]
   b03f0:      	ldr	x0, [sp, #0x398]
   b03f4:      	ldr	x1, [sp, #0x3d0]
   b03f8:      	ldr	x2, [sp, #0x3c8]
   b03fc:      	ldr	x3, [sp, #0x3b8]
   b0400:      	b.gt	0xaf650 <air1_opcal5_algorithm+0x6a6c>
   b0404:      	adrp	x12, 0xe9000 <g_algo+0x330>
   b0408:      	ldr	d2, [x12, #0x430]
   b040c:      	mov	x12, #0x4059000000000000 // =4636737291354636288
   b0410:      	fcmp	d2, d3
   b0414:      	fmov	d0, x12
   b0418:      	b.mi	0xb0228 <air1_opcal5_algorithm+0x7644>
   b041c:      	adrp	x27, 0xe8000 <quick_sel_arr+0x1810>
   b0420:      	adrp	x15, 0xe9000 <g_algo+0x330>
   b0424:      	adrp	x4, 0xe8000 <quick_sel_arr+0x1810>
   b0428:      	fcmp	d2, d4
   b042c:      	ldr	x23, [sp, #0x208]
   b0430:      	add	x27, x27, #0x2f8
   b0434:      	ldr	x5, [sp, #0x3a0]
   b0438:      	adrp	x24, 0xe9000 <g_algo+0x330>
   b043c:      	ldr	x19, [sp, #0x390]
   b0440:      	add	x15, x15, #0x480
   b0444:      	ldr	x16, [sp, #0x228]
   b0448:      	add	x4, x4, #0x6a7
   b044c:      	ldr	x17, [sp, #0x220]
   b0450:      	ldr	x0, [sp, #0x398]
   b0454:      	ldr	x1, [sp, #0x3d0]
   b0458:      	ldr	x2, [sp, #0x3c8]
   b045c:      	ldr	x3, [sp, #0x3b8]
   b0460:      	b.gt	0xaf650 <air1_opcal5_algorithm+0x6a6c>
   b0464:      	adrp	x12, 0xe9000 <g_algo+0x330>
   b0468:      	ldr	d5, [x12, #0x438]
   b046c:      	mov	x12, #0x4059000000000000 // =4636737291354636288
   b0470:      	fcmp	d5, d3
   b0474:      	fmov	d0, x12
   b0478:      	b.mi	0xb0228 <air1_opcal5_algorithm+0x7644>
   b047c:      	adrp	x27, 0xe8000 <quick_sel_arr+0x1810>
   b0480:      	adrp	x15, 0xe9000 <g_algo+0x330>
   b0484:      	adrp	x4, 0xe8000 <quick_sel_arr+0x1810>
   b0488:      	fcmp	d5, d4
   b048c:      	ldr	x23, [sp, #0x208]
   b0490:      	add	x27, x27, #0x2f8
   b0494:      	ldr	x5, [sp, #0x3a0]
   b0498:      	adrp	x24, 0xe9000 <g_algo+0x330>
   b049c:      	ldr	x19, [sp, #0x390]
   b04a0:      	add	x15, x15, #0x480
   b04a4:      	ldr	x16, [sp, #0x228]
   b04a8:      	add	x4, x4, #0x6a7
   b04ac:      	ldr	x17, [sp, #0x220]
   b04b0:      	ldr	x0, [sp, #0x398]
   b04b4:      	ldr	x1, [sp, #0x3d0]
   b04b8:      	ldr	x2, [sp, #0x3c8]
   b04bc:      	ldr	x3, [sp, #0x3b8]
   b04c0:      	b.gt	0xaf650 <air1_opcal5_algorithm+0x6a6c>
   b04c4:      	adrp	x12, 0xe9000 <g_algo+0x330>
   b04c8:      	ldr	d6, [x12, #0x440]
   b04cc:      	mov	x12, #0x4059000000000000 // =4636737291354636288
   b04d0:      	fcmp	d6, d3
   b04d4:      	fmov	d0, x12
   b04d8:      	b.mi	0xb0228 <air1_opcal5_algorithm+0x7644>
   b04dc:      	adrp	x27, 0xe8000 <quick_sel_arr+0x1810>
   b04e0:      	adrp	x15, 0xe9000 <g_algo+0x330>
   b04e4:      	adrp	x4, 0xe8000 <quick_sel_arr+0x1810>
   b04e8:      	fcmp	d6, d4
   b04ec:      	ldr	x23, [sp, #0x208]
   b04f0:      	add	x27, x27, #0x2f8
   b04f4:      	ldr	x5, [sp, #0x3a0]
   b04f8:      	adrp	x24, 0xe9000 <g_algo+0x330>
   b04fc:      	ldr	x19, [sp, #0x390]
   b0500:      	add	x15, x15, #0x480
   b0504:      	ldr	x16, [sp, #0x228]
   b0508:      	add	x4, x4, #0x6a7
   b050c:      	ldr	x17, [sp, #0x220]
   b0510:      	ldr	x0, [sp, #0x398]
   b0514:      	ldr	x1, [sp, #0x3d0]
   b0518:      	ldr	x2, [sp, #0x3c8]
   b051c:      	ldr	x3, [sp, #0x3b8]
   b0520:      	b.gt	0xaf650 <air1_opcal5_algorithm+0x6a6c>
   b0524:      	mov	x12, #0x4059000000000000 // =4636737291354636288
   b0528:      	fcmp	d6, #0.0
   b052c:      	fmov	d0, x12
   b0530:      	b.le	0xb0228 <air1_opcal5_algorithm+0x7644>
   b0534:      	adrp	x27, 0xe8000 <quick_sel_arr+0x1810>
   b0538:      	adrp	x15, 0xe9000 <g_algo+0x330>
   b053c:      	adrp	x4, 0xe8000 <quick_sel_arr+0x1810>
   b0540:      	fcmp	d1, #0.0
   b0544:      	ldr	x23, [sp, #0x208]
   b0548:      	add	x27, x27, #0x2f8
   b054c:      	ldr	x5, [sp, #0x3a0]
   b0550:      	adrp	x24, 0xe9000 <g_algo+0x330>
   b0554:      	ldr	x19, [sp, #0x390]
   b0558:      	add	x15, x15, #0x480
   b055c:      	ldr	x16, [sp, #0x228]
   b0560:      	add	x4, x4, #0x6a7
   b0564:      	ldr	x17, [sp, #0x220]
   b0568:      	ldr	x0, [sp, #0x398]
   b056c:      	ldr	x1, [sp, #0x3d0]
   b0570:      	ldr	x2, [sp, #0x3c8]
   b0574:      	ldr	x3, [sp, #0x3b8]
   b0578:      	b.le	0xaf650 <air1_opcal5_algorithm+0x6a6c>
   b057c:      	scvtf	d0, x11
   b0580:      	mov	x11, #0x404e000000000000 // =4633641066610819072
   b0584:      	fsub	d1, d6, d1
   b0588:      	fcmp	d5, #0.0
   b058c:      	fmov	d3, x11
   b0590:      	adrp	x11, 0xe9000 <g_algo+0x330>
   b0594:      	fdiv	d0, d0, d3
   b0598:      	fdiv	d0, d1, d0
   b059c:      	str	d0, [x11, #0x458]
   b05a0:      	b.le	0xb0228 <air1_opcal5_algorithm+0x7644>
   b05a4:      	fcmp	d2, #0.0
   b05a8:      	b.le	0xb0228 <air1_opcal5_algorithm+0x7644>
   b05ac:      	sub	x9, x10, x9
   b05b0:      	fsub	d4, d6, d5
   b05b4:      	adrp	x27, 0xe8000 <quick_sel_arr+0x1810>
   b05b8:      	movi	d6, #0000000000000000
   b05bc:      	adrp	x15, 0xe9000 <g_algo+0x330>
   b05c0:      	adrp	x4, 0xe8000 <quick_sel_arr+0x1810>
   b05c4:      	scvtf	d1, x9
   b05c8:      	mov	x9, #0x404e000000000000 // =4633641066610819072
   b05cc:      	ldr	x23, [sp, #0x208]
   b05d0:      	add	x27, x27, #0x2f8
   b05d4:      	ldr	x5, [sp, #0x3a0]
   b05d8:      	adrp	x24, 0xe9000 <g_algo+0x330>
   b05dc:      	fmov	d3, x9
   b05e0:      	ldr	x19, [sp, #0x390]
   b05e4:      	ldr	x16, [sp, #0x228]
   b05e8:      	add	x15, x15, #0x480
   b05ec:      	ldr	x17, [sp, #0x220]
   b05f0:      	add	x4, x4, #0x6a7
   b05f4:      	fdiv	d1, d1, d3
   b05f8:      	ldr	x0, [sp, #0x398]
   b05fc:      	ldr	x1, [sp, #0x3d0]
   b0600:      	ldr	x2, [sp, #0x3c8]
   b0604:      	ldr	x3, [sp, #0x3b8]
   b0608:      	fdiv	d1, d4, d1
   b060c:      	fmov	d4, #1.00000000
   b0610:      	fcmp	d1, #0.0
   b0614:      	b.pl	0xb0620 <air1_opcal5_algorithm+0x7a3c>
   b0618:      	fcmp	d0, d4
   b061c:      	b.ge	0xb0678 <air1_opcal5_algorithm+0x7a94>
   b0620:      	fcmp	d1, #0.0
   b0624:      	b.le	0xb0228 <air1_opcal5_algorithm+0x7644>
   b0628:      	fmov	d4, #-1.00000000
   b062c:      	adrp	x27, 0xe8000 <quick_sel_arr+0x1810>
   b0630:      	movi	d6, #0000000000000000
   b0634:      	adrp	x15, 0xe9000 <g_algo+0x330>
   b0638:      	adrp	x4, 0xe8000 <quick_sel_arr+0x1810>
   b063c:      	ldr	x23, [sp, #0x208]
   b0640:      	fcmp	d0, d4
   b0644:      	ldr	x5, [sp, #0x3a0]
   b0648:      	ldr	x19, [sp, #0x390]
   b064c:      	add	x27, x27, #0x2f8
   b0650:      	ldr	x16, [sp, #0x228]
   b0654:      	adrp	x24, 0xe9000 <g_algo+0x330>
   b0658:      	ldr	x17, [sp, #0x220]
   b065c:      	add	x15, x15, #0x480
   b0660:      	ldr	x0, [sp, #0x398]
   b0664:      	add	x4, x4, #0x6a7
   b0668:      	ldr	x1, [sp, #0x3d0]
   b066c:      	ldr	x2, [sp, #0x3c8]
   b0670:      	ldr	x3, [sp, #0x3b8]
   b0674:      	b.hi	0xaf650 <air1_opcal5_algorithm+0x6a6c>
   b0678:      	scvtf	d0, x8
   b067c:      	fsub	d2, d5, d2
   b0680:      	adrp	x8, 0xe9000 <g_algo+0x330>
   b0684:      	fdiv	d0, d0, d3
   b0688:      	fdiv	d0, d2, d0
   b068c:      	fmul	d0, d0, d1
   b0690:      	fcmp	d0, #0.0
   b0694:      	fcsel	d0, d6, d1, mi
   b0698:      	str	d0, [x8, #0x458]
   b069c:      	b	0xaf650 <air1_opcal5_algorithm+0x6a6c>
   b06a0:      	mov	x8, #0x7ff8000000000000 // =9221120237041090560
   b06a4:      	fmov	d0, x8
   b06a8:      	b	0xae9a8 <air1_opcal5_algorithm+0x5dc4>
   b06ac:      	mov	x8, #0x7ff8000000000000 // =9221120237041090560
   b06b0:      	fmov	d2, x8
   b06b4:      	b	0xae9d4 <air1_opcal5_algorithm+0x5df0>
   b06b8:      	mov	x8, #0x7ff8000000000000 // =9221120237041090560
   b06bc:      	fmov	d0, x8
   b06c0:      	b	0xaea08 <air1_opcal5_algorithm+0x5e24>
   b06c4:      	mov	x8, #0x7ff8000000000000 // =9221120237041090560
   b06c8:      	fmov	d2, x8
   b06cc:      	b	0xaec10 <air1_opcal5_algorithm+0x602c>
   b06d0:      	mov	x8, #0x7ff8000000000000 // =9221120237041090560
   b06d4:      	fmov	d0, x8
   b06d8:      	b	0xaefb4 <air1_opcal5_algorithm+0x63d0>
   b06dc:      	adrp	x10, 0xe8000 <quick_sel_arr+0x1810>
   b06e0:      	ldur	q0, [x26, #0x6]
   b06e4:      	add	x10, x10, #0x618
   b06e8:      	mov	w8, #0x18               // =24
   b06ec:      	str	q0, [x10]
   b06f0:      	ldur	q0, [x26, #0x16]
   b06f4:      	str	q0, [x10, #0x10]
   b06f8:      	ldur	q0, [x26, #0x26]
   b06fc:      	str	q0, [x10, #0x20]
   b0700:      	adrp	x13, 0xe8000 <quick_sel_arr+0x1810>
   b0704:      	lsl	x8, x8, #1
   b0708:      	add	x10, x26, #0x6
   b070c:      	add	x13, x13, #0x610
   b0710:      	ldrh	w11, [x10, x8]
   b0714:      	add	x12, x13, x8
   b0718:      	add	x8, x8, #0x2
   b071c:      	cmp	x8, #0x3c
   b0720:      	strh	w11, [x12, #0x8]
   b0724:      	b.ne	0xb0710 <air1_opcal5_algorithm+0x7b2c>
   b0728:      	ldur	w8, [x22, #0x5d]
   b072c:      	strh	w9, [x22, #0x5a]
   b0730:      	ldrb	w10, [x22, #0x61]
   b0734:      	strh	w9, [x22, #0x1ce]
   b0738:      	adrp	x12, 0xe9000 <g_algo+0x330>
   b073c:      	str	w8, [x22, #0x5c]
   b0740:      	strb	w10, [x22, #0x60]
   b0744:      	ldrb	w11, [x13, #0x9a]
   b0748:      	ldur	q0, [x13, #0x28]
   b074c:      	ldrh	w9, [x13, #0x2]
   b0750:      	strb	w11, [x22, #0x61]
   b0754:      	ldr	w10, [x13, #0x4]
   b0758:      	stur	q0, [x20, #0x32]
   b075c:      	ldur	d0, [x26, #0x42]
   b0760:      	ldrh	w8, [x13]
   b0764:      	strh	w9, [x20, #0x2]
   b0768:      	ldur	q1, [x13, #0x18]
   b076c:      	str	w10, [x20, #0x4]
   b0770:      	ldur	q2, [x13, #0x8]
   b0774:      	stur	d0, [x20, #0xa]
   b0778:      	ldur	q0, [x13, #0x34]
   b077c:      	strh	w8, [x20]
   b0780:      	ldrb	w9, [x13, #0x9a]
   b0784:      	stur	q1, [x20, #0x22]
   b0788:      	ldrb	w12, [x12, #0xfb0]
   b078c:      	stur	q2, [x20, #0x12]
   b0790:      	ldurh	w10, [x13, #0x97]
   b0794:      	stur	q0, [x20, #0x3e]
   b0798:      	strb	w9, [x20, #0x8]
   b079c:      	tbz	w12, #0x0, 0xb07c0 <air1_opcal5_algorithm+0x7bdc>
   b07a0:      	adrp	x12, 0xe8000 <quick_sel_arr+0x1810>
   b07a4:      	add	w10, w10, #0x20
   b07a8:      	adrp	x9, 0xe8000 <quick_sel_arr+0x1810>
   b07ac:      	mov	w11, #0x1               // =1
   b07b0:      	add	x12, x12, #0x6a7
   b07b4:      	strb	w11, [x9, #0xa75]
   b07b8:      	strh	w10, [x12]
   b07bc:      	ldrb	w11, [x22, #0x61]
   b07c0:      	ldrb	w9, [x22, #0x5c]
   b07c4:      	ldrb	w12, [x22, #0x5d]
   b07c8:      	ldrb	w13, [x22, #0x5e]
   b07cc:      	cmp	w9, #0x8
   b07d0:      	cset	w9, eq
   b07d4:      	cmp	w11, #0x8
   b07d8:      	ldrb	w11, [x22, #0x5f]
   b07dc:      	cinc	w9, w9, eq
   b07e0:      	cmp	w12, #0x8
   b07e4:      	ldrb	w12, [x22, #0x60]
   b07e8:      	cinc	w9, w9, eq
   b07ec:      	cmp	w13, #0x8
   b07f0:      	cinc	w9, w9, eq
   b07f4:      	cmp	w11, #0x8
   b07f8:      	cinc	w9, w9, eq
   b07fc:      	cmp	w12, #0x8
   b0800:      	cinc	w9, w9, eq
   b0804:      	cmp	w9, #0x6
   b0808:      	b.ne	0xb0828 <air1_opcal5_algorithm+0x7c44>
   b080c:      	adrp	x12, 0xe8000 <quick_sel_arr+0x1810>
   b0810:      	add	w10, w10, #0x80
   b0814:      	adrp	x9, 0xe8000 <quick_sel_arr+0x1810>
   b0818:      	mov	w11, #0x1               // =1
   b081c:      	add	x12, x12, #0x6a7
   b0820:      	strb	w11, [x9, #0xa76]
   b0824:      	strh	w10, [x12]
   b0828:      	ldr	x15, [sp, #0x390]
   b082c:      	adrp	x9, 0xe8000 <quick_sel_arr+0x1810>
   b0830:      	adrp	x12, 0xe8000 <quick_sel_arr+0x1810>
   b0834:      	add	x9, x9, #0x611
   b0838:      	add	x14, x9, #0x9a
   b083c:      	mov	x11, x15
   b0840:      	add	x13, x15, #0x1
   b0844:      	cmp	x13, x14
   b0848:      	strh	w10, [x12, #0xa6e]
   b084c:      	strb	w8, [x11], #0x9b
   b0850:      	b.hs	0xb0868 <air1_opcal5_algorithm+0x7c84>
   b0854:      	cmp	x11, x9
   b0858:      	b.ls	0xb0868 <air1_opcal5_algorithm+0x7c84>
   b085c:      	mov	w8, #0x1                // =1
   b0860:      	mov	x10, x15
   b0864:      	b	0xb08bc <air1_opcal5_algorithm+0x7cd8>
   b0868:      	ldp	q0, q1, [x9]
   b086c:      	add	x10, x15, #0x98
   b0870:      	mov	w8, #0x99               // =153
   b0874:      	stur	q0, [x15, #0x1]
   b0878:      	stur	q1, [x15, #0x11]
   b087c:      	ldp	q0, q1, [x9, #0x20]
   b0880:      	stur	q0, [x15, #0x21]
   b0884:      	stur	q1, [x15, #0x31]
   b0888:      	ldp	q0, q1, [x9, #0x40]
   b088c:      	stur	q0, [x15, #0x41]
   b0890:      	stur	q1, [x15, #0x51]
   b0894:      	ldp	q0, q1, [x9, #0x60]
   b0898:      	stur	q0, [x15, #0x61]
   b089c:      	stur	q1, [x15, #0x71]
   b08a0:      	ldr	d0, [x9, #0x80]
   b08a4:      	stur	d0, [x15, #0x81]
   b08a8:      	ldr	d0, [x9, #0x88]
   b08ac:      	stur	d0, [x15, #0x89]
   b08b0:      	ldr	d0, [x9, #0x90]
   b08b4:      	add	x9, x9, #0x98
   b08b8:      	stur	d0, [x15, #0x91]
   b08bc:      	sub	w8, w8, #0x9b
   b08c0:      	add	x10, x10, #0x1
   b08c4:      	ldrb	w11, [x9], #0x1
   b08c8:      	adds	w8, w8, #0x1
   b08cc:      	strb	w11, [x10], #0x1
   b08d0:      	b.lo	0xb08c4 <air1_opcal5_algorithm+0x7ce0>
   b08d4:      	ldr	x11, [sp, #0x3a0]
   b08d8:      	add	x8, x20, #0x61e
   b08dc:      	cmp	x11, x8
   b08e0:      	b.hs	0xb08f8 <air1_opcal5_algorithm+0x7d14>
   b08e4:      	add	x8, x11, #0x61e
   b08e8:      	cmp	x8, x20
   b08ec:      	b.ls	0xb08f8 <air1_opcal5_algorithm+0x7d14>
   b08f0:      	mov	w8, wzr
   b08f4:      	b	0xb0948 <air1_opcal5_algorithm+0x7d64>
   b08f8:      	mov	x8, xzr
   b08fc:      	add	x9, x20, x8
   b0900:      	add	x10, x11, x8
   b0904:      	add	x8, x8, #0x20
   b0908:      	cmp	x8, #0x600
   b090c:      	ldp	q0, q1, [x9]
   b0910:      	stp	q0, q1, [x10]
   b0914:      	b.ne	0xb08fc <air1_opcal5_algorithm+0x7d18>
   b0918:      	adrp	x8, 0xe8000 <quick_sel_arr+0x1810>
   b091c:      	add	x9, x11, #0x618
   b0920:      	add	x8, x8, #0xcac
   b0924:      	add	x20, x8, #0x18
   b0928:      	ldr	d0, [x8]
   b092c:      	str	d0, [x11, #0x600]
   b0930:      	ldr	d0, [x8, #0x8]
   b0934:      	str	d0, [x11, #0x608]
   b0938:      	ldr	d0, [x8, #0x10]
   b093c:      	mov	w8, #0x618              // =1560
   b0940:      	str	d0, [x11, #0x610]
   b0944:      	mov	x11, x9
   b0948:      	sub	w8, w8, #0x61e
   b094c:      	adrp	x24, 0xe8000 <quick_sel_arr+0x1810>
   b0950:      	ldrb	w9, [x20], #0x1
   b0954:      	adds	w8, w8, #0x1
   b0958:      	strb	w9, [x11], #0x1
   b095c:      	b.lo	0xb0950 <air1_opcal5_algorithm+0x7d6c>
   b0960:      	b	0xa8d6c <air1_opcal5_algorithm+0x188>
   b0964:      	bl	0xbefe0 <__stack_chk_fail@plt>
