/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

@isTest
public class CPQB2BPriceBookSelectorTest {

    @isTest
    public static void testGetPricebookById(){
        PriceBook2 pb = CPQB2BTestFactory.createPriceBook('PBName', 'PBDescription');
        insert pb;
        
        CPQB2BPriceBookSelector selector = new CPQB2BPriceBookSelector();
        PriceBook2 result = selector.getPricebookById(pb.Id);
        System.assertEquals(pb.Name, result.Name);
        System.assertEquals(pb.Description, result.Description);
        System.assertEquals(pb.IsActive, result.IsActive);
        System.assertEquals(pb.IsStandard, result.IsStandard);
    }

    @isTest
    public static void testGetPricebooksByIds(){
        PriceBook2 pb = CPQB2BTestFactory.createPriceBook('PBName', 'PBDescription');
        insert pb;

        CPQB2BPriceBookSelector selector = new CPQB2BPriceBookSelector();
        List<PriceBook2> results = selector.getPricebooksByIds(new List<Id> {pb.Id});
        System.assertEquals(1, results.size());

        PriceBook2 result = results[0];
        System.assertEquals(pb.Name, result.Name);
        System.assertEquals(pb.Description, result.Description);
        System.assertEquals(pb.IsActive, result.IsActive);
        System.assertEquals(pb.IsStandard, result.IsStandard);
    }
}