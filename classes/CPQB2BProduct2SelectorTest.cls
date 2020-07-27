/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
* @author Amil Abdallah
* @date 02/17/2020
*
* @description Product2SelectorTest class that handles code coverage against the Product2Selector class
*/

@isTest
public class CPQB2BProduct2SelectorTest {
    @isTest
    public static void testGetProductByName(){
        Product2 product = new Product2();
        product.Name = 'CPQB2B - TestProduct';
        product.ProductCode = 'TEST-1234';
        product.IsActive = true;
        insert product;

        CPQB2BProduct2Selector p2s = new CPQB2BProduct2Selector();
        List<Product2> productList = p2s.getProductByName('CPQB2B - TestProduct');

        System.assertEquals(1, productList.size(),'The returned list size of: ' + productList.size() + ' does not match the expected value of 1');
    }

    @isTest
    public static void testSelectById(){
        Product2 product = new Product2();
        product.Name = 'CPQB2B - TestProduct';
        product.ProductCode = 'TEST-1234';
        product.IsActive = true;
        insert product;

        CPQB2BProduct2Selector p2s = new CPQB2BProduct2Selector();
        Product2 queriedProduct = p2s.selectById(product.Id);

        System.assertEquals(product.Name, queriedProduct.Name,'The returned product record name: ' + queriedProduct.Name + ' does not match the expected value of ' + product.Name);
    }

    @isTest
    public static void testSelectByIds(){
        List<Product2> prodList = new List<Product2>();

        Product2 p1 = new Product2();
        p1.Name = 'CPQB2B - TestProduct';
        p1.ProductCode = 'TEST-1234';
        p1.IsActive = true;
        prodList.add(p1);

        Product2 p2 = new Product2();
        p2.Name = 'CPQB2B - TestProduct2';
        p2.ProductCode = 'TEST-1235';
        p2.IsActive = true;     
        prodList.add(p2);

        insert prodList;

        List<Id> prodIds = new List<Id>();
        for(Product2 prod : prodList){
            prodIds.add(prod.Id);
        }

        CPQB2BProduct2Selector p2s = new CPQB2BProduct2Selector();
        List<Product2> queriedProducts = p2s.selectByIds(prodIds);

        System.assertEquals(2,queriedProducts.size(),'The returned list size of ' + queriedProducts.size() + 'does not match the expected value of 2.');
    }
}