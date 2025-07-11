//
// Copyright 2021 Signal Messenger, LLC.
// SPDX-License-Identifier: AGPL-3.0-only
//

import { randomBytes } from 'crypto';
import * as Native from '../../../Native';
import { RANDOM_LENGTH } from '../internal/Constants';
import ServerSecretParams from '../ServerSecretParams';
import ReceiptCredentialRequest from './ReceiptCredentialRequest';
import ReceiptCredentialResponse from './ReceiptCredentialResponse';
import ReceiptCredentialPresentation from './ReceiptCredentialPresentation';

export default class ServerZkReceiptOperations {
  serverSecretParams: ServerSecretParams;

  constructor(serverSecretParams: ServerSecretParams) {
    this.serverSecretParams = serverSecretParams;
  }

  issueReceiptCredential(
    receiptCredentialRequest: ReceiptCredentialRequest,
    receiptExpirationTime: number,
    receiptLevel: bigint
  ): ReceiptCredentialResponse {
    const random = randomBytes(RANDOM_LENGTH);
    return this.issueReceiptCredentialWithRandom(
      random,
      receiptCredentialRequest,
      receiptExpirationTime,
      receiptLevel
    );
  }

  issueReceiptCredentialWithRandom(
    random: Uint8Array,
    receiptCredentialRequest: ReceiptCredentialRequest,
    receiptExpirationTime: number,
    receiptLevel: bigint
  ): ReceiptCredentialResponse {
    return new ReceiptCredentialResponse(
      Native.ServerSecretParams_IssueReceiptCredentialDeterministic(
        this.serverSecretParams,
        random,
        receiptCredentialRequest.getContents(),
        receiptExpirationTime,
        receiptLevel
      )
    );
  }

  verifyReceiptCredentialPresentation(
    receiptCredentialPresentation: ReceiptCredentialPresentation
  ): void {
    Native.ServerSecretParams_VerifyReceiptCredentialPresentation(
      this.serverSecretParams,
      receiptCredentialPresentation.getContents()
    );
  }
}
