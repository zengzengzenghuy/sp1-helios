// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import {SP1LightClient} from "../src/SP1LightClient.sol";
import {SP1MockVerifier} from "@sp1-contracts/SP1MockVerifier.sol";
import {ISP1Verifier} from "@sp1-contracts/ISP1Verifier.sol";

// Required environment variables:
// - SP1_PROVER
// - SP1_BLOBSTREAM_PROGRAM_VKEY
// - CREATE2_SALT
// - SP1_VERIFIER_ADDRESS
        // bytes32 genesisValidatorsRoot,
        // uint256 genesisTime,
        // uint256 secondsPerSlot,
        // uint256 slotsPerPeriod,
        // bytes32 syncCommitteeHash,
        // bytes32 telepathyProgramVkey,
contract DeployScript is Script {
    function setUp() public {}

    function run() public returns (address) {
        vm.startBroadcast();

        ISP1Verifier verifier;
        // Detect if the SP1_PROVER is set to mock, and pick the correct verifier.
        string memory mockStr = "mock";
        if (
            keccak256(abi.encodePacked(vm.envString("SP1_PROVER")))
                == keccak256(abi.encodePacked(mockStr))
        ) {
            verifier = ISP1Verifier(address(new SP1MockVerifier()));
        } else {
            verifier = ISP1Verifier(address(vm.envAddress("SP1_VERIFIER_ADDRESS")));
        }


        // Deploy the SP1Telepathy contract.
        SP1LightClient lightClient =
            new SP1LightClient{salt: bytes32(vm.envBytes("CREATE2_SALT"))}(
                vm.envBytes32("GENESIS_VALIDATORS_ROOT"),
                vm.envUint("GENESIS_TIME"),
                vm.envUint("SECONDS_PER_SLOT"),
                vm.envUint("SLOTS_PER_PERIOD"),
                vm.envBytes32("SYNC_COMMITTEE_HASH"),
                vm.envBytes32("FINALIZED_HEADER"),
                vm.envUint("HEAD"),
                vm.envBytes32("SP1_TELEPATHY_PROGRAM_VKEY"),
                address(verifier)
            );

        return address(lightClient);
    }
}