#include <eosio/eosio.hpp>

using namespace eosio;

class [[eosio::contract]] action_results : public contract {
  public:
      using contract::contract;

      [[eosio::action]]
      int sum(int valueA, int valueB) {
         return valueA + valueB;
      }

  private:
};