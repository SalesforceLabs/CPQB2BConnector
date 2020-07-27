/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

trigger CPQB2BCCOrderTrigger on ccrz__E_Order__c (after insert, after update) {
    CPQB2BDomain.triggerHandler(CPQB2BCCOrderDomain.class);
}