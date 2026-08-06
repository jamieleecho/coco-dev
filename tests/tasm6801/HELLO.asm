; Minimal MC-10 program: store 'A' at the top-left of the text screen.
scrn	.equ	$4000

	.org	$4400

start	ldaa	#$41
	staa	scrn
	rts

	.end	start
