//
// Copyright 2020-2022 Signal Messenger, LLC.
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import SignalFfi

public func signalEncrypt<Bytes: ContiguousBytes>(
    message: Bytes,
    for address: ProtocolAddress,
    sessionStore: SessionStore,
    identityStore: IdentityKeyStore,
    now: Date = Date(),
    context: StoreContext
) throws -> CiphertextMessage {
    return try withAllBorrowed(address, .bytes(message)) { addressHandle, messageBuffer in
        try withSessionStore(sessionStore, context) { ffiSessionStore in
            try withIdentityKeyStore(identityStore, context) { ffiIdentityStore in
                try invokeFnReturningNativeHandle {
                    signal_encrypt_message(
                        $0,
                        messageBuffer,
                        addressHandle.const(),
                        ffiSessionStore,
                        ffiIdentityStore,
                        UInt64(now.timeIntervalSince1970 * 1000)
                    )
                }
            }
        }
    }
}

public func signalDecrypt(
    message: SignalMessage,
    from address: ProtocolAddress,
    sessionStore: SessionStore,
    identityStore: IdentityKeyStore,
    context: StoreContext
) throws -> Data {
    return try withAllBorrowed(message, address) { messageHandle, addressHandle in
        try withSessionStore(sessionStore, context) { ffiSessionStore in
            try withIdentityKeyStore(identityStore, context) { ffiIdentityStore in
                try invokeFnReturningData {
                    signal_decrypt_message(
                        $0,
                        messageHandle.const(),
                        addressHandle.const(),
                        ffiSessionStore,
                        ffiIdentityStore
                    )
                }
            }
        }
    }
}

public func signalDecryptPreKey(
    message: PreKeySignalMessage,
    from address: ProtocolAddress,
    sessionStore: SessionStore,
    identityStore: IdentityKeyStore,
    preKeyStore: PreKeyStore,
    signedPreKeyStore: SignedPreKeyStore,
    kyberPreKeyStore: KyberPreKeyStore,
    context: StoreContext,
    usePqRatchet: Bool
) throws -> Data {
    return try withAllBorrowed(message, address) { messageHandle, addressHandle in
        try withSessionStore(sessionStore, context) { ffiSessionStore in
            try withIdentityKeyStore(identityStore, context) { ffiIdentityStore in
                try withPreKeyStore(preKeyStore, context) { ffiPreKeyStore in
                    try withSignedPreKeyStore(signedPreKeyStore, context) { ffiSignedPreKeyStore in
                        try withKyberPreKeyStore(kyberPreKeyStore, context) { ffiKyberPreKeyStore in
                            try invokeFnReturningData {
                                signal_decrypt_pre_key_message(
                                    $0,
                                    messageHandle.const(),
                                    addressHandle.const(),
                                    ffiSessionStore,
                                    ffiIdentityStore,
                                    ffiPreKeyStore,
                                    ffiSignedPreKeyStore,
                                    ffiKyberPreKeyStore,
                                    usePqRatchet
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

public func processPreKeyBundle(
    _ bundle: PreKeyBundle,
    for address: ProtocolAddress,
    sessionStore: SessionStore,
    identityStore: IdentityKeyStore,
    now: Date = Date(),
    context: StoreContext,
    usePqRatchet: Bool
) throws {
    return try withAllBorrowed(bundle, address) { bundleHandle, addressHandle in
        try withSessionStore(sessionStore, context) { ffiSessionStore in
            try withIdentityKeyStore(identityStore, context) { ffiIdentityStore in
                try checkError(
                    signal_process_prekey_bundle(
                        bundleHandle.const(),
                        addressHandle.const(),
                        ffiSessionStore,
                        ffiIdentityStore,
                        UInt64(now.timeIntervalSince1970 * 1000),
                        usePqRatchet
                    )
                )
            }
        }
    }
}

public func groupEncrypt<Bytes: ContiguousBytes>(
    _ message: Bytes,
    from sender: ProtocolAddress,
    distributionId: UUID,
    store: SenderKeyStore,
    context: StoreContext
) throws -> CiphertextMessage {
    return try withAllBorrowed(sender, .bytes(message), distributionId) { senderHandle, messageBuffer, distributionId in
        try withSenderKeyStore(store, context) { ffiStore in
            try invokeFnReturningNativeHandle {
                signal_group_encrypt_message($0, senderHandle.const(), distributionId, messageBuffer, ffiStore)
            }
        }
    }
}

public func groupDecrypt<Bytes: ContiguousBytes>(
    _ message: Bytes,
    from sender: ProtocolAddress,
    store: SenderKeyStore,
    context: StoreContext
) throws -> Data {
    return try withAllBorrowed(sender, .bytes(message)) { senderHandle, messageBuffer in
        try withSenderKeyStore(store, context) { ffiStore in
            try invokeFnReturningData {
                signal_group_decrypt_message($0, senderHandle.const(), messageBuffer, ffiStore)
            }
        }
    }
}

public func processSenderKeyDistributionMessage(
    _ message: SenderKeyDistributionMessage,
    from sender: ProtocolAddress,
    store: SenderKeyStore,
    context: StoreContext
) throws {
    return try withAllBorrowed(sender, message) { senderHandle, messageHandle in
        try withSenderKeyStore(store, context) {
            try checkError(
                signal_process_sender_key_distribution_message(
                    senderHandle.const(),
                    messageHandle.const(),
                    $0
                )
            )
        }
    }
}
