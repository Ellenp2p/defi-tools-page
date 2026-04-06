module contract::yeap {
    // use std::reflect;
    // use std::string;
    // use aptos_framework::object;
    use aptos_framework::fungible_asset::Metadata;
    use aptos_framework::primary_fungible_store;
    use yeap_vault::vault_lens;
    use yeap_vault::vault_metadata;

    #[view]
    public fun get_withdraw(
        metadata: address,
        amount: u64
    ): u64 {
        // let preview_withdraw : |address, u64|u64 = reflect::resolve(@0x7b90b95e1060d9d2e424c6687ba03cccaed6996cccd4868b759c9fca361fa70, &string::utf8(b"vault_lens"), &string::utf8(b"preview_withdraw")).unwrap();
        // preview_withdraw(metadata, amount)
        vault_lens::preview_redeem(metadata, amount)
    }

    #[view]
    public fun get_withdraw_by_user(
        user: address,
        metadata: address
    ): u64 {
        // let preview_withdraw : |address, u64|u64 = reflect::resolve(@0x7b90b95e1060d9d2e424c6687ba03cccaed6996cccd4868b759c9fca361fa70, &string::utf8(b"vault_lens"), &string::utf8(b"preview_deposit")).unwrap();
        // let vault_metadata: |address| object::Object<Metadata> = reflect::resolve(@0x7b90b95e1060d9d2e424c6687ba03cccaed6996cccd4868b759c9fca361fa70, &string::utf8(b"vault_metadata"), &string::utf8(b"vault_metadata")).unwrap();
        // let token_metadata = vault_metadata(metadata);
        // let amount = primary_fungible_store::balance<Metadata>(user , token_metadata);
        // preview_withdraw(metadata, amount)
        let token_metadata = vault_metadata::vault_metadata(metadata);
        let amount = primary_fungible_store::balance<Metadata>(user , token_metadata);
        vault_lens::preview_redeem(metadata, amount)
    }


}