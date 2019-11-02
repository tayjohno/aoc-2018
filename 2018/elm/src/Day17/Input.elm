module Day17.Input exposing (..)

import Coordinate exposing (Coordinate)
import Matrix exposing (Matrix)
import Parser exposing (..)


type alias ScanData =
    List ScanDatum


type alias ScanDatum =
    { xMin : Int
    , xMax : Int
    , yMin : Int
    , yMax : Int
    }


type Tile
    = Clay
    | Sand
    | Spring
    | Water WaterStatus


type WaterStatus
    = Flowing
    | Settled


type alias Map =
    Matrix Tile


{-| Returns the smallest valid area that could be used for displaying the full map.
-}
minMatrixArea : ScanData -> { size : ( Int, Int ), originX : Int, originY : Int }
minMatrixArea scanData =
    let
        xMin =
            scanData
                |> List.map .xMin
                |> List.minimum
                |> Maybe.map (\a -> a - 2)
                |> Maybe.withDefault 0

        -- |> Debug.log "xMin"
        xMax =
            scanData
                |> List.map .xMax
                |> List.maximum
                |> Maybe.map ((+) 1)
                |> Maybe.withDefault 0

        -- |> Debug.log "xMax"
        yMin =
            scanData
                |> List.map .yMin
                |> List.minimum
                |> Maybe.withDefault 0

        -- |> Debug.log "yMin"
        yMax =
            scanData
                |> List.map .yMax
                |> List.maximum
                |> Maybe.withDefault 0

        -- |> Debug.log "yMax"
    in
    { size = ( xMax - xMin + 1, (yMax - yMin) + 1 )
    , originX = xMin
    , originY = yMin
    }


scanDataParser : Parser (List ScanDatum)
scanDataParser =
    succeed identity
        |= Parser.loop [] scanDataHelper


scanDataHelper : List ScanDatum -> Parser (Step (List ScanDatum) (List ScanDatum))
scanDataHelper scanData =
    oneOf
        [ succeed (\s -> Loop (s :: scanData))
            |= scanDatumParser
            |. spaces
        , succeed ()
            |> map (\_ -> Done (List.reverse scanData))
        ]


scanDatumParser : Parser ScanDatum
scanDatumParser =
    oneOf
        [ succeed (\x yMin yMax -> ScanDatum x x yMin yMax)
            |. token "x="
            |= int
            |. token ","
            |. spaces
            |. token "y="
            |= digitChain
            |. token ".."
            |= int
        , succeed (\y xMin xMax -> ScanDatum xMin xMax y y)
            |. token "y="
            |= int
            |. token ","
            |. spaces
            |. token "x="
            |= digitChain
            |. token ".."
            |= int
        ]


digitChain : Parser Int
digitChain =
    getChompedString (chompWhile Char.isDigit)
        |> Parser.map (String.toInt >> Maybe.withDefault 0)


{-| Returns a compact map (one where x and y values only include the minimum required problem set). Also returns the starting point for the flowing water.
-}
input : ( Map, List Coordinate )
input =
    let
        data =
            run scanDataParser rawInput
                |> ensure

        { size, originX, originY } =
            minMatrixArea data
    in
    ( Matrix.empty size Sand
        |> populateMap data ( originX, originY )
    , [ ( 500 - originX, 0 ) ]
    )


prettyPrintMap : Map -> Map
prettyPrintMap map =
    map
        |> Matrix.customPrint
            (\a ->
                case a of
                    Clay ->
                        '#'

                    Sand ->
                        '.'

                    Spring ->
                        '+'

                    Water Flowing ->
                        '|'

                    Water Settled ->
                        '~'
            )
        |> always map


populateMap : ScanData -> Coordinate -> Map -> Map
populateMap scanData origin map =
    List.foldl (addClay origin) map scanData


addClay : Coordinate -> ScanDatum -> Map -> Map
addClay ( originX, originY ) scanDatum map =
    let
        xVals =
            List.range scanDatum.xMin scanDatum.xMax

        --|> Debug.log "xVals"
        yVals =
            List.range scanDatum.yMin scanDatum.yMax

        --|> Debug.log "yVals"
    in
    List.foldl
        (\x xMap ->
            List.foldl
                (\y yMap ->
                    Matrix.set ( x - originX, y - originY ) Clay yMap
                )
                xMap
                yVals
        )
        map
        xVals


ensure : Result b a -> a
ensure resultA =
    case resultA of
        Err _ ->
            Debug.todo "Oops"

        Ok a ->
            a


sampleRawInput =
    """
x=495, y=2..7
y=7, x=495..501
x=501, y=3..7
x=498, y=2..4
x=506, y=1..2
x=498, y=10..13
x=504, y=10..13
y=13, x=498..504
    """
        |> String.trim


rawInput =
    """
x=531, y=15..33
y=658, x=645..649
x=641, y=497..499
y=1055, x=601..607
x=440, y=982..995
x=594, y=119..129
x=400, y=1494..1499
y=1155, x=439..444
y=1136, x=540..553
x=394, y=213..218
y=347, x=462..477
x=444, y=594..601
x=453, y=927..933
x=356, y=34..54
y=923, x=538..540
x=353, y=563..585
x=484, y=87..100
x=436, y=226..227
x=621, y=217..223
x=629, y=669..678
x=346, y=1466..1484
x=561, y=409..427
x=550, y=410..427
y=657, x=410..434
x=623, y=25..28
x=620, y=1244..1251
x=476, y=597..599
x=602, y=555..559
x=541, y=1233..1238
y=682, x=499..506
y=761, x=522..525
x=359, y=1092..1100
y=591, x=400..412
x=527, y=676..689
x=633, y=431..437
x=522, y=1238..1252
x=492, y=1264..1265
x=585, y=442..469
x=413, y=1029..1042
y=1659, x=313..331
x=313, y=1649..1659
x=618, y=1409..1429
y=939, x=601..608
x=364, y=1218..1235
x=525, y=1194..1204
x=400, y=1175..1199
y=561, x=635..642
x=563, y=510..526
x=464, y=869..893
x=349, y=315..324
x=532, y=908..912
x=487, y=1521..1542
x=424, y=605..618
x=452, y=1410..1438
y=1598, x=592..606
y=1622, x=422..438
x=393, y=1397..1406
x=586, y=1591..1607
x=539, y=582..589
y=622, x=476..479
y=747, x=583..604
x=554, y=321..326
x=434, y=157..174
y=353, x=646..654
x=577, y=1190..1194
x=483, y=679..688
x=610, y=1183..1197
y=1542, x=484..487
x=413, y=1361..1363
y=1379, x=489..516
x=403, y=732..740
y=853, x=475..500
x=582, y=624..629
x=526, y=775..787
y=432, x=465..485
y=284, x=601..615
x=587, y=633..649
x=443, y=953..959
x=470, y=153..155
x=562, y=106..109
x=463, y=1199..1211
x=349, y=616..621
y=823, x=386..401
y=1195, x=347..361
x=562, y=401..406
y=293, x=430..448
y=689, x=527..533
x=379, y=300..304
x=606, y=1629..1648
x=456, y=544..558
x=554, y=1338..1342
x=477, y=281..290
y=1383, x=447..464
y=601, x=433..444
x=334, y=1081..1082
y=767, x=511..532
x=615, y=594..616
y=238, x=589..594
y=825, x=530..535
x=440, y=807..812
y=1260, x=387..398
x=614, y=1554..1562
y=1490, x=317..321
x=356, y=1567..1575
y=1429, x=546..552
y=942, x=601..608
x=539, y=700..716
x=407, y=975..986
y=537, x=494..498
x=587, y=1389..1416
y=428, x=477..479
x=353, y=187..213
y=1508, x=452..472
x=493, y=1216..1229
y=935, x=418..423
y=1015, x=362..364
x=580, y=684..686
x=398, y=97..124
x=333, y=817..834
y=1238, x=538..541
y=12, x=323..348
x=353, y=327..343
y=1053, x=365..390
y=495, x=462..479
x=483, y=524..534
y=1184, x=616..626
y=1391, x=428..439
x=552, y=1423..1429
x=403, y=904..908
x=327, y=1132..1146
y=1575, x=352..356
x=384, y=362..375
x=469, y=483..492
y=70, x=333..335
x=391, y=917..918
y=326, x=554..556
x=479, y=613..622
x=365, y=550..552
x=436, y=1081..1084
x=485, y=422..432
x=528, y=1552..1569
y=367, x=460..480
y=1480, x=351..378
x=399, y=1446..1460
x=530, y=733..736
y=364, x=604..607
x=342, y=835..841
x=433, y=750..767
x=342, y=369..382
y=599, x=470..476
x=334, y=234..248
x=460, y=679..703
x=472, y=27..36
x=510, y=545..556
x=441, y=378..389
y=192, x=538..546
x=372, y=485..509
x=635, y=1563..1586
x=494, y=1003..1014
y=54, x=353..356
x=570, y=1032..1038
y=364, x=471..473
x=436, y=543..560
y=155, x=463..470
x=449, y=109..124
x=591, y=389..408
y=1648, x=600..606
y=537, x=363..382
x=455, y=316..326
x=632, y=533..542
x=353, y=517..533
x=614, y=1005..1027
x=541, y=860..871
x=391, y=1515..1517
x=605, y=1523..1535
y=1026, x=382..396
y=263, x=437..440
y=1429, x=605..618
x=411, y=1174..1199
x=410, y=974..986
x=516, y=513..521
x=398, y=443..451
x=451, y=1549..1553
x=640, y=1308..1318
y=626, x=368..370
x=377, y=887..890
x=472, y=1503..1508
x=642, y=245..254
x=369, y=413..427
y=635, x=368..370
x=531, y=160..164
y=1499, x=545..562
x=365, y=1041..1053
x=610, y=1440..1462
x=434, y=634..657
y=217, x=621..626
x=374, y=142..161
x=499, y=1545..1549
y=1048, x=374..379
y=1063, x=565..577
y=144, x=605..624
x=510, y=275..277
x=654, y=333..353
x=386, y=816..823
x=333, y=194..217
y=332, x=546..574
x=531, y=1600..1628
x=610, y=1499..1508
y=21, x=486..513
x=625, y=436..443
y=326, x=455..469
y=970, x=355..372
x=454, y=303..306
x=471, y=354..364
x=555, y=1400..1407
y=164, x=528..531
x=548, y=1376..1383
y=615, x=596..609
x=430, y=858..877
x=423, y=419..443
y=736, x=530..550
x=576, y=443..469
x=642, y=926..928
x=572, y=1227..1228
y=959, x=470..476
y=1055, x=446..449
y=499, x=641..645
x=576, y=629..633
y=1452, x=486..492
y=893, x=357..383
y=1631, x=584..590
x=435, y=1261..1270
x=355, y=300..304
x=345, y=1547..1561
x=393, y=28..41
y=640, x=477..480
y=1536, x=358..438
y=357, x=546..548
x=374, y=59..71
x=436, y=367..373
x=622, y=986..995
x=334, y=1465..1484
x=625, y=650..666
y=28, x=623..630
y=1194, x=577..583
x=354, y=737..759
x=414, y=1000..1004
x=335, y=67..70
y=420, x=633..635
y=1416, x=579..587
x=412, y=587..591
x=357, y=871..893
x=479, y=425..428
y=80, x=420..439
x=577, y=982..996
y=1213, x=589..592
x=646, y=1027..1031
y=1580, x=437..459
x=353, y=1049..1060
x=527, y=646..668
x=500, y=451..458
x=444, y=1403..1406
x=510, y=963..979
x=649, y=654..658
x=379, y=1048..1050
y=1259, x=611..627
x=623, y=1295..1298
x=522, y=266..280
x=490, y=1405..1411
x=354, y=1006..1018
y=1179, x=430..449
x=374, y=707..709
x=462, y=334..347
y=250, x=561..574
y=1230, x=607..618
x=530, y=863..867
x=332, y=1154..1177
x=516, y=1370..1379
y=1100, x=439..465
x=379, y=444..451
y=1531, x=374..416
y=443, x=423..432
x=617, y=1501..1503
x=581, y=1226..1228
x=631, y=98..106
y=1338, x=554..606
y=470, x=318..346
y=946, x=590..617
x=506, y=204..211
x=603, y=188..202
y=1100, x=352..359
y=1615, x=346..352
y=1082, x=334..350
y=496, x=414..432
y=489, x=513..535
x=414, y=239..266
x=418, y=213..218
x=373, y=932..942
x=486, y=30..40
y=47, x=572..583
x=505, y=1592..1615
x=511, y=1174..1186
x=380, y=1445..1454
x=614, y=14..35
x=583, y=730..747
x=590, y=935..946
x=392, y=1592..1612
y=343, x=353..375
x=475, y=444..457
y=383, x=614..629
y=686, x=563..580
x=373, y=800..826
x=626, y=1170..1184
x=569, y=960..974
x=367, y=1303..1305
x=623, y=356..359
y=912, x=532..538
x=614, y=381..383
x=382, y=549..552
x=545, y=1496..1499
x=564, y=736..757
y=554, x=422..429
x=474, y=65..78
y=1618, x=604..622
x=530, y=581..606
y=903, x=650..653
x=577, y=1051..1063
y=71, x=358..374
y=179, x=630..634
x=629, y=75..90
y=102, x=594..607
y=382, x=340..342
x=604, y=177..181
x=616, y=435..443
x=600, y=878..904
y=846, x=478..495
x=425, y=165..167
y=1078, x=454..605
x=592, y=1210..1213
x=589, y=229..238
x=504, y=1119..1123
y=1094, x=605..625
x=476, y=569..581
x=573, y=1478..1502
y=1274, x=618..623
y=434, x=592..605
x=576, y=694..722
y=55, x=398..401
x=387, y=1258..1260
x=559, y=636..648
y=290, x=439..441
y=1280, x=611..629
y=720, x=490..493
y=743, x=452..458
y=928, x=637..642
x=612, y=799..814
x=345, y=572..581
x=455, y=869..893
x=612, y=879..904
x=486, y=511..513
y=110, x=420..435
x=605, y=411..434
x=508, y=839..850
x=503, y=505..524
x=553, y=795..809
x=446, y=29..44
x=422, y=1614..1622
x=483, y=1634..1638
x=559, y=292..295
x=633, y=406..420
x=630, y=1592..1595
x=432, y=258..269
y=1641, x=325..467
y=1454, x=380..396
x=643, y=196..217
x=396, y=1006..1026
y=1039, x=434..451
x=369, y=29..41
x=633, y=593..616
x=463, y=928..933
y=974, x=569..590
x=554, y=1165..1176
x=572, y=20..47
x=524, y=863..867
y=385, x=447..449
x=462, y=465..475
x=628, y=492..503
x=357, y=1405..1414
y=451, x=379..398
x=591, y=817..832
y=78, x=474..490
y=616, x=615..633
x=382, y=520..537
x=605, y=1408..1429
x=601, y=261..284
y=552, x=365..382
y=109, x=562..577
x=424, y=1115..1118
x=341, y=572..581
y=1254, x=641..646
x=561, y=628..633
x=490, y=1590..1610
x=653, y=1028..1031
y=1123, x=500..504
x=565, y=221..225
x=428, y=1239..1252
x=477, y=467..478
x=369, y=835..841
x=500, y=849..853
x=453, y=1585..1588
x=496, y=1395..1414
x=498, y=170..182
y=280, x=494..522
y=1593, x=352..355
x=393, y=1486..1499
x=568, y=1222..1236
x=446, y=697..720
x=542, y=1309..1312
x=397, y=797..813
x=481, y=524..534
x=386, y=1491..1496
x=461, y=1025..1036
y=871, x=519..541
y=361, x=339..351
x=421, y=1189..1203
x=460, y=379..389
x=611, y=556..559
y=1130, x=621..625
y=1251, x=616..620
x=348, y=903..914
y=841, x=342..369
x=554, y=915..929
y=1242, x=533..558
y=1031, x=646..653
y=38, x=384..387
x=601, y=119..129
x=601, y=939..942
x=607, y=1510..1513
y=448, x=443..446
y=662, x=564..580
x=645, y=1479..1484
x=498, y=526..537
x=469, y=316..326
x=502, y=145..147
x=486, y=1128..1139
y=834, x=469..476
x=357, y=1150..1161
x=323, y=1399..1422
x=324, y=144..151
x=453, y=1107..1117
x=538, y=190..192
y=641, x=439..445
x=645, y=654..658
x=608, y=939..942
y=1129, x=491..510
x=437, y=1570..1580
y=903, x=322..335
x=641, y=1592..1595
x=501, y=567..582
x=565, y=1052..1063
x=364, y=1013..1015
x=407, y=399..411
x=633, y=1564..1586
x=538, y=295..319
x=397, y=1592..1612
y=532, x=546..554
x=604, y=969..974
x=538, y=338..360
x=342, y=1225..1235
x=477, y=1107..1117
x=328, y=257..264
x=554, y=876..886
y=32, x=384..387
y=1411, x=384..402
x=650, y=895..903
x=434, y=19..33
y=181, x=590..604
y=1391, x=616..625
y=543, x=583..592
x=453, y=150..161
x=495, y=841..846
y=254, x=636..642
y=155, x=494..510
y=1057, x=464..490
y=874, x=439..444
y=1363, x=397..399
y=1134, x=374..399
x=501, y=653..664
x=398, y=1259..1260
y=603, x=338..352
x=338, y=958..961
x=466, y=1263..1265
y=935, x=632..648
x=516, y=15..33
x=423, y=866..889
x=490, y=167..178
x=324, y=233..248
y=633, x=561..576
x=538, y=909..912
x=491, y=193..206
y=1078, x=403..405
y=1042, x=413..415
y=1058, x=592..615
y=135, x=313..317
x=568, y=1399..1407
x=625, y=1383..1391
x=518, y=698..702
y=1346, x=397..656
x=322, y=1367..1368
y=1499, x=369..393
x=391, y=1397..1406
x=623, y=1265..1274
y=84, x=566..571
x=390, y=1442..1451
x=490, y=711..720
y=914, x=348..358
x=414, y=490..496
y=559, x=602..611
x=460, y=804..817
x=446, y=433..448
y=804, x=491..514
y=1387, x=333..340
y=1119, x=500..504
x=529, y=623..629
y=1520, x=385..401
y=647, x=319..327
x=467, y=193..206
y=206, x=467..491
x=541, y=1601..1628
x=634, y=179..183
x=439, y=872..874
x=611, y=1246..1259
x=530, y=821..825
y=378, x=364..391
x=427, y=966..992
x=400, y=1377..1388
x=588, y=771..773
x=545, y=260..275
y=1570, x=563..575
x=531, y=1197..1208
x=401, y=38..55
x=611, y=1267..1280
x=519, y=1006..1030
x=600, y=1207..1216
x=590, y=1628..1631
x=433, y=74..76
y=1375, x=473..478
y=248, x=324..334
x=546, y=598..606
y=73, x=377..384
x=440, y=1190..1203
y=288, x=352..354
x=318, y=962..983
x=437, y=1049..1054
y=995, x=622..624
x=510, y=1117..1129
x=464, y=1054..1057
y=904, x=600..612
x=352, y=267..288
y=1425, x=357..371
x=501, y=86..100
x=625, y=1441..1462
x=389, y=316..321
x=510, y=635..642
x=426, y=742..743
x=313, y=62..74
x=430, y=74..76
x=644, y=1387..1410
x=430, y=927..953
x=628, y=284..311
x=517, y=734..744
x=583, y=523..543
y=1363, x=413..421
x=586, y=716..722
x=375, y=1324..1342
x=604, y=1615..1618
x=347, y=1188..1195
x=340, y=105..126
y=583, x=389..398
x=479, y=485..495
x=590, y=1183..1197
x=319, y=807..830
y=1508, x=610..626
x=337, y=257..264
x=330, y=518..533
y=425, x=477..479
x=587, y=65..89
x=619, y=189..202
x=615, y=1044..1058
x=641, y=1629..1645
y=130, x=356..380
y=1452, x=570..576
x=623, y=523..524
x=554, y=1575..1587
x=375, y=684..689
x=646, y=1232..1254
y=908, x=403..406
y=1607, x=572..586
x=542, y=699..716
y=1014, x=475..494
x=569, y=511..526
x=492, y=167..178
x=525, y=1593..1615
x=553, y=694..722
y=1342, x=348..375
x=620, y=799..814
x=416, y=965..992
y=44, x=446..458
y=1038, x=570..572
y=309, x=441..461
x=399, y=833..835
x=381, y=172..179
x=317, y=920..945
x=488, y=1009..1011
x=607, y=1053..1055
x=433, y=1261..1270
x=429, y=741..743
x=583, y=1024..1036
y=1579, x=343..362
y=868, x=648..652
x=422, y=145..149
x=588, y=1267..1271
x=438, y=604..618
y=1367, x=387..407
x=601, y=1053..1055
x=335, y=564..585
x=606, y=1555..1562
y=1211, x=463..474
y=758, x=522..525
x=602, y=1166..1176
y=589, x=539..560
x=525, y=623..629
x=546, y=222..225
x=562, y=1495..1499
x=510, y=141..155
y=692, x=365..383
y=1414, x=479..496
x=491, y=1116..1129
x=546, y=1423..1429
y=834, x=333..336
x=401, y=816..823
x=606, y=700..723
x=322, y=884..903
x=374, y=1210..1213
x=596, y=1510..1513
x=537, y=115..128
x=544, y=838..847
x=368, y=929..937
x=630, y=1044..1070
x=384, y=70..73
y=604, x=464..484
y=526, x=563..569
x=351, y=106..126
x=396, y=250..273
x=607, y=94..102
x=546, y=896..906
y=1199, x=400..411
y=1177, x=325..332
x=477, y=1620..1625
x=483, y=545..558
x=407, y=609..634
x=393, y=916..918
x=397, y=337..338
y=1213, x=374..402
x=514, y=781..804
x=493, y=674..687
x=370, y=626..635
x=484, y=281..290
x=620, y=1138..1163
x=318, y=1131..1146
x=447, y=376..385
y=1491, x=482..505
x=516, y=962..979
y=1625, x=477..479
x=525, y=1416..1439
y=507, x=331..334
x=520, y=1194..1204
x=536, y=74..78
y=370, x=488..513
y=251, x=442..511
y=229, x=610..636
x=482, y=713..724
x=502, y=714..724
x=427, y=165..167
y=830, x=319..329
y=992, x=447..453
x=396, y=1422..1436
x=321, y=1477..1490
x=441, y=189..196
y=503, x=628..651
x=522, y=452..458
y=1235, x=334..342
y=835, x=385..399
x=445, y=1128..1139
x=564, y=657..662
x=476, y=613..622
y=986, x=622..624
x=401, y=1510..1520
x=540, y=1553..1569
x=480, y=631..640
y=161, x=453..480
x=350, y=1080..1082
x=511, y=1196..1208
x=595, y=634..649
x=336, y=818..834
x=623, y=95..116
x=420, y=56..80
x=437, y=915..931
y=716, x=539..542
x=416, y=1531..1533
y=463, x=323..337
x=449, y=376..385
x=503, y=1278..1281
x=359, y=930..937
x=530, y=839..850
x=400, y=587..591
y=1436, x=396..412
y=723, x=606..608
y=1203, x=421..440
y=1157, x=482..486
x=468, y=634..643
y=509, x=372..382
x=575, y=853..877
x=313, y=133..135
x=387, y=32..38
x=476, y=949..959
y=787, x=526..544
y=245, x=354..373
y=1502, x=573..587
y=887, x=371..377
x=335, y=1324..1348
x=605, y=65..89
x=540, y=294..319
y=324, x=325..349
y=666, x=614..625
x=426, y=1446..1460
x=546, y=60..82
y=1312, x=527..542
y=722, x=580..586
y=217, x=333..346
x=334, y=500..507
x=320, y=1366..1368
y=743, x=426..429
y=1161, x=357..372
x=440, y=20..33
y=1460, x=399..426
x=405, y=1309..1318
x=397, y=1333..1346
x=459, y=981..995
x=352, y=1091..1100
x=323, y=449..463
x=327, y=1016..1025
y=933, x=453..463
x=545, y=1376..1383
x=511, y=755..767
x=616, y=1384..1391
x=543, y=1269..1275
x=341, y=61..74
y=757, x=564..578
x=614, y=984..1001
x=398, y=38..55
x=374, y=526..534
y=803, x=343..358
x=504, y=1213..1225
x=438, y=1115..1118
x=491, y=781..804
x=370, y=1006..1018
y=1208, x=314..325
y=196, x=435..441
y=524, x=503..528
x=533, y=116..128
x=524, y=940..952
x=639, y=98..106
x=340, y=725..726
x=557, y=383..393
x=587, y=109..125
x=344, y=401..427
y=670, x=324..326
x=574, y=239..250
x=602, y=968..974
y=1439, x=536..560
x=489, y=527..537
x=620, y=322..331
y=830, x=521..544
x=438, y=1615..1622
y=1236, x=565..568
x=387, y=1442..1451
x=604, y=346..364
x=532, y=419..439
y=1030, x=519..540
y=966, x=436..452
x=600, y=1025..1036
y=867, x=524..530
y=1004, x=414..438
y=815, x=599..607
x=333, y=1383..1387
x=608, y=22..27
x=374, y=1048..1050
x=423, y=932..935
x=453, y=990..992
x=453, y=747..772
x=457, y=443..457
x=530, y=1092..1102
x=380, y=142..161
x=372, y=362..375
y=1609, x=651..653
y=375, x=372..384
x=469, y=820..834
y=642, x=505..510
y=974, x=602..604
x=577, y=105..109
x=471, y=1453..1455
x=378, y=936..939
y=681, x=541..560
y=1462, x=610..625
y=639, x=358..381
x=432, y=470..475
y=1645, x=641..646
x=524, y=695..705
y=1176, x=436..440
x=456, y=572..574
y=1621, x=339..359
x=378, y=1463..1480
x=357, y=1422..1425
y=89, x=587..605
x=435, y=101..110
x=484, y=1522..1542
y=264, x=328..337
x=434, y=1035..1039
x=459, y=1571..1580
x=561, y=837..847
x=488, y=633..643
x=480, y=169..182
y=213, x=353..373
x=338, y=762..763
x=460, y=403..406
x=473, y=747..772
y=807, x=440..446
y=1127, x=351..370
y=273, x=396..405
y=826, x=362..373
x=369, y=526..534
x=578, y=548..573
y=1513, x=596..607
y=695, x=344..357
y=389, x=441..460
y=33, x=434..440
y=861, x=616..630
y=1597, x=341..361
x=505, y=634..642
y=1654, x=461..480
y=1408, x=314..317
y=996, x=485..577
x=447, y=990..992
x=477, y=631..640
x=405, y=250..273
x=340, y=368..382
x=642, y=41..50
x=399, y=1360..1363
y=877, x=430..452
y=959, x=443..445
y=1102, x=530..553
y=1612, x=392..397
x=439, y=1087..1100
x=601, y=1127..1137
x=635, y=669..678
x=439, y=1153..1155
y=995, x=440..459
x=551, y=1520..1530
y=689, x=375..377
x=351, y=1462..1480
x=341, y=1016..1025
x=648, y=844..868
x=540, y=1119..1136
y=574, x=435..456
y=469, x=576..585
y=40, x=467..486
y=581, x=341..345
x=461, y=1650..1654
y=911, x=397..417
x=369, y=172..179
x=570, y=1434..1452
x=607, y=813..815
x=385, y=980..996
y=1406, x=439..444
y=406, x=551..562
x=325, y=1184..1208
x=442, y=314..328
y=73, x=481..483
y=943, x=547..553
y=648, x=557..559
y=1368, x=320..322
y=1318, x=638..640
x=594, y=229..238
x=554, y=505..532
x=384, y=32..38
x=331, y=1399..1422
x=331, y=1649..1659
x=513, y=9..21
x=560, y=1420..1439
x=518, y=246..250
y=1502, x=327..346
x=544, y=649..654
x=589, y=1004..1013
y=1001, x=614..639
x=433, y=803..817
y=1172, x=474..477
y=1624, x=413..418
y=149, x=422..440
y=183, x=630..634
x=558, y=1227..1242
y=664, x=481..501
y=720, x=420..446
x=534, y=74..78
x=539, y=619..634
y=157, x=588..595
y=1084, x=436..447
x=428, y=1585..1588
x=626, y=217..223
y=1036, x=583..600
y=1265, x=466..492
x=639, y=432..437
x=353, y=34..54
x=418, y=759..763
x=424, y=788..807
x=515, y=1401..1414
x=432, y=1148..1160
x=499, y=318..344
x=329, y=806..830
y=1646, x=650..653
x=527, y=1279..1281
y=164, x=386..400
x=397, y=3..28
x=564, y=1144..1156
x=639, y=983..1001
y=540, x=447..459
x=462, y=403..406
x=346, y=193..217
x=402, y=1209..1213
x=544, y=817..830
x=620, y=1351..1374
x=459, y=513..540
x=358, y=618..639
x=470, y=948..959
x=391, y=357..378
x=461, y=1046..1058
x=477, y=333..347
x=450, y=721..727
x=486, y=616..625
x=584, y=1627..1631
x=370, y=1119..1127
x=553, y=383..393
y=1411, x=488..490
y=1116, x=590..640
x=652, y=845..868
y=1270, x=433..435
y=1484, x=334..346
y=124, x=398..410
y=740, x=391..403
x=314, y=1401..1408
x=481, y=45..54
x=378, y=1594..1612
x=383, y=872..893
x=604, y=731..747
x=493, y=318..344
x=372, y=1376..1388
x=395, y=1515..1517
x=656, y=1332..1346
x=462, y=486..495
x=599, y=814..815
y=817, x=433..460
x=420, y=458..481
x=439, y=55..80
y=27, x=605..608
x=592, y=411..434
x=611, y=1065..1078
y=1610, x=477..490
x=527, y=1310..1312
y=344, x=493..499
x=406, y=1374..1388
x=436, y=949..966
x=425, y=1048..1054
x=440, y=1167..1176
x=475, y=1004..1014
x=599, y=15..35
x=581, y=941..952
y=176, x=522..539
x=380, y=413..427
y=211, x=506..532
x=568, y=896..906
y=427, x=369..380
y=1648, x=529..552
x=645, y=95..116
x=532, y=203..211
y=1438, x=590..592
x=447, y=513..540
x=364, y=400..427
x=326, y=662..670
x=341, y=1587..1597
y=1197, x=590..610
y=872, x=439..444
y=1654, x=619..638
x=587, y=1477..1502
x=502, y=215..229
y=1248, x=398..400
x=624, y=986..995
x=474, y=810..815
y=558, x=456..483
x=528, y=160..164
y=1295, x=623..638
y=1018, x=354..370
x=356, y=103..130
x=421, y=1361..1363
x=613, y=1065..1078
x=640, y=1102..1116
x=377, y=684..689
x=412, y=1555..1558
x=495, y=876..886
x=351, y=356..361
y=28, x=397..400
x=400, y=145..164
x=362, y=1570..1579
x=569, y=390..408
x=390, y=763..790
x=511, y=1215..1229
y=679, x=386..396
x=557, y=637..648
x=429, y=552..554
y=1239, x=593..625
x=605, y=124..144
x=445, y=632..641
x=365, y=1585..1590
y=996, x=385..396
y=668, x=527..532
x=490, y=1055..1057
y=1281, x=503..527
x=448, y=281..293
y=1569, x=528..540
x=362, y=1013..1015
x=418, y=1288..1301
x=447, y=459..481
y=1540, x=447..457
y=1496, x=383..386
y=521, x=514..516
x=590, y=1436..1438
x=472, y=505..516
x=616, y=1169..1184
x=383, y=680..692
x=483, y=63..73
y=128, x=533..537
x=362, y=801..826
y=475, x=462..471
y=1011, x=485..488
x=544, y=776..787
x=326, y=1368..1392
y=126, x=340..351
x=335, y=884..903
x=448, y=1547..1561
x=417, y=897..911
y=178, x=490..492
y=373, x=436..447
y=1139, x=445..486
y=100, x=484..501
x=422, y=552..554
y=1451, x=387..390
y=179, x=369..381
x=646, y=333..353
x=438, y=1000..1004
x=358, y=58..71
x=499, y=1213..1225
y=321, x=379..389
x=627, y=1247..1259
y=534, x=481..483
y=1146, x=318..327
x=379, y=315..321
x=427, y=1308..1318
x=460, y=356..367
x=622, y=1616..1618
y=1300, x=357..365
y=406, x=460..462
x=331, y=499..507
x=636, y=213..229
y=1455, x=471..477
y=1374, x=620..633
x=325, y=315..324
y=319, x=538..540
x=395, y=796..813
x=452, y=1502..1508
x=587, y=664..688
x=453, y=680..703
y=1156, x=564..589
y=475, x=432..436
x=436, y=470..475
y=33, x=516..531
y=1628, x=531..541
y=41, x=369..393
y=572, x=341..345
y=1027, x=609..614
x=522, y=758..761
x=371, y=887..890
x=555, y=835..843
y=1458, x=465..483
x=346, y=1499..1502
x=332, y=302..311
x=594, y=95..102
x=481, y=63..73
x=570, y=597..606
y=662, x=324..326
y=1586, x=633..635
y=1155, x=482..486
x=637, y=1355..1367
x=408, y=544..560
y=763, x=418..423
y=443, x=616..625
x=467, y=1628..1641
x=546, y=505..532
x=346, y=1606..1615
x=546, y=355..357
y=116, x=623..645
y=918, x=391..393
x=418, y=1612..1624
x=491, y=92..95
y=129, x=594..601
y=1638, x=483..502
y=634, x=515..539
y=1558, x=412..423
x=397, y=1360..1363
x=630, y=851..861
y=478, x=457..477
x=415, y=1030..1042
x=515, y=618..634
y=427, x=344..364
x=588, y=153..157
y=649, x=587..595
x=326, y=1325..1348
x=583, y=1433..1442
x=620, y=1478..1484
x=550, y=733..736
x=538, y=245..250
y=1216, x=579..600
x=560, y=583..589
y=1448, x=508..515
x=390, y=336..338
x=338, y=594..603
x=405, y=750..767
y=306, x=449..454
y=74, x=534..536
x=352, y=1567..1575
x=644, y=1288..1301
y=143, x=467..483
x=342, y=738..759
x=569, y=1270..1275
x=438, y=1525..1536
x=426, y=225..227
x=566, y=854..877
x=446, y=1264..1273
y=1305, x=367..375
x=364, y=724..726
y=618, x=424..438
x=653, y=195..217
x=605, y=22..27
y=437, x=633..639
y=497, x=641..645
x=374, y=1132..1134
y=355, x=546..548
x=348, y=7..12
x=553, y=835..843
y=886, x=495..554
x=589, y=1144..1156
x=519, y=551..555
x=323, y=7..12
x=623, y=1137..1163
y=1342, x=554..606
y=1321, x=630..646
y=573, x=578..597
y=581, x=476..493
x=358, y=903..914
x=594, y=501..505
x=572, y=1590..1607
x=494, y=527..537
x=471, y=400..411
x=533, y=1226..1242
x=532, y=756..767
x=451, y=1035..1039
x=625, y=283..311
x=480, y=1650..1654
x=528, y=506..524
x=477, y=1453..1455
x=479, y=45..54
x=337, y=738..746
y=1050, x=374..379
x=426, y=239..266
x=380, y=1269..1284
x=640, y=171..190
x=630, y=1568..1578
x=400, y=1246..1248
y=1117, x=453..477
x=408, y=1373..1388
x=441, y=298..309
x=343, y=779..803
x=411, y=787..807
x=478, y=678..688
x=396, y=671..679
x=446, y=1043..1055
x=344, y=668..695
y=328, x=416..442
x=373, y=186..213
x=435, y=571..574
x=638, y=1295..1298
y=106, x=631..639
y=1595, x=630..641
y=1153, x=439..444
y=1235, x=607..618
x=427, y=5..16
x=546, y=316..332
x=621, y=1127..1130
y=469, x=593..620
x=333, y=655..673
y=311, x=625..628
x=345, y=1048..1060
y=1013, x=567..589
y=1208, x=511..531
x=461, y=299..309
x=357, y=1282..1300
x=464, y=591..604
x=539, y=150..176
y=498, x=351..362
x=505, y=1402..1414
y=1503, x=617..620
y=174, x=408..434
y=266, x=414..426
x=483, y=1443..1458
x=477, y=425..428
y=979, x=510..516
x=330, y=761..763
x=638, y=1651..1654
y=1301, x=418..644
x=486, y=10..21
x=438, y=110..124
x=592, y=1044..1058
x=499, y=679..682
x=616, y=1244..1251
x=553, y=1118..1136
y=1388, x=372..400
x=503, y=109..136
x=630, y=24..28
x=410, y=98..124
y=893, x=455..464
y=1060, x=345..353
x=493, y=568..581
x=488, y=363..370
x=552, y=458..467
y=889, x=419..423
y=1517, x=391..395
x=355, y=951..970
x=398, y=569..583
x=590, y=177..181
x=498, y=545..556
x=432, y=490..496
x=470, y=597..599
x=618, y=1230..1235
x=395, y=703..719
y=1612, x=370..378
x=541, y=674..681
x=361, y=1187..1195
y=890, x=371..377
x=612, y=75..90
x=651, y=1589..1609
y=1392, x=548..565
x=527, y=580..606
x=481, y=652..664
x=519, y=861..871
y=123, x=469..494
x=471, y=483..492
x=651, y=357..359
y=161, x=374..380
x=609, y=1005..1027
x=625, y=1228..1239
x=339, y=357..361
y=832, x=591..594
x=535, y=483..489
y=1392, x=326..350
y=140, x=474..476
x=396, y=1444..1454
x=475, y=849..853
x=653, y=1639..1646
x=510, y=1545..1549
x=359, y=1608..1621
x=513, y=362..370
x=458, y=28..44
x=615, y=260..284
x=479, y=1395..1414
x=609, y=624..629
x=592, y=522..543
x=476, y=128..140
y=1167, x=336..350
x=410, y=633..657
x=403, y=1493..1499
x=637, y=41..50
y=1228, x=572..581
x=465, y=1088..1100
y=759, x=342..354
y=942, x=373..399
x=390, y=1041..1053
x=319, y=634..647
x=458, y=736..743
y=709, x=352..374
y=983, x=313..318
y=95, x=491..493
y=629, x=582..609
x=465, y=1442..1458
y=688, x=583..587
x=467, y=131..143
y=1499, x=400..403
x=420, y=100..110
y=82, x=524..546
x=385, y=1510..1520
y=1587, x=554..564
y=534, x=369..374
y=727, x=450..462
x=563, y=1552..1570
x=556, y=337..360
y=331, x=614..620
x=399, y=1133..1134
y=218, x=394..418
y=1229, x=493..511
x=478, y=27..36
x=375, y=327..343
x=313, y=961..983
y=1176, x=554..602
x=538, y=1233..1238
y=986, x=407..410
y=931, x=435..437
x=343, y=1569..1579
x=464, y=1411..1438
x=428, y=1377..1391
x=430, y=1170..1179
x=614, y=651..666
y=1162, x=476..498
x=374, y=1531..1533
y=1590, x=365..372
x=585, y=108..125
y=411, x=407..471
x=355, y=1585..1593
x=443, y=433..448
x=441, y=278..290
x=449, y=1169..1179
x=457, y=468..478
y=654, x=538..544
x=598, y=1432..1442
y=362, x=372..384
x=348, y=1324..1342
x=652, y=1355..1367
x=616, y=852..861
x=486, y=1155..1157
x=540, y=1007..1030
y=807, x=411..424
x=623, y=170..190
x=650, y=1640..1646
x=480, y=357..367
x=421, y=627..628
x=583, y=663..688
x=493, y=92..95
y=582, x=501..508
y=1360, x=397..399
x=532, y=646..668
y=125, x=585..587
x=446, y=807..812
x=576, y=1128..1137
x=467, y=29..40
x=630, y=522..524
x=500, y=1119..1123
x=538, y=921..923
x=354, y=231..245
x=492, y=1427..1452
y=136, x=503..515
x=397, y=1076..1093
y=1442, x=583..598
y=311, x=314..332
y=850, x=508..530
x=369, y=1486..1499
y=78, x=534..536
y=1078, x=611..613
y=556, x=498..510
y=1484, x=620..645
x=618, y=1265..1274
x=489, y=1371..1379
x=358, y=1525..1536
x=314, y=1184..1208
x=536, y=1419..1439
x=327, y=919..945
x=632, y=914..935
y=1273, x=426..446
x=485, y=1173..1186
y=560, x=408..436
x=324, y=662..670
y=35, x=599..614
x=325, y=1155..1177
x=433, y=594..601
y=182, x=480..498
x=405, y=1057..1078
x=439, y=632..641
x=594, y=818..832
x=607, y=1230..1235
x=352, y=593..603
x=375, y=1304..1305
y=1439, x=521..525
y=1422, x=323..331
y=929, x=533..554
x=596, y=600..615
x=432, y=419..443
x=635, y=406..420
x=470, y=526..537
x=514, y=513..521
x=637, y=926..928
y=505, x=594..607
x=406, y=904..908
x=381, y=1077..1093
x=593, y=1227..1239
x=469, y=111..123
x=334, y=1224..1235
y=1013, x=362..364
y=1252, x=428..522
x=565, y=1223..1236
x=563, y=685..686
x=384, y=1399..1411
x=605, y=1066..1078
x=609, y=601..615
x=565, y=1388..1392
x=337, y=449..463
x=354, y=268..288
x=607, y=501..505
x=447, y=366..373
x=502, y=696..705
x=525, y=758..761
x=397, y=898..911
x=454, y=1066..1078
x=630, y=179..183
y=1058, x=441..461
y=1235, x=346..364
x=653, y=894..903
x=352, y=706..709
y=190, x=623..640
x=357, y=668..695
y=1438, x=452..464
x=614, y=321..331
x=408, y=158..174
x=456, y=215..229
y=151, x=313..324
y=217, x=643..653
x=515, y=109..136
x=583, y=1191..1194
y=275, x=505..510
x=435, y=914..931
y=1160, x=432..451
x=405, y=1465..1478
y=606, x=527..530
x=564, y=1575..1587
x=575, y=1553..1570
y=906, x=546..568
x=392, y=461..479
y=359, x=623..651
x=508, y=1442..1448
y=1348, x=326..335
x=644, y=532..542
x=384, y=936..939
x=452, y=950..966
x=372, y=952..970
x=649, y=1386..1410
y=167, x=425..427
y=393, x=553..557
x=470, y=615..625
x=610, y=213..229
x=403, y=1058..1078
x=412, y=1422..1436
x=551, y=402..406
x=398, y=1246..1248
y=746, x=326..337
x=471, y=465..475
x=506, y=679..682
x=490, y=66..78
x=522, y=151..176
x=386, y=1225..1251
x=365, y=1283..1300
x=502, y=1634..1638
x=629, y=1268..1280
y=250, x=518..538
x=380, y=104..130
y=773, x=588..606
x=511, y=237..251
x=646, y=1630..1645
x=462, y=721..727
x=508, y=567..582
x=477, y=1169..1172
x=548, y=1388..1392
y=961, x=338..348
x=505, y=275..277
x=494, y=110..123
y=1054, x=425..437
x=586, y=1266..1271
x=418, y=932..935
y=877, x=566..575
x=325, y=81..98
x=469, y=48..57
y=202, x=603..619
x=476, y=1149..1162
x=413, y=1612..1624
x=476, y=819..834
x=580, y=715..722
x=372, y=1584..1590
x=451, y=1147..1160
y=767, x=405..433
y=1118, x=424..438
y=427, x=550..561
x=572, y=1033..1038
x=576, y=1434..1452
y=809, x=535..553
y=1137, x=576..601
x=464, y=1358..1383
x=567, y=1003..1013
x=515, y=1442..1448
y=360, x=538..556
x=527, y=457..467
y=225, x=546..565
x=646, y=1311..1321
x=423, y=1555..1558
x=630, y=1310..1321
y=16, x=417..427
y=295, x=551..559
x=348, y=958..961
x=453, y=1549..1553
y=513, x=482..486
y=1225, x=499..504
y=479, x=383..392
y=939, x=378..384
y=949, x=547..553
x=578, y=737..757
x=533, y=677..689
x=653, y=1588..1609
y=1533, x=374..416
x=327, y=1498..1502
x=372, y=1149..1161
y=147, x=502..504
y=1163, x=620..623
x=423, y=759..763
x=440, y=261..263
y=439, x=532..546
x=395, y=609..634
x=561, y=240..250
y=623, x=525..529
x=479, y=1620..1625
x=441, y=1045..1058
x=439, y=278..290
y=1318, x=405..427
y=76, x=430..433
x=482, y=1155..1157
x=320, y=114..127
x=340, y=1406..1414
x=485, y=1009..1011
x=486, y=1428..1452
x=629, y=382..383
x=420, y=697..720
x=448, y=258..269
x=580, y=656..662
x=560, y=674..681
x=327, y=635..647
x=440, y=145..149
y=36, x=472..478
x=625, y=1127..1130
y=277, x=505..510
x=444, y=1153..1155
x=524, y=61..82
x=463, y=153..155
x=447, y=1516..1540
x=504, y=145..147
y=1251, x=386..406
y=705, x=502..524
x=482, y=1476..1491
x=521, y=817..830
y=227, x=426..436
y=50, x=637..642
y=481, x=420..447
y=945, x=317..327
y=726, x=340..364
y=790, x=381..390
x=327, y=616..621
x=533, y=915..929
y=643, x=468..488
y=1501, x=617..620
x=589, y=1210..1213
x=364, y=357..378
y=813, x=395..397
y=555, x=519..545
x=402, y=1400..1411
y=1561, x=345..448
y=724, x=482..502
x=483, y=130..143
x=449, y=303..306
x=642, y=555..561
x=574, y=317..332
x=430, y=280..293
x=494, y=142..155
x=524, y=1521..1530
x=540, y=921..923
y=688, x=478..483
y=763, x=330..338
x=593, y=1524..1535
x=624, y=125..144
x=608, y=699..723
x=386, y=671..679
x=447, y=1081..1084
x=365, y=680..692
y=1535, x=593..605
x=597, y=549..573
x=373, y=231..245
y=702, x=516..518
x=333, y=67..70
x=386, y=144..164
x=480, y=151..161
x=474, y=1170..1172
x=583, y=21..47
y=703, x=453..460
x=457, y=1516..1540
y=1210, x=589..592
x=417, y=5..16
x=545, y=551..555
y=1383, x=545..548
y=269, x=432..448
x=566, y=81..84
x=447, y=1359..1383
y=275, x=545..551
x=407, y=1356..1367
x=634, y=1043..1070
x=370, y=1593..1612
y=1246, x=398..400
x=477, y=1591..1610
y=74, x=430..433
y=1070, x=630..634
y=1530, x=524..551
x=346, y=1218..1235
y=1093, x=381..397
y=772, x=453..473
y=74, x=313..341
x=351, y=1120..1127
x=606, y=771..773
y=1553, x=451..453
x=512, y=675..687
x=494, y=733..744
y=90, x=612..629
x=474, y=128..140
x=494, y=504..516
y=304, x=355..379
y=628, x=413..421
x=439, y=1403..1406
x=636, y=244..254
y=904, x=403..406
y=815, x=474..483
y=54, x=479..481
x=340, y=1383..1387
x=337, y=80..98
x=452, y=737..743
x=350, y=1367..1392
x=547, y=943..949
x=535, y=796..809
x=478, y=1364..1375
x=363, y=520..537
x=485, y=982..996
x=352, y=1606..1615
y=722, x=553..576
x=553, y=943..949
y=843, x=553..555
y=458, x=500..522
y=1562, x=606..614
x=358, y=780..803
y=1478, x=383..405
y=1204, x=520..525
x=413, y=626..628
x=619, y=1569..1578
y=1275, x=543..569
y=408, x=569..591
x=553, y=1091..1102
x=595, y=153..157
x=535, y=821..825
x=378, y=703..719
y=229, x=456..502
x=617, y=934..946
x=551, y=293..295
y=585, x=335..353
y=812, x=440..446
y=1414, x=340..357
y=1410, x=644..649
y=290, x=477..484
x=326, y=739..746
y=1298, x=623..638
x=400, y=3..28
y=467, x=527..552
x=389, y=569..583
x=339, y=1609..1621
x=552, y=1641..1648
x=381, y=764..790
y=516, x=472..494
x=641, y=1231..1254
x=412, y=928..953
x=436, y=1167..1176
x=334, y=114..127
y=1406, x=391..393
y=625, x=470..486
x=385, y=834..835
x=371, y=1423..1425
x=346, y=445..470
x=351, y=478..498
x=444, y=872..874
y=814, x=612..620
x=325, y=1629..1641
y=673, x=317..333
y=1414, x=505..515
x=626, y=1498..1508
x=482, y=511..513
x=474, y=1199..1211
x=317, y=656..673
x=483, y=810..815
x=638, y=1308..1318
x=505, y=1477..1491
y=678, x=629..635
x=382, y=485..509
y=1036, x=461..481
x=620, y=454..469
y=634, x=395..407
x=593, y=453..469
y=1407, x=555..568
x=619, y=1650..1654
x=625, y=1083..1094
x=435, y=189..196
y=992, x=416..427
x=372, y=1268..1284
x=546, y=420..439
y=470, x=432..436
x=465, y=423..432
y=98, x=325..337
x=452, y=857..877
y=1549, x=499..510
y=223, x=621..626
y=542, x=632..644
y=124, x=438..449
y=1367, x=637..652
x=600, y=1630..1648
x=521, y=1415..1439
x=382, y=1005..1026
x=551, y=260..275
x=478, y=840..846
x=426, y=1263..1273
y=744, x=494..517
x=538, y=649..654
x=419, y=866..889
x=317, y=1476..1490
x=317, y=1401..1408
y=687, x=493..512
x=314, y=302..311
y=1578, x=619..630
x=548, y=355..357
x=383, y=1466..1478
x=592, y=1436..1438
x=391, y=731..740
y=57, x=469..488
x=606, y=1338..1342
y=457, x=457..475
y=1555, x=412..423
x=361, y=1588..1597
x=336, y=1141..1167
x=377, y=71..73
y=1271, x=586..588
x=381, y=617..639
x=494, y=266..280
x=635, y=555..561
y=153, x=463..470
x=529, y=1642..1648
x=579, y=1389..1416
x=399, y=933..942
x=449, y=1043..1055
x=571, y=82..84
y=537, x=470..489
x=481, y=1024..1036
x=607, y=347..364
x=633, y=1352..1374
x=317, y=133..135
x=516, y=698..702
x=620, y=1501..1503
x=416, y=315..328
y=1186, x=485..511
x=445, y=953..959
y=492, x=469..471
x=442, y=238..251
x=383, y=461..479
x=498, y=1150..1162
x=383, y=1491..1496
x=439, y=1376..1391
x=590, y=1103..1116
x=473, y=1365..1375
x=579, y=1206..1216
x=546, y=190..192
y=606, x=546..570
x=313, y=144..151
x=488, y=47..57
y=937, x=359..368
x=473, y=354..364
x=368, y=626..635
x=406, y=1226..1251
x=484, y=592..604
x=651, y=492..503
x=387, y=1357..1367
y=952, x=524..581
y=1284, x=372..380
x=648, y=915..935
x=437, y=261..263
y=1588, x=428..453
x=513, y=483..489
y=1615, x=505..525
x=590, y=960..974
x=488, y=1405..1411
y=1025, x=327..341
x=606, y=1597..1598
x=556, y=321..326
x=592, y=1596..1598
y=847, x=544..561
x=396, y=981..996
y=338, x=390..397
x=318, y=444..470
x=352, y=1585..1593
y=533, x=330..353
y=629, x=525..529
x=645, y=497..499
y=621, x=327..349
x=605, y=1083..1094
y=1388, x=406..408
x=350, y=1142..1167
y=953, x=412..430
y=127, x=320..334
x=362, y=477..498
x=493, y=711..720
y=719, x=378..395
y=524, x=623..630
    """
        |> String.trim
