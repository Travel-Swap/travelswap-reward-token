sui move build

sui client publish ./sources/travelswap_reward_token.move --gas-budget 20000000

sui client call --function mint --module travl_rt --package 0x3cda8223ac0b27b5711d3a402758668689497f4d9c5561d62b5bd0a6fabbd656 --gas-budget 10000000 --args "0x4dba046038735b57f626d0ce9b07e0731e2d824a7e4be7f470bf799668fc34e8" 10000000 "0xfe9c062121f4fc3c1d7b543a36eff8139e35cbe6dd603e89593e72c98840810b"