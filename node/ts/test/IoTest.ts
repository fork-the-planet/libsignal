//
// Copyright 2024 Signal Messenger, LLC.
// SPDX-License-Identifier: AGPL-3.0-only
//

import { use } from 'chai';
import * as chaiAsPromised from 'chai-as-promised';

import * as Native from '../../Native';
import { Uint8ArrayInputStream } from './ioutil';
import { assertArrayEquals } from './util';

use(chaiAsPromised);

const CAPS_ALPHABET_INPUT = Buffer.from('ABCDEFGHIJKLMNOPQRSTUVWXYZ');

describe('InputStream', () => {
  it('handles reads into empty buffers', async () => {
    const input = new Uint8ArrayInputStream(CAPS_ALPHABET_INPUT);
    const output = await Native.TESTING_InputStreamReadIntoZeroLengthSlice(
      input
    );
    assertArrayEquals(output, CAPS_ALPHABET_INPUT);
  });
});
