//KC03E99A JOB ,'Sanoj Oad',MSGCLASS=H
//JSTEP01  EXEC PGM=ASSIST
//STEPLIB  DD DSN=KC00NIU.ASSIST.LOADLIB,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
******************************************************************
* CSCI 360-2                PROJECT 1                SPRING 2023 *
*                                                                *
* NAME: SANOJ OAD & Mohamed Sharif                               *
* DATE: 02/27/2023                                               *
*                                                                *
* PROJECT 1                                                      *
*                                                                *
******************************************************************
NEXTROW  EQU   48            ROW OFFSET FOR CUSTOMER TABLE
TNEXTROW EQU   28            ROW OFFSET FOR TRANSACTION TABLE
*
* TABLE 1
*==================================================================
* CUSTOMER TABLE FROM INPUT FIELD ADDRESSING
$IBUFF   DSECT
$IACCID  DS    CL8           ACCOUNT ID
         DS    C
$INAME   DS    CL20          NAME OF CUSTOMER
         DS    C
$IEYINC  DS    CL8           ESTIMATED YEARLY INCOME
         DS    C
$ICLMT   DS    CL6           CREDIT LIMIT
         DS    C
$ICAPR   DS    CL4           CURRENT APR
         DS    C
$IEQSCR  DS    CL3           EQUIFAX SCORE
         DS    C
$ITUSCR  DS    CL3           TRANSUNION SCORE
         DS    C
$IEPSCR  DS    CL3           EXPERIAN SCORE
*
*==================================================================
* CUSTOMER TABLE
$CTABL   DSECT
$ACCID   DS    F             ACCOUNT ID
$NAME    DS    CL20          NAME OF CUSTOMER
$EYINC   DS    F             ESTIMATED YEARLY INCOME
$CLMT    DS    F             CREDIT LIMIT
$CAPR    DS    F             CURRENT APR
$EQSCR   DS    F             EQUIFAX SCORE
$TUSCR   DS    F             TRANSUNION SCORE
$EPSCR   DS    F             EXPERIAN SCORE
*==================================================================
* TABLE 2
*==================================================================
* TRANSACTION TABLE FROM INPUT FIELD ADDRESSING
$IBUF2   DSECT
$ITACID  DS    CL8           ACCOUNT ID
         DS    C
$IMNTH   DS    CL2           MONTH OF TRANSACTION
         DS    C
$IDAY    DS    CL2           DAY OF TRANSACTION
         DS    C
$ITTYPE  DS    CL9           TRANSACTION TYPE
         DS    C
$IAMOUNT DS    CL6           AMOUNT OF TRANSACTION
*
*==================================================================
* TRANSACTION TABLE
$TTABL   DSECT
$TACID   DS    F             ACCOUNT ID
$MNTH    DS    F             MONTH OF TRANSACTION
$DAY     DS    F             DAY OF TRANSACTION
$TTYPE   DS    CL9           TRANSACTION TYPE
$AMOUNT  DS    F             AMOUNT OF TRANSACTION
*==================================================================
*
MAIN     CSECT
         USING MAIN,15       ESTABLISH ADDRESSABILITY ON REG 15
*
         LA    2,CUSTABL     R2 := HEAD OF FIRST ROW
         LA    3,BUFFER      R3 := HEAD OF INPUT BUFFER
*
         XREAD BUFFER,80     PRIMING READ
READLOOP BNZ   ENDREAD       BRANCH OUT ON EOF
*
         USING $CTABL,2      USE R2 AS BASE FOR $CTABL DSECT LABELS
         USING $IBUFF,3      USE R3 AS BASE FOR $IBUFF DSECT LABELS
* ------ LOADING CUSTOMER TABLE ---------------------------
         CLI   $IACCID,C'*'  CHECKS IF FIRST TABLE IS AT THE END ('*')
         BZ    ENDREAD       IF TABLE IS AT THE END RETURN TO ENDREAD
         XDECI 4,$IACCID     GET ACCID FROM RECORD
         ST    4,$ACCID      STORE IN TABLE ACCID POS
         MVC   $NAME(20),$INAME   COPIES NAME FROM INAME FIELD
         XDECI 4,$IEYINC     GET EST. YEARLY INCOME FROM RECORD
         ST    4,$EYINC      STORE IN TABLE EYINC POS
         XDECI 4,$ICLMT      GET CREDIT LMT FROM RECORD
         ST    4,$CLMT       STORE IN TABLE CLMT POS
         XDECI 4,$ICAPR      GET CUR. APR FROM RECORD
         ST    4,$CAPR       STORE IN TABLE CAPR POS
         XDECI 4,$IEQSCR     GET EQ SCORE FROM RECORD
         ST    4,$EQSCR      STROE IN TABLE EQSCR POS
         XDECI 4,$ITUSCR     GET TU SCORE FROM RECORD
         ST    4,$TUSCR      STORE IN TABLE TUSCR POS
         XDECI 4,$IEPSCR     GET EP SCORE FROM RECORD
         ST    4,$EPSCR      STORE IN TABLE EPSCR POS
* ---------------------------------------------------------
         DROP  3             DROP THE RECORD ONCE DONE
*
         LA    2,NEXTROW(,2) POINT R2 TO NEXT ROW IN TABLE
         XREAD BUFFER,80     GET NEXT RECORD
         B     READLOOP      BRANCH TO READLOOP
ENDREAD  DS    0H
*         XDUMP CUSTABL,165  CHECKPOINT FOR TABLE 1 CONTENTS LOADING
*
* ------ LOADING TRANSACTION TABLE ------------------------
         LA    2,TRTABL      R2 := HEAD OF FIRST ROW
         LA    3,BUFFER      R3 := HEAD OF INPUT BUFFER
         XREAD BUFFER,80     PRIMING READ
*
RTLOOP   BNZ   TDREAD        BRANCH OUT ON EOF
         USING $TTABL,2      USE R2 AS BASE FOR $CTABL DSECT LABELS
         USING $IBUF2,3      USE R3 AS BASE FOR $IBUFF DSECT LABELS
* ---------------------------------------------------------
         XDECI 4,$ITACID     GET ACCOUNT ID FROM RECORD
         ST    4,$TACID      STORE IN TABLE TACID POS
         XDECI 4,$IMNTH      GET EST. YEARLY INCOME FROM RECORD
         ST    4,$MNTH       STORE IN TABLE EYINC POS
         XDECI 4,$IDAY       GET CREDIT LMT FROM RECORD
         ST    4,$DAY        STORE IN TABLE CLMT POS
         MVC   $TTYPE(9),$ITTYPE   COPIES NAME FROM INAME FIELD
         XDECI 4,$IAMOUNT    GET CUR. APR FROM RECORD
         ST    4,$AMOUNT     STORE IN TABLE CAPR POS
* ---------------------------------------------------------
         DROP  3             DROP THE RECORD ONCE DONE
*
         LA    2,TNEXTROW(,2) POINT R2 TO NEXT ROW IN TABLE
         XREAD BUFFER,80     GET NEXT RECORD
         B     RTLOOP        BRANCH TO READLOOP
TDREAD   DS    0H
*         XDUMP TRTABL,540    CHECKPOINT FOR TABLE 2 CONTENTS LOADING
*
         BR    14            RETURN TO CALLER (OS)
*
         LTORG               LITERAL ORGANIZATION
*
CUSTABL  DS    3CL55         TABL FOR THE CUSTOMER TABLE
TABLEND  DS    0H            END OF CUSTOMER TABL
*
BUFFER   DS    CL80          INPUT BUFFER
         DS    0F
*
TRTABL   DS    20CL27        TABL FOR THE TRANSACTION TABLE
TRTEND   DS    0H            END OF TRANSACTION TABL
*
         END   MAIN
/*
//*
//* IN-STREAM PROGRAM DATA
//FT05F001 DD *
53081599 Branden Mursell      04900000 400000 1364 805 811 789
46068220 Lena Copestake       10400000 300000 1446 595 587 599
58393056 Jeremy Mollett       11200000 100000 2103 640 649 627
*
53081599 11 16 TRANSFER  047500
46068220 05 09 LIVING    098400
46068220 03 08 TRANSFER  022600
46068220 11 25 TRANSFER  029700
53081599 03 18 MISC      069900
46068220 08 31 LIVING    057100
53081599 01 26 LIVING    079300
46068220 11 04 ENTERTAIN 036600
46068220 09 16 MISC      044200
58393056 06 06 TRANSFER  093900
58393056 07 18 TRANSFER  042500
53081599 05 25 ENTERTAIN 034300
46068220 09 07 ENTERTAIN 033100
53081599 07 18 PAYMENT   011500
53081599 09 14 ENTERTAIN 040500
53081599 12 07 MISC      084900
58393056 12 26 PAYMENT   027500
53081599 10 16 TRANSFER  015900
53081599 07 24 ENTERTAIN 098100
58393056 04 25 ENTERTAIN 057300
/*
//
