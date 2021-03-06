/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

trigger CPQB2BProduct2Trigger on Product2 (after insert, after update) {
    CPQB2BDomain.triggerHandler(CPQB2BProduct2Domain.class);
}