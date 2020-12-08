project( action_return_value )
cmake_minimum_required( VERSION 3.18 )

set( EOSIO_WASM_OLD_BEHAVIOR "Off" )
find_package( eosio.cdt )

add_contract( action_return_value action_return_value action_return_value.cpp )
target_ricardian_directory( action_return_value ${CMAKE_SOURCE_DIR}/../ricardian )
