BEGIN TRAN

    UPDATE t1
    SET t1.CalledNumber = t1.CallingNumber
    --SELECT t1.CallingNumber , t1.CalledNumber
    FROM imp_KoreDetail t1
    WHERE rid IN (732534)

    UPDATE t1
    SET t1.CallingNumber = t1.CalledNumber
    --SELECT t1.CallingNumber , t1.CalledNumber
    FROM imp_KoreDetail t1
    WHERE rid IN (
    350440
    ,522159
    ,370207
    ,68278
    ,338603
    ,853591
    ,295189
    ,498742
    ,337116
    ,484419
    ,513994
    ,575591
    ,575605
    ,575616
    ,575691
    ,837980
    ,838060
    ,838061
    ,243021
    ,243024
    ,662601
    ,118533
    ,138664
    ,350463
    ,30661
    ,732533
    ,506484
    ,506485
    ,664617
    ,240304
    ,679742
    ,828323
    ,828409
    ,829585
    ,758470
    ,295268
    ,337400
    ,575584
    ,575585
    ,575586
    ,575587
    ,575588
    ,575589
    ,575590
    ,828382
    )

    UPDATE t1
    SET Quantity = 1
    --SELECT * 
    FROM imp_KoreSummary2 t1
    WHERE GSM LIKE '%5705097712%'
    AND UsageClass = 'M2M International SMS MT'

    DELETE t1
    --SELECT * 
    FROM imp_KoreSummary2 t1
    WHERE GSM LIKE '%5706928502%'
    AND UsageClass = 'M2M International SMS MT'

    /*
    COMMIT
    ROLLBACK
    
    */

    SELECT t1.CallingNumber , t1.CalledNumber
    FROM imp_KoreDetail t1
    WHERE rid IN (732534)

    SELECT t1.CallingNumber , t1.CalledNumber
    FROM imp_KoreDetail t1
    WHERE rid IN (
    350440
    ,522159
    ,370207
    ,68278
    ,338603
    ,853591
    ,295189
    ,498742
    ,337116
    ,484419
    ,513994
    ,575591
    ,575605
    ,575616
    ,575691
    ,837980
    ,838060
    ,838061
    ,243021
    ,243024
    ,662601
    ,118533
    ,138664
    ,350463
    ,30661
    ,732533
    ,506484
    ,506485
    ,664617
    ,240304
    ,679742
    ,828323
    ,828409
    ,829585
    ,758470
    ,295268
    ,337400
    ,575584
    ,575585
    ,575586
    ,575587
    ,575588
    ,575589
    ,575590
    ,828382
    )

    SELECT * 
    FROM imp_KoreSummary2 t1
    WHERE GSM LIKE '%5705097712%'
    AND UsageClass = 'M2M International SMS MT'


    SELECT * 
    FROM imp_KoreSummary2 t1
    WHERE GSM LIKE '%5706928502%'
    AND UsageClass = 'M2M International SMS MT'