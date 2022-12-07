import requests
import json
from web3 import Web3, HTTPProvider

# ANTES:
# 1. sudo ganache-cli -h 0.0.0.0 -p 8545
# 2. sudo truffle console, migrate
# 3. Copiar "contract address" de "Deploying 'RedePostos'" para deployed_contract_address 
deployed_contract_address = '0x827B0F219b57936C3C9D3c45cc61b35C0Eb68Ce0'
# 4. python3 firebaseDemo.py

blockchain_address = 'http://0.0.0.0:8545'
compiled_contract_path = 'build/contracts/RedePostos.json'
link = "https://testefirebase-1458a-default-rtdb.firebaseio.com/"

web3 = Web3(HTTPProvider(blockchain_address))
web3.eth.defaultAccount = web3.eth.accounts[0]

valor = 0
print ("Conectando ao banco de dados no Firebase para processar a compra...")
api = requests.get(f'{link}/TCC_copy/ABASTECER/VALOR/.json', data=json.dumps(valor))
print (str("Response do input do Firebase (\"GET\"): ") + str(api))
valorSolicitado = api.json()
print ("Resultado (valor obtido, em reais): " + valorSolicitado + "\n")

while valorSolicitado != '':
    with open(compiled_contract_path) as file:
        contract_json = json.load(file)
    contract_abi = contract_json['abi']

    contract = web3.eth.contract(address=deployed_contract_address, abi=contract_abi)

    print ("Conectando ao smart contract...")
    message = contract.functions.digaOla().call()
    print(str("Resposta básica do smart contract: ") + message + "\n")

    dados = {'transferido': valorSolicitado}
    print ("Conectando ao banco de dados no Firebase para liberar o abastecimento via Arduino...")
    req = requests.patch(f'{link}TESTE_FIREBASE/Validacao/-NIemd7leghZjzoSUtYB/.json', data=json.dumps(dados))
    print(str("Response do output ao Firebase (\"POST\"): ") + str(req))
    print(str("Payload: ") + str(req.text) + "\n")
    break



