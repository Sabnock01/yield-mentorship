
# include .env file and export its env vars (-include to ignore error if it does not exist)
-include .env

deploy:
	forge create src/SimpleNameRegister.sol:SimpleNameRegister --private-key ${PK} --rpc-url ${RPC_URL}

verify:
	forge verify-contract --chain-id ${CHAIN_ID} --compiler-version ${COMPILER_VERSION} ${CONTRACT_ADDRESS} ${CONTRACT} ${ETHERSCAN_API_KEY} --num-of-optimizations 200 --flatten

verify-check:
	forge verify-check --chain-id ${CHAIN_ID} ${GUID} ${ETHERSCAN_API_KEY}
