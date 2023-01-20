    PROCESSOR PIC12F1840
    include <p12f1840.inc>
    __CONFIG _CONFIG1, _MCLRE_OFF  & _FOSC_INTOSC & _WDTE_OFF
    __CONFIG _CONFIG2, _LVP_OFF
    
    ORG 0 

    BANKSEL TRISA
    BCF TRISA, RA5
	
    BANKSEL PORTA

HERE
    BSF PORTA, RA5 ;LED ON
    CALL DELAY_SEC
    BCF PORTA, RA5 ;LED OFF
    CALL DELAY_SEC
    GOTO HERE

; We are using the default 500 kHz oscillator
; 1 instruction cycle = 4 oscillator cycles
; Therefore, for a 1s delay we need to execute 125000 instructions
; c1: cycles of the inner loop
; c2: cycles of the outer loop
; x1: number of inner loop iterations
; x2: number of outer loop iterations
;  e: extra cycles (from instructions outside the loops)
;
; We need 8-bit solutions for (c1 * x1 * x2) + (c2 * x2) + e = 125000 
; with e = 2(CALL) + 1(MOVLW) + 1(MOVWF) + 2(RETURN) - 1(skipped cycle) = 5
; One such solution is:
; 3 * 212 * 195 + 5 * 195 + 5 = 125000
DELAY_SEC        
    MOVLW d'195'
    MOVWF 0x20           	
OUTER_LOOP
    MOVLW d'212'
    MOVWF 0x21           
INNER_LOOP  
    DECFSZ 0x21, F       
    GOTO INNER_LOOP        
    NOP		    ; Compensates for the DECFSZ skip
    DECFSZ 0x20, F         
    GOTO OUTER_LOOP ; -1 cycle when skipped
    RETURN

    END


