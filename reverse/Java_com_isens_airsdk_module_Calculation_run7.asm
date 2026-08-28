
libCALCULATION.so:	file format elf64-littleaarch64

Disassembly of section .text:

000000000003d574 <Java_com_isens_airsdk_module_Calculation_run7>:
   3d574:      	stp	x29, x30, [sp, #-0x60]!
   3d578:      	stp	x28, x27, [sp, #0x10]
   3d57c:      	mov	x29, sp
   3d580:      	stp	x26, x25, [sp, #0x20]
   3d584:      	stp	x24, x23, [sp, #0x30]
   3d588:      	stp	x22, x21, [sp, #0x40]
   3d58c:      	stp	x20, x19, [sp, #0x50]
   3d590:      	sub	sp, sp, #0x2d, lsl #12  // =0x2d000
   3d594:      	sub	sp, sp, #0xb30
   3d598:      	mrs	x8, TPIDR_EL0
   3d59c:      	mov	x19, x0
   3d5a0:      	str	x8, [sp, #0x8]
   3d5a4:      	add	x0, sp, #0x28, lsl #12  // =0x28000
   3d5a8:      	mov	x22, x2
   3d5ac:      	ldr	x8, [x8, #0x28]
   3d5b0:      	add	x0, x0, #0xd30
   3d5b4:      	mov	w1, wzr
   3d5b8:      	mov	w2, #0x2ef              // =751
   3d5bc:      	add	x24, sp, #0x28, lsl #12 // =0x28000
   3d5c0:      	add	x24, x24, #0xd30
   3d5c4:      	stur	x8, [x29, #-0x10]
   3d5c8:      	bl	0xbefc0 <memset@plt>
   3d5cc:      	mov	x20, #0x3a07            // =14855
   3d5d0:      	add	x25, sp, #0x29, lsl #12 // =0x29000
   3d5d4:      	movk	x20, #0xa06d, lsl #16
   3d5d8:      	mov	w23, wzr
   3d5dc:      	movk	x20, #0x6d3, lsl #32
   3d5e0:      	mov	w26, wzr
   3d5e4:      	mov	w28, wzr
   3d5e8:      	movk	x20, #0x6d3a, lsl #48
   3d5ec:      	mov	w27, #0x4b              // =75
   3d5f0:      	add	x25, x25, #0x20
   3d5f4:      	b	0x3d610 <Java_com_isens_airsdk_module_Calculation_run7+0x9c>
   3d5f8:      	strb	w28, [x24, #0x2bc]
   3d5fc:      	cmp	w23, #0x3
   3d600:      	b.eq	0x3d77c <Java_com_isens_airsdk_module_Calculation_run7+0x208>
   3d604:      	add	w23, w23, #0x1
   3d608:      	cmp	w23, #0x4
   3d60c:      	b.eq	0x3d798 <Java_com_isens_airsdk_module_Calculation_run7+0x224>
   3d610:      	ldr	x8, [x19]
   3d614:      	mov	x0, x19
   3d618:      	mov	x1, x22
   3d61c:      	mov	w2, w23
   3d620:      	ldr	x8, [x8, #0x568]
   3d624:      	blr	x8
   3d628:      	mov	x21, x0
   3d62c:      	and	w8, w23, #0xff
   3d630:      	cmp	w8, #0x1
   3d634:      	b.eq	0x3d65c <Java_com_isens_airsdk_module_Calculation_run7+0xe8>
   3d638:      	cbnz	w8, 0x3d6dc <Java_com_isens_airsdk_module_Calculation_run7+0x168>
   3d63c:      	ldr	x8, [x19]
   3d640:      	mov	x0, x19
   3d644:      	mov	x1, x21
   3d648:      	mov	x2, xzr
   3d64c:      	ldr	x8, [x8, #0x5c0]
   3d650:      	blr	x8
   3d654:      	str	x0, [sp, #0x20]
   3d658:      	b	0x3d604 <Java_com_isens_airsdk_module_Calculation_run7+0x90>
   3d65c:      	ldr	x8, [x19]
   3d660:      	mov	x0, x19
   3d664:      	mov	x1, x21
   3d668:      	ldr	x8, [x8, #0x558]
   3d66c:      	blr	x8
   3d670:      	ldr	x8, [x19]
   3d674:      	sxtw	x9, w0
   3d678:      	mov	x0, x19
   3d67c:      	mov	x1, x21
   3d680:      	mov	x2, xzr
   3d684:      	umulh	x9, x9, x20
   3d688:      	ldr	x8, [x8, #0x5c0]
   3d68c:      	lsr	x26, x9, #5
   3d690:      	blr	x8
   3d694:      	cmp	w26, #0x1
   3d698:      	b.lt	0x3d6dc <Java_com_isens_airsdk_module_Calculation_run7+0x168>
   3d69c:      	mov	w8, wzr
   3d6a0:      	and	x9, x8, #0xffff
   3d6a4:      	add	w8, w8, #0x1
   3d6a8:      	mul	x9, x9, x27
   3d6ac:      	cmp	w26, w8, uxth
   3d6b0:      	add	x10, x0, x9
   3d6b4:      	add	x9, x25, x9
   3d6b8:      	ldr	q0, [x10]
   3d6bc:      	str	q0, [x9]
   3d6c0:      	ldp	q2, q1, [x10, #0x20]
   3d6c4:      	ldur	q0, [x10, #0x3b]
   3d6c8:      	ldr	q3, [x10, #0x10]
   3d6cc:      	stur	q0, [x9, #0x3b]
   3d6d0:      	stp	q2, q1, [x9, #0x20]
   3d6d4:      	str	q3, [x9, #0x10]
   3d6d8:      	b.gt	0x3d6a0 <Java_com_isens_airsdk_module_Calculation_run7+0x12c>
   3d6dc:      	cmp	w23, #0x2
   3d6e0:      	b.ne	0x3d5fc <Java_com_isens_airsdk_module_Calculation_run7+0x88>
   3d6e4:      	ldr	x8, [x19]
   3d6e8:      	mov	x0, x19
   3d6ec:      	mov	x1, x21
   3d6f0:      	ldr	x8, [x8, #0x558]
   3d6f4:      	blr	x8
   3d6f8:      	ldr	x8, [x19]
   3d6fc:      	mov	x10, #-0x7777777777777778 // =-8608480567731124088
   3d700:      	sxtw	x9, w0
   3d704:      	movk	x10, #0x8889
   3d708:      	mov	x0, x19
   3d70c:      	mov	x1, x21
   3d710:      	ldr	x8, [x8, #0x5c0]
   3d714:      	mov	x2, xzr
   3d718:      	umulh	x9, x9, x10
   3d71c:      	lsr	x28, x9, #3
   3d720:      	blr	x8
   3d724:      	cmp	w28, #0x1
   3d728:      	b.lt	0x3d5f8 <Java_com_isens_airsdk_module_Calculation_run7+0x84>
   3d72c:      	mov	w8, wzr
   3d730:      	and	x9, x8, #0xff
   3d734:      	add	x12, x24, w8, uxtb #3
   3d738:      	lsl	x10, x9, #4
   3d73c:      	add	x14, x24, w8, uxtb #2
   3d740:      	sub	x10, x10, x9
   3d744:      	add	w8, w8, #0x1
   3d748:      	add	x10, x0, x10
   3d74c:      	cmp	w28, w8, uxtb
   3d750:      	ldrh	w11, [x10]
   3d754:      	ldur	d0, [x10, #0x2]
   3d758:      	ldur	w13, [x10, #0xa]
   3d75c:      	ldrb	w10, [x10, #0xe]
   3d760:      	strh	w11, [x24, x9, lsl #1]
   3d764:      	add	x9, x24, x9
   3d768:      	stur	d0, [x12, #0x64]
   3d76c:      	str	w13, [x14, #0x1f4]
   3d770:      	strb	w10, [x9, #0x2bd]
   3d774:      	b.gt	0x3d730 <Java_com_isens_airsdk_module_Calculation_run7+0x1bc>
   3d778:      	b	0x3d5f8 <Java_com_isens_airsdk_module_Calculation_run7+0x84>
   3d77c:      	ldr	x8, [x19]
   3d780:      	mov	x0, x19
   3d784:      	mov	x1, x21
   3d788:      	mov	x2, xzr
   3d78c:      	ldr	x8, [x8, #0x5c0]
   3d790:      	blr	x8
   3d794:      	mov	x21, x0
   3d798:      	add	x0, sp, #0x2, lsl #12   // =0x2000
   3d79c:      	mov	w2, #0x6c00             // =27648
   3d7a0:      	add	x0, x0, #0x130
   3d7a4:      	mov	w1, wzr
   3d7a8:      	movk	w2, #0x2, lsl #16
   3d7ac:      	add	x22, sp, #0x2, lsl #12  // =0x2000
   3d7b0:      	add	x22, x22, #0x130
   3d7b4:      	bl	0xbefc0 <memset@plt>
   3d7b8:      	add	x0, sp, #0x1, lsl #12   // =0x1000
   3d7bc:      	mov	w1, wzr
   3d7c0:      	add	x0, x0, #0xb10
   3d7c4:      	mov	w2, #0x61e              // =1566
   3d7c8:      	bl	0xbefc0 <memset@plt>
   3d7cc:      	cmp	w26, #0x1
   3d7d0:      	b.lt	0x3d888 <Java_com_isens_airsdk_module_Calculation_run7+0x314>
   3d7d4:      	add	x27, sp, #0x29, lsl #12 // =0x29000
   3d7d8:      	mov	w23, wzr
   3d7dc:      	mov	w24, wzr
   3d7e0:      	mov	w25, #0x4b              // =75
   3d7e4:      	add	x27, x27, #0x20
   3d7e8:      	mov	w20, #0x9b              // =155
   3d7ec:      	b	0x3d7fc <Java_com_isens_airsdk_module_Calculation_run7+0x288>
   3d7f0:      	add	w23, w23, #0x1
   3d7f4:      	cmp	w26, w23, uxth
   3d7f8:      	b.le	0x3d88c <Java_com_isens_airsdk_module_Calculation_run7+0x318>
   3d7fc:      	and	x8, x23, #0xffff
   3d800:      	add	x2, sp, #0x28, lsl #12  // =0x28000
   3d804:      	add	x4, sp, #0x1, lsl #12   // =0x1000
   3d808:      	add	x2, x2, #0xd30
   3d80c:      	madd	x1, x8, x25, x27
   3d810:      	add	x4, x4, #0x8a0
   3d814:      	add	x5, sp, #0x28
   3d818:      	ldr	x0, [sp, #0x20]
   3d81c:      	mov	x3, x21
   3d820:      	bl	0xbf040 <air1_opcal5_algorithm@plt>
   3d824:      	tst	w0, #0xff
   3d828:      	b.eq	0x3d7f0 <Java_com_isens_airsdk_module_Calculation_run7+0x27c>
   3d82c:      	add	x9, sp, #0x1, lsl #12   // =0x1000
   3d830:      	and	x8, x0, #0xff
   3d834:      	add	x9, x9, #0x8a0
   3d838:      	and	x10, x24, #0xffff
   3d83c:      	ldr	q2, [x9, #0x80]
   3d840:      	ldp	q0, q1, [x9, #0x60]
   3d844:      	nop
   3d848:      	madd	x10, x10, x20, x22
   3d84c:      	add	w24, w24, #0x1
   3d850:      	subs	x8, x8, #0x1
   3d854:      	str	q2, [x10, #0x80]
   3d858:      	stp	q0, q1, [x10, #0x60]
   3d85c:      	ldur	q3, [x9, #0x8b]
   3d860:      	ldp	q0, q1, [x9, #0x20]
   3d864:      	stur	q3, [x10, #0x8b]
   3d868:      	ldp	q2, q3, [x9, #0x40]
   3d86c:      	stp	q0, q1, [x10, #0x20]
   3d870:      	ldp	q0, q1, [x9]
   3d874:      	add	x9, x9, #0x9b
   3d878:      	stp	q2, q3, [x10, #0x40]
   3d87c:      	stp	q0, q1, [x10]
   3d880:      	b.ne	0x3d838 <Java_com_isens_airsdk_module_Calculation_run7+0x2c4>
   3d884:      	b	0x3d7f0 <Java_com_isens_airsdk_module_Calculation_run7+0x27c>
   3d888:      	mov	w24, wzr
   3d88c:      	ldr	x8, [x19]
   3d890:      	mov	x0, x19
   3d894:      	mov	w1, #0x1                // =1
   3d898:      	ldr	x8, [x8, #0x580]
   3d89c:      	blr	x8
   3d8a0:      	ldr	x8, [x19]
   3d8a4:      	mov	x1, x0
   3d8a8:      	mov	x0, x19
   3d8ac:      	ldr	x20, [x8, #0x560]
   3d8b0:      	ldr	x8, [x8, #0xf8]
   3d8b4:      	blr	x8
   3d8b8:      	mov	x2, x0
   3d8bc:      	mov	x0, x19
   3d8c0:      	mov	w1, #0x6                // =6
   3d8c4:      	mov	x3, xzr
   3d8c8:      	blr	x20
   3d8cc:      	and	w8, w24, #0xffff
   3d8d0:      	mov	w9, #0x9b               // =155
   3d8d4:      	mov	w10, #0x4b              // =75
   3d8d8:      	add	x24, sp, #0x28, lsl #12 // =0x28000
   3d8dc:      	mul	w11, w8, w9
   3d8e0:      	lsl	w8, w28, #4
   3d8e4:      	sub	w8, w8, w28
   3d8e8:      	mov	x22, x0
   3d8ec:      	mov	w23, wzr
   3d8f0:      	add	x24, x24, #0xd30
   3d8f4:      	add	x25, sp, #0x28
   3d8f8:      	stp	w11, w8, [sp, #0x18]
   3d8fc:      	mul	w8, w26, w10
   3d900:      	adrp	x26, 0x1000 <strcasecmp+0x1000>
   3d904:      	add	x26, x26, #0x213
   3d908:      	str	w8, [sp, #0x14]
   3d90c:      	b	0x3d978 <Java_com_isens_airsdk_module_Calculation_run7+0x404>
   3d910:      	ldr	x8, [x19]
   3d914:      	mov	x0, x19
   3d918:      	ldr	w20, [sp, #0x18]
   3d91c:      	ldr	x8, [x8, #0x580]
   3d920:      	mov	w1, w20
   3d924:      	blr	x8
   3d928:      	ldr	x8, [x19]
   3d92c:      	add	x4, sp, #0x2, lsl #12   // =0x2000
   3d930:      	mov	x27, x0
   3d934:      	add	x4, x4, #0x130
   3d938:      	ldr	x8, [x8, #0x680]
   3d93c:      	mov	x0, x19
   3d940:      	mov	x1, x27
   3d944:      	mov	w2, wzr
   3d948:      	mov	w3, w20
   3d94c:      	blr	x8
   3d950:      	ldr	x8, [x19]
   3d954:      	mov	x0, x19
   3d958:      	mov	x1, x22
   3d95c:      	mov	w2, w23
   3d960:      	mov	x3, x27
   3d964:      	ldr	x8, [x8, #0x570]
   3d968:      	blr	x8
   3d96c:      	add	w23, w23, #0x1
   3d970:      	cmp	w23, #0x6
   3d974:      	b.eq	0x3daec <Java_com_isens_airsdk_module_Calculation_run7+0x578>
   3d978:      	and	w8, w23, #0xff
   3d97c:      	cmp	w8, #0x4
   3d980:      	b.hi	0x3dab0 <Java_com_isens_airsdk_module_Calculation_run7+0x53c>
   3d984:      	and	x8, x23, #0xff
   3d988:      	adr	x9, 0x3d910 <Java_com_isens_airsdk_module_Calculation_run7+0x39c>
   3d98c:      	ldrb	w10, [x26, x8]
   3d990:      	add	x9, x9, x10, lsl #2
   3d994:      	br	x9
   3d998:      	ldr	x8, [x19]
   3d99c:      	mov	x0, x19
   3d9a0:      	mov	w1, #0x1be              // =446
   3d9a4:      	ldr	x8, [x8, #0x580]
   3d9a8:      	blr	x8
   3d9ac:      	ldr	x8, [x19]
   3d9b0:      	mov	x27, x0
   3d9b4:      	ldr	x4, [sp, #0x20]
   3d9b8:      	mov	x0, x19
   3d9bc:      	mov	x1, x27
   3d9c0:      	mov	w2, wzr
   3d9c4:      	ldr	x8, [x8, #0x680]
   3d9c8:      	mov	w3, #0x1be              // =446
   3d9cc:      	b	0x3d94c <Java_com_isens_airsdk_module_Calculation_run7+0x3d8>
   3d9d0:      	cmp	w28, #0x1
   3d9d4:      	b.lt	0x3da24 <Java_com_isens_airsdk_module_Calculation_run7+0x4b0>
   3d9d8:      	mov	w8, wzr
   3d9dc:      	and	x9, x8, #0xff
   3d9e0:      	add	x10, x24, w8, uxtb #3
   3d9e4:      	add	x11, x24, w8, uxtb #2
   3d9e8:      	lsl	x12, x9, #4
   3d9ec:      	sub	x12, x12, x9
   3d9f0:      	add	w8, w8, #0x1
   3d9f4:      	add	x12, x25, x12
   3d9f8:      	ldur	d0, [x10, #0x64]
   3d9fc:      	ldr	w10, [x11, #0x1f4]
   3da00:      	add	x11, x24, x9
   3da04:      	ldrh	w9, [x24, x9, lsl #1]
   3da08:      	cmp	w28, w8, uxtb
   3da0c:      	stur	d0, [x12, #0x2]
   3da10:      	stur	w10, [x12, #0xa]
   3da14:      	ldrb	w10, [x11, #0x2bd]
   3da18:      	strh	w9, [x12]
   3da1c:      	strb	w10, [x12, #0xe]
   3da20:      	b.gt	0x3d9dc <Java_com_isens_airsdk_module_Calculation_run7+0x468>
   3da24:      	ldr	x8, [x19]
   3da28:      	mov	x0, x19
   3da2c:      	ldr	w20, [sp, #0x1c]
   3da30:      	ldr	x8, [x8, #0x580]
   3da34:      	mov	w1, w20
   3da38:      	blr	x8
   3da3c:      	ldr	x8, [x19]
   3da40:      	mov	x27, x0
   3da44:      	add	x4, sp, #0x28
   3da48:      	b	0x3d938 <Java_com_isens_airsdk_module_Calculation_run7+0x3c4>
   3da4c:      	ldr	x8, [x19]
   3da50:      	mov	x0, x19
   3da54:      	mov	w1, #0x93d8             // =37848
   3da58:      	ldr	x8, [x8, #0x580]
   3da5c:      	blr	x8
   3da60:      	ldr	x8, [x19]
   3da64:      	mov	x27, x0
   3da68:      	mov	x0, x19
   3da6c:      	mov	x1, x27
   3da70:      	mov	w2, wzr
   3da74:      	mov	w3, #0x93d8             // =37848
   3da78:      	ldr	x8, [x8, #0x680]
   3da7c:      	mov	x4, x21
   3da80:      	b	0x3d94c <Java_com_isens_airsdk_module_Calculation_run7+0x3d8>
   3da84:      	ldr	x8, [x19]
   3da88:      	mov	x0, x19
   3da8c:      	ldr	w20, [sp, #0x14]
   3da90:      	ldr	x8, [x8, #0x580]
   3da94:      	mov	w1, w20
   3da98:      	blr	x8
   3da9c:      	ldr	x8, [x19]
   3daa0:      	add	x4, sp, #0x29, lsl #12  // =0x29000
   3daa4:      	mov	x27, x0
   3daa8:      	add	x4, x4, #0x20
   3daac:      	b	0x3d938 <Java_com_isens_airsdk_module_Calculation_run7+0x3c4>
   3dab0:      	ldr	x8, [x19]
   3dab4:      	mov	x0, x19
   3dab8:      	mov	w1, #0x61e              // =1566
   3dabc:      	ldr	x8, [x8, #0x580]
   3dac0:      	blr	x8
   3dac4:      	ldr	x8, [x19]
   3dac8:      	mov	x27, x0
   3dacc:      	add	x4, sp, #0x1, lsl #12   // =0x1000
   3dad0:      	mov	x0, x19
   3dad4:      	add	x4, x4, #0xb10
   3dad8:      	mov	x1, x27
   3dadc:      	ldr	x8, [x8, #0x680]
   3dae0:      	mov	w2, wzr
   3dae4:      	mov	w3, #0x61e              // =1566
   3dae8:      	b	0x3d94c <Java_com_isens_airsdk_module_Calculation_run7+0x3d8>
   3daec:      	ldr	x8, [sp, #0x8]
   3daf0:      	ldr	x8, [x8, #0x28]
   3daf4:      	ldur	x9, [x29, #-0x10]
   3daf8:      	cmp	x8, x9
   3dafc:      	b.ne	0x3db28 <Java_com_isens_airsdk_module_Calculation_run7+0x5b4>
   3db00:      	mov	x0, x22
   3db04:      	add	sp, sp, #0x2d, lsl #12  // =0x2d000
   3db08:      	add	sp, sp, #0xb30
   3db0c:      	ldp	x20, x19, [sp, #0x50]
   3db10:      	ldp	x22, x21, [sp, #0x40]
   3db14:      	ldp	x24, x23, [sp, #0x30]
   3db18:      	ldp	x26, x25, [sp, #0x20]
   3db1c:      	ldp	x28, x27, [sp, #0x10]
   3db20:      	ldp	x29, x30, [sp], #0x60
   3db24:      	ret
   3db28:      	bl	0xbefe0 <__stack_chk_fail@plt>
