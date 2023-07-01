       IDENTIFICATION DIVISION.
       PROGRAM-ID. DAYCALC.
       AUTHOR. Tolga Kayis.
      *-----------------------------------------------------------------
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT OUTPUT-FILE   ASSIGN TO OUTPFILE
                                STATUS ST-OUTPUT-FILE.
           SELECT INPUT-FILE    ASSIGN TO INPFILE
                                STATUS ST-INPUT-FILE.
      *This is where we declare input and output files.
      *Also their variables to hold their status information. e.g. 0, 97
      *-----------------------------------------------------------------
       DATA DIVISION.
       FILE SECTION.
       FD  OUTPUT-FILE RECORDING MODE F.
       01  OUT-REC.
           03 OREC-ID              PIC X(04).
           03 OREC-NAME            PIC X(15).
           03 OREC-SURNAME         PIC X(15).
           03 OREC-BDAY            PIC 9(08).
           03 OREC-TDAY            PIC 9(08).
           03 OREC-LDAY            PIC 9(05).

       FD  INPUT-FILE RECORDING MODE F.
       01  IN-REC.
           03 IREC-ID              PIC X(04).
           03 IREC-NAME            PIC X(15).
           03 IREC-SURNAME         PIC X(15).
           03 IREC-BDAY            PIC 9(08).
           03 IREC-TDAY            PIC 9(08).
      *
      *
      *--------------------------------------
       WORKING-STORAGE SECTION.
       01  WS-WORKSHOP.
           03 ST-INPUT-FILE        PIC 9(02).
              88 INPFILE-EOF                 VALUE 10.
              88 INPFILE-SUCCESS              VALUE 00 97.
           03 ST-OUTPUT-FILE       PIC 9(02).
              88 OUTPFILE-SUCCESS             VALUE 00 97.
           03 BDAY-INT             PIC 9(07).
           03 TDAY-INT             PIC 9(07).
      *
      *
      *-----------------------------------------------------------------
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM H100-OPEN-FILES
           PERFORM H200-READ-FILE UNTIL INPFILE-EOF
           PERFORM H999-EXIT-PROGRAM.
       0000-END. EXIT.

       H100-OPEN-FILES.
           OPEN INPUT INPUT-FILE.
           IF (ST-INPUT-FILE NOT = 0) AND (ST-INPUT-FILE NOT = 97)
              DISPLAY 'INPFILE DID NOT PROPERLY OPEN: ' ST-INPUT-FILE
              MOVE ST-INPUT-FILE TO RETURN-CODE
              PERFORM H999-EXIT-PROGRAM
              END-IF.
           OPEN OUTPUT OUTPUT-FILE.
           IF (ST-OUTPUT-FILE NOT = 0) AND (ST-OUTPUT-FILE NOT = 97)
              DISPLAY 'OUTPFILE DID NOT PROPERLY OPEN: ' ST-OUTPUT-FILE
              MOVE ST-OUTPUT-FILE TO RETURN-CODE
              PERFORM H999-EXIT-PROGRAM
              END-IF.
           READ INPUT-FILE.
       H100-END. EXIT.

       H200-READ-FILE.
           PERFORM CALCULATION.
           READ INPUT-FILE.
       H200-END. EXIT.

       CALCULATION.
           COMPUTE BDAY-INT = FUNCTION INTEGER-OF-DATE(IREC-BDAY)
           COMPUTE TDAY-INT = FUNCTION INTEGER-OF-DATE(IREC-TDAY)
           COMPUTE OREC-LDAY = TDAY-INT - BDAY-INT
           PERFORM WRITE-OUT.
       CALCULATION-END. EXIT.

       WRITE-OUT.
           MOVE IREC-ID      TO OREC-ID.
           MOVE IREC-NAME    TO OREC-NAME.
           MOVE IREC-SURNAME TO OREC-SURNAME.
           MOVE IREC-BDAY    TO OREC-BDAY.
           MOVE IREC-TDAY    TO OREC-TDAY.
           WRITE OUT-REC.
       WRITE-END. EXIT.

       H999-EXIT-PROGRAM.
           CLOSE OUTPUT-FILE.
           CLOSE INPUT-FILE.
           STOP RUN.
       H999-END.
