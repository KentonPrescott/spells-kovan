pragma solidity 0.5.12;

import "ds-math/math.sol";
import "ds-test/test.sol";
import "lib/dss-interfaces/src/Interfaces.sol";

import {DssSpell, SpellAction} from "./Kovan-DssSpell.sol";

interface Hevm {
    function warp(uint) external;
    function store(address,bytes32,bytes32) external;
}


contract DssSpellTest is DSTest, DSMath {
    // populate with kovan spell if needed
    address constant KOVAN_SPELL = address(0);
    // this needs to be updated
    uint256 constant SPELL_CREATED = 0;

    struct CollateralValues {
        uint256 line;
        uint256 dust;
        uint256 duty;
        uint256 chop;
        uint256 dunk;
        uint256 pct;
        uint256 mat;
        uint256 beg;
        uint48 ttl;
        uint48 tau;
        uint256 liquidations;
    }

    struct SystemValues {
        uint256 pot_dsr;
        uint256 pot_dsrPct;
        uint256 vat_Line;
        uint256 pause_delay;
        uint256 vow_wait;
        uint256 vow_dump;
        uint256 vow_sump;
        uint256 vow_bump;
        uint256 vow_hump;
        uint256 cat_box;
        mapping (bytes32 => CollateralValues) collaterals;
    }

    SystemValues afterSpell;

    Hevm hevm;

    // KOVAN ADDRESSES
    DSPauseAbstract      pause = DSPauseAbstract(    0x8754E6ecb4fe68DaA5132c2886aB39297a5c7189);
    address         pauseProxy =                     0x0e4725db88Bb038bBa4C4723e91Ba183BE11eDf3;
    DSChiefAbstract      chief = DSChiefAbstract(    0xbBFFC76e94B34F72D96D054b31f6424249c1337d);
    VatAbstract            vat = VatAbstract(        0xbA987bDB501d131f766fEe8180Da5d81b34b69d9);
    CatAbstract            cat = CatAbstract(        0xdDb5F7A3A5558b9a6a1f3382BD75E2268d1c6958);
    VowAbstract            vow = VowAbstract(        0x0F4Cbe6CBA918b7488C26E29d9ECd7368F38EA3b);
    PotAbstract            pot = PotAbstract(        0xEA190DBDC7adF265260ec4dA6e9675Fd4f5A78bb);
    JugAbstract            jug = JugAbstract(        0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD);
    SpotAbstract          spot = SpotAbstract(       0x3a042de6413eDB15F2784f2f97cC68C7E9750b2D);

    DSTokenAbstract        gov = DSTokenAbstract(    0xAaF64BFCC32d0F15873a02163e7E500671a4ffcD);
    EndAbstract            end = EndAbstract(        0x24728AcF2E2C403F5d2db4Df6834B8998e56aA5F);
    IlkRegistryAbstract    reg = IlkRegistryAbstract(0xedE45A0522CA19e979e217064629778d6Cc2d9Ea);

    OsmMomAbstract      osmMom = OsmMomAbstract(     0x5dA9D1C3d4f1197E5c52Ff963916Fe84D2F5d8f3);
    FlipperMomAbstract flipMom = FlipperMomAbstract( 0x50dC6120c67E456AdA2059cfADFF0601499cf681);

    // COMP-A specific
    DSTokenAbstract comp       = DSTokenAbstract(    0x1dDe24ACE93F9F638Bfd6fCE1B38b842703Ea1Aa);
    GemJoinAbstract joinCOMPA  = GemJoinAbstract(    0x16D567c1F6824ffFC460A11d48F61E010ae43766);
    OsmAbstract pipCOMP        = OsmAbstract(        0x08F29dCC1f4e6FD194c163FC9398742B3fF2BbE0);
    FlipAbstract flipCOMPA     = FlipAbstract(       0x2917a962BC45ED48497de85821bddD065794DF6C);
    // MedianAbstract medCOMPA      = MedianAbstract(   0x074EcAe0CD5c37f59D9b91E2994407418aCe05B7); // TODO: Add back in

    DssSpell spell;

    // CHEAT_CODE = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D
    bytes20 constant CHEAT_CODE =
        bytes20(uint160(uint256(keccak256('hevm cheat code'))));

    uint256 constant HUNDRED    = 10 ** 2;
    uint256 constant THOUSAND   = 10 ** 3;
    uint256 constant MILLION    = 10 ** 6;
    uint256 constant BILLION    = 10 ** 9;
    uint256 constant WAD        = 10 ** 18;
    uint256 constant RAY        = 10 ** 27;
    uint256 constant RAD        = 10 ** 45;

    // not provided in DSMath
    function rpow(uint x, uint n, uint b) internal pure returns (uint z) {
      assembly {
        switch x case 0 {switch n case 0 {z := b} default {z := 0}}
        default {
          switch mod(n, 2) case 0 { z := b } default { z := x }
          let half := div(b, 2)  // for rounding.
          for { n := div(n, 2) } n { n := div(n,2) } {
            let xx := mul(x, x)
            if iszero(eq(div(xx, x), x)) { revert(0,0) }
            let xxRound := add(xx, half)
            if lt(xxRound, xx) { revert(0,0) }
            x := div(xxRound, b)
            if mod(n,2) {
              let zx := mul(z, x)
              if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) { revert(0,0) }
              let zxRound := add(zx, half)
              if lt(zxRound, zx) { revert(0,0) }
              z := div(zxRound, b)
            }
          }
        }
      }
    }
    // 10^-5 (tenth of a basis point) as a RAY
    uint256 TOLERANCE = 10 ** 22;

    function yearlyYield(uint256 duty) public pure returns (uint256) {
        return rpow(duty, (365 * 24 * 60 *60), RAY);
    }

    function expectedRate(uint256 percentValue) public pure returns (uint256) {
        return (100000 + percentValue) * (10 ** 22);
    }

    function diffCalc(uint256 expectedRate_, uint256 yearlyYield_) public pure returns (uint256) {
        return (expectedRate_ > yearlyYield_) ? expectedRate_ - yearlyYield_ : yearlyYield_ - expectedRate_;
    }

    function setUp() public {
        hevm = Hevm(address(CHEAT_CODE));

        spell = KOVAN_SPELL != address(0) ? DssSpell(KOVAN_SPELL) : new DssSpell();

        //
        // Test for all system configuration changes
        //
        afterSpell = SystemValues({
            pot_dsr: 1000000000000000000000000000,
            pot_dsrPct: 0 * 1000,
            vat_Line: 770 * MILLION * RAD,
            pause_delay: 60,
            vow_wait: 3600,
            vow_dump: 2 * WAD,
            vow_sump: 50 * RAD,
            vow_bump: 10 * RAD,
            vow_hump: 500 * RAD,
            cat_box: 10 * THOUSAND * RAD
        });

        //
        // Test for all collateral based changes here
        //
        afterSpell.collaterals["ETH-A"] = CollateralValues({
            line:         540 * MILLION * RAD,
            dust:         100 * RAD,
            duty:         1000000002440418608258400030,
            pct:          8 * 1000,
            chop:         113 * WAD / 100,
            dunk:         500 * RAD,
            mat:          150 * RAY / 100,
            beg:          103 * WAD / 100,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["BAT-A"] = CollateralValues({
            line:         5 * MILLION * RAD,
            dust:         100 * RAD,
            duty:         1000000000000000000000000000,
            pct:          0 * 1000,
            chop:         113 * WAD / 100,
            dunk:         500 * RAD,
            mat:          150 * RAY / 100,
            beg:          103 * WAD / 100,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["USDC-A"] = CollateralValues({
            line:         40 * MILLION * RAD,
            dust:         100 * RAD,
            duty:         1000000000000000000000000000,
            pct:          0,
            chop:         113 * WAD / 100,
            dunk:         500 * RAD,
            mat:          110 * RAY / 100,
            beg:          103 * WAD / 100,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 0
        });
        afterSpell.collaterals["USDC-B"] = CollateralValues({
            line:         30 * MILLION * RAD,
            dust:         100 * RAD,
            duty:         1000000011562757347033522598,
            pct:          44 * 1000,
            chop:         113 * WAD / 100,
            dunk:         500 * RAD,
            mat:          120 * RAY / 100,
            beg:          103 * WAD / 100,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 0
        });
        afterSpell.collaterals["WBTC-A"] = CollateralValues({
            line:         120 * MILLION * RAD,
            dust:         100 * RAD,
            duty:         1000000000000000000000000000,
            pct:          0,
            chop:         113 * WAD / 100,
            dunk:         500 * RAD,
            mat:          150 * RAY / 100,
            beg:          103 * WAD / 100,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["TUSD-A"] = CollateralValues({
            line:         2 * MILLION * RAD,
            dust:         100 * RAD,
            duty:         1000000000000000000000000000,
            pct:          0 * 1000,
            chop:         113 * WAD / 100,
            dunk:         500 * RAD,
            mat:          120 * RAY / 100,
            beg:          103 * WAD / 100,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 0
        });
        afterSpell.collaterals["KNC-A"] = CollateralValues({
            line:         5 * MILLION * RAD,
            dust:         100 * RAD,
            duty:         1000000000000000000000000000,
            pct:          0,
            chop:         113 * WAD / 100,
            dunk:         500 * RAD,
            mat:          175 * RAY / 100,
            beg:          103 * WAD / 100,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["ZRX-A"] = CollateralValues({
            line:         5 * MILLION * RAD,
            dust:         100 * RAD,
            duty:         1000000000000000000000000000,
            pct:          0,
            chop:         113 * WAD / 100,
            dunk:         500 * RAD,
            mat:          175 * RAY / 100,
            beg:          103 * WAD / 100,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["MANA-A"] = CollateralValues({
            line:         1 * MILLION * RAD,
            dust:         100 * RAD,
            duty:         1000000001847694957439350562,
            pct:          6 * 1000,
            chop:         113 * WAD / 100,
            dunk:         500 * RAD,
            mat:          175 * RAY / 100,
            beg:          103 * WAD / 100,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["USDT-A"] = CollateralValues({
            line:         10 * MILLION * RAD,
            dust:         100 * RAD,
            duty:         1000000001847694957439350562, // 6% SF
            pct:          6 * 1000,
            chop:         113 * WAD / 100,
            dunk:         500 * RAD,
            mat:          150 * RAY / 100,
            beg:          103 * WAD / 100,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["PAXUSD-A"] = CollateralValues({
            line:         5 * MILLION * RAD,
            dust:         100 * RAD,
            duty:         1000000000627937192491029810, // 2% SF
            pct:          2 * 1000,
            chop:         113 * WAD / 100,
            dunk:         500 * RAD,
            mat:          120 * RAY / 100,
            beg:          103 * WAD / 100,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 0
        });
        afterSpell.collaterals["COMP-A"] = CollateralValues({
            line:         7 * MILLION * RAD,
            dust:         100 * RAD,
            duty:         1000000000315522921573372069, // 1% SF
            pct:          1 * 1000,
            chop:         113 * WAD / 100,
            dunk:         500 * RAD,
            mat:          175 * RAY / 100,
            beg:          103 * WAD / 100,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
    }

    function vote() private {
        if (chief.hat() != address(spell)) {
            hevm.store(
                address(gov),
                keccak256(abi.encode(address(this), uint256(1))),
                bytes32(uint256(999999999999 ether))
            );
            gov.approve(address(chief), uint256(-1));
            chief.lock(sub(gov.balanceOf(address(this)), 1 ether));

            assertTrue(!spell.done());

            address[] memory yays = new address[](1);
            yays[0] = address(spell);

            chief.vote(yays);
            chief.lift(address(spell));
        }
        assertEq(chief.hat(), address(spell));
    }

    function scheduleWaitAndCast() public {
        spell.schedule();
        hevm.warp(now + pause.delay());
        spell.cast();
    }

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }

    function checkSystemValues(SystemValues storage values) internal {
        // dsr
        assertEq(pot.dsr(), values.pot_dsr);
        // make sure dsr is less than 100% APR
        // bc -l <<< 'scale=27; e( l(2.00)/(60 * 60 * 24 * 365) )'
        // 1000000021979553151239153027
        assertTrue(
            pot.dsr() >= RAY && pot.dsr() < 1000000021979553151239153027
        );
        assertTrue(diffCalc(expectedRate(values.pot_dsrPct), yearlyYield(values.pot_dsr)) <= TOLERANCE);

        // Line
        assertEq(vat.Line(), values.vat_Line);
        assertTrue(
            (vat.Line() >= RAD && vat.Line() < BILLION * RAD) ||
            vat.Line() == 0
        );

        // Pause delay
        assertEq(pause.delay(), values.pause_delay);

        // wait
        assertEq(vow.wait(), values.vow_wait);

        // dump
        assertEq(vow.dump(), values.vow_dump);
        assertTrue(
            (vow.dump() >= WAD && vow.dump() < 2 * THOUSAND * WAD) ||
            vow.dump() == 0
        );

        // sump
        assertEq(vow.sump(), values.vow_sump);
        assertTrue(
            (vow.sump() >= RAD && vow.sump() < 500 * THOUSAND * RAD) ||
            vow.sump() == 0
        );

        // bump
        assertEq(vow.bump(), values.vow_bump);
        assertTrue(
            (vow.bump() >= RAD && vow.bump() < HUNDRED * THOUSAND * RAD) ||
            vow.bump() == 0
        );

        // hump
        assertEq(vow.hump(), values.vow_hump);
        assertTrue(
            (vow.hump() >= RAD && vow.hump() < HUNDRED * MILLION * RAD) ||
            vow.hump() == 0
        );
    }

    function checkCollateralValues(bytes32 ilk, SystemValues storage values) internal {
        (uint duty,)  = jug.ilks(ilk);
        assertEq(duty,   values.collaterals[ilk].duty);
        // make sure duty is less than 1000% APR
        // bc -l <<< 'scale=27; e( l(10.00)/(60 * 60 * 24 * 365) )'
        // 1000000073014496989316680335
        assertTrue(duty >= RAY && duty < 1000000073014496989316680335);  // gt 0 and lt 1000%
        assertTrue(diffCalc(expectedRate(values.collaterals[ilk].pct), yearlyYield(values.collaterals[ilk].duty)) <= TOLERANCE);
        assertTrue(values.collaterals[ilk].pct < THOUSAND * THOUSAND);   // check value lt 1000%

        (,,, uint line, uint dust) = vat.ilks(ilk);
        assertEq(line, values.collaterals[ilk].line);
        assertTrue((line >= RAD && line < BILLION * RAD) || line == 0);  // eq 0 or gt eq 1 RAD and lt 1B
        assertEq(dust, values.collaterals[ilk].dust);
        assertTrue((dust >= RAD && dust < 10 * THOUSAND * RAD) || dust == 0); // eq 0 or gt eq 1 and lt 10k

        (, uint chop, uint dunk) = cat.ilks(ilk);
        assertEq(chop, values.collaterals[ilk].chop);
        // make sure chop is less than 100%
        assertTrue(chop >= WAD && chop < 2 * WAD);   // penalty gt eq 0% and lt 100%
        assertEq(dunk, values.collaterals[ilk].dunk);
        // put back in after LIQ-1.2
        assertTrue(dunk >= RAD && dunk < MILLION * RAD);

        (,uint mat) = spot.ilks(ilk);
        assertEq(mat, values.collaterals[ilk].mat);
        assertTrue(mat >= RAY && mat < 10 * RAY);    // cr eq 100% and lt 1000%

        (address flipper,,) = cat.ilks(ilk);
        FlipAbstract flip = FlipAbstract(flipper);
        assertEq(uint(flip.beg()), values.collaterals[ilk].beg);
        assertTrue(flip.beg() >= WAD && flip.beg() < 105 * WAD / 100);  // gt eq 0% and lt 5%
        assertEq(uint(flip.ttl()), values.collaterals[ilk].ttl);
        assertTrue(flip.ttl() >= 600 && flip.ttl() < 10 hours);         // gt eq 10 minutes and lt 10 hours
        assertEq(uint(flip.tau()), values.collaterals[ilk].tau);
        assertTrue(flip.tau() >= 600 && flip.tau() <= 1 hours);          // gt eq 10 minutes and lt eq 1 hours

        assertEq(flip.wards(address(cat)), values.collaterals[ilk].liquidations);  // liquidations == 1 => on
    }

    function checkNewlyOnboardedCollateral_COMP_A() public {
        // pipCOMP.poke();
        // hevm.warp(now + 3601); // TODO: Add back
        // pipCOMP.poke();
        spot.poke("COMP-A");

        hevm.store(
            address(comp),
            keccak256(abi.encode(address(this), uint256(1))),
            bytes32(uint256(1 * THOUSAND * WAD))
        );

        // check median matches pip.src()
        // assertEq(pipCOMP.src(), address(medCOMPA)); // TODO: Add back

        // Authorization
        assertEq(joinCOMPA.wards(pauseProxy), 1);
        assertEq(vat.wards(address(joinCOMPA)), 1);
        assertEq(flipCOMPA.wards(address(end)), 1);
        assertEq(flipCOMPA.wards(address(flipMom)), 1);
        // assertEq(pipCOMP.wards(address(osmMom)), 1);
        // assertEq(pipCOMP.bud(address(spot)), 1);
        // assertEq(pipCOMP.bud(address(end)), 1);
        // assertEq(MedianAbstract(pipCOMP.src()).bud(address(pipCOMP)), 1);

        // Join to adapter
        assertEq(comp.balanceOf(address(this)), 1 * THOUSAND * WAD);
        assertEq(vat.gem("COMP-A", address(this)), 0);
        comp.approve(address(joinCOMPA), 1 * THOUSAND * WAD);
        joinCOMPA.join(address(this), 1 * THOUSAND * WAD);
        assertEq(comp.balanceOf(address(this)), 0);
        assertEq(vat.gem("COMP-A", address(this)), 1 * THOUSAND * WAD);

        // Deposit collateral, generate DAI
        assertEq(vat.dai(address(this)), 0);
        vat.frob("COMP-A", address(this), address(this), address(this), int(1 * THOUSAND * WAD), int(100 * WAD));
        assertEq(vat.gem("COMP-A", address(this)), 0);
        assertEq(vat.dai(address(this)), 100 * RAD);

        // Payback DAI, withdraw collateral
        vat.frob("COMP-A", address(this), address(this), address(this), -int(1 * THOUSAND * WAD), -int(100 * WAD));
        assertEq(vat.gem("COMP-A", address(this)), 1 * THOUSAND * WAD);
        assertEq(vat.dai(address(this)), 0);

        // Withdraw from adapter
        joinCOMPA.exit(address(this), 1 * THOUSAND * WAD);
        assertEq(comp.balanceOf(address(this)), 1 * THOUSAND * WAD);
        assertEq(vat.gem("COMP-A", address(this)), 0);

        // Generate new DAI to force a liquidation
        comp.approve(address(joinCOMPA), 1 * THOUSAND * WAD);
        joinCOMPA.join(address(this), 1 * THOUSAND * WAD);
        (,,uint256 spotV,,) = vat.ilks("COMP-A");
        // dart max amount of DAI
        vat.frob("COMP-A", address(this), address(this), address(this), int(1 * THOUSAND * WAD), int(mul(1 * THOUSAND * WAD, spotV) / RAY));
        hevm.warp(now + 1);
        jug.drip("COMP-A");
        assertEq(flipCOMPA.kicks(), 0);
        cat.bite("COMP-A", address(this));
        assertEq(flipCOMPA.kicks(), 1);
    }

    function testSpellIsCast() public {
        string memory description = new DssSpell().description();
        assertTrue(bytes(description).length > 0);
        // DS-Test can't handle strings directly, so cast to a bytes32.
        assertEq(stringToBytes32(spell.description()),
                stringToBytes32(description));

        if(address(spell) != address(KOVAN_SPELL)) {
            assertEq(spell.expiration(), (now + 30 days));
        } else {
            assertEq(spell.expiration(), (SPELL_CREATED + 30 days));
        }

        vote();
        scheduleWaitAndCast();
        assertTrue(spell.done());

        checkSystemValues(afterSpell);

        bytes32[] memory ilks = reg.list();
        for(uint i = 0; i < ilks.length; i++) {
            checkCollateralValues(ilks[i],  afterSpell);
        }

        checkNewlyOnboardedCollateral_COMP_A();
    }

}
