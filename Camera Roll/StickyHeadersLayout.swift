//
//  StickyHeadersLayout.swift
//  Camera Roll
//
//  Created by Mic Pringle on 18/03/2015.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//
// modified by Dave Rothschild May 7, 2016

import UIKit

class StickyHeadersLayout: UICollectionViewFlowLayout {
  
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    
    // get layout attributes
    var layoutAttributes = super.layoutAttributesForElementsInRect(rect)! as [UICollectionViewLayoutAttributes]
    
    // look for missing headers and hold on for later
    let headersNeedingLayout = NSMutableIndexSet()
    
    // loop through to see which ones to care about
    for attributes in layoutAttributes {
      if attributes.representedElementCategory == .Cell {
        headersNeedingLayout.addIndex(attributes.indexPath.section)
      }
    }
    // remove any where layout attributes are already in the array
    for attributes in layoutAttributes {
      if let elementKind = attributes.representedElementKind {
        if elementKind == UICollectionElementKindSectionHeader {
            // remove because super class has already taken care of the layout attributes
          headersNeedingLayout.removeIndex(attributes.indexPath.section)
        }
      }
    }
    
    // now headers needing layout only contains sections where we need layout engine to handle the layout attributes
    headersNeedingLayout.enumerateIndexesUsingBlock { (index, stop) -> Void in
      let indexPath = NSIndexPath(forItem: 0, inSection: index)
        
        // pass index to element kind, then we have all the layout attributes
      let attributes = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: indexPath)
      layoutAttributes.append(attributes!)
    }
    
    
    // now applying the three rules
    for attributes in layoutAttributes {
      if let elementKind = attributes.representedElementKind {
        if elementKind == UICollectionElementKindSectionHeader {
            
            // get section header belongs to
          let section = attributes.indexPath.section
            
            // then get layout attributes for first and last items in that section
          let attributesForFirstItemInSection = layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: section))
          let attributesForLastItemInSection = layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: collectionView!.numberOfItemsInSection(section) - 1, inSection: section))
            // get the frame of the current header
          var frame = attributes.frame
            
            // get Y value of collection view content offset
          let offset = collectionView!.contentOffset.y
          
          /* The header should never go further up than one-header-height above
             the upper bounds of the first cell in the current section */
          let minY = CGRectGetMinY(attributesForFirstItemInSection!.frame) - frame.height
          /* The header should never go further down than one-header-height above
             the lower bounds of the last cell in the section */
          let maxY = CGRectGetMaxY(attributesForLastItemInSection!.frame) - frame.height
          /* If it doesn't break either of those two rules then it should be 
             positioned using the y value of the content offset */
          let y = min(max(offset, minY), maxY)
          
          frame.origin.y = y
          attributes.frame = frame
            // set high to make sure it appears on the top of the views
          attributes.zIndex = 99
        }
      }
    }
    // return layout attributes array
    return layoutAttributes
  }
  
  override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
    return true
  }
  
}
