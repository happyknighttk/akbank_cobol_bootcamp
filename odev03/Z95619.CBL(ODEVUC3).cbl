       IDENTIFICATION DIVISION.
       PROGRAM-ID. ODEVUC3.
       AUTHOR. Tolga Kayis.
      *-----------------------------------------------------------------
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT OUTPUT-FILE   ASSIGN TO OUTPFILE
                                STATUS ST-OUTPUT-FILE.
           SELECT INPUT-FILE    ASSIGN TO INPFILE
                                STATUS ST-INPUT-FILE.
           SELECT INDEX-FILE    ASSIGN TO IDXFILE
                                ORGANIZATION INDEXED
                                ACCESS RANDOM
                                RECORD KEY IDX-KEY
                                STATUS ST-INDEX-FILE.
           SELECT INVALID-FILE  ASSIGN TO INVFILE
                                STATUS ST-INVALID-FILE.
      *This is where we declare input and output files.
      *Also their variables to hold their status information. e.g. 0, 97
      *My INPUT file is the keys that I have to match with.
      *My INDEX file is the vsam.aa. (All the data I need to compare)
      *INVFILE contains the invalid keys. (The keys that doesn't match)
      *-----------------------------------------------------------------
       DATA DIVISION.
       FILE SECTION.
       FD  OUTPUT-FILE RECORDING MODE F.
       01  OUT-REC.
           03 OREC-ID              PIC 9(05).
           03 FILLER               PIC X(02) VALUE SPACES.
           03 OREC-CURRENCY        PIC 9(03).
           03 FILLER               PIC X(02) VALUE SPACES.
           03 OREC-NAME            PIC X(15).
           03 OREC-SURNAME         PIC X(15).
           03 OREC-BDAY            PIC 9(08).
           03 FILLER               PIC X(02) VALUE SPACES.
           03 OREC-BALANCE         PIC 9(15).
      *
       FD  INVALID-FILE RECORDING MODE F.
       01  INV-REC.
           03 INVREC-ID            PIC 9(05).
           03 FILLER               PIC X(02) VALUE SPACES.
           03 INVREC-CURRENCY      PIC 9(03).
           03 FILLER               PIC X(02) VALUE SPACES.
      *
       FD  INPUT-FILE RECORDING MODE F.
       01  IN-REC.
           03 IREC-ID              PIC X(05).
           03 IREC-CURRENCY        PIC X(03).

       FD  INDEX-FILE.
       01  IDX-REC.
           03 IDX-KEY.
              05 IDX-ID            PIC S9(05) COMP-3.
              05 IDX-CURRENCY      PIC S9(03) COMP.
           03 IDX-NAME             PIC X(15).
           03 IDX-SURNAME          PIC X(15).
           03 IDX-BDAY             PIC S9(07) COMP-3.
           03 IDX-BALANCE          PIC S9(15) COMP-3.
      *Here I declare the data sets that I need.     
      *--------------------------------------
       WORKING-STORAGE SECTION.
       01  WS-WORKSHOP.
           03 INT-BDAY             PIC 9(07).
           03 GREG-BDAY            PIC 9(08).
           03 ST-INPUT-FILE        PIC 9(02).
              88 INPFILE-EOF                 VALUE 10.
              88 INPFILE-SUCCESS             VALUE 00 97.
           03 ST-OUTPUT-FILE       PIC 9(02).
              88 OUTPFILE-SUCCESS            VALUE 00 97.
           03 ST-INDEX-FILE        PIC 9(02).
              88 IDXFILE-SUCCESS             VALUE 00 97.
           03 ST-INVALID-FILE      PIC 9(02).
              88 INVFILE-SUCCESS             VALUE 00 97.
      *       
       01  HEADER-1.
           05  FILLER         PIC X(23) VALUE 'Assignment - Third Week'.
           05  FILLER         PIC X(19) VALUE SPACES.
           05  FILLER         PIC X(19) VALUE 'Author: Tolga KAYIS'.
           05  FILLER         PIC X(19) VALUE SPACES.
      *
       01  HEADER-2.
           05  FILLER         PIC X(05) VALUE 'Year '.
           05  HDR-YR         PIC 9(04).
           05  FILLER         PIC X(02) VALUE SPACES.
           05  FILLER         PIC X(06) VALUE 'Month '.
           05  HDR-MO         PIC X(02).
           05  FILLER         PIC X(02) VALUE SPACES.
           05  FILLER         PIC X(04) VALUE 'Day '.
           05  HDR-DAY        PIC X(02).
           05  FILLER         PIC X(56) VALUE SPACES.
      *
       01  HEADER-3.
           05  FILLER         PIC X(03) VALUE 'ID '.
           05  FILLER         PIC X(04) VALUE SPACES.
           05  FILLER         PIC X(04) VALUE 'Cur '.
           05  FILLER         PIC X(01) VALUE SPACES.
           05  FILLER         PIC X(05) VALUE 'Name '.
           05  FILLER         PIC X(10) VALUE SPACES.
           05  FILLER         PIC X(08) VALUE 'Surname '.
           05  FILLER         PIC X(07) VALUE SPACES.
           05  FILLER         PIC X(09) VALUE 'Birthday '.
           05  FILLER         PIC X(01) VALUE SPACES.
           05  FILLER         PIC X(08) VALUE 'Balance '.
           05  FILLER         PIC X(20) VALUE SPACES.
      *
       01  HEADER-4.
           05  FILLER         PIC X(05) VALUE '-----'.
           05  FILLER         PIC X(02) VALUE SPACES.
           05  FILLER         PIC X(03) VALUE '---'.
           05  FILLER         PIC X(02) VALUE SPACES.
           05  FILLER         PIC X(13) VALUE '-------------'.
           05  FILLER         PIC X(02) VALUE SPACES.
           05  FILLER         PIC X(13) VALUE '-------------'.
           05  FILLER         PIC X(02) VALUE SPACES.
           05  FILLER         PIC X(08) VALUE '--------'.
           05  FILLER         PIC X(02) VALUE SPACES.
           05  FILLER         PIC X(15) VALUE '---------------'.
           05  FILLER         PIC X(13) VALUE SPACES.
      *
       01  HEADER-5.
           03 INV-HEADER      PIC X(13) VALUE 'INVALID KEYS'.
           03 INV-LINE        PIC X(10) VALUE '----------'.
      *
       01 WS-CURRENT-DATE-DATA.
           05  WS-CURRENT-DATE.
               10  WS-CURRENT-YEAR         PIC 9(04).
               10  WS-CURRENT-MONTH        PIC 9(02).
               10  WS-CURRENT-DAY          PIC 9(02).
      *My quality of life FILLERs and the supporting variables
      *-----------------------------------------------------------------
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM H100-OPEN-FILES
           PERFORM H150-WRITE-HEADERS
           PERFORM H200-READ-FILE UNTIL INPFILE-EOF
           PERFORM H999-PREPARE-EXIT.
           STOP RUN.
       0000-END. EXIT.
      *
       H100-OPEN-FILES.
           OPEN INPUT INPUT-FILE.
           IF (ST-INPUT-FILE NOT = 0) AND (ST-INPUT-FILE NOT = 97)
              DISPLAY 'INPFILE DID NOT OPEN PROPERLY: ' ST-INPUT-FILE
              MOVE ST-INPUT-FILE TO RETURN-CODE
              PERFORM H999-PREPARE-EXIT
              END-IF.
           OPEN OUTPUT OUTPUT-FILE.
           IF (ST-OUTPUT-FILE NOT = 0) AND (ST-OUTPUT-FILE NOT = 97)
              DISPLAY 'OUTPFILE DID NOT OPEN PROPERLY: ' ST-OUTPUT-FILE
              MOVE ST-OUTPUT-FILE TO RETURN-CODE
              PERFORM H999-PREPARE-EXIT
              END-IF.
           OPEN INPUT INDEX-FILE.
           IF (ST-INDEX-FILE NOT = 0) AND (ST-INDEX-FILE NOT = 97)
              DISPLAY 'IDXFILE DID NOT OPEN PROPERLY: ' ST-INDEX-FILE
              MOVE ST-INDEX-FILE TO RETURN-CODE
              PERFORM H999-PREPARE-EXIT
              END-IF.
           OPEN OUTPUT INVALID-FILE.
           IF (ST-INVALID-FILE NOT = 0) AND (ST-INVALID-FILE NOT = 97)
              DISPLAY 'INVFILE DID NOT OPEN PROPERLY: ' ST-INVALID-FILE
              MOVE ST-INVALID-FILE TO RETURN-CODE
              PERFORM H999-PREPARE-EXIT
              END-IF.
           READ INPUT-FILE.
       H100-END. EXIT.
      * 
       H150-WRITE-HEADERS.
           MOVE FUNCTION CURRENT-DATE TO WS-CURRENT-DATE-DATA.
           MOVE WS-CURRENT-YEAR  TO HDR-YR.
           MOVE WS-CURRENT-MONTH TO HDR-MO.
           MOVE WS-CURRENT-DAY   TO HDR-DAY.
           WRITE OUT-REC FROM HEADER-1.
           WRITE OUT-REC FROM HEADER-2.
           MOVE SPACES TO OUT-REC.
           WRITE OUT-REC AFTER ADVANCING 1 LINES.
           WRITE OUT-REC FROM HEADER-3.
           WRITE OUT-REC FROM HEADER-4.
           MOVE SPACES TO OUT-REC.
           PERFORM INVALID-FILE-HEADER.
       H150-END. EXIT.
      *
       H200-READ-FILE.
           PERFORM VALIDATION.
           READ INPUT-FILE.
       H200-END. EXIT.
      *
       VALIDATION.
           COMPUTE IDX-ID = FUNCTION NUMVAL(IREC-ID)
           COMPUTE IDX-CURRENCY = FUNCTION NUMVAL(IREC-CURRENCY)
           READ INDEX-FILE KEY IS IDX-KEY
           INVALID KEY PERFORM INVALID-KEYS
           NOT INVALID KEY PERFORM WRITE-OUT.
       VALIDATION-END. EXIT.
      *
       WRITE-OUT.
           PERFORM BALANCE-CALC.
           COMPUTE INT-BDAY = FUNCTION INTEGER-OF-DAY(IDX-BDAY)
           COMPUTE GREG-BDAY = FUNCTION DATE-OF-INTEGER(INT-BDAY)
           MOVE IDX-ID         TO OREC-ID.
           MOVE IDX-CURRENCY   TO OREC-CURRENCY.
           MOVE IDX-NAME       TO OREC-NAME.
           MOVE IDX-SURNAME    TO OREC-SURNAME.
           MOVE GREG-BDAY      TO OREC-BDAY.
           MOVE IDX-BALANCE    TO OREC-BALANCE.
           WRITE OUT-REC.
       WRITE-END. EXIT.
      *
       BALANCE-CALC.
           IF IDX-CURRENCY = 949
              COMPUTE IDX-BALANCE = IDX-BALANCE + 125000
           END-IF.
           IF IDX-CURRENCY = 840
              COMPUTE IDX-BALANCE = IDX-BALANCE + 42000
           END-IF.
           IF IDX-CURRENCY = 978
              COMPUTE IDX-BALANCE = IDX-BALANCE + 525042
           END-IF.
       BALANCE-END.
      *
       INVALID-FILE-HEADER.
           WRITE INV-REC FROM HEADER-5.
           WRITE INV-REC FROM INV-LINE.
       INVALID-FILE-HEADER-END. EXIT.
      *
       INVALID-KEYS.
           MOVE SPACES TO INV-REC.
           MOVE IDX-ID TO INVREC-ID.
           MOVE IDX-CURRENCY TO INVREC-CURRENCY.
           WRITE INV-REC.
       INVALID-END. EXIT.
      *
       H999-PREPARE-EXIT.
           CLOSE OUTPUT-FILE.
           CLOSE INPUT-FILE.
           CLOSE INDEX-FILE.
       H999-END. EXIT.
      *