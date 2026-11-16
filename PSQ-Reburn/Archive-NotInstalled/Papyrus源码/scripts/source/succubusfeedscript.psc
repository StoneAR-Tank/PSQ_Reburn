Scriptname succubusfeedscript extends Perk hidden
String[] Function GetTagEntry()
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.FeedEntries34()
  EndIf
  String[] sOptions = new String[102] ; #DEBUG_LINE_NO:135
  sOptions[0] = ((("Act" + ";;" + -1 as String) + ";;" + 1 as String) + ";;" + 0 as String) + ";;1" ; #DEBUG_LINE_NO:136
  sOptions[1] = ((("Organ" + ";;" + -1 as String) + ";;" + 2 as String) + ";;" + 1 as String) + ";;1" ; #DEBUG_LINE_NO:137
  sOptions[2] = ((("SexPosition" + ";;" + -1 as String) + ";;" + 3 as String) + ";;" + 2 as String) + ";;1" ; #DEBUG_LINE_NO:138
  sOptions[3] = ((("Sex" + ";;" + -1 as String) + ";;" + 4 as String) + ";;" + 3 as String) + ";;1" ; #DEBUG_LINE_NO:139
  sOptions[4] = ((("Behavior" + ";;" + -1 as String) + ";;" + 5 as String) + ";;" + 4 as String) + ";;1" ; #DEBUG_LINE_NO:140
  sOptions[5] = ((("Cum" + ";;" + -1 as String) + ";;" + 6 as String) + ";;" + 5 as String) + ";;1" ; #DEBUG_LINE_NO:141
  sOptions[6] = ((("Misc" + ";;" + -1 as String) + ";;" + 7 as String) + ";;" + 6 as String) + ";;1" ; #DEBUG_LINE_NO:142
  sOptions[7] = ((("Author" + ";;" + -1 as String) + ";;" + 8 as String) + ";;" + 7 as String) + ";;1" ; #DEBUG_LINE_NO:143
  sOptions[8] = ((("Aggressive" + ";;" + -1 as String) + ";;" + 9 as String) + ";;" + 8 as String) + ";;0" ; #DEBUG_LINE_NO:144
  sOptions[9] = ((("None" + ";;" + -1 as String) + ";;" + 10 as String) + ";;" + 9 as String) + ";;0" ; #DEBUG_LINE_NO:145
  sOptions[10] = ((("Sex" + ";;" + 1 as String) + ";;" + 20 as String) + ";;" + 0 as String) + ";;0" ; #DEBUG_LINE_NO:147
  sOptions[11] = ((("Foreplay" + ";;" + 1 as String) + ";;" + 21 as String) + ";;" + 1 as String) + ";;0" ; #DEBUG_LINE_NO:148
  sOptions[12] = ((("Licking" + ";;" + 1 as String) + ";;" + 22 as String) + ";;" + 2 as String) + ";;0" ; #DEBUG_LINE_NO:149
  sOptions[13] = ((("Cunnilingus" + ";;" + 1 as String) + ";;" + 23 as String) + ";;" + 3 as String) + ";;0" ; #DEBUG_LINE_NO:150
  sOptions[14] = ((("Petting" + ";;" + 1 as String) + ";;" + 24 as String) + ";;" + 4 as String) + ";;0" ; #DEBUG_LINE_NO:151
  sOptions[15] = ((("Blowjob" + ";;" + 1 as String) + ";;" + 25 as String) + ";;" + 5 as String) + ";;0" ; #DEBUG_LINE_NO:152
  sOptions[16] = ((("Handjob" + ";;" + 1 as String) + ";;" + 26 as String) + ";;" + 6 as String) + ";;0" ; #DEBUG_LINE_NO:153
  sOptions[17] = ((("Boobjob" + ";;" + 1 as String) + ";;" + 27 as String) + ";;" + 7 as String) + ";;0" ; #DEBUG_LINE_NO:154
  sOptions[18] = ((("Footjob" + ";;" + 1 as String) + ";;" + 28 as String) + ";;" + 8 as String) + ";;0" ; #DEBUG_LINE_NO:155
  sOptions[19] = ((("Breastfeeding" + ";;" + 1 as String) + ";;" + 29 as String) + ";;" + 9 as String) + ";;0" ; #DEBUG_LINE_NO:156
  sOptions[20] = ((("Kneeling" + ";;" + 1 as String) + ";;" + 30 as String) + ";;" + 10 as String) + ";;0" ; #DEBUG_LINE_NO:157
  sOptions[21] = ((("Fisting" + ";;" + 1 as String) + ";;" + 31 as String) + ";;" + 11 as String) + ";;0" ; #DEBUG_LINE_NO:158
  sOptions[22] = ((("Fondling" + ";;" + 1 as String) + ";;" + 32 as String) + ";;" + 12 as String) + ";;0" ; #DEBUG_LINE_NO:159
  sOptions[23] = ((("69" + ";;" + 1 as String) + ";;" + 33 as String) + ";;" + 13 as String) + ";;0" ; #DEBUG_LINE_NO:160
  sOptions[24] = ((("Vaginal" + ";;" + 2 as String) + ";;" + 40 as String) + ";;" + 0 as String) + ";;0" ; #DEBUG_LINE_NO:162
  sOptions[25] = ((("Pussy" + ";;" + 2 as String) + ";;" + 41 as String) + ";;" + 1 as String) + ";;0" ; #DEBUG_LINE_NO:163
  sOptions[26] = ((("Anal" + ";;" + 2 as String) + ";;" + 42 as String) + ";;" + 2 as String) + ";;0" ; #DEBUG_LINE_NO:164
  sOptions[27] = ((("Hands" + ";;" + 2 as String) + ";;" + 43 as String) + ";;" + 3 as String) + ";;0" ; #DEBUG_LINE_NO:165
  sOptions[28] = ((("Dick" + ";;" + 2 as String) + ";;" + 44 as String) + ";;" + 4 as String) + ";;0" ; #DEBUG_LINE_NO:166
  sOptions[29] = ((("Penis" + ";;" + 2 as String) + ";;" + 45 as String) + ";;" + 5 as String) + ";;0" ; #DEBUG_LINE_NO:167
  sOptions[30] = ((("Oral" + ";;" + 2 as String) + ";;" + 46 as String) + ";;" + 6 as String) + ";;0" ; #DEBUG_LINE_NO:168
  sOptions[31] = ((("Mouth" + ";;" + 2 as String) + ";;" + 47 as String) + ";;" + 7 as String) + ";;0" ; #DEBUG_LINE_NO:169
  sOptions[32] = ((("Breast" + ";;" + 2 as String) + ";;" + 48 as String) + ";;" + 8 as String) + ";;0" ; #DEBUG_LINE_NO:170
  sOptions[33] = ((("Boobs" + ";;" + 2 as String) + ";;" + 49 as String) + ";;" + 9 as String) + ";;0" ; #DEBUG_LINE_NO:171
  sOptions[34] = ((("Feet" + ";;" + 2 as String) + ";;" + 50 as String) + ";;" + 10 as String) + ";;0" ; #DEBUG_LINE_NO:172
  sOptions[35] = ((("Knees" + ";;" + 2 as String) + ";;" + 51 as String) + ";;" + 11 as String) + ";;0" ; #DEBUG_LINE_NO:173
  sOptions[36] = ((("Missionary" + ";;" + 3 as String) + ";;" + 60 as String) + ";;" + 0 as String) + ";;0" ; #DEBUG_LINE_NO:175
  sOptions[37] = ((("Cowgirl" + ";;" + 3 as String) + ";;" + 61 as String) + ";;" + 1 as String) + ";;0" ; #DEBUG_LINE_NO:176
  sOptions[38] = ((("ReverseCowgirl" + ";;" + 3 as String) + ";;" + 62 as String) + ";;" + 2 as String) + ";;0" ; #DEBUG_LINE_NO:177
  sOptions[39] = ((("RCowgirl" + ";;" + 3 as String) + ";;" + 63 as String) + ";;" + 3 as String) + ";;0" ; #DEBUG_LINE_NO:178
  sOptions[40] = ((("Riding" + ";;" + 3 as String) + ";;" + 64 as String) + ";;" + 4 as String) + ";;0" ; #DEBUG_LINE_NO:179
  sOptions[41] = ((("Doggystyle" + ";;" + 3 as String) + ";;" + 65 as String) + ";;" + 5 as String) + ";;0" ; #DEBUG_LINE_NO:180
  sOptions[42] = ((("Doggy" + ";;" + 3 as String) + ";;" + 66 as String) + ";;" + 6 as String) + ";;0" ; #DEBUG_LINE_NO:181
  sOptions[43] = ((("Standing" + ";;" + 3 as String) + ";;" + 67 as String) + ";;" + 7 as String) + ";;0" ; #DEBUG_LINE_NO:182
  sOptions[44] = ((("Sitting" + ";;" + 3 as String) + ";;" + 68 as String) + ";;" + 8 as String) + ";;0" ; #DEBUG_LINE_NO:183
  sOptions[45] = ((("Hugging" + ";;" + 3 as String) + ";;" + 69 as String) + ";;" + 9 as String) + ";;0" ; #DEBUG_LINE_NO:184
  sOptions[46] = ((("Cuddling" + ";;" + 3 as String) + ";;" + 70 as String) + ";;" + 10 as String) + ";;0" ; #DEBUG_LINE_NO:185
  sOptions[47] = ((("Holding" + ";;" + 3 as String) + ";;" + 71 as String) + ";;" + 11 as String) + ";;0" ; #DEBUG_LINE_NO:186
  sOptions[48] = ((("Facing" + ";;" + 3 as String) + ";;" + 72 as String) + ";;" + 12 as String) + ";;0" ; #DEBUG_LINE_NO:187
  sOptions[49] = ((("Kissing" + ";;" + 3 as String) + ";;" + 73 as String) + ";;" + 13 as String) + ";;0" ; #DEBUG_LINE_NO:188
  sOptions[50] = ((("Laying" + ";;" + 3 as String) + ";;" + 74 as String) + ";;" + 14 as String) + ";;0" ; #DEBUG_LINE_NO:189
  sOptions[51] = ((("Lying" + ";;" + 3 as String) + ";;" + 75 as String) + ";;" + 15 as String) + ";;0" ; #DEBUG_LINE_NO:190
  sOptions[52] = ((("Reverse" + ";;" + 3 as String) + ";;" + 76 as String) + ";;" + 16 as String) + ";;0" ; #DEBUG_LINE_NO:191
  sOptions[53] = ((("OnBack" + ";;" + 3 as String) + ";;" + 77 as String) + ";;" + 17 as String) + ";;0" ; #DEBUG_LINE_NO:192
  sOptions[54] = ((("Behind" + ";;" + 3 as String) + ";;" + 78 as String) + ";;" + 18 as String) + ";;0" ; #DEBUG_LINE_NO:193
  sOptions[55] = ((("Sleeping" + ";;" + 3 as String) + ";;" + 79 as String) + ";;" + 19 as String) + ";;0" ; #DEBUG_LINE_NO:194
  sOptions[56] = ((("Sideways" + ";;" + 3 as String) + ";;" + 80 as String) + ";;" + 20 as String) + ";;0" ; #DEBUG_LINE_NO:195
  sOptions[57] = ((("Spooning" + ";;" + 3 as String) + ";;" + 81 as String) + ";;" + 21 as String) + ";;0" ; #DEBUG_LINE_NO:196
  sOptions[58] = ((("Binding" + ";;" + 3 as String) + ";;" + 82 as String) + ";;" + 22 as String) + ";;0" ; #DEBUG_LINE_NO:197
  sOptions[59] = ((("Acrobatic" + ";;" + 3 as String) + ";;" + 83 as String) + ";;" + 23 as String) + ";;0" ; #DEBUG_LINE_NO:198
  sOptions[60] = ((("FF" + ";;" + 4 as String) + ";;" + 90 as String) + ";;" + 0 as String) + ";;0" ; #DEBUG_LINE_NO:200
  sOptions[61] = ((("MF" + ";;" + 4 as String) + ";;" + 91 as String) + ";;" + 1 as String) + ";;0" ; #DEBUG_LINE_NO:201
  sOptions[62] = ((("MM" + ";;" + 4 as String) + ";;" + 92 as String) + ";;" + 2 as String) + ";;0" ; #DEBUG_LINE_NO:202
  sOptions[63] = ((("Lesbian" + ";;" + 4 as String) + ";;" + 93 as String) + ";;" + 3 as String) + ";;0" ; #DEBUG_LINE_NO:203
  sOptions[64] = ((("Straight" + ";;" + 4 as String) + ";;" + 94 as String) + ";;" + 4 as String) + ";;0" ; #DEBUG_LINE_NO:204
  sOptions[65] = ((("Loving" + ";;" + 5 as String) + ";;" + 100 as String) + ";;" + 0 as String) + ";;0" ; #DEBUG_LINE_NO:206
  sOptions[66] = ((("Dirty" + ";;" + 5 as String) + ";;" + 101 as String) + ";;" + 1 as String) + ";;0" ; #DEBUG_LINE_NO:207
  sOptions[67] = ((("Fetish" + ";;" + 5 as String) + ";;" + 102 as String) + ";;" + 2 as String) + ";;0" ; #DEBUG_LINE_NO:208
  sOptions[68] = ((("Rough" + ";;" + 5 as String) + ";;" + 103 as String) + ";;" + 3 as String) + ";;0" ; #DEBUG_LINE_NO:209
  sOptions[69] = ((("Creampie" + ";;" + 6 as String) + ";;" + 110 as String) + ";;" + 0 as String) + ";;0" ; #DEBUG_LINE_NO:211
  sOptions[70] = ((("AnalCreampie" + ";;" + 6 as String) + ";;" + 111 as String) + ";;" + 1 as String) + ";;0" ; #DEBUG_LINE_NO:212
  sOptions[71] = ((("VaginalCum" + ";;" + 6 as String) + ";;" + 112 as String) + ";;" + 2 as String) + ";;0" ; #DEBUG_LINE_NO:213
  sOptions[72] = ((("AnalCum" + ";;" + 6 as String) + ";;" + 113 as String) + ";;" + 3 as String) + ";;0" ; #DEBUG_LINE_NO:214
  sOptions[73] = ((("Facial" + ";;" + 6 as String) + ";;" + 114 as String) + ";;" + 4 as String) + ";;0" ; #DEBUG_LINE_NO:215
  sOptions[74] = ((("CumInMouth" + ";;" + 6 as String) + ";;" + 115 as String) + ";;" + 5 as String) + ";;0" ; #DEBUG_LINE_NO:216
  sOptions[75] = ((("ChestCum" + ";;" + 6 as String) + ";;" + 116 as String) + ";;" + 6 as String) + ";;0" ; #DEBUG_LINE_NO:217
  sOptions[76] = ((("HandsCum" + ";;" + 6 as String) + ";;" + 117 as String) + ";;" + 7 as String) + ";;0" ; #DEBUG_LINE_NO:218
  sOptions[77] = ((("FeetCum" + ";;" + 6 as String) + ";;" + 118 as String) + ";;" + 8 as String) + ";;0" ; #DEBUG_LINE_NO:219
  sOptions[78] = ((("EatingCum" + ";;" + 6 as String) + ";;" + 119 as String) + ";;" + 9 as String) + ";;0" ; #DEBUG_LINE_NO:220
  sOptions[79] = ((("Default" + ";;" + 7 as String) + ";;" + 120 as String) + ";;" + 0 as String) + ";;0" ; #DEBUG_LINE_NO:222
  sOptions[80] = ((("LeadIn" + ";;" + 7 as String) + ";;" + 121 as String) + ";;" + 1 as String) + ";;0" ; #DEBUG_LINE_NO:223
  sOptions[81] = ((("Beds" + ";;" + 7 as String) + ";;" + 122 as String) + ";;" + 2 as String) + ";;0" ; #DEBUG_LINE_NO:224
  sOptions[82] = ((("BedOnly" + ";;" + 7 as String) + ";;" + 123 as String) + ";;" + 3 as String) + ";;0" ; #DEBUG_LINE_NO:225
  sOptions[83] = ((("Furniture" + ";;" + 7 as String) + ";;" + 124 as String) + ";;" + 4 as String) + ";;0" ; #DEBUG_LINE_NO:226
  sOptions[84] = ((("DomSub" + ";;" + 7 as String) + ";;" + 125 as String) + ";;" + 5 as String) + ";;0" ; #DEBUG_LINE_NO:227
  sOptions[85] = ((("Forced" + ";;" + 7 as String) + ";;" + 126 as String) + ";;" + 6 as String) + ";;0" ; #DEBUG_LINE_NO:228
  sOptions[86] = ((("Powerbomb" + ";;" + 7 as String) + ";;" + 127 as String) + ";;" + 7 as String) + ";;0" ; #DEBUG_LINE_NO:229
  sOptions[87] = ((("Muscle" + ";;" + 7 as String) + ";;" + 128 as String) + ";;" + 8 as String) + ";;0" ; #DEBUG_LINE_NO:230
  sOptions[88] = ((("AggressiveDefault" + ";;" + 7 as String) + ";;" + 129 as String) + ";;" + 9 as String) + ";;0" ; #DEBUG_LINE_NO:231
  sOptions[89] = ((("SexToy" + ";;" + 7 as String) + ";;" + 130 as String) + ";;" + 10 as String) + ";;0" ; #DEBUG_LINE_NO:232
  sOptions[90] = ((("AnimObject" + ";;" + 7 as String) + ";;" + 131 as String) + ";;" + 11 as String) + ";;0" ; #DEBUG_LINE_NO:233
  sOptions[91] = ((("3jiou" + ";;" + 8 as String) + ";;" + 140 as String) + ";;" + 0 as String) + ";;0" ; #DEBUG_LINE_NO:235
  sOptions[92] = ((("4uDIK" + ";;" + 8 as String) + ";;" + 141 as String) + ";;" + 1 as String) + ";;0" ; #DEBUG_LINE_NO:236
  sOptions[93] = ((("AP" + ";;" + 8 as String) + ";;" + 142 as String) + ";;" + 2 as String) + ";;0" ; #DEBUG_LINE_NO:237
  sOptions[94] = ((("Arrok" + ";;" + 8 as String) + ";;" + 143 as String) + ";;" + 3 as String) + ";;0" ; #DEBUG_LINE_NO:238
  sOptions[95] = ((("Athstai" + ";;" + 8 as String) + ";;" + 144 as String) + ";;" + 4 as String) + ";;0" ; #DEBUG_LINE_NO:239
  sOptions[96] = ((("Bleagh" + ";;" + 8 as String) + ";;" + 145 as String) + ";;" + 5 as String) + ";;0" ; #DEBUG_LINE_NO:240
  sOptions[97] = ((("FalloutBoy2" + ";;" + 8 as String) + ";;" + 146 as String) + ";;" + 6 as String) + ";;0" ; #DEBUG_LINE_NO:241
  sOptions[98] = ((("M2M" + ";;" + 8 as String) + ";;" + 147 as String) + ";;" + 7 as String) + ";;0" ; #DEBUG_LINE_NO:242
  sOptions[99] = ((("Mitos" + ";;" + 8 as String) + ";;" + 148 as String) + ";;" + 8 as String) + ";;0" ; #DEBUG_LINE_NO:243
  sOptions[100] = ((("Leito" + ";;" + 8 as String) + ";;" + 149 as String) + ";;" + 9 as String) + ";;0" ; #DEBUG_LINE_NO:244
  sOptions[101] = ((("Zyn" + ";;" + 8 as String) + ";;" + 150 as String) + ";;" + 10 as String) + ";;0" ; #DEBUG_LINE_NO:245
  Return sOptions ; #DEBUG_LINE_NO:246
EndFunction
String Function GetTagResult(Int i)
  If SKSE.GetPluginVersion("PSQ Appearance") >= 16777250
    Return PSQAppearance.FeedResult34(i)
  EndIf
  String TagResult
  If i == 9 ; #DEBUG_LINE_NO:251
    TagResult = "Aggressive" ; #DEBUG_LINE_NO:252
  ElseIf i == 20 ; #DEBUG_LINE_NO:253
    TagResult = "Sex" ; #DEBUG_LINE_NO:254
  ElseIf i == 21 ; #DEBUG_LINE_NO:255
    TagResult = "Foreplay" ; #DEBUG_LINE_NO:256
  ElseIf i == 22 ; #DEBUG_LINE_NO:257
    TagResult = "Licking" ; #DEBUG_LINE_NO:258
  ElseIf i == 23 ; #DEBUG_LINE_NO:259
    TagResult = "Cunnilingus" ; #DEBUG_LINE_NO:260
  ElseIf i == 24 ; #DEBUG_LINE_NO:261
    TagResult = "Petting" ; #DEBUG_LINE_NO:262
  ElseIf i == 25 ; #DEBUG_LINE_NO:263
    TagResult = "Blowjob" ; #DEBUG_LINE_NO:264
  ElseIf i == 26 ; #DEBUG_LINE_NO:265
    TagResult = "Handjob" ; #DEBUG_LINE_NO:266
  ElseIf i == 27 ; #DEBUG_LINE_NO:267
    TagResult = "Boobjob" ; #DEBUG_LINE_NO:268
  ElseIf i == 28 ; #DEBUG_LINE_NO:269
    TagResult = "Footjob" ; #DEBUG_LINE_NO:270
  ElseIf i == 29 ; #DEBUG_LINE_NO:271
    TagResult = "Breastfeeding" ; #DEBUG_LINE_NO:272
  ElseIf i == 30 ; #DEBUG_LINE_NO:273
    TagResult = "Kneeling" ; #DEBUG_LINE_NO:274
  ElseIf i == 31 ; #DEBUG_LINE_NO:275
    TagResult = "Fisting" ; #DEBUG_LINE_NO:276
  ElseIf i == 32 ; #DEBUG_LINE_NO:277
    TagResult = "Fondling" ; #DEBUG_LINE_NO:278
  ElseIf i == 33 ; #DEBUG_LINE_NO:279
    TagResult = "69" ; #DEBUG_LINE_NO:280
  ElseIf i == 40 ; #DEBUG_LINE_NO:281
    TagResult = "Vaginal" ; #DEBUG_LINE_NO:282
  ElseIf i == 41 ; #DEBUG_LINE_NO:283
    TagResult = "Pussy" ; #DEBUG_LINE_NO:284
  ElseIf i == 42 ; #DEBUG_LINE_NO:285
    TagResult = "Anal" ; #DEBUG_LINE_NO:286
  ElseIf i == 43 ; #DEBUG_LINE_NO:287
    TagResult = "Hands" ; #DEBUG_LINE_NO:288
  ElseIf i == 44 ; #DEBUG_LINE_NO:289
    TagResult = "Dick" ; #DEBUG_LINE_NO:290
  ElseIf i == 45 ; #DEBUG_LINE_NO:291
    TagResult = "Penis" ; #DEBUG_LINE_NO:292
  ElseIf i == 46 ; #DEBUG_LINE_NO:293
    TagResult = "Oral" ; #DEBUG_LINE_NO:294
  ElseIf i == 47 ; #DEBUG_LINE_NO:295
    TagResult = "Mouth" ; #DEBUG_LINE_NO:296
  ElseIf i == 48 ; #DEBUG_LINE_NO:297
    TagResult = "Breast" ; #DEBUG_LINE_NO:298
  ElseIf i == 49 ; #DEBUG_LINE_NO:299
    TagResult = "Boobs" ; #DEBUG_LINE_NO:300
  ElseIf i == 50 ; #DEBUG_LINE_NO:301
    TagResult = "Feet" ; #DEBUG_LINE_NO:302
  ElseIf i == 51 ; #DEBUG_LINE_NO:303
    TagResult = "Knees" ; #DEBUG_LINE_NO:304
  ElseIf i == 60 ; #DEBUG_LINE_NO:305
    TagResult = "Missionary" ; #DEBUG_LINE_NO:306
  ElseIf i == 61 ; #DEBUG_LINE_NO:307
    TagResult = "Cowgirl" ; #DEBUG_LINE_NO:308
  ElseIf i == 62 ; #DEBUG_LINE_NO:309
    TagResult = "ReverseCowgirl" ; #DEBUG_LINE_NO:310
  ElseIf i == 63 ; #DEBUG_LINE_NO:311
    TagResult = "RCowgirl" ; #DEBUG_LINE_NO:312
  ElseIf i == 64 ; #DEBUG_LINE_NO:313
    TagResult = "Riding" ; #DEBUG_LINE_NO:314
  ElseIf i == 65 ; #DEBUG_LINE_NO:315
    TagResult = "Doggystyle" ; #DEBUG_LINE_NO:316
  ElseIf i == 66 ; #DEBUG_LINE_NO:317
    TagResult = "Doggy" ; #DEBUG_LINE_NO:318
  ElseIf i == 67 ; #DEBUG_LINE_NO:319
    TagResult = "Standing" ; #DEBUG_LINE_NO:320
  ElseIf i == 68 ; #DEBUG_LINE_NO:321
    TagResult = "Sitting" ; #DEBUG_LINE_NO:322
  ElseIf i == 69 ; #DEBUG_LINE_NO:323
    TagResult = "Hugging" ; #DEBUG_LINE_NO:324
  ElseIf i == 70 ; #DEBUG_LINE_NO:325
    TagResult = "Cuddling" ; #DEBUG_LINE_NO:326
  ElseIf i == 71 ; #DEBUG_LINE_NO:327
    TagResult = "Holding" ; #DEBUG_LINE_NO:328
  ElseIf i == 72 ; #DEBUG_LINE_NO:329
    TagResult = "Facing" ; #DEBUG_LINE_NO:330
  ElseIf i == 73 ; #DEBUG_LINE_NO:331
    TagResult = "Kissing" ; #DEBUG_LINE_NO:332
  ElseIf i == 74 ; #DEBUG_LINE_NO:333
    TagResult = "Laying" ; #DEBUG_LINE_NO:334
  ElseIf i == 75 ; #DEBUG_LINE_NO:335
    TagResult = "Lying" ; #DEBUG_LINE_NO:336
  ElseIf i == 76 ; #DEBUG_LINE_NO:337
    TagResult = "Reverse" ; #DEBUG_LINE_NO:338
  ElseIf i == 77 ; #DEBUG_LINE_NO:339
    TagResult = "OnBack" ; #DEBUG_LINE_NO:340
  ElseIf i == 78 ; #DEBUG_LINE_NO:341
    TagResult = "Behind" ; #DEBUG_LINE_NO:342
  ElseIf i == 79 ; #DEBUG_LINE_NO:343
    TagResult = "Sleeping" ; #DEBUG_LINE_NO:344
  ElseIf i == 80 ; #DEBUG_LINE_NO:345
    TagResult = "Sideways" ; #DEBUG_LINE_NO:346
  ElseIf i == 81 ; #DEBUG_LINE_NO:347
    TagResult = "Spooning" ; #DEBUG_LINE_NO:348
  ElseIf i == 82 ; #DEBUG_LINE_NO:349
    TagResult = "Binding" ; #DEBUG_LINE_NO:350
  ElseIf i == 83 ; #DEBUG_LINE_NO:351
    TagResult = "Acrobatic" ; #DEBUG_LINE_NO:352
  ElseIf i == 90 ; #DEBUG_LINE_NO:353
    TagResult = "FF" ; #DEBUG_LINE_NO:354
  ElseIf i == 91 ; #DEBUG_LINE_NO:355
    TagResult = "MF" ; #DEBUG_LINE_NO:356
  ElseIf i == 92 ; #DEBUG_LINE_NO:357
    TagResult = "MM" ; #DEBUG_LINE_NO:358
  ElseIf i == 93 ; #DEBUG_LINE_NO:359
    TagResult = "Lesbian" ; #DEBUG_LINE_NO:360
  ElseIf i == 94 ; #DEBUG_LINE_NO:361
    TagResult = "Straight" ; #DEBUG_LINE_NO:362
  ElseIf i == 100 ; #DEBUG_LINE_NO:363
    TagResult = "Loving" ; #DEBUG_LINE_NO:364
  ElseIf i == 101 ; #DEBUG_LINE_NO:365
    TagResult = "Dirty" ; #DEBUG_LINE_NO:366
  ElseIf i == 102 ; #DEBUG_LINE_NO:367
    TagResult = "Fetish" ; #DEBUG_LINE_NO:368
  ElseIf i == 103 ; #DEBUG_LINE_NO:369
    TagResult = "Rough" ; #DEBUG_LINE_NO:370
  ElseIf i == 110 ; #DEBUG_LINE_NO:371
    TagResult = "Creampie" ; #DEBUG_LINE_NO:372
  ElseIf i == 111 ; #DEBUG_LINE_NO:373
    TagResult = "AnalCreampie" ; #DEBUG_LINE_NO:374
  ElseIf i == 112 ; #DEBUG_LINE_NO:375
    TagResult = "VaginalCum" ; #DEBUG_LINE_NO:376
  ElseIf i == 113 ; #DEBUG_LINE_NO:377
    TagResult = "AnalCum" ; #DEBUG_LINE_NO:378
  ElseIf i == 114 ; #DEBUG_LINE_NO:379
    TagResult = "Facial" ; #DEBUG_LINE_NO:380
  ElseIf i == 115 ; #DEBUG_LINE_NO:381
    TagResult = "CumInMouth" ; #DEBUG_LINE_NO:382
  ElseIf i == 116 ; #DEBUG_LINE_NO:383
    TagResult = "ChestCum" ; #DEBUG_LINE_NO:384
  ElseIf i == 117 ; #DEBUG_LINE_NO:385
    TagResult = "HandsCum" ; #DEBUG_LINE_NO:386
  ElseIf i == 118 ; #DEBUG_LINE_NO:387
    TagResult = "FeetCum" ; #DEBUG_LINE_NO:388
  ElseIf i == 119 ; #DEBUG_LINE_NO:389
    TagResult = "EatingCum" ; #DEBUG_LINE_NO:390
  ElseIf i == 120 ; #DEBUG_LINE_NO:391
    TagResult = "Default" ; #DEBUG_LINE_NO:392
  ElseIf i == 121 ; #DEBUG_LINE_NO:393
    TagResult = "LeadIn" ; #DEBUG_LINE_NO:394
  ElseIf i == 122 ; #DEBUG_LINE_NO:395
    TagResult = "Beds" ; #DEBUG_LINE_NO:396
  ElseIf i == 123 ; #DEBUG_LINE_NO:397
    TagResult = "BedOnly" ; #DEBUG_LINE_NO:398
  ElseIf i == 124 ; #DEBUG_LINE_NO:399
    TagResult = "Furniture" ; #DEBUG_LINE_NO:400
  ElseIf i == 125 ; #DEBUG_LINE_NO:401
    TagResult = "DomSub" ; #DEBUG_LINE_NO:402
  ElseIf i == 126 ; #DEBUG_LINE_NO:403
    TagResult = "Forced" ; #DEBUG_LINE_NO:404
  ElseIf i == 127 ; #DEBUG_LINE_NO:405
    TagResult = "Powerbomb" ; #DEBUG_LINE_NO:406
  ElseIf i == 128 ; #DEBUG_LINE_NO:407
    TagResult = "Muscle" ; #DEBUG_LINE_NO:408
  ElseIf i == 129 ; #DEBUG_LINE_NO:409
    TagResult = "AggressiveDefault" ; #DEBUG_LINE_NO:410
  ElseIf i == 130 ; #DEBUG_LINE_NO:411
    TagResult = "SexToy" ; #DEBUG_LINE_NO:412
  ElseIf i == 131 ; #DEBUG_LINE_NO:413
    TagResult = "AnimObject" ; #DEBUG_LINE_NO:414
  ElseIf i == 140 ; #DEBUG_LINE_NO:415
    TagResult = "3jiou" ; #DEBUG_LINE_NO:416
  ElseIf i == 141 ; #DEBUG_LINE_NO:417
    TagResult = "4uDIK" ; #DEBUG_LINE_NO:418
  ElseIf i == 142 ; #DEBUG_LINE_NO:419
    TagResult = "AP" ; #DEBUG_LINE_NO:420
  ElseIf i == 143 ; #DEBUG_LINE_NO:421
    TagResult = "Arrok" ; #DEBUG_LINE_NO:422
  ElseIf i == 144 ; #DEBUG_LINE_NO:423
    TagResult = "Athstai" ; #DEBUG_LINE_NO:424
  ElseIf i == 145 ; #DEBUG_LINE_NO:425
    TagResult = "Bleagh" ; #DEBUG_LINE_NO:426
  ElseIf i == 146 ; #DEBUG_LINE_NO:427
    TagResult = "FalloutBoy2" ; #DEBUG_LINE_NO:428
  ElseIf i == 147 ; #DEBUG_LINE_NO:429
    TagResult = "M2M" ; #DEBUG_LINE_NO:430
  ElseIf i == 148 ; #DEBUG_LINE_NO:431
    TagResult = "Mitos" ; #DEBUG_LINE_NO:432
  ElseIf i == 149 ; #DEBUG_LINE_NO:433
    TagResult = "Leito" ; #DEBUG_LINE_NO:434
  ElseIf i == 150 ; #DEBUG_LINE_NO:435
    TagResult = "Zyn" ; #DEBUG_LINE_NO:436
  EndIf
  Return TagResult ; #DEBUG_LINE_NO:438
EndFunction
