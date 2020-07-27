/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
 * @description Trigger to handle of syncing Orders to CC Orders
 */
trigger CPQB2BOrderTrigger on Order (after insert, after update) {
    CPQB2BDomain.triggerHandler(CPQB2BOrderDomain.class);
}