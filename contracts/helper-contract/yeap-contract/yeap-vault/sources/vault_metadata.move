module yeap_vault::vault_metadata {
    use aptos_framework::object;
    use aptos_framework::fungible_asset;
    use aptos_framework::error;

    struct VaultMetadata has copy, drop, key {
        underlying_store: object::Object<fungible_asset::FungibleStore>,
    }

    public fun vault_metadata(p0: address): object::Object<fungible_asset::Metadata> {
        object::address_to_object<fungible_asset::Metadata>(p0)
    }
    friend fun initialize(p0: &signer, p1: object::Object<fungible_asset::FungibleStore>) {
        let _v0 = VaultMetadata{underlying_store: p1};
        move_to<VaultMetadata>(p0, _v0);
    }
    public fun assert_is_vault(p0: address) {
        if (!object::object_exists<VaultMetadata>(p0)) {
            let _v0 = error::unauthenticated(3);
            abort _v0
        };
    }
    public fun debt_metadata(p0: address): object::Object<fungible_asset::Metadata> {
        object::address_to_object<fungible_asset::Metadata>(object::create_object_address(&p0, vector[100u8, 101u8, 98u8, 116u8]))
    }
    public fun governance_object(p0: address): address {
        object::create_object_address(&p0, vector[118u8, 97u8, 117u8, 108u8, 116u8, 95u8, 99u8, 111u8, 110u8, 102u8, 105u8, 103u8])
    }
    public fun underlying_asset_store(p0: address): object::Object<fungible_asset::FungibleStore>
        acquires VaultMetadata
    {
        *&borrow_global<VaultMetadata>(p0).underlying_store
    }
    public fun underlying_asset_metadata(p0: address): object::Object<fungible_asset::Metadata>
        acquires VaultMetadata
    {
        fungible_asset::store_metadata<fungible_asset::FungibleStore>(underlying_asset_store(p0))
    }
}
