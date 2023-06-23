//SORTREPR JOB ' ',CLASS=A,MSGLEVEL=(1,1),
//          MSGCLASS=X,NOTIFY=Z95619
//* SORTREPR adında bir JOB başlatıp, işin tamamlandığında
//* kullanıcıya bildirim göndermesini istiyorum.
//DELET100 EXEC PGM=IDCAMS
//* DELET100  adında progrma çalıştırılıyor. (IDCAMS).
//SYSPRINT DD SYSOUT=*
//* Çıktıyı SYSOUT'a yönlendiriyorum.
//SYSIN DD *
  DELETE Z95619.QSAM.AA NONVSAM
  IF LASTCC LE 08 THEN SET MAXCC = 00
//SORT0200 EXEC PGM=SORT
//* SYSIN ile giriş verileri belirtiliyor. Altındaki
//* komutlarla QSAM.AA veri setini silip son işlem durumu kontrol ediyorum.
//* Ardından SORT adındaki programı çalıştırıyorum.
//SYSOUT   DD SYSOUT=*
//* Çıktıyı SYSOUT'a yönlendiriyorum.
//SORTIN   DD *
0003TOLGA          KAYIS          19971208
0002ISMAIL         KAYIS          19650603
0001ELIF           KAYIS          19690820
//SORTOUT DD DSN=Z95619.QSAM.AA,
//* SORTIN ile veri girişini yapıyorum.
//* SORTOUT ile çıkış verileri belirtiliyor.(QSAM.AA veri seti).
//           DISP=(NEW,CATLG,DELETE),
//* ^^ ile le çıkış veri setinin yeni oluşturulacağı,
//* kataloglanacağı ve silineceği belirtiliyor.
//           SPACE=(TRK,(5,5),RLSE),
//* ^^ ile çıkış veri setinin alan ayarlarını belirtiyorum.
//           DCB=(RECFM=FB,LRECL=42)
//* ^^  ile çıkış veri setinin kayıt formatını ve uzunluğunu belirtiyorum.
//* vv Burada SORT FIELDS=COPY komutuyla kayıtların
//*aynen kopyalanmasını sağlıyorum.
//SYSIN    DD *
  SORT FIELDS=COPY
//DELET300 EXEC PGM=IEFBR14
//FILE01   DD DSN=Z95619.QSAM.BB,
//* SORT işleminin sonucunu bu dosyaya çıkartacağım.
//            DISP=(MOD,DELETE,DELETE),SPACE=(TRK,0)
//SORT0400 EXEC PGM=SORT
//SYSOUT   DD SYSOUT=*
//SORTIN   DD DSN=Z95619.QSAM.AA,DISP=SHR
//SORTOUT  DD DSN=Z95619.QSAM.BB,
//            DISP=(NEW,CATLG,DELETE),
//            SPACE=(TRK,(5,5),RLSE),
//            DCB=(RECFM=FB,LRECL=50)
//* SORT işlemi için olan komutları belirtiyorum.
//* SORT FIELDS.. komutuyla kayıtların 1-4 karakterine göre sıralandığı,
//* INCLUDE COND.. ile sadece 1. karakteri '0' olan kayıtların dahil edildiği,
//* OUTREC FIELDS.. ile çıkış kayıtlarının 1-42 karakterlerini alarak DATE1 ile
//* birleştiriyorum. 
//SYSIN     DD *
  SORT FIELDS=(1,4,CH,A)
  INCLUDE COND=(1,1,CH,EQ,C'0')
  OUTREC FIELDS=(1,42,DATE1)
