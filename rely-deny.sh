#!/usr/bin/env bash
set -e

export MCD_VAT=0xbA987bDB501d131f766fEe8180Da5d81b34b69d9
export MCD_VOW=0x0F4Cbe6CBA918b7488C26E29d9ECd7368F38EA3b
export MCD_CAT=0x0511674A67192FE51e86fE55Ed660eB4f995BDd6
export MCD_JUG=0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD
export MCD_POT=0xEA190DBDC7adF265260ec4dA6e9675Fd4f5A78bb
export MCD_PAUSE_PROXY=0x0e4725db88Bb038bBa4C4723e91Ba183BE11eDf3

export MCD_SPOT=0x3a042de6413eDB15F2784f2f97cC68C7E9750b2D
export MCD_END=0x24728AcF2E2C403F5d2db4Df6834B8998e56aA5F
export FLIPPER_MOM=0xf3828caDb05E5F22844f6f9314D99516D68a0C84

export MCD_FLAP=0xc6d3C83A080e2Ef16E4d7d4450A869d0891024F5
export MCD_FLOP=0x52482a3100F79FC568eb2f38C4a45ba457FBf5fA
export MCD_FLAP_OLD=0x064cd5f762851b1af81Fd8fcA837227cb3eC84b4
export MCD_FLOP_OLD=0x145B00b1AC4F01E84594EFa2972Fce1f5Beb5CED

export ETH_A_FLIP=0xc78EdADA7e8bEa29aCc3a31bBA1D516339deD350
export ETH_A_FLIP_OLD=0xB40139Ea36D35d0C9F6a2e62601B616F1FfbBD1b

export BAT_A_FLIP=0xcf4D650679a23ec4027f6675c7245d02fbFc7Da3
export BAT_A_FLIP_OLD=0xC94014A032cA5fCc01271F4519Add7E87a16b94C

export USDC_A_FLIP=0x157c2552165fE6e1003981076eAA20F6e0a2B30F
export USDC_A_FLIP_OLD=0x45d5b4A304f554262539cfd167dd05e331Da686E

export USDC_B_FLIP=0x8ceC95bB1758Ff2126e63a85ffC3C3c0F3717ea1
export USDC_B_FLIP_OLD=0x93AE217b0C6bF52E9FFea6Ab191cCD438d9EC0de

export WBTC_A_FLIP=0x21926b5aeC6732B87985376cCb9308823E7e377b
export WBTC_A_FLIP_OLD=0xc45A1b76D3316D56a0225fB02Ab6b7637403fF67

export ZRX_A_FLIP=0xdc181998D4d4aF194a16b59a3a018017F624D5C4
export ZRX_A_FLIP_OLD=0x1341E0947D03Fd2C24e16aaEDC347bf9D9af002F

export KNC_A_FLIP=0x675597341Cb21Bdbb69A5Aa18C9638eaa5DC06d6
export KNC_A_FLIP_OLD=0xf14Ec3538C86A31bBf576979783a8F6dbF16d571

export TUSD_A_FLIP=0x72bE7125B1CFf0dA9D6AD98e9e14d560F57FaAd2
export TUSD_A_FLIP_OLD=0x51a8fB578E830c932A2D49927584C643Ad08d9eC

echo 'Relying on pause proxy...'
seth send $ETH_A_FLIP 'rely(address)' $MCD_PAUSE_PROXY
seth send $BAT_A_FLIP 'rely(address)' $MCD_PAUSE_PROXY
seth send $USDC_A_FLIP 'rely(address)' $MCD_PAUSE_PROXY
seth send $USDC_B_FLIP 'rely(address)' $MCD_PAUSE_PROXY
seth send $WBTC_A_FLIP 'rely(address)' $MCD_PAUSE_PROXY
seth send $ZRX_A_FLIP 'rely(address)' $MCD_PAUSE_PROXY
seth send $KNC_A_FLIP 'rely(address)' $MCD_PAUSE_PROXY
seth send $TUSD_A_FLIP 'rely(address)' $MCD_PAUSE_PROXY
seth send $MCD_FLAP 'rely(address)' $MCD_PAUSE_PROXY
seth send $MCD_FLOP 'rely(address)' $MCD_PAUSE_PROXY

echo '\nChecking relies'
echo ETH-A:  $(seth call $ETH_A_FLIP 'wards(address)(uint)' $MCD_PAUSE_PROXY)
echo BAT-A:  $(seth call $BAT_A_FLIP 'wards(address)(uint)' $MCD_PAUSE_PROXY)
echo USDC-A: $(seth call $USDC_A_FLIP 'wards(address)(uint)' $MCD_PAUSE_PROXY)
echo USDC-B: $(seth call $USDC_B_FLIP 'wards(address)(uint)' $MCD_PAUSE_PROXY)
echo WBTC-A: $(seth call $WBTC_A_FLIP 'wards(address)(uint)' $MCD_PAUSE_PROXY)
echo ZRX-A:  $(seth call $ZRX_A_FLIP 'wards(address)(uint)' $MCD_PAUSE_PROXY)
echo KNC-A:  $(seth call $KNC_A_FLIP 'wards(address)(uint)' $MCD_PAUSE_PROXY)
echo TUSD-A: $(seth call $TUSD_A_FLIP 'wards(address)(uint)' $MCD_PAUSE_PROXY)
echo FLAP:   $(seth call $MCD_FLAP 'wards(address)(uint)' $MCD_PAUSE_PROXY)
echo FLOP:   $(seth call $MCD_FLOP 'wards(address)(uint)' $MCD_PAUSE_PROXY)

echo 'Denying deployer address...'
seth send $ETH_A_FLIP 'deny(address)' $ETH_FROM
seth send $BAT_A_FLIP 'deny(address)' $ETH_FROM
seth send $USDC_A_FLIP 'deny(address)' $ETH_FROM
seth send $USDC_B_FLIP 'deny(address)' $ETH_FROM
seth send $WBTC_A_FLIP 'deny(address)' $ETH_FROM
seth send $ZRX_A_FLIP 'deny(address)' $ETH_FROM
seth send $KNC_A_FLIP 'deny(address)' $ETH_FROM
seth send $TUSD_A_FLIP 'deny(address)' $ETH_FROM
seth send $MCD_FLAP 'deny(address)' $ETH_FROM
seth send $MCD_FLOP 'deny(address)' $ETH_FROM

echo '\nChecking denies'
echo ETH-A:  $(seth call $ETH_A_FLIP 'wards(address)(uint)' $ETH_FROM)
echo BAT-A:  $(seth call $BAT_A_FLIP 'wards(address)(uint)' $ETH_FROM)
echo USDC-A: $(seth call $USDC_A_FLIP 'wards(address)(uint)' $ETH_FROM)
echo USDC-B: $(seth call $USDC_B_FLIP 'wards(address)(uint)' $ETH_FROM)
echo WBTC-A: $(seth call $WBTC_A_FLIP 'wards(address)(uint)' $ETH_FROM)
echo ZRX-A:  $(seth call $ZRX_A_FLIP 'wards(address)(uint)' $ETH_FROM)
echo KNC-A:  $(seth call $KNC_A_FLIP 'wards(address)(uint)' $ETH_FROM)
echo TUSD-A: $(seth call $TUSD_A_FLIP 'wards(address)(uint)' $ETH_FROM)
echo FLAP:   $(seth call $MCD_FLAP 'wards(address)(uint)' $ETH_FROM)
echo FLOP:   $(seth call $MCD_FLOP 'wards(address)(uint)' $ETH_FROM)