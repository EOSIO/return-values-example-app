# Sample Return Values Application
![EOSIO Alpha](https://img.shields.io/badge/EOSIO-Alpha-blue.svg) ![EOSIO Labs](https://img.shields.io/badge/EOSIO-Labs-5cb3ff.svg)

# About EOSIO Labs

EOSIO Labs repositories are experimental.  Developers in the community are encouraged to use EOSIO Labs repositories as the basis for code and concepts to incorporate into their applications. Community members are also welcome to contribute and further develop these repositories. Since these repositories are not supported by Block.one, we may not provide responses to issue reports, pull requests, updates to functionality, or other requests from the community, and we encourage the community to take responsibility for these.

Sample Return Values Application lets developers start using the new action return values feature with eosio and eosjs in a matter of minutes. 

Powered by Gitpod.io and Docker, it provides developers with a personal single-node EOSIO blockchain for development and testing purposes without a need of going through advanced local environment setup. It also includes a simple example application with a concise smart contract and web frontend, connected to the blockchain. Developers can also use EOSIO tools like cleos and eosio.cdt straight out of the box. This project requires zero installation on the user's machine. All code is stored and managed on the developer's personal GitHub account, with the changes saved automatically.

We built this example application with ease of use and simplicity in mind. It can be used by new and advanced developers to try out the new action return values feature.

We hope you will find this example application insightful and welcome feedback on future improvements.

# Setup

1. Fork this repo to your personal GitHub account so that you can save your work into your personal Github account.

2. Point your browser to the following URL https://gitpod.io/#https://github.com/your-github-account/sample-return-values-application to start the IDE. You will be automatically prompted to create a Gitpod account (all types of Gitpod accounts (including free) will work). You can also choose to provide multiple developers push access to your personal github fork of this repo to collaborate with them (one developer working on the smart contract (C++) while the other working on the front-end decentralized application (EOSJS), etc.). Each such developer sharing access to the forked repo will get their own copy of the EOSIO blockchain components to enable independent development.

You can test drive the system by accessing the IDE at https://gitpod.io/#https://github.com/EOSIO/sample-return-values-application (however you will not be able to save your work into the EOSIO/sample-return-values-application Github repository)

# Instructions

The following instructions assume that the Web IDE was started successfully (see [Setup](#setup)).

## Initial State

The example application has the simple smart contract located in `contracts`.  This version is already set on the chain and is available after the chain initializes.  Upon launching the IDE, the nodeos and webpack processes will start the chain and webapp respectively and you can test the simple number addition action the smart contract has. 

## Opening a terminal

To open a terminal, use the Terminal drop-down menu in the IDE user interface.

## Building sample contract

The source code for the sample smart contract is in `contracts` if you would like to change the contract and set a new version to the chain.  To compile the contract, run these commands in a new terminal or at the root folder of the workspace in an existing terminal:

```
eosio-cpp contracts/action_results.cpp
```

This will produce `action_results.abi` and `action_results.wasm` in the directory you ran the command.

## Installing the contract

Run this in a terminal from the directory you ran the previous command:

```
cleos set abi returnvalue ./action_results.abi -p returnvalue@active -p eosio@active
cleos set code returnvalue ./action_results.wasm -p returnvalue@active -p eosio@active
```

## Viewing the front-end decentralized web app (EOSJS):

The source code for the React WebApp is at `webapp/src/index.tsx` within the IDE. To preview the WebApp run this in a terminal:

```
gp preview $(gp url 8000)
```

## Resetting the chain

To remove the existing chain and create another:

* Switch to the terminal running `nodeos`
* Press `ctrl+c` to stop it
* Run the following

```
rm -rf ~/eosio/chain
nodeos --config-dir ~/eosio/chain/config --data-dir ~/eosio/chain/data -e -p eosio --plugin eosio::chain_api_plugin
```

## Contributing

[Contributing Guide](./CONTRIBUTING.md)

[Code of Conduct](./CONTRIBUTING.md#conduct)

## License

[MIT](./LICENSE)

## Important

See [LICENSE](./LICENSE) for copyright and license terms.

All repositories and other materials are provided subject to the terms of this [IMPORTANT](./IMPORTANT.md) notice and you must familiarize yourself with its terms.  The notice contains important information, limitations and restrictions relating to our software, publications, trademarks, third-party resources, and forward-looking statements.  By accessing any of our repositories and other materials, you accept and agree to the terms of the notice.
