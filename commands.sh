sui move build

sui client publish ./sources/travelswap_reward_token.move --gas-budget 100000000

sui client call --function mint --module travl_rt --package 0x59723610fb92b3e1d83b20cffda010378b00a23dc43a07b670941082c999b0be --gas-budget 10000000 --args "0x73f7e035319941393f0bb01d79431d1e5ce0e0558d7a32f812d001b063f16d59" 10000000 "0xfe9c062121f4fc3c1d7b543a36eff8139e35cbe6dd603e89593e72c98840810b"

