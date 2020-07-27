/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
 * @description Trigger to handle of syncing OrderItems to CC Order Items
 */
trigger CPQB2BOrderItemTrigger on OrderItem (after insert, after update) {
    CPQB2BDomain.triggerHandler(CPQB2BOrderItemDomain.class);
}