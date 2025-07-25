//
// Copyright 2020-2021 Signal Messenger, LLC.
// SPDX-License-Identifier: AGPL-3.0-only
//

import ByteArray from './internal/ByteArray';

export default class NotarySignature extends ByteArray {
  private readonly __type?: never;
  static SIZE = 64;

  constructor(contents: Uint8Array) {
    super(contents, NotarySignature.checkLength(NotarySignature.SIZE));
  }
}
