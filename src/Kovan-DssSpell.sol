// Copyright (C) 2020 Maker Ecosystem Growth Holdings, INC.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity 0.5.12;

import "lib/dss-interfaces/src/dapp/DSPauseAbstract.sol";
import "lib/dss-interfaces/src/dss/VatAbstract.sol";
import "lib/dss-interfaces/src/dss/IlkRegistryAbstract.sol";
import "lib/dss-interfaces/src/dss/CatAbstract.sol";
import "lib/dss-interfaces/src/dss/EndAbstract.sol";
import "lib/dss-interfaces/src/dss/JugAbstract.sol";
import "lib/dss-interfaces/src/dss/FlipAbstract.sol";
import "lib/dss-interfaces/src/dss/FlapAbstract.sol";
import "lib/dss-interfaces/src/dss/FlopAbstract.sol";
import "lib/dss-interfaces/src/dss/SpotAbstract.sol";
import "lib/dss-interfaces/src/dss/OsmAbstract.sol";
import "lib/dss-interfaces/src/dss/OsmMomAbstract.sol";
import "lib/dss-interfaces/src/dss/MedianAbstract.sol";
import "lib/dss-interfaces/src/dss/GemJoinAbstract.sol";
import "lib/dss-interfaces/src/dss/FlipperMomAbstract.sol";
import "lib/dss-interfaces/src/dss/VowAbstract.sol";
import "lib/dss-interfaces/src/dss/MkrAuthorityAbstract.sol";

contract SpellAction {

    string constant public description = "Kovan Spell Deploy 2020-08-21";

    // KOVAN ADDRESSES
    //
    // The contracts in this list should correspond to MCD core contracts, verify
    // against the current release list at:
    //     https://changelog.makerdao.com/releases/kovan/1.0.9/contracts.json

    address constant MCD_VAT             = 0xbA987bDB501d131f766fEe8180Da5d81b34b69d9;
    address constant MCD_VOW             = 0x0F4Cbe6CBA918b7488C26E29d9ECd7368F38EA3b;
    address constant MCD_JUG             = 0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD;
    address constant ILK_REGISTRY        = 0x6618BD7bBaBFacC518Fdec43542E4a73629B0819;
    address constant MCD_SPOT            = 0x3a042de6413eDB15F2784f2f97cC68C7E9750b2D;
    address constant MCD_END             = 0x24728AcF2E2C403F5d2db4Df6834B8998e56aA5F;
    address constant FLIPPER_MOM         = 0xf3828caDb05E5F22844f6f9314D99516D68a0C84;
    address constant OSM_MOM             = 0x5dA9D1C3d4f1197E5c52Ff963916Fe84D2F5d8f3;

    address constant MCD_CAT             = 0xdDb5F7A3A5558b9a6a1f3382BD75E2268d1c6958;
    address constant MCD_CAT_OLD         = 0x0511674A67192FE51e86fE55Ed660eB4f995BDd6;

    address constant MCD_FLIP_ETH_A      = 0x750295A8db0580F32355f97de7918fF538c818F1;
    address constant MCD_FLIP_ETH_A_OLD  = 0xc78EdADA7e8bEa29aCc3a31bBA1D516339deD350;

    address constant MCD_FLIP_BAT_A      = 0x44Acf0eb2C7b9F0B55723e5289437AefE8ef7a1c;
    address constant MCD_FLIP_BAT_A_OLD  = 0xc0126c3383777bDc175E659A51020E56307dDe21;

    address constant MCD_FLIP_USDC_A     = 0x17C144eaC1B3D6777eF2C3fA1F98e3BC3c18DB4F;
    address constant MCD_FLIP_USDC_A_OLD = 0xc29Ad1913C3B415497fdA1eA15c132502B8fa372;

    address constant MCD_FLIP_USDC_B     = 0x6DCd745D91AB422e962d08Ed1a9242adB47D8d0C;
    address constant MCD_FLIP_USDC_B_OLD = 0x3c9eF711B68882d9732F60758e7891AcEae2Aa7c;

    address constant MCD_FLIP_WBTC_A     = 0x80Fb08f2EF268f491D6B58438326a3006C1a0e09;
    address constant MCD_FLIP_WBTC_A_OLD = 0x28dd4263e1FcE04A9016Bd7BF71a4f0F7aB93810;

    address constant MCD_FLIP_ZRX_A      = 0x798eB3126f1d5cb54743E3e93D3512C58f461084;
    address constant MCD_FLIP_ZRX_A_OLD  = 0xe07F1219f7d6ccD59431a6b151179A9181e3902c;

    address constant MCD_FLIP_KNC_A      = 0xF2c21882Bd14A5F7Cb46291cf3c86E53057FaD06;
    address constant MCD_FLIP_KNC_A_OLD  = 0x644699674D06cF535772D0DC19Ad5EA695000F51;

    address constant MCD_FLIP_TUSD_A     = 0x867711f695e11663eC8adCFAAD2a152eFBA56dfD;
    address constant MCD_FLIP_TUSD_A_OLD = 0xD4A145d161729A4B43B7Ab7DD683cB9A16E01a1b;

    address constant MCD_FLIP_MANA_A     = 0xb2B7430D49D2D2e7abb6a6B4699B2659c141A2a6;
    address constant MCD_FLIP_MANA_A_OLD = 0x5CB9D33A9fE5244019e6F5f45e68F18600805264;

    // Decimals & precision
    uint256 constant THOUSAND = 10 ** 3;
    uint256 constant MILLION  = 10 ** 6;
    uint256 constant WAD      = 10 ** 18;
    uint256 constant RAY      = 10 ** 27;
    uint256 constant RAD      = 10 ** 45;

    function execute() external {
        bytes32 ilk;
        FlipAbstract newFlip;
        FlipAbstract oldFlip;
        CatAbstract  oldCat = CatAbstract(MCD_CAT_OLD);
        CatAbstract  newCat = CatAbstract(MCD_CAT);
        VatAbstract     vat = VatAbstract(MCD_VAT);
        VowAbstract     vow = VowAbstract(MCD_VOW);
        EndAbstract     end = EndAbstract(MCD_END);

        uint256 box  = 100 * MILLION * RAD;  // TODO: Change this
        uint256 chop = 113 * WAD / 100;      // TODO: Change this
        uint256 dunk = 100 * THOUSAND * RAD; // TODO: Change this

        // TODO: Do we need oldFlip for anything anymore?
        // TODO: Determine chop/dunk values for each collateral type
        
        /*** Update Cat ***/
        newCat.file("vow", oldCat.vow());
        vat.rely(address(newCat));
        vat.deny(address(oldCat));
        vow.rely(address(newCat));
        vow.deny(address(oldCat));
        end.file("cat", address(newCat));
        newCat.rely(address(end));
        newCat.file("box", box);


        /*** ETH-A Flip ***/
        ilk = "ETH-A";
        newFlip = FlipAbstract(MCD_FLIP_ETH_A);
        oldFlip = FlipAbstract(MCD_FLIP_ETH_A_OLD);

        newCat.file(ilk, "flip", address(newFlip));
        newCat.file(ilk, "chop", chop);
        newCat.file(ilk, "dunk", dunk);
        newCat.rely(address(newFlip));

        newFlip.rely(address(newCat));
        newFlip.rely(MCD_END);
        newFlip.rely(FLIPPER_MOM);
        newFlip.file("beg", oldFlip.beg());
        newFlip.file("ttl", oldFlip.ttl());
        newFlip.file("tau", oldFlip.tau());
        require(newFlip.ilk() == ilk, "non-matching-ilk");
        require(newFlip.cat() == address(newCat), "non-matching-cat");
        require(newFlip.vat() == MCD_VAT, "non-matching-vat");


        /*** BAT-A Flip ***/
        ilk = "BAT-A";
        newFlip = FlipAbstract(MCD_FLIP_BAT_A);
        oldFlip = FlipAbstract(MCD_FLIP_BAT_A_OLD);

        newCat.file(ilk, "flip", address(newFlip));
        newCat.file(ilk, "chop", chop);
        newCat.file(ilk, "dunk", dunk);
        newCat.rely(address(newFlip));

        newFlip.rely(address(newCat));
        newFlip.rely(MCD_END);
        newFlip.rely(FLIPPER_MOM);
        newFlip.file("beg", oldFlip.beg());
        newFlip.file("ttl", oldFlip.ttl());
        newFlip.file("tau", oldFlip.tau());
        require(newFlip.ilk() == ilk, "non-matching-ilk");
        require(newFlip.cat() == address(newCat), "non-matching-cat");
        require(newFlip.vat() == MCD_VAT, "non-matching-vat");


        /*** USDC-A Flip ***/
        ilk = "USDC-A";
        newFlip = FlipAbstract(MCD_FLIP_USDC_A);
        oldFlip = FlipAbstract(MCD_FLIP_USDC_A_OLD);

        newCat.file(ilk, "flip", address(newFlip));
        newCat.file(ilk, "chop", chop);
        newCat.file(ilk, "dunk", dunk);
        newCat.rely(address(newFlip));

        newFlip.rely(address(newCat)); // This will be denied after via FlipperMom, just doing this for explicitness
        newFlip.rely(MCD_END);
        newFlip.rely(FLIPPER_MOM);
        newFlip.file("beg", oldFlip.beg());
        newFlip.file("ttl", oldFlip.ttl());
        newFlip.file("tau", oldFlip.tau());
        require(newFlip.ilk() == ilk, "non-matching-ilk");
        require(newFlip.cat() == address(newCat), "non-matching-cat");
        require(newFlip.vat() == MCD_VAT, "non-matching-vat");
        FlipperMomAbstract(FLIPPER_MOM).deny(MCD_FLIP_USDC_A);


        /*** USDC-B Flip ***/
        ilk = "USDC-B";
        newFlip = FlipAbstract(MCD_FLIP_USDC_B);
        oldFlip = FlipAbstract(MCD_FLIP_USDC_B_OLD);

        newCat.file(ilk, "flip", address(newFlip));
        newCat.file(ilk, "chop", chop);
        newCat.file(ilk, "dunk", dunk);
        newCat.rely(address(newFlip));

        newFlip.rely(address(newCat)); // This will be denied after via FlipperMom, just doing this for explicitness
        newFlip.rely(MCD_END);
        newFlip.rely(FLIPPER_MOM);
        newFlip.file("beg", oldFlip.beg());
        newFlip.file("ttl", oldFlip.ttl());
        newFlip.file("tau", oldFlip.tau());
        require(newFlip.ilk() == ilk, "non-matching-ilk");
        require(newFlip.cat() == address(newCat), "non-matching-cat");
        require(newFlip.vat() == MCD_VAT, "non-matching-vat");
        FlipperMomAbstract(FLIPPER_MOM).deny(MCD_FLIP_USDC_B);


        /*** WBTC-A Flip ***/
        ilk = "WBTC-A";
        newFlip = FlipAbstract(MCD_FLIP_WBTC_A);
        oldFlip = FlipAbstract(MCD_FLIP_WBTC_A_OLD);

        newCat.file(ilk, "flip", address(newFlip));
        newCat.file(ilk, "chop", chop);
        newCat.file(ilk, "dunk", dunk);
        newCat.rely(address(newFlip));

        newFlip.rely(address(newCat));
        newFlip.rely(MCD_END);
        newFlip.rely(FLIPPER_MOM);
        newFlip.file("beg", oldFlip.beg());
        newFlip.file("ttl", oldFlip.ttl());
        newFlip.file("tau", oldFlip.tau());
        require(newFlip.ilk() == ilk, "non-matching-ilk");
        require(newFlip.cat() == address(newCat), "non-matching-cat");
        require(newFlip.vat() == MCD_VAT, "non-matching-vat");


        /*** TUSD-A Flip ***/
        ilk = "TUSD-A";
        newFlip = FlipAbstract(MCD_FLIP_TUSD_A);
        oldFlip = FlipAbstract(MCD_FLIP_TUSD_A_OLD);

        newCat.file(ilk, "flip", address(newFlip));
        newCat.file(ilk, "chop", chop);
        newCat.file(ilk, "dunk", dunk);
        newCat.rely(address(newFlip));

        newFlip.rely(address(newCat)); // This will be denied after via FlipperMom, just doing this for explicitness
        newFlip.rely(MCD_END);
        newFlip.rely(FLIPPER_MOM);
        newFlip.file("beg", oldFlip.beg());
        newFlip.file("ttl", oldFlip.ttl());
        newFlip.file("tau", oldFlip.tau());
        require(newFlip.ilk() == ilk, "non-matching-ilk");
        require(newFlip.cat() == address(newCat), "non-matching-cat");
        require(newFlip.vat() == MCD_VAT, "non-matching-vat");
        FlipperMomAbstract(FLIPPER_MOM).deny(MCD_FLIP_TUSD_A); 


        /*** ZRX-A Flip ***/
        ilk = "ZRX-A";
        newFlip = FlipAbstract(MCD_FLIP_ZRX_A);
        oldFlip = FlipAbstract(MCD_FLIP_ZRX_A_OLD);

        newCat.file(ilk, "flip", address(newFlip));
        newCat.file(ilk, "chop", chop);
        newCat.file(ilk, "dunk", dunk);
        newCat.rely(address(newFlip));

        newFlip.rely(address(newCat));
        newFlip.rely(MCD_END);
        newFlip.rely(FLIPPER_MOM);
        newFlip.file("beg", oldFlip.beg());
        newFlip.file("ttl", oldFlip.ttl());
        newFlip.file("tau", oldFlip.tau());
        require(newFlip.ilk() == ilk, "non-matching-ilk");
        require(newFlip.cat() == address(newCat), "non-matching-cat");
        require(newFlip.vat() == MCD_VAT, "non-matching-vat");


        /*** KNC-A Flip ***/
        ilk = "KNC-A";
        newFlip = FlipAbstract(MCD_FLIP_KNC_A);
        oldFlip = FlipAbstract(MCD_FLIP_KNC_A_OLD);

        newCat.file(ilk, "flip", address(newFlip));
        newCat.file(ilk, "chop", chop);
        newCat.file(ilk, "dunk", dunk);
        newCat.rely(address(newFlip));

        newFlip.rely(address(newCat));
        newFlip.rely(MCD_END);
        newFlip.rely(FLIPPER_MOM);
        newFlip.file("beg", oldFlip.beg());
        newFlip.file("ttl", oldFlip.ttl());
        newFlip.file("tau", oldFlip.tau());
        require(newFlip.ilk() == ilk, "non-matching-ilk");
        require(newFlip.cat() == address(newCat), "non-matching-cat");
        require(newFlip.vat() == MCD_VAT, "non-matching-vat");


        /*** MANA-A Flip ***/
        ilk = "MANA-A";
        newFlip = FlipAbstract(MCD_FLIP_MANA_A);
        oldFlip = FlipAbstract(MCD_FLIP_MANA_A_OLD);

        newCat.file(ilk, "flip", address(newFlip));
        newCat.file(ilk, "chop", chop);
        newCat.file(ilk, "dunk", dunk);
        newCat.rely(address(newFlip));

        newFlip.rely(address(newCat));
        newFlip.rely(MCD_END);
        newFlip.rely(FLIPPER_MOM);
        newFlip.file("beg", oldFlip.beg());
        newFlip.file("ttl", oldFlip.ttl());
        newFlip.file("tau", oldFlip.tau());
        require(newFlip.ilk() == ilk, "non-matching-ilk");
        require(newFlip.cat() == address(newCat), "non-matching-cat");
        require(newFlip.vat() == MCD_VAT, "non-matching-vat");
    }
}

contract DssSpell {
    DSPauseAbstract public pause =
        DSPauseAbstract(0x8754E6ecb4fe68DaA5132c2886aB39297a5c7189);
    address         public action;
    bytes32         public tag;
    uint256         public eta;
    bytes           public sig;
    uint256         public expiration;
    bool            public done;

    constructor() public {
        sig = abi.encodeWithSignature("execute()");
        action = address(new SpellAction());
        bytes32 _tag;
        address _action = action;
        assembly { _tag := extcodehash(_action) }
        tag = _tag;
        expiration = now + 30 days;
    }

    function description() public view returns (string memory) {
        return SpellAction(action).description();
    }

    function schedule() public {
        require(now <= expiration, "This contract has expired");
        require(eta == 0, "This spell has already been scheduled");
        eta = now + DSPauseAbstract(pause).delay();
        pause.plot(action, tag, sig, eta);
    }

    function cast() public {
        require(!done, "spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
}